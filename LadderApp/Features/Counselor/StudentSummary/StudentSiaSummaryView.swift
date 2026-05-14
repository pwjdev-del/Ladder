import SwiftUI
import os

// D-002: Counselor-facing student summary.
// HARD RULE: This view reads ONLY from SiaEngine.summarize() and briefCounselor().
// It NEVER reads student_ai_chats. Any future contributor must not add direct
// chat reads here — the RLS on student_ai_chats would reject them anyway (migration 0016).

// MARK: - View model

@MainActor
private final class StudentSummaryViewModel: ObservableObject {
    @Published var summary: StudentSiaSummary?
    @Published var isLoadingSummary = false
    @Published var summaryError: String?

    @Published var briefAnswer: String?
    @Published var isLoadingBrief = false
    @Published var briefError: String?

    @Published var customQuestion: String = ""
    @Published var showAskSheet = false

    private let log = Logger(subsystem: "ladder", category: "CounselorSummary")

    func load(studentId: String, counselorUid: String) async {
        isLoadingSummary = true
        summaryError = nil
        defer { isLoadingSummary = false }
        do {
            summary = try await SiaEngine.shared.summarize(
                studentId: studentId,
                requestingCounselorAuthUid: counselorUid
            )
        } catch {
            log.error("summarize failed: \(error)")
            summaryError = "Couldn't load student summary. Please try again."
        }
    }

    func askSIA(studentId: String, counselorUid: String, question: String) async {
        guard !question.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoadingBrief = true
        briefAnswer = nil
        briefError = nil
        defer { isLoadingBrief = false }
        do {
            briefAnswer = try await SiaEngine.shared.briefCounselor(
                studentId: studentId,
                requestingCounselorAuthUid: counselorUid,
                question: question
            )
        } catch {
            log.error("briefCounselor failed: \(error)")
            briefError = "SIA couldn't answer right now. Please try again later."
        }
    }
}

// MARK: - Main view

/// Full-screen student summary card for a counselor.
/// Route: StudentQueueView row tap → NavigationLink or sheet to here.
public struct StudentSiaSummaryView: View {
    public let studentId: String
    public let studentDisplayName: String
    public let counselorAuthUid: String

    @StateObject private var vm = StudentSummaryViewModel()

    public init(
        studentId: String,
        studentDisplayName: String,
        counselorAuthUid: String
    ) {
        self.studentId = studentId
        self.studentDisplayName = studentDisplayName
        self.counselorAuthUid = counselorAuthUid
    }

