import SwiftUI

// MARK: - Student Credential Card View
// Reusable card showing one student's auto-generated login credentials.
// Designed with clean borders for a printable appearance.

struct StudentCredentialCardView: View {
    let credential: StudentCredential
    let schoolName: String

    @State private var passwordVisible = false
    @State private var copiedField: String?

    var body: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Ladder logo area
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(LadderColors.primary)
                Text("Ladder")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.primary)
            }

            // Student name
            Text(credential.studentName)
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            Text("Grade \(credential.grade)")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            // Credential fields
            VStack(spacing: LadderSpacing.md) {
                // Login ID
                credentialRow(
                    label: "Login ID",
                    value: credential.loginId,
                    fieldId: "loginId",
                    masked: false
                )

                // Password
                credentialRow(
                    label: "Temporary Password",
                    value: credential.password,
                    fieldId: "password",
                    masked: !passwordVisible,
                    showRevealToggle: true
                )
            }

            // First login note
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 12))
                    .foregroundStyle(LadderColors.tertiary)
                Text("Change your password on first login")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(LadderColors.tertiaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))

            // School name
            Text(schoolName)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                .strokeBorder(LadderColors.outlineVariant, lineWidth: 1)
        )
    }

    // MARK: - Credential Row

    private func credentialRow(
        label: String,
        value: String,
        fieldId: String,
        masked: Bool,
        showRevealToggle: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text(label)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            HStack(spacing: LadderSpacing.sm) {
                Text(masked ? String(repeating: "\u{2022}", count: value.count) : value)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                if showRevealToggle {
                    Button {
                        passwordVisible.toggle()
                    } label: {
                        Image(systemName: passwordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    UIPasteboard.general.string = value
                    copiedField = fieldId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedField == fieldId { copiedField = nil }
                    }
                } label: {
                    Image(systemName: copiedField == fieldId ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundStyle(copiedField == fieldId ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
        }
    }
}

#Preview {
    StudentCredentialCardView(
        credential: StudentCredential(
            loginId: "jsmith0415",
            password: "john10!",
            studentName: "John Smith",
            dateOfBirth: Date(),
            grade: 10
        ),
        schoolName: "Lincoln High School"
    )
    .padding(LadderSpacing.lg)
    .background(LadderColors.surface)
}
