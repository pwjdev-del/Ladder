# SECURITY AUDIT — Ladder iOS + Supabase — 2026-05-14

**Verdict: SHIP_WITH_FIXES**

No remote-RCE-tier issues, no leaked secrets in working tree or git history (prior commit `0e27ce0` cleanup confirmed; `.env` gitignored). But four S1 findings each undermine a v1.0 trust claim that the app is being marketed on (per-student isolation, counselor surface, founder 2FA).

**Scope:** `/Users/kathanpatel/Desktop/LadderApp/` — iOS app under `LadderApp/`, edge functions under `LadderBackend/supabase/functions/`, migrations 0001–0019 under `LadderBackend/supabase/migrations/`. Excluded: `LadderApp/Features/Legacy/`, `Ladder-Oloid (WIP)/`.

**Threat model:** primary attacker = motivated student (13–18) attempting cross-tenant data access, role escalation, prompt-injection of SIA, or counselor-surface bypass. Secondary = insider counselor at school X trying to read school Y data. Tertiary = outsider with stolen founder credentials. Surface = Supabase PostgREST + 6 edge functions + iOS client over TLS.

---

## S1 — CRITICAL (4)

### S1-1 (NEW) — Founder TOTP is a hardcoded RFC 6238 test vector
`LadderBackend/supabase/functions/founder-login/index.ts:57,178`

Every founder verifies against the same world-famous secret `JBSWY3DPEHPK3PXP` (the canonical TOTP tutorial example). The `founder_users.totp_secret_cipher` column is read but its value is discarded.

**Why dangerous:** Collapses 2FA to single-factor. The "every action is audited" reassurance under `FounderLoginView` becomes meaningless if any leaked founder password = full founder access. Combine with no rate-limit on `/functions/v1/founder-login` (no `Retry-After`, no lockout on repeated 401) and any account in `founder_users` can be cracked via password spray.

**Fix:** Ship migration 0020 implementing real DEK-based TOTP decrypt + enrollment; remove `PLACEHOLDER_TOTP_SECRET` entirely. Add per-actor 5-attempt lockout in the edge function.

### S1-2 (NEW) — `app.bind_session()` never auto-runs; 97 RLS policies fail closed silently
`LadderBackend/supabase/migrations/0001_tenants_and_rls_baseline.sql:67` and 97 policies across migrations 0001–0019.

No `db-pre-request` hook is configured (no `supabase/config.toml`), and `bind_session()` is only called inside specific RPCs (0011/0012/0013/0018). Every PostgREST query from iOS that relies on `current_setting('app.role', true)` or `current_setting('app.tenant_id', true)` receives NULL → policy USING evaluates NULL → 0 rows. The counselor SIA surface (`SiaEngine+Counselor.summarize` direct PostgREST read of `student_memory_summaries`, `sia_safety_events`) cannot return data in production unless `bind_session()` is wired to a pre-request hook.

**Why dangerous:** Three reasons.
1. Counselor surface ships broken — D-002 promise silently undelivered.
2. NULL-silently-fails creates false confidence: a future fix to `bind_session` turns on dozens of policies simultaneously — invisible regressions become live.
3. The `sia_isolation.test.ts:262` "PASS T3" assertion must be running under conditions this codebase doesn't document — likely a service-role override in tests. **Audit-trust gap.**

**Fix:** Add `db-pre-request = "app.bind_session"` to Supabase project config (`PGRST_DB_PRE_REQUEST` env var). Add CI integration test asserting a counselor query returns rows.

### S1-3 (NEW) — Supabase SDK calls bypass TLS pinning
`LadderApp/Services/Auth/SupabaseAuthService.swift:53`

`SupabaseClient(supabaseURL:, supabaseKey:)` uses the SDK's default `URLSession`, not `TLSPinnedSessionFactory.shared.session`. Every `client.auth.signIn`, `client.from(...).select`, and `client.functions.invoke` call goes through unpinned TLS. Only `AIGatewayClient`, `AuditClient`, and `FlagClient` use the pinned session — but those are NOT how the app talks to PostgREST, Auth, or the bootstrap / founder-login / invite-redeem edge functions.

