# Legacy Triage — Phase 2b
Generated: 2026-04-27

---

## 1. Summary Table

| Classification       | Count | Notes |
|----------------------|-------|-------|
| PROMOTE              | 47    | Logic intact, imports trivially fixable |
| PROMOTE_WITH_REWRITES| 28    | Right concept, stale Auth/AWS/SwiftData wiring |
| MERGE_INTO           | 5     | Overlaps with an active file |
| REWRITE              | 4     | Concept wanted, code too stale or too hardcoded |
| DELETE               | 13    | AWS-only stubs, pure prototypes, confirmed dead |
| **Total**            | **97** (161 Features + 49 Services = 210, minus ~113 UI helper/view-modifier files bucketed en bloc below) | |

**Effort estimates (per promotion cluster):**
- Engines cluster — S (no wiring needed, pure logic)
- Shared Models + SwiftData schema — S (already used by active code)
- AI Advisor / SiaEngine stack — M (PromptBuilder needs AIGatewayClient hookup)
- Career + CollegeIntelligence features — M (AuthManager refs must flip to AppCoordinator/SupabaseAuthService)
- Counselor + Admin surfaces — M (same auth swap, plus active CounselorDashboardView collision)
- Auth / Onboarding views — L (biggest collision risk: AuthManager, UserRole, AuthState)
- Sync / Networking infrastructure — S-M (AppSync stubs → delete; Supabase+NetworkMonitor → promote)

**DesignSystem en-bloc PROMOTE:** All view-modifier extensions, color tokens, spacing constants, and typography helpers inside `Features/Legacy/*/Views/` that do not define a named top-level `View` struct or `ViewModel` — promote to `LadderApp/DesignSystem/` without individual listing. Verify no name clash with existing `ColorTokens.swift`, `Spacing.swift`, `Typography.swift` (active files exist — confirm no duplicate `LadderColors` extension).

---

## 2. Promote-Now Cluster — Services/Legacy/Engines/

These are the load-bearing pieces called out by ADR-008 §2. All are pure-logic, `@Observable`, no AWS/Auth dependency.

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `ActivitySuggestionEngine.swift` | **PROMOTE** | Self-contained 4+7 system, no external deps | `LadderApp/Services/Engines/` |
| `CollegeMatchCalculator.swift` | **PROMOTE** | Pure function, no state | `LadderApp/Services/Engines/` |
| `ConnectionEngine.swift` | **PROMOTE** | Uses `ModelContext` + `UserDefaults`, no Auth dep | `LadderApp/Services/Engines/` |
| `StateRequirementsEngine.swift` | **PROMOTE** | Pure lookup, no external deps | `LadderApp/Services/Engines/` |
| `LevelManager.swift` | **PROMOTE** | Pure XP calculator, no deps | `LadderApp/Services/Engines/` |
| `ContentModerationService.swift` | **PROMOTE_WITH_REWRITES** | Comment says "TODO: Replace with AWS Comprehend" — strip that note, ship the keyword list as-is for now | `LadderApp/Services/Engines/` |
| `CollegeLogoService.swift` | **PROMOTE** | Stateless URL builder using Clearbit; no AWS dependency | `LadderApp/Services/Engines/` |

**Also promote from Features/Legacy/Career/Services/:**
| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `RIASECEngine.swift` | **PROMOTE** | Canonical 3-stage Holland Code engine, pure logic | `LadderApp/Services/Engines/` |

---

## 3. Features/Legacy/ — Per-Subfolder Classification

### 3a. AIAdvisor/
*11 files. The SIA advisor UI — chat, essay hub, mock interview, LOCI, academic resume, score improvement.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/ChatModels.swift` | **PROMOTE** | `ChatSessionModel`/`ChatMessageModel` are SwiftData `@Model`s, already in SwiftDataContainer schema | `LadderApp/Features/Student/AIAdvisor/Models/` |
| `ViewModels/AdvisorChatViewModel.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` (legacy proxy) — swap to `AIGatewayClient`; uses `AuthManager` — swap to `SupabaseAuthService` for access token | `LadderApp/Features/Student/AIAdvisor/` |
| `ViewModels/AcademicResumeViewModel.swift` | **PROMOTE_WITH_REWRITES** | Same AIService swap; otherwise clean | `LadderApp/Features/Student/AIAdvisor/` |
| `ViewModels/ActivityImpactViewModel.swift` | **PROMOTE_WITH_REWRITES** | Same AIService swap | `LadderApp/Features/Student/AIAdvisor/` |
| `ViewModels/MockInterviewViewModel.swift` | **PROMOTE_WITH_REWRITES** | Same AIService swap | `LadderApp/Features/Student/AIAdvisor/` |
| `Views/AdvisorHubView.swift` | **PROMOTE** | Already references `AppCoordinator`, clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/AdvisorChatView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager.self` env — swap to `SupabaseAuthService` for session token | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/EssayHubView.swift` | **PROMOTE** | No auth refs found, pure SwiftData + nav | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/MockInterviewView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/MockInterviewFeedbackView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/AcademicResumeView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/ActivityImpactView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/LOCIGeneratorView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/ScoreImprovementView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |
| `Views/ThankYouNoteView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/AIAdvisor/Views/` |

---

### 3b. Academic/
*6 files. AI class planner, GPA tracker, AP suggestions, dual enrollment, test prep.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/GPAEntryModel.swift` | **PROMOTE** | `@Model` already in SwiftDataContainer schema | `LadderApp/Features/Student/Academic/Models/` |
| `Services/ClassScheduleAIEngine.swift` | **PROMOTE_WITH_REWRITES** | Pure logic but calls `AIService` internally via ViewModel — promote as engine, wire AI calls to `AIGatewayClient` in ViewModel layer | `LadderApp/Services/Engines/` |
| `ViewModels/AIClassPlannerViewModel.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` — swap to `AIGatewayClient` | `LadderApp/Features/Student/Academic/` |
| `ViewModels/GPATrackerViewModel.swift` | **PROMOTE** | Pure SwiftData read/write, no auth | `LadderApp/Features/Student/Academic/` |
| `Views/AIClassPlannerView.swift` | **PROMOTE** | No auth refs; use with rewritten ViewModel | `LadderApp/Features/Student/Academic/Views/` |
| `Views/GPATrackerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Academic/Views/` |
| `Views/APSuggestionView.swift` | **PROMOTE** | Clean informational UI | `LadderApp/Features/Student/Academic/Views/` |
| `Views/ClassDifficultyPickerView.swift` | **PROMOTE** | Clean picker | `LadderApp/Features/Student/Academic/Views/` |
| `Views/DualEnrollmentGuideView.swift` | **PROMOTE** | Static content view | `LadderApp/Features/Student/Academic/Views/` |
| `Views/TestPrepResourcesView.swift` | **PROMOTE** | Static content view | `LadderApp/Features/Student/Academic/Views/` |

