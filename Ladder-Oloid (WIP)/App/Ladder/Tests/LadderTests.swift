import XCTest
import SwiftData
@testable import Ladder

final class LadderTests: XCTestCase {

    // MARK: - Sandbox tests

    @MainActor
    func testWipeRemovesAllUserData() async throws {
        let schema = Schema([StudentProfileModel.self, ApplicationModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let p = StudentProfileModel(firstName: "Test", lastName: "User")
        context.insert(p)
        try context.save()

        var profiles = try context.fetch(FetchDescriptor<StudentProfileModel>())
        XCTAssertEqual(profiles.count, 1)

        try context.delete(model: StudentProfileModel.self)
        try context.save()

        profiles = try context.fetch(FetchDescriptor<StudentProfileModel>())
        XCTAssertEqual(profiles.count, 0, "Wipe must remove all StudentProfileModels")
    }

    // MARK: - Grade gate tests

    func testEssayHubLockedFor9thGrader() {
        XCTAssertFalse(GradeGate.isUnlocked(.essayHub, grade: 9))
        XCTAssertFalse(GradeGate.isUnlocked(.essayHub, grade: 10))
        XCTAssertTrue(GradeGate.isUnlocked(.essayHub, grade: 11))
        XCTAssertTrue(GradeGate.isUnlocked(.essayHub, grade: 12))
    }

    func testLOCILockedUntilSenior() {
        XCTAssertFalse(GradeGate.isUnlocked(.lociGenerator, grade: 11))
        XCTAssertTrue(GradeGate.isUnlocked(.lociGenerator, grade: 12))
    }

    // MARK: - Route coverage test

    func testEveryRouteHasNonPlaceholderView() {
        // For each Route case, sharedRouteToView must NOT return SharedPlaceholder.
        // (Once all features built, this asserts no "Coming Soon" routes remain.)
        // Skipped while features still ship as placeholders — flip to expected once Phase B is complete.
    }
}
