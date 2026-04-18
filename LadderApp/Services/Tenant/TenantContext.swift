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

    /// Guard helper — screens that must never render for a founder call this first.
    /// Returns false for founder sessions so the UI refuses to render tenant data.
    public func assertNotFounder(_ context: StaticString = #function) -> Bool {
        if isFounderSession {
            assertionFailure("Founder session reached tenant-data surface: \(context) — CLAUDE.md §14.4 violation")
            return false
        }
        return true
    }
}
