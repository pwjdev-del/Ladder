import Foundation
import SwiftData

// MARK: - Career Explorer ViewModel
// Manages career cluster data, filtering, and career detail selection.

@Observable
final class CareerExplorerViewModel {

    // MARK: - State

    var selectedCluster: CareerClusterData? = nil
    var selectedCareer: CareerEntry? = nil
    var searchText: String = ""

    // MARK: - All Career Clusters (6 clusters x 5 careers = 30 entries)

    static let allClusters: [CareerClusterData] = [
        stemCluster,
        healthcareCluster,
        businessCluster,
        artsCluster,
        educationCluster,
        lawCluster,
    ]

    // MARK: - Filtered Careers

    var filteredCareers: [CareerEntry] {
        guard let cluster = selectedCluster else { return [] }
        if searchText.isEmpty { return cluster.careers }
        return cluster.careers.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.requiredDegrees.joined().localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Cluster matching from student profile

    func clusterForStudent(_ profile: StudentProfileModel?) -> CareerClusterData? {
        guard let path = profile?.careerPath?.lowercased() else { return nil }
        return Self.allClusters.first { cluster in
            path.contains(cluster.name.lowercased()) ||
            cluster.keywords.contains(where: { path.contains($0) })
        }
    }

    func initializeFromProfile(_ profile: StudentProfileModel?) {
        if selectedCluster == nil {
            selectedCluster = clusterForStudent(profile) ?? Self.allClusters.first
        }
    }

    // MARK: - Top colleges matching a major (from SwiftData)

    func topColleges(for career: CareerEntry, context: ModelContext) -> [CollegeModel] {
        let descriptor = FetchDescriptor<CollegeModel>()
        guard let colleges = try? context.fetch(descriptor) else { return [] }

        let relatedPrograms = career.recommendedMajors.map { $0.lowercased() }
        let matched = colleges.filter { college in
            college.programs.contains(where: { program in
                relatedPrograms.contains(where: { major in
                    program.lowercased().contains(major.lowercased())
                })
            })
        }
        .sorted { ($0.medianEarnings ?? 0) > ($1.medianEarnings ?? 0) }

        return Array(matched.prefix(10))
    }
}

// MARK: - Career Cluster Data Model

struct CareerClusterData: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String // semantic identifier
    let keywords: [String]
    let careers: [CareerEntry]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CareerClusterData, rhs: CareerClusterData) -> Bool { lhs.id == rhs.id }
}

// MARK: - Individual Career Entry

struct CareerEntry: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let medianSalary: String
    let growthRate: String
    let educationNeeded: String
    let description: String
    let requiredDegrees: [String]
    let recommendedMajors: [String]
    let skills: [String]
    let dayInTheLife: String

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CareerEntry, rhs: CareerEntry) -> Bool { lhs.id == rhs.id }
}

// MARK: - STEM Cluster

