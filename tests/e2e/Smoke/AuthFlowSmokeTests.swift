import XCTest

// MARK: - AuthFlowSmokeTests
//
// Smoke coverage for the auth entry-point flows:
//   1. Landing renders and primary CTA is tappable
//   2. B2C login form renders required fields
//   3. School login form renders required fields
//   4. 30-second logo long-press triggers BackdoorChoiceView
//
// These tests do NOT call Supabase — they exercise only the UI layer.
// "Log in" button disabled-state verification covers the formReady guard in
// B2CLoginView without requiring a live backend connection.

final class AuthFlowSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "true"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test 1: Landing view renders

    func test_launch_shows_landing_view() throws {
        // The landing page shows two primary CTAs. Both must exist and be
        // hittable within 5 seconds of launch.
        let b2cButton = app.buttons["Log in with your ID"]
        XCTAssertTrue(
            b2cButton.waitForExistence(timeout: 5),
            "LandingView must render 'Log in with your ID' button"
        )
        XCTAssertTrue(b2cButton.isHittable, "'Log in with your ID' must be tappable")

        let schoolButton = app.buttons["Sign in through your school"]
        XCTAssertTrue(
            schoolButton.waitForExistence(timeout: 3),
            "LandingView must render 'Sign in through your school' button"
        )
        XCTAssertTrue(schoolButton.isHittable, "'Sign in through your school' must be tappable")
    }

    // MARK: - Test 2: B2C login form renders required fields

    func test_b2c_login_screen_renders_required_fields() throws {
        // Navigate into B2C login
        let b2cButton = app.buttons["Log in with your ID"]
        XCTAssertTrue(b2cButton.waitForExistence(timeout: 5))
        b2cButton.tap()

        // Email field (placeholder "you@example.com")
        let emailField = app.textFields["you@example.com"]
        XCTAssertTrue(
            emailField.waitForExistence(timeout: 5),
            "B2CLoginView must show email field with placeholder 'you@example.com'"
        )

        // Password field (secure)
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(
            passwordField.waitForExistence(timeout: 3),
            "B2CLoginView must show a secure password field"
        )

        // Log in button must be disabled when both fields are empty (formReady == false)
        let loginButton = app.buttons["Log in"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 3))
        XCTAssertFalse(
            loginButton.isEnabled,
            "'Log in' button must be disabled when email and password are empty"
        )
    }

    // MARK: - Test 3: School login renders required fields

    func test_school_login_screen_renders_required_fields() throws {
        // Navigate to school picker
        let schoolButton = app.buttons["Sign in through your school"]
        XCTAssertTrue(schoolButton.waitForExistence(timeout: 5))
        schoolButton.tap()

        // SchoolPickerView shows a TextField with prompt "Search your school".
        // It's not a UISearchBar/searchField — it's a plain SwiftUI TextField.
        // Verify the text field exists; the actual school-login form requires
        // selecting a school from the live Supabase list (partial coverage).
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5),
            "SchoolPickerView must show a text field for searching schools"
        )
    }

    // MARK: - Test 4a: Forgot-password sheet (S1-3)

    func test_forgotPassword_flow() throws {
        // Navigate into B2C login
        let b2cButton = app.buttons["Log in with your ID"]
        XCTAssertTrue(b2cButton.waitForExistence(timeout: 5))
        b2cButton.tap()

        // Tap "Forgot password?" link in the footer
        let forgotButton = app.buttons["Forgot password?"]
        XCTAssertTrue(
            forgotButton.waitForExistence(timeout: 5),
            "B2CLoginView must show a 'Forgot password?' button"
        )
        forgotButton.tap()

        // Wait for ForgotPasswordView's sheet heading to confirm the sheet is fully presented.
        let resetTitle = app.staticTexts["Reset Password"]
        XCTAssertTrue(
            resetTitle.waitForExistence(timeout: 5),
            "ForgotPasswordView must show 'Reset Password' heading"
        )

        // Now target the email field — use the last match since the sheet overlays
        // B2CLoginView's non-hittable field at a lower z-level.
        let allEmailFields = app.textFields.matching(
            NSPredicate(format: "placeholderValue == 'you@example.com'")
        )
        let emailField = allEmailFields.element(boundBy: allEmailFields.count - 1)
        XCTAssertTrue(emailField.isHittable, "ForgotPasswordView email field must be hittable")

        // Fill in a valid email address
        emailField.tap()
        emailField.typeText("test@example.com")

        // "Send reset link" button must now be enabled
        let sendButton = app.buttons["Send reset link"]
        XCTAssertTrue(
            sendButton.waitForExistence(timeout: 3),
            "ForgotPasswordView must show 'Send reset link' button"
        )
        XCTAssertTrue(
            sendButton.isEnabled,
            "'Send reset link' must be enabled once a valid email is entered"
        )

        // Tap send — Supabase is not live in UI tests so we expect either:
        //   A) the success banner ("Check your email"), or
        //   B) an error message (network unavailable — still counts as "something happened")
        sendButton.tap()

        let successBanner = app.staticTexts["Check your email"]
        let anyResponse = successBanner.waitForExistence(timeout: 10)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'reset link'")).firstMatch.waitForExistence(timeout: 0)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'error'")).firstMatch.waitForExistence(timeout: 0)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'network'")).firstMatch.waitForExistence(timeout: 0)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Unable'")).firstMatch.waitForExistence(timeout: 0)

        XCTAssertTrue(
            anyResponse,
            "ForgotPasswordView must show a success or error response after tapping 'Send reset link'"
        )
    }

    // MARK: - Test 4: Long-press logo opens BackdoorChoiceView

    func test_long_press_logo_opens_backdoor() throws {
        // The logo has accessibilityLabel "Ladder" and fires BackdoorChoiceView
        // after a 30-second hold. We simulate the hold gesture.
        // NOTE: LandingView fires the trigger at 30s but auto-fires from the
        // progress timer too, so a 30.5-second press should reliably trigger it.
        // The logo ZStack has accessibilityLabel "Ladder". Query broadly across
        // element types since SwiftUI's accessibility flattening can change the
        // element type (otherElements, images, or a merged group).
        let logoPredicate = NSPredicate(format: "label == 'Ladder'")
        let logo = app.descendants(matching: .any).matching(logoPredicate).firstMatch
        XCTAssertTrue(
            logo.waitForExistence(timeout: 5),
            "Logo element with accessibilityLabel 'Ladder' must exist on LandingView"
        )

        // The real hold duration is 30 seconds. This makes the test slow but
        // correct; CI must not impose a < 60-second per-test timeout.
        logo.press(forDuration: 30.5)

        // BackdoorChoiceView shows "LADDER · STAFF" header and role buttons.
        let founderButton = app.buttons["Login as Founder"]
        XCTAssertTrue(
            founderButton.waitForExistence(timeout: 5),
            "BackdoorChoiceView must appear with 'Login as Founder' after 30s logo hold"
        )

        let employeeButton = app.buttons["Login as Employee"]
        XCTAssertTrue(
            employeeButton.exists,
            "BackdoorChoiceView must also show 'Login as Employee'"
        )
    }
}
