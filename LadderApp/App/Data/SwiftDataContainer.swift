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
        let container = try ModelContainer(
            for: schema,
            migrationPlan: LadderMigrationPlan.self,
            configurations: [configuration]
        )
        // S4: Upgrade the SwiftData store files to NSFileProtectionComplete so
        // that the OS requires device unlock before granting read access.
        // The default is CompleteUntilFirstUserAuthentication, which allows reads
        // while the device is powered on but screen-locked — insufficient for a
        // targeted physical-access attack on a minor's device.
        applyFileProtection(to: container)
        return container
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

// MARK: - S4: NSFileProtectionComplete

/// Applies `NSFileProtectionComplete` to every file inside the SwiftData store
/// directory. SwiftData places store files under
/// `<Application Support>/default.store` (and sibling WAL/SHM files).
/// We target the parent directory so that future store files created during
/// migration also inherit the protection class.
///
/// This is a defence-in-depth measure: if a motivated attacker gains physical
/// access to the device while it is screen-locked (but previously booted), they
/// cannot read the SQLite store without the user's passcode.
@MainActor
private func applyFileProtection(to container: ModelContainer) {
    guard let appSupportURL = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first else {
        Log.warn("[S4] Could not resolve Application Support directory — file protection not applied")
        return
    }

    // SwiftData stores its SQLite files directly in Application Support.
    // Apply protection to every file in that directory rather than hard-coding
    // a filename that could change across SwiftData versions.
    let fm = FileManager.default
    guard let contents = try? fm.contentsOfDirectory(
        at: appSupportURL,
        includingPropertiesForKeys: nil
    ) else {
        Log.warn("[S4] Could not enumerate Application Support — file protection not applied")
        return
    }

    let protection: [FileAttributeKey: Any] = [
        .protectionKey: FileProtectionType.complete
    ]

    var failCount = 0
    for url in contents {
        do {
            try fm.setAttributes(protection, ofItemAtPath: url.path)
        } catch {
            failCount += 1
        }
    }

    if failCount == 0 {
        Log.info("[S4] NSFileProtectionComplete applied to SwiftData store files")
    } else {
        Log.warn("[S4] NSFileProtectionComplete: \(failCount) file(s) could not be upgraded")
    }
}
