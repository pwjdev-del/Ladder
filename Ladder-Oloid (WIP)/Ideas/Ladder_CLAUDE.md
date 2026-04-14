# ⚠ SUPERSEDED — This file reflects an earlier state of the project.
# The authoritative CLAUDE.md is now at the ROOT of the Xcode project.
# As of April 2026: 209 files, 47,734 lines, 145+ features, AWS (not Supabase),
# ConnectionEngine/GradeFeatureManager/ActivitySuggestionEngine/StateRequirementsEngine all BUILT.
# This file is kept as a planning artifact only.
# ────────────────────────────────────────────────────────────────────────────

# LADDER — iOS App: Claude Code Context File (HISTORICAL — April 2026 Session)
# Original planning artifact — see Xcode project root CLAUDE.md for current truth

---

## What This App Is

**Ladder** is an iOS college guidance platform for high schoolers (grades 9–12).
Think: personal AI college counselor in your pocket — career discovery, activity tracking,
college research, application management, AI advisor, scholarships, financial aid, all in one.

**Platform:** iOS 17+ — SwiftUI + SwiftData
**Architecture:** MVVM + Coordinator pattern, `@Observable` throughout
**Backend:** Supabase (auth + DB + storage + edge functions), Gemini AI via Supabase proxy
**Status:** ~65 of 145 features built. All UI is complete. Backend is NOT wired. Nothing talks to anything.

---

## The #1 Problem: Nothing Talks to Anything

The app has screens, but no journey. Data is stored in `StudentProfileModel` but **zero features read it to personalize themselves.**

```
Career Quiz result ─────────────────→ stored, never read by anything
GPA / SAT scores ───────────────────→ stored, never read by AI or chances calc
Saved colleges ─────────────────────→ stored, only DeadlinesCalendar reads it
Grade (9th vs 12th) ────────────────→ stored, UX is identical for both grades
State (FL vs CA) ───────────────────→ graduation tracker hardcoded to Florida
```

The fix is the **ConnectionEngine** — described below. Build that after wiring Supabase.

---

## App Architecture

### Entry Point & Auth State Machine

`LadderApp.swift` routes through 5 states via `AuthManager.swift`:

```
.loading       → SplashScreenView   (1s session check)
.unauthenticated → LoginView
.consentRequired → ConsentView      (COPPA age gate + 6 legal docs)
.onboarding    → OnboardingContainerView (5-step wizard)
.authenticated → MainTabView        (5-tab app)
```

`AuthManager` currently **mocks** state — it just sets it directly.
Supabase auth is wired with TODO comments but NOT actually connected (SPM package not added).

### 5-Tab Navigation

`MainTabView.swift` — each tab has its own independent `NavigationPath`:

| Tab | Root View | Status |
|-----|-----------|--------|
| Home | `DashboardView` | Built, all mock data |
| Tasks | `TasksView` | Built, all mock data |
| Colleges | `CollegeDiscoveryView` | Built, mock 6500 colleges |
| Advisor | `AdvisorHubView` | Built, mocked AI responses |
| Profile | `ProfileView` | Built |

`Route.swift` has 49 enum cases.
`AppCoordinator.swift` is `@Observable` and manages cross-tab navigation.

### Onboarding (5 Steps)

`OnboardingContainerView.swift` collects and saves to `StudentProfileModel`:
- Step 2: name, grade (9–12), school, `isFirstGen`
- Step 3: GPA, SAT/ACT scores, AP courses
- Step 4: dream school selections (100+ colleges, tap to save → `savedCollegeIds`)
- Step 5: career interests + extracurriculars → `careerPath`

**Problem:** All this data saves to `StudentProfileModel` via SwiftData, but **nothing downstream reads it.**

---

## Data Models (SwiftData, All Local Right Now)

### `StudentProfileModel` — The Central Model

```swift
// Everything should read from this
var name: String
var grade: Int              // 9, 10, 11, or 12
var gpa: Double
var satScore: Int
var actScore: Int
var careerPath: String      // "STEM" | "Medical" | "Business" | "Humanities" | "Sports"
var isFirstGen: Bool
var savedCollegeIds: [String]
var interests: [String]
var extracurriculars: [String]
var stateOfResidence: String // CURRENTLY HARDCODED "FL" — needs to be user-set
var streakCount: Int
var totalPoints: Int
// MISSING: transcriptData, parsedGrades, activityLog
```

