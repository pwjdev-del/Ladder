import SwiftUI

// Student home dashboard — shell on the brand gradient.
// Full tab bar + role-specific cards land in the next PR; for now this
// shows the student their tenant + role so sign-in feels real.

public struct StudentDashboardView: View {
    public let session: SignedInSession

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                hero
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        checklistCard
                        nextUpCard
                        quickActions
                        dailyTip
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                StudentBottomNav()
            }
        }
        .navigationBarHidden(true)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STUDENT DASHBOARD")
                .font(.ladderCaps(11))
                .tracking(1.4)
                .foregroundStyle(LadderBrand.lime500)
            HStack {
                Text("Good morning, \(firstName) 👋")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Spacer()
                Image("LadderLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
            Text("\(session.tenantName) · Grade 5")
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
        session.displayName.split(separator: ".").first.map(String.init)?.capitalized ?? "Friend"
    }

    private var checklistCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Checklist")
                    .font(.ladderDisplay(22, relativeTo: .title2))
                    .foregroundStyle(LadderBrand.ink900)
                Text("Keep pushing towards your dream college.")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.ink600)
                Text("View Tasks →")
                    .font(.ladderLabel(13))
                    .foregroundStyle(LadderBrand.forest700)
            }
            Spacer()
            ZStack {
                Circle().stroke(LadderBrand.lime500.opacity(0.25), lineWidth: 6).frame(width: 64, height: 64)
                Circle().trim(from: 0, to: 0.6).stroke(LadderBrand.lime500, style: StrokeStyle(lineWidth: 6, lineCap: .round)).rotationEffect(.degrees(-90)).frame(width: 64, height: 64)
                Text("60%").font(.ladderLabel(12)).foregroundStyle(LadderBrand.ink900)
            }
        }
        .padding(16)
        .background(LadderBrand.cream100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var nextUpCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("NEXT UP").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.ink600)
                Spacer()
                Text("Career quiz")
                    .font(.ladderCaps(10)).tracking(1.0)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(LadderBrand.lime500.opacity(0.25))
                    .foregroundStyle(LadderBrand.forest900)
                    .clipShape(Capsule())
            }
            Text("Take the Career Quiz")
                .font(.ladderDisplay(20, relativeTo: .title3))
                .foregroundStyle(LadderBrand.ink900)
            Text("15 questions · ~10 minutes")
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.ink600)
            ProgressView(value: 0.0)
                .tint(LadderBrand.lime500)
                .padding(.top, 4)
        }
        .padding(16)
        .background(LadderBrand.cream100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            actionTile("Grades", icon: "book", color: LadderBrand.lime500)
            actionTile("Classes", icon: "graduationcap", color: LadderBrand.lime500)
            actionTile("Schedule", icon: "calendar", color: LadderBrand.lime500)
        }
    }

    private func actionTile(_ label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 22)).foregroundStyle(color)
            Text(label).font(.ladderLabel(12)).foregroundStyle(LadderBrand.cream100)
        }
        .frame(maxWidth: .infinity).frame(height: 72)
        .background(LadderBrand.cream100.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var dailyTip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill").foregroundStyle(LadderBrand.lime500)
                Text("DAILY TIP").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.lime500)
            }
            Text("\"Success is the sum of small efforts, repeated day in and day out.\"")
                .font(.ladderDisplay(16, relativeTo: .body).italic())
                .foregroundStyle(LadderBrand.cream100)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(LadderBrand.forest900.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Shared student-style bottom nav

struct StudentBottomNav: View {
    var body: some View {
        HStack(spacing: 0) {
            tab("Home", icon: "house.fill", active: true)
            tab("Tasks", icon: "checklist", active: false)
            tab("Classes", icon: "graduationcap", active: false)
            tab("Advisor", icon: "sparkles", active: false)
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
