import Foundation

// MARK: - Feature Gate Manager
// Controls feature visibility based on subscription tier
// Supports free, school_basic, and school_premium tiers

@Observable
final class FeatureGateManager {
    static let shared = FeatureGateManager()

    enum Tier: String {
        case free = "free"
        case schoolBasic = "school_basic"
        case schoolPremium = "school_premium"
    }

    enum Feature {
        // Free tier - core features
        case collegeSearch, basicChecklist, careerQuiz, gpaTracker, activityLog
        // Free tier - limited AI
        case aiAdvisor
        // School Basic - student + counselor features
        case classScheduling, counselorDashboard, autoId, bulkImport, parentAccess, messaging
        // School Premium - district + advanced
        case districtAnalytics, unlimitedAI, pdfExport, dataExport, parentPortal, peerComparison
    }

    var currentTier: Tier = .free

    // MARK: - Feature Availability

    /// Check if a feature is available for the current subscription tier
    func isAvailable(_ feature: Feature) -> Bool {
        switch feature {
        // Free tier — core features
        case .collegeSearch, .basicChecklist, .careerQuiz, .gpaTracker, .activityLog:
            return true

        // Free tier — limited AI
        case .aiAdvisor:
            return aiRequestsToday < aiDailyLimit

        // School Basic — all student + counselor features
        case .classScheduling, .counselorDashboard, .autoId, .bulkImport, .parentAccess, .messaging:
            return currentTier == .schoolBasic || currentTier == .schoolPremium

        // School Premium — district + advanced
        case .districtAnalytics, .unlimitedAI, .pdfExport, .dataExport, .parentPortal, .peerComparison:
            return currentTier == .schoolPremium
        }
    }

    // MARK: - AI Rate Limiting

    private var aiRequestsToday: Int {
        let key = "ai_requests_\(dateKey)"
        return UserDefaults.standard.integer(forKey: key)
    }

    var aiDailyLimit: Int {
        switch currentTier {
        case .free: return 5
        case .schoolBasic: return 50
        case .schoolPremium: return 999
        }
    }

    /// Record an AI request for rate limiting
    func recordAIRequest() {
        let key = "ai_requests_\(dateKey)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }

    /// Number of AI requests remaining today
    var remainingAIRequests: Int {
        max(0, aiDailyLimit - aiRequestsToday)
    }

    // MARK: - Helpers

    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
