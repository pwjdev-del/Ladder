import XCTest
@testable import LadderApp

final class StateRequirementsEngineTests: XCTestCase {

    func test_florida_creditRequirements() {
        let engine = StateRequirementsEngine.shared
        let reqs = engine.requirements(for: "FL")
        XCTAssertEqual(reqs.state, "Florida")
        XCTAssertEqual(reqs.graduationCredits, 24)
        XCTAssertNotNil(reqs.meritScholarship, "Florida should have Bright Futures scholarship")
        XCTAssertEqual(reqs.meritScholarship?.name, "Bright Futures FAS")
    }

    func test_caseInsensitive_lookupWorks() {
        let engine = StateRequirementsEngine.shared
        let lower = engine.requirements(for: "florida")
        let upper = engine.requirements(for: "FLORIDA")
        XCTAssertEqual(lower.state, upper.state)
        XCTAssertEqual(lower.graduationCredits, upper.graduationCredits)
    }

    func test_unknownState_returnsGenericDefaults() {
        let engine = StateRequirementsEngine.shared
        let reqs = engine.requirements(for: "ZZ")
        XCTAssertEqual(reqs.graduationCredits, 24, "Generic default is 24 credits")
        XCTAssertNil(reqs.meritScholarship, "Unknown state has no merit scholarship")
        XCTAssertFalse(reqs.specialRules.isEmpty, "Generic state should still provide counselor advice")
    }

    func test_supportedStatesList_notEmpty() {
        XCTAssertFalse(StateRequirementsEngine.supportedStates.isEmpty)
        XCTAssertTrue(StateRequirementsEngine.supportedStates.contains("Florida"))
    }
}
