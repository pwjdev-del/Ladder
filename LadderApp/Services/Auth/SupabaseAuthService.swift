import Foundation
import Supabase
import os

// CLAUDE.md §3 / §4 — canonical Supabase auth wrapper.
// All sign-in flows route through this actor; the Supabase SDK handles
// JWT storage in its own Keychain-backed session store (GoTrue).
// TenantContext is bound after sign-in from the JWT claims.

// MARK: - Auth errors

public enum LadderAuthError: LocalizedError {
    case missingRoleClaim
    case bootstrapFailed
    /// GoTrue returned a nil session after signUp — email confirmation is required.
    case emailConfirmationRequired
    /// founder-login returned 401: invalid TOTP or account is not a founder.
    /// Message is deliberately generic to avoid enumeration of founder accounts.
    case founderLoginUnauthorized
    /// founder-login returned 5xx or a network error.
    case founderLoginUnavailable

    public var errorDescription: String? {
        switch self {
        case .missingRoleClaim:
            return "Account not configured. Contact your administrator."
        case .bootstrapFailed:
            return "Could not initialize your account. Please try again or contact support."
        case .emailConfirmationRequired:
            return "Check your email to confirm your account, then log in."
        case .founderLoginUnauthorized:
            return "Invalid login. Check your password and TOTP code."
        case .founderLoginUnavailable:
            return "Service temporarily unavailable. Try again."
        }
    }
}

// MARK: - OSLog category

private extension OSLog {
    static let auth = OSLog(subsystem: "app.ladder", category: "auth")
}

// MARK: - Service

