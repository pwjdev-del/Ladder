import SwiftUI
import SwiftData

// MARK: - Scholarship Match ViewModel
// Matches student profile against seeded scholarships, calculates match percentages,
// and sorts by best fit

@Observable
final class ScholarshipMatchViewModel {

    // MARK: - State

    var scholarships: [MatchedScholarship] = []
    var selectedFilter: ScholarshipMatchFilter = .all
    var isLoading: Bool = false
    var totalMatchCount: Int = 0
    var totalPotentialAmount: Int = 0
    var studentName: String = ""

    enum ScholarshipMatchFilter: String, CaseIterable {
        case all = "All"
        case highMatch = "High Match (>70%)"
        case merit = "Merit"
        case needBased = "Need-Based"
    }

    // MARK: - Matched Scholarship Model

    struct MatchedScholarship: Identifiable {
        let id = UUID()
        let scholarship: ScholarshipModel
        let matchPercent: Int
        let matchReasons: [String]
    }

    // MARK: - Filtered Results

    var filteredScholarships: [MatchedScholarship] {
        switch selectedFilter {
        case .all: return scholarships
        case .highMatch: return scholarships.filter { $0.matchPercent > 70 }
        case .merit: return scholarships.filter { $0.scholarship.isMeritBased }
        case .needBased: return scholarships.filter { $0.scholarship.isNeedBased }
        }
    }

    // MARK: - Load & Match

    @MainActor
    func loadAndMatch(profiles: [StudentProfileModel], existingScholarships: [ScholarshipModel], context: ModelContext) {
        isLoading = true

        guard let student = profiles.first else {
            isLoading = false
            return
        }

        studentName = student.firstName

        // Seed scholarships if none exist
        if existingScholarships.isEmpty {
            seedFloridaScholarships(context: context)
        }

        // Re-fetch after possible seeding
        let descriptor = FetchDescriptor<ScholarshipModel>(sortBy: [SortDescriptor(\.name)])
        let allScholarships = (try? context.fetch(descriptor)) ?? existingScholarships

        // Calculate matches
        var matched: [MatchedScholarship] = []
        for scholarship in allScholarships {
            let (percent, reasons) = calculateMatch(student: student, scholarship: scholarship)
            matched.append(MatchedScholarship(
                scholarship: scholarship,
                matchPercent: percent,
                matchReasons: reasons
            ))

            // Update the scholarship's matchPercent in SwiftData
            scholarship.matchPercent = percent
        }

        // Sort by match percentage descending
        matched.sort { $0.matchPercent > $1.matchPercent }

        scholarships = matched
        totalMatchCount = matched.filter { $0.matchPercent > 50 }.count
        totalPotentialAmount = matched.filter { $0.matchPercent > 50 }.compactMap(\.scholarship.amount).reduce(0, +)

        try? context.save()
        isLoading = false
    }

    // MARK: - Match Algorithm

    private func calculateMatch(student: StudentProfileModel, scholarship: ScholarshipModel) -> (Int, [String]) {
        var score: Double = 0
        var maxScore: Double = 0
        var reasons: [String] = []

        let gpa = student.gpa ?? 0
        let criteria = (scholarship.eligibilityCriteria ?? "").lowercased()

        // Florida residency match (weight: 25)
        maxScore += 25
        if criteria.contains("florida") || criteria.contains("fl resident") {
            if student.isFloridaResident {
                score += 25
                reasons.append("FL Resident")
            }
        } else {
            // No FL requirement = universal, give partial credit
            score += 15
        }

        // GPA match (weight: 25)
        maxScore += 25
        if criteria.contains("3.5 gpa") || criteria.contains("3.5+") {
            if gpa >= 3.5 {
                score += 25
                reasons.append("GPA \(String(format: "%.1f", gpa))")
            } else if gpa >= 3.0 {
                score += 10
            }
        } else if criteria.contains("3.0 gpa") || criteria.contains("3.0+") {
            if gpa >= 3.0 {
                score += 25
                reasons.append("GPA \(String(format: "%.1f", gpa))")
            } else if gpa >= 2.5 {
                score += 15
            }
        } else {
            // No specific GPA requirement
            if gpa >= 3.0 { score += 20 }
            else if gpa >= 2.5 { score += 15 }
            else { score += 10 }
        }

        // Need-based match (weight: 20)
        maxScore += 20
        if scholarship.isNeedBased {
            if student.freeReducedLunch || student.parentIncomeBracket == "low" {
                score += 20
                reasons.append("Need-Based")
            } else if student.parentIncomeBracket == "middle" {
                score += 10
            } else {
                score += 5
            }
        } else {
            score += 12 // neutral
        }

        // First-gen match (weight: 15)
        maxScore += 15
        if criteria.contains("first-gen") || criteria.contains("first generation") {
            if student.isFirstGen {
                score += 15
                reasons.append("First-Gen")
            }
        } else {
            score += 8 // neutral
        }

        // Career/STEM alignment (weight: 15)
        maxScore += 15
        let career = (student.careerPath ?? "").lowercased()
        if criteria.contains("stem") || criteria.contains("engineering") || criteria.contains("science") {
            if career.contains("stem") || career.contains("engineering") || career.contains("medical") {
                score += 15
                reasons.append("STEM")
            } else {
                score += 5
            }
        } else if criteria.contains("arts") || criteria.contains("humanities") {
            if career.contains("humanities") || career.contains("liberal arts") {
                score += 15
                reasons.append("Humanities")
            } else {
                score += 5
            }
        } else {
            score += 10 // neutral/general scholarship
        }

        // Merit badge
        if scholarship.isMeritBased && gpa >= 3.5 {
            reasons.append("Merit")
        }

        let percent = maxScore > 0 ? Int((score / maxScore) * 100) : 0
        return (min(percent, 100), reasons)
    }

