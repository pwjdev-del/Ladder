# Ladder — Fix Prompt for Claude Code
> Paste this into Claude Code at your Xcode project root.
> Fix everything found in the gap analysis audit. Work through each section in order.

---

## CRITICAL FIXES (Core UX Broken Without These)

---

### FIX 1 — Career Override: Let student say "I want Medical not STEM"

**Problem:** Career path is one-way. Quiz says STEM, student is locked in unless they retake the whole quiz and hope for different results. No override mechanism.

**What to build:**
After `CareerResultsView` shows the quiz result, add a secondary row:
```
"Not quite right? Override your career path →"
```
Tapping opens a `CareerOverrideSheet` — a simple picker with the 6 career clusters (STEM, Medical, Business, Humanities, Sports, Law). Student picks one. It calls the same `connectionEngine.onCareerPathChanged(to:)` that the quiz calls. Same history tracking. Same cascades. Just a direct pick instead of quiz-driven.

Also add the override option in Profile settings so they can change it anytime without retaking the quiz.

---

### FIX 2 — Major Dropdown After Career Quiz Result

**Problem:** Student gets "STEM" but has no way to pick Computer Science vs Mechanical Engineering vs Biology. The career cluster is too broad to drive class and activity suggestions.

**What to build:**
Add a `selectedMajor: String?` field to `StudentProfileModel`.

After career result is shown (or after override), show a `MajorPickerView` — a searchable list of majors scoped to the selected career cluster. Use this mapping:
- STEM → Computer Science, Software Engineering, Mechanical Engineering, Electrical Engineering, Civil Engineering, Data Science, Physics, Chemistry, Mathematics, Environmental Science, Aerospace Engineering
- Medical → Pre-Med, Nursing, Pharmacy, Dentistry, Physical Therapy, Biomedical Science, Public Health, Occupational Therapy
- Business → Finance, Accounting, Marketing, Entrepreneurship, Economics, Management, Supply Chain, HR
- Humanities → Psychology, English, History, Political Science, Sociology, Philosophy, Communications, Journalism
- Sports → Exercise Science, Sports Management, Athletic Training, Kinesiology, Sports Marketing
- Law → Pre-Law, Criminal Justice, Political Science, International Relations, Paralegal Studies

Store `selectedMajor` in `StudentProfileModel`. Fire `connectionEngine.onMajorChanged(to:)` — add this trigger to `ConnectionEngine` so ClassPlanner and ActivitySuggestionEngine can refine their suggestions based on specific major, not just cluster.

---

### FIX 3 — TasksView Grade-Awareness

**Problem:** A 9th grader sees the same task list as a 12th grader. Completely wrong. A 9th grader should not be seeing "submit Common App" tasks.

**What to fix in TasksView / TasksViewModel:**
Filter tasks by the student's current grade. Add a `minimumGrade: Int` property to whatever task model drives this view (add it if it doesn't exist). Default = 9 so everything shows for 12th graders. Map task categories:
- Grade 9: career quiz, activities setup, class planning, volunteering start
- Grade 10: SAT prep intro, transcript upload, activity check-in
- Grade 11: SAT registration, college research, application essay brainstorm, scholarship search
- Grade 12: applications, FAFSA, CSS Profile, post-acceptance checklist

If `TaskModel` doesn't have `minimumGrade`, add it. Seed the existing tasks with the right grade floors. In `TasksViewModel`, filter: `tasks.filter { $0.minimumGrade <= profile.grade }`.

---

### FIX 4 — State Cascade: Wire StateRequirementsEngine Everywhere

**Problem:** `StateRequirementsEngine` works and `GraduationTracker` uses it — but `Dashboard`, `ScholarshipSearchView`, and `RoadmapView` don't adapt based on state. A Florida student and a New York student see identical content everywhere except GraduationTracker.

**What to wire:**

In `DashboardViewModel` or `DashboardView`: inject `stateRequirementsEngine`. Add a state-specific tip card. For FL: show Bright Futures tracker. For other states: show generic graduation tip. Keep it one card, keep it simple.