public actor SupabaseAuthService {
    public static let shared = SupabaseAuthService()

    private let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: AppConfiguration.supabaseURL)!,
            supabaseKey: AppConfiguration.supabaseAnonKey
        )
    }

    // MARK: - Sign in

    /// Sign in with email + password. Returns the authenticated Session.
    /// Throws `LadderAuthError` or Supabase errors on failure.
    @discardableResult
    public func signInWithPassword(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signIn(email: email, password: password)
        try await bindTenantContext(from: response)
        return response
    }

    // MARK: - Sign up (B2C)

    /// Creates a new account and bootstraps the role claim via the `bootstrap-user` Edge Function.
    /// Only sign-UP triggers bootstrap — sign-IN deliberately does not (misconfigured
    /// accounts or attack signals must surface as `missingRoleClaim`, not silently fixed).
    @discardableResult
    public func signUp(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signUp(email: email, password: password)
        // GoTrue returns a Session when email confirmation is disabled; when confirmation
        // is required it returns a User-only response. We need a Session to proceed.
        guard let session = response.session else {
            // Email confirmation required — caller should prompt user to verify.
            // This is NOT a configuration error; throw the specific case so the
            // UI can show the confirmation banner rather than an error message.
            throw LadderAuthError.emailConfirmationRequired
        }

        // Check whether the bootstrapped JWT already contains a role claim.
        // If Supabase triggers a DB function on signup that stamps the claim synchronously,
        // we might already have it and can skip the Edge Function round-trip.
        if let rawRole = session.user.appMetadata["role"]?.value as? String, !rawRole.isEmpty {
            try await bindTenantContext(from: session)
            return session
        }

        // Role absent — call bootstrap-user to stamp app_metadata.role on the server.
        // The SDK attaches the current Bearer JWT automatically via SupabaseClient.setAuth.
        os_log("signUp: role claim absent, calling bootstrap-user", log: .auth, type: .info)
        do {
            try await client.functions.invoke("bootstrap-user", options: .init())
        } catch let FunctionsError.httpError(code, _) {
            os_log("bootstrap-user returned HTTP %d, signing out", log: .auth, type: .error, code)
            try? await client.auth.signOut()
            throw LadderAuthError.bootstrapFailed
        } catch {
            os_log("bootstrap-user network error: %{public}@", log: .auth, type: .error,
                   String(describing: error))
            try? await client.auth.signOut()
            throw LadderAuthError.bootstrapFailed
        }

        // Refresh the session so the JWT picks up the freshly stamped role claim.
        let refreshed = try await client.auth.refreshSession()

        guard let rawRole = refreshed.user.appMetadata["role"]?.value as? String, !rawRole.isEmpty else {
            os_log("bootstrap-user succeeded but role claim still absent after refresh",
                   log: .auth, type: .fault)
            try? await client.auth.signOut()
            throw LadderAuthError.missingRoleClaim
        }

        try await bindTenantContext(from: refreshed)
        return refreshed
    }

    // MARK: - Founder TOTP verification

    /// Calls the `founder-login` Edge Function to verify the TOTP server-side, then
    /// refreshes the session so the JWT picks up the `app_metadata.role = 'founder'` stamp.
    ///
    /// On 401 (wrong TOTP or account is not a founder): throws `founderLoginUnauthorized`.
    /// On 5xx / network error: throws `founderLoginUnavailable`.
    /// Both cases are handled by signing out before throwing — the caller must not
    /// proceed to FounderDashboard regardless of the error variant.
    public func invokeFounderLogin(totpCode: String) async throws {
        do {
            try await client.functions.invoke(
                "founder-login",
                options: .init(body: ["totpCode": totpCode])
            )
        } catch let FunctionsError.httpError(code, _) where code == 401 {
            os_log("founder-login: 401 — unauthorized (invalid TOTP or non-founder account)",
                   log: .auth, type: .error)
            try? await client.auth.signOut()
            await MainActor.run { TenantContext.shared.clear() }
            throw LadderAuthError.founderLoginUnauthorized
        } catch let FunctionsError.httpError(code, _) {
            os_log("founder-login: HTTP %d — service error", log: .auth, type: .error, code)
            try? await client.auth.signOut()
            await MainActor.run { TenantContext.shared.clear() }
            throw LadderAuthError.founderLoginUnavailable
        } catch {
            os_log("founder-login: network error: %{public}@",
                   log: .auth, type: .error, String(describing: error))
            try? await client.auth.signOut()
            await MainActor.run { TenantContext.shared.clear() }
            throw LadderAuthError.founderLoginUnavailable
        }

        // 200 OK — refresh session to pick up the idempotent role stamp,
        // then rebind TenantContext so callers see role=.founder. Without
        // the rebind, in DEBUG builds where the original signInWithPassword
        // session lacked role and bindTenantContext defaulted to .student,
        // the claim in TenantContext stays stale at .student even though
        // the JWT has been refreshed to role=founder.
        let refreshed = try await client.auth.refreshSession()
        try await bindTenantContext(from: refreshed)
    }

    // MARK: - Password reset

    /// Sends a password-reset email via Supabase Auth (GoTrue).
    /// Throws on network error; does NOT throw when the address is unregistered
    /// (GoTrue returns 200 in that case to prevent account enumeration).
    public func resetPasswordForEmail(_ email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    // MARK: - Sign out

    public func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run { TenantContext.shared.clear() }
    }

    // MARK: - Current session

    /// Returns the persisted session if one exists (GoTrue persists to Keychain).
    public var currentSession: Session? {
        get async {
            let session = try? await client.auth.session
            if session == nil {
                os_log("currentSession: no active session found", log: .auth, type: .debug)
            }
            return session
        }
    }

    // MARK: - Tenant binding

    /// Extracts role + tenant from the JWT user_metadata / app_metadata claims
    /// and populates TenantContext. Adapt claim keys to match your DB schema.
    /// Throws `LadderAuthError.missingRoleClaim` in Release when the role claim is absent.
    private func bindTenantContext(from session: Session) async throws {
        let metadata = session.user.appMetadata
        let rawRole: String

        if let r = metadata["role"]?.value as? String {
            rawRole = r
        } else {
            #if DEBUG
            os_log("role claim missing, defaulting to .student in DEBUG",
                   log: .auth, type: .fault)
            rawRole = "student"
            #else
            throw LadderAuthError.missingRoleClaim
            #endif
        }

        let appRole = AppRole(rawValue: rawRole) ?? .student
        let tenantIdString = metadata["tenant_id"]?.value as? String
        let tenantId = tenantIdString.flatMap { UUID(uuidString: $0) }

        let claim = TenantClaim(
            tenantId: tenantId,
            role: appRole,
            userId: session.user.id,
            // session.expiresAt is a TimeInterval (Unix seconds), not a Date —
            // convert before storing on TenantClaim.
            expiresAt: Date(timeIntervalSince1970: session.expiresAt)
        )

        // tenant_display_name is optional — the DB RLS fn sets it via
        // the tenants table; for now pull from user_metadata if present.
        let displayName = metadata["tenant_display_name"]?.value as? String

        // TenantContext is @MainActor-isolated; hop explicitly from this actor.
        await MainActor.run {
            TenantContext.shared.bind(claim,
                                      displayName: displayName,
                                      primaryColorHex: nil,
                                      logoKey: nil)
        }

        // If this is a student session, fetch grade_level from the DB.
        // RLS on the `students` table restricts the row to the current user automatically.
        if appRole == .student {
            await fetchAndCacheGradeLevel(userId: session.user.id)
        }
    }

    // MARK: - Grade level fetch

    /// Fetches `students.grade_level` for the authenticated user from the DB.
    /// Caches the result in TenantContext so the router and feature gates can read it
    /// without an additional async hop. RLS guarantees the query returns only own row.
    private func fetchAndCacheGradeLevel(userId: UUID) async {
        struct GradeRow: Decodable {
            let gradeLevel: Int?
            enum CodingKeys: String, CodingKey { case gradeLevel = "grade_level" }
        }
        do {
            let rows: [GradeRow] = try await client
                .from("students")
                .select("grade_level")
                .eq("user_id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            let grade = rows.first?.gradeLevel
            // TenantContext is @MainActor-isolated; hop explicitly.
            await MainActor.run { TenantContext.shared.setStudentGradeLevel(grade) }
        } catch {
            os_log("grade fetch failed: %{public}@",
                   log: .auth, type: .error, String(describing: error))
        }
    }

    // MARK: - Supabase client accessor

    /// Exposed for callers that need raw DB / Edge Function access
    /// (e.g., grade_level fetch in Fix 6).
    public var supabase: SupabaseClient { client }
}
