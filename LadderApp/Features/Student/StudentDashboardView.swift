import SwiftUI
import SwiftData

// Student home dashboard — shell on the brand gradient.
// Full tab bar + role-specific cards land in the next PR; for now this
// shows the student their tenant + role so sign-in feels real.

// MARK: - Tab enum

public enum StudentTab: CaseIterable {
    case home, tasks, classes, advisor, profile

    var label: String {
        switch self {
        case .home:    return "Home"
        case .tasks:   return "Tasks"
        case .classes: return "Classes"
        case .advisor: return "Advisor"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .tasks:   return "checklist"
        case .classes: return "graduationcap"
        case .advisor: return "sparkles"
        case .profile: return "person"
        }
    }
}

public struct StudentDashboardView: View {
    public let session: SignedInSession
    public let onLogout: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State private var selectedTab: StudentTab = .home
    /// Used by the iPad sidebar List selection binding (requires Optional<StudentTab>).
    @State private var sidebarSelection: StudentTab? = .home
    @State private var showGradesSheet = false
    @State private var showScheduleSheet = false
    /// Resolved from the live Supabase JWT on appear. Required by AdvisorChatView (D-003).
    @State private var resolvedStudentId: String?
    /// Which nudge is currently visible in the card carousel (0-based).
    @State private var nudgeIndex: Int = 0
    /// When non-nil, the advisor tab opens with this pre-filled seed message.
    @State private var advisorSeedMessage: String?

    private var nudgeStore: NudgeStore { NudgeStore.shared }

    public init(session: SignedInSession, onLogout: @escaping () -> Void = {}) {
        self.session = session
        self.onLogout = onLogout
    }

    public var body: some View {
        Group {
            if hSizeClass == .regular {
                // iPad regular size class: NavigationSplitView with sidebar navigation.
                // The tab bar becomes a sidebar column; content fills the detail column.
                iPadLayout
            } else {
                // iPhone / compact: original bottom-tab layout unchanged.
                iPhoneLayout
            }
        }
        .requireNonStaff()
        .task {
            if resolvedStudentId == nil {
                // Prefer the live Supabase JWT; fall back to TenantContext (e.g. UITestMode).
                let s = await SupabaseAuthService.shared.currentSession
                if let uid = s?.user.id.uuidString {
                    resolvedStudentId = uid
                } else {
                    resolvedStudentId = await TenantContext.shared.claim?.userId.uuidString
                }
            }
            await refreshNudgesIfReady()
        }
        .sheet(isPresented: $showGradesSheet) {
            NavigationStack { GradesSelfEntryView() }
        }
        .sheet(isPresented: $showScheduleSheet) {
            NavigationStack { ScheduleBuilderView() }
        }
    }

    // MARK: - iPhone layout (unchanged)

