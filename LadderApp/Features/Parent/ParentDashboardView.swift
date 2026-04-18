import SwiftUI

// §6.2 + §5 — parent viewer of linked student(s). Sibling switcher on
// brand gradient.

public struct LinkedStudent: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let displayName: String
    public let gradeLevel: Int
}

public struct ParentDashboardView: View {
    public let session: SignedInSession

    @State private var linked: [LinkedStudent] = [
        LinkedStudent(id: UUID(), displayName: "Maya", gradeLevel: 4),
        LinkedStudent(id: UUID(), displayName: "Noah", gradeLevel: 7),
    ]
    @State private var selected: LinkedStudent?

    public init(session: SignedInSession) { self.session = session }

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                hero
                if linked.count > 1 {
                    siblingSwitcher
                        .padding(.vertical, 12)
                }
                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard
                        gradesCard
                        scheduleCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                parentBottomNav
            }
        }
        .navigationBarHidden(true)
        .onAppear { if selected == nil { selected = linked.first } }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PARENT VIEW")
                .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.lime500)
            HStack {
                Text("Hi, \(firstName) 👋")
                    .font(.ladderDisplay(28, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Spacer()
                Image("LadderLogo")
                    .resizable().scaledToFill().frame(width: 44, height: 44).clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var firstName: String {
        session.displayName.split(separator: ".").first.map(String.init)?.capitalized ?? "Parent"
    }

    private var siblingSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(linked) { student in
                    Button {
                        selected = student
                    } label: {
                        HStack(spacing: 8) {
                            Circle().fill(selected == student ? LadderBrand.ink900 : LadderBrand.cream100.opacity(0.25))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(String(student.displayName.prefix(1)))
                                        .font(.ladderLabel(12))
                                        .foregroundStyle(selected == student ? LadderBrand.lime500 : LadderBrand.cream100)
                                )
                            Text(student.displayName.uppercased())
                                .font(.ladderCaps(11))
                                .tracking(1.1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selected == student ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.12))
                        .foregroundStyle(selected == student ? LadderBrand.ink900 : LadderBrand.cream100)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selected?.displayName ?? "")
                .font(.ladderDisplay(22, relativeTo: .title2))
                .foregroundStyle(LadderBrand.ink900)
            Text("Grade \(selected?.gradeLevel ?? 0) · Career quiz completed")
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.ink600)
            Text("On track for advanced Algebra next year.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.forest700)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(LadderBrand.cream100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var gradesCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("GRADES").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
                Spacer()
            }
            Text("Grades are shown only when your child chooses to share. Respect their privacy.")
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NEXT YEAR'S SCHEDULE").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            Text("Maya's picks are with the counselor for review.")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100)
            Text("Approved in 48 hrs on average")
                .font(.ladderCaps(10))
                .tracking(0.8)
                .foregroundStyle(LadderBrand.lime500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var parentBottomNav: some View {
        HStack(spacing: 0) {
            tab("Home", icon: "house.fill", active: true)
            tab("Grades", icon: "chart.line.uptrend.xyaxis", active: false)
            tab("Schedule", icon: "calendar", active: false)
            tab("Messages", icon: "bubble.left.and.bubble.right", active: false)
            tab("Settings", icon: "gear", active: false)
        }
        .padding(.top, 10).padding(.bottom, 24)
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
