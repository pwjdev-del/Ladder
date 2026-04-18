import SwiftUI

// §6.1 — invite code redemption.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/invite_redemption/

public struct InviteRedemptionView: View {
    public let code: String
    public let tenantId: UUID

    @State private var codeInput: String
    @State private var email: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var success = false
    @Environment(\.dismiss) private var dismiss

    public init(code: String, tenantId: UUID) {
        self.code = code
        self.tenantId = tenantId
        self._codeInput = State(initialValue: code)
    }

    public var body: some View {
        ZStack {
            LadderBrand.lime500.opacity(0.18).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 24)
                card
                    .padding(.horizontal, 24)
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar (forest wordmark)

    private var topBar: some View {
        ZStack {
            LadderBrand.forest700.ignoresSafeArea(edges: .top)

            HStack {
                Text("Ladder")
                    .font(.ladderDisplay(24, relativeTo: .title2).italic())
                    .foregroundStyle(LadderBrand.cream100)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderBrand.cream100)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 80)
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Join Your School")
                    .font(.ladderDisplay(26, relativeTo: .title))
                    .foregroundStyle(LadderBrand.ink900)
                    .multilineTextAlignment(.center)
                Text("Enter your details to redeem your invitation.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.ink600)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                InputField(label: "INVITE CODE", icon: "ticket", placeholder: "LDR-XXXX-XXXX", text: $codeInput)
                InputField(label: "YOUR SCHOOL EMAIL", icon: "envelope", placeholder: "student@school.edu", text: $email, keyboard: .emailAddress)
            }

            Button {
                redeem()
            } label: {
                HStack(spacing: 8) {
                    if working {
                        ProgressView().tint(LadderBrand.ink900)
                    } else {
                        Text("Join")
                            .font(.ladderLabel(16))
                        Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(LadderBrand.ink900)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
            }
            .disabled(working || codeInput.isEmpty || email.isEmpty)

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }

            if success {
                Text("Welcome aboard! 🎉")
                    .font(.ladderLabel(15))
                    .foregroundStyle(LadderBrand.forest700)
            }

            HStack(spacing: 4) {
                Text("Need help?")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.ink600)
                Text("Contact your counselor")
                    .font(.ladderBody(13).bold())
                    .foregroundStyle(LadderBrand.ink900)
                    .underline()
            }
        }
        .padding(24)
        .background(LadderBrand.paper)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: 8)
    }

    private func redeem() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: POST /functions/v1/invite-redeem
            error = "Backend not yet deployed — wiring in a follow-up PR."
        }
    }
}
