import SwiftUI
import SwiftData

// MARK: - SAT Score Tracker View
// Matches sat_score_tracker Stitch design

struct SATScoreTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SATScoreTrackerViewModel()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    superscoreCard
                    chartSection
                    attemptsSection
                    collegeTargetsSection
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(LadderColors.primaryContainer)
                            .clipShape(Circle())
                            .ladderShadow(LadderElevation.floating)
                    }
                    .padding(.trailing, LadderSpacing.md)
                    .padding(.bottom, 100)
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
                Text("SAT Score Tracker")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear {
            viewModel.loadEntries(from: modelContext)
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            addScoreSheet
        }
    }

    // MARK: - Superscore Card

    private var superscoreCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text("BEST SUPERSCORE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text("\(viewModel.bestSuperscore)")
                            .font(LadderTypography.displaySmall)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    Spacer()
                    if viewModel.entries.count > 0 {
                        Text("Superscored across \(viewModel.entries.count) attempt\(viewModel.entries.count == 1 ? "" : "s")")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.accentLime)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: LadderSpacing.xxl) {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text("MATH")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text("\(viewModel.bestMath)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text("READING")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                        Text("\(viewModel.bestReading)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Score Progression")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface.opacity(0.8))

            LineChartView(
                data: viewModel.chartData,
                targetLine: viewModel.targetSATAverage,
                lineColor: LadderColors.primaryContainer
            )
            .frame(height: 180)
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

            if !viewModel.sortedEntries.isEmpty {
                HStack {
                    ForEach(viewModel.sortedEntries, id: \.testDate) { entry in
                        Text(monthString(entry.testDate))
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.6))
                            .labelTracking()
                        if entry.testDate != viewModel.sortedEntries.last?.testDate {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
            }
        }
    }

    // MARK: - Attempts Section

    private var attemptsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text("My Attempts")
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Text("\(viewModel.entries.count) Total")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary.opacity(0.6))
                    .labelTracking()
            }

            ForEach(Array(viewModel.sortedEntries.reversed().enumerated()), id: \.element.testDate) { index, entry in
                let reversed = viewModel.sortedEntries.reversed()
                let reversedArray = Array(reversed)
                let improvement: Int? = (index + 1 < reversedArray.count)
                    ? entry.totalScore - reversedArray[index + 1].totalScore
                    : nil

                attemptRow(entry: entry, improvement: improvement)
                    .opacity(1.0 - Double(index) * 0.15)
            }
        }
    }

    private func attemptRow(entry: SATScoreEntryModel, improvement: Int?) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(dateFormatter.string(from: entry.testDate).uppercased())
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.7))
                    .labelTracking()
                HStack(spacing: LadderSpacing.sm) {
                    Text("\(entry.totalScore)")
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    if let improvement, improvement > 0 {
                        HStack(spacing: LadderSpacing.xxs) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                            Text("+\(improvement) pts")
                                .font(LadderTypography.labelSmall)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    if entry.isPractice {
                        Text("PRACTICE")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: LadderSpacing.xxs) {
                HStack(spacing: LadderSpacing.xs) {
                    Text("M:")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("\(entry.mathScore)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                HStack(spacing: LadderSpacing.xs) {
                    Text("R:")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("\(entry.readingScore)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - College Targets

    private var collegeTargetsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("College Targets")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            ForEach(viewModel.collegeTargets) { target in
                let status = viewModel.statusForTarget(target)
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.sm)
                            .fill(LadderColors.surfaceContainerHighest)
                            .frame(width: 48, height: 48)
                        Image(systemName: "building.columns")
                            .font(.system(size: 20))
                            .foregroundStyle(LadderColors.primary)
                    }
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(target.name)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Range: \(target.satLow) - \(target.satHigh)")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: LadderSpacing.xs) {
                        Circle()
                            .fill(status.color)
                            .frame(width: 10, height: 10)
                        Text(status.label.uppercased())
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(status.color)
                            .labelTracking()
                    }
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
        }
    }

    // MARK: - Add Score Sheet

    private var addScoreSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                VStack(spacing: LadderSpacing.lg) {
                    DatePicker("Test Date", selection: $viewModel.newTestDate, displayedComponents: .date)
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurface)

                    LadderTextField("Math Score (200-800)", text: $viewModel.newMathScore, icon: "function")

                    LadderTextField("Reading Score (200-800)", text: $viewModel.newReadingScore, icon: "text.book.closed")

                    Toggle(isOn: $viewModel.newIsPractice) {
                        Text("Practice Test")
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .tint(LadderColors.primary)

                    Spacer()

                    LadderPrimaryButton("Save Score", icon: "checkmark") {
                        viewModel.addScore(context: modelContext)
                    }
                }
                .padding(LadderSpacing.lg)
            }
            .navigationTitle("Add Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showAddSheet = false }
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func monthString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Safe Collection Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        SATScoreTrackerView()
    }
}
