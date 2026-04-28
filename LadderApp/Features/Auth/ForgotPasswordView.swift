import SwiftUI

// Fix S1-3 — "Forgot password?" sheet. Presented from B2CLoginView and
// SchoolLoginView. Calls SupabaseAuthService.resetPasswordForEmail and
// shows a success or error state inline.

public struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var working = false
    @State private var sent = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                BrandGradient.auth
                BrandGradient.heroGlow

                VStack(spacing: 24) {
                    Spacer()

                    LadderLogoMark(size: 64, withShadow: true)

                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.ladderDisplay(28, relativeTo: .title))
                            .foregroundStyle(LadderBrand.cream100)
                        Text("Enter the email you signed up with. We'll send a reset link.")
                            .font(.ladderBody(14))
                            .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 8)

                    if sent {
                        sentBanner
                    } else {
                        inputSection
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LadderBrand.cream100)
                            .frame(width: 36, height: 36)
                            .background(LadderBrand.cream100.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            GradientInputField(
                label: "EMAIL",
                icon: "envelope",
                placeholder: "you@example.com",
                text: $email,
                keyboard: .emailAddress
            )

            Button { sendReset() } label: {
                HStack(spacing: 8) {
                    if working {
                        ProgressView().tint(LadderBrand.ink900)
                    } else {
                        Text("Send reset link").font(.ladderLabel(16))
                        Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canSend ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.18))
                .clipShape(Capsule())
                .shadow(color: canSend ? LadderBrand.lime500.opacity(0.35) : .clear, radius: 12, y: 4)
            }
            .disabled(!canSend || working)

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var sentBanner: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "envelope.badge.checkmark.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(LadderBrand.lime500)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check your email")
                        .font(.ladderLabel(15))
                        .foregroundStyle(LadderBrand.cream100)
                    Text("A password reset link has been sent to \(email). Check your spam folder if it doesn't arrive in a few minutes.")
                        .font(.ladderBody(13))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.8))
                }
            }
            .padding(16)
            .background(LadderBrand.lime500.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(LadderBrand.lime500.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button("Done") { dismiss() }
                .font(.ladderLabel(16))
                .foregroundStyle(LadderBrand.cream100)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(LadderBrand.cream100.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    private var canSend: Bool { email.contains("@") && email.count > 4 }

    private func sendReset() {
        Task { @MainActor in
            working = true
            error = nil
            defer { working = false }
            do {
                try await SupabaseAuthService.shared.resetPasswordForEmail(email.lowercased().trimmingCharacters(in: .whitespaces))
                sent = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
