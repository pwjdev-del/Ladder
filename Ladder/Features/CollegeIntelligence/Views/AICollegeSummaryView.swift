import SwiftUI
import SwiftData

// MARK: - AI College Summary View

struct AICollegeSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let collegeId: String

    @State private var viewModel: AICollegeSummaryViewModel
    @State private var showShareSheet = false

    init(collegeId: String) {
        self.collegeId = collegeId
        self._viewModel = State(initialValue: AICollegeSummaryViewModel(collegeId: collegeId))
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: LadderSpacing.md) {
                    ProgressView()
                        .tint(LadderColors.primary)
                    Text("Generating summary...")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            } else {
                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // Hero header
                        if let college = viewModel.college {
                            CollegeGradientHero(name: college.name, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                                .overlay(alignment: .bottomLeading) {
                                    HStack(spacing: LadderSpacing.md) {
                                        CollegeLogoView(college.name, websiteURL: college.websiteURL, size: 48, cornerRadius: 12)
                                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                                            Text(college.name)
                                                .font(LadderTypography.headlineSmall)
                                                .foregroundStyle(.white)
                                            if let city = college.city, let state = college.state {
                                                Text("\(city), \(state)")
                                                    .font(LadderTypography.bodySmall)
                                                    .foregroundStyle(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                    .padding(LadderSpacing.lg)
                                }
                        }

                        // Summary sections
                        ForEach(viewModel.sections) { section in
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                    HStack(spacing: LadderSpacing.sm) {
                                        Image(systemName: section.icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(LadderColors.primary)
                                        Text(section.title)
                                            .font(LadderTypography.titleMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }

                                    Text(section.body)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .lineSpacing(4)
                                }
                            }
                        }

                        // Share button
                        LadderPrimaryButton("Share Summary", icon: "square.and.arrow.up") {
                            showShareSheet = true
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("College Summary")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [viewModel.shareText()])
        }
        .task { viewModel.loadData(context: context) }
    }
}

// ShareSheet is defined in CounselorImpactReportView.swift and reused here
