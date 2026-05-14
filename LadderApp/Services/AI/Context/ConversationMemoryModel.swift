import Foundation
import SwiftData
import os

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

    // MARK: - Remote load (T012)

    /// Fetches the most recent session summaries from `student_memory_summaries` for the
    /// given student. Returns them ordered newest-first (limit 50).
    ///
    /// D-003: asserts `studentId == auth.uid()` before hitting the network.
    /// Throws `SiaIsolationError.contextMismatch` on mismatch, `.noActiveSession` if
    /// there is no active JWT.
    ///
    /// The return value is an ordered list of `(sessionId, summaryText, createdAt)` tuples
    /// so the caller can pick the most recent summary without re-parsing a `ConversationMemory`.
    static func loadFromRemote(studentId: String) async throws -> [RemoteSummaryEntry] {
        // D-003 identity assertion — must match live JWT before any network call.
        let session = await SupabaseAuthService.shared.currentSession
        guard let uid = session?.user.id.uuidString else {
            Log.warn("[T012-MemoryLoad] no active session — cannot load remote summaries for studentId=\(studentId)")
            throw SiaIsolationError.noActiveSession
        }
        guard uid == studentId else {
            Log.warn("[T012-MemoryLoad] contextMismatch — expected=\(studentId) actual=\(uid)")
            throw SiaIsolationError.contextMismatch(expected: studentId, actual: uid)
        }

        let rows: [RemoteSummaryEntry] = try await SupabaseAuthService.shared.supabase
            .from("student_memory_summaries")
            .select("id,session_id,summary_text,created_at")
            .eq("student_user_id", value: studentId)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value

        return rows
    }
}

// MARK: - Remote summary shape (T012)

/// Lightweight decodable representing one row from `student_memory_summaries`.
/// `embedding` is deliberately omitted — v1.1 concern.
struct RemoteSummaryEntry: Decodable, Identifiable {
    let id: UUID
    let sessionId: UUID?
    let summaryText: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId   = "session_id"
        case summaryText = "summary_text"
        case createdAt   = "created_at"
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
