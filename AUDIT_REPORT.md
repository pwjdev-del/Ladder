# Ladder — Consolidated Audit & Gap Report
_Date: 2026-04-26  •  Audited by: PWJ pipeline_

> **STATUS UPDATE — 2026-05-14:** This is a historical audit reflecting the pre-sweep state (2026-04-26). All critical S1 findings (fake auth, hardcoded password, placeholder Supabase config, TLS pinning placeholders, iPad parity violation, founder data wall unenforced) have been resolved in the v1.0 audit-fix sweep. See `CHANGELOG.md` and `FOUNDER_SHIP_REVIEW_2026-05-14.md` for the final verdict and remaining known issues.

---

## TL;DR (3 sentences for the founder)

The app you have today is **not the same app the Ideas folder describes** — at some point the project pivoted from a student-journey product (career quiz, college matching, AI advisor, 5-tab journey) to a B2B/B2C school-sandbox product (founder dashboard, school admins, counselors, scheduling), and the original ~210 student files were quarantined to `Features/Legacy/` and excluded from the build. Every "must-have" feature in the IDEAS_DIGEST (ConnectionEngine, CollegeMatchCalculator, GradeFeatureManager grade gates, 5-step Onboarding wizard, AI streaming, MATCH/REACH/SAFETY, Application Tracker, Essay Hub, Roadmap, Activity Suggestions, Career Quiz history, Scholarships) **exists as code but is not compiled into the app**. On top of that, login is currently a hardcoded `==` password check shared by every role — so before any feature work, you need to (1) decide whether the canonical product is the new sandbox app or the original student-journey app, and (2) replace the placeholder auth with the real Supabase flow.

---

## Stack Reality Check

**Verdict: Supabase is canonical. AWS is dead.**

The "AWS pivot" the IDEAS_DIGEST mentions came from a now-superseded planning artifact at `/Ideas/Ladder_CLAUDE.md`, which itself opens with the banner:
> "⚠ SUPERSEDED — This file reflects an earlier state of the project. The authoritative CLAUDE.md is now at the ROOT of the Xcode project. As of April 2026: 209 files, 47,734 lines, 145+ features, AWS (not Supabase)…"

That superseded file claimed AWS, but the **actual canonical CLAUDE.md** at `/Users/kathanpatel/Desktop/LadderApp/CLAUDE.md` (line 33) says:
> "The iOS app talks to a secure backend (Swift on server or Node/TypeScript — use whatever the existing prototype uses; do NOT introduce a second backend)."

And the existing prototype is **Supabase**, end-to-end:
- `LadderBackend/supabase/functions/{ai-gateway,varun-validate,invite-redeem}/index.ts`
- `LadderBackend/supabase/migrations/`
- `docs/decisions/ADR-001-supabase-native-backend.md`
- iOS client `LadderApp/Services/Networking/TLSPinnedSession.swift` pins Supabase URL

There is **zero AWS code** in the active repo (no Cognito, Lambda, DynamoDB, or S3 integration). The "Friday April 11 AWS wiring" never happened — it was a planning idea in the superseded doc that the next docs cycle reverted. Either delete the superseded file or move it under `docs/historical/` with a redirect, because anyone reading the Ideas folder today will draw the wrong conclusion.

---

## Critical Blockers (S1)

**1. Auth is fake.** Files: `LadderApp/Features/Auth/B2CLogin/B2CLoginView.swift:144-160`, `Features/Auth/SchoolLogin/SchoolLoginView.swift:202-228`, `Features/Founder/Login/FounderLoginView.swift:135-152`.
> What this means: On every login screen, the app does `if password == "Ladder!v2-pilot" { signIn() }`. There is no call to Supabase. There is no JWT. The backend's row-level security, the per-tenant encryption keys, and the founder data wall are all unreachable because nobody ever logs into Supabase. This is an "unshippable" item — the app does not actually have authentication.

