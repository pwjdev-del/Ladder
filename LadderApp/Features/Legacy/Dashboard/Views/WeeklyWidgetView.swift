import SwiftUI
import SwiftData

// MARK: - Weekly Widget View
// "3 Things To Do This Week" — compact card for embedding in DashboardView

struct WeeklyWidgetView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator
    @State private var items: [WeeklyActionItem] = []
    @State private var loaded = false

    var body: some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.accentLime)

                    Text("3 THINGS TO DO THIS WEEK")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    Spacer()
                }

                if !loaded {
                    // Loading placeholder
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, LadderSpacing.sm)
                } else if items.isEmpty {
                    // All caught up
                    allCaughtUp
                } else {
                    // Action items
                    VStack(spacing: LadderSpacing.xs) {
                        ForEach(items.prefix(3)) { item in
                            weeklyActionRow(item)
                        }
                    }
                }
            }
        }
    }

    // MARK: - All Caught Up

    private var allCaughtUp: some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                Circle()
                    .fill(LadderColors.accentLime.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(LadderColors.accentLime)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("You're all caught up!")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Nothing urgent this week. Keep up the great work.")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()
        }
    }

    // MARK: - Action Row

    private func weeklyActionRow(_ item: WeeklyActionItem) -> some View {
        Button {
            if let route = item.route {
                coordinator.navigate(to: route)
            }
        } label: {
            HStack(spacing: LadderSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous)
                        .fill(item.iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: item.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(item.iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                if item.route != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(LadderColors.outlineVariant)
                }
            }
            .padding(.vertical, LadderSpacing.xs)
        }
        .buttonStyle(.plain)
        .disabled(item.route == nil)
    }

    // MARK: - Data Loading

    func loadActions() {
        var actions: [WeeklyActionItem] = []
        let now = Date()
        let oneWeek = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now

        // 1. Upcoming deadlines within 7 days
        let deadlineDescriptor = FetchDescriptor<CollegeDeadlineModel>()
        let deadlines = (try? context.fetch(deadlineDescriptor)) ?? []
        for deadline in deadlines {
            guard let date = deadline.date,
                  date >= now && date <= oneWeek,
                  let collegeName = deadline.college?.name else { continue }

            let daysLeft = Calendar.current.dateComponents([.day], from: now, to: date).day ?? 0
            actions.append(WeeklyActionItem(
                icon: "calendar.badge.exclamationmark",
                iconColor: daysLeft <= 3 ? LadderColors.error : Color.orange,
                title: "\(collegeName) \(deadline.deadlineType)",
                subtitle: daysLeft == 0 ? "Due today" : "Due in \(daysLeft) day\(daysLeft == 1 ? "" : "s")",
                urgency: 100 - daysLeft,
                route: .deadlinesCalendar
            ))
        }

        // 2. Incomplete checklist items with due dates this week
        let checklistDescriptor = FetchDescriptor<ChecklistItemModel>()
        let checklistItems = (try? context.fetch(checklistDescriptor)) ?? []
        for item in checklistItems {
            guard item.status != "completed" else { continue }
            if let dueDate = item.dueDate, dueDate >= now && dueDate <= oneWeek {
                let daysLeft = Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? 0
                actions.append(WeeklyActionItem(
                    icon: "checklist",
                    iconColor: LadderColors.primary,
                    title: item.title,
                    subtitle: daysLeft == 0 ? "Due today" : "Due in \(daysLeft) day\(daysLeft == 1 ? "" : "s")",
                    urgency: 90 - daysLeft,
                    route: .activityChecklist
                ))
            }
        }

        // 3. Missing essays (not_started status)
        let essayDescriptor = FetchDescriptor<EssayModel>()
        let essays = (try? context.fetch(essayDescriptor)) ?? []
        let notStarted = essays.filter { $0.status == "not_started" }
        for essay in notStarted.prefix(2) {
            actions.append(WeeklyActionItem(
                icon: "doc.text",
                iconColor: LadderColors.tertiary,
                title: "Start essay for \(essay.collegeName)",
                subtitle: "\(essay.wordLimit) word limit",
                urgency: 50,
                route: .essayTracker
            ))
        }

        // Sort by urgency (highest first) and take top 3
        items = Array(actions.sorted { $0.urgency > $1.urgency }.prefix(3))
        loaded = true
    }
}

// MARK: - Weekly Action Item Model

struct WeeklyActionItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let urgency: Int  // Higher = more urgent
    let route: Route?
}

// MARK: - Task modifier to load on appear

extension WeeklyWidgetView {
    func autoLoad() -> some View {
        self.task { loadActions() }
    }
}

#Preview {
    WeeklyWidgetView()
        .padding()
        .background(LadderColors.surface)
        .environment(AppCoordinator())
}