**Why dangerous:** A network-position attacker with a misissued cert for `supabase.co` can MITM every auth flow, JWT, password, and PostgREST query — including minors' SIA chats and grades. The whole pinning effort is defeated for ~95% of traffic.

**Fix:** Inject a custom `URLSession` into `SupabaseClient` via `SupabaseClientOptions.global.session` (supabase-swift 2.x supports this). Re-run e2e to confirm pinning still allows app flow with the real cert.

### S1-4 (NEW) — SwiftData store is not wiped on signOut → cross-user PII leak on shared devices
`LadderApp/Services/Auth/SupabaseAuthService.swift:163`

`signOut()` only clears the GoTrue session and TenantContext. Local SwiftData stays. `StudentContextBuilder.fetchSAT/fetchActivities/fetchGPA/fetchEssays` uses unpredicated `FetchDescriptor<...>()`, returning every row in the local store. After Student A signs out and Student B (sibling on the same iPad) signs in, the D-003 identity assert passes (JWT uid = B's uid), then SwiftData hands B all of A's residual SAT, essays, activity, GPA, and quiz history.

**Why dangerous:** Direct contradiction of D-003 "zero cross-student data leakage." Minors' essays and crisis-adjacent `ConversationMemoryStore` data could be read by a sibling. Likely COPPA-disclosure failure.

**Fix:** On signOut, `try modelContext.delete(model: StudentProfileModel.self)` for every SwiftData model + drop the underlying store file. Or scope models with `@Attribute` `userId` and predicate every fetch.

---

## S2 — HIGH (5)

| # | File:line | Finding | Fix |
|---|---|---|---|
| S2-1 (NEW) | `LadderBackend/supabase/functions/founder-login/index.ts` | No rate limit / lockout on TOTP attempts; attacker with a valid JWT can brute the 6-digit TOTP at HTTPS speed. Audit log records attempts but does not throttle. | Add `rate_limit_buckets` check before `authenticator.verify`; lock 15 min after 5 fails per user. |
| S2-2 (NEW) | `LadderApp/Features/Backdoor/EmployeeLoginView.swift` | Employee role granted by `auth.admin.updateUserById` with no second factor and no visible audit trail; phished password = cross-tenant visibility into transfers and safety events. | Require TOTP for employee login (mirror founder path); set `app_metadata.role='employee'` only via a vetted edge function with audit. |
| S2-3 (NEW) | `LadderApp/Services/AI/Context/StudentContextBuilder.swift:170-186` | `buildForCounselorBrief` has explicit TODO "T016 will add: assert counselor tenant == student tenant via Supabase query" — currently a counselor can request a brief on a student in a different tenant; only RLS-on-summary lookup stops it. | Add the tenant-match assertion before calling `AIGatewayClient.counselorBrief`. |
| S2-4 (NEW) | `LadderBackend/supabase/functions/ai-gateway/index.ts:316-321` | `body.input` is passed unvalidated to `buildPrompt`. `safeSerialize` strips control chars and caps length but doesn't validate schema. Student can pass `sia_chat` payload with fake "student context" claiming a different name/grade — degrades persona integrity. | Add Zod schema per `feature`; reject unknown fields and unknown roles in `messages[]`. |
| S2-5 (NEW) | `LadderApp/Features/Founder/Login/FounderLoginView.swift` & `EmployeeLoginView.swift` | No client-side throttle either — user can hammer "Enter" with bad codes; combined with S2-1, this is the realistic brute path. | Cap to 1 submit/5s + clear error state; defense-in-depth alongside server-side. |

---

## S3 — MEDIUM (5)

| # | File:line | Finding | Fix |
|---|---|---|---|
| S3-1 (NEW) | `LadderApp/Info.plist` | No task-switcher snapshot blur. App in switcher shows SIA chat / crisis-resource text in plain. | Install privacy overlay on `scenePhase == .background`. |
| S3-2 (NEW) | `LadderApp/Services/AI/MemoryExtractorService.swift:131` | `Log.warn` includes raw `studentId` UUID and full Supabase error — auth UUID is PII for minors. | Log hash or last-4 of studentId; redact `error.localizedDescription`. |
| S3-3 (NEW) | `LadderBackend/supabase/functions/ai-gateway/index.ts:107` | Rate-limit storage failure → fails OPEN, allowing unlimited Gemini calls if the `rate_limit_buckets` RPC fails. Cost-amplification risk. | Fail closed for SIA chat; fail open only for low-cost features. |
| S3-4 (PARTIAL — open from prior AUDIT_REPORT) | `LadderApp/Services/Tenant/TenantContext.swift:154` | `requireNonFounder()` wired on 5 surfaces (good); Founder surfaces directly query tenant-scoped tables. If S1-2 is fixed and a buggy claim mints `role='founder'` with a `tenant_id`, founder could read student data via the standard tenant policy. | After fixing S1-2, add `app.is_founder()` as a RESTRICTIVE guard on every tenant-scoped policy. |
| S3-5 (NEW) | `LadderApp/App/Configuration/AppConfiguration.swift:34` | Hardcoded Supabase project host in source. Not a secret, but couples binary to one infra — any infra-swap incident needs App Store resubmit. | Move to Info.plist-only with required preflight; keep "fail fast" on missing. |

---

## S4 — INFO / HARDENING

- `LadderApp/Info.plist`: set `NSFileProtectionComplete` on the SwiftData store to require unlock (vs. `…CompleteUntilFirstUserAuthentication` default).
- `LadderApp/Services/AI/SiaEngine+Counselor.swift:25,100`: D-003 role-gate is in the right place; also verify counselor's tenant_id matches student's tenant_id via server RPC before invoking the gateway.
- `LadderBackend/supabase/functions/ai-gateway/index.ts:140-146`: regex PII redaction misses international phones, DOBs, addresses.
- `0014_sia_memory.sql:138`: `counselors_read_tenant_summaries` grants tenant-wide read; D-002 says caseload-only may be acceptable — confirm with product.
- Legacy `Ladder.xcodeproj` still in working tree (open from prior AUDIT_REPORT §3). Newer contributors picking it bypass `project.yml` source excludes — quarantined Legacy code could end up compiled with student-PII paths.
- `.env` gitignored. `git log -S "AIza" -S "fc-" -S "AKIA" -S "ghp_"` returned nothing.

---

## Compliance touch-points
- **COPPA / FERPA:** S1-4 (shared-device leak) and S3-1 (task-switcher) are most likely to fail an audit. Consent flow in `LegalDocumentSheet.swift` is in place, but technical safeguards must back it.
- **GDPR (EU minors):** S1-4 violates Article 32 (security of processing). S3-2 logging PII violates data-minimisation.
- **Mandatory reporting:** `safety_events` policy split (founders all, counselors tenant) aligns with Title IX / CPS.

---

## What looks good
- DEK envelope, prompt-injection delimiter discipline, invite-redeem HMAC + uniform failure, safety-keyword regex with anti-idiom lookahead.
- D-003 isolation assert in `StudentContextBuilder`.
- Separation of `student_ai_chats` (counselor caseload) from `student_memory_summaries` (counselor tenant).
- Explicit `tests/rls/sia_isolation.test.ts` cross-tenant suite.
- SIA system prompt is genuinely high-quality — sycophancy guard, no-replacement-for-therapy floor, Stanley-Brown deference.

---

## Recommended next steps (priority order)
1. **Today:** Fix S1-3 (pin Supabase SDK URLSession) — one-line API change, blast radius enormous.
2. **Today:** Fix S1-1 (founder TOTP placeholder) — ship migration 0020 + enrollment flow.
3. **Tomorrow:** Configure `db-pre-request = app.bind_session` and add regression test (S1-2). Validate counselor SIA summary surface loads end-to-end.
4. **Before TestFlight:** Add SwiftData wipe-on-signout (S1-4); add brute-force throttle on founder/employee TOTP (S2-1, S2-2).
