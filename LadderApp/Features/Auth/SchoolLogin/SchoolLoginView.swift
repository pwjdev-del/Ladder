import SwiftUI

// §3.2 — per-school login. Brand gradient (no white), press-and-hold
// password reveal. When backend isn't wired, the "Sign in" button still
// gives a real response so testers know what they typed reached the app.

public struct SchoolLoginView: View {
    public let school: PartnerSchool

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var inviteCode: String = ""
    @State private var showingInviteFlow = false
    @State private var showingForgotPassword = false
    @State private var working = false
    @State private var error: String?
    @State private var session: SignedInSession?
    @Environment(\.dismiss) private var dismiss

    public init(school: PartnerSchool) { self.school = school }

    public var body: some View {
        ZStack {
            BrandGradient.auth
            BrandGradient.heroGlow

            if sizeClass == .regular {
                // iPad: school brand hero on left, scrollable form on right
                HStack(spacing: 0) {
                    padHero
                        .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(LadderBrand.cream100.opacity(0.12))
                        .frame(width: 1)
                        .padding(.vertical, 80)

                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 48)
                            MaxWidthContainer(maxWidth: 440) {
                                VStack(spacing: 24) {
                                    backButton
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    signInSection
                                    orDivider
                                    inviteSection
                                    footer
                                }
                                .padding(.horizontal, 40)
                            }
                            Spacer(minLength: 48)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxWidth: .infinity)
                }
            } else {
                // iPhone: original single-column layout, unchanged
                VStack(spacing: 0) {
                    hero
                    ScrollView {
                        VStack(spacing: 24) {
                            signInSection
                            orDivider
                            inviteSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    footer
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingInviteFlow) {
            InviteRedemptionView(code: inviteCode, tenantId: school.id)
        }
        .navigationDestination(item: $session) { session in
            SignedInRouter(session: session)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - iPad hero pane (left column)

    private var padHero: some View {
        VStack(spacing: 20) {
            Spacer()
            LadderLogoMark(size: 120, withShadow: true)
            Text(school.displayName)
                .font(.ladderDisplay(32, relativeTo: .largeTitle))
                .foregroundStyle(LadderBrand.cream100)
                .multilineTextAlignment(.center)
            Text("Powered by Ladder")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.6))
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Back button (iPad form column only)

    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(LadderBrand.cream100)
                .frame(width: 40, height: 40)
                .background(LadderBrand.cream100.opacity(0.12))
                .clipShape(Circle())
        }
    }

    // MARK: - Hero (logo + school name)

    private var hero: some View {
        VStack(spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(LadderBrand.cream100)
                        .frame(width: 40, height: 40)
                        .background(LadderBrand.cream100.opacity(0.12))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            LadderLogoMark(size: 72, withShadow: true)

            Text(school.displayName)
                .font(.ladderDisplay(22, relativeTo: .title2))
                .foregroundStyle(LadderBrand.cream100)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Sign in

    private var signInSection: some View {
        VStack(spacing: 16) {
            Text("Sign in")
                .font(.ladderDisplay(32, relativeTo: .title))
                .foregroundStyle(LadderBrand.cream100)

            Text("Welcome back to \(school.displayName).")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                GradientInputField(
                    label: "EMAIL ADDRESS",
                    icon: "envelope",
                    placeholder: "student@\(school.slug).edu",
                    text: $email,
                    keyboard: .emailAddress
                )
                PasswordField(label: "PASSWORD", text: $password, onDarkSurface: true)
            }

            Button { submit() } label: {
                HStack(spacing: 8) {
                    if working { ProgressView().tint(LadderBrand.ink900) }
                    else {
                        Text("Sign in").font(.ladderLabel(16))
                        Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(formReady ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.18))
                .clipShape(Capsule())
                .shadow(color: formReady ? LadderBrand.lime500.opacity(0.35) : .clear, radius: 12, y: 4)
            }
            .disabled(!formReady || working)
            .opacity(formReady ? 1.0 : 0.85)
            .padding(.top, 8)

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - OR divider

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(LadderBrand.cream100.opacity(0.3)).frame(height: 1)
            Text("OR")
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
            Rectangle().fill(LadderBrand.cream100.opacity(0.3)).frame(height: 1)
        }
    }

    // MARK: - Invite

    private var inviteSection: some View {
        VStack(spacing: 12) {
            Text("First time?")
                .font(.ladderDisplay(24, relativeTo: .title2))
                .foregroundStyle(LadderBrand.cream100)

            HStack(spacing: 10) {
                Image(systemName: "ticket")
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                TextField("", text: $inviteCode,
                          prompt: Text("INVITE-CODE").foregroundColor(LadderBrand.cream100.opacity(0.4)))
                    .font(.ladderBody(15).monospaced())
                    .foregroundStyle(LadderBrand.cream100)
                    .tint(LadderBrand.lime500)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(LadderBrand.cream100.opacity(0.12))
            .clipShape(Capsule())

            Button { showingInviteFlow = true } label: {
                Text("Join with invite code")
                    .font(.ladderLabel(15))
                    .foregroundStyle(LadderBrand.cream100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(Capsule().stroke(LadderBrand.cream100.opacity(0.4), lineWidth: 1))
            }
            .disabled(inviteCode.isEmpty)
            .opacity(inviteCode.isEmpty ? 0.5 : 1.0)
        }
        .padding(20)
        .background(LadderBrand.lime500.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LadderBrand.lime500.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var footer: some View {
        HStack(spacing: 24) {
            Button("Forgot password?") { showingForgotPassword = true }
            Button("Use a different school") { dismiss() }
        }
        .font(.ladderBody(13))
        .foregroundStyle(LadderBrand.cream100.opacity(0.7))
        .padding(.bottom, 24)
    }

    private var formReady: Bool {
        email.contains("@") && password.count >= 6
    }

    private func submit() {
        Task { @MainActor in
            working = true
            error = nil
            defer { working = false }
            do {
                let supabaseSession = try await SupabaseAuthService.shared.signInWithPassword(
                    email: email.lowercased(),
                    password: password
                )
                let claim = await TenantContext.shared.claim
                let role: SignedInRole = {
                    switch claim?.role {
                    case .admin:     return .admin
                    case .counselor: return .counselor
                    case .parent:    return .parent
                    case .founder:   return .founder
                    default:         return .student
                    }
                }()
                // Grade level fetched from students table and cached on TenantContext
                // by SupabaseAuthService after sign-in (RLS restricts to own row).
                let grade = TenantContext.shared.studentGradeLevel
                session = SignedInSession(
                    role: role,
                    displayName: String(supabaseSession.user.email?.split(separator: "@").first ?? ""),
                    tenantName: school.displayName,
                    gradeLevel: grade
                )
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
private let _previewSchool = PartnerSchool(
    id: UUID(),
    slug: "oakridge",
    displayName: "Oakridge High",
    primaryColorHex: nil,
    logoURL: nil
)

#Preview("iPhone 15") {
    SchoolLoginView(school: _previewSchool)
}

#Preview("iPad Air 10.9 portrait") {
    SchoolLoginView(school: _previewSchool)
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Air landscape") {
    SchoolLoginView(school: _previewSchool)
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Pro 12.9 portrait") {
    SchoolLoginView(school: _previewSchool)
        .environment(\.horizontalSizeClass, .regular)
}
#endif

// MARK: - Placeholder "you're in" screen while role dashboards are being wired

public struct PlaceholderSignedInView: View {
    public let displayName: String
    public let tenantName: String

    public init(displayName: String, tenantName: String) {
        self.displayName = displayName
        self.tenantName = tenantName
    }

    public var body: some View {
        ZStack {
            BrandGradient.auth
            BrandGradient.heroGlow

            VStack(spacing: 20) {
                LadderLogoMark(size: 96, withShadow: true)

                Text("You're in.")
                    .font(.ladderDisplay(34, relativeTo: .largeTitle))
                    .foregroundStyle(LadderBrand.cream100)

                Text("Welcome back to \(tenantName).\nYour role dashboard ships in the next PR.")
                    .font(.ladderBody(15))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(displayName.uppercased())
                    .font(.ladderCaps(11))
                    .tracking(1.4)
                    .foregroundStyle(LadderBrand.lime500)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(false)
    }
}
