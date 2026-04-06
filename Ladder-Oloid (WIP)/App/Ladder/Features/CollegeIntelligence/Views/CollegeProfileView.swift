import SwiftUI

// MARK: - College Profile Detail View

struct CollegeProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    let collegeId: String
    @State private var isFavorite = false
    @State private var selectedSection = 0

    private var college: CollegeListItem? {
        CollegeListItem.sampleColleges.first { $0.id == collegeId }
    }

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            if let college {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection(college)
                        quickStats(college)
                        sectionPicker
                        sectionContent(college)
                    }
                    .padding(.bottom, 120)
                }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { isFavorite.toggle() } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? LadderColors.error : LadderColors.onSurface)
                }
            }
        }
    }

    // MARK: - Hero

    private func heroSection(_ college: CollegeListItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Image placeholder
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primaryContainer, LadderColors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white.opacity(0.2))
                )

            // College name overlay
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                if let match = college.matchPercent {
                    Text("\(match)% MATCH")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.secondaryFixed)
                        .clipShape(Capsule())
                }

                Text(college.name)
                    .font(LadderTypography.headlineMedium)
                    .foregroundStyle(.white)

                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                    Text(college.location)
                        .font(LadderTypography.bodyMedium)
                }
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding(LadderSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    // MARK: - Quick Stats

    private func quickStats(_ college: CollegeListItem) -> some View {
        HStack(spacing: 0) {
            statItem(
                value: college.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A",
                label: "Acceptance",
                icon: "chart.pie.fill"
            )
            Divider().frame(height: 40)
            statItem(
                value: college.tuition.map { "$\(formatNumber($0))" } ?? "N/A",
                label: "Tuition",
                icon: "dollarsign.circle.fill"
            )
            Divider().frame(height: 40)
            statItem(
                value: college.satRange ?? "N/A",
                label: "SAT Range",
                icon: "pencil.line"
            )
            Divider().frame(height: 40)
            statItem(
                value: college.enrollment.map { formatNumber($0) } ?? "N/A",
                label: "Students",
                icon: "person.3.fill"
            )
        }
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(LadderColors.primary)

            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        let sections = ["Overview", "Deadlines", "Personality", "Actions"]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LadderSpacing.sm) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, title in
                    Button {
                        withAnimation { selectedSection = index }
                    } label: {
                        Text(title)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(selectedSection == index ? .white : LadderColors.onSurfaceVariant)
                            .padding(.horizontal, LadderSpacing.md)
                            .padding(.vertical, LadderSpacing.sm)
                            .background(selectedSection == index ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
        }
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(_ college: CollegeListItem) -> some View {
        switch selectedSection {
        case 0: overviewSection(college)
        case 1: deadlinesSection(college)
        case 2: personalitySection(college)
        case 3: actionsSection(college)
        default: EmptyView()
        }
    }

    // Overview
    private func overviewSection(_ college: CollegeListItem) -> some View {
        VStack(spacing: LadderSpacing.md) {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("About")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("\(college.name) is a \(college.type.lowercased()) institution located in \(college.location). With an enrollment of \(college.enrollment.map { formatNumber($0) } ?? "N/A") students, it offers a \(college.tags.contains("Large") ? "large" : college.tags.contains("Small") ? "small" : "medium")-sized campus experience.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }

            // Tags
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Known For")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    FlowLayout(spacing: LadderSpacing.sm) {
                        ForEach(college.tags, id: \.self) { tag in
                            LadderTagChip(tag)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // Deadlines
    private func deadlinesSection(_ college: CollegeListItem) -> some View {
        VStack(spacing: LadderSpacing.md) {
            deadlineRow(type: "Early Action", date: "November 1, 2026", daysLeft: 213)
            deadlineRow(type: "Early Decision", date: "November 1, 2026", daysLeft: 213)
            deadlineRow(type: "Regular Decision", date: "January 15, 2027", daysLeft: 288)

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Application Platforms")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    HStack(spacing: LadderSpacing.sm) {
                        LadderTagChip("Common App", icon: "doc.text")
                        LadderTagChip("Coalition App", icon: "doc.text")
                    }
                }
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("Testing Policy")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(LadderColors.accentLime)
                        Text("Test Optional")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Text("Submitting SAT/ACT scores is recommended but not required for admission.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private func deadlineRow(type: String, date: String, daysLeft: Int) -> some View {
        HStack {
            LadderTracker(height: 50)

            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(type)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(date)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }

            Spacer()

            Text("\(daysLeft) days")
                .font(LadderTypography.labelMedium)
                .foregroundStyle(daysLeft < 30 ? LadderColors.error : LadderColors.primary)
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xs)
                .background(
                    (daysLeft < 30 ? LadderColors.errorContainer : LadderColors.primaryContainer)
                        .opacity(0.3)
                )
                .clipShape(Capsule())
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // Personality
    private func personalitySection(_ college: CollegeListItem) -> some View {
        VStack(spacing: LadderSpacing.md) {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(LadderColors.accentLime)
                        Text("AI-Generated Personality")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                    }

                    Text("The \(college.tags.contains("STEM") ? "Builder/Maker" : college.tags.contains("Research") ? "Scholar/Researcher" : "Explorer")")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("This school values hands-on learning, practical experience, and collaborative problem-solving. Students thrive when they're builders who learn by doing.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    Divider()

                    Text("Culture Keywords")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    FlowLayout(spacing: LadderSpacing.sm) {
                        ForEach(["Innovative", "Collaborative", "Diverse", "Career-focused", "Hands-on"], id: \.self) { keyword in
                            LadderTagChip(keyword)
                        }
                    }
                }
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("What They Value in Applicants")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    importanceRow("Academic Rigor", importance: "Very Important")
                    importanceRow("GPA", importance: "Very Important")
                    importanceRow("Test Scores", importance: "Considered")
                    importanceRow("Extracurriculars", importance: "Important")
                    importanceRow("Essay", importance: "Important")
                    importanceRow("Demonstrated Interest", importance: "Considered")
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private func importanceRow(_ label: String, importance: String) -> some View {
        HStack {
            Text(label)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
            Spacer()
            Text(importance)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(importanceColor(importance))
        }
    }

    private func importanceColor(_ importance: String) -> Color {
        switch importance {
        case "Very Important": return LadderColors.error
        case "Important": return LadderColors.primary
        default: return LadderColors.onSurfaceVariant
        }
    }

    // Actions
    private func actionsSection(_ college: CollegeListItem) -> some View {
        VStack(spacing: LadderSpacing.md) {
            actionButton("Start Application", icon: "doc.badge.plus", description: "Track your application to \(college.name)") {
                coordinator.navigate(to: .applicationDetail(applicationId: college.id))
            }
            actionButton("Mock Interview", icon: "person.wave.2", description: "Practice interview questions for this school") {
                coordinator.navigate(to: .mockInterview(collegeId: college.id))
            }
            actionButton("Generate LOCI", icon: "envelope", description: "Draft a Letter of Continued Interest") {
                coordinator.navigate(to: .lociGenerator(collegeId: college.id))
            }
            actionButton("Compare Schools", icon: "arrow.left.arrow.right", description: "Side-by-side comparison with another school") {
                coordinator.navigate(to: .collegeComparison(leftId: college.id, rightId: ""))
            }
            actionButton("View Match Score", icon: "percent", description: "See detailed breakdown of your match") {
                coordinator.navigate(to: .matchScore(collegeId: college.id))
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private func actionButton(_ title: String, icon: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 44, height: 44)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
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

    // MARK: - Helpers

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    NavigationStack {
        CollegeProfileView(collegeId: "rit")
            .environment(AppCoordinator())
    }
}
