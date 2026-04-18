import SwiftUI
import AuthenticationServices

// MARK: - Login View
// Matches login_ui Stitch mockup: dark green bg, social login, email/password
// Now includes role selector for multi-role authentication

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .student
    @State private var showSignUp = false
    @State private var showResetAlert = false
    @State private var resetEmail = ""

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

                    // Red error banner above the form
                    if let error = authManager.errorMessage {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            Text(error)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(LadderSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LadderColors.error)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }

                    // Ladder logo
                    Image("LadderLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

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

                    // MARK: - Role Selector
                    VStack(spacing: LadderSpacing.sm) {
                        Text("I am a...")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.sm) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                RoleCard(
                                    role: role,
                                    isSelected: selectedRole == role
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedRole = role
                                    }
                                }
                            }
                        }
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
                            Button("Forgot Password?") {
                                showResetAlert = true
                            }
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.secondaryFixed)
                        }
                    }

                    // Login button
                    Button {
                        Task { await authManager.signIn(email: email, password: password, role: selectedRole) }
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
                        Text("Or sign in with")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.5))
                        Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
                    }

                    // Sign in with Apple
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
            SignUpView(selectedRole: selectedRole)
        }
        .alert("Reset Password", isPresented: $showResetAlert) {
            TextField("Email", text: $resetEmail)
            Button("Send Reset Link") { /* TODO: Replace with AWS Cognito */ }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your email to receive a password reset link.")
        }
        .onChange(of: email) { _, _ in
            if authManager.errorMessage != nil { authManager.errorMessage = nil }
        }
        .onChange(of: password) { _, _ in
            if authManager.errorMessage != nil { authManager.errorMessage = nil }
        }
        .onChange(of: selectedRole) { _, _ in
            if authManager.errorMessage != nil { authManager.errorMessage = nil }
        }
    }
}

// MARK: - Role Card

struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: LadderSpacing.sm) {
                Image(systemName: role.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? LadderColors.primary : .white.opacity(0.7))

                Text(role.displayName)
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(isSelected ? LadderColors.onSurface : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.md)
            .background(isSelected ? LadderColors.surface : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                    .stroke(isSelected ? LadderColors.primary : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var ageVerified: Bool = UserDefaults.standard.bool(forKey: "age_verified")
    var selectedRole: UserRole = .student

    /// Students must pass age verification before creating an account (COPPA compliance)
    private var needsAgeGate: Bool {
        selectedRole == .student && !ageVerified
    }

    var body: some View {
        NavigationStack {
            if needsAgeGate {
                AgeGateView {
                    ageVerified = true
                }
            } else {
                signUpForm
            }
        }
    }

    private var signUpForm: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.xl) {
                    Text("Create Account")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Start your college journey as a \(selectedRole.displayName)")
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    // Selected role badge
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: selectedRole.icon)
                            .font(.system(size: 16))
                        Text(selectedRole.displayName)
                            .font(LadderTypography.labelMedium)
                    }
                    .foregroundStyle(LadderColors.primary)
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(Capsule())

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
                        Task { await authManager.signUp(email: email, password: password, role: selectedRole) }
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

#Preview {
    LoginView()
        .environment(AuthManager())
}
