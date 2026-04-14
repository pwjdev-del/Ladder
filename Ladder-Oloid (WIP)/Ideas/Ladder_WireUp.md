# Ladder — 5 Disconnected Wires to Fix
# Give this entire file to Claude Code in your Xcode project.
# Prompt: "Wire up all 5 ConnectionEngine triggers exactly as described in this file."

---

## Context

ConnectionEngine exists and has these methods:
- `onCareerPathChanged(to:)`
- `onCollegeSaved(collegeId:)`
- `onCollegeRemoved(collegeId:)`

GradeFeatureManager exists but MainTabView doesn't check it.
Match/Reach/Safety logic doesn't exist anywhere yet.
Post-acceptance checklist transform doesn't exist anywhere yet.

---

## Wire 1 — Career Quiz → `onCareerPathChanged()`

**File to modify:** The view or viewmodel that handles career quiz completion.
Look for where `careerPath` is written to `StudentProfileModel` after the quiz finishes.
It will look something like:

```swift
// Somewhere in CareerQuizViewModel or CareerQuizView
profile.careerPath = result.pathIdentifier
```

**Add immediately after that line:**

```swift
// Fire the ConnectionEngine cascade
connectionEngine.onCareerPathChanged(to: result.pathIdentifier)
```

Make sure `connectionEngine` is injected into the quiz viewmodel via `@Environment` or passed in.
If it isn't available there, add it:

```swift
// At top of CareerQuizViewModel
@Environment(ConnectionEngine.self) private var connectionEngine
// OR in init:
private let connectionEngine: ConnectionEngine
```

---

## Wire 2 — College Save/Unsave → `onCollegeSaved()` / `onCollegeRemoved()`

**File to modify:** `CollegeDiscoveryView.swift` or `CollegeProfileView.swift` — wherever the heart/save button lives.

Find the save action. It will look like:

```swift
// Current code (heart button tap action)
if profile.savedCollegeIds.contains(college.id) {
    profile.savedCollegeIds.removeAll { $0 == college.id }
} else {
    profile.savedCollegeIds.append(college.id)
}
```

**Replace with:**

```swift
if profile.savedCollegeIds.contains(college.id) {
    profile.savedCollegeIds.removeAll { $0 == college.id }
    connectionEngine.onCollegeRemoved(collegeId: college.id)
} else {
    profile.savedCollegeIds.append(college.id)
    connectionEngine.onCollegeSaved(collegeId: college.id)
}
```

If the save logic lives in a ViewModel, wire it there instead of the view.

---

## Wire 3 — Application Status → Post-Acceptance Checklist

**Context:** When `ApplicationModel.status` changes to `.accepted`, the existing pre-application
checklist items should be deleted and a new post-acceptance checklist should be generated.

**File to modify:** Wherever application status is updated. Look for `application.status = .accepted`
or a status picker/button in `ApplicationDetailView.swift`.