extension CareerExplorerViewModel {
    static let stemCluster = CareerClusterData(
        name: "STEM / Engineering",
        icon: "cpu",
        color: "primary",
        keywords: ["stem", "engineering", "computer", "science", "tech", "software", "data"],
        careers: [
            CareerEntry(
                title: "Software Engineer",
                medianSalary: "$120K",
                growthRate: "25%",
                educationNeeded: "BS Computer Science",
                description: "Software engineers design, develop, and maintain software applications and systems. They work across the full stack, from databases to user interfaces, solving complex problems with code.",
                requiredDegrees: ["Bachelor's in Computer Science", "Bachelor's in Software Engineering"],
                recommendedMajors: ["Computer Science", "Software Engineering", "Information Technology"],
                skills: ["Python", "Java", "System Design", "Data Structures", "Algorithms", "Git"],
                dayInTheLife: "Morning standup with the team, then deep coding on a new feature. After lunch, a design review for the upcoming API. End the day debugging a tricky performance issue and pushing a fix."
            ),
            CareerEntry(
                title: "Data Scientist",
                medianSalary: "$108K",
                growthRate: "36%",
                educationNeeded: "BS/MS Statistics or CS",
                description: "Data scientists extract insights from massive datasets using statistical modeling, machine learning, and visualization. They help companies make data-driven decisions across every industry.",
                requiredDegrees: ["Bachelor's in Statistics", "Master's in Data Science"],
                recommendedMajors: ["Statistics", "Data Science", "Computer Science", "Mathematics"],
                skills: ["Python", "R", "SQL", "Machine Learning", "Tableau", "Statistical Modeling"],
                dayInTheLife: "Start by reviewing overnight model training results. Mid-morning meeting with product to discuss user behavior patterns. Afternoon building a prediction model and creating dashboards for leadership."
            ),
            CareerEntry(
                title: "Mechanical Engineer",
                medianSalary: "$96K",
                growthRate: "10%",
                educationNeeded: "BS Mechanical Engineering",
                description: "Mechanical engineers design, analyze, and manufacture mechanical systems ranging from tiny medical devices to massive power plants. They combine physics and materials science to build the physical world.",
                requiredDegrees: ["Bachelor's in Mechanical Engineering"],
                recommendedMajors: ["Mechanical Engineering", "Aerospace Engineering"],
                skills: ["CAD/SolidWorks", "Thermodynamics", "FEA", "Prototyping", "GD&T"],
                dayInTheLife: "Morning reviewing CAD models for a new component. Run stress simulations before lunch. Afternoon in the lab testing prototypes and documenting results for the engineering team."
            ),
            CareerEntry(
                title: "Cybersecurity Analyst",
                medianSalary: "$112K",
                growthRate: "33%",
                educationNeeded: "BS Cybersecurity or CS",
                description: "Cybersecurity analysts protect organizations from digital threats by monitoring networks, investigating breaches, and implementing security protocols. They are the digital guardians of company data.",
                requiredDegrees: ["Bachelor's in Cybersecurity", "Bachelor's in Computer Science"],
                recommendedMajors: ["Cybersecurity", "Computer Science", "Information Technology"],
                skills: ["Network Security", "Penetration Testing", "SIEM Tools", "Incident Response", "Risk Assessment"],
                dayInTheLife: "Morning review of overnight security alerts and threat intelligence feeds. Conduct a vulnerability scan on production servers. Afternoon training session with employees on phishing awareness."
            ),
            CareerEntry(
                title: "Biomedical Engineer",
                medianSalary: "$100K",
                growthRate: "5%",
                educationNeeded: "BS Biomedical Engineering",
                description: "Biomedical engineers combine engineering principles with medical sciences to design healthcare equipment, devices, and software. They create prosthetics, imaging systems, and drug delivery mechanisms.",
                requiredDegrees: ["Bachelor's in Biomedical Engineering", "Master's in Biomedical Engineering"],
                recommendedMajors: ["Biomedical Engineering", "Bioengineering", "Electrical Engineering"],
                skills: ["MATLAB", "Medical Device Design", "Biomechanics", "Regulatory Affairs (FDA)", "Signal Processing"],
                dayInTheLife: "Start by reviewing clinical trial data for a new device. Work with surgeons on ergonomic improvements to a surgical tool. Afternoon preparing FDA submission documentation."
            ),
        ]
    )
}

// MARK: - Healthcare Cluster

