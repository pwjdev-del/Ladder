import Foundation

// MARK: - AI Rate Limiter
// Wraps FeatureGateManager's rate limiting with a clean API
// Use withRateLimit {} to guard any AI request

@Observable
final class AIRateLimiter {
    static let shared = AIRateLimiter()
    private init() {}

    // Check if user can make another AI request
    func canMakeRequest() -> Bool {
        return FeatureGateManager.shared.remainingAIRequests > 0
    }

    // Record a request was made
    func recordRequest() {
        FeatureGateManager.shared.recordAIRequest()
    }

    // Get remaining requests
    var remaining: Int {
        FeatureGateManager.shared.remainingAIRequests
    }

    // Get a user-friendly message when rate limited
    var rateLimitMessage: String {
        "You've used all \(FeatureGateManager.shared.aiDailyLimit) AI requests for today. They reset at midnight."
    }

    // Wrapper that checks rate limit before executing
    func withRateLimit<T>(action: () async throws -> T) async throws -> T {
        guard canMakeRequest() else {
            throw AIRateLimitError.dailyLimitReached
        }
        recordRequest()
        return try await action()
    }

    enum AIRateLimitError: LocalizedError {
        case dailyLimitReached
        var errorDescription: String? {
            "You've reached your daily AI request limit. Try again tomorrow."
        }
    }
}
