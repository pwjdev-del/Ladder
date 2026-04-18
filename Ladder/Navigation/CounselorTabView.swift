import SwiftUI
import SwiftData

// MARK: - Counselor Tab Enum

enum CounselorTab: Int, CaseIterable {
    case caseload = 0
    case classes
    case deadlines
    case profile

    var title: String {
        switch self {
        case .caseload: "Caseload"
        case .classes: "Classes"
        case .deadlines: "Deadlines"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .caseload: "person.3"
        case .classes: "calendar.badge.clock"
        case .deadlines: "calendar"
        case .profile: "person"
        }
    }

    var iconFilled: String {
        switch self {
        case .caseload: "person.3.fill"
        case .classes: "calendar.badge.clock"
        case .deadlines: "calendar.circle.fill"
        case .profile: "person.fill"
        }
    }
}

// MARK: - Counselor Tab View
// 4 tabs: Caseload, Classes, Deadlines, Profile

struct CounselorTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedCounselorTab) {
                NavigationStack(path: $coordinator.caseloadPath) {
                    CaseloadManagerView()
                        .navigationDestination(for: Route.self) { route in
                            counselorRouteToView(route)
                        }
                }
                .tag(CounselorTab.caseload)

                NavigationStack(path: $coordinator.classesPath) {
                    ClassApprovalListView()
                        .navigationDestination(for: Route.self) { route in
                            counselorRouteToView(route)
                        }
                }
                .tag(CounselorTab.classes)

                NavigationStack(path: $coordinator.deadlinesPath) {
                    GenericDeadlineCalendarView()
                        .navigationDestination(for: Route.self) { route in
                            counselorRouteToView(route)
                        }
                }
                .tag(CounselorTab.deadlines)

                NavigationStack(path: $coordinator.counselorProfilePath) {
                    ProfileView()
                        .navigationDestination(for: Route.self) { route in
                            counselorRouteToView(route)
                        }
                }
                .tag(CounselorTab.profile)
            }
            .toolbar(.hidden, for: .tabBar)

            CounselorTabBar(selectedTab: $coordinator.selectedCounselorTab)
        }
    }

    // MARK: - Counselor Route Resolution

    @ViewBuilder
    private func counselorRouteToView(_ route: Route) -> some View {
        switch route {
        case .caseloadManager:
            CaseloadManagerView()
        case .studentDetailCounselor(let studentId):
            StudentDetailCounselorView(studentId: studentId)
        case .genericDeadlineCalendar:
            GenericDeadlineCalendarView()
        case .counselorVerification:
            CounselorVerificationView()
        case .counselorDashboard:
            CounselorDashboardView()
        case .classApprovalList:
            ClassApprovalListView()
        case .classApprovalDetail(let studentId):
            ClassApprovalDetailView(studentId: studentId)
        case .bulkStudentImport:
            BulkStudentImportView()
        case .addSingleStudent:
            AddSingleStudentView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Counselor Tab Bar

struct CounselorTabBar: View {
    @Binding var selectedTab: CounselorTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CounselorTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                            .frame(height: 28)

                        Text(tab.title)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(selectedTab == tab ? LadderColors.primary : LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, LadderSpacing.sm)
        .padding(.bottom, safeAreaBottom > 0 ? safeAreaBottom : LadderSpacing.sm)
        .background(
            Rectangle()
                .fill(LadderColors.surface.opacity(0.85))
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - Caseload Screen

struct CounselorCaseloadScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Your Caseload")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Students assigned to you")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Empty state
                    VStack(spacing: LadderSpacing.lg) {
                        Spacer().frame(height: LadderSpacing.xxl)

                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.25))
                                .frame(width: 110, height: 110)
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.5))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("Connect Your School")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Once your school administrator connects Ladder, your assigned students will appear here with their progress, applications, and action items.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, LadderSpacing.md)

                        // Status chip
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "link.badge.plus")
                                .font(.system(size: 12))
                            Text("Awaiting School Connection")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(Capsule())

                        // What to expect
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("When connected, you'll see")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(["Student profiles & academic info", "Application progress tracker", "Deadline alerts for your students", "Class schedule approvals"], id: \.self) { item in
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundStyle(LadderColors.primary)
                                    Text(item)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Spacer()
                                }
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Classes Screen

