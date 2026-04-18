import SwiftUI
import SwiftData

// MARK: - Parent Dashboard View
// Read-only view of child's college prep data

struct ParentDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var students: [StudentProfileModel]
    @Query private var applications: [ApplicationModel]
    @Query private var activities: [ActivityModel]
    @Query private var financialAid: [FinancialAidPackageModel]

    private var student: StudentProfileModel? { students.first }

    private var submittedApps: Int {
        applications.filter { $0.status == "submitted" || $0.status == "accepted" || $0.status == "committed" }.count
    }

    private var totalAid: Int {
        financialAid.reduce(0) { $0 + $1.totalAid }
    }

    private var upcomingDeadlines: [ApplicationModel] {
        applications
            .filter { $0.deadlineDate != nil && ($0.deadlineDate ?? .distantPast) > Date() }
            .sorted { ($0.deadlineDate ?? .distantFuture) < ($1.deadlineDate ?? .distantFuture) }
    }

    private var savedColleges: [ApplicationModel] {
        applications.sorted { $0.collegeName < $1.collegeName }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    if let student = student {
                        connectedView(student)
                    } else {
                        disconnectedView
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.top, LadderSpacing.lg)
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
                Text("Parent Dashboard")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Connected View (student found)

    @ViewBuilder
    private func connectedView(_ student: StudentProfileModel) -> some View {
        // Child header
        HStack(spacing: LadderSpacing.md) {
            Circle()
                .fill(LadderColors.primaryContainer)
                .frame(width: 56, height: 56)
                .overlay {
                    Text(String(student.firstName.prefix(1)))
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullName)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Grade \(student.grade) \(student.schoolName.map { " - \($0)" } ?? "")")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

        // Stats overview
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
            parentStatTile(icon: "chart.line.uptrend.xyaxis", label: "GPA", value: student.gpa.map { String(format: "%.2f", $0) } ?? "--")
            parentStatTile(icon: "pencil.and.list.clipboard", label: "SAT", value: student.satScore.map { "\($0)" } ?? "--")
            parentStatTile(icon: "doc.text.fill", label: "Applications", value: "\(submittedApps)")
            parentStatTile(icon: "person.3.fill", label: "Activities", value: "\(activities.count)")
        }

        // College list
        if !savedColleges.isEmpty {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("College List")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(savedColleges) { app in
                    HStack(spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(statusColor(app.status).opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: statusIcon(app.status))
                                .font(.system(size: 14))
                                .foregroundStyle(statusColor(app.status))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.collegeName)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(app.status.capitalized)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        Spacer()
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }

        // Upcoming deadlines
        if !upcomingDeadlines.isEmpty {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Upcoming Deadlines")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(upcomingDeadlines.prefix(5)) { app in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.collegeName)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            if let type = app.deadlineType {
                                Text(type)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                        Spacer()
                        if let date = app.deadlineDate {
                            Text(date, style: .date)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }

        // Financial aid summary
        if totalAid > 0 {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Financial Aid Summary")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                HStack {
                    Text("Total Aid Awarded")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    Text("$\(totalAid.formatted())")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.primary)
                }
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    // MARK: - Disconnected View

    private var disconnectedView: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xxl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.2.circle")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("Connect to Your Child")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Connect to your child's account using their invite code to view their college prep progress, deadlines, and financial aid information.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)

            // Invite code input placeholder
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundStyle(LadderColors.primary)
                Text("Enter invite code")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                Spacer()
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            .padding(.horizontal, LadderSpacing.xl)
        }
    }

    // MARK: - Helpers

    private func parentStatTile(icon: String, label: String, value: String) -> some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(LadderColors.primary)

            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "accepted", "committed": return LadderColors.primary
        case "rejected": return LadderColors.error
        case "waitlisted": return .orange
        case "submitted": return LadderColors.primaryContainer
        default: return LadderColors.onSurfaceVariant
        }
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "accepted", "committed": return "checkmark.circle.fill"
        case "rejected": return "xmark.circle.fill"
        case "waitlisted": return "clock.fill"
        case "submitted": return "paperplane.fill"
        default: return "circle"
        }
    }
}
