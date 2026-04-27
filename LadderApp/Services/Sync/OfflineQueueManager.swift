import Foundation

@Observable
final class OfflineQueueManager {
    static let shared = OfflineQueueManager()
    private init() {}

    struct QueuedMutation: Codable, Identifiable {
        let id: UUID
        let operation: String
        let payload: Data
        let timestamp: Date
        var retryCount: Int = 0
    }

    var queue: [QueuedMutation] = []
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

    // Replay all queued mutations when back online.
    // TODO(Batch 5): wire real Supabase mutation sender here. AppSyncManager
    // (AWS GraphQL) was deleted in Batch 3 — this stub returns false so mutations
    // stay queued until the Supabase sync path is implemented.
    func replayQueue() async {
        guard isOnline else { return }
        var remaining: [QueuedMutation] = []
        for var mutation in queue {
            let success = await sendMutation(operation: mutation.operation, payload: mutation.payload)
            if success {
                continue
            }
            mutation.retryCount += 1
            // Drop after 5 attempts to avoid an infinite retry loop.
            if mutation.retryCount < 5 {
                remaining.append(mutation)
            } else {
                Log.warn("Dropping offline mutation \(mutation.operation) after 5 retries.")
            }
        }
        queue = remaining
        save()
    }

    /// Stub sender — always returns false until Supabase sync is wired (Batch 5).
    private func sendMutation(operation: String, payload: Data) async -> Bool {
        // TODO(Batch 5): call Supabase RPC / REST with operation + payload
        return false
    }

    private func save() {
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: "offline_queue")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "offline_queue"),
           let loaded = try? JSONDecoder().decode([QueuedMutation].self, from: data) {
            queue = loaded
        }
    }
}
