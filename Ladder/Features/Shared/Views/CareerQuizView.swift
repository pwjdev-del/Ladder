import SwiftUI

// MARK: - Career Quiz — Full Scoring System
// 5 buckets: STEM, Medical, Business, Humanities, Sports
// Annual retake: taken every year as interests evolve

struct CareerQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var scores: [String: Int] = ["STEM": 0, "Medical": 0, "Business": 0, "Humanities": 0, "Sports": 0]
    @State private var selectedOption: Int = -1
    @State private var showResult = false
    @State private var resultBucket = "STEM"

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()
            if showResult {
                CareerResultView(bucket: resultBucket, scores: scores) {
                    withAnimation(.spring(response: 0.4)) {
                        currentQuestion = 0; selectedOption = -1
                        scores = ["STEM": 0, "Medical": 0, "Business": 0, "Humanities": 0, "Sports": 0]
                        showResult = false
                    }
                }
            } else {
                quizBody
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Career Discovery").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    private var quizBody: some View {
        VStack(spacing: 0) {
            VStack(spacing: LadderSpacing.xs) {
                HStack {
                    Text("Question \(currentQuestion + 1) of \(QuizData.questions.count)")
                        .font(LadderTypography.labelMedium).foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    Text("\(Int(Double(currentQuestion + 1) / Double(QuizData.questions.count) * 100))%")
                        .font(LadderTypography.labelMedium).foregroundStyle(LadderColors.primary)
                }
                LinearProgressBar(progress: Double(currentQuestion + 1) / Double(QuizData.questions.count))
            }
            .padding([.horizontal, .top], LadderSpacing.md).padding(.bottom, LadderSpacing.sm)

            ScrollView(showsIndicators: false) {
                let q = QuizData.questions[currentQuestion]
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        ZStack {
                            Circle().fill(LadderColors.primaryContainer.opacity(0.3)).frame(width: 56, height: 56)
                            Image(systemName: q.icon).font(.system(size: 24)).foregroundStyle(LadderColors.primary)
                        }
                        Text(q.question).font(LadderTypography.headlineSmall).foregroundStyle(LadderColors.onSurface)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, LadderSpacing.md).padding(.top, LadderSpacing.lg)

                    VStack(spacing: LadderSpacing.sm) {
                        ForEach(Array(q.options.enumerated()), id: \.offset) { idx, opt in
                            Button {
                                withAnimation(.spring(response: 0.25)) { selectedOption = idx }
                            } label: {
                                HStack(spacing: LadderSpacing.md) {
                                    ZStack {
                                        Circle().stroke(selectedOption == idx ? LadderColors.accentLime : LadderColors.outlineVariant, lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        if selectedOption == idx {
                                            Circle().fill(LadderColors.accentLime).frame(width: 12, height: 12)
                                        }
                                    }
                                    Text(opt).font(LadderTypography.bodyLarge).foregroundStyle(LadderColors.onSurface)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(LadderSpacing.md)
                                .background(selectedOption == idx ? LadderColors.primaryContainer.opacity(0.25) : LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                                    .stroke(selectedOption == idx ? LadderColors.accentLime.opacity(0.5) : Color.clear, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, LadderSpacing.md)
                }
                .padding(.bottom, 120)
            }

            Divider().opacity(0.1)
            LadderPrimaryButton(
                currentQuestion == QuizData.questions.count - 1 ? "See My Results" : "Next Question",
                icon: currentQuestion == QuizData.questions.count - 1 ? "sparkles" : "arrow.right"
            ) {
                guard selectedOption != -1 else { return }
                let weights = QuizData.questions[currentQuestion].weights[selectedOption]
                for (bucket, pts) in weights { scores[bucket, default: 0] += pts }
                if currentQuestion == QuizData.questions.count - 1 {
                    resultBucket = scores.max(by: { $0.value < $1.value })?.key ?? "STEM"
                    withAnimation(.spring(response: 0.5)) { showResult = true }
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) { currentQuestion += 1; selectedOption = -1 }
                }
            }
            .padding(.horizontal, LadderSpacing.md).padding(.vertical, LadderSpacing.md)
            .opacity(selectedOption == -1 ? 0.5 : 1)
            .background(LadderColors.surface)
        }
    }
}

// MARK: - Career Result View

struct CareerResultView: View {
    let bucket: String
    let scores: [String: Int]
    let onRetake: () -> Void
    @Environment(\.dismiss) private var dismiss
    private var info: BucketInfo { BucketInfo.all[bucket] ?? BucketInfo.all["STEM"]! }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LadderSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [info.color, info.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 130, height: 130)
                    Image(systemName: info.icon).font(.system(size: 44)).foregroundStyle(.white)
                }
                .padding(.top, LadderSpacing.xl)

                VStack(spacing: LadderSpacing.sm) {
                    Text(info.archetype).font(LadderTypography.headlineLarge).foregroundStyle(LadderColors.onSurface)
                    Text(bucket.uppercased()).font(LadderTypography.labelSmall).foregroundStyle(LadderColors.accentLime).labelTracking()
                    Text(info.description).font(LadderTypography.bodyLarge).foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center).padding(.horizontal, LadderSpacing.md)
                }

                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Your Career Profile").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                        let total = max(scores.values.reduce(0, +), 1)
                        ForEach(["STEM","Medical","Business","Humanities","Sports"], id: \.self) { b in
                            let pct = Double(scores[b] ?? 0) / Double(total)
                            let bi = BucketInfo.all[b]!
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: bi.icon).font(.system(size: 13))
                                    .foregroundStyle(b == bucket ? LadderColors.accentLime : LadderColors.onSurfaceVariant).frame(width: 18)
                                Text(b).font(LadderTypography.bodySmall)
                                    .foregroundStyle(b == bucket ? LadderColors.onSurface : LadderColors.onSurfaceVariant).frame(width: 90, alignment: .leading)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4).fill(LadderColors.surfaceContainerHigh).frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4).fill(b == bucket ? LadderColors.accentLime : LadderColors.primary.opacity(0.4))
                                            .frame(width: max(geo.size.width * pct, 0), height: 6)
                                    }
                                }.frame(height: 6)
                                Text("\(Int(pct * 100))%").font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant).frame(width: 34, alignment: .trailing)
                            }
                        }
                    }
                }

                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Suggested Majors").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                        FlowLayout(spacing: LadderSpacing.sm) {
                            ForEach(info.majors, id: \.self) { LadderTagChip($0) }
                        }
                    }
                }

                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Classes to Focus On").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                        ForEach(info.classes, id: \.self) { cls in
                            HStack(spacing: LadderSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(LadderColors.accentLime).font(.system(size: 14))
                                Text(cls).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface)
                                Spacer()
                            }
                        }
                    }
                }

                LadderCard {
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("Colleges to Explore").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                        ForEach(Array(info.colleges.enumerated()), id: \.offset) { i, c in
                            HStack {
                                Text("\(i + 1).").font(LadderTypography.labelMedium).foregroundStyle(LadderColors.accentLime).frame(width: 20)
                                Text(c).font(LadderTypography.bodyMedium).foregroundStyle(LadderColors.onSurface)
                                Spacer()
                            }
                        }
                    }
                }

                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "arrow.clockwise.circle").foregroundStyle(LadderColors.onSurfaceVariant).font(.system(size: 14))
                    Text("Suggestions only — not final decisions. Retake every year as your interests evolve.")
                        .font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.horizontal, LadderSpacing.md)

                HStack(spacing: LadderSpacing.md) {
                    LadderSecondaryButton("Retake Quiz") { onRetake() }
                    LadderPrimaryButton("Save My Path", icon: "checkmark") { dismiss() }
                }
                .padding(.horizontal, LadderSpacing.md).padding(.bottom, 120)
            }
            .padding(.horizontal, LadderSpacing.md)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Your Career Path").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
            }
        }
    }
}

