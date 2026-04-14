import SwiftUI
import SwiftData

// MARK: - College Profile Detail View

struct CollegeProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    let collegeId: String
    @State private var isFavorite = false
    @State private var selectedSection = 0

    private var userGrade: Int { profiles.first?.grade ?? 10 }

    private var edYear: Int {
        // If we're past November, use next year for upcoming ED/EA deadlines
        let now = Date()
        let month = Calendar.current.component(.month, from: now)
        return Calendar.current.component(.year, from: now) + (month > 10 ? 1 : 0)
    }
    private var rdYear: Int { edYear + 1 }

    private var college: CollegeListItem? {
        CollegeListItem.sampleColleges.first { $0.id == collegeId }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
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

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
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
    }

    // MARK: - iPad Layout (two-column, 65/35)

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if let college {
                HStack(alignment: .top, spacing: LadderSpacing.xl) {
                    // Left 65% — hero + tabs + section content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.lg) {
                            iPadHero(college)
                            sectionPicker
                                .padding(.horizontal, 0)
                            sectionContent(college)
                                .padding(.horizontal, 0)
                        }
                        .padding(.horizontal, LadderSpacing.xl)
                        .padding(.top, LadderSpacing.lg)
                        .padding(.bottom, LadderSpacing.xxxxl)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    // Right 35% — stats stack + fit + CTAs
                    ScrollView(showsIndicators: false) {
                        iPadRightColumn(college)
                            .padding(.trailing, LadderSpacing.xl)
                            .padding(.top, LadderSpacing.lg)
                            .padding(.bottom, LadderSpacing.xxxxl)
                    }
                    .frame(width: 380)
                }
            }
        }
    }

    private func iPadHero(_ college: CollegeListItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primaryContainer, LadderColors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 320)
                .overlay(
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(.white.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                if let match = college.matchPercent {
                    Text("\(match)% MATCH")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                        .labelTracking()
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.xs)
                        .background(LadderColors.secondaryFixed)
                        .clipShape(Capsule())
                }

                Text(college.name)
                    .font(LadderTypography.displaySmall)
                    .foregroundStyle(.white)
                    .editorialTracking()

                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                    Text(college.location)
                        .font(LadderTypography.titleMedium)
                }
                .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: LadderSpacing.xs) {
                    ForEach(college.tags, id: \.self) { tag in
                        Text(tag)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(.white)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, LadderSpacing.xs)
            }
            .padding(LadderSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    private func iPadRightColumn(_ college: CollegeListItem) -> some View {
        VStack(spacing: LadderSpacing.md) {
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text("At a Glance")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    statRow("Acceptance", college.acceptanceRate.map { "\(Int($0 * 100))%" } ?? "N/A")
                    statRow("Tuition (In-State)", college.tuition.map { "$\(formatNumber($0))" } ?? "N/A")
                    statRow("Tuition (Out-of-State)", college.tuition.map { "$\(formatNumber($0 + 15000))" } ?? "N/A")
                    statRow("SAT Range", college.satRange ?? "N/A")
                    statRow("ACT Range", "28-33")
                    statRow("Enrollment", college.enrollment.map { formatNumber($0) } ?? "N/A")
                    statRow("Graduation Rate", "86%")
                    statRow("Student-Faculty", "12:1")
                }
            }

            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(LadderColors.accentLime)
                        Text("YOUR FIT")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .labelTracking()
                    }

                    if let m = college.matchPercent {
                        HStack(spacing: LadderSpacing.md) {
                            CircularProgressView(
                                progress: Double(m) / 100.0,
                                label: "\(m)%",
                                sublabel: "Match",
                                size: 80
                            )
                            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                Text(m >= 75 ? "Strong Match" : m >= 40 ? "Good Match" : "Reach")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Based on your profile")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }
                }
            }

            LadderPrimaryButton("Start Application", icon: "arrow.right") {
                coordinator.navigate(to: .applicationDetail(applicationId: college.id))
            }

            Button {
                isFavorite.toggle()
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                    Text(isFavorite ? "Saved to List" : "Add to List")
                        .font(LadderTypography.titleSmall)
                }
                .foregroundStyle(LadderColors.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surfaceContainerHigh)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
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
            if userGrade >= 11 {
                deadlineRow(type: "Early Action", date: "November 1, \(String(edYear))", daysLeft: 213)
                deadlineRow(type: "Early Decision", date: "November 1, \(String(edYear))", daysLeft: 213)
                deadlineRow(type: "Regular Decision", date: "January 15, \(String(rdYear))", daysLeft: 288)
            } else {
                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Typical Application Timeline")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Typical deadlines: Early Decision ~November, Regular Decision ~January")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("Specific dates unlock in 11th grade.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }

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
            if GradeGate.isUnlocked(.lociGenerator, grade: userGrade) {
                actionButton("Generate LOCI", icon: "envelope", description: "Draft a Letter of Continued Interest") {
                    coordinator.navigate(to: .lociGenerator(collegeId: college.id))
                }
            } else {
                LockedFeatureCard(title: "Generate LOCI", icon: "envelope", feature: .lociGenerator, userGrade: userGrade)
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

// FlowLayout is defined in OnboardingContainerView.swift and shared across the app

#Preview {
    NavigationStack {
        CollegeProfileView(collegeId: "rit")
            .environment(AppCoordinator())
    }
}
