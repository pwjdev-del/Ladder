import SwiftUI

// MARK: - Career Quiz View (Wheel of Career/Life)

struct CareerQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(AppCoordinator.self) private var coordinator
    @State private var currentQuestion = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 8)
    @State private var showResult = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if showResult {
                if sizeClass == .regular {
                    iPadResultView
                } else {
                    resultView
                }
            } else {
                if sizeClass == .regular {
                    iPadQuizView
                } else {
                    iPhoneQuizView
                }
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
    }

    // MARK: - iPhone Quiz

    private var iPhoneQuizView: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Progress
            VStack(spacing: LadderSpacing.sm) {
                HStack {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Spacer()

                    Text("\(Int(Double(currentQuestion) / Double(questions.count) * 100))%")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                LinearProgressBar(progress: Double(currentQuestion) / Double(questions.count))
            }
            .padding(.horizontal, LadderSpacing.md)

            // Question
            let q = questions[currentQuestion]
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Image(systemName: q.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(LadderColors.primary)

                Text(q.question)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(Array(q.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        answers[currentQuestion] = index
                    } label: {
                        HStack(spacing: LadderSpacing.md) {
                            Image(systemName: answers[currentQuestion] == index ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(answers[currentQuestion] == index ? LadderColors.accentLime : LadderColors.outline)

                            Text(option)
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurface)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding(LadderSpacing.md)
                        .background(
                            answers[currentQuestion] == index
                                ? LadderColors.primaryContainer.opacity(0.3)
                                : LadderColors.surfaceContainerLow
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, LadderSpacing.md)

            Spacer()

            navigationButtons
                .padding(.horizontal, LadderSpacing.md)
                .padding(.bottom, LadderSpacing.lg)
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - iPad Quiz

    private var iPadQuizView: some View {
        VStack(spacing: LadderSpacing.xl) {
            // Progress at top
            VStack(spacing: LadderSpacing.sm) {
                HStack {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Spacer()

                    Text("\(Int(Double(currentQuestion) / Double(questions.count) * 100))%")
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.primary)
                }

                LinearProgressBar(progress: Double(currentQuestion) / Double(questions.count))
            }
            .frame(maxWidth: 700)
            .padding(.top, LadderSpacing.xl)

            Spacer()

            // Centered card
            let q = questions[currentQuestion]
            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    VStack(spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.3))
                                .frame(width: 80, height: 80)
                            Image(systemName: q.icon)
                                .font(.system(size: 36))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text(q.question)
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .multilineTextAlignment(.center)
                    }

                    // 2-column grid of answer cards
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: LadderSpacing.md), GridItem(.flexible(), spacing: LadderSpacing.md)],
                        spacing: LadderSpacing.md
                    ) {
                        ForEach(Array(q.options.enumerated()), id: \.offset) { index, option in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    answers[currentQuestion] = index
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                    Image(systemName: answers[currentQuestion] == index ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(answers[currentQuestion] == index ? LadderColors.accentLime : LadderColors.outline)

                                    Text(option)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Spacer(minLength: 0)
                                }
                                .padding(LadderSpacing.lg)
                                .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                                .background(
                                    answers[currentQuestion] == index
                                        ? LadderColors.primaryContainer.opacity(0.4)
                                        : LadderColors.surfaceContainerLow
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                                        .stroke(
                                            answers[currentQuestion] == index ? LadderColors.primary : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                                .ladderShadow(LadderElevation.ambient)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: 700)
                .padding(LadderSpacing.xl)
            }

            Spacer()

            navigationButtons
                .frame(maxWidth: 700)
                .padding(.bottom, LadderSpacing.xl)
        }
        .frame(maxWidth: .infinity)
    }

    private var navigationButtons: some View {
        HStack(spacing: LadderSpacing.md) {
            if currentQuestion > 0 {
                LadderSecondaryButton("Back") {
                    withAnimation { currentQuestion -= 1 }
                }
            }

            LadderPrimaryButton(
                currentQuestion == questions.count - 1 ? "See Results" : "Next",
                icon: currentQuestion == questions.count - 1 ? "sparkles" : "arrow.right"
            ) {
                if currentQuestion == questions.count - 1 {
                    withAnimation { showResult = true }
                } else {
                    withAnimation { currentQuestion += 1 }
                }
            }
        }
    }

    // MARK: - iPhone Result

    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                // Hero
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LadderColors.primaryContainer, LadderColors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }

                Text("The Ambitious Healer")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(LadderColors.onSurface)

                Text("You're driven by a desire to help others through science and medicine. Your empathy combined with academic discipline makes you a natural fit for healthcare careers.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.md)

                // Traits
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Your Traits")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        FlowLayout(spacing: LadderSpacing.sm) {
                            ForEach(["Empathetic", "Analytical", "Disciplined", "Curious", "Leadership-oriented"], id: \.self) { trait in
                                LadderTagChip(trait)
                            }
                        }
                    }
                }

                // Recommended Paths
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Recommended Paths")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        pathRow("Pre-Medicine", schools: "UF, Emory, USF")
                        pathRow("Biomedical Engineering", schools: "Georgia Tech, RIT")
                        pathRow("Public Health", schools: "UF, FIU, USF")
                        pathRow("Nursing", schools: "UCF, FSU, FIU")
                    }
                }

                // Suggested Classes
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Classes to Take")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        ForEach(["AP Biology", "AP Chemistry", "Anatomy & Physiology", "AP Calculus", "AP Psychology", "Statistics"], id: \.self) { cls in
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(LadderColors.accentLime)
                                    .font(.system(size: 14))
                                Text(cls)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }
                    }
                }

                LadderPrimaryButton("Retake Quiz") {
                    withAnimation {
                        showResult = false
                        currentQuestion = 0
                        answers = Array(repeating: -1, count: 8)
                    }
                }

                resultActionButtons
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.lg)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Result Action CTAs

    private var resultActionButtons: some View {
        VStack(spacing: LadderSpacing.md) {
            LadderPrimaryButton("Explore Suggested Activities", icon: "arrow.right") {
                coordinator.navigate(to: .activityChecklist)
            }
            LadderSecondaryButton("View College Matches") {
                coordinator.navigate(to: .collegeDiscovery)
            }
            Button("Back to Dashboard") {
                if coordinator.isIPad {
                    coordinator.popDetailToRoot()
                } else {
                    coordinator.popToRoot()
                }
            }
            .font(LadderTypography.labelMedium)
            .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.lg)
    }

    // MARK: - iPad Result

    private var iPadResultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.xl) {
                // Hero
                VStack(spacing: LadderSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LadderColors.primaryContainer, LadderColors.primary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)

                        Image(systemName: "sparkles")
                            .font(.system(size: 56))
                            .foregroundStyle(.white)
                    }

                    Text("The Ambitious Healer")
                        .font(LadderTypography.displaySmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("You're driven by a desire to help others through science and medicine. Your empathy combined with academic discipline makes you a natural fit for healthcare careers.")
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 640)
                }

                // Two-column grid for cards
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: LadderSpacing.lg), GridItem(.flexible(), spacing: LadderSpacing.lg)],
                    spacing: LadderSpacing.lg
                ) {
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Your Traits")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            FlowLayout(spacing: LadderSpacing.sm) {
                                ForEach(["Empathetic", "Analytical", "Disciplined", "Curious", "Leadership-oriented"], id: \.self) { trait in
                                    LadderTagChip(trait)
                                }
                            }
                        }
                    }

                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Recommended Paths")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            pathRow("Pre-Medicine", schools: "UF, Emory, USF")
                            pathRow("Biomedical Engineering", schools: "Georgia Tech, RIT")
                            pathRow("Public Health", schools: "UF, FIU, USF")
                            pathRow("Nursing", schools: "UCF, FSU, FIU")
                        }
                    }
                }

                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Classes to Take")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.sm) {
                            ForEach(["AP Biology", "AP Chemistry", "Anatomy & Physiology", "AP Calculus", "AP Psychology", "Statistics"], id: \.self) { cls in
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(LadderColors.accentLime)
                                        .font(.system(size: 14))
                                    Text(cls)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                }
                            }
                        }
                    }
                }

                LadderPrimaryButton("Retake Quiz") {
                    withAnimation {
                        showResult = false
                        currentQuestion = 0
                        answers = Array(repeating: -1, count: 8)
                    }
                }

                resultActionButtons
                    .frame(maxWidth: 640)
            }
            .frame(maxWidth: 900)
            .padding(LadderSpacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    private func pathRow(_ path: String, schools: String) -> some View {
        HStack {
            Text(path)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Text(schools)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Questions

    private var questions: [QuizQuestion] {
        [
            QuizQuestion(question: "What excites you most about your future?", icon: "sparkles", options: ["Solving complex problems with technology", "Helping people heal and stay healthy", "Building a business or leading a team", "Creating art, writing, or telling stories"]),
            QuizQuestion(question: "In your free time, you're most likely to...", icon: "clock", options: ["Code, build, or experiment with tech", "Volunteer, tutor, or help someone", "Plan events, sell things, or organize", "Read, write, draw, or play music"]),
            QuizQuestion(question: "Which school subject do you enjoy most?", icon: "book", options: ["Math or Computer Science", "Biology or Chemistry", "Economics or History", "English or Art"]),
            QuizQuestion(question: "You feel most fulfilled when you...", icon: "heart", options: ["Figure out how something works", "Make someone feel better", "Achieve a goal or win a competition", "Express yourself creatively"]),
            QuizQuestion(question: "Which work environment appeals to you?", icon: "building.2", options: ["Lab, office, or tech startup", "Hospital, clinic, or research center", "Corporate office or my own business", "Studio, newsroom, or classroom"]),
            QuizQuestion(question: "What's your approach to group projects?", icon: "person.3", options: ["I focus on the technical or analytical parts", "I make sure everyone is included and heard", "I take charge and delegate tasks", "I come up with the creative ideas"]),
            QuizQuestion(question: "Which challenge motivates you most?", icon: "flame", options: ["A difficult puzzle or engineering problem", "A patient who needs a diagnosis", "Growing revenue or scaling an idea", "A blank page that needs a story"]),
            QuizQuestion(question: "In 10 years, you'd like to be...", icon: "star", options: ["An engineer, scientist, or tech leader", "A doctor, researcher, or healthcare professional", "A CEO, entrepreneur, or consultant", "A writer, designer, or educator"]),
        ]
    }
}

struct QuizQuestion {
    let question: String
    let icon: String
    let options: [String]
}

#Preview {
    NavigationStack {
        CareerQuizView()
            .environment(AppCoordinator())
    }
}
