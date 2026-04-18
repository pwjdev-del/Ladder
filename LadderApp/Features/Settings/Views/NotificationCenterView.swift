import SwiftUI
import SwiftData

// MARK: - Notification Center View

struct NotificationCenterView: View {
    @Environment(\.dismiss) private var dismiss
    // Only load upcoming deadlines (not the full ~20K historical dataset).
    @Query(
        filter: #Predicate<CollegeDeadlineModel> { $0.date != nil },
        sort: \CollegeDeadlineModel.date
    ) private var deadlines: [CollegeDeadlineModel]

    @State private var notifications: [AppNotification] = []

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.sm) {
                    ForEach(notifications) { notification in
                        LadderCard {
                            HStack(alignment: .top, spacing: LadderSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(notification.color.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: notification.icon)
                                        .foregroundStyle(notification.color)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .fontWeight(notification.isRead ? .regular : .semibold)
                                    Text(notification.message)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Text(notification.timeAgo)
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.outlineVariant)
                                }

                                Spacer()

                                if !notification.isRead {
                                    Circle()
                                        .fill(LadderColors.primary)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }

                    if notifications.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("No new notifications")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Notifications will appear here when you have upcoming deadlines or activity updates.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                        .padding(.horizontal, LadderSpacing.lg)
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
                Text("Notifications").font(LadderTypography.titleSmall)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Read All") {
                    for i in notifications.indices { notifications[i].isRead = true }
                }
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.primary)
            }
        }
        .onAppear { generateNotifications() }
    }

    // MARK: - Dynamic Notification Generation

    private func generateNotifications() {
        var generated: [AppNotification] = []
        let now = Date()
        let twoWeeks = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now

        // Generate notifications from upcoming deadlines (within 14 days)
        let upcoming = deadlines.filter { dl in
            guard let date = dl.date else { return false }
            return date >= now && date <= twoWeeks
        }

        for deadline in upcoming.prefix(5) {
            guard let date = deadline.date else { continue }
            let collegeName = deadline.college?.name ?? "A college"
            let days = Calendar.current.dateComponents([.day], from: now, to: date).day ?? 0

            let urgency: String
            let icon: String
            let color: Color

            if days <= 3 {
                urgency = "in \(days) day\(days == 1 ? "" : "s")"
                icon = "exclamationmark.circle.fill"
                color = .red
            } else if days <= 7 {
                urgency = "in \(days) days"
                icon = "clock.fill"
                color = .orange
            } else {
                urgency = "in \(days) days"
                icon = "calendar.badge.clock"
                color = LadderColors.primary
            }

            generated.append(AppNotification(
                title: "Deadline Approaching",
                message: "\(collegeName) \(deadline.deadlineType) deadline is \(urgency).",
                icon: icon,
                color: color,
                timeAgo: "Now",
                isRead: days > 7
            ))
        }

        notifications = generated
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let color: Color
    let timeAgo: String
    var isRead: Bool
}
