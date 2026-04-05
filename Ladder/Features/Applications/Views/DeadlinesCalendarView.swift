import SwiftUI

// MARK: - Deadlines Calendar View

struct DeadlinesCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    monthSelector
                    upcomingDeadlines
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Deadlines")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(Array(months.enumerated()), id: \.offset) { index, month in
                    let monthNum = index + 1
                    let hasDeadlines = deadlinesForMonth(monthNum).count > 0
                    Button {
                        withAnimation { selectedMonth = monthNum }
                    } label: {
                        VStack(spacing: LadderSpacing.xs) {
                            Text(month)
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(selectedMonth == monthNum ? .white : LadderColors.onSurfaceVariant)

                            if hasDeadlines {
                                Circle()
                                    .fill(selectedMonth == monthNum ? .white : LadderColors.accentLime)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(selectedMonth == monthNum ? LadderColors.primary : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Upcoming Deadlines

    private var upcomingDeadlines: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("\(months[selectedMonth - 1].uppercased()) DEADLINES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            let deadlines = deadlinesForMonth(selectedMonth)
            if deadlines.isEmpty {
                VStack(spacing: LadderSpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Text("No deadlines this month")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.xxxxl)
            } else {
                ForEach(deadlines) { deadline in
                    deadlineCard(deadline)
                }
            }
        }
    }

    private func deadlineCard(_ deadline: DeadlineItem) -> some View {
        Button {
            coordinator.navigate(to: .applicationDetail(applicationId: deadline.collegeId))
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Date column
                VStack(spacing: 2) {
                    Text(deadline.dayString)
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(deadline.isUrgent ? LadderColors.error : LadderColors.primary)

                    Text(deadline.weekday)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .frame(width: 48)

                Rectangle()
                    .fill(deadline.isUrgent ? LadderColors.error : LadderColors.primaryContainer)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(deadline.collegeName)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(deadline.type)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    HStack(spacing: LadderSpacing.sm) {
                        LadderTagChip(deadline.platform)
                        if deadline.isUrgent {
                            LadderTagChip("Urgent", icon: "exclamationmark.triangle")
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mock Data

    private func deadlinesForMonth(_ month: Int) -> [DeadlineItem] {
        let all: [DeadlineItem] = [
            DeadlineItem(collegeName: "SAT Registration", type: "Test Registration", platform: "College Board", collegeId: "sat", month: 4, day: 15, isUrgent: true),
            DeadlineItem(collegeName: "FAFSA Opens", type: "Financial Aid", platform: "studentaid.gov", collegeId: "fafsa", month: 10, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "University of Florida", type: "Early Action", platform: "Common App", collegeId: "uf", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Florida State University", type: "Early Action", platform: "Common App", collegeId: "fsu", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Emory University", type: "Early Decision", platform: "Common App", collegeId: "emory", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Georgia Tech", type: "Early Action", platform: "Common App", collegeId: "gatech", month: 11, day: 1, isUrgent: false),
            DeadlineItem(collegeName: "Rochester Institute of Technology", type: "Early Decision", platform: "Common App", collegeId: "rit", month: 11, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "University of Florida", type: "Regular Decision", platform: "Common App", collegeId: "uf", month: 1, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "Georgia Tech", type: "Regular Decision", platform: "Common App", collegeId: "gatech", month: 1, day: 4, isUrgent: false),
            DeadlineItem(collegeName: "Emory University", type: "Regular Decision", platform: "Common App", collegeId: "emory", month: 1, day: 15, isUrgent: false),
            DeadlineItem(collegeName: "National Decision Day", type: "Commitment Deadline", platform: "All Schools", collegeId: "ndd", month: 5, day: 1, isUrgent: false),
        ]
        return all.filter { $0.month == month }.sorted { $0.day < $1.day }
    }
}

// MARK: - Deadline Item

struct DeadlineItem: Identifiable {
    let id = UUID()
    let collegeName: String
    let type: String
    let platform: String
    let collegeId: String
    let month: Int
    let day: Int
    let isUrgent: Bool

    var dayString: String { "\(day)" }
    var weekday: String {
        let components = DateComponents(year: 2026, month: month, day: day)
        guard let date = Calendar.current.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DeadlinesCalendarView()
            .environment(AppCoordinator())
    }
}
