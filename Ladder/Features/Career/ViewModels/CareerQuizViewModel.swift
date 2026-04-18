import Foundation
import SwiftData

// MARK: - Adaptive Career Quiz ViewModel
// Manages 3-stage RIASEC quiz flow, scoring, and results

@Observable
final class CareerQuizViewModel {

    // MARK: - State

    enum QuizStage: Int, CaseIterable {
        case quick = 1
        case deep = 2
        case results = 3

        var title: String {
            switch self {
            case .quick: return "Quick Discovery"
            case .deep: return "Deep Dive"
            case .results: return "Your Results"
            }
        }

        var subtitle: String {
            switch self {
            case .quick: return "6 quick questions to map your interests"
            case .deep: return "12 deeper questions based on your top strengths"
            case .results: return "Your personalized career clusters"
            }
        }
    }

    var currentStage: QuizStage = .quick
    var currentQuestionIndex: Int = 0
    var showTransition: Bool = false
    var resultsSaved: Bool = false

    // Answers
    private(set) var stage1Answers: [(RIASECQuestion, RIASECChoice)] = []
    private(set) var stage2Answers: [(RIASECQuestion, RIASECChoice)] = []

    // Stage 2 questions (determined after stage 1)
    private(set) var stage2Questions: [RIASECQuestion] = []

    // Results (computed after stage 2)
    private(set) var topClusters: [(cluster: CareerCluster, confidence: Double)] = []
    private(set) var archetypeName: String = ""
    private(set) var allScores: [RIASECDimension: Int] = [:]

    // MARK: - Computed Properties

    var currentQuestions: [RIASECQuestion] {
        switch currentStage {
        case .quick: return RIASECEngine.stage1Questions
        case .deep: return stage2Questions
        case .results: return []
        }
    }

    var currentQuestion: RIASECQuestion? {
        let questions = currentQuestions
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestionsInStage: Int {
        currentQuestions.count
    }

    var progress: Double {
        guard totalQuestionsInStage > 0 else { return 1.0 }
        return Double(currentQuestionIndex + 1) / Double(totalQuestionsInStage)
    }

    var overallProgress: Double {
        switch currentStage {
        case .quick:
            return Double(currentQuestionIndex) / 18.0 // 6 + 12 total
        case .deep:
            return Double(6 + currentQuestionIndex) / 18.0
        case .results:
            return 1.0
        }
    }

    var isLastQuestionInStage: Bool {
        currentQuestionIndex >= totalQuestionsInStage - 1
    }

    // MARK: - Trait list for profile saving

    var traitList: [String] {
        guard !topClusters.isEmpty else { return [] }
        return topClusters.first?.cluster.traits ?? []
    }

    // MARK: - Actions

    func answerQuestion(choice: RIASECChoice) {
        guard let question = currentQuestion else { return }

        switch currentStage {
        case .quick:
            stage1Answers.append((question, choice))

            if isLastQuestionInStage {
                // Calculate stage 1 scores and determine top 3
                let stage1Scores = RIASECEngine.calculateScores(
                    stage1Answers: stage1Answers,
                    stage2Answers: []
                )
                let top3 = RIASECEngine.topDimensions(from: stage1Scores)
                stage2Questions = RIASECEngine.stage2Questions(topDimensions: top3)

                // Show transition
                showTransition = true
            } else {
                currentQuestionIndex += 1
            }

        case .deep:
            stage2Answers.append((question, choice))

            if isLastQuestionInStage {
                calculateResults()
            } else {
                currentQuestionIndex += 1
            }

        case .results:
            break
        }
    }

    func moveToNextStage() {
        showTransition = false
        switch currentStage {
        case .quick:
            currentStage = .deep
            currentQuestionIndex = 0
        case .deep:
            currentStage = .results
            currentQuestionIndex = 0
        case .results:
            break
        }
    }

    func calculateResults() {
        allScores = RIASECEngine.calculateScores(
            stage1Answers: stage1Answers,
            stage2Answers: stage2Answers
        )
        topClusters = RIASECEngine.matchClusters(scores: allScores)
        archetypeName = RIASECEngine.archetypeName(from: allScores)
        currentStage = .results
    }

    @MainActor func saveResults(to profile: StudentProfileModel, context: ModelContext) {
        // Guard against double-tap: if already saved, don't re-fire cascade
        guard !resultsSaved else { return }
        guard let topCluster = topClusters.first else { return }

        profile.careerPath = topCluster.cluster.name
        profile.archetype = archetypeName
        profile.archetypeTraits = traitList
        try? context.save()

        // Wire 1: Fire ConnectionEngine cascade (after save, so profile is persisted)
        ConnectionEngine.shared.onCareerPathChanged(newPath: topCluster.cluster.name, context: context)

        // Wire 2: Award XP for completing the career quiz
        let _ = LevelManager.shared.awardXP(.finishCareerQuiz, to: profile)
        try? context.save()

        resultsSaved = true
    }

    func retakeQuiz() {
        currentStage = .quick
        currentQuestionIndex = 0
        showTransition = false
        resultsSaved = false
        stage1Answers = []
        stage2Answers = []
        stage2Questions = []
        topClusters = []
        archetypeName = ""
        allScores = [:]
    }
}
