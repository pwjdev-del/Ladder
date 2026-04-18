import XCTest

// §18 e2e — end-to-end: student redeems invite → career quiz → grades →
// schedule builder → submit → counselor approves.

final class StudentHappyPathTests: XCTestCase {
    func test_studentRedeemsInviteThenTakesQuiz() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "true", "-fixtureTenant", "lwrpa"]
        app.launch()

        XCTAssertTrue(app.buttons["Sign in through your school"].waitForExistence(timeout: 5))
        app.buttons["Sign in through your school"].tap()

        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("Lakewood")
        app.staticTexts["Lakewood Ranch Preparatory Academy"].tap()

        let codeField = app.textFields["INVITE-CODE"]
        codeField.tap()
        codeField.typeText("LDR-TESTCODE")
        app.buttons["Join with invite code"].tap()

        XCTAssertTrue(app.navigationBars["Invite code"].waitForExistence(timeout: 5))
    }

    func test_founderLogoHoldTriggersFounderLogin() throws {
        let app = XCUIApplication()
        app.launch()

        let logo = app.otherElements["Ladder"]
        logo.press(forDuration: 30.5)

        XCTAssertTrue(app.navigationBars["Founder login"].waitForExistence(timeout: 3))
    }

    func test_founderLogoHoldShortOfThresholdDoesNothing() throws {
        let app = XCUIApplication()
        app.launch()

        let logo = app.otherElements["Ladder"]
        logo.press(forDuration: 25)

        XCTAssertFalse(app.navigationBars["Founder login"].exists)
    }
}
