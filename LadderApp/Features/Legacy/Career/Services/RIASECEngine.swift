import Foundation

// MARK: - RIASEC Engine
// 3-stage adaptive Holland Code career quiz engine
// Stage 1: 6 quick forced-choice questions (one per dimension)
// Stage 2: 12 deep-dive questions on top 3 dimensions
// Stage 3: Career cluster matching with confidence scores

// MARK: - RIASEC Dimension

enum RIASECDimension: String, CaseIterable, Codable, Hashable {
    case realistic = "Realistic"
    case investigative = "Investigative"
    case artistic = "Artistic"
    case social = "Social"
    case enterprising = "Enterprising"
    case conventional = "Conventional"

    var shortCode: String {
        switch self {
        case .realistic: return "R"
        case .investigative: return "I"
        case .artistic: return "A"
        case .social: return "S"
        case .enterprising: return "E"
        case .conventional: return "C"
        }
    }

    var icon: String {
        switch self {
        case .realistic: return "wrench.and.screwdriver"
        case .investigative: return "magnifyingglass"
        case .artistic: return "paintpalette"
        case .social: return "person.2"
        case .enterprising: return "chart.line.uptrend.xyaxis"
        case .conventional: return "tablecells"
        }
    }
}

// MARK: - Career Cluster

struct CareerCluster: Hashable {
    let name: String
    let archetype: String
    let description: String
    let icon: String
    let traits: [String]
    let sampleCareers: [String]
    let primaryDimension: RIASECDimension
}

// MARK: - Quiz Question

struct RIASECQuestion: Identifiable {
    let id = UUID()
    let scenario: String
    let choiceA: String
    let choiceB: String
    let dimensionA: RIASECDimension
    let dimensionB: RIASECDimension
    let stage: Int // 1, 2, or 3 (only 1 and 2 used for questions)
    /// Which top-3 dimensions this question targets (for stage 2 filtering)
    let targetDimensions: Set<RIASECDimension>
}

// MARK: - Quiz Answer

enum RIASECChoice: Codable {
    case a
    case b
}

// MARK: - RIASEC Engine

final class RIASECEngine {

    // MARK: - Scoring

    static func calculateScores(
        stage1Answers: [(RIASECQuestion, RIASECChoice)],
        stage2Answers: [(RIASECQuestion, RIASECChoice)]
    ) -> [RIASECDimension: Int] {
        var scores: [RIASECDimension: Int] = [:]
        for dim in RIASECDimension.allCases { scores[dim] = 0 }

        // Stage 1 answers worth 2 points each
        for (question, choice) in stage1Answers {
            let dim = choice == .a ? question.dimensionA : question.dimensionB
            scores[dim, default: 0] += 2
        }

        // Stage 2 answers worth 3 points each (deeper insight)
        for (question, choice) in stage2Answers {
            let dim = choice == .a ? question.dimensionA : question.dimensionB
            scores[dim, default: 0] += 3
        }

        return scores
    }

    /// Returns the top 3 dimensions from Stage 1 scores
    static func topDimensions(from scores: [RIASECDimension: Int], count: Int = 3) -> [RIASECDimension] {
        scores.sorted { $0.value > $1.value }
            .prefix(count)
            .map { $0.key }
    }

    /// Generates Stage 2 questions filtered to the student's top 3 dimensions
    static func stage2Questions(topDimensions: [RIASECDimension]) -> [RIASECQuestion] {
        let topSet = Set(topDimensions)
        return allStage2Questions.filter { q in
            !q.targetDimensions.isDisjoint(with: topSet)
        }
    }

