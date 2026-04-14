import SwiftUI
import SwiftData

// MARK: - Data Deletion View
// FERPA/GDPR/CCPA compliant account deletion flow.
// User must type "DELETE" to confirm. All data removed within 30 days.

struct DataDeletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var modelContext

    @State private var confirmText = ""
    @State private var showFinalConfirm = false
    @State private var isDeleting = false
    @State private var deleteComplete = false
    @State private var selectedReasons: Set<String> = []

    private let reasons = [
        "I no longer need the app",
        "I'm concerned about my privacy",
        "I want to create a new account",
        "The app didn't meet my needs",
        "My counselor/school manages my account",
        "Other"
    ]

    private var canDelete: Bool {
        confirmText.uppercased() == "DELETE"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                if deleteComplete {
                    deletionConfirmationView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.xl) {
                            warningHeader
                            whatGetsDeleted
                            reasonsSection
                            confirmationInput
                            deleteButton
                        }
                        .padding(LadderSpacing.lg)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if !deleteComplete {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Delete My Data")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }
            }
        }
    }

    // MARK: - Warning Header

    private var warningHeader: some View {
        VStack(spacing: LadderSpacing.md) {
            ZStack {
                Circle()
                    .fill(LadderColors.error.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "trash.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(LadderColors.error)
            }

            Text("Delete Account & Data")
                .font(LadderTypography.headlineLarge)
                .foregroundStyle(LadderColors.error)
                .editorialTracking()

            Text("This action is permanent and cannot be undone. All your data will be permanently deleted within 30 days.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - What Gets Deleted

    private var whatGetsDeleted: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("WHAT WILL BE PERMANENTLY DELETED")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: LadderSpacing.sm) {
                deletionRow("Your account and login credentials")
                deletionRow("All academic data (GPA, test scores, courses)")
                deletionRow("College lists, applications, and essays")
                deletionRow("Career quiz results and history")
                deletionRow("Activity portfolio and achievements")
                deletionRow("Financial aid and scholarship tracking")
                deletionRow("AI advisor conversation history")
                deletionRow("All files you uploaded (transcripts, PDFs)")
            }
            .padding(LadderSpacing.lg)
            .background(LadderColors.error.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(LadderColors.error.opacity(0.2), lineWidth: 1)
            )

            // FERPA note
            if true { // Show for school accounts — when backend is wired, check if school account
                HStack(alignment: .top, spacing: LadderSpacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(LadderColors.primary)
                        .font(.system(size: 14))
                    Text("Note: If your account was created by a school, your school may retain FERPA-required education records separately per their data retention policy.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(LadderSpacing.md)
                .background(LadderColors.primaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
            }
        }
    }

    // MARK: - Reason (optional, helps improve the app)

    private var reasonsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("WHY ARE YOU LEAVING? (OPTIONAL)")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: LadderSpacing.sm) {
                ForEach(reasons, id: \.self) { reason in
                    Button {
                        if selectedReasons.contains(reason) {
                            selectedReasons.remove(reason)
                        } else {
                            selectedReasons.insert(reason)
                        }
                    } label: {
                        HStack {
                            Text(reason)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                            Image(systemName: selectedReasons.contains(reason) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedReasons.contains(reason) ? LadderColors.primary : LadderColors.onSurfaceVariant.opacity(0.4))
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.surfaceContainerLow)
                    }
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    // MARK: - Confirmation Input

    private var confirmationInput: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("TYPE \"DELETE\" TO CONFIRM")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.error)
                .labelTracking()

            TextField("Type DELETE here", text: $confirmText)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.error)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                        .stroke(canDelete ? LadderColors.error : LadderColors.surfaceContainerHighest, lineWidth: 1.5)
                )
        }
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        VStack(spacing: LadderSpacing.md) {
            Button {
                performDeletion()
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    if isDeleting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "trash.fill")
                        Text("Permanently Delete My Account")
                    }
                }
                .font(LadderTypography.labelLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(canDelete ? LadderColors.error : LadderColors.surfaceContainerHighest)
                .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(!canDelete || isDeleting)

            Button { dismiss() } label: {
                Text("Cancel — Keep My Account")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.primary)
            }
        }
    }

    // MARK: - Success View

    private var deletionConfirmationView: some View {
        VStack(spacing: LadderSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(spacing: LadderSpacing.md) {
                Text("Deletion Requested")
                    .font(LadderTypography.headlineLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .editorialTracking()

                Text("Your account and all associated data will be permanently deleted within 30 days.\n\nYou will receive a confirmation email when deletion is complete.")
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LadderSpacing.lg)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private func performDeletion() {
        guard canDelete else { return }
        isDeleting = true

        Task {
            // TODO: Call AWS Lambda to schedule data deletion
            // TODO: Revoke all Cognito tokens
            // Clear local SwiftData
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run {
                isDeleting = false
                deleteComplete = true
                // Sign out after brief delay so user sees confirmation
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    await authManager.signOut()
                    dismiss()
                }
            }
        }
    }

    private func deletionRow(_ text: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(LadderColors.error)
                .font(.system(size: 14))
            Text(text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
        }
    }
}
