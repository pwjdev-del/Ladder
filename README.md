# Ladder

> "Every kid needs a ladder to success."

iOS-native K–8 school-adoption platform. Dual B2B (schools) + B2C (families).
First pilot: Lakewood Ranch Preparatory Academy (LWRPA), Florida.

## Quick start

```sh
make bootstrap    # installs XcodeGen, SwiftLint, Supabase CLI, Gitleaks, Deno
cp .env.example .env   # fill in SUPABASE keys, GEMINI_API_KEY, AWS_* for KMS
make dev          # starts local Supabase, runs migrations + seed, opens Xcode
```

## Layout (per CLAUDE.md §18)

```
LadderApp/       iOS app target (SwiftUI + Swift Concurrency, iOS 16+)
  App/           entry + navigation + configuration
  Features/      Landing, Auth, Student, Parent, Counselor, Admin, Founder
  Services/      Auth, Tenant, Crypto, AI, Flags, Audit, Networking, ...
  DesignSystem/  tokens + components
  Models/        shared domain types
  Resources/     assets
LadderBackend/   Supabase-native backend
  supabase/
    migrations/  SQL — RLS policies, audit, DEK, ledger
    functions/   Edge Functions (ai-gateway, varun-validate, invite-redeem, ...)
  crypto/        envelope encryption (AWS KMS + per-tenant DEK)
  domain/        deterministic scheduling core
tests/
  isolation/     cross-tenant attack suite (P0 per §4.2)
  scheduling/    engine conflict / prereq / capacity tests
  flags/         Varun dependency tests
  crypto/        envelope roundtrip
  e2e/           XCUITests + Playwright-style Supabase flows
docs/
  decisions/     ADRs — start here
  compliance/    Lawyer-agent outputs (DPA, T&Cs, privacy)
  research/      scheduling + K-8 policy research
  runbooks/
```

## What is mandatory

Read `CLAUDE.md` end to end. The short version:

- Tenant isolation is absolute (§4). RLS on every table. Isolation tests block CI.
- Grades are student-self-only (§2.2). No counselor, admin, teacher, or founder ever reads them.
- Teachers are NOT app users (§2.1). Teacher *data* exists; the app does not.
- Founder backdoor (§14) is gated by a 30s logo-hold + MFA. Founders see NO tenant data.
- AI calls go only through the `ai-gateway` Edge Function (§8.4, ADR-005).
- Per-tenant DEKs wrap PII. Master key in AWS KMS. Founders cannot load DEKs — enforced at IAM layer (§16.2, ADR-004).
- Lawyer Agent (§17) reviews every student-data PR before merge.

## Status

See `docs/decisions/ADR-000-scope-full-spec.md` for the founder-overridden
scope decision — we are building the full spec, not the CEO-trimmed version.

## Contributing

See `CONTRIBUTING.md` (todo) and the ADRs in `docs/decisions/`.