**2. The shared password is hardcoded in source.** Same files as above.
> What this means: The pilot password ships in the App Store binary. Anyone who downloads the app can extract it with a hex editor and impersonate any role.

**3. iPad target is explicitly disabled in the build config.** File: `project.yml:46-48` — `TARGETED_DEVICE_FAMILY: "1"` with comment `# iPad deferred per user instruction — iPhone only for this pass.`
> What this means: This directly violates your standing "iPad parity is mandatory" rule. The Stitch designs include iPad, but the build will not install on iPad at all.

**4. The founder data wall is a paper rule.** File: `LadderApp/Services/Tenant/TenantContext.swift:75-98` defines `RequireNonFounderModifier`, but a project-wide search shows **zero callers**. The founder can technically see every tenant's data because nothing actually enforces the wall in the views.
> What this means: You wrote the lock but never installed it on any door.

**5. Supabase config has placeholder URL.** File: `LadderApp/App/Configuration/AppConfiguration.swift:7-22` — fallback URL `"https://your-project.supabase.co"` and an empty anon key. There is no preflight crash.
> What this means: A misconfigured release build will silently boot with a non-functional backend instead of failing fast and obvious.

**6. TLS pinning has placeholder hashes.** File: `LadderApp/Services/Networking/TLSPinnedSession.swift:18-30` — pin bytes are literally `0x00` and `0x01` repeated 32 times.
> What this means: A release build will refuse all network connections (or accept everything, depending on flag) until you paste in the real Supabase SPKI SHA-256 hashes.

---

## Big Architectural Gaps (Ideas vs Code)

**Gap 1 — Two products, only one compiled.** The Ideas folder describes a student-journey app with 20 must-have features. The active build is a school-sandbox app with founder/admin/counselor/parent/student dashboards. Every "must-have" engine (`ConnectionEngine`, `CollegeMatchCalculator`, `ActivitySuggestionEngine`, `StateRequirementsEngine`, `AuthManager`, `OnboardingContainerView`, `EssayHubView`, `RoadmapView`, `ScholarshipMatchView`, `TranscriptUploadView`, `LORTrackerView`, `DecisionPortalView`, `AppSeasonDashboardView`, `AdvisorChatView`, `MockInterviewView`, `BrightFuturesTrackerView`, `GraduationTrackerView`, `RIASECEngine`) **exists in `Features/Legacy/` or `Services/Legacy/`** — but `project.yml:39-44` excludes those folders from the build. So the founder vision lives in the repo as ~210 quarantined files that the compiler never sees.

**Gap 2 — Auth never connects to the backend.** The canonical CLAUDE.md describes a 5-state machine with 4 roles + founder, role claims from the JWT, and tenant binding via `app.bind_session()`. The actual app does a string comparison and calls it a day. Backend RLS, DEK envelope, and the tenant context are all unreachable until this is fixed.

**Gap 3 — iPad parity exists in design only.** Stitch batches include iPad layouts and the user's standing rule says "every iPhone feature must appear on iPad." `project.yml` ships iPhone-only and there are zero `horizontalSizeClass` / `userInterfaceIdiom` checks anywhere in active code.

**Gap 4 — Role detection is by email-prefix string match.** `LadderApp/App/SignedInRouter.swift:36-44` looks at `email.hasPrefix("admin")` etc. The spec requires role to come from the JWT `role` claim. Same file (lines 47-58) hardcodes student grade level by email switch instead of reading `students.grade_level` from the database.

**Gap 5 — Two `.xcodeproj` files in the repo.** `Ladder.xcodeproj` (legacy, 2,142 lines) sits next to the active `LadderApp.xcodeproj` (1,303 lines, generated from `project.yml`). New contributors will pick the wrong one.

---

## Feature Gap Matrix

Status legend: ✅ built · 🟡 partial/stubbed · ❌ missing entirely · 🚫 quarantined (exists in `Features/Legacy/` but excluded from build)

### Core Features (IDEAS_DIGEST §3)

