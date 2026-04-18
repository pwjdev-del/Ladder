import SwiftUI

// MARK: - Class Approval Detail View
// Full schedule review for a single student with conflict resolution and approval actions

struct ClassApprovalDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let studentId: String

    @State private var changeNotes = ""
    @State private var isApproved = false
    @State private var showChangesSheet = false

    // Resolve the student from mock data
    private var student: MockStudentSchedule? {
        MockStudentSchedule.sampleStudents.first { $0.id.uuidString == studentId }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if let student {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.xl) {
                        // Student header
                        studentHeader(student)

                        // Schedule grid
                        scheduleGrid(student)

                        // Previous year schedule
                        if let previous = student.previousYearPeriods {
                            previousYearSection(previous)
                        }

                        // Action buttons
                        if !isApproved {
                            actionButtons
                        } else {
                            approvedBanner
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, LadderSpacing.lg)
                }
            } else {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("Student not found")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
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
                Text("Schedule Review")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showChangesSheet) {
            requestChangesSheet
        }
    }

    // MARK: - Student Header

    private func studentHeader(_ student: MockStudentSchedule) -> some View {
        VStack(spacing: LadderSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 70, height: 70)
                Text(studentInitials(student.name))
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.primary)
            }

            Text(student.name)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            // Info chips
            HStack(spacing: LadderSpacing.sm) {
                infoBadge("Grade \(student.grade)")
                infoBadge("GPA \(String(format: "%.2f", student.gpa))")
                if student.apCount > 0 {
                    infoBadge("\(student.apCount) AP")
                }
                if student.honorsCount > 0 {
                    infoBadge("\(student.honorsCount) Honors")
                }
            }

            // AI Warning
            if let warning = student.aiWarning {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.tertiary)
                    Text(warning)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.tertiary)
                }
                .padding(LadderSpacing.md)
                .frame(maxWidth: .infinity)
                .background(LadderColors.tertiaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
            }
        }
        .padding(.top, LadderSpacing.lg)
    }

    private func infoBadge(_ text: String) -> some View {
        Text(text)
            .font(LadderTypography.labelMedium)
            .foregroundStyle(LadderColors.onSurfaceVariant)
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.xs)
            .background(LadderColors.surfaceContainerHigh)
            .clipShape(Capsule())
    }

    // MARK: - Schedule Grid

    private func scheduleGrid(_ student: MockStudentSchedule) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Proposed Schedule")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            VStack(spacing: LadderSpacing.sm) {
                ForEach(student.periods) { period in
                    periodRow(period)
                }
            }
        }
    }

    private func periodRow(_ period: MockClassPeriod) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: LadderSpacing.md) {
                // Period number
                Text("P\(period.period)")
                    .font(LadderTypography.labelLarge)
                    .foregroundStyle(period.hasConflict ? LadderColors.error : LadderColors.onSurfaceVariant)
                    .frame(width: 32)

                // Class info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: LadderSpacing.xs) {
                        Text(period.className)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        if period.isAP {
                            Text("AP")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(LadderColors.primary)
                                .clipShape(Capsule())
                        }
                        if period.isHonors {
                            Text("H")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(LadderColors.tertiary)
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: LadderSpacing.sm) {
                        Text(period.teacher)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("\u{2022}")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("Room \(period.room)")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                if period.hasConflict {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(LadderColors.error)
                }
            }
            .padding(LadderSpacing.md)
            .background(
                period.hasConflict
                    ? LadderColors.errorContainer.opacity(0.15)
                    : LadderColors.surfaceContainerLow
            )
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

            // Conflict detail + AI suggestion
            if period.hasConflict, let reason = period.conflictReason {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(LadderColors.error)
                        Text(reason)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.error)
                    }

                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(LadderColors.secondary)
                        Text("AI suggestion: Move to Period \(period.period == 2 ? 5 : 2) or swap with a non-AP elective")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .padding(.leading, 44) // align with class info
            }
        }
    }

    // MARK: - Previous Year Schedule

    private func previousYearSection(_ periods: [MockClassPeriod]) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("Previous Year's Schedule")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }

            VStack(spacing: LadderSpacing.xs) {
                ForEach(periods) { period in
                    HStack(spacing: LadderSpacing.md) {
                        Text("P\(period.period)")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .frame(width: 32)

                        Text(period.className)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        Spacer()

                        Text(period.teacher)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.outline)
                    }
                    .padding(.vertical, LadderSpacing.xs)
                }
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: LadderSpacing.md) {
            // Approve
            Button {
                isApproved = true
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                    Text("APPROVE SCHEDULE")
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
            .buttonStyle(ScaleButtonStyle())

            // Request Changes
            Button {
                showChangesSheet = true
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14))
                    Text("Request Changes")
                        .font(LadderTypography.titleSmall)
                }
                .foregroundStyle(LadderColors.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surfaceContainerHighest)
                .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Approved Banner

    private var approvedBanner: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 24))
                .foregroundStyle(LadderColors.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Schedule Approved")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.primary)
                Text("Student has been notified")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.primaryContainer.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Request Changes Sheet

    private var requestChangesSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                VStack(spacing: LadderSpacing.lg) {
                    Text("Request Schedule Changes")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Describe what changes the student should make to their schedule.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    TextEditor(text: $changeNotes)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(LadderSpacing.md)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                    LadderPrimaryButton("Send Request", icon: "paperplane.fill") {
                        showChangesSheet = false
                    }
                    .disabled(changeNotes.isEmpty)
                    .opacity(changeNotes.isEmpty ? 0.5 : 1.0)

                    Spacer()
                }
                .padding(LadderSpacing.lg)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showChangesSheet = false
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func studentInitials(_ name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map { String($0) } }.joined()
    }
}

#Preview {
    NavigationStack {
        ClassApprovalDetailView(
            studentId: MockStudentSchedule.sampleStudents[1].id.uuidString
        )
    }
}