---

### 3c. AdminModels/ + AdminViews/
*7 files. School admin dashboard, uploads, district analytics.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `AdminModels/SchoolDataModels.swift` | **PROMOTE** | `SchoolClubModel`, `SchoolSportModel`, `SchoolCalendarEventModel` are `@Model` types already in SwiftDataContainer; no collision | `LadderApp/Features/Admin/Models/` |
| `AdminViews/SchoolAdminDashboardView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager` — swap; concept maps to ADR-008 school surface | `LadderApp/Features/Admin/Dashboard/` |
| `AdminViews/ClassCatalogUploadView.swift` | **PROMOTE** | No auth refs; SwiftData inserts | `LadderApp/Features/Admin/Uploads/` |
| `AdminViews/ClubsUploadView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Admin/Uploads/` |
| `AdminViews/SportsUploadView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Admin/Uploads/` |
| `AdminViews/SchoolCalendarUploadView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Admin/Uploads/` |
| `AdminViews/DistrictAnalyticsView.swift` | **PROMOTE** | No auth refs; aggregates SwiftData counts | `LadderApp/Features/Admin/Analytics/` |

---

### 3d. Applications/
*6 files. App season dashboard, detail view, deadlines calendar, decision portal, LOR tracker.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/ApplicationModels.swift` | **PROMOTE** | `ApplicationModel`, `ChecklistItemModel` are `@Model`s in schema | `LadderApp/Features/Student/Applications/Models/` |
| `Models/LORModel.swift` | **PROMOTE** | `LetterOfRecModel` `@Model` already in schema | `LadderApp/Features/Student/Applications/Models/` |
| `ViewModels/AppSeasonDashboardViewModel.swift` | **PROMOTE** | Pure SwiftData, no auth | `LadderApp/Features/Student/Applications/` |
| `Views/AppSeasonDashboardView.swift` | **PROMOTE** | Clean; references `AppCoordinator` not `AuthManager` | `LadderApp/Features/Student/Applications/Views/` |
| `Views/ApplicationDetailView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Applications/Views/` |
| `Views/DeadlinesCalendarView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Applications/Views/` |
| `Views/DecisionPortalView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Applications/Views/` |
| `Views/LORTrackerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Applications/Views/` |

---

### 3e. AuthViews/
*8 files. Login, age gate, counselor/parent/admin onboarding, DPA consent, force password change, legal views.*

**WARNING: This subfolder has the highest collision density. See §5.**

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `LoginView.swift` | **DELETE** | Replaced by active `B2CLoginView` + `SchoolLoginView` + `FounderLoginView`; references legacy `AuthManager` + old `UserRole` env | — |
| `AgeGateView.swift` | **PROMOTE_WITH_REWRITES** | COPPA gate logic wanted; strip `AuthManager` dep, wire to `SupabaseAuthService` onboarding flow | `LadderApp/Features/Auth/AgeGate/` |
| `CounselorOnboardingView.swift` | **PROMOTE_WITH_REWRITES** | School code join flow wanted; swap `AuthManager`/`SchoolCodeManager` → `TenantContext` + `SupabaseAuthService` | `LadderApp/Features/Counselor/Onboarding/` |
| `ParentOnboardingView.swift` | **PROMOTE_WITH_REWRITES** | Parent linkage onboarding wanted; swap `AuthManager` env | `LadderApp/Features/Parent/Onboarding/` |
| `SchoolAdminOnboardingView.swift` | **PROMOTE_WITH_REWRITES** | School admin DPA + setup flow wanted; swap `AuthManager` | `LadderApp/Features/Admin/Onboarding/` |
| `DPAConsentView.swift` | **PROMOTE** | Stateless consent UI, no `AuthManager` dep found; `onConsent` callback pattern clean | `LadderApp/Features/Auth/Legal/` |
| `ForcePasswordChangeView.swift` | **PROMOTE_WITH_REWRITES** | First-login password change wanted; swap `AuthManager` → `SupabaseAuthService.updatePassword()` | `LadderApp/Features/Auth/ForcePasswordChange/` |
| `PrivacyPolicyView.swift` | **PROMOTE** | Static; feeds from `LegalTexts` | `LadderApp/Features/Auth/Legal/` |
| `TermsOfServiceView.swift` | **PROMOTE** | Same | `LadderApp/Features/Auth/Legal/` |

---

### 3f. Career/
*8 files. RIASEC engine (promoted above), career quiz UI, explorer, override sheet, retake, major picker, history model.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/CareerQuizHistoryModel.swift` | **PROMOTE** | `@Model` already in schema | `LadderApp/Features/Student/Career/Models/` |
| `Services/RIASECEngine.swift` | **PROMOTE** | (see §2 above) | `LadderApp/Services/Engines/` |
| `ViewModels/CareerQuizViewModel.swift` | **MERGE_INTO** | Functional but the 5-bucket model it uses is superseded by the active `CareerQuizViewModel` (ObservableObject) in `Features/Student/CareerQuiz/`. Reconcile the RIASEC 3-stage flow from Legacy into the active file. | `LadderApp/Features/Student/CareerQuiz/CareerQuizView.swift` |
| `ViewModels/CareerExplorerViewModel.swift` | **PROMOTE** | No auth dep, SwiftData read | `LadderApp/Features/Student/Career/` |
| `Views/AdaptiveCareerQuizView.swift` | **PROMOTE_WITH_REWRITES** | The RIASEC 3-stage quiz UI; rename to `RIASECQuizView` to avoid collision with active `CareerQuizView` | `LadderApp/Features/Student/Career/Views/` |
| `Views/CareerExplorerView.swift` | **PROMOTE** | No collision | `LadderApp/Features/Student/Career/Views/` |
| `Views/CareerOverrideSheet.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Career/Views/` |
| `Views/CareerQuizRetakeView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Career/Views/` |
| `Views/MajorPickerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Career/Views/` |