In `ScholarshipSearchView`: filter or tag scholarships by `stateOfResidence`. Tag scholarships that are FL-only (Bright Futures, Florida Medallion, etc.) with a state badge. If student's state is not FL, hide FL-only scholarships or push them to bottom with a "not available in your state" label.

In `RoadmapView`: the milestones are fine universally, but the descriptions under each milestone should reference state-specific things (e.g., "In Florida, you need 120 volunteer hours for Bright Futures by this point"). Make the milestone detail text pull from `StateRequirementsEngine` rather than being hardcoded.

Also: add a `stateOfResidence` picker in Profile settings. Right now it appears to be hardcoded `"FL"`. Let students change it. When they do, fire `connectionEngine.onStateChanged(to:)` — add this trigger to `ConnectionEngine` if it's not wired.

---

### FIX 5 — Add `portalURL` to CollegeModel + Surface in College Detail View

**Problem:** When a student is ready to apply, there's no "Apply Now" button. `CollegeModel` has `websiteURL` but no `portalURL` pointing to the actual admissions application portal.

**What to fix:**

Add `portalURL: String?` to `CollegeModel`. Populate it for the top 200 most common colleges in the seed data (Common App colleges use `commonapp.org/apply`, Coalition App colleges use `coalitionapp.org`, STARS schools like USF use their own). For others, default to the college's main `websiteURL`.

In `CollegeDetailView` or `CollegeProfileView`, add a prominent "Apply Now" button that opens `portalURL` in `SafariView`. Below it, show a smaller label: "Uses [Common App / Coalition / Direct Portal]" — pull from `ApplicationModel.platform` if already applied, or from the college data.

---

## MEDIUM FIXES (Important but Not Day-1 Blockers)

---

### FIX 6 — Essay "Why Field?" Talking Points: Wire to Career Changes

**Problem:** `WhyThisSchoolView` has career references but they are NOT reactively updated when student changes career path. So if student pivots from STEM to Medical, their essay talking points still say STEM.

**What to fix:**
In `ConnectionEngine.onCareerPathChanged(to:)`, add a cascade that regenerates the essay talking points. Create a method `EssayHubViewModel.refreshCareerTalkingPoints(for careerPath:)` — it should produce 3–5 bullet points like:
- "Why [Medical]: passion for patient care + AP Bio performance"
- "Your strongest activity supporting this: [top-rated career-specific activity from ActivitySuggestionEngine]"
- "What gap to address: you haven't done any medical-related volunteer work yet"

These live as a card in `EssayHubView` titled "Your 'Why [Field]?' starter points." Regenerate them whenever career changes.

---

### FIX 7 — Junior Year Major Re-Prompt

**Problem:** No trigger when student hits 11th grade asking "Have you decided your major?" Even though it was heavily discussed as a core feature.

**What to build:**
In `ConnectionEngine.onGradeChanged(to:)` (or wherever grade changes are handled), add a check: if `newGrade == 11 && profile.selectedMajor == nil`, set a flag `profile.needsMajorConfirmation = true`.

In `DashboardView`, check this flag. If true, show a persistent banner card:
```
"You're in 11th grade — it's time to lock in your major direction.
Colleges you'll apply to this fall care about this.
[Confirm My Major →]"
```
Tapping goes to the major picker (built in Fix 2). Once they pick, dismiss the banner and set `needsMajorConfirmation = false`.

---

### FIX 8 — Add Professional Interview as Activity Type

**Problem:** "Professional interview" is one of the strongest ways to show active career passion in an application, but it's not in the 6 career-specific activity suggestions.

**What to fix:**
In `ActivitySuggestionEngine`, add a `professionalInterview` activity type to the career-specific pool. Rating: 8/10 for all clusters. Description: "Interview a professional in your target field. Record it (with consent) and reference it in your application essays."

This applies to all 6 career clusters — it's universally valuable. Add it so it appears as one of the suggestions for every career path.

---

### FIX 9 — College Preference Quiz (Campus Size, Dorm, Location)

**Problem:** There is no "What do you want in a college?" quiz. Student says they want to be a doctor and the app jumps straight to a list of colleges — but never asks if they want urban or rural, big or small, in-state or out-of-state.

**What to build:**
Add a `CollegePreferenceQuizView` — short, max 5 questions, Duolingo card-flip style:

