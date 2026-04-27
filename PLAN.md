# Ladder — Post-Audit Sprint Plan
_Date: 2026-04-26 • Author: PWJ Orchestrator_

> Founder decision (2026-04-26): both the student-journey app AND the school surfaces ship together. Same app, same backend, role-based routing.

This plan sequences fixes from the AUDIT_REPORT.md into 4 phases. Each phase has a clear "done" condition. Phases are gated — don't start phase N+1 until N is green.

---

## Sprint sequencing principle

**Foundation before features.** Auth + iPad target + secrets are foundational — every later fix depends on them. The Legacy un-quarantine (the architectural merge) is the biggest single change, so it gets its own ADR + planning before code.

## Phase 1 — Foundation (3-5 days)

Goal: turn the app from "looks like it works" into "actually works against the real backend." After Phase 1, every backend security mechanism the audit praised (RLS, DEK, founder wall, ai-gateway hardening) is actually exercised.

| # | Fix | Files | Specialist | Effort |
|---|-----|-------|------------|--------|
| 1 | Real Supabase auth on all 3 login screens | `B2CLoginView.swift`, `SchoolLoginView.swift`, `FounderLoginView.swift`, new `SupabaseAuthService.swift` | `pwj:swift-ios-specialist` + `pwj:supabase-specialist` | M |
| 2 | Delete hardcoded `Ladder!v2-pilot` literal from source; add SwiftLint custom rule banning it | same login files + `.swiftlint.yml` | `pwj:swift-ios-specialist` | S |
| 3 | Apply `.requireNonFounder()` to every non-founder root view | ~30 dashboard files under `Features/{Student,Counselor,Admin,Parent}/**` | `pwj:swift-ios-specialist` | S |
| 4 | Add `AppConfig.preflightOrCrash()` invoked from `LadderApp.init()` | `App/Configuration/AppConfiguration.swift`, `LadderApp.swift` | `pwj:swift-ios-specialist` | S |
| 5 | Fill real Supabase TLS SPKI pins; add CI gate that fails on placeholder bytes | `Services/Networking/TLSPinnedSession.swift`, `docs/runbooks/tls-pins.md` | `pwj:swift-ios-specialist` + `pwj:security-auditor` | S |
| 6 | Flip `TARGETED_DEVICE_FAMILY` to `"1,2"` (re-enable iPad target) | `project.yml` | `pwj:swift-ios-specialist` | XS |
| 7 | Replace email-prefix `RoleDetector` with JWT `role` claim from `TenantContext` | `App/SignedInRouter.swift`, `Services/Tenant/TenantContext.swift` | `pwj:swift-ios-specialist` | S |
| 8 | Replace email-switch grade lookup with `students.grade_level` from DB | `App/SignedInRouter.swift` | `pwj:swift-ios-specialist` + `pwj:supabase-specialist` | S |

**Done condition:** all 3 login screens authenticate against Supabase, JWT role+tenant flow through `app.bind_session()`, founder data wall is enforced on every non-founder root view, app crashes loud on missing config, iPad target builds, role/grade come from JWT not email.

---

## Phase 2 — Product Fork Merge (5-7 days, requires ADR first)

Goal: bring the student-journey surface (currently quarantined in `Features/Legacy/`) into the active build, alongside the school surfaces. This is the biggest architectural change — needs an ADR before code.

### Phase 2a — Architecture (0.5-1 day)

Write **ADR-008-student-school-surface-merge.md** covering:
- Routing: `SignedInRouter` dispatches by JWT role to either StudentSurface or SchoolSurface (Counselor/Admin/Parent/Founder dashboards).
- Shared services: which services are common (Tenant, Auth, AI, Networking, DesignSystem) vs surface-specific.
- Engine ownership: `ConnectionEngine`, `CollegeMatchCalculator`, `ActivitySuggestionEngine`, `StateRequirementsEngine`, `RIASECEngine`, `GradeFeatureManager` — all move from `Services/Legacy/Engines/` to `Services/Engines/` and get unit tests.
- Tab structure for student surface: `Home / Tasks / Colleges / Advisor / Profile` (per Ideas §7).
- Counselor → Student visibility: how a counselor's view of a student maps to the student surface.

### Phase 2b — Triage Legacy folder (1 day)

Use `pwj:refactorer` to walk every file under `Features/Legacy/` and `Services/Legacy/` and classify:
- **Promote** (still wanted; move out of Legacy/) — engines, onboarding, career quiz, college discovery, activity suggestions, essay hub, roadmap, advisor chat, scholarships, transcript upload
- **Rewrite** (concept wanted but code is stale; rewrite from spec) — likely AuthManager, AWSManager
- **Delete** (truly dead) — any half-finished experiments

