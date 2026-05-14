import SwiftUI
import os

// T024 iPad parity: on iPad regular width the dashboard uses a NavigationSplitView
// so counselors can see filters + quick stats in the sidebar while the main
// content fills the detail column.  On iPhone the existing single-column flow
// is preserved unchanged.

// MARK: - Student summary row model (counselor dashboard)

/// Lightweight row used by the student-list section of the dashboard.
/// Contains only what we need to render the card; detailed SIA data is
/// loaded on-demand inside StudentSiaSummaryView (D-002 boundary).
private struct StudentRow: Identifiable, Decodable {
    let id: String         // auth.uid of the student
    let displayName: String
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case displayName = "display_name"
    }
}

// MARK: - KPI view-model (isolated actor avoids data races on the dashboard state)
@MainActor
private final class CounselorKPIViewModel: ObservableObject {
    @Published var schedulesWaiting: String = "—"
    @Published var studentsCount: String = "—"
    @Published var activityFeed: [ActivityEntry] = []
    @Published var isLoading = false
    @Published var studentRows: [StudentRow] = []
    @Published var studentsLoadError = false

    private let log = Logger(subsystem: "ladder", category: "CounselorKPI")

    struct ActivityEntry: Identifiable {
        let id: String
        let description: String
        let relativeTime: String
    }

    // Decodable shims — only pull the columns we need.
    private struct ScheduleEventRow: Decodable {
        let id: String
        let to_state: String
        let actor_id: String
        let ts: String           // ISO-8601 from Supabase
    }

    func fetch() async {
        isLoading = true
        defer { isLoading = false }

        let client = SupabaseAuthService.shared.supabase

        // 1. schedules waiting (state = SUBMITTED)
        do {
            let response = try await client
                .from("schedules")
                .select("id", head: false, count: .exact)
                .eq("state", value: "SUBMITTED")
                .execute()
            let n = response.count ?? 0
            schedulesWaiting = n == 0 ? "—" : "\(n)"
        } catch {
            log.error("schedules waiting query failed: \(error)")
            schedulesWaiting = "—"
        }

        // 2. student count
        do {
            let response = try await client
                .from("students")
                .select("id", head: false, count: .exact)
                .execute()
            let n = response.count ?? 0
            studentsCount = n == 0 ? "—" : "\(n)"
        } catch {
            log.error("students count query failed: \(error)")
            studentsCount = "—"
        }

        // 3. student list (display_name + user_id only — no profile data, no chat)
        do {
            let rows: [StudentRow] = try await client
                .from("students")
                .select("user_id, display_name")
                .order("display_name", ascending: true)
                .limit(20)
                .execute()
                .value
            studentRows = rows
        } catch {
            log.error("student list query failed: \(error)")
            studentsLoadError = true
        }

        // 4. activity feed from schedule_events (most recent 10 state transitions)
        do {
            let rows: [ScheduleEventRow] = try await client
                .from("schedule_events")
                .select("id, to_state, actor_id, ts")
                .order("ts", ascending: false)
                .limit(10)
                .execute()
                .value
            activityFeed = rows.map { row in
                ActivityEntry(
                    id: row.id,
                    description: "Schedule moved to \(row.to_state.lowercased())",
                    relativeTime: Self.relativeLabel(isoString: row.ts)
                )
            }
        } catch {
            log.error("activity feed query failed: \(error)")
            // leave activityFeed empty — UI shows placeholder
        }
    }

    // Minimal relative-time formatter; no Calendar math library needed.
    private static func relativeLabel(isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: isoString) else { return "" }
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case ..<60:        return "just now"
        case ..<3600:      return "\(seconds / 60)m ago"
        case ..<86400:     return "\(seconds / 3600)h ago"
        default:           return "\(seconds / 86400)d ago"
        }
    }
}

public struct CounselorDashboardView: View {
    public let session: SignedInSession
    public let onLogout: () -> Void
    /// The counselor's own auth UID — threaded through to D-002 surfaces.
    public let counselorAuthUid: String
    @StateObject private var kpi = CounselorKPIViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(
        session: SignedInSession,
        counselorAuthUid: String = "",
        onLogout: @escaping () -> Void = {}
    ) {
        self.session = session
        self.counselorAuthUid = counselorAuthUid
        self.onLogout = onLogout
    }

    public var body: some View {
        Group {
            if sizeClass == .regular {
                ipadLayout
            } else {
                phoneLayout
            }
        }
        .requireNonStaff()
        .task { await kpi.fetch() }
    }

    // MARK: - iPad layout (NavigationSplitView: sidebar = filters/stats, detail = content)

