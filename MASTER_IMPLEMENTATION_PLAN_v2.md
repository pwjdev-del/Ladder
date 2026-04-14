# Ladder — Master Implementation Plan v3
## 80+ Features + 27 Problems + AWS Architecture + Parallel Module System

**Current state**: 107 Swift files, 65 features built, 6,322 colleges
**Target**: 145+ total features, ~120 new/modified files, school/district B2B ready
**Backend**: AWS (Cognito + RDS PostgreSQL + Lambda + AppSync + S3 + CloudFront)

---

## AWS ARCHITECTURE (Replacing Supabase)

Since we're using AWS instead of Supabase, here's the full mapping:

| Component | AWS Service | Purpose |
|-----------|------------|---------|
| **Authentication** | **AWS Cognito** | User pools, social sign-in (Apple/Google), MFA, role claims in JWT tokens, HIPAA-eligible |
| **Database** | **Amazon RDS (PostgreSQL)** | Relational data — same SQL schemas, views, and queries work directly |
| **Real-time Sync** | **AWS AppSync** (GraphQL) | Subscriptions for counselor↔student live updates, built-in offline sync + conflict resolution |
| **Serverless Functions** | **AWS Lambda** | AI proxy (Gemini), data processing, scheduled jobs (school year rollover, push notifications) |
| **File Storage** | **Amazon S3** + **CloudFront CDN** | College photos, counselor profile pics, PDF exports, transcript uploads |
| **Push Notifications** | **Amazon SNS** + **APNs** | Server-side push for school-wide announcements |
| **Content Moderation** | **AWS Comprehend** | Text filtering in messaging (block explicit content, flag concerning keywords) |
| **Search** | **Amazon OpenSearch** (future) | Full-text search across 6,322 colleges (optional upgrade from local SwiftData predicates) |
| **Monitoring** | **CloudWatch** | API usage, Lambda errors, cost tracking |

### AWS-Specific Files to Create
- `Core/Networking/AWSManager.swift` — Cognito client, AppSync client, S3 client (replaces SupabaseManager)
- `Core/Auth/CognitoAuthManager.swift` — Sign in, sign up, role claims, token refresh
- `Core/Sync/AppSyncManager.swift` — GraphQL mutations/queries/subscriptions
- `Core/Sync/OfflineQueueManager.swift` — AppSync offline mutation queue
- `Core/Storage/S3StorageManager.swift` — Upload/download files, presigned URLs
- `Core/Notifications/SNSPushManager.swift` — Remote push via SNS topics

### AWS SDK Setup
- Add `aws-sdk-swift` SPM package (or `Amplify` for higher-level API)
- `AppConfiguration.swift` — AWS region, Cognito pool ID, AppSync endpoint, S3 bucket name
- Lambda functions deployed separately (Node.js or Python)

---

## ALL 27 PROBLEMS TO SOLVE

### CATEGORY A: Core Architecture (8 original problems)

---

### Problem 1: Multi-Role Auth System
**The issue**: App has ONE user type (student). Need 4: Student, Parent, Counselor, School Admin — each with different login flows, home screens, and permissions.

**Solution — AWS Cognito Role-Based Auth**:
```
Cognito User Pool setup:
- Custom attribute: `custom:role` = student | parent | counselor | school_admin
- Custom attribute: `custom:school_id` = UUID (for B2B users)
- Cognito Groups: Students, Parents, Counselors, SchoolAdmins
- Group membership controls API access via Lambda authorizers

App-side:
- Login screen → role selector: "I am a..." (Student / Parent / Counselor / School Admin)
- After login, JWT token contains role claim → determines which TabView loads
- StudentTabView (5 tabs: Home, Tasks, Colleges, Advisor, Profile)
- ParentTabView (3 tabs: Overview, Finances, Settings) — read-only
- CounselorTabView (4 tabs: Caseload, Classes, Students, Profile)
- AdminTabView (3 tabs: Dashboard, Schools, Reports)
```

**Files**: Modify `AuthManager.swift`, `AppCoordinator.swift`, `LoginView.swift`, `LadderApp.swift`. Create `ParentTabView.swift`, `CounselorTabView.swift`, `AdminTabView.swift`

---

### Problem 2: Parent ↔ Student Linking
**The issue**: Parent needs to see child's data. FERPA requires explicit consent. Can't share credentials.

**Solution — Invite Code System**:
```
1. Student → Settings → "Parent Access" → "Generate Code"
2. 6-digit code stored in RDS (expires 48 hours)
3. Parent downloads Ladder → "I am a Parent" → enters code
4. Cognito creates parent account, RDS links parent_id to student_id
5. Parent sees read-only ParentTabView
6. Student can revoke anytime
7. SUPPORTS MULTIPLE CHILDREN: parent enters multiple codes, gets child-switcher
```

**RDS Table**: `parent_links` (id, student_id, parent_id, invite_code, status, created_at, expires_at)
**Files**: `InviteCodeManager.swift`, `ParentAccessView.swift`, `ParentOnboardingView.swift`, `ChildSwitcherView.swift`

---

### Problem 3: Counselor ↔ School ↔ Student Linking + Auto-ID System
**The issue**: How does a counselor see their students? Schools need onboarding, counselors need linking, and NEW students need accounts.

**Solution — School Onboarding + Auto-ID Generation**:
```
School Setup:
1. School admin signs up → creates School profile (name, district, NCES ID)
2. Admin generates "School Code" (e.g., "PNCV-2026") → shared with counselors
3. Counselors sign up → enter School Code → linked to school

Student Auto-ID System (THE KEY B2B FEATURE):
- When new students arrive (8th → 9th grade transition, or mid-year transfers):
  1. Counselor uploads CSV with columns: First Name, Last Name, Date of Birth, Grade
  2. System auto-generates credentials for EACH student:
     - Login ID: first initial + last name + birth month + birth day
       Example: John Smith, born April 15 → "jsmith0415"
     - Password: first name (lowercase) + birth year last 2 digits + "!"
       Example: John Smith, born 2010 → "john10!"
  3. If duplicate login ID (two "jsmith0415"), append incrementing number: "jsmith0415-2"
  4. System creates Cognito account for each student
  5. Counselor prints credential cards (PDF) to hand out
  6. Student logs in → FORCED password change on first login
  7. Student completes onboarding flow (already built)

- Counselor can also add students ONE BY ONE:
  1. "Add Student" → enter name + DOB + grade
  2. Auto-generates credentials
  3. Shows credential card on screen

- Every August (school year rollover):
  1. Counselor clicks "Add New Class" → uploads incoming 9th graders CSV
  2. All accounts generated in bulk
  3. Existing students auto-promoted (9th→10th, etc.)
  4. Graduated 12th graders archived (not deleted — FERPA)
```

**RDS Tables**:
```sql
schools (id, name, district_name, nces_id, school_code, admin_user_id, created_at)
school_counselors (school_id, counselor_user_id, caseload_limit)
school_students (school_id, student_user_id, counselor_id, grade, login_id, is_first_login, enrolled_at)
```

