import SwiftUI
import SwiftData

// MARK: - Career Quiz Retake View
// Annual retake prompt with year-over-year comparison

struct CareerQuizRetakeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \CareerQuizHistoryModel.dateTaken) var quizHistory: [CareerQuizHistoryModel]
    @Query var profiles: [StudentProfileModel]
    @State private var navigateToQuiz = false

    private var student: StudentProfileModel? { profiles.first }

    private var currentGrade: Int {
        student?.grade ?? 10
    }

    private var lastResult: CareerQuizHistoryModel? {
        quizHistory.last
    }

    private var canRetake: Bool {
        guard let last = lastResult else { return true }
        let lastYear = Calendar.current.component(.year, from: last.dateTaken)
        let thisYear = Calendar.current.component(.year, from: Date())
        return thisYear > lastYear
    }

    // All career paths across all history entries
    private var allCareerPaths: [String] {
        var paths = Set<String>()
        for entry in quizHistory {
            for key in entry.scores.keys {
                paths.insert(key)
            }
        }
        return paths.sorted()
    }

    // Detect significant shifts between last two results
    private var significantShifts: [(path: String, change: Double)] {
        guard quizHistory.count >= 2 else { return [] }
        let previous = quizHistory[quizHistory.count - 2]
        let current = quizHistory[quizHistory.count - 1]
        var shifts: [(String, Double)] = []
        for path in allCareerPaths {
            let prev = previous.scores[path] ?? 0
            let curr = current.scores[path] ?? 0
            let diff = curr - prev
            if abs(diff) >= 0.10 {
                shifts.append((path, diff))
            }
        }
        return shifts.sorted { abs($0.1) > abs($1.1) }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    if !quizHistory.isEmpty {
                        lastTakenBadge
                        comparisonSection
                        if !significantShifts.isEmpty {
                            shiftsSection
                        }
                    } else {
                        emptyStateSection
                    }
                    retakeButton
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
                Text("Career Check-In")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .navigationDestination(isPresented: $navigateToQuiz) {
            AdaptiveCareerQuizView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack(spacing: LadderSpacing.sm) {
                Text("Annual Career Check-In")
                    .font(LadderTypography.displaySmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text("\(currentGrade)th")
                    .font(LadderTypography.labelLarge)
                    .foregroundStyle(LadderColors.onSecondaryFixed)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(LadderColors.secondaryFixed)
                    .clipShape(Capsule())
            }

            Text("Your interests evolve each year. Retake to see how your career path is shifting.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Last Taken Badge

    private var lastTakenBadge: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)

            if let last = lastResult {
                let formatter: DateFormatter = {
                    let f = DateFormatter()
                    f.dateFormat = "MMMM yyyy"
                    return f
                }()
                Text("Last taken: \(formatter.string(from: last.dateTaken)) (\(ordinalGrade(last.gradeTaken)) grade)")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    // MARK: - Comparison Section

    private var comparisonSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Year-Over-Year Comparison")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                // Legend
                HStack(spacing: LadderSpacing.lg) {
                    ForEach(Array(quizHistory.enumerated()), id: \.offset) { index, entry in
                        HStack(spacing: LadderSpacing.xs) {
                            Circle()
                                .fill(barColor(for: index))
                                .frame(width: 8, height: 8)
                            Text("\(ordinalGrade(entry.gradeTaken)) Grade")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                }

                // Horizontal bars per career path
                ForEach(allCareerPaths, id: \.self) { path in
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text(path)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        ForEach(Array(quizHistory.enumerated()), id: \.offset) { index, entry in
                            let score = entry.scores[path] ?? 0
                            HStack(spacing: LadderSpacing.sm) {
                                Text("\(ordinalGrade(entry.gradeTaken))")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 30, alignment: .trailing)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(LadderColors.surfaceContainerHigh)
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(barColor(for: index))
                                            .frame(width: max(geo.size.width * score, 0), height: 8)
                                    }
                                }
                                .frame(height: 8)

                                Text("\(Int(score * 100))%")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 34, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Shifts Section

    private var shiftsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.accentLime)
                    Text("Notable Changes")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                ForEach(significantShifts, id: \.path) { shift in
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: shift.change > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12))
                            .foregroundStyle(shift.change > 0 ? LadderColors.accentLime : LadderColors.tertiary)

                        Text("Your interest in \(shift.path) \(shift.change > 0 ? "grew" : "decreased") \(Int(abs(shift.change) * 100))%")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }

                if let last = lastResult, let prev = quizHistory.dropLast().last,
                   last.topCareerPath != prev.topCareerPath {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)
                        Text("Your path changed! Here are updated activity suggestions based on your new top interest in \(last.topCareerPath).")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.2))
                    .frame(width: 100, height: 100)
                Image(systemName: "questionmark.bubble")
                    .font(.system(size: 40))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(spacing: LadderSpacing.sm) {
                Text("No Quiz History Yet")
                    .font(LadderTypography.titleLarge)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Take your first career quiz to discover your interests and track how they evolve over your high school journey.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, LadderSpacing.xl)
    }

    // MARK: - Retake Button

    private var retakeButton: some View {
        VStack(spacing: LadderSpacing.sm) {
            if canRetake {
                LadderPrimaryButton("Retake Quiz", icon: "arrow.clockwise") {
                    navigateToQuiz = true
                }
            } else {
                LadderSecondaryButton("Already Taken This Year") { }
                    .opacity(0.5)
                    .disabled(true)

                Text("You can retake once per school year. Check back next year.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helpers

    private func barColor(for index: Int) -> Color {
        let colors: [Color] = [
            LadderColors.primary.opacity(0.4),
            LadderColors.primary.opacity(0.65),
            LadderColors.accentLime,
            LadderColors.secondaryFixed
        ]
        return colors[min(index, colors.count - 1)]
    }

    private func ordinalGrade(_ grade: Int) -> String {
        switch grade {
        case 9: return "9th"
        case 10: return "10th"
        case 11: return "11th"
        case 12: return "12th"
        default: return "\(grade)th"
        }
    }
}

#Preview {
    NavigationStack {
        CareerQuizRetakeView()
    }
    .modelContainer(for: [StudentProfileModel.self, CareerQuizHistoryModel.self], inMemory: true)
}
