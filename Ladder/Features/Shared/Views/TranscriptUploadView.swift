import SwiftUI
import PhotosUI

// MARK: - Transcript Upload View
// Students upload their official transcript (PDF or photo).
// Gemini Vision (via Edge Function) parses courses + grades → populates profile.

struct TranscriptUploadView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var uploadState: UploadState = .idle
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var parsedCourses: [ParsedCourse] = []
    @State private var showDocumentPicker = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    headerCard
                    uploadArea
                    if case .parsed = uploadState {
                        parsedResultsSection
                    }
                    howItWorksSection
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
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
                Text("Upload Transcript")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .photosPicker(isPresented: .constant(uploadState == .choosingPhoto),
                      selection: $selectedPhoto,
                      matching: .images)
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await loadPhoto(item) }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle().fill(LadderColors.accentLime.opacity(0.15)).frame(width: 48, height: 48)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundStyle(LadderColors.accentLime)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Transcript Analysis")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("Upload your transcript and we'll automatically build your academic profile — GPA, courses, and class recommendations.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }

    // MARK: - Upload Area

    private var uploadArea: some View {
        VStack(spacing: LadderSpacing.md) {
            switch uploadState {
            case .idle:
                idleUploadArea

            case .choosingPhoto, .choosingFile:
                // PhotosPicker handles UI
                idleUploadArea

            case .uploading:
                uploadingIndicator

            case .parsing:
                parsingIndicator

            case .parsed:
                previewSection

            case .error(let msg):
                errorView(msg)
            }
        }
    }

    private var idleUploadArea: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Drop zone
            VStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.25))
                        .frame(width: 80, height: 80)
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(LadderColors.primary)
                }
                Text("Upload Your Transcript")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("PDF, photo, or screenshot — we'll handle the rest")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.xxxxl)
            .background(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(LadderColors.outlineVariant.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .background(LadderColors.surfaceContainerLow.clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)))
            )

            // Action buttons
            HStack(spacing: LadderSpacing.md) {
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Label("Photo / Screenshot", systemImage: "photo.fill")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primaryContainer.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }

                Button {
                    uploadState = .choosingFile
                    // In production: use UIDocumentPickerViewController via sheet
                    simulatePDFUpload()
                } label: {
                    Label("PDF File", systemImage: "doc.fill")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primaryContainer.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                }
            }
        }
    }

    private var uploadingIndicator: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(LadderColors.primary)
                Text("Uploading transcript...")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text("This only takes a moment")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.xl)
        }
    }

    private var parsingIndicator: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.accentLime.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(LadderColors.accentLime)
                        .symbolEffect(.pulse)
                }
                Text("AI is analyzing your transcript")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Extracting courses, grades, and GPA...")
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                ProgressView(value: 0.6)
                    .tint(LadderColors.accentLime)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.xl)
        }
    }

    private var previewSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(LadderColors.accentLime)
                    Text("Transcript uploaded")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Button {
                        uploadState = .idle
                        previewImage = nil
                        parsedCourses = []
                    } label: {
                        Text("Replace")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.primary)
                    }
                }
                if let img = previewImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                }
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        LadderCard {
            VStack(spacing: LadderSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(LadderColors.error)
                Text("Upload failed")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(message)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                Button {
                    uploadState = .idle
                } label: {
                    Text("Try Again")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.primary)
                }
                .padding(.top, LadderSpacing.xs)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.md)
        }
    }

    // MARK: - Parsed Results

    private var parsedResultsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack {
                Text("DETECTED COURSES")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()
                Spacer()
                Text("\(parsedCourses.count) courses found")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
            }

            // GPA summary
            LadderCard {
                HStack(spacing: LadderSpacing.lg) {
                    VStack(spacing: 4) {
                        Text("3.78")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.accentLime)
                        Text("GPA").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    VStack(spacing: 4) {
                        Text("4.12")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.primary)
                        Text("Weighted").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    VStack(spacing: 4) {
                        Text("24")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Credits").font(LadderTypography.labelSmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Grade 10")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Sophomore")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }

            // Course list
            ForEach(parsedCourses) { course in
                courseRow(course)
            }

            // Recommendation row
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "lightbulb.fill").foregroundStyle(LadderColors.accentLime)
                        Text("Course Recommendations").font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                    }
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        recommendationRow("Take AP Physics next year — strengthens your STEM profile", icon: "atom")
                        recommendationRow("Add AP Statistics to demonstrate quantitative ability", icon: "chart.bar")
                        recommendationRow("Your math trajectory is excellent — consider AP Calculus BC", icon: "function")
                    }
                }
            }

            // Save button
            LadderPrimaryButton("Save to My Profile", icon: "checkmark") {
                // In production: call SupabaseManager to persist parsed profile data
                dismiss()
            }
        }
    }

    private func courseRow(_ course: ParsedCourse) -> some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous)
                    .fill(gradeColor(course.grade).opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(course.grade)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(gradeColor(course.grade))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                HStack(spacing: LadderSpacing.xs) {
                    Text(course.year).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    if course.isAP {
                        Text("AP")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(LadderColors.primary)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
            Text("\(course.credits) cr")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func recommendationRow(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 16)
            Text(text)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurface)
        }
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "info.circle.fill").foregroundStyle(LadderColors.accentLime)
                    Text("How It Works").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                }
                stepRow("1", title: "Upload your transcript", detail: "Use a PDF export from your student portal, or take a clear photo.")
                stepRow("2", title: "AI extracts your data", detail: "Gemini AI reads your courses, grades, credits, and GPA automatically.")
                stepRow("3", title: "Review and confirm", detail: "Check the results, correct anything, then save to your profile.")
                stepRow("4", title: "Get personalized advice", detail: "Your advisor and college match scores update based on your actual record.")

                HStack(spacing: LadderSpacing.xs) {
                    Image(systemName: "lock.fill").font(.system(size: 11)).foregroundStyle(LadderColors.onSurfaceVariant)
                    Text("Your transcript is processed privately and never shared with colleges.")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.top, LadderSpacing.xs)
            }
        }
    }

    private func stepRow(_ number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: LadderSpacing.md) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 24, height: 24)
                .background(LadderColors.primaryContainer.opacity(0.35))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                Text(detail).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    // MARK: - Helpers

    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A", "A+": return LadderColors.accentLime
        case "A-":      return LadderColors.accentLime
        case "B+", "B": return LadderColors.primary
        case "B-":      return LadderColors.primary
        default:        return Color.orange
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem) async {
        uploadState = .uploading
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                await MainActor.run { previewImage = img }
            }
        } catch {}
        await MainActor.run { uploadState = .parsing }
        // Simulate Gemini parsing delay (replace with real Edge Function call)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            parsedCourses = ParsedCourse.sampleCourses
            uploadState = .parsed
        }
    }

    private func simulatePDFUpload() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run { uploadState = .uploading }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run { uploadState = .parsing }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                parsedCourses = ParsedCourse.sampleCourses
                uploadState = .parsed
            }
        }
    }

    // MARK: - Upload State

    enum UploadState: Equatable {
        case idle
        case choosingPhoto
        case choosingFile
        case uploading
        case parsing
        case parsed
        case error(String)
    }
}

