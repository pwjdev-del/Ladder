import Foundation
import SwiftData

// MARK: - Essay Model
// Tracks supplemental essays per college application

@Model
final class EssayModel {
    var collegeId: String
    var collegeName: String
    var prompt: String
    var draft: String
    var wordLimit: Int
    var status: String  // Use EssayStatus enum rawValue
    var createdAt: Date
    var updatedAt: Date
    var versionId: Int = 1

    var wordCount: Int {
        draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? 0
            : draft.split(separator: " ").count
    }

    init(
        collegeId: String,
        collegeName: String,
        prompt: String,
        wordLimit: Int = 650
    ) {
        self.collegeId = collegeId
        self.collegeName = collegeName
        self.prompt = prompt
        self.draft = ""
        self.wordLimit = wordLimit
        self.status = "not_started"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Essay Status Helpers

extension EssayModel {

    var statusLabel: String {
        switch EssayState(rawValue: status) {
        case .notStarted: return "Not Started"
        case .drafting:   return "Drafting"
        case .reviewing:  return "Reviewing"
        case .complete:   return "Complete"
        case .none:
            Log.warn("Unknown EssayModel.status '\(self.status)'")
            return status.capitalized
        }
    }

    var isComplete: Bool { EssayState(rawValue: status) == .complete }

    /// Apply a new status if the transition is valid; returns true on success.
    @discardableResult
    func setState(_ new: EssayState) -> Bool {
        guard let current = EssayState(rawValue: status) else {
            status = new.rawValue
            updatedAt = Date()
            versionId &+= 1
            return true
        }
        guard EssayState.canTransition(from: current, to: new) else {
            Log.warn("Rejected essay transition \(current.rawValue) → \(new.rawValue)")
            return false
        }
        status = new.rawValue
        updatedAt = Date()
        versionId &+= 1
        return true
    }
}
