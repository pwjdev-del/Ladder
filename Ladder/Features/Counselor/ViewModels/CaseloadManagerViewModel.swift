import SwiftUI
import SwiftData
import Combine

// MARK: - Caseload Manager ViewModel

@Observable
final class CaseloadManagerViewModel {

    // MARK: - Filter & Sort

    enum SortOption: String, CaseIterable {
        case byName = "By Name"
        case byGrade = "By Grade"
        case urgency = "Urgency"
    }

    enum GradeFilter: String, CaseIterable {
        case all = "All"
        case grade9 = "Grade 9"
        case grade10 = "Grade 10"
        case grade11 = "Grade 11"
        case grade12 = "Grade 12"
        case atRisk = "At Risk"

        var gradeValue: Int? {
            switch self {
            case .grade9: return 9
            case .grade10: return 10
            case .grade11: return 11
            case .grade12: return 12
            default: return nil
            }
        }
    }

    var searchText: String = ""
    var selectedSort: SortOption = .byName
    var selectedFilter: GradeFilter = .all

    // MARK: - Student Status

    /// Determines a student's risk status based on their profile data.
    static func statusForStudent(_ student: StudentProfileModel) -> StudentStatus {
        let gpa = student.gpa ?? 0.0
        let hasScore = student.satScore != nil || student.actScore != nil

        if gpa < 2.5 { return .atRisk }
        if gpa < 3.0 || (!hasScore && student.grade >= 11) { return .needsAttention }
        return .onTrack
    }

    // MARK: - Filtering & Sorting

    func filteredStudents(from students: [StudentProfileModel]) -> [StudentProfileModel] {
        var result = students

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { student in
                student.fullName.lowercased().contains(query) ||
                (student.schoolName?.lowercased().contains(query) ?? false)
            }
        }

        // Apply grade filter
        switch selectedFilter {
        case .all:
            break
        case .atRisk:
            result = result.filter { Self.statusForStudent($0) == .atRisk }
        default:
            if let grade = selectedFilter.gradeValue {
                result = result.filter { $0.grade == grade }
            }
        }

        // Apply sort
        switch selectedSort {
        case .byName:
            result.sort { $0.lastName.lowercased() < $1.lastName.lowercased() }
        case .byGrade:
            result.sort { $0.grade > $1.grade }
        case .urgency:
            result.sort { lhs, rhs in
                Self.statusForStudent(lhs).sortOrder < Self.statusForStudent(rhs).sortOrder
            }
        }

        return result
    }

    /// Formats a relative date string for "last activity".
    static func lastActivityText(for student: StudentProfileModel) -> String {
        let days = Calendar.current.dateComponents([.day], from: student.createdAt, to: Date()).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days) days ago" }
        if days < 30 { return "\(days / 7) weeks ago" }
        return "\(days / 30) months ago"
    }
}

// MARK: - Student Status Enum

enum StudentStatus: String {
    case onTrack = "On Track"
    case needsAttention = "Needs Attention"
    case atRisk = "At Risk"

    var color: Color {
        switch self {
        case .onTrack: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .needsAttention: return Color(red: 0.9, green: 0.7, blue: 0.1)
        case .atRisk: return Color(red: 0.85, green: 0.2, blue: 0.2)
        }
    }

    var containerColor: Color {
        switch self {
        case .onTrack: return Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.15)
        case .needsAttention: return Color(red: 0.9, green: 0.7, blue: 0.1).opacity(0.15)
        case .atRisk: return Color(red: 0.85, green: 0.2, blue: 0.2).opacity(0.15)
        }
    }

    var sortOrder: Int {
        switch self {
        case .atRisk: return 0
        case .needsAttention: return 1
        case .onTrack: return 2
        }
    }
}
