import SwiftUI

// MARK: - Application Detail View

struct ApplicationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var sizeClass
    let applicationId: String

    private var college: CollegeListItem? {
        CollegeListItem.sampleColleges.first { $0.id == applicationId }
    }

    @State private var checklistItems: [AppChecklistItem] = AppChecklistItem.sampleItems

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
            ToolbarItem(placement: .principal) {
                Text(college?.name ?? "Application")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    statusCard
                    progressSection
                    checklistSection
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            GeometryReader { geo in
                HStack(alignment: .top, spacing: LadderSpacing.lg) {
                    // Left column (~60%): application info, checklist, essays, documents
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.lg) {
                            statusCard
                            progressSection
                            checklistSection
                            attachedDocumentsSection
                            essayStatusSection
                        }
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                    .frame(width: geo.size.width * 0.6)

                    // Right column (~40%): timeline, decision status, AI insights
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: LadderSpacing.lg) {
                            timelineCard
                            decisionStatusCard
                            aiInsightsCard
                        }
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, LadderSpacing.xl)
                .padding(.top, LadderSpacing.lg)
            }
        }
    }

    // MARK: - iPad Supporting Cards

    private var attachedDocumentsSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("ATTACHED DOCUMENTS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                ForEach(["Transcript.pdf", "Resume.pdf", "Personal_Statement.docx"], id: \.self) { doc in
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.primary)
                            .frame(width: 36, height: 36)
                            .background(LadderColors.primaryContainer.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                        Text(doc)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Spacer()

                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(LadderSpacing.sm)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                }
            }
        }
    }

    private var essayStatusSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("ESSAY STATUS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                ForEach([("Personal Statement", 0.9, LadderColors.accentLime), ("Why This School", 0.4, LadderColors.tertiary), ("Extracurricular", 0.0, LadderColors.outlineVariant)], id: \.0) { title, prog, color in
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        HStack {
                            Text(title)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                            Text("\(Int(prog * 100))%")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(color)
                        }
                        LinearProgressBar(progress: prog)
                    }
                    .padding(LadderSpacing.sm)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                }
            }
        }
    }

    private var timelineCard: some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("TIMELINE")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                ForEach([("Application Open", "Aug 1", true), ("Transcript Sent", "Sep 12", true), ("Essays Due", "Oct 20", false), ("Deadline", "Nov 1", false)], id: \.0) { label, date, done in
                    HStack(spacing: LadderSpacing.md) {
                        Circle()
                            .fill(done ? LadderColors.accentLime : LadderColors.outlineVariant)
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(label)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(date)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var decisionStatusCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("DECISION STATUS")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(LadderColors.tertiary)
                    Text("Awaiting Decision")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }

                Text("Expected by March 15")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    private var aiInsightsCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(LadderColors.primary)
                    Text("AI INSIGHTS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()
                }

                Text("Based on your profile, your chances look strong. Focus on polishing your supplemental essay and submitting recommendation letters early.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text(college?.name ?? "College")
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        Text(college?.location ?? "")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    if let match = college?.matchPercent {
                        CircularProgressView(
                            progress: Double(match) / 100.0,
                            label: "\(match)%",
                            sublabel: "Match",
                            size: 56
                        )
                    }
                }

                Divider()

                HStack(spacing: LadderSpacing.lg) {
                    statusItem("Status", value: "Planning", color: LadderColors.primary)
                    statusItem("Deadline", value: "Nov 1", color: LadderColors.error)
                    statusItem("Type", value: "Early Action", color: LadderColors.onSurfaceVariant)
                }
            }
        }
    }

    private func statusItem(_ label: String, value: String, color: Color) -> some View {
        VStack(spacing: LadderSpacing.xxs) {
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Progress

    private var progressSection: some View {
        let completed = checklistItems.filter(\.isCompleted).count
        let total = checklistItems.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Text("Application Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Spacer()

                    Text("\(completed)/\(total)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                LinearProgressBar(progress: progress)
            }
        }
    }

    // MARK: - Checklist

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("APPLICATION CHECKLIST")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, item in
                checklistRow(item, index: index)
            }
        }
    }

    private func checklistRow(_ item: AppChecklistItem, index: Int) -> some View {
        Button {
            withAnimation {
                checklistItems[index].isCompleted.toggle()
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(item.isCompleted ? LadderColors.accentLime : LadderColors.outline)

                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.primary)
                    .frame(width: 32, height: 32)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(item.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(item.isCompleted ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
                        .strikethrough(item.isCompleted)

                    Text(item.category)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .opacity(item.isCompleted ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Checklist Item

struct AppChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let icon: String
    var isCompleted: Bool

    static var sampleItems: [AppChecklistItem] {
        [
            AppChecklistItem(title: "Create Common App Account", category: "Setup", icon: "person.badge.plus", isCompleted: true),
            AppChecklistItem(title: "Request Official Transcript", category: "Transcript", icon: "doc.text", isCompleted: true),
            AppChecklistItem(title: "Submit SAT Scores", category: "Testing", icon: "pencil.line", isCompleted: false),
            AppChecklistItem(title: "Write Personal Statement", category: "Essay", icon: "text.alignleft", isCompleted: false),
            AppChecklistItem(title: "Write Supplemental Essays", category: "Essay", icon: "doc.append", isCompleted: false),
            AppChecklistItem(title: "Request 2 Recommendation Letters", category: "Recommendations", icon: "envelope", isCompleted: false),
            AppChecklistItem(title: "Complete Activities Section", category: "Activities", icon: "list.bullet", isCompleted: false),
            AppChecklistItem(title: "Review and Submit Application", category: "Submission", icon: "paperplane", isCompleted: false),
            AppChecklistItem(title: "Pay Application Fee", category: "Financial", icon: "creditcard", isCompleted: false),
        ]
    }
}

#Preview {
    NavigationStack {
        ApplicationDetailView(applicationId: "uf")
            .environment(AppCoordinator())
    }
}
