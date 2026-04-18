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
    /// Cheap email-prefix routing for the seeded test accounts.
    /// Real role comes from JWT claim once SupabaseAuthService ships.
    public static func role(for email: String) -> SignedInRole {
        let lower = email.lowercased()
        if lower.hasPrefix("admin.") { return .admin }
        if lower.hasPrefix("counselor.") { return .counselor }
        if lower.hasPrefix("parent.") { return .parent }
        let studentPrefixes = ["alice.", "bob.", "carol.", "maya.", "noah.", "kai.", "zed."]
        if studentPrefixes.contains(where: { lower.hasPrefix($0) }) { return .student }
        return .student
    }

    /// Grade lookup for the seeded student accounts (§ADR-007 pivot to 9–12).
    public static func gradeLevel(for email: String) -> Int? {
        switch email.lowercased() {
        case "alice.lwrpa@ladder.test": return 10
        case "bob.lwrpa@ladder.test":   return 11
        case "carol.lwrpa@ladder.test": return 12
        case "maya.smith@ladder.test":  return 9
        case "noah.smith@ladder.test":  return 11
        case "kai.jones@ladder.test":   return 10
        case "zed.beta@ladder.test":    return 11
        default: return nil
        }
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
