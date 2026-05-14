# Bug Report — User-Hittable Paths in Active Build
_Date: 2026-04-28 • Audited by: PWJ debugger_

---

## Top S1 (would block a real user)

### S1-1: Invite redemption accepts only 3 hardcoded codes — all real invites rejected
`LadderApp/Features/Auth/InviteRedemption/InviteRedemptionView.swift:151`
`validCodes` is a literal `Set<String>` with `"LDR-TEST-0001"`, `"LDR-TEST-BULK-A"`, `"LDR-TEST-G5"`. Any code issued by a real counselor (`CounselorInviteCodesView` generates UUID-based codes) fails with "We couldn't use that code." The entire school-login onboarding path is broken for new students.
Fix: replace the hardcoded whitelist with a `POST /rest/v1/rpc/redeem_invite` call to validate the code server-side.

### S1-2: `missingRoleClaim` error during signup is silently misclassified as "check your email"
`LadderApp/Features/Auth/B2CSignup/B2CSignupView.swift:377-380`
`SupabaseAuthService.signUp` throws `LadderAuthError.missingRoleClaim` in two distinct situations: (a) Supabase requires email confirmation (nil session) and (b) the `bootstrap-user` Edge Function ran but the role claim still wasn't stamped (misconfiguration). The catch block treats both as case (a) and shows the "Check your email" banner. A user whose account is genuinely misconfigured sees a false success state and can never log in — no real error is surfaced.
Fix: introduce a separate `LadderAuthError.emailConfirmationRequired` case and throw it from `signUp` when `response.session == nil`; reserve `missingRoleClaim` for the post-bootstrap failure path.

### S1-3: "Forgot password?" / "Help" buttons are empty no-ops on both login screens
`LadderApp/Features/Auth/B2CLoginView.swift:126-127`
`LadderApp/Features/Auth/SchoolLoginView.swift:190`
`Button("Forgot password?") { /* TODO */ }` — tapping does nothing. A user who forgets their password has no recovery path; they are permanently locked out with no feedback.
Fix: navigate to a password-reset view or open the Supabase password-reset email flow (`client.auth.resetPasswordForEmail`).

### S1-4: Student dashboard bottom nav tabs (Tasks / Classes / Advisor / Profile) are inert
`LadderApp/Features/Student/StudentDashboardView.swift:161-182`
`StudentBottomNav.tab()` renders a `VStack` with no `Button`, `NavigationLink`, or `onTapGesture`. The tab bar looks fully interactive but every tap on the 4 non-Home tabs is silently swallowed.
Fix: wrap each tab in a `Button` with a navigation destination or a state toggle until the real views are wired.

### S1-5: Counselor queue approval buttons ("Send back", "Modify & approve", "Approve") are stubs
`LadderApp/Features/Counselor/StudentQueue/StudentQueueView.swift:68-72`
All three action buttons are `Button("…") { /* TODO */ }`. A counselor who opens the queue to approve or reject a student schedule cannot perform any action. The core counselor workflow is non-functional.
Fix: wire each button to the corresponding `PATCH /rest/v1/schedules?id=eq.X` call with the appropriate `state` value.

### S1-6: Grades entered in `GradesSelfEntryView` are lost on navigation
`LadderApp/Features/Student/GradesSelfEntry/GradesSelfEntryView.swift:16`
`@State private var grades: [GradeEntry] = []` — in-memory only, no SwiftData `@Query` or Supabase insert. A `GPAEntryModel` SwiftData model exists and is in the container (`SwiftDataContainer.swift:36`) but `GradesSelfEntryView` never uses it. Every grade the student enters disappears when they leave the screen.
Fix: replace `@State var grades: [GradeEntry]` with `@Query var gpaEntries: [GPAEntryModel]` and write through to SwiftData (then sync to Supabase).

### S1-7: Extracurriculars chat "Send" — message appends, AI never responds, no loading state
`LadderApp/Features/Student/Extracurriculars/ExtracurricularsView.swift:52-56`
`send()` appends the user message to the transcript then exits. No AI call, no `ProgressView`, no "thinking…" turn. The chat UI looks interactive but after the user types and hits Send, the screen freezes silently waiting for an AI reply that will never arrive.
Fix: add a `loading` boolean, append a placeholder AI turn, then call `AIGatewayClient.shared.call(feature: .extracurricularSession, ...)` and replace the placeholder on completion.

