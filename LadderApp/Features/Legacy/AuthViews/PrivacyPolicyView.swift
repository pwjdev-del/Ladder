import SwiftUI

// MARK: - Privacy Policy View
// Full scrollable privacy policy. Accessible from ConsentView and Settings.

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: true) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xl) {
                        // Header
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Privacy Policy")
                                .font(LadderTypography.headlineLarge)
                                .foregroundStyle(LadderColors.onSurface)
                                .editorialTracking()

                            Text("Last Updated: \(LegalTexts.lastUpdated)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        legalTextBlock(LegalTexts.privacyPolicy)

                        Divider()

                        // FERPA Section
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Label("FERPA Notice", systemImage: "building.columns")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)

                            legalTextBlock(LegalTexts.ferpaNotice)
                        }

                        Divider()

                        // COPPA Section
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Label("COPPA Notice (Under 13)", systemImage: "person.badge.shield.checkmark")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)

                            legalTextBlock(LegalTexts.coppaNotice)
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
                    Text("Privacy Policy")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    private func legalTextBlock(_ text: String) -> some View {
        Text(text)
            .font(LadderTypography.bodyMedium)
            .foregroundStyle(LadderColors.onSurface)
            .lineSpacing(4)
    }
}
