# Ladder — Master Plan v3: Connecting the Dots
## From Scattered Features to One Connected Journey

**Philosophy**: "An app is not just dots. Everything should be connected so that those dots connect together and make a beautiful painting." — Kathan

**Current state**: 195 Swift files, ~145 features, BUILD SUCCEEDING
**Problem**: Features exist but don't FLOW into each other. The app has screens, but not a JOURNEY.

---

## PART 1: THE DISCONNECTED DOTS (What's Wrong Now)

Right now a student opens Ladder and sees features. But features don't talk to each other:

1. **Career Quiz results don't drive anything** — Student takes quiz, gets "STEM" result, but the college search doesn't auto-filter for STEM schools, the class planner doesn't know they want engineering, the activity suggestions are generic
2. **Transcript/GPA data is isolated** — Student enters GPA but the AI Class Planner doesn't pull it, the My Chances Calculator doesn't auto-load it, the Scholarship Match doesn't use it
3. **Activities don't connect to applications** — Student logs 4 years of activities but when they open a college application, those activities aren't pre-filled or suggested
4. **College list doesn't drive deadlines** — Student saves 10 colleges but their dashboard doesn't show those specific deadlines, the essay tracker doesn't auto-create essay slots
5. **Grade level doesn't shape the experience** — A 9th grader and 12th grader see nearly the same app
6. **Annual career re-quiz is missing** — Your original idea was: quiz in 9th grade, RETAKE every year, show how interests evolved. Currently it's one-and-done.
7. **State-specific requirements missing** — Florida has Bright Futures, 24-credit graduation, dual enrollment rules. Other states have completely different requirements. The app should adapt.
8. **School-uploaded data missing** — Your original idea: schools upload their class catalog, clubs list, sports tryout dates, calendar. Students see THEIR school's specific offerings. Not built yet.
9. **The "4 general + 6 career-specific" activity system** — Your original idea was very specific: EVERY student does 4 general activities (volunteering, clubs, athletics, jobs) + 6 activities specific to their career path. The current app has generic activity logging.
10. **Easy/Moderate/Hard class tiers** — Your original idea: students pick class difficulty tier, AI recommends specific classes at that tier. Not implemented.

---

## PART 2: THE CONNECTED PAINTING (How Everything Should Flow)

### The Student Journey: One Thread from 9th to College

```
ONBOARDING (Day 1)
    │
    ├─→ Age Gate (COPPA) ─→ Career Quiz (RIASEC) ─→ Career Path Set
    │                                                     │
    │                     ┌───────────────────────────────┘
    │                     ▼
    ├─→ Student Profile Created with:
    │     • Name, grade, school, state (FL/other)
    │     • Career path (from quiz)
    │     • Class difficulty preference (Easy/Moderate/Hard)
    │     • Florida resident? → unlocks Bright Futures tracker
    │
    ▼
DASHBOARD (Every Day)
    │
    │   The dashboard ADAPTS based on ALL of the above:
    │   - Career path drives: suggested activities, class recs, college filters
    │   - Grade drives: which features are active/locked
    │   - State drives: which requirements to show
    │   - Saved colleges drive: which deadlines appear
    │   - Time of year drives: what's urgent right now
    │
    ├─→ "This Week" widget pulls from:
    │     • Saved college deadlines
    │     • Incomplete essays
    │     • Activity hour goals
    │     • Upcoming SAT dates
    │
    ├─→ Quick Actions change by grade AND career:
    │     9th STEM:  "Explore Engineering Careers" | "Join Robotics Club" | "Start Volunteering"
    │     9th Medical: "Explore Healthcare Careers" | "Join Health Occ." | "Shadow a Doctor"
    │     11th STEM: "Finish MIT Essay" | "Retake SAT" | "Submit Georgia Tech EA"
    │
    ▼
ANNUAL CYCLE (Every August)
    │
    ├─→ Career Quiz RETAKE
    │     • Shows: "Last year you were 70% STEM, 20% Business, 10% Arts"
    │     • "This year you're 60% STEM, 30% Business, 10% Arts"
    │     • "Your interest in Business grew! Here are new activity suggestions..."
    │     • Year-over-year comparison chart
    │
    ├─→ Class Selection for New Year
    │     • AI loads your school's class catalog (uploaded by admin)
    │     • Filters by your career path + difficulty preference
    │     • Shows: "Based on your STEM path and 3.7 GPA, here's your recommended schedule"
    │     • Student picks, submits to counselor for approval
    │
    ├─→ Activity Goal Reset
    │     • "Last year you logged 45 volunteer hours. Goal this year: 55"
    │     • New career-specific activity suggestions based on updated quiz
    │
    └─→ State Requirement Check
          • FL: "You have 18/24 graduation credits. Need 6 more."
          • FL: "Bright Futures FAS: 2.8/3.5 GPA — need to bring up 0.7"
          • FL: "75/100 community service hours completed"
```

