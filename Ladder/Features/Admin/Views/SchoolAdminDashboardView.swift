import SwiftUI
import SwiftData

// MARK: - School Admin Dashboard View
// Admin overview with stats, activity feed, and quick actions

struct SchoolAdminDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var students: [StudentProfileModel]
    @Query private var counselors: [CounselorProfileModel]
    @Query private var applications: [ApplicationModel]

    private var totalStudents: Int { students.count }
    private var totalCounselors: Int { counselors.count }
    private var totalApplications: Int { applications.count }

    private var acceptanceRate: Double {
        let decided = applications.filter { $0.status == "accepted" || $0.status == "rejected" || $0.status == "committed" }
        guard !decided.isEmpty else { return 0 }
        let accepted = decided.filter { $0.status == "accepted" || $0.status == "committed" }
        return Double(accepted.count) / Double(decided.count) * 100
    }

    private var recentMilestones: [(icon: String, text: String, time: String)] {
        var items: [(String, String, String)] = []
        let recentApps = applications.sorted { ($0.submittedAt ?? $0.createdAt) > ($1.submittedAt ?? $1.createdAt) }.prefix(5)
        for app in recentApps {
            switch app.status {
            case "submitted":
                items.append(("doc.text.fill", "Application submitted to \(app.collegeName)", "Recent"))
            case "accepted":
                items.append(("checkmark.seal.fill", "Accepted to \(app.collegeName)", "Recent"))
            case "committed":
                items.append(("graduationcap.fill", "Committed to \(app.collegeName)", "Recent"))
            default: break
            }
        }
        if items.isEmpty {
            items.append(("sparkles", "No recent activity yet", ""))
        }
        return items
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School Dashboard")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(LadderColors.primary)
                            Text(students.first?.schoolName ?? "Your School")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    if totalStudents == 0 {
                        emptyState
                    } else {
                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                            AdminStatCard(icon: "person.3.fill", value: "\(totalStudents)", label: "Students", color: LadderColors.primary)
                            AdminStatCard(icon: "person.text.rectangle.fill", value: "\(totalCounselors)", label: "Counselors", color: LadderColors.primaryContainer)
                            AdminStatCard(icon: "doc.text.fill", value: "\(totalApplications)", label: "Applications", color: LadderColors.primary)
                            AdminStatCard(icon: "checkmark.seal.fill", value: String(format: "%.0f%%", acceptanceRate), label: "Acceptance", color: LadderColors.primaryContainer)
                        }

                        // This week activity
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("This Week")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(Array(recentMilestones.enumerated()), id: \.offset) { _, item in
                                HStack(spacing: LadderSpacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(LadderColors.primaryContainer.opacity(0.3))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: item.icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(LadderColors.primary)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.text)
                                            .font(LadderTypography.bodyMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                        if !item.time.isEmpty {
                                            Text(item.time)
                                                .font(LadderTypography.labelSmall)
                                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                        }
                                    }

                                    Spacer()
                                }
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    }

                    // Quick actions
                    quickActionsSection

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
                Text("Admin Dashboard")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.crop.rectangle.stack.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Students Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Import your student roster to see school-wide analytics and track college readiness across your school.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Quick Actions")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            ForEach([
                ("person.badge.plus", "Add Students", "Import student roster"),
                ("person.text.rectangle", "Manage Counselors", "Invite and manage counselors"),
                ("chart.bar.xaxis", "View Reports", "District-level analytics")
            ], id: \.1) { icon, title, subtitle in
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                            .fill(LadderColors.primaryContainer.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundStyle(LadderColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(subtitle)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }
        }
    }
}