---

### 3g. Checklists/
*3 files. Tasks list, roadmap.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `ViewModels/TasksViewModel.swift` | **PROMOTE** | No auth dep; uses `TaskItem.sampleTasks` — replace with SwiftData fetch in followup | `LadderApp/Features/Student/Checklists/` |
| `Views/RoadmapView.swift` | **PROMOTE** | No auth dep; grade-gated content | `LadderApp/Features/Student/Checklists/Views/` |
| `Views/TasksView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Checklists/Views/` |

---

### 3h. CollegeIntelligence/
*16 files. Discovery, profile, comparison, deadlines, GapAnalysis, MyChances, WhatIf, VisitPlanner, APCredits, etc.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/CollegeModels.swift` | **PROMOTE** | `CollegeModel`, `CollegePersonalityModel`, `CollegeDeadlineModel` `@Model`s in schema | `LadderApp/Features/Student/CollegeIntelligence/Models/` |
| `Models/CollegeVisitModel.swift` | **PROMOTE** | `CollegeVisitModel` `@Model` in schema | `LadderApp/Features/Student/CollegeIntelligence/Models/` |
| `ViewModels/CollegeDiscoveryViewModel.swift` | **PROMOTE** | No auth dep; references `AppCoordinator` — clean | `LadderApp/Features/Student/CollegeIntelligence/` |
| `ViewModels/AICollegeSummaryViewModel.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` — swap to `AIGatewayClient` | `LadderApp/Features/Student/CollegeIntelligence/` |
| `ViewModels/DeadlineHeatmapViewModel.swift` | **PROMOTE** | Pure SwiftData | `LadderApp/Features/Student/CollegeIntelligence/` |
| `ViewModels/MyChancesViewModel.swift` | **PROMOTE** | Uses `CollegeMatchCalculator` — fine | `LadderApp/Features/Student/CollegeIntelligence/` |
| `ViewModels/VisitPlannerViewModel.swift` | **PROMOTE** | Pure SwiftData | `LadderApp/Features/Student/CollegeIntelligence/` |
| `ViewModels/WhatIfSimulatorViewModel.swift` | **PROMOTE** | Uses `CollegeMatchCalculator` — fine | `LadderApp/Features/Student/CollegeIntelligence/` |
| `Views/CollegeDiscoveryView.swift` | **PROMOTE** | References `AppCoordinator` — clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/CollegeProfileView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/CollegeComparisonView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/MyChancesView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/WhatIfSimulatorView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/DeadlineHeatmapView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/AICollegeSummaryView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/GapAnalysisView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/VisitPlannerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/APCreditsView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/AdmissionChecklistView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/EnrollmentChecklistView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/AcceptanceWarningView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/CollegeFiltersView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/CollegePersonalityView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |
| `Views/CollegePreferenceQuizView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/CollegeIntelligence/Views/` |

---

### 3i. CounselorModels/ + CounselorServices/ + CounselorViewModels/ + CounselorViews/
*16 files. Caseload manager, booking, bulk import, class approval, impact report, marketplace, review, verification, deadline calendar.*

**Note:** Active `CounselorDashboardView` exists at `Features/Counselor/Dashboard/`. Legacy counselor views are additive sub-screens, not root replacements.

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `CounselorModels/CounselorModels.swift` | **PROMOTE** | `CounselorProfileModel` `@Model` in schema | `LadderApp/Features/Counselor/Models/` |
| `CounselorServices/SchoolYearRolloverService.swift` | **PROMOTE** | Pure SwiftData mutation, no auth dep | `LadderApp/Services/Counselor/` |
| `CounselorViewModels/CaseloadManagerViewModel.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager` — swap counselorId to come from `SupabaseAuthService.currentUser` | `LadderApp/Features/Counselor/Caseload/` |
| `CounselorViews/CaseloadManagerView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager.self` env — swap | `LadderApp/Features/Counselor/Caseload/` |
| `CounselorViews/StudentDetailCounselorView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Caseload/` |
| `CounselorViews/AddSingleStudentView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Caseload/` |
| `CounselorViews/BulkStudentImportView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Caseload/` |
| `CounselorViews/ClassApprovalListView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/ClassApproval/` |
| `CounselorViews/ClassApprovalDetailView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/ClassApproval/` |
| `CounselorViews/CounselorImpactReportView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Reports/` |
| `CounselorViews/CounselorMarketplaceView.swift` | **PROMOTE** | No auth dep; uses `CounselorProfileModel` query | `LadderApp/Features/Student/Marketplace/` |
| `CounselorViews/CounselorReviewView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Marketplace/` |
| `CounselorViews/CounselorVerificationView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Onboarding/` |
| `CounselorViews/BookSessionView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Marketplace/` |
| `CounselorViews/GenericDeadlineCalendarView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/` |
| `CounselorViews/StudentCredentialCardView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Counselor/Caseload/` |

---

### 3j. Dashboard/
*3 files. Student home dashboard with weekly widget.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `ViewModels/DashboardViewModel.swift` | **PROMOTE** | References `AppCoordinator` not `AuthManager`; `DashboardAction`/`DashboardDeadline` structs are local — no collision | `LadderApp/Features/Student/Dashboard/` |
| `Views/DashboardView.swift` | **PROMOTE** | References `AppCoordinator.self` env — clean; no name collision with active `StudentDashboardView` | `LadderApp/Features/Student/Dashboard/Views/` |
| `Views/WeeklyWidgetView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Dashboard/Views/` |

---

### 3k. Financial/
*5 files. Scholarship match, FAFSA guide, CSS guide, financial aid comparison, search.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/FinancialAidModels.swift` | **PROMOTE** | `FinancialAidPackageModel`, `ScholarshipModel` `@Model`s in schema | `LadderApp/Features/Student/Financial/Models/` |
| `ViewModels/ScholarshipMatchViewModel.swift` | **PROMOTE** | Pure SwiftData, no auth | `LadderApp/Features/Student/Financial/` |
| `Views/ScholarshipMatchView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Financial/Views/` |
| `Views/ScholarshipSearchView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Financial/Views/` |
| `Views/FAFSAGuideView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Financial/Views/` |
| `Views/CSSProfileGuideView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Financial/Views/` |
| `Views/FinancialAidComparisonView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Financial/Views/` |