### The Connection Map: How Every Feature Feeds Every Other Feature

```
CAREER QUIZ RESULT
    │
    ├─→ drives → Class Recommendations (AI suggests career-aligned classes)
    ├─→ drives → Activity Suggestions (6 career-specific activities)
    ├─→ drives → College Discovery filter ("Best for Your Major")
    ├─→ drives → Scholarship Match (career-aligned scholarships)
    ├─→ drives → Career Explorer (pre-filtered to your path)
    ├─→ drives → AP Suggestions (career-relevant APs prioritized)
    ├─→ drives → Why This School essays (career-specific talking points)
    └─→ drives → Dashboard quick actions (career-relevant next steps)

GPA / TRANSCRIPT DATA
    │
    ├─→ feeds → My Chances Calculator (real GPA vs college requirements)
    ├─→ feeds → What If Simulator (baseline from real data)
    ├─→ feeds → Scholarship Match (GPA-based eligibility)
    ├─→ feeds → Class Recommendations (difficulty calibrated to GPA)
    ├─→ feeds → Graduation Tracker (credits completed vs required)
    ├─→ feeds → Bright Futures Tracker (FL GPA requirements)
    └─→ feeds → Counselor's student detail view

SAVED COLLEGE LIST
    │
    ├─→ populates → Deadline Heatmap (only YOUR colleges' deadlines)
    ├─→ populates → Essay Tracker (auto-creates essay slots per college)
    ├─→ populates → Admission Checklist (per-college tasks)
    ├─→ populates → Financial Aid Comparison (slots for each school)
    ├─→ populates → Dashboard deadlines (YOUR nearest deadlines)
    ├─→ populates → CSS Profile Guide (filters to your CSS-required schools)
    └─→ populates → Decision Portal (after submission)

ACTIVITY LOG
    │
    ├─→ exports → Common App (formatted for 10-activity limit)
    ├─→ exports → Academic Resume (auto-populated)
    ├─→ feeds → Volunteering Log progress bar
    ├─→ feeds → Bright Futures hour tracker
    ├─→ feeds → PDF Portfolio export
    ├─→ feeds → Counselor's student detail view
    └─→ feeds → Impact Report

STATE (e.g., Florida)
    │
    ├─→ configures → Graduation requirements (FL = 24 credits)
    ├─→ configures → Bright Futures tracker (FL only)
    ├─→ configures → Dual Enrollment info (FL = free)
    ├─→ configures → Fee waiver eligibility
    ├─→ configures → Scholarship suggestions (state-specific)
    └─→ configures → Class requirements (FL has specific credit areas)
```

---

## PART 3: MISSING FEATURES FROM YOUR ORIGINAL IDEAS

These are ideas from your brainstorming sessions that are NOT yet in the app:

### MISSING 1: Annual Career Quiz Retake with Year-over-Year Comparison
**Your idea**: "Career quiz done every year to keep up to date" (subtitles 11)
**What's missing**: Quiz currently saves once. No retake prompt, no history, no comparison.
**Solution**: 
- Store quiz results with grade_taken in SwiftData
- Every August, prompt: "Time to retake your career quiz!"
- Results screen shows: bar chart comparing this year vs last year
- If career path changed significantly, AI suggests: "Your interests shifted toward Business. Consider these new activities..."

### MISSING 2: Easy/Moderate/Hard Class Difficulty Tiers
**Your idea**: "Students choose from easy, moderate, or hard classes starting 9th grade" (subtitles 2)
**What's missing**: AI Class Planner doesn't ask for difficulty preference.
**Solution**:
- Add to onboarding: "How challenging do you want your classes?" (3 cards: Balanced / Challenging / Maximum Rigor)
- Store as `classDifficultyPreference` on StudentProfileModel
- AI Class Planner uses this when recommending: Balanced = 0-1 AP, Challenging = 2-3 AP, Maximum = 4+ AP
- Override per-class: "I want AP Bio but regular English"

