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

    public func clear() {
        claim = nil
        tenantDisplayName = nil
        tenantPrimaryColorHex = nil
        tenantLogoKey = nil
    }

    public var isFounderSession: Bool {
        claim?.role == .founder
    }

    public var isStaffSession: Bool {
        guard let r = claim?.role else { return false }
        return r == .counselor || r == .admin
    }

    /// Guard helper — screens that must never render for a founder MUST call this
    /// at screen root. Uses `preconditionFailure` (NOT `assertionFailure`) so the
    /// trap survives Release builds. §14.4 is a hard stop; a silently-allowed
    /// founder-into-tenant-data render in Release is unacceptable.
    public func requireNonFounder(_ context: StaticString = #function) {
        if isFounderSession {
            preconditionFailure("§14.4 violation: founder session reached tenant-data surface: \(context)")
        }
    }
}

// MARK: - SwiftUI view-root guard

import SwiftUI

public struct RequireNonFounderModifier: ViewModifier {
    @EnvironmentObject private var tenant: TenantContext
    let context: StaticString

    public func body(content: Content) -> some View {
        if tenant.isFounderSession {
            // In Release we also trip preconditionFailure via the guard below, but
            // this view branch keeps the surface type-safe for testing and ensures
            // we never render tenant fields even if the precondition is disabled
            // by a misconfigured compiler flag.
            FounderBlockedView(context: context)
                .onAppear { tenant.requireNonFounder(context) }
        } else {
            content
        }
    }
}

public extension View {
    /// Attach to the root of any screen that must not render for founder sessions.
    func requireNonFounder(_ context: StaticString = #function) -> some View {
        modifier(RequireNonFounderModifier(context: context))
    }
}

public struct FounderBlockedView: View {
    public let context: StaticString
    public var body: some View {
        ContentUnavailableView(
            "Not available for founder sessions",
            systemImage: "lock.shield.fill",
            description: Text("§14.4 — founder sessions are denied tenant data at the API, DB, and UI layers.")
        )
    }
}
