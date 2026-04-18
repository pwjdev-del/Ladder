import SwiftUI

// MARK: - Add Single Student View
// Quick-add one student with auto-generated credentials

struct AddSingleStudentView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -15, to: Date()) ?? Date()
    @State private var selectedGrade = 9
    @State private var generatedCredential: StudentCredential?
    @State private var showingShareSheet = false

    private let grades = [9, 10, 11, 12]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Add Student")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Enter student details to generate login credentials")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    if generatedCredential == nil {
                        // Input form
                        formSection
                    } else {
                        // Credential result
                        credentialResult
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Add Student")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            // First Name
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("First Name")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                TextField("Enter first name", text: $firstName)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }

            // Last Name
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("Last Name")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                TextField("Enter last name", text: $lastName)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }

            // Date of Birth
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("Date of Birth")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                DatePicker(
                    "Date of Birth",
                    selection: $dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .tint(LadderColors.primary)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }

            // Grade Picker
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("Grade")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                HStack(spacing: 0) {
                    ForEach(grades, id: \.self) { grade in
                        Button {
                            selectedGrade = grade
                        } label: {
                            Text("\(grade)")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(selectedGrade == grade ? .white : LadderColors.onSurfaceVariant)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LadderSpacing.md)
                                .background(selectedGrade == grade ? LadderColors.primary : LadderColors.surfaceContainerLow)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }

            // Generate button
            LadderPrimaryButton("Generate Credentials", icon: "key.fill") {
                generateCredential()
            }
            .disabled(firstName.isEmpty || lastName.isEmpty)
            .opacity(firstName.isEmpty || lastName.isEmpty ? 0.5 : 1.0)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Credential Result

    private var credentialResult: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Success icon
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("Credentials Generated")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            if let credential = generatedCredential {
                StudentCredentialCardView(
                    credential: credential,
                    schoolName: "Your School"
                )
            }

            // Actions
            HStack(spacing: LadderSpacing.md) {
                if let credential = generatedCredential {
                    ShareLink(
                        item: credentialShareText(credential)
                    ) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "printer")
                                .font(.system(size: 14))
                            Text("Print Card")
                                .font(LadderTypography.titleSmall)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(Capsule())
                    }
                }

                Button {
                    resetForm()
                } label: {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                        Text("Add Another")
                            .font(LadderTypography.titleSmall)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                    .background(LadderColors.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func generateCredential() {
        generatedCredential = StudentAutoIDGenerator.generate(
            firstName: firstName,
            lastName: lastName,
            dob: dateOfBirth,
            grade: selectedGrade
        )
    }

    private func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Calendar.current.date(byAdding: .year, value: -15, to: Date()) ?? Date()
        selectedGrade = 9
        generatedCredential = nil
    }

    private func credentialShareText(_ credential: StudentCredential) -> String {
        """
        LADDER - Student Login Credentials
        -----------------------------------
        Student: \(credential.studentName)
        Grade: \(credential.grade)
        Login ID: \(credential.loginId)
        Temporary Password: \(credential.password)

        Please change your password on first login.
        """
    }
}

#Preview {
    NavigationStack {
        AddSingleStudentView()
    }
}
