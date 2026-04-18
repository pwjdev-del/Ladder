import SwiftUI
import SwiftData

// MARK: - Main Tab View
// 5 tabs with independent NavigationStacks and custom Ladder tab bar

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Query private var studentProfiles: [StudentProfileModel]

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedTab) {
                // Home Tab
                NavigationStack(path: $coordinator.homePath) {
                    DashboardView()
                        .navigationDestination(for: Route.self) { route in
                            routeToView(route)
                        }
                }
                .tag(Tab.home)

                // Tasks Tab
                NavigationStack(path: $coordinator.tasksPath) {
                    TasksView()
                        .navigationDestination(for: Route.self) { route in
                            routeToView(route)
                        }
                }
                .tag(Tab.tasks)

                // Colleges Tab
                NavigationStack(path: $coordinator.collegePath) {
                    CollegeDiscoveryView()
                        .navigationDestination(for: Route.self) { route in
                            routeToView(route)
                        }
                }
                .tag(Tab.colleges)

                // Advisor Tab
                NavigationStack(path: $coordinator.advisorPath) {
                    AdvisorHubView()
                        .navigationDestination(for: Route.self) { route in
                            routeToView(route)
                        }
                }
                .tag(Tab.advisor)

                // Profile Tab
                NavigationStack(path: $coordinator.profilePath) {
                    ProfileView()
                        .navigationDestination(for: Route.self) { route in
                            routeToView(route)
                        }
                }
                .tag(Tab.profile)
            }
            .toolbar(.hidden, for: .tabBar) // Hide default tab bar

            LadderTabBar(selectedTab: $coordinator.selectedTab)
        }
    }

    // MARK: - Grade Gating

    @ViewBuilder
    private func gradeGated(_ feature: GradeFeatureManager.Feature, @ViewBuilder content: () -> some View) -> some View {
        let grade = studentProfiles.first?.grade ?? 9  // Default to 9th (most restrictive) if no profile
        if GradeFeatureManager.shared.isAccessible(feature, grade: grade) {
            content()
        } else {
            let unlock = GradeFeatureManager.shared.unlockGrade(for: feature) ?? 11
            LockedFeatureView(
                featureName: feature.displayName,
                unlockGrade: unlock,
                description: feature.featureDescription
            )
        }
    }

    // MARK: - Route → View Resolution

    @ViewBuilder
    private func routeToView(_ route: Route) -> some View {
        switch route {

        // MARK: College Intelligence
        case .collegeDiscovery:
            CollegeDiscoveryView()
        case .collegeProfile(let id):
            CollegeProfileView(collegeId: id)
        case .collegeComparison(let left, let right):
            CollegeComparisonView(leftId: left, rightId: right)
        case .matchScore(let id):
            GapAnalysisView(collegeId: id)
        case .collegeFilters:
            CollegeFiltersView()
        case .collegePersonality(let id):
            CollegePersonalityView(collegeId: id)
        case .apCredits(let id):
            APCreditsView(collegeId: id)

        // MARK: Phase 1 — College Intelligence 2.0
        case .gapAnalysis(let id):
            GapAnalysisView(collegeId: id)
        case .acceptanceWarning:
            AcceptanceWarningView()

        // MARK: Applications
        case .deadlinesCalendar:
            DeadlinesCalendarView()
        case .deadlineHeatmap:
            DeadlineHeatmapView()
        case .applicationDetail(let id):
            ApplicationDetailView(applicationId: id)
        case .decisionPortal:
            gradeGated(.decisionPortal) { DecisionPortalView() }
        case .waitlistStrategy(let id):
            LOCIGeneratorView(collegeId: id)

        // MARK: Checklists
        case .roadmap:
            RoadmapView()
        case .activityChecklist:
            TasksView()
        case .enrollmentChecklist(let id):
            EnrollmentChecklistView(collegeId: id)
        case .volunteeringLog:
            VolunteeringLogView()

        // MARK: AI Advisor
        case .advisorChat(let id):
            AdvisorChatView(sessionId: id)
        case .interviewFeedback:
            FeatureInProgressView(
                title: "Interview Feedback",
                icon: "star.bubble",
                description: "After completing a mock interview, you'll find a detailed feedback report here with scores, tips, and areas for improvement.",
                features: ["Question-by-question scoring", "Suggested answer improvements", "Confidence & delivery analysis"]
            )
        case .interviewPrepHub:
            FeatureInProgressView(
                title: "Interview Prep Hub",
                icon: "person.wave.2",
                description: "Prepare for college interviews with school-specific questions, tips from admissions officers, and practice scenarios.",
                features: ["Common questions by school", "Answer frameworks & examples", "Video practice mode"]
            )
        case .essayHub:
            EssayHubView()
        case .lociGenerator(let id):
            gradeGated(.lociGenerator) { LOCIGeneratorView(collegeId: id) }
        case .thankYouNote(let id):
            ThankYouNoteView(collegeId: id)
        case .scoreImprovement:
            ScoreImprovementView()

        // MARK: Phase 3 — Academic Intelligence
        case .satScoreTracker:
            SATScoreTrackerView()
        case .classRecommendations:
            ClassRecommendationsView()
        case .aiClassPlanner:
            AIClassPlannerView()
        case .graduationTracker:
            GraduationTrackerView()
        case .feeWaiverChecker:
            FeeWaiverCheckerView()

        // MARK: Phase 4 — AI Writing Studio
        case .mockInterviewFull:
            MockInterviewView()
        case .mockInterviewFeedback:
            FeatureInProgressView(
                title: "Interview Results",
                icon: "star.bubble",
                description: "Your mock interview results will appear here with detailed scoring across communication, content, and confidence.",
                features: ["Overall performance score", "Strengths & areas to improve", "Comparison with previous attempts"]
            )
        case .academicResume:
            AcademicResumeView()
        case .activityImpact:
            ActivityImpactView()
        case .cssProfileGuide:
            gradeGated(.cssProfileGuide) { CSSProfileGuideView() }
        case .ncaaTrack:
            NCAAAthleteView()

        // MARK: Financial
        case .scholarshipSearch:
            ScholarshipSearchView()
        case .scholarshipMatch:
            ScholarshipMatchView()
        case .financialAidComparison:
            gradeGated(.financialAidComparison) { FinancialAidComparisonView() }
        case .fafsaGuide:
            gradeGated(.fafsaGuide) { FAFSAGuideView() }
        case .freshmanGuide(let id):
            FreshmanSurvivalGuideView(collegeId: id)

        // MARK: Housing
        case .housingPreferences:
            FeatureInProgressView(
                title: "Housing Preferences",
                icon: "house",
                description: "Set your ideal living situation so we can match you with the right dorms and roommates.",
                features: ["Room type preferences", "Meal plan selection", "Lifestyle & schedule habits"]
            )
        case .dormComparison(let id):
            FeatureInProgressView(
                title: "Dorm Comparison",
                icon: "building.2",
                description: "Compare housing options side-by-side at \(id) to find the best fit for your lifestyle and budget.",
                features: ["Cost & amenity comparison", "Distance to classes", "Student ratings & reviews"]
            )
        case .roommateFinder(let id):
            FeatureInProgressView(
                title: "Roommate Finder",
                icon: "person.2",
                description: "Find compatible roommates at \(id) based on your lifestyle, schedule, and living preferences.",
                features: ["Compatibility scoring", "Lifestyle & habit matching", "Direct messaging"]
            )
        case .roommateProfile(let id):
            FeatureInProgressView(
                title: "Roommate Profile",
                icon: "person.crop.circle",
                description: "View detailed roommate profile for \(id) including habits, interests, and compatibility score.",
                features: ["Bio & interests", "Sleep & study schedule", "Cleanliness & noise preferences"]
            )
        case .roommateIntro(let id):
            FeatureInProgressView(
                title: "Roommate Intro",
                icon: "hand.wave",
                description: "Send a friendly introduction to \(id) and start getting to know your potential roommate.",
                features: ["Icebreaker prompts", "Shared interests highlight", "In-app messaging"]
            )
        case .housingTimeline:
            HousingTimelineView()

        // MARK: Reports
        case .pdfPreview(let type):
            FeatureInProgressView(
                title: "PDF Export",
                icon: "doc.richtext",
                description: "Export your \(type) report as a polished PDF ready to share with counselors, parents, or colleges.",
                features: ["Professional formatting", "Share via email or AirDrop", "Save to Files"]
            )
        case .impactReport:
            ImpactReportView()
        case .socialShare:
            SocialShareView()

        // MARK: Settings
        case .profileSettings:
            ProfileSettingsView()
        case .notificationSettings:
            NotificationSettingsView()
        case .legalSettings:
            LegalSettingsView()
        case .notificationCenter:
            NotificationCenterView()

        // MARK: Shared
        case .customReminder:
            CustomReminderView()
        case .milestone(let id):
            MilestoneCelebrationView(milestoneId: id)
        case .careerQuiz:
            CareerQuizView()
        case .messaging(let id):
            MessagingView(recipientId: id)

        // MARK: New Features
        case .wheelOfCareer:
            WheelOfCareerView()
        case .transcriptUpload:
            TranscriptUploadView()
        case .alternativePaths:
            AlternativePathsView()
        case .brightFuturesTracker:
            BrightFuturesTrackerView()

        // MARK: Phase 2 — Application Command
        case .lorTracker:
            LORTrackerView()
        case .dualEnrollmentGuide:
            DualEnrollmentGuideView()

        // MARK: Writing
        case .essayTracker:
            gradeGated(.essayTracker) { EssayTrackerView() }

        // MARK: Phase 6 — Community
        case .counselorDashboard:
            CounselorDashboardView()
        case .counselorMarketplace:
            CounselorMarketplaceView()
        case .parentAccess:
            ParentAccessView()
        case .peerTutoring:
            FeatureInProgressView(
                title: "Peer Tutoring",
                icon: "person.2.wave.2",
                description: "Connect with high-scoring students in your area for SAT, ACT, and subject tutoring.",
                features: ["Tutor profiles & ratings", "Subject-specific matching", "Schedule sessions in-app"]
            )
        case .ambassadorProgram:
            FeatureInProgressView(
                title: "Ambassador Program",
                icon: "megaphone",
                description: "Join Ladder's ambassador program to help other students and earn rewards for your involvement.",
                features: ["Referral rewards", "Exclusive ambassador badge", "Early access to new features"]
            )
        case .activitiesPortfolio:
            ActivitiesPortfolioView()
        case .commonAppExport:
            CommonAppExportWrapper()

        // MARK: Phase 7 — Essay & Checklist Tools
        case .whyThisSchool(let id):
            WhyThisSchoolView(collegeId: id)
        case .aiCollegeSummary(let id):
            AICollegeSummaryView(collegeId: id)
        case .admissionChecklist(let id):
            AdmissionChecklistView(collegeId: id)

        // MARK: Career & Academic Intelligence
        case .adaptiveCareerQuiz:
            CareerQuizView()
        case .careerExplorer:
            CareerExplorerView()
        case .apSuggestions:
            APSuggestionView()
        case .gpaTracker:
            GraduationTrackerView()

        // MARK: Phase 8 — College Intelligence Tools
        case .whatIfSimulator:
            WhatIfSimulatorView()
        case .myChances:
            MyChancesView()
        case .visitPlanner:
            VisitPlannerView()

        // MARK: Phase 9 — App Season & Student Life
        case .appSeasonDashboard:
            gradeGated(.appSeasonDashboard) { AppSeasonDashboardView() }
        case .first100Days:
            First100DaysView()
        case .testPrepResources:
            TestPrepResourcesView()

        // MARK: Phase 10 — Counselor B2B
        case .caseloadManager:
            CaseloadManagerView()
        case .studentDetailCounselor(let studentId):
            StudentDetailCounselorView(studentId: studentId)
        case .genericDeadlineCalendar:
            GenericDeadlineCalendarView()
        case .counselorVerification:
            CounselorVerificationView()
        case .classApprovalList:
            FeatureInProgressView(title: "Class Approvals", icon: "checkmark.rectangle.stack", description: "Review and approve student class selections.", features: [])
        case .classApprovalDetail(let studentId):
            FeatureInProgressView(title: "Class Approval", icon: "checkmark.rectangle", description: "Approve classes for student \(studentId).", features: [])
        case .bulkStudentImport:
            FeatureInProgressView(title: "Bulk Import", icon: "square.and.arrow.down", description: "Import multiple students at once.", features: [])
        case .addSingleStudent:
            FeatureInProgressView(title: "Add Student", icon: "person.badge.plus", description: "Add a single student to your caseload.", features: [])

        // MARK: Module G — Counselor Marketplace Enhancement
        case .bookSession(let name, let specialty):
            BookSessionView(counselorName: name, counselorSpecialty: specialty)
        case .counselorImpactReport:
            CounselorImpactReportView()
        case .counselorReview(let name, let id):
            CounselorReviewView(counselorName: name, counselorId: id)

        // MARK: Module H — School Admin
        case .schoolAdminDashboard:
            SchoolAdminDashboardView()
        case .districtAnalytics:
            DistrictAnalyticsView()
        case .classCatalogUpload:
            ClassCatalogUploadView()

        // MARK: Module I — Parent
        case .parentDashboard:
            ParentDashboardView()
        case .peerComparison:
            PeerComparisonView()

        // MARK: Module J — Reports & Export
        case .pdfPortfolio:
            PDFPortfolioView()
        case .internshipGuide:
            InternshipGuideView()
        case .postGraduation:
            PostGraduationView()

        // School data routes
        case .clubsUpload:
            ClubsUploadView()
        case .sportsUpload:
            SportsUploadView()
        case .schoolCalendarUpload:
            SchoolCalendarUploadView()
        case .mySchool:
            MySchoolView()

        // MARK: College Preference & Level System
        case .collegePreferenceQuiz:
            CollegePreferenceQuizView()
        }
    }
}