struct CounselorClassesScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Class Schedules")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Review schedules and manage students")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Quick actions
                    VStack(spacing: LadderSpacing.md) {
                        NavigationLink(value: Route.classApprovalList) {
                            counselorActionRow(
                                icon: "checkmark.rectangle.stack",
                                title: "Class Schedule Approvals",
                                subtitle: "Review and approve student class selections",
                                badgeCount: 7
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: Route.bulkStudentImport) {
                            counselorActionRow(
                                icon: "person.3.sequence",
                                title: "Bulk Import Students",
                                subtitle: "Add multiple students with auto-generated credentials",
                                badgeCount: nil
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: Route.addSingleStudent) {
                            counselorActionRow(
                                icon: "person.badge.plus",
                                title: "Add Single Student",
                                subtitle: "Quick add one student with login credentials",
                                badgeCount: nil
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // What you can do
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("What you can do here")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        ForEach(["Review proposed class schedules", "Approve or request changes", "Bulk import students with auto-credentials", "Recommend AP/Honors courses"], id: \.self) { item in
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(LadderColors.primary)
                                Text(item)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Spacer()
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func counselorActionRow(icon: String, title: String, subtitle: String, badgeCount: Int?) -> some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineLimit(1)
            }

            Spacer()

            if let count = badgeCount {
                Text("\(count)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(LadderColors.error)
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Deadlines Screen (uses real CollegeDeadlineModel from SwiftData)

struct CounselorDeadlinesScreen: View {
    @Query(sort: \CollegeDeadlineModel.date) private var deadlines: [CollegeDeadlineModel]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("College Deadlines")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("\(upcomingDeadlines.count) upcoming deadline\(upcomingDeadlines.count == 1 ? "" : "s")")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    if upcomingDeadlines.isEmpty {
                        // Empty state
                        VStack(spacing: LadderSpacing.lg) {
                            Spacer().frame(height: LadderSpacing.xl)

                            ZStack {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.25))
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.5))
                                    .frame(width: 70, height: 70)
                                Image(systemName: "calendar")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            Text("No Upcoming Deadlines")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            Text("College application deadlines from your students' saved colleges will appear here as a consolidated calendar.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, LadderSpacing.md)
                        }
                    } else {
                        // Deadline list
                        ForEach(upcomingDeadlines, id: \.self) { deadline in
                            CounselorDeadlineRow(deadline: deadline)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var upcomingDeadlines: [CollegeDeadlineModel] {
        deadlines.filter { deadline in
            guard let date = deadline.date else { return false }
            return date >= Date()
        }
    }
}

// MARK: - Counselor Deadline Row

struct CounselorDeadlineRow: View {
    let deadline: CollegeDeadlineModel

    var body: some View {
        HStack(spacing: LadderSpacing.md) {
            // Date badge
            VStack(spacing: 2) {
                if let date = deadline.date {
                    Text(date.formatted(.dateTime.month(.abbreviated)))
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.primary)
                    Text(date.formatted(.dateTime.day()))
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            .frame(width: 48, height: 48)
            .background(LadderColors.primaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(deadline.college?.name ?? "Unknown College")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)

                Text(deadline.deadlineType)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            if let date = deadline.date {
                let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                Text("\(daysLeft)d")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(daysLeft <= 7 ? LadderColors.error : LadderColors.primary)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        (daysLeft <= 7 ? LadderColors.errorContainer : LadderColors.primaryContainer).opacity(0.3)
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Counselor Profile Screen

struct CounselorProfileScreen: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Profile header
                    VStack(spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.3))
                                .frame(width: 90, height: 90)
                            Image(systemName: "person.text.rectangle.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("Counselor Profile")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(authManager.userEmail ?? "counselor@school.edu")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(.top, LadderSpacing.xxl)

                    // Stats
                    HStack(spacing: LadderSpacing.md) {
                        CounselorStatBadge(value: "0", label: "Students")
                        CounselorStatBadge(value: "0", label: "Pending")
                        CounselorStatBadge(value: "0", label: "Approved")
                    }

                    // Verification CTA
                    Button {
                        coordinator.navigateForRole(to: .counselorVerification, role: .counselor)
                    } label: {
                        HStack(spacing: LadderSpacing.md) {
                            Image(systemName: "checkmark.shield")
                                .font(.system(size: 20))
                                .foregroundStyle(LadderColors.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Verify Credentials")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Submit your license and credentials")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(LadderColors.outlineVariant)
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    // Settings rows
                    VStack(spacing: 0) {
                        ParentSettingsRow(icon: "person.circle", title: "Edit Profile", subtitle: "Name, title, school")
                        ParentSettingsRow(icon: "bell", title: "Notifications", subtitle: "Alerts and reminders")
                        ParentSettingsRow(icon: "lock.shield", title: "Privacy", subtitle: "Data access settings")
                    }
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    // Sign out
                    Button {
                        Task { await authManager.signOut() }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(LadderColors.error)
                            Text("Sign Out")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.error)
                            Spacer()
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Counselor Stat Badge

struct CounselorStatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

#Preview {
    CounselorTabView()
        .environment(AppCoordinator())
        .environment(AuthManager())
}
