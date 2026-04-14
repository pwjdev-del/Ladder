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
            // MARK: Ivy League
            CollegeListItem(id: "harvard", name: "Harvard University",
                location: "Cambridge, MA", matchPercent: 12,
                imageURL: nil, tags: ["Ivy", "Private", "Research"],
                acceptanceRate: 0.04, tuition: 59076, enrollment: 23000,
                satRange: "1500-1580", type: "Private"),
            CollegeListItem(id: "yale", name: "Yale University",
                location: "New Haven, CT", matchPercent: 14,
                imageURL: nil, tags: ["Ivy", "Private", "Liberal Arts"],
                acceptanceRate: 0.05, tuition: 64700, enrollment: 14000,
                satRange: "1500-1560", type: "Private"),
            CollegeListItem(id: "princeton", name: "Princeton University",
                location: "Princeton, NJ", matchPercent: 13,
                imageURL: nil, tags: ["Ivy", "Private", "Research"],
                acceptanceRate: 0.06, tuition: 59710, enrollment: 8500,
                satRange: "1500-1570", type: "Private"),
            CollegeListItem(id: "columbia", name: "Columbia University",
                location: "New York, NY", matchPercent: 15,
                imageURL: nil, tags: ["Ivy", "Private", "Urban"],
                acceptanceRate: 0.04, tuition: 66139, enrollment: 33000,
                satRange: "1500-1560", type: "Private"),
            CollegeListItem(id: "upenn", name: "University of Pennsylvania",
                location: "Philadelphia, PA", matchPercent: 18,
                imageURL: nil, tags: ["Ivy", "Private", "Business"],
                acceptanceRate: 0.06, tuition: 63452, enrollment: 28000,
                satRange: "1500-1570", type: "Private"),
            CollegeListItem(id: "cornell", name: "Cornell University",
                location: "Ithaca, NY", matchPercent: 22,
                imageURL: nil, tags: ["Ivy", "Private", "Research"],
                acceptanceRate: 0.07, tuition: 65204, enrollment: 25000,
                satRange: "1470-1550", type: "Private"),
            CollegeListItem(id: "brown", name: "Brown University",
                location: "Providence, RI", matchPercent: 16,
                imageURL: nil, tags: ["Ivy", "Private", "Liberal Arts"],
                acceptanceRate: 0.05, tuition: 65146, enrollment: 10000,
                satRange: "1490-1560", type: "Private"),
            CollegeListItem(id: "dartmouth", name: "Dartmouth College",
                location: "Hanover, NH", matchPercent: 19,
                imageURL: nil, tags: ["Ivy", "Private", "Small"],
                acceptanceRate: 0.06, tuition: 62430, enrollment: 6700,
                satRange: "1470-1560", type: "Private"),

            // MARK: Elite Private
            CollegeListItem(id: "stanford", name: "Stanford University",
                location: "Stanford, CA", matchPercent: 10,
                imageURL: nil, tags: ["Private", "Research", "STEM"],
                acceptanceRate: 0.04, tuition: 61731, enrollment: 17000,
                satRange: "1500-1570", type: "Private"),
            CollegeListItem(id: "mit", name: "Massachusetts Institute of Technology",
                location: "Cambridge, MA", matchPercent: 15,
                imageURL: nil, tags: ["Private", "Research", "STEM"],
                acceptanceRate: 0.04, tuition: 57986, enrollment: 11000,
                satRange: "1510-1580", type: "Private"),
            CollegeListItem(id: "caltech", name: "California Institute of Technology",
                location: "Pasadena, CA", matchPercent: 12,
                imageURL: nil, tags: ["Private", "STEM", "Small"],
                acceptanceRate: 0.03, tuition: 60816, enrollment: 2400,
                satRange: "1530-1580", type: "Private"),
            CollegeListItem(id: "duke", name: "Duke University",
                location: "Durham, NC", matchPercent: 20,
                imageURL: nil, tags: ["Private", "Research", "D1 Sports"],
                acceptanceRate: 0.06, tuition: 63450, enrollment: 17000,
                satRange: "1490-1560", type: "Private"),
            CollegeListItem(id: "northwestern", name: "Northwestern University",
                location: "Evanston, IL", matchPercent: 22,
                imageURL: nil, tags: ["Private", "Research", "Journalism"],
                acceptanceRate: 0.07, tuition: 63468, enrollment: 22000,
                satRange: "1490-1560", type: "Private"),
            CollegeListItem(id: "vanderbilt", name: "Vanderbilt University",
                location: "Nashville, TN", matchPercent: 24,
                imageURL: nil, tags: ["Private", "Research", "Music"],
                acceptanceRate: 0.07, tuition: 61618, enrollment: 13000,
                satRange: "1470-1560", type: "Private"),
            CollegeListItem(id: "rice", name: "Rice University",
                location: "Houston, TX", matchPercent: 23,
                imageURL: nil, tags: ["Private", "STEM", "Small"],
                acceptanceRate: 0.09, tuition: 57210, enrollment: 8500,
                satRange: "1490-1560", type: "Private"),
            CollegeListItem(id: "georgetown", name: "Georgetown University",
                location: "Washington, DC", matchPercent: 28,
                imageURL: nil, tags: ["Private", "Urban", "Politics"],
                acceptanceRate: 0.12, tuition: 63672, enrollment: 20000,
                satRange: "1410-1540", type: "Private"),
            CollegeListItem(id: "notredame", name: "University of Notre Dame",
                location: "Notre Dame, IN", matchPercent: 26,
                imageURL: nil, tags: ["Private", "Catholic", "D1 Sports"],
                acceptanceRate: 0.13, tuition: 62693, enrollment: 13000,
                satRange: "1460-1550", type: "Private"),
            CollegeListItem(id: "wustl", name: "Washington University in St. Louis",
                location: "St. Louis, MO", matchPercent: 25,
                imageURL: nil, tags: ["Private", "Research", "Pre-Med"],
                acceptanceRate: 0.12, tuition: 62982, enrollment: 16000,
                satRange: "1490-1560", type: "Private"),
            CollegeListItem(id: "emory", name: "Emory University",
                location: "Atlanta, GA", matchPercent: 28,
                imageURL: nil, tags: ["Private", "Research", "Pre-Med"],
                acceptanceRate: 0.11, tuition: 57948, enrollment: 15000,
                satRange: "1420-1540", type: "Private"),

            // MARK: State Flagships
            CollegeListItem(id: "umich", name: "University of Michigan",
                location: "Ann Arbor, MI", matchPercent: 38,
                imageURL: nil, tags: ["Public", "Research", "D1 Sports"],
                acceptanceRate: 0.18, tuition: 17786, enrollment: 51000,
                satRange: "1350-1530", type: "Public"),
            CollegeListItem(id: "berkeley", name: "University of California, Berkeley",
                location: "Berkeley, CA", matchPercent: 32,
                imageURL: nil, tags: ["Public", "Research", "STEM"],
                acceptanceRate: 0.11, tuition: 15348, enrollment: 45000,
                satRange: "1340-1530", type: "Public"),
            CollegeListItem(id: "ucla", name: "University of California, Los Angeles",
                location: "Los Angeles, CA", matchPercent: 34,
                imageURL: nil, tags: ["Public", "Urban", "D1 Sports"],
                acceptanceRate: 0.09, tuition: 13804, enrollment: 47000,
                satRange: "1330-1530", type: "Public"),
            CollegeListItem(id: "unc", name: "University of North Carolina at Chapel Hill",
                location: "Chapel Hill, NC", matchPercent: 42,
                imageURL: nil, tags: ["Public", "Research", "D1 Sports"],
                acceptanceRate: 0.19, tuition: 9028, enrollment: 31000,
                satRange: "1330-1500", type: "Public"),
            CollegeListItem(id: "uva", name: "University of Virginia",
                location: "Charlottesville, VA", matchPercent: 40,
                imageURL: nil, tags: ["Public", "Research", "Historic"],
                acceptanceRate: 0.19, tuition: 19698, enrollment: 26000,
                satRange: "1380-1520", type: "Public"),
            CollegeListItem(id: "utaustin", name: "University of Texas at Austin",
                location: "Austin, TX", matchPercent: 45,
                imageURL: nil, tags: ["Public", "Large", "D1 Sports"],
                acceptanceRate: 0.31, tuition: 11678, enrollment: 52000,
                satRange: "1230-1480", type: "Public"),
            CollegeListItem(id: "wisconsin", name: "University of Wisconsin-Madison",
                location: "Madison, WI", matchPercent: 55,
                imageURL: nil, tags: ["Public", "Research", "D1 Sports"],
                acceptanceRate: 0.49, tuition: 10796, enrollment: 48000,
                satRange: "1300-1480", type: "Public"),
            CollegeListItem(id: "illinois", name: "University of Illinois Urbana-Champaign",
                location: "Champaign, IL", matchPercent: 52,
                imageURL: nil, tags: ["Public", "Engineering", "STEM"],
                acceptanceRate: 0.45, tuition: 17138, enrollment: 56000,
                satRange: "1290-1490", type: "Public"),
            CollegeListItem(id: "gatech", name: "Georgia Institute of Technology",
                location: "Atlanta, GA", matchPercent: 35,
                imageURL: nil, tags: ["Public", "Engineering", "STEM"],
                acceptanceRate: 0.17, tuition: 12682, enrollment: 44000,
                satRange: "1390-1540", type: "Public"),
            CollegeListItem(id: "uwash", name: "University of Washington",
                location: "Seattle, WA", matchPercent: 50,
                imageURL: nil, tags: ["Public", "Research", "Urban"],
                acceptanceRate: 0.43, tuition: 12643, enrollment: 52000,
                satRange: "1240-1460", type: "Public"),

            // MARK: HBCUs
            CollegeListItem(id: "howard", name: "Howard University",
                location: "Washington, DC", matchPercent: 58,
                imageURL: nil, tags: ["HBCU", "Private", "Historic"],
                acceptanceRate: 0.36, tuition: 30985, enrollment: 12000,
                satRange: "1130-1280", type: "Private"),
            CollegeListItem(id: "spelman", name: "Spelman College",
                location: "Atlanta, GA", matchPercent: 55,
                imageURL: nil, tags: ["HBCU", "Private", "Women"],
                acceptanceRate: 0.43, tuition: 30304, enrollment: 2100,
                satRange: "1100-1230", type: "Private"),
            CollegeListItem(id: "morehouse", name: "Morehouse College",
                location: "Atlanta, GA", matchPercent: 60,
                imageURL: nil, tags: ["HBCU", "Private", "Men"],
                acceptanceRate: 0.58, tuition: 30192, enrollment: 2200,
                satRange: "1030-1190", type: "Private"),
            CollegeListItem(id: "hampton", name: "Hampton University",
                location: "Hampton, VA", matchPercent: 68,
                imageURL: nil, tags: ["HBCU", "Private", "Coastal"],
                acceptanceRate: 0.36, tuition: 30118, enrollment: 3500,
                satRange: "990-1150", type: "Private"),
            CollegeListItem(id: "famu", name: "Florida A&M University",
                location: "Tallahassee, FL", matchPercent: 72,
                imageURL: nil, tags: ["HBCU", "Public", "Research"],
                acceptanceRate: 0.36, tuition: 5785, enrollment: 9700,
                satRange: "1010-1170", type: "Public"),

            // MARK: HSIs
            CollegeListItem(id: "utep", name: "University of Texas at El Paso",
                location: "El Paso, TX", matchPercent: 85,
                imageURL: nil, tags: ["HSI", "Public", "Research"],
                acceptanceRate: 1.00, tuition: 9040, enrollment: 24000,
                satRange: "970-1160", type: "Public"),
            CollegeListItem(id: "fiu", name: "Florida International University",
                location: "Miami, FL", matchPercent: 78,
                imageURL: nil, tags: ["HSI", "Public", "Urban"],
                acceptanceRate: 0.58, tuition: 6556, enrollment: 56000,
                satRange: "1100-1280", type: "Public"),
            CollegeListItem(id: "ucriverside", name: "University of California, Riverside",
                location: "Riverside, CA", matchPercent: 72,
                imageURL: nil, tags: ["HSI", "Public", "Research"],
                acceptanceRate: 0.69, tuition: 13854, enrollment: 26000,
                satRange: "1120-1330", type: "Public"),

            // MARK: Liberal Arts Colleges
            CollegeListItem(id: "williams", name: "Williams College",
                location: "Williamstown, MA", matchPercent: 18,
                imageURL: nil, tags: ["LAC", "Private", "Small"],
                acceptanceRate: 0.08, tuition: 63200, enrollment: 2100,
                satRange: "1450-1550", type: "Private"),
            CollegeListItem(id: "amherst", name: "Amherst College",
                location: "Amherst, MA", matchPercent: 20,
                imageURL: nil, tags: ["LAC", "Private", "Small"],
                acceptanceRate: 0.07, tuition: 66650, enrollment: 1900,
                satRange: "1450-1550", type: "Private"),
            CollegeListItem(id: "pomona", name: "Pomona College",
                location: "Claremont, CA", matchPercent: 19,
                imageURL: nil, tags: ["LAC", "Private", "Small"],
                acceptanceRate: 0.07, tuition: 62816, enrollment: 1700,
                satRange: "1440-1550", type: "Private"),
            CollegeListItem(id: "swarthmore", name: "Swarthmore College",
                location: "Swarthmore, PA", matchPercent: 21,
                imageURL: nil, tags: ["LAC", "Private", "Small"],
                acceptanceRate: 0.07, tuition: 62412, enrollment: 1650,
                satRange: "1450-1550", type: "Private"),
            CollegeListItem(id: "wellesley", name: "Wellesley College",
                location: "Wellesley, MA", matchPercent: 26,
                imageURL: nil, tags: ["LAC", "Private", "Women"],
                acceptanceRate: 0.14, tuition: 63340, enrollment: 2500,
                satRange: "1410-1530", type: "Private"),
            CollegeListItem(id: "bowdoin", name: "Bowdoin College",
                location: "Brunswick, ME", matchPercent: 22,
                imageURL: nil, tags: ["LAC", "Private", "Coastal"],
                acceptanceRate: 0.09, tuition: 62120, enrollment: 1900,
                satRange: "1430-1530", type: "Private"),

            // MARK: Florida Schools
            CollegeListItem(id: "uf", name: "University of Florida",
                location: "Gainesville, FL", matchPercent: 52,
                imageURL: nil, tags: ["Public", "Research", "Large"],
                acceptanceRate: 0.23, tuition: 6380, enrollment: 55000,
                satRange: "1330-1500", type: "Public"),
            CollegeListItem(id: "fsu", name: "Florida State University",
                location: "Tallahassee, FL", matchPercent: 62,
                imageURL: nil, tags: ["Public", "Research", "D1 Sports"],
                acceptanceRate: 0.25, tuition: 6517, enrollment: 45000,
                satRange: "1260-1400", type: "Public"),
            CollegeListItem(id: "usf", name: "University of South Florida",
                location: "Tampa, FL", matchPercent: 78,
                imageURL: nil, tags: ["Public", "Research", "Urban"],
                acceptanceRate: 0.43, tuition: 6410, enrollment: 50000,
                satRange: "1190-1350", type: "Public"),
            CollegeListItem(id: "ucf", name: "University of Central Florida",
                location: "Orlando, FL", matchPercent: 82,
                imageURL: nil, tags: ["Public", "Large", "Urban"],
                acceptanceRate: 0.43, tuition: 6368, enrollment: 72000,
                satRange: "1160-1340", type: "Public"),

            // MARK: Private STEM / Other
            CollegeListItem(id: "rit", name: "Rochester Institute of Technology",
                location: "Rochester, NY", matchPercent: 70,
                imageURL: nil, tags: ["Private", "Co-op", "STEM"],
                acceptanceRate: 0.68, tuition: 54588, enrollment: 16000,
                satRange: "1230-1410", type: "Private"),

            // MARK: Mid-tier State Schools
            CollegeListItem(id: "pennstate", name: "Pennsylvania State University",
                location: "University Park, PA", matchPercent: 60,
                imageURL: nil, tags: ["Public", "Large", "D1 Sports"],
                acceptanceRate: 0.55, tuition: 19286, enrollment: 89000,
                satRange: "1160-1360", type: "Public"),
            CollegeListItem(id: "ohiostate", name: "Ohio State University",
                location: "Columbus, OH", matchPercent: 58,
                imageURL: nil, tags: ["Public", "Large", "D1 Sports"],
                acceptanceRate: 0.57, tuition: 12485, enrollment: 61000,
                satRange: "1250-1450", type: "Public"),
            CollegeListItem(id: "indiana", name: "Indiana University Bloomington",
                location: "Bloomington, IN", matchPercent: 72,
                imageURL: nil, tags: ["Public", "Research", "Business"],
                acceptanceRate: 0.82, tuition: 11790, enrollment: 47000,
                satRange: "1170-1370", type: "Public"),
            CollegeListItem(id: "umaryland", name: "University of Maryland, College Park",
                location: "College Park, MD", matchPercent: 52,
                imageURL: nil, tags: ["Public", "Research", "STEM"],
                acceptanceRate: 0.45, tuition: 11505, enrollment: 41000,
                satRange: "1290-1470", type: "Public"),
            CollegeListItem(id: "rutgers", name: "Rutgers University-New Brunswick",
                location: "New Brunswick, NJ", matchPercent: 65,
                imageURL: nil, tags: ["Public", "Research", "Large"],
                acceptanceRate: 0.66, tuition: 16263, enrollment: 50000,
                satRange: "1210-1430", type: "Public"),
            CollegeListItem(id: "asu", name: "Arizona State University",
                location: "Tempe, AZ", matchPercent: 80,
                imageURL: nil, tags: ["Public", "Large", "Innovation"],
                acceptanceRate: 0.88, tuition: 12051, enrollment: 80000,
                satRange: "1120-1370", type: "Public"),
            CollegeListItem(id: "sdsu", name: "San Diego State University",
                location: "San Diego, CA", matchPercent: 68,
                imageURL: nil, tags: ["Public", "Urban", "Coastal"],
                acceptanceRate: 0.37, tuition: 8362, enrollment: 37000,
                satRange: "1110-1320", type: "Public"),
        ]
    }
}
