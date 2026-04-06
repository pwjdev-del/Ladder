import SwiftUI

// MARK: - College Discovery ViewModel

@Observable
final class CollegeDiscoveryViewModel {

    var searchText = ""
    var selectedFilter: CollegeFilter = .all
    var colleges: [CollegeListItem] = CollegeListItem.sampleColleges
    var favoriteIds: Set<String> = []

    enum CollegeFilter: String, CaseIterable {
        case all = "All"
        case reach = "Reach"
        case match = "Match"
        case safety = "Safety"
        case favorites = "Favorites"
    }

    var filteredColleges: [CollegeListItem] {
        var result = colleges
        switch selectedFilter {
        case .all: break
        case .reach: result = result.filter { ($0.matchPercent ?? 0) < 40 }
        case .match: result = result.filter { ($0.matchPercent ?? 0) >= 40 && ($0.matchPercent ?? 0) < 75 }
        case .safety: result = result.filter { ($0.matchPercent ?? 0) >= 75 }
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

    static var sampleColleges: [CollegeListItem] {
        [
            CollegeListItem(
                id: "uf", name: "University of Florida",
                location: "Gainesville, FL", matchPercent: 82,
                imageURL: nil, tags: ["Public", "Research", "Large"],
                acceptanceRate: 0.23, tuition: 6380, enrollment: 55000,
                satRange: "1330-1500", type: "Public"
            ),
            CollegeListItem(
                id: "fsu", name: "Florida State University",
                location: "Tallahassee, FL", matchPercent: 88,
                imageURL: nil, tags: ["Public", "Research", "D1 Sports"],
                acceptanceRate: 0.25, tuition: 6517, enrollment: 45000,
                satRange: "1260-1400", type: "Public"
            ),
            CollegeListItem(
                id: "rit", name: "Rochester Institute of Technology",
                location: "Rochester, NY", matchPercent: 92,
                imageURL: nil, tags: ["Private", "Co-op", "STEM"],
                acceptanceRate: 0.68, tuition: 54588, enrollment: 16000,
                satRange: "1230-1410", type: "Private"
            ),
            CollegeListItem(
                id: "usf", name: "University of South Florida",
                location: "Tampa, FL", matchPercent: 90,
                imageURL: nil, tags: ["Public", "Research", "Urban"],
                acceptanceRate: 0.43, tuition: 6410, enrollment: 50000,
                satRange: "1190-1350", type: "Public"
            ),
            CollegeListItem(
                id: "gatech", name: "Georgia Institute of Technology",
                location: "Atlanta, GA", matchPercent: 35,
                imageURL: nil, tags: ["Public", "Engineering", "STEM"],
                acceptanceRate: 0.17, tuition: 12682, enrollment: 44000,
                satRange: "1390-1540", type: "Public"
            ),
            CollegeListItem(
                id: "mit", name: "Massachusetts Institute of Technology",
                location: "Cambridge, MA", matchPercent: 15,
                imageURL: nil, tags: ["Private", "Research", "STEM"],
                acceptanceRate: 0.04, tuition: 57986, enrollment: 11000,
                satRange: "1510-1580", type: "Private"
            ),
            CollegeListItem(
                id: "ucf", name: "University of Central Florida",
                location: "Orlando, FL", matchPercent: 95,
                imageURL: nil, tags: ["Public", "Large", "Urban"],
                acceptanceRate: 0.43, tuition: 6368, enrollment: 72000,
                satRange: "1160-1340", type: "Public"
            ),
            CollegeListItem(
                id: "fiu", name: "Florida International University",
                location: "Miami, FL", matchPercent: 91,
                imageURL: nil, tags: ["Public", "Research", "Urban"],
                acceptanceRate: 0.58, tuition: 6556, enrollment: 56000,
                satRange: "1100-1280", type: "Public"
            ),
            CollegeListItem(
                id: "emory", name: "Emory University",
                location: "Atlanta, GA", matchPercent: 28,
                imageURL: nil, tags: ["Private", "Research", "Pre-Med"],
                acceptanceRate: 0.11, tuition: 57948, enrollment: 15000,
                satRange: "1420-1540", type: "Private"
            ),
            CollegeListItem(
                id: "ut", name: "University of Tampa",
                location: "Tampa, FL", matchPercent: 85,
                imageURL: nil, tags: ["Private", "Small", "Business"],
                acceptanceRate: 0.52, tuition: 30864, enrollment: 10000,
                satRange: "1100-1270", type: "Private"
            ),
        ]
    }
}
