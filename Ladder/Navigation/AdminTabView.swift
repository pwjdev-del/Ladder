import SwiftUI

// MARK: - Admin Tab Enum

enum AdminTab: Int, CaseIterable {
    case dashboard = 0
    case students
    case reports

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .students: "Students"
        case .reports: "Reports"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "chart.bar.xaxis"
        case .students: "person.3"
        case .reports: "doc.text.magnifyingglass"
        }
    }

    var iconFilled: String {
        switch self {
        case .dashboard: "chart.bar.xaxis"
        case .students: "person.3.fill"
        case .reports: "doc.text.magnifyingglass"
        }
    }
}

// MARK: - Admin Tab View
// 3 tabs: Dashboard, Students, Reports

struct AdminTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedAdminTab) {
                NavigationStack(path: $coordinator.dashboardPath) {
                    SchoolAdminDashboardView()
                        .navigationDestination(for: Route.self) { route in
                            AdminRouteResolver.resolve(route)
                        }
                }
                .tag(AdminTab.dashboard)

                NavigationStack(path: $coordinator.studentsPath) {
                    BulkStudentImportView()
                        .navigationDestination(for: Route.self) { route in
                            AdminRouteResolver.resolve(route)
                        }
                }
                .tag(AdminTab.students)

                NavigationStack(path: $coordinator.reportsPath) {
                    DistrictAnalyticsView()
                        .navigationDestination(for: Route.self) { route in
                            AdminRouteResolver.resolve(route)
                        }
                }
                .tag(AdminTab.reports)
            }
            .toolbar(.hidden, for: .tabBar)

            AdminTabBar(selectedTab: $coordinator.selectedAdminTab)
        }
    }
}

// MARK: - Admin Tab Bar

struct AdminTabBar: View {
    @Binding var selectedTab: AdminTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AdminTab.allCases, id: \.self) { tab in
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

// MARK: - Admin Dashboard Screen

struct AdminDashboardScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School Dashboard")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Your school at a glance")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // School info card
                    VStack(spacing: LadderSpacing.lg) {
                        HStack(spacing: LadderSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set Up Your School")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Configure school details to get started")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            Spacer()
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                        AdminStatCard(icon: "person.3.fill", value: "0", label: "Students", color: LadderColors.primary)
                        AdminStatCard(icon: "person.text.rectangle.fill", value: "0", label: "Counselors", color: LadderColors.primaryContainer)
                        AdminStatCard(icon: "doc.text.fill", value: "0", label: "Applications", color: LadderColors.primary)
                        AdminStatCard(icon: "checkmark.seal.fill", value: "0", label: "Acceptances", color: LadderColors.primaryContainer)
                    }

                    // School Data section
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("School Data")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        NavigationLink(value: Route.classCatalogUpload) {
                            schoolDataRow(icon: "book.fill", title: "Manage Classes", subtitle: "Upload class catalog")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: Route.clubsUpload) {
                            schoolDataRow(icon: "person.3.fill", title: "Manage Clubs", subtitle: "Add clubs and organizations")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: Route.sportsUpload) {
                            schoolDataRow(icon: "figure.run", title: "Manage Sports", subtitle: "Add athletics programs")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: Route.schoolCalendarUpload) {
                            schoolDataRow(icon: "calendar", title: "School Calendar", subtitle: "Add events and important dates")
                        }
                        .buttonStyle(.plain)
                    }

                    // Quick actions
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Quick Actions")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        ForEach(["Invite counselors to your school", "Set up student import", "Configure school settings", "View district reports"], id: \.self) { action in
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 16))
                                    .foregroundStyle(LadderColors.primary)
                                Text(action)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.4))
                            }
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func schoolDataRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(subtitle)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.4))
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
    }
}

// MARK: - Admin Stat Card

struct AdminStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Admin Students Screen

struct AdminStudentsScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Manage Students")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Import and manage student accounts")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Empty state
                    VStack(spacing: LadderSpacing.lg) {
                        Spacer().frame(height: LadderSpacing.xl)

                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.25))
                                .frame(width: 110, height: 110)
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.5))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.crop.rectangle.stack.fill")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("No Students Yet")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Import your student roster to create accounts automatically. Students will receive login credentials via email.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, LadderSpacing.md)

                        // Import button
                        Button {
                            // TODO: Implement CSV import
                        } label: {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Import Students")
                                    .font(LadderTypography.labelLarge)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.lg)
                            .background(LadderColors.primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, LadderSpacing.xl)

                        // Supported formats
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Supported import methods")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(["CSV file upload (name, email, grade)", "Clever integration", "ClassLink integration", "Manual entry"], id: \.self) { method in
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundStyle(LadderColors.primary)
                                    Text(method)
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

// MARK: - Admin Reports Screen

struct AdminReportsScreen: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Reports & Analytics")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("District-level insights")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Empty state
                    VStack(spacing: LadderSpacing.lg) {
                        Spacer().frame(height: LadderSpacing.xl)

                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.25))
                                .frame(width: 110, height: 110)
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.5))
                                .frame(width: 80, height: 80)
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("Reports Coming Soon")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Once students are imported and actively using Ladder, you'll see aggregated analytics on college readiness, application status, and outcomes.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, LadderSpacing.md)

                        // What to expect
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Available reports")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(["College readiness scores by grade", "Application completion rates", "Acceptance & enrollment outcomes", "Financial aid coverage", "Counselor caseload metrics"], id: \.self) { report in
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "chart.bar")
                                        .font(.system(size: 16))
                                        .foregroundStyle(LadderColors.primary)
                                    Text(report)
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

                    // Sign out (also available from reports since admin has no dedicated settings tab)
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

// MARK: - Admin Route Resolver

enum AdminRouteResolver {
    @ViewBuilder
    static func resolve(_ route: Route) -> some View {
        switch route {
        case .schoolAdminDashboard:
            SchoolAdminDashboardView()
        case .districtAnalytics:
            DistrictAnalyticsView()
        case .classCatalogUpload:
            ClassCatalogUploadView()
        case .clubsUpload:
            ClubsUploadView()
        case .sportsUpload:
            SportsUploadView()
        case .schoolCalendarUpload:
            SchoolCalendarUploadView()
        case .mySchool:
            MySchoolView()
        default:
            FeatureInProgressView(
                title: "Coming Soon",
                icon: "hammer",
                description: "This feature is being built for the admin portal.",
                features: []
            )
        }
    }
}

#Preview {
    AdminTabView()
        .environment(AppCoordinator())
        .environment(AuthManager())
}
