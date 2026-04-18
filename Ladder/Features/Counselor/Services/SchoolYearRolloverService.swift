import Foundation
import SwiftData

// MARK: - School Year Rollover Service
// Handles annual grade promotion and graduation archiving

@Observable
final class SchoolYearRolloverService {

    // MARK: - Promote Grades

    /// Promote all students' grades by one year.
    /// Students at grade 12 are flagged for graduation archival.
    @MainActor
    func promoteGrades(context: ModelContext) {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        guard let students = try? context.fetch(descriptor) else { return }

        for student in students {
            let grade = student.grade
            if grade >= 12 {
                // Archive graduated students
                // TODO: Set archived flag when model supports it
            } else {
                student.grade = grade + 1
            }
        }
        try? context.save()
    }

    // MARK: - Rollover Check

    /// Returns true if the current month is August, the typical rollover window.
    var isRolloverMonth: Bool {
        Calendar.current.component(.month, from: Date()) == 8
    }

    // MARK: - Rollover Summary

    /// Returns a summary of what the rollover would do without actually performing it.
    func previewRollover(context: ModelContext) -> RolloverPreview {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        guard let students = try? context.fetch(descriptor) else {
            return RolloverPreview(totalStudents: 0, graduating: 0, promoting: 0)
        }

        let graduating = students.filter { $0.grade >= 12 }.count
        let promoting = students.filter { $0.grade < 12 }.count

        return RolloverPreview(
            totalStudents: students.count,
            graduating: graduating,
            promoting: promoting
        )
    }
}

// MARK: - Rollover Preview

struct RolloverPreview {
    let totalStudents: Int
    let graduating: Int
    let promoting: Int
}