    private var iPhoneLayout: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                tabContent
                StudentBottomNav(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - iPad layout

    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar — tab list.
            List(selection: $sidebarSelection) {
                ForEach(StudentTab.allCases, id: \.self) { tab in
                    Label(tab.label, systemImage: tab.icon)
                        .font(.ladderBody(16))
                        .foregroundStyle(
                            selectedTab == tab ? LadderBrand.lime500 : LadderBrand.cream100
                        )
                        .tag(tab)
                }
            }
            .onChange(of: sidebarSelection) { _, newVal in
                if let tab = newVal { selectedTab = tab }
            }
            .listStyle(.sidebar)
            .navigationTitle("Ladder")
            .navigationBarTitleDisplayMode(.large)
            .background(LadderBrand.forest900)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    LogoutButton(action: onLogout)
                }
            }
        } detail: {
            ZStack {
                BrandGradient.list.ignoresSafeArea()
                BrandGradient.heroGlow.ignoresSafeArea()
                tabContent
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Nudge refresh

    private func refreshNudgesIfReady() async {
        guard let studentId = resolvedStudentId else { return }
        let descriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = (try? modelContext.fetch(descriptor))?.first else { return }
        await NudgeStore.shared.refresh(studentId: studentId, profile: profile, context: modelContext)
        nudgeIndex = 0
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            homeContent
        case .tasks:
            placeholderTab(title: "Tasks", message: "Your task list is coming soon.")
        case .classes:
            NavigationStack { ClassSuggesterView() }
        case .advisor:
            advisorTab
        case .profile:
            placeholderTab(title: "Profile", message: "Profile settings are coming soon.")
        }
    }

    @ViewBuilder
    private var advisorTab: some View {
        // studentId sourced from the live Supabase JWT (D-003).
        // Resolved asynchronously on dashboard appear via SupabaseAuthService.
        // If nil, the session has expired — show a recoverable error.
        if let studentId = resolvedStudentId {
            NavigationStack {
                // Pass advisorSeedMessage when navigating from a nudge card.
                // AdvisorChatViewModel pre-fills currentInput; student edits before sending.
                AdvisorChatView(
                    viewModel: AdvisorChatViewModel(
                        studentId: studentId,
                        seedMessage: advisorSeedMessage
                    )
                )
            }
            .onAppear {
                // Clear seed after view builds so next manual open is a fresh session.
                advisorSeedMessage = nil
            }
        } else {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderBrand.lime500)
                Text("Please sign in again")
                    .font(.ladderDisplay(20, relativeTo: .title3))
                    .foregroundStyle(LadderBrand.cream100)
                Text("We couldn't load your session. Tap the logout button and sign back in.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var homeContent: some View {
        VStack(spacing: 0) {
            hero
            ScrollView {
                // MaxWidthContainer(720) prevents the home cards from stretching
                // edge-to-edge on iPad Pro 12.9"/13" while preserving full-width on iPhone.
                MaxWidthContainer(maxWidth: 720) {
                    VStack(alignment: .leading, spacing: 20) {
                        nudgeSectionIfNeeded
                        checklistCard
                        nextUpCard
                        quickActions
                        dailyTip
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private func placeholderTab(title: String, message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text(title)
                    .font(.ladderDisplay(26, relativeTo: .title))
                    .foregroundStyle(LadderBrand.cream100)
                Text(message)
                    .font(.ladderBody(15))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nudge section

    /// Renders the SIA nudge card at `nudgeIndex` when nudges are available.
    /// Returns EmptyView when the store has no current nudges (no layout impact).
    @ViewBuilder
    private var nudgeSectionIfNeeded: some View {
        let nudges = nudgeStore.currentNudges
        if !nudges.isEmpty {
            let clampedIndex = min(nudgeIndex, nudges.count - 1)
            let nudge = nudges[clampedIndex]
            let hasNext = clampedIndex < nudges.count - 1

            VStack(alignment: .leading, spacing: 8) {
                Text("FOR YOU")
                    .font(.ladderCaps(11))
                    .tracking(1.2)
                    .foregroundStyle(LadderBrand.lime500)

                SiaNudgeCard(
                    nudge: nudge,
                    index: clampedIndex,
                    total: nudges.count,
                    onTellMeMore: {
                        guard let studentId = resolvedStudentId else { return }
                        // Record acted=true, then open the Advisor tab pre-seeded.
                        Task {
                            await NudgeStore.shared.act(nudge: nudge, studentId: studentId)
                        }
                        // Build the opening hook from the nudge topic.
                        advisorSeedMessage = nudgeSeedMessage(for: nudge)
                        selectedTab = .advisor
                    },
                    onNotNow: {
                        guard let studentId = resolvedStudentId else { return }
                        Task {
                            await NudgeStore.shared.dismiss(nudge: nudge, studentId: studentId)
                        }
                        // Advance to next nudge if one exists, else card disappears.
                        if hasNext {
                            nudgeIndex = clampedIndex + 1
                        }
                    },
                    onShowNext: hasNext
                        ? { nudgeIndex = clampedIndex + 1 }
                        : nil
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: nudgeIndex)
            }
        }
    }

    /// Constructs a low-pressure opening hook that pre-fills the SIA chat input.
    /// The student sees this text in the input field and can edit before sending.
    private func nudgeSeedMessage(for nudge: NudgeIntent) -> String {
        // Use the rawMessage as the opening hook — it's already phrased conversationally
        // by NudgeRules. The student edits it before tapping send (low-pressure per SIA_PERSONA_RESEARCH.md §4).
        return nudge.rawMessage
    }

    // MARK: - Hero
    //
    // On iPad the hero sits inside MaxWidthContainer via homeContent's scroll wrapper.
    // LogoutButton is hidden in the hero on iPad because it moves to the sidebar toolbar.

    private var hero: some View {
        MaxWidthContainer(maxWidth: 720) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("STUDENT DASHBOARD")
                            .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.lime500)
                        Text("Good morning, \(firstName) 👋")
                            .font(.ladderDisplay(26, relativeTo: .title))
                            .foregroundStyle(LadderBrand.cream100)
                    }
                    Spacer()
                    // On iPad the logout button lives in the sidebar toolbar.
                    if hSizeClass != .regular {
                        LogoutButton(action: onLogout)
                    }
                }
                Text("\(session.tenantName) · Grade \(session.gradeLevel ?? 10)")
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
        // AdaptiveStack: on iPhone stays as a horizontal row (already compact).
        // On iPad regular it spreads with more spacing for better touch targets.
        AdaptiveStack(compactSpacing: 12, regularSpacing: 16) {
            actionTile("Grades", icon: "book") { showGradesSheet = true }
            actionTile("Classes", icon: "graduationcap") { selectedTab = .classes }
            actionTile("Schedule", icon: "calendar") { showScheduleSheet = true }
        }
    }

    private func actionTile(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 22)).foregroundStyle(LadderBrand.lime500)
                Text(label).font(.ladderLabel(12)).foregroundStyle(LadderBrand.cream100)
            }
            .frame(maxWidth: .infinity).frame(height: 72)
            .background(LadderBrand.cream100.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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

// MARK: - Previews

#if DEBUG
private let previewSession = SignedInSession(
    role: .student,
    displayName: "alex.student",
    tenantName: "Lincoln High",
    gradeLevel: 11
)

#Preview("iPhone 15", traits: .sizeThatFitsLayout) {
    StudentDashboardView(session: previewSession)
        .frame(width: 393, height: 852)
        .modelContainer(for: [StudentProfileModel.self, ConversationMemoryModel.self], inMemory: true)
}

#Preview("iPad Air portrait", traits: .sizeThatFitsLayout) {
    StudentDashboardView(session: previewSession)
        .frame(width: 820, height: 1180)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self, ConversationMemoryModel.self], inMemory: true)
}

#Preview("iPad Air landscape", traits: .sizeThatFitsLayout) {
    StudentDashboardView(session: previewSession)
        .frame(width: 1180, height: 820)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self, ConversationMemoryModel.self], inMemory: true)
}

#Preview("iPad Pro 12.9 portrait", traits: .sizeThatFitsLayout) {
    StudentDashboardView(session: previewSession)
        .frame(width: 1024, height: 1366)
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(for: [StudentProfileModel.self, ConversationMemoryModel.self], inMemory: true)
}
#endif

// MARK: - Shared student-style bottom nav

struct StudentBottomNav: View {
    @Binding var selectedTab: StudentTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(StudentTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    tabLabel(tab)
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel(tab.label)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(LadderBrand.forest900)
    }

    private func tabLabel(_ tab: StudentTab) -> some View {
        let active = selectedTab == tab
        return VStack(spacing: 4) {
            Image(systemName: tab.icon).font(.system(size: 18))
            Text(tab.label).font(.ladderCaps(10)).tracking(0.6)
        }
        .foregroundStyle(active ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.55))
    }
}