    // T024 iPad parity: when presented as a sheet from StudentQueueView on iPad,
    // the view defaults to a .formSheet presentation (~60% of the screen width).
    // MaxWidthContainer(640) caps the content column so it never spans the full
    // iPad Pro width in landscape or when the sheet is expanded.
    public var body: some View {
        ZStack {
            BrandGradient.list.ignoresSafeArea()

            ScrollView {
                MaxWidthContainer(maxWidth: 640) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        if vm.isLoadingSummary {
                            loadingCard
                        } else if let error = vm.summaryError {
                            errorCard(message: error)
                        } else if let summary = vm.summary {
                            summaryCard(summary)
                            askSIAButton(summary: summary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(studentDisplayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $vm.showAskSheet) {
            AskSIASheet(
                studentDisplayName: studentDisplayName,
                studentId: studentId,
                counselorAuthUid: counselorAuthUid,
                vm: vm
            )
        }
        .task {
            await vm.load(studentId: studentId, counselorUid: counselorAuthUid)
        }
    }

    // MARK: - Sub-views

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("STUDENT OVERVIEW")
                .font(.ladderCaps(11)).tracking(1.4)
                .foregroundStyle(LadderBrand.lime500)
            Text(studentDisplayName)
                .font(.ladderDisplay(26, relativeTo: .title))
                .foregroundStyle(LadderBrand.cream100)
        }
    }

    private var loadingCard: some View {
        HStack {
            ProgressView().tint(LadderBrand.cream100)
            Text("Loading student summary...")
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func errorCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Unable to load", systemImage: "exclamationmark.triangle")
                .font(.ladderLabel(14))
                .foregroundStyle(LadderBrand.cream100)
            Text(message)
                .font(.ladderBody(13))
                .foregroundStyle(LadderBrand.cream100.opacity(0.7))
            Button("Try again") {
                Task { await vm.load(studentId: studentId, counselorUid: counselorAuthUid) }
            }
            .font(.ladderLabel(13))
            .foregroundStyle(LadderBrand.lime500)
        }
        .padding(16)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func summaryCard(_ summary: StudentSiaSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            // Last active
            if let lastActive = summary.lastActiveAt {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.6))
                    Text("Last active \(lastActive.relativeLabel)")
                        .font(.ladderBody(13))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.7))
                }
            }

            Divider().background(LadderBrand.cream100.opacity(0.15))

            // Topics
            if summary.topics.isEmpty {
                Text("SIA hasn't talked with this student yet.")
                    .font(.ladderBody(14))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.7))
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENTLY WORKING ON")
                        .font(.ladderCaps(10)).tracking(1.2)
                        .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                    ForEach(summary.topics, id: \.self) { topic in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.ladderBody(14))
                                .foregroundStyle(LadderBrand.lime500)
                            Text(topic)
                                .font(.ladderBody(14))
                                .foregroundStyle(LadderBrand.cream100)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            // Summary text (SIA-generated, not raw chat)
            if !summary.summaryText.isEmpty {
                Divider().background(LadderBrand.cream100.opacity(0.15))
                VStack(alignment: .leading, spacing: 4) {
                    Text("SIA OVERVIEW")
                        .font(.ladderCaps(10)).tracking(1.2)
                        .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                    Text(summary.summaryText)
                        .font(.ladderBody(14))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Safety flags
            if !summary.activeSafetyFlags.isEmpty {
                Divider().background(LadderBrand.cream100.opacity(0.15))
                safetyFlagsSection(summary.activeSafetyFlags)
            }
        }
        .padding(16)
        .background(LadderBrand.cream100.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func safetyFlagsSection(_ flags: [SafetyFlag]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                Text("\(flags.count) safety flag\(flags.count == 1 ? "" : "s") — review recommended")
                    .font(.ladderLabel(13))
                    .foregroundStyle(LadderBrand.cream100)
            }
            ForEach(flags) { flag in
                VStack(alignment: .leading, spacing: 2) {
                    Text(flag.type.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.ladderLabel(12))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                    Text("Flagged \(flag.createdAt.relativeLabel) via \(flag.triggeredBy)")
                        .font(.ladderBody(11))
                        .foregroundStyle(LadderBrand.cream100.opacity(0.5))
                }
                .padding(10)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func askSIAButton(summary: StudentSiaSummary) -> some View {
        Button {
            vm.customQuestion = "What does \(studentDisplayName) need from me this week?"
            vm.showAskSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.system(size: 16))
                Text("Ask SIA: what does \(studentDisplayName) need?")
                    .font(.ladderLabel(14))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundStyle(LadderBrand.ink900)
            .padding(14)
            .background(LadderBrand.lime500)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ask SIA sheet

struct AskSIASheet: View {
    let studentDisplayName: String
    let studentId: String
    let counselorAuthUid: String
    @ObservedObject fileprivate var vm: StudentSummaryViewModel

    @FocusState private var questionFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BrandGradient.list.ignoresSafeArea()

                ScrollView {
                    MaxWidthContainer(maxWidth: 640) {
                        VStack(alignment: .leading, spacing: 20) {

                            Text("SIA will answer using only its stored summaries — never raw conversation content.")
                                .font(.ladderBody(13))
                                .foregroundStyle(LadderBrand.cream100.opacity(0.65))
                                .padding(.top, 4)

                            // Question field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("YOUR QUESTION")
                                    .font(.ladderCaps(10)).tracking(1.2)
                                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                                TextField(
                                    "What does \(studentDisplayName) need from me this week?",
                                    text: $vm.customQuestion,
                                    axis: .vertical
                                )
                                .lineLimit(3...6)
                                .padding(12)
                                .background(LadderBrand.cream100.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(LadderBrand.cream100)
                                .tint(LadderBrand.lime500)
                                .focused($questionFocused)
                            }

                            // Ask button
                            Button {
                                questionFocused = false
                                Task {
                                    await vm.askSIA(
                                        studentId: studentId,
                                        counselorUid: counselorAuthUid,
                                        question: vm.customQuestion
                                    )
                                }
                            } label: {
                                if vm.isLoadingBrief {
                                    HStack(spacing: 8) {
                                        ProgressView().tint(LadderBrand.ink900)
                                        Text("Asking SIA...")
                                            .font(.ladderLabel(14))
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    Text("Ask SIA")
                                        .font(.ladderLabel(14))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .foregroundStyle(LadderBrand.ink900)
                            .padding(.vertical, 14)
                            .background(LadderBrand.lime500)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .buttonStyle(.plain)
                            .disabled(
                                vm.isLoadingBrief
                                || vm.customQuestion.trimmingCharacters(in: .whitespaces).isEmpty
                            )

                            // Answer
                            if let answer = vm.briefAnswer {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("SIA's Brief", systemImage: "sparkles")
                                        .font(.ladderLabel(13))
                                        .foregroundStyle(LadderBrand.lime500)
                                    Text(answer)
                                        .font(.ladderBody(14))
                                        .foregroundStyle(LadderBrand.cream100)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .background(LadderBrand.cream100.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            if let error = vm.briefError {
                                Text(error)
                                    .font(.ladderBody(13))
                                    .foregroundStyle(.red.opacity(0.85))
                                    .padding(12)
                                    .background(Color.red.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Ask SIA about \(studentDisplayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LadderBrand.lime500)
                }
            }
        }
    }
}

// MARK: - Date helper

private extension Date {
    var relativeLabel: String {
        let seconds = Int(Date().timeIntervalSince(self))
        switch seconds {
        case ..<60:       return "just now"
        case ..<3600:     return "\(seconds / 60)m ago"
        case ..<86400:    return "\(seconds / 3600)h ago"
        default:          return "\(seconds / 86400)d ago"
        }
    }
}
