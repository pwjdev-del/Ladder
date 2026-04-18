import SwiftUI
import SwiftData

// MARK: - Student Detail View (Counselor)
// Read-only view of a student's full profile, applications, and activities.

struct StudentDetailCounselorView: View {
    @Environment(\.dismiss) private var dismiss
    let studentId: String

    @Query private var students: [StudentProfileModel]
    @Query private var applications: [ApplicationModel]
    @Query private var activities: [ActivityModel]

    @State private var noteText: String = ""
    @State private var showMeetingAlert = false
    @State private var selectedSection: DetailSection = .academic

    private var student: StudentProfileModel? {
        // Match by hash of persistentModelID, or fall back to first student in dev
        students.first { $0.persistentModelID.hashValue.description == studentId }
            ?? students.first
    }

    enum DetailSection: String, CaseIterable {
        case academic = "Academic"
        case colleges = "Colleges"
        case applications = "Applications"
        case activities = "Activities"
        case notes = "Notes"
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if let student {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        studentHeader(student)
                        statsRow(student)
                        sectionPicker
                        sectionContent(student)
                        scheduleMeetingButton
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, LadderSpacing.lg)
                }
            } else {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.outlineVariant)
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
                Text("Student Profile")
                    .font(LadderTypography.titleSmall)
            }
        }
        .onAppear { loadNotes() }
        .alert("Schedule Meeting", isPresented: $showMeetingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let student {
                Text("Meeting scheduling with \(student.fullName) will be available in a future update. For now, reach out via your school's communication system.")
            }
        }
    }

    // MARK: - Student Header

    private func studentHeader(_ student: StudentProfileModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 80, height: 80)
                Text(student.firstName.prefix(1).uppercased() + student.lastName.prefix(1).uppercased())
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.primary)
            }

            Text(student.fullName)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            HStack(spacing: LadderSpacing.md) {
                Text("Grade \(student.grade)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.primary)
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(Capsule())

                if let school = student.schoolName {
                    Text(school)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            // Status
            let status = CaseloadManagerViewModel.statusForStudent(student)
            HStack(spacing: LadderSpacing.xs) {
                Circle()
                    .fill(status.color)
                    .frame(width: 8, height: 8)
                Text(status.rawValue)
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(status.color)
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(status.containerColor)
            .clipShape(Capsule())
        }
        .padding(.top, LadderSpacing.lg)
    }

    // MARK: - Stats Row

    private func statsRow(_ student: StudentProfileModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            statBadge(value: student.gpa.map { String(format: "%.2f", $0) } ?? "--", label: "GPA")
            statBadge(value: student.satScore.map { "\($0)" } ?? "--", label: "SAT")
            statBadge(value: "\(applications.count)", label: "Apps")
            statBadge(value: "\(activities.count)", label: "Activities")
        }
    }

    private func statBadge(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(DetailSection.allCases, id: \.self) { section in
                    LadderFilterChip(
                        title: section.rawValue,
                        isSelected: selectedSection == section
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedSection = section
                        }
                    }
                }
            }
        }
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(_ student: StudentProfileModel) -> some View {
        switch selectedSection {
        case .academic:
            academicSection(student)
        case .colleges:
            collegeListSection(student)
        case .applications:
            applicationsSection
        case .activities:
            activitiesSection
        case .notes:
            notesSection(student)
        }
    }

    // MARK: - Academic Summary

    private func academicSection(_ student: StudentProfileModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Academic Summary")

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    detailRow(icon: "chart.bar.fill", label: "GPA",
                              value: student.gpa.map { String(format: "%.2f", $0) } ?? "Not reported")
                    detailRow(icon: "doc.text.fill", label: "SAT Score",
                              value: student.satScore.map { "\($0)" } ?? "Not taken")
                    detailRow(icon: "pencil.and.list.clipboard", label: "ACT Score",
                              value: student.actScore.map { "\($0)" } ?? "Not taken")
                    detailRow(icon: "person.text.rectangle", label: "First Generation",
                              value: student.isFirstGen ? "Yes" : "No")

                    if !student.apCourses.isEmpty {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("AP Courses (\(student.apCourses.count))")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            FlowLayout(spacing: LadderSpacing.xs) {
                                ForEach(student.apCourses, id: \.self) { course in
                                    LadderTagChip(course)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - College List

    private func collegeListSection(_ student: StudentProfileModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("College List")

            if student.savedCollegeIds.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 28))
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("No colleges saved yet")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                }
            } else {
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        ForEach(student.savedCollegeIds, id: \.self) { collegeId in
                            HStack(spacing: LadderSpacing.md) {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.5))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "building.columns")
                                            .font(.system(size: 14))
                                            .foregroundStyle(LadderColors.primary)
                                    )

                                Text(collegeId)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Applications

    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Applications")

            if applications.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 28))
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("No applications started")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                }
            } else {
                ForEach(applications, id: \.self) { app in
                    LadderCard {
                        HStack(spacing: LadderSpacing.md) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.collegeName)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)

                                if let deadline = app.deadlineType {
                                    Text(deadline)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }

                            Spacer()

                            applicationStatusChip(app.status)
                        }
                    }
                }
            }
        }
    }

    private func applicationStatusChip(_ status: String) -> some View {
        let (label, chipColor) = applicationStatusInfo(status)
        return Text(label)
            .font(LadderTypography.labelSmall)
            .foregroundStyle(chipColor)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xs)
            .background(chipColor.opacity(0.15))
            .clipShape(Capsule())
    }

    private func applicationStatusInfo(_ status: String) -> (String, Color) {
        switch status {
        case "submitted": return ("Submitted", LadderColors.primary)
        case "accepted": return ("Accepted", Color(red: 0.2, green: 0.7, blue: 0.3))
        case "rejected": return ("Rejected", LadderColors.error)
        case "waitlisted": return ("Waitlisted", Color(red: 0.9, green: 0.7, blue: 0.1))
        case "committed": return ("Committed", LadderColors.primary)
        case "in_progress": return ("In Progress", Color(red: 0.3, green: 0.5, blue: 0.9))
        default: return ("Planning", LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Activities")

            if activities.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "star")
                            .font(.system(size: 28))
                            .foregroundStyle(LadderColors.outlineVariant)
                        Text("No activities recorded")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LadderSpacing.md)
                }
            } else {
                ForEach(activities, id: \.self) { activity in
                    LadderCard {
                        HStack(spacing: LadderSpacing.md) {
                            Image(systemName: ActivityModel.categoryIcons[activity.category] ?? "star.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(LadderColors.primary)
                                .frame(width: 36, height: 36)
                                .background(LadderColors.primaryContainer.opacity(0.3))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.name)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .lineLimit(1)

                                HStack(spacing: LadderSpacing.sm) {
                                    Text(activity.category)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)

                                    if let role = activity.role {
                                        Text(role)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                    }
                                }
                            }

                            Spacer()

                            if activity.isLeadership {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(red: 0.9, green: 0.7, blue: 0.1))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notes

    private func notesSection(_ student: StudentProfileModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Counselor Notes")

            Text("Private notes only visible to you.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            VStack(spacing: LadderSpacing.sm) {
                TextEditor(text: $noteText)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(LadderSpacing.md)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                HStack {
                    Spacer()
                    Button {
                        saveNotes(for: student)
                    } label: {
                        Text("Save Notes")
                            .font(LadderTypography.labelLarge)
                            .foregroundStyle(.white)
                            .padding(.horizontal, LadderSpacing.lg)
                            .padding(.vertical, LadderSpacing.sm)
                            .background(LadderColors.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Schedule Meeting

    private var scheduleMeetingButton: some View {
        LadderPrimaryButton("Schedule Meeting", icon: "calendar.badge.plus") {
            showMeetingAlert = true
        }
        .padding(.top, LadderSpacing.md)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(LadderTypography.titleMedium)
            .foregroundStyle(LadderColors.onSurface)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24)

            Text(label)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            Spacer()

            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    private var notesKey: String {
        "counselor_notes_\(studentId)"
    }

    private func loadNotes() {
        noteText = UserDefaults.standard.string(forKey: notesKey) ?? ""
    }

    private func saveNotes(for student: StudentProfileModel) {
        UserDefaults.standard.set(noteText, forKey: notesKey)
    }
}

// FlowLayout is defined in OnboardingContainerView.swift and reused here
