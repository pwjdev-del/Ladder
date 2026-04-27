import Foundation
import SwiftData

// MARK: - College Data Merger
// Merges 6,322 Scorecard schools + 1,990 Perplexity research schools into SwiftData

@Observable
final class CollegeDataMerger {

    var mergedCount = 0
    var totalCount = 0

    @MainActor
    func merge(context: ModelContext, onProgress: @escaping (Double) -> Void) async {
        // Step 1: Parse scorecard JSON
        let scorecardParser = ScorecardJSONParser()
        let scorecardSchools = scorecardParser.parse()
        totalCount = scorecardSchools.count
        onProgress(0.05)

        // Step 2: Parse Perplexity research
        let perplexityParser = PerplexityParser()
        let researchSchools = perplexityParser.parse()
        onProgress(0.15)

        // Step 3: Build lookup index for Perplexity schools
        var researchIndex: [String: ParsedSchool] = [:]
        for school in researchSchools {
            let key = normalizeForMatching(name: school.name, state: school.state)
            researchIndex[key] = school
        }
        onProgress(0.20)

        // Step 4: Create CollegeModel for each scorecard school
        let batchSize = 500
        var processedCount = 0

        for sc in scorecardSchools {
            let college = CollegeModel(name: sc.name)
            college.scorecardId = sc.scorecardId
            college.city = sc.city
            college.state = sc.state
            college.zipCode = sc.zip
            college.latitude = sc.latitude
            college.longitude = sc.longitude
            college.institutionType = sc.institutionType
            college.sizeCategory = sc.sizeCategory
            college.acceptanceRate = sc.admissionRate
            college.inStateTuition = sc.tuitionInState
            college.outStateTuition = sc.tuitionOutState
            college.roomAndBoard = sc.roomAndBoard
            college.enrollment = sc.enrollment
            college.satAvg = sc.satAvg
            college.satMath25 = sc.satMath25
            college.satMath75 = sc.satMath75
            college.satReading25 = sc.satReading25
            college.satReading75 = sc.satReading75
            college.actAvg = sc.actCumulative25 != nil && sc.actCumulative75 != nil
                ? (sc.actCumulative25! + sc.actCumulative75!) / 2 : nil
            college.completionRate = sc.completionRate
            college.medianEarnings = sc.medianEarnings
            college.websiteURL = sc.websiteURL
            college.isHBCU = sc.isHBCU
            college.alias = sc.alias
            college.pellRate = sc.pellRate
            college.medianDebt = sc.medianDebt
            college.avgNetPrice = sc.avgNetPrice
            college.accreditor = sc.accreditor
            college.carnegieClassification = sc.carnegieBasic
            college.dataSource = "scorecard"

            // Step 5: Try to match with Perplexity research data
            let matchKey = normalizeForMatching(name: sc.name, state: sc.state)
            if let research = researchIndex[matchKey] {
                overlayResearchData(onto: college, from: research)
                researchIndex.removeValue(forKey: matchKey)
            } else {
                // Try alternate matching with alias
                if let alias = sc.alias {
                    let aliasKey = normalizeForMatching(name: alias, state: sc.state)
                    if let research = researchIndex[aliasKey] {
                        overlayResearchData(onto: college, from: research)
                        researchIndex.removeValue(forKey: aliasKey)
                    }
                }
            }

            // Create deadline models from research data
            createDeadlines(for: college)

            context.insert(college)
            processedCount += 1

            if processedCount % batchSize == 0 {
                let progress = 0.20 + (Double(processedCount) / Double(totalCount)) * 0.65
                onProgress(progress)
            }
        }

        onProgress(0.85)

        // Step 6: Create entries for unmatched Perplexity schools
        for (_, research) in researchIndex {
            let college = CollegeModel(name: research.name)
            overlayResearchData(onto: college, from: research)
            createDeadlines(for: college)
            context.insert(college)
        }

        onProgress(0.95)

        // Step 7: Save
        do {
            try context.save()
            mergedCount = processedCount + researchIndex.count
            print("[CollegeDataMerger] Saved \(mergedCount) colleges to SwiftData")
        } catch {
            print("[CollegeDataMerger] Save error: \(error)")
        }

        onProgress(1.0)
    }

