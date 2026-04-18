import SwiftUI

// §14 — founder backdoor overview.
// Brand gradient (no white). Grid of school cards — tap drills into detail.
// Four-tab dark bottom bar for navigating the backdoor surfaces.

public struct FounderDashboardView: View {
    @State private var selectedTab: FounderTab = .overview
    public let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                BrandGradient.list
                BrandGradient.heroGlow

                VStack(spacing: 0) {
                    header
                    ScrollView {
                        switch selectedTab {
                        case .overview: overviewContent
                        case .schools:  schoolsContent
                        case .solo:     soloContent
                        case .system:   systemContent
                        }
                    }
                    tabBar
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Circle().fill(LadderBrand.cream100.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: "person.fill").foregroundStyle(LadderBrand.cream100))
            VStack(alignment: .leading, spacing: 2) {
                Text("FOUNDER · LADDER").font(.ladderCaps(10)).tracking(1.4).foregroundStyle(LadderBrand.cream100.opacity(0.7))
                Text("Kathan · Jet").font(.ladderLabel(14)).foregroundStyle(LadderBrand.cream100)
            }
            Spacer()
            LogoutButton(action: onLogout)
            LadderLogoMark(size: 36, withShadow: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    // MARK: - OVERVIEW

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleBlock

            // Two big cards
            HStack(spacing: 12) {
                summaryCard(title: "Schools", count: "4", caption: "TENANTS", glyph: "building.columns") {
                    selectedTab = .schools
                }
                summaryCard(title: "Families", count: "22", caption: "SOLO", glyph: "person.2.fill") {
                    selectedTab = .solo
                }
            }

            // System health
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Rectangle().fill(LadderBrand.lime500).frame(width: 3, height: 16)
                    Text("System Health").font(.ladderDisplay(18, relativeTo: .title3)).foregroundStyle(LadderBrand.cream100)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    kpiTile(caps: "AI TOKENS",  value: "2.4M",   trailing: "last 30d")
                    kpiTile(caps: "EST. COST",  value: "$42.80", trailing: "-2% MoM", amber: true)
                    kpiTile(caps: "ACTIVE SESH", value: "18",     trailing: "live", lime: true)
                    kpiTile(caps: "NEW LEADS",  value: "12",     trailing: "+ last 24h", lime: true)
                }
            }

            // Schools grid preview on overview
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Schools preview").font(.ladderDisplay(18, relativeTo: .title3)).foregroundStyle(LadderBrand.cream100)
                    Spacer()
                    Button("See all →") { selectedTab = .schools }
                        .font(.ladderLabel(12))
                        .foregroundStyle(LadderBrand.lime500)
                }
                schoolsPreviewGrid
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 24)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Overview")
                .font(.ladderDisplay(40, relativeTo: .largeTitle))
                .tracking(-0.6)
                .foregroundStyle(LadderBrand.cream100)
            Text("System vitals + per-tenant aggregates. No student data lives here.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func summaryCard(title: String, count: String, caption: String, glyph: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.ladderDisplay(18, relativeTo: .title3))
                        .foregroundStyle(LadderBrand.cream100)
                    Spacer()
                    Circle()
                        .fill(LadderBrand.lime500.opacity(0.25))
                        .frame(width: 32, height: 32)
                        .overlay(Image(systemName: glyph).foregroundStyle(LadderBrand.lime500))
                }
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(count)
                        .font(.ladderDisplay(40, relativeTo: .largeTitle))
                        .foregroundStyle(LadderBrand.cream100)
                    Text(caption)
                        .font(.ladderCaps(10))
                        .tracking(1.2)
                        .foregroundStyle(LadderBrand.cream100.opacity(0.6))
                }
                Text("Tap to open →")
                    .font(.ladderCaps(10))
                    .tracking(1.1)
                    .foregroundStyle(LadderBrand.lime500)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(LadderBrand.cream100.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(LadderBrand.cream100.opacity(0.15), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func kpiTile(caps: String, value: String, trailing: String, amber: Bool = false, lime: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caps).font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.6))
            Text(value)
                .font(.ladderDisplay(24, relativeTo: .title2))
                .foregroundStyle(LadderBrand.cream100)
            HStack(spacing: 4) {
                if lime {
                    Circle().fill(LadderBrand.lime500).frame(width: 6, height: 6)
                }
                Text(trailing)
                    .font(.ladderCaps(9))
                    .tracking(0.8)
                    .foregroundStyle(amber ? LadderBrand.statusAmber : (lime ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.65)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var schoolsPreviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(FounderSchool.pilotData.prefix(4)) { school in
                NavigationLink { FounderSchoolDetailView(school: school) } label: {
                    SchoolPreviewCard(school: school)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - SCHOOLS TAB

    private var schoolsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Schools")
                .font(.ladderDisplay(36, relativeTo: .largeTitle))
                .foregroundStyle(LadderBrand.cream100)
            Text("Each school is its own sandbox. Tap a card to drill into aggregates — we never render student data here.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))

            NavigationLink { AddSchoolFormView() } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill").foregroundStyle(LadderBrand.ink900)
                    Text("Add a new school")
                        .font(.ladderLabel(15))
                        .foregroundStyle(LadderBrand.ink900)
                    Spacer()
                    Image(systemName: "arrow.right").foregroundStyle(LadderBrand.ink900)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
                .shadow(color: LadderBrand.lime500.opacity(0.4), radius: 12, y: 4)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(FounderSchool.pilotData) { school in
                    NavigationLink { FounderSchoolDetailView(school: school) } label: {
                        SchoolPreviewCard(school: school)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - SOLO TAB

    private var soloContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Solo people")
                .font(.ladderDisplay(36, relativeTo: .largeTitle))
                .foregroundStyle(LadderBrand.cream100)
            Text("B2C families. Names are hashed — you see structure, not identity.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))

            VStack(spacing: 8) {
                ForEach(["A7C3", "B9F2", "D4E1", "E8K5", "H2M7"], id: \.self) { hash in
                    HStack {
                        Text("Family #\(hash)").font(.ladderLabel(14).monospaced()).foregroundStyle(LadderBrand.lime500)
                        Spacer()
                        Text("1p · 2k").font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
                        Text("Paid").font(.ladderCaps(10)).tracking(0.8).foregroundStyle(LadderBrand.lime500).padding(.leading, 8)
                    }
                    .padding(12)
                    .background(LadderBrand.cream100.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - SYSTEM TAB

    private var systemContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System")
                .font(.ladderDisplay(36, relativeTo: .largeTitle))
                .foregroundStyle(LadderBrand.cream100)
            Text("Feature flags, Varun, impersonation grants. Configuration only — no data.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))

            NavigationLink { FeatureFlagsRootView() } label: {
                systemLink("Feature flags", sub: "Grouped per-tenant toggles · Varun-gated", icon: "flag.fill")
            }.buttonStyle(.plain)

            NavigationLink { VarunPanelView() } label: {
                systemLink("Varun rule explainer", sub: "10 dependency rules · trace chain", icon: "link.circle.fill")
            }.buttonStyle(.plain)

            NavigationLink { ImpersonationGrantsView() } label: {
                systemLink("Impersonation grants", sub: "0 active · full history", icon: "person.crop.circle.badge.exclamationmark.fill")
            }.buttonStyle(.plain)

            NavigationLink { AuditTimelineView() } label: {
                systemLink("Audit timeline", sub: "Append-only, metadata only", icon: "list.bullet.rectangle")
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private func systemLink(_ title: String, sub: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(LadderBrand.lime500)
                .frame(width: 44, height: 44)
                .background(LadderBrand.cream100.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.ladderLabel(15)).foregroundStyle(LadderBrand.cream100)
                Text(sub).font(.ladderBody(12)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Placeholder destinations (gradient shells for System tab links)

    public struct ImpersonationGrantsView: View {
        @Environment(\.dismiss) private var dismiss
        public init() {}
        public var body: some View {
            ZStack {
                BrandGradient.list; BrandGradient.heroGlow
                VStack(spacing: 16) {
                    Text("Impersonation grants").font(.ladderDisplay(28, relativeTo: .title)).foregroundStyle(LadderBrand.cream100)
                    Text("0 active · 0 expired today").font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
                    Text("Admin-initiated, time-limited (15 min max). Every grant is audited.")
                        .font(.ladderBody(12)).foregroundStyle(LadderBrand.cream100.opacity(0.55))
                        .multilineTextAlignment(.center).padding(.horizontal, 32)
                }.padding(.top, 40)
            }
            .navigationTitle("").navigationBarHidden(false)
        }
    }

    public struct AuditTimelineView: View {
        public init() {}
        public var body: some View {
            ZStack {
                BrandGradient.list; BrandGradient.heroGlow
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Audit timeline").font(.ladderDisplay(28, relativeTo: .title)).foregroundStyle(LadderBrand.cream100)
                        Text("Append-only · metadata only · founder-visible subset")
                            .font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.lime500)
                        Divider().background(LadderBrand.cream100.opacity(0.2))
                        auditRow("LWRPA · counselor issued 12 invites", "2h ago")
                        auditRow("Beta · admin opened scheduling window", "6h ago")
                        auditRow("St Jude · Varun rejected feature.scheduling toggle", "1d ago")
                        auditRow("Evergreen · founder read aggregates", "2d ago")
                    }.padding(20)
                }
            }
            .navigationTitle("").navigationBarHidden(false)
        }
        private func auditRow(_ action: String, _ when: String) -> some View {
            HStack {
                Circle().fill(LadderBrand.lime500.opacity(0.6)).frame(width: 6, height: 6)
                Text(action).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100)
                Spacer()
                Text(when).font(.ladderBody(12)).foregroundStyle(LadderBrand.cream100.opacity(0.55))
            }
            .padding(12)
            .background(LadderBrand.cream100.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "square.grid.2x2.fill",  label: "Overview", tab: .overview)
            tabItem(icon: "building.columns.fill", label: "Schools",  tab: .schools)
            tabItem(icon: "person.3.fill",          label: "Solo",     tab: .solo)
            tabItem(icon: "terminal.fill",          label: "System",   tab: .system)
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(LadderBrand.forest900)
    }

    private func tabItem(icon: String, label: String, tab: FounderTab) -> some View {
        Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 18))
                Text(label).font(.ladderCaps(10)).tracking(0.6)
            }
            .foregroundStyle(selectedTab == tab ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.55))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

public enum FounderTab { case overview, schools, solo, system }

// MARK: - School model + sample data

public struct FounderSchool: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let displayName: String
    public let slug: String
    public let primaryColorHex: String
    public let studentCount: Int
    public let billingBalance: Int  // $ whole dollars
    public let aiTokensMonth: String
    public let aiCostMonth: String
    public let successRate: Double
    public let flagsOn: Int
    public let flagsOff: Int

    public static let pilotData: [FounderSchool] = [
        FounderSchool(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            displayName: "Lakewood Ranch Prep",
            slug: "LWRPA",
            primaryColorHex: "#A8D234",
            studentCount: 428,
            billingBalance: 12_400,
            aiTokensMonth: "640K",
            aiCostMonth: "$18.40",
            successRate: 0.94,
            flagsOn: 7,
            flagsOff: 2
        ),
        FounderSchool(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            displayName: "Beta Test Academy",
            slug: "BETA",
            primaryColorHex: "#6B8A67",
            studentCount: 186,
            billingBalance: 3_200,
            aiTokensMonth: "220K",
            aiCostMonth: "$7.10",
            successRate: 0.88,
            flagsOn: 6,
            flagsOff: 3
        ),
        FounderSchool(
            id: UUID(),
            displayName: "St. Jude Academy",
            slug: "STJ",
            primaryColorHex: "#C94A3F",
            studentCount: 1_240,
            billingBalance: 45_200,
            aiTokensMonth: "1.1M",
            aiCostMonth: "$32.80",
            successRate: 0.92,
            flagsOn: 8,
            flagsOff: 1
        ),
        FounderSchool(
            id: UUID(),
            displayName: "Evergreen Charter",
            slug: "EVG",
            primaryColorHex: "#D9A54A",
            studentCount: 312,
            billingBalance: 8_900,
            aiTokensMonth: "410K",
            aiCostMonth: "$11.20",
            successRate: 0.90,
            flagsOn: 7,
            flagsOff: 2
        ),
    ]
}

// MARK: - School preview card

public struct SchoolPreviewCard: View {
    public let school: FounderSchool

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: school.primaryColorHex) ?? LadderBrand.lime500)
                    .frame(width: 12, height: 12)
                Text(school.slug)
                    .font(.ladderCaps(10))
                    .tracking(1.1)
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                Spacer()
            }
            Text(school.displayName)
                .font(.ladderDisplay(16, relativeTo: .headline))
                .foregroundStyle(LadderBrand.cream100)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.0f%%", school.successRate * 100))
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.lime500)
                Text("SUCCESS").font(.ladderCaps(9)).tracking(1.0).foregroundStyle(LadderBrand.cream100.opacity(0.6))
            }
            Divider().background(LadderBrand.cream100.opacity(0.15))
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STUDENTS").font(.ladderCaps(9)).tracking(1.0).foregroundStyle(LadderBrand.cream100.opacity(0.6))
                    Text("\(school.studentCount)").font(.ladderLabel(13)).foregroundStyle(LadderBrand.cream100)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("AI COST").font(.ladderCaps(9)).tracking(1.0).foregroundStyle(LadderBrand.cream100.opacity(0.6))
                    Text(school.aiCostMonth).font(.ladderLabel(13)).foregroundStyle(LadderBrand.cream100)
                }
            }
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(LadderBrand.cream100.opacity(0.12), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Detail view (drill-in from grid)

public struct FounderSchoolDetailView: View {
    public let school: FounderSchool
    @Environment(\.dismiss) private var dismiss

    public init(school: FounderSchool) { self.school = school }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            ScrollView {
                VStack(spacing: 16) {
                    hero
                    metricsGrid
                    contractsCard
                    flagsLinkCard
                    auditCard
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LadderBrand.cream100)
                    .frame(width: 40, height: 40)
                    .background(LadderBrand.cream100.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Circle()
                .fill((Color(hex: school.primaryColorHex) ?? LadderBrand.lime500).opacity(0.25))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(hex: school.primaryColorHex) ?? LadderBrand.lime500)
                )
            Text(school.displayName)
                .font(.ladderDisplay(26, relativeTo: .title))
                .foregroundStyle(LadderBrand.cream100)
                .multilineTextAlignment(.center)
            Text(school.slug)
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
        }
        .padding(.top, 48)
        .padding(.bottom, 8)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            metric(caps: "STUDENTS", value: "\(school.studentCount)")
            metric(caps: "BALANCE", value: "$\(school.billingBalance)")
            metric(caps: "AI TOKENS (30D)", value: school.aiTokensMonth)
            metric(caps: "AI COST (30D)", value: school.aiCostMonth)
            metric(caps: "SUCCESS RATE", value: String(format: "%.1f%%", school.successRate * 100), lime: true)
            metric(caps: "FLAGS", value: "\(school.flagsOn) on / \(school.flagsOff) off")
        }
    }

    private func metric(caps: String, value: String, lime: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caps).font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.6))
            Text(value)
                .font(.ladderDisplay(22, relativeTo: .title2))
                .foregroundStyle(lime ? LadderBrand.lime500 : LadderBrand.cream100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var contractsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONTRACTS").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            VStack(spacing: 8) {
                contractRow("Data Processing Agreement", signed: true)
                contractRow("Liability acknowledgement",   signed: true)
                contractRow("AI Features Addendum",        signed: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func contractRow(_ name: String, signed: Bool) -> some View {
        HStack {
            Image(systemName: signed ? "checkmark.circle.fill" : "circle").foregroundStyle(signed ? LadderBrand.lime500 : LadderBrand.statusAmber)
            Text(name).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100)
            Spacer()
            Image(systemName: "arrow.up.right.square").foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
    }

    private var flagsLinkCard: some View {
        HStack {
            Text("Feature flags")
                .font(.ladderLabel(15))
                .foregroundStyle(LadderBrand.cream100)
            Spacer()
            Text("\(school.flagsOn) on / \(school.flagsOff) off")
                .font(.ladderCaps(11))
                .tracking(1.1)
                .foregroundStyle(LadderBrand.lime500)
            Image(systemName: "chevron.right").foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var auditCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AUDIT TIMELINE (METADATA ONLY)").font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            auditRow("Admin opened a scheduling window", "2h ago")
            auditRow("Counselor issued 12 invites", "6h ago")
            auditRow("Varun rejected a flag change", "1d ago")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func auditRow(_ action: String, _ when: String) -> some View {
        HStack {
            Circle().fill(LadderBrand.lime500.opacity(0.6)).frame(width: 6, height: 6)
            Text(action).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100)
            Spacer()
            Text(when).font(.ladderBody(12)).foregroundStyle(LadderBrand.cream100.opacity(0.55))
        }
    }

    private var footerNote: some View {
        Text("Founders never see student data. This surface enforces §14.4 at the API, DB, and UI layers.")
            .font(.ladderBody(11))
            .foregroundStyle(LadderBrand.cream100.opacity(0.55))
            .multilineTextAlignment(.center)
            .padding(.top, 12)
    }
}
