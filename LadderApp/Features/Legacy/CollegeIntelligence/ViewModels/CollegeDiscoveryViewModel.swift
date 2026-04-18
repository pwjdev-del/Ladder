import SwiftUI
import SwiftData

// MARK: - College Discovery ViewModel

@Observable
final class CollegeDiscoveryViewModel {

    var searchText = ""
    var selectedFilter: CollegeFilter = .all
    var colleges: [CollegeListItem] = []
    var visibleCount: Int = 60
    private let pageSize: Int = 60
    var favoriteIds: Set<String> = []
    var isLoading = false
    var totalSchoolCount = 0
    var bestForMajorEnabled = false
    var studentCareerPath: String?
    var studentGPA: Double?
    var studentSAT: Int?

    // College preference quiz results
    var preferredSize: String?
    var preferredLocation: String?
    var preferredSetting: String?
    var preferredCulture: String?

    init() {}

    // MARK: - Load from SwiftData

    @MainActor
    func loadColleges(from context: ModelContext) {
        isLoading = true
        do {
            var descriptor = FetchDescriptor<CollegeModel>(
                sortBy: [SortDescriptor(\.name)]
            )
            descriptor.fetchLimit = 10000
            let models = try context.fetch(descriptor)
            totalSchoolCount = models.count
            colleges = models.map { CollegeListItem(from: $0) }

            // Load student profile data
            let profileDescriptor = FetchDescriptor<StudentProfileModel>()
            if let profile = try? context.fetch(profileDescriptor).first {
                studentCareerPath = profile.careerPath
                studentGPA = profile.gpa
                studentSAT = profile.satScore
                preferredSize = profile.preferredSize
                preferredLocation = profile.preferredLocation
                preferredSetting = profile.preferredSetting
                preferredCulture = profile.preferredCulture
            }
        } catch {
            Log.error("CollegeDiscoveryVM fetch error: \(error)")
        }
        isLoading = false
    }

    // MARK: - Filtering

    enum CollegeFilter: String, CaseIterable {
        case all = "All"
        case bestForMajor = "Best for Major"
        case reach = "Reach"
        case match = "Match"
        case safety = "Safety"
        case inFlorida = "Florida"
        case smallSchool = "Small"
        case favorites = "Favorites"
    }

    /// Label for the "Best for Major" chip, including the career path name
    var bestForMajorLabel: String {
        if let path = studentCareerPath, !path.isEmpty {
            return "Best for \(path)"
        }
        return "Best for Major"
    }