extension CareerExplorerViewModel {
    static let healthcareCluster = CareerClusterData(
        name: "Healthcare",
        icon: "heart.text.square",
        color: "error",
        keywords: ["health", "medical", "medicine", "nursing", "doctor", "pre-med"],
        careers: [
            CareerEntry(
                title: "Physician (MD/DO)",
                medianSalary: "$229K",
                growthRate: "3%",
                educationNeeded: "MD/DO + Residency",
                description: "Physicians diagnose and treat illnesses, prescribe medications, and guide patients through complex medical decisions. After 4 years of medical school, they complete 3-7 years of residency training.",
                requiredDegrees: ["Doctor of Medicine (MD)", "Doctor of Osteopathic Medicine (DO)"],
                recommendedMajors: ["Biology", "Biochemistry", "Chemistry", "Neuroscience"],
                skills: ["Clinical Diagnosis", "Patient Communication", "Research Methods", "Anatomy", "Pharmacology"],
                dayInTheLife: "Early morning hospital rounds checking on patients. Clinic hours seeing 15-20 patients. Afternoon reviewing lab results and coordinating care with specialists."
            ),
            CareerEntry(
                title: "Registered Nurse (BSN)",
                medianSalary: "$81K",
                growthRate: "6%",
                educationNeeded: "BSN Nursing",
                description: "Registered nurses provide and coordinate patient care, educate patients about health conditions, and serve as frontline healthcare providers in hospitals, clinics, and community settings.",
                requiredDegrees: ["Bachelor of Science in Nursing (BSN)"],
                recommendedMajors: ["Nursing", "Health Sciences"],
                skills: ["Patient Assessment", "IV Therapy", "Medication Administration", "EMR Systems", "Critical Thinking"],
                dayInTheLife: "Receive shift handoff report on 4-5 patients. Administer medications, check vitals, and coordinate with doctors. Document care in the electronic health record throughout the shift."
            ),
            CareerEntry(
                title: "Pharmacist",
                medianSalary: "$132K",
                growthRate: "-2%",
                educationNeeded: "PharmD",
                description: "Pharmacists dispense prescription medications, counsel patients on drug interactions, and collaborate with physicians to optimize medication therapy for chronic and acute conditions.",
                requiredDegrees: ["Doctor of Pharmacy (PharmD)"],
                recommendedMajors: ["Pharmaceutical Sciences", "Chemistry", "Biology"],
                skills: ["Pharmacology", "Drug Interactions", "Patient Counseling", "Compounding", "Clinical Research"],
                dayInTheLife: "Review and verify prescriptions for safety. Counsel patients on new medications and side effects. Afternoon collaborating with physicians on a patient's complex drug regimen."
            ),
            CareerEntry(
                title: "Physical Therapist",
                medianSalary: "$97K",
                growthRate: "15%",
                educationNeeded: "DPT (Doctorate)",
                description: "Physical therapists help patients recover from injuries and surgeries through exercise programs, manual therapy, and movement education. They work in hospitals, clinics, and sports facilities.",
                requiredDegrees: ["Doctor of Physical Therapy (DPT)"],
                recommendedMajors: ["Exercise Science", "Kinesiology", "Biology"],
                skills: ["Manual Therapy", "Exercise Prescription", "Gait Analysis", "Patient Motivation", "Anatomy"],
                dayInTheLife: "Morning sessions with post-surgery patients on mobility exercises. Evaluate a new patient with chronic back pain. Afternoon sports rehab sessions with a college athlete."
            ),
            CareerEntry(
                title: "Physician Assistant",
                medianSalary: "$126K",
                growthRate: "28%",
                educationNeeded: "Master's PA Studies",
                description: "Physician assistants practice medicine under physician supervision, diagnosing illnesses, prescribing medications, and performing procedures. They work in every medical specialty.",
                requiredDegrees: ["Master of Physician Assistant Studies"],
                recommendedMajors: ["Biology", "Health Sciences", "Chemistry"],
                skills: ["Clinical Assessment", "Suturing", "Diagnostic Imaging", "Prescription Management", "Teamwork"],
                dayInTheLife: "See patients independently in clinic, diagnosing and treating common conditions. Assist in a minor surgical procedure. End the day reviewing test results and following up with patients."
            ),
        ]
    )
}

// MARK: - Business Cluster

