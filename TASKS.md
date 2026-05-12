# TASKS.md — Ladder v1.0 launch (target: 2026-05-27)

**Total tasks:** 39
**Dependency levels:** 6 (Day-bands)
**Estimated complexity:** L
**Success metric:** A student-role login opens the app, converses with SIA, and their memory persists across reinstall; a counselor sees that student's SIA summary (never raw chat); the founder cannot read tenant data without permission; all views render correctly on iPad and iPhone; TestFlight build passes smoke test.

---

## Source of truth
- Spec: `SPEC_v2.md` (locked) + `DECISIONS.md` (overrides — D-001..D-005)
- Plan: `PLAN.md`
- Persona research: `SIA_PERSONA_RESEARCH.md` (in flight, parallel to Day-band 1)

## How to read this
- Tasks are grouped by Day-band (matches `DECISIONS.md` D-005 calendar)
- Each task has: id, owner, inputs, deliverable, acceptance check, est. complexity
- Tasks inside the same Day-band are parallelizable unless an explicit `depends_on` is noted
- Tasks across Day-bands run sequentially (do not start Day-band N+1 until N is fully accepted)

---

## Day-band 1 (Days 1-3, 5/12-5/14): Hard blockers

### T001 — Founder data wall enforcement
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Services/Tenant/TenantContext.swift`, all root views under `LadderApp/Features/{Student,Counselor,Admin,Parent}/`
- **files_touched:**
  - `LadderApp/Services/Tenant/TenantContext.swift`
  - Sub-bullets — every view that must receive `.requireNonFounder()`:
    - `Features/Student/StudentDashboardView.swift`
    - `Features/Counselor/Dashboard/CounselorDashboardView.swift`
    - `Features/Counselor/StudentQueue/StudentQueueView.swift`
    - `Features/Counselor/SchedulingWindow/SchedulingWindowView.swift`
    - `Features/Admin/AdminTabView.swift`
    - `Features/Admin/TeacherProfiles/TeacherProfilesView.swift`
    - `Features/Admin/SuccessMetricsPopup/SuccessMetricsPopupView.swift`
    - `Features/Parent/` (all root views)
    - grep command to confirm zero-callers resolved: `grep -r "requireNonFounder" LadderApp/Features/`
- **acceptance:** `grep -r "requireNonFounder" LadderApp/Features/` returns at least one hit per role folder above; a Founder-role login cannot reach any of those views without receiving a block; `TenantContext.requireNonFounder` still passes for non-founder roles
- **est. complexity:** S

### T002 — TLS pins + AppConfig preflight crash
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Services/Networking/TLSPinnedSession.swift` (placeholder bytes 0x00/0x01 at lines 18-30), `LadderApp/App/Configuration/AppConfiguration.swift`, `LadderApp/LadderApp.swift`
- **files_touched:**
  - `LadderApp/Services/Networking/TLSPinnedSession.swift` — replace placeholder bytes with real Supabase SPKI SHA-256 hashes
  - `LadderApp/App/Configuration/AppConfiguration.swift` — add `preflightOrCrash()` that fatal-errors on blank/placeholder URL or anon-key
  - `LadderApp/LadderApp.swift` — call `AppConfig.preflightOrCrash()` in `init()`
  - `.github/workflows/ci.yml` — add step that greps for `0x00, 0x00` in TLSPinnedSession and fails the build if found
- **acceptance:** app crashes with a clear log message when launched with missing env config; CI build fails if placeholder bytes are re-introduced; a real Supabase network call succeeds in a device/simulator run
- **est. complexity:** S

