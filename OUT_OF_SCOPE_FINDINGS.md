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

## F2-FOLLOWUP — uniform 401 in founder-login + employee-login

**Source:** SECURITY_RE-AUDIT_2026-05-14.md S2-NEW-3

**Issue:** founder-login returns 403 `{"error":"not_a_founder"}` vs 401 `{"error":"invalid_totp"}` — distinguishable. An attacker iterating `auth.users` can detect founder accounts.

**Fix when F2 commits its TOCTOU edits to founder-login/index.ts (and employee-login/index.ts):**
1. Always return HTTP 401 with `{"error":"invalid_credentials"}` for ANY failure path (wrong password, wrong TOTP, not-a-founder, rate-limited-soft, decrypt-failed). Reserve 429 for rate-limited-hard (the explicit lockout response) — that's already enumeration-protected because the timing is deterministic.
2. Audit-log the REAL error category server-side (so we still know WHY a request failed) but never surface it to the client.
3. Same change in employee-login/index.ts.

If F2 has already committed without this, file a small follow-up edge function patch.

---

# P2-FOLLOWUP — Realtime pinning blocked on SDK (S1-3 partial close, 2026-05-14)

**Source:** SECURITY_RE-AUDIT_2026-05-14.md, finding S1-3 (partial)

**Path taken:** Documented SDK limitation. Pinning for Auth/PostgREST/Storage/Functions was confirmed intact (B1's GlobalOptions.session injection). Realtime cannot be wired through the same pin with the current SDK version.

## (a) What was attempted

`RealtimeClientOptions` in supabase-swift 2.44.1 was inspected at:

```
build/SourcePackages/checkouts/supabase-swift/Sources/Realtime/Types.swift
build/SourcePackages/checkouts/supabase-swift/Sources/Realtime/RealtimeClientV2.swift
build/SourcePackages/checkouts/supabase-swift/Sources/Realtime/WebSocket/URLSessionWebSocket.swift
```

`SupabaseClientOptions.realtime` (type `RealtimeClientOptions`) was checked for any `URLSession` or `URLSessionConfiguration` parameter. Neither exists. The `fetch` closure on `RealtimeClientOptions` is HTTP-only (used to construct an `HTTPClient` for presence-related HTTP calls); it does NOT control the WebSocket upgrade handshake.

The WebSocket transport is hardcoded in `RealtimeClientV2.init(url:options:)`:

```swift
wsTransport: { url, headers in
    return try await URLSessionWebSocket.connect(to: url, headers: headers)
}
```

`URLSessionWebSocket.connect(to:headers:configuration:)` accepts a `URLSessionConfiguration?` but is called from inside the SDK without exposing that parameter to the public options API. The app cannot reach it without forking the SDK or swizzling (both ruled out per task constraints).

## (b) SDK version checked

**supabase-swift 2.44.1** (revision `06ae7b34ec21406cbd3e643bee7a8a54206fa8f5`)
Confirmed via `LadderApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

## (c) Proposed long-term fix

**Option 1 (preferred) — Wait for upstream SDK fix:**
File an issue at https://github.com/supabase/supabase-swift requesting a `urlSessionConfiguration: URLSessionConfiguration?` parameter on `RealtimeClientOptions`. Once merged, the fix in `SupabaseAuthService.swift` is:

```swift
realtime: RealtimeClientOptions(
    // Pass the pinned session's configuration so the WebSocket transport
    // is created from the same ephemeral config + TLS delegate.
    urlSessionConfiguration: TLSPinnedSessionFactory.shared.session.configuration
)
```

The pinned host `seicofzlgwjqkggscvao.supabase.co` is already present in `PinnedHost` and `PinnedKeys.current`/`PinnedKeys.next` — no additional pin work is needed once the SDK hook exists.

**Option 2 (deferred, v1.1+) — Custom Realtime client:**
Write a custom Realtime client that calls `URLSessionWebSocket.connect(to:headers:configuration:)` directly using `TLSPinnedSessionFactory.shared.session.configuration`. Large scope; not appropriate for v1.0 or v1.0.1.

**Option 3 (never) — Swizzle:** Ruled out per task constraints. Fragile, breaks on SDK updates.

## (d) Current Realtime usage in app

**Zero.** As of 2026-05-14, `grep -rn "\.realtime" LadderApp/` returns no hits. The app does not subscribe to any Realtime channels. The risk is unexploited.

### CI guard — fail build if Realtime is called before pinning is resolved

Add the following shell script step to `.github/workflows/ci.yml` (or equivalent) **before** any Realtime usage is merged:

```sh
# Guard: Fail CI if any app source calls client.realtime before Realtime pinning is resolved.
# Remove this check only after supabase-swift exposes a URLSessionConfiguration hook in
# RealtimeClientOptions and SupabaseAuthService.swift is updated. (OUT_OF_SCOPE_FINDINGS.md P2-FOLLOWUP)
if grep -rn "\.realtime\b" LadderApp/ --include="*.swift"; then
  echo "ERROR: client.realtime called in app code but Realtime TLS pinning is not yet implemented."
  echo "See OUT_OF_SCOPE_FINDINGS.md section P2-FOLLOWUP before adding Realtime usage."
  exit 1
fi
```

**Priority:** P2 — no current exposure. Elevate to P1 before any Realtime code lands.

**Reported by:** S1-3 partial close (SupabaseAuthService.swift security audit sweep, 2026-05-14)
