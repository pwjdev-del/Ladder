import SwiftUI
import SwiftData

// MARK: - Deadlines Calendar View

struct DeadlinesCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Query var deadlines: [CollegeDeadlineModel]
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var calendarAlert: CalendarAlertState?

    private enum CalendarAlertState: Identifiable {
        case added(String)
        case alreadyExists(String)
        case noAccess

        var id: String {
            switch self {
            case .added(let t): return "added-\(t)"
            case .alreadyExists(let t): return "exists-\(t)"
            case .noAccess: return "noaccess"
            }
        }
    }

    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    monthSelector
                    upcomingDeadlines
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
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
                Text("Deadlines")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .alert(item: $calendarAlert) { alertType in
            switch alertType {
            case .added(let title):
                Alert(title: Text("Added to Calendar"), message: Text("\(title) has been added with reminders set for 1 week and 1 day before."), dismissButton: .default(Text("OK")))
            case .alreadyExists(let title):
                Alert(title: Text("Already Added"), message: Text("\(title) is already on your calendar."), dismissButton: .default(Text("OK")))
            case .noAccess:
                Alert(title: Text("Calendar Access Required"), message: Text("Please enable calendar access in Settings to add deadlines."), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(Array(months.enumerated()), id: \.offset) { index, month in
                    let monthNum = index + 1
                    let hasDeadlines = deadlinesForMonth(monthNum).count > 0
                    Button {
                        withAnimation { selectedMonth = monthNum }
                    } label: {
                        VStack(spacing: LadderSpacing.xs) {
                            Text(month)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(selectedMonth == monthNum ? .white : LadderColors.onSurfaceVariant)

                            if hasDeadlines {
                                Circle()
                                    .fill(selectedMonth == monthNum ? .white : LadderColors.accentLime)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(selectedMonth == monthNum ? LadderColors.primary : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Upcoming Deadlines

    private var upcomingDeadlines: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("\(months[selectedMonth - 1].uppercased()) DEADLINES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            let monthDeadlines = deadlinesForMonth(selectedMonth)
            if deadlines.isEmpty {
                // No deadlines at all in database
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text("Add colleges to your list to see their deadlines")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .multilineTextAlignment(.center)

                    Text("Deadlines will appear here once you add colleges with deadline information.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.xxxxl)
            } else if monthDeadlines.isEmpty {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text("No deadlines this month")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.xxxxl)
            } else {
                ForEach(monthDeadlines) { deadline in
                    deadlineCard(deadline)
                }
            }
        }
    }

    private func deadlineCard(_ deadline: CollegeDeadlineModel) -> some View {
        let collegeName = deadline.college?.name ?? "Unknown College"
        let deadlineDate = deadline.date ?? Date()
        let day = Calendar.current.component(.day, from: deadlineDate)
        let isUrgent = deadlineDate.timeIntervalSinceNow < 7 * 24 * 3600 && deadlineDate.timeIntervalSinceNow > 0
        let platform = deadline.applicationPlatforms.first ?? "Direct"

        let weekdayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f
        }()

        return VStack(spacing: 0) {
            Button {
                if let collegeId = deadline.college?.supabaseId {
                    coordinator.navigate(to: .applicationDetail(applicationId: collegeId))
                }
            } label: {
                HStack(spacing: LadderSpacing.md) {
                    // Date column
                    VStack(spacing: 2) {
                        Text("\(day)")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(isUrgent ? LadderColors.error : LadderColors.primary)

                        Text(weekdayFormatter.string(from: deadlineDate))
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(width: 48)

                    Rectangle()
                        .fill(isUrgent ? LadderColors.error : LadderColors.primaryContainer)
                        .frame(width: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 2))

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(collegeName)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(deadline.deadlineType)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        HStack(spacing: LadderSpacing.sm) {
                            LadderTagChip(platform)
                            if isUrgent {
                                LadderTagChip("Urgent", icon: "exclamationmark.triangle")
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(LadderSpacing.md)
            }
            .buttonStyle(.plain)

            // Add to Calendar button
            Button {
                addDeadlineToCalendar(deadline)
            } label: {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 12))
                    Text("Add to Calendar")
                        .font(LadderTypography.labelSmall)
                }
                .foregroundStyle(LadderColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.15))
            }
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Calendar Integration

    private func addDeadlineToCalendar(_ deadline: CollegeDeadlineModel) {
        guard let date = deadline.date else { return }
        let collegeName = deadline.college?.name ?? "Unknown College"
        let title = "\(collegeName) - \(deadline.deadlineType)"
        let platform = deadline.applicationPlatforms.first ?? "Direct"

        Task {
            let manager = CalendarManager.shared
            let success = await manager.addDeadline(
                title: title,
                date: date,
                notes: "Platform: \(platform)\nAdded from Ladder"
            )
            await MainActor.run {
                if success {
                    calendarAlert = .added(title)
                } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                    calendarAlert = .noAccess
                } else {
                    calendarAlert = .alreadyExists(title)
                }
            }
        }
    }

    // MARK: - Data Helpers

    private func deadlinesForMonth(_ month: Int) -> [CollegeDeadlineModel] {
        deadlines
            .filter { deadline in
                guard let date = deadline.date else { return false }
                return Calendar.current.component(.month, from: date) == month
            }
            .sorted { a, b in
                (a.date ?? .distantFuture) < (b.date ?? .distantFuture)
            }
    }
}

#Preview {
    NavigationStack {
        DeadlinesCalendarView()
            .environment(AppCoordinator())
    }
}
