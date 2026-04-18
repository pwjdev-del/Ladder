import Foundation
import UserNotifications

// MARK: - Push Notification Manager
// Handles notification permission and scheduling deadline reminders

@MainActor
@Observable
final class PushNotificationManager {

    static let shared = PushNotificationManager()

    var isAuthorized = false
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    /// Request notification permission from the user
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            print("[PushNotificationManager] Permission request failed: \(error)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Deadline Reminders

    /// Schedule reminders for a deadline: 3 days before, 1 day before, and day-of
    func scheduleDeadlineReminder(title: String, date: Date, collegeId: String) {
        let calendar = Calendar.current

        // 3 days before
        if let threeDaysBefore = calendar.date(byAdding: .day, value: -3, to: date),
           threeDaysBefore > Date() {
            scheduleNotification(
                id: "deadline-3d-\(collegeId)-\(date.timeIntervalSince1970)",
                title: "Deadline in 3 Days",
                body: title,
                date: threeDaysBefore,
                categoryId: "DEADLINE_REMINDER"
            )
        }

        // 1 day before
        if let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: date),
           oneDayBefore > Date() {
            scheduleNotification(
                id: "deadline-1d-\(collegeId)-\(date.timeIntervalSince1970)",
                title: "Deadline Tomorrow",
                body: title,
                date: oneDayBefore,
                categoryId: "DEADLINE_URGENT"
            )
        }

        // Day of
        if date > Date() {
            scheduleNotification(
                id: "deadline-0d-\(collegeId)-\(date.timeIntervalSince1970)",
                title: "Deadline Today",
                body: title,
                date: date,
                categoryId: "DEADLINE_URGENT"
            )
        }
    }

    /// Cancel all pending notifications
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    /// Cancel notifications for a specific college deadline
    func cancelDeadlineReminders(collegeId: String) {
        center.getPendingNotificationRequests { [weak self] requests in
            let idsToRemove = requests
                .filter { $0.identifier.contains(collegeId) }
                .map(\.identifier)
            self?.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    // MARK: - Private Helpers

    private func scheduleNotification(
        id: String,
        title: String,
        body: String,
        date: Date,
        categoryId: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryId

        // Schedule at 9 AM on the target date
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
                print("[PushNotificationManager] Failed to schedule '\(id)': \(error)")
            }
        }
    }
}
