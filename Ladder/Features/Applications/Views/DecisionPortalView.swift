import SwiftUI
import SwiftData

// MARK: - Decision Portal

struct DecisionPortalView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var context
    @State private var applications: [ApplicationModel] = []
    @State private var showAddSheet = false
    @State private var selectedApplication: ApplicationModel?

    private let statusGroups = ["submitted", "accepted", "rejected", "waitlisted", "committed", "planning", "in_progress"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    ForEach(statusGroups, id: \.self) { status in
                        let apps = applications.filter { $0.status == status }
                        if !apps.isEmpty {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                HStack {
                                    Circle()
                                        .fill(statusColor(status))
                                        .frame(width: 10, height: 10)
                                    Text(displayName(for: status))
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text("(\(apps.count))")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }

                                ForEach(apps, id: \.collegeName) { app in
                                    Button {
                                        selectedApplication = app
                                    } label: {
                                        LadderCard {
                                            HStack(spacing: LadderSpacing.md) {
                                                CollegeLogoView(app.collegeName, websiteURL: collegeWebsiteURL(for: app), size: 40, cornerRadius: 10)
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(app.collegeName)
                                                        .font(LadderTypography.bodyMedium)
                                                        .foregroundStyle(LadderColors.onSurface)
                                                    if let type = app.deadlineType {
                                                        Text(type)
                                                            .font(LadderTypography.labelSmall)
                                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                                    }
                                                    if let deadline = app.deadlineDate {
                                                        Text(deadline, style: .date)
                                                            .font(LadderTypography.labelSmall)
                                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: statusIcon(app.status))
                                                    .foregroundStyle(statusColor(app.status))
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    if applications.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("No applications yet")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            Text("Tap + to add your first application")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(LadderColors.primary)
                            .clipShape(Circle())
                            .shadow(color: LadderColors.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.trailing, LadderSpacing.lg)
                    .padding(.bottom, 100)
                }
            }
        }
        .task { loadApplications() }
        .sheet(isPresented: $showAddSheet) {
            AddApplicationSheet { newApp in
                // Use the factory so duplicates by collegeId are coalesced instead
                // of creating orphan ApplicationModels.
                let app = ApplicationFactory.findOrCreate(
                    collegeId: newApp.collegeId,
                    collegeName: newApp.collegeName,
                    context: context
                )
                app.deadlineType = newApp.deadlineType ?? app.deadlineType
                app.deadlineDate = newApp.deadlineDate ?? app.deadlineDate
                if let state = ApplicationState(rawValue: newApp.status) {
                    app.setState(state, context: context)
                } else {
                    app.status = newApp.status
                }
                do { try context.save() } catch { Log.error("Application create save failed: \(error)") }
                loadApplications()
            }
        }
        .sheet(item: $selectedApplication) { app in
            ApplicationDetailSheet(application: app) {
                do { try context.save() } catch { Log.error("Application edit save failed: \(error)") }
                loadApplications()
            } onDelete: {
                context.delete(app)
                do { try context.save() } catch { Log.error("Application delete save failed: \(error)") }
                loadApplications()
            }
        }
    }

    private func loadApplications() {
        let descriptor = FetchDescriptor<ApplicationModel>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        applications = (try? context.fetch(descriptor)) ?? []
    }

    private func displayName(for status: String) -> String {
        switch status {
        case "in_progress": return "In Progress"
        case "planning": return "Planning"
        default: return status.capitalized
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "accepted", "committed": return LadderColors.primary
        case "rejected": return .red
        case "waitlisted": return .orange
        case "submitted": return LadderColors.primaryContainer
        case "in_progress": return .blue
        case "planning": return LadderColors.outlineVariant
        default: return LadderColors.outlineVariant
        }
    }

    /// Look up the websiteURL for a college by matching the application's collegeName or collegeId.
    private func collegeWebsiteURL(for app: ApplicationModel) -> String? {
        let descriptor = FetchDescriptor<CollegeModel>()
        guard let colleges = try? context.fetch(descriptor) else { return nil }
        if let id = app.collegeId, let match = colleges.first(where: { String($0.scorecardId ?? 0) == id || $0.name == id }) {
            return match.websiteURL
        }
        return colleges.first(where: { $0.name == app.collegeName })?.websiteURL
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "accepted": return "checkmark.circle.fill"
        case "committed": return "star.fill"
        case "rejected": return "xmark.circle.fill"
        case "waitlisted": return "clock.fill"
        case "submitted": return "paperplane.fill"
        case "in_progress": return "pencil.circle.fill"
        case "planning": return "circle.dashed"
        default: return "circle"
        }
    }
}

// MARK: - Add Application Sheet

private struct AddApplicationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var collegeName = ""
    @State private var deadlineType = "Regular Decision"
    @State private var deadlineDate = Date()
    @State private var status = "planning"

    let onSave: (ApplicationModel) -> Void

    private let deadlineTypes = ["Early Decision", "Early Action", "Regular Decision", "Rolling"]
    private let statuses = ["planning", "in_progress", "submitted", "accepted", "rejected", "waitlisted", "committed"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // College Name
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("COLLEGE NAME")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextField("e.g. University of Florida", text: $collegeName)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .padding(LadderSpacing.md)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }

                        // Deadline Type
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("DEADLINE TYPE")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Picker("Deadline Type", selection: $deadlineType) {
                                ForEach(deadlineTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Deadline Date
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("DEADLINE DATE")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            DatePicker("", selection: $deadlineDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(LadderColors.primary)
                        }

                        // Status
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("STATUS")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Picker("Status", selection: $status) {
                                ForEach(statuses, id: \.self) { s in
                                    Text(displayName(for: s)).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(LadderSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }

                        // Save Button
                        Button {
                            guard !collegeName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let app = ApplicationModel(collegeName: collegeName.trimmingCharacters(in: .whitespaces))
                            app.deadlineType = deadlineType
                            app.deadlineDate = deadlineDate
                            app.status = status
                            onSave(app)
                            dismiss()
                        } label: {
                            Text("Add Application")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(LadderSpacing.md)
                                .background(collegeName.trimmingCharacters(in: .whitespaces).isEmpty ? LadderColors.outlineVariant : LadderColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
                        }
                        .disabled(collegeName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Application")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func displayName(for status: String) -> String {
        switch status {
        case "in_progress": return "In Progress"
        case "planning": return "Not Started"
        default: return status.capitalized
        }
    }
}

// MARK: - Application Detail Sheet

private struct ApplicationDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var application: ApplicationModel
    @State private var editedStatus: String
    @State private var editedNotes: String
    @State private var showDeleteConfirm = false
    @State private var showRemoveAcceptanceConfirm = false

    let onSave: () -> Void
    let onDelete: () -> Void

    private let statuses = ["planning", "in_progress", "submitted", "accepted", "rejected", "waitlisted", "committed"]

    init(application: ApplicationModel, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.application = application
        self.onSave = onSave
        self.onDelete = onDelete
        _editedStatus = State(initialValue: application.status)
        _editedNotes = State(initialValue: application.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // College Info Header
                        VStack(spacing: LadderSpacing.sm) {
                            Text(application.collegeName)
                                .font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            if let type = application.deadlineType {
                                Text(type)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            if let deadline = application.deadlineDate {
                                HStack(spacing: LadderSpacing.xs) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 12))
                                    Text(deadline, style: .date)
                                }
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl))

                        // Status Picker
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("STATUS")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Picker("Status", selection: $editedStatus) {
                                ForEach(statuses, id: \.self) { s in
                                    Text(displayName(for: s)).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(LadderSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text("NOTES")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextEditor(text: $editedNotes)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(LadderSpacing.md)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }

                        // Save Button
                        Button {
                            let previousStatus = application.status

                            // If moving AWAY from accepted, confirm before removing checklist items
                            if previousStatus == "accepted" && editedStatus != "accepted" && editedStatus != "committed" {
                                showRemoveAcceptanceConfirm = true
                                return
                            }

                            applyStatusChange(previousStatus: previousStatus, context: modelContext)
                        } label: {
                            Text("Save Changes")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(LadderSpacing.md)
                                .background(LadderColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
                        }

                        // Delete Button
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete Application")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(LadderSpacing.md)
                                .background(Color.red.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
                        }
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Application Details")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .alert("Delete Application?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove \(application.collegeName) from your applications.")
            }
            .alert("Remove Acceptance?", isPresented: $showRemoveAcceptanceConfirm) {
                Button("Remove & Clear Checklist", role: .destructive) {
                    // Remove post-acceptance checklist items
                    let postAcceptanceItems = application.checklistItems.filter { $0.category == "post_acceptance" }
                    for item in postAcceptanceItems {
                        application.checklistItems.removeAll { $0 === item }
                    }
                    applyStatusChange(previousStatus: application.status, context: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Changing status from Accepted will remove the post-acceptance checklist for \(application.collegeName). This cannot be undone.")
            }
        }
        .presentationDetents([.large])
    }

    private func displayName(for status: String) -> String {
        switch status {
        case "in_progress": return "In Progress"
        case "planning": return "Not Started"
        default: return status.capitalized
        }
    }

    // MARK: - Apply Status Change

    @MainActor
    private func applyStatusChange(previousStatus: String, context: ModelContext) {
        application.notes = editedNotes.isEmpty ? nil : editedNotes
        if editedStatus == "submitted" && application.submittedAt == nil {
            application.submittedAt = Date()
        }
        if editedStatus == "accepted" || editedStatus == "rejected" || editedStatus == "waitlisted" {
            application.decisionAt = Date()
        }

        if let target = ApplicationState(rawValue: editedStatus) {
            let accepted = application.setState(target, context: context)
            if !accepted {
                Log.warn("Ignored invalid status change \(previousStatus) → \(editedStatus)")
            }
        } else {
            // Unknown raw value — fall back to direct assignment and log.
            Log.warn("Unknown status rawValue '\(editedStatus)'")
            application.status = editedStatus
        }

        onSave()
        dismiss()
    }
}
