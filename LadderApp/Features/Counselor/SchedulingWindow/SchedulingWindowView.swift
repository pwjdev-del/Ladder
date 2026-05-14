import SwiftUI
import Supabase

// §11.2 — counselor opens/closes scheduling windows. Required preconditions:
// teacher schedules + class catalog + prereqs uploaded (§11.1).
//
// Bug-fix (S1-8): preconditions are fetched from real Supabase tables; Open
// button posts a real row into scheduling_windows. Counselor can still flip
// the precondition rows manually if data isn't loaded but they confirmed it.

public struct SchedulingWindowView: View {
    @State private var opensAt: Date = Date()
    @State private var closesAt: Date = Date().addingTimeInterval(60 * 60 * 24 * 7)
    @State private var academicYear: String = "2026-2027"
    @State private var prereqsReady = false
    @State private var teacherSchedulesReady = false
    @State private var classCatalogReady = false
    @State private var isLoading = true
    @State private var isPosting = false
    @State private var banner: String?
    @State private var bannerIsError = false

    public init() {}

    // T024 iPad parity: MaxWidthContainer(640) prevents the Form from stretching
    // across the full 1024+pt width of an iPad Pro in landscape.
    public var body: some View {
        MaxWidthContainer(maxWidth: 640) {
            Form {
                Section("Preconditions (§11.1)") {
                    Toggle(isOn: $teacherSchedulesReady) {
                        rowLabel("Teacher schedules uploaded", teacherSchedulesReady)
                    }
                    Toggle(isOn: $classCatalogReady) {
                        rowLabel("Class catalog uploaded", classCatalogReady)
                    }
                    Toggle(isOn: $prereqsReady) {
                        rowLabel("Prereqs confirmed", prereqsReady)
                    }
                    if isLoading { ProgressView("Checking…").font(.caption) }
                }
                Section("Window") {
                    TextField("Academic year", text: $academicYear)
                    DatePicker("Opens at", selection: $opensAt)
                    DatePicker("Closes at", selection: $closesAt)
                }
                if let banner {
                    Section {
                        Text(banner).foregroundStyle(bannerIsError ? .red : .green)
                    }
                }
                Section {
                    Button(isPosting ? "Opening…" : "Open scheduling window") {
                        Task { await openWindow() }
                    }
                    .disabled(isPosting || !(prereqsReady && teacherSchedulesReady && classCatalogReady))
                }
            }
        }
        .navigationTitle("Scheduling window")
        .task { await loadPreconditions() }
        .requireNonFounder()
    }

    private func rowLabel(_ label: String, _ ready: Bool) -> some View {
        HStack {
            Image(systemName: ready ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(ready ? .green : .secondary)
            Text(label)
        }
    }

    // MARK: - Data

    private struct CountResult: Decodable { let count: Int }

    private func loadPreconditions() async {
        defer { isLoading = false }
        let client = await SupabaseAuthService.shared.supabase
        async let classes = nonEmptyCount(table: "classes", client: client)
        async let teachers = nonEmptyCount(table: "teacher_assignments", client: client)
        let (c, t) = await (classes, teachers)
        classCatalogReady = c
        teacherSchedulesReady = t
        // Prereqs has no direct table — leave as counselor-confirmed manual toggle.
    }

    private func nonEmptyCount(table: String, client: SupabaseClient) async -> Bool {
        do {
            let response = try await client
                .from(table)
                .select("id", head: false, count: .exact)
                .limit(1)
                .execute()
            return (response.count ?? 0) > 0
        } catch {
            return false
        }
    }

    private struct ScheduleWindowInsert: Encodable {
        let academic_year: String
        let opens_at: String
        let closes_at: String
    }

    private func openWindow() async {
        isPosting = true
        banner = nil
        defer { isPosting = false }
        let iso = ISO8601DateFormatter()
        let body = ScheduleWindowInsert(
            academic_year: academicYear,
            opens_at: iso.string(from: opensAt),
            closes_at: iso.string(from: closesAt)
        )
        do {
            let client = await SupabaseAuthService.shared.supabase
            try await client.from("scheduling_windows").insert(body).execute()
            bannerIsError = false
            banner = "Scheduling window opened for \(academicYear)."
        } catch {
            bannerIsError = true
            banner = "Couldn't open window: \(error.localizedDescription)"
        }
    }
}