    var filteredColleges: [CollegeListItem] {
        var result = colleges
        switch selectedFilter {
        case .all: break
        case .bestForMajor:
            if let path = studentCareerPath,
               let keywords = ActivitySuggestionEngine.careerKeywords[path] {
                result = result.filter { college in
                    let searchable = (college.name + " " + college.tags.joined(separator: " ") + " " + college.programs.joined(separator: " ")).lowercased()
                    return keywords.contains { searchable.contains($0) }
                }
            }
        case .reach:     result = result.filter { matchTier(for: $0) == .reach }
        case .match:     result = result.filter { matchTier(for: $0) == .match }
        case .safety:    result = result.filter { matchTier(for: $0) == .safety }
        case .inFlorida: result = result.filter { $0.location.hasSuffix(", FL") }
        case .smallSchool: result = result.filter { ($0.enrollment ?? 999999) < 10000 }
        case .favorites: result = result.filter { favoriteIds.contains($0.id) }
        }

        // Apply "Best for Major" as additional filter when toggled on via bestForMajorEnabled
        if bestForMajorEnabled && selectedFilter != .bestForMajor {
            if let path = studentCareerPath,
               let keywords = ActivitySuggestionEngine.careerKeywords[path] {
                result = result.filter { college in
                    let searchable = (college.name + " " + college.tags.joined(separator: " ") + " " + college.programs.joined(separator: " ")).lowercased()
                    return keywords.contains { searchable.contains($0) }
                }
            }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Preference-based sorting: colleges matching preferences float higher
        let hasPreferences = preferredSize != nil || preferredLocation != nil || preferredSetting != nil
        if hasPreferences {
            result.sort { a, b in
                preferenceScore(for: a) > preferenceScore(for: b)
            }
        }

        return result
    }

    /// Paginated slice of filteredColleges for rendering.
    var visibleColleges: [CollegeListItem] {
        Array(filteredColleges.prefix(visibleCount))
    }

    var hasMore: Bool {
        visibleCount < filteredColleges.count
    }

    func loadMore() {
        guard hasMore else { return }
        visibleCount = min(visibleCount + pageSize, filteredColleges.count)
    }

    func resetPagination() {
        visibleCount = pageSize
    }

    // MARK: - Preference Score

    /// Bonus points for colleges matching student preference quiz answers (0-4 scale)
    func preferenceScore(for college: CollegeListItem) -> Int {
        var score = 0

        // Size preference
        if let pref = preferredSize, let enrollment = college.enrollment {
            switch pref {
            case "small"  where enrollment < 5000: score += 1
            case "medium" where enrollment >= 5000 && enrollment <= 15000: score += 1
            case "large"  where enrollment > 15000: score += 1
            default: break
            }
        }

        // Location preference
        if let pref = preferredLocation {
            switch pref {
            case "in_state":
                if college.state == "FL" || college.location.hasSuffix(", FL") { score += 1 }
            case "out_of_state":
                // Open to anywhere always matches
                score += 1
            default: break
            }
        }

        // Setting preference — use tags/type for a rough signal
        if let pref = preferredSetting {
            let nameAndTags = (college.name + " " + college.tags.joined(separator: " ")).lowercased()
            switch pref {
            case "urban":
                let urbanKeywords = ["urban", "city", "metropolitan"]
                if urbanKeywords.contains(where: { nameAndTags.contains($0) }) { score += 1 }
            case "suburban":
                let suburbanKeywords = ["suburban"]
                if suburbanKeywords.contains(where: { nameAndTags.contains($0) }) { score += 1 }
            case "rural":
                let ruralKeywords = ["rural"]
                if ruralKeywords.contains(where: { nameAndTags.contains($0) }) { score += 1 }
            default: break
            }
        }

        // Culture preference — use type and programs for a rough signal
        if let pref = preferredCulture {
            let type = college.type.lowercased()
            switch pref {
            case "research":
                if type.contains("university") || type.contains("research") { score += 1 }
            case "teaching":
                if type.contains("college") || type.contains("liberal arts") { score += 1 }
            case "both":
                score += 1 // everything matches "both"
            default: break
            }
        }

        return score
    }

    // MARK: - Match Tier

    func matchTier(for college: CollegeListItem) -> MatchTier {
        CollegeMatchCalculator.tier(
            studentGPA: studentGPA,
            studentSAT: studentSAT,
            collegeAcceptanceRate: college.acceptanceRate,
            collegeSATAvg: college.satAvg,
            collegeSAT25: college.sat25,
            collegeSAT75: college.sat75
        )
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
    let websiteURL: String?
    let tags: [String]
    let acceptanceRate: Double?
    let tuition: Int?
    let enrollment: Int?
    let satRange: String?
    let type: String

    // SAT component scores for match calculator
    let satAvg: Int?
    let sat25: Int?  // satMath25 + satReading25
    let sat75: Int?  // satMath75 + satReading75

    // Additional fields from merged data
    let testingPolicy: String?
    let applicationFee: String?
    let topMeritScholarship: String?
    let state: String?
    let programs: [String]

    init(from model: CollegeModel) {
        self.id = model.scorecardId.map(String.init) ?? model.name
        self.name = model.name
        self.location = [model.city, model.state].compactMap { $0 }.joined(separator: ", ")
        self.matchPercent = nil
        self.imageURL = model.imageURL
        self.websiteURL = model.websiteURL
        self.acceptanceRate = model.acceptanceRate
        self.tuition = model.inStateTuition
        self.enrollment = model.enrollment
        self.type = model.institutionType ?? "Unknown"
        self.state = model.state
        self.testingPolicy = model.testingPolicy
        self.applicationFee = model.applicationFee
        self.topMeritScholarship = model.topMeritScholarship
        self.programs = model.programs
        self.satAvg = model.satAvg

        // Composite SAT scores for match calculator
        if let m25 = model.satMath25, let r25 = model.satReading25 {
            self.sat25 = m25 + r25
        } else {
            self.sat25 = nil
        }
        if let m75 = model.satMath75, let r75 = model.satReading75 {
            self.sat75 = m75 + r75
        } else {
            self.sat75 = nil
        }

        // Build SAT range string
        if let sat25 = self.sat25, let sat75 = self.sat75 {
            self.satRange = "\(sat25)–\(sat75)"
        } else if let avg = model.satAvg {
            self.satRange = "\(avg)"
        } else {
            self.satRange = nil
        }

        // Build tags
        var t: [String] = []
        if let type = model.institutionType { t.append(type) }
        if let size = model.sizeCategory { t.append(size) }
        if model.isHBCU { t.append("HBCU") }
        if model.testingPolicy?.lowercased().contains("optional") == true { t.append("Test-Optional") }
        self.tags = t
    }

    // Legacy initializer for compatibility
    init(id: String, name: String, location: String, matchPercent: Int?, imageURL: String?, websiteURL: String? = nil, tags: [String], acceptanceRate: Double?, tuition: Int?, enrollment: Int?, satRange: String?, type: String) {
        self.id = id
        self.name = name
        self.location = location
        self.matchPercent = matchPercent
        self.imageURL = imageURL
        self.websiteURL = websiteURL
        self.tags = tags
        self.acceptanceRate = acceptanceRate
        self.tuition = tuition
        self.enrollment = enrollment
        self.satRange = satRange
        self.type = type
        self.satAvg = nil
        self.sat25 = nil
        self.sat75 = nil
        self.testingPolicy = nil
        self.applicationFee = nil
        self.topMeritScholarship = nil
        self.state = nil
        self.programs = []
    }

    // Fallback for screens that reference sample data
    static var sampleColleges: [CollegeListItem] {
        CollegeScorecardService.bundledTopColleges
    }
}
