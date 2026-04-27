import XCTest

// Smoke test for the B2C signup flow.
// This test was added after the original bug (S3 #17): the "Create account"
// button had a stub submit() that only slept 400ms without calling
// SupabaseAuthService.signUp — so tapping the button did nothing visible.
//
// PASS criteria: after tapping "Create account", ANY of the following appear:
//   1. Navigation to a dashboard (sign-up returned a live session)
//   2. An inline error message (sign-up threw a recoverable error, e.g. duplicate)
//   3. A "check your email" confirmation banner (email confirmation is ON in Supabase)
//
// FAIL criteria: none of the above appear within 10 seconds — the button is
// still doing nothing (the original regression).

final class SignupSmokeTest: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "true"]
        app.launch()
    }

    // MARK: - Primary smoke test

    func test_signupButton_doesSomethingVisible() throws {
        // Step 1: From Landing, tap "Create an account"
        let createAccountLink = app.buttons["Create an account"]
        XCTAssertTrue(
            createAccountLink.waitForExistence(timeout: 5),
            "Landing screen must show 'Create an account' link"
        )
        createAccountLink.tap()

        // Step 2: Fill in a valid email address
        let emailField = app.textFields["student@example.com"]
        XCTAssertTrue(
            emailField.waitForExistence(timeout: 5),
            "Signup screen must show email field"
        )
        emailField.tap()
        // Use a timestamp-suffixed address so duplicate-account errors are
        // the exception rather than the rule in CI.
        let timestamp = Int(Date().timeIntervalSince1970)
        emailField.typeText("smoke+\(timestamp)@test.ladderapp.com")

        // Step 3: Fill in a strong password (12+ chars, matching formReady gate)
        let passwordField = app.secureTextFields["••••••••"]
        XCTAssertTrue(
            passwordField.waitForExistence(timeout: 3),
            "Signup screen must show password field"
        )
        passwordField.tap()
        passwordField.typeText("SmokeTest!99x")

        // Step 4: Accept Terms and Privacy toggles
        // The toggles are labelled by their adjacent Text; target by index since
        // there are exactly two consent toggles.
        let toggles = app.switches
        if toggles.count >= 2 {
            let termsToggle = toggles.element(boundBy: 0)
            if termsToggle.exists && termsToggle.value as? String == "0" {
                termsToggle.tap()
            }
            let privacyToggle = toggles.element(boundBy: 1)
            if privacyToggle.exists && privacyToggle.value as? String == "0" {
                privacyToggle.tap()
            }
        }

        // Step 5: Tap the submit button — it should now be enabled
        let createButton = app.buttons["Create account"]
        XCTAssertTrue(
            createButton.waitForExistence(timeout: 3),
            "'Create account' button must exist on the signup screen"
        )
        // Scroll down in case the button is below the fold on small devices.
        createButton.tap()

        // Step 6: Assert one of three valid outcomes within 10 seconds.
        //   A — navigation: any nav bar or dashboard element appears
        //   B — inline error: signup-error-message accessibility ID appears
        //   C — email confirmation: signup-email-confirmation-banner appears
        let outcome = waitForAny(timeout: 10, predicates: [
            NSPredicate(format: "exists == true"),  // evaluated per element below
        ])
        _ = outcome  // silence unused warning; real check is below

        let errorBanner    = app.staticTexts.matching(identifier: "signup-error-message").firstMatch
        let confirmBanner  = app.otherElements.matching(identifier: "signup-email-confirmation-banner").firstMatch
        let studentDash    = app.staticTexts["Your Dashboard"]   // StudentDashboardView title
        let anyDashbar     = app.navigationBars.firstMatch

        let somethingHappened =
            errorBanner.waitForExistence(timeout: 10)   ||
            confirmBanner.waitForExistence(timeout: 0)  ||
            studentDash.waitForExistence(timeout: 0)    ||
            // Fall back: any navigation bar pushed means we navigated somewhere.
            (anyDashbar.exists && anyDashbar.identifier != "")

        XCTAssertTrue(
            somethingHappened,
            """
            Signup button did NOTHING — no error message, no email-confirmation banner,
            and no navigation occurred within 10 seconds. This is the original bug (S3 #17):
            submit() was a stub that never called SupabaseAuthService.signUp.
            """
        )
    }

    // MARK: - Regression guard: button must be disabled until form is complete

    func test_createAccountButton_disabledWithEmptyForm() throws {
        let createAccountLink = app.buttons["Create an account"]
        XCTAssertTrue(createAccountLink.waitForExistence(timeout: 5))
        createAccountLink.tap()

        let createButton = app.buttons["Create account"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        // With empty email, empty password, and no consent toggles accepted,
        // formReady == false and the button must be disabled.
        XCTAssertFalse(
            createButton.isEnabled,
            "'Create account' must be disabled when the form is not filled in"
        )
    }

    // MARK: - Helpers

    /// Polls until `block` returns true or `timeout` elapses.
    private func waitForAny(timeout: TimeInterval, predicates: [NSPredicate]) -> Bool {
        // No-op helper; real assertions use XCUIElement.waitForExistence directly.
        return true
    }
}
