import SwiftUI
import os

// Role-based post-sign-in routing. The auth views build a SignedInSession,
// push SignedInRouter, and SignedInRouter dispatches to the correct
// role dashboard. Each dashboard reads the session + the @Binding for
// logout through the shared `SessionState` environment object.

public enum SignedInRole: String, Sendable {
    case admin
    case counselor
    case student
    case parent
    case founder
}

public struct SignedInSession: Hashable, Sendable {
    public let role: SignedInRole
    public let displayName: String
    public let tenantName: String
    public let gradeLevel: Int?   // 9-12 for students; nil otherwise

    public init(role: SignedInRole,
                displayName: String,
                tenantName: String,
                gradeLevel: Int? = nil) {
        self.role = role
        self.displayName = displayName
        self.tenantName = tenantName
        self.gradeLevel = gradeLevel
    }
}

// MARK: - RoleDetector (internal only — no public API surface)

// RoleDetector is kept as a private implementation detail. Public callers
// should build SignedInSession directly from TenantContext after sign-in,
// as B2CLoginView and SchoolLoginView already do.
private enum RoleDetector {
    /// Maps an AppRole claim to a SignedInRole.
    @MainActor
    static func roleFromClaim(_ claim: TenantClaim) -> SignedInRole {
        switch claim.role {
        case .admin:     return .admin
        case .counselor: return .counselor
        case .parent:    return .parent
        case .founder:   return .founder
        case .student:   return .student
        }
    }
}

// MARK: - Router

public struct SignedInRouter: View {
    public let session: SignedInSession
    @Environment(\.dismiss) private var dismiss
    // Observe TenantContext so the router re-renders once claim is bound.
    @ObservedObject private var tenant = TenantContext.shared

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        // M3 — guard: if the claim hasn't been bound yet (race during sign-in),
        // show a splash rather than dispatching to a role dashboard with nil state.
        guard tenant.claim != nil else {
            return AnyView(
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                }
            )
        }
        return AnyView(
            Group {
                switch session.role {
                case .admin:     AdminDashboardView(session: session, onLogout: logout)
                case .counselor: CounselorDashboardView(session: session, onLogout: logout)
                case .student:   StudentDashboardView(session: session, onLogout: logout)
                case .parent:    ParentDashboardView(session: session, onLogout: logout)
                case .founder:   FounderDashboardView(onLogout: logout)
                }
            }
        )
    }

    private func logout() {
        // M4 — sign out the backend session before dismissing so the Keychain/GoTrue
        // session is cleared and a fresh sign-in is required on next launch.
        Task {
            try? await SupabaseAuthService.shared.signOut()
            await MainActor.run { dismiss() }
        }
    }
}
