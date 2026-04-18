import Foundation
import SwiftData

// MARK: - GPA Entry Model
// Stores per-semester GPA data with individual course grades

@Model
final class GPAEntryModel {
    var semester: String  // "Fall 2024"
    var coursesData: Data?  // CourseGrade array stored as JSON
    var weightedGPA: Double
    var unweightedGPA: Double
    var createdAt: Date

    init(semester: String, courses: [CourseGrade] = [], weightedGPA: Double = 0.0, unweightedGPA: Double = 0.0) {
        self.semester = semester
        self.coursesData = try? JSONEncoder().encode(courses)
        self.weightedGPA = weightedGPA
        self.unweightedGPA = unweightedGPA
        self.createdAt = Date()
    }

    var courses: [CourseGrade] {
        get {
            guard let data = coursesData else { return [] }
            return (try? JSONDecoder().decode([CourseGrade].self, from: data)) ?? []
        }
        set {
            coursesData = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - Course Grade

struct CourseGrade: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var creditHours: Double
    var grade: String  // A, A-, B+, B, B-, C+, C, C-, D+, D, D-, F
    var isAP: Bool
    var isHonors: Bool

    // MARK: - Grade Point Mapping

    static let gradePoints: [String: Double] = [
        "A+": 4.0, "A": 4.0, "A-": 3.7,
        "B+": 3.3, "B": 3.0, "B-": 2.7,
        "C+": 2.3, "C": 2.0, "C-": 1.7,
        "D+": 1.3, "D": 1.0, "D-": 0.7,
        "F": 0.0
    ]

    static let allGrades: [String] = [
        "A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F"
    ]

    /// Unweighted grade points (standard 4.0 scale)
    var unweightedPoints: Double {
        Self.gradePoints[grade] ?? 0.0
    }

    /// Weighted grade points: AP adds 1.0, Honors adds 0.5
    var weightedPoints: Double {
        var base = unweightedPoints
        if isAP { base += 1.0 }
        else if isHonors { base += 0.5 }
        return base
    }
}

// MARK: - GPA Calculation Helpers

extension Array where Element == CourseGrade {
    var totalCreditHours: Double {
        reduce(0) { $0 + $1.creditHours }
    }

    var weightedGPA: Double {
        let totalCredits = totalCreditHours
        guard totalCredits > 0 else { return 0.0 }
        let qualityPoints = reduce(0.0) { $0 + ($1.weightedPoints * $1.creditHours) }
        return qualityPoints / totalCredits
    }

    var unweightedGPA: Double {
        let totalCredits = totalCreditHours
        guard totalCredits > 0 else { return 0.0 }
        let qualityPoints = reduce(0.0) { $0 + ($1.unweightedPoints * $1.creditHours) }
        return qualityPoints / totalCredits
    }
}