| # | Feature | Status | Where | Note |
|---|---|---|---|---|
| 1 | Career Discovery Quiz (RIASEC) | 🚫 + 🟡 | `Features/Legacy/Career/Views/AdaptiveCareerQuizView.swift`, `Features/Legacy/Career/Services/RIASECEngine.swift`; new shell at `Features/Student/CareerQuiz/CareerQuizView.swift` | Old engine quarantined; new file is a single shell view with no RIASEC logic |
| 2 | 5-Step Onboarding Wizard | 🚫 | `Features/Legacy/Onboarding/Views/OnboardingContainerView.swift`, `Features/Legacy/Onboarding/ViewModels/OnboardingViewModel.swift` | Quarantined; not called from any active route |
| 3 | ConnectionEngine (cascade) | 🚫 | `Services/Legacy/Engines/ConnectionEngine.swift` | The "single most important architectural piece" is build-excluded |
| 4 | Activity Suggestion System | 🚫 | `Services/Legacy/Engines/ActivitySuggestionEngine.swift` | Quarantined |
| 5 | College Discovery + MATCH/REACH/SAFETY | 🚫 | `Services/Legacy/Engines/CollegeMatchCalculator.swift` | Calculator quarantined; no Discovery view in active build at all |
| 6 | Application Tracker (status machine) | 🚫 | `Features/Legacy/Applications/Models/ApplicationModels.swift`, `Features/Legacy/Applications/Views/ApplicationDetailView.swift` | Quarantined |
| 7 | Post-Acceptance Checklist auto-transform | ❌ | — | No code anywhere — not even in Legacy |
| 8 | AI Advisor (Gemini, streaming) | 🟡 | `Services/AI/AIGatewayClient.swift`, backend `LadderBackend/supabase/functions/ai-gateway/index.ts` | Backend gateway is solid (prompt-injection defense, model tiering via ADR-006). iOS client exists but no `AsyncThrowingStream` SSE wiring; no chat UI surfaces it. Old `AdvisorChatView.swift` quarantined |
| 9 | Grade-Gated Features (`GradeFeatureManager`) | 🟡 | `Services/Flags/GradeFeatureManager.swift` (active) + `Services/Flags/FeatureGateManager.swift` | The manager exists in active build, but the features it would gate (App Tracker, Essay Hub, SAT Strategy, etc.) all live in Legacy and aren't gated by anyone |
| 10 | Roadmap (4-year milestones) | 🚫 | `Features/Legacy/Checklists/Views/RoadmapView.swift` | Quarantined |
| 11 | Tasks (grade-aware) | 🚫 | `Features/Legacy/Checklists/Views/TasksView.swift`, `Features/Legacy/Checklists/ViewModels/TasksViewModel.swift` | Quarantined |
| 12 | Deadlines Calendar | 🚫 | `Features/Legacy/Applications/Views/DeadlinesCalendarView.swift` | Quarantined |
| 13 | Essay Hub | 🚫 | `Features/Legacy/AIAdvisor/Views/EssayHubView.swift` | Quarantined |
| 14 | Scholarship Search + first-gen filtering | 🚫 | `Features/Legacy/Financial/Views/ScholarshipSearchView.swift`, `Features/Legacy/Financial/Views/ScholarshipMatchView.swift` | Quarantined |
| 15 | State Requirements Engine (FL Bright Futures) | 🚫 | `Services/Legacy/Engines/StateRequirementsEngine.swift`, `Features/Legacy/Shared/Views/BrightFuturesTrackerView.swift` | Quarantined |
| 16 | Transcript Upload + Gemini Vision parse | 🚫 | `Features/Legacy/Shared/Views/TranscriptUploadView.swift` | Quarantined; no Vision API integration in any version |
| 17 | Class Planner (AI Easy/Moderate/Hard) | 🟡 | `Features/Student/ClassSuggester/ClassSuggesterView.swift` (active) | Shell exists in active build; AI suggestion logic absent |
| 18 | Personalized AI College Pages (Firecrawl + Lambda) | ❌ | — | Zero Firecrawl integration; no AWS Lambda (and we just confirmed AWS is not the stack) |
| 19 | Streak + Points + Levels (Duolingo-style) | ❌ | — | No `streakCount`, `totalPoints`, or `LevelUpView` anywhere |
| 20 | Auth + Consent (5-state machine) | 🚫 + 🟡 | `Services/Legacy/Auth/AuthManager.swift` (quarantined); active auth in `Features/Auth/*LoginView.swift` is hardcoded password check | No `ConsentView`, no COPPA gate, no 6 legal docs in active build |

