import SwiftUI

// MARK: - Activity Impact View
// Generates 150-char Common App impact statements. Matches describe_your_activity Stitch design.

struct ActivityImpactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ActivityImpactViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    activitySummaryCard
                    currentDescriptionSection

                    if viewModel.hasGenerated {
                        aiTransition
                        enhancedDescriptionCard
                        proTip
                    }

                    if !viewModel.hasGenerated {
                        inputSection
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.sm)
                .padding(.bottom, 140)
            }

            // Bottom actions
            VStack {
                Spacer()
                bottomActions
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Enhance Activity")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Activity Summary Card

    private var activitySummaryCard: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            if !viewModel.activityName.isEmpty {
                Text("\(viewModel.activityName)\(viewModel.role.isEmpty ? "" : " - \(viewModel.role)")")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            if !viewModel.durationLabel.isEmpty {
                Text(viewModel.durationLabel)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSecondaryFixed)
                    .labelTracking()
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(LadderColors.secondaryFixed)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: LadderSpacing.md) {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text("ACTIVITY DETAILS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    LadderTextField("Activity name", text: $viewModel.activityName, icon: "star")
                    LadderTextField("Your role", text: $viewModel.role, icon: "person")

                    HStack(spacing: LadderSpacing.md) {
                        LadderTextField("Hours/week", text: $viewModel.hoursPerWeek, icon: "clock")
                        LadderTextField("Weeks/year", text: $viewModel.weeksPerYear, icon: "calendar")
                    }
                }
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack {
                        Text("YOUR DESCRIPTION")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Spacer()
                        Text("\(viewModel.description.count) / 150")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.outline)
                    }

                    TextEditor(text: $viewModel.description)
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 100)
                }
            }
        }
    }

    // MARK: - Current Description (shown after generation)

    @ViewBuilder
    private var currentDescriptionSection: some View {
        if viewModel.hasGenerated {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("YOUR CURRENT DESCRIPTION")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                    Spacer()
                    Text("\(viewModel.description.count) / 150")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.outline)
                }
                Text(viewModel.description.isEmpty ? "No description provided" : "\"\(viewModel.description)\"")
                    .font(LadderTypography.bodyMedium)
                    .italic()
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(LadderSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LadderColors.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
        }
    }

    // MARK: - AI Transition

    private var aiTransition: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [LadderColors.outlineVariant, LadderColors.primaryContainer],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 40)

            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(LadderColors.primary)
                Text("AI REWROTE IT")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
                    .labelTracking()
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(LadderColors.surfaceContainerHighest)
            .clipShape(Capsule())

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primaryContainer, LadderColors.secondaryFixed],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 40)
        }
    }

    // MARK: - Enhanced Description Card

    private var enhancedDescriptionCard: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text("Ladder's Version")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.primary)
                Spacer()
                Text("\(viewModel.characterCount) / 150")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
                if viewModel.characterCount <= 150 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.accentLime)
                }
            }

            Text(viewModel.generatedStatement)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onPrimaryContainer)
                .fixedSize(horizontal: false, vertical: true)
                .padding(LadderSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LadderColors.primaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                .ladderShadow(LadderElevation.floating)
        }
    }

    // MARK: - Pro Tip

    private var proTip: some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: "lightbulb")
                .foregroundStyle(LadderColors.tertiary)
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text("Pro Tip")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.tertiary)
                Text("150 characters is tight. Lead with your impact, not your tasks.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.tertiary)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.tertiaryFixed.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        HStack(spacing: LadderSpacing.lg) {
            if viewModel.hasGenerated {
                Button {
                    viewModel.regenerate()
                } label: {
                    VStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20))
                        Text("RETRY")
                            .font(LadderTypography.labelSmall)
                            .labelTracking()
                    }
                    .foregroundStyle(LadderColors.onSurface)
                    .padding(.horizontal, LadderSpacing.lg)
                    .padding(.vertical, LadderSpacing.md)
                }

                Button {
                    dismiss()
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("CONFIRM")
                            .font(LadderTypography.labelSmall)
                            .labelTracking()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, LadderSpacing.xl)
                    .padding(.vertical, LadderSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    .ladderShadow(LadderElevation.primaryGlow)
                }
            } else {
                LadderPrimaryButton(
                    viewModel.isGenerating ? "Generating..." : "Enhance with AI",
                    icon: "sparkles"
                ) {
                    viewModel.generateImpactStatement()
                }
                .opacity(viewModel.isFormValid ? 1 : 0.5)
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow.opacity(0.7))
    }
}

#Preview {
    NavigationStack {
        ActivityImpactView()
    }
}