### MISSING 3: School-Uploaded Class Catalog, Clubs, Sports, Calendar
**Your idea**: "School uploads classes offered, clubs, athletics, try-out dates" (subtitles 9, 12)
**What's missing**: ClassCatalogUploadView exists but only admin can upload classes. No clubs, sports, or calendar.
**Solution**:
- Expand school data model: classes + clubs + sports + calendar events
- Student sees THEIR school's specific offerings when browsing activities
- "Join Robotics Club" → shows their school's actual robotics club meeting time
- Club/sport tryout dates appear in student's calendar automatically

### MISSING 4: The "4 General + 6 Career-Specific" Activity System
**Your idea**: "Four general electives: volunteering, clubs, jobs, athletics. Five career breakdowns with six career-specific hobbies each" (subtitles 9)
**What's missing**: Activities are currently free-form. No structured "you SHOULD be doing these" system.
**Solution**:
- Activity Suggestions Engine:
  - EVERY student gets 4 general goals: 
    1. Volunteering (120+ hours over 4 years)
    2. Club membership (at least 2, leadership in 1)
    3. Athletics or physical activity
    4. Part-time job or internship (summer)
  - Based on career path, 6 additional suggestions:
    - STEM: Science fair, coding project, robotics team, research paper, STEM summer camp, math competition
    - Medical: Hospital volunteering, health occupations club, research shadow, CPR certification, anatomy study group, medical summer program
    - Business: DECA/FBLA, start a small business, finance club, marketing project, entrepreneurship camp, stock market simulation
    - Humanities: Writing contest, debate team, model UN, literary magazine, community theater, language exchange
    - Sports: Varsity athletics, coaching younger kids, sports camp counselor, kinesiology research, fitness certification, sports journalism
  - Dashboard shows: "4/4 General Activities ✓ | 3/6 Career Activities"
  - Each suggestion has: what it is, why it matters for your career, how to get started at YOUR school

### MISSING 5: Real-Time State Requirement Engine
**Your idea**: "Every year, according to the state or whatever the laws are in the state the kid is in, it changes" (from your current conversation)
**What's missing**: App is hardcoded to Florida. No state selection, no state-specific requirements.
**Solution**:
- Add `state` field to StudentProfileModel (set during onboarding)
- Create `StateRequirementsEngine` service:
  - Florida: 24 credits, Bright Futures (FAS 3.5 GPA + 1330 SAT + 100 service hours = 100% tuition)
  - Texas: Foundation + Endorsement graduation plan, Top 10% rule for UT Austin auto-admit
  - California: A-G requirements (15 year-long courses), UC/CSU eligibility
  - New York: Regents diploma requirements, Regents exam scores
  - Georgia: HOPE Scholarship (3.0 GPA = free tuition at state schools)
  - (Start with top 10 states, expand over time)
- Graduation Tracker adapts to student's state
- Scholarship suggestions include state-specific scholarships
- Class recommendations follow state graduation requirements

### MISSING 6: College Auto-Page Generation via AI
**Your idea**: "AI analyzes college and creates page with link to admissions portal, checklist, deadlines" (Export text IMG8203)
**What's missing**: CollegeProfileView only shows data from our database. If a school isn't in our data, nothing.
**Solution**:
- "Can't find your college?" button in College Discovery
- Enter school name + website URL
- AI scrapes/analyzes the website (via Lambda + Firecrawl)
- Auto-generates: deadlines, application method, requirements, checklists
- Saves as a new CollegeModel in SwiftData
- Community-shared: once one student generates it, all students can see it

### MISSING 7: Application Method Tracking (Common App vs STARS vs Portal)
**Your idea**: "Which colleges use STARS, which use different transcript upload systems" (IMG_8239)
**What's missing**: CollegeModel has some data but the UI doesn't prominently show HOW to apply.
**Solution**:
- Add to Admission Checklist: "Apply via: Common App" or "Apply via: STARS + FSU Portal"
- Color-coded badges on college cards: "Common App" | "Coalition" | "Direct Portal" | "STARS"
- Step-by-step for each method: "1. Create STARS account 2. Enter your courses 3. Submit to FSU"

