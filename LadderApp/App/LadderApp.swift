import SwiftUI
import SwiftData

@main
struct LadderApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var authManager = AuthManager()
    @State private var theme = LadderTheme()
    @State private var seeder = CollegeDataSeeder()

    init() {
        // §16.1/§16.3 — preflight guard: Release builds crash at launch if the
        // TLS pin bytes are still placeholder. See ADR-004 rotation runbook.
        PinnedKeys.preflightOrCrash()

        let cache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            directory: nil
        )
        URLCache.shared = cache
        NetworkMonitor.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
                .environment(authManager)
                .environment(theme)
                .environment(seeder)
                .preferredColorScheme(theme.colorScheme)
        }
        .modelContainer(createModelContainer())
    }
}

// MARK: - Root View (has access to modelContext for seeding)

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(CollegeDataSeeder.self) private var seeder
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if seeder.isSeeding || !seeder.isComplete {
                DataLoadingView(progress: seeder.progress)
            } else {
                switch authManager.authState {
                case .loading:
                    SplashScreenView()
                case .unauthenticated:
                    LoginView()
                case .onboarding:
                    onboardingView
                case .authenticated:
                    if authManager.isFirstLogin {
                        ForcePasswordChangeView()
                    } else {
                        authenticatedView
                    }
                }
            }
        }
        .task {
            await seeder.seedIfNeeded(context: context)
            await authManager.checkSession()
        }
    }

    // Each role gets their OWN onboarding — parents don't fill out student info
    @ViewBuilder
    private var onboardingView: some View {
        switch authManager.userRole {
        case .student:
            OnboardingContainerView()
        case .parent:
            ParentOnboardingView()
        case .counselor:
            CounselorOnboardingView()
        case .schoolAdmin:
            SchoolAdminOnboardingView()
        }
    }

    @ViewBuilder
    private var authenticatedView: some View {
        switch authManager.userRole {
        case .student:
            MainTabView()
        case .parent:
            ParentTabView()
        case .counselor:
            CounselorTabView()
        case .schoolAdmin:
            AdminTabView()
        }
    }
}

// MARK: - Data Loading View (shown during first-launch database seeding)

struct DataLoadingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            LadderColors.surface
                .ignoresSafeArea()

            VStack(spacing: LadderSpacing.xl) {
                Image("LadderLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: LadderColors.primary.opacity(0.3), radius: 10, y: 3)

                VStack(spacing: LadderSpacing.sm) {
                    Text("Building Your College Database")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Loading 6,300+ colleges...")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                VStack(spacing: LadderSpacing.xs) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LadderColors.surfaceContainerLow)
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [LadderColors.primary, LadderColors.secondaryFixed],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 12)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                    .frame(height: 12)

                    Text("\(Int(progress * 100))%")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.horizontal, LadderSpacing.xxl)
            }
        }
    }
}

// MARK: - Splash Screen (shown during auth check)

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LadderColors.surface
                .ignoresSafeArea()

            VStack(spacing: LadderSpacing.lg) {
                // Real Ladder logo
                Image("LadderLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(color: LadderColors.primary.opacity(0.3), radius: 15, y: 5)

                VStack(spacing: LadderSpacing.sm) {
                    Text("Ladder")
                        .font(LadderTypography.displaySmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Guiding Students to Success")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }
}
