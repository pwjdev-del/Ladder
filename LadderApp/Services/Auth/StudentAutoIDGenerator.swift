import Foundation

// MARK: - Student Credential
// Auto-generated login credentials from student name + birthdate

struct StudentCredential {
    let loginId: String      // e.g., "jsmith0415"
    let password: String     // e.g., "john10!"
    let studentName: String
    let dateOfBirth: Date
    let grade: Int
}

// MARK: - Student Auto ID Generator
// Generates deterministic login credentials for counselor-created student accounts

struct StudentAutoIDGenerator {

    // MARK: - Login ID

    /// Generate login ID: first initial + last name + birth month + birth day
    /// Example: John Smith, born April 15 → "jsmith0415"
    static func generateLoginId(firstName: String, lastName: String, dob: Date) -> String {
        let first = firstName.prefix(1).lowercased()
        let last = lastName.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "-", with: "")
        let cal = Calendar.current
        let month = String(format: "%02d", cal.component(.month, from: dob))
        let day = String(format: "%02d", cal.component(.day, from: dob))
        return "\(first)\(last)\(month)\(day)"
    }

    // MARK: - Password

    /// Generate password: first name (lowercase) + birth year last 2 digits + "!"
    /// Example: John, born 2010 → "john10!"
    static func generatePassword(firstName: String, dob: Date) -> String {
        let name = firstName.lowercased()
        let year = Calendar.current.component(.year, from: dob) % 100
        return "\(name)\(year)!"
    }

    // MARK: - Single Generation

    /// Generate a full credential for one student
    static func generate(firstName: String, lastName: String, dob: Date, grade: Int) -> StudentCredential {
        return StudentCredential(
            loginId: generateLoginId(firstName: firstName, lastName: lastName, dob: dob),
            password: generatePassword(firstName: firstName, dob: dob),
            studentName: "\(firstName) \(lastName)",
            dateOfBirth: dob,
            grade: grade
        )
    }

    // MARK: - Bulk Generation

    /// Bulk generate credentials with duplicate login ID detection.
    /// Appends a suffix (-2, -3, etc.) when collisions occur.
    static func bulkGenerate(students: [(firstName: String, lastName: String, dob: Date, grade: Int)]) -> [StudentCredential] {
        var usedIds: Set<String> = []
        var results: [StudentCredential] = []

        for student in students {
            let credential = generate(
                firstName: student.firstName,
                lastName: student.lastName,
                dob: student.dob,
                grade: student.grade
            )

            var finalId = credential.loginId
            var counter = 2
            while usedIds.contains(finalId) {
                finalId = "\(credential.loginId)-\(counter)"
                counter += 1
            }
            usedIds.insert(finalId)

            if finalId != credential.loginId {
                results.append(StudentCredential(
                    loginId: finalId,
                    password: credential.password,
                    studentName: credential.studentName,
                    dateOfBirth: credential.dateOfBirth,
                    grade: credential.grade
                ))
            } else {
                results.append(credential)
            }
        }

        return results
    }
}
