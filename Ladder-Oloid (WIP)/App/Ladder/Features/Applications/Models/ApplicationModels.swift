import Foundation
import SwiftData

// MARK: - Application Status

enum ApplicationStatus: String, CaseIterable, Codable {
    case pending, inProgress, submitted, accepted, waitlisted, denied, deferred

    var displayName: String {
        switch self {
        case .pending: "Not Started"
        case .inProgress: "In Progress"
        case .submitted: "Submitted"
        case .accepted: "Accepted"
        case .waitlisted: "Waitlisted"
        case .denied: "Denied"
        case .deferred: "Deferred"
        }
    }
}

// MARK: - Application

@Model
final class ApplicationModel {
    var supabaseId: String?
    var collegeId: String?
    var collegeName: String
    var status: String = "pending" // pending / inProgress / submitted / accepted / waitlisted / denied / deferred
    var deadlineType: String? // "Early Action", "Early Decision", "Regular Decision"
    var deadlineDate: Date?
    var submittedAt: Date?
    var decisionAt: Date?
    var decisionDate: Date?
    var financialAidOffer: Double?
    var notes: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var checklistItems: [ChecklistItemModel] = []
    var studentProfile: StudentProfileModel?

    init(collegeName: String) {
        self.collegeName = collegeName
        self.createdAt = Date()
    }
}

// MARK: - Checklist Item

@Model
final class ChecklistItemModel {
    var supabaseId: String?
    var title: String
    var itemDescription: String?
    var category: String? // "transcript", "essay", "lor", "test_score", "financial", "housing"
    var status: String = "pending" // pending, in_progress, completed
    var dueDate: Date?
    var completedAt: Date?
    var sortOrder: Int = 0

    var application: ApplicationModel?

    init(title: String) {
        self.title = title
    }
}

// MARK: - Student Profile

@Model
final class StudentProfileModel {
    var supabaseId: String?
    var userId: String?
    var firstName: String
    var lastName: String
    var grade: Int = 10
    var schoolName: String?
    var studentId: String?
    var gpa: Double?
    var weightedGPA: Double?
    var satScore: Int?
    var actScore: Int?
    var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 4
    var stateOfResidence: String = "FL"
    var isFirstGen: Bool = false
    var careerPath: String? // "Medical", "Engineering", "Liberal Arts"
    var archetype: String? // "The Creative Researcher"
    var archetypeTraits: [String] = []
    var interests: [String] = []
    var extracurriculars: [String] = []
    var apCourses: [String] = []
    var savedCollegeIds: [String] = []
    var profileImageURL: String?
    var streak: Int = 0
    var createdAt: Date

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
    }

    var fullName: String { "\(firstName) \(lastName)" }
}
