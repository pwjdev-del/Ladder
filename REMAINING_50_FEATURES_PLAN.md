# Ladder — Remaining 50 Features Implementation Plan

**Current state**: 107 Swift files, 65 features built, 6,322 colleges, BUILD SUCCEEDING
**Target**: Complete all 115 planned features

---

## SPRINT 1: Core Student Tools (12 features, ~15 new/modified files)
*These are P1 features that every student needs. No backend dependency.*

### 1A. Adaptive Career Quiz (3-stage RIASEC)
**Research**: Complete (adaptive-career-discovery-quiz.md — 400+ lines)
**Files to create**:
- `Features/Shared/Views/AdaptiveCareerQuizView.swift` — 3-stage flow (General → Branch → Results)
- `Features/Shared/ViewModels/AdaptiveCareerQuizViewModel.swift` — RIASEC scoring, branching logic, consistency detection
- `Features/Shared/Models/CareerQuizModels.swift` — @Model: QuizResultModel (stores scores, bucket, sub-specializations, date, grade taken), QuizQuestionBank (all 30 questions)

**Logic**:
- Stage 1: 5 general questions (scenario, forced-choice, Likert, ranking, time-allocation)
- Scoring gate: calculate 5 bucket scores, identify top 2
- Stage 2: 5 branch-specific questions based on top bucket (STEM/Medical/Business/Humanities/Sports)
- Stage 3: AI personalization via Gemini (career narrative, major recs, college suggestions, AP alignment)
- Annual retake: store history, show year-over-year comparison chart
- Replace current CareerQuizView in onboarding Step 4

**Features covered**: 2.1, 2.2, 2.3, 2.4, 1.10, 1.11, 1.12

### 1B. Per-Semester GPA Tracking
**Files to create**:
- `Features/Shared/Models/GradeModels.swift` — @Model: SemesterModel (year, semester, courses: [CourseGrade]), CourseGrade (name, grade, credits, isAP, isHonors, isDE)
- `Features/Shared/Views/GPATrackerView.swift` — Add courses per semester, auto-calculate unweighted + weighted GPA, show trend chart
- `Features/Shared/ViewModels/GPATrackerViewModel.swift` — GPA calculation (standard + FL Bright Futures weighting: AP/IB/DE +0.5, Honors +0.25)

**Features covered**: 3.7, 3.9 (AP suggestions can come from seeing which APs are missing)

### 1C. Supplemental Essay Tracker
**Files to create**:
- `Features/AIAdvisor/Models/EssayModels.swift` — @Model: EssayModel (collegeId, collegeName, essayType: "personal"/"supplemental", prompt, wordLimit, draft, status: "not_started"/"drafting"/"reviewing"/"complete", dueDate)
- `Features/AIAdvisor/Views/EssayTrackerView.swift` — Shows all essays grouped by college, progress bars, word count, status badges
- `Features/AIAdvisor/ViewModels/EssayTrackerViewModel.swift`

**Modify**: EssayHubView.swift — Replace sample data with SwiftData fetch
**Features covered**: 8.2, 8.3

### 1D. Weekly "3 Things To Do" Widget
**Files to create**:
- `Features/Dashboard/Views/WeeklyTasksCard.swift` — Shows 3 prioritized tasks for this week based on: nearest deadlines, incomplete checklist items, missing profile data
- Add to DashboardView as a card

**Modify**: DashboardView.swift — Add WeeklyTasksCard after checklistProgressCard
**Features covered**: 11.7

### 1E. FERPA/COPPA Consent Flow
**Files to create**:
- `Features/Auth/Views/ConsentView.swift` — Age verification (13+ for COPPA), parental consent for under-18, data usage agreement, FERPA acknowledgment
- `Features/Auth/Models/ConsentModel.swift` — @Model: ConsentRecord (agreedAt, ageVerified, parentalConsent)

**Modify**: LadderApp.swift — Show consent before onboarding if not yet agreed
**Features covered**: 17.5

---

## SPRINT 2: College Intelligence Enhancements (10 features, ~10 files)
*Makes college profiles richer and more visual.*

### 2A. Campus Photos
**Approach**: Use each college's `websiteURL` + `/images/` or generate a Google search URL. For v1, use deterministic gradient + initials (already built) but add an `AsyncImage` attempt from the school's URL.

**Files to modify**:
- `CollegeProfileView.swift` — Replace gradient hero with AsyncImage attempt, fallback to gradient
- `CollegeDiscoveryView.swift` — Add small thumbnail attempt on college cards
- `CollegeModel` — Already has `imageURL` field, populate during seed from school website

**Features covered**: 5.2

### 2B. School Logo + Colors
**Approach**: Use Clearbit Logo API (free): `https://logo.clearbit.com/{domain}`. Extract domain from `websiteURL`.

**Files to create**:
- `Core/Services/LogoService.swift` — Extracts domain from websiteURL, returns Clearbit logo URL

**Modify**: CollegeDiscoveryView, CollegeProfileView — Show logo from AsyncImage
**Features covered**: 5.3, 5.4

