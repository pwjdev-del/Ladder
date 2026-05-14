import Foundation

// D-003: SIA isolation error types.
// Every StudentContextBuilder.build call asserts JWT uid == requested studentId.
// Mismatches throw here; callers must surface "please log out and back in" to the user.

enum SiaIsolationError: Error, Equatable {
    /// The authenticated user's JWT uid does not match the studentId passed to build().
    case contextMismatch(expected: String, actual: String)
    /// No active authenticated session found; cannot verify identity.
    case noActiveSession
    /// A tenant ID is required for this operation but none is available in TenantContext.
    case tenantUnavailable
    /// The caller's JWT role is not counselor or admin — defence-in-depth guard (D-003).
    case roleNotCounselor(actual: String)

    var localizedDescription: String {
        switch self {
        case let .contextMismatch(expected, actual):
            return "SIA isolation violation: requested context for \(expected) but authenticated as \(actual)."
        case .noActiveSession:
            return "SIA isolation: no active session. Please log out and back in."
        case .tenantUnavailable:
            return "SIA isolation: no tenant context found. Please contact your school administrator."
        case let .roleNotCounselor(actual):
            return "SIA isolation: counselor surface requires role counselor or admin, got \(actual)."
        }
    }
}
