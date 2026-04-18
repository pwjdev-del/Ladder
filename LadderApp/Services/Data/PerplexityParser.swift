import Foundation

// MARK: - Perplexity Database Parser
// Parses the 129K-line research database with 3 format variants

struct ParsedSchool {
    var name: String
    var dataSource: String? // "browse" or "research"
    var sourceURL: String?

    // Admissions process
    var applicationFee: String?
    var feeWaiverAvailable: String?
    var applicationPlatforms: String?
    var testingPolicy: String?
    var supplementalEssaysCount: String?
    var recommendationLetters: String?
    var interviewPolicy: String?
    var demonstratedInterest: String?
    var transcriptMethod: String?
    var selfReportedGrades: String?
    var cssProfileRequired: String?

    // Deadlines
    var edDeadline: String?
    var eaDeadline: String?
    var rdDeadline: String?
    var priorityDeadline: String?
    var faPriorityDeadline: String?

    // Enrollment
    var enrollmentDeposit: String?
    var depositDeadline: String?
    var housingDeposit: String?
    var housingDeadline: String?
    var orientationRequired: String?
    var orientationCost: String?
    var immunizationsRequired: String?
    var placementTests: String?

    // Merit
    var topMeritScholarship: String?
    var meritScholarshipAmount: String?
    var meritCriteria: String?

    // Open admissions
    var openAdmissions: String?

    // State (inferred)
    var state: String?
}

final class PerplexityParser {

    // Field name normalization mapping — maps all variants to canonical names
    private static let fieldMapping: [String: String] = [
        // Application
        "application_fee": "applicationFee",
        "app_fee": "applicationFee",
        "fee_waiver_available": "feeWaiverAvailable",
        "fee_waiver": "feeWaiverAvailable",
        "application_platforms": "applicationPlatforms",
        "platforms": "applicationPlatforms",
        "testing_policy": "testingPolicy",
        "testing": "testingPolicy",
        "supplemental_essays_count": "supplementalEssaysCount",
        "supplemental_essays": "supplementalEssaysCount",
        "supp_essays": "supplementalEssaysCount",
        "recommendation_letters_required": "recommendationLetters",
        "recommendation_letters": "recommendationLetters",
        "rec_letters": "recommendationLetters",
        "interview_policy": "interviewPolicy",
        "demonstrated_interest": "demonstratedInterest",
        "transcript_method": "transcriptMethod",
        "self_reported_grades": "selfReportedGrades",
        "css_profile_required": "cssProfileRequired",
        "css_profile": "cssProfileRequired",
        "css": "cssProfileRequired",

        // Deadlines
        "ed_deadline": "edDeadline",
        "ed": "edDeadline",
        "ed1": "edDeadline",
        "ea_deadline": "eaDeadline",
        "ea": "eaDeadline",
        "rd_deadline": "rdDeadline",
        "rd": "rdDeadline",
        "priority_deadline": "priorityDeadline",
        "fa_priority_deadline": "faPriorityDeadline",

        // Enrollment
        "enrollment_deposit": "enrollmentDeposit",
        "deposit": "enrollmentDeposit",
        "deposit_deadline": "depositDeadline",
        "dep_deadline": "depositDeadline",
        "housing_deposit": "housingDeposit",
        "housing_deadline": "housingDeadline",
        "orientation_required": "orientationRequired",
        "orientation_cost": "orientationCost",
        "immunizations_required": "immunizationsRequired",
        "immunizations": "immunizationsRequired",
        "placement_tests": "placementTests",

        // Merit
        "top_merit_scholarship": "topMeritScholarship",
        "top_scholarship": "topMeritScholarship",
        "merit_scholarship_amount": "meritScholarshipAmount",
        "merit_amount": "meritScholarshipAmount",
        "merit_criteria": "meritCriteria",

        // Meta
        "data_source": "dataSource",
        "source_url": "sourceURL",
        "school_name": "schoolName",
        "school": "schoolName",
        "open_admissions": "openAdmissions",
        "sources": "sources",
    ]

    func parse(from bundleFilename: String = "ladder_master_college_database") -> [ParsedSchool] {
        guard let url = Bundle.main.url(forResource: bundleFilename, withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("[PerplexityParser] Could not load \(bundleFilename).txt from bundle")
            return []
        }
        return parseContent(content)
    }