    private var ipadLayout: some View {
        NavigationSplitView {
            sidebarColumn
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 340)
        } detail: {
            ZStack {
                BrandGradient.list.ignoresSafeArea()
                BrandGradient.heroGlow.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            hero
                            queueCard
                            quickActions
                            studentSummarySection
                            recentActivity
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationSplitViewStyle(.balanced)
    }

    /// Sidebar: filter chips + quick KPIs — visible on iPad alongside the main scroll.
    private var sidebarColumn: some View {
        ZStack {
            BrandGradient.list.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COUNSELOR").font(.ladderCaps(10)).tracking(1.4)
                            .foregroundStyle(LadderBrand.lime500)
                        Text(session.tenantName)
                            .font(.ladderLabel(15))
                            .foregroundStyle(LadderBrand.cream100)
                    }
                    .padding(.top, 12)

                    Divider().overlay(LadderBrand.cream100.opacity(0.15))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("QUICK STATS").font(.ladderCaps(10)).tracking(1.2)
                            .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                        sideStat("Waiting", kpi.isLoading ? "…" : kpi.schedulesWaiting)
                        sideStat("Students", kpi.isLoading ? "…" : kpi.studentsCount)
                    }

                    Divider().overlay(LadderBrand.cream100.opacity(0.15))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("FILTERS").font(.ladderCaps(10)).tracking(1.2)
                            .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                        filterChip("All students", isActive: true)
                        filterChip("Flagged", isActive: false)
                        filterChip("No activity", isActive: false)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private func sideStat(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.ladderBody(13)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            Spacer()
            Text(value).font(.ladderLabel(14)).foregroundStyle(LadderBrand.cream100)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func filterChip(_ label: String, isActive: Bool) -> some View {
        Text(label)
            .font(.ladderLabel(12))
            .foregroundStyle(isActive ? LadderBrand.ink900 : LadderBrand.cream100.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.1))
            .clipShape(Capsule())
    }

    // MARK: - iPhone layout (existing single-column)

    private var phoneLayout: some View {
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
                        studentSummarySection
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
                LadderLogoMark(size: 44, withShadow: true)
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
                if kpi.isLoading {
                    ProgressView().tint(LadderBrand.ink600)
                } else {
                    Text("\(kpi.schedulesWaiting) schedules waiting")
                        .font(.ladderDisplay(22, relativeTo: .title2))
                        .foregroundStyle(LadderBrand.ink900)
                }
                Text("Submitted and awaiting review").font(.ladderBody(13)).foregroundStyle(LadderBrand.ink600)
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
            smallKPI("STUDENTS", kpi.isLoading ? "…" : kpi.studentsCount)
            smallKPI("QUIZ DONE", "—")      // T016 SIA hook will populate
            smallKPI("APPROVED", "—")       // T016 SIA hook will populate
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

    // MARK: - Student summary section (D-002)
    // D-002 HARD: no raw chat content here or in any downstream view.
    // Each card navigates to StudentSiaSummaryView which calls SiaEngine.summarize().
    @ViewBuilder
    private var studentSummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STUDENT OVERVIEWS")
                .font(.ladderCaps(11)).tracking(1.2)
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))

            if kpi.isLoading {
                ProgressView().tint(LadderBrand.cream100).frame(maxWidth: .infinity, alignment: .center)
            } else if kpi.studentsLoadError {
                Text("Couldn't load students — check your connection.")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LadderBrand.cream100.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if kpi.studentRows.isEmpty {
                Text("No students enrolled yet.")
                    .font(.ladderBody(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LadderBrand.cream100.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                VStack(spacing: 10) {
                    ForEach(kpi.studentRows) { row in
                        NavigationLink(
                            destination: StudentSiaSummaryView(
                                studentId: row.id,
                                studentDisplayName: row.displayName,
                                counselorAuthUid: counselorAuthUid
                            )
                        ) {
                            studentRowCard(row)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func studentRowCard(_ row: StudentRow) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LadderBrand.lime500.opacity(0.25))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(row.displayName.prefix(1)).uppercased())
                        .font(.ladderLabel(14))
                        .foregroundStyle(LadderBrand.lime500)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(row.displayName)
                    .font(.ladderLabel(14))
                    .foregroundStyle(LadderBrand.cream100)
                Text("Tap for SIA summary")
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(LadderBrand.cream100.opacity(0.35))
        }
        .padding(12)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT ACTIVITY").font(.ladderCaps(11)).tracking(1.2).foregroundStyle(LadderBrand.cream100.opacity(0.7))
            if kpi.isLoading {
                ProgressView().tint(LadderBrand.cream100).frame(maxWidth: .infinity, alignment: .center)
            } else if kpi.activityFeed.isEmpty {
                activityRow("No recent activity", "")
            } else {
                VStack(spacing: 8) {
                    ForEach(kpi.activityFeed) { entry in
                        activityRow(entry.description, entry.relativeTime)
                    }
                }
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
