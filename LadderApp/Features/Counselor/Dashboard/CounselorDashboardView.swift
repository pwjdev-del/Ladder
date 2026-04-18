import SwiftUI

public struct CounselorDashboardView: View {
    public let session: SignedInSession

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                hero
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        queueCard
                        kpiRow
                        quickActions
                        recentActivity
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                CounselorBottomNav()
            }
        }
        .navigationBarHidden(true)
    }

    private var firstName: String {
        session.displayName.split(separator: ".").first.map(String.init)?.capitalized ?? "Counselor"
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COUNSELOR DASHBOARD")
                .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.lime500)
            HStack {
                Text("Good morning, \(firstName) 👋")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Spacer()
                Image("LadderLogo")
                    .resizable().scaledToFill().frame(width: 44, height: 44).clipShape(Circle())
            }
            Text("\(session.tenantName) · K–8")
                .font(.ladderCaps(11)).tracking(1.2)
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(LadderBrand.cream100.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var queueCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("12 schedules waiting").font(.ladderDisplay(22, relativeTo: .title2)).foregroundStyle(LadderBrand.ink900)
                Text("3 with conflicts · oldest 2 hrs").font(.ladderBody(13)).foregroundStyle(LadderBrand.ink600)
            }
            Spacer()
            Circle().fill(LadderBrand.lime500).frame(width: 48, height: 48)
                .overlay(Image(systemName: "arrow.right").foregroundStyle(LadderBrand.ink900))
        }
        .padding(16)
        .background(LadderBrand.cream100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var kpiRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            smallKPI("STUDENTS", "428")
            smallKPI("QUIZ DONE", "82%")
            smallKPI("APPROVED", "48")
        }
    }

    private func smallKPI(_ caps: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(caps).font(.ladderCaps(10)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.6))
            Text(value).font(.ladderDisplay(22, relativeTo: .title2)).foregroundStyle(LadderBrand.cream100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                action("Invite students", "envelope.open")
                action("Upload class list", "tablecells.badge.ellipsis")
                action("Open window", "clock.badge.checkmark")
                action("Messages", "bubble.left.and.bubble.right")
            }
        }
    }

    private func action(_ label: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 22)).foregroundStyle(LadderBrand.forest900)
            Text(label).font(.ladderLabel(12)).foregroundStyle(LadderBrand.forest900).multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(width: 120, height: 96).padding(8)
        .background(LadderBrand.lime500.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT ACTIVITY").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            VStack(spacing: 8) {
                activityRow("Alice submitted her schedule", "2h ago")
                activityRow("Bob redeemed an invite", "3h ago")
                activityRow("Carol completed the career quiz", "yesterday")
            }
        }
    }

    private func activityRow(_ text: String, _ time: String) -> some View {
        HStack {
            Text(text).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100)
            Spacer()
            Text(time).font(.ladderBody(12)).foregroundStyle(LadderBrand.cream100.opacity(0.5))
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct CounselorBottomNav: View {
    var body: some View {
        HStack(spacing: 0) {
            tab("Home", icon: "house.fill", active: true)
            tab("Queue", icon: "tray", active: false)
            tab("Classes", icon: "tablecells", active: false)
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