### Secondary Features (IDEAS_DIGEST §4)

| Feature | Status | Where | Note |
|---|---|---|---|
| Major dropdown after career cluster | 🚫 | `Features/Legacy/Career/Views/MajorPickerView.swift` | Quarantined |
| Career Override picker | 🚫 | `Features/Legacy/Career/Views/CareerOverrideSheet.swift` | Quarantined |
| Junior-year major re-prompt banner | ❌ | — | Not built |
| College Preference Quiz | ❌ | — | Not built |
| `portalURL` per college + "Apply Now" SafariView | ❌ | — | Not built |
| Letters of Recommendation tracker | 🚫 | `Features/Legacy/Applications/Views/LORTrackerView.swift`, `Models/LORModel.swift` | Quarantined |
| LOCI / Decision Portal | 🚫 | `Features/Legacy/Applications/Views/DecisionPortalView.swift` | Quarantined |
| App Season Dashboard (12th) | 🚫 | `Features/Legacy/Applications/Views/AppSeasonDashboardView.swift` | Quarantined |
| Career Explorer (jobs+salary) | 🚫 | `Features/Legacy/Career/Views/CareerExplorerView.swift` | Quarantined |
| Scholarshipsearch.net integration | ❌ | — | Not built |
| SAT fee waiver detection | 🚫 | `Features/Legacy/Shared/Views/FeeWaiverCheckerView.swift` | Quarantined |
| AI Advisor structured onboarding mode | ❌ | — | Not built |
| Mock Interview with recording | 🚫 | `Features/Legacy/AIAdvisor/Views/MockInterviewView.swift`, `MockInterviewViewModel.swift`, `MockInterviewFeedbackView.swift` | Quarantined |
| Resume Builder | 🚫 | `Features/Legacy/AIAdvisor/Views/AcademicResumeView.swift` | Quarantined (one-page Canva-style template missing) |
| PDF portfolio export | 🚫 | `Features/Legacy/Shared/Views/ActivitiesPortfolioView.swift` | View exists; PDF export logic does not |
| Class preference share with counselor | ❌ | — | Not built |
| Saved Colleges view | ❌ | — | Not built |
| Edit Profile sheet (post-onboarding) | 🚫 | `Features/Legacy/Settings/Views/ProfileSettingsView.swift` | Quarantined |
| Achievements / badges (iPhone Profile) | ❌ | — | Not built |
| Push notifications | ❌ | — | Not built |
| "Colleges can revoke acceptance" warning | ❌ | — | Not built |
| "Apply before Nov 1" early-app warning | ❌ | — | Not built |
| NCAA athlete track | ❌ | — | Not built |
| Activity longevity tracking | ❌ | — | Not built |
| STARS/Common App/SSAR/SPARK as distinct platforms | ❌ | — | Schema exists in `college_requirements_db.json` per Ideas; no UI |

### Engines (IDEAS_DIGEST §9)

| Engine | Status | Where |
|---|---|---|
| `ConnectionEngine` | 🚫 | `Services/Legacy/Engines/ConnectionEngine.swift` |
| `CollegeMatchCalculator` | 🚫 | `Services/Legacy/Engines/CollegeMatchCalculator.swift` |
| `GradeFeatureManager` | ✅ (active) but unwired | `Services/Flags/GradeFeatureManager.swift` |
| `ActivitySuggestionEngine` | 🚫 | `Services/Legacy/Engines/ActivitySuggestionEngine.swift` |
| `StateRequirementsEngine` | 🚫 | `Services/Legacy/Engines/StateRequirementsEngine.swift` |