### 2C. "Best for Your Major" Filter
**Files to modify**:
- `CollegeFiltersView.swift` — Add "Best for my career path" toggle that filters colleges with programs matching the student's career bucket
- `CollegeDiscoveryViewModel.swift` — Add career-based filter predicate

**Features covered**: 5.12

### 2D. AI-Generated College Pages (Unlisted Schools)
**Files to create**:
- `Features/CollegeIntelligence/Views/GenerateCollegePageView.swift` — Input school name + URL, AI generates profile from web data
- `Features/CollegeIntelligence/ViewModels/GenerateCollegeViewModel.swift`

**Features covered**: 5.10

### 2E. Pre-Admission Checklist (Phase 1) + Post-Acceptance Checklist (Phase 2)
**Files to create**:
- `Features/Applications/Views/ApplicationChecklistView.swift` — Phase 1 (before decision): transcript sent, test scores sent, essays submitted, LoRs requested, fee paid. Phase 2 (after acceptance): enrollment deposit, housing app, orientation signup, immunizations, placement tests
- Auto-generates from CollegeModel data (FL schools get deep Phase 2)

**Modify**: ApplicationDetailView.swift — Wire to real checklist
**Features covered**: 6.3, 6.4

---

## SPRINT 3: Academic Planning Engine (8 features, ~8 files)
*Makes the academic planning side fully functional.*

### 3A. Transcript Upload + AI Parse
**Modify**: TranscriptUploadView.swift — Wire the existing photosPicker to Gemini Vision API via AIService. Extract: courses, grades, GPA, credits. Auto-populate SemesterModel from Sprint 1B.

**Features covered**: 1.6, 1.7, 3.1

### 3B. AP Course Suggestions with Difficulty
**Files to create**:
- `Features/Shared/Views/APCourseSuggestionsView.swift` — Based on career path + current courses + target schools' rigor importance, suggest specific APs with difficulty ratings (Easy/Moderate/Hard based on national pass rates)

**Modify**: ClassRecommendationsView.swift — Add AP-specific section with difficulty labels
**Features covered**: 3.9

### 3C. Dual Enrollment Guide + Tracking
**Files to create**:
- `Features/Shared/Views/DualEnrollmentView.swift` — FL dual enrollment requirements (3.0 GPA, placement tests), credit transfer rules, how DE credits map to college courses

**Features covered**: 3.10

### 3D. Career-Specific Activity Suggestions
**Modify**: ActivitiesPortfolioView.swift — Add "Suggested Activities" section that recommends specific activities based on career bucket (e.g., Medical → hospital volunteering, research assistant, health club)

**Features covered**: 4.6, 4.15

### 3E. Research Paper + Internship Tracking
**Modify**: AddActivityView.swift — Ensure "Research" and "Internship" categories have specialized fields (paper title, journal, mentor name for research; company, supervisor, project for internship)

**Features covered**: 4.8, 4.9

---

## SPRINT 4: Notification & Reminder System (6 features, ~4 files)
*Makes the app proactively helpful.*

### 4A. SAT/PSAT Registration Reminders
**Modify**: LocalNotificationManager.swift — Add methods for:
- PSAT reminder (October of 10th grade)
- SAT registration deadlines (6 dates per year, register 4 weeks before)
- Trigger from student's grade level

**Features covered**: 10.2, 10.3

### 4B. Annual Career Quiz Retake Prompt
**Modify**: LocalNotificationManager.swift — Schedule September 1 notification: "Time to retake your career quiz! See how your interests have evolved."

**Features covered**: 2.2

### 4C. Grade-Aware Activity Urgency Flags
**Modify**: ActivitiesPortfolioView.swift — Show warning banners for juniors/seniors with few activities: "You're in 11th grade with only 2 activities — colleges want to see 4-6."

**Features covered**: 4.15

### 4D. Test Prep Resource Links
**Files to create**:
- `Features/Shared/Views/TestPrepResourcesView.swift` — Links to Khan Academy SAT prep, College Board practice, ACT.org, free resources. Categorized by section (Math, Reading, Writing).

**Features covered**: 10.4

### 4E. Scholarship Action Plans
**Modify**: ScholarshipSearchView.swift — For each scholarship, show action items (eligibility check, documents needed, essay required, deadline). Mark as "Applied" or "Not Eligible."

**Features covered**: 9.3, 9.2

### 4F. FAFSA Readiness Score
**Modify**: FAFSAGuideView.swift — Add a readiness percentage based on which documents the student has gathered. "You're 60% ready for FAFSA."

**Features covered**: 9.6

---

## SPRINT 5: Multi-User & Social Features (8 features, ~10 files)
*Requires Supabase backend for multi-user.*

### 5A. Parent Access Toggle
**Files to create**:
- `Features/Settings/Views/ParentAccessView.swift` — Generate 6-digit invite code, parent enters on their device, sees read-only dashboard (grades, deadlines, college list, financial aid)

**Features covered**: 17.4

### 5B. Counselor Portal (Full)
**Modify**: CounselorDashboardView.swift — Add auth role check, real student list from Supabase, at-risk flags (no SAT, low GPA, few activities), class preference approval workflow

