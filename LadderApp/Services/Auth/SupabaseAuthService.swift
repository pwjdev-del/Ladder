import Foundation
import Supabase

// CLAUDE.md §3 / §4 — canonical Supabase auth wrapper.
// All sign-in flows route through this actor; the Supabase SDK handles
// JWT storage in its own Keychain-backed session store (GoTrue).
// TenantContext is bound after sign-in from the JWT claims.

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
    /// Throws `AuthError` on failure (bad credentials, network error, etc.).
    @discardableResult
    public func signInWithPassword(email: String, password: String) async throws -> Session {
        let response = try await client.auth.signIn(email: email, password: password)
        await bindTenantContext(from: response)
        return response
    }

    // MARK: - Sign out

    public func signOut() async throws {
        try await client.auth.signOut()
        await TenantContext.shared.clear()
    }

    // MARK: - Current session

    /// Returns the persisted session if one exists (GoTrue persists to Keychain).
    public var currentSession: Session? {
        get async {
            try? await client.auth.session
        }
    }

    // MARK: - Tenant binding

    /// Extracts role + tenant from the JWT user_metadata / app_metadata claims
    /// and populates TenantContext. Adapt claim keys to match your DB schema.
    private func bindTenantContext(from session: Session) async {
        let metadata = session.user.appMetadata
        let rawRole = metadata["role"]?.value as? String ?? "student"
        let appRole = AppRole(rawValue: rawRole) ?? .student
        let tenantIdString = metadata["tenant_id"]?.value as? String
        let tenantId = tenantIdString.flatMap { UUID(uuidString: $0) }

        let claim = TenantClaim(
            tenantId: tenantId,
            role: appRole,
            userId: session.user.id,
            expiresAt: session.expiresAt ?? Date.distantFuture
        )

        // tenant_display_name is optional — the DB RLS fn sets it via
        // the tenants table; for now pull from user_metadata if present.
        let displayName = metadata["tenant_display_name"]?.value as? String

        await TenantContext.shared.bind(claim,
                                        displayName: displayName,
                                        primaryColorHex: nil,
                                        logoKey: nil)

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
            await TenantContext.shared.setStudentGradeLevel(grade)
        } catch {
            // Non-fatal: grade_level missing means feature gates default to nil.
            // Will be populated once the students row is created via onboarding.
        }
    }

    // MARK: - Supabase client accessor

    /// Exposed for callers that need raw DB / Edge Function access
    /// (e.g., grade_level fetch in Fix 6).
    public var supabase: SupabaseClient { client }
}
