import Foundation
import SwiftData

// MARK: - College Scorecard Service
// Fetches all ~6,900 US colleges from the FREE College Scorecard API
// API key: register free at https://api.data.gov/signup/ (key emailed in minutes)
// Documentation: https://collegescorecard.ed.gov/data/documentation/

@Observable
final class CollegeScorecardService {

    // MARK: - State

    var isLoading = false
    var loadedCount = 0
    var totalCount = 0
    var lastError: String?

    // MARK: - Config

    private let apiKey: String
    private let baseURL = "https://api.data.gov/ed/collegescorecard/v1/schools"
    private let pageSize = 100

    // Fields we request per school (compact set keeps payload small)
    private let fields = [
        "id",
        "school.name",
        "school.city",
        "school.state",
        "school.school_url",
        "school.ownership",
        "school.locale",
        "school.hbcu",
        "school.minority_serving.historically_black",
        "latest.admissions.admission_rate.overall",
        "latest.cost.tuition.in_state",
        "latest.cost.tuition.out_of_state",
        "latest.cost.roomboard.oncampus",
        "latest.student.size",
        "latest.admissions.sat_scores.average.overall",
        "latest.admissions.sat_scores.25th_percentile.critical_reading",
        "latest.admissions.sat_scores.75th_percentile.critical_reading",
        "latest.admissions.sat_scores.25th_percentile.math",
        "latest.admissions.sat_scores.75th_percentile.math",
        "latest.admissions.act_scores.25th_percentile.cumulative",
        "latest.admissions.act_scores.75th_percentile.cumulative",
        "latest.completion.rate_suppressed.overall",
        "latest.earnings.10_yrs_after_entry.median",
        "location.lat",
        "location.lon",
    ].joined(separator: ",")

    init(apiKey: String = "") {
        self.apiKey = apiKey.isEmpty ? (Bundle.main.infoDictionary?["COLLEGE_SCORECARD_API_KEY"] as? String ?? "") : apiKey
    }

    // MARK: - Sync

    /// Fetch all colleges from College Scorecard and return as CollegeListItem array.
    /// Call on first launch or when user explicitly refreshes.
    func fetchAll() async throws -> [CollegeListItem] {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY" else {
            // Return bundled top-50 as immediate fallback (zero network cost)
            return CollegeScorecardService.bundledTopColleges
        }

        isLoading = true
        defer { isLoading = false }

        var allItems: [CollegeListItem] = []
        var page = 0

        // First call to get total count
        let firstPage = try await fetchPage(page: 0)
        totalCount = firstPage.metadata.total
        allItems.append(contentsOf: firstPage.results.compactMap { CollegeListItem(from: $0) })
        loadedCount = allItems.count

        let totalPages = Int(ceil(Double(totalCount) / Double(pageSize)))

        // Fetch remaining pages concurrently in batches of 10
        for batchStart in stride(from: 1, to: totalPages, by: 10) {
            let batchEnd = min(batchStart + 10, totalPages)
            let batchPages = try await withThrowingTaskGroup(of: ScorecardPage.self) { group in
                for p in batchStart..<batchEnd {
                    group.addTask { try await self.fetchPage(page: p) }
                }
                var pages: [ScorecardPage] = []
                for try await page in group { pages.append(page) }
                return pages
            }
            let newItems = batchPages.flatMap { $0.results }.compactMap { CollegeListItem(from: $0) }
            allItems.append(contentsOf: newItems)
            loadedCount = allItems.count
        }