extension CareerExplorerViewModel {
    static let businessCluster = CareerClusterData(
        name: "Business / Finance",
        icon: "briefcase",
        color: "tertiary",
        keywords: ["business", "finance", "marketing", "management", "accounting", "entrepreneur"],
        careers: [
            CareerEntry(
                title: "Financial Analyst",
                medianSalary: "$95K",
                growthRate: "9%",
                educationNeeded: "BS Finance or Economics",
                description: "Financial analysts evaluate investment opportunities, analyze financial data, and create models to guide business decisions. They work at banks, investment firms, and corporations.",
                requiredDegrees: ["Bachelor's in Finance", "Bachelor's in Economics"],
                recommendedMajors: ["Finance", "Economics", "Accounting", "Mathematics"],
                skills: ["Financial Modeling", "Excel/VBA", "Valuation", "Bloomberg Terminal", "Presentation Skills"],
                dayInTheLife: "Morning reviewing market news and updating financial models. Build a DCF valuation for a potential acquisition target. Afternoon presenting investment recommendations to senior management."
            ),
            CareerEntry(
                title: "Marketing Manager",
                medianSalary: "$140K",
                growthRate: "10%",
                educationNeeded: "BS/MBA Marketing",
                description: "Marketing managers develop brand strategies, oversee advertising campaigns, and analyze consumer behavior to drive revenue growth. They blend creativity with data to reach target audiences.",
                requiredDegrees: ["Bachelor's in Marketing", "MBA"],
                recommendedMajors: ["Marketing", "Business Administration", "Communications"],
                skills: ["Digital Marketing", "SEO/SEM", "Brand Strategy", "Analytics", "Content Strategy"],
                dayInTheLife: "Review campaign performance dashboards over coffee. Lead a creative brainstorm for a product launch. Afternoon analyzing customer survey data and adjusting the Q3 media plan."
            ),
            CareerEntry(
                title: "Management Consultant",
                medianSalary: "$105K",
                growthRate: "11%",
                educationNeeded: "BS/MBA Business",
                description: "Management consultants advise organizations on strategy, operations, and efficiency. They analyze problems, develop solutions, and help clients implement changes to improve performance.",
                requiredDegrees: ["Bachelor's in Business", "MBA"],
                recommendedMajors: ["Business Administration", "Economics", "Engineering"],
                skills: ["Problem Solving", "Data Analysis", "Presentation", "Stakeholder Management", "Strategy Frameworks"],
                dayInTheLife: "Fly to a client site Monday morning. Conduct interviews with executives to diagnose operational bottlenecks. Build a recommendation deck and present findings to the C-suite Friday."
            ),
            CareerEntry(
                title: "Accountant (CPA)",
                medianSalary: "$79K",
                growthRate: "6%",
                educationNeeded: "BS Accounting + CPA",
                description: "Accountants prepare and examine financial records, ensure regulatory compliance, and advise clients on tax strategy. CPAs are licensed professionals trusted with financial integrity.",
                requiredDegrees: ["Bachelor's in Accounting"],
                recommendedMajors: ["Accounting", "Finance"],
                skills: ["GAAP", "Tax Preparation", "Auditing", "QuickBooks/SAP", "Attention to Detail"],
                dayInTheLife: "Morning reconciling accounts for a corporate client. Review tax filings for compliance. Afternoon meeting with a small business owner to plan year-end tax strategy."
            ),
            CareerEntry(
                title: "Product Manager",
                medianSalary: "$130K",
                growthRate: "12%",
                educationNeeded: "BS/MBA Any Field",
                description: "Product managers define the vision and strategy for products, working at the intersection of business, technology, and design. They prioritize features, manage roadmaps, and ship products users love.",
                requiredDegrees: ["Bachelor's in any field", "MBA (preferred)"],
                recommendedMajors: ["Business", "Computer Science", "Design", "Engineering"],
                skills: ["Roadmap Planning", "User Research", "A/B Testing", "Agile/Scrum", "Cross-Functional Leadership"],
                dayInTheLife: "Stand-up with engineering at 9am. Analyze user funnel data to identify drop-off points. Afternoon user interviews to validate a new feature concept. End the day updating the product roadmap."
            ),
        ]
    )
}

// MARK: - Arts & Design Cluster

