import XCTest
@testable import LadderApp

final class CollegeLogoServiceTests: XCTestCase {

    func test_extractDomain_stripsProtocolAndWWW() {
        let domain = CollegeLogoService.extractDomain(from: "https://www.ufl.edu/admissions")
        XCTAssertEqual(domain, "ufl.edu")
    }

    func test_extractDomain_bareURL() {
        let domain = CollegeLogoService.extractDomain(from: "mit.edu")
        XCTAssertEqual(domain, "mit.edu")
    }

    func test_extractDomain_nilInput_returnsNil() {
        XCTAssertNil(CollegeLogoService.extractDomain(from: nil))
    }

    func test_extractDomain_emptyString_returnsNil() {
        XCTAssertNil(CollegeLogoService.extractDomain(from: ""))
    }

    func test_logoURL_buildsCorrectClearbitURL() {
        let url = CollegeLogoService.logoURL(for: "https://www.stanford.edu", size: 64)
        XCTAssertEqual(url?.absoluteString, "https://logo.clearbit.com/stanford.edu?size=64")
    }

    func test_logoURL_defaultSize128() {
        let url = CollegeLogoService.logoURL(for: "harvard.edu")
        XCTAssertTrue(url?.absoluteString.contains("size=128") == true)
    }
}