---

### 3l. Housing/
*1 file.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Views/HousingTimelineView.swift` | **PROMOTE** | Clean; post-acceptance feature wanted | `LadderApp/Features/Student/Applications/Views/` |

---

### 3m. OldDuplicates/
*3 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `CareerQuizView_Shared.swift` | **DELETE** | Superseded 5-bucket quiz; active `CareerQuizView` exists with RIASEC engine | — |
| `CounselorDashboardView_Old.swift` | **DELETE** | Active `CounselorDashboardView` exists in `Features/Counselor/Dashboard/`; this queries `CollegeDeadlineModel` only — logic absorbed | — |
| `ParentDashboardView_Old.swift` | **DELETE** | Active `ParentDashboardView` exists in `Features/Parent/`; this is the full replacement | — |

---

### 3n. Onboarding/
*2 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `ViewModels/OnboardingViewModel.swift` | **PROMOTE_WITH_REWRITES** | Right concept; step 4 uses old 5-bucket career scores — replace with `RIASECEngine`; remove `AuthManager` dependency | `LadderApp/Features/Student/Onboarding/` |
| `Views/OnboardingContainerView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager.self` env — swap to `SupabaseAuthService`/`AppCoordinator`; 6-step flow is correct | `LadderApp/Features/Student/Onboarding/` |

---

### 3o. ParentViewsOld/
*2 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `ChildSwitcherView.swift` | **PROMOTE_WITH_REWRITES** | Multi-child switching is an ADR-008 feature (parent multi-child digest); strip hardcoded mock `LinkedChild` array, wire to `TenantContext`/Supabase children lookup | `LadderApp/Features/Parent/ChildSwitcher/` |
| `PeerComparisonView.swift` | **PROMOTE** | Anonymous comparison; hardcoded national averages are acceptable as constants for now | `LadderApp/Features/Student/Profile/` |

---

### 3p. Reports/
*6 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Views/ImpactReportView.swift` | **PROMOTE** | Clean SwiftData, no auth | `LadderApp/Features/Student/Reports/Views/` |
| `Views/PDFPortfolioView.swift` | **PROMOTE** | Text export; no auth dep | `LadderApp/Features/Student/Reports/Views/` |
| `Views/SocialShareView.swift` | **PROMOTE** | Clean share sheet | `LadderApp/Features/Student/Reports/Views/` |
| `Views/AlternativePathsView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Reports/Views/` |
| `Views/InternshipGuideView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Reports/Views/` |
| `Views/PostGraduationView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Reports/Views/` |

---

