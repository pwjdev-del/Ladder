import Foundation
import Network

/// Observes network reachability and kicks off offline-queue replay when we
/// transition from offline → online.
@MainActor
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private(set) var isOnline: Bool = true
    private(set) var isExpensive: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.ladder.network.monitor")
    private var started = false

    private init() {}

    static let didChange = Notification.Name("NetworkMonitor.didChange")

    func start() {
        guard !started else { return }
        started = true

        monitor.pathUpdateHandler = { [weak self] path in
            let nowOnline = path.status == .satisfied
            let expensive = path.isExpensive
            Task { @MainActor [weak self] in
                guard let self else { return }
                let wasOnline = self.isOnline
                self.isOnline = nowOnline
                self.isExpensive = expensive
                OfflineQueueManager.shared.isOnline = nowOnline
                NotificationCenter.default.post(name: Self.didChange, object: nowOnline)
                if !wasOnline, nowOnline {
                    Task { await OfflineQueueManager.shared.replayQueue() }
                }
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
        started = false
    }
}
