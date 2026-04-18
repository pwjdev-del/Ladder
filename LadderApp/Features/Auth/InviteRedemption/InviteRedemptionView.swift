import SwiftUI

// §6.1 — invite code redemption on the brand gradient.

public struct InviteRedemptionView: View {
    public let code: String
    public let tenantId: UUID

    @State private var codeInput: String
    @State private var email: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var session: SignedInSession?
    @Environment(\.dismiss) private var dismiss

    public init(code: String, tenantId: UUID) {
        self.code = code
        self.tenantId = tenantId
        self._codeInput = State(initialValue: code)
    }

    public var body: some View {
        ZStack {
            BrandGradient.auth
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 24)
                card
                    .padding(.horizontal, 24)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $session) { session in
            SignedInRouter(session: session)
        }
    }

    private var topBar: some View {
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
            Text("Ladder")
                .font(.ladderDisplay(20, relativeTo: .title3).italic())
                .foregroundStyle(LadderBrand.cream100)
            Spacer()
            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var card: some View {
        VStack(spacing: 20) {
            LadderLogoMark(size: 72, withShadow: true, style: .cream)

            VStack(spacing: 8) {
                Text("Join Your School")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                    .multilineTextAlignment(.center)
                Text("Enter your details to redeem your invitation.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                GradientInputField(
                    label: "INVITE CODE",
                    icon: "ticket",
                    placeholder: "LDR-XXXX-XXXX",
                    text: $codeInput,
                    capitalization: .characters,
                    mono: true
                )
                GradientInputField(
                    label: "YOUR SCHOOL EMAIL",
                    icon: "envelope",
                    placeholder: "student@school.edu",
                    text: $email,
                    keyboard: .emailAddress
                )
            }

            Button { redeem() } label: {
                HStack(spacing: 8) {
                    if working { ProgressView().tint(LadderBrand.ink900) }
                    else {
                        Text("Join").font(.ladderLabel(16))
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

            if let error {
                Text(error)
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.statusRed)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 4) {
                Text("Need help?")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                Text("Contact your counselor")
                    .font(.ladderBody(13).bold())
                    .foregroundStyle(LadderBrand.lime500)
                    .underline()
            }
        }
        .padding(24)
        .background(LadderBrand.cream100.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LadderBrand.cream100.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var formReady: Bool {
        !codeInput.isEmpty && email.contains("@")
    }

    private func redeem() {
        Task { @MainActor in
            working = true
            error = nil
            defer { working = false }
            try? await Task.sleep(nanoseconds: 700_000_000)

            let validCodes: Set<String> = ["LDR-TEST-0001", "LDR-TEST-BULK-A", "LDR-TEST-G5"]
            if validCodes.contains(codeInput.uppercased()) && email.contains("@") {
                // Assume student redemption for now; kind lives on the
                // invite_codes row in the real backend.
                session = SignedInSession(
                    role: .student,
                    displayName: String(email.split(separator: "@").first ?? ""),
                    tenantName: "your school"
                )
            } else {
                error = "We couldn't use that code. Ask your counselor to issue a new one."
            }
        }
    }
}