    /// Maps final scores to top 3 career clusters with confidence %
    static func matchClusters(scores: [RIASECDimension: Int]) -> [(cluster: CareerCluster, confidence: Double)] {
        let totalPoints = max(Double(scores.values.reduce(0, +)), 1)

        var clusterScores: [(CareerCluster, Double)] = allClusters.map { cluster in
            let dimScore = Double(scores[cluster.primaryDimension] ?? 0)
            let confidence = (dimScore / totalPoints) * 100
            return (cluster, confidence)
        }

        clusterScores.sort { $0.1 > $1.1 }

        // Normalize top 3 so they sum to ~100
        let top3 = Array(clusterScores.prefix(3))
        let top3Sum = top3.reduce(0.0) { $0 + $1.1 }
        let normalizer = top3Sum > 0 ? 100.0 / top3Sum : 1.0

        return top3.map { (cluster: $0.0, confidence: min(round($0.1 * normalizer), 99)) }
    }

    /// Determines archetype name from top 2 dimensions
    static func archetypeName(from scores: [RIASECDimension: Int]) -> String {
        let top2 = topDimensions(from: scores, count: 2)
        guard top2.count >= 2 else { return "The Explorer" }

        let archetypeMap: [Set<RIASECDimension>: String] = [
            [.realistic, .investigative]: "The Analytical Builder",
            [.realistic, .artistic]: "The Creative Maker",
            [.realistic, .social]: "The Hands-On Helper",
            [.realistic, .enterprising]: "The Action Leader",
            [.realistic, .conventional]: "The Precision Expert",
            [.investigative, .artistic]: "The Creative Researcher",
            [.investigative, .social]: "The Empathetic Scientist",
            [.investigative, .enterprising]: "The Strategic Innovator",
            [.investigative, .conventional]: "The Methodical Analyst",
            [.artistic, .social]: "The Expressive Communicator",
            [.artistic, .enterprising]: "The Visionary Creator",
            [.artistic, .conventional]: "The Design Specialist",
            [.social, .enterprising]: "The People Leader",
            [.social, .conventional]: "The Organized Caregiver",
            [.enterprising, .conventional]: "The Business Strategist",
        ]

        let key = Set(top2.prefix(2))
        return archetypeMap[key] ?? "The Renaissance Mind"
    }

    // MARK: - Career Clusters

    static let allClusters: [CareerCluster] = [
        CareerCluster(
            name: "Engineering & Trades",
            archetype: "The Builder",
            description: "You thrive working with tools, machines, and physical systems. You like seeing tangible results from your work.",
            icon: "gearshape.2",
            traits: ["Hands-on", "Practical", "Mechanical aptitude", "Problem-solver"],
            sampleCareers: ["Mechanical Engineer", "Electrician", "Civil Engineer", "Robotics Technician", "Architect"],
            primaryDimension: .realistic
        ),
        CareerCluster(
            name: "Science & Research",
            archetype: "The Discoverer",
            description: "You love asking questions, running experiments, and uncovering how the world works at a deep level.",
            icon: "flask",
            traits: ["Analytical", "Curious", "Detail-oriented", "Data-driven"],
            sampleCareers: ["Research Scientist", "Data Scientist", "Physician", "Pharmacist", "Environmental Analyst"],
            primaryDimension: .investigative
        ),
        CareerCluster(
            name: "Arts & Design",
            archetype: "The Creator",
            description: "You express yourself through creativity and imagination. You see beauty and meaning where others see routine.",
            icon: "paintbrush",
            traits: ["Creative", "Expressive", "Original", "Intuitive"],
            sampleCareers: ["Graphic Designer", "UX Designer", "Film Director", "Writer", "Music Producer"],
            primaryDimension: .artistic
        ),
        CareerCluster(
            name: "Healthcare & Education",
            archetype: "The Nurturer",
            description: "You find fulfillment in helping others grow, learn, and heal. People naturally come to you for support.",
            icon: "heart.text.clipboard",
            traits: ["Empathetic", "Patient", "Supportive", "Communicative"],
            sampleCareers: ["Teacher", "School Counselor", "Nurse", "Social Worker", "Physical Therapist"],
            primaryDimension: .social
        ),
        CareerCluster(
            name: "Business & Law",
            archetype: "The Persuader",
            description: "You are driven to lead, influence, and build ventures. You think strategically and take calculated risks.",
            icon: "briefcase",
            traits: ["Ambitious", "Persuasive", "Decisive", "Competitive"],
            sampleCareers: ["Entrepreneur", "Lawyer", "Marketing Manager", "Sales Director", "Political Strategist"],
            primaryDimension: .enterprising
        ),
        CareerCluster(
            name: "Finance & Administration",
            archetype: "The Organizer",
            description: "You bring order to complexity. Numbers, systems, and processes are your strengths -- you make organizations run smoothly.",
            icon: "chart.bar.doc.horizontal",
            traits: ["Organized", "Methodical", "Reliable", "Detail-focused"],
            sampleCareers: ["Accountant", "Financial Analyst", "Actuary", "Database Administrator", "Compliance Officer"],
            primaryDimension: .conventional
        ),
    ]

