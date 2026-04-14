import SwiftUI

// MARK: - PDF Portfolio Builder
// Batch_10_Reports_Parent M1 — section toggles + live preview of a
// multi-section student portfolio. Export is mock-only.

struct PDFPortfolioView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // MARK: - Sections

    struct PortfolioSection: Identifiable, Hashable {
        let id: String
        let title: String
        let icon: String
        let summary: String
    }

    private let sections: [PortfolioSection] = [
        .init(id: "profile", title: "Profile", icon: "person.crop.square", summary: "Bio, GPA, test scores"),
        .init(id: "activities", title: "Activities", icon: "figure.2.arms.open", summary: "Clubs, leadership, sports"),
        .init(id: "awards", title: "Awards", icon: "rosette", summary: "Honors, scholarships, competitions"),
        .init(id: "essays", title: "Essays", icon: "doc.text", summary: "Personal statement & supplementals"),
        .init(id: "recommendations", title: "Recommendations", icon: "quote.bubble", summary: "Letter previews & endorsers"),
    ]

    @State private var enabled: Set<String> = ["profile", "activities", "awards", "essays"]
    @State private var accent: Color = LadderColors.primary

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("PDF Portfolio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                sectionsPanel
                livePreview
                LadderPrimaryButton("Export PDF", icon: "arrow.down.doc.fill") {}
            }
            .padding(LadderSpacing.lg)
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left panel: toggles
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    header
                    sectionsPanel
                    accentPicker
                    LadderPrimaryButton("Export PDF", icon: "arrow.down.doc.fill") {}
                }
                .padding(LadderSpacing.xl)
            }
            .frame(width: 360)
            .background(LadderColors.surfaceContainerLow)

            // Right panel: preview canvas
            ScrollView {
                livePreview
                    .padding(LadderSpacing.xxl)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("REPORTS & EXPORTS")
                .font(LadderTypography.labelMedium)
                .labelTracking()
                .foregroundStyle(LadderColors.primary)
            Text("Portfolio Builder")
                .font(LadderTypography.headlineLarge)
                .editorialTracking()
                .foregroundStyle(LadderColors.onSurface)
            Text("Toggle sections on the left — the preview updates in real time.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private var sectionsPanel: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                Text("Sections")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                ForEach(sections) { s in
                    Toggle(isOn: Binding(
                        get: { enabled.contains(s.id) },
                        set: { on in
                            if on { enabled.insert(s.id) } else { enabled.remove(s.id) }
                        }
                    )) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: s.icon)
                                .foregroundStyle(LadderColors.primary)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.title)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text(s.summary)
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    }
                    .tint(LadderColors.primary)
                }
            }
        }
    }

    private var accentPicker: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Accent")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                HStack(spacing: LadderSpacing.sm) {
                    ForEach([LadderColors.primary, LadderColors.accentLime, LadderColors.secondaryFixed, LadderColors.tertiary], id: \.self) { color in
                        Button { accent = color } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().stroke(accent == color ? LadderColors.onSurface : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Live Preview Canvas

    private var livePreview: some View {
        VStack(spacing: LadderSpacing.lg) {
            if enabled.contains("profile") { previewPage(title: "Profile", accent: accent) { profileBody } }
            if enabled.contains("activities") { previewPage(title: "Activities", accent: accent) { activitiesBody } }
            if enabled.contains("awards") { previewPage(title: "Awards & Honors", accent: accent) { awardsBody } }
            if enabled.contains("essays") { previewPage(title: "Essays", accent: accent) { essaysBody } }
            if enabled.contains("recommendations") { previewPage(title: "Recommendations", accent: accent) { recsBody } }

            if enabled.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "doc")
                            .font(.system(size: 36))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("Toggle sections on to build your portfolio")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(LadderSpacing.xxl)
                }
            }
        }
    }

    @ViewBuilder
    private func previewPage<Body: View>(title: String, accent: Color, @ViewBuilder body: () -> Body) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Rectangle().fill(accent).frame(width: 6, height: 28)
                Text(title)
                    .font(LadderTypography.headlineSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Text("Page")
                    .font(LadderTypography.labelSmall)
                    .labelTracking()
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            body()
        }
        .padding(LadderSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    private var profileBody: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Kathan Patel")
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)
            Text("Senior · Harrison High · GPA 4.38 (weighted) · SAT 1510")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("Aspiring CS major focused on accessible consumer software. Founder of the school's Mobile Dev Club and lead on two production iOS apps.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    private var activitiesBody: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ForEach([
                ("Mobile Dev Club", "Founder & President · 3 yrs"),
                ("Science Olympiad", "Captain · 4 yrs"),
                ("Volunteer Tutoring", "100+ hrs · 2 yrs")
            ], id: \.0) { item in
                HStack(alignment: .firstTextBaseline) {
                    Text(item.0)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text(item.1)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                Divider().background(LadderColors.outlineVariant)
            }
        }
    }

    private var awardsBody: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            ForEach([
                "National Merit Commended",
                "Congressional App Challenge — District Winner",
                "AP Scholar with Distinction"
            ], id: \.self) { award in
                HStack {
                    Image(systemName: "rosette").foregroundStyle(LadderColors.primary)
                    Text(award)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    private var essaysBody: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Personal Statement — excerpt")
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text("The first bug I ever shipped wasn't in code — it was in a paper airplane design I refused to let my little brother test…")
                .font(LadderTypography.bodyLargeItalic)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    private var recsBody: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            ForEach([
                ("Ms. Rivera", "AP Computer Science"),
                ("Mr. Okafor", "AP Literature"),
                ("Coach Diaz", "Science Olympiad")
            ], id: \.0) { item in
                HStack {
                    Image(systemName: "quote.bubble").foregroundStyle(LadderColors.primary)
                    VStack(alignment: .leading) {
                        Text(item.0).font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(item.1).font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
        }
    }
}
