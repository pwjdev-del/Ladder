import SwiftUI
import SwiftData

// CLAUDE.md §3 — unauthenticated root is LandingView.
// Legacy prototype routing (AuthManager, AppCoordinator, CollegeDataSeeder,
// role-based tab routers) is quarantined under Features/Legacy and will be
// wired back in as SupabaseAuthService + TenantContext lands. See:
//   - docs/decisions/ADR-002-repo-layout-spec-§18.md
//   - docs/planning/pr-body.md "Recommended next 5 PRs"

@main
struct LadderApp: App {
    @StateObject private var tenantContext = TenantContext.shared
    @StateObject private var flagClient = FlagClient.shared

    private let modelContainer: ModelContainer = createModelContainer()

    init() {
        // §16.1 / §16.3 — Release builds crash at launch if TLS pins are
        // still placeholder bytes. Debug builds skip.
        PinnedKeys.preflightOrCrash()
        // §5 — Release builds crash if Supabase URL is still the placeholder
        // or anon key is empty. Prevents silent boot against a broken backend.
        AppConfiguration.preflightOrCrash()
        // S1-4 — Register the ModelContainer so SupabaseAuthService.signOut()
        // can wipe SwiftData on sign-out (shared-iPad PII leak fix).
        SwiftDataWipeRegistry.register(modelContainer)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(tenantContext)
                .environmentObject(flagClient)
                .modelContainer(modelContainer)
                // S3-1: cover the view in the iOS task-switcher snapshot so student
                // PII (SIA chat, crisis resources, grades) is never visible in the
                // app switcher. Modifier defined in App/PrivacyOverlay.swift.
                // TEMP: PrivacyOverlay.swift is on disk but NOT in the Xcode project
                // file, so the extension is invisible at compile time. Cached .o files
                // from earlier Xcode-IDE builds were masking this. Re-enable after
                // adding the file to the LadderApp target (Xcode → right-click App/
                // group → Add Files… → PrivacyOverlay.swift).
                // .privacyOverlay()
        }
    }
}

// MARK: - AppRootView
//
// Root view that handles three startup modes:
//   1. Normal (no persisted session): shows LandingView.
//   2. Normal (persisted Supabase session found in Keychain): restores session
//      and routes directly to the appropriate role dashboard — the user never
//      sees LandingView on subsequent launches while their token is valid.
//   3. -UITestMode: injects a mock student session (UITestBootstrap) and skips
//      auth UI entirely so XCUITests start from the student dashboard.
//
// Using a separate view keeps LadderApp.init() synchronous and avoids
// entangling test-only code with the Scene lifecycle.

private struct AppRootView: View {
    @EnvironmentObject private var tenantContext: TenantContext

    // Three states:
    //   nil        — still checking for a persisted session (splash shown)
    //   .some(nil) — no persisted session; show LandingView
    //   .some(.some(session)) — restored; route to dashboard
    @State private var restoredSession: SignedInSession?? = nil

#if DEBUG
    @State private var testSession: SignedInSession?
#endif

    var body: some View {
#if DEBUG
        if UITestBootstrap.isActive {
            Group {
                if let session = testSession {
                    SignedInRouter(session: session)
                } else {
                    // Blank splash while bootstrap populates TenantContext
                    Color.black.ignoresSafeArea()
                        .task {
                            await UITestBootstrap.bootstrapIfNeeded()
                            let student = MockStudent.shared
                            testSession = SignedInSession(
                                role: .student,
                                displayName: student.displayName,
                                tenantName: "Test School",
                                gradeLevel: student.gradeLevel
                            )
                        }
                }
            }
        } else {
            sessionAwareRoot
        }
#else
        sessionAwareRoot
#endif
    }

    // MARK: - Session-aware root (non-test path)

    @ViewBuilder
    private var sessionAwareRoot: some View {
        switch restoredSession {
        case .none:
            // Still checking — show a neutral splash to avoid a LandingView flash.
            Color.black.ignoresSafeArea()
                .task { await restoreSessionIfNeeded() }

        case .some(.none):
            // No persisted session — normal unauthenticated entry point.
            LandingView()

        case .some(.some(let session)):
            // Persisted session found — jump straight to the role dashboard.
            SignedInRouter(session: session)
        }
    }

    // MARK: - Session restore

    /// Checks the Keychain-backed Supabase session store. If a valid session
    /// exists, rebinds TenantContext (so SignedInRouter has a live claim) and
    /// builds a SignedInSession. On any error — expired token, no session,
    /// network failure — falls through to LandingView so the user can log in fresh.
    @MainActor
    private func restoreSessionIfNeeded() async {
        guard let supabaseSession = await SupabaseAuthService.shared.currentSession else {
            restoredSession = .some(nil)
            return
        }

        // currentSession (via client.auth.session) may return a locally-cached
        // session whose JWT is still valid without hitting the network. Re-bind
        // TenantContext from it so the role claim is populated before routing.
        do {
            try await SupabaseAuthService.shared.rebindFromSession(supabaseSession)
        } catch {
            // Rebind failed (e.g. role claim missing in Release) — treat as logged out.
            try? await SupabaseAuthService.shared.signOut()
            restoredSession = .some(nil)
            return
        }

        let claim = tenantContext.claim
        let role: SignedInRole = {
            switch claim?.role {
            case .admin:     return .admin
            case .counselor: return .counselor
            case .parent:    return .parent
            case .founder:   return .founder
            case .employee:  return .employee
            default:         return .student
            }
        }()
        let grade = tenantContext.studentGradeLevel
        restoredSession = .some(SignedInSession(
            role: role,
            displayName: String(supabaseSession.user.email?.split(separator: "@").first ?? ""),
            tenantName: tenantContext.tenantDisplayName ?? "Ladder",
            gradeLevel: grade
        ))
    }
}