### S1-8: Counselor scheduling-window "Open scheduling window" button is permanently disabled
`LadderApp/Features/Counselor/SchedulingWindow/SchedulingWindowView.swift:10-12, 32`
`prereqsReady`, `teacherSchedulesReady`, and `classCatalogReady` all default to `false` with no API call or toggle in the UI to set them true. The button `.disabled(!(prereqsReady && teacherSchedulesReady && classCatalogReady))` can never be enabled. The scheduling-window surface is completely non-functional.
Fix: either fetch actual precondition states from the DB on `.task`, or add toggle rows in the "Preconditions" section that the counselor can manually check off.

### S1-9: `ParentInviteView` "Generate invite" produces a fake local UUID code — not persisted or emailed
`LadderApp/Features/Student/ParentInvite/ParentInviteView.swift:54`
`generatedCode = "LDR-\(UUID().uuidString.prefix(8))"` — the code is client-generated, never stored in Supabase, never emailed to the parent. The student copies a code that the backend has no record of, so the parent can never redeem it.
Fix: replace with `POST /rest/v1/rpc/generate_parent_invite` and use the server-returned code.

### S1-10: Feature Flags "Save" button calls empty `save()` function — no changes are persisted
`LadderApp/Features/Founder/FeatureFlags/FeatureFlagsView.swift:212-214`
The `save()` function body is a single `// TODO:` comment. A founder who toggles flags and taps Save gets no error, no confirmation, and no actual change in the DB. On next visit all toggles revert.
Fix: wire to `POST /rest/v1/feature_flags` or the `varun-validate` edge function; surface a success/error toast.

---

## S2 (cosmetic / friction)

### S2-1: Student dashboard "Grades", "Classes", "Schedule" action tiles are decorative — no tap action
`LadderApp/Features/Student/StudentDashboardView.swift:131-139`
`actionTile()` returns a plain `VStack` with no `Button` or `NavigationLink`. The tiles look tappable but do nothing.

### S2-2: `ClassSuggesterView` shows "Consulting Gemini…" spinner then returns zero results
`LadderApp/Features/Student/ClassSuggester/ClassSuggesterView.swift:43-49`
`.task { await load() }` runs a 500ms sleep then sets `suggestions = []`. The spinner appears, then an empty list — no "no results" state, no explanation, no error. Looks like a broken load.

### S2-3: Career quiz completes locally but answers are never scored — career profile silently absent
`LadderApp/Features/Student/CareerQuiz/CareerQuizView.swift:48-53`
`finish()` sets `completed = true` and `locked = true` but the `// TODO: POST …` scoring call is absent. The student sees the quiz as "done" but no `career_profile_vector_cipher` is written. Any feature gated on having a career profile will behave as if the quiz was never taken.

### S2-4: Class list upload "Parse with AI" always returns an empty parsed list
`LadderApp/Features/Counselor/ClassListUpload/ClassListUploadView.swift:40-46`
`parse()` sleeps then sets `parsedRows = []`. The "Confirm & save" button can never appear. Counselors cannot upload class data.

### S2-5: ScheduleBuilderView window/quiz gates are hardcoded `true` — gates are never actually enforced
`LadderApp/Features/Student/ScheduleBuilder/ScheduleBuilderView.swift:16-17`
`windowOpen = true` and `quizFresh = true` are hardcoded defaults with no `.task` to fetch real values. Both gates from the spec (§11.2) appear enforced in code but are always bypassed.

### S2-6: SuccessMetricsPopup "Submit" dismisses the sheet but data is never posted
`LadderApp/Features/Admin/SuccessMetricsPopup/SuccessMetricsPopupView.swift:35-38`
The `// TODO: POST /rest/v1/success_metrics` is absent; the popup closes with no feedback and no data saved.

