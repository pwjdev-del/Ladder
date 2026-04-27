import Foundation
import SwiftData

// MARK: - Career Quiz History Model
// Stores quiz results per year for year-over-year comparison

@Model
final class CareerQuizHistoryModel {
    var gradeTaken: Int  // 9, 10, 11, 12
    var yearTaken: Int   // 2024, 2025, etc.
    var dateTaken: Date
    var topCareerPath: String  // "STEM", "Medical", etc.
    var scores: [String: Double]  // ["STEM": 0.75, "Business": 0.15, "Arts": 0.10]
    var archetypeName: String?

    init(gradeTaken: Int, topCareerPath: String, scores: [String: Double], archetypeName: String?) {
        self.gradeTaken = gradeTaken
        self.yearTaken = Calendar.current.component(.year, from: Date())
        self.dateTaken = Date()
        self.topCareerPath = topCareerPath
        self.scores = scores
        self.archetypeName = archetypeName
    }
}
