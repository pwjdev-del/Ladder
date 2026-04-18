import SwiftUI

// MARK: - Mock Data for Class Approval

struct MockClassPeriod: Identifiable {
    let id = UUID()
    let period: Int
    let className: String
    let teacher: String
    let room: String
    let isAP: Bool
    let isHonors: Bool
    let hasConflict: Bool
    let conflictReason: String?
}

struct MockStudentSchedule: Identifiable {
    let id = UUID()
    let name: String
    let grade: Int
    let gpa: Double
    let apCount: Int
    let honorsCount: Int
    let conflictCount: Int
    let aiWarning: String?
    let periods: [MockClassPeriod]
    let previousYearPeriods: [MockClassPeriod]?
}

// MARK: - Sample Data

extension MockStudentSchedule {
    static let sampleStudents: [MockStudentSchedule] = [
        MockStudentSchedule(
            name: "Emily Chen", grade: 11, gpa: 3.95, apCount: 3, honorsCount: 1,
            conflictCount: 0, aiWarning: nil,
            periods: [
                MockClassPeriod(period: 1, className: "AP Calculus AB", teacher: "Mr. Torres", room: "204", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP English Language", teacher: "Ms. Rivera", room: "112", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "AP Chemistry", teacher: "Dr. Patel", room: "305", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "Honors US History", teacher: "Mr. Kim", room: "118", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 5, className: "Spanish III", teacher: "Sra. Lopez", room: "220", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Art Studio", teacher: "Ms. Park", room: "401", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
        MockStudentSchedule(
            name: "Marcus Johnson", grade: 12, gpa: 3.2, apCount: 4, honorsCount: 0,
            conflictCount: 2, aiWarning: "4 APs with 3.2 GPA -- may be too heavy",
            periods: [
                MockClassPeriod(period: 1, className: "AP Physics C", teacher: "Dr. Novak", room: "310", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP Calculus BC", teacher: "Mr. Torres", room: "204", isAP: true, isHonors: false, hasConflict: true, conflictReason: "Same period as required Senior Seminar"),
                MockClassPeriod(period: 3, className: "AP Government", teacher: "Ms. White", room: "120", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "AP Literature", teacher: "Ms. Rivera", room: "112", isAP: true, isHonors: false, hasConflict: true, conflictReason: "Teacher unavailable this period"),
                MockClassPeriod(period: 5, className: "Senior Seminar", teacher: "Mr. Lee", room: "100", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Study Hall", teacher: "—", room: "Library", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: [
                MockClassPeriod(period: 1, className: "AP US History", teacher: "Mr. Kim", room: "118", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "Pre-Calculus", teacher: "Ms. Chen", room: "202", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "English 11", teacher: "Mr. Hall", room: "110", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "Chemistry", teacher: "Dr. Patel", room: "305", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 5, className: "Spanish II", teacher: "Sra. Lopez", room: "220", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Elective: Music", teacher: "Mr. Ray", room: "403", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ]
        ),
        MockStudentSchedule(
            name: "Sofia Martinez", grade: 10, gpa: 3.75, apCount: 1, honorsCount: 2,
            conflictCount: 0, aiWarning: nil,
            periods: [
                MockClassPeriod(period: 1, className: "Honors Geometry", teacher: "Ms. Chen", room: "202", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP World History", teacher: "Mr. Kim", room: "118", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "Honors English 10", teacher: "Mr. Hall", room: "110", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "Biology", teacher: "Ms. Green", room: "302", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 5, className: "French II", teacher: "Mme. Dupont", room: "222", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Digital Arts", teacher: "Ms. Park", room: "401", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
        MockStudentSchedule(
            name: "Aiden Williams", grade: 11, gpa: 2.9, apCount: 3, honorsCount: 0,
            conflictCount: 1, aiWarning: "3 APs with 2.9 GPA -- consider reducing load",
            periods: [
                MockClassPeriod(period: 1, className: "AP Biology", teacher: "Ms. Green", room: "302", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP US History", teacher: "Mr. Kim", room: "118", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "Algebra II", teacher: "Ms. Chen", room: "202", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "AP Computer Science A", teacher: "Mr. Zhao", room: "Lab 2", isAP: true, isHonors: false, hasConflict: true, conflictReason: "Conflicts with required English 11 section"),
                MockClassPeriod(period: 5, className: "English 11", teacher: "Mr. Hall", room: "110", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Woodshop", teacher: "Mr. Berg", room: "Shop", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
        MockStudentSchedule(
            name: "Priya Sharma", grade: 12, gpa: 4.0, apCount: 4, honorsCount: 1,
            conflictCount: 0, aiWarning: nil,
            periods: [
                MockClassPeriod(period: 1, className: "AP Calculus BC", teacher: "Mr. Torres", room: "204", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP Physics C", teacher: "Dr. Novak", room: "310", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "AP Literature", teacher: "Ms. Rivera", room: "112", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "AP Statistics", teacher: "Ms. Chen", room: "202", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 5, className: "Honors Economics", teacher: "Mr. White", room: "120", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "Senior Seminar", teacher: "Mr. Lee", room: "100", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Orchestra", teacher: "Mr. Ray", room: "403", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
        MockStudentSchedule(
            name: "Jordan Taylor", grade: 9, gpa: 3.5, apCount: 0, honorsCount: 2,
            conflictCount: 0, aiWarning: nil,
            periods: [
                MockClassPeriod(period: 1, className: "Honors English 9", teacher: "Ms. Adams", room: "108", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "Honors Algebra I", teacher: "Ms. Chen", room: "200", isAP: false, isHonors: true, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "Earth Science", teacher: "Mr. Stone", room: "300", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "World Geography", teacher: "Ms. White", room: "122", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 5, className: "Spanish I", teacher: "Sra. Lopez", room: "220", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Intro to Computer Science", teacher: "Mr. Zhao", room: "Lab 1", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
        MockStudentSchedule(
            name: "Liam O'Connor", grade: 10, gpa: 3.1, apCount: 2, honorsCount: 0,
            conflictCount: 1, aiWarning: "2 APs with 3.1 GPA -- monitor closely",
            periods: [
                MockClassPeriod(period: 1, className: "AP Human Geography", teacher: "Ms. White", room: "122", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 2, className: "AP Computer Science Principles", teacher: "Mr. Zhao", room: "Lab 2", isAP: true, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 3, className: "English 10", teacher: "Mr. Hall", room: "110", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 4, className: "Chemistry", teacher: "Dr. Patel", room: "305", isAP: false, isHonors: false, hasConflict: true, conflictReason: "Lab section full, waitlisted"),
                MockClassPeriod(period: 5, className: "Algebra II", teacher: "Ms. Chen", room: "202", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 6, className: "PE / Health", teacher: "Coach Davis", room: "Gym", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
                MockClassPeriod(period: 7, className: "Band", teacher: "Mr. Ray", room: "403", isAP: false, isHonors: false, hasConflict: false, conflictReason: nil),
            ],
            previousYearPeriods: nil
        ),
    ]
}

// MARK: - Class Approval List View

struct ClassApprovalListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator

    @State private var students = MockStudentSchedule.sampleStudents
    @State private var selectedFilter = "All"
    @State private var approvedIds: Set<UUID> = []

    private let filters = ["All", "No Conflicts", "Has Conflicts", "Grade 9", "Grade 10", "Grade 11", "Grade 12"]

    private var filteredStudents: [MockStudentSchedule] {
        switch selectedFilter {
        case "No Conflicts": return students.filter { $0.conflictCount == 0 }
        case "Has Conflicts": return students.filter { $0.conflictCount > 0 }
        case "Grade 9": return students.filter { $0.grade == 9 }
        case "Grade 10": return students.filter { $0.grade == 10 }
        case "Grade 11": return students.filter { $0.grade == 11 }
        case "Grade 12": return students.filter { $0.grade == 12 }
        default: return students
        }
    }

    private var pendingCount: Int {
        students.count - approvedIds.count
    }

    private var noConflictIds: Set<UUID> {
        Set(students.filter { $0.conflictCount == 0 && !approvedIds.contains($0.id) }.map(\.id))
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        HStack(alignment: .center) {
                            Text("Class Schedule Approvals")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            Spacer()

                            // Pending badge
                            Text("\(pendingCount) pending")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, LadderSpacing.md)
                                .padding(.vertical, LadderSpacing.xs)
                                .background(pendingCount > 0 ? LadderColors.error : LadderColors.primary)
                                .clipShape(Capsule())
                        }

                        Text("Review and approve student class selections")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LadderSpacing.sm) {
                            ForEach(filters, id: \.self) { filter in
                                LadderFilterChip(title: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }

                    // Bulk approve button
                    if !noConflictIds.isEmpty {
                        Button {
                            approvedIds.formUnion(noConflictIds)
                        } label: {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                Text("Approve All No-Conflict (\(noConflictIds.count))")
                                    .font(LadderTypography.titleSmall)
                            }
                            .foregroundStyle(LadderColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.md)
                            .background(LadderColors.primaryContainer.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    // Student cards
                    ForEach(filteredStudents) { student in
                        studentCard(student)
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
                Text("Approvals")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Student Card

    private func studentCard(_ student: MockStudentSchedule) -> some View {
        let isApproved = approvedIds.contains(student.id)

        return VStack(alignment: .leading, spacing: LadderSpacing.md) {
            // Name row
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    HStack(spacing: LadderSpacing.sm) {
                        Text(student.name)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        if isApproved {
                            Text("Approved")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.primary)
                                .padding(.horizontal, LadderSpacing.sm)
                                .padding(.vertical, LadderSpacing.xxs)
                                .background(LadderColors.primaryContainer.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }

                    Text("Grade \(student.grade) \u{2022} GPA \(String(format: "%.2f", student.gpa))")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()

                // AP/Honors count
                VStack(alignment: .trailing, spacing: 2) {
                    if student.apCount > 0 {
                        Text("\(student.apCount) AP")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                    if student.honorsCount > 0 {
                        Text("\(student.honorsCount) Honors")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.tertiary)
                    }
                }
            }

            // Conflict status
            HStack(spacing: LadderSpacing.sm) {
                if student.conflictCount == 0 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.primary)
                    Text("No Conflicts")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.error)
                    Text("\(student.conflictCount) Conflict\(student.conflictCount == 1 ? "" : "s")")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.error)
                }
            }

            // AI Warning
            if let warning = student.aiWarning {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12))
                        .foregroundStyle(LadderColors.tertiary)
                    Text(warning)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.tertiary)
                }
                .padding(LadderSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LadderColors.tertiaryContainer.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
            }

            // Action buttons
            if !isApproved {
                HStack(spacing: LadderSpacing.sm) {
                    // Approve
                    Button {
                        approvedIds.insert(student.id)
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Approve")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    // Review
                    NavigationLink(value: Route.classApprovalDetail(studentId: student.id.uuidString)) {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 12))
                            Text("Review")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    // Request Changes
                    Button {} label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 12))
                            Text("Request Changes")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ClassApprovalListView()
            .environment(AppCoordinator())
    }
}
