import Foundation
import Supabase
import SwiftData
import os

// CLAUDE.md §3 / §4 — canonical Supabase auth wrapper.
// All sign-in flows route through this actor; the Supabase SDK handles
// JWT storage in its own Keychain-backed session store (GoTrue).
// TenantContext is bound after sign-in from the JWT claims.
//
// S1-3 FIX (2026-05-14): SupabaseClient is now constructed with the
// TLS-pinned URLSession injected via SupabaseClientOptions.GlobalOptions.
// This routes every auth, PostgREST, and Edge Function call through the
// same cert-pinned transport used by AIGatewayClient / AuditClient / FlagClient.
//
// S1-4 FIX (2026-05-14): signOut() wipes the SwiftData store before clearing
// the GoTrue session so shared-device Student A → Student B transitions
// cannot leak residual PII. The ModelContainer is registered once at app
// startup via SwiftDataWipeRegistry.register(_:). If the container was never
// registered the wipe is skipped and logged — callers must not rely on
// sign-out as the sole isolation mechanism in that case.

// MARK: - SwiftData wipe registry
//
// Holds a weak-ish reference to the app's ModelContainer so signOut() can wipe
// on-device PII without requiring the container to be threaded through the
// actor's initialiser (which would require changes to the app entry point beyond
// this file's scope).
//
// SEAM NOTE: LadderApp.swift must call
//   SwiftDataWipeRegistry.register(modelContainer)
// once, immediately after `createModelContainer()` returns. This is a one-liner
// addition to LadderApp.init() — tracked as an out-of-scope seam in
// OUT_OF_SCOPE_FINDINGS.md.

public enum SwiftDataWipeRegistry {
    // nonisolated(unsafe) is safe here: the container is set once on the main
    // thread during app startup, before any concurrent access is possible, and
    // is only ever read (never mutated after registration) at sign-out time.
    nonisolated(unsafe) private static var _container: ModelContainer?

    /// Register the app's ModelContainer. Call once from LadderApp.init().
    public static func register(_ container: ModelContainer) {
        _container = container
    }

