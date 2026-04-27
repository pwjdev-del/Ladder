import XCTest
@testable import LadderApp

final class ContentModerationServiceTests: XCTestCase {

    func test_cleanMessage_isAllowed() {
        let result = ContentModerationService.shared.moderate("Can you help me with my college essay?")
        XCTAssertTrue(result.isAllowed)
        XCTAssertTrue(result.flags.contains(.clean))
    }

    func test_concerningMessage_isFlagged() {
        let result = ContentModerationService.shared.moderate("I want to kill this exam")
        XCTAssertTrue(result.flags.contains(.concerning), "Message containing 'kill' should be flagged concerning")
    }

    func test_concerningMessage_isStillAllowed() {
        // Concerning flags notify but do not block (only explicit blocks)
        let result = ContentModerationService.shared.moderate("I want to hurt myself")
        XCTAssertTrue(result.flags.contains(.concerning))
        XCTAssertTrue(result.isAllowed, "Concerning content is allowed through but flagged for intervention")
    }

    func test_emptyMessage_returnsClean() {
        let result = ContentModerationService.shared.moderate("")
        XCTAssertTrue(result.flags.contains(.clean))
        XCTAssertTrue(result.isAllowed)
    }
}
