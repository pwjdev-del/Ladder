import XCTest
@testable import LadderApp

final class ActivitySuggestionEngineTests: XCTestCase {

    func test_generalActivitiesCount() {
        let engine = ActivitySuggestionEngine.shared
        XCTAssertEqual(engine.generalActivities.count, 4, "4+7 system requires exactly 4 general activities")
    }

    func test_allSuggestions_returnsSevenCareerPlusGeneral() {
        let engine = ActivitySuggestionEngine.shared
        let suggestions = engine.allSuggestions(for: "STEM")
        // 4 general + 6 career-specific + 1 professional interview = 11
        XCTAssertEqual(suggestions.count, 11, "STEM path: 4 general + 7 career-specific = 11")
    }

    func test_careerActivities_professionalInterviewAppended() {
        let engine = ActivitySuggestionEngine.shared
        let activities = engine.careerActivities(for: "Medical")
        let hasInterview = activities.contains { $0.name == "Professional Interview" }
        XCTAssertTrue(hasInterview, "Every career path must include Professional Interview as 7th item")
    }

    func test_unknownCareerPath_returnsPromptToTakeQuiz() {
        let engine = ActivitySuggestionEngine.shared
        let activities = engine.careerActivities(for: "Unknown")
        XCTAssertEqual(activities.count, 1)
        XCTAssertEqual(activities.first?.name, "Take the Career Quiz")
    }
}
