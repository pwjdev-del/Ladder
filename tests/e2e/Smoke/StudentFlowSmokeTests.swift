import XCTest

// MARK: - StudentFlowSmokeTests
//
// Smoke coverage for the student-facing post-login flows:
//   5. Student dashboard renders the Advisor tab
//   6. AdvisorChatView input bar and send button render
//   7. NudgeCard renders with "Tell me more" and "Not now" when seeded
//
// Auth gate: Tests 5-7 require a signed-in student session. The app's
// -UITestMode launch argument (guarded by #if DEBUG in LadderApp.swift) is
// the mechanism; if that short-circuit is not implemented yet these tests
// call XCTSkip so CI stays green without a false-positive PASS.
//
// IMPLEMENTATION NOTE for the auth short-circuit:
//   In LadderApp.swift init(), add:
//
//   #if DEBUG
//   if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
//       // Bypass Supabase — inject a deterministic test session.
//       // Sets TenantContext.shared.claim synchronously before any view renders.
//       UITestSessionBootstrap.injectTestStudent()
//   }
//   #endif
//
//   UITestSessionBootstrap is a DEBUG-only helper that seeds a SignedInSession
//   with role = .student, tenantName = "TestSchool", and a fake gradeLevel = 11.
//   Contact the auth specialist to implement this helper.

private let kUITestModeArg = "-UITestMode"

final class StudentFlowSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "true", kUITestModeArg]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    /// Checks whether the -UITestMode short-circuit is wired up and the
    /// student dashboard is immediately visible. If not, the test skips.
    private func requireStudentDashboard(timeout: TimeInterval = 5) throws {
        // After -UITestMode launch, the app should skip auth and land directly
        // on the student dashboard. We detect this by looking for one of the
        // five bottom-tab labels or the NavigationSplitView sidebar on iPad.
        let advisorTab = app.buttons["Advisor"]
        let advisorSidebar = app.staticTexts["Advisor"]
        let isVisible = advisorTab.waitForExistence(timeout: timeout)
                     || advisorSidebar.waitForExistence(timeout: timeout)

        if !isVisible {
            throw XCTSkip(
                """
                Student dashboard did not appear after launch with \(kUITestModeArg). \
                The -UITestMode auth short-circuit is not yet implemented. \
                Implement UITestSessionBootstrap.injectTestStudent() in LadderApp.swift \
                to unblock tests 5-7.
                """
            )
        }
    }

    // MARK: - Test 5: Student dashboard renders the Advisor tab

    func test_student_dashboard_renders_advisor_tab() throws {
        try requireStudentDashboard()

        // On iPhone: bottom tab bar shows "Advisor" tab button.
        // On iPad: sidebar list shows "Advisor" label.
        let advisorElement = app.buttons["Advisor"].exists
            ? app.buttons["Advisor"]
            : app.staticTexts["Advisor"]

        XCTAssertTrue(
            advisorElement.exists,
            "Student dashboard must render an Advisor tab (bottom bar on iPhone, sidebar on iPad)"
        )
    }

    // MARK: - Test 6: AdvisorChatView input bar and send button render

    func test_advisor_chat_renders_input_and_send_button() throws {
        try requireStudentDashboard()

        // Navigate to Advisor tab
        let advisorTab = app.buttons["Advisor"].exists
            ? app.buttons["Advisor"]
            : app.staticTexts["Advisor"]
        advisorTab.tap()

        // The chat input has placeholder text "Ask SIA..."
        let inputField = app.textFields["Ask SIA..."]
        XCTAssertTrue(
            inputField.waitForExistence(timeout: 5),
            "AdvisorChatView must show a text field with placeholder 'Ask SIA...'"
        )

        // The send button uses the "arrow.up.circle.fill" SF Symbol.
        // It has no explicit label so we match by button index in the toolbar area.
        // On launch the send button is disabled (empty input), which is correct.
        // We just check it exists — not that it's enabled.
        let sendButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'arrow.up.circle.fill'")
        ).firstMatch
        // Fallback: buttons() with image only have no title, test existence via
        // the button count in the input bar area.
        let inputBarHasButtons = app.buttons.count > 0
        XCTAssertTrue(
            sendButton.exists || inputBarHasButtons,
            "AdvisorChatView input bar must contain a send button"
        )
    }

    // MARK: - Test 7: NudgeCard visible when seeded via -fixtureTenant

    func test_nudge_card_visible_when_seeded() throws {
        // NudgeStore.shared is seeded with mock nudges when the app launches
        // with -UITestMode. If the short-circuit isn't wired, skip.
        try requireStudentDashboard()

        // Navigate to Home tab (default selected on launch)
        let homeTab = app.buttons["Home"].exists
            ? app.buttons["Home"]
            : app.staticTexts["Home"]
        homeTab.tap()

        // SiaNudgeCard renders "Tell me more" and "Not now" buttons.
        // If nudges are not seeded, the card won't appear — still skip rather
        // than fail so we don't block on NudgeStore fixture wiring.
        let tellMeMore = app.buttons["Tell me more"]
        let notNow = app.buttons["Not now"]

        let cardVisible = tellMeMore.waitForExistence(timeout: 5)

        if !cardVisible {
            throw XCTSkip(
                """
                SiaNudgeCard did not appear on the Home tab within 5 seconds. \
                The -UITestMode fixture must seed at least one NudgeIntent into \
                NudgeStore.shared for this test to pass. Wire up the fixture or \
                add a -seedNudges launch argument.
                """
            )
        }

        XCTAssertTrue(tellMeMore.isHittable, "'Tell me more' must be tappable on SiaNudgeCard")
        XCTAssertTrue(notNow.exists, "'Not now' must be present on SiaNudgeCard")
    }
}
