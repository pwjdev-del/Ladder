import SwiftUI
import SwiftData

// MARK: - Financial Aid Comparison View

struct FinancialAidComparisonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var packages: [FinancialAidPackageModel] = []
    @State private var showingAddSheet = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Financial Aid Comparison")
                                .font(LadderTypography.headlineSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Compare aid packages side-by-side")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        Spacer()
                        Button { showingAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }

                    if packages.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "banknote")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("Add financial aid packages to compare")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            LadderPrimaryButton("Add Package", icon: "plus") {
                                showingAddSheet = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        // Best value highlight
                        if let best = packages.min(by: { $0.netCost < $1.netCost }) {
                            LadderCard {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(LadderColors.secondaryFixed)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Best Value")
                                            .font(LadderTypography.labelSmall)
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                        Text(best.collegeName)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                    Spacer()
                                    Text("$\(best.netCost.formatted())/yr")
                                        .font(LadderTypography.titleMedium)
                                        .foregroundStyle(LadderColors.primary)
                                }
                            }
                        }

                        // Package cards
                        ForEach(packages, id: \.collegeName) { pkg in
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                    Text(pkg.collegeName)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)

                                    // Cost bars
                                    costRow("Tuition", pkg.tuitionCost, .red.opacity(0.6))
                                    costRow("Room & Board", pkg.roomBoardCost, .orange.opacity(0.6))
                                    costRow("Grants & Scholarships", -pkg.totalAid, LadderColors.primary)
                                    costRow("Loans", pkg.loanAmount, .yellow.opacity(0.6))

                                    // Net cost
                                    HStack {
                                        Text("Net Cost")
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        Spacer()
                                        Text("$\(pkg.netCost.formatted())")
                                            .font(LadderTypography.headlineSmall)
                                            .foregroundStyle(pkg.netCost < 15000 ? LadderColors.primary : LadderColors.onSurface)
                                    }
                                    .padding(.top, LadderSpacing.xs)
                                }
                            }
                        }
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAidPackageSheet { pkg in
                context.insert(pkg)
                try? context.save()
                loadPackages()
            }
        }
        .task { loadPackages() }
    }

    @ViewBuilder
    private func costRow(_ label: String, _ amount: Int, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(amount < 0 ? "-$\(abs(amount).formatted())" : "$\(amount.formatted())")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(amount < 0 ? LadderColors.primary : LadderColors.onSurface)
        }
    }

    private func loadPackages() {
        let descriptor = FetchDescriptor<FinancialAidPackageModel>(sortBy: [SortDescriptor(\.createdAt)])
        packages = (try? context.fetch(descriptor)) ?? []
    }
}

struct AddAidPackageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var tuition = ""
    @State private var roomBoard = ""
    @State private var grants = ""
    @State private var scholarships = ""
    @State private var loans = ""
    let onSave: (FinancialAidPackageModel) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: LadderSpacing.md) {
                        LadderTextField("College Name", text: $name)
                        LadderTextField("Tuition ($)", text: $tuition).keyboardType(.numberPad)
                        LadderTextField("Room & Board ($)", text: $roomBoard).keyboardType(.numberPad)
                        LadderTextField("Grants ($)", text: $grants).keyboardType(.numberPad)
                        LadderTextField("Scholarships ($)", text: $scholarships).keyboardType(.numberPad)
                        LadderTextField("Loans ($)", text: $loans).keyboardType(.numberPad)

                        LadderPrimaryButton("Save Package", icon: "checkmark") {
                            let pkg = FinancialAidPackageModel(collegeId: name, collegeName: name)
                            pkg.tuitionCost = Int(tuition) ?? 0
                            pkg.roomBoardCost = Int(roomBoard) ?? 0
                            pkg.grantAid = Int(grants) ?? 0
                            pkg.scholarshipAid = Int(scholarships) ?? 0
                            pkg.loanAmount = Int(loans) ?? 0
                            onSave(pkg)
                            dismiss()
                        }
                        .disabled(name.isEmpty)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationTitle("Add Aid Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