**Files**:
- `Core/Auth/SchoolCodeManager.swift` — generate/validate school codes
- `Core/Auth/StudentAutoIDGenerator.swift` — generate login IDs + passwords from name+DOB
- `Features/Counselor/Views/BulkStudentImportView.swift` — CSV upload, preview generated IDs, confirm
- `Features/Counselor/Views/AddStudentView.swift` — single student add
- `Features/Counselor/Views/StudentCredentialCardView.swift` — printable card with login info
- `Features/Auth/Views/ForcePasswordChangeView.swift` — first-login password change
- `Features/Auth/Views/SchoolAdminOnboardingView.swift`
- `Features/Auth/Views/CounselorOnboardingView.swift`

**Stitch design needed**: `bulk_student_import` — CSV upload screen with preview table of generated IDs, "Generate All" button, "Print Cards" button

---

### Problem 4: Data Sync Between Student ↔ Counselor
**The issue**: Student updates GPA → counselor needs to see it. Counselor approves class schedule → student needs to see it. Real-time sync needed.

**Solution — AWS AppSync + Local SwiftData Cache**:
```
Architecture:
- SwiftData = local cache (offline-first, instant UI updates)
- RDS PostgreSQL = source of truth
- AppSync = GraphQL API + real-time subscriptions

Sync strategy:
1. Student writes to SwiftData locally → immediate UI update
2. AppSync mutation pushes change to RDS (background)
3. Counselor's app subscribes to AppSync for their students' changes
4. When change arrives → counselor's SwiftData cache updates
5. Offline: AppSync queues mutations locally, replays on reconnect
6. Conflict resolution: AppSync "auto-merge" for profiles, "custom Lambda" for class schedules
```

**Files**: `Core/Sync/SyncManager.swift`, `Core/Sync/AppSyncManager.swift`, `Core/Sync/OfflineQueueManager.swift`

---

### Problem 5: AI Class Schedule Suggestions
**The issue**: Students need to pick classes each semester. They don't know what to take. Counselors can't individually advise 250+ students on class selection. Need AI to handle the heavy lifting.

**Solution — AI Class Schedule Engine**:
```
Student Side:
1. Student opens "Class Planner" → sees their completed courses
2. AI considers:
   - Grade level (9/10/11/12)
   - Career interest (from RIASEC quiz)
   - Graduation requirements (FL 24-credit requirement)
   - Bright Futures requirements (if FL resident)
   - College admissions suggestions (AP classes that target colleges want)
   - Prerequisites met/not met
   - Course difficulty balance (don't take 5 APs simultaneously)
   - Student's GPA trend (struggling? suggest fewer APs)
3. AI generates: "Recommended Schedule for Fall 2026"
   - Period 1: AP English Literature (needed for UF, prereq met ✓)
   - Period 2: AP Calculus BC (prereq: Calc AB ✓, career: engineering)
   - Period 3: Spanish 3 (2 years foreign language for FL grad req)
   - Period 4: AP Physics 1 (career: engineering, first AP science)
   - Period 5: US History (graduation requirement)
   - Period 6: Elective: Robotics Club (career alignment)
   - Period 7: Study Hall (balance — 3 APs is enough)
4. Student can swap courses, see alternatives, get explanations
5. Student submits preferences → goes to counselor for approval

Counselor Side:
1. Sees list of students who submitted class preferences
2. AI pre-flags conflicts:
   - Period conflicts (two classes same period)
   - Prerequisite issues (AP Calc BC without AB)
   - Capacity problems (class full)
   - Balance warnings (too many APs for this student's GPA)
3. One-click approve or "Request Changes" with note
4. Bulk approve: "Approve all no-conflict schedules" for efficiency

School Admin Side:
1. Upload school's class catalog (CSV: class name, period, teacher, capacity, prerequisites)
2. Updated each semester
3. AI uses this catalog to only suggest available classes
```

**RDS Tables**:
```sql
class_catalogs (id, school_id, class_name, period, teacher, capacity, current_enrollment, prerequisites, is_ap, is_honors, subject_area, semester)
class_preferences (id, student_id, school_id, semester, period, class_id, is_ai_suggested, status)
class_approvals (id, preference_id, counselor_id, status, notes, reviewed_at)
```

**Files**:
- `Features/Academic/Views/AIClassPlannerView.swift` — student sees AI recommendations
- `Features/Academic/ViewModels/AIClassPlannerViewModel.swift` — calls AI, loads prereqs, generates schedule
- `Features/Academic/Services/ClassScheduleAIEngine.swift` — the AI logic (prereq checker + Gemini call)
- `Features/Counselor/Views/ClassApprovalListView.swift` — counselor sees all pending approvals
- `Features/Counselor/Views/ClassApprovalDetailView.swift` — individual student schedule review
- `Features/Admin/Views/ClassCatalogUploadView.swift` — admin uploads class catalog CSV
- `Features/Shared/Views/ClassPreferenceView.swift` — student submits final preferences

**Stitch designs needed**:
- `ai_class_planner_student` — AI-recommended schedule with swap/explain buttons, period grid
- `class_approval_counselor` — list of students with pending schedules, conflict badges, bulk approve

---

### Problem 6: District-Level Data Aggregation
**The issue**: District admin needs aggregate data across 10-20 schools. Can't query each school separately.

**Solution — RDS Views + Lambda Aggregation**:
```sql
CREATE VIEW district_metrics AS
SELECT 
  s.district_name,
  COUNT(DISTINCT st.student_user_id) as total_students,
  AVG(sp.gpa) as avg_gpa,
  COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) as total_acceptances,
  SUM(f.scholarship_aid + f.grant_aid) as total_aid
FROM schools s
JOIN school_students st ON s.id = st.school_id
JOIN student_profiles sp ON st.student_user_id = sp.user_id
LEFT JOIN applications a ON sp.user_id = a.user_id
LEFT JOIN financial_aid_packages f ON a.id = f.application_id
GROUP BY s.district_name;
```

**Files**: `Core/Services/DistrictDataService.swift`

---

### Problem 7: Freelance Counselor Verification
**The issue**: Random people can't sign up as counselors and access student data.

