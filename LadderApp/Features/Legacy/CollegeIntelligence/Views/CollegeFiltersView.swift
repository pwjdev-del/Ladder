import SwiftUI

// MARK: - Advanced College Filters

struct CollegeFiltersView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedState = "All"
    @State private var tuitionRange: ClosedRange<Double> = 0...80000
    @State private var acceptanceRange: ClosedRange<Double> = 0...100
    @State private var enrollmentMin: Double = 0
    @State private var testPolicy = "All"
    @State private var institutionType = "All"
    @State private var hbcuOnly = false
    @State private var cssRequired = false

    let states = ["All", "FL", "CA", "NY", "TX", "PA", "OH", "IL", "NC", "GA", "VA", "MA", "MI", "NJ"]
    let testPolicies = ["All", "Test-Required", "Test-Optional", "Test-Blind"]
    let institutionTypes = ["All", "Public", "Private nonprofit", "Private for-profit"]

    var onApply: ((FilterCriteria) -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // State
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("State").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: LadderSpacing.xs) {
                                        ForEach(states, id: \.self) { state in
                                            LadderFilterChip(title: state, isSelected: selectedState == state) {
                                                selectedState = state
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Tuition
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Tuition Range").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                                Text("$\(Int(tuitionRange.lowerBound).formatted()) – $\(Int(tuitionRange.upperBound).formatted())")
                                    .font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                                // Simple slider for max tuition
                                Slider(value: Binding(
                                    get: { tuitionRange.upperBound },
                                    set: { tuitionRange = tuitionRange.lowerBound...$0 }
                                ), in: 0...80000, step: 1000)
                                .tint(LadderColors.primary)
                            }
                        }

                        // Test Policy
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Testing Policy").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: LadderSpacing.xs) {
                                        ForEach(testPolicies, id: \.self) { policy in
                                            LadderFilterChip(title: policy, isSelected: testPolicy == policy) {
                                                testPolicy = policy
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Institution Type
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Institution Type").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                                ForEach(institutionTypes, id: \.self) { type in
                                    LadderFilterChip(title: type, isSelected: institutionType == type) {
                                        institutionType = type
                                    }
                                }
                            }
                        }

                        // Toggles
                        LadderCard {
                            VStack(spacing: LadderSpacing.md) {
                                Toggle("HBCU Only", isOn: $hbcuOnly)
                                    .font(LadderTypography.bodyMedium)
                                    .tint(LadderColors.primary)
                                Toggle("CSS Profile Required", isOn: $cssRequired)
                                    .font(LadderTypography.bodyMedium)
                                    .tint(LadderColors.primary)
                            }
                        }

                        LadderPrimaryButton("Apply Filters", icon: "line.3.horizontal.decrease") {
                            let criteria = FilterCriteria(
                                state: selectedState == "All" ? nil : selectedState,
                                maxTuition: Int(tuitionRange.upperBound),
                                testPolicy: testPolicy == "All" ? nil : testPolicy,
                                institutionType: institutionType == "All" ? nil : institutionType,
                                hbcuOnly: hbcuOnly,
                                cssRequired: cssRequired
                            )
                            onApply?(criteria)
                            dismiss()
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        selectedState = "All"
                        tuitionRange = 0...80000
                        testPolicy = "All"
                        institutionType = "All"
                        hbcuOnly = false
                        cssRequired = false
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }
}

struct FilterCriteria {
    var state: String?
    var maxTuition: Int?
    var testPolicy: String?
    var institutionType: String?
    var hbcuOnly: Bool
    var cssRequired: Bool
}
