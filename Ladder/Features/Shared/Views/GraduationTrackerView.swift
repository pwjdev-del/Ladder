import SwiftUI
import SwiftData

// MARK: - Graduation Tracker View
// Dynamic state-based graduation tracking using StateRequirementsEngine

struct GraduationTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query var profiles: [StudentProfileModel]
    @State private var viewModel = GraduationTrackerViewModel()
    @State private var showTranscriptAlert = false
    @State private var hasConfigured = false

    private var student: StudentProfileModel? { profiles.first }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headlineSection
                    progressDial
                    missingCreditsAlert
                    creditsBentoGrid
                    if viewModel.meritScholarship != nil {
                        scholarshipSection
                    }
                    if !viewModel.specialRules.isEmpty {
                        specialRulesSection
                    }
                    updateButton
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
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
                Text("Milestone Progress")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear {
            guard !hasConfigured else { return }
            let state = student?.state ?? "Florida"
            viewModel.configure(for: state)
            hasConfigured = true
        }
    }

    // MARK: - Headline

    private var headlineSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Graduation Progress \u{2014} \(viewModel.stateName)")
                .font(LadderTypography.displaySmall)
                .foregroundStyle(LadderColors.onSurface)
            Text("\(viewModel.stateName) requires \(viewModel.totalCreditsRequired) credits to graduate")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Progress Dial

    private var progressDial: some View {
        VStack(spacing: LadderSpacing.lg) {
            ZStack {
                // Background track
                Circle()
                    .stroke(LadderColors.surfaceContainerHigh, lineWidth: 20)
                    .frame(width: 220, height: 220)

                // Progress arc
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(
                        LinearGradient(
                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: viewModel.overallProgress)

                // Center circle
                ZStack {
                    Circle()
                        .fill(LadderColors.secondaryFixed)
                        .frame(width: 160, height: 160)
                        .ladderShadow(LadderElevation.glow)

                    VStack(spacing: LadderSpacing.xs) {
                        Text("\(Int(viewModel.overallProgress * 100))%")
                            .font(LadderTypography.displaySmall)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                        Text("\(viewModel.totalCreditsEarned) / \(viewModel.totalCreditsRequired) CREDITS")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSecondaryFixed.opacity(0.8))
                            .labelTracking()
                    }
                }
            }

            // Projection card
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("PROJECTION")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(.white.opacity(0.8))
                        .labelTracking()
                    Text(viewModel.projectionMessage)
                        .font(LadderTypography.bodyLargeItalic)
                        .foregroundStyle(.white)
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                .ladderShadow(LadderElevation.floating)
                .frame(maxWidth: 240)
            }
        }
    }

    // MARK: - Missing Credits Alert

    @ViewBuilder
    private var missingCreditsAlert: some View {
        let missing = viewModel.missingCategories
        if !missing.isEmpty {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(LadderColors.tertiary)
                    Text("Missing Credits Alert")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.tertiary)
                }

                ForEach(missing) { cat in
                    HStack {
                        Text(cat.name)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Text("\(cat.required - cat.earned) credit\(cat.required - cat.earned == 1 ? "" : "s") needed")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(Color.white.opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.tertiaryFixed)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    // MARK: - Credits Bento Grid

    private var creditsBentoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
            ForEach(viewModel.categories) { cat in
                creditTile(cat)
            }
        }
    }

    private func creditTile(_ cat: GraduationTrackerViewModel.CreditCategory) -> some View {
        let progress = min(Double(cat.earned) / max(Double(cat.required), 1), 1.0)
        let isComplete = cat.earned >= cat.required
        let isBehind = cat.earned < cat.required

        return VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(cat.name)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("\(cat.earned) / \(cat.required) Credits")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(isBehind ? LadderColors.error : LadderColors.primary)
            }

            Spacer()

            VStack(spacing: LadderSpacing.sm) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LadderColors.surfaceContainerHighest)
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isBehind ? LadderColors.error : LadderColors.primary)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text(isComplete ? "COMPLETED" : (isBehind ? "BEHIND" : "ON TRACK"))
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(isComplete ? LadderColors.onSecondaryFixed : (isBehind ? LadderColors.error : LadderColors.primary))
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(isComplete ? LadderColors.secondaryFixed : (isBehind ? LadderColors.error.opacity(0.1) : LadderColors.primary.opacity(0.1)))
                        .clipShape(Capsule())
                    Spacer()
                }
            }
        }
        .padding(LadderSpacing.md)
        .frame(minHeight: 140)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Scholarship Section

    private var scholarshipSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(LadderColors.accentLime)
                Text("Merit Scholarship Eligibility")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }

            ForEach(viewModel.scholarshipRequirements) { req in
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: req.isMet ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(req.isMet ? LadderColors.accentLime : LadderColors.onSurfaceVariant)
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(req.title)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(req.detail)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Special Rules Section

    private var specialRulesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(LadderColors.primary)
                Text("\(viewModel.stateName) Tips")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }

            ForEach(viewModel.specialRules, id: \.self) { rule in
                HStack(alignment: .top, spacing: LadderSpacing.sm) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.primary.opacity(0.6))
                        .padding(.top, 3)
                    Text(rule)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Update Button

    private var updateButton: some View {
        LadderPrimaryButton("Update from Transcript", icon: "doc.text") {
            showTranscriptAlert = true
        }
        .alert("Transcript Import", isPresented: $showTranscriptAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Transcript import is coming soon. You can manually update your credits by tapping each subject category above.")
        }
    }
}

#Preview {
    NavigationStack {
        GraduationTrackerView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
