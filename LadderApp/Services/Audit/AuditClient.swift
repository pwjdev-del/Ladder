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

    private let endpoint: URL
    private let session: URLSession

    public init(endpoint: URL = URL(string: "https://edge.ladder.app/functions/v1/audit-ingest")!,
                session: URLSession = TLSPinnedSessionFactory.shared.session) {
        self.endpoint = endpoint
        self.session = session
    }

    public func record(_ event: AuditEvent, accessToken: String) async {
        // Fire-and-forget; a failed audit write must not block a user action,
        // but server-side RLS-gated inserts are still the authoritative log.
        var req = URLRequest(url: endpoint)
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
