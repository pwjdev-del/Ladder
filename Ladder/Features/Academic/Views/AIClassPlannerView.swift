import SwiftUI
import SwiftData

// MARK: - AI Class Planner View
// Shows AI-recommended 7-period class schedule based on student profile

struct AIClassPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @State private var viewModel = AIClassPlannerViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else if let recommendation = viewModel.recommendation {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        headerSection
                        infoBanner
                        periodCards(recommendation.classes)
                        summaryBar
                        actionButtons
                        Spacer().frame(height: LadderSpacing.xl)
                    }
                    .padding(.horizontal, LadderSpacing.md)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .onAppear { viewModel.loadStudent(from: profiles) }
        .alert("Submitted", isPresented: $viewModel.showSubmitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your class plan has been sent to your counselor for review. You will be notified when they respond.")
        }
        .alert("Draft Saved", isPresented: $viewModel.showSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your class plan draft has been saved. You can return to edit it anytime.")
        }
        .sheet(isPresented: $viewModel.showSwapSheet) {
            swapSheet
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Your AI Class Plan")
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(viewModel.semesterLabel)
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                // Grade badge
                Text("Grade \(viewModel.studentGrade)")
                    .font(LadderTypography.labelLarge)
                    .foregroundStyle(LadderColors.onPrimary)
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(LadderColors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(LadderColors.secondary)

            Text("Based on your career interest (\(viewModel.studentCareer)), GPA (\(viewModel.gpaFormatted)), and graduation requirements")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
    }

    // MARK: - Period Cards

    private func periodCards(_ classes: [ClassRecommendation]) -> some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(classes) { classRec in
                periodCard(classRec)
            }
        }
    }

    private func periodCard(_ classRec: ClassRecommendation) -> some View {
        HStack(spacing: LadderSpacing.md) {
            // Period number
            VStack {
                Text("P\(classRec.period)")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onPrimary)
            }
            .frame(width: 44, height: 44)
            .background(LadderColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

            // Class info
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                HStack(spacing: LadderSpacing.sm) {
                    Text(classRec.className)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    if classRec.isAP {
                        apBadge
                    }
                    if classRec.isHonors {
                        honorsBadge
                    }
                }

                Text(classRec.reason)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineLimit(2)
            }

            Spacer()

            // Swap button
            Button {
                viewModel.showAlternatives(for: classRec.period)
            } label: {
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 36, height: 36)
                    .background(LadderColors.surfaceContainerHigh)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
        .ladderShadow(LadderElevation.ambient)
    }

    // MARK: - Badges

    private var apBadge: some View {
        Text("AP")
            .font(LadderTypography.labelSmall)
            .foregroundStyle(.white)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(LadderColors.secondary)
            .clipShape(Capsule())
    }

    private var honorsBadge: some View {
        Text("Honors")
            .font(LadderTypography.labelSmall)
            .foregroundStyle(LadderColors.onSurfaceVariant)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(LadderColors.surfaceContainerHighest)
            .clipShape(Capsule())
    }

    // MARK: - Summary Bar

    private var summaryBar: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(LadderColors.primary)

            Text(viewModel.summaryText)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(LadderSpacing.md)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [LadderColors.primaryContainer.opacity(0.3), LadderColors.surfaceContainerLow],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: LadderSpacing.sm) {
            // Submit to Counselor
            Button {
                viewModel.submitToCounselor()
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "paperplane.fill")
                    Text("Submit to Counselor")
                }
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
                .ladderShadow(LadderElevation.primaryGlow)
            }
            .buttonStyle(.plain)

            // Save Draft
            Button {
                viewModel.saveDraft()
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Draft")
                }
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surfaceContainerHigh)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: LadderSpacing.lg) {
            ProgressView()
                .tint(LadderColors.primary)
                .scaleEffect(1.2)
            Text("Building your personalized schedule...")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Swap Sheet

    private var swapSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.md) {
                        if let period = viewModel.selectedPeriod,
                           let current = viewModel.recommendation?.classes.first(where: { $0.period == period }) {
                            // Current class
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Current Selection")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)

                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(LadderColors.primary)
                                    Text(current.className)
                                        .font(LadderTypography.titleMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                }
                                .padding(LadderSpacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(LadderColors.primaryContainer.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                            }
                            .padding(.top, LadderSpacing.md)
                        }

                        // Alternatives
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Alternatives")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            ForEach(viewModel.swapAlternatives) { alt in
                                Button {
                                    viewModel.swapClass(with: alt)
                                } label: {
                                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                                        HStack(spacing: LadderSpacing.sm) {
                                            Text(alt.className)
                                                .font(LadderTypography.titleMedium)
                                                .foregroundStyle(LadderColors.onSurface)
                                            Spacer()
                                            if alt.isAP { apBadge }
                                            if alt.isHonors { honorsBadge }
                                        }
                                        Text(alt.reason)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(LadderSpacing.md)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(LadderColors.surfaceContainerLowest)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)
                }
            }
            .navigationTitle("Swap Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showSwapSheet = false }
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        AIClassPlannerView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
