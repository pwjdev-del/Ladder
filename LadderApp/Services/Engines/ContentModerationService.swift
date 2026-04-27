import Foundation

// MARK: - Content Moderation Service
// Client-side content moderation for messaging features
// Flags concerning content (self-harm, violence) and explicit content
// TODO: Replace with AWS Comprehend for production-grade moderation

@Observable
final class ContentModerationService {
    static let shared = ContentModerationService()
    private init() {}

    // Keywords that should be flagged
    private let concerningKeywords = [
        "kill", "suicide", "harm", "hurt myself", "end my life",
        "gun", "weapon", "drugs", "alcohol",
        "hate", "threat", "bully"
    ]

    private let explicitKeywords = [
        // Basic list — TODO: Use AWS Comprehend for production
        "profanity_placeholder" // Replace with real list
    ]

    struct ModerationResult {
        let isAllowed: Bool
        let flags: [Flag]

        enum Flag {
            case concerning  // Self-harm, violence — needs intervention
            case explicit    // Profanity, inappropriate content
            case clean       // No issues
        }
    }

    // Check message before sending
    func moderate(_ message: String) -> ModerationResult {
        let lower = message.lowercased()
        var flags: [ModerationResult.Flag] = []

        // Check for concerning content (highest priority)
        for keyword in concerningKeywords {
            if lower.contains(keyword) {
                flags.append(.concerning)
                break
            }
        }

        // Check for explicit content
        for keyword in explicitKeywords {
            if lower.contains(keyword) {
                flags.append(.explicit)
                break
            }
        }

        if flags.isEmpty {
            flags.append(.clean)
        }

        // TODO: In production, use AWS Comprehend for better moderation
        // let result = try await comprehendClient.detectSentiment(text: message)

        return ModerationResult(
            isAllowed: !flags.contains(.explicit),
            flags: flags
        )
    }

    // Report a message
    func reportMessage(messageId: String, reason: String) {
        // TODO: Send report to backend via AppSync
        UserDefaults.standard.set(true, forKey: "reported_\(messageId)")
    }
}
