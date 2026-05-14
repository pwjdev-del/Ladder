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

    // The Supabase publishable anon key is safe to ship in the iOS binary —
    // by design it grants ONLY the access RLS policies allow, and Apple makes
    // any iOS binary trivially downloadable + decryptable on a jailbroken
    // device. Real security comes from JWT-derived auth + RLS, NOT from
    // hiding this key. Same xcconfig + auto-Info.plist filtering issues that
    // affect SUPABASE_HOST also affect this key, so hardcoded fallback.
    private static let supabaseAnonKeyFallback = "sb_publishable_kXZvRLZgvh2qL_jqfSjtHg_ZdnjrFyX"

    static var supabaseAnonKey: String {
        let raw = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
        return raw.isEmpty ? supabaseAnonKeyFallback : raw
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

    /// Known placeholder / template values that must never reach production.
    /// Extend this list whenever a new env template is added.
    private static let placeholderURLs: Set<String> = [
        "https://your-project.supabase.co",
        "https://example.supabase.co",
        "https://<your-project-id>.supabase.co",
        "https://YOUR_PROJECT.supabase.co",
    ]

    private static let placeholderAnonKeys: Set<String> = [
        "your-anon-key",
        "<your-anon-key>",
        "YOUR_ANON_KEY",
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder",
    ]

    /// Call from LadderApp.init() before any other work.
    ///
    /// S2#2 fix: replaced `#if !DEBUG` with a runtime XCTest-environment guard so
    /// that the preflight runs in ALL non-test launch contexts — including Debug,
    /// TestFlight/AdHoc, and Release. `#if !DEBUG` was unsafe because a
    /// misconfigured scheme can pass `-D DEBUG` into a TestFlight archive, causing
    /// the preflight to silently skip and ship placeholder config to testers.
    ///
    /// The only exemption is XCTest runs, where the host app launches with real-device
    /// env vars stripped and every value would be blank, causing spurious failures.
    static func preflightOrCrash() {
        // Skip during unit/UI test runs; XCTest injects this path when active.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }

        let url = supabaseURL
        if url.isEmpty {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_URL is blank. " +
                "Add SUPABASE_URL to Config/Secrets.xcconfig before archiving."
            )
        }
        if placeholderURLs.contains(url) {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_URL is a placeholder (\(url)). " +
                "Replace it with the real Supabase project URL before archiving."
            )
        }
        if !url.hasPrefix("https://") {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_URL does not start with https://. " +
                "Value: \(url)"
            )
        }

        let key = supabaseAnonKey
        if key.isEmpty {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_ANON_KEY is blank. " +
                "Add SUPABASE_ANON_KEY to Config/Secrets.xcconfig before archiving."
            )
        }
        if placeholderAnonKeys.contains(key) {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_ANON_KEY is a placeholder (\(key)). " +
                "Replace it with the real Supabase anon key before archiving."
            )
        }
    }
}
