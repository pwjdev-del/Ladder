import SwiftUI
import AuthenticationServices

// MARK: - Login View
// iPad: Green gradient bg + centered cream card (matches Stitch ipad_login_screen_3)
// iPhone: Full green gradient with form overlay (existing design)

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        if sizeClass == .regular {
            iPadLoginLayout
        } else {
            iPhoneLoginLayout
        }
    }

    // MARK: - iPad Layout (centered card over green gradient)

    private var iPadLoginLayout: some View {
        ZStack {
            // Full green gradient background
            LinearGradient(
                colors: [LadderColors.primary, LadderColors.primaryContainer, Color(red: 0.19, green: 0.31, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(LadderColors.secondaryFixed.opacity(0.2))
                .frame(width: 500, height: 500)
                .blur(radius: 120)
                .offset(x: -200, y: -150)

            Circle()
                .fill(LadderColors.secondaryFixed.opacity(0.15))
                .frame(width: 600, height: 600)
                .blur(radius: 140)
                .offset(x: 300, y: 200)

            // Decorative "Ladder" watermark bottom-right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Ladder")
                        .font(LadderTypography.displayLargeItalic)
                        .foregroundStyle(.white.opacity(0.08))
                        .scaleEffect(2)
                }
            }
            .padding(LadderSpacing.xxl)

            // Centered card
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        loginCardContent
                    }
                    .frame(maxWidth: 480)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    .shadow(color: Color(red: 0.12, green: 0.11, blue: 0.08).opacity(0.06), radius: 40, y: 20)
                    .padding(.vertical, LadderSpacing.xxl)
                }
            }

            // Footer links
            VStack {
                Spacer()
                HStack(spacing: LadderSpacing.xl) {
                    footerLink("PRIVACY POLICY")
                    footerLink("TERMS OF SERVICE")
                    footerLink("SUPPORT")
                }
                .padding(.bottom, LadderSpacing.lg)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }

    // MARK: - Login Card Content (shared)

    private var loginCardContent: some View {
        VStack(spacing: LadderSpacing.xl) {
            // Logo + heading
            VStack(spacing: LadderSpacing.lg) {
                // Diamond logo
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                        .fill(LadderColors.primary)
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(15))

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(-15))
                }

                VStack(spacing: LadderSpacing.sm) {
                    Text("Welcome Back")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    Text("Continue your academic journey at the Atelier.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            // Form fields
            VStack(spacing: LadderSpacing.lg) {
                // Email
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("EMAIL ADDRESS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                        .tracking(2)

                    LadderTextField("student@university.edu", text: $email, icon: "envelope")
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }

                // Password
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    HStack {
                        Text("PASSWORD")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                            .tracking(2)

                        Spacer()

                        Button("Forgot?") {}
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                    }

                    LadderSecureField("••••••••", text: $password, icon: "lock")
                }
            }

            // Error message
            if let error = authManager.errorMessage {
                Text(error)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.error)
            }

            // Login button (lime accent)
            Button {
                Task { await authManager.signIn(email: email, password: password) }
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Text("Log In")
                        .font(LadderTypography.labelLarge)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(LadderColors.onSecondaryFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(LadderColors.secondaryFixed)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())

            // Divider
            HStack {
                Rectangle().fill(LadderColors.outlineVariant.opacity(0.3)).frame(height: 1)
                Text("OR CONNECT VIA")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.outline)
                    .tracking(2)
                Rectangle().fill(LadderColors.outlineVariant.opacity(0.3)).frame(height: 1)
            }

            // Social login
            HStack(spacing: LadderSpacing.md) {
                // Apple
                Button {
                    // Apple Sign-In handled below
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16))
                        Text("Apple")
                            .font(LadderTypography.labelLarge)
                    }
                    .foregroundStyle(LadderColors.onSurface)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                    .background(LadderColors.surfaceContainerHighest)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }

                // Google
                Button {
                    // TODO: Google Sign-In
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Text("G")
                            .font(.system(size: 16, weight: .bold))
                        Text("Google")
                            .font(LadderTypography.labelLarge)
                    }
                    .foregroundStyle(LadderColors.onSurface)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                    .background(LadderColors.surfaceContainerHighest)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }
            }

            // Create account link
            HStack(spacing: LadderSpacing.xs) {
                Text("New to the Ladder?")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Button("Create Account") {
                    showSignUp = true
                }
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            }
        }
        .padding(LadderSpacing.xxl)
    }

    // MARK: - Footer Link

    private func footerLink(_ text: String) -> some View {
        Button(text) {}
            .font(LadderTypography.labelSmall)
            .foregroundStyle(.white.opacity(0.4))
            .tracking(2)
    }

    // MARK: - iPhone Layout (original full-gradient design)

    private var iPhoneLoginLayout: some View {
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
// iPad: Two-column (green branding left, white form right) — matches Stitch ipad_sign_up_screen

struct SignUpView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var selectedRole: UserRole = .student

    private var canCreateAccount: Bool {
        !email.isEmpty && password.count >= 8 && password == confirmPassword && agreedToTerms
    }

    var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    iPadSignUpLayout
                } else {
                    iPhoneSignUpLayout
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
            .sheet(isPresented: $showTerms) { TermsOfServiceView() }
            .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        }
    }

    // MARK: - iPad Sign Up (two-column)

    private var iPadSignUpLayout: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Left: Green branding panel
                ZStack {
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        Text("Ladder")
                            .font(LadderTypography.headlineMediumItalic)
                            .foregroundStyle(LadderColors.secondaryFixed)

                        Spacer()

                        Text("The path to\nyour future,\nrefined.")
                            .font(LadderTypography.displaySmall)
                            .foregroundStyle(.white)
                            .editorialTracking()
                            .lineSpacing(4)

                        Text("Join an elite community of students navigating the complexities of college admissions with editorial precision.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        Text("12,000+ STUDENTS ALREADY ENROLLED")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(2)
                    }
                    .padding(LadderSpacing.xxl)
                }
                .frame(width: geo.size.width * 0.4)

                // Right: White form panel
                ScrollView {
                    signUpFormContent
                        .padding(LadderSpacing.xxl)
                        .padding(.top, LadderSpacing.xl)
                }
                .background(LadderColors.surface)
                .frame(width: geo.size.width * 0.6)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Role picker (shared)

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("I AM A...")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                .tracking(2)

            VStack(spacing: LadderSpacing.sm) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button {
                        selectedRole = role
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: role.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(selectedRole == role ? LadderColors.primary : LadderColors.onSurfaceVariant)
                            VStack(alignment: .leading) {
                                Text(role.rawValue).font(LadderTypography.titleSmall)
                                Text(role.description).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            Spacer()
                            if selectedRole == role {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(LadderColors.primary)
                            }
                        }
                        .padding(LadderSpacing.md)
                        .background(selectedRole == role ? LadderColors.primary.opacity(0.08) : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Shared form content

    private var signUpFormContent: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xl) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Create Account")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .editorialTracking()

                Text("Begin your journey with the Academic Atelier.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            rolePicker

            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("EMAIL ADDRESS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                        .tracking(2)
                    LadderTextField("student@university.edu", text: $email, icon: "envelope")
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("PASSWORD")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                        .tracking(2)
                    LadderSecureField("Password (8+ characters)", text: $password, icon: "lock")
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("CONFIRM PASSWORD")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                        .tracking(2)
                    LadderSecureField("Confirm password", text: $confirmPassword, icon: "lock")
                }
            }

            // Consent
            Button {
                agreedToTerms.toggle()
            } label: {
                HStack(alignment: .top, spacing: LadderSpacing.sm) {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(agreedToTerms ? LadderColors.primary : LadderColors.onSurfaceVariant.opacity(0.5))

                    Text("I agree to the ")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurface)
                    + Text("Terms of Service")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.primary)
                        .underline()
                    + Text(" and ")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurface)
                    + Text("Privacy Policy")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.primary)
                        .underline()
                }
            }
            .buttonStyle(.plain)

            if let error = authManager.errorMessage {
                Text(error)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.error)
            }

            // Create Account button (lime)
            Button {
                guard password == confirmPassword else {
                    authManager.errorMessage = "Passwords don't match"
                    return
                }
                authManager.userRole = selectedRole
                Task { await authManager.signUp(email: email, password: password) }
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Text("Create Account")
                        .font(LadderTypography.labelLarge)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(LadderColors.onSecondaryFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(LadderColors.secondaryFixed)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .opacity(canCreateAccount ? 1 : 0.5)
            .disabled(!canCreateAccount)

            // Switch to login
            HStack(spacing: LadderSpacing.xs) {
                Text("Already have an account?")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Button("Log In") { dismiss() }
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - iPhone Sign Up (original)

    private var iPhoneSignUpLayout: some View {
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

                    rolePicker

                    VStack(spacing: LadderSpacing.lg) {
                        LadderTextField("Email address", text: $email, icon: "envelope")
                        LadderSecureField("Password (8+ characters)", text: $password, icon: "lock")
                        LadderSecureField("Confirm password", text: $confirmPassword, icon: "lock")
                    }

                    Button {
                        agreedToTerms.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: LadderSpacing.sm) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundStyle(agreedToTerms ? LadderColors.primary : LadderColors.onSurfaceVariant.opacity(0.5))
                                .padding(.top, 1)

                            Text("I am at least 13 years old and agree to the ")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                            + Text("Terms of Service")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.primary)
                                .underline()
                            + Text(" and ")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                            + Text("Privacy Policy")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.primary)
                                .underline()
                        }
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: LadderSpacing.lg) {
                        Button("Read Terms") { showTerms = true }
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                        Button("Read Privacy Policy") { showPrivacy = true }
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
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
                        authManager.userRole = selectedRole
                Task { await authManager.signUp(email: email, password: password) }
                    }
                    .opacity(canCreateAccount ? 1 : 0.5)
                    .disabled(!canCreateAccount)
                }
                .padding(LadderSpacing.lg)
                .padding(.top, LadderSpacing.xl)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
