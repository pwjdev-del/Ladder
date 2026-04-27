import Foundation
import SwiftData

// MARK: - Activity Model
// Represents a single extracurricular activity for the student's portfolio.
// Maps to Common App Activities section (up to 10 activities).

@Model
final class ActivityModel {
    var name: String
    var category: String  // "Club", "Athletics", "Job", "Volunteering", "Award", "Research", "Internship", "Leadership"
    var role: String?
    var organization: String?
    var hoursPerWeek: Double?
    var weeksPerYear: Double?
    var startDate: Date?
    var endDate: Date?
    var gradeYears: [Int] = []  // [9, 10, 11, 12]
    var isLeadership: Bool = false
    var impactStatement: String?  // 150-char Common App description
    var notes: String?
    var tier: Int = 4  // Activity tier 1-4 (1=National, 2=State, 3=Regional, 4=School)
    var createdAt: Date

    init(name: String, category: String) {
        self.name = name
        self.category = category
        self.createdAt = Date()
    }

    var totalHours: Double {
        (hoursPerWeek ?? 0) * (weeksPerYear ?? 0)
    }

    var gradeYearsFormatted: String {
        gradeYears.sorted().map { "\($0)" }.joined(separator: ", ")
    }

    static var tierDescriptions: [Int: String] {
        [
            1: "National Recognition",
            2: "State Level",
            3: "Regional / School-wide",
            4: "Participation"
        ]
    }

    static var allCategories: [String] {
        ["Club", "Athletics", "Job", "Volunteering", "Award", "Research", "Internship", "Leadership"]
    }

    static var categoryIcons: [String: String] {
        [
            "Club": "person.3.fill",
            "Athletics": "figure.run",
            "Job": "briefcase.fill",
            "Volunteering": "heart.fill",
            "Award": "trophy.fill",
            "Research": "flask.fill",
            "Internship": "building.2.fill",
            "Leadership": "star.fill"
        ]
    }
}
