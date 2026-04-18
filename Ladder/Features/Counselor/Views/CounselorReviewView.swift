import SwiftUI

// MARK: - Counselor Review View
// Student submits a star rating and review for a counselor

struct CounselorReviewView: View {
    @Environment(\.dismiss) private var dismiss
    let counselorName: String
    let counselorId: String

    @State private var starRating: Int = 0
    @State private var selectedTags: Set<String> = []
    @State private var reviewText = ""
    @State private var showConfirmation = false

    private let helpfulTags = ["Essay Review", "Test Strategy", "College Selection", "Financial Aid", "Encouragement"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {

                    // Counselor header
                    VStack(spacing: LadderSpacing.md) {
                        Circle()
                            .fill(LadderColors.primaryContainer)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Text(String(counselorName.split(separator: " ").last?.prefix(1) ?? "?"))
                                    .font(LadderTypography.headlineMedium)
                                    .foregroundStyle(.white)
                            }

                        Text("How was your session with \(counselorName)?")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LadderSpacing.xl)

                    // Star rating
                    VStack(spacing: LadderSpacing.sm) {
                        Text("Rating")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        HStack(spacing: LadderSpacing.md) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        starRating = star
                                    }
                                } label: {
                                    Image(systemName: star <= starRating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundStyle(star <= starRating ? .orange : LadderColors.outlineVariant)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if starRating > 0 {
                            Text(ratingLabel)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    // Helpful tags
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("What was helpful?")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        FlowLayout(spacing: LadderSpacing.sm) {
                            ForEach(helpfulTags, id: \.self) { tag in
                                Button {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                } label: {
                                    Text(tag)
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(selectedTags.contains(tag) ? .white : LadderColors.onSurfaceVariant)
                                        .padding(.horizontal, LadderSpacing.md)
                                        .padding(.vertical, LadderSpacing.sm)
                                        .background(selectedTags.contains(tag) ? LadderColors.primary : LadderColors.surfaceContainerLow)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Written review
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Written Review (Optional)")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        TextEditor(text: $reviewText)
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                if reviewText.isEmpty {
                                    Text("Share your experience...")
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                                        .padding(LadderSpacing.md)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    // Submit button
                    LadderPrimaryButton("Submit Review", icon: "paperplane.fill") {
                        saveReview()
                        showConfirmation = true
                    }
                    .opacity(starRating > 0 ? 1.0 : 0.4)
                    .disabled(starRating == 0)

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
                Text("Write a Review")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .alert("Review Submitted", isPresented: $showConfirmation) {
            Button("Done") { dismiss() }
        } message: {
            Text("Thank you for your feedback. Your review helps other students find the right counselor.")
        }
    }

    private var ratingLabel: String {
        switch starRating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent"
        default: return ""
        }
    }

    private func saveReview() {
        let review: [String: Any] = [
            "counselorId": counselorId,
            "counselorName": counselorName,
            "rating": starRating,
            "tags": Array(selectedTags),
            "text": reviewText,
            "date": Date().timeIntervalSince1970
        ]
        let key = "ladder_reviews_\(counselorId)"
        var reviews = UserDefaults.standard.array(forKey: key) as? [[String: Any]] ?? []
        reviews.append(review)
        UserDefaults.standard.set(reviews, forKey: key)
    }
}

// FlowLayout is defined in OnboardingContainerView.swift and reused here
