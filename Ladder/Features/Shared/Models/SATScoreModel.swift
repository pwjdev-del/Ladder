import Foundation
import SwiftData

@Model
final class SATScoreEntryModel {
    var testDate: Date
    var totalScore: Int
    var mathScore: Int
    var readingScore: Int
    var isPractice: Bool = false
    var source: String?

    init(testDate: Date, totalScore: Int, mathScore: Int, readingScore: Int) {
        self.testDate = testDate
        self.totalScore = totalScore
        self.mathScore = mathScore
        self.readingScore = readingScore
    }
}
