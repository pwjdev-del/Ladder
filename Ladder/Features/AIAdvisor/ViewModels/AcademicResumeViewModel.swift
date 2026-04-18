import SwiftUI
import SwiftData

// MARK: - Academic Resume ViewModel

@Observable
final class AcademicResumeViewModel {

    // MARK: - Resume Data

    var studentName = ""
    var email = ""
    var schoolName = ""
    var gpa: String = ""
    var graduationYear = "2027"

    var apCourses: [String] = []
    var extracurriculars: [ResumeActivity] = []
    var awards: [String] = []
    var skills: [String] = []

    // Section visibility toggles
    var showEducation = true
    var showActivities = true
    var showLeadership = true
    var showAwards = true
    var showSkills = true

    // MARK: - Models

    struct ResumeActivity: Identifiable {
        let id = UUID()
        let name: String
        let role: String
        let description: String
        let years: String
    }

    // MARK: - Computed

    var resumeText: String {
        var lines: [String] = []
        lines.append(studentName)
        if !email.isEmpty { lines.append(email) }
        lines.append("")

        if showEducation {
            lines.append("EDUCATION")
            lines.append("\(schoolName) | \(graduationYear)")
            if !gpa.isEmpty { lines.append("GPA: \(gpa)") }
            if !apCourses.isEmpty {
                lines.append("AP Courses: \(apCourses.joined(separator: ", "))")
            }
            lines.append("")
        }

        if showActivities {
            lines.append("ACTIVITIES")
            for activity in extracurriculars {
                lines.append("\(activity.name) - \(activity.role) (\(activity.years))")
                lines.append(activity.description)
            }
            lines.append("")
        }

        if showAwards && !awards.isEmpty {
            lines.append("AWARDS")
            for award in awards { lines.append("- \(award)") }
            lines.append("")
        }

        if showSkills && !skills.isEmpty {
            lines.append("SKILLS")
            lines.append(skills.joined(separator: ", "))
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Load from Profile

    func loadFromProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = (try? context.fetch(descriptor))?.first else {
            loadMockData()
            return
        }

        studentName = profile.fullName
        schoolName = profile.schoolName ?? "High School"
        gpa = profile.gpa.map { String(format: "%.1f", $0) } ?? ""
        apCourses = profile.apCourses
        skills = profile.interests

        extracurriculars = profile.extracurriculars.map { name in
            ResumeActivity(name: name, role: "Member", description: "", years: "2023 - Present")
        }

        if extracurriculars.isEmpty && apCourses.isEmpty {
            loadMockData()
        }
    }

    private func loadMockData() {
        studentName = "Student Name"
        email = "student@email.com"
        schoolName = "Cypress Bay High School"
        gpa = "3.8"
        graduationYear = "2027"

        apCourses = ["AP Biology", "AP Calculus AB", "AP English Language", "AP US History"]

        extracurriculars = [
            ResumeActivity(name: "Science Club", role: "Vice President",
                           description: "Led experimental research for state competitions focused on sustainable energy.",
                           years: "2023 - Present"),
            ResumeActivity(name: "Debate Team", role: "Captain",
                           description: "Mentored 15+ students in persuasive speaking. Won Regional Finals 2025.",
                           years: "2022 - Present"),
            ResumeActivity(name: "Hospital Volunteer", role: "Volunteer",
                           description: "Provided support to 40+ patients weekly across 3 departments.",
                           years: "2024 - Present")
        ]

        awards = ["AP Scholar with Distinction", "National Honor Society", "Regional Science Fair - 2nd Place"]
        skills = ["Python", "Spanish (Fluent)", "Data Analysis", "Public Speaking"]
    }
}