    // MARK: - Stage 1 Questions (6 questions, one per dimension pair)

    static let stage1Questions: [RIASECQuestion] = [
        RIASECQuestion(
            scenario: "On a Saturday afternoon, would you rather...",
            choiceA: "Build or repair something with your hands",
            choiceB: "Read about a scientific breakthrough",
            dimensionA: .realistic, dimensionB: .investigative,
            stage: 1, targetDimensions: [.realistic, .investigative]
        ),
        RIASECQuestion(
            scenario: "For a school project, would you prefer to...",
            choiceA: "Design an original poster, video, or presentation",
            choiceB: "Organize a volunteer event for the community",
            dimensionA: .artistic, dimensionB: .social,
            stage: 1, targetDimensions: [.artistic, .social]
        ),
        RIASECQuestion(
            scenario: "If you started a club, would it be about...",
            choiceA: "Entrepreneurship and pitching business ideas",
            choiceB: "Coding, robotics, or engineering challenges",
            dimensionA: .enterprising, dimensionB: .realistic,
            stage: 1, targetDimensions: [.enterprising, .realistic]
        ),
        RIASECQuestion(
            scenario: "Which sounds more rewarding?",
            choiceA: "Tutoring a struggling student until they succeed",
            choiceB: "Organizing and tracking data in a detailed spreadsheet",
            dimensionA: .social, dimensionB: .conventional,
            stage: 1, targetDimensions: [.social, .conventional]
        ),
        RIASECQuestion(
            scenario: "Which excites you more?",
            choiceA: "Investigating a mystery using clues and logic",
            choiceB: "Leading a team to win a competition",
            dimensionA: .investigative, dimensionB: .enterprising,
            stage: 1, targetDimensions: [.investigative, .enterprising]
        ),
        RIASECQuestion(
            scenario: "In your ideal future, would you rather...",
            choiceA: "Write, paint, or create something that moves people",
            choiceB: "Manage budgets, schedules, and keep things running smoothly",
            dimensionA: .artistic, dimensionB: .conventional,
            stage: 1, targetDimensions: [.artistic, .conventional]
        ),
    ]

    // MARK: - Stage 2 Questions (deep-dive pool, filtered by top 3)

