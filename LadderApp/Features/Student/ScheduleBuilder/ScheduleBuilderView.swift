import SwiftUI
import Supabase

// §11.2 — student schedule builder. Quiz gate: cannot enter unless career
// quiz is dated within the current academic year. Window gate: cannot
// submit outside scheduling_windows.opens_at / closes_at.
//
// Fix B-04 (2026-05-14): Added per-period class picker via Menu. Classes are
//   loaded from the `classes` table (tenant-scoped, classes_tenant_read policy).
//   If the tenant has no classes seeded, a hardcoded Subject fallback is used so
//   the UI is never empty. The fallback is clearly labeled; a real catalog
//   seed is required before the school goes live.
//
// Fix B-05 (2026-05-14): submit() now does a SELECT-then-UPDATE/INSERT (logical
//   upsert) on the `schedules` table keyed on the existing DRAFT row for the
//   active window. Picks are encoded as UTF-8 JSON and stored in picks_cipher.
//   NOTE: picks_cipher is typed bytea in the DB. For v1.0 the client writes
//   plain JSON bytes without envelope encryption. A follow-up task (after DEK
//   key management is wired) must encrypt this field — filed in OUT_OF_SCOPE_FINDINGS.md.

// MARK: - Models

public struct SchedulePick: Identifiable, Sendable {
    public let id: UUID
    public var classId: String
    public var period: String
    public var classTitle: String

    public init(id: UUID = UUID(), classId: String, period: String, classTitle: String) {
        self.id = id
        self.classId = classId
        self.period = period
        self.classTitle = classTitle
    }
}

/// Represents a class from the `classes` table or the hardcoded fallback catalog.
public struct ClassOption: Identifiable, Sendable {
    public let id: String   // UUID string from DB, or Subject rawValue for fallback
    public let title: String
    public let subject: String

    public init(id: String, title: String, subject: String) {
        self.id = id
        self.title = title
        self.subject = subject
    }
}

// MARK: - Fallback subject catalog (used when DB classes table is empty)

/// Hardcoded subject catalog used when the tenant has no classes seeded yet.
/// MIGRATION GAP: Every school must seed the `classes` table before go-live.
/// This fallback exists solely to unblock v1.0 UI testing.
private enum FallbackSubject: String, CaseIterable {
    case math          = "Math"
    case english       = "English"
    case science       = "Science"
    case socialStudies = "Social Studies"
    case worldLanguage = "World Language"
    case artMusic      = "Art / Music"
    case peOther       = "PE / Other"

    var asClassOption: ClassOption {
        ClassOption(id: rawValue, title: rawValue, subject: rawValue)
    }
}

// MARK: - ScheduleBuilderView

public struct ScheduleBuilderView: View {
    @State private var picks: [SchedulePick] = []
    @State private var windowOpen = false
    @State private var quizFresh = false
    @State private var loaded = false
    @State private var submitState: String = "DRAFT"
    @State private var availableClasses: [ClassOption] = []
    @State private var activeWindowId: String?

    public init() {}

    public var body: some View {
        Group {
            if !loaded {
                ProgressView().padding()
            } else if !quizFresh {
                ContentUnavailableView(
                    "Take the career quiz first",
                    systemImage: "pencil.and.list.clipboard",
                    description: Text("Your career quiz needs to be dated this school year before you can plan classes (§11.2).")
                )
            } else if !windowOpen {
                ContentUnavailableView(
                    "Scheduling window is closed",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Your counselor or admin opens this window when it's time to plan.")
                )
            } else {
                ScheduleBuilderBody(
                    picks: $picks,
                    submitState: $submitState,
                    availableClasses: availableClasses,
                    activeWindowId: activeWindowId
                )
            }
        }
        .navigationTitle("Next year's schedule")
        .task { await loadAll() }
    }

    // MARK: - Decodable rows

    private struct WindowRow: Decodable {
        let id: String
        let opens_at: Date
        let closes_at: Date
    }

    private struct QuizRow: Decodable {
        let submitted_at: Date
    }

    private struct ClassRow: Decodable {
        let id: String
        let title: String
        let subject: String?
    }

    private struct ExistingScheduleRow: Decodable {
        let id: String
        let state: String
    }

    // MARK: - Gate + catalog loading

