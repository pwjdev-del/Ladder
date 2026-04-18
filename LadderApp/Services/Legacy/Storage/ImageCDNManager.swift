import Foundation
import SwiftUI

// MARK: - Image CDN Manager
// Manages college logo and campus photo URLs for S3 + CloudFront delivery.
// Placeholder until the CDN bucket is loaded with actual images.

@Observable
final class ImageCDNManager {
    static let shared = ImageCDNManager()
    private init() {}

    // CDN base URL (TODO: set when S3 is configured)
    private let cdnBase = "https://cdn.ladderapp.com"

    // MARK: - College Logo

    func collegeLogoURL(scorecardId: Int) -> URL? {
        URL(string: "\(cdnBase)/colleges/\(scorecardId)/logo.jpg")
    }

    // MARK: - Campus Photos

    func campusPhotoURLs(scorecardId: Int, count: Int = 3) -> [URL] {
        (1...count).compactMap {
            URL(string: "\(cdnBase)/colleges/\(scorecardId)/campus_\($0).jpg")
        }
    }

    // For now, return false — AsyncImage will fall back to the deterministic gradient.
    // This is a placeholder until S3 is loaded with actual images.
    var isConfigured: Bool { false }
}
