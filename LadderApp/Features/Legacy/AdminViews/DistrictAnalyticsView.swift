import SwiftUI
import SwiftData

// MARK: - District Analytics View
// District-level aggregate analytics

struct DistrictAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var students: [StudentProfileModel]
    @Query private var applications: [ApplicationModel]
    @Query private var financialAid: [FinancialAidPackageModel]

    private var totalStudents: Int { students.count }

    private var avgGPA: Double {
        let gpas = students.compactMap(\.gpa)
        guard !gpas.isEmpty else { return 0 }
        return gpas.reduce(0, +) / Double(gpas.count)
    }

    private var totalScholarships: Int {
        financialAid.reduce(0) { $0 + $1.scholarshipAid + $1.grantAid }
    }

    private var gpaDistribution: [(label: String, value: Double, color: Color)] {
        let ranges: [(String, ClosedRange<Double>, Color)] = [
            ("4.0+", 4.0...5.0, LadderColors.primary),
            ("3.5-3.9", 3.5...3.99, LadderColors.primaryContainer),
            ("3.0-3.4", 3.0...3.49, LadderColors.primary.opacity(0.7)),
            ("2.5-2.9", 2.5...2.99, LadderColors.primaryContainer.opacity(0.7)),
            ("< 2.5", 0...2.49, LadderColors.outlineVariant)
        ]
        return ranges.map { label, range, color in
            let count = students.filter { ($0.gpa ?? 0) >= range.lowerBound && ($0.gpa ?? 0) <= range.upperBound }.count
            return (label: label, value: Double(count), color: color)
        }
    }

    private var acceptanceRate: Double {
        let decided = applications.filter { $0.status == "accepted" || $0.status == "rejected" || $0.status == "committed" }
        guard !decided.isEmpty else { return 0 }
        let accepted = decided.filter { $0.status == "accepted" || $0.status == "committed" }
        return Double(accepted.count) / Double(decided.count) * 100
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("District Analytics")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Aggregate data across your district")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Aggregate stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                        districtStatCard(value: "\(totalStudents)", label: "Total Students", icon: "person.3.fill")
                        districtStatCard(value: String(format: "%.2f", avgGPA), label: "Avg GPA", icon: "chart.line.uptrend.xyaxis")
                        districtStatCard(value: "$\(totalScholarships.formatted())", label: "Scholarships Won", icon: "dollarsign.circle.fill")
                        districtStatCard(value: String(format: "%.0f%%", acceptanceRate), label: "Acceptance Rate", icon: "checkmark.seal.fill")
                    }

                    // School comparison table
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("School Comparison")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        // Single school row (for now)
                        let schoolName = students.first?.schoolName ?? "Your School"
                        VStack(spacing: 0) {
                            // Header row
                            HStack {
                                Text("School")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Students")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 60)
                                Text("GPA")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 50)
                                Text("Rate")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.sm)

                            // Data row
                            HStack {
                                Text(schoolName)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Text("\(totalStudents)")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .frame(width: 60)
                                Text(String(format: "%.1f", avgGPA))
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .frame(width: 50)
                                Text(String(format: "%.0f%%", acceptanceRate))
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.primary)
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                    // GPA distribution chart
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("GPA Distribution")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        BarChartView(
                            data: gpaDistribution,
                            maxValue: max(gpaDistribution.map(\.value).max() ?? 1, 1)
                        )
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                    // Export button
                    LadderPrimaryButton("Export Report", icon: "square.and.arrow.up") {
                        // TODO: export functionality
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
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
                Text("District Analytics")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private func districtStatCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(LadderColors.primary)

            Text(value)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}
