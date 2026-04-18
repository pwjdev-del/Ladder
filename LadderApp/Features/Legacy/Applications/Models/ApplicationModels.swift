import Foundation
import SwiftData

// MARK: - Application

@Model
final class ApplicationModel {
    var supabaseId: String?
    // collegeId is NOT SwiftData-unique (Optional can have multiple nils).
    // Uniqueness is enforced programmatically in ApplicationFactory.findOrCreate().
    var collegeId: String?
    var collegeName: String
    var status: String = "planning" // Use ApplicationStatus enum rawValue via extension
    var updatedAt: Date = Date()
    var versionId: Int = 1
    var deadlineType: String? // "Early Action", "Early Decision", "Regular Decision"
    var deadlineDate: Date?
    var submittedAt: Date?
    var decisionAt: Date?
    var notes: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var checklistItems: [ChecklistItemModel] = []

    init(collegeName: String) {
        self.collegeName = collegeName
        self.createdAt = Date()
    }

    /// Apply a new status if the transition is valid; returns true on success.
    @MainActor
    @discardableResult
    func setState(_ new: ApplicationState, context: ModelContext? = nil) -> Bool {
        guard let current = ApplicationState(rawValue: status) else {
            status = new.rawValue
            updatedAt = Date()
            versionId &+= 1
            return true
        }
        guard ApplicationState.canTransition(from: current, to: new) else {
            Log.warn("Rejected application transition \(current.rawValue) → \(new.rawValue)")
            return false
        }
        status = new.rawValue
        updatedAt = Date()
        versionId &+= 1
        if new == .accepted, let ctx = context {
            ConnectionEngine.shared.onApplicationAccepted(self, context: ctx)
        }
        return true
    }
}

// MARK: - Dedup factory

enum ApplicationFactory {
    /// Return existing ApplicationModel for a collegeId if present, otherwise create one.
    @MainActor
    static func findOrCreate(
        collegeId: String?,
        collegeName: String,
        context: ModelContext
    ) -> ApplicationModel {
        if let id = collegeId, !id.isEmpty {
            let descriptor = FetchDescriptor<ApplicationModel>(
                predicate: #Predicate { $0.collegeId == id }
            )
            if let existing = (try? context.fetch(descriptor))?.first {
                return existing
            }
        }
        let app = ApplicationModel(collegeName: collegeName)
        app.collegeId = collegeId
        context.insert(app)
        return app
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
    var grade: Int = 9
    var updatedAt: Date = Date()
    var versionId: Int = 1
    var schoolName: String?
    var schoolId: String?
    var studentId: String?
    var gpa: Double?
    var satScore: Int?
    var actScore: Int?
    var isFirstGen: Bool = false
    var isFloridaResident: Bool = false
    var parentIncomeBracket: String?
    var freeReducedLunch: Bool = false
    var careerPath: String? // "Medical", "Engineering", "Liberal Arts"
    var selectedMajor: String? // e.g. "Computer Science", "Pre-Med"
    var archetype: String? // "The Creative Researcher"
    var archetypeTraits: [String] = []
    var interests: [String] = []
    var extracurriculars: [String] = []
    var apCourses: [String] = []
    var savedCollegeIds: [String] = []
    var state: String?
    var classDifficultyPreference: String?
    var profileImageURL: String?
    var preferredSize: String?       // "small", "medium", "large"
    var preferredLocation: String?   // "in_state", "out_of_state"
    var preferredSetting: String?    // "urban", "suburban", "rural"
    var preferredCulture: String?    // "research", "teaching", "both"
    var totalXP: Int = 0
    var streak: Int = 0
    var createdAt: Date

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
    }

    var fullName: String { "\(firstName) \(lastName)" }
}
