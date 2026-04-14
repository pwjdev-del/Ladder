import SwiftUI

// MARK: - Terms of Service View
// Full scrollable ToS. Accessible from ConsentView and Settings.

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: true) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        // Header
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Terms of Service")
                                .font(LadderTypography.headlineLarge)
                                .foregroundStyle(LadderColors.onSurface)
                                .editorialTracking()

                            Text("Last Updated: \(LegalTexts.lastUpdated)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        // Key highlights card (plain language summary)
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Label("Quick Summary", systemImage: "list.bullet.clipboard")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)

                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                summaryRow("Ladder provides guidance only — no admissions guarantees", icon: "info.circle")
                                summaryRow("AI features may have errors — always verify important info", icon: "sparkles")
                                summaryRow("You own your essays and content — we never sell your data", icon: "lock.shield")
                                summaryRow("Must be 13+ to use, or have parental consent", icon: "person.badge.shield.checkmark")
                                summaryRow("Disputes resolved by binding arbitration in Florida", icon: "scalemass")
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.primaryContainer.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                        Divider()

                        // Full terms
                        Text("FULL TERMS OF SERVICE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        Text(LegalTexts.termsOfService)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineSpacing(4)

                        Divider()

                        // Liability Waiver
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Label("Acknowledgment & Waiver", systemImage: "signature")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)

                            Text(LegalTexts.liabilityWaiver)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineSpacing(4)
                        }

                        // Contact
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Questions?")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            Text("Email us at \(LegalTexts.companyEmail)")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.primary)
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                        Spacer().frame(height: LadderSpacing.xxxxl)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Terms of Service")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    private func summaryRow(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 20)
                .padding(.top, 2)

            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