### Architecture pieces

| Piece | Status | Note |
|---|---|---|
| 5-tab `MainTabView` (Home/Tasks/Colleges/Advisor/Profile) | 🚫 | `App/Navigation/MainTabView.swift` — exists but `App/Navigation/**` is build-excluded in `project.yml:43`. Active app uses `SignedInRouter.swift` instead, with role-based dashboards (no tabs) |
| `Route.swift` enum (49–80 cases) | 🚫 | `App/Navigation/Route.swift` — same exclusion |
| `AppCoordinator` | 🚫 | `App/Navigation/AppCoordinator.swift` — same exclusion |
| 5-state auth machine | 🚫 | `Services/Legacy/Auth/AuthManager.swift` quarantined |
| College Scorecard API integration | ❌ | No HTTP client, no cache, no model |
| AI streaming via `AsyncThrowingStream` | ❌ | Backend supports SSE; iOS client doesn't consume it |
| AI suggestions-not-mandates rule | ✅ | Enforced in backend system prompt (`ai-gateway/index.ts`, ADR-006) |

---

## What's Done Right (don't break this)

1. **Per-tenant DEK envelope crypto** (`LadderBackend/crypto/envelope.ts`) is correctly implemented — every tenant has its own data-encryption key wrapped with a key-encryption key. This is the right model and you should not "simplify" it away.
2. **Row-Level Security policies** (`LadderBackend/db/policies/`) consistently use `current_setting('app.tenant_id')` so a single Postgres connection can't leak across tenants. There's even a cross-tenant RLS test in the repo.
3. **AI gateway prompt-injection defense** (`LadderBackend/supabase/functions/ai-gateway/index.ts`, ADR-006) is textbook — input sanitization, output scanning, model tiering by subscription. Rare to see this done right.
4. **Invite-redeem HMAC + uniform failure response** (`LadderBackend/supabase/functions/invite-redeem/index.ts`) prevents timing-attack enumeration of invite codes. Good defense-in-depth.
5. **TLS preflight crash safety net** (`Services/Networking/TLSPinnedSession.swift`) — once you fill in the real SPKI hashes, the app will refuse to boot if it ever gets a wrong cert. This is the right paranoia for a student-data product.
6. **Design system tokens are clean** (`DesignSystem/Theme/{LadderTheme,LadderBrand,ColorTokens,Typography,Spacing}.swift`). Brand colors codified, components reused, dark mode covered. Don't let any future refactor introduce one-off color hex codes.
7. **ADR discipline** (`docs/decisions/ADR-000…007`) — every significant architectural choice is recorded with reasoning. Keep doing this; it's the single biggest reason an external auditor can trust the project.
8. **GradeFeatureManager pattern** is the right shape for the grade 9–12 pivot — the gate exists, you "just" need to plug the actual features into it.

---

## Open Founder Decisions Surfaced

These are decisions only you can make. The pipeline cannot proceed cleanly until each is answered:

