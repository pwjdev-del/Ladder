import SwiftUI
import SwiftData

// MARK: - Gap Analysis View ("What does this college want from YOU?")

struct GapAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let collegeId: String

    @State private var college: CollegeModel?
    @State private var gaps: [GapItem] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Match score header
                    LadderCard {
                        VStack(spacing: LadderSpacing.md) {
                            Text("Your Fit Analysis")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(college?.name ?? "")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            // Overall match circle
                            let overallMatch = calculateOverallMatch()
                            ZStack {
                                Circle()
                                    .stroke(LadderColors.surfaceContainerLow, lineWidth: 12)
                                    .frame(width: 120, height: 120)
                                Circle()
                                    .trim(from: 0, to: overallMatch / 100)
                                    .stroke(matchColor(overallMatch), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                VStack(spacing: 2) {
                                    Text("\(Int(overallMatch))%")
                                        .font(LadderTypography.headlineMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text("Match")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                    }

                    // Gap breakdown
                    ForEach(gaps) { gap in
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                HStack {
                                    Image(systemName: gap.icon)
                                        .foregroundStyle(matchColor(gap.matchPercent))
                                    Text(gap.dimension)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                    Text("\(Int(gap.matchPercent))%")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(matchColor(gap.matchPercent))
                                }

                                // Progress bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(LadderColors.surfaceContainerLow)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(matchColor(gap.matchPercent))
                                            .frame(width: geo.size.width * gap.matchPercent / 100)
                                    }
                                }
                                .frame(height: 8)

                                HStack {
                                    Text("You: \(gap.yourValue)")
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Spacer()
                                    Text("Target: \(gap.targetValue)")
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }

                                if let suggestion = gap.suggestion {
                                    Text(suggestion)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.primary)
                                        .padding(.top, 2)
                                }
                            }
                        }
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .task { loadData() }
    }

    private func loadData() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            college = results.first { String($0.scorecardId ?? 0) == collegeId }
        }
        guard let c = college else { return }

        // Mock student data (would come from StudentProfileModel in production)
        let studentGPA = 3.7
        let studentSAT = 1350

        var items: [GapItem] = []

        // GPA gap
        let avgGPA = 3.8 // Approximate from acceptance rate
        let gpaMatch = min(100, (studentGPA / avgGPA) * 100)
        items.append(GapItem(dimension: "GPA", yourValue: String(format: "%.2f", studentGPA),
                             targetValue: String(format: "%.1f+", avgGPA), matchPercent: gpaMatch,
                             icon: "graduationcap", suggestion: gpaMatch < 80 ? "Consider taking more AP courses to boost your weighted GPA" : nil))

        // SAT gap
        if let satAvg = c.satAvg {
            let satMatch = min(100, (Double(studentSAT) / Double(satAvg)) * 100)
            items.append(GapItem(dimension: "SAT Score", yourValue: "\(studentSAT)",
                                 targetValue: "\(satAvg)", matchPercent: satMatch,
                                 icon: "doc.text", suggestion: satMatch < 80 ? "Focus on practice tests — Khan Academy shows 90-115 point gains" : nil))
        }

        // Acceptance rate as difficulty indicator
        if let rate = c.acceptanceRate {
            let difficulty = rate * 100
            items.append(GapItem(dimension: "Selectivity", yourValue: "Your Profile",
                                 targetValue: "\(Int(difficulty))% acceptance", matchPercent: min(100, difficulty * 1.5),
                                 icon: "chart.bar", suggestion: difficulty < 20 ? "This is a highly selective school — strong essays and activities are critical" : nil))
        }

        gaps = items
    }

    private func calculateOverallMatch() -> Double {
        guard !gaps.isEmpty else { return 50 }
        return gaps.reduce(0) { $0 + $1.matchPercent } / Double(gaps.count)
    }

    private func matchColor(_ percent: Double) -> Color {
        if percent >= 75 { return LadderColors.primary }
        if percent >= 50 { return LadderColors.secondaryFixed }
        return Color.orange
    }
}

struct GapItem: Identifiable {
    let id = UUID()
    let dimension: String
    let yourValue: String
    let targetValue: String
    let matchPercent: Double
    let icon: String
    let suggestion: String?
}