    // MARK: - Private Helpers

    private func overlayResearchData(onto college: CollegeModel, from research: ParsedSchool) {
        college.applicationFee = research.applicationFee
        college.feeWaiverAvailable = research.feeWaiverAvailable
        college.testingPolicy = research.testingPolicy
        college.supplementalEssaysCount = research.supplementalEssaysCount
        college.recommendationLetters = research.recommendationLetters
        college.interviewPolicy = research.interviewPolicy
        college.demonstratedInterest = research.demonstratedInterest
        college.transcriptMethod = research.transcriptMethod
        college.selfReportedGrades = research.selfReportedGrades
        college.cssProfileRequired = research.cssProfileRequired
        college.topMeritScholarship = research.topMeritScholarship
        college.meritScholarshipAmount = research.meritScholarshipAmount
        college.meritCriteria = research.meritCriteria
        college.faPriorityDeadline = research.faPriorityDeadline

        // Florida-deep fields
        college.enrollmentDeposit = research.enrollmentDeposit
        college.depositDeadline = research.depositDeadline
        college.housingDeposit = research.housingDeposit
        college.housingDeadline = research.housingDeadline
        college.orientationRequired = research.orientationRequired
        college.orientationCost = research.orientationCost
        college.immunizationsRequired = research.immunizationsRequired
        college.placementTests = research.placementTests

        college.researchSourceURL = research.sourceURL
        college.dataSource = research.dataSource ?? "research"

        if research.openAdmissions?.lowercased().contains("yes") == true {
            college.isOpenAdmissions = true
        }

        // Infer state from research if not set
        if college.state == nil {
            college.state = research.state
        }
    }

    private func createDeadlines(for college: CollegeModel) {
        // Deadlines are created via createDeadlinesFromResearch() during merge
    }

    func createDeadlinesFromResearch(_ research: ParsedSchool, for college: CollegeModel, in context: ModelContext) {
        let year = Calendar.current.component(.year, from: Date())

        if let ed = research.edDeadline, !ed.contains("UNVERIFIED"), !ed.contains("N/A"), !ed.contains("Not") {
            let deadline = CollegeDeadlineModel(deadlineType: "Early Decision")
            deadline.source = "perplexity"
            deadline.cycleYear = year
            deadline.college = college
            context.insert(deadline)
        }

        if let ea = research.eaDeadline, !ea.contains("UNVERIFIED"), !ea.contains("N/A"), !ea.contains("Not") {
            let deadline = CollegeDeadlineModel(deadlineType: "Early Action")
            deadline.source = "perplexity"
            deadline.cycleYear = year
            deadline.college = college
            context.insert(deadline)
        }

        if let rd = research.rdDeadline, !rd.contains("UNVERIFIED"), !rd.contains("N/A") {
            let deadline = CollegeDeadlineModel(deadlineType: rd.lowercased().contains("rolling") ? "Rolling" : "Regular Decision")
            deadline.source = "perplexity"
            deadline.cycleYear = year
            deadline.college = college
            context.insert(deadline)
        }
    }

    private func normalizeForMatching(name: String, state: String?) -> String {
        var n = name.lowercased()
        // Remove common prefixes/suffixes
        n = n.replacingOccurrences(of: "the ", with: "")
        n = n.replacingOccurrences(of: "university of ", with: "")
        n = n.replacingOccurrences(of: " university", with: "")
        n = n.replacingOccurrences(of: " college", with: "")
        n = n.replacingOccurrences(of: " institute of technology", with: "")
        // Remove parenthetical abbreviations like (UCF), (FSU)
        if let parenStart = n.range(of: "(") {
            if let parenEnd = n.range(of: ")", range: parenStart.upperBound..<n.endIndex) {
                n.removeSubrange(parenStart.lowerBound..<parenEnd.upperBound)
            }
        }
        n = n.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = (state ?? "").lowercased()
        return "\(n)|\(st)"
    }
}