### T003 — S1-5: Wire counselor queue action buttons
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift` lines 68-72 (`/* TODO */` stubs)
- **files_touched:** `LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift`
- **acceptance:** "Approve", "Send back", and "Modify & approve" buttons each call `PATCH /rest/v1/schedules?id=eq.{id}` with the correct `state` value; loading state shown during request; success/failure surfaced to counselor
- **est. complexity:** S

### T004 — S1-6: Fix grades lost on navigation
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Student/GradesSelfEntry/GradesSelfEntryView.swift` line 16 (`@State var grades`), `LadderApp/App/Data/SwiftDataContainer.swift` line 36 (`GPAEntryModel` is registered)
- **files_touched:** `LadderApp/Features/Student/GradesSelfEntry/GradesSelfEntryView.swift`
- **acceptance:** grades entered by the student survive navigation away and back; the SwiftData `@Query` is used; new grades are written to SwiftData then synced to Supabase `students` table; a second launch of the app shows the same grades
- **est. complexity:** S

### T005 — S1-8: Fix scheduling window permanently disabled
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Counselor/SchedulingWindow/SchedulingWindowView.swift` lines 10-12, 32 (all precondition booleans default `false`)
- **files_touched:** `LadderApp/Features/Counselor/SchedulingWindow/SchedulingWindowView.swift`
- **acceptance:** precondition states (`prereqsReady`, `teacherSchedulesReady`, `classCatalogReady`) are fetched from DB on `.task`; button is enabled when all three are true per real DB state; counselor can toggle them manually if the DB fetch is unavailable
- **est. complexity:** S

### T006 — S1-9: Fix parent invite fake codes
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Student/ParentInvite/ParentInviteView.swift` line 54 (client-generated UUID)
- **files_touched:** `LadderApp/Features/Student/ParentInvite/ParentInviteView.swift`
- **acceptance:** "Generate invite" calls `POST /rest/v1/rpc/generate_parent_invite`; the server-returned code is displayed; code is stored in Supabase; a parent can redeem the code on a separate device
- **est. complexity:** S

### T007 — S1-10: Wire feature flags Save
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Founder/FeatureFlags/FeatureFlagsView.swift` lines 212-214 (`// TODO:` save stub)
- **files_touched:** `LadderApp/Features/Founder/FeatureFlags/FeatureFlagsView.swift`
- **acceptance:** tapping Save calls `POST /rest/v1/feature_flags` (or the `varun-validate` edge function); a success toast appears; re-opening FeatureFlagsView shows the persisted toggle states; no local revert on re-entry
- **est. complexity:** S

### T008 — Delete legacy Ladder.xcodeproj + historical file cleanup
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `Ladder-Oloid (WIP)/App/Ladder.xcodeproj/` (2,142-line legacy project file), `Ideas/Ladder_CLAUDE.md`
- **files_touched:**
  - Delete `Ladder-Oloid (WIP)/App/Ladder.xcodeproj/` directory
  - Move `Ideas/Ladder_CLAUDE.md` → `docs/historical/Ideas_Ladder_CLAUDE.md`
  - `.gitignore` — add entry for `*.xcodeproj` at old WIP path
- **acceptance:** only `LadderApp.xcodeproj` remains in repo root search; `git status` shows no untracked xcodeproj; `docs/historical/` contains the moved file
- **est. complexity:** XS

---

## Day-band 2 (Days 4-7, 5/15-5/18): SIA visible

### T009 — Migration 0010: student_memory_summaries + student_nudge_log + RLS
- **agent:** `postgres-specialist`
- **deps:** []
- **inputs:** `SPEC_v2.md §2.5` (schema spec), `DECISIONS.md D-003` (RLS requirements), `LadderBackend/supabase/migrations/` (existing 0001-0009)
- **files_touched:**
  - `LadderBackend/supabase/migrations/0010_sia_memory.sql` (new)
- **deliverable:** migration creates:
  - `student_memory_summaries(id uuid PK, student_user_id uuid NOT NULL, summary_text text, embedding vector(1536), created_at timestamptz, session_id uuid)` — requires `pgvector` extension confirmed enabled
  - `student_nudge_log(id uuid PK, student_user_id uuid NOT NULL, nudge_type text, trigger_event text, dismissed boolean DEFAULT false, acted boolean DEFAULT false, created_at timestamptz)`
  - RLS on both tables:
    - Student policy: `auth.uid() = student_user_id` for SELECT/INSERT/UPDATE/DELETE
    - Counselor policy (per **D-002** and **D-003**): counselors can SELECT from `student_memory_summaries` for students assigned to their tenant — NOT `student_chat_messages`; zero counselor access to `student_nudge_log`
    - No other roles have access
