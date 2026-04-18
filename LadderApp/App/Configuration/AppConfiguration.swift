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
}