    /// Wipe all SwiftData models from the persistent store.
    /// Must be called from a context that can await (the actor's signOut is async).
    /// Returns false if the container was never registered or the wipe failed.
    @discardableResult
    static func wipeAll(hashedUserId: String) async -> Bool {
        guard let container = _container else {
            os_log("SwiftDataWipeRegistry: no container registered — skipping wipe for user %{public}@",
                   log: .auth, type: .fault, hashedUserId)
            return false
        }
        do {
            // deleteAllData() drops the entire persistent store on disk and
            // reinitialises it in the same location. iOS 17.4+.
            // This is preferred over per-model deletes because it is atomic and
            // avoids a missed-model regression when new @Model types are added.
            try container.deleteAllData()
            os_log("SwiftDataWipeRegistry: store wiped for user %{public}@",
                   log: .auth, type: .info, hashedUserId)
            return true
        } catch {
            os_log("SwiftDataWipeRegistry: deleteAllData failed for user %{public}@ — %{public}@",
                   log: .auth, type: .fault,
                   hashedUserId,
                   error.localizedDescription)
            return false
        }
    }
}

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

    private nonisolated let client: SupabaseClient

    private init() {
        // S1-3: Inject the TLS-pinned URLSession so every auth, PostgREST, and
        // Edge Function request is covered by certificate pinning — matching the
        // transport used by AIGatewayClient, AuditClient, and FlagClient.
        // SupabaseClientOptions is the 2.x API; GlobalOptions.session replaces
        // the SDK-default URLSession.shared with TLSPinnedSessionFactory.shared.session.
        let options = SupabaseClientOptions(
            global: SupabaseClientOptions.GlobalOptions(
                session: TLSPinnedSessionFactory.shared.session
            )
        )
        guard let url = URL(string: AppConfiguration.supabaseURL) else {
            // AppConfiguration.preflightOrCrash() in App.init() catches the
            // Release-build case. In DEBUG the guard provides a clear crash site
            // rather than a force-unwrap with no context.
            fatalError("SupabaseAuthService: AppConfiguration.supabaseURL is not a valid URL — check AppConfiguration.")
        }
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: AppConfiguration.supabaseAnonKey,
            options: options
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
        os_log("signUp: starting for %{public}@", log: .auth, type: .info, email)
        let response = try await client.auth.signUp(email: email, password: password)
        os_log("signUp: response received, session=%{public}@",
               log: .auth, type: .info, response.session == nil ? "nil" : "present")
        let session: Session
        if let direct = response.session {
            session = direct
        } else {
            os_log("signUp: response.session nil, calling signIn", log: .auth, type: .info)
            do {
                session = try await client.auth.signIn(email: email, password: password)
                os_log("signUp: signIn after signUp succeeded", log: .auth, type: .info)
            } catch let authError as AuthError {
                os_log("signUp: signIn after signUp threw AuthError: %{public}@",
                       log: .auth, type: .error, String(describing: authError))
                if case .api(_, let code, _, _) = authError, code == .emailNotConfirmed {
                    throw LadderAuthError.emailConfirmationRequired
                }
                throw authError
            } catch {
                os_log("signUp: signIn after signUp threw generic: %{public}@",
                       log: .auth, type: .error, String(describing: error))
                throw error
            }
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

        // Re-issue the session so the JWT picks up the freshly stamped role claim.
        // We use signIn(email:password:) rather than refreshSession() because under
        // the SDK's PKCE flow the refresh_token returned from /signup interacts
        // poorly with mid-flight Edge Function calls and refreshSession() will
        // throw AuthError.sessionMissing — leaving the user dead-ended on the
        // signup screen. signIn always returns a fresh, fully-claimed JWT.
        os_log("signUp: bootstrap-user succeeded, re-issuing session via signIn",
               log: .auth, type: .info)
        let refreshed = try await client.auth.signIn(email: email, password: password)

        guard let rawRole = refreshed.user.appMetadata["role"]?.value as? String, !rawRole.isEmpty else {
            os_log("bootstrap-user succeeded but role claim still absent after re-signin",
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

    // MARK: - Session rebind (cold-launch restore)

    /// Re-populates TenantContext from a session that was already persisted in
    /// the Keychain (i.e. a cold-launch restore). Does NOT perform a network
    /// round-trip unless `bindTenantContext` needs to fetch grade level.
    /// Throws `LadderAuthError.missingRoleClaim` in Release when the JWT lacks
    /// an `app_metadata.role` claim — the caller should sign out and show LandingView.
    public func rebindFromSession(_ session: Session) async throws {
        try await bindTenantContext(from: session)
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
        // S1-4: Wipe SwiftData FIRST before clearing the GoTrue session.
        // Order matters: if the wipe fails we still have the session reference
        // for any cleanup retry; conversely, clearing the session first and then
        // crashing the wipe would leave residual PII accessible to the next user.
        //
        // The user's raw UUID is never logged. We derive a short opaque hash for
        // correlation in crash reports without exposing PII.
        let hashedId: String
        if let uid = (try? await client.auth.session)?.user.id.uuidString {
            hashedId = String(uid.hashValue & 0xFFFF, radix: 16)
        } else {
            hashedId = "unknown"
        }

        // Best-effort wipe: never throws from signOut().
        // The registry logs a fault-level message on failure; the caller must
        // not rely on this succeeding in abnormal conditions (e.g. container
        // not registered in a test target).
        await SwiftDataWipeRegistry.wipeAll(hashedUserId: hashedId)

        // Clear GoTrue session from Keychain after the local store is gone.
        try await client.auth.signOut()

        // Clear in-memory TenantContext last so any in-flight reads still have
        // a valid claim reference during the async wipe above.
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
    public nonisolated var supabase: SupabaseClient { client }

#if DEBUG
    // MARK: - Test hooks (DEBUG only)

    /// Bypasses Supabase auth and directly populates TenantContext with a
    /// mock student session. Only callable when -UITestMode is active.
    /// This does NOT create a real Supabase Session — the actor holds no
    /// JWT state for the injected session, which is intentional: tests that
    /// need a live JWT must sign in normally.
    public func injectMockSession(_ student: MockStudent) async {
        let claim = TenantClaim(
            tenantId: UUID(uuidString: student.tenantId),
            role: .student,
            userId: UUID(uuidString: student.userId) ?? UUID(),
            expiresAt: Date(timeIntervalSinceNow: 3600)
        )
        await MainActor.run {
            TenantContext.shared.bind(claim,
                                     displayName: "Test School",
                                     primaryColorHex: nil,
                                     logoKey: nil)
            TenantContext.shared.setStudentGradeLevel(student.gradeLevel)
        }
    }
#endif
}
