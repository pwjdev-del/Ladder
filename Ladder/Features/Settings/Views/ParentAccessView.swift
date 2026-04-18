import SwiftUI

// MARK: - Parent Access View
// Student's view to generate an invite code for their parent

struct ParentAccessView: View {
    @State private var inviteManager = InviteCodeManager()
    @State private var copiedToClipboard = false

    var body: some View {
        ScrollView {
            VStack(spacing: LadderSpacing.xl) {

                // MARK: - Header
                headerSection

                // MARK: - Code Display or Generate
                if let code = inviteManager.generatedCode, !inviteManager.isCodeExpired {
                    codeDisplaySection(code: code)
                } else {
                    generateSection
                }

                // MARK: - Instructions
                instructionsSection
            }
            .padding(LadderSpacing.lg)
            .padding(.top, LadderSpacing.md)
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Parent Access")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.primary)

            Text("Share Access with Your Parent")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.center)

            Text("Generate a code so your parent can view your progress in Ladder.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Code Display

    private func codeDisplaySection(code: String) -> some View {
        VStack(spacing: LadderSpacing.lg) {
            LadderCard(elevated: true) {
                VStack(spacing: LadderSpacing.md) {
                    Text("Your Invite Code")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    // Large code display with letter spacing
                    Text(code)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundStyle(LadderColors.primary)
                        .tracking(8)
                        .padding(.vertical, LadderSpacing.sm)

                    // Expiration countdown
                    if let timeRemaining = inviteManager.timeRemainingString {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                            Text(timeRemaining)
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(
                            timeRemaining == "Expired"
                                ? LadderColors.error
                                : LadderColors.onSurfaceVariant
                        )
                    }

                    // Copy button
                    Button {
                        UIPasteboard.general.string = code
                        copiedToClipboard = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedToClipboard = false
                        }
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 14, weight: .semibold))
                            Text(copiedToClipboard ? "Copied" : "Copy Code")
                                .font(LadderTypography.labelLarge)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .frame(maxWidth: .infinity)
            }

            // Generate new code
            LadderSecondaryButton("Generate New Code") {
                _ = inviteManager.generateInviteCode()
            }
        }
    }

    // MARK: - Generate Section

    private var generateSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            LadderCard {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(LadderColors.primary)

                    Text("No active code")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Generate an invite code to share with your parent. The code will be valid for 48 hours.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }

            LadderPrimaryButton("Generate Code", icon: "plus") {
                _ = inviteManager.generateInviteCode()
            }
        }
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("How it works")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            instructionRow(step: "1", text: "Share the code above with your parent")
            instructionRow(step: "2", text: "Your parent should download Ladder")
            instructionRow(step: "3", text: "They select \"I am a Parent\" during sign-up")
            instructionRow(step: "4", text: "They enter this code to link to your account")
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func instructionRow(step: String, text: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Text(step)
                .font(LadderTypography.labelLarge)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(LadderColors.primary)
                .clipShape(Circle())

            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }
}

#Preview {
    NavigationStack {
        ParentAccessView()
    }
}
