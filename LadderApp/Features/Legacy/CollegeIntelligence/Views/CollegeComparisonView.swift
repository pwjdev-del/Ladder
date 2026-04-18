import SwiftUI
import SwiftData

// MARK: - College Comparison View (side-by-side)

struct CollegeComparisonView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let leftId: String
    let rightId: String

    @State private var leftCollege: CollegeModel?
    @State private var rightCollege: CollegeModel?

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header with school logos and names
                    HStack {
                        VStack(spacing: LadderSpacing.sm) {
                            CollegeLogoView(leftCollege?.name ?? "School 1", websiteURL: leftCollege?.websiteURL, size: 48, cornerRadius: 12)
                            Text(leftCollege?.name ?? "School 1")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                        Text("vs")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        VStack(spacing: LadderSpacing.sm) {
                            CollegeLogoView(rightCollege?.name ?? "School 2", websiteURL: rightCollege?.websiteURL, size: 48, cornerRadius: 12)
                            Text(rightCollege?.name ?? "School 2")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(LadderSpacing.lg)

                    // Comparison rows
                    LadderCard {
                        VStack(spacing: 0) {
                            comparisonRow("Acceptance", leftCollege?.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A",
                                         rightCollege?.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A",
                                         lowerIsBetter: true, leftVal: leftCollege?.acceptanceRate, rightVal: rightCollege?.acceptanceRate)

                            comparisonRow("In-State Tuition", leftCollege?.inStateTuition.map { "$\($0.formatted())" } ?? "N/A",
                                         rightCollege?.inStateTuition.map { "$\($0.formatted())" } ?? "N/A",
                                         lowerIsBetter: true, leftVal: leftCollege?.inStateTuition.map(Double.init), rightVal: rightCollege?.inStateTuition.map(Double.init))

                            comparisonRow("SAT Average", leftCollege?.satAvg.map { "\($0)" } ?? "N/A",
                                         rightCollege?.satAvg.map { "\($0)" } ?? "N/A",
                                         lowerIsBetter: false, leftVal: leftCollege?.satAvg.map(Double.init), rightVal: rightCollege?.satAvg.map(Double.init))

                            comparisonRow("Enrollment", leftCollege?.enrollment.map { "\($0.formatted())" } ?? "N/A",
                                         rightCollege?.enrollment.map { "\($0.formatted())" } ?? "N/A",
                                         lowerIsBetter: nil, leftVal: nil, rightVal: nil)

                            comparisonRow("Graduation Rate", leftCollege?.completionRate.map { "\(Int($0 * 100))%" } ?? "N/A",
                                         rightCollege?.completionRate.map { "\(Int($0 * 100))%" } ?? "N/A",
                                         lowerIsBetter: false, leftVal: leftCollege?.completionRate, rightVal: rightCollege?.completionRate)

                            comparisonRow("Median Earnings", leftCollege?.medianEarnings.map { "$\($0.formatted())" } ?? "N/A",
                                         rightCollege?.medianEarnings.map { "$\($0.formatted())" } ?? "N/A",
                                         lowerIsBetter: false, leftVal: leftCollege?.medianEarnings.map(Double.init), rightVal: rightCollege?.medianEarnings.map(Double.init))

                            comparisonRow("Testing Policy", leftCollege?.testingPolicy ?? "N/A",
                                         rightCollege?.testingPolicy ?? "N/A",
                                         lowerIsBetter: nil, leftVal: nil, rightVal: nil)

                            comparisonRow("App Fee", leftCollege?.applicationFee ?? "N/A",
                                         rightCollege?.applicationFee ?? "N/A",
                                         lowerIsBetter: nil, leftVal: nil, rightVal: nil)
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
            ToolbarItem(placement: .principal) {
                Text("Compare Schools").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
            }
        }
        .task { loadColleges() }
    }

    @ViewBuilder
    private func comparisonRow(_ label: String, _ left: String, _ right: String,
                                lowerIsBetter: Bool?, leftVal: Double?, rightVal: Double?) -> some View {
        let advantage: Bool? = {
            guard let l = leftVal, let r = rightVal, let lower = lowerIsBetter else { return nil }
            if lower { return l < r ? true : l > r ? false : nil }
            return l > r ? true : l < r ? false : nil
        }()

        ComparisonRow(label: label, leftValue: left, rightValue: right, leftAdvantage: advantage)
    }

    private func loadColleges() {
        let descriptor = FetchDescriptor<CollegeModel>()
        if let results = try? context.fetch(descriptor) {
            leftCollege = results.first { String($0.scorecardId ?? 0) == leftId || $0.name == leftId }
            rightCollege = results.first { String($0.scorecardId ?? 0) == rightId || $0.name == rightId }
        }
    }
}
