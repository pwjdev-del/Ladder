import SwiftUI

// MARK: - College Discovery ViewModel

@Observable
final class CollegeDiscoveryViewModel {

    var searchText = ""
    var selectedFilter: CollegeFilter = .all
    var colleges: [CollegeListItem] = []
    var favoriteIds: Set<String> = []
    var isLoadingScorecard = false

    private let scorecardService = CollegeScorecardService()

    init() {
        // Show bundled top-50 immediately (no loading flicker)
        colleges = CollegeScorecardService.bundledTopColleges
        // Kick off full Scorecard fetch in background
        Task { await loadFromScorecard() }
    }

    // MARK: - Scorecard Load

    @MainActor
    private func loadFromScorecard() async {
        isLoadingScorecard = true
        do {
            let all = try await scorecardService.fetchAll()
            // Only replace if we got a meaningful result
            if all.count > 50 { colleges = all.sorted { $0.name < $1.name } }
        } catch {
            // Silently fall back to bundled data — no error shown to user
        }
        isLoadingScorecard = false
    }

    // MARK: - Filtering

    enum CollegeFilter: String, CaseIterable {
        case all = "All"
        case reach = "Reach"
        case match = "Match"
        case safety = "Safety"
        case inFlorida = "Florida"
        case smallSchool = "Small"
        case favorites = "Favorites"
    }

    var filteredColleges: [CollegeListItem] {
        var result = colleges
        switch selectedFilter {
        case .all: break
        case .reach:     result = result.filter { ($0.matchPercent ?? 50) < 40 || ($0.acceptanceRate ?? 1.0) < 0.15 }
        case .match:     result = result.filter { let m = $0.matchPercent ?? 50; return m >= 40 && m < 75 }
        case .safety:    result = result.filter { ($0.matchPercent ?? 50) >= 75 || ($0.acceptanceRate ?? 0) > 0.60 }
        case .inFlorida: result = result.filter { $0.location.hasSuffix(", FL") }
        case .smallSchool: result = result.filter { ($0.enrollment ?? 999999) < 10000 }
        case .favorites: result = result.filter { favoriteIds.contains($0.id) }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    func toggleFavorite(_ college: CollegeListItem) {
        if favoriteIds.contains(college.id) {
            favoriteIds.remove(college.id)
        } else {
            favoriteIds.insert(college.id)
        }
    }
}

// MARK: - College List Item

struct CollegeListItem: Identifiable {
    let id: String
    let name: String
    let location: String
    let matchPercent: Int?
    let imageURL: String?
    let tags: [String]
    let acceptanceRate: Double?
    let tuition: Int?
    let enrollment: Int?
    let satRange: String?
    let type: String

    // Fallback for screens that reference sample data directly
    static var sampleColleges: [CollegeListItem] {
        CollegeScorecardService.bundledTopColleges
    }
}
