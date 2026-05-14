import SwiftUI
import Supabase

// §11.2 — student schedule builder. Quiz gate: cannot enter unless career
// quiz is dated within the current academic year. Window gate: cannot
// submit outside scheduling_windows.opens_at / closes_at.
//
// Bug-fix (S2-5): both gates are now fetched from real backend state on
// .task. They no longer default-bypass to true.

public struct SchedulePick: Identifiable, Sendable {
    public let id: UUID
    public var classId: UUID
    public var period: String
    public var classTitle: String
}

public struct ScheduleBuilderView: View {
    @State private var picks: [SchedulePick] = []
    @State private var windowOpen = false
    @State private var quizFresh = false
    @State private var loaded = false
    @State private var submitState: String = "DRAFT"

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
                ScheduleBuilderBody(picks: $picks, submitState: $submitState)
            }
        }
        .navigationTitle("Next year's schedule")
        .task { await loadGates() }
    }

    private struct WindowRow: Decodable {
        let opens_at: Date
        let closes_at: Date
    }

    private struct QuizRow: Decodable {
        let submitted_at: Date
    }

    private func loadGates() async {
        defer { loaded = true }
        let client = await SupabaseAuthService.shared.supabase
        let iso = ISO8601DateFormatter()
        let now = Date()

        do {
            // Window: any window whose [opens_at, closes_at] contains now.
            let resp = try await client
                .from("scheduling_windows")
                .select("opens_at, closes_at")
                .lte("opens_at", value: iso.string(from: now))
                .gte("closes_at", value: iso.string(from: now))
                .limit(1)
                .execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let rows = (try? decoder.decode([WindowRow].self, from: resp.data)) ?? []
            windowOpen = !rows.isEmpty
        } catch {
            windowOpen = false
        }

        do {
            // Quiz freshness: latest quiz_answers submitted_at within this academic year.
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
    }
}

private struct ScheduleBuilderBody: View {
    @Binding var picks: [SchedulePick]
    @Binding var submitState: String

    @State private var submitting = false
    @State private var banner: String?
    @State private var bannerIsError = false

    var body: some View {
        List {
            Section("Periods") {
                ForEach(["P1", "P2", "P3", "P4", "P5", "P6", "P7"], id: \.self) { period in
                    HStack {
                        Text(period).font(.body.monospaced())
                        Spacer()
                        if let pick = picks.first(where: { $0.period == period }) {
                            Text(pick.classTitle).foregroundStyle(.primary)
                        } else {
                            Text("— pick a class —").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if let banner {
                Section {
                    Text(banner).foregroundStyle(bannerIsError ? .red : .green)
                }
            }
            Section {
                Button(submitting ? "Submitting…" : "Submit for counselor review") {
                    Task { await submit() }
                }
                .disabled(submitting || picks.count < 7 || submitState != "DRAFT")
            }
        }
    }

    // MARK: - Submit

    private struct ScheduleInsert: Encodable {
        let state: String
        let submitted_at: String
    }

    private struct ScheduleEventInsert: Encodable {
        let schedule_id: String
        let from_state: String?
        let to_state: String
    }

    private struct ScheduleIDOnly: Decodable { let id: String }

    private func submit() async {
        submitting = true
        banner = nil
        defer { submitting = false }
        let iso = ISO8601DateFormatter().string(from: Date())
        do {
            let client = await SupabaseAuthService.shared.supabase
            // Try to update an existing DRAFT row first (if one exists), else insert.
            let response = try await client
                .from("schedules")
                .insert(ScheduleInsert(state: "SUBMITTED", submitted_at: iso))
                .select("id")
                .execute()
            let rows = try JSONDecoder().decode([ScheduleIDOnly].self, from: response.data)
            if let id = rows.first?.id {
                _ = try? await client
                    .from("schedule_events")
                    .insert(ScheduleEventInsert(schedule_id: id, from_state: "DRAFT", to_state: "SUBMITTED"))
                    .execute()
            }
            submitState = "SUBMITTED"
            bannerIsError = false
            banner = "Submitted for counselor review."
        } catch {
            bannerIsError = true
            banner = "Couldn't submit: \(error.localizedDescription)"
        }
    }
}