### `CollegeModel`
```swift
var id: String              // College Scorecard unitId
var name: String
var acceptanceRate: Double
var tuitionInState: Int
var tuitionOutState: Int
var satRange: String        // e.g. "1200-1480"
var actAvg: Int
var enrollment: Int
var completionRate: Double
var medianEarnings: Int
var isHBCU: Bool
var programs: [String]
var imageURL: String
// Relationships:
var personality: CollegePersonalityModel?   // 1:1, AI-generated archetype
var deadlines: [CollegeDeadlineModel]       // 1:many
```

### `CollegePersonalityModel` (AI-generated)
```swift
var archetypeName: String   // e.g. "The Builder/Maker"
var traits: [String]
var testPolicy: String      // "test-optional" | "test-required" | "test-blind"
var rigorImportance: Int    // 1-10
var essayImportance: Int    // 1-10
```

### `ApplicationModel`
```swift
var collegeName: String
var collegeId: String
var status: ApplicationStatus  // .planning → .inProgress → .submitted → .accepted → .rejected → .waitlisted → .committed
var deadlineType: DeadlineType // .earlyAction | .earlyDecision | .regular | .rolling
var platform: String           // "Common App" | "Coalition" | direct
var checklistItems: [ChecklistItemModel]   // cascade delete
```

### `ChecklistItemModel`
```swift
var title: String
var category: ChecklistCategory  // .transcript | .essay | .lor | .testScore | .financial | .postAcceptance
var status: ItemStatus           // .pending | .inProgress | .completed
var dueDate: Date?
```

### Other Models
- `ChatSessionModel` + `ChatMessageModel` — AI advisor chat history
- `RoadmapMilestoneModel` — 4-year milestone journey (pre-seeded, not grade-adaptive yet)
- `ScholarshipModel` — search results, isSaved, matchPercent
- `CollegeDeadlineModel` — deadlineType, date, platform, source (.scraped | .crowdsourced | .manual)

---

## External Services

### Supabase (NOT WIRED — #1 priority)
- Auth: `supabase.auth.signIn/signUp/session` — AuthManager has TODO comments, SPM package not added
- DB: Student profiles, college saves, chat sessions — everything is local SwiftData
- Storage: Transcript uploads (planned), photos
- Realtime: cross-device sync
- Edge Functions: Gemini AI proxy (endpoint configured, Bearer token TODO)

### Google Gemini AI (PARTIAL — endpoint configured, auth TODO)
- `AIService.swift` — correctly architectured with both non-streaming and SSE streaming
- `sendMessage()` returns `String`
- `streamMessage()` returns `AsyncThrowingStream` for real-time token streaming
- Route: app → Supabase Edge Function → Gemini API
- **Problem:** Bearer token auth is TODO. Student context not injected into system prompt.
- Current `AdvisorChatViewModel` uses hardcoded keyword-matched responses as fallback.

### College Scorecard API (NOT WIRED)
- API key is configured in constants
- 6,500 colleges are seeded as **static mock JSON** — the real API is never called
- Endpoint: `https://api.data.gov/ed/collegescorecard/v1/schools`

### Firecrawl + AWS Lambda (NOT BUILT)
- Planned: student saves an unlisted college → Lambda fires → Firecrawl scrapes admissions page → AI generates checklist → page appears in app
- Nothing implemented yet

---

## The ConnectionEngine (NOT BUILT — Critical Architecture)

This is the single most important missing piece. It's an `@Observable` service that observes
`StudentProfileModel` changes and fires cascading updates across all features.

**Build it as `ConnectionEngine.swift`, inject it via SwiftUI Environment.**

### Every cascade that must exist:

#### `careerPath` changes (set by Career Quiz)
```
→ CollegeDiscovery: auto-enable the matching filter chip
→ ActivitySuggestions: show career-specific activities (4 generals + 6 specific)
→ ClassPlanner: recommend AP classes aligned with career path
→ ScholarshipSearch: filter to matching field scholarships
→ Dashboard: update quick action cards
→ EssayHub: generate "Why [field]?" talking points
→ CareerExplorer: show jobs and salaries in that field
```

#### `savedCollegeIds` changes (user hearts a college)
```
→ DeadlinesCalendar: add that college's deadlines ← THIS IS THE ONLY ONE WORKING
→ ApplicationModel: auto-create an application record for that college
→ ChecklistItems: auto-generate a pre-application checklist
→ EssayHub: create essay slots for that college
→ FinancialAidComparison: add to comparison table
→ Dashboard: update "MIT EA in 47 days" urgency card
```

