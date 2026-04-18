import SwiftUI
import SwiftData

// MARK: - Post Graduation View
// For students who've committed to a college

struct PostGraduationView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<ApplicationModel> { $0.status == "committed" })
    private var committedApps: [ApplicationModel]

    private var committedCollege: ApplicationModel? { committedApps.first }

    // Approximate move-in: August 20 of current or next year
    private var moveInDate: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year], from: now)
        // If we're past August, target next year
        if calendar.component(.month, from: now) > 8 {
            components.year = (components.year ?? 2026) + 1
        }
        components.month = 8
        components.day = 20
        return calendar.date(from: components) ?? now
    }

    private var daysUntilMoveIn: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: moveInDate).day ?? 0)
    }

    private let quickLinks: [(icon: String, title: String, subtitle: String)] = [
        ("house.fill", "Housing", "Secure your dorm room"),
        ("person.3.fill", "Orientation", "Register for orientation"),
        ("book.fill", "Course Registration", "Plan your first semester"),
        ("person.2.fill", "Roommate Finder", "Find your roommate match")
    ]

    private let summerChecklist: [(title: String, done: Bool)] = [
        ("Accept admission offer", true),
        ("Submit housing deposit", false),
        ("Complete health forms", false),
        ("Register for orientation", false),
        ("Submit final transcript", false),
        ("Set up student email", false),
        ("Apply for work-study jobs", false),
        ("Buy dorm essentials", false)
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {

                    // Celebration header
                    VStack(spacing: LadderSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.3))
                                .frame(width: 100, height: 100)
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LadderColors.primary)
                        }

                        Text("Congratulations!")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        if let college = committedCollege {
                            Text("You're going to \(college.collegeName)!")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.primary)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Once you commit to a college, your post-graduation hub will appear here.")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Countdown
                    if committedCollege != nil {
                        VStack(spacing: LadderSpacing.sm) {
                            Text("\(daysUntilMoveIn)")
                                .font(LadderTypography.displayMedium)
                                .foregroundStyle(LadderColors.primary)

                            Text("days until move-in")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.xl)
                        .background(LadderColors.primaryContainer.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                        // Quick links
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Quick Links")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(quickLinks, id: \.title) { link in
                                HStack(spacing: LadderSpacing.md) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                                            .fill(LadderColors.primaryContainer.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: link.icon)
                                            .font(.system(size: 16))
                                            .foregroundStyle(LadderColors.primary)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(link.title)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Text(link.subtitle)
                                            .font(LadderTypography.bodySmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                                }
                                .padding(LadderSpacing.md)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                            }
                        }

                        // First 100 Days tracker
                        HStack(spacing: LadderSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                                    .fill(LadderColors.primaryContainer.opacity(0.3))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "calendar.badge.checkmark")
                                    .font(.system(size: 22))
                                    .foregroundStyle(LadderColors.primary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("First 100 Days Tracker")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("Make the most of your first semester")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(LadderColors.primary)
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                        // Summer prep checklist
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Summer Prep Checklist")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(summerChecklist, id: \.title) { item in
                                HStack(spacing: LadderSpacing.md) {
                                    Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundStyle(item.done ? LadderColors.primary : LadderColors.outlineVariant)

                                    Text(item.title)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(item.done ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                                        .strikethrough(item.done, color: LadderColors.onSurfaceVariant)

                                    Spacer()
                                }
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Post-Graduation")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }
}
