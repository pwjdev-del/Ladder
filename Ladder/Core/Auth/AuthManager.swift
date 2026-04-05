import SwiftUI
import AuthenticationServices

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

        // For now, default to unauthenticated
        try? await Task.sleep(for: .seconds(1))
        authState = .unauthenticated
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
            // TODO: Uncomment with Supabase
            // let session = try await SupabaseManager.shared.client.auth.signUp(
            //     email: email, password: password
            // )
            // userId = session.user.id.uuidString
            // userEmail = email
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
            // TODO: Uncomment with Supabase
            // let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
            //     credentials: .init(provider: .apple, idToken: tokenString)
            // )
            // userId = session.user.id.uuidString
            // userEmail = credential.email ?? session.user.email

            // Check if new user needs onboarding
            // let hasProfile = try await checkStudentProfile()
            // authState = hasProfile ? .authenticated : .onboarding
            authState = .onboarding
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        // try? await SupabaseManager.shared.client.auth.signOut()
        userId = nil
        userEmail = nil
        authState = .unauthenticated
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        authState = .authenticated
    }
}