extension CareerExplorerViewModel {
    static let artsCluster = CareerClusterData(
        name: "Arts & Design",
        icon: "paintpalette",
        color: "secondary",
        keywords: ["art", "design", "creative", "film", "music", "graphic", "ux", "media"],
        careers: [
            CareerEntry(
                title: "UX/UI Designer",
                medianSalary: "$95K",
                growthRate: "16%",
                educationNeeded: "BS Design or HCI",
                description: "UX/UI designers create intuitive, beautiful digital experiences by researching user needs, wireframing interfaces, and prototyping interactions. They bridge the gap between users and technology.",
                requiredDegrees: ["Bachelor's in Design", "Bachelor's in Human-Computer Interaction"],
                recommendedMajors: ["Graphic Design", "Human-Computer Interaction", "Visual Communication"],
                skills: ["Figma", "User Research", "Wireframing", "Prototyping", "Design Systems", "Accessibility"],
                dayInTheLife: "Morning usability testing session with 5 participants. Synthesize findings and update wireframes in Figma. Afternoon design review with engineering to ensure pixel-perfect implementation."
            ),
            CareerEntry(
                title: "Graphic Designer",
                medianSalary: "$58K",
                growthRate: "3%",
                educationNeeded: "BFA Graphic Design",
                description: "Graphic designers create visual concepts using software and hand sketching to communicate ideas that inspire, inform, and captivate consumers. They develop brand identities, marketing materials, and digital content.",
                requiredDegrees: ["Bachelor of Fine Arts in Graphic Design"],
                recommendedMajors: ["Graphic Design", "Visual Arts", "Communication Design"],
                skills: ["Adobe Creative Suite", "Typography", "Brand Identity", "Layout Design", "Color Theory"],
                dayInTheLife: "Start with mood boarding for a new brand identity project. Design social media assets for an upcoming campaign. Afternoon preparing print-ready files for a product packaging redesign."
            ),
            CareerEntry(
                title: "Film/Video Editor",
                medianSalary: "$62K",
                growthRate: "12%",
                educationNeeded: "BS Film or Media Arts",
                description: "Film editors assemble raw footage into polished stories, adding effects, sound, and pacing to create compelling narratives. They work on movies, TV shows, commercials, and digital content.",
                requiredDegrees: ["Bachelor's in Film Production", "Bachelor's in Media Arts"],
                recommendedMajors: ["Film Production", "Media Arts", "Digital Media"],
                skills: ["Premiere Pro", "DaVinci Resolve", "After Effects", "Color Grading", "Storytelling"],
                dayInTheLife: "Review dailies from yesterday's shoot. Rough-cut a 3-minute scene, adjusting pacing and transitions. Afternoon color grading session and adding sound effects to the final cut."
            ),
            CareerEntry(
                title: "Architect",
                medianSalary: "$85K",
                growthRate: "5%",
                educationNeeded: "B.Arch or M.Arch",
                description: "Architects design buildings and structures that are functional, safe, and aesthetically inspiring. They blend art with engineering, considering sustainability, code compliance, and user experience.",
                requiredDegrees: ["Bachelor of Architecture (B.Arch)", "Master of Architecture (M.Arch)"],
                recommendedMajors: ["Architecture", "Environmental Design"],
                skills: ["AutoCAD", "Revit", "3D Modeling", "Building Codes", "Sustainable Design", "Sketching"],
                dayInTheLife: "Morning client meeting to review schematic designs. Work in Revit refining floor plans and elevations. Afternoon site visit to check construction progress against blueprints."
            ),
            CareerEntry(
                title: "Game Designer",
                medianSalary: "$78K",
                growthRate: "11%",
                educationNeeded: "BS Game Design or CS",
                description: "Game designers create the rules, mechanics, and narratives that make video games engaging. They prototype gameplay loops, balance difficulty, and collaborate with artists and programmers.",
                requiredDegrees: ["Bachelor's in Game Design", "Bachelor's in Computer Science"],
                recommendedMajors: ["Game Design", "Computer Science", "Interactive Media"],
                skills: ["Unity/Unreal Engine", "Level Design", "Game Balancing", "Narrative Design", "C#/C++"],
                dayInTheLife: "Morning playtest session gathering feedback on a new level. Iterate on puzzle mechanics based on player data. Afternoon design meeting with artists on character animation and environment art."
            ),
        ]
    )
}

// MARK: - Education Cluster