#### `gpa` + `satScore` changes (from onboarding or transcript upload)
```
→ CollegeDiscovery: auto-sort MATCH / REACH / SAFETY chips
→ ChancesCalculator: compute acceptance probability per saved college
→ ScholarshipSearch: filter to merit scholarships student qualifies for
→ AIAdvisor: inject academic stats into system prompt context
→ Roadmap: unlock/adjust milestone urgency
```

#### `grade` changes (9 / 10 / 11 / 12)
```
→ GradeFeatureManager: lock/unlock features by grade (see below)
→ Dashboard: change greeting, hero subtitle, quick actions
→ Roadmap: highlight current year's milestones
→ Tasks: show grade-appropriate checklist items
→ CollegeDiscovery: hide for 9th/10th, surface for 11th/12th
```

#### `applicationStatus` → `.accepted`
```
→ ChecklistItems: delete all pre-application items
→ ChecklistItems: generate new post-acceptance checklist:
   - Pay deposit
   - Submit official transcripts (school sends directly)
   - Immunization forms
   - Apply for housing (deadline: Jan-Apr)
   - Financial aid / FAFSA completion
   - Orientation sign-up
   - Meal plan selection
→ Dashboard: switch to post-acceptance mode
→ FinancialAidComparison: mark as committed
```

#### `stateOfResidence` changes
```
→ GraduationTracker: swap in correct state graduation requirements
→ ScholarshipSearch: surface state-specific scholarships (FL → Bright Futures, 120h volunteer)
→ Roadmap: adjust state-specific deadlines
→ AIAdvisor: inject state context ("You're in Florida, here's Bright Futures...")
```

---

## GradeFeatureManager (NOT BUILT)

Maps `grade` → which features are visible/locked. Build as a separate service.

| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| Career Quiz | ✅ Full | ✅ Retake | ✅ Retake | ✅ Full |
| College Discovery | 👁 Browse | 👁 Browse | ✅ Full access | ✅ Full access |
| Application Tracker | 🔒 Hidden | 🔒 Hidden | ⚙ Prep mode | ✅ Full |
| SAT Strategy | 🔒 Hidden | ⚙ PSAT prep | ✅ Full SAT | ✅ Score improvement |
| Scholarship Search | 👁 Browse | 👁 Browse | ✅ Apply mode | ✅ Full |
| Essay Hub | 🔒 Hidden | 🔒 Hidden | ⚙ Practice | ✅ Full |
| Post-Acceptance | 🔒 Hidden | 🔒 Hidden | 🔒 Hidden | ✅ On accept |

---

## Activity Suggestion System (NOT BUILT — Core Feature)

This is the **main differentiator** — the reason to start in 9th grade, not 11th.

### 4 General Activities (Required for all students)
1. **Athletics** — sports, team manager, scorekeeper, stat tracker
2. **Volunteering** — minimum 120 hours total (FL: Bright Futures requirement)
3. **Clubs** — at least 1 per year, longevity matters
4. **Leadership** — overarching category across all 3 above

### 6 Career-Specific Activities (Rated 1–10 importance)
Career path determines which 6 are suggested. Rated by how much they help college apps.

| Activity | STEM | Medical | Business | Humanities | Sports |
|----------|------|---------|----------|------------|--------|
| Research paper (mandatory all) | 10 | 10 | 8 | 10 | 6 |
| Internship / job | 8 | 9 | 10 | 7 | 6 |
| Professional interview | 7 | 8 | 8 | 9 | 7 |
| Science fair / competition | 10 | 10 | 6 | 5 | 5 |
| Awards | 8 | 8 | 8 | 9 | 10 |
| Journals / portfolio | 7 | 7 | 7 | 10 | 8 |

---

## AI Advisor Context Requirements

When calling Gemini, always inject this system prompt context from `StudentProfileModel`:

```swift
// Build this in AIService.swift before every API call
let systemContext = """
You are a personal college counselor for \(profile.name).
Student profile:
- Grade: \(profile.grade)th grade
- GPA: \(profile.gpa) | SAT: \(profile.satScore)
- Career interest: \(profile.careerPath)
- State: \(profile.stateOfResidence)
- First-generation college student: \(profile.isFirstGen)
- Saved colleges: \(savedCollegeNames.joined(separator: ", "))
- Extracurriculars: \(profile.extracurriculars.joined(separator: ", "))

Always give SPECIFIC, ACTIONABLE advice with real deadlines.
Frame everything as suggestions, never mandates.
Never give vague advice — be like "go bug your counselor by March 1st for your LOR."
"""
```

