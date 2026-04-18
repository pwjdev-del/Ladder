import SwiftUI

// §3.2 — per-school login. Brand gradient (no white), press-and-hold
// password reveal. When backend isn't wired, the "Sign in" button still
// gives a real response so testers know what they typed reached the app.

public struct SchoolLoginView: View {
    public let school: PartnerSchool

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var inviteCode: String = ""
    @State private var showingInviteFlow = false
    @State private var working = false
    @State private var error: String?
    @State private var signedIn = false
    @Environment(\.dismiss) private var dismiss

    public init(school: PartnerSchool) { self.school = school }

    public var body: some View {
        ZStack {
            BrandGradient.auth
            BrandGradient.heroGlow

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
                footer
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingInviteFlow) {
            InviteRedemptionView(code: inviteCode, tenantId: school.id)
        }
        .navigationDestination(isPresented: $signedIn) {
            PlaceholderSignedInView(displayName: email.isEmpty ? "student" : email, tenantName: school.displayName)
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

            Image("LadderLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.18), radius: 10, y: 4)

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
            Button("Forgot password?") { /* TODO */ }
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
            try? await Task.sleep(nanoseconds: 700_000_000)

            // TODO: SupabaseAuthService.signIn(email:password:tenantId:)
            // Until the backend lands, accept any of the seeded test accounts
            // from docs/runbooks/test-accounts.md so testers get a usable flow.
            let acceptedEmails: Set<String> = [
                "admin.lwrpa@ladder.test",
                "counselor.lwrpa@ladder.test",
                "alice.lwrpa@ladder.test",
                "bob.lwrpa@ladder.test",
                "carol.lwrpa@ladder.test",
            ]
            if acceptedEmails.contains(email.lowercased()) && password == "Ladder!v2-pilot" {
                signedIn = true
            } else {
                error = "Couldn't sign in. Use a seeded test account — see docs/runbooks/test-accounts.md."
            }
        }
    }
}

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
                Image("LadderLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

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