### S2-7: Offline queue `sendMutation` always returns `false` — queued mutations are never replayed
`LadderApp/Services/Sync/OfflineQueueManager.swift:56-59`
Every offline mutation accumulates indefinitely. After 5 retries it is silently dropped with a `Log.warn`. Users who work offline will have all mutations lost without notification.

### S2-8: AdminTabView "CSV import" button is a commented stub
`LadderApp/App/Navigation/AdminTabView.swift:349`
`// TODO: Implement CSV import` — the import button in the admin toolbar is present in the UI but does nothing.

### S2-9: TeacherProfilesView "+" add teacher button is an empty action
`LadderApp/Features/Admin/TeacherProfiles/TeacherProfilesView.swift:15`
`Button { /* TODO */ } label: { Image(systemName: "plus") }` — the add-teacher flow is unreachable.

### S2-10: `CounselorInviteCodesView` generates fake codes locally, not from backend
`LadderApp/Features/Counselor/InviteCodes/CounselorInviteCodesView.swift:50-54`
Codes are UUID-generated client-side, never persisted. The counselor hands out codes that the backend cannot verify (directly contributes to S1-1).

### S2-11: SchoolDetailView URLs contain developer debug domain `purewavejosh.com`
`LadderApp/Features/Founder/SchoolDetail/SchoolDetailView.swift:33-34`
DPA and liability links point to `purewavejosh.com/legal/…` — a personal domain, not a production legal URL. Force-unwrap `URL(string:)!` is safe here (the interpolated string is always a valid URL), but the domain is wrong for any non-test deployment.

### S2-12: Counselor dashboard KPIs and activity feed are hardcoded mock data
`LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift:66-67, 122-126`
"12 schedules waiting", "428 students", "Alice submitted…" are literals, not fetched values. Counselors see the same fake numbers regardless of school state.

---

## S3 (warnings — fix when convenient)

### S3-1: Only `ONLY_ACTIVE_ARCH` warnings from the build — all from dependency SPM targets
The `xcodebuild` run produced zero Swift source-level warnings from `LadderApp/**`. All `warning:` output was `ONLY_ACTIVE_ARCH=YES` from SPM packages (`swift-clocks`, `Supabase`, etc.) when building without an active simulator selected. No action needed on first-party code.

### S3-2: `ContentModerationService` explicit-keyword list is a single placeholder string
`LadderApp/Services/Engines/ContentModerationService.swift:22`
`"profanity_placeholder"` is the entire explicit-content list. AI chat messages pass through with no real explicit content filter. Low urgency for a school pilot, but must be replaced before broader launch.

### S3-3: `OfflineQueueManager` persists mutations to `UserDefaults` as JSON blobs
`LadderApp/Services/Sync/OfflineQueueManager.swift:61-63`
UserDefaults is not encrypted. Mutation payloads (which may contain PII) survive app reinstall-to-same-device in unprotected storage. Move to a Keychain-backed or encrypted SwiftData store before production.

---

## What I did NOT find (transparency)

- **Force-unwrap crashes**: All `URL(string:)!` calls use literal or compile-time-known strings. `scores.last!` in `SiaEngine.swift:160` is guarded by `guard !all.isEmpty` immediately above. `levels[0]` in `LevelManager.swift:31` is a hardcoded 5-element array. `pilotData[0]` in `FeatureFlagsView.swift:9` is a non-empty static literal. No realistic nil-crash paths found.
- **`try!` usage**: None found anywhere in the active build.
- **Navigation to `EmptyView()`**: No `NavigationLink` destinations pointing at `EmptyView` or bare `Text("Coming soon")`. Dead navigation ends manifest as empty action closures, not broken destinations.
- **Auth sign-in (school + B2C) and sign-up flows**: Both call `SupabaseAuthService` with real Supabase SDK calls, proper loading state, error surfacing, and post-auth routing. The auth core is functional.
- **`TenantContext.preconditionFailure`**: Intentional — fires only if a staff session reaches a tenant-data surface, which is a deliberate security crash.

---

---

## Found during Day-band 5 QA

_Added: 2026-05-12 by ios-specialist_

