import SwiftUI

// §14.1 — founder login. Dark utilitarian mood.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/founder_backdoor_login/

public struct FounderLoginView: View {
    @State private var founderId: String = ""
    @State private var password: String = ""
    @State private var totp: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var goDashboard = false

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                Text("LADDER · FOUNDER")
                    .font(.ladderCaps(12))
                    .tracking(3.0)
                    .foregroundStyle(LadderBrand.cream100.opacity(0.85))

                card

                Spacer()

                Text("This surface does not render tenant data.\nEvery action is audited.")
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goDashboard) {
            FounderDashboardView()
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            GradientInputField(label: "FOUNDER ID",
                               icon: "person.badge.key",
                               placeholder: "FND-0000",
                               text: $founderId,
                               capitalization: .characters,
                               mono: true)
            PasswordField(label: "PASSWORD",
                          icon: "key",
                          placeholder: "••••••••••••",
                          text: $password,
                          onDarkSurface: true)
            GradientInputField(label: "TOTP CODE",
                               icon: "lock.shield",
                               placeholder: "000000",
                               text: $totp,
                               keyboard: .numberPad,
                               mono: true)

            Button {
                submit()
            } label: {
                HStack(spacing: 8) {
                    if working { ProgressView().tint(LadderBrand.ink900) }
                    else {
                        Text("Enter").font(.ladderLabel(16))
                        Image(systemName: "arrow.right.square.fill").font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
            }
            .disabled(working || founderId.isEmpty || password.isEmpty || totp.isEmpty)
            .opacity((founderId.isEmpty || password.isEmpty || totp.isEmpty) ? 0.7 : 1.0)

            if let error {
                Text(error)
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(LadderBrand.forest900.opacity(0.35))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LadderBrand.cream100.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func field(label: String,
                       icon: String,
                       placeholder: String,
                       binding: Binding<String>,
                       secure: Bool = false,
                       keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(LadderBrand.ink600)
                if secure {
                    SecureField(placeholder, text: binding)
                        .font(.ladderBody(15).monospaced())
                } else {
                    TextField(placeholder, text: binding)
                        .font(.ladderBody(15).monospaced())
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(LadderBrand.stone200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func submit() {
        Task { @MainActor in
            working = true
            error = nil
            defer { working = false }
            do {
                // TODO(server): founder TOTP must verify server-side via Edge Function
                // /functions/v1/founder-login (Phase 4). That function will accept
                // founderId + password + totp and return a short-lived founder JWT.
                // For now, sign in via Supabase email/password only. TOTP field is
                // collected but not validated client-side; server-side validation ships Phase 4.
                // founderId maps to email: FND-0001 → fnd-0001@ladder.internal
                let founderEmail = "\(founderId.lowercased())@ladder.internal"
                _ = try await SupabaseAuthService.shared.signInWithPassword(
                    email: founderEmail,
                    password: password
                )
                // B1 — verify JWT role before navigating. A non-founder JWT must not
                // reach FounderDashboardView even if the email pattern matched.
                // TenantContext.bind was already called inside signInWithPassword.
                guard TenantContext.shared.claim?.role == .founder else {
                    // Sign out the (wrong-role) session so we don't leave a half-bound state.
                    try? await SupabaseAuthService.shared.signOut()
                    self.error = "This account is not authorized for founder login."
                    return
                }
                goDashboard = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
