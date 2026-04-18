import SwiftUI

// MARK: - Class Recommendations View
// AI-generated course recommendations based on career path + target schools
// Matches my_classes_recommendations Stitch design

struct ClassRecommendationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ClassRecommendationsViewModel()
    @State private var showSubmitAlert = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    recommendationCards
                    creditProgressSection
                    submitButton
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.sm)
                .padding(.bottom, 120)
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
                Text("My Classes")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear { viewModel.loadRecommendations() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Based on your transcript and career path")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            if let path = viewModel.careerPath {
                Text(path + " Path")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSecondaryFixed)
                    .labelTracking()
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(LadderColors.secondaryFixed)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("Next Year's Schedule")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(LadderColors.primary)
                Text("AI-suggested for \(viewModel.gradeLabel)")
                    .font(LadderTypography.bodyLargeItalic)
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Recommendation Cards

    private var recommendationCards: some View {
        VStack(spacing: LadderSpacing.md) {
            ForEach(viewModel.recommendations) { rec in
                courseCard(rec)
            }
        }
    }

    private func courseCard(_ rec: ClassRecommendationsViewModel.CourseRecommendation) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.lg)
                    .fill(LadderColors.surfaceContainerHigh)
                    .frame(width: 48, height: 48)
                Image(systemName: rec.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text(rec.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Button {
                        viewModel.toggleSelected(rec)
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(rec.isSelected ? LadderColors.accentLime : LadderColors.outlineVariant, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            if rec.isSelected {
                                Circle()
                                    .fill(LadderColors.accentLime)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(LadderColors.onSecondaryFixed)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text(rec.tag.uppercased())
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(rec.tagColor)
                    .labelTracking()

                Text(rec.reason)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    // MARK: - Credit Progress

    private var creditProgressSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Your Credit Progress")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.primary)

            VStack(spacing: LadderSpacing.md) {
                ForEach(viewModel.creditProgress) { cat in
                    VStack(spacing: LadderSpacing.sm) {
                        HStack {
                            Text(cat.name.uppercased())
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                            Spacer()
                            Text("\(cat.earned) / \(cat.required) Credits")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                        }
                        LinearProgressBar(
                            progress: min(Double(cat.earned) / max(Double(cat.required), 1), 1.0),
                            height: 6
                        )
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        LadderPrimaryButton("Submit to Counselor", icon: "paperplane") {
            showSubmitAlert = true
        }
        .alert("Recommendations Saved", isPresented: $showSubmitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your class recommendations have been saved. Share them with your counselor when your school connects to Ladder.")
        }
    }
}

#Preview {
    NavigationStack {
        ClassRecommendationsView()
    }
}
