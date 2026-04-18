import SwiftUI
import SwiftData

// MARK: - Adaptive Career Quiz View
// 3-stage RIASEC quiz with animated transitions and results

struct AdaptiveCareerQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @State private var viewModel = CareerQuizViewModel()
    @State private var selectedChoice: RIASECChoice? = nil
    @State private var animateCard = false
    @State private var showCareerOverride = false
    @State private var showMajorPicker = false

    private var student: StudentProfileModel? { profiles.first }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if viewModel.showTransition {
                transitionCard
            } else if viewModel.currentStage == .results {
                resultsView
            } else {
                quizBody
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
                Text("Career Discovery")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showCareerOverride) {
            CareerOverrideSheet()
        }
        .sheet(isPresented: $showMajorPicker) {
            if let cluster = student?.careerPath {
                MajorPickerView(careerCluster: cluster)
            }
        }
    }

    // MARK: - Quiz Body

    private var quizBody: some View {
        VStack(spacing: 0) {
            // Stage indicator + progress
            VStack(spacing: LadderSpacing.xs) {
                HStack {
                    stageIndicator
                    Spacer()
                    Text("Q\(viewModel.currentQuestionIndex + 1)/\(viewModel.totalQuestionsInStage)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }
                LinearProgressBar(progress: viewModel.progress)
            }
            .padding([.horizontal, .top], LadderSpacing.md)
            .padding(.bottom, LadderSpacing.sm)

            ScrollView(showsIndicators: false) {
                if let question = viewModel.currentQuestion {
                    VStack(spacing: LadderSpacing.lg) {
                        // Scenario text
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 56, height: 56)
                                Image(systemName: stageIcon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            Text(question.scenario)
                                .font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.top, LadderSpacing.lg)

                        // Choice cards
                        VStack(spacing: LadderSpacing.md) {
                            choiceCard(
                                label: "A",
                                text: question.choiceA,
                                dimension: question.dimensionA,
                                choice: .a
                            )

                            choiceCard(
                                label: "B",
                                text: question.choiceB,
                                dimension: question.dimensionB,
                                choice: .b
                            )
                        }
                        .padding(.horizontal, LadderSpacing.md)
                    }
                    .padding(.bottom, 100)
                    .id("\(viewModel.currentStage.rawValue)-\(viewModel.currentQuestionIndex)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
    }

    // MARK: - Choice Card

    private func choiceCard(label: String, text: String, dimension: RIASECDimension, choice: RIASECChoice) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedChoice = choice
            }
            // Brief delay then advance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.answerQuestion(choice: choice)
                    selectedChoice = nil
                }
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Label badge
                ZStack {
                    Circle()
                        .fill(selectedChoice == choice ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                        .frame(width: 36, height: 36)
                    Text(label)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(selectedChoice == choice ? .white : LadderColors.onSurfaceVariant)
                }

                Text(text)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(LadderSpacing.lg)
            .background(
                selectedChoice == choice
                    ? LadderColors.primaryContainer.opacity(0.3)
                    : LadderColors.surfaceContainerLow
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(
                        selectedChoice == choice
                            ? LadderColors.primary.opacity(0.5)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(selectedChoice == choice ? 0.97 : 1.0)
        .animation(.spring(response: 0.25), value: selectedChoice)
    }

    // MARK: - Stage Indicator

    private var stageIndicator: some View {
        HStack(spacing: LadderSpacing.sm) {
            ForEach(1...3, id: \.self) { stage in
                HStack(spacing: LadderSpacing.xs) {
                    Circle()
                        .fill(stage <= viewModel.currentStage.rawValue ? LadderColors.primary : LadderColors.surfaceContainerHighest)
                        .frame(width: 8, height: 8)
                    if stage == viewModel.currentStage.rawValue {
                        Text("Stage \(stage)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                }
            }
        }
    }

    private var stageIcon: String {
        switch viewModel.currentStage {
        case .quick: return "sparkles"
        case .deep: return "brain.head.profile"
        case .results: return "star"
        }
    }

    // MARK: - Transition Card

    private var transitionCard: some View {
        VStack(spacing: LadderSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(spacing: LadderSpacing.sm) {
                Text("Great progress!")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Now let's go deeper into your top interests to find your best career matches.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.xl)

                // Show top 3 dimensions
                HStack(spacing: LadderSpacing.sm) {
                    let stage1Scores = RIASECEngine.calculateScores(
                        stage1Answers: viewModel.stage1Answers,
                        stage2Answers: []
                    )
                    let top3 = RIASECEngine.topDimensions(from: stage1Scores)
                    ForEach(top3, id: \.self) { dim in
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: dim.icon)
                                .font(.system(size: 12))
                            Text(dim.rawValue)
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.onSurface)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(Capsule())
                    }
                }
                .padding(.top, LadderSpacing.sm)
            }

            Spacer()

            LadderPrimaryButton("Continue", icon: "arrow.right") {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.moveToNextStage()
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.bottom, LadderSpacing.xl)
        }
    }

    // MARK: - Results View

    private var resultsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                // Archetype hero
                VStack(spacing: LadderSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LadderColors.primary, LadderColors.primaryContainer],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        Image(systemName: viewModel.topClusters.first?.cluster.icon ?? "star")
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, LadderSpacing.xl)

                    Text(viewModel.archetypeName)
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .multilineTextAlignment(.center)

                    Text("RIASEC PROFILE")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.accentLime)
                        .labelTracking()
                }

                // Top 3 clusters with confidence
                VStack(spacing: LadderSpacing.sm) {
                    ForEach(Array(viewModel.topClusters.enumerated()), id: \.offset) { index, match in
                        clusterResultCard(
                            rank: index + 1,
                            cluster: match.cluster,
                            confidence: match.confidence
                        )
                    }
                }
                .padding(.horizontal, LadderSpacing.md)

                // RIASEC dimension scores
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Your RIASEC Profile")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        let total = max(Double(viewModel.allScores.values.reduce(0, +)), 1)
                        ForEach(RIASECDimension.allCases, id: \.self) { dim in
                            let score = Double(viewModel.allScores[dim] ?? 0)
                            let pct = score / total
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: dim.icon)
                                    .font(.system(size: 13))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 18)
                                Text(dim.rawValue)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .frame(width: 100, alignment: .leading)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(LadderColors.surfaceContainerHigh)
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(LadderColors.primary.opacity(0.7))
                                            .frame(width: max(geo.size.width * pct, 0), height: 6)
                                    }
                                }
                                .frame(height: 6)
                                Text("\(Int(pct * 100))%")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 34, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal, LadderSpacing.md)

                // Traits
                if let topCluster = viewModel.topClusters.first {
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Your Key Traits")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            FlowLayout(spacing: LadderSpacing.sm) {
                                ForEach(topCluster.cluster.traits, id: \.self) { trait in
                                    LadderTagChip(trait, icon: "checkmark.circle.fill")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)

                    // Sample careers
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Careers to Explore")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            ForEach(Array(topCluster.cluster.sampleCareers.enumerated()), id: \.offset) { i, career in
                                HStack(spacing: LadderSpacing.sm) {
                                    Text("\(i + 1).")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.accentLime)
                                        .frame(width: 20)
                                    Text(career)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)
                }

                // Disclaimer
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "arrow.clockwise.circle")
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .font(.system(size: 14))
                    Text("These are suggestions based on your interests -- not final decisions. Retake as your interests evolve.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.horizontal, LadderSpacing.md)

                // Action buttons
                HStack(spacing: LadderSpacing.md) {
                    LadderSecondaryButton("Retake Quiz") {
                        withAnimation(.spring(response: 0.4)) {
                            viewModel.retakeQuiz()
                        }
                    }
                    LadderPrimaryButton(
                        viewModel.resultsSaved ? "Saved" : "Save Results",
                        icon: viewModel.resultsSaved ? "checkmark" : "square.and.arrow.down"
                    ) {
                        guard !viewModel.resultsSaved, let profile = student else { return }
                        viewModel.saveResults(to: profile, context: context)
                        showMajorPicker = true
                    }
                }
                .padding(.horizontal, LadderSpacing.md)

                // Override link
                Button {
                    showCareerOverride = true
                } label: {
                    Text("Not quite right?")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.primary)
                        .underline(true, color: LadderColors.secondaryFixed)
                }
                .padding(.top, LadderSpacing.xs)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Cluster Result Card

    private func clusterResultCard(rank: Int, cluster: CareerCluster, confidence: Double) -> some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(rank == 1 ? LadderColors.accentLime : LadderColors.surfaceContainerHigh)
                        .frame(width: 40, height: 40)
                    Text("#\(rank)")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(rank == 1 ? LadderColors.onSecondaryFixed : LadderColors.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(cluster.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(cluster.description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .lineLimit(2)
                }

                Spacer()

                // Confidence %
                VStack(spacing: 2) {
                    Text("\(Int(confidence))%")
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(rank == 1 ? LadderColors.accentLime : LadderColors.primary)
                    Text("match")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdaptiveCareerQuizView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
