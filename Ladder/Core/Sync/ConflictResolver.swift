import Foundation

@Observable
final class ConflictResolver {
    static let shared = ConflictResolver()
    private init() {}

    enum Strategy { case lastWriteWins, clientWins, serverWins, manual }

    struct Conflict {
        let modelType: String
        let recordId: String
        let localValue: Any
        let serverValue: Any
        let localTimestamp: Date
        let serverTimestamp: Date
    }

    // Resolve conflict based on strategy
    func resolve(_ conflict: Conflict, strategy: Strategy = .lastWriteWins) -> ConflictResolution {
        switch strategy {
        case .lastWriteWins:
            return conflict.localTimestamp > conflict.serverTimestamp ? .useLocal : .useServer
        case .clientWins:
            return .useLocal
        case .serverWins:
            return .useServer
        case .manual:
            return .needsManualResolution
        }
    }

    enum ConflictResolution {
        case useLocal, useServer, needsManualResolution
    }
}