### 3q. Settings/
*5 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Views/ProfileSettingsView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager` for signOut — swap to `SupabaseAuthService.signOut()` | `LadderApp/Features/Student/Settings/Views/` |
| `Views/NotificationCenterView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Settings/Views/` |
| `Views/ParentAccessView.swift` | **PROMOTE** | No auth dep; invite code generation | `LadderApp/Features/Student/Settings/Views/` |
| `Views/LegalSettingsView.swift` | **PROMOTE** | Static links to LegalTexts; no auth dep | `LadderApp/Features/Student/Settings/Views/` |
| `Views/DataDeletionView.swift` | **PROMOTE_WITH_REWRITES** | FERPA right-to-delete flow; calls need to route to Supabase deletion Edge Function | `LadderApp/Features/Student/Settings/Views/` |

---

### 3r. Shared/
*~20 files. Core models, portfolio VM/View, GPA tracker, SAT tracker, graduation tracker, messaging, milestones, volunteering, transcripts, CommonApp export, etc.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/ActivityModels.swift` | **PROMOTE** | `ActivityModel` `@Model` in schema | `LadderApp/Features/Student/Shared/Models/` |
| `Models/SATScoreModel.swift` | **PROMOTE** | `SATScoreEntryModel` `@Model` in schema | `LadderApp/Features/Student/Shared/Models/` |
| `ViewModels/ActivitiesPortfolioViewModel.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/` |
| `ViewModels/ClassRecommendationsViewModel.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` — swap to `AIGatewayClient` | `LadderApp/Features/Student/Shared/` |
| `ViewModels/GraduationTrackerViewModel.swift` | **PROMOTE** | Uses `StateRequirementsEngine` — no auth dep | `LadderApp/Features/Student/Shared/` |
| `ViewModels/SATScoreTrackerViewModel.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/` |
| `Views/ActivitiesPortfolioView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/AddActivityView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/BrightFuturesTrackerView.swift` | **PROMOTE** | Uses `StateRequirementsEngine` | `LadderApp/Features/Student/Shared/Views/` |
| `Views/ClassRecommendationsView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/CommonAppExportView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/CustomReminderView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/Views/` |
| `Views/FeeWaiverCheckerView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/Views/` |
| `Views/FreshmanSurvivalGuideView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Shared/Views/` |
| `Views/GraduationTrackerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/MessagingView.swift` | **PROMOTE** | Clean; uses `ContentModerationService` | `LadderApp/Features/Student/Shared/Views/` |
| `Views/MilestoneCelebrationView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/NCAAAthleteView.swift` | **PROMOTE** | Static content | `LadderApp/Features/Student/Shared/Views/` |
| `Views/ProfileView.swift` | **PROMOTE_WITH_REWRITES** | References `AuthManager` for signOut — same swap as ProfileSettingsView | `LadderApp/Features/Student/Shared/Views/` |
| `Views/SATScoreTrackerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/TranscriptUploadView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/Views/` |
| `Views/VolunteeringLogView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Shared/Views/` |
| `Views/WheelOfCareerView.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Shared/Views/` |

---

### 3s. StudentViewModels/ + StudentViews/
*3 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `StudentViewModels/First100DaysViewModel.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/PostAcceptance/` |
| `StudentViews/First100DaysView.swift` | **PROMOTE** | Clean; post-acceptance milestone feature | `LadderApp/Features/Student/PostAcceptance/Views/` |
| `StudentViews/MySchoolView.swift` | **PROMOTE** | Uses `SchoolClubModel`/`SchoolSportModel`/`SchoolCalendarEventModel` queries; no auth dep | `LadderApp/Features/Student/School/Views/` |

---

### 3t. Writing/
*4 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `Models/EssayModel.swift` | **PROMOTE** | `EssayModel` `@Model` in schema | `LadderApp/Features/Student/Writing/Models/` |
| `ViewModels/EssayTrackerViewModel.swift` | **PROMOTE** | No auth dep | `LadderApp/Features/Student/Writing/` |
| `ViewModels/WhyThisSchoolViewModel.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` — swap to `AIGatewayClient` | `LadderApp/Features/Student/Writing/` |
| `Views/EssayTrackerView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Writing/Views/` |
| `Views/WhyThisSchoolView.swift` | **PROMOTE** | Clean | `LadderApp/Features/Student/Writing/Views/` |

---

## 4. Services/Legacy/ — Per-Subfolder Classification

### 4a. Services/Legacy/AI/
*18 files. SiaEngine, AIService, PromptBuilder, SessionType, SpecialistPrompts, HandoffRouter, MemoryExtractorService, NudgeRules, AIRateLimiter, AIResponseCache, context structs.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `SiaEngine.swift` | **PROMOTE_WITH_REWRITES** | Replace `AIService` calls with `AIGatewayClient`; `HomeCard`/`SiaPriority` types must either be promoted alongside or redefined | `LadderApp/Services/AI/` |
| `AIService.swift` | **DELETE** | Replaced by `AIGatewayClient` (active, TLS-pinned, auth-bearing) | — |
| `AIRateLimiter.swift` | **DELETE** | Rate limiting moved server-side via ai-gateway Edge Function | — |
| `AIResponseCache.swift` | **REWRITE** | Caching concept is valid but the impl caches raw strings; needs redesign around `AIGatewayResponse` + tenant scoping before it can be used | — |
| `Prompts/PromptBuilder.swift` | **PROMOTE_WITH_REWRITES** | The structured prompt assembly pattern is valuable; update `SchoolContext` wiring to come from `TenantContext` instead of ad-hoc struct | `LadderApp/Services/AI/Prompts/` |
| `Prompts/SessionType.swift` | **PROMOTE** | Pure enum, no deps | `LadderApp/Services/AI/Prompts/` |
| `Prompts/SpecialistPromptLoader.swift` | **PROMOTE** | Pure static loader | `LadderApp/Services/AI/Prompts/` |
| `Prompts/SpecialistPrompts.swift` | **PROMOTE** | Large but clean string constants | `LadderApp/Services/AI/Prompts/` |
| `HandoffRouter.swift` | **PROMOTE** | Pure string-matching, no deps | `LadderApp/Services/AI/` |
| `MemoryExtractorService.swift` | **PROMOTE_WITH_REWRITES** | Uses `AIService` — swap to `AIGatewayClient`; uses `ConversationMemoryModel` which is in schema | `LadderApp/Services/AI/` |
| `NudgeRules.swift` | **PROMOTE** | Pure rules function, no deps | `LadderApp/Services/AI/` |
| `Context/StudentContext.swift` | **PROMOTE** | Codable snapshot struct, no deps | `LadderApp/Services/AI/Context/` |
| `Context/StudentContextBuilder.swift` | **PROMOTE** | SwiftData → `StudentContext` mapper, no auth dep | `LadderApp/Services/AI/Context/` |
| `Context/TemporalContext.swift` | **PROMOTE** | Pure date logic | `LadderApp/Services/AI/Context/` |
| `Context/SchoolContext.swift` | **PROMOTE_WITH_REWRITES** | Wire source to `TenantContext` (active) instead of free-form string capture | `LadderApp/Services/AI/Context/` |
| `Context/ConversationMemory.swift` | **PROMOTE** | No auth dep | `LadderApp/Services/AI/Context/` |
| `Context/ConversationMemoryModel.swift` | **PROMOTE** | `@Model` in schema | `LadderApp/Services/AI/Context/` |
| `Context/BehaviorSignals.swift` | **PROMOTE** | Pure struct, no deps | `LadderApp/Services/AI/Context/` |

