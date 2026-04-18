import SwiftUI

// MARK: - Parent Tab Enum

enum ParentTab: Int, CaseIterable {
    case overview = 0
    case finances
    case settings

    var title: String {
        switch self {
        case .overview: "Overview"
        case .finances: "Finances"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .overview: "chart.bar"
        case .finances: "dollarsign.circle"
        case .settings: "gearshape"
        }
    }

    var iconFilled: String {
        switch self {
        case .overview: "chart.bar.fill"
        case .finances: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - Parent Tab View
// 3 tabs: Overview, Finances, Settings — read-only access to child's data

struct ParentTabView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedParentTab) {
                NavigationStack(path: $coordinator.overviewPath) {
                    ParentDashboardView()
                        .navigationDestination(for: Route.self) { route in
                            ParentRouteResolver.resolve(route)
                        }
                }
                .tag(ParentTab.overview)

                NavigationStack(path: $coordinator.financesPath) {
                    FinancialAidComparisonView()
                        .navigationDestination(for: Route.self) { route in
                            ParentRouteResolver.resolve(route)
                        }
                }
                .tag(ParentTab.finances)

                NavigationStack(path: $coordinator.parentSettingsPath) {
                    ProfileSettingsView()
                        .navigationDestination(for: Route.self) { route in
                            ParentRouteResolver.resolve(route)
                        }
                }
                .tag(ParentTab.settings)
            }
            .toolbar(.hidden, for: .tabBar)

            ParentTabBar(selectedTab: $coordinator.selectedParentTab)
        }
    }
}

// MARK: - Parent Tab Bar

struct ParentTabBar: View {
    @Binding var selectedTab: ParentTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ParentTab.allCases, id: \.self) { tab in
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

// MARK: - Parent Overview Screen

struct ParentOverviewScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Parent Dashboard")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Your child's college prep at a glance")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Child info card
                    VStack(spacing: LadderSpacing.lg) {
                        HStack(spacing: LadderSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Connect Your Child")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Link your account to view their progress")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            Spacer()
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    // Progress placeholder cards
                    ParentStatCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "GPA",
                        value: "--",
                        subtitle: "Will update when linked"
                    )

                    ParentStatCard(
                        icon: "checkmark.circle",
                        title: "Checklist Progress",
                        value: "0%",
                        subtitle: "Tasks completed"
                    )

                    ParentStatCard(
                        icon: "building.columns",
                        title: "Colleges Saved",
                        value: "0",
                        subtitle: "On their list"
                    )

                    ParentStatCard(
                        icon: "doc.text",
                        title: "Applications",
                        value: "0",
                        subtitle: "Submitted"
                    )

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Parent Stat Card

struct ParentStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                    .fill(LadderColors.primaryContainer.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text(subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
            }

            Spacer()

            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Parent Finances Screen

struct ParentFinancesScreen: View {
    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Financial Overview")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Scholarships and financial aid summary")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Empty state
                    VStack(spacing: LadderSpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.25))
                                .frame(width: 100, height: 100)
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.5))
                                .frame(width: 70, height: 70)
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("No Financial Data Yet")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Once your child adds colleges and explores financial aid options, scholarship matches and net cost estimates will appear here.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, LadderSpacing.lg)

                        // What to expect
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("What you'll see here")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(["Scholarship matches & amounts", "Estimated net cost per college", "FAFSA & CSS Profile status", "Financial aid package comparison"], id: \.self) { item in
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
                    .padding(.top, LadderSpacing.xxl)

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Parent Settings Screen

struct ParentSettingsScreen: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Settings")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Manage your parent account")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Account section
                    VStack(spacing: 0) {
                        ParentSettingsRow(icon: "person.circle", title: "Account", subtitle: authManager.userEmail ?? "Not signed in")
                        ParentSettingsRow(icon: "bell", title: "Notifications", subtitle: "Manage alerts")
                        ParentSettingsRow(icon: "person.2", title: "Switch Child", subtitle: "If you have multiple children")
                    }
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    // Support section
                    VStack(spacing: 0) {
                        ParentSettingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQs and contact")
                        ParentSettingsRow(icon: "lock.shield", title: "Privacy", subtitle: "Data and permissions")
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

// MARK: - Parent Settings Row

struct ParentSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
        }
        .padding(LadderSpacing.lg)
    }
}

// MARK: - Parent Route Resolver

enum ParentRouteResolver {
    @ViewBuilder
    static func resolve(_ route: Route) -> some View {
        switch route {
        case .parentDashboard:
            ParentDashboardView()
        case .peerComparison:
            PeerComparisonView()
        default:
            FeatureInProgressView(
                title: "Coming Soon",
                icon: "hammer",
                description: "This feature is being built for the parent portal.",
                features: []
            )
        }
    }
}

#Preview {
    ParentTabView()
        .environment(AppCoordinator())
        .environment(AuthManager())
}
