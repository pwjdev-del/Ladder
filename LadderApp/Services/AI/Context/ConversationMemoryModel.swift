import Foundation
import SwiftData

// SwiftData persistence layer for ConversationMemory.
// One row per student. The full ConversationMemory is stored as a Codable JSON
// blob — simpler than denormalizing 7 relationships and gives us schema evolution
// for free. Access via `memory` computed property.

@Model
final class ConversationMemoryModel {
    @Attribute(.unique) var studentId: String
    var dataJSON: Data?
    var updatedAt: Date

    init(studentId: String) {
        self.studentId = studentId
        self.dataJSON = nil
        self.updatedAt = Date()
    }

    var memory: ConversationMemory {
        get {
            guard let data = dataJSON,
                  let decoded = try? JSONDecoder.iso.decode(ConversationMemory.self, from: data)
            else { return .empty }
            return decoded
        }
        set {
            dataJSON = try? JSONEncoder.iso.encode(newValue)
            updatedAt = Date()
        }
    }
}

// MARK: - Store

enum ConversationMemoryStore {

    /// Load (or create) the memory row for this student.
    @MainActor
    static func load(studentId: String, context: ModelContext) -> ConversationMemory {
        fetchOrCreate(studentId: studentId, context: context).memory
    }

    /// Replace the stored memory for this student.
    @MainActor
    static func save(_ memory: ConversationMemory, studentId: String, context: ModelContext) {
        let row = fetchOrCreate(studentId: studentId, context: context)
        row.memory = memory
        try? context.save()
    }

    @MainActor
    private static func fetchOrCreate(studentId: String, context: ModelContext) -> ConversationMemoryModel {
        let target = studentId
        let descriptor = FetchDescriptor<ConversationMemoryModel>(
            predicate: #Predicate { $0.studentId == target }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let fresh = ConversationMemoryModel(studentId: studentId)
        context.insert(fresh)
        return fresh
    }
}

// MARK: - Codable date strategy (stable across versions)

private extension JSONEncoder {
    static let iso: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}

private extension JSONDecoder {
    static let iso: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
