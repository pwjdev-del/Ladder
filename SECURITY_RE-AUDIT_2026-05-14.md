# SECURITY RE-AUDIT — Ladder v1.0 audit-fix sweep — 2026-05-14

**Commit audited:** `ae1a364` on `fix/v1.0-audit-sweep`
**Verdict: SHIP_WITH_FIXES**

Three of four S1 findings are closed in code. One (S1-2) is partial — code is correct but ships depending on a production dashboard step that, if forgotten, fail-closes the entire app for every role (not just founders). No NEW S1s introduced by the sweep, but four NEW S2s found, plus the operational risk around S1-2 deployment.

---

## S1 verdicts

### S1-1 — Founder TOTP test vector → ✅ CLOSED

- `JBSWY3DPEHPK3PXP` and `PLACEHOLDER_TOTP_SECRET` removed from active code. Only mention left is a historical reference in the comment block of `LadderBackend/supabase/migrations/0020_founder_totp_decrypt.sql:9` — documentation, not executable.
- `LadderBackend/supabase/functions/founder-login/index.ts:218-220` calls `supa.rpc('decrypt_founder_totp', { p_user_id: userId })` and verifies with the returned secret. Test vector cannot be re-introduced without DB change.
- Migration `0020_founder_totp_decrypt.sql:158-208` provides `app.decrypt_founder_totp(uuid)` with `SECURITY DEFINER`, FSK from Vault, granted only to `service_role`.

### S1-2 — `bind_session()` pre-request hook → ⚠ PARTIAL (deployment-dependent)

- `LadderBackend/supabase/config.toml:59` sets `db_pre_request = "app.bind_session"`. **Local-dev only.**
- Production env var requirement (`PGRST_DB_PRE_REQUEST=app.bind_session`) is documented in `config.toml:26-34` and `migration 0020:302-305`. **Dashboard step is manual and not automatable from this repo.**
- **OPERATIONAL RISK (verified):** Migration 0022 adds 25 RESTRICTIVE `_no_founder` policies whose `USING (NOT app.is_founder())` clause depends on `bind_session` having set `app.role`. `app.is_founder()` (migration `0009:29-36`) is `SELECT current_setting('app.role', true) = 'founder'`. When the hook is not configured, `app.role` is NULL → `NULL = 'founder'` returns NULL → `NOT NULL` is NULL → RESTRICTIVE policy evaluates NULL → Postgres treats as FALSE → **ALL roles get 0 rows on 25 tables** including students, classes, grades, schedules, essays, ai_chats. App is bricked silently for every user.
- If the dashboard step is not applied, this is no longer just "counselor SIA surface ships broken" (the prior S1-2 statement) — the entire student experience also ships broken.

**Recommendation:** Add a production smoke test in CI that asserts a student SELECT against `students` returns ≥1 row using a real JWT (not service_role). Fail deploy if zero rows. Also: document the dashboard step in DEPLOY.md as a release blocker.

### S1-3 — Supabase SDK TLS pinning → ⚠ PARTIAL

- `LadderApp/Services/Auth/SupabaseAuthService.swift:124-139` wires `SupabaseClientOptions.GlobalOptions(session: TLSPinnedSessionFactory.shared.session)`. ✅
- `LadderApp/Services/Networking/TLSPinnedSession.swift:17` pins `seicofzlgwjqkggscvao.supabase.co`. ✅
- **Verified via supabase-swift SDK source** (Sources/Supabase/SupabaseClient.swift:130-200): the global session propagates to **Auth (line 188), PostgREST (line 53 → `fetchWithAuth` → line 339 `session.data(for:)`), Storage (line 71), and Functions (line 102)**. ✅
- **GAP:** `RealtimeClient` (Supabase 2.x) is constructed at line 193-199 without `options.global.session`. Realtime uses its own internal WebSocket transport that bypasses the pinned URLSession. The current iOS codebase does **not** use Realtime (`grep -r realtimeV2 LadderApp/` returns nothing), so this is unexploited today, but flag as **S3** to prevent a future regression when someone adds a "live counselor presence" or "live SIA" subscription.

### S1-4 — SwiftData wipe on signOut → ✅ CLOSED (with documented best-effort caveat)

- `SupabaseAuthService.swift:293` calls `SwiftDataWipeRegistry.wipeAll(hashedUserId:)` BEFORE clearing the GoTrue session (correct ordering).
- `LadderApp/App/LadderApp.swift:27` calls `SwiftDataWipeRegistry.register(modelContainer)` in `init()`.
- Wipe uses `container.deleteAllData()` (atomic, all-models, iOS 17.4+).
- **Caveat (already known, B3 from prior audits):** if `deleteAllData()` throws (or the container was never registered) the wipe returns `false`, logs to OSLog at `.fault`, and signOut continues. The user is never told. This is documented in `SupabaseAuthService.swift:17-21` as intentional best-effort. **Acceptable for v1.0** — the 7 `@Model` types without `userId` are the underlying issue and addressing those is a larger refactor. Flag as **S2** to track.

---

## NEW findings introduced by the sweep

### S2-NEW-1 — `find_invite_by_hash` RPC may be callable by any authenticated user

`LadderBackend/supabase/migrations/0021_invite_hmac_hash.sql:64-86`

