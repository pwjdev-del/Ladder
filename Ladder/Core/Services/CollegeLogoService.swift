import Foundation

// MARK: - College Logo Service
// Uses Clearbit Logo API (free, no key needed) to fetch college logos from their domain.

struct CollegeLogoService {

    /// Extract the root domain from a college's websiteURL.
    /// Input examples: "www.ufl.edu", "https://www.ufl.edu/admissions", "http://ufl.edu"
    /// Output: "ufl.edu"
    static func extractDomain(from websiteURL: String?) -> String? {
        guard let urlString = websiteURL, !urlString.isEmpty else { return nil }

        var cleaned = urlString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")

        // Remove trailing path after the domain
        if let slashIndex = cleaned.firstIndex(of: "/") {
            cleaned = String(cleaned[cleaned.startIndex..<slashIndex])
        }

        // Remove trailing whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? nil : cleaned
    }

    /// Build a Clearbit logo URL for a college domain at the given pixel size.
    static func logoURL(for websiteURL: String?, size: Int = 128) -> URL? {
        guard let domain = extractDomain(from: websiteURL) else { return nil }
        return URL(string: "https://logo.clearbit.com/\(domain)?size=\(size)")
    }
}