- **acceptance:** `supabase db push` applies cleanly to a fresh DB; RLS test in `tests/crypto/` or new `tests/rls/sia_isolation.test.ts` confirms a counselor JWT can read summaries but not nudge log; a student JWT cannot read another student's rows
- **est. complexity:** S

### T010 — SIA isolation runtime assertion
- **agent:** `swift-ios-specialist`
- **deps:** [T009]
- **inputs:** `LadderApp/Services/AI/SiaEngine.swift`, `LadderApp/Services/AI/StudentContextBuilder.swift`, `DECISIONS.md D-003`
- **files_touched:**
  - `LadderApp/Services/AI/StudentContextBuilder.swift` — add identity assertion
  - `LadderApp/Services/AI/SiaEngine.swift` — thread `studentId: String` through every context-load call
  - `tests/LadderAppTests/SiaIsolationTests.swift` (new)
- **deliverable:** every `StudentContextBuilder.build()` call receives the JWT `auth.uid()` and asserts it matches the loaded `StudentModel.userId` before returning context; `SiaEngine` carries `studentId` param on every public method
- **binding constraint (D-003):** "Runtime assertion in SiaEngine: every context-load and every prompt-build must include the active `studentId` and assert it matches the authenticated user (or the counselor's authorized lookup). No shared embedding cache keyed by anything other than `studentId`."
- **acceptance:**
  - A deliberate negative test in `SiaIsolationTests.swift` passes: load Student B's `StudentModel` into a session authenticated as Student A → assertion fires with a clear error message, context is NOT returned
  - Normal single-student flow continues to work
- **est. complexity:** S

### T011 — AdvisorChatView un-quarantine (port + rewrite)
- **agent:** `swift-ios-specialist`
- **deps:** [T010]
- **inputs:**
  - Legacy source: `LadderApp/Features/Legacy/AIAdvisor/Views/AdvisorChatView.swift` (quarantined — DO NOT move; port + rewrite into active code)
  - Legacy ViewModel: `LadderApp/Features/Legacy/AIAdvisor/ViewModels/AdvisorChatViewModel.swift` (same: port + rewrite, not a direct move)
  - Active chat models: `LadderApp/Features/Student/AIAdvisor/Models/ChatModels.swift`
  - Active AI client: `LadderApp/Services/Networking/AIGatewayClient.swift`
  - Active auth: `LadderApp/Services/Auth/SupabaseAuthService.swift`
  - Active engine: `LadderApp/Services/AI/SiaEngine.swift`
- **files_touched:**
  - `LadderApp/Features/Student/AIAdvisor/Views/AdvisorChatView.swift` (new, ported + rewritten)
  - `LadderApp/Features/Student/AIAdvisor/ViewModels/AdvisorChatViewModel.swift` (new, ported + rewritten)
  - `LadderApp/Features/Student/StudentDashboardView.swift` — wire Advisor tab to new AdvisorChatView
- **note:** this is a **port + rewrite**, NOT a file move. The legacy `AdvisorChatView` targets the old `AIService` and old `AuthManager`; all AI calls must be rewritten to use `AIGatewayClient`; all auth references must use `SupabaseAuthService`. The legacy file remains quarantined in `Features/Legacy/`.
- **acceptance:** a student-role user can navigate to the Advisor tab and send a message; SIA responds via `AIGatewayClient`; chat messages are appended to the transcript; loading state visible during AI call; no reference to `AIService` or `AuthManager` (legacy) in the new files
- **est. complexity:** M

