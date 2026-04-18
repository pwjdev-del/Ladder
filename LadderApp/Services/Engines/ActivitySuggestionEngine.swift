import Foundation

// MARK: - Activity Suggestion Engine
// The heart of the 4+7 system: every student does 4 general activities
// (volunteering 120hrs, clubs, athletics, jobs) + 7 career-specific
// activities based on their career path (6 unique + Professional Interview).

@Observable
final class ActivitySuggestionEngine {
    static let shared = ActivitySuggestionEngine()
    private init() {}

    struct ActivitySuggestion: Identifiable {
        let id = UUID()
        let name: String
        let category: String  // "Volunteering", "Club", "Athletics", "Job", or career-specific
        let description: String
        let whyItMatters: String
        let howToStart: String
        let icon: String
        let isGeneral: Bool  // true = one of the 4 general, false = career-specific
        let targetHours: Int?  // e.g., 120 for volunteering
        let rating: Int?  // 1-10 importance rating (nil = unrated)

        init(name: String, category: String, description: String, whyItMatters: String, howToStart: String, icon: String, isGeneral: Bool, targetHours: Int?, rating: Int? = nil) {
            self.name = name
            self.category = category
            self.description = description
            self.whyItMatters = whyItMatters
            self.howToStart = howToStart
            self.icon = icon
            self.isGeneral = isGeneral
            self.targetHours = targetHours
            self.rating = rating
        }
    }

    // MARK: - Professional Interview (added to every career path)

    private let professionalInterview = ActivitySuggestion(
        name: "Professional Interview",
        category: "Research",
        description: "Interview a professional in your target field",
        whyItMatters: "Shows genuine career exploration. Record it (with consent) and reference it in essays. Demonstrates initiative beyond classroom learning.",
        howToStart: "Identify 3 professionals in your career area. LinkedIn is great for finding them. Prepare 10 thoughtful questions. Ask a parent or teacher to help make the introduction.",
        icon: "mic.circle.fill",
        isGeneral: false,
        targetHours: nil,
        rating: 8
    )

    // MARK: - 4 General Activities ALL Students Should Do

    let generalActivities: [ActivitySuggestion] = [
        ActivitySuggestion(
            name: "Community Volunteering",
            category: "Volunteering",
            description: "120+ hours of community service over 4 years",
            whyItMatters: "Shows commitment to community. Required for Florida Bright Futures (100 hrs). Colleges value sustained service over one-time events.",
            howToStart: "Contact your school's community service coordinator, or find opportunities at local nonprofits, food banks, hospitals, or churches.",
            icon: "heart.fill",
            isGeneral: true,
            targetHours: 120
        ),
        ActivitySuggestion(
            name: "Club Membership & Leadership",
            category: "Club",
            description: "Join at least 2 clubs. Aim for leadership in 1 by junior year.",
            whyItMatters: "Shows intellectual curiosity outside the classroom. Leadership roles (president, VP, treasurer) show initiative. 4-year commitment beats many 1-year memberships.",
            howToStart: "Attend your school's club fair. Join clubs aligned with your career interest + one just for fun.",
            icon: "person.3.fill",
            isGeneral: true,
            targetHours: nil
        ),
        ActivitySuggestion(
            name: "Athletics or Physical Activity",
            category: "Athletics",
            description: "Varsity sport, intramural, or regular physical activity",
            whyItMatters: "Demonstrates discipline, teamwork, and time management. Even non-varsity athletics count -- personal fitness routine, recreational leagues, or coaching.",
            howToStart: "Try out for a school sport, join intramural leagues, or start a personal fitness journey you can document.",
            icon: "figure.run",
            isGeneral: true,
            targetHours: nil
        ),
        ActivitySuggestion(
            name: "Part-Time Job or Internship",
            category: "Job",
            description: "Summer employment or year-round part-time work",
            whyItMatters: "Shows responsibility and real-world skills. Especially valued for students from working families. Work experience is an activity on Common App.",
            howToStart: "Look for summer jobs starting sophomore year. Ask teachers about internship connections related to your career interest.",
            icon: "briefcase.fill",
            isGeneral: true,
            targetHours: nil
        )
    ]

    // MARK: - 6 Career-Specific Activities Per Path

    func careerActivities(for path: String) -> [ActivitySuggestion] {
        let base = baseCareerActivities(for: path)
        // Every career path gets Professional Interview as 7th item
        if path != "General" && base.count > 1 {
            return base + [professionalInterview]
        }
        return base
    }

