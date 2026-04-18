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

    // Replay all queued mutations when back online
    func replayQueue() async {
        guard isOnline else { return }
        var remaining: [QueuedMutation] = []
        for var mutation in queue {
            let success = await AppSyncManager.shared.send(
                operation: mutation.operation,
                payload: mutation.payload
            )
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