### T012 — SIA memory sync to Supabase
- **agent:** `swift-ios-specialist`
- **deps:** [T009, T011]
- **inputs:** `LadderApp/Services/AI/MemoryExtractorService.swift`, `LadderApp/Services/AI/ConversationMemoryStore.swift`, migration 0010 (`student_memory_summaries`)
- **files_touched:**
  - `LadderApp/Services/AI/MemoryExtractorService.swift` — after local SwiftData write, upsert to `student_memory_summaries` via Supabase client
- **acceptance:** after a chat session ends, a row appears in `student_memory_summaries` matching the student's UUID; on app reinstall, `StudentContextBuilder` retrieves the persisted summaries from Supabase (not just local SwiftData); memory is not shared between two distinct student UUIDs
- **est. complexity:** S

### T013 — Proactive nudge card on Home tab
- **agent:** `swift-ios-specialist`
- **deps:** [T009, T011]
- **inputs:** `LadderApp/Services/AI/NudgeRules.swift`, `LadderApp/Features/Student/StudentDashboardView.swift` (urgency section), `SPEC_v2.md §2.4` (trigger events + "no more than 2 new nudges per session")
- **files_touched:**
  - `LadderApp/Features/Student/StudentDashboardView.swift` — add nudge card to urgency section
  - `LadderApp/Services/AI/NudgeRules.swift` — wire `evaluate()` output to a `@Published` property consumed by the dashboard
  - Writes dismissed/acted state to `student_nudge_log`
- **acceptance:** on student login, if `NudgeRules.evaluate()` returns at least one nudge, a card appears in the Home tab urgency section; tapping the card records `acted = true` in `student_nudge_log`; dismissing records `dismissed = true`; a dismissed nudge does not re-appear for 30 days; no more than 2 new nudges surface per session
- **est. complexity:** M

### T014 — ai-gateway safeSerialize fix + rate limiting
- **agent:** `supabase-specialist`
- **deps:** []
- **inputs:** `LadderBackend/supabase/functions/ai-gateway/index.ts` (safeSerialize regex bug, rate-limit TODO stub)
- **files_touched:**
  - `LadderBackend/supabase/functions/ai-gateway/index.ts`
  - `LadderBackend/tests/` — add unit test for safeSerialize
- **acceptance:** `safeSerialize` regex is `/[\x00-\x1f]/g` (not `/\s-/g`); a per-user per-minute rate limit is implemented (not a TODO stub); rate limit returns HTTP 429 with a clear message; existing `deno test` suite passes
- **est. complexity:** S

---

## Day-band 3 (Days 8-9, 5/19-5/20): SIA persona + counselor surface + S2 bugs

### T015 — SIA persona implementation (D-001)
- **agent:** `claude-api-specialist`
- **deps:** [T011, T012]
- **inputs:** `DECISIONS.md D-001` (warm-mentor + professional counselor blended persona), `SIA_PERSONA_RESEARCH.md` (Rogerian + motivational interviewing research, delivered in parallel), `LadderBackend/supabase/functions/ai-gateway/index.ts`, `LadderApp/Services/AI/Prompts/SpecialistPrompts.swift`
- **files_touched:**
  - `LadderBackend/supabase/functions/ai-gateway/index.ts` — update system prompt block
  - `LadderApp/Services/AI/Prompts/SpecialistPrompts.swift` — update opening context injection for new-student first session
- **binding constraint (D-001):** "SIA speaks like an empathetic older sibling (warm-mentor delivery: curiosity-first, no jargon, validates feelings before advising) AND has the actual competence of a trained school counselor (motivational interviewing, age-appropriate scaffolding for ages 13-18, college-prep substance, ethics/safety boundaries). It is NOT just a friendly chatbot. It is NOT a stiff coach. It is the school counselor every student wishes they had. Adapts per student over time but the starter tone is always warm-mentor."
- **acceptance:** a new student's first message receives a response matching the warm-mentor archetype (curiosity-first opening, no jargon, validates before advising); `SpecialistPrompts.swift` opening message is updated from any prior placeholder; a returning student's context (memory summaries) is incorporated into tone adaptation
- **est. complexity:** M

