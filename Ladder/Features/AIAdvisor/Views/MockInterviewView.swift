import SwiftUI

// MARK: - Mock Interview View
// Matches mock_interview_session_uf Stitch design

struct MockInterviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MockInterviewViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            switch viewModel.phase {
            case .setup:
                setupView
            case .inProgress:
                interviewSessionView
            case .review:
                EmptyView() // handled by submit flow
            case .results:
                MockInterviewFeedbackView(viewModel: viewModel)
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
                HStack(spacing: LadderSpacing.sm) {
                    if viewModel.phase == .inProgress {
                        Text(viewModel.timerString)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                    }
                    Text(viewModel.phase == .results ? "Interview Results" : "Mock Interview")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    // MARK: - Setup View

    private var setupView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                // Hero
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.3))
                        .frame(width: 100, height: 100)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.primary)
                }
                .padding(.top, LadderSpacing.xl)

                VStack(spacing: LadderSpacing.sm) {
                    Text("Practice Your Interview")
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                        .multilineTextAlignment(.center)
                    Text("Select a school and interview type to get school-specific practice questions.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }

                // College picker
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("SELECT COLLEGE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        LadderTextField("College name", text: $viewModel.selectedCollege, icon: "building.columns")

                        if !viewModel.selectedCollege.isEmpty {
                            let filtered = viewModel.collegeSuggestions.filter {
                                $0.localizedCaseInsensitiveContains(viewModel.selectedCollege)
                            }
                            if !filtered.isEmpty {
                                VStack(spacing: LadderSpacing.xs) {
                                    ForEach(filtered, id: \.self) { suggestion in
                                        Button {
                                            viewModel.selectedCollege = suggestion
                                        } label: {
                                            HStack {
                                                Text(suggestion)
                                                    .font(LadderTypography.bodyMedium)
                                                    .foregroundStyle(LadderColors.onSurface)
                                                Spacer()
                                            }
                                            .padding(.vertical, LadderSpacing.xs)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }

                // Interview type
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("INTERVIEW TYPE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()

                        ForEach(MockInterviewViewModel.InterviewType.allCases) { type in
                            Button {
                                withAnimation(.spring(response: 0.25)) {
                                    viewModel.interviewType = type
                                }
                            } label: {
                                HStack(spacing: LadderSpacing.md) {
                                    ZStack {
                                        Circle()
                                            .stroke(viewModel.interviewType == type ? LadderColors.accentLime : LadderColors.outlineVariant, lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        if viewModel.interviewType == type {
                                            Circle()
                                                .fill(LadderColors.accentLime)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                        Text(type.rawValue)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Text(typeDescription(type))
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                    }
                                    Spacer()
                                }
                                .padding(LadderSpacing.sm)
                                .background(viewModel.interviewType == type ? LadderColors.primaryContainer.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                LadderPrimaryButton("Start Interview", icon: "play.fill") {
                    viewModel.startInterview()
                }
                .opacity(viewModel.selectedCollege.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Interview Session

    private var interviewSessionView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Progress
                    HStack(spacing: LadderSpacing.sm) {
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        if let cat = viewModel.currentQuestion?.category {
                            Text(cat)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.primary)
                        }
                        Spacer()
                    }

                    // Progress dots
                    HStack(spacing: LadderSpacing.sm) {
                        ForEach(0..<viewModel.questions.count, id: \.self) { i in
                            Circle()
                                .fill(i <= viewModel.currentQuestionIndex ? LadderColors.primary : LadderColors.outlineVariant)
                                .frame(width: 10, height: 10)
                                .if(i <= viewModel.currentQuestionIndex) { view in
                                    view.ladderShadow(LadderElevation.primaryGlow)
                                }
                        }
                    }

                    // Question card
                    if let question = viewModel.currentQuestion {
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text(question.text)
                                .font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(LadderSpacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                        // Answer text field
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("YOUR ANSWER")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextEditor(text: Binding(
                                get: { viewModel.questions[viewModel.currentQuestionIndex].answer },
                                set: { viewModel.updateAnswer($0) }
                            ))
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurface)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 150)
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                        }
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("TIPS")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: LadderSpacing.sm) {
                                tipChip("Use the STAR method", icon: "lightbulb")
                                tipChip("Be specific", icon: "scope")
                                tipChip("Keep it under 2 min", icon: "clock")
                            }
                        }
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }

            // Bottom navigation
            HStack(spacing: LadderSpacing.md) {
                if viewModel.currentQuestionIndex > 0 {
                    LadderSecondaryButton("Previous") {
                        withAnimation { viewModel.previousQuestion() }
                    }
                }

                if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                    LadderPrimaryButton("Next", icon: "arrow.right") {
                        withAnimation { viewModel.nextQuestion() }
                    }
                } else {
                    LadderPrimaryButton("Submit", icon: "checkmark") {
                        viewModel.submitInterview()
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.surface)
        }
    }

    // MARK: - Helpers

    private func tipChip(_ text: String, icon: String) -> some View {
        HStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(LadderTypography.labelMedium)
        }
        .foregroundStyle(LadderColors.primary)
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(Capsule())
    }

    private func typeDescription(_ type: MockInterviewViewModel.InterviewType) -> String {
        switch type {
        case .admissions: return "Standard admissions interview questions"
        case .scholarship: return "Scholarship-focused behavioral questions"
        case .alumni: return "Casual conversational alumni interview"
        }
    }
}

#Preview {
    NavigationStack {
        MockInterviewView()
    }
}
