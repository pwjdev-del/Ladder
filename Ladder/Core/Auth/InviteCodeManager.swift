import SwiftUI

// MARK: - Invite Code Manager
// Handles parent↔student linking via 6-digit alphanumeric invite codes

@Observable
final class InviteCodeManager {

    var generatedCode: String?
    var isLoading = false
    var errorMessage: String?
    var codeExpirationDate: Date?

    // Characters excluding I/O/0/1 to avoid visual confusion
    private let allowedCharacters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

    // MARK: - Generate Code

    /// Generate a 6-digit alphanumeric invite code
    func generateInviteCode() -> String {
        let code = String((0..<6).map { _ in allowedCharacters.randomElement()! })
        generatedCode = code
        codeExpirationDate = Calendar.current.date(byAdding: .hour, value: 48, to: Date())
        return code
    }

    // MARK: - Validate Code

    /// Validate an entered invite code
    /// - Parameter code: The 6-character code entered by the parent
    /// - Returns: Whether the code is valid
    func validateCode(_ code: String) async -> Bool {
        // TODO: Replace with AWS API call to check code against RDS
        // For now, accept any 6-char alphanumeric code
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))

        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return trimmed.count == 6
    }

    // MARK: - Link Parent to Student

    /// Link a parent account to a student via invite code
    /// - Parameter code: The validated invite code
    func linkParentToStudent(code: String) async throws {
        // TODO: Create parent_link entry in RDS via Lambda
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try await Task.sleep(for: .seconds(1))
        // Simulated success — in production this calls AWS Lambda
    }

    // MARK: - Helpers

    /// Time remaining before the current code expires
    var timeRemainingString: String? {
        guard let expiration = codeExpirationDate else { return nil }
        let remaining = expiration.timeIntervalSince(Date())
        guard remaining > 0 else { return "Expired" }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "\(hours)h \(minutes)m remaining"
    }

    /// Whether the current code has expired
    var isCodeExpired: Bool {
        guard let expiration = codeExpirationDate else { return true }
        return Date() >= expiration
    }
}
