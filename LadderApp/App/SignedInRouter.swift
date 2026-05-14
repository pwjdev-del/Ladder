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
    case employee
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
        case .employee:  return .employee
        }
    }
}

// MARK: - Router

public struct SignedInRouter: View {
    public let session: SignedInSession
    @Environment(\.dismiss) private var dismiss
    // Observe TenantContext so the router re-renders once claim is bound.
    @ObservedObject private var tenant = TenantContext.shared

    /// Non-nil when a SwiftData wipe failure occurred during sign-out.
    /// Drives the blocking wipe-failure alert. Nil means no alert is shown.
    @State private var wipeFailureReason: String?

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
                case .employee:  EmployeeDashboardView(onLogout: logout)
                }
            }
            // Wipe-failure alert: blocking, no "continue anyway" path.
            // The user must retry or force-quit. Completing sign-out with
            // residual on-disk PII would expose Student A's data to Student B
            // on a shared device — intentionally no dismiss-without-action button.
            .alert(
                "Couldn't Finish Signing Out",
                isPresented: Binding(
                    get: { wipeFailureReason != nil },
                    set: { if !$0 { wipeFailureReason = nil } }
                )
            ) {
                Button("Try Again") {
                    wipeFailureReason = nil
                    logout()
                }
                Button("Cancel", role: .cancel) {
                    // User stays signed in. No stale data leak possible because
                    // sign-out was intentionally NOT completed when wipe failed.
                    wipeFailureReason = nil
                }
                // No "Continue Anyway" button — that is the whole risk.
            } message: {
                Text(
                    "Your local data couldn't be cleared for safety reasons. " +
                    "Please force-quit Ladder and try again. " +
                    "If this keeps happening, contact support."
                )
            }
        )
    }

    private func logout() {
        // M4 — sign out the backend session before dismissing so the Keychain/GoTrue
        // session is cleared and a fresh sign-in is required on next launch.
        //
        // On LadderAuthError.wipeFailed: signOut() did NOT clear GoTrue — the user
        // remains authenticated with their existing session intact. We surface the
        // blocking wipe-failure alert so they can retry or force-quit. We never
        // dismiss here on failure: doing so would complete the sign-out flow without
        // the wipe, opening the Student A → Student B PII leak.
        Task {
            do {
                try await SupabaseAuthService.shared.signOut()
                await MainActor.run { dismiss() }
            } catch LadderAuthError.wipeFailed(let reason) {
                await MainActor.run { wipeFailureReason = reason }
            } catch {
                // Non-wipe errors (network, GoTrue): surface via the same alert
                // with a generic message so sign-out failures are never silent.
                await MainActor.run {
                    wipeFailureReason = error.localizedDescription
                }
            }
        }
    }
}
