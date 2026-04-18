import SwiftUI

// MARK: - Common App Export View
// Displays all activities formatted for the Common Application (up to 10).

struct CommonAppExportView: View {
    @Environment(\.dismiss) private var dismiss
    let activities: [ActivityModel]
    @State private var copiedAll = false

    private let commonAppLimit = 10

    private var sortedActivities: [ActivityModel] {
        activities
            .sorted { $0.tier < $1.tier }
            .prefix(commonAppLimit)
            .map { $0 }
    }

    private var exportText: String {
        sortedActivities.enumerated().map { index, activity in
            formatActivityForExport(activity, number: index + 1)
        }.joined(separator: "\n\n")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // Header info
                        headerSection

                        // Activity cards
                        ForEach(Array(sortedActivities.enumerated()), id: \.element.id) { index, activity in
                            exportActivityCard(activity, number: index + 1)
                        }

                        if sortedActivities.isEmpty {
                            emptyExportState
                        }

                        // Actions
                        if !sortedActivities.isEmpty {
                            actionsSection
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, LadderSpacing.xxl)
                }
            }
            .navigationTitle("Common App Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.primary)
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Common Application")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Activities Section")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                }

                HStack(spacing: LadderSpacing.lg) {
                    VStack {
                        Text("\(sortedActivities.count)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("of \(commonAppLimit)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    // Progress bar
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LadderColors.surfaceContainerHigh)
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(sortedActivities.count >= commonAppLimit ? LadderColors.primary : LadderColors.secondary)
                                    .frame(width: geo.size.width * CGFloat(sortedActivities.count) / CGFloat(commonAppLimit), height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text(sortedActivities.count >= commonAppLimit ? "Maximum reached" : "\(commonAppLimit - sortedActivities.count) slots remaining")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(sortedActivities.count >= commonAppLimit ? LadderColors.primary : LadderColors.onSurfaceVariant)
                    }
                }
            }
        }
    }

    // MARK: - Export Activity Card

    private func exportActivityCard(_ activity: ActivityModel, number: Int) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                // Number + name
                HStack(alignment: .top) {
                    Text("\(number)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(LadderColors.primary)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(activity.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(activity.category)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    tierLabel(activity.tier)
                }

                // Position / Leadership
                if let role = activity.role, !role.isEmpty {
                    fieldRow(label: "Position", value: role)
                }

                // Organization
                if let org = activity.organization, !org.isEmpty {
                    fieldRow(label: "Organization", value: org)
                }

                // Description (impact statement)
                if let impact = activity.impactStatement, !impact.isEmpty {
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Description")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(impact)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("\(impact.count)/150 characters")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(impact.count > 150 ? LadderColors.error : LadderColors.outlineVariant)
                    }
                } else {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 12))
                        Text("Missing impact statement")
                            .font(LadderTypography.bodySmall)
                    }
                    .foregroundStyle(.orange)
                }

                // Hours + Weeks + Grades
                HStack(spacing: LadderSpacing.lg) {
                    if let hours = activity.hoursPerWeek, hours > 0 {
                        VStack {
                            Text("\(Int(hours))")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("hrs/wk")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    if let weeks = activity.weeksPerYear, weeks > 0 {
                        VStack {
                            Text("\(Int(weeks))")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("wks/yr")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    if !activity.gradeYears.isEmpty {
                        VStack {
                            Text(activity.gradeYearsFormatted)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("grades")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    Spacer()

                    if activity.isLeadership {
                        HStack(spacing: LadderSpacing.xxs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text("Leadership")
                                .font(LadderTypography.labelSmall)
                        }
                        .foregroundStyle(LadderColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func fieldRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(value)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    private func tierLabel(_ tier: Int) -> some View {
        Text("Tier \(tier)")
            .font(LadderTypography.labelSmall)
            .foregroundStyle(LadderColors.onSurfaceVariant)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(LadderColors.surfaceContainerHighest)
            .clipShape(Capsule())
    }

    // MARK: - Empty State

    private var emptyExportState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.outlineVariant)
            Text("No activities to export")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text("Add activities to your portfolio first.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.top, 40)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: LadderSpacing.md) {
            LadderPrimaryButton(copiedAll ? "Copied" : "Copy All", icon: copiedAll ? "checkmark" : "doc.on.doc") {
                UIPasteboard.general.string = exportText
                withAnimation {
                    copiedAll = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { copiedAll = false }
                }
            }

            ShareLink(item: exportText) {
                HStack(spacing: LadderSpacing.sm) {
                    Text("SHARE".uppercased())
                        .font(LadderTypography.labelLarge)
                        .labelTracking()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(LadderColors.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Export Formatting

    private func formatActivityForExport(_ activity: ActivityModel, number: Int) -> String {
        var lines: [String] = []
        lines.append("Activity \(number): \(activity.name)")
        lines.append("Category: \(activity.category)")

        if let role = activity.role, !role.isEmpty {
            lines.append("Position: \(role)")
        }
        if let org = activity.organization, !org.isEmpty {
            lines.append("Organization: \(org)")
        }
        if let impact = activity.impactStatement, !impact.isEmpty {
            lines.append("Description: \(impact)")
        }
        if let hours = activity.hoursPerWeek, hours > 0 {
            lines.append("Hours/Week: \(Int(hours))")
        }
        if let weeks = activity.weeksPerYear, weeks > 0 {
            lines.append("Weeks/Year: \(Int(weeks))")
        }
        if !activity.gradeYears.isEmpty {
            lines.append("Grades: \(activity.gradeYearsFormatted)")
        }
        if activity.isLeadership {
            lines.append("Leadership: Yes")
        }

        return lines.joined(separator: "\n")
    }
}
