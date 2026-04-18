import SwiftUI
import SwiftData

// MARK: - Peer Comparison View
// Anonymous comparison of student's stats vs national averages

struct PeerComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var students: [StudentProfileModel]
    @Query private var activities: [ActivityModel]
    @Query private var applications: [ApplicationModel]

    private var student: StudentProfileModel? { students.first }

    // National averages (hardcoded for now)
    private let nationalAvgGPA: Double = 3.0
    private let top25GPA: Double = 3.75
    private let nationalAvgSAT: Int = 1060
    private let top25SAT: Int = 1300
    private let avgActivities: Int = 4
    private let avgApplications: Int = 8

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("How does \(student?.firstName ?? "your child") compare?")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Anonymous peer comparison based on national data")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // GPA comparison
                    comparisonCard(
                        title: "GPA",
                        icon: "chart.line.uptrend.xyaxis",
                        studentValue: student?.gpa.map { String(format: "%.2f", $0) } ?? "--",
                        avgValue: String(format: "%.1f", nationalAvgGPA),
                        top25Value: String(format: "%.2f", top25GPA),
                        percentile: student?.gpa.map { calculatePercentile(value: $0, avg: nationalAvgGPA, top25: top25GPA) }
                    )

                    // SAT comparison
                    comparisonCard(
                        title: "SAT Score",
                        icon: "pencil.and.list.clipboard",
                        studentValue: student?.satScore.map { "\($0)" } ?? "--",
                        avgValue: "\(nationalAvgSAT)",
                        top25Value: "\(top25SAT)",
                        percentile: student?.satScore.map { calculatePercentile(value: Double($0), avg: Double(nationalAvgSAT), top25: Double(top25SAT)) }
                    )

                    // Activities comparison
                    comparisonCard(
                        title: "Activities",
                        icon: "person.3.fill",
                        studentValue: "\(activities.count)",
                        avgValue: "\(avgActivities)",
                        top25Value: "7+",
                        percentile: calculatePercentile(value: Double(activities.count), avg: Double(avgActivities), top25: 7.0)
                    )

                    // Applications comparison
                    comparisonCard(
                        title: "Applications",
                        icon: "doc.text.fill",
                        studentValue: "\(applications.count)",
                        avgValue: "\(avgApplications)",
                        top25Value: "12+",
                        percentile: calculatePercentile(value: Double(applications.count), avg: Double(avgApplications), top25: 12.0)
                    )

                    // Privacy note
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 16))
                            .foregroundStyle(LadderColors.primary)
                        Text("All comparisons are anonymous. No individual student data is shared.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

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
                Text("Peer Comparison")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Comparison Card

    private func comparisonCard(title: String, icon: String, studentValue: String, avgValue: String, top25Value: String, percentile: String?) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(LadderColors.primary)
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                if let percentile = percentile {
                    Text(percentile)
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xs)
                        .background(LadderColors.primaryContainer.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            // Three-column comparison
            HStack(spacing: 0) {
                comparisonColumn(label: "Your Child", value: studentValue, isHighlighted: true)
                comparisonColumn(label: "Average", value: avgValue, isHighlighted: false)
                comparisonColumn(label: "Top 25%", value: top25Value, isHighlighted: false)
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func comparisonColumn(label: String, value: String, isHighlighted: Bool) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text(value)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(isHighlighted ? LadderColors.primary : LadderColors.onSurface)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Percentile Calculation

    private func calculatePercentile(value: Double, avg: Double, top25: Double) -> String {
        if value >= top25 { return "Top 25%" }
        if value >= avg { return "Above Avg" }
        if value >= avg * 0.85 { return "Near Avg" }
        return "Below Avg"
    }
}