**Solution**: Counselor signs up → enters credentials (license #, school affiliation) → "pending" state → manual review → verified badge. School counselors auto-verified via School Code.

**Files**: `Features/Counselor/Views/CounselorVerificationView.swift`, modify `CounselorModels.swift`

---

### Problem 8: FERPA Compliance for School Data
**The issue**: Student data protected by FERPA when schools use Ladder.

**Solution**: DPA signed during school onboarding. Data encrypted at rest (RDS encryption). Student data never shared between schools. Audit log of all counselor access. Data retention: auto-archive 2 years after graduation. Parent/student can request deletion.

**Files**: `DPAConsentView.swift`, `AuditLogger.swift`, `DataDeletionView.swift`

---

### CATEGORY B: Data & Sync Problems (5 problems)

---

### Problem 9: Offline-First Architecture
**The issue**: Students in rural schools have bad WiFi. App MUST work without internet. But once AWS sync is added, what happens when student submits data offline, then reconnects hours later?

**Solution**: AppSync has built-in offline support. Mutations queue locally and replay on reconnect. Use "auto-merge" for non-critical data (profile updates), "custom Lambda resolver" for critical data (class schedules, applications). SwiftData remains the local cache — user never sees a loading spinner for their own data.

**Files**: `Core/Sync/OfflineQueueManager.swift`, `Core/Sync/ConflictResolver.swift`

---

### Problem 10: SwiftData Schema Migration
**The issue**: 15 @Model classes. Any field change = existing users' databases break on app update. NO VersionedSchema exists yet. First App Store update = crash.

**Solution**: Implement `VersionedSchema` immediately in Sprint 0. Create `SchemaV1` with all current 15 models frozen. Every future sprint that modifies models creates SchemaV2, V3, etc. with `MigrationPlan`.

**Files**: `Core/Data/SchemaVersions/SchemaV1.swift`, `Core/Data/LadderMigrationPlan.swift`, modify `SwiftDataContainer.swift`

---

### Problem 11: Multi-Student Parent
**The issue**: A parent may have 2-3 kids at the same school. Current invite code system only handles 1:1.

**Solution**: `parent_links` table supports multiple rows per parent_id. Parent enters one code per child. Parent dashboard gets a "child switcher" (like Gmail account switching). Each child's data loads independently.

**Files**: `Features/Parent/Views/ChildSwitcherView.swift`, modify `ParentTabView.swift`

---

### Problem 12: School Year Rollover
**The issue**: Every August — 12th graders graduate, grades shift up, new 9th graders arrive, counselor assignments change, checklists reset.

**Solution**: Lambda cron job runs August 1:
1. Auto-promote all grades (9→10, 10→11, 11→12)
2. Archive graduated 12th graders (set `archived = true`, don't delete — FERPA)
3. Reset grade-specific roadmap milestones
4. Notify counselors: "Upload new 9th graders" (Auto-ID system from Problem 3)
5. Student sees "Welcome to 11th Grade!" dashboard splash on next login

**Files**: Lambda function, `Core/Services/SchoolYearRolloverService.swift`, modify `DashboardView.swift`

---

### Problem 13: Data Export / Portability
**The issue**: If school cancels, FERPA says parents can request all data. Students switching schools need data transfer.

**Solution**: Lambda generates JSON/PDF export of all student data. Settings → "Export My Data". School admin can bulk-export. 30-day grace period after cancellation.

**Files**: `Features/Settings/Views/DataExportView.swift`, Lambda export function

---

### CATEGORY C: Scale & Performance Problems (4 problems)

---

### Problem 14: AI Cost at School Scale
**The issue**: One school = 2,000 students using AI advisor, mock interviews, essay review. Gemini API costs could be $500+/month per school.

**Solution**:
- Cache common responses ("Tell me about UF" asked 500 times → cache it)
- Rate limit: 20 AI requests/day free tier, 50 for school tier
- Batch essay reviews (cheaper bulk API pricing)
- Tiered AI: simple questions → local rule engine (zero cost), complex → Gemini
- Pre-generate college personality profiles at seeding time

**Files**: `Core/AI/AIRateLimiter.swift`, `Core/AI/AIResponseCache.swift`, modify `AIService.swift`

---

### Problem 15: Counselor Caseload Performance
**The issue**: Loading 250-500 student profiles + real-time updates = performance nightmare.

**Solution**:
- Pagination: 20 students at a time, sorted by urgency
- Lazy subscriptions: only subscribe to students currently on screen
- Summary cache: Lambda pre-computes stats hourly (on-track count, alert count)

**Files**: `Features/Counselor/Services/CaseloadPaginationService.swift`

---

### Problem 16: Performance with 6,322 Colleges
**The issue**: Search/filter/sort on 6K+ items with SwiftData predicates could lag.

**Solution**: Add `@Attribute(.index)` to frequently queried fields (name, state, acceptanceRate). Debounced search (300ms). Pre-computed search tokens.

**Files**: Modify `CollegeModels.swift`, modify `CollegeDiscoveryViewModel.swift`

---

### Problem 17: Image/Asset Management
**The issue**: College logos, campus photos, counselor pics. 6,322 colleges × photos = lots of images.

**Solution**: S3 bucket + CloudFront CDN. URL pattern: `cdn.ladderapp.com/colleges/{id}/logo.jpg`. AsyncImage with cache. Fallback to deterministic gradient (already built).

**Files**: `Core/Services/ImageCDNManager.swift`, modify `CollegeProfileView.swift`

---

### CATEGORY D: Compliance & Legal Problems (4 problems)

---

### Problem 18: COPPA Compliance (Under-13)
**The issue**: Some 9th graders could be under 13. COPPA requires verifiable parental consent.

**Solution**: Age gate during onboarding. Under 13 → require parent email for consent. Parent gets verification email. AI features locked until parent consents.

**Files**: `Features/Auth/Views/AgeGateView.swift`, modify `OnboardingContainerView.swift`

---

### Problem 19: Accessibility / ADA Section 508
**The issue**: Selling to public schools requires ADA compliance. VoiceOver, Dynamic Type, color contrast (4.5:1 minimum).

**Solution**: Audit all views for `.accessibilityLabel()`, `.dynamicTypeSize()` support, color contrast. Fix `outline` color (#737970) on `surface` (#fff8f2) which is 4.3:1 — fails WCAG AA for small text.

**Files**: Accessibility pass across all views, `LadderColors.swift` contrast fixes

---

### Problem 20: Multi-Language Support
**The issue**: Florida schools have large Spanish-speaking populations. "Is this in Spanish?" will be asked before buying.

**Solution**: Phase 1 — use `LocalizedStringKey` everywhere (prep). Phase 2 — Spanish. Phase 3 — Haitian Creole.

**Files**: `Localizable.xcstrings`, modify views to use `String(localized:)`

---

### Problem 21: Content Moderation in Messaging
**The issue**: Messaging between students and counselors needs moderation. Schools are legally liable for unmoderated communication tools.

**Solution**: AWS Comprehend for text filtering on send. Report button on every message. Admin can view reported conversations. Auto-flag concerning keywords (self-harm, threats).

**Files**: `Core/Services/ContentModerationService.swift`, modify `MessagingView.swift`

---

### CATEGORY E: Distribution & Business Problems (4 problems)

---

### Problem 22: App Distribution to Schools (MDM)
**The issue**: School IT uses MDM (Jamf, Mosyle). Need Apple Business Manager + Volume Purchase Program compatibility.

**Solution**: Register for Apple Business Manager. Enable volume purchase. Provide MDM config profile. Future: web portal alternative for schools that block app installs.

**Action items**: Business/ops setup, not code. Documentation for sales team.

---

### Problem 23: Pricing Model / Feature Gating
**The issue**: Free students vs paid school accounts. App needs to know what features to show per subscription tier.

**Solution**: Cognito JWT includes `custom:tier` claim (free, school_basic, school_premium).
- **Free**: Core college search, basic checklist, 5 AI requests/day
- **School Basic**: All student features, counselor dashboard, class scheduling, auto-ID
- **School Premium**: District analytics, unlimited AI, PDF exports, parent portal

**Files**: `Core/Services/FeatureGateManager.swift`, modify views to check gates

---

### Problem 24: Testing / QA (Zero Tests)
**The issue**: 130+ features with ZERO test files. One bad merge = app-breaking bug.

**Solution**: Unit tests for parsers (Perplexity, Scorecard, Merger). Integration tests for auth + sync. UI tests for onboarding and college search. GitHub Actions CI on every PR.

**Files**: `LadderTests/` directory, `LadderUITests/`, GitHub Actions workflow

---

### Problem 25: Server-Side Push Notifications
**The issue**: Local notifications work for individuals. School-wide announcements ("FAFSA Night Thursday") need server-side push.

**Solution**: AWS SNS → APNs. Topic-based: subscribe students to school topic. Counselor/admin sends announcement → Lambda → SNS → all devices.

**Files**: `Core/Notifications/SNSPushManager.swift`, Lambda push function

---

### CATEGORY F: UX & Product Problems (2 problems)

---

### Problem 26: Information Overload
**The issue**: 145+ features. A 9th grader doesn't need LOCI generators or housing timelines. Showing everything = overwhelming = uninstall.

**Solution — Grade-Based Progressive Disclosure**:
- **9th**: Career quiz, class recommendations, activity suggestions, GPA tracker
- **10th**: + SAT prep, college discovery, Bright Futures tracker
- **11th**: + Applications, essays, mock interviews, AP credits, financial aid
- **12th**: + Decision portal, enrollment checklist, housing, LOCI, roommate

**Files**: `Core/Services/GradeFeatureManager.swift`, modify tab views

---

### Problem 27: Counselor Adoption — Don't Add Work, Remove It
**The issue**: Counselors are overworked (250:1). If Ladder adds MORE tasks, they won't use it.

**Solution**:
- Counselor deadline view shows GENERIC college deadlines ("UF: Nov 1", "FSU: Jan 15") NOT per-student deadlines — they already have too much on their plate
- AI pre-screens and prioritizes: "3 students need attention today" not "here's 250 students"
- One-click approve workflows (class schedules, recommendations)
- Auto-generate reports (no manual data entry)
- Bulk actions: "Approve all no-conflict schedules"
- Auto-ID system eliminates manual account creation

**Files**: Modify `CounselorDashboardView.swift`, create `GenericDeadlineCalendarView.swift`

---

## PARALLEL MODULE SYSTEM

Everything is divided into **10 independent modules**. Each module can be worked on by a **separate agent** simultaneously. Modules are designed so their files DON'T OVERLAP.

```
MODULE A ─── Auth & Identity ──────────── MUST DO FIRST (all others depend on this)
    │
    ├── MODULE B ─── Student Core Tools ──────── } 
    ├── MODULE C ─── College Intelligence 2.0 ── }
    ├── MODULE D ─── Academic Planning + AI ──── } Can ALL run in
    ├── MODULE E ─── Notifications & Seasons ──── } PARALLEL after
    ├── MODULE F ─── Infrastructure & Safety ──── } Module A
    │                                              }
    ├── MODULE G ─── B2B Counselor Platform ───── Needs Module A + F
    ├── MODULE H ─── B2B School Admin ─────────── Needs Module A + G
    │
    ├── MODULE I ─── Parent & Community ────────── Needs Module A
    └── MODULE J ─── Reports & Export ─────────── Needs Modules B-D
```

---

### MODULE A: Auth & Identity (MUST DO FIRST — Solo Agent)
*Everything else depends on this. 1 agent, no parallelism.*

| Task | Files | Solves |
|------|-------|--------|
| AWS Cognito setup + role-based auth | `AWSManager.swift`, `CognitoAuthManager.swift`, modify `AuthManager.swift` | Problem 1 |
| Role selector on login | Modify `LoginView.swift` | Problem 1 |
| Student/Parent/Counselor/Admin tab views | `ParentTabView.swift`, `CounselorTabView.swift`, `AdminTabView.swift` | Problem 1 |
| Parent invite code system | `InviteCodeManager.swift`, `ParentAccessView.swift`, `ParentOnboardingView.swift` | Problem 2 |
| Child switcher for multi-student parents | `ChildSwitcherView.swift` | Problem 11 |
| School code system | `SchoolCodeManager.swift`, `SchoolAdminOnboardingView.swift`, `CounselorOnboardingView.swift` | Problem 3 |
| Student Auto-ID generator | `StudentAutoIDGenerator.swift`, `ForcePasswordChangeView.swift` | Problem 3 |
| FERPA consent + DPA | `DPAConsentView.swift`, `AuditLogger.swift` | Problem 8 |
| COPPA age gate | `AgeGateView.swift` | Problem 18 |
| SwiftData VersionedSchema | `SchemaV1.swift`, `LadderMigrationPlan.swift` | Problem 10 |
| Feature gate manager | `FeatureGateManager.swift` | Problem 23 |
| App route to correct TabView | Modify `LadderApp.swift`, `AppCoordinator.swift` | Problem 1 |

**New files: ~18 | Modified: ~6 | Total: ~24**

---

### MODULE B: Student Core Tools (Agent 2)
*Student-facing features. No B2B dependency.*

| Feature | Files | Stitch |
|---------|-------|--------|
| B1. Adaptive Career Quiz (3-stage RIASEC) | `AdaptiveCareerQuizView.swift`, `RIASECEngine.swift`, `CareerQuizViewModel.swift` | existing |
| B2. Per-Semester GPA Tracking | `GPATrackerView.swift`, `GPATrackerViewModel.swift`, `GPAEntryModel.swift` | ✅ gpa_tracker |
| B3. Supplemental Essay Tracker | `EssayTrackerView.swift`, `EssayTrackerViewModel.swift`, `EssayModel.swift` | N/A |
| B4. Weekly "3 Things To Do" Widget | `WeeklyWidgetView.swift`, modify `DashboardView.swift` | N/A |
| B5. FERPA/COPPA Consent Flow | `ConsentFlowView.swift`, modify `OnboardingContainerView.swift` | N/A |
| B6. Grade-Based Feature Disclosure | `GradeFeatureManager.swift` | N/A |

**New files: ~12 | Modified: ~3 | Solves: Problem 26**

---

### MODULE C: College Intelligence 2.0 (Agent 3)
*Enhanced college features. Independent of B2B.*

| Feature | Files | Stitch |
|---------|-------|--------|
| C1. Campus Photos + Logos (S3/CDN) | `ImageCDNManager.swift`, modify `CollegeProfileView.swift` | N/A |
| C2. "Best for Your Major" Filter | Modify `CollegeDiscoveryViewModel.swift`, `CollegeFiltersView.swift` | N/A |
| C3. AI-Generated College Summary Pages | `AICollegeSummaryView.swift`, `AICollegeSummaryViewModel.swift` | N/A |
| C4. Pre/Post Admission Checklists | `AdmissionChecklistView.swift`, modify `EnrollmentChecklistView.swift` | N/A |
| C5. What If Simulator | `WhatIfSimulatorView.swift`, `WhatIfSimulatorViewModel.swift` | ✅ what_if_simulator |
| C6. My Chances Calculator | `MyChancesView.swift`, `MyChancesViewModel.swift` | ✅ my_chances_calculator |
| C7. Why This School Essay Seed | `WhyThisSchoolView.swift`, `WhyThisSchoolViewModel.swift` | ✅ why_this_school_essay_seed |
| C8. Deadline Heatmap Calendar | `DeadlineHeatmapView.swift`, `DeadlineHeatmapViewModel.swift` | ✅ deadline_heatmap |
| C9. College Visit Planner | `VisitPlannerView.swift`, `VisitPlannerViewModel.swift` | ✅ campus_visit_planner |
| C10. College performance indexing | Modify `CollegeModels.swift` (@Attribute(.index)) | N/A |

**New files: ~15 | Modified: ~4 | Solves: Problem 16, 17**

---

### MODULE D: Academic Planning + AI Class Scheduling (Agent 4)
*Academic features + the AI class planner. Independent of B2B.*

| Feature | Files | Stitch |
|---------|-------|--------|
| D1. Transcript Upload + AI Parse | Modify `AcademicResumeView.swift` | N/A |
| D2. AP Course Suggestions w/ Difficulty | `APSuggestionView.swift`, modify `ClassRecommendationsView.swift` | N/A |
| D3. Dual Enrollment Guide | `DualEnrollmentGuideView.swift` | N/A |
| D4. Career-Specific Activity Suggestions | Modify `ActivitiesPortfolioView.swift` | N/A |
| D5. Research/Internship Tracking | Modify `ActivityModels.swift` | N/A |
| D6. Scholarship Match Score | `ScholarshipMatchView.swift`, `ScholarshipMatchViewModel.swift` | ✅ scholarship_match_score |
| D7. Career Explorer (Degree→Jobs) | `CareerExplorerView.swift`, `CareerExplorerViewModel.swift` | ✅ career_explorer_medical |
| **D8. AI Class Planner (Student)** | `AIClassPlannerView.swift`, `AIClassPlannerViewModel.swift`, `ClassScheduleAIEngine.swift` | **NEW: ai_class_planner_student** |
| **D9. Class Preference Submission** | `ClassPreferenceView.swift` | N/A |

**New files: ~10 | Modified: ~4 | Solves: Problem 5 (student side)**

---

### MODULE E: Notifications & App Season (Agent 5)
*Notification system + seasonal features.*

| Feature | Files | Stitch |
|---------|-------|--------|
| E1. SAT/PSAT Registration Reminders | Modify `LocalNotificationManager.swift` | N/A |
| E2. Annual Quiz Retake Prompt | Modify `LocalNotificationManager.swift` | N/A |
| E3. Grade-Aware Urgency Flags | Modify `DashboardViewModel.swift` | N/A |
| E4. Test Prep Resources | `TestPrepResourcesView.swift` | N/A |
| E5. Scholarship Action Plans | Modify `ScholarshipModel.swift` | N/A |
| E6. FAFSA Readiness Score | Modify `FAFSAGuideView.swift` | N/A |
| E7. App Season Dashboard Mode | `AppSeasonDashboardView.swift`, `AppSeasonViewModel.swift` | ✅ app_season_command_center |
| E8. First 100 Days Tracker | `First100DaysView.swift`, `First100DaysViewModel.swift` | ✅ first_100_days_tracker |
| E9. SNS Server-Side Push | `SNSPushManager.swift` | N/A |

**New files: ~6 | Modified: ~5 | Solves: Problem 25**

---

### MODULE F: Infrastructure & Safety (Agent 6)
*Cross-cutting concerns. No UI — services only.*

| Task | Files | Solves |
|------|-------|--------|
| AppSync sync manager | `SyncManager.swift`, `AppSyncManager.swift` | Problem 4 |
| Offline queue + conflict resolver | `OfflineQueueManager.swift`, `ConflictResolver.swift` | Problem 9 |
| AI rate limiter + response cache | `AIRateLimiter.swift`, `AIResponseCache.swift` | Problem 14 |
| S3 storage manager | `S3StorageManager.swift` | Problem 17 |
| Content moderation service | `ContentModerationService.swift` | Problem 21 |
| Accessibility pass (labels, contrast) | Modify `LadderColors.swift`, add labels across views | Problem 19 |
| Localization prep (LocalizedStringKey) | `Localizable.xcstrings`, modify key views | Problem 20 |

**New files: ~8 | Modified: ~10 | Solves: Problems 4, 9, 14, 17, 19, 20, 21**

---

### MODULE G: B2B Counselor Platform (Agent 7 — after Module A + F)
*All counselor-facing features. Requires auth + sync.*

| Feature | Files | Stitch |
|---------|-------|--------|
| G1. Counselor Caseload Manager | `CaseloadManagerView.swift`, `CaseloadManagerViewModel.swift` | ✅ counselor_caseload_manager |
| G2. Caseload Pagination | `CaseloadPaginationService.swift` | N/A |
| G3. Student Detail View (counselor) | `StudentDetailCounselorView.swift` | ✅ student_profile_counselor_view |
| G4. Class Approval List | `ClassApprovalListView.swift`, `ClassApprovalDetailView.swift` | **NEW: class_approval_counselor** |
| G5. Generic Deadline Calendar | `GenericDeadlineCalendarView.swift` | N/A |
| G6. Counselor Impact Report | `CounselorImpactReportView.swift`, `CounselorImpactViewModel.swift` | ✅ counselor_impact_report |
| G7. Counselor Verification Flow | `CounselorVerificationView.swift` | N/A |
| G8. Bulk Student Import + Auto-ID | `BulkStudentImportView.swift`, `AddStudentView.swift`, `StudentCredentialCardView.swift` | **NEW: bulk_student_import** |
| G9. School Year Rollover | `SchoolYearRolloverService.swift` | N/A |
| G10. Messaging (counselor side) | Modify `MessagingView.swift` | N/A |
| G11. Counselor Marketplace (Full) | `MarketplaceFullView.swift`, `BookSessionView.swift`, `CounselorReviewView.swift` | N/A |

**New files: ~16 | Modified: ~3 | Solves: Problems 5 (counselor side), 7, 12, 15, 27**

---

### MODULE H: B2B School Admin (Agent 8 — after Module G)
*Admin dashboard + district analytics. Requires counselor platform.*

| Feature | Files | Stitch |
|---------|-------|--------|
| H1. School Admin Dashboard | `SchoolAdminDashboardView.swift`, `SchoolAdminViewModel.swift` | ✅ school_admin_dashboard |
| H2. District Analytics Dashboard | `DistrictAnalyticsView.swift`, `DistrictDataService.swift` | ✅ district_analytics_dashboard |
| H3. Class Catalog Upload | `ClassCatalogUploadView.swift` | N/A |
| H4. School Profile Management | `SchoolProfileView.swift` | N/A |
| H5. Ambassador Program Signup | `AmbassadorSignupView.swift` | N/A |
| H6. Data Export (admin) | `DataExportView.swift` | N/A |
| H7. DPA Management | Modify `DPAConsentView.swift` | N/A |

**New files: ~8 | Modified: ~2 | Solves: Problems 6, 13, 22**

---

### MODULE I: Parent & Community (Agent 9 — after Module A)
*Parent-facing features + community.*

| Feature | Files | Stitch |
|---------|-------|--------|
| I1. Parent Dashboard | `ParentDashboardView.swift`, `ParentDashboardViewModel.swift` | ✅ parent_dashboard_read_only_view |
| I2. Peer Comparison (Anonymous) | `PeerComparisonView.swift`, `PeerComparisonViewModel.swift` | ✅ peer_comparison_anonymous |
| I3. Housing Preferences Quiz | `HousingQuizView.swift` | ✅ roommate_quiz |
| I4. Dorm Comparison | `DormComparisonView.swift` | N/A |
| I5. Roommate Finder | `RoomateFinderView.swift` | N/A |
| I6. Housing Deadline per App | Modify `HousingTimelineView.swift` | N/A |

**New files: ~7 | Modified: ~2**

---

### MODULE J: Reports & Export (Agent 10 — after Modules B-D)
*Export features. Needs student data from B-D.*

| Feature | Files | Stitch |
|---------|-------|--------|
| J1. PDF Portfolio Export | `PDFPortfolioView.swift`, `PDFGenerator.swift` | ✅ my_student_portfolio |
| J2. Alternative Paths (CC/Trade/Military) | `AlternativePathsView.swift` | N/A |
| J3. Resume Builder (Professional) | Modify `AcademicResumeView.swift` | N/A |
| J4. Internship Guide | `InternshipGuideView.swift` | N/A |
| J5. Post-Graduation Mode | `PostGraduationView.swift` | N/A |
| J6. Impact Report (student) | Modify `ImpactReportView.swift` | N/A |
| J7. Social Share Templates | Modify `SocialShareView.swift` | N/A |

**New files: ~5 | Modified: ~3**

---

## NEW STITCH DESIGN PROMPTS NEEDED

These are screens that don't have Stitch designs yet and need them:

### Stitch Prompt 1: `bulk_student_import`
```
Design a school counselor bulk student import screen for Ladder app.

Screen flow:
1. Top section: "Add New Students" header with school name
2. File upload area: Drag & drop zone for CSV file, or "Browse Files" button
3. CSV format guide: small helper showing required columns (First Name, Last Name, Date of Birth, Grade)
4. Preview table after upload:
   - Columns: Name | DOB | Grade | Generated Login ID | Generated Password | Status
   - Example row: "John Smith | Apr 15, 2010 | 9 | jsmith0415 | john10! | Ready"
   - Yellow warning icon for duplicate IDs (with auto-fix suggestion)
   - Green checkmarks for valid entries
5. Bottom bar: "Generate All Accounts" primary button + "Print Credential Cards" secondary button
6. Success state: "47 student accounts created!" with print/download options

Also design the "Student Credential Card" — a printable card (3x5 size) showing:
- Ladder logo at top
- Student name
- Login ID: jsmith0415
- Temporary Password: john10!
- "Change your password on first login" note
- School name at bottom

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

### Stitch Prompt 2: `ai_class_planner_student`
```
Design an AI class schedule planner for high school students in the Ladder app.

Screen layout:
1. Header: "Your AI Class Plan — Fall 2026" with student's grade badge (e.g., "11th Grade")
2. Info banner: "Based on your career interest (Engineering), GPA (3.7), and graduation requirements"
3. Schedule grid — 7 periods:
   Each period card shows:
   - Period number (left)
   - Class name (bold, e.g., "AP Calculus BC")
   - Why recommended (small text: "Prereq met ✓ • Needed for engineering programs")
   - AP/Honors badge if applicable
   - "Swap" button (opens alternatives sheet)
   - Green checkmark if prerequisite met, red X if not
4. Bottom summary:
   - "3 AP Classes • 2 Honors • Meets FL graduation requirements ✓"
   - "Bright Futures FAS progress: 22/24 credits"
5. Action buttons: "Submit to Counselor" (primary) + "Save Draft"
6. Alternatives bottom sheet (when "Swap" tapped):
   - List of alternative classes for that period
   - Each shows: class name, teacher, seats left, difficulty rating
   - AI explanation: "Switching to AP Physics 2 would be harder but better for engineering apps"

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

### Stitch Prompt 3: `class_approval_counselor`
```
Design a counselor class schedule approval screen for the Ladder app.

Screen layout:
1. Header: "Class Schedule Approvals" with count badge ("23 pending")
2. Filter chips: "All" | "No Conflicts" | "Has Conflicts" | "Grade 9" | "Grade 10" | "Grade 11" | "Grade 12"
3. Student cards (scrollable list):
   Each card shows:
   - Student name + grade + GPA
   - Number of AP/Honors classes selected
   - Conflict status: green "No conflicts" or red "2 conflicts found"
   - AI flag if any: "Warning: 4 APs with 3.2 GPA — may be too heavy"
   - Quick actions: "Approve ✓" (green) | "Review" (opens detail) | "Request Changes"
4. Bulk action bar at top: "Approve all no-conflict schedules (18)" button
5. Detail view (when "Review" tapped):
   - Student's full schedule grid (7 periods)
   - Red highlighted conflicts with explanation
   - AI suggestion for resolution
   - "Approve" | "Request Changes" (with note field)
   - Previous year's schedule for reference

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

### Stitch Prompt 4: `student_auto_id_single`
```
Design a single student add screen for school counselors in Ladder app.

Screen layout:
1. Header: "Add New Student"
2. Form fields:
   - First Name (text field)
   - Last Name (text field)
   - Date of Birth (date picker)
   - Grade (segmented control: 9 | 10 | 11 | 12)
   - Assign to Counselor (dropdown, defaults to current counselor)
3. "Generate Credentials" button
4. After generation — credential card appears:
   - Student name
   - Login ID: "jsmith0415" (with copy button)
   - Temporary Password: "john10!" (with copy/reveal toggle)
   - "Must change password on first login" note
5. Action buttons: "Print Card" | "Send via Email" | "Add Another Student"

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

### Stitch Prompt 5: `force_password_change`
```
Design a first-login password change screen for students in Ladder app.

Screen layout:
1. Ladder logo at top (circle version)
2. "Welcome to Ladder!" headline
3. "Your counselor created your account. Please set a new password to continue."
4. Current password field (pre-filled but masked, showing it's the auto-generated one)
5. New password field with requirements:
   - At least 8 characters
   - One uppercase letter
   - One number
   - Visual strength meter (weak/medium/strong)
6. Confirm password field
7. "Set Password & Continue" button
8. On success → flows into normal student onboarding

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

### Stitch Prompt 6: `generic_deadline_calendar_counselor`
```
Design a generic college deadline calendar for school counselors in Ladder app.

This is NOT per-student deadlines. This shows ALL major college deadlines that ANY 
student might care about.

Screen layout:
1. Header: "College Deadlines Calendar"
2. Month view calendar with colored dots on deadline dates:
   - Red dots: Early Decision deadlines
   - Orange dots: Early Action deadlines
   - Blue dots: Regular Decision deadlines
   - Green dots: Scholarship deadlines
   - Purple dots: SAT/ACT test dates
3. When a date is tapped, show list of deadlines:
   - "UF Early Action — Nov 1"
   - "FSU Regular Decision — Jan 15"
   - "Common App opens — Aug 1"
   Each with college logo/initials and deadline type badge
4. Filter chips at top: "All" | "Early Decision" | "Early Action" | "Regular" | "Scholarships" | "Tests"
5. "This Month" summary card: "12 deadlines this month, 3 are Early Decision"
6. No student names anywhere — this is a reference calendar

Design system: Warm cream background (#FDF8F0), forest green primary (#4A7C59), 
lime accent (#CAF24D), Noto Serif headlines, Manrope body. No divider lines — use 
tonal surface shifts. No pure black text — use #1f1b15.
```

---

## AWS RDS TABLES NEEDED (All Sprints)

| Table | Purpose | Module |
|-------|---------|--------|
| `user_profiles` | Role, tier, metadata | A |
| `parent_links` | Parent ↔ Student (supports multiple children) | A |
| `schools` | School profiles, school codes | A |
| `school_counselors` | Counselor ↔ School, caseload limits | A |
| `school_students` | Student ↔ School ↔ Counselor, login_id, is_first_login | A |
| `counselor_profiles` | Verification, specialties, rates | G |
| `class_catalogs` | School's available classes per semester | H |
| `class_preferences` | Student AI-suggested + submitted class selections | D/G |
| `class_approvals` | Counselor approval/rejection + notes | G |
| `audit_logs` | FERPA access tracking | A |
| `dpa_agreements` | School data processing agreements | A |
| `ai_response_cache` | Cached AI responses for common queries | F |
| `student_schedules` | Finalized class schedules per semester | D |
| `announcements` | School-wide push notification messages | E |
| `message_reports` | Flagged/reported messages | F |
| `data_exports` | Export request tracking | H |

---

## TOTAL FILE COUNT (Updated)

| Module | New Files | Modified Files | Total |
|--------|-----------|---------------|-------|
| A: Auth & Identity | 18 | 6 | 24 |
| B: Student Core Tools | 12 | 3 | 15 |
| C: College Intelligence | 15 | 4 | 19 |
| D: Academic + AI Classes | 10 | 4 | 14 |
| E: Notifications & Seasons | 6 | 5 | 11 |
| F: Infrastructure & Safety | 8 | 10 | 18 |
| G: B2B Counselor | 16 | 3 | 19 |
| H: B2B School Admin | 8 | 2 | 10 |
| I: Parent & Community | 7 | 2 | 9 |
| J: Reports & Export | 5 | 3 | 8 |
| **TOTAL** | **~105** | **~42** | **~147** |

**Current: 107 files → After all modules: ~254 files**
**Current: 65 features → After all modules: ~145+ features**
**Stitch designs: 97 existing + 6 new = 103 total**

---

## EXECUTION TIMELINE — 20 PARALLEL AGENTS

Each module is broken into **sub-agents** so multiple agents work inside each module simultaneously. Zero file overlap between any two agents.

```
PHASE 1: MODULE A — 3 agents in parallel ──────────────── MUST DO FIRST
    │
    │   Agent A1: Cognito Auth + Role System
    │       → AWSManager.swift, CognitoAuthManager.swift, AuthManager.swift (modify),
    │         LoginView.swift (modify), LadderApp.swift (modify), AppCoordinator.swift (modify)
    │
    │   Agent A2: Linking Systems + Auto-ID  
    │       → InviteCodeManager.swift, ParentAccessView.swift, ParentOnboardingView.swift,
    │         ChildSwitcherView.swift, SchoolCodeManager.swift, StudentAutoIDGenerator.swift,
    │         SchoolAdminOnboardingView.swift, CounselorOnboardingView.swift,
    │         ForcePasswordChangeView.swift
    │
    │   Agent A3: Compliance + Schema + Gates
    │       → DPAConsentView.swift, AuditLogger.swift, AgeGateView.swift,
    │         SchemaV1.swift, LadderMigrationPlan.swift, FeatureGateManager.swift,
    │         ParentTabView.swift, CounselorTabView.swift, AdminTabView.swift
    │
PHASE 2: 11 agents in parallel ──────────────────────────── ALL INDEPENDENT
    │
    │   Agent B1: Career Quiz + GPA
    │       → AdaptiveCareerQuizView.swift, RIASECEngine.swift, CareerQuizViewModel.swift,
    │         GPATrackerView.swift, GPATrackerViewModel.swift, GPAEntryModel.swift
    │
    │   Agent B2: Essay Tracker + Weekly Widget + Consent + Grade Gates
    │       → EssayTrackerView.swift, EssayTrackerViewModel.swift, EssayModel.swift,
    │         WeeklyWidgetView.swift, ConsentFlowView.swift, GradeFeatureManager.swift,
    │         modify DashboardView.swift, modify OnboardingContainerView.swift
    │
    │   Agent C1: What If + My Chances + Visit Planner
    │       → WhatIfSimulatorView.swift, WhatIfSimulatorViewModel.swift,
    │         MyChancesView.swift, MyChancesViewModel.swift,
    │         VisitPlannerView.swift, VisitPlannerViewModel.swift
    │
    │   Agent C2: Deadline Heatmap + Campus Photos + College Index
    │       → DeadlineHeatmapView.swift, DeadlineHeatmapViewModel.swift,
    │         ImageCDNManager.swift, modify CollegeProfileView.swift,
    │         modify CollegeModels.swift (@Attribute(.index))
    │
    │   Agent C3: AI College Pages + Essay Seed + Major Filter + Checklists
    │       → AICollegeSummaryView.swift, AICollegeSummaryViewModel.swift,
    │         WhyThisSchoolView.swift, WhyThisSchoolViewModel.swift,
    │         AdmissionChecklistView.swift, modify CollegeDiscoveryViewModel.swift,
    │         modify CollegeFiltersView.swift, modify EnrollmentChecklistView.swift
    │
    │   Agent D1: AI Class Planner + Scholarship Match
    │       → AIClassPlannerView.swift, AIClassPlannerViewModel.swift,
    │         ClassScheduleAIEngine.swift, ClassPreferenceView.swift,
    │         ScholarshipMatchView.swift, ScholarshipMatchViewModel.swift
    │
    │   Agent D2: Career Explorer + AP Suggestions + Dual Enrollment + Transcript
    │       → CareerExplorerView.swift, CareerExplorerViewModel.swift,
    │         APSuggestionView.swift, DualEnrollmentGuideView.swift,
    │         modify ClassRecommendationsView.swift, modify AcademicResumeView.swift,
    │         modify ActivitiesPortfolioView.swift, modify ActivityModels.swift
    │
    │   Agent E1: Notifications + App Season + First 100 Days
    │       → AppSeasonDashboardView.swift, AppSeasonViewModel.swift,
    │         First100DaysView.swift, First100DaysViewModel.swift,
    │         TestPrepResourcesView.swift, SNSPushManager.swift,
    │         modify LocalNotificationManager.swift, modify DashboardViewModel.swift,
    │         modify FAFSAGuideView.swift, modify ScholarshipModel.swift
    │
    │   Agent F1: Sync + Offline + Conflict Resolution
    │       → SyncManager.swift, AppSyncManager.swift,
    │         OfflineQueueManager.swift, ConflictResolver.swift
    │
    │   Agent F2: AI Safety (Rate Limiter + Cache + Moderation)
    │       → AIRateLimiter.swift, AIResponseCache.swift,
    │         ContentModerationService.swift, S3StorageManager.swift,
    │         modify AIService.swift
    │
    │   Agent F3: Accessibility + Localization Prep
    │       → Localizable.xcstrings, modify LadderColors.swift,
    │         accessibility labels pass across key views
    │
PHASE 3: 4 agents in parallel ──────────────────────────── NEEDS PHASE 1 + 2
    │
    │   Agent G1: Counselor Caseload + Student Detail + Deadline Calendar
    │       → CaseloadManagerView.swift, CaseloadManagerViewModel.swift,
    │         CaseloadPaginationService.swift, StudentDetailCounselorView.swift,
    │         GenericDeadlineCalendarView.swift, CounselorVerificationView.swift
    │
    │   Agent G2: Class Approval + Bulk Import + Auto-ID UI
    │       → ClassApprovalListView.swift, ClassApprovalDetailView.swift,
    │         BulkStudentImportView.swift, AddStudentView.swift,
    │         StudentCredentialCardView.swift, SchoolYearRolloverService.swift
    │
    │   Agent G3: Counselor Marketplace + Messaging + Impact Report
    │       → MarketplaceFullView.swift, BookSessionView.swift,
    │         CounselorReviewView.swift, CounselorImpactReportView.swift,
    │         CounselorImpactViewModel.swift, modify MessagingView.swift
    │
    │   Agent I1: Parent Dashboard + Peer Comparison + Housing
    │       → ParentDashboardView.swift, ParentDashboardViewModel.swift,
    │         PeerComparisonView.swift, PeerComparisonViewModel.swift,
    │         HousingQuizView.swift, DormComparisonView.swift,
    │         RoomateFinderView.swift, modify HousingTimelineView.swift
    │
PHASE 4: 2 agents in parallel ──────────────────────────── NEEDS PHASE 3
    │
    │   Agent H1: School Admin + District Analytics + Catalog + Export
    │       → SchoolAdminDashboardView.swift, SchoolAdminViewModel.swift,
    │         DistrictAnalyticsView.swift, DistrictDataService.swift,
    │         ClassCatalogUploadView.swift, SchoolProfileView.swift,
    │         AmbassadorSignupView.swift, DataExportView.swift
    │
    │   Agent J1: PDF Export + Alt Paths + Resume + Internship + Post-Grad
    │       → PDFPortfolioView.swift, PDFGenerator.swift,
    │         AlternativePathsView.swift, InternshipGuideView.swift,
    │         PostGraduationView.swift, modify AcademicResumeView.swift,
    │         modify ImpactReportView.swift, modify SocialShareView.swift
    │
DONE ──────────────────────────────────────────────────────
```

### AGENT SUMMARY

| Phase | Agents | Files | Can Start When |
|-------|--------|-------|---------------|
| **Phase 1** | 3 agents parallel | ~24 files | Immediately |
| **Phase 2** | 11 agents parallel | ~77 files | After Phase 1 |
| **Phase 3** | 4 agents parallel | ~28 files | After Phase 2 |
| **Phase 4** | 2 agents parallel | ~18 files | After Phase 3 |
| **TOTAL** | **20 agents** | **~147 files** | |

### WHY 20 AGENTS IS BETTER THAN 10

- **Phase 1**: Was 1 solo agent (24 files). Now 3 agents → **3x faster**
  - Auth, linking, and compliance have zero file overlap
- **Phase 2**: Was 5 agents. Now 11 agents → **~2x faster**
  - Module B split into B1 (quiz/GPA) + B2 (essay/widget)
  - Module C split into C1 (simulators) + C2 (heatmap/photos) + C3 (AI pages/filters)
  - Module D split into D1 (class planner) + D2 (career/AP)
  - Module F split into F1 (sync) + F2 (AI safety) + F3 (accessibility)
- **Phase 3**: Was 1 agent. Now 4 agents → **4x faster**
  - Module G split into G1 (caseload) + G2 (class approval) + G3 (marketplace)
  - Module I runs parallel with G
- **Phase 4**: Was 3 agents. Now 2 (H and J only, I moved to Phase 3)

**Maximum parallel agents at any time: 11 (Phase 2)**

---

## RISK REGISTER (Updated for AWS)

| Risk | Impact | Mitigation |
|------|--------|-----------|
| AWS costs at scale (RDS, Lambda, AppSync) | Monthly bill grows with schools | Use RDS reserved instances, Lambda free tier (1M requests), monitor with CloudWatch budgets |
| Cognito user pool limits (50K default) | Blocks multi-school rollout | Request limit increase early (AWS supports millions) |
| FERPA legal review needed | Blocks B2B sales | Draft DPA template early, consult ed-tech lawyer |
| Gemini API costs at scale | AI features expensive per-student | Cache responses, rate limit per user, tiered AI (Problem 14) |
| SwiftData schema migrations | Crashes on update if schema changes | VersionedSchema from Module A (Problem 10) |
| Multiple agents editing same files | Merge conflicts | Modules designed with zero file overlap |
| College Scorecard API rate limit (1K/hr) | Slow data refresh | Bundle data in app, only fetch deltas |
| App Store review (under-18 users) | Rejection risk | COPPA consent flow + age gate (Problem 18) |
| School IT blocking app installs | Can't deploy to school devices | MDM compatibility, future web portal (Problem 22) |
| Counselor resistance to new tools | Low adoption kills B2B revenue | Design to REMOVE work, not add it (Problem 27) |
| AppSync offline conflict resolution | Data inconsistency | Custom Lambda resolvers for critical paths (Problem 9) |
| ADA/Section 508 compliance | Legal risk for public schools | Accessibility pass in Module F (Problem 19) |
| Spanish language support delay | Loses FL schools with ESL populations | LocalizedStringKey prep in Module F, translate in v2 (Problem 20) |

---

## LAMBDA FUNCTIONS NEEDED (Deployed separately)

| Function | Trigger | Purpose |
|----------|---------|---------|
| `ai-proxy` | API Gateway | Proxy to Gemini API (keeps key server-side) |
| `school-year-rollover` | CloudWatch cron (Aug 1) | Promote grades, archive graduates |
| `push-announcement` | API Gateway (counselor/admin calls) | SNS → APNs push to school topic |
| `district-metrics` | CloudWatch cron (hourly) | Pre-compute district rollup stats |
| `data-export` | API Gateway | Generate student data export (JSON/PDF) |
| `content-moderate` | AppSync resolver | AWS Comprehend check on messages |
| `auto-id-generator` | AppSync resolver | Bulk create Cognito accounts from CSV |
| `ai-response-cache` | API Gateway | Check cache → hit Gemini if miss → store |
| `audit-log` | AppSync resolver | Log every counselor data access |

---

## WHAT TO TELL STITCH

6 new screen designs needed (prompts above):
1. `bulk_student_import` — CSV upload + preview table + credential cards
2. `ai_class_planner_student` — AI schedule grid with swap buttons
3. `class_approval_counselor` — approval list with conflict badges + bulk approve
4. `student_auto_id_single` — single student add + credential display
5. `force_password_change` — first-login password change
6. `generic_deadline_calendar_counselor` — college deadline reference calendar (no student names)

**Total Stitch screens: 103** (97 existing + 6 new)
