import Foundation

// MARK: - App Configuration
// Reads values from xcconfig → Info.plist at build time.
//
// xcconfig treats `//` as a comment, so URLs with `https://` cannot be stored
// directly in xcconfig values. Two patterns handle this:
//   1. Host-only keys (SUPABASE_HOST) — AppConfiguration prepends "https://".
//   2. Function-path-only keys (AI_GATEWAY_PATH etc.) — AppConfiguration
//      assembles the full URL as: "https://" + SUPABASE_HOST + key value.
//
// NO source-code fallbacks for production values. Missing keys crash fast via
// preflightOrCrash(), called from LadderApp.init(). This prevents a
// misconfigured scheme from silently booting against a broken or stale backend.
// (Fixes S3-5 / B-16 — removed supabaseHostFallback and supabaseAnonKeyFallback.)

enum AppConfiguration {

    // MARK: - Supabase

    /// Full HTTPS URL for the Supabase project.
    /// Reads `SUPABASE_URL` from Info.plist first; if that value lacks a scheme,
    /// falls back to assembling from `SUPABASE_HOST`. Both keys are required —
    /// preflightOrCrash() will abort launch if neither yields a valid URL.
    static var supabaseURL: String {
        let raw = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        if raw.hasPrefix("https://") {
            return raw
        }
        if let host = Bundle.main.infoDictionary?["SUPABASE_HOST"] as? String,
           !host.isEmpty,
           !host.hasPrefix("your-project"),
           !host.hasPrefix("YOUR_PROJECT") {
            return "https://\(host)"
        }
        // No fallback — preflightOrCrash() will have caught this before any
        // client code runs. If somehow reached at runtime, fail loudly.
        fatalError(
            "[AppConfiguration] SUPABASE_URL / SUPABASE_HOST missing or placeholder. " +
            "Set them in Config/Secrets.xcconfig and ensure preflightOrCrash() is called " +
            "from LadderApp.init() before any service initialisation."
        )
    }

    /// Supabase publishable anon key. Safe to ship in the binary — security
    /// comes from JWT + RLS, not from hiding this key.
    static var supabaseAnonKey: String {
        let raw = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
        guard !raw.isEmpty else {
            fatalError(
                "[AppConfiguration] SUPABASE_ANON_KEY is missing. " +
                "Set it in Config/Secrets.xcconfig."
            )
        }
        return raw
    }

    // MARK: - AI Gateway

    /// Full HTTPS URL for the `ai-gateway` Edge Function.
    /// Reads `GEMINI_PROXY_URL` from Info.plist; if the value lacks `https://`
    /// (xcconfig limitation), synthesises from `supabaseURL`.
    /// Required — preflightOrCrash() validates this key.
    static var aiGatewayBaseURL: URL {
        if let raw = Bundle.main.infoDictionary?["GEMINI_PROXY_URL"] as? String,
           raw.hasPrefix("https://"),
           let url = URL(string: raw) {
            return url
        }
        // Synthesise from Supabase host. GEMINI_PROXY_URL in xcconfig holds
        // the scheme-less path; we prepend https:// here.
        guard let url = URL(string: "\(supabaseURL)/functions/v1/ai-gateway") else {
            fatalError(
                "[AppConfiguration] Could not construct ai-gateway URL from supabaseURL: \(supabaseURL)"
            )
        }
        return url
    }

    // MARK: - Feature Flags

    /// Full HTTPS URL for the `varun-validate` Edge Function.
    /// Reads `FLAGS_BASE_URL` from Info.plist; synthesises from `supabaseURL`
    /// if the key is absent or scheme-less.
    static var flagsBaseURL: URL {
        if let raw = Bundle.main.infoDictionary?["FLAGS_BASE_URL"] as? String,
           raw.hasPrefix("https://"),
           let url = URL(string: raw) {
            return url
        }
        guard let url = URL(string: "\(supabaseURL)/functions/v1/varun-validate") else {
            fatalError(
                "[AppConfiguration] Could not construct varun-validate URL from supabaseURL: \(supabaseURL)"
            )
        }
        return url
    }

    // MARK: - Audit

    /// Full HTTPS URL for the `audit-ingest` Edge Function.
    /// Reads `AUDIT_BASE_URL` from Info.plist; synthesises from `supabaseURL`
    /// if the key is absent or scheme-less.
    static var auditBaseURL: URL {
        if let raw = Bundle.main.infoDictionary?["AUDIT_BASE_URL"] as? String,
           raw.hasPrefix("https://"),
           let url = URL(string: raw) {
            return url
        }
        guard let url = URL(string: "\(supabaseURL)/functions/v1/audit-ingest") else {
            fatalError(
                "[AppConfiguration] Could not construct audit-ingest URL from supabaseURL: \(supabaseURL)"
            )
        }
        return url
    }

    // MARK: - Misc

    static var collegeScorecardAPIKey: String {
        Bundle.main.infoDictionary?["COLLEGE_SCORECARD_API_KEY"] as? String ?? ""
    }

    // MARK: - Preflight

    /// Known placeholder / template values that must never reach production.
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
        "REPLACE_ME",
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder",
    ]

    /// Call from LadderApp.init() before any other work.
    ///
    /// Validates every required key is present and non-placeholder. The only
    /// exemption is XCTest runs, where the host app launches without the real
    /// xcconfig env and every value would be blank.
    ///
    /// Validates: SUPABASE_URL, SUPABASE_ANON_KEY, and the three Edge Function
    /// URLs (ai-gateway, varun-validate, audit-ingest). The Edge Function URLs
    /// synthesise from supabaseURL when not explicitly set, so only the base
    /// URL needs independent validation here.
    static func preflightOrCrash() {
        // Skip during unit/UI test runs.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
            return
        }

        // --- SUPABASE_URL ---
        let url = supabaseURL
        if placeholderURLs.contains(url) {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_URL is a placeholder (\(url)). " +
                "Replace it with the real Supabase project URL in Config/Secrets.xcconfig."
            )
        }
        guard url.hasPrefix("https://") else {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_URL does not start with https://. " +
                "Value: \(url). xcconfig stores the host only; AppConfiguration prepends the scheme."
            )
        }

        // --- SUPABASE_ANON_KEY ---
        let key = supabaseAnonKey
        if key.isEmpty {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_ANON_KEY is blank. " +
                "Add SUPABASE_ANON_KEY to Config/Secrets.xcconfig."
            )
        }
        if placeholderAnonKeys.contains(key) {
            fatalError(
                "[AppConfiguration.preflightOrCrash] SUPABASE_ANON_KEY is a placeholder (\(key)). " +
                "Replace with the real Supabase anon key in Config/Secrets.xcconfig."
            )
        }

        // --- AI Gateway ---
        // aiGatewayBaseURL synthesises from supabaseURL, so if supabaseURL passed
        // above then the gateway URL will always be structurally valid. This access
        // confirms no fatalError fires during synthesis.
        _ = aiGatewayBaseURL
        _ = flagsBaseURL
        _ = auditBaseURL
    }
}
