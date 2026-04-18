import SwiftUI

// MARK: - Activity Impact ViewModel

@Observable
final class ActivityImpactViewModel {

    // MARK: - Input Fields

    var activityName = ""
    var role = ""
    var hoursPerWeek = ""
    var weeksPerYear = ""
    var description = ""

    // MARK: - Output

    var generatedStatement = ""
    var isGenerating = false
    var hasGenerated = false
    var characterCount: Int { generatedStatement.count }

    // MARK: - Validation

    var isFormValid: Bool {
        !activityName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var durationLabel: String {
        let hours = Int(hoursPerWeek) ?? 0
        let weeks = Int(weeksPerYear) ?? 0
        if hours > 0 && weeks > 0 {
            return "\(hours) hr/wk, \(weeks) wk/yr"
        }
        return ""
    }

    // MARK: - Generate Impact Statement

    func generateImpactStatement() {
        guard isFormValid else { return }
        isGenerating = true

        // Simulated AI generation
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))

            let name = activityName
            let desc = description.trimmingCharacters(in: .whitespacesAndNewlines)

            // Smart mock generation based on input
            if desc.lowercased().contains("hospital") || desc.lowercased().contains("patient") || desc.lowercased().contains("health") {
                generatedStatement = "Provided compassionate support to 40+ patients weekly across 3 departments, improving care coordination and earning recognition from nursing staff."
            } else if desc.lowercased().contains("tutor") || desc.lowercased().contains("teach") || desc.lowercased().contains("mentor") {
                generatedStatement = "Mentored 25+ underclassmen in STEM subjects, raising average test scores by 15% and developing curriculum materials adopted school-wide."
            } else if desc.lowercased().contains("code") || desc.lowercased().contains("app") || desc.lowercased().contains("software") {
                generatedStatement = "Designed and launched a mobile app serving 500+ users, leading a 4-person dev team and presenting at the district technology showcase."
            } else if desc.lowercased().contains("captain") || desc.lowercased().contains("sport") || desc.lowercased().contains("team") {
                generatedStatement = "Led varsity \(name.lowercased()) team to regional finals as captain, coordinating practices for 20+ athletes and improving team cohesion."
            } else if desc.lowercased().contains("debate") || desc.lowercased().contains("speech") || desc.lowercased().contains("model un") {
                generatedStatement = "Advanced to state finals in \(name), mentoring 12 novice members and pioneering a weekly practice workshop series."
            } else {
                generatedStatement = "Spearheaded initiatives within \(name) as \(role.isEmpty ? "member" : role), driving measurable outcomes and building skills directly aligned with academic goals."
            }

            // Trim to 150 chars if needed
            if generatedStatement.count > 150 {
                generatedStatement = String(generatedStatement.prefix(147)) + "..."
            }

            isGenerating = false
            hasGenerated = true
        }
    }

    func regenerate() {
        hasGenerated = false
        generateImpactStatement()
    }

    func reset() {
        generatedStatement = ""
        hasGenerated = false
    }
}
