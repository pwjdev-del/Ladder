import SwiftUI
import AuthenticationServices

// MARK: - User Role

enum UserRole: String, Codable, CaseIterable {
    case student
    case parent
    case counselor
    case schoolAdmin

    var displayName: String {
        switch self {
        case .student: return "Student"
        case .parent: return "Parent"
        case .counselor: return "Counselor"
        case .schoolAdmin: return "School Admin"
        }
    }

    var icon: String {
        switch self {
        case .student: return "graduationcap.fill"
        case .parent: return "figure.2.circle.fill"
        case .counselor: return "person.text.rectangle.fill"
        case .schoolAdmin: return "building.2.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .student: return "Track applications & prep"
        case .parent: return "Monitor your child's progress"
        case .counselor: return "Guide your caseload"
        case .schoolAdmin: return "Manage your school"
        }
    }
}

// MARK: - Auth Manager
// Manages authentication state machine for the entire app

@Observable
final class AuthManager {

    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case onboarding
        case authenticated
    }

    var authState: AuthState = .loading
    var userEmail: String?
    var userId: String?
    var errorMessage: String?

    /// The current user's role — persisted via @AppStorage wrapper in views,
    /// but stored here for in-memory access across the app.
    var userRole: UserRole = .student {
        didSet {
            UserDefaults.standard.set(userRole.rawValue, forKey: "user_role")
        }
    }

    /// School identifier for B2B users (counselors & school admins)
    var schoolId: String?

    /// When true, the user must change their auto-generated password before proceeding.
    var isFirstLogin: Bool = false

    // MARK: - Initialization

    init() {
        // Restore persisted role
        if let saved = UserDefaults.standard.string(forKey: "user_role"),
           let role = UserRole(rawValue: saved) {
            userRole = role
        }
    }

    // MARK: - Session Management

    func checkSession() async {
        // TODO: Replace with AWS Cognito session check
        // let session = try? await CognitoManager.shared.currentSession()
        // if let session {
        //     userId = session.userId
        //     userEmail = session.email
        //     userRole = session.role
        //     isFirstLogin = session.requiresPasswordChange
        //     let hasProfile = try? await checkProfile(for: userRole)
        //     authState = hasProfile == true ? .authenticated : .onboarding
        // } else {
        //     authState = .unauthenticated
        // }

        // For now, default to unauthenticated
        try? await Task.sleep(for: .seconds(1))
        authState = .unauthenticated
    }

    // MARK: - Email Auth

    /// UserDefaults key prefix used to simulate a "registered role" mapping
    /// per email while AWS Cognito is still TODO-stubbed.
    private static let registeredRoleKeyPrefix = "ladder.account.role."

    private func registeredRoleKey(for email: String) -> String {
        Self.registeredRoleKeyPrefix + email.lowercased()
    }

    private func registeredRole(for email: String) -> UserRole? {
        guard let raw = UserDefaults.standard.string(forKey: registeredRoleKey(for: email)) else {
            return nil
        }
        return UserRole(rawValue: raw)
    }

    private func storeRegisteredRole(_ role: UserRole, for email: String) {
        UserDefaults.standard.set(role.rawValue, forKey: registeredRoleKey(for: email))
    }

    func signIn(email: String, password: String, role: UserRole? = nil) async {
        errorMessage = nil

        // Validate picked role against the registered role (if one exists).
        // Legacy accounts without a stored role are accepted silently.
        if let role, let registered = registeredRole(for: email), registered != role {
            errorMessage = "This email is registered as a \(registered.displayName). Please pick \(registered.displayName) at login."
            return
        }

        // Update role if provided
        if let role {
            userRole = role
        }

        do {
            // TODO: Replace with AWS Cognito
            // let session = try await CognitoManager.shared.signIn(
            //     email: email, password: password
            // )
            // userId = session.userId
            // userEmail = email
            // userRole = session.role ?? role ?? .student
            // isFirstLogin = session.requiresPasswordChange
            // authState = isFirstLogin ? .authenticated : .authenticated
            authState = .authenticated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, role: UserRole? = nil) async {
        errorMessage = nil

        // Update role if provided
        if let role {
            userRole = role
        }

        do {
            // TODO: Replace with AWS Cognito
            // let session = try await CognitoManager.shared.signUp(
            //     email: email, password: password, role: userRole
            // )
            // userId = session.userId
            // userEmail = email

            // Persist the registered role so later sign-ins can validate
            // the picked role matches what was actually created.
            storeRegisteredRole(userRole, for: email)

            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign in with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            errorMessage = "Failed to get Apple ID token"
            return
        }

        do {
            // TODO: Replace with AWS Cognito
            // let session = try await CognitoManager.shared.signInWithApple(
            //     idToken: tokenString, role: userRole
            // )
            // userId = session.userId
            // userEmail = credential.email ?? session.email
            // userRole = session.role ?? userRole

            // Check if new user needs onboarding
            // let hasProfile = try await checkProfile(for: userRole)
            // authState = hasProfile ? .authenticated : .onboarding
            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        // TODO: Replace with AWS Cognito
        // try? await CognitoManager.shared.signOut()
        userId = nil
        userEmail = nil
        isFirstLogin = false
        authState = .unauthenticated
    }

    // MARK: - Force Password Change

    func changePassword(currentPassword: String, newPassword: String) async {
        errorMessage = nil
        do {
            // TODO: Replace with AWS Cognito
            // try await CognitoManager.shared.changePassword(
            //     current: currentPassword, new: newPassword
            // )
            isFirstLogin = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Role Management

    func setRole(_ role: UserRole) {
        userRole = role
        // TODO: Update role in Cognito user attributes
        // try? await AWSManager.shared.updateUserAttribute(key: "custom:role", value: role.rawValue)
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        authState = .authenticated
    }
}