### Phase 2c — Promote (3-5 days)

For each "promote" file: move out of `Features/Legacy/`, fix imports, hook into the new routing, add at least one unit test. Update `project.yml` to remove the Legacy exclusion. PRs should be small (1 feature area per PR).

### Phase 2d — Reconnect ConnectionEngine cascades

ConnectionEngine is the load-bearing piece. Every cascade in IDEAS_DIGEST §9 needs to fire on the matching `StudentProfileModel` change. Add cascade unit tests (career change → all 7 affected feature areas update).

**Done condition:** student surface is reachable from a student-role login, all engines compile and have basic tests, Legacy folder is empty, `project.yml` has no Legacy exclusions.

---

## Phase 3 — iPad Parity (3-4 days, after Phase 1+2)

Goal: every student-journey view + every school-surface dashboard works on iPad in landscape and portrait, per the Stitch designs.

Use the `ladder-ipad-parity` skill. Highest priority surfaces:
1. Student MainTabView (5 tabs)
2. CounselorDashboard (NavigationSplitView already exists in `StudentQueueView`)
3. ParentDashboard
4. AdminDashboard
5. FounderDashboard
6. Auth flows (B2C, School, Founder, Invite Redemption)

For each: add `horizontalSizeClass` checks, switch to `NavigationSplitView` for iPad column layouts, verify env objects propagate across columns (Phase 1 #4 noted env objects only attach to LandingView).

**Done condition:** all dashboards rendered correctly on iPad Air + iPad Pro 12.9", landscape + portrait, no clipped layouts.

---

## Phase 4 — Cleanup + Hardening (2-3 days, parallel-able)

Goal: pay down the remaining S2/S3 audit items.

| # | Fix | Specialist |
|---|-----|------------|
| 1 | Delete `Ladder.xcodeproj/`, add to `.gitignore`, document `LadderApp.xcodeproj` is XCGen-regenerated | `pwj:refactorer` |
| 2 | Move `/Ideas/Ladder_CLAUDE.md` to `docs/historical/` so the AWS pivot myth dies | `pwj:doc-writer` |
| 3 | Move `ci.yml` from `docs/ci-pending/` to `.github/workflows/`; run xcodegen + xcodebuild test + swiftlint + tsc + deno test | `pwj:github-actions-specialist` |
| 4 | Implement ai-gateway per-minute/per-user rate limit (replace TODO stub) | `pwj:supabase-specialist` |
| 5 | Cache `tenants` lookup in ai-gateway leakage scan (5-min TTL) | `pwj:supabase-specialist` |
| 6 | Fix ai-gateway safeSerialize regex (`/ -/g` → `/[\x00-\x1f]/g`) + add unit test | `pwj:supabase-specialist` |
| 7 | Resolve COPPA grade<7 trigger now that product is grade 9-12 (compute `is_under_13` app-side from DOB before encryption, OR write ADR deprecating the trigger) | `pwj:supabase-specialist` |
| 8 | Add iOS unit tests for `RoleDetector`, `GradeFeatureManager`, `TenantContext.requireNonFounder` modifier presence, ConnectionEngine cascades | `pwj:test-writer` |
| 9 | Pin all backend deps to exact versions; add `deno.lock` | `pwj:supabase-specialist` |

---

## Out-of-scope (later sprints)

- Counselor Marketplace (Ideas §5 stretch)
- School admin SSO with Focus/PowerSchool/CSUSA (county-permission-gated)
- Web sign-up flow to bypass Apple's 30%
- Daily AI training updates
- Anonymized data insights
- Cross-app expansion beyond US

---

## Estimated total

- Phase 1: 3-5 days
- Phase 2: 5-7 days (after Phase 1)
- Phase 3: 3-4 days (after Phase 2)
- Phase 4: 2-3 days (parallel to Phase 3)

**Total to "ready for first real TestFlight":** ~13-19 working days of specialist time, sequenced. Phases 3 + 4 partially overlap.

---

## Phase 4 backlog (from Phase 1 code review)

- iPad size-class adapters across all dashboards (NavigationSplitView for 13"+)
- AppConfiguration: `os_log` warning when DEBUG falls back to placeholder URL
- SupabaseAuthService.signInWithPassword: catch `bindTenantContext` failures, sign out backend so we don't leak a half-bound session
- Currently `currentSession` getter swallows errors with `try?` — switch to logged
- FounderLoginView: dead `field(...)` helper at L102-133 — delete
- Phase 4 already has founder TOTP server-side (Edge Function) — confirm it's listed
- `.swiftlint.yml` `plaintext_password` regex too narrow (`[A-Za-z0-9]+` misses special chars) — pre-existing scope