    private func baseCareerActivities(for path: String) -> [ActivitySuggestion] {
        switch path {
        case "STEM":
            return [
                ActivitySuggestion(name: "Science Fair Project", category: "Research", description: "Design and present an original experiment", whyItMatters: "Demonstrates scientific thinking and initiative. Regional/state wins are major resume boosters.", howToStart: "Pick a topic you're curious about. Ask a science teacher to mentor your project.", icon: "flask.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Coding / App Project", category: "Research", description: "Build a website, app, or software project", whyItMatters: "Shows technical skills and self-motivation. A finished project is better than any certificate.", howToStart: "Start with free courses (Khan Academy, freeCodeCamp). Build something that solves a real problem.", icon: "chevron.left.forwardslash.chevron.right", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Robotics Team", category: "Club", description: "Join FIRST Robotics, VEX, or a school robotics club", whyItMatters: "Combines engineering, teamwork, and competition. Top colleges actively recruit from robotics teams.", howToStart: "Check if your school has a robotics team. If not, start one -- that shows even more leadership.", icon: "gearshape.2.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Research Paper", category: "Research", description: "Write an independent research paper in your field", whyItMatters: "College-level work as a high schooler. Can be submitted to science journals or presented at symposiums.", howToStart: "Ask a science or math teacher to supervise. Use Google Scholar to find a topic gap.", icon: "doc.text.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "STEM Summer Camp/Program", category: "Internship", description: "Attend a summer STEM program at a university", whyItMatters: "Shows dedication during summer. Selective programs (MIT MITES, Stanford SIMR) are prestigious on applications.", howToStart: "Search for summer programs in your field. Apply early (deadlines are often January).", icon: "sun.max.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Math Competition", category: "Award", description: "AMC, MATHCOUNTS, or school math competitions", whyItMatters: "Quantifiable achievement that colleges recognize. Even participation shows interest in rigorous math.", howToStart: "Register for AMC 10/12 through your school's math department.", icon: "function", isGeneral: false, targetHours: nil)
            ]
        case "Medical":
            return [
                ActivitySuggestion(name: "Hospital/Clinic Volunteering", category: "Volunteering", description: "Volunteer at a local hospital, clinic, or nursing home", whyItMatters: "Direct healthcare exposure is critical for medical school. Shows you've seen the reality of healthcare.", howToStart: "Contact your local hospital's volunteer coordinator. Most require age 16+ and an application.", icon: "cross.case.fill", isGeneral: false, targetHours: 50),
                ActivitySuggestion(name: "Health Occupations Club", category: "Club", description: "Join HOSA or a health science club at school", whyItMatters: "HOSA competitions look great on applications. Connects you with other pre-med students.", howToStart: "Ask your school if HOSA or a health club exists. If not, start one with a biology teacher as advisor.", icon: "stethoscope", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Doctor/Healthcare Shadow", category: "Internship", description: "Shadow a doctor, dentist, nurse, or other healthcare professional", whyItMatters: "Shows initiative and genuine interest. You'll learn what the career actually looks like day-to-day.", howToStart: "Ask your family doctor, or ask parents/teachers if they know any healthcare professionals.", icon: "person.badge.clock.fill", isGeneral: false, targetHours: 20),
                ActivitySuggestion(name: "CPR/First Aid Certification", category: "Award", description: "Get certified in CPR, First Aid, or both", whyItMatters: "Practical healthcare skill that shows commitment. Low cost and quick to complete.", howToStart: "Red Cross offers courses online and in-person. Check if your school offers a free certification class.", icon: "heart.text.square.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Anatomy/Medical Study Group", category: "Club", description: "Form or join a study group focused on medical sciences", whyItMatters: "Self-directed learning shows passion. Peer study groups build collaboration skills.", howToStart: "Gather 3-5 classmates interested in medicine. Meet weekly to study biology, anatomy, or medical cases.", icon: "brain.head.profile", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Medical Summer Program", category: "Internship", description: "Attend a pre-med summer program", whyItMatters: "University-level medical exposure. Programs like NIH summer research are very prestigious.", howToStart: "Search 'pre-med summer programs for high school students'. Apply in January-February.", icon: "sun.max.fill", isGeneral: false, targetHours: nil)
            ]
        case "Business":
            return [
                ActivitySuggestion(name: "DECA / FBLA", category: "Club", description: "Join DECA, FBLA, or a business competition club", whyItMatters: "National business competitions are highly recognized. State/national awards stand out on applications.", howToStart: "Check if your school has DECA or FBLA. Compete in marketing, finance, or entrepreneurship events.", icon: "chart.bar.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Start a Small Business", category: "Research", description: "Launch a real business -- even small scale", whyItMatters: "Nothing says 'business-minded' like actually running a business. Revenue doesn't matter -- the experience does.", howToStart: "Identify a need at your school or community. Start with low investment: tutoring, reselling, social media management.", icon: "storefront.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Finance/Investment Club", category: "Club", description: "Join or start an investment/finance club", whyItMatters: "Shows interest in financial markets. Stock market simulations teach real skills.", howToStart: "Start a club that uses paper trading (Investopedia Simulator is free). Meet weekly to discuss markets.", icon: "dollarsign.circle.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Marketing / Social Media Project", category: "Research", description: "Run social media for a club, business, or nonprofit", whyItMatters: "Digital marketing is a real-world business skill. Growing a following shows measurable impact.", howToStart: "Offer to manage social media for a school club or local business. Track follower growth as a metric.", icon: "megaphone.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Entrepreneurship Camp", category: "Internship", description: "Attend a summer entrepreneurship or business program", whyItMatters: "Structured learning + networking. Programs at Wharton, Babson, etc. are prestigious.", howToStart: "Search 'high school business summer programs'. Many offer financial aid.", icon: "sun.max.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Stock Market Simulation", category: "Award", description: "Compete in a stock market game or business case competition", whyItMatters: "Competitive experience in finance. Winning or placing shows analytical ability.", howToStart: "Register for SIFMA's Stock Market Game or a similar competition through your school.", icon: "chart.line.uptrend.xyaxis", isGeneral: false, targetHours: nil)
            ]
        case "Humanities":
            return [
                ActivitySuggestion(name: "Writing Contest", category: "Award", description: "Enter essay, poetry, or short story competitions", whyItMatters: "Published or award-winning writing is a strong credential. Scholastic Art & Writing Awards are nationally recognized.", howToStart: "Submit to Scholastic Art & Writing Awards, local literary magazines, or Young Authors contests.", icon: "pencil.line", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Debate / Speech Team", category: "Club", description: "Join debate, Model UN, or speech & forensics", whyItMatters: "Develops argumentation, research, and public speaking -- skills valued in law, politics, and academia.", howToStart: "Join your school's debate team or Model UN club. Tournaments start in fall.", icon: "bubble.left.and.bubble.right.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Model United Nations", category: "Club", description: "Represent countries and debate global issues", whyItMatters: "Shows international awareness, diplomacy, and research skills. Awards at conferences are prestigious.", howToStart: "Join your school's MUN club or find a local conference to attend.", icon: "globe.americas.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Literary Magazine / Newspaper", category: "Club", description: "Write for or edit your school's publication", whyItMatters: "Editor roles show leadership. Published clips demonstrate writing ability better than any test.", howToStart: "Join the school newspaper, yearbook, or literary magazine. Aim for editor by junior year.", icon: "newspaper.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Community Theater", category: "Club", description: "Participate in school or community theater productions", whyItMatters: "Shows creativity, collaboration, and dedication. Both onstage and backstage roles count.", howToStart: "Audition for school plays, or volunteer as stage crew, set design, or costume team.", icon: "theatermasks.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Language Exchange / Cultural Club", category: "Club", description: "Join a foreign language or cultural exchange club", whyItMatters: "Bilingual skills and cultural awareness are highly valued. Shows global perspective.", howToStart: "Join your school's language club or find conversation partners online (Tandem, HelloTalk).", icon: "globe.badge.chevron.backward", isGeneral: false, targetHours: nil)
            ]
        case "Sports":
            return [
                ActivitySuggestion(name: "Varsity Athletics", category: "Athletics", description: "Compete on a varsity sports team", whyItMatters: "Demonstrates elite athletic commitment. Varsity letters are recognized on applications. NCAA eligibility requires specific academic standards.", howToStart: "Try out for your school's varsity team. If not ready, start with JV and work up.", icon: "trophy.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Coach/Mentor Younger Athletes", category: "Volunteering", description: "Coach youth sports or mentor younger players", whyItMatters: "Leadership through sports. Shows maturity, teaching ability, and community investment.", howToStart: "Volunteer at local youth leagues, summer camps, or your school's junior programs.", icon: "person.2.fill", isGeneral: false, targetHours: 30),
                ActivitySuggestion(name: "Sports Camp Counselor", category: "Job", description: "Work as a counselor at a sports summer camp", whyItMatters: "Combines athletics with leadership and employment. Great for sports management interest.", howToStart: "Apply to local sports camps in spring. Experience coaching preferred but not required.", icon: "figure.2.and.child.holdinghands", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Sports Science/Kinesiology Research", category: "Research", description: "Research project in biomechanics, nutrition, or exercise science", whyItMatters: "Unique combination of athletics and academics. Sets you apart from athletes who only play.", howToStart: "Ask a science teacher about a sports-related research project. Topics: hydration, training optimization, injury prevention.", icon: "waveform.path.ecg", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Fitness/Personal Training Certification", category: "Award", description: "Get CPT, group fitness, or sports nutrition certification", whyItMatters: "Professional credential as a teenager. Shows serious commitment to the field.", howToStart: "NASM, ACE, and ISSA offer certifications. Some have student discounts. Study for 2-3 months.", icon: "dumbbell.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Sports Journalism/Broadcasting", category: "Club", description: "Write about sports for school paper or start a sports podcast", whyItMatters: "Combines athletic knowledge with communication skills. Great for sports media/management careers.", howToStart: "Start a sports column for the school paper, or launch a podcast covering your school's athletics.", icon: "mic.fill", isGeneral: false, targetHours: nil)
            ]
        case "Law":
            return [
                ActivitySuggestion(name: "Mock Trial Team", category: "Club", description: "Join or start a mock trial team at your school", whyItMatters: "Direct simulation of legal practice. State and national competitions are highly recognized by law schools.", howToStart: "Check if your school has a mock trial team. If not, ask a history or government teacher to sponsor one.", icon: "building.columns.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Debate / Speech Team", category: "Club", description: "Join debate, Lincoln-Douglas, or public forum events", whyItMatters: "Develops argumentation, research, and public speaking -- core skills for any legal career.", howToStart: "Join your school's debate team. Tournaments start in fall. Practice argumentation daily.", icon: "bubble.left.and.bubble.right.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Model United Nations", category: "Club", description: "Represent countries and debate global policy issues", whyItMatters: "Shows international awareness, diplomacy, and policy research skills valued in law and government.", howToStart: "Join your school's MUN club or find a local conference to attend.", icon: "globe.americas.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Legal Internship / Shadow", category: "Internship", description: "Shadow a lawyer, judge, or legal professional", whyItMatters: "Shows genuine interest in law. First-hand courtroom or office experience is invaluable.", howToStart: "Contact local law firms or the county courthouse about shadowing opportunities for students.", icon: "person.badge.clock.fill", isGeneral: false, targetHours: 20),
                ActivitySuggestion(name: "Student Government", category: "Club", description: "Hold office in student government or student council", whyItMatters: "Demonstrates leadership, policy-making, and civic engagement -- all relevant to legal careers.", howToStart: "Run for a student government position. Start as a representative and work toward leadership roles.", icon: "person.3.sequence.fill", isGeneral: false, targetHours: nil),
                ActivitySuggestion(name: "Community Advocacy Project", category: "Volunteering", description: "Organize a civic engagement or advocacy campaign", whyItMatters: "Shows passion for justice and community impact. Demonstrates ability to research issues and mobilize action.", howToStart: "Identify a local issue you care about. Partner with a nonprofit or civic organization to create a campaign.", icon: "megaphone.fill", isGeneral: false, targetHours: nil)
            ]
        default:
            // Generic suggestions if no career path set
            return [
                ActivitySuggestion(name: "Take the Career Quiz", category: "Research", description: "Discover your career interests to get personalized activity suggestions", whyItMatters: "Knowing your career direction helps you choose activities that strengthen your applications.", howToStart: "Go to Profile and complete the Career Quiz to get your 6 personalized activity goals.", icon: "sparkles", isGeneral: false, targetHours: nil)
            ]
        }
    }

    // MARK: - Get All Suggestions (4 General + 7 Career-Specific)

    func allSuggestions(for path: String) -> [ActivitySuggestion] {
        generalActivities + careerActivities(for: path)
    }

    // MARK: - Career Path Keywords for College Matching

    static let careerKeywords: [String: [String]] = [
        "STEM": ["engineering", "computer science", "mathematics", "physics", "chemistry", "biology", "technology", "data science", "robotics", "aerospace", "mechanical", "electrical", "software", "stem"],
        "Medical": ["pre-med", "nursing", "biology", "biochemistry", "neuroscience", "health", "medical", "pharmaceutical", "kinesiology", "public health", "biomedical"],
        "Business": ["business", "finance", "accounting", "economics", "marketing", "management", "entrepreneurship", "mba", "commerce", "supply chain"],
        "Humanities": ["english", "history", "philosophy", "political science", "psychology", "sociology", "anthropology", "literature", "writing", "liberal arts", "communications", "journalism"],
        "Sports": ["kinesiology", "sports management", "exercise science", "athletic training", "physical education", "recreation", "sport"],
        "Law": ["pre-law", "criminal justice", "political science", "international relations", "legal studies", "paralegal", "public policy", "government", "law"]
    ]
}
