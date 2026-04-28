import SwiftUI

// §3.1 — B2C "Log in with your ID" now on the brand gradient with
// press-and-hold password reveal + seeded-account acceptance so signing
// in from the sim actually lands on a confirmation screen.

public struct B2CLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var session: SignedInSession?
    @State private var showingForgotPassword = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            BrandGradient.auth
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                hero
                ScrollView {
                    VStack(spacing: 24) {
                        signInBlock
                        footerLinks
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $session) { session in
            SignedInRouter(session: session)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }

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

            LadderLogoMark(size: 80, withShadow: true)

            Text("Ladder")
                .font(.ladderDisplay(26, relativeTo: .title).italic())
                .foregroundStyle(LadderBrand.cream100)
        }
        .padding(.top, 8)
    }

    private var signInBlock: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Welcome back")
                    .font(.ladderDisplay(32, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Text("Log in with your Ladder ID.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.75))
            }

            VStack(spacing: 12) {
                GradientInputField(
                    label: "EMAIL",
                    icon: "envelope",
                    placeholder: "you@example.com",
                    text: $email,
                    keyboard: .emailAddress
                )
                PasswordField(label: "PASSWORD", text: $password, onDarkSurface: true)
            }

            Button { submit() } label: {
                HStack(spacing: 8) {
                    if working { ProgressView().tint(LadderBrand.ink900) }
                    else {
                        Text("Log in").font(.ladderLabel(16))
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

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 4) {
                Text("First time?").font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100.opacity(0.75))
                NavigationLink { B2CSignupView() } label: {
                    Text("Create an account")
                        .font(.ladderBody(13).bold())
                        .foregroundStyle(LadderBrand.lime500)
                        .underline()
                }
            }
            .padding(.top, 4)
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 24) {
            Button("Forgot password?") { showingForgotPassword = true }
            Button("Help") { /* TODO */ }
        }
        .font(.ladderBody(13))
        .foregroundStyle(LadderBrand.cream100.opacity(0.7))
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
                // Grade level was fetched from students table and cached on TenantContext
                // by SupabaseAuthService.bindTenantContext — read it directly here.
                let grade = TenantContext.shared.studentGradeLevel
                session = SignedInSession(
                    role: role,
                    displayName: String(supabaseSession.user.email?.split(separator: "@").first ?? ""),
                    tenantName: TenantContext.shared.tenantDisplayName ?? "Ladder",
                    gradeLevel: grade
                )
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
