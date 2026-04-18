import SwiftUI

// MARK: - Mock Interview Feedback View
// Matches mock_interview_results_uf Stitch design

struct MockInterviewFeedbackView: View {
    @Bindable var viewModel: MockInterviewViewModel
    @State private var expandedQuestionId: UUID?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                scoreBanner
                metricsRow
                questionBreakdown
                improvementsSection
                actionButtons
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.top, LadderSpacing.md)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Score Banner

    private var scoreBanner: some View {
        VStack(spacing: LadderSpacing.md) {
            Text("FINAL ASSESSMENT")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onPrimaryContainer.opacity(0.8))
                .labelTracking()

            HStack(alignment: .firstTextBaseline, spacing: LadderSpacing.xs) {
                Text("\(viewModel.overallScore)")
                    .font(LadderTypography.displayLarge)
                    .foregroundStyle(LadderColors.onPrimaryContainer)
                Text("/ 100")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onPrimaryContainer.opacity(0.6))
            }

            Text(feedbackSummary)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onPrimaryContainer.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(LadderSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(LadderColors.primaryContainer)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
        .ladderShadow(LadderElevation.floating)
    }

    private var feedbackSummary: String {
        if viewModel.overallScore >= 80 {
            return "Excellent performance. Your clarity and depth stood out."
        } else if viewModel.overallScore >= 60 {
            return "Good effort. A few areas to polish before the real interview."
        } else {
            return "Keep practicing! Focus on adding specific examples to your answers."
        }
    }

    // MARK: - Metrics Row

    private var metricsRow: some View {
        HStack(spacing: LadderSpacing.sm) {
            metricTile("Content", score: viewModel.contentScore)
            metricTile("Clarity", score: viewModel.clarityScore)
            metricTile("Confidence", score: viewModel.confidenceScore)
        }
    }

    private func metricTile(_ label: String, score: Int) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text(label.uppercased())
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.outline)
                .labelTracking()
            Text("\(score)")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Question Breakdown

    private var questionBreakdown: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Question Breakdown")
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            ForEach(viewModel.questions) { question in
                questionRow(question)
            }
        }
    }

    private func questionRow(_ question: MockInterviewViewModel.InterviewQuestion) -> some View {
        let isExpanded = expandedQuestionId == question.id

        return VStack(spacing: LadderSpacing.sm) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    expandedQuestionId = isExpanded ? nil : question.id
                }
            } label: {
                VStack(spacing: LadderSpacing.sm) {
                    HStack {
                        Text(question.text)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(isExpanded ? nil : 1)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.outline)
                    }

                    // Score bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LadderColors.surfaceContainerLow)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LadderColors.primary)
                                .frame(width: geo.size.width * Double(question.score) / 100.0, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    if !question.answer.isEmpty {
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("YOUR ANSWER")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                            Text(question.answer)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }

                    feedbackRow(icon: "checkmark.circle.fill", color: LadderColors.accentLime, title: "Strength", text: question.strength)
                    feedbackRow(icon: "arrow.up.circle.fill", color: LadderColors.tertiary, title: "To Improve", text: question.improvement)
                    feedbackRow(icon: "lightbulb.fill", color: LadderColors.primary, title: "Suggested Approach", text: question.suggestedResponse)
                }
                .padding(.top, LadderSpacing.xs)
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func feedbackRow(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title)
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text(text)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Improvements Section

    private var improvementsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Top 3 Improvements")
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            VStack(spacing: LadderSpacing.lg) {
                ForEach(Array(viewModel.improvements.enumerated()), id: \.offset) { index, improvement in
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.secondaryFixed)
                                .frame(width: 32, height: 32)
                            Text("\(index + 1)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSecondaryFixed)
                        }
                        Text(improvement)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: LadderSpacing.sm) {
            LadderSecondaryButton("Retry This Interview") {
                viewModel.retryInterview()
            }

            ShareLink(item: shareText) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share Results")
                        .font(LadderTypography.titleSmall)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
        }
    }

    private var shareText: String {
        let college = viewModel.selectedCollege.isEmpty ? "my" : viewModel.selectedCollege
        return "I scored \(viewModel.overallScore)% on my \(college) mock interview practice on Ladder! Content: \(viewModel.contentScore), Clarity: \(viewModel.clarityScore), Confidence: \(viewModel.confidenceScore)."
    }
}

#Preview {
    let vm = MockInterviewViewModel()
    vm.overallScore = 82
    vm.contentScore = 85
    vm.clarityScore = 78
    vm.confidenceScore = 84
    vm.improvements = [
        "Slow down -- your pacing was fast on Q3.",
        "Add more specific examples with real numbers.",
        "Strong STAR method on Q1 -- keep doing that."
    ]
    return NavigationStack {
        MockInterviewFeedbackView(viewModel: vm)
    }
}
