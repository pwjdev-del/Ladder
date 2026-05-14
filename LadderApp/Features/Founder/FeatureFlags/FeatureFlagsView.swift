import SwiftUI
import Supabase

// §14.3 + §15 — per-tenant feature flags, grouped by subsystem so a
// founder can see every toggle in one scroll. Each flag has a Varun-
// aware state; toggling a flag calls the validator and blocks save if
// a dependency rule is violated.

public struct FeatureFlagsRootView: View {
    @State private var selectedTenantId: UUID = FounderSchool.pilotData[0].id

    public init() {}

    public var body: some View {
        ZStack {
            BrandGradient.list
            BrandGradient.heroGlow

            VStack(spacing: 0) {
                header
                tenantPicker
                ScrollView {
                    MaxWidthContainer(maxWidth: 720) {
                        FeatureFlagsTenantView(tenantId: selectedTenantId)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(false)
        .navigationTitle("")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FEATURE FLAGS")
                .font(.ladderCaps(11)).tracking(1.4).foregroundStyle(LadderBrand.lime500)
            Text("Varun validates every change")
                .font(.ladderDisplay(28, relativeTo: .title))
                .foregroundStyle(LadderBrand.cream100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var tenantPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FounderSchool.pilotData) { school in
                    Button { selectedTenantId = school.id } label: {
                        Text(school.slug)
                            .font(.ladderCaps(11)).tracking(1.1)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(selectedTenantId == school.id ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.12))
                            .foregroundStyle(selectedTenantId == school.id ? LadderBrand.ink900 : LadderBrand.cream100)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
}

public struct FeatureFlagsTenantView: View {
    public let tenantId: UUID
    @State private var flags: [String: Bool] = FeatureFlagsCatalog.defaultState
    @State private var violations: [String] = []   // per-flag violations
    @State private var isSaving = false
    @State private var saveResult: SaveResult?

    public enum SaveResult: Equatable { case success(Int), failure(String) }

    public init(tenantId: UUID) { self.tenantId = tenantId }

    public var body: some View {
        VStack(spacing: 14) {
            ForEach(FeatureFlagsCatalog.groups) { group in
                groupCard(group)
            }

            if !violations.isEmpty {
                violationsCard
            }

            if let result = saveResult {
                saveBanner(result)
            }

            saveButton
        }
        .task(id: tenantId) { await loadFlags() }
    }

    @ViewBuilder
    private func saveBanner(_ r: SaveResult) -> some View {
        switch r {
        case .success(let n):
            Text("Settings saved (\(n) flag\(n == 1 ? "" : "s")).")
                .font(.ladderBody(12))
                .foregroundStyle(LadderBrand.lime500)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 6)
        case .failure(let msg):
            HStack(spacing: 10) {
                Text(msg)
                    .font(.ladderBody(12))
                    .foregroundStyle(LadderBrand.statusAmber)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 4)
                Button("Retry") { Task { await save() } }
                    .font(.ladderLabel(12))
                    .foregroundStyle(LadderBrand.ink900)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(LadderBrand.statusAmber)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 6)
        }
    }

    private func groupCard(_ group: FlagGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: group.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(LadderBrand.lime500)
                    .frame(width: 36, height: 36)
                    .background(LadderBrand.cream100.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.title).font(.ladderDisplay(16, relativeTo: .headline)).foregroundStyle(LadderBrand.cream100)
                    Text(group.subtitle).font(.ladderBody(11)).foregroundStyle(LadderBrand.cream100.opacity(0.7))
                }
                Spacer()
            }
            Divider().background(LadderBrand.cream100.opacity(0.15))

            VStack(spacing: 10) {
                ForEach(group.flags) { flag in
                    flagRow(flag)
                }
            }
        }
        .padding(14)
        .background(LadderBrand.cream100.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(LadderBrand.cream100.opacity(0.15), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func flagRow(_ flag: FlagDef) -> some View {
        let isOn = flags[flag.key] ?? false
        let violation = violations.contains(flag.key)
        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(flag.key)
                    .font(.ladderBody(12).monospaced())
                    .foregroundStyle(LadderBrand.cream100)
                Text(flag.description)
                    .font(.ladderBody(11))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newVal in
                    flags[flag.key] = newVal
                    validate()
                }
            ))
            .labelsHidden()
            .tint(LadderBrand.lime500)
        }
        .padding(10)
        .background(violation ? LadderBrand.statusAmber.opacity(0.18) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(violation ? LadderBrand.statusAmber : .clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var violationsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(LadderBrand.statusAmber)
                Text("Varun says").font(.ladderLabel(13)).foregroundStyle(LadderBrand.cream100)
            }
            ForEach(violations, id: \.self) { v in
                if let flag = FeatureFlagsCatalog.find(v) {
                    Text("• \(flag.description) — turn its required dependency on first.")
                        .font(.ladderBody(12))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                }
            }
        }
        .padding(12)
        .background(LadderBrand.statusAmber.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var saveButton: some View {
        Button { Task { await save() } } label: {
            HStack(spacing: 8) {
                if isSaving { ProgressView().tint(LadderBrand.ink900) }
                Text(isSaving ? "Saving…" : (violations.isEmpty ? "Save changes" : "Fix Varun issues first"))
                    .font(.ladderLabel(15))
                    .foregroundStyle(LadderBrand.ink900)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(violations.isEmpty ? LadderBrand.lime500 : LadderBrand.cream100.opacity(0.18))
            .clipShape(Capsule())
        }
        .disabled(!violations.isEmpty || isSaving)
        .padding(.top, 8)
    }

    private func validate() {
        // Local mirror of the Varun rules (edge function is the truth).
        var v: [String] = []
        if flags["feature.scheduling"] == true {
            for dep in ["feature.classes", "feature.teacher_data", "feature.student_profile"] {
                if flags[dep] != true { v.append("feature.scheduling") }
            }
        }
        if flags["feature.class_suggester"] == true {
            for dep in ["feature.career_quiz", "feature.grades_self_entry"] {
                if flags[dep] != true { v.append("feature.class_suggester") }
            }
        }
        if flags["feature.extracurriculars_ai"] == true {
            for dep in ["feature.career_quiz", "feature.student_profile"] {
                if flags[dep] != true { v.append("feature.extracurriculars_ai") }
            }
        }
        if flags["feature.teacher_reviews"] == true && flags["feature.teacher_data"] != true {
            v.append("feature.teacher_reviews")
        }
        if flags["feature.flex_scheduling"] == true && flags["feature.scheduling"] != true {
            v.append("feature.flex_scheduling")
        }
        if flags["feature.auth"] == false {
            for k in flags.keys where k != "feature.auth" && flags[k] == true { v.append(k) }
        }
        violations = Array(Set(v))
    }

    // MARK: - Persistence

    private struct FlagRow: Codable {
        let tenant_id: String
        let flag_key: String
        let enabled: Bool
    }

    // Mirrors the ValidateResult shape from varun-validate/index.ts
    private struct VarunValidateResponse: Decodable {
        struct Violation: Decodable {
            let rule: String
            let message: String
        }
        let ok: Bool
        let violations: [Violation]
    }

    private func loadFlags() async {
        let client = await SupabaseAuthService.shared.supabase
        do {
            let response = try await client
                .from("feature_flags")
                .select("flag_key, enabled")
                .eq("tenant_id", value: tenantId.uuidString)
                .execute()
            struct Row: Decodable { let flag_key: String; let enabled: Bool }
            let rows = try JSONDecoder().decode([Row].self, from: response.data)
            // Start from defaults, then overlay what's in the DB.
            var map = FeatureFlagsCatalog.defaultState
            for r in rows { map[r.flag_key] = r.enabled }
            flags = map
            validate()
        } catch {
            // Non-fatal: keep defaults. Founder can still save.
        }
    }

    private func save() async {
        validate()
        guard violations.isEmpty else { return }
        isSaving = true
        saveResult = nil
        defer { isSaving = false }

        let rows: [FlagRow] = flags.map {
            FlagRow(tenant_id: tenantId.uuidString, flag_key: $0.key, enabled: $0.value)
        }

        let client = await SupabaseAuthService.shared.supabase

        // 1. Server-side validation via varun-validate edge function.
        //    The edge function returns 200 { ok: true } or 409 { ok: false, violations: [...] }.
        //    The Supabase SDK throws FunctionsError.httpError on non-2xx, so catch 409 separately
        //    to surface the first violation message rather than a generic network error.
        struct ValidateBody: Encodable { let flags: [String: Bool] }
        do {
            let varunResult: VarunValidateResponse = try await client.functions.invoke(
                "varun-validate",
                options: .init(body: ValidateBody(flags: flags))
            )
            // 200 path — ok must be true or we fall through to upsert.
            if !varunResult.ok {
                saveResult = .failure(varunResult.violations.first?.message ?? "Varun rejected these settings.")
                return
            }
        } catch FunctionsError.httpError(409, let data) {
            // 409 path — decode the violations array from the error body.
            if let result = try? JSONDecoder().decode(VarunValidateResponse.self, from: data),
               let first = result.violations.first {
                saveResult = .failure(first.message)
            } else {
                saveResult = .failure("Varun rejected these settings (409).")
            }
            return
        } catch {
            saveResult = .failure("Validation failed: \(error.localizedDescription)")
            return
        }

        // 2. Upsert all flags in a single call (PK: tenant_id, flag_key).
        do {
            try await client
                .from("feature_flags")
                .upsert(rows, onConflict: "tenant_id,flag_key")
                .execute()
            saveResult = .success(rows.count)
        } catch {
            saveResult = .failure("Couldn't save: \(error.localizedDescription)")
        }
    }
}

// MARK: - Catalog

public struct FlagDef: Identifiable, Hashable {
    public let key: String
    public let description: String
    public var id: String { key }
}

public struct FlagGroup: Identifiable {
    public let title: String
    public let subtitle: String
    public let icon: String
    public let flags: [FlagDef]
    public var id: String { title }
}

public enum FeatureFlagsCatalog {
    public static let groups: [FlagGroup] = [
        FlagGroup(
            title: "Authentication",
            subtitle: "Sign-in surfaces and identity",
            icon: "lock.shield.fill",
            flags: [
                FlagDef(key: "feature.auth",           description: "Enable authentication at all."),
                FlagDef(key: "feature.school_login",   description: "B2B sign-in through school picker."),
                FlagDef(key: "feature.b2c_signup",     description: "Student self-signup (Create an account)."),
                FlagDef(key: "feature.invite_codes",   description: "Invite-code redemption flow."),
                FlagDef(key: "feature.parent_invite",  description: "Student-invites-parent B2C flow."),
                FlagDef(key: "feature.mfa_admin",      description: "Require MFA for admin + counselor."),
                FlagDef(key: "feature.passkey_founder", description: "Passkey authentication for founders."),
            ]
        ),
        FlagGroup(
            title: "Student",
            subtitle: "What grade 9–12 students see",
            icon: "graduationcap.fill",
            flags: [
                FlagDef(key: "feature.student_profile",   description: "Profile model + editable fields."),
                FlagDef(key: "feature.grades_self_entry", description: "Student-only GPA + transcript entry."),
                FlagDef(key: "feature.career_quiz",       description: "RIASEC career quiz, retakeable yearly."),
                FlagDef(key: "feature.class_suggester",   description: "AI-recommended next-year classes."),
                FlagDef(key: "feature.extracurriculars_ai", description: "Iterative AI activity suggestions."),
                FlagDef(key: "feature.schedule_builder",  description: "Student-side schedule builder."),
                FlagDef(key: "feature.essay_hub",         description: "Per-college essay tracker + AI talking points."),
                FlagDef(key: "feature.mock_interview",    description: "AI mock interview recording."),
            ]
        ),
        FlagGroup(
            title: "College intelligence",
            subtitle: "Discovery, match, applications, deadlines",
            icon: "building.columns.fill",
            flags: [
                FlagDef(key: "feature.college_discovery", description: "6,500-college discovery + search."),
                FlagDef(key: "feature.match_reach_safety", description: "Match/Reach/Safety calculator from GPA + SAT."),
                FlagDef(key: "feature.college_personality", description: "AI-generated college personality archetypes."),
                FlagDef(key: "feature.application_tracker", description: "Status machine + auto checklists."),
                FlagDef(key: "feature.deadlines_calendar",  description: "Deadlines per saved college + reminders."),
                FlagDef(key: "feature.financial_aid",       description: "Aid calculator + scholarship search."),
                FlagDef(key: "feature.college_connect",     description: "Chat with current college students."),
                FlagDef(key: "feature.loci_generator",      description: "Letter-of-Continued-Interest drafting."),
            ]
        ),
        FlagGroup(
            title: "AI",
            subtitle: "Gemini-powered features (via ai-gateway)",
            icon: "sparkles",
            flags: [
                FlagDef(key: "feature.ai_academic_advisor", description: "Conversational AI advisor."),
                FlagDef(key: "feature.ai_essay_feedback",   description: "Essay scoring + suggestions."),
                FlagDef(key: "feature.ai_career_analysis",  description: "Deep career-profile analysis."),
                FlagDef(key: "feature.ai_college_matcher",  description: "AI college matcher (beyond M/R/S)."),
                FlagDef(key: "feature.ai_class_research",   description: "Grounded class-pathway research."),
                FlagDef(key: "feature.ai_token_budgets",    description: "Per-tenant AI token budgets + throttles."),
            ]
        ),
        FlagGroup(
            title: "Counselor",
            subtitle: "School-licensed counselor tools",
            icon: "person.2.fill",
            flags: [
                FlagDef(key: "feature.counselor_dashboard", description: "Counselor home + caseload."),
                FlagDef(key: "feature.student_queue",       description: "Schedule approval queue + conflict view."),
                FlagDef(key: "feature.class_list_upload",   description: "CSV/XLSX/PDF class list ingest."),
                FlagDef(key: "feature.scheduling",          description: "Scheduling engine + window."),
                FlagDef(key: "feature.flex_scheduling",     description: "Late-add flex-schedule re-opens."),
                FlagDef(key: "feature.counselor_messages",  description: "Counselor ↔ student messaging."),
            ]
        ),
        FlagGroup(
            title: "Admin",
            subtitle: "Admin-exclusive surfaces",
            icon: "building.2.fill",
            flags: [
                FlagDef(key: "feature.admin_dashboard",   description: "Admin home + KPIs."),
                FlagDef(key: "feature.teacher_data",      description: "Teacher profile + schedule CRUD."),
                FlagDef(key: "feature.teacher_reviews",   description: "Admin-only teacher performance reviews."),
                FlagDef(key: "feature.success_metrics",   description: "Periodic annual metrics popup."),
                FlagDef(key: "feature.classes",           description: "Class catalog management."),
                FlagDef(key: "feature.admin_invites",     description: "Admin-side invite code batching."),
            ]
        ),
        FlagGroup(
            title: "Scheduling + prereqs",
            subtitle: "Engine-level controls",
            icon: "calendar.badge.clock",
            flags: [
                FlagDef(key: "feature.scheduling_engine",  description: "Deterministic core + AI suggester."),
                FlagDef(key: "feature.window_lock",        description: "Hard-lock schedules outside the window."),
                FlagDef(key: "feature.prereq_chain",       description: "Multi-step prereq chain validation."),
                FlagDef(key: "feature.capacity_enforcement", description: "Refuse picks past section cap."),
                FlagDef(key: "feature.teacher_matcher",    description: "AI suggests teacher per student."),
            ]
        ),
    ]

    public static var defaultState: [String: Bool] {
        var map: [String: Bool] = [:]
        for g in groups { for f in g.flags { map[f.key] = true } }
        return map
    }

    public static func find(_ key: String) -> FlagDef? {
        for g in groups { if let m = g.flags.first(where: { $0.key == key }) { return m } }
        return nil
    }
}
