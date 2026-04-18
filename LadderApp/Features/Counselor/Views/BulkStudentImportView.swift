import SwiftUI

// MARK: - Bulk Student Import View
// Table-based input for adding multiple students at once with auto-generated credentials

struct BulkStudentImportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var studentRows: [StudentInputRow] = [StudentInputRow()]
    @State private var generatedCredentials: [StudentCredential] = []
    @State private var isGenerated = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Add New Students")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(isGenerated
                            ? "\(generatedCredentials.count) credential\(generatedCredentials.count == 1 ? "" : "s") generated"
                            : "\(studentRows.count) student\(studentRows.count == 1 ? "" : "s") to add"
                        )
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    if !isGenerated {
                        inputSection
                    } else {
                        resultsSection
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
                Text("Bulk Import")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            ForEach(Array(studentRows.enumerated()), id: \.element.id) { index, _ in
                studentInputCard(index: index)
            }

            // Add Another button
            Button {
                studentRows.append(StudentInputRow())
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add Another Student")
                        .font(LadderTypography.titleSmall)
                }
                .foregroundStyle(LadderColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(LadderColors.primaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
            .buttonStyle(.plain)

            // Generate All button
            LadderPrimaryButton("Generate All Accounts", icon: "key.fill") {
                generateAllCredentials()
            }
            .disabled(!allRowsValid)
            .opacity(allRowsValid ? 1.0 : 0.5)
        }
    }

    // MARK: - Student Input Card

    private func studentInputCard(index: Int) -> some View {
        VStack(spacing: LadderSpacing.md) {
            // Card header
            HStack {
                Text("Student \(index + 1)")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                if studentRows.count > 1 {
                    Button {
                        studentRows.remove(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Name fields
            HStack(spacing: LadderSpacing.sm) {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("First Name")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    TextField("First", text: $studentRows[index].firstName)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .padding(LadderSpacing.sm)
                        .background(LadderColors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Last Name")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    TextField("Last", text: $studentRows[index].lastName)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .padding(LadderSpacing.sm)
                        .background(LadderColors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
                }
            }

            // DOB + Grade
            HStack(spacing: LadderSpacing.sm) {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Date of Birth")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    DatePicker(
                        "",
                        selection: $studentRows[index].dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .tint(LadderColors.primary)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Grade")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Picker("Grade", selection: $studentRows[index].grade) {
                        ForEach([9, 10, 11, 12], id: \.self) { g in
                            Text("\(g)").tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(LadderColors.primary)
                }
            }

            // Live preview of generated credentials
            if !studentRows[index].firstName.isEmpty && !studentRows[index].lastName.isEmpty {
                let row = studentRows[index]
                let previewId = StudentAutoIDGenerator.generateLoginId(
                    firstName: row.firstName, lastName: row.lastName, dob: row.dateOfBirth
                )
                let previewPw = StudentAutoIDGenerator.generatePassword(
                    firstName: row.firstName, dob: row.dateOfBirth
                )

                HStack(spacing: LadderSpacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Login ID")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(previewId)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(LadderColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Password")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(previewPw)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(LadderColors.primary)
                    }

                    Spacer()
                }
                .padding(LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Results Section

    private var resultsSection: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Success banner
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(LadderColors.primary)
                Text("\(generatedCredentials.count) Accounts Created")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            .frame(maxWidth: .infinity)
            .padding(LadderSpacing.lg)
            .background(LadderColors.primaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

            // Credential cards
            ForEach(generatedCredentials, id: \.loginId) { credential in
                StudentCredentialCardView(
                    credential: credential,
                    schoolName: "Your School"
                )
            }

            // Print All button
            ShareLink(item: allCredentialsShareText) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "printer")
                        .font(.system(size: 16, weight: .bold))
                    Text("PRINT CREDENTIAL CARDS")
                        .font(LadderTypography.labelLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.lg)
                .background(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }

            // Start over
            Button {
                studentRows = [StudentInputRow()]
                generatedCredentials = []
                isGenerated = false
            } label: {
                Text("Add More Students")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.primary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private var allRowsValid: Bool {
        studentRows.allSatisfy { !$0.firstName.isEmpty && !$0.lastName.isEmpty }
    }

    private func generateAllCredentials() {
        let input = studentRows.map { row in
            (firstName: row.firstName, lastName: row.lastName, dob: row.dateOfBirth, grade: row.grade)
        }
        generatedCredentials = StudentAutoIDGenerator.bulkGenerate(students: input)
        isGenerated = true
    }

    private var allCredentialsShareText: String {
        var text = "LADDER - Student Login Credentials\n"
        text += "===================================\n\n"
        for credential in generatedCredentials {
            text += "Student: \(credential.studentName)\n"
            text += "Grade: \(credential.grade)\n"
            text += "Login ID: \(credential.loginId)\n"
            text += "Password: \(credential.password)\n"
            text += "-----------------------------------\n\n"
        }
        text += "Please change your password on first login.\n"
        return text
    }
}

// MARK: - Student Input Row

struct StudentInputRow: Identifiable {
    let id = UUID()
    var firstName = ""
    var lastName = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -15, to: Date()) ?? Date()
    var grade = 9
}

#Preview {
    NavigationStack {
        BulkStudentImportView()
    }
}
