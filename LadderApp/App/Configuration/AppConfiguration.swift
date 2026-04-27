import Foundation

// MARK: - App Configuration
// Reads values from xcconfig → Info.plist at build time

enum AppConfiguration {
    static var supabaseURL: String {
        Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? "https://your-project.supabase.co"
    }

    static var supabaseAnonKey: String {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }

    static var geminiProxyURL: String {
        Bundle.main.infoDictionary?["GEMINI_PROXY_URL"] as? String
            ?? "\(supabaseURL)/functions/v1/gemini-proxy"
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
