import SwiftUI

// MARK: - Class Catalog Upload View
// Admin uploads school's class catalog via table input

struct ClassCatalogUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var classes: [CatalogClass] = []
    @State private var showClearConfirmation = false
    @State private var showSaveConfirmation = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Class Catalog")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Add your school's available classes")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Class count
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundStyle(LadderColors.primary)
                        Text("\(classes.count) Classes")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

                    // Class entries
                    ForEach(Array(classes.enumerated()), id: \.element.id) { index, _ in
                        classEntryCard(index: index)
                    }

                    // Add class button
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            classes.append(CatalogClass())
                        }
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Add Class")
                                .font(LadderTypography.titleSmall)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.lg)
                        .background(LadderColors.primaryContainer.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    // Save button
                    if !classes.isEmpty {
                        LadderPrimaryButton("Save Catalog", icon: "checkmark.circle") {
                            saveCatalog()
                            showSaveConfirmation = true
                        }

                        // Clear button
                        Button {
                            showClearConfirmation = true
                        } label: {
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Clear Catalog")
                                    .font(LadderTypography.titleSmall)
                            }
                            .foregroundStyle(LadderColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LadderSpacing.md)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Class Catalog")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear { loadCatalog() }
        .alert("Catalog Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(classes.count) classes saved to your school's catalog.")
        }
        .alert("Clear Catalog?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                classes.removeAll()
                UserDefaults.standard.removeObject(forKey: "ladder_class_catalog")
            }
        } message: {
            Text("This will remove all classes from the catalog. This action cannot be undone.")
        }
    }

    // MARK: - Class Entry Card

    private func classEntryCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text("Class \(index + 1)")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        _ = classes.remove(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            catalogField("Class Name", text: $classes[index].name)

            HStack(spacing: LadderSpacing.sm) {
                catalogField("Period", text: $classes[index].period)
                catalogField("Capacity", text: $classes[index].capacity)
            }

            catalogField("Teacher", text: $classes[index].teacher)
            catalogField("Subject Area", text: $classes[index].subjectArea)

            HStack(spacing: LadderSpacing.md) {
                Toggle(isOn: $classes[index].isAP) {
                    Text("AP")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))

                Toggle(isOn: $classes[index].isHonors) {
                    Text("Honors")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
                .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func catalogField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(LadderTypography.bodyMedium)
            .foregroundStyle(LadderColors.onSurface)
            .padding(LadderSpacing.sm)
            .background(LadderColors.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
    }

    // MARK: - Persistence

    private func saveCatalog() {
        let encoded = classes.map { c in
            [
                "name": c.name,
                "period": c.period,
                "teacher": c.teacher,
                "capacity": c.capacity,
                "isAP": c.isAP ? "true" : "false",
                "isHonors": c.isHonors ? "true" : "false",
                "subjectArea": c.subjectArea
            ]
        }
        UserDefaults.standard.set(encoded, forKey: "ladder_class_catalog")
    }

    private func loadCatalog() {
        guard let saved = UserDefaults.standard.array(forKey: "ladder_class_catalog") as? [[String: String]] else { return }
        classes = saved.map { dict in
            var c = CatalogClass()
            c.name = dict["name"] ?? ""
            c.period = dict["period"] ?? ""
            c.teacher = dict["teacher"] ?? ""
            c.capacity = dict["capacity"] ?? ""
            c.isAP = dict["isAP"] == "true"
            c.isHonors = dict["isHonors"] == "true"
            c.subjectArea = dict["subjectArea"] ?? ""
            return c
        }
    }
}

// MARK: - Catalog Class Model

struct CatalogClass: Identifiable {
    let id = UUID()
    var name: String = ""
    var period: String = ""
    var teacher: String = ""
    var capacity: String = ""
    var isAP: Bool = false
    var isHonors: Bool = false
    var subjectArea: String = ""
}
