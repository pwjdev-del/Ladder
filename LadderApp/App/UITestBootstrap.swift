#if DEBUG
import Foundation

// MARK: - UITestBootstrap
//
// Injects a deterministic test student session when the app is launched with
// the -UITestMode launch argument. This bypasses Supabase auth entirely so
// XCUITests can reach post-login screens without a live backend connection.
//
// Usage (XCUITest):
//   app.launchArguments = ["-UITestMode"]
//   app.launch()
//
// The bootstrap runs in a `.task` on LadderApp's root WindowGroup so it fires
// before any view renders a navigation destination that requires auth.

enum UITestBootstrap {
    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestMode")
    }

    @MainActor
    static func bootstrapIfNeeded() async {
        guard isActive else { return }
        let student = MockStudent.shared
        await SupabaseAuthService.shared.injectMockSession(student)
        TenantContext.shared.setForTesting(role: .student, tenantId: student.tenantId)
    }
}

// MARK: - MockStudent

public struct MockStudent {
    public static let shared = MockStudent(
        userId: "11111111-1111-1111-1111-111111111111",
        email: "test-student@ladder.app",
        displayName: "Test Student",
        gradeLevel: 11,
        tenantId: "00000000-0000-0000-0000-000000000001"
    )
    public let userId: String
    public let email: String
    public let displayName: String
    public let gradeLevel: Int
    public let tenantId: String
}
#endif