### T016 — Counselor summary surface (D-002)
- **agent:** `swift-ios-specialist`
- **deps:** [T009, T012, T015]
- **inputs:** `DECISIONS.md D-002` (summary + safety-flag only — no raw chat), `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift`, `LadderApp/Services/AI/SiaEngine.swift`
- **files_touched:**
  - `LadderApp/Services/AI/SiaEngine.swift` — add `summarize(studentId:)` and `briefCounselor(studentId:, question:)` methods
  - `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift` — new per-student card showing: topic summary, active safety flags, last-active timestamp, "Ask SIA" button
  - `LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift` — link to the new card from the student queue
- **binding constraint (D-002):** "Counselor CAN see: SIA-generated topic summary + active safety flags + last-active timestamp. Counselor CANNOT scroll the student's chat history. 'Ask SIA' button triggers `SiaEngine.briefCounselor(studentId:, question:)` — SIA decides what to surface, never dumps raw transcript."
- **acceptance:** a counselor-role login sees a per-student summary card; no raw chat messages are visible to the counselor at any UI path; "Ask SIA: what does this student need from me this week?" button calls `briefCounselor` and renders the response in the card; RLS on `student_chat_messages` rejects a counselor's direct read attempt
- **est. complexity:** M

### T017 — S2 bug batch: career quiz scoring
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Student/CareerQuiz/CareerQuizView.swift` line 48-53 (`// TODO: POST` scoring)
- **files_touched:** `LadderApp/Features/Student/CareerQuiz/CareerQuizView.swift`
- **acceptance:** `finish()` calls `ai-gateway` for RIASEC scoring; a `career_profile_vector_cipher` row is written to Supabase under the student's UUID; quiz is marked complete server-side; features gated on career profile behave correctly after quiz completion
- **est. complexity:** S

### T018 — S2 bug batch: ClassSuggesterView real AI call
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Student/ClassSuggester/ClassSuggesterView.swift` lines 43-49 (500ms sleep + empty list)
- **files_touched:** `LadderApp/Features/Student/ClassSuggester/ClassSuggesterView.swift`
- **acceptance:** `load()` calls `AIGatewayClient.shared.call(feature: .classSuggestion, ...)` with the student's grade and career profile; actual suggestions are returned and rendered; an empty-state message shows if the AI returns no suggestions; loading state is visible during the request
- **est. complexity:** S

### T019 — S2 bug batch: counselor dashboard real KPIs
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift` lines 66-67, 122-126 (hardcoded mock KPIs)
- **files_touched:** `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift`
- **acceptance:** KPIs ("schedules waiting", "students count", activity feed) are fetched from Supabase on `.task`; values update to reflect actual DB state; hardcoded literals `"12 schedules waiting"`, `"428 students"`, `"Alice submitted…"` are gone; a loading state is shown during fetch
- **est. complexity:** S

