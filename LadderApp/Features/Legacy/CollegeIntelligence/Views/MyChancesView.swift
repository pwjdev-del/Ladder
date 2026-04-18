import SwiftUI
import SwiftData

// MARK: - My Chances View
// Admission probability calculator across all saved colleges

struct MyChancesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var vm = MyChancesViewModel()
    @State private var showingSortPicker = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    if !vm.hasProfile {
                        noProfileState
                    } else if vm.collegeChances.isEmpty {
                        emptyState
                    } else {
                        // Student stats header
                        studentStatsCard

                        // Summary badges
                        summaryBadges

                        // Bar chart overview
                        barChartCard

                        // Sort control
                        sortControl

                        // College chances list
                        collegeChancesList

                        // Improvement suggestions
                        suggestionsSection
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
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
                Text("My Chances")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            vm.loadData(from: context)
        }
    }

    // MARK: - Student Stats Card

    private var studentStatsCard: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Text("Your Profile")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.lg) {
                    profileStat("GPA", vm.studentGPA > 0 ? String(format: "%.2f", vm.studentGPA) : "--")
                    profileStat("SAT", vm.studentSAT > 0 ? "\(vm.studentSAT)" : "--")
                    profileStat("APs", "\(vm.studentAPCount)")
                }
            }
        }
    }

    private func profileStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text(value)
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.primary)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Summary Badges

    private var summaryBadges: some View {
        HStack(spacing: LadderSpacing.sm) {
            summaryBadge("\(vm.safetyCount)", "Safety", LadderColors.primary)
            summaryBadge("\(vm.matchCount)", "Match", LadderColors.secondaryFixedDim)
            summaryBadge("\(vm.reachCount)", "Reach", LadderColors.error)
        }
    }

    private func summaryBadge(_ count: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text(count)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(color)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
    }

    // MARK: - Bar Chart

    private var barChartCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Chances Overview")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(vm.collegeChances) { chance in
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        HStack {
                            Text(chance.college.name)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)
                            Spacer()
                            Text("\(Int(chance.chancePercent))%")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(categoryColor(chance.category))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LadderColors.surfaceContainerHighest)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(categoryColor(chance.category))
                                    .frame(width: geo.size.width * chance.chancePercent / 100)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
    }

    // MARK: - Sort Control

    private var sortControl: some View {
        HStack {
            Text("YOUR COLLEGES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            Spacer()

            Menu {
                ForEach(MyChancesViewModel.SortOrder.allCases, id: \.self) { order in
                    Button {
                        vm.sortOrder = order
                        vm.sortColleges()
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if vm.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: LadderSpacing.xs) {
                    Text(vm.sortOrder.rawValue)
                        .font(LadderTypography.labelMedium)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(LadderColors.primary)
            }
        }
    }

    // MARK: - College Chances List

    private var collegeChancesList: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(vm.collegeChances) { chance in
                collegeChanceRow(chance)
            }
        }
    }

    private func collegeChanceRow(_ chance: MyChancesViewModel.CollegeChance) -> some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                // Match indicator
                ZStack {
                    Circle()
                        .stroke(LadderColors.surfaceContainerHighest, lineWidth: 4)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: chance.chancePercent / 100)
                        .stroke(categoryColor(chance.category), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(chance.chancePercent))%")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(chance.college.name)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)

                    HStack(spacing: LadderSpacing.sm) {
                        Text(chance.category.rawValue)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(categoryColor(chance.category))
                            .clipShape(Capsule())

                        if let rate = chance.college.acceptanceRate {
                            Text("\(Int(rate * 100))% acceptance")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    if let city = chance.college.city, let state = chance.college.state {
                        Text("\(city), \(state)")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Suggestions

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(LadderColors.secondaryFixed)
                Text("Improve Your Chances")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }

            ForEach(vm.suggestions) { suggestion in
                LadderCard {
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(LadderColors.primary)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            Text(suggestion.text)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(suggestion.impact)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.primary)
                                .padding(.horizontal, LadderSpacing.sm)
                                .padding(.vertical, LadderSpacing.xxs)
                                .background(LadderColors.primaryContainer.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty / No Profile States

    private var noProfileState: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("Complete your profile first")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Add your GPA, SAT score, and other details in Profile Settings to see your admission chances.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var emptyState: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("No saved colleges yet")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Save colleges from the Discovery Hub to see your admission chances for each one.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helpers

    private func categoryColor(_ category: MyChancesViewModel.MatchCategory) -> Color {
        switch category {
        case .reach: return LadderColors.error
        case .match: return LadderColors.secondaryFixedDim
        case .safety: return LadderColors.primary
        }
    }
}