// MARK: - Bucket Info

struct BucketInfo {
    let archetype: String; let description: String; let icon: String
    let color: Color; let majors: [String]; let classes: [String]; let colleges: [String]

    static let all: [String: BucketInfo] = [
        "STEM": BucketInfo(
            archetype: "The Innovator",
            description: "You're driven by curiosity and building things. Technology, math, and science are where you shine — you want to engineer the future.",
            icon: "cpu", color: Color(red: 0.26, green: 0.38, blue: 0.25),
            majors: ["Computer Science", "Electrical Engineering", "Data Science", "Mechanical Engineering", "Cybersecurity", "Aerospace Engineering", "Mathematics"],
            classes: ["AP Computer Science A", "AP Calculus BC", "AP Physics C", "AP Statistics", "AP Chemistry", "Dual Enrollment Math"],
            colleges: ["Georgia Tech", "RIT", "University of Florida", "UCF", "Purdue", "Virginia Tech", "University of Michigan"]
        ),
        "Medical": BucketInfo(
            archetype: "The Healer",
            description: "You care deeply about people and are drawn to science as a way to help others. Your empathy and analytical mind make you a natural in healthcare.",
            icon: "cross.case", color: Color(red: 0.15, green: 0.35, blue: 0.55),
            majors: ["Pre-Medicine", "Biomedical Science", "Nursing", "Public Health", "Pharmacy", "Biomedical Engineering", "Kinesiology"],
            classes: ["AP Biology", "AP Chemistry", "AP Psychology", "Anatomy & Physiology", "AP Calculus AB", "Intro to Health Science"],
            colleges: ["University of Florida", "USF", "FSU", "Emory", "University of Miami", "FIU", "UCF"]
        ),
        "Business": BucketInfo(
            archetype: "The Entrepreneur",
            description: "You're a natural leader and strategic thinker. You see opportunities where others don't — running organizations and building teams energizes you.",
            icon: "briefcase", color: Color(red: 0.55, green: 0.30, blue: 0.10),
            majors: ["Business Administration", "Finance", "Marketing", "Accounting", "Entrepreneurship", "Economics", "Real Estate"],
            classes: ["AP Economics", "AP Statistics", "Business Essentials", "Marketing Principles", "AP US Government", "Dual Enrollment: Business 101"],
            colleges: ["UF Warrington", "FSU Business", "University of Tampa", "FIU", "Indiana University", "UGA Terry", "Miami Herbert"]
        ),
        "Humanities": BucketInfo(
            archetype: "The Storyteller",
            description: "You make sense of the world through words, ideas, and creativity. Your ability to communicate and empathize is your superpower.",
            icon: "book.open", color: Color(red: 0.50, green: 0.20, blue: 0.45),
            majors: ["English / Writing", "Political Science", "Psychology", "Journalism", "Education", "Film / Media", "History", "Sociology"],
            classes: ["AP English Language", "AP US History", "AP Psychology", "Creative Writing", "Journalism", "AP Art History"],
            colleges: ["UF", "FSU", "University of Miami", "Rollins College", "New College of Florida", "Georgetown", "UNC Chapel Hill"]
        ),
        "Sports": BucketInfo(
            archetype: "The Competitor",
            description: "You thrive on discipline, competition, and physical excellence. Whether on the field or behind the scenes, athletics is your arena.",
            icon: "figure.run", color: Color(red: 0.55, green: 0.15, blue: 0.15),
            majors: ["Athletic Training", "Sports Management", "Kinesiology", "Physical Education", "Nutrition & Dietetics", "Exercise Science"],
            classes: ["AP Biology", "Anatomy & Physiology", "Health Science", "Sports Medicine", "AP Psychology", "PE Leadership"],
            colleges: ["UF", "FSU", "University of Tampa", "UCF", "Auburn University", "Florida Atlantic University", "Stetson University"]
        )
    ]
}