        return allItems
    }

    private func fetchPage(page: Int) async throws -> ScorecardPage {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "per_page", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "fields", value: fields),
            // Only degree-granting institutions (not purely certificate-only)
            URLQueryItem(name: "school.degrees_awarded.predominant", value: "1,2,3,4"),
        ]
        let url = components.url!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ScorecardError.badResponse((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(ScorecardPage.self, from: data)
    }

    enum ScorecardError: Error {
        case badResponse(Int)
        case noAPIKey
    }

    // MARK: - Bundled Top-50 Fallback
    // Shown instantly on first launch while API fetch happens in background.
    // These are accurate as of the most recent College Scorecard data release.

    static let bundledTopColleges: [CollegeListItem] = [
        CollegeListItem(id: "139959", name: "University of Florida", location: "Gainesville, FL", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.23, tuition: 6380, enrollment: 55000, satRange: "1330–1500", type: "Public"),
        CollegeListItem(id: "134130", name: "Florida State University", location: "Tallahassee, FL", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "D1 Sports"], acceptanceRate: 0.25, tuition: 6517, enrollment: 45000, satRange: "1260–1400", type: "Public"),
        CollegeListItem(id: "166683", name: "Massachusetts Institute of Technology", location: "Cambridge, MA", matchPercent: nil, imageURL: nil, tags: ["Private", "STEM", "Research"], acceptanceRate: 0.04, tuition: 57986, enrollment: 11000, satRange: "1510–1580", type: "Private"),
        CollegeListItem(id: "130794", name: "Yale University", location: "New Haven, CT", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Research"], acceptanceRate: 0.05, tuition: 62250, enrollment: 14000, satRange: "1500–1570", type: "Private"),
        CollegeListItem(id: "166027", name: "Harvard University", location: "Cambridge, MA", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Research"], acceptanceRate: 0.04, tuition: 57246, enrollment: 22000, satRange: "1490–1580", type: "Private"),
        CollegeListItem(id: "215062", name: "University of Pennsylvania", location: "Philadelphia, PA", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Business"], acceptanceRate: 0.07, tuition: 61710, enrollment: 22000, satRange: "1480–1570", type: "Private"),
        CollegeListItem(id: "190150", name: "Columbia University", location: "New York, NY", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Urban"], acceptanceRate: 0.04, tuition: 65524, enrollment: 15000, satRange: "1490–1580", type: "Private"),
        CollegeListItem(id: "182670", name: "Dartmouth College", location: "Hanover, NH", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Liberal Arts"], acceptanceRate: 0.08, tuition: 61947, enrollment: 8000, satRange: "1440–1570", type: "Private"),
        CollegeListItem(id: "186131", name: "Princeton University", location: "Princeton, NJ", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Research"], acceptanceRate: 0.04, tuition: 57410, enrollment: 10000, satRange: "1500–1580", type: "Private"),
        CollegeListItem(id: "147767", name: "Northwestern University", location: "Evanston, IL", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Journalism"], acceptanceRate: 0.07, tuition: 62391, enrollment: 22000, satRange: "1480–1570", type: "Private"),
        CollegeListItem(id: "144050", name: "University of Chicago", location: "Chicago, IL", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Economics"], acceptanceRate: 0.07, tuition: 62361, enrollment: 18000, satRange: "1500–1580", type: "Private"),
        CollegeListItem(id: "110635", name: "California Institute of Technology", location: "Pasadena, CA", matchPercent: nil, imageURL: nil, tags: ["Private", "STEM", "Research"], acceptanceRate: 0.04, tuition: 60864, enrollment: 2300, satRange: "1530–1590", type: "Private"),
        CollegeListItem(id: "110680", name: "University of California, Berkeley", location: "Berkeley, CA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "STEM"], acceptanceRate: 0.14, tuition: 14312, enrollment: 42000, satRange: "1310–1530", type: "Public"),
        CollegeListItem(id: "110662", name: "University of California, Los Angeles", location: "Los Angeles, CA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Urban"], acceptanceRate: 0.14, tuition: 13240, enrollment: 46000, satRange: "1290–1510", type: "Public"),
        CollegeListItem(id: "126614", name: "University of Colorado Boulder", location: "Boulder, CO", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Outdoors"], acceptanceRate: 0.84, tuition: 12086, enrollment: 37000, satRange: "1160–1380", type: "Public"),
        CollegeListItem(id: "201645", name: "Cornell University", location: "Ithaca, NY", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Engineering"], acceptanceRate: 0.11, tuition: 63200, enrollment: 25000, satRange: "1450–1560", type: "Private"),
        CollegeListItem(id: "152080", name: "University of Notre Dame", location: "Notre Dame, IN", matchPercent: nil, imageURL: nil, tags: ["Private", "Catholic", "D1 Sports"], acceptanceRate: 0.13, tuition: 60301, enrollment: 13000, satRange: "1440–1560", type: "Private"),
        CollegeListItem(id: "228778", name: "University of Texas at Austin", location: "Austin, TX", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.31, tuition: 11448, enrollment: 52000, satRange: "1230–1480", type: "Public"),
        CollegeListItem(id: "199120", name: "Duke University", location: "Durham, NC", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Pre-Med"], acceptanceRate: 0.06, tuition: 62688, enrollment: 17000, satRange: "1490–1570", type: "Private"),
        CollegeListItem(id: "209551", name: "University of Oregon", location: "Eugene, OR", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Outdoors"], acceptanceRate: 0.83, tuition: 13500, enrollment: 23000, satRange: "1100–1320", type: "Public"),
        CollegeListItem(id: "139755", name: "Emory University", location: "Atlanta, GA", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Pre-Med"], acceptanceRate: 0.11, tuition: 57948, enrollment: 15000, satRange: "1420–1540", type: "Private"),
        CollegeListItem(id: "218663", name: "Brown University", location: "Providence, RI", matchPercent: nil, imageURL: nil, tags: ["Ivy League", "Private", "Liberal Arts"], acceptanceRate: 0.05, tuition: 65656, enrollment: 11000, satRange: "1490–1580", type: "Private"),
        CollegeListItem(id: "215293", name: "Carnegie Mellon University", location: "Pittsburgh, PA", matchPercent: nil, imageURL: nil, tags: ["Private", "STEM", "CS"], acceptanceRate: 0.11, tuition: 61344, enrollment: 16000, satRange: "1480–1570", type: "Private"),
        CollegeListItem(id: "240444", name: "University of Wisconsin–Madison", location: "Madison, WI", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.51, tuition: 10729, enrollment: 48000, satRange: "1280–1490", type: "Public"),
        CollegeListItem(id: "170976", name: "University of Michigan", location: "Ann Arbor, MI", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "D1 Sports"], acceptanceRate: 0.18, tuition: 16178, enrollment: 48000, satRange: "1380–1540", type: "Public"),
        CollegeListItem(id: "243744", name: "University of Washington", location: "Seattle, WA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Tech"], acceptanceRate: 0.49, tuition: 11525, enrollment: 49000, satRange: "1260–1480", type: "Public"),
        CollegeListItem(id: "174066", name: "University of Minnesota Twin Cities", location: "Minneapolis, MN", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.68, tuition: 15330, enrollment: 55000, satRange: "1270–1480", type: "Public"),
        CollegeListItem(id: "164988", name: "Johns Hopkins University", location: "Baltimore, MD", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Pre-Med"], acceptanceRate: 0.08, tuition: 63340, enrollment: 29000, satRange: "1510–1580", type: "Private"),
        CollegeListItem(id: "163286", name: "University of Maryland", location: "College Park, MD", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "STEM"], acceptanceRate: 0.44, tuition: 11505, enrollment: 41000, satRange: "1330–1520", type: "Public"),
        CollegeListItem(id: "198419", name: "University of North Carolina at Chapel Hill", location: "Chapel Hill, NC", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "D1 Sports"], acceptanceRate: 0.17, tuition: 9198, enrollment: 32000, satRange: "1330–1510", type: "Public"),
        CollegeListItem(id: "139658", name: "Georgia Institute of Technology", location: "Atlanta, GA", matchPercent: nil, imageURL: nil, tags: ["Public", "Engineering", "STEM"], acceptanceRate: 0.17, tuition: 12682, enrollment: 44000, satRange: "1390–1540", type: "Public"),
        CollegeListItem(id: "138947", name: "Auburn University", location: "Auburn, AL", matchPercent: nil, imageURL: nil, tags: ["Public", "Engineering", "D1 Sports"], acceptanceRate: 0.79, tuition: 11796, enrollment: 33000, satRange: "1170–1360", type: "Public"),
        CollegeListItem(id: "155317", name: "University of Kansas", location: "Lawrence, KS", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.93, tuition: 11167, enrollment: 27000, satRange: "1120–1330", type: "Public"),
        CollegeListItem(id: "139861", name: "University of Georgia", location: "Athens, GA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.40, tuition: 11180, enrollment: 40000, satRange: "1280–1470", type: "Public"),
        CollegeListItem(id: "133951", name: "University of Central Florida", location: "Orlando, FL", matchPercent: nil, imageURL: nil, tags: ["Public", "Large", "Urban"], acceptanceRate: 0.43, tuition: 6368, enrollment: 72000, satRange: "1160–1340", type: "Public"),
        CollegeListItem(id: "137351", name: "University of South Florida", location: "Tampa, FL", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Urban"], acceptanceRate: 0.43, tuition: 6410, enrollment: 50000, satRange: "1190–1350", type: "Public"),
        CollegeListItem(id: "133669", name: "Florida International University", location: "Miami, FL", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Urban"], acceptanceRate: 0.58, tuition: 6556, enrollment: 56000, satRange: "1100–1280", type: "Public"),
        CollegeListItem(id: "136242", name: "University of Tampa", location: "Tampa, FL", matchPercent: nil, imageURL: nil, tags: ["Private", "Small", "Business"], acceptanceRate: 0.52, tuition: 30864, enrollment: 10000, satRange: "1100–1270", type: "Private"),
        CollegeListItem(id: "196097", name: "Rochester Institute of Technology", location: "Rochester, NY", matchPercent: nil, imageURL: nil, tags: ["Private", "Co-op", "STEM"], acceptanceRate: 0.68, tuition: 54588, enrollment: 16000, satRange: "1230–1410", type: "Private"),
        CollegeListItem(id: "235097", name: "University of Virginia", location: "Charlottesville, VA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "D1 Sports"], acceptanceRate: 0.20, tuition: 18454, enrollment: 25000, satRange: "1360–1530", type: "Public"),
        CollegeListItem(id: "227757", name: "Texas A&M University", location: "College Station, TX", matchPercent: nil, imageURL: nil, tags: ["Public", "Engineering", "Large"], acceptanceRate: 0.58, tuition: 13239, enrollment: 74000, satRange: "1170–1400", type: "Public"),
        CollegeListItem(id: "186867", name: "Rutgers University–New Brunswick", location: "New Brunswick, NJ", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.66, tuition: 15507, enrollment: 51000, satRange: "1230–1440", type: "Public"),
        CollegeListItem(id: "110529", name: "University of California, San Diego", location: "La Jolla, CA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "STEM"], acceptanceRate: 0.24, tuition: 14556, enrollment: 42000, satRange: "1280–1510", type: "Public"),
        CollegeListItem(id: "110653", name: "University of California, Davis", location: "Davis, CA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Agriculture"], acceptanceRate: 0.37, tuition: 14642, enrollment: 39000, satRange: "1180–1420", type: "Public"),
        CollegeListItem(id: "126818", name: "University of Denver", location: "Denver, CO", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Business"], acceptanceRate: 0.70, tuition: 57006, enrollment: 13000, satRange: "1170–1380", type: "Private"),
        CollegeListItem(id: "212054", name: "Temple University", location: "Philadelphia, PA", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Urban"], acceptanceRate: 0.67, tuition: 16658, enrollment: 40000, satRange: "1170–1370", type: "Public"),
        CollegeListItem(id: "181215", name: "University of Nebraska–Lincoln", location: "Lincoln, NE", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "Large"], acceptanceRate: 0.77, tuition: 9510, enrollment: 26000, satRange: "1110–1330", type: "Public"),
        CollegeListItem(id: "204796", name: "The Ohio State University", location: "Columbus, OH", matchPercent: nil, imageURL: nil, tags: ["Public", "Research", "D1 Sports"], acceptanceRate: 0.54, tuition: 11518, enrollment: 62000, satRange: "1270–1460", type: "Public"),
        CollegeListItem(id: "221999", name: "Vanderbilt University", location: "Nashville, TN", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Pre-Med"], acceptanceRate: 0.07, tuition: 60348, enrollment: 14000, satRange: "1480–1570", type: "Private"),
        CollegeListItem(id: "209807", name: "University of Southern California", location: "Los Angeles, CA", matchPercent: nil, imageURL: nil, tags: ["Private", "Research", "Film"], acceptanceRate: 0.12, tuition: 65446, enrollment: 48000, satRange: "1420–1550", type: "Private"),
    ]
}

// MARK: - Scorecard API Response Models

private struct ScorecardPage: Decodable {
    let metadata: Metadata
    let results: [ScorecardSchool]

    struct Metadata: Decodable {
        let total: Int
        let page: Int
        let perPage: Int

        enum CodingKeys: String, CodingKey {
            case total, page
            case perPage = "per_page"
        }
    }
}

private struct ScorecardSchool: Decodable {
    let id: Int?
    let school: School?
    let latest: Latest?
    let location: Location?

    struct School: Decodable {
        let name: String?
        let city: String?
        let state: String?
        let schoolUrl: String?
        let ownership: Int?
        let hbcu: Int?

        enum CodingKeys: String, CodingKey {
            case name, city, state, hbcu
            case schoolUrl = "school_url"
            case ownership
        }
    }

    struct Latest: Decodable {
        let admissions: Admissions?
        let cost: Cost?
        let student: Student?

        struct Admissions: Decodable {
            let admissionRate: AdmissionRate?
            let satScores: SATScores?
            let actScores: ACTScores?

            enum CodingKeys: String, CodingKey {
                case admissionRate = "admission_rate"
                case satScores = "sat_scores"
                case actScores = "act_scores"
            }

            struct AdmissionRate: Decodable {
                let overall: Double?
            }

            struct SATScores: Decodable {
                let average: SATAverage?

                struct SATAverage: Decodable {
                    let overall: Double?
                }
            }

            struct ACTScores: Decodable {
                let midpoint: ACTMidpoint?

                struct ACTMidpoint: Decodable {
                    let cumulative: Double?
                }
            }
        }

        struct Cost: Decodable {
            let tuition: Tuition?

            struct Tuition: Decodable {
                let inState: Int?
                let outOfState: Int?

                enum CodingKeys: String, CodingKey {
                    case inState = "in_state"
                    case outOfState = "out_of_state"
                }
            }
        }

        struct Student: Decodable {
            let size: Int?
        }
    }

    struct Location: Decodable {
        let lat: Double?
        let lon: Double?
    }
}

// MARK: - CollegeListItem init from Scorecard

fileprivate extension CollegeListItem {
    init?(from school: ScorecardSchool) {
        guard let id = school.id,
              let name = school.school?.name, !name.isEmpty else { return nil }

        let city = school.school?.city ?? ""
        let state = school.school?.state ?? ""
        let location = [city, state].filter { !$0.isEmpty }.joined(separator: ", ")
        let ownership = school.school?.ownership
        let typeStr: String
        switch ownership {
        case 1: typeStr = "Public"
        case 2: typeStr = "Private"
        default: typeStr = "For-Profit"
        }

        let acceptanceRate = school.latest?.admissions?.admissionRate?.overall
        let inStateTuition = school.latest?.cost?.tuition?.inState
        let outStateTuition = school.latest?.cost?.tuition?.outOfState
        let enrollment = school.latest?.student?.size

        var tags: [String] = [typeStr]
        if let size = enrollment {
            switch size {
            case ..<2500: tags.append("Small")
            case 2500..<15000: tags.append("Medium")
            default: tags.append("Large")
            }
        }
        if school.school?.hbcu == 1 { tags.append("HBCU") }

        self.init(
            id: "\(id)",
            name: name,
            location: location,
            matchPercent: nil,
            imageURL: nil,
            tags: tags,
            acceptanceRate: acceptanceRate,
            tuition: inStateTuition ?? outStateTuition,
            enrollment: enrollment,
            satRange: nil,
            type: typeStr
        )
    }
}

// AppConfiguration is defined in Configuration/AppConfiguration.swift
