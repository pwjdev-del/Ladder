import SwiftUI

// MARK: - School Code Manager
// Handles school↔counselor↔student linking via school codes

@Observable
final class SchoolCodeManager {

    var schoolCode: String?
    var schoolName: String?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Generate School Code

    /// Generate a school code from the school name: prefix + year (e.g., "PNCV-2026")
    /// - Parameter schoolName: The full school name
    /// - Returns: A formatted school code
    func generateSchoolCode(schoolName: String) -> String {
        let cleaned = schoolName
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
        let prefix = String(cleaned.prefix(4))
        let year = Calendar.current.component(.year, from: Date())
        let code = "\(prefix)-\(year)"
        self.schoolCode = code
        self.schoolName = schoolName
        return code
    }

    // MARK: - Validate School Code

    /// Validate a school code against the backend
    /// - Parameter code: The school code entered by a counselor or student
    /// - Returns: A tuple of validity and the associated school name
    func validateSchoolCode(_ code: String) async -> (valid: Bool, schoolName: String?) {
        // TODO: Replace with AWS API call to check code against RDS
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(for: .seconds(0.5))

        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let isValid = trimmed.count >= 6

        if isValid {
            return (true, "Sample School")
        } else {
            errorMessage = "Invalid school code. Please check and try again."
            return (false, nil)
        }
    }

    // MARK: - Join School

    /// Join a school as either a counselor or student
    /// - Parameters:
    ///   - code: The validated school code
    ///   - role: Either "counselor" or "student"
    func joinSchool(code: String, role: String) async throws {
        // TODO: Create school_counselors or school_students entry via Lambda
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try await Task.sleep(for: .seconds(0.8))
        // Simulated success — in production this calls AWS Lambda
    }

    // MARK: - Reset

    func reset() {
        schoolCode = nil
        schoolName = nil
        errorMessage = nil
        isLoading = false
    }
}