### BUG-DB5-1: `B2CSignupView` "Create account" button not disabled when form is empty (Fixed)
**File:** `LadderApp/Features/Auth/B2CSignup/B2CSignupView.swift`
**Severity:** S1 (blocked the `test_createAccountButton_disabledWithEmptyForm` smoke test)
**Root cause:** `createButton` used `.disabled(working)` only — `formReady` gate was enforced in `submit()` but not on the button modifier, so the button appeared enabled with an empty form.
**Fix applied:** Changed to `.disabled(!formReady || working)`. Verified by `SignupSmokeTest` now passing.

### BUG-DB5-2: `StudentHappyPathTests` logo-hold tests checked stale nav bar label (Fixed)
**File:** `tests/e2e/StudentHappyPathTests.swift`
**Severity:** Stale test (not a product bug)
**Root cause:** Tests were written before the backdoor refactor. Logo hold now opens `BackdoorChoiceView` (role-choice buttons), not directly to a "Founder login" navigation bar. Tests were also using `app.otherElements["Ladder"]` without `waitForExistence`, which is fragile on cold launch.
**Fix applied:** Tests updated to check `BackdoorChoiceView` buttons ("Login as Founder") and use `waitForExistence`.

### BUG-DB5-3: `test_studentRedeemsInviteThenTakesQuiz` requires live Supabase fixture (Deferred — infra)
**File:** `tests/e2e/StudentHappyPathTests.swift`
**Severity:** Infrastructure gap (not a product bug)
**Root cause:** Test requires fixture tenant "lwrpa" (Lakewood Ranch Preparatory Academy) to exist in the live Supabase `tenants` table and appear in `SchoolPickerView` results. The invite code "LDR-TESTCODE" also has no server-side record.
**Action:** Deferred. Test marked `XCTSkip` with clear reason. Re-enable after a `-fixtureTenant` Supabase seeding script is implemented.

### BUG-DB5-4: `StudentDashboardView.resolvedStudentId` always nil in UITestMode (Fixed)
**File:** `LadderApp/Features/Student/StudentDashboardView.swift`
**Severity:** Blocked all UITestMode advisor tab tests
**Root cause:** `resolvedStudentId` was populated only from `SupabaseAuthService.currentSession`, which returns nil when no real Supabase JWT exists. This prevented `AdvisorChatView` from rendering in UITestMode.
**Fix applied:** Falls back to `TenantContext.shared.claim?.userId.uuidString` when no Supabase session exists.

---

## D-002 cleanup required

_Added: 2026-05-12 by T009b postgres-specialist_

Migration `0009_adr_008_schema_additions.sql` created policy `ai_chats_counselor_read` on `student_ai_chats`, giving counselors direct SELECT access to raw chat rows for assigned students. This violates **DECISIONS.md D-002** ("Counselor CANNOT scroll the student's chat history"). Migration `0016_d002_counselor_chat_revoke.sql` drops that policy.

**iOS call sites reading raw chats under a counselor role:** NONE found.
Grepped `LadderApp/Features/Counselor/` for `student_ai_chats` and `studentAIChats` — zero matches. No iOS cleanup required.

**Edge Function call sites:** NONE found.
Grepped `LadderBackend/supabase/functions/` for `student_ai_chats` — zero matches.

**Action for T016 (counselor surface):** When building the counselor student-detail view, read only from `student_memory_summaries` (topic summaries, safety flags, last-active). Do NOT add any query against `student_ai_chats` in counselor-role code paths. Any attempt to add such a policy to `student_ai_chats` will be caught by the DO block in migration 0016 and the RLS test `tests/rls/sia_isolation.test.ts`.

---

## Test approach used

Scanned all 126 Swift files in the active build (per `project.yml` excludes). Phase 1: grep passes for `TODO`, `FIXME`, `/* TODO */`, `assertionFailure`, `preconditionFailure`, `fatalError`, `try!`, `try?`, force-unwrap patterns on URL/Int/array. Phase 2: read every file flagged by grep, plus the full user journey from `LandingView` through each role dashboard, checking for missing loading states, empty closures, and silent data loss. Phase 3: `xcodebuild` run for compiler warnings. No runtime simulator execution was performed; any bugs requiring live Supabase state (e.g., JWT race in `SignedInRouter:68`) were not testable from static analysis alone.
