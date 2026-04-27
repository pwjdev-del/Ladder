import Foundation
import SwiftData

// MARK: - College Visit (for Visit Planner)

@Model
final class CollegeVisitModel {
    var collegeId: String
    var collegeName: String
    var visitDate: Date?
    var tourTime: Date?
    var notes: String?
    var hasVisited: Bool = false
    var createdAt: Date

    init(collegeId: String, collegeName: String) {
        self.collegeId = collegeId
        self.collegeName = collegeName
        self.createdAt = Date()
    }
}
