import SwiftUI

// Admin home on brand gradient. §13 success-metrics banner, KPI tiles,
// admin-only quick actions. Session carries role + tenant + display name.

public struct AdminDashboardView: View {
    public let session: SignedInSession
    @State private var showingSuccessMetrics = false

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                hero
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        metricsBanner
                        kpiRow
                        quickActionsRow
                        sectionCards
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                AdminBottomNav()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSuccessMetrics) { SuccessMetricsPopupView() }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ADMIN DASHBOARD")
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.lime500)
            HStack(alignment: .center) {
                Text("Good morning, \(firstName) 👋")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Spacer()
                LadderLogoMark(size: 44, withShadow: true, style: .cream)
            }
            Text("\(session.tenantName) · K–8")
                .font(.ladderCaps(11))
                .tracking(1.2)
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(LadderBrand.cream100.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var firstName: String {
        session.displayName.split(separator: ".").first.map(String.init)?.capitalized ?? "Admin"
    }

    // MARK: - Mandatory metrics banner

    private var metricsBanner: some View {
        Button { showingSuccessMetrics = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(LadderBrand.statusAmber)
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Update your annual metrics").font(.ladderLabel(14)).foregroundStyle(LadderBrand.ink900)
                    Text("Last submitted 3+ months ago").font(.ladderBody(12)).foregroundStyle(LadderBrand.ink600)
                }
                Spacer()
                Image(systemName: "arrow.right").foregroundStyle(LadderBrand.ink900)
            }
            .padding(14)
            .background(LadderBrand.cream100)
            .overlay(HStack { Rectangle().fill(LadderBrand.statusAmber).frame(width: 4); Spacer() })
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - KPI row

    private var kpiRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            kpi("STUDENTS", value: "428", delta: "+12 this month")
            kpi("COUNSELORS", value: "3", delta: "full staff")
            kpi("TEACHERS", value: "38", delta: "4 open roles", deltaAmber: true)
            kpi("ACTIVE WINDOWS", value: "1", delta: "closes Fri")
        }
    }

    private func kpi(_ caps: String, value: String, delta: String, deltaAmber: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caps).font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.6))
            Text(value).font(.ladderDisplay(28, relativeTo: .title)).foregroundStyle(LadderBrand.cream100)
            Text(delta).font(.ladderCaps(10)).tracking(0.8).foregroundStyle(deltaAmber ? LadderBrand.statusAmber : LadderBrand.lime500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Quick actions

    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                quickAction("Upload teacher schedules", icon: "calendar.badge.plus")
                quickAction("Invite counselor", icon: "envelope")
                quickAction("Open scheduling window", icon: "clock")
                quickAction("Teacher reviews", icon: "text.badge.checkmark")
            }
            .padding(.vertical, 4)
        }
    }

    private func quickAction(_ label: String, icon: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 22)).foregroundStyle(LadderBrand.forest900)
            Text(label).font(.ladderLabel(12)).foregroundStyle(LadderBrand.forest900).multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(width: 120, height: 96)
        .padding(8)
        .background(LadderBrand.lime500.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Section cards

    private var sectionCards: some View {
        VStack(spacing: 12) {
            sectionCard("Teacher data", sub: "38 teachers · 2 pending invites", icon: "person.2.fill")
            sectionCard("Classes", sub: "64 classes for 2026–27", icon: "tablecells.fill")
            sectionCard("Scheduling", sub: "Window opens Fri at 8am", icon: "calendar")
        }
    }

    private func sectionCard(_ title: String, sub: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(LadderBrand.lime500)
                .frame(width: 48, height: 48)
                .background(LadderBrand.cream100.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.ladderDisplay(18, relativeTo: .title3)).foregroundStyle(LadderBrand.cream100)
                Text(sub).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AdminBottomNav: View {
    var body: some View {
        HStack(spacing: 0) {
            tab("Home", icon: "house.fill", active: true)
            tab("Teachers", icon: "person.2", active: false)
            tab("Classes", icon: "graduationcap", active: false)
            tab("Invites", icon: "envelope", active: false)
            tab("Profile", icon: "person", active: false)
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(LadderBrand.forest900)
    }

    private func tab(_ label: String, icon: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 18))
            Text(label).font(.ladderCaps(10)).tracking(0.6)
        }
        .foregroundStyle(active ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.55))
        .frame(maxWidth: .infinity)
    }
}
