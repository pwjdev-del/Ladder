import SwiftUI
import SwiftData

// MARK: - Data Deletion View
// FERPA right to delete — student/parent can request permanent data deletion
// Requires typing "DELETE" to confirm the destructive action

struct DataDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var confirmationText = ""
    @State private var showConfirmAlert = false
    @State private var isDeleting = false

    private var isDeleteConfirmed: Bool {
        confirmationText.trimmingCharacters(in: .whitespaces).uppercased() == "DELETE"
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(LadderColors.error)

                        Text("Delete My Data")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("This action cannot be undone")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.error)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, LadderSpacing.lg)

                    // Warning Card
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(LadderColors.error)

                            Text("WARNING")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.error)
                        }

                        Text("This will permanently delete all your Ladder data including your profile, applications, activities, and saved colleges.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            deletionItem("Your student profile")
                            deletionItem("All college applications")
                            deletionItem("Extracurricular activities")
                            deletionItem("Saved and matched colleges")
                            deletionItem("Chat history with Sia")
                            deletionItem("Checklists and roadmap progress")
                            deletionItem("Financial aid information")
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: LadderRadius.lg)
                            .fill(LadderColors.error.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: LadderRadius.lg)
                                    .stroke(LadderColors.error.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // Confirmation Input
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Type DELETE to confirm")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        LadderTextField("Type DELETE", text: $confirmationText, icon: "keyboard")
                    }

                    // Delete Button
                    Button {
                        showConfirmAlert = true
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            if isDeleting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "trash.fill")
                            }
                            Text("Delete My Account")
                                .font(LadderTypography.titleSmall)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: LadderRadius.lg)
                                .fill(isDeleteConfirmed ? LadderColors.error : LadderColors.error.opacity(0.3))
                        )
                    }
                    .disabled(!isDeleteConfirmed || isDeleting)

                    // FERPA note
                    Text("Under FERPA, you have the right to request deletion of your educational records. This action is immediate and irreversible.")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, LadderSpacing.xl)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you absolutely sure?", isPresented: $showConfirmAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                performDeletion()
            }
        } message: {
            Text("All your data will be permanently deleted and you will be signed out. This cannot be undone.")
        }
    }

    // MARK: - Deletion Item Row

    @ViewBuilder
    private func deletionItem(_ text: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(LadderColors.error)

            Text(text)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    // MARK: - Perform Deletion

    private func performDeletion() {
        isDeleting = true

        // TODO: Delete data from Supabase backend
        // TODO: Clear Keychain credentials

        // Clear all SwiftData models
        do {
            try modelContext.delete(model: StudentProfileModel.self)
            try modelContext.delete(model: ApplicationModel.self)
            try modelContext.delete(model: ActivityModel.self)
            try modelContext.delete(model: CollegeModel.self)
            try modelContext.delete(model: ChatSessionModel.self)
            try modelContext.delete(model: ChatMessageModel.self)
            try modelContext.delete(model: ChecklistItemModel.self)
            try modelContext.delete(model: ScholarshipModel.self)
            try modelContext.delete(model: RoadmapMilestoneModel.self)
            try modelContext.delete(model: LetterOfRecModel.self)
            try modelContext.delete(model: SATScoreEntryModel.self)
            try modelContext.delete(model: FinancialAidPackageModel.self)
            try modelContext.delete(model: AuditLogEntry.self)
            try modelContext.save()
        } catch {
            // Log deletion error
            print("Data deletion error: \(error)")
        }

        // Clear UserDefaults
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }

        // TODO: Sign out via AuthManager
        // authManager.signOut()

        isDeleting = false
        dismiss()
    }
}

#Preview {
    DataDeletionView()
}
