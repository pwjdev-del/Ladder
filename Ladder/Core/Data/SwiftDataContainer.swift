import SwiftUI
import SwiftData

// MARK: - SwiftData Container
// Configures the model container with all app models

@MainActor
func createModelContainer() -> ModelContainer {
    let schema = Schema([
        CollegeModel.self,
        CollegePersonalityModel.self,
        CollegeDeadlineModel.self,
        StudentProfileModel.self,
        ApplicationModel.self,
        ChecklistItemModel.self,
        ChatSessionModel.self,
        ChatMessageModel.self,
        ScholarshipModel.self,
        RoadmapMilestoneModel.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )

    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
