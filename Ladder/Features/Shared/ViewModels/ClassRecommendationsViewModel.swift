import SwiftUI

// MARK: - Class Recommendations ViewModel

@Observable
final class ClassRecommendationsViewModel {

    var careerPath: String? = "Healthcare"
    var gradeLabel: String = "11th grade"
    var recommendations: [CourseRecommendation] = []
    var creditProgress: [CreditCategory] = []

    // MARK: - Models

    struct CourseRecommendation: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let tag: String
        var tagColor: Color
        let reason: String
        var isSelected: Bool
    }

    struct CreditCategory: Identifiable {
        let id = UUID()
        let name: String
        let earned: Int
        let required: Int
    }

    // MARK: - Load

    func loadRecommendations() {
        recommendations = [
            CourseRecommendation(
                name: "AP Biology",
                icon: "flask",
                tag: "Recommended",
                tagColor: LadderColors.primary,
                reason: "Strengthens your pre-med foundation through advanced lab work.",
                isSelected: true
            ),
            CourseRecommendation(
                name: "Precalculus Honors",
                icon: "function",
                tag: "Required",
                tagColor: LadderColors.error,
                reason: "State requirement for 11th grade honors track students.",
                isSelected: false
            ),
            CourseRecommendation(
                name: "Intro to Anatomy",
                icon: "heart",
                tag: "Elective",
                tagColor: LadderColors.onSurfaceVariant,
                reason: "Highly aligned with your interest in Surgeon career paths.",
                isSelected: true
            ),
            CourseRecommendation(
                name: "Modern Literature",
                icon: "book.closed",
                tag: "Required",
                tagColor: LadderColors.error,
                reason: "Fulfills the core 11th grade English credit requirement.",
                isSelected: false
            ),
            CourseRecommendation(
                name: "AP Chemistry",
                icon: "atom",
                tag: "Recommended",
                tagColor: LadderColors.primary,
                reason: "Top medical schools prefer dual AP sciences on transcripts.",
                isSelected: false
            ),
            CourseRecommendation(
                name: "Spanish III Honors",
                icon: "globe",
                tag: "Elective",
                tagColor: LadderColors.onSurfaceVariant,
                reason: "Bilingual healthcare providers are in high demand.",
                isSelected: false
            )
        ]

        creditProgress = [
            CreditCategory(name: "Science", earned: 3, required: 4),
            CreditCategory(name: "Math", earned: 2, required: 4),
            CreditCategory(name: "English", earned: 2, required: 4),
            CreditCategory(name: "Social Studies", earned: 3, required: 3),
            CreditCategory(name: "World Language", earned: 2, required: 2),
            CreditCategory(name: "Fine Art", earned: 1, required: 1),
            CreditCategory(name: "Electives", earned: 4, required: 7)
        ]
    }

    func toggleSelected(_ rec: CourseRecommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == rec.id }) {
            recommendations[index].isSelected.toggle()
        }
    }
}
