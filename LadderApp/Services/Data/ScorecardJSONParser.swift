import Foundation

// MARK: - College Scorecard JSON Parser
// Parses the 6,322-school JSON from College Scorecard API

struct ParsedScorecardSchool {
    var scorecardId: Int
    var name: String
    var alias: String?
    var city: String?
    var state: String?
    var zip: String?
    var websiteURL: String?
    var ownership: Int? // 1=public, 2=private nonprofit, 3=for-profit
    var locale: Int?
    var carnegieBasic: Int?
    var accreditor: String?
    var isHBCU: Bool
    var admissionRate: Double?
    var satAvg: Int?
    var satReading25: Int?
    var satReading75: Int?
    var satMath25: Int?
    var satMath75: Int?
    var actCumulative25: Int?
    var actCumulative75: Int?
    var enrollment: Int?
    var tuitionInState: Int?
    var tuitionOutState: Int?
    var roomAndBoard: Int?
    var avgNetPrice: Int?
    var pellRate: Double?
    var medianDebt: Int?
    var completionRate: Double?
    var medianEarnings: Int?
    var latitude: Double?
    var longitude: Double?

    var institutionType: String {
        switch ownership {
        case 1: return "Public"
        case 2: return "Private nonprofit"
        case 3: return "Private for-profit"
        default: return "Unknown"
        }
    }

    var sizeCategory: String {
        guard let e = enrollment else { return "Unknown" }
        if e < 5000 { return "Small" }
        if e < 15000 { return "Medium" }
        return "Large"
    }
}

final class ScorecardJSONParser {

    func parse(from bundleFilename: String = "scorecard_all_schools") -> [ParsedScorecardSchool] {
        guard let url = Bundle.main.url(forResource: bundleFilename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("[ScorecardJSONParser] Could not load \(bundleFilename).json from bundle")
            return []
        }
        return parseData(data)
    }

    func parseData(_ data: Data) -> [ParsedScorecardSchool] {
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("[ScorecardJSONParser] Could not parse JSON array")
            return []
        }

        var schools: [ParsedScorecardSchool] = []

        for obj in jsonArray {
            guard let id = obj["id"] as? Int,
                  let name = obj["school.name"] as? String else { continue }

            let school = ParsedScorecardSchool(
                scorecardId: id,
                name: name,
                alias: obj["school.alias"] as? String,
                city: obj["school.city"] as? String,
                state: obj["school.state"] as? String,
                zip: obj["school.zip"] as? String,
                websiteURL: obj["school.school_url"] as? String,
                ownership: obj["school.ownership"] as? Int,
                locale: obj["school.locale"] as? Int,
                carnegieBasic: obj["school.carnegie_basic"] as? Int,
                accreditor: obj["school.accreditor"] as? String,
                isHBCU: (obj["school.minority_serving.historically_black"] as? Int) == 1,
                admissionRate: obj["latest.admissions.admission_rate.overall"] as? Double,
                satAvg: asInt(obj["latest.admissions.sat_scores.average.overall"]),
                satReading25: asInt(obj["latest.admissions.sat_scores.25th_percentile.critical_reading"]),
                satReading75: asInt(obj["latest.admissions.sat_scores.75th_percentile.critical_reading"]),
                satMath25: asInt(obj["latest.admissions.sat_scores.25th_percentile.math"]),
                satMath75: asInt(obj["latest.admissions.sat_scores.75th_percentile.math"]),
                actCumulative25: asInt(obj["latest.admissions.act_scores.25th_percentile.cumulative"]),
                actCumulative75: asInt(obj["latest.admissions.act_scores.75th_percentile.cumulative"]),
                enrollment: asInt(obj["latest.student.size"]),
                tuitionInState: asInt(obj["latest.cost.tuition.in_state"]),
                tuitionOutState: asInt(obj["latest.cost.tuition.out_of_state"]),
                roomAndBoard: asInt(obj["latest.cost.roomboard.oncampus"]),
                avgNetPrice: asInt(obj["latest.cost.avg_net_price.overall"] ?? obj["latest.cost.avg_net_price.public"] ?? obj["latest.cost.avg_net_price.private"]),
                pellRate: obj["latest.aid.pell_grant_rate"] as? Double,
                medianDebt: asInt(obj["latest.aid.median_debt.completers.overall"]),
                completionRate: obj["latest.completion.rate_suppressed.overall"] as? Double,
                medianEarnings: asInt(obj["latest.earnings.10_yrs_after_entry.median"]),
                latitude: obj["location.lat"] as? Double,
                longitude: obj["location.lon"] as? Double
            )

            schools.append(school)
        }

        print("[ScorecardJSONParser] Parsed \(schools.count) schools")
        return schools
    }

    private func asInt(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let d = value as? Double { return Int(d) }
        return nil
    }
}
