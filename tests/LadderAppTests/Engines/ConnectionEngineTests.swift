import Testing
import Foundation
@testable import LadderApp

@MainActor
struct ConnectionEngineTests {

    @Test func sharedSingletonIsNotNil() {
        let engine = ConnectionEngine.shared
        #expect(engine !== nil)
    }

    @Test func dashboardActionsForGrade9ReturnsFourActions() {
        let actions = ConnectionEngine.shared.dashboardActions(grade: 9, careerPath: nil)
        #expect(actions.count == 4)
    }

    @Test func dashboardActionsForGrade12ReturnsFourActions() {
        let actions = ConnectionEngine.shared.dashboardActions(grade: 12, careerPath: "STEM")
        #expect(actions.count == 4)
    }

    @Test func dashboardActionsForSTEMGrade9HasCareerAction() {
        let actions = ConnectionEngine.shared.dashboardActions(grade: 9, careerPath: "STEM")
        let titles = actions.map(\.title)
        #expect(titles.contains("Explore Engineering"))
    }

    @Test func dashboardActionsForUnknownGradeFallsBackToDefault() {
        let actions = ConnectionEngine.shared.dashboardActions(grade: 8, careerPath: nil)
        #expect(actions.count == 4)
    }
}