### MISSING 8: Sponsor/Tutoring Partner Integration
**Your idea**: "Getting investors from SAT tutoring sites, recommending tutoring services to students" (subtitles)
**What's missing**: No partner/sponsor system.
**Solution** (future — not code, but plan):
- "Recommended Resources" section in Test Prep view
- Partner badges: "Ladder Partner" on recommended services
- Affiliate links generate revenue
- Premium placement in resource lists for paying partners

### MISSING 9: Post-Acceptance AI Checklist from College Websites
**Your idea**: "AI deletes completed checklist items, creates new post-acceptance checklist. AI should scan college websites to build checklists" (Export text IMG8203)
**What's missing**: Enrollment checklists are static data from our research. Not dynamically generated.
**Solution**:
- When student marks "Accepted" on a college, trigger:
  1. Pull enrollment data from our database (we have this for FL schools)
  2. If data is incomplete, show "Help us improve: What requirements did [college] send you?"
  3. Student can forward welcome email text → AI extracts deadlines and tasks
  4. Crowdsourced: aggregated across students to build better checklists

### MISSING 10: Counselor Scheduling of Student Meetings
**Your idea**: "Class scheduling is major time commitment for counselors" (subtitles 12)
**What's missing from the counselor side**: No way for counselors to schedule meetings with students based on urgency.
**Solution**: Already designed in the plan — the Counselor Meeting Scheduler (Smart Priority Scoring). Student with deadline in 5 days gets priority over student with no upcoming deadlines.

---

## PART 4: GRADE-BASED PROGRESSIVE EXPERIENCE

### How It Works

Every feature has a **visibility tier** based on student's grade:

| Tier | Meaning | Where It Shows |
|------|---------|---------------|
| **ACTIVE** | Front-and-center, on dashboard, fully functional | Dashboard + Tab views |
| **AVAILABLE** | In Profile → Tools, can explore freely | Profile menu |
| **PREVIEW** | Visible but shows "Unlocks in Xth grade" with preview | "Coming Up" section |
| **HIDDEN** | Not visible at all (irrelevant to this grade) | Nowhere |

### Full Feature Visibility Matrix

#### CORE FEATURES (Used by all grades)
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| Career Quiz (RIASEC) | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Career Quiz Retake (annual) | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Activities Portfolio | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| 4 General Activity Goals | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| 6 Career-Specific Activities | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| GPA Tracker | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Graduation Tracker | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Class Recommendations / AI Planner | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| College Discovery (browse) | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Career Explorer | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Volunteering Log | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Profile + Settings | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Messaging (counselor) | ACTIVE | ACTIVE | ACTIVE | ACTIVE |

#### COLLEGE PREP FEATURES
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| College Profiles (view) | AVAILABLE | ACTIVE | ACTIVE | ACTIVE |
| Save Colleges to List | AVAILABLE | ACTIVE | ACTIVE | ACTIVE |
| AP Credits View | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| AP Suggestions | AVAILABLE | ACTIVE | ACTIVE | ACTIVE |
| Dual Enrollment Guide | AVAILABLE | ACTIVE | ACTIVE | AVAILABLE |
| Bright Futures Tracker (FL) | ACTIVE | ACTIVE | ACTIVE | ACTIVE |
| Scholarship Search | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Scholarship Match Score | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |

#### TEST PREP FEATURES
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| SAT Score Tracker | PREVIEW | ACTIVE | ACTIVE | ACTIVE |
| Test Prep Resources | PREVIEW | ACTIVE | ACTIVE | ACTIVE |
| Fee Waiver Checker | AVAILABLE | ACTIVE | ACTIVE | ACTIVE |
| PSAT Info | AVAILABLE | ACTIVE | AVAILABLE | HIDDEN |

#### APPLICATION FEATURES
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| What If Simulator | PREVIEW | AVAILABLE | ACTIVE | ACTIVE |
| My Chances Calculator | PREVIEW | AVAILABLE | ACTIVE | ACTIVE |
| College Comparison | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Gap Analysis | PREVIEW | AVAILABLE | ACTIVE | ACTIVE |
| College Visit Planner | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Deadline Heatmap | PREVIEW | AVAILABLE | ACTIVE | ACTIVE |
| Essay Tracker | HIDDEN | PREVIEW | ACTIVE | ACTIVE |
| Why This School Essay | HIDDEN | PREVIEW | ACTIVE | ACTIVE |
| Mock Interview | HIDDEN | PREVIEW | ACTIVE | ACTIVE |
| LOR Tracker | HIDDEN | PREVIEW | ACTIVE | ACTIVE |
| Thank You Note | HIDDEN | HIDDEN | ACTIVE | ACTIVE |
| Common App Export | HIDDEN | PREVIEW | ACTIVE | ACTIVE |
| Academic Resume | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Admission Checklist | HIDDEN | PREVIEW | ACTIVE | ACTIVE |

