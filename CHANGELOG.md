# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0-rc.1] - 2026-05-14

### Security

- Founder TOTP decryption migrated from placeholder test vector to Vault-backed FSK (migration 0020; SECURITY DEFINER RPC; service-role only).
- Invite redemption now uses HMAC-SHA256 validation with hex bytea storage, eliminating hardcoded whitelist (migration 0021; edge function rewrite).
- Founder-login TOCTOU fixed: rate limit count now post-increment via upsert return value, preventing concurrent-attempt bypass (founder-login/index.ts:116-167).
- Employee-login rate limit TOCTOU fixed identically (employee-login/index.ts).
- `find_invite_by_hash` RPC permissions audited; explicit `REVOKE` from public/anon/authenticated added (migration 0021).

### Bug Fixes

- `AdvisorChatViewModel` now carries `studentId` end-to-end, closing sia_chat client/server contract break (SiaChatInput + CounselorBriefInput schemas aligned).
- Career quiz `q2_build` and `q2_story` branches now resolve to real question bank (CareerQuizView.swift:231; verified across three grade bands).
- Schedule builder picker unblocked via `Menu` component with per-period class catalog (ScheduleBuilderView.swift:99-104).
- Invite-redeem path fixed to HMAC-SHA256 RPC validation (migration 0021; edge-function rewrite; invite-redeem/index.ts:91).
- Student dashboard role routing now reads JWT role claim instead of email prefix (SignedInRouter); grade level reads from `students.grade_level` (SignedInRouter).
- `SupabaseAuthService` now pre-flightCheck fails if Supabase config missing (AppConfiguration.preflightOrCrash).

### AI Safety

- Keyword safety scanner now includes `violence_to_others` prefix-match entries (ai-gateway/index.ts:391-399; closes red-team gap).
- Gemini native `finishReason='SAFETY'` filter now returns canned 988 response (ai-gateway/index.ts:614-625).
- Counselor SiaChatContext narrowing enforced: only assigned-caseload students visible (migration 0022 RESTRICTIVE policies; SiaEngine+Counselor.swift).
- Student-memory summaries and safety_events isolated by counselor caseload join (migration 0022:445-471).

### Product

- Parent dashboard now intentional "Coming soon" placeholder (ParentDashboardView.swift); removes deceptive mock.
- LegalTexts.swift rewritten: no AWS language; retention windows (30-day deletion, 90-day backups) intact; FERPA/COPPA language intact.
- Founder data wall narrowed: 4 RESTRICTIVE policies (`feature_flags_no_founder`, `audit_log_no_founder`, `ai_usage_ledger_no_founder`, `success_metrics_no_founder`) block founder PostgREST access to audit/usage tables (migration 0022).
- Caseload-only join in migration 0022 uses `counselor_assignments → students → student_memory_summaries.student_user_id` correctly; preserves founder mandatory-reporting bypass.

### Infrastructure

- `bind_session()` db-pre-request hook documented in config.toml (config.toml:26-34; migration 0020:302-305). Dashboard env var `PGRST_DB_PRE_REQUEST=app.bind_session` is **manual deploy-day gate** — without it, all 25 RESTRICTIVE policies evaluate NULL → app bricks for every role.
- All six Edge Functions (ai-gateway, founder-login, invite-redeem, bootstrap-user, counselor-invite, varun-validate) deployed and syntax-verified (Deno check: PASS).
- All four database migrations (0020–0023) syntax clean; no DDL issues detected (Wave 3 QA: PASS).

### Deferred to v1.0.1+

- **SwiftData per-student isolation** — S1-4 safety caveat: wipe is best-effort; if `deleteAllData()` throws, wipe returns false, logs to OSLog, signOut continues. Seven `@Model` types lack `userId` attribute; fetch predicates are unpredicated. Mitigation: add `userId` to all seven models (`SATScoreEntryModel`, `ActivityModel`, `GPAEntryModel`, `EssayModel`, `ApplicationModel`, `CareerQuizHistoryModel`, `CollegeModel`), update `StudentContextBuilder` predicates, ship schema migration. **Should fix before v1.0 launch for COPPA/FERPA shared-device compliance; deferred pending refactor scope.**
- **SwiftData wipe-failure UI alert** — S3-NEW-1. Current: silent on wipe failure. Required: wipe-failure blocks signOut, surfaces "Cannot complete sign-out — restart app" alert. ~1 hour change. **Should fix before TestFlight; post-launch acceptable if risk acknowledged in CHANGELOG.**
- **AES-CBC IV hygiene** — S2-NEW-2. Current: pgcrypto `encrypt(..., 'aes-cbc')` uses zero IV (deterministic). Follow-up: migrate to `pgsodium.crypto_aead_det_encrypt` or explicit `gen_random_bytes(16)` IV. **v1.1 crypto hardening; not launch-blocking if each founder secret is randomly generated.**
- **Founder-login enumeration fix** — S2-NEW-3. Current: `founder-login` returns 403 `not_a_founder` (enumerable) vs 401 `invalid_totp`. Follow-up: return uniform 401 for both, log REAL error server-side only. **Post-launch patch acceptable; minor attacker advantage.**
- **Realtime TLS pinning** — S2-NEW-4. Current: Realtime client bypasses pinned URLSession (uses internal WebSocket transport). Today: no Realtime subscriptions in code; unexploited. Follow-up: if future PR adds Realtime, inject pinned session or guard against `client.realtimeV2` access. **v1.1 if Realtime ever used.**
- **Content moderation reporting backend** — D2 finding. Current: `reportMessage` sets UserDefaults only; no Supabase insert. Follow-up: add `reported_messages` table, wire POST in ContentModerationService. **v1.0.1 moderation pipeline.**
- **SiblingSwitcher orphan deletion** — C4 finding. Component defined in DesignSystem; no active caller (ParentDashboardView placeholder has no sibling data). Recommend delete once agent-ownership lock lifted; verify no new callers first. **v1.0.1 cleanup.**

### Known Issues

- SwiftData wipe is best-effort; silent on failure (S1-4 caveat documented in SupabaseAuthService.swift:17-21). Blocking risk: if wipe throws and is never reattempted, Student A's residual data visible to Student B on same device (shared iPad). Mitigation: wipe-failure UI alert pre-TestFlight.
- Founder TOTP uses AES-CBC with zero IV (deterministic ciphertext). Practical impact low (each founder secret randomly generated). Fix: pgsodium in v1.1.
- Founder-login distinguishes `not_a_founder` vs `invalid_totp` by status code (403 vs 401). Allows account enumeration. Fix: uniform 401 in v1.0.1 patch.
- Realtime client not pinned (future exposure if Realtime ever used). Today: unexploited (no subscriptions in code).
- Content moderation reports not persisted to backend (only UserDefaults). Moderation reporting non-functional until v1.0.1.