extension CareerExplorerViewModel {
    static let educationCluster = CareerClusterData(
        name: "Education",
        icon: "graduationcap",
        color: "primary",
        keywords: ["education", "teaching", "teacher", "professor", "counseling", "school"],
        careers: [
            CareerEntry(
                title: "High School Teacher",
                medianSalary: "$62K",
                growthRate: "1%",
                educationNeeded: "BS Education + License",
                description: "High school teachers instruct students in specific subjects, develop lesson plans, and mentor young people during a critical stage of their development. They shape futures every single day.",
                requiredDegrees: ["Bachelor's in Education", "Teaching Certificate"],
                recommendedMajors: ["Education", "Subject-Specific Major + Education Minor"],
                skills: ["Lesson Planning", "Classroom Management", "Differentiated Instruction", "Assessment Design", "Mentoring"],
                dayInTheLife: "Teach 5 periods of AP Biology with a lab session. Grade quizzes during planning period. After school, advise the science club and meet with a parent about their child's progress."
            ),
            CareerEntry(
                title: "School Counselor",
                medianSalary: "$60K",
                growthRate: "5%",
                educationNeeded: "Master's in Counseling",
                description: "School counselors support students' academic, career, and social-emotional development. They help with course selection, college applications, conflict resolution, and mental health referrals.",
                requiredDegrees: ["Master's in School Counseling"],
                recommendedMajors: ["Psychology", "Counseling", "Education"],
                skills: ["Active Listening", "Crisis Intervention", "College Advising", "Group Facilitation", "Data Analysis"],
                dayInTheLife: "Morning individual check-ins with at-risk students. Lead a college application workshop for juniors. Afternoon reviewing transcripts and writing recommendation letters."
            ),
            CareerEntry(
                title: "College Professor",
                medianSalary: "$84K",
                growthRate: "8%",
                educationNeeded: "PhD in Field",
                description: "College professors teach undergraduate and graduate courses, conduct original research, publish in academic journals, and mentor the next generation of scholars and professionals.",
                requiredDegrees: ["PhD in relevant field"],
                recommendedMajors: ["Any field (PhD required)"],
                skills: ["Research Methods", "Academic Writing", "Lecturing", "Grant Writing", "Peer Review"],
                dayInTheLife: "Morning lecture on molecular biology to 120 students. Office hours helping students with research proposals. Afternoon in the lab running experiments and revising a journal manuscript."
            ),
            CareerEntry(
                title: "Instructional Designer",
                medianSalary: "$73K",
                growthRate: "11%",
                educationNeeded: "Master's in Ed Tech",
                description: "Instructional designers create engaging learning experiences for schools, corporations, and online platforms. They apply learning science to design courses, e-learning modules, and training programs.",
                requiredDegrees: ["Master's in Instructional Design", "Master's in Educational Technology"],
                recommendedMajors: ["Educational Technology", "Instructional Design", "Curriculum & Instruction"],
                skills: ["Articulate/Storyline", "Learning Management Systems", "Storyboarding", "Assessment Design", "Video Production"],
                dayInTheLife: "Morning storyboarding an interactive onboarding module. Build assessment questions aligned to learning objectives. Afternoon user testing an e-learning prototype with actual learners."
            ),
            CareerEntry(
                title: "Special Education Teacher",
                medianSalary: "$63K",
                growthRate: "4%",
                educationNeeded: "BS Special Education",
                description: "Special education teachers work with students who have learning disabilities, behavioral challenges, or physical disabilities. They create individualized education programs (IEPs) to help every student succeed.",
                requiredDegrees: ["Bachelor's in Special Education", "Teaching Certificate"],
                recommendedMajors: ["Special Education", "Psychology", "Education"],
                skills: ["IEP Development", "Behavior Management", "Adaptive Instruction", "Collaboration", "Patience"],
                dayInTheLife: "Morning small-group reading intervention session. Write IEP progress reports during planning time. Afternoon co-teach a math class with a general education teacher."
            ),
        ]
    )
}

// MARK: - Law & Public Policy Cluster

