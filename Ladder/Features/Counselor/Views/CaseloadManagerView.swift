import SwiftUI
import SwiftData

// MARK: - Caseload Manager View
// Main view for counselors to browse and manage their student caseload.

struct CaseloadManagerView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    // Fetch all students sorted alphabetically; filter to this counselor's
    // school in-memory so we can cleanly handle an optional schoolId.
    @Query(sort: [SortDescriptor(\StudentProfileModel.firstName),
                  SortDescriptor(\StudentProfileModel.lastName)])
    private var allStudents: [StudentProfileModel]

    @Query private var applications: [ApplicationModel]

    @State private var viewModel = CaseloadManagerViewModel()

    /// Students enrolled at the current counselor's school.
    private var students: [StudentProfileModel] {
        guard let schoolId = authManager.schoolId, !schoolId.isEmpty else {
            return []
        }
        return allStudents.filter { $0.schoolId == schoolId }
    }

    private var filtered: [StudentProfileModel] {
        viewModel.filteredStudents(from: students)
    }

    private var hasJoinedSchool: Bool {
        if let id = authManager.schoolId, !id.isEmpty { return true }
        return false
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    headerSection
                    searchAndSort
                    filterChips

                    if !hasJoinedSchool {
                        joinSchoolPrompt
                    } else if students.isEmpty {
                        emptyState
                    } else if filtered.isEmpty {
                        noResultsState
                    } else {
                        studentList
                    }

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text("My Students")
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Manage your caseload")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            if !students.isEmpty {
                Text("\(students.count)")
                    .font(LadderTypography.labelLarge)
                    .foregroundStyle(LadderColors.onPrimary)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(LadderColors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(.top, LadderSpacing.lg)
    }

    // MARK: - Search & Sort

    private var searchAndSort: some View {
        VStack(spacing: LadderSpacing.sm) {
            LadderSearchBar(placeholder: "Search students...", text: $viewModel.searchText)

            HStack(spacing: LadderSpacing.sm) {
                ForEach(CaseloadManagerViewModel.SortOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedSort = option
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(
                                viewModel.selectedSort == option
                                    ? .white
                                    : LadderColors.onSurfaceVariant
                            )
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.sm)
                            .background(
                                viewModel.selectedSort == option
                                    ? LadderColors.primary
                                    : LadderColors.surfaceContainerHigh
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(CaseloadManagerViewModel.GradeFilter.allCases, id: \.self) { filter in
                    LadderFilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
        }
    }

    // MARK: - Student List

    private var studentList: some View {
        LazyVStack(spacing: LadderSpacing.md) {
            ForEach(filtered, id: \.self) { student in
                Button {
                    coordinator.navigateForRole(
                        to: .studentDetailCounselor(studentId: student.persistentModelID.hashValue.description),
                        role: .counselor
                    )
                } label: {
                    StudentCaseloadCard(
                        student: student,
                        applicationCount: applicationCount(for: student)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Join School Prompt (no schoolId on account)

    private var joinSchoolPrompt: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xxl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("Join a school to see your students")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .multilineTextAlignment(.center)

            Text("Enter your school code to connect your counselor account. Your school's students will appear here once you're linked.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)

            Button {
                coordinator.navigateForRole(to: .counselorVerification, role: .counselor)
            } label: {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 12))
                    Text("Join a School")
                        .font(LadderTypography.labelMedium)
                }
                .foregroundStyle(LadderColors.onPrimary)
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xxl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Students Linked Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Share your school code to connect students. Once linked, their profiles, applications, and progress will appear here.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)

            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 12))
                Text("Share School Code to Connect")
                    .font(LadderTypography.labelMedium)
            }
            .foregroundStyle(LadderColors.primary)
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(LadderColors.primaryContainer.opacity(0.3))
            .clipShape(Capsule())
        }
    }

    // MARK: - No Results State

    private var noResultsState: some View {
        VStack(spacing: LadderSpacing.md) {
            Spacer().frame(height: LadderSpacing.xl)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(LadderColors.outlineVariant)

            Text("No students match your filters")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            Text("Try adjusting your search or filter criteria.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Helpers

    private func applicationCount(for student: StudentProfileModel) -> Int {
        // In a real B2B setup, applications would be linked per-student.
        // For now, return total application count as a proxy.
        applications.filter { $0.status == "submitted" || $0.status == "accepted" }.count
    }
}

// MARK: - Student Caseload Card

struct StudentCaseloadCard: View {
    let student: StudentProfileModel
    let applicationCount: Int

    private var status: StudentStatus {
        CaseloadManagerViewModel.statusForStudent(student)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            // Top row: name + grade badge
            HStack(spacing: LadderSpacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.4))
                        .frame(width: 44, height: 44)
                    Text(student.firstName.prefix(1).uppercased())
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: LadderSpacing.sm) {
                        Text(student.fullName)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(1)

                        // Grade badge
                        Text("Grade \(student.grade)")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, 2)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(Capsule())
                    }

                    if let school = student.schoolName {
                        Text(school)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Status chip
                Text(status.rawValue)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(status.color)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xs)
                    .background(status.containerColor)
                    .clipShape(Capsule())
            }

            // Stats row
            HStack(spacing: LadderSpacing.lg) {
                if let gpa = student.gpa {
                    statItem(label: "GPA", value: String(format: "%.2f", gpa))
                }
                if let sat = student.satScore {
                    statItem(label: "SAT", value: "\(sat)")
                }
                if let act = student.actScore {
                    statItem(label: "ACT", value: "\(act)")
                }
                statItem(label: "Apps", value: "\(applicationCount)")
            }

            // Bottom row: last activity
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("Last active: \(CaseloadManagerViewModel.lastActivityText(for: student))")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.outlineVariant)
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }
}
