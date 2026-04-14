import SwiftUI
import SwiftData
import AuthenticationServices

// MARK: - Auth Manager
// Manages authentication state machine for the entire app
//
// SANDBOX RULE: every account on the device is isolated. When a user signs up
// or signs out, all user-scoped SwiftData (StudentProfileModel, ApplicationModel,
// ChecklistItemModel, ChatSessionModel, RoadmapMilestoneModel) is wiped from
// the local container. Cross-account access is only allowed server-side via
// explicit relationships (parent → child, counselor → caseload).

@Observable
final class AuthManager {

    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case consentRequired   // New user must agree to legal terms before onboarding
        case onboarding
        case authenticated
    }

    var authState: AuthState = .loading
    var userEmail: String?
    var userId: String?
    var errorMessage: String?
    var userRole: UserRole = .student  // default until user selects

    // MARK: - Session Management

    func checkSession() async {
        // TODO: Check Supabase session
        // let session = try? await SupabaseManager.shared.client.auth.session
        // if let session {
        //     userId = session.user.id.uuidString
        //     userEmail = session.user.email
        //     let hasProfile = try? await checkStudentProfile()
        //     authState = hasProfile == true ? .authenticated : .onboarding
        // } else {
        //     authState = .unauthenticated
        // }

        // Restore persisted role (if any)
        if let r = UserDefaults.standard.string(forKey: "ladder_user_role"),
           let role = UserRole(rawValue: r) {
            userRole = role
        }

        // For now, default to unauthenticated
        try? await Task.sleep(for: .seconds(1))
        authState = .unauthenticated
        // TODO (AWS): After Cognito session check, also verify consent:
        // let hasConsented = UserDefaults.standard.bool(forKey: "ladder_consent_given")
        // let consentVersion = UserDefaults.standard.string(forKey: "ladder_consent_version")
        // if hasConsented && consentVersion == LegalTexts.lastUpdated { authState = .authenticated }
        // else { authState = .consentRequired }
    }

    // MARK: - Email Auth

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            // TODO: Uncomment with Supabase
            // let session = try await SupabaseManager.shared.client.auth.signIn(
            //     email: email, password: password
            // )
            // userId = session.user.id.uuidString
            // userEmail = email
            // authState = .authenticated
            authState = .authenticated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        do {
            // TODO: Uncomment with AWS Cognito
            // let session = try await CognitoAuthManager.shared.signUp(email: email, password: password)
            // userId = session.user.id.uuidString
            // userEmail = email

            // SANDBOX: wipe any leftover account data on this device before starting fresh
            wipeAllUserData()

            // Generate a new userId for this account (replaced by Cognito sub once wired)
            userId = UUID().uuidString
            userEmail = email
            UserDefaults.standard.set(userId, forKey: "ladder_user_id")
            UserDefaults.standard.set(email, forKey: "ladder_user_email")
            UserDefaults.standard.set(userRole.rawValue, forKey: "ladder_user_role")

            // New users always go through consent before onboarding
            authState = .consentRequired
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Accept Consent (called from ConsentView on "I Agree")

    func acceptConsent() {
        let consentManager = ConsentManager()
        consentManager.recordConsent()
        // After consent, new users go to onboarding; returning users go to dashboard
        // TODO (AWS): Check if profile exists to decide
        authState = .onboarding
    }

    // MARK: - Sign in with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            errorMessage = "Failed to get Apple ID token"
            return
        }

        do {
            // TODO: Uncomment with Supabase
            // let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
            //     credentials: .init(provider: .apple, idToken: tokenString)
            // )
            // userId = session.user.id.uuidString
            // userEmail = credential.email ?? session.user.email

            // Check if new user needs onboarding
            // let hasProfile = try await checkStudentProfile()
            // authState = hasProfile ? .authenticated : .onboarding

            // SANDBOX: wipe leftover account data when signing in with Apple too
            wipeAllUserData()
            userId = credential.user  // Apple's stable user id
            userEmail = credential.email
            UserDefaults.standard.set(userId, forKey: "ladder_user_id")

            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Apple Sign-In consent check



    func signOut() async {
        // try? await SupabaseManager.shared.client.auth.signOut()

        // SANDBOX: wipe all user-scoped data on sign-out to guarantee the next
        // account starts fresh with no bleed-through from this session.
        wipeAllUserData()

        userId = nil
        userEmail = nil
        UserDefaults.standard.removeObject(forKey: "ladder_user_id")
        UserDefaults.standard.removeObject(forKey: "ladder_user_email")
        UserDefaults.standard.removeObject(forKey: "ladder_user_role")
        UserDefaults.standard.removeObject(forKey: "ladder_consent_given")
        UserDefaults.standard.removeObject(forKey: "ladder_consent_version")
        authState = .unauthenticated
    }

    // MARK: - Sandbox Wipe
    // Deletes all user-scoped SwiftData for the current device. This guarantees
    // that signing up as a new account never surfaces data from a previous one.

    private func wipeAllUserData() {
        // ModelContainer is created in LadderApp; grab the shared one via a
        // background context and purge all user-scoped entities.
        Task { @MainActor in
            guard let container = Self.sharedContainer else { return }
            let context = ModelContext(container)
            do {
                try context.delete(model: StudentProfileModel.self)
                try context.delete(model: ApplicationModel.self)
                try context.delete(model: ChecklistItemModel.self)
                try context.delete(model: ChatSessionModel.self)
                try context.delete(model: ChatMessageModel.self)
                try context.delete(model: RoadmapMilestoneModel.self)
                // Scholarships + CollegeModels are shared reference data, don't wipe
                try context.save()
            } catch {
                print("[AuthManager] Wipe failed: \(error)")
            }
        }
    }

    /// Weak-held reference to the shared ModelContainer, assigned from LadderApp on launch
    static weak var sharedContainer: ModelContainer?

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        authState = .authenticated
    }
}
