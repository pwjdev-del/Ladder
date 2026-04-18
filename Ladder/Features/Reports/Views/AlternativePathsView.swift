import SwiftUI

// MARK: - Alternative Paths View
// Informational guide to paths beyond 4-year college

struct AlternativePathsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String?

    private let sections: [(icon: String, title: String, description: String, pros: [String], cons: [String], nextSteps: [String])] = [
        (
            icon: "building.columns",
            title: "Community College",
            description: "Start at a community college, save money, and transfer to a 4-year university. Many top universities have guaranteed transfer agreements.",
            pros: ["Significantly lower tuition", "Smaller class sizes", "Flexible scheduling", "Guaranteed transfer paths to state universities"],
            cons: ["May miss traditional campus experience", "Fewer extracurricular options", "Transfer credits may not all apply"],
            nextSteps: ["Research local community colleges", "Check transfer agreements with target universities", "Meet with a transfer advisor", "Apply for community college scholarships"]
        ),
        (
            icon: "wrench.and.screwdriver",
            title: "Trade Schools",
            description: "Learn a skilled trade with hands-on training. Many trades offer excellent salaries and job security with programs lasting 6 months to 2 years.",
            pros: ["High demand careers", "Earn while you learn (apprenticeships)", "Lower education costs", "Quick path to employment"],
            cons: ["Physically demanding work", "Less career flexibility", "May need ongoing certification"],
            nextSteps: ["Explore trades: electrician ($60K+), plumber ($56K+), HVAC ($50K+), welder ($44K+)", "Visit local trade schools", "Look into apprenticeship programs", "Talk to professionals in the field"]
        ),
        (
            icon: "shield.checkered",
            title: "Military Service",
            description: "Serve your country while gaining skills, discipline, and education benefits. The GI Bill covers full tuition at most universities after service.",
            pros: ["GI Bill covers college tuition", "Job training and leadership skills", "Healthcare and housing benefits", "ROTC scholarships available"],
            cons: ["Multi-year commitment required", "Risk of deployment", "Structured lifestyle"],
            nextSteps: ["Research branches: Army, Navy, Air Force, Marines, Coast Guard, Space Force", "Talk to a recruiter (no obligation)", "Explore ROTC programs at colleges", "Study for the ASVAB exam"]
        ),
        (
            icon: "globe.americas",
            title: "Gap Year",
            description: "Take a year between high school and college to explore, volunteer, work, or travel. Many colleges support and even encourage gap years.",
            pros: ["Personal growth and maturity", "Clarity about career goals", "Real-world experience", "Many colleges defer admission for gap years"],
            cons: ["Cost of travel or programs", "May lose academic momentum", "Less structure"],
            nextSteps: ["Research structured gap year programs (AmeriCorps, City Year, etc.)", "Apply for gap year scholarships", "Discuss deferral options with admitted colleges", "Create a gap year plan with goals"]
        ),
        (
            icon: "lightbulb.fill",
            title: "Entrepreneurship",
            description: "Start a business or freelance career. Many successful entrepreneurs started young. Resources and mentorship are more accessible than ever.",
            pros: ["Be your own boss", "Unlimited earning potential", "Learn real business skills", "Start with low overhead online"],
            cons: ["Financial risk", "No guaranteed income", "Steep learning curve", "May need capital"],
            nextSteps: ["Take free online courses (Khan Academy, Coursera)", "Join DECA or FBLA at school", "Start a small side project", "Find a mentor through SCORE or local business organizations"]
        )
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Empowering header
                    VStack(spacing: LadderSpacing.md) {
                        Image(systemName: "road.lanes")
                            .font(.system(size: 36))
                            .foregroundStyle(LadderColors.primary)

                        Text("Your Path, Your Choice")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Not everyone needs a 4-year degree to build an amazing career. Explore paths that might be the perfect fit for you.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.lg)

                    // Sections
                    ForEach(sections, id: \.title) { section in
                        pathCard(section)
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
                Text("Alternative Paths")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Path Card

    private func pathCard(_ section: (icon: String, title: String, description: String, pros: [String], cons: [String], nextSteps: [String])) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedSection = expandedSection == section.title ? nil : section.title
                }
            } label: {
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                            .fill(LadderColors.primaryContainer.opacity(0.25))
                            .frame(width: 44, height: 44)
                        Image(systemName: section.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(LadderColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.title)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(section.description)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .lineLimit(expandedSection == section.title ? nil : 2)
                    }

                    Spacer()

                    Image(systemName: expandedSection == section.title ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                }
                .padding(LadderSpacing.lg)
            }
            .buttonStyle(.plain)

            // Expanded content
            if expandedSection == section.title {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    // Pros
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Advantages")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)

                        ForEach(section.pros, id: \.self) { pro in
                            HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(LadderColors.primary)
                                    .padding(.top, 2)
                                Text(pro)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }
                    }

                    // Cons
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Considerations")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        ForEach(section.cons, id: \.self) { con in
                            HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 14))
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .padding(.top, 2)
                                Text(con)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }

                    // Next steps
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Next Steps")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.primary)

                        ForEach(Array(section.nextSteps.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: LadderSpacing.sm) {
                                Text("\(i + 1).")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.primary)
                                    .frame(width: 20)
                                Text(step)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                        }
                    }
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.bottom, LadderSpacing.lg)
            }
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}
