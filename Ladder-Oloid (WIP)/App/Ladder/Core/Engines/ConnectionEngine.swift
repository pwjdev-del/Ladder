import Foundation
import SwiftData

/// Cascades changes when a student updates a foundational field.
/// Career path change → activity suggestions refresh + match recalculation flag.
/// GPA/SAT change → match scores recompute on next view appearance.
@Observable
final class ConnectionEngine {
    static let shared = ConnectionEngine()

    /// Last known career path — used to detect changes
    private(set) var lastCareerPath: String?
    private(set) var lastGPA: Double?
    private(set) var lastSAT: Int?

    /// Triggered when career path changes
    var onCareerChange: ((String) -> Void)?

    /// Triggered when stats change (GPA, SAT, ACT)
    var onStatsChange: (() -> Void)?

    func observe(profile: StudentProfileModel?) {
        guard let p = profile else { return }
        if p.careerPath != lastCareerPath {
            lastCareerPath = p.careerPath
            if let path = p.careerPath { onCareerChange?(path) }
        }
        if p.gpa != lastGPA || p.satScore != lastSAT {
            lastGPA = p.gpa
            lastSAT = p.satScore
            onStatsChange?()
        }
    }

    func notifyCareerChanged(to path: String) {
        lastCareerPath = path
        onCareerChange?(path)
    }
}