    static let allStage2Questions: [RIASECQuestion] = [
        // Realistic-focused
        RIASECQuestion(
            scenario: "You notice a machine is broken at school. Do you...",
            choiceA: "Try to figure out the issue and fix it yourself",
            choiceB: "Research the engineering principles behind how it works",
            dimensionA: .realistic, dimensionB: .investigative,
            stage: 2, targetDimensions: [.realistic, .investigative]
        ),
        RIASECQuestion(
            scenario: "Your friend asks for help moving. Do you prefer...",
            choiceA: "Doing the physical work -- loading, carrying, assembling",
            choiceB: "Planning the logistics -- what goes where, the route",
            dimensionA: .realistic, dimensionB: .conventional,
            stage: 2, targetDimensions: [.realistic, .conventional]
        ),
        RIASECQuestion(
            scenario: "Would you rather spend your summer...",
            choiceA: "Working on a construction site or in a workshop",
            choiceB: "Interning at a startup and pitching ideas",
            dimensionA: .realistic, dimensionB: .enterprising,
            stage: 2, targetDimensions: [.realistic, .enterprising]
        ),
        // Investigative-focused
        RIASECQuestion(
            scenario: "You find a puzzling pattern in data. Do you...",
            choiceA: "Dig deeper until you understand the root cause",
            choiceB: "Present your findings to convince others to act on it",
            dimensionA: .investigative, dimensionB: .enterprising,
            stage: 2, targetDimensions: [.investigative, .enterprising]
        ),
        RIASECQuestion(
            scenario: "In a science fair, would you rather...",
            choiceA: "Run a controlled experiment and analyze results",
            choiceB: "Create an artistic display that explains a concept beautifully",
            dimensionA: .investigative, dimensionB: .artistic,
            stage: 2, targetDimensions: [.investigative, .artistic]
        ),
        RIASECQuestion(
            scenario: "A friend is stressed about health symptoms. Do you...",
            choiceA: "Research their symptoms and explain possible causes",
            choiceB: "Listen, comfort them, and help them feel better emotionally",
            dimensionA: .investigative, dimensionB: .social,
            stage: 2, targetDimensions: [.investigative, .social]
        ),
        // Artistic-focused
        RIASECQuestion(
            scenario: "Your school needs a new mural. Do you...",
            choiceA: "Design and paint the mural yourself",
            choiceB: "Organize a team of student artists to create it together",
            dimensionA: .artistic, dimensionB: .social,
            stage: 2, targetDimensions: [.artistic, .social]
        ),
        RIASECQuestion(
            scenario: "You have a great idea for a product. Do you first...",
            choiceA: "Sketch out the design and branding",
            choiceB: "Write a business plan and figure out how to sell it",
            dimensionA: .artistic, dimensionB: .enterprising,
            stage: 2, targetDimensions: [.artistic, .enterprising]
        ),
        // Social-focused
        RIASECQuestion(
            scenario: "A new student joins your school. Do you...",
            choiceA: "Go out of your way to welcome them and show them around",
            choiceB: "Set up a structured buddy system so every new student gets help",
            dimensionA: .social, dimensionB: .conventional,
            stage: 2, targetDimensions: [.social, .conventional]
        ),
        RIASECQuestion(
            scenario: "In a group disagreement, do you...",
            choiceA: "Mediate and make sure everyone feels heard",
            choiceB: "Take charge and make a decision to move things forward",
            dimensionA: .social, dimensionB: .enterprising,
            stage: 2, targetDimensions: [.social, .enterprising]
        ),
        // Enterprising-focused
        RIASECQuestion(
            scenario: "You win $1,000. Do you...",
            choiceA: "Invest it or start a small business",
            choiceB: "Put it in savings and track it carefully in a budget",
            dimensionA: .enterprising, dimensionB: .conventional,
            stage: 2, targetDimensions: [.enterprising, .conventional]
        ),
        RIASECQuestion(
            scenario: "Your class is running a fundraiser. Do you...",
            choiceA: "Come up with a bold marketing strategy and rally the team",
            choiceB: "Build something people can buy -- crafts, food, or a product",
            dimensionA: .enterprising, dimensionB: .realistic,
            stage: 2, targetDimensions: [.enterprising, .realistic]
        ),
        // Conventional-focused
        RIASECQuestion(
            scenario: "You are organizing a school event. Do you enjoy...",
            choiceA: "Creating the schedule, checklists, and budget",
            choiceB: "Analyzing past events to figure out what worked best",
            dimensionA: .conventional, dimensionB: .investigative,
            stage: 2, targetDimensions: [.conventional, .investigative]
        ),
        RIASECQuestion(
            scenario: "Your teacher needs help grading. Do you prefer...",
            choiceA: "Entering scores into a spreadsheet and calculating averages",
            choiceB: "Giving feedback to students on how to improve",
            dimensionA: .conventional, dimensionB: .social,
            stage: 2, targetDimensions: [.conventional, .social]
        ),
    ]
}
