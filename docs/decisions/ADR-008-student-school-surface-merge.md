# ADR-008 — Student / School Surface Merge (Single App, Role-Routed)

**Status:** Proposed
**Date:** 2026-04-26
**Supersedes:** none
**Related:** ADR-001 (Supabase backend), ADR-005 (AI gateway), ADR-007 (grade 9–12 pivot), AUDIT_REPORT.md §"Big Architectural Gaps", PLAN.md Phase 2

**Status update log:**
- 2026-04-26: 4 open questions resolved by founder; schema changes pending Supabase-specialist review.

---

## 1. Context

The Ladder iOS repo currently ships **two products tangled together**:

1. **Student-journey app** — the original IDEAS_DIGEST vision: Career Quiz → Activity Suggestions → College Discovery → Application Tracker → AI Advisor → Essay Hub → Roadmap → Scholarships. ~210 source files. Quarantined under `Features/Legacy/` and `Services/Legacy/` and **excluded from the build** by `project.yml:39-44`. Engines: `ConnectionEngine`, `CollegeMatchCalculator`, `ActivitySuggestionEngine`, `StateRequirementsEngine`, `RIASECEngine`, `GradeFeatureManager`.

2. **School-surfaces app** — what is actually compiled today: ~73 files spanning founder dashboard, school-admin dashboard, counselor dashboard with student queue, parent dashboard. Came out of post-MVP school/counselor input.

Until 2026-04-26 this fork was unresolved. The audit's #1 open question to the founder was *"which product is canonical?"*

**Founder decision (2026-04-26):** **both ship together in v1.** Single binary, single Supabase backend, role-based routing decides which surface a user sees on sign-in. The student journey is the consumer product; the school surfaces are the wrap that makes Ladder defensible to schools, counselors, and parents.

This ADR specifies how the two products coexist in one iOS app.

### What the audit established as fixed before this ADR can be implemented