// MARK: - Parsed Course Model

struct ParsedCourse: Identifiable {
    let id = UUID()
    let name: String
    let grade: String
    let credits: Double
    let year: String
    let isAP: Bool

    static var sampleCourses: [ParsedCourse] {
        [
            ParsedCourse(name: "AP English Language", grade: "A", credits: 1.0, year: "Grade 10", isAP: true),
            ParsedCourse(name: "Honors Pre-Calculus", grade: "A-", credits: 1.0, year: "Grade 10", isAP: false),
            ParsedCourse(name: "AP World History", grade: "B+", credits: 1.0, year: "Grade 10", isAP: true),
            ParsedCourse(name: "Honors Biology", grade: "A", credits: 1.0, year: "Grade 10", isAP: false),
            ParsedCourse(name: "Spanish III", grade: "A-", credits: 1.0, year: "Grade 10", isAP: false),
            ParsedCourse(name: "AP Computer Science Principles", grade: "A", credits: 1.0, year: "Grade 10", isAP: true),
            ParsedCourse(name: "English I", grade: "A", credits: 1.0, year: "Grade 9", isAP: false),
            ParsedCourse(name: "Algebra II", grade: "A-", credits: 1.0, year: "Grade 9", isAP: false),
            ParsedCourse(name: "World Geography", grade: "B+", credits: 0.5, year: "Grade 9", isAP: false),
            ParsedCourse(name: "Earth Science", grade: "A", credits: 1.0, year: "Grade 9", isAP: false),
            ParsedCourse(name: "Spanish II", grade: "B+", credits: 1.0, year: "Grade 9", isAP: false),
            ParsedCourse(name: "PE / Health", grade: "A", credits: 1.0, year: "Grade 9", isAP: false),
        ]
    }
}

#Preview {
    NavigationStack { TranscriptUploadView() }
}
