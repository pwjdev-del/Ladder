import SwiftUI
import SwiftData

// MARK: - Student Home Dashboard
// iPad: Two-column grid matching Stitch ipad_student_dashboard designs
// iPhone: Single-column scrollable cards

struct DashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    @State private var viewModel = DashboardViewModel()
    @State private var showSearchSheet = false
    @State private var showNotificationsSheet = false

    // MARK: - Live Profile Derived Values
    private var profile: StudentProfileModel? { profiles.first }
    private var studentFirstName: String { (profile?.firstName.isEmpty == false) ? profile!.firstName : "Student" }
    private var studentGrade: Int { profile?.grade ?? 9 }
    private var studentCareerPath: String { profile?.careerPath ?? "Not set" }
    private var studentGPA: String { profile?.gpa.map { String(format: "%.2f", $0) } ?? "—" }
    private var studentSAT: String { profile?.satScore.map { "\($0)" } ?? "—" }
    private var studentStreak: Int { profile?.streak ?? 0 }
    private var studentSavedCount: Int { profile?.savedCollegeIds.count ?? 0 }

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            if sizeClass == .regular {
                iPadDashboard
            } else {
                iPhoneDashboard
            }
        }
        .navigationBarHidden(sizeClass != .regular)
        .navigationTitle(sizeClass == .regular ? "" : "")
        .toolbar(sizeClass == .regular ? .visible : .hidden, for: .navigationBar)
        .sheet(isPresented: $showSearchSheet) {
            GlobalSearchSheet()
        }
        .sheet(isPresented: $showNotificationsSheet) {
            NotificationsSheet()
        }
    }

    // MARK: - iPad Dashboard (two-column grid)

    private var iPadDashboard: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                // Top bar: title + date + search + bell
                iPadTopBar

                // Two-column content
                HStack(alignment: .top, spacing: LadderSpacing.lg) {
                    // Left column (~60%)
                    VStack(spacing: LadderSpacing.lg) {
                        heroGreetingCard
                        nextUpCard
                        dailyTipCard
                    }
                    .frame(maxWidth: .infinity)

                    // Right column (~40%)
                    VStack(spacing: LadderSpacing.lg) {
                        portfolioReadinessCard
                        if viewModel.daysUntilDeadline > 0 {
                            urgentDeadlineCard
                        }
                        statsGrid
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(LadderSpacing.lg)
            .padding(.bottom, LadderSpacing.xxl)
        }
    }

    // MARK: - iPad Top Bar

    private var iPadTopBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("Academic Portfolio")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .editorialTracking()

                Text(dateString)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            HStack(spacing: LadderSpacing.md) {
                Button {
                    showSearchSheet = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(width: 40, height: 40)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Circle())
                }

                Button {
                    showNotificationsSheet = true
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(width: 40, height: 40)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Hero Greeting Card (green, with career path + grade)

    private var heroGreetingCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                // Current path label
                Text("CURRENT PATH")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed.opacity(0.8))
                    .tracking(2)

                // Greeting
                Text("Welcome back, \(studentFirstName).")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(.white)

                Text("Your trajectory is currently aligned with \(studentCareerPath) requirements for top-tier schools.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)

                Spacer().frame(height: LadderSpacing.sm)

                // Grade + track chips
                HStack(spacing: LadderSpacing.lg) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("GRADE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(2)
                        Text("\(studentGrade)th Grade")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("TRACK")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(2)
                        Text(studentCareerPath)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(LadderSpacing.xl)
        }
        .frame(minHeight: 180)
    }

    // MARK: - Portfolio Readiness (ring + count)

    private var portfolioReadinessCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                Text("PORTFOLIO READINESS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .tracking(2)

                CircularProgressView(
                    progress: viewModel.checklistProgress,
                    label: "\(Int(viewModel.checklistProgress * 100))%",
                    sublabel: "READY",
                    size: 120
                )

                Text("\(viewModel.completedTasks) of \(viewModel.totalTasks) Activities Complete")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .multilineTextAlignment(.center)

                if studentStreak > 7 {
                    Text("You're on a great streak!")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Keep going — every completed task counts.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }

                Button {
                    coordinator.navigate(to: .activityChecklist)
                } label: {
                    Text("View All Tasks")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Next Up Card

    private var nextUpCard: some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack {
                    Text("NEXT UP")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .tracking(2)

                    Spacer()

                    LadderTagChip(viewModel.nextTaskCategory)
                }

                Text(viewModel.nextTaskTitle)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                // Progress
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    HStack {
                        Text("PROGRESS")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .tracking(2)
                        Spacer()
                        Text("\(Int(viewModel.nextTaskProgress * 100))%")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    LinearProgressBar(progress: viewModel.nextTaskProgress)
                }

                Button {
                    coordinator.navigate(to: .activityChecklist)
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Text("Continue Task")
                            .font(LadderTypography.labelLarge)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(LadderColors.onSecondaryFixed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                    .background(LadderColors.secondaryFixed)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Urgent Deadline Card

    private var urgentDeadlineCard: some View {
        Button {
            coordinator.navigate(to: .deadlinesCalendar)
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                // Red accent top bar
                HStack {
                    Text("URGENT")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.error)
                        .tracking(2)
                    Spacer()
                    Text("Due in \(viewModel.daysUntilDeadline) days")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Text(viewModel.urgentDeadlineTitle)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("University of Florida")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text(viewModel.urgentDeadlineDate)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Text("Register Now →")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(LadderColors.error.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily Tip Card

    private var dailyTipCard: some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            // Accent dot
            Circle()
                .fill(LadderColors.secondaryFixed)
                .frame(width: 12, height: 12)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Strategic Counsel")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .italic()

                Text(viewModel.dailyTip)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineLimit(3)
                    .italic()
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    // MARK: - Stats Grid (2x2)

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
            statCard(icon: "star", label: "GPA", value: studentGPA, change: nil)
            statCard(icon: "doc.text", label: "PRACTICE SAT", value: studentSAT, change: nil)
            statCard(icon: "graduationcap", label: "SAVED COLLEGES", value: "\(studentSavedCount)", change: nil)
            statCard(icon: "flame", label: "DAY STREAK", value: "\(studentStreak)", change: nil)
        }
    }

    private func statCard(icon: String, label: String, value: String, change: String?) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .tracking(1)

            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            if let change {
                Text(change)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Date String

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    // MARK: - iPhone Dashboard (original single-column)

    private var iPhoneDashboard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Green header
                iPhoneHeaderSection

                // Content cards
                VStack(spacing: LadderSpacing.md) {
                    iPhoneChecklistCard
                    nextUpCard
                    if viewModel.daysUntilDeadline > 0 {
                        urgentDeadlineCard
                    }
                    dailyTipCard
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, -LadderSpacing.xl)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPhone Header

    private var iPhoneHeaderSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("STUDENT DASHBOARD")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.secondaryFixed)
                    .labelTracking()

                Spacer()

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        )

                    Text("\(studentStreak)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(LadderColors.accentLime)
                        .clipShape(Capsule())
                        .offset(x: 8, y: 4)
                }
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("\(viewModel.greetingText), \(studentFirstName)")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(.white)

                Text("\(studentCareerPath) · Grade \(studentGrade)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(LadderSpacing.lg)
        .padding(.top, LadderSpacing.xxl)
        .padding(.bottom, LadderSpacing.xxxxl)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - iPhone Checklist Progress Card

    private var iPhoneChecklistCard: some View {
        LadderCard(elevated: true) {
            HStack(spacing: LadderSpacing.lg) {
                CircularProgressView(
                    progress: viewModel.checklistProgress,
                    label: "\(Int(viewModel.checklistProgress * 100))%",
                    sublabel: "Complete",
                    size: 80
                )

                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Your Checklist")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("\(viewModel.completedTasks) of \(viewModel.totalTasks) tasks done")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Button {
                        coordinator.navigate(to: .activityChecklist)
                    } label: {
                        Text("View Tasks")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppCoordinator())
        .environment(LadderTheme())
}

private struct GlobalSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let mockResults: [(String, String, String)] = [
        ("Stanford University", "College", "graduationcap"),
        ("MIT", "College", "graduationcap"),
        ("Coca-Cola Scholars", "Scholarship", "dollarsign.circle"),
        ("Common App Essay", "Task", "doc.text"),
        ("SAT Registration", "Deadline", "calendar")
    ]

    var filtered: [(String, String, String)] {
        if searchText.isEmpty { return mockResults }
        return mockResults.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                List(filtered, id: \.0) { item in
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: item.2)
                            .foregroundStyle(LadderColors.primary)
                            .frame(width: 28)
                        VStack(alignment: .leading) {
                            Text(item.0).font(LadderTypography.titleSmall)
                            Text(item.1).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search colleges, scholarships, tasks...")
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let mockNotifications: [(String, String, String, String)] = [
        ("calendar.badge.exclamationmark", "SAT Registration Deadline", "Due in 3 days — register before Apr 15", "2h ago"),
        ("graduationcap.fill", "MIT EA Decision", "Decision releases Dec 14", "1d ago"),
        ("sparkles", "New Scholarship Match", "Coca-Cola Scholars matches your profile", "2d ago")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                if mockNotifications.isEmpty {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "bell.slash").font(.system(size: 48)).foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("No notifications yet").font(LadderTypography.titleMedium)
                        Text("Deadline reminders and activity updates will appear here.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(mockNotifications, id: \.1) { notif in
                        HStack(alignment: .top, spacing: LadderSpacing.md) {
                            Image(systemName: notif.0)
                                .foregroundStyle(LadderColors.primary)
                                .frame(width: 32, height: 32)
                                .background(LadderColors.primaryContainer.opacity(0.2))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                Text(notif.1).font(LadderTypography.titleSmall)
                                Text(notif.2).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                                Text(notif.3).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.6))
                            }
                        }
                        .padding(.vertical, LadderSpacing.xs)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
