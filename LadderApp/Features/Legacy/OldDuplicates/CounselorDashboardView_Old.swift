import SwiftUI
import SwiftData

// MARK: - Counselor Dashboard View

struct CounselorDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CollegeDeadlineModel.date) private var allDeadlines: [CollegeDeadlineModel]

    private var upcomingDeadlines: [CollegeDeadlineModel] {
        let now = Date()
        let twoMonths = Calendar.current.date(byAdding: .month, value: 2, to: now) ?? now
        return allDeadlines.filter { dl in
            guard let date = dl.date else { return false }
            return date >= now && date <= twoMonths
        }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // School connection prompt
                    connectSchoolCard

                    // Upcoming deadlines from SwiftData
                    deadlinesSection
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
                Text("Counselor Dashboard").font(LadderTypography.titleSmall)
            }
        }
    }

    // MARK: - Connect School Card

    private var connectSchoolCard: some View {
        VStack(spacing: LadderSpacing.lg) {
            Image(systemName: "building.columns")
                .font(.system(size: 40))
                .foregroundStyle(LadderColors.primary)

            VStack(spacing: LadderSpacing.sm) {
                Text("Connect Your School")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Connect your school to see your students, track their progress, and manage deadlines all in one place.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

            LadderPrimaryButton("Connect School", icon: "link") {
                // School integration coming in future update
            }
        }
        .padding(LadderSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
    }

    // MARK: - Deadlines Section

    private var deadlinesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Upcoming College Deadlines")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            if upcomingDeadlines.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "calendar")
                            .font(.system(size: 32))
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("No upcoming deadlines")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("Deadlines will appear here as colleges are added to student lists.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.lg)
                }
            } else {
                ForEach(upcomingDeadlines, id: \.deadlineType) { deadline in
                    LadderCard {
                        HStack(spacing: LadderSpacing.md) {
                            Circle()
                                .fill(deadlineColor(deadline.deadlineType))
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(deadline.college?.name ?? "Unknown College")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text(deadline.deadlineType)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            Spacer()

                            if let date = deadline.date {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(date, style: .date)
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text(daysUntil(date))
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(daysUntilColor(date))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func deadlineColor(_ type: String) -> Color {
        switch type {
        case "Early Decision": return .red
        case "Early Action": return .orange
        case "Regular Decision": return LadderColors.primary
        default: return LadderColors.primaryContainer
        }
    }

    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "Past due" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "\(days) days"
    }

    private func daysUntilColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days <= 3 { return .red }
        if days <= 7 { return .orange }
        return LadderColors.onSurfaceVariant
    }
}