    // MARK: - Save to Tracker

    func addToTracker(_ matched: MatchedScholarship) {
        matched.scholarship.isSaved = true
    }

    func removeFromTracker(_ matched: MatchedScholarship) {
        matched.scholarship.isSaved = false
    }

    // MARK: - Seed Florida Scholarships

    @MainActor
    private func seedFloridaScholarships(context: ModelContext) {
        let scholarshipsData: [(name: String, provider: String, amount: Int, isNeed: Bool, isMerit: Bool, criteria: String, url: String)] = [
            ("Bright Futures - Florida Academic Scholars (FAS)", "Florida DOE", 12000, false, true,
             "Florida resident, 3.5+ GPA, 1330 SAT / 29 ACT, 100 community service hours",
             "https://www.floridastudentfinancialaidsg.org/SAPBF"),
            ("Bright Futures - Florida Medallion Scholars (FMS)", "Florida DOE", 8000, false, true,
             "Florida resident, 3.0+ GPA, 1210 SAT / 25 ACT, 75 community service hours",
             "https://www.floridastudentfinancialaidsg.org/SAPBF"),
            ("Benacquisto Scholarship", "Florida Prepaid", 20000, false, true,
             "Florida resident, National Merit or National Achievement Finalist, attend FL university",
             "https://www.floridastudentfinancialaidsg.org/SAPBFMF"),
            ("Jack Kent Cooke Foundation College Scholarship", "Jack Kent Cooke Foundation", 55000, true, true,
             "3.5+ GPA, first generation, financial need, exceptional academic ability",
             "https://www.jkcf.org/our-scholarships/college-scholarship-program/"),
            ("Gates Scholarship", "Bill & Melinda Gates Foundation", 50000, true, true,
             "3.3+ GPA, minority, Pell-eligible, first-gen, STEM or public service interest",
             "https://www.thegatesscholarship.org"),
            ("Florida Student Assistance Grant (FSAG)", "Florida DOE", 5000, true, false,
             "Florida resident, financial need, enrolled in eligible FL institution",
             "https://www.floridastudentfinancialaidsg.org/SAPFSAG"),
            ("Jose Marti Scholarship", "Florida DOE", 2000, true, false,
             "Florida resident, Hispanic heritage, 3.0+ GPA, financial need",
             "https://www.floridastudentfinancialaidsg.org/SAPJM"),
            ("First Generation Matching Grant (FGMG)", "Florida DOE", 4000, true, false,
             "Florida resident, first generation college student, financial need",
             "https://www.floridastudentfinancialaidsg.org/SAPFGMG"),
            ("Dell Scholars Program", "Michael & Susan Dell Foundation", 20000, true, true,
             "2.4+ GPA, Pell-eligible, first-gen, strong self-motivation, participate in approved program",
             "https://www.dellscholars.org"),
            ("Coca-Cola Scholars Program", "Coca-Cola Scholars Foundation", 20000, false, true,
             "3.0+ GPA, strong leadership, community involvement, US citizen or permanent resident",
             "https://www.coca-colascholarsfoundation.org"),
            ("QuestBridge National College Match", "QuestBridge", 40000, true, true,
             "Low-income household, strong academics, attend partner university, first-gen preferred",
             "https://www.questbridge.org"),
            ("Elks National Foundation Most Valuable Student", "Elks National Foundation", 12500, true, true,
             "3.0+ GPA, US citizen, financial need, leadership, community service",
             "https://www.elks.org/scholars/scholarships/MVS.cfm"),
            ("Hispanic Scholarship Fund", "Hispanic Scholarship Fund", 5000, true, true,
             "Hispanic heritage, 3.0+ GPA, US citizen or permanent resident, financial need",
             "https://www.hsf.net"),
            ("Ron Brown Scholar Program", "CAP Charitable Foundation", 40000, false, true,
             "African American, academic excellence, leadership, community service, financial need considered",
             "https://www.ronbrown.org"),
            ("Horatio Alger Scholarship", "Horatio Alger Association", 25000, true, false,
             "Financial need (family income < $55k), 2.0+ GPA, adversity, community involvement, US citizen",
             "https://scholars.horatioalger.org"),
            ("Florida Prepaid Scholarship (Stanley G. Tate)", "Florida Prepaid", 6000, true, true,
             "Florida resident, 3.0+ GPA, complete FL Prepaid plan, financial need considered",
             "https://www.myfloridaprepaid.com"),
            ("National Merit Scholarship", "National Merit Scholarship Corp", 10000, false, true,
             "PSAT/NMSQT score in top 1%, strong academics, semifinalist/finalist status",
             "https://www.nationalmerit.org"),
            ("Amazon Future Engineer Scholarship", "Amazon", 40000, false, true,
             "STEM interest, computer science focus, 3.0+ GPA, financial need considered, plans to study CS",
             "https://www.amazonfutureengineer.com"),
        ]

        let calendar = Calendar.current
        for (index, data) in scholarshipsData.enumerated() {
            let scholarship = ScholarshipModel(name: data.name)
            scholarship.provider = data.provider
            scholarship.amount = data.amount
            scholarship.isNeedBased = data.isNeed
            scholarship.isMeritBased = data.isMerit
            scholarship.eligibilityCriteria = data.criteria
            scholarship.url = data.url
            // Stagger deadlines throughout the year
            let monthOffset = (index % 12) + 1
            scholarship.deadline = calendar.date(from: DateComponents(year: 2026, month: monthOffset, day: 15))
            context.insert(scholarship)
        }

        try? context.save()
    }
}
