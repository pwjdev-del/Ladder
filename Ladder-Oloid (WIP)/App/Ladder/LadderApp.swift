import SwiftUI
import SwiftData

@main
struct LadderApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var authManager = AuthManager()
    @State private var theme = LadderTheme()
    private let modelContainer: ModelContainer

    init() {
        let container = createModelContainer()
        self.modelContainer = container
        // Expose to AuthManager so sign-out/sign-up can wipe user-scoped data
        AuthManager.sharedContainer = container
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.authState {
                case .loading:
                    SplashScreenView()

                case .unauthenticated:
                    LoginView()

                case .consentRequired:
                    ConsentView()

                case .onboarding:
                    OnboardingContainerView()

                case .authenticated:
                    switch authManager.userRole {
                    case .student:
                        MainTabView()
                    case .parent:
                        NavigationStack { ParentDashboardView() }
                    case .counselor:
                        NavigationStack { CounselorDashboardView() }
                    case .schoolAdmin:
                        NavigationStack { SchoolAdminDashboardView() }
                    }
                }
            }
            .environment(coordinator)
            .environment(authManager)
            .environment(theme)
            .preferredColorScheme(theme.colorScheme)
            .task {
                await authManager.checkSession()
            }
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - Splash Screen (shown during auth check)
// Matches Stitch ipad_splash_screen: full green gradient, diamond logo, editorial feel

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // Full green gradient background
            LinearGradient(
                colors: [LadderColors.primary, LadderColors.primaryContainer, Color(red: 0.19, green: 0.31, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow blobs
            Circle()
                .fill(LadderColors.secondaryFixed.opacity(0.03))
                .frame(width: 500, height: 500)
                .blur(radius: 120)
                .offset(x: 150, y: -200)

            Circle()
                .fill(LadderColors.secondaryFixed.opacity(0.05))
                .frame(width: 600, height: 600)
                .blur(radius: 150)
                .offset(x: -200, y: 200)

            // Central identity cluster
            VStack(spacing: LadderSpacing.xxl) {
                // Diamond logo
                ZStack {
                    // Glow
                    RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                        .fill(LadderColors.secondaryFixed.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(45))
                        .blur(radius: 40)

                    // Diamond container
                    RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                        .fill(.white)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(45))
                        .shadow(color: Color(red: 0.79, green: 0.95, blue: 0.30).opacity(0.15), radius: 60, y: 10)

                    // Graduation cap icon (not rotated)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(LadderColors.primary)
                }

                // Wordmark
                VStack(spacing: LadderSpacing.md) {
                    Text("LADDER")
                        .font(LadderTypography.displayLargeItalic)
                        .foregroundStyle(.white)
                        .tracking(-2)

                    Text("LEADING STUDENTS TO THEIR OWN SUCCESS")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.secondaryFixed.opacity(0.9))
                        .tracking(4)
                }
            }

            // Bottom version label
            VStack {
                Spacer()
                HStack(spacing: LadderSpacing.md) {
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 48, height: 1)
                    Text("ACADEMIC ATELIER")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(3)
                    Rectangle().fill(.white.opacity(0.3)).frame(width: 48, height: 1)
                }
                .padding(.bottom, LadderSpacing.xxl)
            }
        }
    }
}