---

## Design System

**Brand Colors:**
```swift
static let primary = Color(hex: "#42603f")   // Dark evergreen
static let accent  = Color(hex: "#caf24d")   // Lime
static let surface = Color(hex: "#fff8f2")   // Warm white
static let text    = Color(hex: "#1f1b15")   // Dark brown
```

Full light/dark mode support throughout.

**Reusable Components in `DesignSystem/Components/`:**
- `LadderPrimaryButton`, `LadderSecondaryButton`, `LadderAccentButton`
- `LadderCard` (with elevation option)
- `LadderTextField`, `LadderSearchBar`
- `LadderFilterChip`, `LadderTagChip`
- `CircularProgressView`, `LinearProgressBar`
- `LadderTabBar` (custom 5-tab bottom bar)

**Always use these components. Never create one-off buttons or cards.**

---

## Coding Rules for This Project

1. **Always use `@Observable` macro**, not `ObservableObject`. iOS 17+ target.
2. **SwiftData for local models**, Supabase for cloud sync. Don't use CoreData.
3. **Navigation via `AppCoordinator`** + `NavigationPath`. Don't push directly.
4. **All new routes go in `Route.swift`** enum before building the view.
5. **Always pass context to AI** — never call AIService without student profile context.
6. **Suggestions, never mandates** — all AI-generated content must be framed as suggestions.
7. **Grade-gate everything** — before adding a feature, ask "should a 9th grader see this?"
8. **No hardcoded strings** for college requirements — use the requirements engine.
9. **Test on iOS Simulator iPhone 15 Pro** (what the target device is).
10. **Never break the build** — check that build succeeds before marking anything done.

---

## Sprint Priority (What to Build Next)

### Sprint 1 — Backend Foundation (DO THIS FIRST)
1. Add Supabase SPM package to Xcode project
2. Wire `AuthManager` to `supabase.auth.signIn/signUp`
3. Sync `StudentProfileModel` to Supabase DB on every write
4. Add Bearer token to `AIService.swift` Edge Function calls
5. Inject `StudentProfileModel` context into Gemini system prompt
6. Wire College Scorecard API (replace mock seed JSON)

### Sprint 2 — ConnectionEngine
1. Build `ConnectionEngine.swift` as `@Observable` service
2. Wire `careerPath` → college filter + activity suggestions (highest leverage cascade)
3. Wire `savedCollegeIds` → `ApplicationModel` auto-creation + checklist generation
4. Build `GradeFeatureManager` — lock/unlock features by grade
5. Wire `gpa + satScore` → MATCH/REACH/SAFETY auto-sort + chances calculator
6. Build `StateRequirementsEngine` — FL first, then multi-state

### Sprint 3 — 25 Missing Features
1. Activity Suggestion System (4 generals + 6 career-specific, rated 1-10)
2. Transcript upload + Gemini Vision parse → profile update cascade
3. Post-acceptance checklist auto-generation on `.accepted` status
4. College auto-page via Firecrawl + AWS Lambda
5. Career quiz yearly retake + year-over-year pivot detection
6. Essay Hub real AI + Mock Interview with recording

### Sprint 4 — Scale & Polish
1. Counselor portal (manage multiple students)
2. Parent access mode (view-only)
3. Push notifications (deadlines + streak reminders)
4. PDF portfolio export
5. Housing + roommate finder
6. App Store prep + TestFlight

---

## Files You'll Touch Most

| File | Purpose |
|------|---------|
| `AuthManager.swift` | Sprint 1: Wire Supabase auth |
| `AIService.swift` | Sprint 1: Wire Bearer token, inject context |
| `StudentProfileModel.swift` | Add missing fields (stateOfResidence, transcriptData) |
| `ConnectionEngine.swift` | Sprint 2: CREATE THIS FILE |
| `GradeFeatureManager.swift` | Sprint 2: CREATE THIS FILE |
| `ApplicationModel.swift` | Sprint 2: Auto-creation + checklist transform |
| `DashboardView.swift` | After ConnectionEngine: reads real data |
| `CollegeDiscoveryView.swift` | After ConnectionEngine: MATCH/REACH/SAFETY + career filter |
| `AdvisorChatViewModel.swift` | Sprint 1: Replace keyword matching with real Gemini |