1. Campus size: Small (<5k) / Medium (5–15k) / Large (15k+) / No preference
2. Location: In-state only / Open to out-of-state / No preference
3. Setting: Urban / Suburban / Rural / No preference
4. Dorm style: Single room / Suite / Apartment / No preference
5. School culture: Research-focused / Teaching-focused / Both

Store results in `StudentProfileModel.collegePreferences` (add this struct if not there). Use these preferences to weight the `CollegeMatchCalculator` scoring so preference-matching colleges float higher in `CollegeDiscoveryView`.

Trigger this quiz after the career quiz completes in onboarding, or surface it as a card on the Colleges tab for students who haven't filled it in.

---

### FIX 10 — Level System (XP Beyond Streaks)

**Problem:** `streakCount` and `totalPoints` exist but there's no level system. Points accumulate but nothing happens with them. No sense of progression.

**What to build:**
Add `currentLevel: Int` and `xpToNextLevel: Int` to `StudentProfileModel`.

Level thresholds (simple):
```
Level 1: 0–99 XP      → "Freshman"
Level 2: 100–299 XP   → "Sophomore"
Level 3: 300–599 XP   → "Junior"
Level 4: 600–999 XP   → "Senior"
Level 5: 1000+ XP     → "College Bound"
```

Map level name to Ladder's domain (Freshman through College Bound) — feels native to the app.

Add a `LevelBadgeView` component that shows the level name + XP bar. Place it in the Profile tab header and as a small badge in the Dashboard greeting area. When `totalPoints` crosses a threshold, show a `LevelUpView` celebration sheet.

Award XP for: completing checklist items (+10), saving a college (+5), finishing career quiz (+20), uploading transcript (+15), completing an activity (+10).

---

## NICE TO HAVE (Post-AWS, Log and Build Later)

---

### FIX 11 — scholarshipsearch.net Integration

Add a card in `ScholarshipSearchView` above the main list:
```
[🔗 Find more scholarships on ScholarshipSearch.net →]
"Take their quiz, screenshot your matches, and upload them here."
```
Button opens `scholarshipsearch.net` in `SafariView`. Below it, add an "Import Screenshot" button that opens the photo picker. Store the image in `ScholarshipModel` as a `screenshotData: Data?` field — a saved reference so student can revisit what they found. No OCR needed now. Just a photo vault.

---

### FIX 12 — AI Advisor Structured Onboarding Flow

In `AdvisorChatViewModel`, add a `conversationMode: .freeChat | .guidedOnboarding` property. When a student has just completed onboarding and `selectedMajor == nil` or `savedCollegeIds.isEmpty`, default the first advisor session to `.guidedOnboarding` mode.

In guided mode, the AI leads with: "Let's figure out what you're aiming for. Do you have any idea what career or major you're interested in? (Yes / No / Not sure)" — three quick-tap response chips, not free text. Branch based on answer into the career quiz or college list building. After 3–4 questions, switch to `.freeChat` mode.

---

### FIX 13 — Class Preference Sharing with Counselor

In `ClassPlannerView`, add a "Share with Counselor" button at the bottom of the generated schedule. This creates a simple PDF summary of the student's AI-recommended schedule (class name, difficulty tier, reason for recommendation) and opens the iOS Share Sheet. Student can AirDrop or email it directly to their counselor. No backend needed — pure local PDF generation using the existing PDF export infrastructure.

---

## AFTER ALL FIXES — RUN THESE CHECKS

1. **Build and run** on simulator. No crashes.
2. **Create a test profile** as a 9th grader — confirm TasksView only shows 9th grade tasks.
3. **Change career path** to Medical — confirm Essay talking points update, ClassPlanner updates, ActivitySuggestionEngine updates.
4. **Change grade to 11** with no major selected — confirm junior year re-prompt banner appears on Dashboard.
5. **Change state to NY** — confirm GraduationTracker shows NY requirements, FL scholarships are hidden/filtered.
6. **Add 200 points** manually to profile — confirm level badge shows "Sophomore" and XP bar is visible.
7. **Tap a college "Apply Now"** — confirm it opens portalURL in SafariView, not the generic website.

Report back with what passed, what failed, and any new issues found.
