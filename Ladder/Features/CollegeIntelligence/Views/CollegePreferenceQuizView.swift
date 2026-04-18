import SwiftUI
import SwiftData

// MARK: - College Preference Quiz
// 4-question swipeable card quiz to set college preferences
// Matches the career quiz style: big tappable cards, smooth transitions

struct CollegePreferenceQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]

    @State private var currentQuestion = 0
    @State private var selectedOption: Int = -1
    @State private var answers: [String?] = [nil, nil, nil, nil]
    @State private var showCompletion = false
    @State private var animateIn = false

    private var student: StudentProfileModel? { profiles.first }
    private let totalQuestions = 4

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if showCompletion {
                completionView
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
                Text("College Preferences")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { animateIn = true }
        }
    }

    // MARK: - Quiz Body

    private var quizBody: some View {
        VStack(spacing: 0) {
            // Progress header
            VStack(spacing: LadderSpacing.xs) {
                HStack {
                    Text("Question \(currentQuestion + 1) of \(totalQuestions)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    Text("\(Int(Double(currentQuestion + 1) / Double(totalQuestions) * 100))%")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LadderColors.surfaceContainerHigh)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LadderColors.primary)
                            .frame(
                                width: geo.size.width * Double(currentQuestion + 1) / Double(totalQuestions),
                                height: 6
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentQuestion)
                    }
                }
                .frame(height: 6)
            }
            .padding([.horizontal, .top], LadderSpacing.md)
            .padding(.bottom, LadderSpacing.sm)

            // Question content
            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    questionHeader
                    optionsGrid
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.bottom, 120)
            }

            // Next button
            LadderPrimaryButton(
                currentQuestion == totalQuestions - 1 ? "See My Preferences" : "Next Question",
                icon: currentQuestion == totalQuestions - 1 ? "sparkles" : "arrow.right"
            ) {
                advanceQuestion()
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .opacity(selectedOption == -1 ? 0.5 : 1)
            .background(LadderColors.surface)
        }
    }

    // MARK: - Question Header

    private var questionHeader: some View {
        let question = PreferenceQuizData.questions[currentQuestion]
        return VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 56, height: 56)
                Image(systemName: question.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(LadderColors.primary)
            }

            Text(question.title)
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = question.subtitle {
                Text(subtitle)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, LadderSpacing.lg)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
    }

    // MARK: - Options Grid

    private var optionsGrid: some View {
        let question = PreferenceQuizData.questions[currentQuestion]
        return VStack(spacing: LadderSpacing.sm) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { idx, option in
                preferenceCard(option: option, index: idx)
            }
        }
    }

    // MARK: - Preference Card

    private func preferenceCard(option: PreferenceOption, index: Int) -> some View {
        let isSelected = selectedOption == index

        return Button {
            withAnimation(.spring(response: 0.25)) { selectedOption = index }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                        .fill(isSelected ? LadderColors.primaryContainer.opacity(0.5) : LadderColors.surfaceContainer)
                        .frame(width: 48, height: 48)
                    Image(systemName: option.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(option.detail)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                // Radio indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? LadderColors.accentLime : LadderColors.outlineVariant,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(LadderColors.accentLime)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(LadderSpacing.md)
            .background(isSelected ? LadderColors.primaryContainer.opacity(0.2) : LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(isSelected ? LadderColors.accentLime.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                Spacer().frame(height: LadderSpacing.xxl)

                // Success icon
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.3))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.6))
                        .frame(width: 88, height: 88)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.primary)
                }

                Text("Preferences Set")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Your college preferences are saved. Discovery will now prioritize matching schools.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.lg)

                // Summary card
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Your Preferences")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        preferenceSummaryRow(
                            icon: "building.2",
                            label: "Campus Size",
                            value: sizeDisplayName(answers[0])
                        )
                        preferenceSummaryRow(
                            icon: "mappin.and.ellipse",
                            label: "Location",
                            value: locationDisplayName(answers[1])
                        )
                        preferenceSummaryRow(
                            icon: "tree",
                            label: "Setting",
                            value: settingDisplayName(answers[2])
                        )
                        preferenceSummaryRow(
                            icon: "lightbulb",
                            label: "Culture",
                            value: cultureDisplayName(answers[3])
                        )
                    }
                }
                .padding(.horizontal, LadderSpacing.md)

                // XP reward indicator
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.accentLime)
                    Text("+15 XP earned")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.2))
                .clipShape(Capsule())

                LadderPrimaryButton("Done", icon: "checkmark") {
                    dismiss()
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
    }

    private func preferenceSummaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24)
            Text(label)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    // MARK: - Logic

    private func advanceQuestion() {
        guard selectedOption != -1 else { return }

        // Store answer value
        let question = PreferenceQuizData.questions[currentQuestion]
        answers[currentQuestion] = question.options[selectedOption].value

        if currentQuestion == totalQuestions - 1 {
            savePreferences()
            withAnimation(.spring(response: 0.5)) { showCompletion = true }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentQuestion += 1
                selectedOption = -1
            }
        }
    }

    private func savePreferences() {
        guard let profile = student else { return }
        profile.preferredSize = answers[0]
        profile.preferredLocation = answers[1]
        profile.preferredSetting = answers[2]
        profile.preferredCulture = answers[3]

        // Award XP
        let _ = LevelManager.shared.awardXP(.completePreferenceQuiz, to: profile)

        try? context.save()
    }

    // MARK: - Display Helpers

    private func sizeDisplayName(_ value: String?) -> String {
        switch value {
        case "small": return "Small (<5K)"
        case "medium": return "Medium (5-15K)"
        case "large": return "Large (15K+)"
        default: return "Any"
        }
    }

    private func locationDisplayName(_ value: String?) -> String {
        switch value {
        case "in_state": return "In-State Only"
        case "out_of_state": return "Open to Anywhere"
        default: return "Any"
        }
    }

    private func settingDisplayName(_ value: String?) -> String {
        switch value {
        case "urban": return "Urban (City)"
        case "suburban": return "Suburban"
        case "rural": return "Rural"
        default: return "Any"
        }
    }

    private func cultureDisplayName(_ value: String?) -> String {
        switch value {
        case "research": return "Research"
        case "teaching": return "Great Teaching"
        case "both": return "Both"
        default: return "Any"
        }
    }
}

