import Foundation
import SwiftData

// MARK: - School Club Model
// Represents a club offered by the school

@Model
final class SchoolClubModel {
    var name: String
    var clubDescription: String?
    var meetingDay: String?
    var meetingTime: String?
    var location: String?
    var advisor: String?
    var category: String
    var isActive: Bool
    var tryoutDate: Date?
    var createdAt: Date

    init(name: String, category: String) {
        self.name = name
        self.category = category
        self.isActive = true
        self.createdAt = Date()
    }

    static var allCategories: [String] {
        ["Academic", "Service", "Arts", "STEM", "Sports", "Cultural", "Other"]
    }

    static var categoryIcons: [String: String] {
        [
            "Academic": "book.fill",
            "Service": "heart.fill",
            "Arts": "paintbrush.fill",
            "STEM": "flask.fill",
            "Sports": "figure.run",
            "Cultural": "globe.americas.fill",
            "Other": "star.fill"
        ]
    }
}

// MARK: - School Sport Model
// Represents a sport/athletics program offered by the school

@Model
final class SchoolSportModel {
    var name: String
    var season: String
    var gender: String
    var level: String
    var coach: String?
    var tryoutDate: Date?
    var firstGameDate: Date?
    var practiceSchedule: String?
    var location: String?
    var isActive: Bool
    var createdAt: Date

    init(name: String, season: String, gender: String, level: String) {
        self.name = name
        self.season = season
        self.gender = gender
        self.level = level
        self.isActive = true
        self.createdAt = Date()
    }

    static var allSeasons: [String] {
        ["Fall", "Winter", "Spring"]
    }

    static var allGenders: [String] {
        ["Boys", "Girls", "Co-ed"]
    }

    static var allLevels: [String] {
        ["Varsity", "JV", "Freshman"]
    }

    static var seasonIcons: [String: String] {
        [
            "Fall": "leaf.fill",
            "Winter": "snowflake",
            "Spring": "flower.fill"
        ]
    }
}

// MARK: - School Calendar Event Model
// Represents a school calendar event (holidays, exams, registration, etc.)

@Model
final class SchoolCalendarEventModel {
    var title: String
    var eventDate: Date
    var endDate: Date?
    var eventType: String
    var eventDescription: String?
    var isAllDay: Bool
    var createdAt: Date

    init(title: String, eventDate: Date, eventType: String) {
        self.title = title
        self.eventDate = eventDate
        self.eventType = eventType
        self.isAllDay = true
        self.createdAt = Date()
    }

    static var allEventTypes: [String] {
        ["Holiday", "Exam", "Registration", "Sports", "Club", "School Event"]
    }

    static var eventTypeIcons: [String: String] {
        [
            "Holiday": "gift.fill",
            "Exam": "pencil.and.list.clipboard",
            "Registration": "doc.text.fill",
            "Sports": "figure.run",
            "Club": "person.3.fill",
            "School Event": "star.fill"
        ]
    }

    static var eventTypeColors: [String: String] {
        [
            "Holiday": "green",
            "Exam": "red",
            "Registration": "blue",
            "Sports": "orange",
            "Club": "purple",
            "School Event": "teal"
        ]
    }
}
