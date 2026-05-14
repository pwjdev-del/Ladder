# Code Review — Ladder v1.0 Audit Sweep (commit ae1a364)

**Verdict:** NEEDS_CHANGES
**Severity:** S1 = 3 · S2 = 5 · S3 = 6
**Reviewer:** Wave 2.1 senior code reviewer

---

## S1 — must fix before merge

### S1-CR1. `AdvisorChatViewModel.swift:198,261-271` — sia_chat client/server contract break
Server-side `SiaChatInputSchema` (`ai-gateway/index.ts:96`) **requires** `studentId: z.string().uuid()`. The iOS `SiaChatInput` struct only encodes `{ context_payload, messages }`. Every SIA chat send returns HTTP 400 `{"error":"invalid_input","detail":"Required"}` before the stream opens.

**Fix:** add `let studentId: String` to `SiaChatInput`, pass `self.studentId` at construction site, add to `CodingKeys`. Audit `CounselorBriefInputSchema` + `MemoryExtractionInputSchema` consumers for the same drift.

### S1-CR2. `0022_founder_restrictive_caseload.sql:§1` — 4 RESTRICTIVE policies silently break founder PostgREST UIs
The `feature_flags_no_founder`, `audit_log_no_founder`, `ai_usage_ledger_no_founder`, `success_metrics_no_founder` RESTRICTIVE policies block the founder's direct PostgREST reads/writes. The only existing founder surface for flags (`FeatureFlagsView.swift:276,337`) reads/writes via PostgREST. After this migration:
- `loadFlags()` returns 0 rows → founder sees `FeatureFlagsCatalog.defaultState`, not real state
- `save()` upserts get silently RLS-filtered → no rows changed → founder thinks save worked

Migration comment promises edge-function counterparts; none exist in this PR.

**Fix:** drop those 4 RESTRICTIVE policies (keep the tenant-data ones — students, grades, essays, summaries — which ARE the actual D-002 founder-data-wall surface). File edge-function follow-up for v1.1.

### S1-CR3. `0020_founder_totp_decrypt.sql:§4` — pgcrypto `encrypt(..., 'aes-cbc')` is deterministic
`pgcrypto.encrypt(data, key, 'aes-cbc')` without explicit IV mode uses a zero IV. Same plaintext → same ciphertext.

**Fix:** switch to `'aes-cbc/pad:pkcs/rand-iv'` form, or generate `gen_random_bytes(16)` IV and store `iv || ciphertext` together.

---

## S2 — fix before shipping

- **S2-CR1.** `AIGatewayClient.swift:121-180` — `streamSiaChat` has no `URLRequest.timeoutInterval` and no idle-timeout. Gemini stall = forever-hang. Fix: 60s request timeout + actor-side idle timeout.
- **S2-CR2.** `PrivacyOverlay.swift:30-40` — 150ms easeInOut fade-in may be slower than the iOS snapshot capture on `.inactive`. Use `.animation(nil, value:)` when going active→inactive, or UIWindow-level visual effect view via `willResignActiveNotification`.
- **S2-CR3.** `ai-gateway/index.ts:626-655` — `userInputSafetyEventId` race + never-read variable. Drop it or `await` the insert before stream.
- **S2-CR4.** `founder-login/index.ts:230-260` — TOCTOU on rate-limit count. Two concurrent attempts both pass at count=4. Fix: `upsert_rate_limit_bucket` returns post-increment count.
- **S2-CR5.** `AIGatewayClient.swift:171` — `try?` silently drops malformed SSE frames. Add structured log at decode-fail.

---

## S3 — nice to have

- Duplicate `SiaStreamEvent` struct in `AdvisorChatViewModel.swift:280-296` — delete (consumer uses `SiaDelta`).
- Dead `safetyFlag: string | null = null` in `ai-gateway/index.ts:790`.
- Boilerplate comments on RESTRICTIVE policies — consolidate to DECISIONS.md.
- `String(uid.hashValue & 0xFFFF, radix: 16)` log hash → use `SHA256.prefix(8).hex`.
- `app._founder_totp_fsk()` fallback should `RAISE WARNING` when Vault path fails.
- `CareerQuizView.swift` `topCareerPath` assigned but not rendered.

---

## Highlights

- **TLS pinning via `SupabaseClientOptions.GlobalOptions.session`** is the correct cross-transport pattern; covers Auth + PostgREST + Storage + Functions in one shot.
- **`invite-redeem` RPC + hex bytea lookup** dodges supabase-js Uint8Array→JSON bug elegantly.
- **SwiftData wipe ordering** (wipe → signOut → clear TenantContext) is correct, well-commented.
- **Caseload-only join in 0022 §2** uses `counselor_assignments → students → student_memory_summaries.student_user_id` correctly. Preserves the founder mandatory-reporting bypass.
- **`bind_session()` + db_pre_request hook** is the right architecture.
- **Fail-closed sia_chat rate-limit** correctly blocks cost amplification on the highest-volume feature.
