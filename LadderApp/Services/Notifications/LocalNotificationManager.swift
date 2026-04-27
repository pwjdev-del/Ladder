import Foundation
import UserNotifications
import SwiftData

// MARK: - Local Notification Manager
// Schedules recurring reminders for SAT, FAFSA, applications, and Bright Futures milestones

@MainActor
@Observable
final class LocalNotificationManager {

    static let shared = LocalNotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - SAT Registration Reminders

    /// Schedule reminders for upcoming SAT registration deadlines
    func scheduleSATRegistrationReminder(testDate: Date, registrationDeadline: Date) {
        let pushManager = PushNotificationManager.shared
        let testDateString = formatted(date: testDate)

        pushManager.scheduleDeadlineReminder(
            title: "SAT Registration closes for the \(testDateString) test",
            date: registrationDeadline,
            collegeId: "sat-\(testDate.timeIntervalSince1970)"
        )
    }

    // MARK: - FAFSA Deadline Reminders

    /// Schedule FAFSA filing reminders (opens Oct 1, priority deadlines vary by state)
    func scheduleFAFSAReminders(priorityDeadline: Date) {
        let pushManager = PushNotificationManager.shared

        pushManager.scheduleDeadlineReminder(
            title: "FAFSA priority filing deadline — submit early for maximum aid",
            date: priorityDeadline,
            collegeId: "fafsa-priority"
        )

        // Also schedule an "opens" reminder for October 1 of the current academic year
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let fafsaYear = currentMonth >= 10 ? currentYear + 1 : currentYear

        var openDateComponents = DateComponents()
        openDateComponents.year = fafsaYear - 1
        openDateComponents.month = 10
        openDateComponents.day = 1

        if let fafsaOpenDate = calendar.date(from: openDateComponents),
           fafsaOpenDate > Date() {
            scheduleOneTimeNotification(
                id: "fafsa-opens-\(fafsaYear)",
                title: "FAFSA is Now Open",
                body: "The \(fafsaYear - 1)-\(fafsaYear) FAFSA is available. File early for the best financial aid packages.",
                date: fafsaOpenDate
            )
        }
    }

    // MARK: - Application Deadline Reminders

    /// Schedule reminders for all tracked college application deadlines from SwiftData
    func scheduleApplicationDeadlines(context: ModelContext) {
        let descriptor = FetchDescriptor<CollegeDeadlineModel>()

        guard let deadlines = try? context.fetch(descriptor) else { return }

        let pushManager = PushNotificationManager.shared
        let now = Date()

        for deadline in deadlines {
            guard let date = deadline.date, date > now else { continue }

            let collegeName = deadline.college?.name ?? "College"
            let title = "\(collegeName) \(deadline.deadlineType) deadline"
            let collegeId = (deadline.college?.name ?? "unknown").lowercased()
                .replacingOccurrences(of: " ", with: "-")

            pushManager.scheduleDeadlineReminder(
                title: title,
                date: date,
                collegeId: "app-\(collegeId)-\(deadline.deadlineType.lowercased().replacingOccurrences(of: " ", with: "-"))"
            )
        }
    }

    // MARK: - Bright Futures Hour Milestones

    /// Schedule encouraging notifications when students hit Bright Futures volunteer hour milestones
    /// FAS requires 100 hours; FMS requires 75 hours
    func scheduleBrightFuturesMilestoneCheck(currentHours: Double) {
        let milestones: [(hours: Double, message: String)] = [
            (25, "You have logged 25 volunteer hours — 25% of the way to Bright Futures FMS (75 hours)"),
            (50, "50 volunteer hours completed — halfway to Bright Futures FAS (100 hours)"),
            (75, "75 hours reached — you qualify for Bright Futures Florida Medallion Scholars"),
            (90, "Just 10 more hours to hit 100 — Bright Futures Florida Academic Scholars is within reach"),
            (100, "100 volunteer hours — you meet the Bright Futures FAS service requirement")
        ]

        // Find the next milestone the student has not yet reached
        guard let nextMilestone = milestones.first(where: { $0.hours > currentHours }) else {
            return
        }

        // Schedule a motivational notification for tomorrow at 10 AM
        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date().addingTimeInterval(86400)
        )
        components.hour = 10
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Bright Futures Progress"
        content.body = nextMilestone.message
        content.sound = .default
        content.categoryIdentifier = "BRIGHT_FUTURES"

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "bf-milestone-\(Int(nextMilestone.hours))",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("[LocalNotificationManager] Failed to schedule BF milestone: \(error)")
            }
        }
    }

    // MARK: - Weekly Checklist Nudge

    /// Schedule a weekly reminder to check the activity checklist (every Sunday at 6 PM)
    func scheduleWeeklyChecklistNudge() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Check-In"
        content.body = "Review your college prep checklist and plan your week ahead."
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_NUDGE"

        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "weekly-checklist-nudge",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("[LocalNotificationManager] Failed to schedule weekly nudge: \(error)")
            }
        }
    }

    // MARK: - Badge Management

    /// Update the app badge count to reflect pending tasks
    func updateBadgeCount(to count: Int) {
        center.setBadgeCount(count) { error in
            if let error {
                print("[LocalNotificationManager] Failed to set badge: \(error)")
            }
        }
    }

    /// Clear the app badge
    func clearBadge() {
        updateBadgeCount(to: 0)
    }

    /// Calculate badge count from incomplete checklist items
    func refreshBadgeFromChecklist(context: ModelContext) {
        let descriptor = FetchDescriptor<ChecklistItemModel>()
        guard let items = try? context.fetch(descriptor) else { return }

        // Count overdue items (due date is in the past and not completed)
        let now = Date()
        let overdueCount = items.filter { item in
            item.status != "completed" && (item.dueDate ?? .distantFuture) < now
        }.count

        updateBadgeCount(to: overdueCount)
    }

    // MARK: - Cancel Helpers

    /// Remove all scheduled local notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        clearBadge()
    }

    /// Remove notifications matching a specific prefix
    func cancelNotifications(withPrefix prefix: String) {
        center.getPendingNotificationRequests { [weak self] requests in
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map(\.identifier)
            self?.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    // MARK: - Private Helpers

    private func scheduleOneTimeNotification(
        id: String,
        title: String,
        body: String,
        date: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: date
        )
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("[LocalNotificationManager] Failed to schedule '\(id)': \(error)")
            }
        }
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