// MARK: - Quiz Data

struct PreferenceOption {
    let label: String
    let detail: String
    let icon: String
    let value: String
}

struct PreferenceQuestion {
    let title: String
    let subtitle: String?
    let icon: String
    let options: [PreferenceOption]
}

enum PreferenceQuizData {
    static let questions: [PreferenceQuestion] = [
        // Q1: Size
        PreferenceQuestion(
            title: "What size school feels right?",
            subtitle: "Smaller schools offer close mentorship; larger ones offer more opportunities and diversity.",
            icon: "building.2",
            options: [
                PreferenceOption(
                    label: "Small",
                    detail: "Under 5,000 students. Close-knit community.",
                    icon: "person.3",
                    value: "small"
                ),
                PreferenceOption(
                    label: "Medium",
                    detail: "5,000 - 15,000 students. Best of both worlds.",
                    icon: "person.3.sequence",
                    value: "medium"
                ),
                PreferenceOption(
                    label: "Large",
                    detail: "15,000+ students. Big campus energy.",
                    icon: "person.3.fill",
                    value: "large"
                ),
            ]
        ),
        // Q2: Location
        PreferenceQuestion(
            title: "Stay close to home?",
            subtitle: "Some students thrive near family; others want a fresh start somewhere new.",
            icon: "mappin.and.ellipse",
            options: [
                PreferenceOption(
                    label: "In-State Only",
                    detail: "Stay close to home. Lower tuition.",
                    icon: "house.fill",
                    value: "in_state"
                ),
                PreferenceOption(
                    label: "Open to Anywhere",
                    detail: "Explore the whole country.",
                    icon: "globe.americas.fill",
                    value: "out_of_state"
                ),
            ]
        ),
        // Q3: Setting
        PreferenceQuestion(
            title: "What setting do you prefer?",
            subtitle: "Where you live shapes your college experience as much as your classes.",
            icon: "tree",
            options: [
                PreferenceOption(
                    label: "Urban",
                    detail: "City campus. Internships, nightlife, transit.",
                    icon: "building.2.fill",
                    value: "urban"
                ),
                PreferenceOption(
                    label: "Suburban",
                    detail: "Near a city but with a traditional campus feel.",
                    icon: "house.and.flag",
                    value: "suburban"
                ),
                PreferenceOption(
                    label: "Rural",
                    detail: "Quiet, spacious campus. Nature-focused.",
                    icon: "leaf.fill",
                    value: "rural"
                ),
            ]
        ),
        // Q4: Culture
        PreferenceQuestion(
            title: "What matters more?",
            subtitle: "Research schools focus on innovation; teaching schools focus on you.",
            icon: "lightbulb",
            options: [
                PreferenceOption(
                    label: "Research Opportunities",
                    detail: "Labs, publications, faculty-led projects.",
                    icon: "magnifyingglass",
                    value: "research"
                ),
                PreferenceOption(
                    label: "Great Teaching",
                    detail: "Small classes, mentorship, accessible professors.",
                    icon: "person.fill.checkmark",
                    value: "teaching"
                ),
                PreferenceOption(
                    label: "Both",
                    detail: "A school that balances research and teaching.",
                    icon: "scale.3d",
                    value: "both"
                ),
            ]
        ),
    ]
}

#Preview {
    NavigationStack {
        CollegePreferenceQuizView()
    }
    .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
