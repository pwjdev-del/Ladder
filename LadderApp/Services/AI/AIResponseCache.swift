import Foundation

// MARK: - AI Response Cache
// Caches AI responses in UserDefaults to reduce Gemini API costs
// Normalized queries improve cache hit rate across similar questions

@Observable
final class AIResponseCache {
    static let shared = AIResponseCache()
    private init() {}

    private let cacheKey = "ai_response_cache"
    private let maxAge: TimeInterval = 24 * 3600 // 24 hours

    struct CachedResponse: Codable {
        let query: String
        let response: String
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 24 * 3600
        }
    }

    // Check cache before making API call
    func getCached(for query: String) -> String? {
        let normalizedQuery = normalizeQuery(query)
        let cache = loadCache()
        guard let entry = cache[normalizedQuery], !entry.isExpired else { return nil }
        return entry.response
    }

    // Store response in cache
    func store(query: String, response: String) {
        var cache = loadCache()
        let normalizedQuery = normalizeQuery(query)
        cache[normalizedQuery] = CachedResponse(query: normalizedQuery, response: response, timestamp: Date())

        // Prune expired entries
        cache = cache.filter { !$0.value.isExpired }

        // Keep max 100 entries
        if cache.count > 100 {
            let sorted = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            cache = Dictionary(uniqueKeysWithValues: sorted.suffix(100))
        }

        saveCache(cache)
    }

    // Normalize query for better cache hits
    // "Tell me about UF" and "tell me about uf" should match
    private func normalizeQuery(_ query: String) -> String {
        query.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private func loadCache() -> [String: CachedResponse] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode([String: CachedResponse].self, from: data)
        else { return [:] }
        return cache
    }

    private func saveCache(_ cache: [String: CachedResponse]) {
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }

    // Clear all cache
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }

    var cacheSize: Int {
        loadCache().count
    }
}
