import Testing
import Foundation
@testable import LadderApp

struct SharedModelsTests {

    @Test func activityModelInit() {
        let activity = ActivityModel(name: "Robotics Club", category: "Club")
        #expect(activity.name == "Robotics Club")
        #expect(activity.tier == 4)
        #expect(activity.totalHours == 0)
    }

    @Test func satScoreEntryModelInit() {
        let entry = SATScoreEntryModel(
            testDate: Date(),
            totalScore: 1450,
            mathScore: 780,
            readingScore: 670
        )
        #expect(entry.totalScore == 1450)
        #expect(entry.isPractice == false)
    }

    @Test func gpaEntryModelInit() {
        let entry = GPAEntryModel(semester: "Fall 2024", weightedGPA: 3.9, unweightedGPA: 3.7)
        #expect(entry.semester == "Fall 2024")
        #expect(entry.weightedGPA == 3.9)
        #expect(entry.courses.isEmpty)
    }

    @Test func careerQuizHistoryModelInit() {
        let history = CareerQuizHistoryModel(
            gradeTaken: 10,
            topCareerPath: "STEM",
            scores: ["STEM": 0.8, "Business": 0.2],
            archetypeName: "The Innovator"
        )
        #expect(history.topCareerPath == "STEM")
        #expect(history.gradeTaken == 10)
    }

    @Test func financialAidPackageModelInit() {
        let pkg = FinancialAidPackageModel(collegeId: "col_001", collegeName: "MIT")
        #expect(pkg.netCost == 0)
        #expect(pkg.totalAid == 0)
    }
}
