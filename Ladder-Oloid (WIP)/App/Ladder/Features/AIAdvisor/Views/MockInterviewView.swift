import SwiftUI

// MARK: - Mock Interview View

struct MockInterviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass

    let collegeId: String?

    private let mockQuestions = [
        "Tell me about yourself.",
        "Why this school?",
        "Describe a challenge you overcame.",
        "What's your biggest strength?",
        "Where do you see yourself in 10 years?",
    ]

    @State private var selectedIndex: Int = 0
    @State private var answer: String = ""
    @State private var timerSeconds: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var isRecording: Bool = false
    @State private var clarityScore: Int = 85
    @State private var structureScore: Int = 70
    @State private var confidenceScore: Int = 60

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var formattedTime: String {
        let minutes = timerSeconds / 60
        let seconds = timerSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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
                Text("Mock Interview")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning { timerSeconds += 1 }
        }
    }

    // MARK: - Question List

    private var questionListCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("QUESTIONS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                ForEach(Array(mockQuestions.enumerated()), id: \.offset) { index, question in
                    Button {
                        selectedIndex = index
                        timerSeconds = 0
                        isTimerRunning = false
                        answer = ""
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Text("\(index + 1)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(selectedIndex == index ? LadderColors.onPrimary : LadderColors.onSurfaceVariant)
                                .frame(width: 28, height: 28)
                                .background(selectedIndex == index ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                                .clipShape(Circle())

                            Text(question)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)

                            Spacer()
                        }
                        .padding(LadderSpacing.sm)
                        .background(selectedIndex == index ? LadderColors.primaryContainer.opacity(0.3) : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Current Question Card

    private var currentQuestionCard: some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack {
                    Text("QUESTION \(selectedIndex + 1) OF \(mockQuestions.count)")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                    Spacer()
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "timer")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)
                        Text(formattedTime)
                            .font(LadderTypography.titleSmall.monospacedDigit())
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, 4)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(Capsule())
                }

                Text(mockQuestions[selectedIndex])
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: LadderSpacing.sm) {
                    Button {
                        isTimerRunning.toggle()
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            Text(isTimerRunning ? "Pause" : "Start")
                        }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.onPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)

                    Button {
                        timerSeconds = 0
                        isTimerRunning = false
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Answer Area

    private var answerAreaCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("YOUR ANSWER")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                    Spacer()
                    Button {
                        isRecording.toggle()
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                                .foregroundStyle(isRecording ? LadderColors.error : LadderColors.primary)
                            Text(isRecording ? "Stop" : "Record")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, 4)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: LadderRadius.md)
                        .fill(LadderColors.surfaceContainerLow)
                        .frame(minHeight: 160)

                    if answer.isEmpty {
                        Text("Type your answer here or tap Record to speak...")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .padding(LadderSpacing.md)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $answer)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .scrollContentBackground(.hidden)
                        .padding(LadderSpacing.sm)
                        .frame(minHeight: 160)
                }
            }
        }
    }

    // MARK: - AI Feedback

    private var aiFeedbackCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(LadderColors.primary)
                    Text("AI FEEDBACK")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                }

                feedbackRow(label: "Clarity", score: Double(clarityScore) / 100.0, color: LadderColors.accentLime)
                feedbackRow(label: "Structure", score: Double(structureScore) / 100.0, color: LadderColors.tertiary)
                feedbackRow(label: "Confidence", score: Double(confidenceScore) / 100.0, color: LadderColors.tertiary)

                Divider()

                Text("Your response is clear and well-structured. Consider adding a concrete example to strengthen your answer, and slow down your pacing for better delivery.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    // Regenerate mock feedback by randomizing scores slightly
                    clarityScore = Int.random(in: 70...95)
                    structureScore = Int.random(in: 65...90)
                    confidenceScore = Int.random(in: 55...85)
                } label: {
                    Text("Regenerate Feedback")
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func feedbackRow(label: String, score: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
            HStack {
                Text(label)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Text("\(Int(score * 100))%")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(color)
            }
            LinearProgressBar(progress: score)
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    currentQuestionCard
                    answerAreaCard
                    aiFeedbackCard
                    questionListCard
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            GeometryReader { geo in
                HStack(alignment: .top, spacing: LadderSpacing.lg) {
                    // Left ~50%: question list + current question
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.lg) {
                            currentQuestionCard
                            questionListCard
                        }
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                    .frame(width: (geo.size.width - LadderSpacing.lg - LadderSpacing.xl * 2) * 0.5)

                    // Right ~50%: answer area + AI feedback
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.lg) {
                            answerAreaCard
                            aiFeedbackCard
                        }
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, LadderSpacing.xl)
                .padding(.top, LadderSpacing.lg)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MockInterviewView(collegeId: nil)
            .environment(AppCoordinator())
    }
}
