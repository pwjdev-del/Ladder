import SwiftUI

// §14.1 — employee login. Phase 1: email + password only (no TOTP).
// Visual language matches FounderLoginView: dark forest, lime accents.
// Employee accounts are provisioned manually by a founder via:
//   supabase.auth.admin.updateUserById(uid, { app_metadata: { role: 'employee' } })

public struct EmployeeLoginView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var goDashboard = false

    // S2-5: client-side throttle — 1 submit per 5 seconds, defense-in-depth
    @State private var lastSubmitAt: Date?
    @State private var isSubmitting: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("LADDER · EMPLOYEE")
                    .font(.ladderCaps(12))
                    .tracking(3.0)
                    .foregroundStyle(LadderBrand.cream100.opacity(0.85))

                // MaxWidthContainer prevents the card from stretching on iPad
                MaxWidthContainer(maxWidth: 480) {
                    card
                }

                Spacer()

                Text("This surface does not render tenant data.\nEvery action is audited.")
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, sizeClass == .regular ? 0 : 24)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goDashboard) {
            EmployeeDashboardView(onLogout: signOut)
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            GradientInputField(
                label: "EMAIL",
                icon: "envelope",
                placeholder: "you@ladder.team",
                text: $email,
                keyboard: .emailAddress
            )
            .onChange(of: email) { error = nil }

            PasswordField(
                label: "PASSWORD",
                icon: "key",
                placeholder: "••••••••••••",
                text: $password,
                onDarkSurface: true
            )
            .onChange(of: password) { error = nil }

            Button {
                submit()
            } label: {
                HStack(spacing: 8) {
                    if working || isSubmitting {
                        ProgressView().tint(LadderBrand.ink900)
                    } else {
                        Text("Sign in").font(.ladderLabel(16))
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
            }
            .disabled(working || isSubmitting || email.isEmpty || password.isEmpty || isThrottled)
            .opacity((email.isEmpty || password.isEmpty || isThrottled) ? 0.7 : 1.0)

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

    // MARK: - Actions

    // S2-5: true when fewer than 5 seconds have elapsed since the last submit.
    private var isThrottled: Bool {
        guard let last = lastSubmitAt else { return false }
        return Date().timeIntervalSince(last) < 5
    }

    private func submit() {
        // S2-5: client-side throttle — reject rapid successive submits.
        let now = Date()
        if let last = lastSubmitAt, now.timeIntervalSince(last) < 5 {
            error = "Please wait a moment before trying again."
            return
        }
        lastSubmitAt = now
        isSubmitting = true

        Task { @MainActor in
            defer { isSubmitting = false }
            working = true
            error = nil
            defer { working = false }
            do {
                _ = try await SupabaseAuthService.shared.signInWithPassword(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )

                // Role-check: the JWT must contain role=employee.
                // Any other role rejects immediately to avoid cross-surface access.
                guard TenantContext.shared.claim?.role == .employee else {
                    try? await SupabaseAuthService.shared.signOut()
                    self.error = "Not authorized. This login is for Ladder employees only."
                    return
                }

                goDashboard = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    private func signOut() {
        Task {
            try? await SupabaseAuthService.shared.signOut()
        }
    }
}
