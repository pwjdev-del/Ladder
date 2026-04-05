import SwiftUI
import AuthenticationServices

// MARK: - Login View
// Matches login_ui Stitch mockup: dark green bg, social login, email/password

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            // Dark green gradient background
            LinearGradient(
                colors: [LadderColors.primaryContainer, LadderColors.primary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative blur circles
            Circle()
                .fill(LadderColors.secondaryFixed.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)

            Circle()
                .fill(LadderColors.accentLime.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: 120, y: 100)

            ScrollView {
                VStack(spacing: LadderSpacing.xxl) {
                    Spacer().frame(height: LadderSpacing.xxxxl)

                    // Logo badge
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                            .fill(LadderColors.secondaryFixed)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(12))

                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(LadderColors.primary)
                    }

                    // Welcome text
                    VStack(spacing: LadderSpacing.sm) {
                        Text("Welcome Back")
                            .font(LadderTypography.displaySmall)
                            .foregroundStyle(.white)
                            .editorialTracking()

                        Text("Elevate your academic journey")
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // Form fields
                    VStack(spacing: LadderSpacing.lg) {
                        // Email
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "envelope")
                                .foregroundStyle(.white.opacity(0.6))
                            TextField("", text: $email, prompt: Text("Email address").foregroundStyle(.white.opacity(0.4)))
                                .foregroundStyle(.white)
                                .font(LadderTypography.bodyLarge)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }
                        .padding(LadderSpacing.md)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // Password
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "lock")
                                .foregroundStyle(.white.opacity(0.6))
                            SecureField("", text: $password, prompt: Text("Password").foregroundStyle(.white.opacity(0.4)))
                                .foregroundStyle(.white)
                                .font(LadderTypography.bodyLarge)
                        }
                        .padding(LadderSpacing.md)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {}
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.secondaryFixed)
                        }
                    }

                    // Error message
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.error)
                            .padding(.horizontal)
                    }

                    // Login button
                    Button {
                        Task { await authManager.signIn(email: email, password: password) }
                    } label: {
                        Text("LOGIN")
                            .font(LadderTypography.labelLarge)
                            .labelTracking()
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.lg)
                            .background(LadderColors.accentLime)
                            .clipShape(Capsule())
                            .ladderShadow(LadderElevation.glow)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Divider
                    HStack {
                        Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
                        Text("Or continue with")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.5))
                        Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
                    }

                    // Social login buttons
                    HStack(spacing: LadderSpacing.md) {
                        // Google
                        Button {
                            // TODO: Google Sign-In
                        } label: {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text("Google")
                                    .font(LadderTypography.labelLarge)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.md)
                            .background(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        // Apple
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let auth):
                                if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                                    Task { await authManager.signInWithApple(credential: credential) }
                                }
                            case .failure:
                                break
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }

                    // Sign up link
                    HStack(spacing: LadderSpacing.xs) {
                        Text("Don't have an account?")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(.white.opacity(0.6))
                        Button("Create Account") {
                            showSignUp = true
                        }
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.secondaryFixed)
                    }

                    Spacer().frame(height: LadderSpacing.xl)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.xl) {
                        Text("Create Account")
                            .font(LadderTypography.headlineLarge)
                            .foregroundStyle(LadderColors.onSurface)
                            .editorialTracking()

                        Text("Start your college journey today")
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        VStack(spacing: LadderSpacing.lg) {
                            LadderTextField("Email address", text: $email, icon: "envelope")
                            LadderSecureField("Password", text: $password, icon: "lock")
                            LadderSecureField("Confirm password", text: $confirmPassword, icon: "lock")
                        }

                        if let error = authManager.errorMessage {
                            Text(error)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.error)
                        }

                        LadderPrimaryButton("Create Account", icon: "arrow.right") {
                            guard password == confirmPassword else {
                                authManager.errorMessage = "Passwords don't match"
                                return
                            }
                            Task { await authManager.signUp(email: email, password: password) }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.top, LadderSpacing.xl)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