---

### 4b. Services/Legacy/Audit/
*1 file.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `AuditLogger.swift` | **MERGE_INTO** | `AuditLogEntry` `@Model` is valid and in schema; however the active `AuditClient` (actor, TLS-pinned, Edge Function) is the real audit sink. Merge `AuditLogEntry` model into a local-cache companion of `AuditClient`; delete the `AuditLogger` class | `LadderApp/Services/Audit/AuditClient.swift` |

---

### 4c. Services/Legacy/Auth/
*4 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `AuthManager.swift` | **DELETE** | Replaced entirely by `SupabaseAuthService` (active); defines `AuthState` and `UserRole` which would duplicate active `AppCoordinator.AuthState`. **Biggest collision risk — see §5.** | — |
| `InviteCodeManager.swift` | **PROMOTE** | Code generation logic is clean and correct; no auth dep | `LadderApp/Services/Auth/` |
| `SchoolCodeManager.swift` | **PROMOTE** | Code generation from school name; no auth dep | `LadderApp/Services/Auth/` |
| `StudentAutoIDGenerator.swift` | **PROMOTE** | Deterministic credential generation for counselor-created accounts; no auth dep | `LadderApp/Services/Auth/` |

---

### 4d. Services/Legacy/Calendar/
*1 file.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `CalendarManager.swift` | **PROMOTE** | EventKit integration, clean `@MainActor` `@Observable`; no auth dep | `LadderApp/Services/Calendar/` |

---

### 4e. Services/Legacy/Data/
*5 files. College data pipeline.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `SwiftDataContainer.swift` | **MERGE_INTO** | Defines `LadderSchemaV1` with the canonical model list. The active build must adopt this versioned schema container to support migrations. Merge its `models:` list into the active `LadderApp.swift` model container setup; the migration stage scaffold is essential to keep. | Active SwiftData container in `LadderApp.swift` |
| `CollegeDataSeeder.swift` | **PROMOTE** | No auth dep; seeds `CollegeModel` from merged data | `LadderApp/Services/Data/` |
| `CollegeDataMerger.swift` | **PROMOTE** | Orchestrates Scorecard + Perplexity parse; no auth dep | `LadderApp/Services/Data/` |
| `ScorecardJSONParser.swift` | **PROMOTE** | Pure JSON → struct parser | `LadderApp/Services/Data/` |
| `PerplexityParser.swift` | **PROMOTE** | Pure parser | `LadderApp/Services/Data/` |
| `CollegeScorecardService.swift` | **PROMOTE_WITH_REWRITES** | Network fetch from College Scorecard API; strip the TODO comment about API key registration, add key to `AppConfiguration`; no AWS dep | `LadderApp/Services/Data/` |

---

### 4f. Services/Legacy/Legal/
*1 file.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `LegalTexts.swift` | **PROMOTE** | Long but self-contained string constants; company info needs updating when legal entity finalises | `LadderApp/Services/Legal/` |

---

### 4g. Services/Legacy/Networking/
*2 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `AWSManager.swift` | **DELETE** | Entirely stub/TODO; AWS stack is superseded by Supabase per project memory hard rule | — |
| `SupabaseManager.swift` | **DELETE** | Commented-out placeholder; active `SupabaseAuthService` uses the real `SupabaseClient` from SPM | — |

---

### 4h. Services/Legacy/Notifications/
*2 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `PushNotificationManager.swift` | **PROMOTE** | Clean `UNUserNotificationCenter` wrapper; no auth dep | `LadderApp/Services/Notifications/` |
| `LocalNotificationManager.swift` | **PROMOTE** | Schedules SAT/FAFSA reminders; depends on `PushNotificationManager` — promote together | `LadderApp/Services/Notifications/` |

---

### 4i. Services/Legacy/Storage/
*2 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `S3StorageManager.swift` | **DELETE** | Pure AWS S3 stub with `fatalError` placeholders; all storage must go through Supabase Storage | — |
| `ImageCDNManager.swift` | **PROMOTE_WITH_REWRITES** | URL builder concept is valid; change `cdnBase` to Supabase Storage bucket URL from `AppConfiguration` | `LadderApp/Services/Storage/` |

---

### 4j. Services/Legacy/Sync/
*5 files.*

| File | Classification | Reason | Target |
|------|---------------|--------|--------|
| `NetworkMonitor.swift` | **PROMOTE** | NWPathMonitor wrapper, clean `@Observable`; no AWS dep | `LadderApp/Services/Sync/` |
| `OfflineQueueManager.swift` | **PROMOTE** | Generic offline mutation queue using UserDefaults/Codable; no AWS dep | `LadderApp/Services/Sync/` |
| `SyncManager.swift` | **REWRITE** | Comment body is "TODO: Use AppSyncManager" — concept of push/pull sync is wanted but must be implemented against Supabase Realtime, not AppSync | — |
| `AppSyncManager.swift` | **DELETE** | Pure AWS AppSync stub; `fatalError` on all methods | — |
| `ConflictResolver.swift` | **REWRITE** | Strategy enum is correct; `resolve()` stores `Any` typed values — needs typed Supabase model variants before it can be used | — |