    private func loadAll() async {
        defer { loaded = true }
        let client = SupabaseAuthService.shared.supabase
        let iso = ISO8601DateFormatter()
        let now = Date()

        // --- Window gate ---
        do {
            let resp = try await client
                .from("scheduling_windows")
                .select("id, opens_at, closes_at")
                .lte("opens_at", value: iso.string(from: now))
                .gte("closes_at", value: iso.string(from: now))
                .limit(1)
                .execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let rows = (try? decoder.decode([WindowRow].self, from: resp.data)) ?? []
            windowOpen = !rows.isEmpty
            activeWindowId = rows.first?.id
        } catch {
            windowOpen = false
        }

        // --- Quiz freshness ---
        do {
            let resp = try await client
                .from("quiz_answers")
                .select("submitted_at")
                .order("submitted_at", ascending: false)
                .limit(1)
                .execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let rows = (try? decoder.decode([QuizRow].self, from: resp.data)) ?? []
            if let latest = rows.first {
                let cal = Calendar.current
                let nowYear = cal.component(.year, from: now)
                let nowMonth = cal.component(.month, from: now)
                let startYear = nowMonth >= 7 ? nowYear : nowYear - 1
                let startOfAY = cal.date(from: DateComponents(year: startYear, month: 7, day: 1)) ?? now
                quizFresh = latest.submitted_at >= startOfAY
            } else {
                quizFresh = false
            }
        } catch {
            quizFresh = false
        }

        // --- Class catalog (only needed when window is open) ---
        if windowOpen {
            await loadClasses(client: client)
            await loadExistingDraft(client: client)
        }
    }

    private func loadClasses(client: SupabaseClient) async {
        do {
            let resp = try await client
                .from("classes")
                .select("id, title, subject")
                .order("title", ascending: true)
                .execute()
            let rows = (try? JSONDecoder().decode([ClassRow].self, from: resp.data)) ?? []
            if rows.isEmpty {
                // FALLBACK: tenant has no classes seeded. Use hardcoded Subject enum.
                // MIGRATION GAP: Seed `classes` table before school go-live.
                availableClasses = FallbackSubject.allCases.map(\.asClassOption)
            } else {
                availableClasses = rows.map {
                    ClassOption(id: $0.id, title: $0.title, subject: $0.subject ?? "")
                }
            }
        } catch {
            // Network failure — use fallback so UI remains functional offline.
            availableClasses = FallbackSubject.allCases.map(\.asClassOption)
        }
    }

    /// Loads any existing DRAFT schedule and pre-populates picks.
    private func loadExistingDraft(client: SupabaseClient) async {
        guard let windowId = activeWindowId else { return }
        do {
            let resp = try await client
                .from("schedules")
                .select("id, state, picks_cipher")
                .eq("window_id", value: windowId)
                .limit(1)
                .execute()

            // Decode the row to get state.
            struct DraftRow: Decodable {
                let id: String
                let state: String
                let picks_cipher: String?   // base64 from Supabase when bytea is returned as JSON
            }
            let rows = (try? JSONDecoder().decode([DraftRow].self, from: resp.data)) ?? []
            guard let row = rows.first else { return }
            submitState = row.state

            // Attempt to re-hydrate picks from picks_cipher (plain JSON bytes for v1.0).
            if let b64 = row.picks_cipher,
               let data = Data(base64Encoded: b64),
               let decoded = try? JSONDecoder().decode([PersistedPick].self, from: data) {
                picks = decoded.map {
                    SchedulePick(id: UUID(), classId: $0.classId, period: $0.period, classTitle: $0.classTitle)
                }
            }
        } catch {
            // Non-fatal: student just starts fresh.
        }
    }
}

// MARK: - ScheduleBuilderBody

private struct ScheduleBuilderBody: View {
    @Binding var picks: [SchedulePick]
    @Binding var submitState: String

    let availableClasses: [ClassOption]
    let activeWindowId: String?

    @State private var submitting = false
    @State private var banner: String?
    @State private var bannerIsError = false

    private let periods = ["P1", "P2", "P3", "P4", "P5", "P6", "P7"]

    /// True when every period has a non-nil pick and state is still DRAFT.
    private var canSubmit: Bool {
        !submitting && submitState == "DRAFT" &&
        periods.allSatisfy { period in picks.contains(where: { $0.period == period }) }
    }

    var body: some View {
        List {
            Section("Periods") {
                ForEach(periods, id: \.self) { period in
                    PeriodPickerRow(
                        period: period,
                        availableClasses: availableClasses,
                        currentPick: picks.first(where: { $0.period == period }),
                        isLocked: submitState != "DRAFT",
                        onSelect: { selected in
                            applyPick(period: period, option: selected)
                        }
                    )
                }
            }

            if let banner {
                Section {
                    Label(banner, systemImage: bannerIsError ? "exclamationmark.circle" : "checkmark.circle")
                        .foregroundStyle(bannerIsError ? .red : .green)
                }
            }

            Section {
                Button(submitButtonTitle) {
                    Task { await submit() }
                }
                .disabled(!canSubmit)
            }
        }
    }

    private var submitButtonTitle: String {
        if submitting { return "Submitting…" }
        if submitState != "DRAFT" { return "Submitted for counselor review" }
        let remaining = periods.filter { period in !picks.contains(where: { $0.period == period }) }.count
        if remaining > 0 { return "Pick \(remaining) more class\(remaining == 1 ? "" : "es")" }
        return "Submit for counselor review"
    }