#### APPLICATION MANAGEMENT (Mostly 12th)
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| Decision Portal | HIDDEN | HIDDEN | PREVIEW | ACTIVE |
| App Season Dashboard | HIDDEN | HIDDEN | HIDDEN | ACTIVE (Sep-Jan) |
| LOCI Generator | HIDDEN | HIDDEN | HIDDEN | ACTIVE |
| Acceptance Warning | HIDDEN | HIDDEN | HIDDEN | ACTIVE |
| Waitlist Strategy | HIDDEN | HIDDEN | HIDDEN | ACTIVE |

#### FINANCIAL AID
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| FAFSA Guide | HIDDEN | HIDDEN | PREVIEW | ACTIVE |
| CSS Profile Guide | HIDDEN | HIDDEN | PREVIEW | ACTIVE |
| Financial Aid Comparison | HIDDEN | HIDDEN | PREVIEW | ACTIVE |
| Net Price Calculator | HIDDEN | HIDDEN | AVAILABLE | ACTIVE |

#### POST-ACCEPTANCE
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| Enrollment Checklist | HIDDEN | HIDDEN | HIDDEN | ACTIVE (post-commit) |
| Housing / Roommate | HIDDEN | HIDDEN | HIDDEN | ACTIVE (post-commit) |
| First 100 Days | HIDDEN | HIDDEN | HIDDEN | ACTIVE (post-commit) |
| Freshman Survival Guide | HIDDEN | HIDDEN | HIDDEN | ACTIVE (post-commit) |
| Post-Graduation Mode | HIDDEN | HIDDEN | HIDDEN | ACTIVE (post-commit) |

#### REPORTS
| Feature | 9th | 10th | 11th | 12th |
|---------|-----|------|------|------|
| PDF Portfolio | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Impact Report | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |
| Alternative Paths | AVAILABLE | AVAILABLE | AVAILABLE | ACTIVE |
| Internship Guide | AVAILABLE | AVAILABLE | ACTIVE | ACTIVE |

---

## PART 5: IMPLEMENTATION — NEW FILES NEEDED

### MODULE K: Connection Engine (7 new files)

These are the "glue" files that make everything connect:

| File | Purpose |
|------|---------|
| `Core/Services/GradeFeatureManager.swift` | Controls feature visibility per grade (ACTIVE/AVAILABLE/PREVIEW/HIDDEN) |
| `Core/Services/StateRequirementsEngine.swift` | State-specific graduation requirements, scholarships, rules |
| `Core/Services/ActivitySuggestionEngine.swift` | Generates the 4 general + 6 career-specific activity suggestions |
| `Core/Services/ConnectionEngine.swift` | The central "glue" — when career quiz changes, update all downstream features |
| `Features/Career/Views/CareerQuizRetakeView.swift` | Annual retake with year-over-year comparison chart |
| `Features/Career/Models/CareerQuizHistoryModel.swift` | SwiftData @Model storing quiz results per year |
| `Features/Academic/Views/ClassDifficultyPickerView.swift` | Easy/Moderate/Hard selection during onboarding |

### MODULE L: School Data System (5 new files)

| File | Purpose |
|------|---------|
| `Features/Admin/Models/SchoolDataModels.swift` | @Model: SchoolClub, SchoolSport, SchoolCalendarEvent |
| `Features/Admin/Views/ClubsUploadView.swift` | Admin uploads clubs + meeting times |
| `Features/Admin/Views/SportsUploadView.swift` | Admin uploads sports + tryout dates |
| `Features/Admin/Views/SchoolCalendarView.swift` | Admin uploads school calendar events |
| `Features/Student/Views/MySchoolView.swift` | Student sees THEIR school's clubs, sports, calendar |

### Modifications to Existing Files

