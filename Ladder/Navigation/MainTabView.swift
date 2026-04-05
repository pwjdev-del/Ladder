import SwiftUI

// MARK: - Main Tab View
// 5 tabs with independent NavigationStacks and custom Ladder tab bar

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

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
            CollegeComparisonPlaceholder(leftId: left, rightId: right)
        case .matchScore(let id):
            MatchScorePlaceholder(collegeId: id)
        case .collegeFilters:
            CollegeFiltersPlaceholder()
        case .collegePersonality(let id):
            CollegeProfileView(collegeId: id)

        // MARK: Applications
        case .deadlinesCalendar:
            DeadlinesCalendarView()
        case .applicationDetail(let id):
            ApplicationDetailView(applicationId: id)
        case .applicationSubmission(let id):
            ApplicationDetailView(applicationId: id)
        case .decisionPortal:
            DecisionPortalPlaceholder()
        case .waitlistStrategy(let id):
            WaitlistPlaceholder(applicationId: id)
        case .postApplication(let id):
            ApplicationDetailView(applicationId: id)

        // MARK: Checklists
        case .roadmap:
            RoadmapView()
        case .activityChecklist:
            TasksView()
        case .enrollmentChecklist(let id):
            ApplicationDetailView(applicationId: id)
        case .volunteeringLog:
            VolunteeringLogPlaceholder()

        // MARK: AI Advisor
        case .advisorChat(let id):
            AdvisorChatView(sessionId: id)
        case .mockInterview(let id):
            MockInterviewPlaceholder(collegeId: id)
        case .interviewFeedback(let id):
            InterviewFeedbackPlaceholder(sessionId: id)
        case .interviewPrepHub:
            InterviewPrepPlaceholder()
        case .essayHub:
            EssayHubView()
        case .lociGenerator(let id):
            LOCIPlaceholder(collegeId: id)
        case .thankYouNote(let id):
            ThankYouPlaceholder(collegeId: id)
        case .scoreImprovement:
            ScoreImprovementView()

        // MARK: Financial
        case .scholarshipSearch:
            ScholarshipSearchView()
        case .financialAidComparison:
            FinancialAidPlaceholder()

        // MARK: Housing
        case .housingPreferences:
            HousingPlaceholder(title: "Housing Preferences")
        case .dormComparison(let id):
            HousingPlaceholder(title: "Dorm Comparison: \(id)")
        case .roommateFinder(let id):
            HousingPlaceholder(title: "Roommate Finder: \(id)")
        case .roommateProfile(let id):
            HousingPlaceholder(title: "Roommate Profile: \(id)")
        case .roommateIntro(let id):
            HousingPlaceholder(title: "Intro: \(id)")

        // MARK: Reports
        case .pdfPreview(let type):
            ReportPlaceholder(title: "PDF Preview: \(type)")
        case .impactReport:
            ReportPlaceholder(title: "Impact Report")
        case .socialShare:
            ReportPlaceholder(title: "Social Share")

        // MARK: Settings
        case .profileSettings:
            ProfileSettingsView()
        case .notificationSettings:
            NotificationSettingsView()

        // MARK: Shared
        case .customReminder:
            ReminderPlaceholder()
        case .milestone(let id):
            MilestonePlaceholder(milestoneId: id)
        case .recommendationRequest:
            RecommendationPlaceholder()
        case .careerQuiz:
            CareerQuizView()
        case .messaging(let id):
            MessagingPlaceholder(recipientId: id)

        // MARK: New Features
        case .wheelOfCareer:
            WheelOfCareerView()
        case .transcriptUpload:
            TranscriptUploadView()
        case .alternativePaths:
            RoadmapView()
        case .brightFuturesTracker:
            BrightFuturesTrackerView()
        }
    }
}

// MARK: - Lightweight Placeholders (for less critical screens not yet fully built)
// These show meaningful UI rather than just "Text()" so users see the app is alive.

private struct CollegeComparisonPlaceholder: View {
    let leftId: String
    let rightId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PlaceholderScreen(
            title: "Compare Schools",
            icon: "arrow.left.arrow.right",
            message: "Side-by-side comparison is coming soon. You'll be able to compare tuition, acceptance rates, and more."
        )
    }
}

private struct MatchScorePlaceholder: View {
    let collegeId: String

