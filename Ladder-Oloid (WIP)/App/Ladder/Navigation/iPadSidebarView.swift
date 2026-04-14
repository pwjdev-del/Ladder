import SwiftUI

// MARK: - iPad Sidebar Navigation
// Replaces the iPhone tab bar on iPad with a collapsible sidebar
// ALL features from iPhone are accessible here — same views, same data

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case tasks = "Tasks"
    case colleges = "Colleges"
    case applications = "Applications"
    case advisor = "AI Advisor"
    case financial = "Financial"
    case career = "Career"
    case housing = "Housing"
    case reports = "Reports"
    case profile = "Profile & Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: "house"
        case .tasks: "checkmark.circle"
        case .colleges: "graduationcap"
        case .applications: "doc.text"
        case .advisor: "sparkles"
        case .financial: "dollarsign.circle"
        case .career: "briefcase"
        case .housing: "building.2"
        case .reports: "chart.bar"
        case .profile: "person.circle"
        }
    }

    var iconFilled: String {
        switch self {
        case .dashboard: "house.fill"
        case .tasks: "checkmark.circle.fill"
        case .colleges: "graduationcap.fill"
        case .applications: "doc.text.fill"
        case .advisor: "sparkles"
        case .financial: "dollarsign.circle.fill"
        case .career: "briefcase.fill"
        case .housing: "building.2.fill"
        case .reports: "chart.bar.fill"
        case .profile: "person.circle.fill"
        }
    }
}

// MARK: - iPad Main View (NavigationSplitView)