// MARK: - Quiz Questions

struct QuizItem {
    let question: String; let icon: String
    let options: [String]; let weights: [[String: Int]]
}

struct QuizData {
    static let questions: [QuizItem] = [
        QuizItem(question: "What excites you most about your future?", icon: "sparkles",
            options: ["Building systems, apps, or solving technical problems",
                      "Helping people heal or stay healthy",
                      "Building a business or leading a team",
                      "Creating stories, art, or understanding society",
                      "Competing, training, or excelling physically"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "In your free time, you're most likely to...", icon: "clock",
            options: ["Code, build gadgets, or watch tech videos",
                      "Volunteer, tutor someone, or study health topics",
                      "Research stocks, plan events, or hustle on a side project",
                      "Read, write, draw, or play music",
                      "Practice a sport, work out, or watch games"],
            weights: [["STEM":3],["Medical":2,"Humanities":1],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "Which school subject do you enjoy most?", icon: "book.closed",
            options: ["Math or Computer Science","Biology or Chemistry",
                      "Economics, Business, or History","English, Art, or Languages","Physical Education or Health Science"],
            weights: [["STEM":3],["Medical":2,"STEM":1],["Business":2,"Humanities":1],["Humanities":3],["Sports":3]]),
        QuizItem(question: "You feel most accomplished when you...", icon: "star",
            options: ["Figure out how something complex works","Help someone feel better",
                      "Hit a business or financial goal","Finish a creative project","Win a competition or beat a personal record"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "Which work environment appeals to you?", icon: "building.2",
            options: ["A tech startup, lab, or engineering firm","A hospital, clinic, or research center",
                      "A corporate office or my own startup","A studio, newsroom, or classroom","A sports facility or athletic training center"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "In group projects, you naturally...", icon: "person.3",
            options: ["Handle the technical or analytical parts","Make sure everyone's included and heard",
                      "Take charge and keep the team on track","Come up with the creative ideas","Push the team to compete harder"],
            weights: [["STEM":2,"Business":1],["Medical":2,"Humanities":1],["Business":3],["Humanities":3],["Sports":2,"Business":1]]),
        QuizItem(question: "Which income path fits your values?", icon: "dollarsign.circle",
            options: ["High income through tech or engineering","Stable meaningful income through healthcare",
                      "Potentially unlimited income through entrepreneurship","Meaningful work first — teaching, writing, social impact","Earn through athletic performance or sports management"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "Which challenge motivates you most?", icon: "flame",
            options: ["Debugging a complex system or building new tech","Diagnosing a condition or developing a treatment",
                      "Closing a deal or scaling a business","Publishing something that changes how people think","Qualifying for a national competition or going pro"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "Who would you most want to learn from?", icon: "person.badge.plus",
            options: ["A tech founder or NASA engineer","A brilliant doctor or public health leader",
                      "Warren Buffett or a successful startup founder","A great author, journalist, or transformative teacher","LeBron James or a top college coach"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]]),
        QuizItem(question: "Where do you see yourself at 30?", icon: "map",
            options: ["Leading a tech company or deep in engineering work",
                      "Practicing medicine, in research, or running a health clinic",
                      "Running my own company or managing a financial portfolio",
                      "Writing, teaching, making films, or doing social impact work",
                      "Competing professionally, coaching athletes, or in sports management"],
            weights: [["STEM":3],["Medical":3],["Business":3],["Humanities":3],["Sports":3]])
    ]
}

#Preview {
    NavigationStack { CareerQuizView() }
}
