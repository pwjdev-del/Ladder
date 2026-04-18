import Foundation

@Observable
final class AppSyncManager {
    static let shared = AppSyncManager()
    private init() {}

    var isConnected: Bool = false

    // TODO: Initialize with AWSAppSyncClient when SDK is added

    // GraphQL mutation
    func mutate<T: Encodable>(operation: String, variables: T) async throws -> Data {
        // TODO: Execute GraphQL mutation via AppSync
        fatalError("AppSync not configured. Add aws-sdk-swift SPM package.")
    }

    // GraphQL query
    func query(operation: String, variables: [String: Any]? = nil) async throws -> Data {
        // TODO: Execute GraphQL query via AppSync
        fatalError("AppSync not configured. Add aws-sdk-swift SPM package.")
    }

    // Real-time subscription
    func subscribe(operation: String, handler: @escaping (Data) -> Void) {
        // TODO: Subscribe to AppSync subscription
        // Used for counselor real-time updates
    }

    func disconnect() {
        isConnected = false
    }

    /// Fire a queued mutation. Returns true on confirmed send so the queue can drop it.
    /// While AppSync is not wired, this always returns false so mutations stay queued
    /// for replay once the backend is configured.
    func send(operation: String, payload: Data) async -> Bool {
        guard isConnected else {
            Log.info("AppSync not connected; mutation \(operation) staying in queue.")
            return false
        }
        // TODO: Execute GraphQL mutation via AppSync once SDK is wired.
        return false
    }
}
