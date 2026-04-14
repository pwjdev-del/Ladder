# Ladder — UX Flow Fix Prompt
# Paste this into Claude Code at your Xcode project root.
# Fixes all 14 actionable issues from the UX Flow Audit (April 2026).
# Work through each fix IN ORDER — later fixes depend on earlier ones.
#
# Read CLAUDE.md at the project root first for architecture context.

---

## PASTE THIS INTO CLAUDE CODE:

```
You are fixing 14 UX flow issues found during a fundamental audit of the Ladder iOS app. Read CLAUDE.md at the project root first. Then work through each fix in order — some later fixes depend on earlier ones completing first.

RULES:
- Build must succeed after EVERY fix. Check before moving on.
- Use existing design system components (LadderPrimaryButton, LadderCard, etc.) — never create one-off UI.
- All navigation goes through AppCoordinator + Route.swift. No direct NavigationPath pushes.
- All SwiftData writes must be @MainActor.
- Test on iOS Simulator iPhone 15 Pro after each fix.

After EACH fix, report: ✅ Done | ⚠️ Done with caveats | ❌ Blocked (explain why)

---

## PHASE 1 — TRIVIAL FIXES (under 30 min each, no new files)

---

### FIX 1 — Onboarding Step 5 "Review Full Profile" button does nothing

**File:** `OnboardingContainerView.swift` (around line 698)

**Problem:** The button at the end of the 5-step onboarding flow has an empty closure. User completes all 5 steps and then gets trapped — the button that's supposed to finish onboarding doesn't do anything.

**Fix:**
1. Find the "Review Full Profile" button action (around line 698)
2. Replace the empty closure with a call to `authManager.completeOnboarding()` (or whatever method transitions auth state from `.onboarding` to `.authenticated`)
3. If that method doesn't exist, check AuthManager.swift for the equivalent — it might be `authManager.authState = .authenticated` or `authManager.finishOnboarding()`
4. After the state change, the user should land on MainTabView (Dashboard). Verify this flow: tap button → auth state changes → MainTabView appears.

**Verify:** Launch app → go through all 5 onboarding steps → tap the final button → confirm you land on Dashboard, not stuck on Step 5.

---

### FIX 2 — Dashboard urgent deadline card not tappable

**File:** `DashboardView.swift` (around line 258)

**Problem:** The deadline urgency card (e.g. "MIT EA in 47 days") is not tappable. User sees it but can't tap to go to that college's detail page.

**Fix:**
1. Find the deadline urgency card view (around line 258)
2. Wrap it in a `Button` or add `.onTapGesture`
3. The action should navigate to the college profile: `coordinator.navigate(to: .collegeProfile(id: collegeId))` — use whatever route case matches college detail in Route.swift
4. Make sure the college ID is available in the card's data. If it only has the college name, trace back to where the card data comes from and ensure the ID is passed through.

**Verify:** Dashboard shows deadline card → tap it → navigates to that college's detail page.

---

### FIX 3 — Add "Retake Career Quiz" button in Profile

**File:** `ProfileView.swift`

**Problem:** Once you take the career quiz during onboarding, there's no way to retake it or change your career path from Profile. You're locked in forever.

**Fix:**
1. In `ProfileView`, find the section that shows the user's career archetype/path (if it exists) or the quick actions area
2. Add a button: "Retake Career Quiz" using `LadderSecondaryButton` or as a tappable row
3. The action should navigate to the career quiz: `coordinator.navigate(to: .careerQuiz)` — check Route.swift for the exact case name (might be `.careerQuiz`, `.careerDiscovery`, or similar)
4. If no route exists for the career quiz, ADD one to Route.swift and wire it to `CareerQuizView` in the navigation destination handler
5. Also add a smaller "Change Career Path" option that opens a simple picker sheet with the 6 career clusters (STEM, Medical, Business, Humanities, Sports, Law) — this lets them change without retaking the whole quiz

**Verify:** Profile → tap "Retake Career Quiz" → opens career quiz → complete it → career path updates in Profile.

---

### FIX 4 — Scholarship cards need "Apply Now" link

**File:** `ScholarshipSearchView.swift`

**Problem:** Users can find scholarships but there's no external link to actually apply. Dead end.

**Fix:**
1. Check `ScholarshipModel` — does it have a `url: String` or `applicationURL: String` field? If not, add `applicationURL: String?` to the model.
2. In the scholarship card view (inside `ScholarshipSearchView`), add an "Apply" button at the bottom of each card
3. Use SwiftUI's `Link("Apply →", destination: URL(string: scholarship.applicationURL ?? "")!)` — but guard against nil/empty URLs:
```swift
if let urlString = scholarship.applicationURL,
   let url = URL(string: urlString) {
    Link("Apply →", destination: url)
        .font(.subheadline.bold())
        .foregroundColor(LadderColors.accent)
}
```
4. If scholarship data is mock/seed data, add placeholder URLs to at least the first 20 scholarships so the button works during testing.

**Verify:** Scholarship search → find a scholarship → tap "Apply" → opens Safari with the scholarship application page.

---

### FIX 5 — Career Quiz results page needs "Explore Activities" CTA

**File:** `CareerQuizView.swift` (or whatever file shows quiz results — might be `CareerResultsView.swift`)

**Problem:** After completing the career quiz, the results page is a dead end. No button to explore suggested activities or see what to do next.

**Fix:**
1. Find the quiz results view (the screen shown after quiz completes)
2. Add TWO action buttons below the results:
   - "Explore Suggested Activities →" — navigates to the activity suggestions view. Check Route.swift for the activity route (might be `.activitySuggestions`, `.activities`, or similar). If no route exists, add one.
   - "View College Matches →" — navigates to the Colleges tab with the career filter applied. Use `coordinator.navigate(to: .collegeDiscovery)` or equivalent.
3. Also add a "Back to Dashboard" option so they're not forced into either flow
4. Use `LadderPrimaryButton` for the main CTA and `LadderSecondaryButton` for the secondary one

**Verify:** Take career quiz → see results → tap "Explore Suggested Activities" → lands on activity suggestions → back button works.

---

### FIX 6 — College Comparison X button does nothing

**File:** `CollegeComparisonView.swift` (around line 258)

**Problem:** The X button to remove a college from the comparison view has an empty closure. Users can add colleges to compare but can't remove them.

**Fix:**
1. Find the X button (around line 258) with the empty closure
2. The action should remove that college from the comparison list. Look for the comparison data source — likely an array of college IDs or CollegeModel references in the ViewModel
3. Wire the button to: `viewModel.removeFromComparison(collegeId)` or equivalent
4. If that method doesn't exist, create it — it should remove the college from the comparison array and trigger a UI refresh
5. Add a brief haptic feedback on removal: `UIImpactFeedbackGenerator(style: .light).impactOccurred()`

**Verify:** College comparison → add 3 colleges → tap X on one → it disappears from comparison → remaining colleges re-layout correctly.

---

### FIX 7 — Roommate Finder detail sheet missing close button

**File:** `RoommateFinderView.swift`

**Problem:** The roommate detail sheet is presented as a `.sheet` or `.fullScreenCover` but has no explicit close/X button. If it's a fullScreenCover, swipe-down won't dismiss it and the user is trapped.

**Fix:**
1. Find the detail sheet presentation
2. If it's `.fullScreenCover` — add an X button in the top-right corner:
```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button { dismiss() } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
}
```
3. If it's `.sheet` — it should dismiss on swipe-down by default. But still add an X button for accessibility and clarity. Check if `.interactiveDismissDisabled(true)` is set anywhere — if so, the X button is mandatory.
4. Wrap the sheet content in a `NavigationStack` if it isn't already, so the toolbar renders.

**Verify:** Roommate Finder → tap a profile → detail appears → X button visible → tap X → returns to Roommate Finder list.

---

### FIX 8 — Display app version in Settings

**File:** `ProfileSettingsView.swift`

**Problem:** No app version displayed anywhere. Minor but expected by users and useful for debugging.

**Fix:**
1. At the bottom of ProfileSettingsView (after the last settings section), add:
```swift
Section {
    HStack {
        Text("Version")
            .foregroundColor(.secondary)
        Spacer()
        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
            .foregroundColor(.secondary)
        Text("(\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
            .foregroundColor(.secondary.opacity(0.6))
            .font(.caption)
    }
}
```
2. Keep it simple, no interaction needed.

**Verify:** Profile → Settings → scroll to bottom → see "Version 1.0 (1)" or whatever the current version is.

---

## PHASE 2 — MODERATE FIXES (new views or significant rewiring)

---

### FIX 9 — ProfileView must read live StudentProfileModel, not mock data

**File:** `ProfileView.swift`

**Problem:** This is the ROOT CAUSE of most UX issues. ProfileView shows hardcoded/mock data instead of reading from the user's actual `StudentProfileModel` via SwiftData. Everything the user entered in onboarding is invisible.

**Fix:**
1. Open `ProfileView.swift` and find how it gets its data. It likely has hardcoded strings or a mock data object.
2. Replace with a SwiftData `@Query`:
```swift
@Query private var profiles: [StudentProfileModel]
private var profile: StudentProfileModel? { profiles.first }
```
3. OR if the profile is passed via Environment or injected from a parent, make sure the injection is live, not a mock.
4. Update EVERY field display in ProfileView to read from the live model:
   - Name: `profile?.name ?? "Student"`
   - Grade: `"\(profile?.grade ?? 9)th Grade"`
   - School: `profile?.school ?? ""`
   - GPA: `String(format: "%.2f", profile?.gpa ?? 0.0)`
   - SAT: `"\(profile?.satScore ?? 0)"`
   - Career Path: `profile?.careerPath ?? "Not set"`
   - Streak: `profile?.streakCount ?? 0`
   - Points: `profile?.totalPoints ?? 0`
5. For the 6 fields that are currently invisible (`isFirstGen`, `interests`, `actScore`, `stateOfResidence`, `selectedMajor`, `archetypeTraits`), add display rows in a new "Details" section of ProfileView.
6. Make sure this doesn't break if `profiles.first` is nil (brand new user before onboarding). Show a graceful empty state: "Complete onboarding to see your profile."

**Verify:** Go through onboarding → enter name "Test", GPA 3.8, SAT 1400, career STEM → finish → go to Profile → ALL of that data is displayed correctly.

---

### FIX 10 — Build "Edit Profile" sheet

**File:** Create new `EditProfileView.swift`

**Problem:** Even after Fix 9 makes Profile read live data, users can't EDIT anything. All onboarding data is permanently locked.

**Fix:**
1. Create `EditProfileView.swift` — a modal sheet with editable fields for:
   - Name (TextField)
   - Grade (Picker: 9, 10, 11, 12)
   - School (TextField)
   - GPA (TextField with decimal keyboard, validated 0.0–5.0)
   - SAT Score (TextField with number keyboard, validated 0–1600)
   - ACT Score (TextField with number keyboard, validated 0–36)
   - State of Residence (Picker or searchable list of US states)
   - Career Path (Picker: STEM, Medical, Business, Humanities, Sports, Law)
   - isFirstGen (Toggle)
2. Add a "Save" button that writes ALL changes to `StudentProfileModel` in ONE SwiftData transaction
3. CRITICAL: After save, fire the appropriate ConnectionEngine cascades. Check if ConnectionEngine exists:
   - If career path changed → `connectionEngine.onCareerPathChanged(to: newPath)`
   - If GPA/SAT changed → match/reach/safety recalculation should trigger
   - If grade changed → grade gating should update
   - If state changed → state requirements should update
   - If ConnectionEngine doesn't exist or these methods don't exist, add TODO comments noting which cascades need wiring
4. Add a Route case if needed: `.editProfile` in Route.swift
5. In ProfileView, add an "Edit" button (pencil icon or "Edit Profile" text) that presents this sheet
6. Use `@Environment(\.dismiss)` for the sheet dismiss after save
7. Add a "Cancel" option that discards changes

**Verify:** Profile → tap Edit → change GPA from 3.8 to 3.5 → tap Save → Profile shows 3.5 → go to Colleges tab → match/reach/safety badges should reflect the new GPA (if wired).

---

### FIX 11 — Inject student context into AI Advisor

**Files:** `AIService.swift`, `AdvisorChatViewModel.swift`

**Problem:** The AI Advisor chat is completely generic — it doesn't know the student's name, grade, GPA, career path, or saved colleges. Every student gets the same generic responses.

**Fix:**
1. Open `AIService.swift`. Find the method that sends messages to the AI (likely `sendMessage()` or `streamMessage()`).
2. Find where the system prompt is constructed. If there's no system prompt, add one.
3. Build a context-aware system prompt. The AdvisorChatViewModel (or whoever calls AIService) needs to inject StudentProfileModel data:
```swift
func buildSystemPrompt(from profile: StudentProfileModel, savedCollegeNames: [String]) -> String {
    """
    You are a personal college counselor for \(profile.name).
    Student profile:
    - Grade: \(profile.grade)th grade
    - GPA: \(profile.gpa) | SAT: \(profile.satScore) | ACT: \(profile.actScore)
    - Career interest: \(profile.careerPath)
    - State: \(profile.stateOfResidence)
    - First-generation college student: \(profile.isFirstGen)
    - Saved colleges: \(savedCollegeNames.joined(separator: ", "))
    
    Always give SPECIFIC, ACTIONABLE advice with real deadlines.
    Frame everything as suggestions, never mandates.
    Reference the student's actual data — don't give generic advice.
    """
}
```
4. In `AdvisorChatViewModel`, make sure it has access to the student profile (via @Query, @Environment, or dependency injection) and passes it to AIService on every message.
5. If AIService is currently using hardcoded keyword-matching as a fallback (not calling a real API), keep that fallback but prepend the student's name to responses so it at least FEELS personalized: "Based on your \(profile.gpa) GPA and interest in \(profile.careerPath)..."
6. If the Bearer token for the AI API isn't wired yet (TODO), that's fine — focus on making the keyword fallback responses use real student data.

**Verify:** Go to Advisor → send "What colleges should I apply to?" → response should reference your actual GPA, SAT, career path, and/or saved colleges — not generic advice.

---

### FIX 12 — Build "My Saved Colleges" view

**File:** Create new `SavedCollegesView.swift`

**Problem:** When a user hearts/saves a college, it just increments a count. There's no dedicated view to see all saved colleges in one place.

**Fix:**
1. Create `SavedCollegesView.swift` — a list view showing all colleges whose IDs are in `StudentProfileModel.savedCollegeIds`
2. For each saved college, show:
   - College name
   - Match/Reach/Safety badge (if CollegeMatchCalculator is wired)
   - Acceptance rate
   - Next deadline (if available)
   - Heart button to unsave
3. Tapping a college row navigates to its detail page: `coordinator.navigate(to: .collegeProfile(id: college.id))`
4. Add a Route case: `.savedColleges` in Route.swift
5. Wire navigation TO this view from:
   - **ProfileView**: Add a "Saved Colleges (X)" row that navigates here
   - **DashboardView**: If there's a "saved colleges" summary card, make it tappable → navigates here
   - **CollegeDiscoveryView**: Add a "My Saves" filter chip or toolbar button
6. Handle empty state: if no colleges saved, show a message: "You haven't saved any colleges yet. Browse the Colleges tab and tap the heart icon to save colleges you're interested in." with a CTA button that goes to CollegeDiscoveryView.

**Verify:** Save 3 colleges from Colleges tab → go to Profile → tap "Saved Colleges (3)" → see all 3 listed → tap one → navigates to college detail → tap heart to unsave → list updates to 2.

---

### FIX 13 — Show achievements/badges on iPhone Profile

**File:** `ProfileView.swift`

**Problem:** Achievements and badges are only visible on iPad due to a size class check or conditional layout. iPhone users (99% of your users) never see them.

**Fix:**
1. Search ProfileView for any `horizontalSizeClass`, `UIDevice.current.userInterfaceIdiom == .pad`, or conditional that hides the achievements section on compact layouts
2. Remove the iPad-only gate. Show achievements on ALL devices.
3. If the achievements section is too wide for iPhone, adapt the layout:
   - Use a horizontal ScrollView with badge cards instead of a grid
   - Or stack badges in a 2-column grid that fits iPhone width
   - Or show a compact "Achievements (X)" row that expands to a detail view on tap
4. Make sure the achievements section reads from real data (streakCount, totalPoints, completed tasks count, etc.) — not mock data

**Verify:** Run on iPhone 15 Pro simulator → go to Profile → achievements/badges section is visible and shows real data.

---

### FIX 14 — Wire Dashboard Search + Notifications buttons

**File:** `DashboardView.swift` (around lines 78, 89)

**Problem:** The search and notification bell icons in the Dashboard header are TODO no-ops. Tapping them does nothing.

**Fix for Search (line ~78):**
1. Option A (quick): Navigate to a universal search view if one exists. Check for `SearchView`, `GlobalSearchView`, etc.
2. Option B (if no search view exists): Present a `.searchable` modifier on the Dashboard NavigationStack, or navigate to the Colleges tab with search focused.
3. Option C (minimum viable): Show a `.sheet` with a simple searchable list that searches across colleges, scholarships, and tasks by name. Even a basic implementation is better than a no-op button.
4. If none of the above are feasible quickly, at MINIMUM replace the empty closure with a TODO alert:
```swift
Button {
    showSearchSheet = true
} label: {
    Image(systemName: "magnifyingglass")
}
.sheet(isPresented: $showSearchSheet) {
    NavigationStack {
        Text("Search coming soon")
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showSearchSheet = false }
                }
            }
    }
}
```

**Fix for Notifications (line ~89):**
1. Check if a NotificationsView or similar exists in the project
2. If yes, wire the bell icon to navigate there
3. If no, create a simple `NotificationsView.swift` placeholder that shows: "No notifications yet. You'll see deadline reminders and activity updates here." — wrap in NavigationStack with proper title and dismiss.
4. Add `.badge(notificationCount)` to the bell icon if there's a way to compute unread notifications from upcoming deadlines

**Verify:** Dashboard → tap search icon → something useful opens (not nothing) → tap notification bell → something useful opens (not nothing) → both can be dismissed back to Dashboard.

---

## AFTER ALL 14 FIXES — VERIFICATION CHECKLIST

Run through this entire flow on iPhone 15 Pro simulator WITHOUT stopping:

1. Launch app fresh (delete app data first)
2. Go through consent flow
3. Complete all 5 onboarding steps — enter: name "Alex", grade 11, GPA 3.7, SAT 1350, career STEM, save 3 colleges
4. Tap "Review Full Profile" → should land on Dashboard (FIX 1)
5. Dashboard shows personalized greeting with "Alex" — deadline card visible
6. Tap deadline card → goes to college detail (FIX 2)
7. Go back to Dashboard → tap search icon → something opens (FIX 14)
8. Go back → tap notification bell → something opens (FIX 14)
9. Go to Profile tab → see real data: Alex, 11th grade, 3.7 GPA, 1350 SAT, STEM (FIX 9)
10. See achievements section on iPhone (FIX 13)
11. Tap "Edit Profile" → change GPA to 3.9 → save → Profile shows 3.9 (FIX 10)
12. Tap "Saved Colleges (3)" → see all 3 colleges → tap one → college detail opens (FIX 12)
13. Tap "Retake Career Quiz" → quiz opens → complete it → career updates (FIX 3)
14. Go to Advisor → ask "What should I focus on?" → response mentions your name, GPA, or career (FIX 11)
15. Go to Colleges tab → find a scholarship → see "Apply" link (FIX 4)
16. Go to College Comparison → add colleges → X button removes one (FIX 6)
17. Open Roommate Finder → tap a profile → X button dismisses (FIX 7)
18. Go to Settings → scroll down → see version number (FIX 8)

Report: which steps passed, which failed, any new issues discovered.

---

## WHAT TO DO AFTER THESE 14 FIXES

These fixes address the IMMEDIATE UX dead-ends. The next priorities (separate prompt needed) are:

1. **Delete Account backend** (App Store blocker) — needs AWS Lambda or equivalent
2. **Wire the 15 orphaned routes** — each one needs at least one navigation entry point
3. **Build missing engines** — ConnectionEngine, CollegeMatchCalculator, GradeFeatureManager, StateRequirementsEngine, ActivitySuggestionEngine are referenced but may not exist in the codebase. These are the brain of the app.
4. **Grade-filter Tasks** — TasksView should only show grade-appropriate tasks
5. **Empty states** — every list view needs a helpful zero-state, not blank screen
6. **Wire the 6 dead data fields** — actScore, isFirstGen, interests, archetypeTraits, profileImageURL, studentId should all be displayed and/or used somewhere
```
