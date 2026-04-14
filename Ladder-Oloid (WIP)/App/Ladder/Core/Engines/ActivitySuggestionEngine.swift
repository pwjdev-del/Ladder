import Foundation

struct ActivitySuggestion: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let description: String
    let timeCommitment: String
    let icon: String
    let careerPaths: [String]  // e.g. ["Medical Path", "Engineering & STEM"]
    let minGrade: Int
}

enum ActivitySuggestionEngine {
    static let allActivities: [ActivitySuggestion] = [
        // STEM
        ActivitySuggestion(title: "Science Olympiad", category: "Academic", description: "Team competition across 23 STEM events.", timeCommitment: "3-5 hrs/week", icon: "atom", careerPaths: ["Engineering & STEM", "Medical Path"], minGrade: 9),
        ActivitySuggestion(title: "Robotics Club / FIRST", category: "Engineering", description: "Design, build, and program robots for competition.", timeCommitment: "5-10 hrs/week", icon: "gearshape.2.fill", careerPaths: ["Engineering & STEM"], minGrade: 9),
        ActivitySuggestion(title: "Math Olympiad / AMC", category: "Academic", description: "Top math competitions for college applications.", timeCommitment: "2-4 hrs/week", icon: "function", careerPaths: ["Engineering & STEM"], minGrade: 9),

        // Medical
        ActivitySuggestion(title: "Hospital Volunteering", category: "Service", description: "Volunteer at a local hospital.", timeCommitment: "4-8 hrs/week", icon: "cross.case.fill", careerPaths: ["Medical Path"], minGrade: 10),
        ActivitySuggestion(title: "HOSA (Future Health Professionals)", category: "Career", description: "Future health professional leadership.", timeCommitment: "2-4 hrs/week", icon: "stethoscope", careerPaths: ["Medical Path"], minGrade: 9),
        ActivitySuggestion(title: "Shadow a Doctor", category: "Career", description: "Reach out to family doctor or specialist for shadowing days.", timeCommitment: "Episodic", icon: "person.fill.questionmark", careerPaths: ["Medical Path"], minGrade: 10),

        // Business
        ActivitySuggestion(title: "DECA / FBLA", category: "Career", description: "Business and entrepreneurship competitions.", timeCommitment: "3-5 hrs/week", icon: "chart.line.uptrend.xyaxis", careerPaths: ["Business & Finance"], minGrade: 9),
        ActivitySuggestion(title: "Start a Small Business / Etsy Shop", category: "Entrepreneurship", description: "Demonstrates initiative and real-world skills.", timeCommitment: "Variable", icon: "bag.fill", careerPaths: ["Business & Finance"], minGrade: 10),
        ActivitySuggestion(title: "Investment Club", category: "Finance", description: "Mock portfolios + real-world finance literacy.", timeCommitment: "1-2 hrs/week", icon: "dollarsign.circle.fill", careerPaths: ["Business & Finance"], minGrade: 9),

        // Humanities
        ActivitySuggestion(title: "Model UN", category: "Academic", description: "Diplomacy and global affairs simulation.", timeCommitment: "3-5 hrs/week", icon: "globe", careerPaths: ["Humanities", "Law & Public Service"], minGrade: 9),
        ActivitySuggestion(title: "Debate Team", category: "Academic", description: "Speech and debate competitions.", timeCommitment: "5-8 hrs/week", icon: "bubble.left.and.bubble.right.fill", careerPaths: ["Humanities", "Law & Public Service"], minGrade: 9),
        ActivitySuggestion(title: "School Newspaper", category: "Media", description: "Writing, editing, journalism.", timeCommitment: "2-4 hrs/week", icon: "newspaper.fill", careerPaths: ["Humanities", "Creative Arts"], minGrade: 9),

        // Arts
        ActivitySuggestion(title: "Theater / Drama Club", category: "Arts", description: "Performance, set design, technical crew.", timeCommitment: "5-15 hrs/week (seasonal)", icon: "theatermasks.fill", careerPaths: ["Creative Arts", "Humanities"], minGrade: 9),
        ActivitySuggestion(title: "Marching Band / Orchestra", category: "Arts", description: "Music ensemble.", timeCommitment: "5-10 hrs/week", icon: "music.note", careerPaths: ["Creative Arts"], minGrade: 9),
        ActivitySuggestion(title: "Art Portfolio Building", category: "Arts", description: "Build portfolio for art school admissions.", timeCommitment: "3-6 hrs/week", icon: "paintpalette.fill", careerPaths: ["Creative Arts"], minGrade: 10),

        // Athletics
        ActivitySuggestion(title: "Varsity Sport", category: "Athletics", description: "School team — leadership and discipline.", timeCommitment: "10-20 hrs/week (in-season)", icon: "figure.run", careerPaths: ["Sports & Athletics"], minGrade: 9),
        ActivitySuggestion(title: "Sports Statistician / Manager", category: "Athletics", description: "Behind-the-scenes role in sports.", timeCommitment: "5-10 hrs/week", icon: "chart.bar.fill", careerPaths: ["Sports & Athletics", "Business & Finance"], minGrade: 10),

        // Law / Public Service
        ActivitySuggestion(title: "Mock Trial", category: "Academic", description: "Courtroom simulation competition.", timeCommitment: "5-8 hrs/week", icon: "scalemass.fill", careerPaths: ["Law & Public Service"], minGrade: 10),
        ActivitySuggestion(title: "Student Government", category: "Leadership", description: "School-wide leadership.", timeCommitment: "2-4 hrs/week", icon: "person.3.fill", careerPaths: ["Law & Public Service", "Business & Finance"], minGrade: 9),
        ActivitySuggestion(title: "Local Campaign Volunteering", category: "Service", description: "Campaign work for local elections.", timeCommitment: "Episodic (election season)", icon: "checkmark.seal.fill", careerPaths: ["Law & Public Service"], minGrade: 11),

        // Universal
        ActivitySuggestion(title: "Tutoring Younger Students", category: "Service", description: "Math/reading tutoring at library or school.", timeCommitment: "2-4 hrs/week", icon: "book.fill", careerPaths: [], minGrade: 9),
        ActivitySuggestion(title: "Community Service (any)", category: "Service", description: "Florida requires 75 hrs; most colleges value 50+.", timeCommitment: "Variable", icon: "heart.fill", careerPaths: [], minGrade: 9),
        ActivitySuggestion(title: "Summer Research Program", category: "Academic", description: "RSI, COSMOS, MITES — competitive STEM/academic programs.", timeCommitment: "6-8 weeks summer", icon: "flask.fill", careerPaths: ["Engineering & STEM", "Medical Path"], minGrade: 11),
    ]

    /// Returns activities matching the student's career path and grade level
    static func suggestions(for careerPath: String?, grade: Int, limit: Int = 6) -> [ActivitySuggestion] {
        let pathMatched = allActivities.filter { activity in
            activity.minGrade <= grade &&
            (activity.careerPaths.isEmpty || activity.careerPaths.contains(careerPath ?? ""))
        }
        return Array(pathMatched.shuffled().prefix(limit))
    }
}