1. **Which product is canonical?** The IDEAS_DIGEST describes a **student-journey app** (career quiz → college matching → AI advisor → application tracker). The active build is a **B2B school-sandbox app** (founder oversight + school admins + counselors + scheduling + grade self-entry). These are different products. Pick one as v1, or define a merge order. Today the repo has both half-built and one of them quarantined.
2. **Stack confirmation** — sign off that **Supabase is canonical** and the AWS mention in `/Ideas/Ladder_CLAUDE.md` should be moved to `docs/historical/` so no future contributor gets confused.
3. **iPad parity** — either ship iPad now (revert `TARGETED_DEVICE_FAMILY: "1"` in `project.yml` and adapt every screen, per the Stitch specs) or formally drop the rule from your memory. Today the rule is in your `MEMORY.md` but the build violates it explicitly.
4. **Counselor freelance marketplace** — Ideas §5 calls for a "top 50 per state" ranked marketplace with bookings. Is this v1, v2, or never? It's a major scope question that affects schema design.
5. **Founder data wall enforcement** — `RequireNonFounderModifier` is defined but unused. Are you OK with the founder being able to read every tenant's data until that modifier is wrapped around every sensitive view, or do we add a backend assertion as well?
6. **Hardcoded pilot password** — is the plan to move to real Supabase auth before TestFlight, or are you intentionally shipping a shared password for the pilot? (Recommendation: real auth before any external user.)
7. **Legacy purge** — do we delete the ~210 quarantined files now (lossy but cleans the repo) or extract the engines into the active build first (slower but preserves work)?

---

## Recommended Next 3 PRs (in order)

### PR #1 — "Real Supabase auth + delete the hardcoded password"
**Files touched:**
- `LadderApp/Features/Auth/B2CLogin/B2CLoginView.swift` — replace `==` check with Supabase `signIn(email, password)`
- `LadderApp/Features/Auth/SchoolLogin/SchoolLoginView.swift` — same
- `LadderApp/Features/Founder/Login/FounderLoginView.swift` — same, with founder-claim verification
- `LadderApp/App/SignedInRouter.swift` — read role from JWT `role` claim, not email prefix; read grade from `students.grade_level`, not email switch
- `LadderApp/App/Configuration/AppConfiguration.swift` — fail fast if URL/anon-key missing; remove placeholder fallback
- `LadderApp/Services/Networking/TLSPinnedSession.swift` — paste real Supabase SPKI SHA-256 pins
- `LadderApp/Services/Tenant/TenantContext.swift` — wire `app.bind_session()` after login so RLS actually fires

**Why first:** Without this, every other feature is moot — no real user can sign in and the entire backend security model (RLS, DEK envelope, founder wall) is bypassed. This unlocks every other PR.

### PR #2 — "Resolve the two-product fork: pick one and gate the other"
**Files touched:**
- A new `docs/decisions/ADR-008-product-scope-decision.md` documenting which app is v1
- If sandbox-app wins: delete `Features/Legacy/`, `Services/Legacy/`, `DesignSystem/Legacy/`, plus the dead `Ladder.xcodeproj/`. Removes ~210 files and ~2.4 MB of search noise.
- If student-journey wins: un-exclude `Features/Legacy/**`, `Services/Legacy/**`, `App/Navigation/**`, `App/Configuration/**` from `project.yml:39-44`, then re-wire `MainTabView` as the post-auth root and connect `ConnectionEngine` to `StudentProfileModel`.
- Either way: delete the redundant `Ladder.xcodeproj/`, leaving only `LadderApp.xcodeproj/`.

**Why second:** Until this fork is resolved, every new feature has to be built twice (once for sandbox, once for journey) or be ambiguous about where it goes. Doing this after PR #1 means you can rebuild on top of working auth instead of fake auth.

### PR #3 — "iPad parity sweep + enable iPad target"
**Files touched:**
- `project.yml:46-48` — change `TARGETED_DEVICE_FAMILY: "1"` to `"1,2"` and remove the "iPad deferred" comment
- Every active view in `Features/{Admin,Counselor,Founder,Parent,Student,Auth,Landing}/` — add `horizontalSizeClass` checks per the Stitch iPad specs in `docs/design/stitch-batches/`
- Add `LadderApp/DesignSystem/Components/Layout/AdaptiveContainer.swift` (or similar) — a single layout component that switches between phone-stack and pad-split layouts so future views don't each reinvent the rule
- Enforce via the `ladder-ipad-parity` skill on every new view going forward

**Why third:** Your standing rule says iPad parity is mandatory and the build violates it. After PR #1 and #2, the surface area is smaller (one product, real auth) so the iPad sweep is bounded — do it now before the surface re-explodes.