### T020 — S2 bug batch: CounselorInviteCodesView server-side codes
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Counselor/InviteCodes/CounselorInviteCodesView.swift` lines 50-54 (client-side UUID generation)
- **files_touched:** `LadderApp/Features/Counselor/InviteCodes/CounselorInviteCodesView.swift`
- **acceptance:** code generation calls `POST /rpc/counselor_issue_invite`; server-returned codes are displayed and stored in Supabase; a student can redeem a counselor-issued code (S1-1 root-cause closed)
- **est. complexity:** S

### T021 — S2: Legal domain fix + S2-11
- **agent:** `swift-ios-specialist`
- **deps:** []
- **inputs:** `LadderApp/Features/Founder/SchoolDetail/SchoolDetailView.swift` lines 33-34 (`purewavejosh.com/legal/…`)
- **files_touched:** `LadderApp/Features/Founder/SchoolDetail/SchoolDetailView.swift`
- **acceptance:** DPA and liability URLs point to the production legal domain (founder to provide the real domain before this task starts — note as a dependency on founder input); `purewavejosh.com` is absent from all active Swift files
- **est. complexity:** XS

---

## Day-band 4 (Days 10-11, 5/21-5/22): iPad parity sweep

> All tasks in this band carry the `ladder-ipad-parity` skill. Each task adds `horizontalSizeClass` checks and uses `NavigationSplitView` for column layouts on iPad. A shared `AdaptiveContainer.swift` is created in T022 and reused by T023-T027.

### T022 — AdaptiveContainer + Auth flows iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T011, T013, T016]
- **inputs:** `LadderApp/DesignSystem/`, `LadderApp/Features/Auth/`, `LadderApp/Features/Landing/`
- **files_touched:**
  - `LadderApp/DesignSystem/Components/Layout/AdaptiveContainer.swift` (new — shared layout component switching between phone-stack and pad-split)
  - `LadderApp/Features/Auth/B2CLoginView.swift` — iPad layout
  - `LadderApp/Features/Auth/SchoolLoginView.swift` — iPad layout
  - `LadderApp/Features/Auth/B2CSignup/B2CSignupView.swift` — iPad layout
  - `LadderApp/Features/Landing/LandingView.swift` — iPad layout
- **acceptance:** all Auth and Landing screens render without clipped layouts on iPad Air (10.9") and iPad Pro 12.9" in both portrait and landscape; `AdaptiveContainer` is present and reusable; no new one-off layout code in individual views
- **est. complexity:** M

### T023 — Student dashboard + AdvisorChatView iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T022]
- **inputs:** `LadderApp/Features/Student/StudentDashboardView.swift`, `LadderApp/Features/Student/AIAdvisor/Views/AdvisorChatView.swift` (from T011)
- **files_touched:**
  - `LadderApp/Features/Student/StudentDashboardView.swift`
  - `LadderApp/Features/Student/AIAdvisor/Views/AdvisorChatView.swift`
  - `LadderApp/Features/Student/GradesSelfEntry/GradesSelfEntryView.swift`
  - `LadderApp/Features/Student/CareerQuiz/CareerQuizView.swift`
  - `LadderApp/Features/Student/ClassSuggester/ClassSuggesterView.swift`
- **acceptance:** all five Student views render on iPad in portrait and landscape with no clipped layouts; AdvisorChatView uses a split layout on iPad (message list left, input right or sidebar); nudge card is visible on Home tab on iPad
- **est. complexity:** M

### T024 — Counselor dashboard + queue iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T022, T016]
- **inputs:** `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift`, `LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift`, `LadderApp/Features/Counselor/SchedulingWindow/SchedulingWindowView.swift`
- **files_touched:**
  - `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift`
  - `LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift`
  - `LadderApp/Features/Counselor/SchedulingWindow/SchedulingWindowView.swift`
  - `LadderApp/Features/Counselor/InviteCodes/CounselorInviteCodesView.swift`
- **acceptance:** counselor queue uses `NavigationSplitView` on iPad (student list left column, detail right column); SIA summary card visible in detail column; no hardcoded frame widths that clip on larger screens
- **est. complexity:** M

### T025 — Founder dashboard + FeatureFlags iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T022]
- **inputs:** `LadderApp/Features/Founder/Dashboard/FounderDashboardView.swift`, `LadderApp/Features/Founder/FeatureFlags/FeatureFlagsView.swift`, `LadderApp/Features/Founder/SchoolDetail/SchoolDetailView.swift`
- **files_touched:**
  - `LadderApp/Features/Founder/Dashboard/FounderDashboardView.swift`
  - `LadderApp/Features/Founder/FeatureFlags/FeatureFlagsView.swift`
  - `LadderApp/Features/Founder/SchoolDetail/SchoolDetailView.swift`
  - `LadderApp/Features/Backdoor/` (all views)
- **acceptance:** founder dashboard and feature flags form render on iPad without layout issues; long-press backdoor flow works on iPad; no clipped text or overflowed controls
- **est. complexity:** S

### T026 — Admin dashboard iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T022]
- **inputs:** `LadderApp/App/Navigation/AdminTabView.swift`, `LadderApp/Features/Admin/TeacherProfiles/TeacherProfilesView.swift`, `LadderApp/Features/Admin/SuccessMetricsPopup/SuccessMetricsPopupView.swift`
- **files_touched:**
  - `LadderApp/App/Navigation/AdminTabView.swift`
  - `LadderApp/Features/Admin/TeacherProfiles/TeacherProfilesView.swift`
  - `LadderApp/Features/Admin/SuccessMetricsPopup/SuccessMetricsPopupView.swift`
- **acceptance:** admin tab renders on iPad in both orientations; no layout clips; sidebar column available for large-screen admin workflows
- **est. complexity:** S

### T027 — Parent dashboard iPad parity
- **agent:** `swift-ios-specialist` (`ladder-ipad-parity`)
- **deps:** [T022]
- **inputs:** `LadderApp/Features/Parent/` (all active root views)
- **files_touched:** all root views under `LadderApp/Features/Parent/`
- **acceptance:** all parent views render without clipping on iPad Air and iPad Pro 12.9" in portrait and landscape
- **est. complexity:** S

---

## Day-band 5 (Days 12-13, 5/23-5/24): QA + fix-loop

### T028 — Autonomous UI test suite
- **agent:** `autonomous-ui-tester`
- **deps:** [T001, T002, T003, T004, T005, T006, T007, T010, T011, T012, T013, T014, T015, T016, T017, T018, T019, T020, T021, T022, T023, T024, T025, T026, T027]
- **inputs:** all shipped views from Day-bands 1-4, `DECISIONS.md` (D-001 through D-005 for acceptance context)
- **scope:**
  - Student login → Advisor tab → send message → SIA responds → check memory persists after re-launch
  - Counselor login → student card → confirm no raw chat visible → "Ask SIA" button returns response
  - Founder login → confirm founder wall blocks non-founder routes
  - iPad simulator (iPad Air + iPad Pro 12.9") → all tab bars and split views render
  - Deliberate isolation negative test: confirm Student B's context does not load into Student A's session
- **acceptance:** all flows pass without manual intervention; any failure generates a BLOCKED ticket referencing the task that owns the broken file
- **est. complexity:** M

### T029 — Unit test bucket: isolation + RLS + nudge
- **agent:** `swift-ios-specialist`
- **deps:** [T010, T012, T013]
- **inputs:** `tests/LadderAppTests/`, `LadderApp/Services/AI/SiaEngine.swift`, migration 0010
- **files_touched:**
  - `tests/LadderAppTests/SiaIsolationTests.swift` (created in T010 — expand)
  - `tests/rls/sia_isolation.test.ts` (created in T009 — confirm coverage)
  - `tests/LadderAppTests/NudgeRulesTests.swift` (new — test 30-day suppression, 2-per-session cap)
- **acceptance:** `xcodebuild test` passes all new test targets; isolation negative test is present and passes; nudge suppression is covered
- **est. complexity:** S

### T030 — Human QA pass preparation
- **agent:** `tester-guide`
- **deps:** [T028]
- **inputs:** `DECISIONS.md D-004` (v1.0 scope list), `SPEC_v2.md §2.7` (P0 requirements)
- **deliverable:** `docs/qa/v1.0_qa_checklist.md` — a human-executable checklist covering every D-004 scope item with expected vs actual columns; includes TestFlight device matrix (iPhone 15 Pro, iPhone SE 3rd gen, iPad Air 10.9", iPad Pro 12.9")
- **acceptance:** checklist covers all 14 D-004 line items; tester-guide confirms checklist is executable by a non-engineer in under 2 hours
- **est. complexity:** S

### T031 — Fix-loop: address all autonomous-UI-tester failures
- **agent:** `swift-ios-specialist`
- **deps:** [T028]
- **inputs:** failure tickets from T028
- **files_touched:** determined by T028 output
- **acceptance:** all failures from T028 are resolved and T028 re-run passes; no new S1-equivalent bugs introduced
- **est. complexity:** S (scoped to regressions only; L items require escalation to founder)

---

## Day-band 6 (Days 14-15, 5/25-5/27): Ship

### T032 — TestFlight build + smoke test
- **agent:** `deployment-coach`
- **deps:** [T028, T029, T030, T031]
- **inputs:** `LadderApp.xcodeproj`, `docs/runbooks/`, CI workflow at `.github/workflows/ci.yml`
- **files_touched:**
  - `.github/workflows/ci.yml` — confirm TestFlight upload step is active
  - `docs/runbooks/testflight.md` (update or create)
- **acceptance:** a signed TestFlight build uploads successfully; the build installs on iPhone 15 Pro and iPad Air from TestFlight; all three role logins (student, counselor, founder) reach their respective dashboards; SIA chat sends and receives at least one message
- **est. complexity:** S

### T033 — Founder / CEO launch review
- **agent:** `delivery-manager`
- **deps:** [T032]
- **inputs:** `DECISIONS.md D-004` (full v1.0 scope checklist), `docs/qa/v1.0_qa_checklist.md` (from T030)
- **deliverable:** signed-off launch approval or a prioritized list of blocking items; written summary of all D-004 items confirmed shipped vs any remaining gaps
- **acceptance:** founder confirms all 14 D-004 items are either shipped or explicitly deferred with a v1.1 ticket; no S1-equivalent bugs remain open; TestFlight build number is recorded in `docs/planning/`
- **est. complexity:** S

### T034 — App Store submission prep
- **agent:** `deployment-coach`
- **deps:** [T033]
- **inputs:** TestFlight build from T032, `docs/compliance/legal/`, `docs/design/`
- **files_touched:** App Store Connect metadata (screenshots, description, privacy policy URL, age rating)
- **acceptance:** App Store submission is in "Waiting for Review" state; privacy policy URL is the production legal domain (not `purewavejosh.com`); age rating correctly reflects 13+ (school guidance); all required screenshots uploaded for iPhone and iPad
- **est. complexity:** S

---

## Explicitly deferred to v1.1
(from `DECISIONS.md D-004`)

- School transfer flow (3-stage approval: student → founder/employee → receiving school) — needs email Edge Function (Resend integration) not yet built
- Parent multi-child digest — needs parent role full build-out; `Features/Parent/` untouched
- Marketplace (B2C) — separate product surface, confirmed post-v1
- Extracurricular seed dataset (300-600 curated entries) — requires 3-5 days human curation
- Founder dashboard school theming — basic founder dashboard ships; theme customization defers
- AI streaming via AsyncThrowingStream — backend supports SSE; iOS client SSE wiring defers
- Offline queue fix (S2-7 — mutations lost after 5 retries) — lower priority for pilot
- ContentModerationService explicit keyword list (S3-2) — replace placeholder before broader launch
- OfflineQueueManager PII in UserDefaults (S3-3) — move to Keychain-backed store
- Legacy engine promotion sweep (ConnectionEngine, CollegeMatchCalculator, ActivitySuggestionEngine, StateRequirementsEngine, RIASECEngine) — engines are quarantined; promote after SIA chat is proven in production
- Mock interview / resume builder — quarantined, no un-quarantine ticket
- Push notifications — not built

---

## Missing specialists
- None. All tasks map to: `swift-ios-specialist`, `supabase-specialist`, `postgres-specialist`, `claude-api-specialist`, `autonomous-ui-tester`, `tester-guide`, `deployment-coach`, `delivery-manager` — all present in catalog.

## Out of scope (reaffirmed from DECISIONS.md D-004 + SPEC_v2.md §6)
- School transfer flow — out of v1 per D-004
- Parent multi-child digest — out of v1 per D-004 and ADR-008
- Counselor Marketplace — out of v1 per PLAN.md
- AWS anything — out of scope permanently (Supabase is canonical per AUDIT_REPORT.md + memory)
