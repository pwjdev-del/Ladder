import Foundation

// MARK: - App Configuration
// Reads values from xcconfig → Info.plist at build time

enum AppConfiguration {
    // The Supabase project host is hardcoded here because:
    //   1) xcconfig treats `//` as a comment, eating `https://` URLs.
    //   2) Xcode's auto-Info.plist generation silently drops custom
    //      INFOPLIST_KEY_* keys not in Apple's known-key list.
    // The host is project-id-only (no secret); the anon key + service role
    // stay in xcconfig / .env. If the project moves, update this constant
    // and rebuild. Future enhancement: code-gen this from .env at build time.
    private static let supabaseHostFallback = "seicofzlgwjqkggscvao.supabase.co"

    static var supabaseURL: String {
        // Allow override via Info.plist for staging / preview environments
        // where the build script CAN produce a clean Info.plist with custom keys.
        let raw = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        if raw.hasPrefix("https://") {
            return raw
        }
        if let host = Bundle.main.infoDictionary?["SUPABASE_HOST"] as? String, !host.isEmpty {
            return "https://\(host)"
        }
        return "https://\(supabaseHostFallback)"
    }

    static var supabaseAnonKey: String {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }

    static var geminiProxyURL: String {
        let raw = Bundle.main.infoDictionary?["GEMINI_PROXY_URL"] as? String ?? ""
        if raw.hasPrefix("https://") {
            return raw
        }
        // Synthesize from host if the gemini URL wasn't explicitly set.
        return "\(supabaseURL)/functions/v1/ai-gateway"
    }

    static var collegeScorecardAPIKey: String {
        Bundle.main.infoDictionary?["COLLEGE_SCORECARD_API_KEY"] as? String ?? ""
    }

    // MARK: - Preflight

    /// Call from LadderApp.init(). In Release builds, crashes immediately if
    /// Supabase is still pointing at the placeholder project or the anon key
    /// is missing — far better than silently booting with a broken backend.
    /// Debug builds are intentionally exempt so local dev without Secrets.xcconfig works.
    static func preflightOrCrash() {
        #if !DEBUG
        if supabaseURL == "https://your-project.supabase.co" {
            preconditionFailure(
                """
                [AppConfiguration] Release build launched with placeholder Supabase URL. \
                Add SUPABASE_URL to Config/Secrets.xcconfig before shipping.
                """
            )
        }
        if supabaseAnonKey.isEmpty {
            preconditionFailure(
                """
                [AppConfiguration] Release build launched with empty SUPABASE_ANON_KEY. \
                Add SUPABASE_ANON_KEY to Config/Secrets.xcconfig before shipping.
                """
            )
        }
        #endif
    }
}
