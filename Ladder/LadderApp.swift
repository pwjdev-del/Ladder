import SwiftUI
import SwiftData

@main
struct LadderApp: App {
    @State private var coordinator = AppCoordinator()
    @State private var authManager = AuthManager()
    @State private var theme = LadderTheme()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.authState {
                case .loading:
                    SplashScreenView()

                case .unauthenticated:
                    LoginView()

                case .onboarding:
                    OnboardingContainerView()

                case .authenticated:
                    MainTabView()
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
        .modelContainer(createModelContainer())
    }
}

// MARK: - Splash Screen (shown during auth check)

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LadderColors.surface
                .ignoresSafeArea()

            VStack(spacing: LadderSpacing.lg) {
                // Logo circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LadderColors.primaryContainer, LadderColors.primary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 120, height: 120)
                        .ladderShadow(LadderElevation.glow)

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }

                VStack(spacing: LadderSpacing.sm) {
                    Text("Ladder")
                        .font(LadderTypography.displaySmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Leading Students to Their Own Success")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }
}
