import SwiftUI

// §3.1 — "Log in with your ID" B2C login.
// Brand: cream-on-forest hero with Ladder wordmark + logo, paper card
// with stone-200 inputs + lime pill CTA (same input shell used by
// SchoolLoginView / InviteRedemptionView / FounderLoginView). This
// replaces the stock white SwiftUI view that was showing up earlier.

public struct B2CLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var working = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.lime500.opacity(0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                ScrollView {
                    card
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                }
                footer
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Hero with logo

    private var hero: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea(edges: .top)

            VStack(spacing: 12) {
                Image("LadderLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                Text("Ladder")
                    .font(.ladderDisplay(24, relativeTo: .title2).italic())
                    .foregroundStyle(LadderBrand.cream100)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .frame(height: 180)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LadderBrand.cream100)
                    .padding(16)
            }
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Welcome back")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.ink900)
                Text("Log in with the email and password you created.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.ink600)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                InputField(label: "EMAIL", icon: "envelope", placeholder: "you@example.com", text: $email, keyboard: .emailAddress)
                InputField(label: "PASSWORD", icon: "lock", placeholder: "••••••••", text: $password, secure: true)
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
                .background(formReady ? LadderBrand.lime500 : LadderBrand.stone200)
                .clipShape(Capsule())
            }
            .disabled(!formReady || working)
            .opacity(formReady ? 1.0 : 0.7)

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 4) {
                Text("First time?")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.ink600)
                NavigationLink {
                    B2CSignupView()
                } label: {
                    Text("Create an account")
                        .font(.ladderBody(13).bold())
                        .foregroundStyle(LadderBrand.forest700)
                        .underline()
                }
            }
        }
        .padding(24)
        .background(LadderBrand.paper)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: 8)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 24) {
            Button("Forgot password?") { /* TODO */ }
            Button("Help") { /* TODO */ }
        }
        .font(.ladderBody(13))
        .foregroundStyle(LadderBrand.ink600)
        .padding(.bottom, 24)
    }

    private var formReady: Bool {
        !email.isEmpty && password.count >= 6
    }

    private func submit() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: wire to SupabaseAuthService.signIn(email:password:)
            // For now, surface the test-account hint so pilot testers know
            // where to find seeded credentials:
            error = "Auth backend not yet deployed.\nSee docs/runbooks/test-accounts.md for pilot credentials."
        }
    }
}
