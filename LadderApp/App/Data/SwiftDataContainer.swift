import SwiftUI
import SwiftData

// MARK: - SwiftData Container
//
// Versioned schema so future @Model field additions/renames migrate safely
// instead of crashing legacy installs. Bump LadderSchemaV_N and add a
// MigrationStage when the shape changes.

enum LadderSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            CollegeModel.self,
            CollegePersonalityModel.self,
            CollegeDeadlineModel.self,
            StudentProfileModel.self,
            ApplicationModel.self,
            ChecklistItemModel.self,
            ChatSessionModel.self,
            ChatMessageModel.self,
            ScholarshipModel.self,
            RoadmapMilestoneModel.self,
            LetterOfRecModel.self,
            SATScoreEntryModel.self,
            FinancialAidPackageModel.self,
            CounselorProfileModel.self,
            ActivityModel.self,
            // AuditLogEntry.self — TODO: re-add when Services/Legacy/Audit/AuditLogger.swift
            // is promoted in a later batch. Excluding it from the schema here lets the build
            // succeed without losing any persisted audit data (the table simply isn't
            // attached to the active SwiftData store yet).
            CareerQuizHistoryModel.self,
            EssayModel.self,
            GPAEntryModel.self,
            CollegeVisitModel.self,
            SchoolClubModel.self,
            SchoolSportModel.self,
            SchoolCalendarEventModel.self,
            ConversationMemoryModel.self
        ]
    }
}

enum LadderMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LadderSchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}

@MainActor
func createModelContainer() -> ModelContainer {
    let schema = Schema(versionedSchema: LadderSchemaV1.self)
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )

    do {
        return try ModelContainer(
            for: schema,
            migrationPlan: LadderMigrationPlan.self,
            configurations: [configuration]
        )
    } catch {
        // Corruption recovery: if the persistent store is incompatible and migration fails,
        // fall back to an in-memory container so the app can still launch for the user to
        // re-sync from backend. A destructive reset is a separate, user-initiated path.
        Log.error("ModelContainer migration failed: \(error). Falling back to in-memory store.")
        do {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [fallback])
        } catch {
            fatalError("Could not create fallback ModelContainer: \(error)")
        }
    }
}
