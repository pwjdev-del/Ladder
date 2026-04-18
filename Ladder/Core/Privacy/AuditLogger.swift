import Foundation
import SwiftData

// MARK: - Audit Log Entry
// SwiftData model for FERPA-compliant audit logging
// Tracks all counselor access to student data

@Model
final class AuditLogEntry {
    var counselorId: String
    var studentId: String
    var action: String  // "viewed_profile", "viewed_grades", "approved_schedule", "exported_data"
    var details: String?
    var timestamp: Date

    init(counselorId: String, studentId: String, action: String, details: String? = nil) {
        self.counselorId = counselorId
        self.studentId = studentId
        self.action = action
        self.details = details
        self.timestamp = Date()
    }
}

// MARK: - Audit Logger

@Observable
final class AuditLogger {
    static let shared = AuditLogger()
    private init() {}

    /// Log a counselor's access to student data
    @MainActor
    func log(counselorId: String, studentId: String, action: String, details: String? = nil, context: ModelContext) {
        let entry = AuditLogEntry(
            counselorId: counselorId,
            studentId: studentId,
            action: action,
            details: details
        )
        context.insert(entry)
        try? context.save()
    }

    /// Fetch recent audit logs for a specific student
    func getRecentLogs(forStudent studentId: String, context: ModelContext) -> [AuditLogEntry] {
        let descriptor = FetchDescriptor<AuditLogEntry>(
            predicate: #Predicate { $0.studentId == studentId },
            sortBy: [SortDescriptor(\AuditLogEntry.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch recent audit logs for a specific counselor
    func getRecentLogs(forCounselor counselorId: String, context: ModelContext) -> [AuditLogEntry] {
        let descriptor = FetchDescriptor<AuditLogEntry>(
            predicate: #Predicate { $0.counselorId == counselorId },
            sortBy: [SortDescriptor(\AuditLogEntry.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Export audit logs for compliance reporting (TODO: actual export)
    func exportLogs(forStudent studentId: String, context: ModelContext) -> [AuditLogEntry] {
        let descriptor = FetchDescriptor<AuditLogEntry>(
            predicate: #Predicate { $0.studentId == studentId },
            sortBy: [SortDescriptor(\AuditLogEntry.timestamp, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