**Files to create**:
- `Features/Counselor/Views/StudentDetailView.swift` — Counselor's view of individual student
- `Features/Counselor/Views/ClassApprovalView.swift` — Review + approve class preferences

**Features covered**: 12.1, 12.2, 12.4, 12.5

### 5C. Counselor Marketplace (Full)
**Modify**: CounselorMarketplaceView.swift — Add booking flow, session scheduling, review system

**Files to create**:
- `Features/Counselor/Views/BookSessionView.swift` — Date/time picker, session type, payment placeholder
- `Features/Counselor/Views/CounselorProfileDetailView.swift` — Full profile, reviews, credentials
- `Features/Counselor/Views/AmbassadorSignupView.swift` — Founding counselor recruitment

**Features covered**: 13.1, 13.2, 13.3, 13.6, 13.7

### 5D. School Profile System
**Files to create**:
- `Features/Counselor/Views/SchoolProfileView.swift` — Counselor uploads: class catalog, clubs list, athletics, school-specific dates

**Features covered**: 3.3, 12.2

---

## SPRINT 6: Housing & Roommate System (4 features, ~5 files)
*Community features that need a user base.*

### 6A. Housing Preferences Quiz
**Files to create**:
- `Features/Housing/Views/HousingPreferencesView.swift` — Dorm type (single/double/suite), meal plan, quiet vs social, proximity preferences

**Features covered**: 15.1

### 6B. Dorm Comparison
**Files to create**:
- `Features/Housing/Views/DormComparisonView.swift` — Side-by-side dorm options per school (if data available)

**Features covered**: 15.2

### 6C. Roommate Finder
**Files to create**:
- `Features/Housing/Views/RoommateFinderView.swift` — Compatibility quiz, match %, intro messages (needs Supabase for multi-user)

**Features covered**: 15.3, 15.4

### 6D. Housing Deadline per Application
**Modify**: HousingTimelineView.swift — Show housing deadlines alongside application deadlines, grouped per school

**Features covered**: 6.8

---

## SPRINT 7: Reports & Export (4 features, ~4 files)
*PDF generation and sharing.*

### 7A. PDF Portfolio Export
**Files to create**:
- `Features/Reports/Services/PDFGenerator.swift` — Uses UIGraphicsImageRenderer or TPPDF to generate branded PDF with: student info, GPA, test scores, activities, essays, accomplishments
- `Features/Reports/Views/PDFPreviewView.swift` — Preview + share

**Features covered**: 16.1, 16.2

### 7B. Alternative Paths (CC/Trade/Military/Gap Year)
**Files to create**:
- `Features/Shared/Views/AlternativePathsView.swift` — Information cards for: community college transfer, trade schools, military (ROTC/academies), gap year programs. Links to resources.

**Features covered**: 11.4

---

## SPRINT 8: Post-College & Future Features (4 features, ~4 files)
*P4 features for post-acceptance students.*

### 8A. Career Explorer (Degree → Jobs)
**Files to create**:
- `Features/Shared/Views/CareerExplorerView.swift` — Maps majors to jobs + salary ranges (BLS data). Shows: job title, median salary, growth rate, education required.

**Features covered**: 18.1, 7.7

### 8B. Resume Builder
**Modify**: AcademicResumeView.swift — Add professional resume template option (1-page, formatted for internships)

**Features covered**: 18.3

### 8C. Internship Guide
**Files to create**:
- `Features/Shared/Views/InternshipGuideView.swift` — When to apply, how to find internships, resume tips, interview prep for specific industries

**Features covered**: 18.2

### 8D. Post-Graduation Mode
**Files to create**:
- `Features/Shared/Views/PostGradModeView.swift` — Switches app to post-college mode: internship tracking, career planning, grad school prep

**Features covered**: 18.4

---

## EXECUTION SCHEDULE

| Sprint | Features | New Files | Priority | Dependencies |
|--------|----------|-----------|----------|-------------|
| **Sprint 1** | 12 features | ~15 files | P1 (critical) | None |
| **Sprint 2** | 10 features | ~10 files | P1-P2 | Sprint 1 (GPA data for gap analysis) |
| **Sprint 3** | 8 features | ~8 files | P1-P2 | Sprint 1 (GPA model, Activities) |
| **Sprint 4** | 6 features | ~4 files | P1-P2 | Sprint 1 (notifications) |
| **Sprint 5** | 8 features | ~10 files | P2-P3 | Supabase backend |
| **Sprint 6** | 4 features | ~5 files | P2-P3 | Supabase + user base |
| **Sprint 7** | 4 features | ~4 files | P2 | Sprints 1-3 (data to export) |
| **Sprint 8** | 4 features | ~4 files | P4 | Post-launch |

**Total: 50 features across 8 sprints, ~60 new files**

### Parallel Execution Strategy
- **Sprints 1-4** can run in parallel (4 agents, one per sprint)
- **Sprint 5** needs Supabase backend configured first
- **Sprints 6-8** are post-launch features

### After All Sprints
Final app: ~167 Swift files, 115/115 features, 6,322 colleges, all research integrated.
