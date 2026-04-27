import SwiftUI

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

public enum RoleDetector {
    /// Returns the role from the JWT claim stored in TenantContext (authoritative).
    /// In DEBUG, falls back to email-prefix heuristic when TenantContext has no claim
    /// (e.g., running against a local Supabase seed before claim schema is deployed).
    @MainActor
    public static func roleFromJWT() -> SignedInRole {
        if let claim = TenantContext.shared.claim {
            switch claim.role {
            case .admin:     return .admin
            case .counselor: return .counselor
            case .parent:    return .parent
            case .founder:   return .founder
            case .student:   return .student
            }
        }
        #if DEBUG
        // No claim yet — return student as safe default.
        // TODO: remove fallback once all seed accounts have role claims in JWT.
        return .student
        #else
        // Release: no claim means something went wrong in bindTenantContext; treat as student.
        return .student
        #endif
    }

    /// Email-prefix fallback retained for debug convenience only.
    /// DO NOT call this in production flows — use roleFromJWT() instead.
    @available(*, deprecated, message: "Use RoleDetector.roleFromJWT() — role must come from JWT claim.")
    public static func role(for email: String) -> SignedInRole {
        #if DEBUG
        let lower = email.lowercased()
        if lower.hasPrefix("admin.") { return .admin }
        if lower.hasPrefix("counselor.") { return .counselor }
        if lower.hasPrefix("parent.") { return .parent }
        return .student
        #else
        return .student
        #endif
    }
}

public struct SignedInRouter: View {
    public let session: SignedInSession
    @Environment(\.dismiss) private var dismiss

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        Group {
            switch session.role {
            case .admin:     AdminDashboardView(session: session, onLogout: logout)
            case .counselor: CounselorDashboardView(session: session, onLogout: logout)
            case .student:   StudentDashboardView(session: session, onLogout: logout)
            case .parent:    ParentDashboardView(session: session, onLogout: logout)
            case .founder:   FounderDashboardView(onLogout: logout)
            }
        }
    }

    private func logout() {
        // Pop back to Landing via NavigationStack unwind. The SignedInRouter
        // is pushed onto the NavigationStack from the auth views, so a
        // single dismiss() returns to the login screen, and the login
        // screen's own state resets the form.
        dismiss()
    }
}
