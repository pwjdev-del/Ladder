import Foundation
// NOTE: import Supabase — uncomment once supabase-swift is added via SPM

// MARK: - Supabase Manager
// Singleton that initializes and holds the Supabase client

@Observable
final class SupabaseManager {
    static let shared = SupabaseManager()

    // Uncomment once Supabase SPM package is added:
    // let client: SupabaseClient

    private init() {
        // client = SupabaseClient(
        //     supabaseURL: URL(string: AppConfiguration.supabaseURL)!,
        //     supabaseKey: AppConfiguration.supabaseAnonKey
        // )
    }
}