// MARK: - Common App Export Wrapper (loads activities from SwiftData)
struct CommonAppExportWrapper: View {
    @Environment(\.modelContext) private var context
    @State private var activities: [ActivityModel] = []

    var body: some View {
        CommonAppExportView(activities: activities)
            .task {
                let descriptor = FetchDescriptor<ActivityModel>(sortBy: [SortDescriptor(\.createdAt)])
                activities = (try? context.fetch(descriptor)) ?? []
            }
    }
}

// MARK: - Feature In Progress View (polished replacement for placeholders)

struct FeatureInProgressView: View {
    let title: String
    let icon: String
    let description: String
    let features: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    Spacer().frame(height: LadderSpacing.xxl)

                    // Icon badge
                    ZStack {
                        Circle()
                            .fill(LadderColors.primaryContainer.opacity(0.25))
                            .frame(width: 110, height: 110)
                        Circle()
                            .fill(LadderColors.primaryContainer.opacity(0.5))
                            .frame(width: 80, height: 80)
                        Image(systemName: icon)
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(LadderColors.primary)
                    }

                    // Title
                    Text(title)
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    // Description
                    Text(description)
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LadderSpacing.xl)

                    // Status chip
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 12))
                        Text("Being Built")
                            .font(LadderTypography.labelMedium)
                    }
                    .foregroundStyle(LadderColors.primary)
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(Capsule())

                    // Planned features card
                    if !features.isEmpty {
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("What to expect")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(features, id: \.self) { feature in
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundStyle(LadderColors.primary)
                                    Text(feature)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Spacer()
                                }
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        .padding(.horizontal, LadderSpacing.lg)
                    }

                    Spacer().frame(height: LadderSpacing.xxl)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }
}