    var body: some View {
        PlaceholderScreen(
            title: "Match Score",
            icon: "percent",
            message: "Your personalized match breakdown will appear here based on your GPA, test scores, and interests."
        )
    }
}

private struct CollegeFiltersPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Filters",
            icon: "slider.horizontal.3",
            message: "Advanced filters for location, size, tuition, acceptance rate, and more are coming soon."
        )
    }
}

private struct DecisionPortalPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Decision Portal",
            icon: "envelope.open",
            message: "Track all your application decisions in one place. See acceptances, waitlists, and rejections."
        )
    }
}

private struct WaitlistPlaceholder: View {
    let applicationId: String

    var body: some View {
        PlaceholderScreen(
            title: "Waitlist Strategy",
            icon: "hourglass",
            message: "Get AI-powered advice on how to strengthen your candidacy while on the waitlist."
        )
    }
}

private struct VolunteeringLogPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Volunteering Log",
            icon: "heart.circle",
            message: "Track your community service hours, organizations, and impact. This feeds into your activity profile."
        )
    }
}

private struct MockInterviewPlaceholder: View {
    let collegeId: String?

    var body: some View {
        PlaceholderScreen(
            title: "Mock Interview",
            icon: "person.wave.2",
            message: "Practice with AI-generated interview questions tailored to your target schools."
        )
    }
}

private struct InterviewFeedbackPlaceholder: View {
    let sessionId: String

    var body: some View {
        PlaceholderScreen(
            title: "Interview Feedback",
            icon: "star.bubble",
            message: "Detailed feedback on your mock interview performance with tips for improvement."
        )
    }
}

private struct InterviewPrepPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Interview Prep Hub",
            icon: "person.wave.2",
            message: "Access common interview questions, tips, and practice sessions for your target schools."
        )
    }
}

private struct LOCIPlaceholder: View {
    let collegeId: String

    var body: some View {
        PlaceholderScreen(
            title: "Letter of Continued Interest",
            icon: "envelope",
            message: "AI will help you draft a compelling LOCI to send to the admissions office."
        )
    }
}

private struct ThankYouPlaceholder: View {
    let collegeId: String

    var body: some View {
        PlaceholderScreen(
            title: "Thank You Note",
            icon: "hand.thumbsup",
            message: "Draft a thank you note for your interviewer or anyone who helped with your application."
        )
    }
}

private struct FinancialAidPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Financial Aid Comparison",
            icon: "chart.bar",
            message: "Compare financial aid packages from different schools side by side."
        )
    }
}

private struct HousingPlaceholder: View {
    let title: String

    var body: some View {
        PlaceholderScreen(
            title: title,
            icon: "house",
            message: "Housing features are coming soon. You'll be able to compare dorms, find roommates, and more."
        )
    }
}

private struct ReportPlaceholder: View {
    let title: String

    var body: some View {
        PlaceholderScreen(
            title: title,
            icon: "doc.richtext",
            message: "Generate and share reports about your college prep journey."
        )
    }
}

private struct ReminderPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Custom Reminder",
            icon: "bell.badge",
            message: "Set custom reminders for deadlines, tasks, and important dates."
        )
    }
}

private struct MilestonePlaceholder: View {
    let milestoneId: String

    var body: some View {
        PlaceholderScreen(
            title: "Milestone",
            icon: "flag.fill",
            message: "Celebrate your progress! You've reached an important milestone on your journey."
        )
    }
}

private struct RecommendationPlaceholder: View {
    var body: some View {
        PlaceholderScreen(
            title: "Recommendation Request",
            icon: "envelope.badge.person.crop",
            message: "Draft a polite request for a letter of recommendation from your teacher or counselor."
        )
    }
}

private struct MessagingPlaceholder: View {
    let recipientId: String

    var body: some View {
        PlaceholderScreen(
            title: "Messaging",
            icon: "message",
            message: "Messaging features are coming soon."
        )
    }
}

// MARK: - Reusable Placeholder Screen

private struct PlaceholderScreen: View {
    let title: String
    let icon: String
    let message: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.3))
                        .frame(width: 100, height: 100)

                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.primary)
                }

                Text(title)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(message)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.xl)

                LadderTagChip("Coming Soon", icon: "sparkles")

                Spacer()
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