    func parseContent(_ content: String) -> [ParsedSchool] {
        var schools: [ParsedSchool] = []
        let lines = content.components(separatedBy: "\n")

        var currentBlock: [(String, String)] = []
        var currentName: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // School block delimiter
            if trimmed.hasPrefix("=== ") && trimmed.hasSuffix(" ===") {
                // Save previous block
                if let name = currentName {
                    if let school = buildSchool(name: name, fields: currentBlock) {
                        schools.append(school)
                    }
                }

                // Start new block
                let rawName = String(trimmed.dropFirst(4).dropLast(4))

                // Skip Section 2 scorecard entries
                if rawName.hasPrefix("SCORECARD:") {
                    currentName = nil
                    currentBlock = []
                    continue
                }

                currentName = rawName
                currentBlock = []
                continue
            }

            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Parse key: value
            if let colonIndex = trimmed.firstIndex(of: ":"), currentName != nil {
                let key = String(trimmed[trimmed.startIndex..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                if !key.isEmpty && !value.isEmpty {
                    currentBlock.append((key, value))
                }
            }
        }

        // Don't forget last block
        if let name = currentName {
            if let school = buildSchool(name: name, fields: currentBlock) {
                schools.append(school)
            }
        }

        print("[PerplexityParser] Parsed \(schools.count) schools")
        return schools
    }

    private func buildSchool(name: String, fields: [(String, String)]) -> ParsedSchool? {
        var school = ParsedSchool(name: name)

        for (rawKey, value) in fields {
            let normalizedKey = Self.fieldMapping[rawKey] ?? rawKey

            // Strip markdown link citations like [text](url) from values
            let cleanValue = stripCitations(value)

            switch normalizedKey {
            case "dataSource": school.dataSource = cleanValue
            case "sourceURL": school.sourceURL = cleanValue
            case "applicationFee": school.applicationFee = cleanValue
            case "feeWaiverAvailable": school.feeWaiverAvailable = cleanValue
            case "applicationPlatforms": school.applicationPlatforms = cleanValue
            case "testingPolicy": school.testingPolicy = cleanValue
            case "supplementalEssaysCount": school.supplementalEssaysCount = cleanValue
            case "recommendationLetters": school.recommendationLetters = cleanValue
            case "interviewPolicy": school.interviewPolicy = cleanValue
            case "demonstratedInterest": school.demonstratedInterest = cleanValue
            case "transcriptMethod": school.transcriptMethod = cleanValue
            case "selfReportedGrades": school.selfReportedGrades = cleanValue
            case "cssProfileRequired": school.cssProfileRequired = cleanValue
            case "edDeadline": school.edDeadline = cleanValue
            case "eaDeadline": school.eaDeadline = cleanValue
            case "rdDeadline": school.rdDeadline = cleanValue
            case "priorityDeadline": school.priorityDeadline = cleanValue
            case "faPriorityDeadline": school.faPriorityDeadline = cleanValue
            case "enrollmentDeposit": school.enrollmentDeposit = cleanValue
            case "depositDeadline": school.depositDeadline = cleanValue
            case "housingDeposit": school.housingDeposit = cleanValue
            case "housingDeadline": school.housingDeadline = cleanValue
            case "orientationRequired": school.orientationRequired = cleanValue
            case "orientationCost": school.orientationCost = cleanValue
            case "immunizationsRequired": school.immunizationsRequired = cleanValue
            case "placementTests": school.placementTests = cleanValue
            case "topMeritScholarship": school.topMeritScholarship = cleanValue
            case "meritScholarshipAmount": school.meritScholarshipAmount = cleanValue
            case "meritCriteria": school.meritCriteria = cleanValue
            case "openAdmissions": school.openAdmissions = cleanValue
            default: break
            }
        }

        return school
    }

    private func stripCitations(_ text: String) -> String {
        // Remove markdown links like [text](url) — keep just the main content before first [
        // Also remove trailing source references
        var result = text
        // Remove inline markdown links: [Label](URL)
        while let openBracket = result.range(of: " ([") ?? result.range(of: " [") {
            if let closeParen = result[openBracket.lowerBound...].range(of: ")") {
                result.removeSubrange(openBracket.lowerBound..<closeParen.upperBound)
            } else {
                break
            }
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