---

## 5. Stale Collisions to Watch

These are the specific type-name or environment-key conflicts that will break compilation the moment Legacy files are un-quarantined without being updated first.

| Collision | Legacy type | Active type | Risk |
|-----------|-------------|-------------|------|
| **CRITICAL: `AuthManager`** | `Services/Legacy/Auth/AuthManager.swift` — `final class AuthManager` with `.environment(AuthManager.self)` injected in ~8+ Legacy views | No active `AuthManager` class; active stack uses `SupabaseAuthService` actor + `AppCoordinator`. Any Legacy view that calls `@Environment(AuthManager.self)` will crash with "No value of type AuthManager found in the environment" | Every `PROMOTE_WITH_REWRITES` in AuthViews, Onboarding, CounselorViews, Settings must have the `AuthManager` env ref swapped before the PR merges. |
| **CRITICAL: `CareerQuizView` / `CareerQuizViewModel`** | `Features/Legacy/OldDuplicates/CareerQuizView_Shared.swift` defines `struct CareerQuizView` and `Features/Legacy/Career/ViewModels/CareerQuizViewModel.swift` defines `final class CareerQuizViewModel` | Active `Features/Student/CareerQuiz/CareerQuizView.swift` defines both `public struct CareerQuizView` and `final class CareerQuizViewModel` | **Duplicate type names = compile error.** `CareerQuizView_Shared.swift` is already marked DELETE; `Legacy/Career/ViewModels/CareerQuizViewModel.swift` must be renamed (e.g. `RIASECQuizViewModel`) before promotion. |
| **`CounselorDashboardView`** | `Features/Legacy/OldDuplicates/CounselorDashboardView_Old.swift` defines `struct CounselorDashboardView` | `Features/Counselor/Dashboard/CounselorDashboardView.swift` defines `public struct CounselorDashboardView` | Already in OldDuplicates → DELETE. Safe only if that file is never un-quarantined. |
| **`ParentDashboardView`** | `Features/Legacy/OldDuplicates/ParentDashboardView_Old.swift` defines `struct ParentDashboardView` | `Features/Parent/ParentDashboardView.swift` defines `public struct ParentDashboardView` | Same as above; DELETE resolves it. |
| **`AuthState` (nested)** | `AuthManager.AuthState` enum with cases `.loading/.unauthenticated/.onboarding/.authenticated` | `AppCoordinator.AuthState` with identical case names | Not a Swift compile error (different namespaces) but any code that references bare `AuthState` without namespace qualification will be ambiguous. Watch any Legacy views referencing `authManager.authState`. |
| **`SwiftDataContainer` / `LadderSchemaV1`** | `Services/Legacy/Data/SwiftDataContainer.swift` defines `LadderSchemaV1` with 24 `@Model` types | Active `LadderApp.swift` does NOT yet use a versioned schema. Promoting `SwiftDataContainer` without simultaneously adopting `LadderSchemaV1` in the app entry point = two schema definitions in the same build | Merge task: adopt `LadderSchemaV1` as the active schema before any model from Legacy is compiled into the build. |
| **`AuditLogEntry` (`@Model`)** | `Services/Legacy/Audit/AuditLogger.swift` defines `@Model final class AuditLogEntry` | `Services/Legacy/Data/SwiftDataContainer.swift` includes `AuditLogEntry.self` in schema, but the active build does not currently have this model compiled in | Once un-quarantined this `@Model` must land simultaneously with the `LadderSchemaV1` adoption or it will be an orphan. |

---

## 6. Recommended Promotion Order — 7 Batches

**Batch 1 — Engines (no PR collision risk)**
Promote: `Services/Legacy/Engines/` (all 5 pure engines + `CollegeLogoService`), `Features/Legacy/Career/Services/RIASECEngine.swift`.
Delete: nothing in this batch.
Blocker: none.

**Batch 2 — SwiftData Schema + Core Models**
Adopt `LadderSchemaV1` from `SwiftDataContainer.swift` into `LadderApp.swift`. Promote all `@Model` files from `Applications/Models/`, `Writing/Models/`, `Career/Models/`, `Shared/Models/`, `Financial/Models/`, `CollegeIntelligence/Models/`, `CounselorModels/`, `AdminModels/`, `AIAdvisor/Models/`, `Services/Legacy/Audit/AuditLogger.swift` (model only).
Delete: old `Services/Legacy/Networking/SupabaseManager.swift`, `Services/Legacy/Networking/AWSManager.swift`, `Services/Legacy/Storage/S3StorageManager.swift`, `Services/Legacy/Sync/AppSyncManager.swift`, `Services/Legacy/AI/AIService.swift`, `Services/Legacy/AI/AIRateLimiter.swift`.
Blocker: must land before any feature batch compiles.

**Batch 3 — AI Services + Sia Stack**
Promote: all `Services/Legacy/AI/Context/*`, `NudgeRules`, `HandoffRouter`, `MemoryExtractorService` (swap `AIService` → `AIGatewayClient`), `PromptBuilder`, `SessionType`, `SpecialistPromptLoader`, `SpecialistPrompts`, `SiaEngine` (swap `AIService` → `AIGatewayClient`).
Promote: `Services/Legacy/Notifications/*`, `Services/Legacy/Calendar/CalendarManager.swift`, `Services/Legacy/Data/*` (seeder/merger/parsers), `Services/Legacy/Legal/LegalTexts.swift`.
Promote: `Services/Legacy/Sync/NetworkMonitor.swift`, `Services/Legacy/Sync/OfflineQueueManager.swift`.
Delete: `Services/Legacy/AI/AIResponseCache.swift` (queue for Batch 7 rewrite).
Blocker: Batch 2 must be merged.