The function is defined in `public` schema with `SECURITY DEFINER` and only `GRANT EXECUTE ... TO service_role` is given — but **no `REVOKE EXECUTE ... FROM public` or `FROM authenticated`**. By default, PostgreSQL grants EXECUTE to `PUBLIC` on new functions unless `ALTER DEFAULT PRIVILEGES` has revoked it for the role/schema. Supabase's default config does not auto-revoke from `authenticated`/`anon` for public-schema functions. Any authenticated user can call `find_invite_by_hash('00..')`. The HMAC secret protects against meaningful exploitation (an attacker without the secret cannot compute valid hashes), but the function returns full `invite_codes` rows (with `intended_email`, `expires_at`, `tenant_id`) — bypassing the edge function's uniform-failure design. **Add explicit `REVOKE EXECUTE ON FUNCTION public.find_invite_by_hash(text) FROM public, anon, authenticated;` in a follow-up migration.**

### S2-NEW-2 — AES-256-CBC without explicit IV (deterministic, no integrity)

`LadderBackend/supabase/migrations/0020_founder_totp_decrypt.sql:191, 248`

`encrypt(data, key, 'aes-cbc')` in pgcrypto uses a zero IV when none is supplied. Result: deterministic ciphertext + no MAC. Practical impact:
- Same plaintext base32 secret → same ciphertext (low risk: each founder secret is randomly generated, so collisions are vanishingly unlikely).
- Malleability: ciphertext can be modified bit-flip style. Mitigation: write requires `service_role`; an attacker with DB write already controls `founder_users` anyway.

This is **S2 (crypto hygiene)**, not S1, but file a follow-up to migrate to `pgsodium.crypto_aead_det_encrypt` (already noted in the migration's own SECTION 1 comments).

### S2-NEW-3 — `founder-login` enumerates founder accounts

`LadderBackend/supabase/functions/founder-login/index.ts:205-211`

Returns 403 `not_a_founder` when the authenticated user is not in `founder_users`, but 401 `invalid_totp` when they are. A student JWT can probe `/functions/v1/founder-login` and learn which auth users are in the founder table by status-code comparison. Combined with knowledge of the founder's email (often public on company pages), this confirms an account is targetable for password spray on the first factor. **Return uniform 401 for both cases.**

### S2-NEW-4 — Realtime client bypasses pinned URLSession

`LadderApp/Services/Auth/SupabaseAuthService.swift:135-139` + supabase-swift `SupabaseClient.swift:193-199`

Realtime (`realtimeV2`) is constructed without the global session injection. Today the app does not subscribe to Realtime channels, so no traffic, but if a future PR adds counselor-presence or live SIA streaming over Realtime instead of the existing SSE Edge Function path, that traffic will be unpinned. Add a runtime guard or `#warning` in code if `client.realtimeV2` is ever accessed. **S3** — defense-in-depth.

### S3-NEW-1 — SwiftData wipe failure silent to user

`SupabaseAuthService.swift:289-296`

The wipe never throws and never surfaces to UI. On failure (B3's 7 unpredicated `@Model` types), Student A's residual data remains and Student B will see it. Add a structured-error path that, on wipe failure, blocks signOut completion and forces a user-visible "Cannot complete sign-out — restart app" alert.

---

## NEW findings — what looks correct on a deeper check

- **Founder-login rate limit ordering** (`founder-login/index.ts:116-167`): JWT verified BEFORE rate-limit RPC. An unauthenticated attacker cannot consume the bucket. ✅
- **Caseload counselor policy join path** (`0022:445-471`): join `counselor_assignments.student_id → students.id → students.user_id = student_memory_summaries.student_user_id` correctly bridges the PK vs auth.uid() indirection noted in A5. Cross-tenant blocked by `ca.tenant_id::text = current_setting('app.tenant_id', true)`. ✅
- **ai-gateway Zod schemas** (`ai-gateway/index.ts:89-122`): per-feature schemas, strict roles, length caps. ✅
- **SSE streaming** is over the same HTTPS connection as the pinned session — TLS protects transport. Pinning IS wired through to Functions (verified above), so MITM is blocked. ✅
- **LegalTexts rewrite** (`LegalTexts.swift`): no weakened commitments. Retention windows (30-day deletion, 90-day backups), FERPA/COPPA language, no-sale, no-advertising clauses all intact. Supabase correctly named as subprocessor. ✅

---

## Recommended next steps (priority order)

1. **Before deploy:** Apply `PGRST_DB_PRE_REQUEST=app.bind_session` in Supabase dashboard AND add CI smoke test asserting student-JWT SELECT against `students` returns rows. Without this, the app bricks for every role on first request.
2. **Before deploy:** Migration 0023 to `REVOKE EXECUTE ON FUNCTION public.find_invite_by_hash(text) FROM public, anon, authenticated;` (S2-NEW-1).
3. **Before deploy:** Patch founder-login to return uniform 401 for both `not_a_founder` and `invalid_totp` (S2-NEW-3).
4. **Pre-TestFlight:** Surface SwiftData wipe failures to UI (S3-NEW-1).
5. **v1.1:** Replace pgcrypto AES-CBC with pgsodium `crypto_aead_det_encrypt` for founder TOTP cipher (S2-NEW-2).
6. **v1.1:** Inject pinned session into Realtime if/when used (S2-NEW-4 / S3-NEW).
