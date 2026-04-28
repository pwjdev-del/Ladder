import Foundation
import Combine

// CLAUDE.md §4 — tenant context. Every authenticated network request reads
// from this, and every RLS-governed query on the backend sees `app.tenant_id`
// derived from the JWT that TenantContext manages.

public enum AppRole: String, Codable, Sendable {
    case student
    case parent
    case counselor
    case admin
    case founder
    /// Ladder internal staff — handles transfer approvals. Cannot access tenant data.
    case employee
}

public struct TenantClaim: Codable, Sendable, Equatable {
    public let tenantId: UUID?      // nil for founder sessions
    public let role: AppRole
    public let userId: UUID
    public let expiresAt: Date
}

@MainActor
public final class TenantContext: ObservableObject {
    public static let shared = TenantContext()

    @Published public private(set) var claim: TenantClaim?
    @Published public private(set) var tenantDisplayName: String?
    @Published public private(set) var tenantPrimaryColorHex: String?
    @Published public private(set) var tenantLogoKey: String?
    /// Cached from `students.grade_level` after sign-in. Nil for non-student roles.
    @Published public private(set) var studentGradeLevel: Int?

    private init() {}

    public func bind(_ claim: TenantClaim,
                     displayName: String?,
                     primaryColorHex: String?,
                     logoKey: String?) {
        self.claim = claim
        self.tenantDisplayName = displayName
        self.tenantPrimaryColorHex = primaryColorHex
        self.tenantLogoKey = logoKey
    }

    public func setStudentGradeLevel(_ grade: Int?) {
        studentGradeLevel = grade
    }

    public func clear() {
        claim = nil
        tenantDisplayName = nil
        tenantPrimaryColorHex = nil
        tenantLogoKey = nil
        studentGradeLevel = nil
    }

    public var isFounderSession: Bool {
        claim?.role == .founder
    }

    public var isEmployeeSession: Bool {
        claim?.role == .employee
    }

    /// True for both founder and employee — neither role may access tenant data.
    public var isLadderStaffSession: Bool {
        claim?.role == .founder || claim?.role == .employee
    }

    public var isStaffSession: Bool {
        guard let r = claim?.role else { return false }
        return r == .counselor || r == .admin
    }

    /// Guard helper — screens that must never render for a founder OR employee MUST call this
    /// at screen root. Uses `preconditionFailure` (NOT `assertionFailure`) so the
    /// trap survives Release builds. §14.4 is a hard stop; a silently-allowed
    /// staff-into-tenant-data render in Release is unacceptable.
    public func requireNonStaff(_ context: StaticString = #function) {
        if isLadderStaffSession {
            preconditionFailure("§14.4 violation: Ladder staff session reached tenant-data surface: \(context)")
        }
    }

    /// Deprecated alias — use `requireNonStaff`. Retained temporarily so call sites
    /// can be migrated one at a time without a build break.
    @available(*, deprecated, renamed: "requireNonStaff")
    public func requireNonFounder(_ context: StaticString = #function) {
        requireNonStaff(context)
    }
}

// MARK: - SwiftUI view-root guard

import SwiftUI

public struct RequireNonStaffModifier: ViewModifier {
    @EnvironmentObject private var tenant: TenantContext
    let context: StaticString

    public func body(content: Content) -> some View {
        if tenant.isLadderStaffSession {
            // In Release we also trip preconditionFailure via the guard below, but
            // this view branch keeps the surface type-safe for testing and ensures
            // we never render tenant fields even if the precondition is disabled
            // by a misconfigured compiler flag.
            StaffBlockedView(context: context)
                .onAppear { tenant.requireNonStaff(context) }
        } else {
            content
        }
    }
}

public extension View {
    /// Attach to the root of any screen that must not render for Ladder staff
    /// (founder or employee) sessions.
    func requireNonStaff(_ context: StaticString = #function) -> some View {
        modifier(RequireNonStaffModifier(context: context))
    }

    /// Deprecated alias — use `requireNonStaff`. Both founder and employee are now
    /// blocked by the same data-wall modifier.
    @available(*, deprecated, renamed: "requireNonStaff")
    func requireNonFounder(_ context: StaticString = #function) -> some View {
        modifier(RequireNonStaffModifier(context: context))
    }
}

public struct StaffBlockedView: View {
    public let context: StaticString
    public var body: some View {
        ContentUnavailableView(
            "Not available for Ladder staff sessions",
            systemImage: "lock.shield.fill",
            description: Text("§14.4 — founder and employee sessions are denied tenant data at the API, DB, and UI layers.")
        )
    }
}

/// Deprecated alias — use `StaffBlockedView`.
@available(*, deprecated, renamed: "StaffBlockedView")
public typealias FounderBlockedView = StaffBlockedView