**Add this function to `ApplicationDetailViewModel` (or create it if it's view-driven):**

```swift
func updateStatus(_ newStatus: ApplicationStatus, for application: ApplicationModel) {
    let previousStatus = application.status
    application.status = newStatus

    // Trigger post-acceptance transform
    if newStatus == .accepted && previousStatus != .accepted {
        generatePostAcceptanceChecklist(for: application)
    }

    // Trigger committed flow
    if newStatus == .committed {
        connectionEngine.onCollegeCommitted(collegeId: application.collegeId)
    }
}

private func generatePostAcceptanceChecklist(for application: ApplicationModel) {
    // 1. Remove all pre-application checklist items
    application.checklistItems.removeAll()

    // 2. Generate post-acceptance items
    let postAcceptanceItems: [(String, ChecklistCategory)] = [
        ("Pay enrollment deposit", .financial),
        ("Submit official transcripts (have your school send directly)", .transcript),
        ("Complete immunization/health forms", .postAcceptance),
        ("Apply for on-campus housing", .postAcceptance),
        ("Complete FAFSA / financial aid verification", .financial),
        ("Register for orientation", .postAcceptance),
        ("Select meal plan", .postAcceptance),
        ("Set up student email & portal login", .postAcceptance),
        ("Decline other college acceptances", .postAcceptance),
    ]

    for (title, category) in postAcceptanceItems {
        let item = ChecklistItemModel(
            title: title,
            category: category,
            status: .pending
        )
        application.checklistItems.append(item)
    }
}
```

**Then in the view, replace any direct status assignment:**

```swift
// OLD
application.status = selectedStatus

// NEW
viewModel.updateStatus(selectedStatus, for: application)
```

---

## Wire 4 — GPA/SAT → Match/Reach/Safety Auto-Calculation

**Context:** The filter chips MATCH / REACH / SAFETY exist in `CollegeDiscoveryView` but are
applied manually. They should auto-calculate based on student's stored GPA + SAT vs each college's data.

**Create a new file: `CollegeMatchCalculator.swift`**

```swift
// CollegeMatchCalculator.swift
// Pure logic — no SwiftUI, no SwiftData dependency

struct CollegeMatchCalculator {

    // Returns the match tier for a student against a college
    static func tier(
        studentGPA: Double,
        studentSAT: Int,
        collegeAcceptanceRate: Double,
        collegeSATRange: String  // e.g. "1200-1480"
    ) -> MatchTier {

        let satBounds = parseSATRange(collegeSATRange)
        let satMidpoint = (satBounds.low + satBounds.high) / 2

        // Acceptance rate tiers
        let isHighlySelective = collegeAcceptanceRate < 0.20
        let isModeratelySelective = collegeAcceptanceRate < 0.50

        // SAT comparison
        let satAbove75th = studentSAT >= satBounds.high
        let satAbove50th = studentSAT >= satMidpoint
        let satBelow25th = studentSAT < satBounds.low

        // GPA comparison (rough: assume 3.7+ is competitive for selective schools)
        let strongGPA = studentGPA >= 3.7
        let averageGPA = studentGPA >= 3.2

        // Classification logic
        if isHighlySelective {
            if satAbove75th && strongGPA { return .match }
            if satAbove50th && averageGPA { return .reach }
            return .reach  // Highly selective is always at least reach
        }

        if isModeratelySelective {
            if satAbove75th && strongGPA { return .safety }
            if satAbove50th && averageGPA { return .match }
            return .reach
        }

        // Less selective (>50% acceptance rate)
        if satAbove50th && averageGPA { return .safety }
        if satAbove25th || averageGPA { return .match }
        return .reach
    }

    private static func parseSATRange(_ range: String) -> (low: Int, high: Int) {
        let parts = range.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return (low: 1000, high: 1400) }
        return (low: parts[0], high: parts[1])
    }
}

enum MatchTier: String {
    case safety  = "SAFETY"
    case match   = "MATCH"
    case reach   = "REACH"
}
```

**Then in `CollegeDiscoveryView.swift` or its ViewModel, use the calculator:**

```swift
// In CollegeDiscoveryViewModel or wherever filtering happens:

func matchTier(for college: CollegeModel) -> MatchTier {
    return CollegeMatchCalculator.tier(
        studentGPA: profile.gpa,
        studentSAT: profile.satScore,
        collegeAcceptanceRate: college.acceptanceRate,
        collegeSATRange: college.satRange
    )
}

// Then when filtering by MATCH chip:
var filteredColleges: [CollegeModel] {
    guard !activeFilters.isEmpty else { return allColleges }
    return allColleges.filter { college in
        let tier = matchTier(for: college)
        if activeFilters.contains(.match) && tier == .match { return true }
        if activeFilters.contains(.reach) && tier == .reach { return true }
        if activeFilters.contains(.safety) && tier == .safety { return true }
        return false
    }
}
```

---

## Wire 5 — MainTabView → GradeFeatureManager Route Gating

**Context:** `GradeFeatureManager` exists and `ProfileView` "Coming Up" section uses it,
but `MainTabView` never checks it. A 9th grader can tap into Applications and see the same
full interface as a 12th grader. This should be gated.

**File to modify:** `MainTabView.swift`

**Find the tab bar tab definitions. They'll look something like:**

```swift
TabView(selection: $selectedTab) {
    DashboardView()
        .tabItem { Label("Home", systemImage: "house") }
        .tag(Tab.home)

    TasksView()
        .tabItem { Label("Tasks", systemImage: "checkmark.circle") }
        .tag(Tab.tasks)

    CollegeDiscoveryView()
        .tabItem { Label("Colleges", systemImage: "graduationcap") }
        .tag(Tab.colleges)

    AdvisorHubView()
        .tabItem { Label("Advisor", systemImage: "sparkles") }
        .tag(Tab.advisor)

    ProfileView()
        .tabItem { Label("Profile", systemImage: "person") }
        .tag(Tab.profile)
}
```

**Replace with grade-aware wrappers:**

```swift
@Environment(GradeFeatureManager.self) private var gradeManager

TabView(selection: $selectedTab) {
    DashboardView()
        .tabItem { Label("Home", systemImage: "house") }
        .tag(Tab.home)

    TasksView()
        .tabItem { Label("Tasks", systemImage: "checkmark.circle") }
        .tag(Tab.tasks)

    // Colleges: show preview for 9th/10th, full for 11th/12th
    Group {
        if gradeManager.isFeatureUnlocked(.collegeDiscovery) {
            CollegeDiscoveryView()
        } else {
            LockedFeatureView(
                title: "College Discovery",
                reason: "Unlocks in 11th grade",
                previewContent: { CollegeDiscoveryPreviewView() }
            )
        }
    }
    .tabItem { Label("Colleges", systemImage: "graduationcap") }
    .tag(Tab.colleges)

    AdvisorHubView()
        .tabItem { Label("Advisor", systemImage: "sparkles") }
        .tag(Tab.advisor)

    ProfileView()
        .tabItem { Label("Profile", systemImage: "person") }
        .tag(Tab.profile)
}
```

**Create `LockedFeatureView.swift` if it doesn't exist:**

```swift
struct LockedFeatureView<Preview: View>: View {
    let title: String
    let reason: String
    let previewContent: () -> Preview

    var body: some View {
        ZStack {
            // Blurred preview underneath
            previewContent()
                .blur(radius: 12)
                .allowsHitTesting(false)

            // Lock overlay
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.ladderAccent)

                Text(title)
                    .font(.title2.bold())

                Text(reason)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Keep building your profile to unlock this feature.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .navigationTitle(title)
    }
}
```

**Also check GradeFeatureManager has `.collegeDiscovery` as a feature case. If not, add it:**

```swift
// In GradeFeatureManager — add to your Feature enum if not present:
enum Feature {
    case collegeDiscovery    // unlocks grade 11
    case applicationTracker  // unlocks grade 12
    case essayHub            // unlocks grade 12
    case satStrategy         // unlocks grade 10
    case scholarshipApply    // unlocks grade 11
    // ... whatever else is in there
}

func isFeatureUnlocked(_ feature: Feature) -> Bool {
    switch feature {
    case .collegeDiscovery:   return currentGrade >= 11
    case .applicationTracker: return currentGrade >= 12
    case .essayHub:           return currentGrade >= 12
    case .satStrategy:        return currentGrade >= 10
    case .scholarshipApply:   return currentGrade >= 11
    }
}
```

---

## How to Give This to Claude Code

Open Claude Code in terminal at the root of your Xcode project and say:

```
Read /path/to/Ladder_WireUp.md and implement all 5 wires exactly as described.
For each wire, find the relevant file, make the minimal change described,
and confirm the build still passes after each one.
Do them one at a time, not all at once.
```

Replace `/path/to/` with wherever this file lives on your Mac.