struct iPadMainView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LadderTheme.self) private var theme

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationSplitView(columnVisibility: $coordinator.sidebarVisibility) {
            iPadSidebarContent(selectedItem: $coordinator.selectedSidebarItem)
        } detail: {
            NavigationStack(path: $coordinator.detailPath) {
                sidebarItemToView(coordinator.selectedSidebarItem)
                    .navigationDestination(for: Route.self) { route in
                        sharedRouteToView(route)
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Sidebar Item → Root View

    @ViewBuilder
    private func sidebarItemToView(_ item: SidebarItem) -> some View {
        switch item {
        case .dashboard:
            DashboardView()
        case .tasks:
            TasksView()
        case .colleges:
            CollegeDiscoveryView()
        case .applications:
            DeadlinesCalendarView()
        case .advisor:
            AdvisorHubView()
        case .financial:
            ScholarshipSearchView()
        case .career:
            CareerQuizView()
        case .housing:
            HousingPreferencesView()
        case .reports:
            ImpactReportView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Shared Route → View Resolution
// Used by BOTH iPad and iPhone. Every real view that exists is used here.
// Placeholders are only for features that don't have implementations yet on EITHER platform.

@ViewBuilder
func sharedRouteToView(_ route: Route) -> some View {
    switch route {

    // MARK: College Intelligence
    case .collegeDiscovery:
        CollegeDiscoveryView()
    case .collegeProfile(let id):
        CollegeProfileView(collegeId: id)
    case .collegeComparison(let left, let right):
        CollegeComparisonView(leftId: left, rightId: right)
    case .matchScore(let id):
        MatchScoreView(collegeId: id)
    case .collegeFilters:
        SharedPlaceholder(title: "Filters", icon: "slider.horizontal.3",
            message: "Advanced filters for location, size, tuition, and more.")
    case .collegePersonality(let id):
        CollegeProfileView(collegeId: id)
    case .savedColleges:
        SavedCollegesView()

    // MARK: Applications
    case .deadlinesCalendar:
        DeadlinesCalendarView()
    case .applicationDetail(let id):
        ApplicationDetailView(applicationId: id)
    case .applicationSubmission(let id):
        ApplicationDetailView(applicationId: id)
    case .decisionPortal:
        DecisionPortalView()
    case .waitlistStrategy(let id):
        SharedPlaceholder(title: "Waitlist Strategy", icon: "hourglass",
            message: "AI-powered advice for waitlist \(id).")
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
        SharedPlaceholder(title: "Volunteering Log", icon: "heart.circle",
            message: "Track your community service hours and impact.")

    // MARK: AI Advisor
    case .advisorChat(let id):
        AdvisorChatView(sessionId: id)
    case .mockInterview(let id):
        MockInterviewView(collegeId: id)
    case .interviewFeedback(let id):
        SharedPlaceholder(title: "Interview Feedback", icon: "star.bubble",
            message: "Detailed feedback on session \(id).")
    case .interviewPrepHub:
        SharedPlaceholder(title: "Interview Prep Hub", icon: "person.wave.2",
            message: "Access common interview questions and tips.")
    case .essayHub:
        EssayHubView()
    case .lociGenerator(let id):
        SharedPlaceholder(title: "Letter of Continued Interest", icon: "envelope",
            message: "AI will help you draft a compelling LOCI for \(id).")
    case .thankYouNote(let id):
        SharedPlaceholder(title: "Thank You Note", icon: "hand.thumbsup",
            message: "Draft a thank you note for \(id).")
    case .scoreImprovement:
        ScoreImprovementView()

    // MARK: Financial
    case .scholarshipSearch:
        ScholarshipSearchView()
    case .financialAidComparison:
        SharedPlaceholder(title: "Financial Aid Comparison", icon: "chart.bar",
            message: "Compare financial aid packages side by side.")

    // MARK: Housing
    case .housingPreferences:
        HousingPreferencesView()
    case .dormComparison(let id):
        DormComparisonView(collegeId: id)
    case .roommateFinder(let id):
        RoommateFinderView(collegeId: id)
    case .roommateProfile(let id):
        SharedPlaceholder(title: "Roommate Profile", icon: "person",
            message: "View profile \(id).")
    case .roommateIntro(let id):
        SharedPlaceholder(title: "Roommate Intro", icon: "hand.wave",
            message: "Send an introduction to \(id).")

    // MARK: Reports
    case .pdfPreview(let type):
        PDFPortfolioView()
    case .impactReport:
        ImpactReportView()
    case .socialShare:
        SharedPlaceholder(title: "Social Share", icon: "square.and.arrow.up",
            message: "Share your achievements.")

    // MARK: Settings — REAL views, not placeholders
    case .profileSettings:
        ProfileSettingsView()
    case .notificationSettings:
        NotificationSettingsView()

    // MARK: Shared — REAL views where they exist
    case .customReminder:
        SharedPlaceholder(title: "Custom Reminder", icon: "bell.badge",
            message: "Set custom reminders for deadlines.")
    case .milestone(let id):
        SharedPlaceholder(title: "Milestone", icon: "flag.fill",
            message: "Milestone \(id) reached!")
    case .recommendationRequest:
        SharedPlaceholder(title: "Recommendation Request", icon: "envelope.badge.person.crop",
            message: "Draft a request for a letter of recommendation.")
    case .careerQuiz:
        CareerQuizView()
    case .messaging(let id):
        SharedPlaceholder(title: "Messaging", icon: "message",
            message: "Chat with \(id).")
    }
}

// MARK: - Shared Placeholder (used by both iPhone and iPad for unbuilt features)

struct SharedPlaceholder: View {
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
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }
}

// MARK: - iPad Feature Placeholder (sidebar root screens)

private struct iPadFeaturePlaceholder: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            VStack(spacing: LadderSpacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.3))
                        .frame(width: 120, height: 120)

                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundStyle(LadderColors.primary)
                }

                Text(title)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text(message)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.xxl)

                LadderTagChip("Coming Soon", icon: "sparkles")

                Spacer()
            }
        }
        .navigationTitle(title)
    }
}

// MARK: - Sidebar Content

private struct iPadSidebarContent: View {
    @Binding var selectedItem: SidebarItem
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            // Main navigation sections
            Section {
                ForEach(SidebarItem.allCases.filter { $0 != .profile }) { item in
                    Button {
                        selectedItem = item
                        coordinator.popDetailToRoot()
                    } label: {
                        sidebarRow(for: item)
                    }
                    .listRowBackground(
                        Group {
                            if selectedItem == item {
                                LadderColors.primary.opacity(0.12)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                            }
                        }
                    )
                }
            }

            // Profile & Settings at bottom
            Section {
                Button {
                    selectedItem = .profile
                    coordinator.popDetailToRoot()
                } label: {
                    sidebarRow(for: .profile)
                }
                .listRowBackground(
                    Group {
                        if selectedItem == .profile {
                            LadderColors.primary.opacity(0.12)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }
                    }
                )
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Ladder")
    }

    @ViewBuilder
    private func sidebarRow(for item: SidebarItem) -> some View {
        let isSelected = selectedItem == item
        let iconName: String = isSelected ? item.iconFilled : item.icon
        let tint: Color = isSelected ? LadderColors.primary : LadderColors.onSurfaceVariant

        Label {
            Text(item.rawValue)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(isSelected ? LadderColors.onSurface : LadderColors.onSurfaceVariant)
        } icon: {
            Image(systemName: iconName)
                .foregroundStyle(tint)
        }
    }
}