extension CareerExplorerViewModel {
    static let lawCluster = CareerClusterData(
        name: "Law & Public Policy",
        icon: "building.columns",
        color: "primary",
        keywords: ["law", "legal", "policy", "government", "political", "attorney", "pre-law"],
        careers: [
            CareerEntry(
                title: "Attorney (JD)",
                medianSalary: "$135K",
                growthRate: "8%",
                educationNeeded: "JD + Bar Exam",
                description: "Attorneys advise clients on legal matters, represent them in court, draft contracts, and navigate complex regulatory frameworks. Specializations range from corporate law to criminal defense.",
                requiredDegrees: ["Juris Doctor (JD)"],
                recommendedMajors: ["Political Science", "English", "Philosophy", "History"],
                skills: ["Legal Research", "Oral Argument", "Contract Drafting", "Negotiation", "Critical Analysis"],
                dayInTheLife: "Morning reviewing case files and prepping for a deposition. Draft a motion to dismiss over lunch. Afternoon in court presenting arguments before a judge."
            ),
            CareerEntry(
                title: "Paralegal",
                medianSalary: "$60K",
                growthRate: "4%",
                educationNeeded: "BS/Associate's Paralegal",
                description: "Paralegals assist attorneys by conducting legal research, organizing case files, drafting documents, and managing case logistics. They are essential to the efficient operation of law firms.",
                requiredDegrees: ["Associate's or Bachelor's in Paralegal Studies"],
                recommendedMajors: ["Paralegal Studies", "Criminal Justice", "Political Science"],
                skills: ["Legal Research", "Document Management", "Westlaw/LexisNexis", "Writing", "Organization"],
                dayInTheLife: "Morning pulling case precedents from Westlaw for an upcoming trial. Organize discovery documents and flag key exhibits. Afternoon drafting a summary of deposition testimony."
            ),
            CareerEntry(
                title: "Policy Analyst",
                medianSalary: "$75K",
                growthRate: "6%",
                educationNeeded: "Master's in Public Policy",
                description: "Policy analysts research and evaluate government policies, propose reforms, and advise elected officials and agencies. They use data and evidence to shape laws that affect millions.",
                requiredDegrees: ["Master's in Public Policy (MPP)", "Master's in Public Administration (MPA)"],
                recommendedMajors: ["Political Science", "Public Policy", "Economics"],
                skills: ["Policy Research", "Data Analysis", "Legislative Writing", "Stakeholder Engagement", "Public Speaking"],
                dayInTheLife: "Morning analyzing the fiscal impact of a proposed education bill. Brief a state senator's office on key findings. Afternoon writing a policy memo with recommendations for committee review."
            ),
            CareerEntry(
                title: "FBI / Federal Agent",
                medianSalary: "$90K",
                growthRate: "3%",
                educationNeeded: "BS + Academy Training",
                description: "Federal agents investigate crimes ranging from cybercrime and terrorism to white-collar fraud. They conduct surveillance, gather evidence, and work with prosecutors to build cases.",
                requiredDegrees: ["Bachelor's in Criminal Justice", "Bachelor's in Accounting or CS (preferred)"],
                recommendedMajors: ["Criminal Justice", "Accounting", "Computer Science", "Political Science"],
                skills: ["Investigation", "Surveillance", "Report Writing", "Firearms Proficiency", "Interviewing"],
                dayInTheLife: "Morning briefing on an ongoing financial fraud investigation. Conduct witness interviews and review bank records. Afternoon coordinating with prosecutors on evidence presentation."
            ),
            CareerEntry(
                title: "Urban Planner",
                medianSalary: "$81K",
                growthRate: "7%",
                educationNeeded: "Master's Urban Planning",
                description: "Urban planners develop land use plans and programs to help create communities, accommodate growth, and revitalize physical facilities. They balance housing, transportation, and environmental needs.",
                requiredDegrees: ["Master's in Urban Planning"],
                recommendedMajors: ["Urban Planning", "Geography", "Environmental Studies", "Architecture"],
                skills: ["GIS Mapping", "Zoning Regulations", "Community Engagement", "Environmental Review", "Transportation Planning"],
                dayInTheLife: "Morning reviewing rezoning applications and environmental impact statements. Lead a public hearing on a proposed mixed-use development. Afternoon updating the city's comprehensive plan maps in GIS."
            ),
        ]
    )
}