- Real Supabase auth replaces the hardcoded `==` password (PLAN Phase 1 #1–2).
- Role comes from JWT `role` claim, not email-prefix string match in `RoleDetector` (Phase 1 #7).
- Grade comes from `students.grade_level`, not `RoleDetector.gradeLevel(for:email)` (Phase 1 #8).
- iPad target re-enabled (`TARGETED_DEVICE_FAMILY: "1,2"`).
- Founder data wall actually wrapped on every non-founder root via `.requireNonFounder()` (Phase 1 #3).

This ADR assumes Phase 1 is green. It does not re-litigate those decisions.

---

## 2. Decision

### 2.1 Routing entrypoint

`SignedInRouter` reads `TenantContext.shared.claim.role` (a `TenantClaim` decoded from the Supabase JWT) and dispatches to exactly one **surface**. A "surface" is the post-auth root — a top-level container view that owns its own navigation stack, its own tab bar (if any), and its own set of feature modules.

**Routing table:**

| JWT `role` | Surface | Root view | Tab bar? |
|---|---|---|---|
| `student` | `StudentSurface` | `StudentSurface.swift` (new) → `MainTabView` | Yes — 5 tabs |
| `parent` | `ParentSurface` | existing `ParentDashboardView` | No |
| `counselor` | `CounselorSurface` | existing `CounselorDashboardView` | No (NavigationSplitView on iPad) |
| `admin` | `AdminSurface` | existing `AdminDashboardView` (school admin) | No |
| `founder` | `FounderSurface` | existing `FounderDashboardView` | No |

`SignedInRole` and `AppRole` are unified into `AppRole` (the `TenantContext` enum); the duplicate `SignedInRole` is deleted as part of this work. The five-case enum is canonical: there is no separate "School Admin" — `admin` *is* school admin.

The current `RoleDetector` (email-prefix routing, hardcoded grade lookup) is deleted in the same PR that ships `SupabaseAuthService`. `SignedInRouter.swift` becomes a 30-line pure dispatcher with no string-matching.

### 2.2 Shared services (used by every surface)

These live outside any surface folder and are owned by no single feature team:

- `Services/Auth/` — `SupabaseAuthService`, session lifecycle, JWT refresh.
- `Services/Tenant/` — `TenantContext` (already exists), `app.bind_session()` wiring, `requireNonFounder` modifier.
- `Services/Networking/` — `TLSPinnedSession`, `SupabaseManager`, `AIGatewayClient`.
- `Services/AI/` — `AIGatewayClient` + `AsyncThrowingStream` SSE adapter (currently missing — see PLAN Phase 4 #4).
- `Services/Crypto/` — `CryptoService` (envelope DEK ops).
- `Services/Audit/` — `AuditClient`.
- `Services/Flags/` — `GradeFeatureManager`, `FeatureGateManager`, `FlagClient`.
- `DesignSystem/` — every theme token + every component. No surface ships its own one-off colors or buttons.
- `Core/` — `Models/DomainEnums.swift` (un-quarantined), `Utilities/Log.swift`, shared value types.

### 2.3 Engines — ownership and cross-surface access

The six engines currently in `Services/Legacy/Engines/` are **student-surface domain logic** but the counselor surface needs **read access** to their outputs (a counselor must see a student's matched colleges, grade-gated unlocks, suggested activities, and Bright Futures status).

| Engine | Promoted path | Primary owner | Counselor access |
|---|---|---|---|
| `ConnectionEngine` | `Services/Engines/ConnectionEngine.swift` | Student | via projection |
| `CollegeMatchCalculator` | `Services/Engines/CollegeMatchCalculator.swift` | Student | via projection |
| `ActivitySuggestionEngine` | `Services/Engines/ActivitySuggestionEngine.swift` | Student | via projection |
| `StateRequirementsEngine` | `Services/Engines/StateRequirementsEngine.swift` | Student | via projection |
| `RIASECEngine` | `Services/Engines/RIASECEngine.swift` | Student | not needed |
| `GradeFeatureManager` | already at `Services/Flags/GradeFeatureManager.swift` | Shared | direct |

**Access pattern (decision):** counselors do **not** instantiate the engines client-side against another user's profile. Instead, the engines run **only inside the student's session**, and their outputs are **persisted as projections** into Postgres tables that the counselor surface reads through the standard RLS-governed query path:

- `student_college_matches(student_id, college_id, tier, computed_at)` — output of `CollegeMatchCalculator`
- `student_suggested_activities(student_id, activity_key, importance, completed)` — output of `ActivitySuggestionEngine`
- `student_state_requirements(student_id, requirement_key, satisfied, due_date)` — output of `StateRequirementsEngine`
- `student_feature_unlocks(student_id, feature_key, unlocked, reason)` — output of `GradeFeatureManager`

**Why projection over `EngineReadAdapter`:**

1. RLS enforcement is uniform — counselors read student data through the same `app.tenant_id` + role-based policy machinery as everything else. No second authorization path to audit.
2. Engines stay single-tenant single-user — no need to make `ConnectionEngine` re-entrant or thread-safe across student identities.
3. Counselor view is consistent with what the student last saw (last `computed_at`), not a re-computation that could disagree with the student's own screen.
4. Cheaper on the counselor side — a queue of 30 students renders from one indexed query, not 30 engine boots.

**Trade-off accepted:** projections add write amplification on every cascade and a `computed_at` staleness window. The cascade frequency is low (career change, GPA change, save-college) and the staleness is bounded by the student's own session activity, which is the right semantic.

### 2.4 Tab structure (StudentSurface)

Confirmed per IDEAS_DIGEST §7: **`Home / Tasks / Colleges / Advisor / Profile`**, five tabs, each with an independent `NavigationPath` owned by `AppCoordinator`. No revision.

Tab contents:
- **Home** — Dashboard, urgency cards, streak, quick actions, junior-year major re-prompt banner.
- **Tasks** — Grade-gated task list (filter by `task.minimumGrade ≤ profile.grade`), Roadmap accessible via push.
- **Colleges** — Discovery + Saved Colleges + College detail + MATCH/REACH/SAFETY chips.
- **Advisor** — Gemini chat (SSE streaming), Essay Hub accessible via push.
- **Profile** — Student profile, Edit Profile sheet, Career override, Career Explorer, Achievements, Settings, Logout.

Scholarships, Application Tracker, Deadlines Calendar are reachable as push destinations from Home and Colleges (not their own tabs — five tabs is the cap).

### 2.5 Folder layout (target state, post-merge)

```
LadderApp/
  App/
    LadderApp.swift              # @main
    SignedInRouter.swift         # role → surface dispatch (30 LOC)
    Configuration/
      AppConfiguration.swift     # un-quarantined; preflightOrCrash() at boot
    Navigation/
      AppCoordinator.swift       # un-quarantined
      Route.swift                # un-quarantined
      MainTabView.swift          # un-quarantined; child of StudentSurface
  Features/
    Auth/                        # shared across surfaces
      B2CLogin/
      SchoolLogin/
      FounderLogin/
      B2CSignup/
      InviteRedemption/
      Consent/                   # COPPA + 6 legal docs (currently missing)
    Student/                     # un-quarantined journey
      StudentSurface.swift       # NEW — wraps MainTabView, owns AppCoordinator
      Onboarding/                # 5-step wizard
      CareerQuiz/                # RIASEC + override + major picker
      Discovery/                 # college discovery + match chips
      Applications/              # tracker + deadlines + post-acceptance
      Essay/
      Advisor/                   # chat UI consumes Services/AI SSE
      Roadmap/
      Scholarships/
      Profile/
      ClassSuggester/            # already active; stays
    Counselor/                   # active sandbox (existing)
      CounselorDashboardView.swift
      StudentQueue/
    Parent/
      ParentDashboardView.swift
    Admin/                       # school admin
      AdminDashboardView.swift
    Founder/
      Dashboard/
      Login/
  Services/
    Auth/                        # NEW SupabaseAuthService
    Tenant/                      # existing
    Engines/                     # NEW — promoted from Services/Legacy/Engines/
      ConnectionEngine.swift
      CollegeMatchCalculator.swift
      ActivitySuggestionEngine.swift
      StateRequirementsEngine.swift
      RIASECEngine.swift
    AI/
    Networking/
    Crypto/
    Audit/
    Flags/
  DesignSystem/
    Theme/
    Components/
    Layout/
      AdaptiveContainer.swift    # NEW — phone-stack / pad-split switch
  Core/
    Models/
      DomainEnums.swift          # un-quarantined
    Utilities/
  Resources/
```

`Features/Legacy/`, `Services/Legacy/`, `DesignSystem/Legacy/` are **deleted** at the end of Phase 2. `project.yml` exclusions for `Features/Legacy/**`, `Services/Legacy/**`, `App/Navigation/**`, `App/Configuration/**`, `Models/DomainEnums.swift` are all removed.

### 2.6 Counselor → Student visibility

When a counselor opens a student profile from the counselor's StudentQueue, they see a **counselor-formatted summary view** — *not* a re-rendering of the student's actual journey screens.

**Counselor sees:**
- Identity strip (name, grade, school, last login).
- College list with MATCH/REACH/SAFETY chips, deadline urgency.
- Application status across all saved colleges (one table).
- Activities list with completion + 1–10 importance, longevity.
- Bright Futures / state requirements progress.
- Career path history (current + last two pivots).
- Tasks overdue / due in 7 days.
- Counselor notes (counselor-private; not visible to student).
- Action buttons: "Approve transcript", "Send nudge", "Add note".

**Counselor does NOT see:**
- The Duolingo streak, points, level-up animations.
- The AI Advisor chat history (see open question #2 — founder must confirm).
- Essay drafts (see open question #2).

**Why summary view, not the student's own screens:**
1. Counselor needs aggregate scan-ability ("which of my 30 students is stuck on essays?") that a tab-by-tab view can't provide.
2. Different access semantics — counselor edits notes the student can't see; student-only chrome (streaks, gamification) is noise to a counselor.
3. Avoids retrofitting every student view with a "counselor-mode" rendering branch.

The counselor view is read-from-projection (§2.3) plus a small `counselor_notes` table.

### 2.7 iPad layout strategy

| Surface | iPhone | iPad portrait | iPad landscape |
|---|---|---|---|
| StudentSurface (MainTabView) | 5-tab bottom bar | NavigationSplitView 2-col (sidebar = tabs, detail = content) | NavigationSplitView 2-col |
| CounselorSurface | single column | NavigationSplitView 2-col (sidebar = StudentQueue, detail = student summary) | NavigationSplitView 3-col (queue, summary, drill-down) |
| ParentSurface | single column | NavigationSplitView 2-col (sidebar = children, detail = child dashboard) | NavigationSplitView 2-col |
| AdminSurface | single column | NavigationSplitView 2-col (sidebar = sections, detail = panel) | NavigationSplitView 2-col |
| FounderSurface | single column | NavigationSplitView 2-col (sidebar = tenants, detail = tenant detail) | NavigationSplitView 3-col (tenants, tenant, drill) |
| Auth flows | single column | centered card max-width 480pt | centered card max-width 480pt |

`StudentQueueView` already uses `NavigationSplitView`; that pattern is the reference. A new `DesignSystem/Components/Layout/AdaptiveContainer.swift` encapsulates the phone-stack vs pad-split switch so no view re-implements the rule.

### 2.8 Migration order (smallest reversible PRs)

PRs are ordered by blast radius (smallest first) and by what unblocks the next PR:

1. **PR-A: Un-quarantine plumbing** — un-exclude `App/Navigation/**`, `App/Configuration/**`, `Models/DomainEnums.swift` from `project.yml`. Fix any compile errors. No behavior change yet — `MainTabView` is built but not routed to.
2. **PR-B: Promote engines** — move `ConnectionEngine`, `CollegeMatchCalculator`, `ActivitySuggestionEngine`, `StateRequirementsEngine`, `RIASECEngine` from `Services/Legacy/Engines/` to `Services/Engines/`. Add unit tests for each. No UI wiring yet.
3. **PR-C: StudentSurface shell** — create `Features/Student/StudentSurface.swift` that wraps `MainTabView`. Wire `SignedInRouter` to dispatch `.student` to `StudentSurface`. Tabs render placeholder views; no engine wiring.
4. **PR-D: Onboarding + CareerQuiz** — un-quarantine `OnboardingContainerView`, `OnboardingViewModel`, `AdaptiveCareerQuizView`. Wire to `RIASECEngine`. Run from first-time student login.
5. **PR-E: Discovery + Match** — un-quarantine Discovery views. Wire to `CollegeMatchCalculator`. Add `student_college_matches` projection table + RLS policy.
6. **PR-F: ConnectionEngine cascades** — wire all seven cascades from IDEAS_DIGEST §9. Cascade unit tests.
7. **PR-G: Tasks + Roadmap + Activity Suggestions** — un-quarantine. Wire to `ActivitySuggestionEngine` + `GradeFeatureManager` + `StateRequirementsEngine`.
8. **PR-H: Essay Hub + Application Tracker + Post-Acceptance** — un-quarantine. Implement post-acceptance auto-transform (currently missing — IDEAS feature #7).
9. **PR-I: Advisor SSE wiring** — adapt `AIGatewayClient` to `AsyncThrowingStream`, wire to chat UI.
10. **PR-J: Counselor projection reads** — counselor StudentQueue + summary view reads from projection tables.
11. **PR-K: Delete Legacy** — `Features/Legacy/`, `Services/Legacy/`, `DesignSystem/Legacy/`, plus `Ladder.xcodeproj/`. Final.

PRs A–C are within Phase 2a–2b. PRs D–J are Phase 2c–2d. PR-K closes Phase 2.

Each PR is independently revertable. None of D–J is allowed to ship without unit tests on the engine it touches.

### 2.9 Per-school theming + per-school feature toggles (NEW)

**Default behavior:** a school-tenant student sees the **same** student app as a self-paying B2C student. There is no automatic flavoring based on `tenant_id`.

**Founder-controlled override (new capability):** the FounderSurface gains a "Manage School" view per tenant. Founder (and only founder) can, per school:

- Override theme colors: `tenants.theme_primary_color text`, `tenants.theme_accent_color text` (hex). When set, those colors override the default Ladder theme for students in that tenant.
- Toggle custom features ON/OFF: `tenants.enabled_features jsonb` — array of feature flag keys (e.g. `["school_class_catalog", "school_specific_roadmap"]`). Defaults to `[]`. Features are NOT self-serve to school admins; only founder writes them.

**Client wiring:** a SwiftUI `ThemeProvider` env object reads from `TenantContext.tenantTheme` (populated when the JWT-bound tenant row is fetched). `DesignSystem/Theme/` falls back to default Ladder palette when fields are null. Feature gates are checked through `FeatureGateManager.isEnabledForTenant(_:)` which reads `enabled_features`.

**RLS:** writes to `tenants.theme_primary_color`, `tenants.theme_accent_color`, `tenants.enabled_features` are restricted to JWT `role = 'founder'`. All authenticated tenant members get read access to their own tenant row.

This resolves open question #1 and supersedes the "additional cards on Home" default proposal.

### 2.10 Parent surface — multi-child dashboard

ParentSurface is a **parent-formatted digest**, not a read-only mirror of any child's student surface.

**Flow:**

1. `ParentSurface.swift` (new wrapper) → `ChildPickerView` lists the parent's children as tiles (e.g. "John, Dave, Sabrina"). One tile per child.
2. Tap a child → `ChildSummaryView` renders that child's parent-formatted summary, scoped to one child at a time.

**`ChildSummaryView` content (per child):**

- Recent activity feed — last 7 days of student app actions (login, college saved, essay edited, task completed). Source: `audit_events` filtered by `student_user_id`.
- Counselor's report (school-enrolled students only) — pulls latest entry from `counselor_notes` flagged `parent_visible = true`.
- Lag detection — pure SQL/derived fields, **not AI**: missed deadlines (`tasks.due_date < now() and completed = false`), application progress vs grade-level benchmark, GPA trend.
- Suggested ways to help — templated copy keyed off lag patterns (e.g. "John has 3 overdue Common App tasks — sit with him this weekend"). No LLM call.

**Parent–child link:** new table `parent_child_links(parent_user_id uuid, student_user_id uuid, status text check (status in ('pending','active','removed')), created_at, primary key (parent_user_id, student_user_id))`. Established at parent signup or via invite-redemption (parent receives an invite code from the student or from school admin).

This extends — does not replace — `ParentDashboardView`. Resolves open question #2 and overrides the "(b) separate parent-formatted dashboard" default with the multi-child variant.

### 2.11 Counselor full read access to AI chats + essays

**Status (2026-04-27):** Founder confirmed counselor full read access is correct. The "your data is yours" promise means tenant-portability, not hiding from your current school. See SPEC_v2 §2.2 (privacy guarantee variants).

Counselors get **read access** to `student_ai_chats` and `student_essays` for any student where the counselor's `counselor_id` matches the student's assigned counselor. There is no per-item opt-in by the student.

**RLS policy:** `select` on `student_ai_chats` and `student_essays` allowed when `auth.jwt() ->> 'role' = 'counselor'` AND `student_id IN (select id from students where assigned_counselor_id = auth.uid())`.

**Consent flow update (mandatory):** the COPPA + 6-doc legal/consent flow (`Features/Auth/Consent/`) must surface explicit copy at student signup: *"Your school counselor can see your AI advisor chats and your essay drafts."* Signup blocks until acknowledged. This applies only to school-tenant students; B2C students see no counselor language because they have no counselor.

The counselor view (§2.6) is amended: chat history and essay drafts ARE visible to counselors.

### 2.12 Counselor freelance marketplace — tenant-gated visibility

The marketplace ships in v1 as a **visibility rule**, not a sixth surface or sixth role.

- **B2C users** (`TenantContext.shared.tenantId == nil`): a `MarketplaceTab` (or push entry "Find a Counselor Near You") is rendered inside `StudentSurface`. Surfaces counselor profiles, ratings, booking, scheduling.
- **School-tenant users** (`tenantId != nil`): the marketplace entry point is hidden. They already have a school counselor; surfacing a freelancer creates conflict.

The full counselor-profile / rating / booking schema is **deferred to a sub-spec** before PR-J ships. The visibility/routing rule is decided now and lives in `StudentSurface` tab assembly.

This resolves open question #4 and overrides the "out of v1" default with a v1 visibility rule plus deferred schema.

---

## 3. Consequences

### Positive

- Founder vision (consumer student journey, $8/mo) and school-side asks (counselor oversight, school admin, parent visibility) ship in **one binary, one backend, one auth system**. No code duplication.
- Distribution flywheel: a school sign-up brings in students *and* parents *and* counselors as users of the same app — network effect inside a single tenant.
- The seven ADRs already accepted (Supabase, RLS, DEK envelope, AI gateway, prompt-injection defense, grade 9–12 pivot) all continue to apply unchanged. This ADR is additive to the architecture, not a rewrite.
- Engines move out of quarantine and get unit tests for the first time. The audit's "engines exist as code but not compiled" gap closes.
- Counselor → student visibility through projections aligns with the existing RLS model — no second authz path to audit.
- Per-school theming + per-school feature toggles (§2.9) give the founder a B2B sales lever — schools can be sold a "feels native to your school" experience without a code change.

### Negative

- App size grows (~210 files un-quarantine; net ~+2.4 MB compiled).
- More code paths and more QA surface — five surfaces × iPhone + iPad = 10 layout configurations to regression-test per release.
- Role-based routing becomes a single point of failure: if the JWT `role` claim is wrong or missing, the user lands somewhere wrong. Mitigation: routing has a hard default of "show error screen, force re-login," not "fall through to student."
- Projection tables add write amplification on every cascade. Acceptable at pilot scale (one K-8 tenant); revisit at the 10K-student tier.
- Parent surface (§2.10) is more work than the read-only mirror would have been: new picker view, new summary view, lag-detection SQL, templated-suggestion logic, and a `parent_child_links` table with invite-redemption flow.
- Counselor full visibility into AI chats + essays (§2.11) raises COPPA/consent stakes: signup copy, parental consent for under-13s, and audit-log requirements all expand. A consent miss here is a regulatory incident, not a UX bug.
- Marketplace tenant-gating (§2.12) adds a routing branch in `StudentSurface` assembly and a deferred sub-spec — the schema isn't free, just postponed.

### Risks

- **R1 — Stale assumptions in legacy engines.** Engines in `Services/Legacy/` were written against a Supabase v1 schema and possibly old SwiftData models. Un-quarantining will surface compile errors and runtime mismatches. **Mitigation:** PR-B promotes engines without UI wiring and triages compile errors first; engines that depend on dead schema get rewritten against the current `LadderBackend/supabase/migrations/`.
- **R2 — ConnectionEngine cascade retain cycles.** The audit (Ladder_Audit_Prompt.md) flagged retain cycles in the original `ConnectionEngine`. **Mitigation:** PR-F adds explicit `[weak self]` in every observer closure and ships a leak test in `LadderAppTests`.
- **R3 — Projection write-amplification at scale.** Every cascade writes to 1–4 projection tables. **Mitigation:** debounce in `ConnectionEngine` (coalesce writes within a 2s window per student). Add a `computed_at` index for counselor-side staleness queries.
- **R4 — Counselor role visibility scope creep.** Founder may later want counselors to see chat history or essays. **Mitigation:** open question #2 below — answer it before PR-J ships.

---

## 4. Founder Decisions (All Resolved)

All questions resolved by founder on 2026-04-26 (ADR-008) and 2026-04-27 (SPEC_v2 Q1–Q4). Schema migration plan pending Supabase-specialist review.

### ADR-008 Questions (Resolved 2026-04-26)

1. **Tenant-flavored vs identical student app.** **RESOLVED — see §2.9.** Default = same app as B2C; founder-controlled per-school theming (primary/accent colors) and per-school feature toggles override on a per-tenant basis. Not self-serve to school admins.

2. **Parent surface scope.** **RESOLVED — see §2.10.** Multi-child dashboard: child picker → parent-formatted summary per child (recent activity, counselor report, lag detection, templated suggestions). Not a mirror.

3. **Counselor visibility into chat + essays.** **RESOLVED — see §2.11.** Counselors get full read access to `student_ai_chats` and `student_essays`. Mandatory consent copy at student signup; no per-item opt-in. Rationale confirmed 2026-04-27: tenant-portability model (SPEC_v2 §2.2).

4. **Counselor freelance marketplace.** **RESOLVED — see §2.12.** In v1 as a tenant-gated visibility rule: shown to B2C (`tenantId == nil`), hidden for school-tenant users. Counselor profile/booking schema deferred to a sub-spec.

### SPEC_v2 Questions (Resolved 2026-04-27)

See SPEC_v2 §6 for all resolutions: Q1 (privacy variants), Q2 (no parent approval), Q3 (3-stage transfer model), Q4 (extracurricular curation — default pending confirmation).

---

## 5. Required schema changes

Net-new columns and tables introduced by §2.9–§2.12. Pending Supabase-specialist review.

**Columns added to `tenants`:**
- `theme_primary_color text null` — hex; null → use Ladder default.
- `theme_accent_color text null` — hex; null → use Ladder default.
- `enabled_features jsonb not null default '[]'::jsonb` — array of feature flag keys.

**New table — `parent_child_links`:**
- `parent_user_id uuid not null references auth.users(id)`
- `student_user_id uuid not null references auth.users(id)`
- `status text not null check (status in ('pending','active','removed'))`
- `created_at timestamptz not null default now()`
- Primary key: `(parent_user_id, student_user_id)`
- Index on `parent_user_id` for the picker query.

**RLS policies needed:**
- `tenants.theme_*` and `tenants.enabled_features` writes restricted to `role = 'founder'`; reads open to authenticated tenant members for their own tenant row.
- `student_ai_chats` and `student_essays`: counselor `select` allowed when `student_id IN (select id from students where assigned_counselor_id = auth.uid())`.
- `parent_child_links`: parent reads own rows; student reads own rows; founder/school-admin manages on behalf of tenant.
- `counselor_notes`: add `parent_visible boolean not null default false` flag (referenced by §2.10 parent summary).

**Columns referenced but assumed already present (verify in `LadderBackend/supabase/migrations/`):**
- `students.assigned_counselor_id uuid` — required by counselor RLS in §2.11.
- `tasks.due_date`, `tasks.completed` — required by lag-detection SQL in §2.10.
- `audit_events(student_user_id, type, created_at)` — required by recent-activity feed in §2.10.

Counselor profile / rating / booking schema for the marketplace (§2.12) is deferred to a sub-spec.

---

## 6. Implementation plan

This ADR is operationalized by **PLAN.md Phase 2** (lines 32–61). Phase 2a writes this ADR; Phase 2b–2d execute PRs A–K.

Phase 2 cannot start until Phase 1 (foundation: real auth, JWT-based role, iPad target enabled, founder wall enforced) is green. Phase 3 (iPad parity sweep) and Phase 4 (cleanup + hardening) follow.

The four open questions are now resolved (§4). Schema changes in §5 must be reviewed by a Supabase specialist before this ADR moves to Accepted, and the migrations must land before PR-D (Onboarding + CareerQuiz) and PR-J (Counselor projection reads) ship.
