import SwiftUI

// §14.2 — founder dashboard.
// Visual source: docs/design/stitch-deliverables/batch-11-full-v2-spec/founder_overview/

public struct FounderDashboardView: View {
    @State private var schoolCount = 4
    @State private var familyCount = 22
    @State private var aiTokensMonth = "2.4M"
    @State private var aiCostMonth = "$42.80"
    @State private var activeSessions = 18
    @State private var newLeads = 12

    public init() {}

    public var body: some View {
        ZStack {
            LadderBrand.paper.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        titleBlock
                        schoolsCard
                        soloPeopleCard
                        systemHealthSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                bottomTabBar
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(LadderBrand.ink900)
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "person.fill").font(.system(size: 14)).foregroundStyle(LadderBrand.cream100))
                Text("Academic Atelier")
                    .font(.ladderDisplay(18, relativeTo: .headline))
                    .foregroundStyle(LadderBrand.forest700)
            }
            Spacer()
            Image(systemName: "graduationcap.fill")
                .foregroundStyle(LadderBrand.forest700)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(LadderBrand.paper)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FOUNDER · LADDER")
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.ink600)
            Text("Overview")
                .font(.ladderDisplay(40, relativeTo: .largeTitle))
                .tracking(-0.6)
                .foregroundStyle(LadderBrand.ink900)
            Text("System vitals and tenant aggregates across the production environment.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.ink600)
        }
    }

    // MARK: - Section cards

    private var schoolsCard: some View {
        NavigationLink { SchoolsGridView() } label: {
            bigCard(title: "Schools", count: "\(schoolCount)", caption: "TENANTS", glyph: "building.columns")
        }
        .buttonStyle(.plain)
    }

    private var soloPeopleCard: some View {
        NavigationLink { SoloPeopleView() } label: {
            bigCard(title: "Solo People", count: "\(familyCount)", caption: "FAMILIES", glyph: "person.fill")
        }
        .buttonStyle(.plain)
    }

    private func bigCard(title: String, count: String, caption: String, glyph: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.ladderDisplay(22, relativeTo: .title2))
                    .foregroundStyle(LadderBrand.ink900)
                Spacer()
                Circle()
                    .fill(LadderBrand.lime500.opacity(0.25))
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: glyph).foregroundStyle(LadderBrand.forest700))
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(count)
                    .font(.ladderDisplay(56, relativeTo: .largeTitle))
                    .foregroundStyle(LadderBrand.ink900)
                Text(caption)
                    .font(.ladderCaps(11))
                    .tracking(1.4)
                    .foregroundStyle(LadderBrand.ink600)
            }
        }
        .padding(20)
        .background(LadderBrand.lime500.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - System health

    private var systemHealthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle().fill(LadderBrand.forest700).frame(width: 3, height: 18)
                Text("System Health")
                    .font(.ladderDisplay(20, relativeTo: .title3))
                    .foregroundStyle(LadderBrand.ink900)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                kpiTile(caps: "AI TOKENS", value: aiTokensMonth, trailing: AnyView(
                    Rectangle().fill(LadderBrand.forest700).frame(height: 3).cornerRadius(2)
                ))
                kpiTile(caps: "EST. COST", value: aiCostMonth, trailing: AnyView(
                    Text("-2% MoM").font(.ladderCaps(10)).foregroundStyle(LadderBrand.statusRed)
                ))
                kpiTile(caps: "ACTIVE SESH", value: "\(activeSessions)", trailing: AnyView(
                    HStack(spacing: 4) {
                        Circle().fill(LadderBrand.lime500).frame(width: 6, height: 6)
                        Text("Live").font(.ladderCaps(10)).foregroundStyle(LadderBrand.forest700)
                    }
                ))
                kpiTile(caps: "NEW LEADS", value: "\(newLeads)", trailing: AnyView(
                    Text("+ Last 24h").font(.ladderCaps(10)).foregroundStyle(LadderBrand.forest700)
                ))
            }
        }
    }

    private func kpiTile(caps: String, value: String, trailing: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(caps).font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.ink600)
            Text(value)
                .font(.ladderDisplay(26, relativeTo: .title2))
                .foregroundStyle(LadderBrand.ink900)
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LadderBrand.lime500.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Bottom tab bar (founder variant)

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "square.grid.2x2.fill", label: "Dashboard", active: true)
            tabItem(icon: "building.columns.fill", label: "Tenants", active: false)
            tabItem(icon: "chart.bar.xaxis", label: "Metrics", active: false)
            tabItem(icon: "terminal.fill", label: "System", active: false)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(LadderBrand.forest900)
    }

    private func tabItem(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 18))
            Text(label).font(.ladderCaps(10)).tracking(0.8)
        }
        .foregroundStyle(active ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.5))
        .frame(maxWidth: .infinity)
    }
}
