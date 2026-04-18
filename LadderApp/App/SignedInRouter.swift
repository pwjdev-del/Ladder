import SwiftUI

// Role-based post-sign-in routing. The auth views determine the role from
// the email (seeded test accounts) and push the matching dashboard.
// Once SupabaseAuthService lands, the role comes from the JWT claim via
// TenantContext.

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

    public init(role: SignedInRole, displayName: String, tenantName: String) {
        self.role = role
        self.displayName = displayName
        self.tenantName = tenantName
    }
}

public enum RoleDetector {
    /// Cheap email-prefix routing used only for the seeded test accounts.
    /// Real role comes from the JWT `role` claim once SupabaseAuthService ships.
    public static func role(for email: String) -> SignedInRole {
        let lower = email.lowercased()
        if lower.hasPrefix("admin.")    { return .admin }
        if lower.hasPrefix("counselor.") { return .counselor }
        if lower.hasPrefix("parent.")   { return .parent }
        // Specific student seeds
        let studentPrefixes = ["alice.", "bob.", "carol.", "maya.", "noah.", "kai.", "zed."]
        if studentPrefixes.contains(where: { lower.hasPrefix($0) }) { return .student }
        return .student
    }
}

/// Dispatches to the correct role dashboard.
public struct SignedInRouter: View {
    public let session: SignedInSession

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        switch session.role {
        case .admin:
            AdminDashboardView(session: session)
        case .counselor:
            CounselorDashboardView(session: session)
        case .student:
            StudentDashboardView(session: session)
        case .parent:
            ParentDashboardView(session: session)
        case .founder:
            FounderDashboardView()
        }
    }
}
