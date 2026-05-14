# Out-of-scope findings — B1

## Seam required by S1-4 fix: `LadderApp.swift` must register the ModelContainer

**File:** `LadderApp/App/LadderApp.swift` (owned by no agent — app entry point)

**Required change (one line in `LadderApp.init()`):**

```swift
init() {
    PinnedKeys.preflightOrCrash()
    AppConfiguration.preflightOrCrash()
    SwiftDataWipeRegistry.register(modelContainer)  // ADD THIS LINE
}
```

`SwiftDataWipeRegistry` is defined in `SupabaseAuthService.swift` (B1's file). Without this call, the S1-4 wipe will skip with a `.fault`-level log on every sign-out. The ModelContainer instance (`modelContainer`) is already a stored property of `LadderApp` — no new state needed.

**Reported by:** B1 (SupabaseAuthService.swift)

---

# Out-of-scope finding — C1

## picks_cipher written as plain JSON bytes (no DEK encryption)

**File:** `LadderApp/Features/Student/ScheduleBuilder/ScheduleBuilderView.swift`

**Issue:** The `schedules.picks_cipher` column is typed `bytea` and the naming convention (`_cipher` suffix) indicates fields in this column should be DEK-encrypted at rest per §16.2. The B-05 fix stores UTF-8 JSON hex bytes without envelope encryption because no client-side DEK key management API is available in the ScheduleBuilder scope. Class picks (course title + id) are not PII under most definitions, but they are student data and the schema signal is clear.

**Required follow-up (out of C1 scope):** Once the DEK/envelope encryption service (referenced by `picks_cipher` naming in 0002/0003 migrations) is available as a Swift API, update `ScheduleBuilderView.submit()` to wrap the JSON payload through the encryption envelope before writing to `picks_cipher`, and decrypt on `loadExistingDraft()`.

**Reported by:** C1 (ScheduleBuilderView.swift)

---

# Out-of-scope findings — C4

## Orphan 1: `LadderApp/DesignSystem/Components/SiblingSwitcher.swift`

`SiblingSwitcher<Item>` is a generic sibling-tab component created to support the parent
multi-child dashboard. With `ParentDashboardView.swift` replaced by the v1.0 placeholder
(D2 fix), **no active file in the build references this component**. It sits in the shared
DesignSystem tree (not Legacy), so `project.yml` includes it in the build as dead code.
Recommend deleting in a follow-up once the agent-ownership lock is lifted; verify no new
callers were added before deleting.

**Reported by:** C4 (ParentDashboardView.swift)

## Orphan 2: `LinkedStudent` struct removed — note for v1.1

The `LinkedStudent` public struct (declared in the old `ParentDashboardView.swift`) has been
removed along with the mock sibling data. If v1.1 re-introduces the parent surface, a
`Codable`-conforming equivalent backed by a Supabase query will need to be declared (likely
in a new `ParentModels.swift`). No action needed now.

**Reported by:** C4 (ParentDashboardView.swift)

---

# Out-of-scope findings — D2

## `reportMessage` never actually sends to backend (ContentModerationService.swift:68-71)

`reportMessage(messageId:reason:)` sets a `UserDefaults` key but never POSTs to Supabase. The function's public signature implies reports are persisted server-side, but they are silently local-only. If a student reports abusive content, no one receives the report. Needs a Supabase insert (e.g., `reported_messages` table) wired up before moderation reporting is meaningful.

**Reported by:** D2 (ContentModerationService.swift)

---

# Out-of-scope findings — B3

## Finding 1: SwiftData models lack `userId` attribute — S1-4 fetch predicates cannot be applied

**Source finding:** S1-4 (SECURITY_AUDIT_2026-05-14.md)

**Files outside B3 scope that must be changed:**
- `LadderApp/Features/Student/Shared/Models/SATScoreModel.swift` (`SATScoreEntryModel`)
- `LadderApp/Features/Student/Shared/Models/ActivityModels.swift` (`ActivityModel`)
- `LadderApp/Features/Student/Academic/Models/GPAEntryModel.swift` (`GPAEntryModel`)
- `LadderApp/Features/Student/Writing/Models/EssayModel.swift` (`EssayModel`)
- `LadderApp/Features/Student/Applications/Models/ApplicationModels.swift` (`ApplicationModel` class — `StudentProfileModel` in the same file already has `userId`)
- `LadderApp/Features/Student/Career/Models/CareerQuizHistoryModel.swift` (`CareerQuizHistoryModel`)
- `LadderApp/Features/Student/CollegeIntelligence/Models/CollegeModels.swift` (`CollegeModel`)

**Problem:** All seven `FetchDescriptor` calls in `StudentContextBuilder` — `fetchSAT` (line 53), `fetchActivities` (line 59), `fetchGPA` (line 64), `fetchEssays` (line 70), `fetchApplications` (line 75), `fetchQuizHistory` (line 80), `fetchCollegeNameIndex` (line 88) — are unpredicated because none of the seven target `@Model` types carry a `userId` attribute. Without user-scoped predicates, if the B1 store-wipe races or fails on sign-out, a second student on the same device will receive the first student's SAT scores, essays, GPA, activities, and career quiz history.

**Required follow-up:**
1. Add `@Attribute var userId: UUID` to each of the seven model classes.
2. Update `StudentContextBuilder`'s seven fetch helpers to predicate on `currentUserId` sourced from `TenantContext.shared.claim?.userId`.
3. Ship a SwiftData schema migration so existing store rows are not silently dropped on upgrade.

The S1-4 safety comment at the top of `StudentContextBuilder.swift` (lines 14-16) documents that the B1 store wipe is the sole isolation backstop until these model changes land.

**Priority:** Must fix before v1.0 launch (COPPA/FERPA shared-device violation).

**Reported by:** B3 (StudentContextBuilder.swift)

---

## Finding 2: `SiaIsolationError` missing `.tenantMismatch` case — S2-3 uses `.contextMismatch` as proxy

**Source finding:** S2-3 (SECURITY_AUDIT_2026-05-14.md)

**File outside B3 scope:** `LadderApp/Services/AI/SiaIsolationError.swift`

**Problem:** The S2-3 tenant-match assertion added to `buildForCounselorBrief` throws `SiaIsolationError.contextMismatch(expected:actual:)` (with counselor/student tenant UUID strings as the arguments) when a cross-tenant brief is blocked. This re-uses the student-identity mismatch case for a structurally different isolation violation, which can confuse log analysis and incident triage.

**Required follow-up:** Add to `SiaIsolationError.swift`:
```swift
/// The counselor's tenant does not match the student's tenant.
/// Thrown by StudentContextBuilder.buildForCounselorBrief (S2-3).
case tenantMismatch(counselor: UUID, student: UUID)
```
Then replace the two `TODO(B3-followup)` throws in `buildForCounselorBrief` with the new case.

**Priority:** Should fix before v1.0 launch for accurate telemetry and log correlation.

**Reported by:** B3 (StudentContextBuilder.swift)

---

# Out-of-scope findings — D3

## S4 complement: add `com.apple.developer.default-data-protection` entitlement

**Source finding:** S4 (SECURITY_AUDIT_2026-05-14.md)

**Issue:** The `FileManager.setAttributes` approach in `SwiftDataContainer.swift` applies `NSFileProtectionComplete` at runtime to files that already exist. However, any file the OS creates *before* `applyFileProtection()` runs (e.g., during the very first launch before the container is fully initialised) will inherit the default protection class (`CompleteUntilFirstUserAuthentication`).

The belt-and-suspenders fix is to add the `com.apple.developer.default-data-protection` entitlement to the app target, which sets `NSFileProtectionComplete` as the default for every file created by the process:

**Required change (project.yml, `LadderApp` target):**
```yaml
entitlements:
  "com.apple.developer.default-data-protection": NSFileProtectionComplete
```

This requires a new entitlements file (e.g., `LadderApp/LadderApp.entitlements`) and a corresponding `CODE_SIGN_ENTITLEMENTS` build setting. `project.yml` accepts an `entitlements` key directly on the target. No App Store capability provisioning is required for this entitlement.

**Priority:** Should fix before v1.0 launch to cover the window between app first-launch and the `createModelContainer()` call.

**Reported by:** D3 (SwiftDataContainer.swift)