| File | Change |
|------|--------|
| `OnboardingContainerView.swift` | Add class difficulty picker step + state selector |
| `StudentProfileModel` | Add `classDifficultyPreference`, `state` fields |
| `DashboardView.swift` | Use GradeFeatureManager for quick actions, use ConnectionEngine for career-driven suggestions |
| `DashboardViewModel.swift` | Pull career-specific quick actions from ConnectionEngine |
| `CollegeDiscoveryViewModel.swift` | Auto-filter by career path when "Best for My Major" is on |
| `AIClassPlannerViewModel.swift` | Read classDifficultyPreference, use school's class catalog |
| `ScholarshipMatchViewModel.swift` | Use state for state-specific scholarships |
| `GraduationTrackerView.swift` | Use StateRequirementsEngine for correct state requirements |
| `ActivitiesPortfolioView.swift` | Show 4+6 activity goals with progress |
| `EssayTrackerView.swift` | Auto-populate from saved college list |
| `DeadlineHeatmapView.swift` | Filter to saved colleges' deadlines by default |
| `CSSProfileGuideView.swift` | Auto-show only saved colleges requiring CSS |
| `MainTabView.swift` | Wrap each route with GradeFeatureManager visibility check |
| `ProfileView.swift` | Add "Coming Up" section showing PREVIEW features |

---

## PART 6: EXECUTION PLAN — 4 AGENTS

### Agent K1: Connection Engine + Grade Feature Manager
- GradeFeatureManager.swift (visibility rules for all ~60 features)
- ConnectionEngine.swift (career quiz → downstream updates)
- Modify DashboardView + DashboardViewModel to use engines
- Modify MainTabView to check visibility
- Modify ProfileView to show "Coming Up" previews
- **~3 new files + ~5 modified files**

### Agent K2: State Requirements + Annual Retake
- StateRequirementsEngine.swift (FL, TX, CA, NY, GA + framework for others)
- CareerQuizHistoryModel.swift + CareerQuizRetakeView.swift
- Modify OnboardingContainerView (add state selector + difficulty picker)
- Modify StudentProfileModel (add state, classDifficultyPreference)
- Modify GraduationTrackerView to use state engine
- **~4 new files + ~4 modified files**

### Agent K3: Activity Suggestion Engine + Career-Driven UX
- ActivitySuggestionEngine.swift (4 general + 6 per career path × 5 paths = 34 suggestions)
- Modify ActivitiesPortfolioView (show suggested vs logged)
- Modify DashboardView quick actions (career-specific)
- Modify CollegeDiscoveryViewModel (auto-filter by career)
- Modify EssayTrackerView (auto-populate from saved colleges)
- **~1 new file + ~5 modified files**

### Agent K4: School Data System
- SchoolDataModels.swift (clubs, sports, calendar)
- ClubsUploadView.swift + SportsUploadView.swift + SchoolCalendarView.swift
- MySchoolView.swift (student sees their school)
- Modify AdminTabView to link to new upload views
- **~5 new files + ~2 modified files**

### Total: ~13 new files + ~16 modified files

---

## PART 7: WHAT THIS UNLOCKS

After implementing this plan, a student's experience becomes:

**9th Grade Maria (STEM, Florida)**:
1. Opens app → takes career quiz → "You're 75% STEM / 15% Business / 10% Arts"
2. Dashboard shows: "Join Robotics Club at YOUR school (meets Tuesdays)" | "Start volunteering: goal 30 hrs this year" | "Take Pre-AP Math to stay on STEM track"
3. Activities page shows: ✓ General (0/4) — Volunteering, Club, Athletics, Job needed | ✓ STEM (0/6) — Science fair, coding project, robotics, research paper, STEM camp, math competition
4. Graduation Tracker shows FL 24-credit progress
5. Bright Futures shows: "GPA 3.5 + 1330 SAT + 100 service hours = 100% tuition free"
6. College Discovery defaults to "Best for STEM" filter
7. Features she CAN'T see: Essay Tracker, Decision Portal, FAFSA, Enrollment. But "Coming Up" section shows: "In 11th grade you'll unlock Essay Writing tools"

**12th Grade Marcus (Business, Florida)**:
1. Opens app → App Season Dashboard: "47 days until Regular Decision deadlines"
2. Dashboard shows: "Finish UF supplemental essay (245/650 words)" | "Submit FSU application (due Dec 1)" | "Compare financial aid packages"
3. All features unlocked — Decision Portal, FAFSA Guide, Enrollment Checklists, Housing
4. Activities page shows 4 years of logged activities, Common App Export ready
5. Career quiz history: "9th: STEM 60% → 10th: Business 55% → 11th: Business 70% → 12th: Business 80%"

**That's the connected painting.**
