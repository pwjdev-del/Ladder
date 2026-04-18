import Foundation
import SwiftData

// MARK: - Counselor Profile Model

@Model
final class CounselorProfileModel {
    var name: String
    var schoolName: String
    var schoolId: String?
    var specialty: String?
    var bio: String?
    var hourlyRate: Int?
    var rating: Double?
    var reviewCount: Int = 0
    var studentIds: [String] = []
    var isFreelance: Bool = false
    var imageURL: String?
    var createdAt: Date

    init(name: String, schoolName: String) {
        self.name = name
        self.schoolName = schoolName
        self.createdAt = Date()
    }
}
