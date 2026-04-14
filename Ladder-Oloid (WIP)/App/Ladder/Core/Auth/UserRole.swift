import Foundation

enum UserRole: String, CaseIterable, Codable {
    case student = "Student"
    case parent = "Parent"
    case counselor = "Counselor"
    case schoolAdmin = "School Admin"

    var icon: String {
        switch self {
        case .student: "graduationcap.fill"
        case .parent: "person.2.fill"
        case .counselor: "person.text.rectangle.fill"
        case .schoolAdmin: "building.columns.fill"
        }
    }

    var description: String {
        switch self {
        case .student: "I'm a high school student planning for college"
        case .parent: "I'm a parent supporting my child"
        case .counselor: "I'm a school counselor managing students"
        case .schoolAdmin: "I'm a school administrator or principal"
        }
    }
}
