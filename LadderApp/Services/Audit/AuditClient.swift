import Foundation

// CLAUDE.md §16.4 — audit log. The iOS client fires best-effort audit writes
// for local-only actions (e.g., quiz started, schedule draft saved); the
// authoritative audit log is server-side and appended by the Edge Functions
// that service the real mutations.
//
// This client NEVER sends raw PII payload — only the action + metadata
// (counts, IDs, feature names).

public struct AuditEvent: Codable, Sendable {
    public let action: String
    public let targetType: String?
    public let targetId: UUID?
    public let metadata: [String: String]
}

public actor AuditClient {
    public static let shared = AuditClient()

    // endpoint is resolved lazily per call so that AppConfiguration is read
    // after preflightOrCrash() has run. An override may be injected for tests.
    private let endpointOverride: URL?
    private let session: URLSession

    public init(endpointOverride: URL? = nil,
                session: URLSession = TLSPinnedSessionFactory.shared.session) {
        self.endpointOverride = endpointOverride
        self.session = session
    }

    // Resolved endpoint: override (tests) → AppConfiguration (production).
    // AppConfiguration.auditBaseURL routes to:
    //   https://seicofzlgwjqkggscvao.supabase.co/functions/v1/audit-ingest
    private var resolvedEndpoint: URL {
        endpointOverride ?? AppConfiguration.auditBaseURL
    }

    public func record(_ event: AuditEvent, accessToken: String) async {
        // Fire-and-forget; a failed audit write must not block a user action,
        // but server-side RLS-gated inserts are still the authoritative log.
        var req = URLRequest(url: resolvedEndpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        do {
            req.httpBody = try JSONEncoder().encode(event)
            _ = try await session.data(for: req)
        } catch {
            // Intentional silence — failure is acceptable for client-side audit.
        }
    }
}