    private func applyPick(period: String, option: ClassOption) {
        if let idx = picks.firstIndex(where: { $0.period == period }) {
            picks[idx] = SchedulePick(classId: option.id, period: period, classTitle: option.title)
        } else {
            picks.append(SchedulePick(classId: option.id, period: period, classTitle: option.title))
        }
    }

    // MARK: - Submit

    private func submit() async {
        submitting = true
        banner = nil
        defer { submitting = false }

        guard let windowId = activeWindowId else {
            bannerIsError = true
            banner = "No active scheduling window found. Please try again."
            return
        }

        do {
            let client = SupabaseAuthService.shared.supabase
            let iso = ISO8601DateFormatter().string(from: Date())

            // Serialise picks to JSON bytes, then hex-encode for Supabase bytea.
            let persistedPicks = picks.map {
                PersistedPick(classId: $0.classId, period: $0.period, classTitle: $0.classTitle)
            }
            let picksData = try JSONEncoder().encode(persistedPicks)
            // Supabase accepts bytea as \x<hex> in text mode.
            let picksHex = "\\x" + picksData.map { String(format: "%02x", $0) }.joined()

            // Check for an existing schedule row for this window.
            let existingResp = try await client
                .from("schedules")
                .select("id, state")
                .eq("window_id", value: windowId)
                .limit(1)
                .execute()

            struct ExistingRow: Decodable { let id: String; let state: String }
            let existing = (try? JSONDecoder().decode([ExistingRow].self, from: existingResp.data)) ?? []

            let scheduleId: String
            if let row = existing.first {
                // UPDATE the existing row (DRAFT → SUBMITTED).
                struct UpdatePayload: Encodable {
                    let state: String
                    let submitted_at: String
                    let picks_cipher: String
                }
                try await client
                    .from("schedules")
                    .update(UpdatePayload(state: "SUBMITTED", submitted_at: iso, picks_cipher: picksHex))
                    .eq("id", value: row.id)
                    .execute()
                scheduleId = row.id
            } else {
                // INSERT a new row.
                struct InsertPayload: Encodable {
                    let window_id: String
                    let state: String
                    let submitted_at: String
                    let picks_cipher: String
                }
                struct InsertedRow: Decodable { let id: String }
                let resp = try await client
                    .from("schedules")
                    .insert(InsertPayload(
                        window_id: windowId,
                        state: "SUBMITTED",
                        submitted_at: iso,
                        picks_cipher: picksHex
                    ))
                    .select("id")
                    .execute()
                let inserted = try JSONDecoder().decode([InsertedRow].self, from: resp.data)
                guard let newId = inserted.first?.id else {
                    throw ScheduleSubmitError.missingInsertedId
                }
                scheduleId = newId
            }

            // Write the audit event.
            struct EventPayload: Encodable {
                let schedule_id: String
                let from_state: String?
                let to_state: String
            }
            _ = try? await client
                .from("schedule_events")
                .insert(EventPayload(
                    schedule_id: scheduleId,
                    from_state: existing.first != nil ? existing.first?.state : nil,
                    to_state: "SUBMITTED"
                ))
                .execute()

            submitState = "SUBMITTED"
            bannerIsError = false
            banner = "Submitted for counselor review."
        } catch {
            bannerIsError = true
            banner = "Couldn't save your schedule — \(error.localizedDescription). Please try again."
        }
    }
}

// MARK: - PeriodPickerRow

private struct PeriodPickerRow: View {
    let period: String
    let availableClasses: [ClassOption]
    let currentPick: SchedulePick?
    let isLocked: Bool
    let onSelect: (ClassOption) -> Void

    var body: some View {
        if isLocked {
            HStack {
                Text(period).font(.body.monospaced()).frame(width: 32, alignment: .leading)
                Spacer()
                Text(currentPick?.classTitle ?? "—").foregroundStyle(.primary)
            }
        } else {
            Menu {
                ForEach(availableClasses) { option in
                    Button(option.title) {
                        onSelect(option)
                    }
                }
            } label: {
                HStack {
                    Text(period).font(.body.monospaced()).frame(width: 32, alignment: .leading)
                    Spacer()
                    if let pick = currentPick {
                        Text(pick.classTitle)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Tap to pick a class")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Shared Codable types

/// Persisted shape written to / read from picks_cipher.
private struct PersistedPick: Codable {
    let classId: String
    let period: String
    let classTitle: String
}

// MARK: - Errors

private enum ScheduleSubmitError: LocalizedError {
    case missingInsertedId

    var errorDescription: String? {
        switch self {
        case .missingInsertedId:
            return "The server didn't return the new schedule ID."
        }
    }
}
