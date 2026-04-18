import Foundation
import SwiftData

// MARK: - Chat Session

@Model
final class ChatSessionModel {
    var supabaseId: String?
    var sessionType: String = "advisor" // advisor, mock_interview, essay_review
    var title: String?
    var collegeId: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade) var messages: [ChatMessageModel] = []

    init(sessionType: String = "advisor") {
        self.sessionType = sessionType
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Chat Message

@Model
final class ChatMessageModel {
    var supabaseId: String?
    var role: String // "user", "assistant"
    var content: String
    var createdAt: Date

    var session: ChatSessionModel?

    init(role: String, content: String) {
        self.role = role
        self.content = content
        self.createdAt = Date()
    }
}

// MARK: - Roadmap Milestone

@Model
final class RoadmapMilestoneModel {
    var supabaseId: String?
    var grade: Int // 9, 10, 11, 12
    var title: String
    var milestoneDescription: String?
    var category: String? // "academic", "extracurricular", "test_prep", "applications"
    var status: String = "pending" // pending, in_progress, completed
    var dueDate: Date?
    var completedAt: Date?
    var sortOrder: Int = 0

    init(grade: Int, title: String) {
        self.grade = grade
        self.title = title
    }
}

// MARK: - Scholarship

@Model
final class ScholarshipModel {
    var supabaseId: String?
    var name: String
    var provider: String?
    var amount: Int?
    var deadline: Date?
    var eligibilityCriteria: String?
    var url: String?
    var isNeedBased: Bool = false
    var isMeritBased: Bool = false
    var isSaved: Bool = false
    var matchPercent: Int?
    var stateTag: String?  // e.g. "FL", "TX" — nil means national/any state

    init(name: String) {
        self.name = name
    }

    /// Returns true if this scholarship is restricted to a specific state
    var isStateSpecific: Bool {
        stateTag != nil && !(stateTag ?? "").isEmpty
    }
}
