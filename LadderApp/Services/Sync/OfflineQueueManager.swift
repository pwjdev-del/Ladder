import Foundation
import Supabase

// Offline queue for mutations that couldn't reach Supabase.
//
// Bug-fix (S2-7): previously every mutation was silently dropped after 5
// retries via Log.warn. Now: a `dropped` sub-queue keeps failed mutations
// so they're visible (and recoverable) instead of vanishing. Quarantined
// mutations are exposed via `quarantined` for a future "Pending sync issues"
// UI to surface them to the user.

@Observable
final class OfflineQueueManager {
    static let shared = OfflineQueueManager()
    private init() {}

    struct QueuedMutation: Codable, Identifiable {
        let id: UUID
        let operation: String           // "insert:table" / "update:table" / "rpc:fnName"
        let payload: Data
        let timestamp: Date
        var retryCount: Int = 0
        var lastError: String?
    }

    var queue: [QueuedMutation] = []
    var quarantined: [QueuedMutation] = []   // mutations that exceeded retry budget
    var isOnline: Bool = true

    // Add mutation to offline queue
    func enqueue(operation: String, payload: Data) {
        let mutation = QueuedMutation(
            id: UUID(),
            operation: operation,
            payload: payload,
            timestamp: Date()
        )
        queue.append(mutation)
        save()
    }

    // Replay all queued mutations when back online. Failed mutations beyond
    // the retry budget are moved to `quarantined` (NOT dropped).
    func replayQueue() async {
        guard isOnline else { return }
        var remaining: [QueuedMutation] = []
        for var mutation in queue {
            let (ok, errorMsg) = await sendMutation(operation: mutation.operation, payload: mutation.payload)
            if ok {
                continue
            }
            mutation.retryCount += 1
            mutation.lastError = errorMsg
            if mutation.retryCount < 5 {
                remaining.append(mutation)
            } else {
                quarantined.append(mutation)
                Log.warn("Quarantining offline mutation \(mutation.operation) after 5 retries: \(errorMsg ?? "unknown")")
            }
        }
        queue = remaining
        save()
    }

    /// Force a retry of every quarantined mutation. Caller is the user via a
    /// "Retry pending sync issues" button.
    func retryQuarantined() async {
        let toRetry = quarantined
        quarantined = []
        queue.append(contentsOf: toRetry.map { var m = $0; m.retryCount = 0; m.lastError = nil; return m })
        await replayQueue()
    }

    /// Permanently discard a quarantined mutation. Caller is the user from
    /// the same "Pending sync issues" UI.
    func discard(_ id: UUID) {
        quarantined.removeAll { $0.id == id }
        save()
    }

    /// Real Supabase mutation sender. `operation` encodes the table + verb;
    /// payload is the row-set JSON to send.
    ///   "insert:tableName" → POST
    ///   "update:tableName:id=eq.<uuid>" → PATCH
    ///   "rpc:fnName" → call RPC
    private func sendMutation(operation: String, payload: Data) async -> (Bool, String?) {
        let client = await SupabaseAuthService.shared.supabase
        let parts = operation.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { return (false, "malformed operation") }
        let verb = parts[0]
        let target = parts[1]

        do {
            switch verb {
            case "insert":
                _ = try await client.from(target).insert(AnyEncodable(payload)).execute()
            case "update":
                // Format: update:tableName:column=value
                guard parts.count == 3 else { return (false, "missing where clause") }
                let where_ = parts[2]
                let kv = where_.split(separator: "=", maxSplits: 1).map(String.init)
                guard kv.count == 2 else { return (false, "malformed where clause") }
                _ = try await client
                    .from(target)
                    .update(AnyEncodable(payload))
                    .eq(kv[0], value: kv[1])
                    .execute()
            case "rpc":
                _ = try await client.rpc(target, params: AnyEncodable(payload)).execute()
            default:
                return (false, "unknown verb \(verb)")
            }
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }

    private func save() {
        struct PersistedState: Codable {
            let queue: [QueuedMutation]
            let quarantined: [QueuedMutation]
        }
        let state = PersistedState(queue: queue, quarantined: quarantined)
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "offline_queue_v2")
        }
    }

    func load() {
        struct PersistedState: Codable {
            let queue: [QueuedMutation]
            let quarantined: [QueuedMutation]
        }
        if let data = UserDefaults.standard.data(forKey: "offline_queue_v2"),
           let loaded = try? JSONDecoder().decode(PersistedState.self, from: data) {
            queue = loaded.queue
            quarantined = loaded.quarantined
        } else if let legacy = UserDefaults.standard.data(forKey: "offline_queue"),
                  let loaded = try? JSONDecoder().decode([QueuedMutation].self, from: legacy) {
            // Migrate from v1.
            queue = loaded
            UserDefaults.standard.removeObject(forKey: "offline_queue")
            save()
        }
    }
}

// Wrap raw JSON Data as Encodable so we can pass it through the SDK's
// generic `.insert/.update/.rpc(params:)` interface without re-decoding.
private struct AnyEncodable: Encodable {
    let raw: Data
    init(_ raw: Data) { self.raw = raw }
    func encode(to encoder: Encoder) throws {
        // Decode the raw JSON into a generic structure and re-encode.
        let value = try JSONSerialization.jsonObject(with: raw, options: [])
        let re = try JSONSerialization.data(withJSONObject: value)
        var c = encoder.singleValueContainer()
        try c.encode(JSONValue(re))
    }
}

private struct JSONValue: Encodable {
    let data: Data
    init(_ data: Data) { self.data = data }
    func encode(to encoder: Encoder) throws {
        let value = try JSONSerialization.jsonObject(with: data)
        try encodeAny(value, to: encoder)
    }
    private func encodeAny(_ value: Any, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as String: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as Bool: try c.encode(v)
        case let v as [Any]:
            try c.encode(v.map { AnyValueWrapper($0) })
        case let v as [String: Any]:
            try c.encode(v.mapValues { AnyValueWrapper($0) })
        case is NSNull:
            try c.encodeNil()
        default:
            try c.encodeNil()
        }
    }
}

private struct AnyValueWrapper: Encodable {
    let value: Any
    init(_ value: Any) { self.value = value }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as String: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as Bool: try c.encode(v)
        case let v as [Any]: try c.encode(v.map { AnyValueWrapper($0) })
        case let v as [String: Any]: try c.encode(v.mapValues { AnyValueWrapper($0) })
        case is NSNull: try c.encodeNil()
        default: try c.encodeNil()
        }
    }
}
