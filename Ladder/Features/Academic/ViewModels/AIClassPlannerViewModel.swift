import SwiftUI
import SwiftData

// MARK: - AI Class Planner ViewModel
// Loads student data from SwiftData and generates schedule recommendations

@Observable
final class AIClassPlannerViewModel {

    var recommendation: ScheduleRecommendation?
    var studentGrade: Int = 11
    var studentGPA: Double = 3.5
    var studentCareer: String = "General"
    var studentName: String = ""
    var isFloridaResident: Bool = false
    var completedCourses: [String] = []
    var isLoading: Bool = false
    var showSubmitAlert: Bool = false
    var showSavedAlert: Bool = false
    var showSwapSheet: Bool = false
    var selectedPeriod: Int? = nil
    var swapAlternatives: [ClassRecommendation] = []

    private let engine = ClassScheduleAIEngine()

    // MARK: - Load Student Data

    func loadStudent(from profiles: [StudentProfileModel]) {
        guard let student = profiles.first else { return }

        studentGrade = student.grade
        studentGPA = student.gpa ?? 3.0
        studentCareer = student.careerPath ?? "General"
        studentName = student.firstName
        isFloridaResident = student.isFloridaResident
        completedCourses = student.apCourses

        generateSchedule()
    }

    // MARK: - Generate Schedule

    func generateSchedule() {
        isLoading = true

        // Simulate brief loading for polish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            recommendation = engine.generateRecommendation(
                grade: studentGrade,
                careerPath: studentCareer,
                currentGPA: studentGPA,
                completedCourses: completedCourses,
                isFloridaResident: isFloridaResident
            )
            isLoading = false
        }
    }

    // MARK: - Swap Alternatives

    func showAlternatives(for period: Int) {
        selectedPeriod = period
        guard let current = recommendation?.classes.first(where: { $0.period == period }) else { return }

        // Generate alternatives based on subject area
        swapAlternatives = generateAlternatives(for: current)
        showSwapSheet = true
    }

    func swapClass(with alternative: ClassRecommendation) {
        guard let period = selectedPeriod,
              var classes = recommendation?.classes else { return }

        if let index = classes.firstIndex(where: { $0.period == period }) {
            classes[index] = ClassRecommendation(
                period: period,
                className: alternative.className,
                reason: alternative.reason,
                isAP: alternative.isAP,
                isHonors: alternative.isHonors,
                prerequisiteMet: alternative.prerequisiteMet,
                subjectArea: alternative.subjectArea
            )

            recommendation = ScheduleRecommendation(
                semester: recommendation?.semester ?? "",
                classes: classes,
                totalAPs: classes.filter(\.isAP).count,
                totalHonors: classes.filter(\.isHonors).count,
                meetsGradRequirements: recommendation?.meetsGradRequirements ?? true,
                brightFuturesProgress: recommendation?.brightFuturesProgress
            )
        }
        showSwapSheet = false
    }

    // MARK: - Save Draft

    func saveDraft() {
        guard let rec = recommendation else { return }
        let data = rec.classes.map { "\($0.period)|\($0.className)|\($0.isAP)|\($0.isHonors)" }
        UserDefaults.standard.set(data, forKey: "savedClassPlanDraft")
        UserDefaults.standard.set(rec.semester, forKey: "savedClassPlanSemester")
        showSavedAlert = true
    }

    // MARK: - Submit to Counselor

    func submitToCounselor() {
        showSubmitAlert = true
    }

    // MARK: - Helpers

    var semesterLabel: String {
        recommendation?.semester ?? "Fall 2026"
    }

    var gpaFormatted: String {
        String(format: "%.1f", studentGPA)
    }

    var summaryText: String {
        guard let rec = recommendation else { return "" }
        var parts: [String] = []
        if rec.totalAPs > 0 { parts.append("\(rec.totalAPs) AP \(rec.totalAPs == 1 ? "Class" : "Classes")") }
        if rec.totalHonors > 0 { parts.append("\(rec.totalHonors) Honors") }
        if rec.meetsGradRequirements { parts.append("Meets FL graduation reqs") }
        return parts.joined(separator: "  |  ")
    }

    // MARK: - Alternative Generation

    private func generateAlternatives(for current: ClassRecommendation) -> [ClassRecommendation] {
        let area = current.subjectArea
        var alts: [ClassRecommendation] = []

        switch area {
        case "English":
            alts = [
                makeAlt(current.period, "Creative Writing", "Develops unique voice for college essays.", false, false, area),
                makeAlt(current.period, "Journalism", "Builds real-world writing skills and deadline management.", false, false, area),
                makeAlt(current.period, "AP English Literature", "Deep literary analysis for humanities-focused students.", true, false, area)
            ]
        case "Math":
            alts = [
                makeAlt(current.period, "AP Statistics", "Data analysis skills valued across all career fields.", true, false, area),
                makeAlt(current.period, "Algebra 2 Honors", "Solid math foundation without the calculus leap.", false, true, area),
                makeAlt(current.period, "Financial Mathematics", "Practical math skills for budgeting and real-world applications.", false, false, area)
            ]
        case "Science":
            alts = [
                makeAlt(current.period, "Marine Science", "Florida-relevant science with field research opportunities.", false, false, area),
                makeAlt(current.period, "Anatomy & Physiology", "Ideal for healthcare-bound students.", false, true, area),
                makeAlt(current.period, "AP Environmental Science", "Interdisciplinary AP with strong pass rates.", true, false, area)
            ]
        case "Social Studies":
            alts = [
                makeAlt(current.period, "AP Psychology", "One of the most popular and approachable AP exams.", true, false, area),
                makeAlt(current.period, "Economics Honors", "Essential financial literacy and market understanding.", false, true, area),
                makeAlt(current.period, "Sociology", "Understanding social structures and human behavior.", false, false, area)
            ]
        default:
            alts = [
                makeAlt(current.period, "Speech & Debate", "Develops public speaking skills valued in every career.", false, false, "Elective"),
                makeAlt(current.period, "Digital Media", "Tech-savvy creative skills for the modern workplace.", false, false, "Elective"),
                makeAlt(current.period, "Peer Mentoring", "Leadership experience that stands out on applications.", false, false, "Elective")
            ]
        }

        // Remove the current class from alternatives
        return alts.filter { $0.className != current.className }
    }

    private func makeAlt(_ period: Int, _ name: String, _ reason: String, _ isAP: Bool, _ isHonors: Bool, _ area: String) -> ClassRecommendation {
        ClassRecommendation(period: period, className: name, reason: reason, isAP: isAP, isHonors: isHonors, prerequisiteMet: true, subjectArea: area)
    }
}
