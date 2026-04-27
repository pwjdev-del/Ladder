import XCTest
@testable import LadderApp

final class CollegeMatchCalculatorTests: XCTestCase {

    // IDEAS_DIGEST §9: GPA 3.7, SAT 1400, acceptance rate 0.5, SAT range 1200-1480
    // Expectation: .match (moderately selective; SAT 1400 >= midpoint ~1340, strong GPA)
    func test_ideasDigest_scenario_returnsMatch() {
        let tier = CollegeMatchCalculator.tier(
            studentGPA: 3.7,
            studentSAT: 1400,
            collegeAcceptanceRate: 0.5,
            collegeSATAvg: nil,
            collegeSAT25: 1200,
            collegeSAT75: 1480
        )
        XCTAssertEqual(tier, .match, "GPA 3.7 + SAT 1400 at 50% acceptance rate (SAT range 1200-1480) should be .match")
    }

    func test_highlySelective_strongProfile_returnsMatch() {
        let tier = CollegeMatchCalculator.tier(
            studentGPA: 3.9,
            studentSAT: 1550,
            collegeAcceptanceRate: 0.08,
            collegeSATAvg: nil,
            collegeSAT25: 1480,
            collegeSAT75: 1540
        )
        // <20% acceptance, SAT above 75th (1550 >= 1540), strong GPA
        XCTAssertEqual(tier, .match, "Highly selective: above-75th SAT + strong GPA = match")
    }

    func test_missingStudentData_returnsNeutralMatch() {
        let tier = CollegeMatchCalculator.tier(
            studentGPA: nil,
            studentSAT: nil,
            collegeAcceptanceRate: 0.3,
            collegeSATAvg: 1300,
            collegeSAT25: nil,
            collegeSAT75: nil
        )
        XCTAssertEqual(tier, .match, "Missing GPA should return neutral .match")
    }

    func test_zeroSAT_returnsNeutralMatch() {
        let tier = CollegeMatchCalculator.tier(
            studentGPA: 3.5,
            studentSAT: 0,
            collegeAcceptanceRate: 0.4,
            collegeSATAvg: 1200,
            collegeSAT25: nil,
            collegeSAT75: nil
        )
        XCTAssertEqual(tier, .match, "SAT=0 (never entered) should return neutral .match")
    }

    func test_openAdmission_strongProfile_returnsSafety() {
        let tier = CollegeMatchCalculator.tier(
            studentGPA: 3.5,
            studentSAT: 1300,
            collegeAcceptanceRate: 0.80,
            collegeSATAvg: nil,
            collegeSAT25: 950,
            collegeSAT75: 1150
        )
        // >50% acceptance, SAT 1300 above mid (1050), averageGPA = true
        XCTAssertEqual(tier, .safety, "Open-admission school with above-median profile should be .safety")
    }
}
