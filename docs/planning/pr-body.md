# Ladder v2 — full CLAUDE.md spec migration

**Branch:** `feat/ladder-v2-spec-upgrade` → `main` (draft; do NOT merge until Phase 7 QA + follow-up PRs land per `Recommended next PRs` below).

## Summary

- Migrates repo to the `CLAUDE.md` §18 layout (`LadderApp/Services/...`, `LadderBackend/...`).
- Ships the entire 605-line v2 spec per `docs/decisions/ADR-000-scope-full-spec.md` (founder override of CEO pipeline scope cuts — full feature surface, not the trimmed pilot).
- Stands up the Supabase-native backend (RLS on every tenant table, per-tenant DEK envelope encryption via AWS KMS, single AI gateway Edge Function, Varun dependency validator, append-only audit log, COPPA trigger).
- iOS feature tree covers Landing (30s founder logo-hold trigger), Auth (B2C + school-picker + invite redemption + COPPA signup gate), Student (quiz, grades self-only, class suggester, extracurriculars, schedule builder, parent-invite), Counselor + Admin dashboards, Founder backdoor (Schools grid, Solo people, Feature flags, Varun).
- Design system: Dynamic Type fix (Typography bound to UIFontMetrics); new components `ScheduleGrid`, `DataDenseTable`, `InviteCodeDisplay`, `ImpersonationBanner`, `SiblingSwitcher`.
- Tests scaffolded: `tests/isolation/` (P0), `tests/scheduling/`, `tests/flags/`, `tests/crypto/`, `tests/e2e/`.
- DevEx: Makefile, CI workflow (lint → iOS build/test → backend tests → isolation attack suite → PR comment bot), SwiftLint with spec guardrails, `.env.example`, `xcconfig` secrets bridge, PR template.

## CLAUDE.md sections touched

§3, §4, §5, §6, §8.3, §8.4, §9, §10, §11, §12, §13, §14, §15, §16.1, §16.2, §16.3, §16.4, §17.3, §18, §19, §20.

## CEO pipeline — full run log

Phases executed in order (Phases 1–5 fanned out in parallel):

| Phase | Role | Verdict | Key output |
|---|---|---|---|
| 1 | Office hours | RED (premise broken) | CEO pipeline recommended narrowest wedge |
| 2 | CEO scope review | Ship 9 / defer 11 / kill 9 | Recommended scope cuts |
| 3 | Eng architecture | Supabase-native + KMS + deterministic scheduling | 10-milestone build order |
| 4 | Design review | 3 blockers + Typography bug | Missing component specs + 30s feedback model |
| 5 | DevEx review | DX 2/10, TTHW 4–8h | Backend + CI + secrets flow priority |
| 6 | Staff code review | YELLOW | 4 release-blockers + next 5 PRs |
| 7 | QA | runbook ready | `docs/runbooks/qa-ios-simulator.md` (Kathan executes) |
| 8 | Security audit | "Must fix before ship" | 2 release-blockers + 1 Critical LLM + FERPA/COPPA gaps |
| 9 | Ship | this PR | draft, no merge |

All CEO cuts **overridden by founders** (ADR-000). See `docs/decisions/OVERRIDES.md`.

## Release-blockers flagged and fixed in this branch

- `TenantContext.assertNotFounder` was `assertionFailure` (release NO-OP) → `requireNonFounder` using `preconditionFailure` returning `Never` + SwiftUI `.requireNonFounder()` modifier + `FounderBlockedView`.
- TLS pin placeholders now fail Release-build preflight (`PinnedKeys.preflightOrCrash()` called from `LadderApp.init`); `kms.*` pin removed as dead config.
- LLM01 prompt injection: `buildPrompt` restructured into `{ system, user }` with delimited `<user-data>` block + per-feature system instructions; `safeSerialize` caps size + strips control chars (ADR-006).
- COPPA: `0007_coppa_parental_consent_trigger.sql` blocks `quiz_answers` + `grades` inserts for under-grade-7 students without a `parental_consent` `legal_acceptance`.
- `founder_users` table + stub `founder_login` RPC added (0006).
- `invite-redeem` hashing → HMAC-SHA256 with per-deployment secret; uniform 400 failure response closes oracle.
- `ai_usage_ledger.user_id_hash` now HMAC(userId, tenantId-salted secret) instead of all-zero bytes.
- Isolation suite JWT signing wired to `SUPABASE_JWT_SECRET` via `pyjwt`; CI pulls the secret from `supabase status --output env`.

## Known follow-ups (next 5 PRs, in order)

1. Quarantine legacy AWS stack (`AuthManager`, `AWSManager`, `AppSyncManager`, `S3StorageManager`) under `LadderApp/Features/Legacy/` behind `LEGACY_AWS` flag. ~70 TODOs today compete with Supabase direction.
2. `SupabaseAuthService` + wire `B2CLoginView`, `FounderLoginView` to real sign-in + MFA enrollment.
3. Real rate limiting (Postgres advisory-lock token bucket) + Zod per-feature schemas in `ai-gateway`.
4. Wire `CareerQuiz` → `ai-gateway` → schedule builder gating (`windowOpen`, `quizFresh` are hardcoded today).
5. Replace consumer Gemini endpoint with Vertex AI under a signed DPA (FERPA/§17.1 requirement before student-data prompts ship).

## Test plan

- [ ] `make bootstrap && make dev` on Kathan's machine succeeds
- [ ] `docs/runbooks/qa-ios-simulator.md` executed — all 10 test scenarios pass or have a logged ticket
- [ ] Isolation attack suite runs green against local Supabase (`make isolation`)
- [ ] Scheduling tests green (`make scheduling`)
- [ ] Varun flags tests green (`make flags`)
- [ ] Crypto envelope tests green (`make crypto`)
- [ ] SwiftLint clean on new files
- [ ] Manually verify Founder logo-hold produces correct haptics + trap when founder session lands on tenant view (Debug should `preconditionFailure`; Release renders `FounderBlockedView`)
- [ ] Confirm `PinnedKeys.preflightOrCrash()` trips a Release build while pins are placeholder

## Pre-merge checklist (per §19, §21)

- [x] Read existing prototype before changes; structure migration preserves history via `git mv`
- [x] Tests cover new behavior (5 suites scaffolded)
- [x] Audit events emitted server-side on mutations
- [x] AI gateway scoped + budgeted (§8.4)
- [x] No direct Gemini calls from iOS (SwiftLint custom rule blocks it)
- [ ] Lawyer-agent sign-off on student-PII additions (queue this after merge-prep)
- [ ] Isolation suite green in CI (§4.2 P0)
- [x] Per-tenant DEK + RLS + role policies encoded in migrations 0001–0007
- [x] Docs updated (README, 7 ADRs, OVERRIDES.md, QA runbook)
- [x] No behavioral ads / 3rd-party analytics / data-sale integrations (§16.4)

## Human founder review

- [ ] Diff summary reviewed by Kathan or Jet before moving off draft

---

🤖 Generated with [Claude Code](https://claude.com/claude-code) as part of the gstack CEO pipeline run on 2026-04-18.
