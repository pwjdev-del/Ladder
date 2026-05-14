import SwiftUI
import Supabase

// §5 — admin-only teacher profiles. List of teachers + add flow.
//
// Bug-fix (S2-9): "+" button now opens a sheet to add a teacher (first/last
// name + teaching style tags). Teachers persist to teacher_profiles via
// Supabase. List reloads on appear.
//
// iPad parity (T026): AdaptiveContainer — teacher list in primary column,
// per-teacher detail in detail column. iPhone: nav-push unchanged.

public struct TeacherProfilesView: View {
    @State private var teachers: [TeacherRow] = []
    @State private var showingAdd = false
    @State private var error: String?
    @State private var loading = true
    @State private var selectedTeacher: TeacherRow?

    public init() {}

    public var body: some View {
        AdaptiveContainer(primaryMaxWidth: 360) {
            teacherList
        } detail: {
            if let teacher = selectedTeacher {
                TeacherDetailPane(teacher: teacher)
            } else {
                ContentUnavailableView(
                    "Select a teacher",
                    systemImage: "person.2.fill",
                    description: Text("Choose a teacher from the list to view details.")
                )
            }
        }
        .navigationTitle("Teachers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddTeacherSheet { added in
                teachers.append(added)
                showingAdd = false
            }
        }
        .task { await load() }
        .refreshable { await load() }
        .requireNonFounder()
    }

    // MARK: - Teacher list (primary pane)

    @ViewBuilder
    private var teacherList: some View {
        List(selection: $selectedTeacher) {
            if let error { Section { Text(error).foregroundStyle(.red) } }

            if teachers.isEmpty && !loading {
                ContentUnavailableView(
                    "No teachers yet",
                    systemImage: "person.2.fill",
                    description: Text("Admin-only per §5. Add a teacher to populate schedules and reviews.")
                )
            } else {
                ForEach(teachers) { t in
                    NavigationLink(value: t) {
                        VStack(alignment: .leading) {
                            Text(t.displayName).font(.headline)
                            if !t.teachingStyleTags.isEmpty {
                                Text(t.teachingStyleTags.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tag(t)
                }
            }
            if loading { Section { ProgressView() } }
        }
        .navigationDestination(for: TeacherRow.self) { teacher in
            // iPhone only: push a detail view when List selection navigates
            TeacherDetailPane(teacher: teacher)
        }
    }

    // MARK: - Data

    public struct TeacherRow: Identifiable, Hashable, Sendable, Decodable {
        public let id: UUID
        public let firstName: String?
        public let lastName: String?
        public let teachingStyleTags: [String]

        public var displayName: String {
            [firstName, lastName].compactMap { $0 }.joined(separator: " ").nonEmpty ?? "Unnamed teacher"
        }

        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case teachingStyleTags = "teaching_style_tags"
        }
    }

    private func load() async {
        loading = true
        error = nil
        defer { loading = false }
        do {
            let client = await SupabaseAuthService.shared.supabase
            let response = try await client
                .rpc("list_teacher_profiles")
                .execute()
            let decoder = JSONDecoder()
            teachers = try decoder.decode([TeacherRow].self, from: response.data)
        } catch {
            self.error = "Couldn't load teachers: \(error.localizedDescription)"
        }
    }
}

// MARK: - Teacher Detail Pane

private struct TeacherDetailPane: View {
    let teacher: TeacherProfilesView.TeacherRow

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                // Avatar + name header
                HStack(spacing: LadderSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(LadderColors.primaryContainer.opacity(0.4))
                            .frame(width: 64, height: 64)
                        Text(initials)
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.primary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(teacher.displayName)
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Teacher")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(LadderSpacing.lg)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                // Style tags
                if !teacher.teachingStyleTags.isEmpty {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Teaching Style")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        FlowLayout(spacing: LadderSpacing.sm) {
                            ForEach(teacher.teachingStyleTags, id: \.self) { tag in
                                Text(tag)
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.primary)
                                    .padding(.horizontal, LadderSpacing.sm)
                                    .padding(.vertical, 4)
                                    .background(LadderColors.primaryContainer.opacity(0.3))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .background(LadderColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                }
            }
            .padding(LadderSpacing.lg)
        }
        .navigationTitle(teacher.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(LadderColors.surface.ignoresSafeArea())
    }

    private var initials: String {
        let parts = [teacher.firstName?.prefix(1), teacher.lastName?.prefix(1)]
        return parts.compactMap { $0.map(String.init) }.joined()
    }
}

// MARK: - Add Teacher Sheet

private struct AddTeacherSheet: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var styleTags = ""
    @State private var saving = false
    @State private var error: String?
    let onAdded: (TeacherProfilesView.TeacherRow) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }
                Section("Teaching style tags (comma-separated)") {
                    TextField("e.g., hands-on, lecture, project-based", text: $styleTags)
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
            }
            .navigationTitle("Add teacher")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(saving ? "Saving…" : "Save") {
                        Task { await save() }
                    }
                    .disabled(saving || firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }

    private struct TeacherInsertParams: Encodable {
        let p_first_name: String
        let p_last_name: String
        let p_tags: [String]
    }

    private struct InsertedTeacher: Decodable {
        let id: UUID
    }

    private func save() async {
        saving = true
        error = nil
        defer { saving = false }
        let tags = styleTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        do {
            let client = await SupabaseAuthService.shared.supabase
            let response = try await client
                .rpc("add_teacher_profile", params: TeacherInsertParams(
                    p_first_name: firstName,
                    p_last_name: lastName,
                    p_tags: tags
                ))
                .execute()
            let inserted = try JSONDecoder().decode([InsertedTeacher].self, from: response.data).first
            let id = inserted?.id ?? UUID()
            onAdded(TeacherProfilesView.TeacherRow(
                id: id,
                firstName: firstName,
                lastName: lastName,
                teachingStyleTags: tags
            ))
        } catch {
            self.error = "Couldn't save: \(error.localizedDescription)"
        }
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