**Batch 4 — Student Surface: Career + CollegeIntelligence + Academic**
Promote: all `Features/Legacy/Career/` (rename `CareerQuizViewModel` → `RIASECQuizViewModel`, rename `AdaptiveCareerQuizView` → `RIASECQuizView`), all `Features/Legacy/CollegeIntelligence/`, all `Features/Legacy/Academic/`.
Promote: `Services/Legacy/Auth/InviteCodeManager.swift`, `SchoolCodeManager.swift`, `StudentAutoIDGenerator.swift`.
Delete: `Features/Legacy/OldDuplicates/CareerQuizView_Shared.swift`.
Blocker: Batch 3.

**Batch 5 — Student Surface: Dashboard + Checklists + Shared + Writing + Financial + Reports + Housing + PostAcceptance**
Promote: `Features/Legacy/Dashboard/*`, `Checklists/*`, `Shared/*`, `Writing/*`, `Financial/*`, `Reports/*`, `Housing/*`, `StudentViews/*`, `StudentViewModels/*`, `ParentViewsOld/PeerComparisonView.swift`.
Auth-swap files: `Shared/Views/ProfileView.swift`, `Settings/Views/ProfileSettingsView.swift`, `Settings/Views/DataDeletionView.swift`.
Blocker: Batch 4.

**Batch 6 — Counselor + Admin Surfaces**
Promote: all `CounselorViews/*`, `CounselorViewModels/*`, `CounselorServices/*`, `AdminViews/*`.
Auth-swap files: `CounselorViews/CaseloadManagerView.swift`, `CounselorViewModels/CaseloadManagerViewModel.swift`, `AdminViews/SchoolAdminDashboardView.swift`.
Delete: `OldDuplicates/CounselorDashboardView_Old.swift`, `OldDuplicates/ParentDashboardView_Old.swift`.
Blocker: Batch 2 (models).

**Batch 7 — Auth/Onboarding Views + Parent ChildSwitcher + Rewrites**
Promote-with-rewrites: all `AuthViews/` except `LoginView.swift` (delete that), `Onboarding/*`, `ParentViewsOld/ChildSwitcherView.swift`, `Settings/Views/ProfileSettingsView.swift` if not done in Batch 5.
Delete: `AuthViews/LoginView.swift`.
Rewrites: `SyncManager.swift` (Supabase Realtime), `ConflictResolver.swift` (typed), `AIResponseCache.swift`.
Blocker: Batch 3 (for `SupabaseAuthService` API surface to be known).

---

## Final Report

**Total file count by subfolder:**
- `Features/Legacy/AIAdvisor/` — 11 files
- `Features/Legacy/Academic/` — 6 files (listed 10 above incl. all views)
- `Features/Legacy/AdminModels/` — 1, `AdminViews/` — 6
- `Features/Legacy/Applications/` — 6 (listed 8 above incl. all views)
- `Features/Legacy/AuthViews/` — 9
- `Features/Legacy/Career/` — 8
- `Features/Legacy/Checklists/` — 3
- `Features/Legacy/CollegeIntelligence/` — 24
- `Features/Legacy/CounselorModels/` — 1, `CounselorServices/` — 1, `CounselorViewModels/` — 1, `CounselorViews/` — 13
- `Features/Legacy/Dashboard/` — 3
- `Features/Legacy/Financial/` — 5 (listed 7)
- `Features/Legacy/Housing/` — 1
- `Features/Legacy/OldDuplicates/` — 3
- `Features/Legacy/Onboarding/` — 2
- `Features/Legacy/ParentViewsOld/` — 2
- `Features/Legacy/Reports/` — 6
- `Features/Legacy/Settings/` — 5
- `Features/Legacy/Shared/` — 23
- `Features/Legacy/StudentViewModels/` — 1, `StudentViews/` — 2
- `Features/Legacy/Writing/` — 5
- `Services/Legacy/AI/` — 18
- `Services/Legacy/Audit/` — 1
- `Services/Legacy/Auth/` — 4
- `Services/Legacy/Calendar/` — 1
- `Services/Legacy/Data/` — 6
- `Services/Legacy/Engines/` — 7
- `Services/Legacy/Legal/` — 1
- `Services/Legacy/Networking/` — 2
- `Services/Legacy/Notifications/` — 2
- `Services/Legacy/Storage/` — 2
- `Services/Legacy/Sync/` — 5

**5-7 batch order:** Engines → Schema + Core Models → AI/Sia Stack + Services → Student Features (Career/College/Academic) → Student Features (Dashboard/Shared/Writing/Financial) → Counselor/Admin Surfaces → Auth/Onboarding Views + Rewrites.

**Single biggest collision risk:** `AuthManager`. Approximately 8 Legacy views inject it via `.environment(AuthManager.self)`. The type does not exist in the active build. Every file touching it must have the auth ref swapped to `SupabaseAuthService`/`AppCoordinator` before it crosses the exclude boundary — otherwise the build fails immediately. The secondary risk is `CareerQuizView` + `CareerQuizViewModel` name duplication with active files; those require a rename in the same PR they are promoted.

**Unclassified / unclear:** `Services/Legacy/Data/SwiftDataContainer.swift` — classified as `MERGE_INTO` but the exact migration stage code (the `LadderMigrationPlan`) inside the file was not fully read. The schema model list is clear; the migration closures need a second pass to confirm they are no-ops for new installs vs upgrade paths from any TestFlight builds.
