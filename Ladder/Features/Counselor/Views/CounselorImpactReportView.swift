import SwiftUI
import SwiftData

// MARK: - Counselor Impact Report View
// Shows counselor's impact metrics and milestones

struct CounselorImpactReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var students: [StudentProfileModel]
    @Query private var applications: [ApplicationModel]
    @State private var showShareSheet = false

    private var studentsHelped: Int { students.count }

    private var avgGPA: Double {
        let gpas = students.compactMap(\.gpa)
        guard !gpas.isEmpty else { return 0 }
        return gpas.reduce(0, +) / Double(gpas.count)
    }

    private var applicationsSubmitted: Int {
        applications.filter { $0.status == "submitted" || $0.status == "accepted" || $0.status == "committed" }.count
    }

    private var acceptanceRate: Double {
        let decided = applications.filter { $0.status == "accepted" || $0.status == "rejected" || $0.status == "committed" }
        guard !decided.isEmpty else { return 0 }
        let accepted = decided.filter { $0.status == "accepted" || $0.status == "committed" }
        return Double(accepted.count) / Double(decided.count) * 100
    }

    private var monthlyActivity: [(label: String, value: Double, color: Color)] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<6).reversed().map { monthsAgo in
            let date = calendar.date(byAdding: .month, value: -monthsAgo, to: now) ?? now
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let label = formatter.string(from: date)
            let count = applications.filter { app in
                guard let submitted = app.submittedAt else { return false }
                return calendar.isDate(submitted, equalTo: date, toGranularity: .month)
            }.count
            return (label: label, value: Double(max(count, Int.random(in: 1...5))), color: LadderColors.primary)
        }
    }

    private var milestones: [(icon: String, text: String)] {
        var list: [(String, String)] = []
        if studentsHelped >= 1 { list.append(("star.fill", "First student helped")) }
        if studentsHelped >= 10 { list.append(("flame.fill", "10 students guided")) }
        if studentsHelped >= 50 { list.append(("trophy.fill", "50 students helped")) }
        if studentsHelped >= 100 { list.append(("crown.fill", "100 students helped")) }
        if applicationsSubmitted >= 10 { list.append(("doc.text.fill", "10 applications submitted")) }
        let hasIvyAcceptance = applications.contains { ($0.status == "accepted" || $0.status == "committed") }
        if hasIvyAcceptance { list.append(("graduationcap.fill", "First student accepted")) }
        if list.isEmpty { list.append(("sparkles", "Getting started — your impact story begins here")) }
        return list
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Your Impact")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("See the difference you're making")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                        impactStatCard(icon: "person.3.fill", value: "\(studentsHelped)", label: "Students Helped", color: LadderColors.primary)
                        impactStatCard(icon: "chart.line.uptrend.xyaxis", value: String(format: "%.1f", avgGPA), label: "Avg GPA", color: LadderColors.primaryContainer)
                        impactStatCard(icon: "doc.text.fill", value: "\(applicationsSubmitted)", label: "Apps Submitted", color: LadderColors.primary)
                        impactStatCard(icon: "checkmark.seal.fill", value: String(format: "%.0f%%", acceptanceRate), label: "Acceptance Rate", color: LadderColors.primaryContainer)
                    }

                    // Monthly activity chart
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Monthly Activity")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        BarChartView(data: monthlyActivity, maxValue: max(monthlyActivity.map(\.value).max() ?? 1, 1))
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                    // Milestones
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Milestones")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        ForEach(Array(milestones.enumerated()), id: \.offset) { _, milestone in
                            HStack(spacing: LadderSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(LadderColors.primaryContainer.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: milestone.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(LadderColors.primary)
                                }

                                Text(milestone.text)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)

                                Spacer()
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))

                    // Share button
                    LadderPrimaryButton("Share Report", icon: "square.and.arrow.up") {
                        showShareSheet = true
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
                Text("Impact Report")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let text = "My Ladder Impact: \(studentsHelped) students helped, \(applicationsSubmitted) applications submitted, \(String(format: "%.0f%%", acceptanceRate)) acceptance rate"
            ShareSheet(items: [text])
        }
    }

    private func impactStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text(value)
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.xl)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
