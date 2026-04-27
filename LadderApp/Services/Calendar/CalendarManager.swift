import EventKit
import Foundation

// MARK: - Calendar Manager
// EventKit integration for adding college deadlines to the system calendar

@MainActor
@Observable
final class CalendarManager {

    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Request Access

    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                print("[CalendarManager] Access request error: \(error)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    // MARK: - Add Deadline to Calendar

    /// Adds a deadline event to the default calendar.
    /// Returns true if the event was created successfully.
    @discardableResult
    func addDeadline(
        title: String,
        date: Date,
        notes: String? = nil,
        location: String? = nil
    ) async -> Bool {
        let hasAccess = await ensureAccess()
        guard hasAccess else { return false }

        // Check for duplicates
        if isDeadlineAlreadyAdded(title: title, date: date) {
            print("[CalendarManager] Deadline already exists: \(title)")
            return false
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = date
        event.isAllDay = true
        event.notes = notes
        event.location = location
        event.calendar = eventStore.defaultCalendarForNewEvents

        // Add a reminder alarm 1 day before
        let alarm = EKAlarm(relativeOffset: -86400) // 24 hours before
        event.addAlarm(alarm)

        // Add a second alarm 1 week before
        let weekAlarm = EKAlarm(relativeOffset: -604800) // 7 days before
        event.addAlarm(weekAlarm)

        do {
            try eventStore.save(event, span: .thisEvent)
            print("[CalendarManager] Added deadline: \(title) on \(date)")
            return true
        } catch {
            print("[CalendarManager] Error saving event: \(error)")
            return false
        }
    }

    // MARK: - Check if Deadline Already Added

    func isDeadlineAlreadyAdded(title: String, date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)
        return events.contains { $0.title == title }
    }

    // MARK: - Build Date from Components

    static func dateFrom(month: Int, day: Int, year: Int = 2026) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }

    // MARK: - Private

    private func ensureAccess() async -> Bool {
        switch authorizationStatus {
        case .fullAccess, .authorized:
            return true
        case .notDetermined:
            return await requestAccess()
        default:
            return false
        }
    }
}
