import SwiftUI

// MARK: - Graduation Tracker ViewModel
// Now uses StateRequirementsEngine for dynamic state-based requirements

@Observable
final class GraduationTrackerViewModel {

    // State-driven requirements
    private(set) var stateName: String = "Florida"
    private(set) var totalCreditsRequired: Int = 24
    private(set) var meritScholarship: StateRequirementsEngine.MeritScholarship? = nil
    private(set) var specialRules: [String] = []

    var categories: [CreditCategory] = []

    init() {
        // Default to Florida on init; call configure(for:) to update
        configure(for: "Florida")
    }

    // MARK: - Configure for State

    func configure(for state: String) {
        let engine = StateRequirementsEngine.shared
        let reqs = engine.requirements(for: state.isEmpty ? "Florida" : state)

        stateName = reqs.state
        totalCreditsRequired = reqs.graduationCredits
        meritScholarship = reqs.meritScholarship
        specialRules = reqs.specialRules

        // Build categories from state requirements, keeping any existing earned credits
        let existingEarned = Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0.earned) })

        // Sort credit requirements for consistent display
        let sorted = reqs.creditRequirements.sorted { $0.key < $1.key }
        categories = sorted.map { name, required in
            CreditCategory(
                name: name,
                earned: existingEarned[name] ?? estimateEarned(for: name, required: required),
                required: required
            )
        }
    }

    // Provide reasonable default earned credits for demo purposes
    private func estimateEarned(for name: String, required: Int) -> Int {
        switch name {
        case "English": return min(3, required)
        case "Math": return min(4, required)
        case "Science": return min(3, required)
        case "Social Studies": return min(2, required)
        case "World Language": return min(2, required)
        case "Fine Arts", "Visual/Performing Arts", "Arts": return min(1, required)
        case "Physical Education", "Health/PE", "Health": return min(1, required)
        default: return min(4, required)
        }
    }

    // MARK: - Models

    struct CreditCategory: Identifiable {
        let id = UUID()
        let name: String
        var earned: Int
        let required: Int
    }

    struct ScholarshipRequirement: Identifiable {
        let id = UUID()
        let title: String
        let detail: String
        let isMet: Bool
    }

    // MARK: - Computed

    var totalCreditsEarned: Int {
        categories.map(\.earned).reduce(0, +)
    }

    var overallProgress: Double {
        min(Double(totalCreditsEarned) / Double(totalCreditsRequired), 1.0)
    }

    var missingCategories: [CreditCategory] {
        categories.filter { $0.earned < $0.required }
    }

    var projectionMessage: String {
        if overallProgress >= 1.0 {
            return "You've met all credit requirements!"
        }
        let remaining = totalCreditsRequired - totalCreditsEarned
        return "On track for graduation (\(remaining) credits remaining)"
    }

    var scholarshipRequirements: [ScholarshipRequirement] {
        guard let scholarship = meritScholarship else { return [] }

        var reqs: [ScholarshipRequirement] = [
            ScholarshipRequirement(
                title: scholarship.name,
                detail: scholarship.requirements,
                isMet: false
            )
        ]

        if let partialName = scholarship.partialName,
           let partialReqs = scholarship.partialRequirements {
            reqs.append(ScholarshipRequirement(
                title: partialName,
                detail: partialReqs,
                isMet: true
            ))
        }

        return reqs
    }
}
