import SwiftUI

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

    init() {
        // §16.1 / §16.3 — Release builds crash at launch if TLS pins are
        // still placeholder bytes. Debug builds skip.
        PinnedKeys.preflightOrCrash()
    }

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(tenantContext)
                .environmentObject(flagClient)
        }
    }
}
