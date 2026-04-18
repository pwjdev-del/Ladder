import Foundation

// MARK: - Class Schedule AI Engine
// Generates personalized 7-period class schedules based on grade level,
// career path, GPA, completed courses, and Florida graduation requirements.

struct ClassRecommendation: Identifiable {
    let id = UUID()
    let period: Int
    let className: String
    let reason: String
    let isAP: Bool
    let isHonors: Bool
    let prerequisiteMet: Bool
    let subjectArea: String
}

struct ScheduleRecommendation {
    let semester: String
    let classes: [ClassRecommendation]
    let totalAPs: Int
    let totalHonors: Int
    let meetsGradRequirements: Bool
    let brightFuturesProgress: String?
}

@Observable
final class ClassScheduleAIEngine {

    // Florida graduation requirements (24 credits)
    let flGradRequirements: [String: Int] = [
        "English": 4, "Math": 4, "Science": 3, "Social Studies": 3,
        "World Language": 2, "Fine Arts": 1, "Physical Education": 1,
        "Elective": 6
    ]

    // MARK: - Generate Recommendation

    func generateRecommendation(
        grade: Int,
        careerPath: String?,
        currentGPA: Double?,
        completedCourses: [String],
        isFloridaResident: Bool
    ) -> ScheduleRecommendation {
        let gpa = currentGPA ?? 3.0
        let maxAPs = suggestedAPCount(gpa: gpa, grade: grade)
        let career = careerPath ?? "General"
        let classes = buildSchedule(grade: grade, career: career, gpa: gpa, maxAPs: maxAPs, completedCourses: completedCourses)

        let completedCredits = estimateCompletedCredits(grade: grade, completedCourses: completedCourses)
        let totalRequired = flGradRequirements.values.reduce(0, +)

        return ScheduleRecommendation(
            semester: "Fall \(2025 + (12 - grade))",
            classes: classes,
            totalAPs: classes.filter(\.isAP).count,
            totalHonors: classes.filter(\.isHonors).count,
            meetsGradRequirements: completedCredits + 7 >= totalRequired,
            brightFuturesProgress: isFloridaResident ? "\(completedCredits)/\(totalRequired) credits" : nil
        )
    }

    // MARK: - Build 7-Period Schedule

    private func buildSchedule(grade: Int, career: String, gpa: Double, maxAPs: Int, completedCourses: [String]) -> [ClassRecommendation] {
        switch grade {
        case 9:
            return buildGrade9Schedule(career: career, gpa: gpa)
        case 10:
            return buildGrade10Schedule(career: career, gpa: gpa, maxAPs: maxAPs, completedCourses: completedCourses)
        case 11:
            return buildGrade11Schedule(career: career, gpa: gpa, maxAPs: maxAPs, completedCourses: completedCourses)
        case 12:
            return buildGrade12Schedule(career: career, gpa: gpa, maxAPs: maxAPs, completedCourses: completedCourses)
        default:
            return buildGrade11Schedule(career: career, gpa: gpa, maxAPs: maxAPs, completedCourses: completedCourses)
        }
    }

    // MARK: - Grade 9 (Foundations)

    private func buildGrade9Schedule(career: String, gpa: Double) -> [ClassRecommendation] {
        let isHighAchiever = gpa >= 3.5
        return [
            ClassRecommendation(
                period: 1,
                className: isHighAchiever ? "English 1 Honors" : "English 1",
                reason: "Core English requirement for 9th grade. \(isHighAchiever ? "Honors track to build a strong GPA foundation." : "Builds reading and writing skills for all future coursework.")",
                isAP: false, isHonors: isHighAchiever, prerequisiteMet: true,
                subjectArea: "English"
            ),
            ClassRecommendation(
                period: 2,
                className: isHighAchiever ? "Algebra 1 Honors" : "Algebra 1",
                reason: "Foundation math course required for graduation. \(isHighAchiever ? "Honors prepares you for Geometry Honors next year." : "Sets the stage for Geometry and beyond.")",
                isAP: false, isHonors: isHighAchiever, prerequisiteMet: true,
                subjectArea: "Math"
            ),
            ClassRecommendation(
                period: 3,
                className: isHighAchiever ? "Biology 1 Honors" : "Biology 1",
                reason: careerScienceReason(career: career, course: "Biology", isHonors: isHighAchiever),
                isAP: false, isHonors: isHighAchiever, prerequisiteMet: true,
                subjectArea: "Science"
            ),
            ClassRecommendation(
                period: 4,
                className: "World History",
                reason: "Fulfills social studies requirement. Introduces global perspectives important for college readiness.",
                isAP: false, isHonors: false, prerequisiteMet: true,
                subjectArea: "Social Studies"
            ),
            ClassRecommendation(
                period: 5,
                className: "Spanish 1",
                reason: "Begins the 2-year world language requirement. Most Florida universities require 2 years of the same language.",
                isAP: false, isHonors: false, prerequisiteMet: true,
                subjectArea: "World Language"
            ),
            ClassRecommendation(
                period: 6,
                className: "Physical Education / HOPE",
                reason: "Florida requires 1 credit of PE with health (HOPE). Best to complete early to free up elective space later.",
                isAP: false, isHonors: false, prerequisiteMet: true,
                subjectArea: "Physical Education"
            ),
            ClassRecommendation(
                period: 7,
                className: careerElective(career: career, grade: 9),
                reason: careerElectiveReason(career: career, grade: 9),
                isAP: false, isHonors: false, prerequisiteMet: true,
                subjectArea: "Elective"
            )
        ]
    }

    // MARK: - Grade 10 (Start Honors Track)

    private func buildGrade10Schedule(career: String, gpa: Double, maxAPs: Int, completedCourses: [String]) -> [ClassRecommendation] {
        let isHighAchiever = gpa >= 3.3
        var apCount = 0

        var classes: [ClassRecommendation] = []

        // Period 1: English
        let useAPWorld = maxAPs > 0 && isHighAchiever
        classes.append(ClassRecommendation(
            period: 1,
            className: isHighAchiever ? "English 2 Honors" : "English 2",
            reason: "Continues the English sequence. \(isHighAchiever ? "Honors prepares you for AP Language next year." : "Strengthens analytical writing skills.")",
            isAP: false, isHonors: isHighAchiever, prerequisiteMet: true,
            subjectArea: "English"
        ))

        // Period 2: Math
        classes.append(ClassRecommendation(
            period: 2,
            className: isHighAchiever ? "Geometry Honors" : "Geometry",
            reason: "Follows Algebra 1. \(isHighAchiever ? "Honors track keeps you on pace for AP Calculus by senior year." : "Required for graduation and college admission.")",
            isAP: false, isHonors: isHighAchiever,
            prerequisiteMet: completedCourses.contains("Algebra 1") || completedCourses.contains("Algebra 1 Honors") || completedCourses.isEmpty,
            subjectArea: "Math"
        ))

        // Period 3: Science
        classes.append(ClassRecommendation(
            period: 3,
            className: isHighAchiever ? "Chemistry Honors" : "Chemistry",
            reason: careerScienceReason(career: career, course: "Chemistry", isHonors: isHighAchiever),
            isAP: false, isHonors: isHighAchiever,
            prerequisiteMet: true,
            subjectArea: "Science"
        ))

        // Period 4: Social Studies (potentially AP)
        if useAPWorld && apCount < maxAPs {
            apCount += 1
            classes.append(ClassRecommendation(
                period: 4,
                className: "AP World History",
                reason: "Your first AP course builds college-level skills. Strong readers with a \(String(format: "%.1f", gpa)) GPA are well-prepared for this exam.",
                isAP: true, isHonors: false, prerequisiteMet: true,
                subjectArea: "Social Studies"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 4,
                className: "US History",
                reason: "Core social studies requirement. Understanding American history is foundational for civics and government courses.",
                isAP: false, isHonors: false, prerequisiteMet: true,
                subjectArea: "Social Studies"
            ))
        }

        // Period 5: World Language
        classes.append(ClassRecommendation(
            period: 5,
            className: "Spanish 2",
            reason: "Completes the 2-year world language requirement. Consistent language study strengthens college applications.",
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "World Language"
        ))

        // Period 6: Fine Arts
        classes.append(ClassRecommendation(
            period: 6,
            className: fineArtsElective(career: career),
            reason: "Fulfills the 1-credit fine arts graduation requirement. \(career == "Humanities" || career == "Liberal Arts" ? "Directly aligned with your creative interests." : "Provides creative balance to your academic schedule.")",
            isAP: false, isHonors: false, prerequisiteMet: true,
            subjectArea: "Fine Arts"
        ))

        // Period 7: Career elective
        classes.append(ClassRecommendation(
            period: 7,
            className: careerElective(career: career, grade: 10),
            reason: careerElectiveReason(career: career, grade: 10),
            isAP: false, isHonors: false, prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        return classes
    }

    // MARK: - Grade 11 (AP Time)

    private func buildGrade11Schedule(career: String, gpa: Double, maxAPs: Int, completedCourses: [String]) -> [ClassRecommendation] {
        var apCount = 0
        var classes: [ClassRecommendation] = []

        // Period 1: English (AP Lang if ready)
        if maxAPs > apCount && gpa >= 3.0 {
            apCount += 1
            classes.append(ClassRecommendation(
                period: 1,
                className: "AP English Language",
                reason: "The most valuable junior-year AP. Develops argumentative writing skills used in every college course and on the SAT.",
                isAP: true, isHonors: false, prerequisiteMet: true,
                subjectArea: "English"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 1,
                className: "English 3 Honors",
                reason: "Continues the English sequence at honors level. Focuses on American literature and analytical writing.",
                isAP: false, isHonors: true, prerequisiteMet: true,
                subjectArea: "English"
            ))
        }

        // Period 2: Math
        if maxAPs > apCount && gpa >= 3.5 && (career == "Engineering" || career == "STEM" || career == "Medical") {
            apCount += 1
            classes.append(ClassRecommendation(
                period: 2,
                className: "AP Calculus AB",
                reason: "Essential for \(career) majors. Demonstrates quantitative readiness to top universities.",
                isAP: true, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Math"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 2,
                className: gpa >= 3.3 ? "Pre-Calculus Honors" : "Algebra 2",
                reason: gpa >= 3.3 ? "Honors track keeps you on pace for AP Calculus senior year." : "Completes the core math sequence required for graduation.",
                isAP: false, isHonors: gpa >= 3.3,
                prerequisiteMet: true,
                subjectArea: "Math"
            ))
        }

        // Period 3: Science (career-aligned AP)
        if maxAPs > apCount {
            apCount += 1
            let (sciName, sciReason) = careerAPScience(career: career)
            classes.append(ClassRecommendation(
                period: 3,
                className: sciName,
                reason: sciReason,
                isAP: true, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Science"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 3,
                className: "Physics Honors",
                reason: "Rounds out the science trio (Bio, Chem, Physics). Many colleges expect all three for competitive applicants.",
                isAP: false, isHonors: true,
                prerequisiteMet: true,
                subjectArea: "Science"
            ))
        }

        // Period 4: Social Studies (APUSH)
        if maxAPs > apCount && gpa >= 3.0 {
            apCount += 1
            classes.append(ClassRecommendation(
                period: 4,
                className: "AP US History",
                reason: "One of the most respected AP courses. Strong writing and reading comprehension at your GPA level make you a great fit.",
                isAP: true, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Social Studies"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 4,
                className: "US History Honors",
                reason: "Fulfills the American History requirement at an advanced level without the AP workload.",
                isAP: false, isHonors: true,
                prerequisiteMet: true,
                subjectArea: "Social Studies"
            ))
        }

        // Period 5: World Language 3 or career elective
        let hasLanguage2 = completedCourses.contains(where: { $0.lowercased().contains("spanish 2") || $0.lowercased().contains("french 2") })
        if hasLanguage2 || completedCourses.isEmpty {
            classes.append(ClassRecommendation(
                period: 5,
                className: "Spanish 3 Honors",
                reason: "A third year of language significantly strengthens college applications, especially for selective schools.",
                isAP: false, isHonors: true,
                prerequisiteMet: true,
                subjectArea: "World Language"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 5,
                className: careerElective(career: career, grade: 11),
                reason: careerElectiveReason(career: career, grade: 11),
                isAP: false, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Elective"
            ))
        }

        // Period 6: Career-aligned elective
        classes.append(ClassRecommendation(
            period: 6,
            className: careerElective(career: career, grade: 11),
            reason: careerElectiveReason(career: career, grade: 11),
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        // Period 7: Additional elective
        classes.append(ClassRecommendation(
            period: 7,
            className: secondaryElective(career: career, grade: 11),
            reason: "Adds depth to your transcript and demonstrates well-roundedness beyond core academics.",
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        return classes
    }

    // MARK: - Grade 12 (Senior APs + Career Focus)

    private func buildGrade12Schedule(career: String, gpa: Double, maxAPs: Int, completedCourses: [String]) -> [ClassRecommendation] {
        var apCount = 0
        var classes: [ClassRecommendation] = []

        // Period 1: English (AP Lit)
        if maxAPs > apCount && gpa >= 3.0 {
            apCount += 1
            classes.append(ClassRecommendation(
                period: 1,
                className: "AP English Literature",
                reason: "Capstone English course. Literary analysis skills transfer directly to college-level humanities courses.",
                isAP: true, isHonors: false, prerequisiteMet: true,
                subjectArea: "English"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 1,
                className: "English 4 Honors",
                reason: "Completes the 4-year English requirement at honors level.",
                isAP: false, isHonors: true, prerequisiteMet: true,
                subjectArea: "English"
            ))
        }

        // Period 2: Math (AP Calc or Stats)
        if maxAPs > apCount && gpa >= 3.3 {
            apCount += 1
            let hasCalcAB = completedCourses.contains(where: { $0.lowercased().contains("calculus ab") })
            classes.append(ClassRecommendation(
                period: 2,
                className: hasCalcAB ? "AP Calculus BC" : "AP Statistics",
                reason: hasCalcAB
                    ? "Extends your calculus foundation. BC credit can place you into Calc III in college."
                    : "Data literacy is essential across all fields. AP Stats is highly practical for \(career) careers.",
                isAP: true, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Math"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 2,
                className: "Pre-Calculus" + (gpa >= 3.0 ? " Honors" : ""),
                reason: "Completes math sequence. A strong senior math course signals college readiness.",
                isAP: false, isHonors: gpa >= 3.0,
                prerequisiteMet: true,
                subjectArea: "Math"
            ))
        }

        // Period 3: Career AP Science
        if maxAPs > apCount && (career == "Engineering" || career == "STEM" || career == "Medical") {
            apCount += 1
            let (sciName, sciReason) = seniorAPScience(career: career, completedCourses: completedCourses)
            classes.append(ClassRecommendation(
                period: 3,
                className: sciName,
                reason: sciReason,
                isAP: true, isHonors: false,
                prerequisiteMet: true,
                subjectArea: "Science"
            ))
        } else {
            classes.append(ClassRecommendation(
                period: 3,
                className: seniorScienceElective(career: career),
                reason: "Advanced science elective that aligns with your interests and strengthens your transcript.",
                isAP: false, isHonors: true,
                prerequisiteMet: true,
                subjectArea: "Science"
            ))
        }

        // Period 4: Government / Economics
        classes.append(ClassRecommendation(
            period: 4,
            className: maxAPs > apCount && gpa >= 3.2 ? "AP Government & Politics" : "US Government / Economics",
            reason: maxAPs > apCount && gpa >= 3.2
                ? "Fulfills the civics requirement with AP rigor. Valuable for understanding policy regardless of career."
                : "Required civics and economics credit for Florida graduation.",
            isAP: maxAPs > apCount && gpa >= 3.2, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Social Studies"
        ))
        if maxAPs > apCount && gpa >= 3.2 { apCount += 1 }

        // Period 5: Career capstone elective
        classes.append(ClassRecommendation(
            period: 5,
            className: careerElective(career: career, grade: 12),
            reason: careerElectiveReason(career: career, grade: 12),
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        // Period 6: Additional elective
        classes.append(ClassRecommendation(
            period: 6,
            className: secondaryElective(career: career, grade: 12),
            reason: "Rounds out your senior schedule and provides opportunities for exploration or leadership.",
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        // Period 7: Free elective or study hall
        classes.append(ClassRecommendation(
            period: 7,
            className: seniorCapstone(career: career),
            reason: "Senior capstone or independent study that demonstrates initiative and passion to admissions officers.",
            isAP: false, isHonors: false,
            prerequisiteMet: true,
            subjectArea: "Elective"
        ))

        return classes
    }

    // MARK: - AP Count Logic

    private func suggestedAPCount(gpa: Double, grade: Int) -> Int {
        switch (gpa, grade) {
        case (3.5..., 11...12): return 3
        case (3.5..., 10): return 2
        case (3.0..<3.5, 11...12): return 2
        case (3.0..<3.5, 10): return 1
        default: return 0
        }
    }

    // MARK: - Credit Estimation

    private func estimateCompletedCredits(grade: Int, completedCourses: [String]) -> Int {
        if !completedCourses.isEmpty { return completedCourses.count }
        // Estimate based on grade
        switch grade {
        case 9: return 0
        case 10: return 7
        case 11: return 14
        case 12: return 21
        default: return 14
        }
    }

    // MARK: - Career-Aligned Course Helpers

    private func careerScienceReason(career: String, course: String, isHonors: Bool) -> String {
        switch career {
        case "Medical", "Healthcare":
            return "\(course) is foundational for pre-med pathways. \(isHonors ? "Honors level signals readiness for AP sciences." : "Builds the scientific literacy needed for healthcare careers.")"
        case "Engineering", "STEM":
            return "\(course) develops analytical thinking critical for STEM fields. \(isHonors ? "Honors prepares you for AP-level coursework." : "A strong science base is essential for engineering programs.")"
        default:
            return "Fulfills the science graduation requirement. \(isHonors ? "Honors level strengthens your overall transcript." : "Develops scientific literacy valued by all colleges.")"
        }
    }

    private func careerAPScience(career: String) -> (String, String) {
        switch career {
        case "Medical", "Healthcare":
            return ("AP Biology", "The premier AP for pre-med students. Covers cellular biology, genetics, and ecology at college depth.")
        case "Engineering", "STEM":
            return ("AP Physics 1", "Physics is the backbone of engineering. AP-level mastery demonstrates readiness for university STEM programs.")
        case "Business":
            return ("AP Environmental Science", "Sustainability knowledge is increasingly valued in business. APES has a manageable workload alongside other rigorous courses.")
        default:
            return ("AP Environmental Science", "Approachable AP science that builds environmental literacy relevant to many career fields.")
        }
    }

    private func seniorAPScience(career: String, completedCourses: [String]) -> (String, String) {
        let hadAPBio = completedCourses.contains(where: { $0.contains("AP Bio") })
        let hadAPPhysics = completedCourses.contains(where: { $0.contains("AP Physics") })
        switch career {
        case "Medical", "Healthcare":
            return hadAPBio
                ? ("AP Chemistry", "Completes the AP science trifecta for pre-med. Organic chemistry in college will build on this foundation.")
                : ("AP Biology", "Essential for pre-med. Demonstrates commitment to the healthcare pathway.")
        case "Engineering", "STEM":
            return hadAPPhysics
                ? ("AP Physics C: Mechanics", "Calculus-based physics is the gold standard for engineering applicants.")
                : ("AP Physics 1", "Core physics for engineering. Develops problem-solving skills used daily in engineering programs.")
        default:
            return ("AP Environmental Science", "Approachable senior AP that complements your schedule without excessive workload.")
        }
    }

    private func seniorScienceElective(career: String) -> String {
        switch career {
        case "Medical", "Healthcare": return "Anatomy & Physiology Honors"
        case "Engineering", "STEM": return "Physics Honors"
        case "Business": return "Environmental Science Honors"
        default: return "Marine Science Honors"
        }
    }

    private func fineArtsElective(career: String) -> String {
        switch career {
        case "Engineering", "STEM": return "Digital Art & Design"
        case "Medical", "Healthcare": return "Photography"
        case "Business": return "Graphic Design"
        case "Humanities", "Liberal Arts": return "Studio Art"
        default: return "Art Foundations"
        }
    }

    private func careerElective(career: String, grade: Int) -> String {
        switch (career, grade) {
        case ("Medical", 9), ("Healthcare", 9): return "Health Science Foundations"
        case ("Medical", 10), ("Healthcare", 10): return "Biomedical Science"
        case ("Medical", 11), ("Healthcare", 11): return "Medical Terminology"
        case ("Medical", 12), ("Healthcare", 12): return "Clinical Internship / CNA Prep"
        case ("Engineering", 9), ("STEM", 9): return "Introduction to Engineering"
        case ("Engineering", 10), ("STEM", 10): return "Computer Science Principles"
        case ("Engineering", 11), ("STEM", 11): return "AP Computer Science A"
        case ("Engineering", 12), ("STEM", 12): return "Engineering Design & Development"
        case ("Business", 9): return "Introduction to Business"
        case ("Business", 10): return "Accounting 1"
        case ("Business", 11): return "Entrepreneurship"
        case ("Business", 12): return "AP Macroeconomics"
        case ("Humanities", 9), ("Liberal Arts", 9): return "Creative Writing"
        case ("Humanities", 10), ("Liberal Arts", 10): return "Journalism"
        case ("Humanities", 11), ("Liberal Arts", 11): return "AP Psychology"
        case ("Humanities", 12), ("Liberal Arts", 12): return "AP Art History"
        default: return grade <= 10 ? "Digital Literacy" : "Leadership / Student Government"
        }
    }

    private func careerElectiveReason(career: String, grade: Int) -> String {
        switch career {
        case "Medical", "Healthcare":
            return grade <= 10
                ? "Introduces healthcare career pathways early. Shows sustained interest on college applications."
                : "Advanced health science coursework directly supports pre-med applications and clinical understanding."
        case "Engineering", "STEM":
            return grade <= 10
                ? "Builds technical foundations that connect math and science to real-world problem solving."
                : "Demonstrates deep STEM commitment. Hands-on engineering experience is valued by top programs."
        case "Business":
            return grade <= 10
                ? "Early business exposure helps you understand career options and develop financial literacy."
                : "Advanced business coursework shows entrepreneurial initiative and practical skills."
        case "Humanities", "Liberal Arts":
            return grade <= 10
                ? "Creative and analytical skills from humanities electives strengthen writing and critical thinking."
                : "Advanced humanities electives demonstrate intellectual curiosity and depth of engagement."
        default:
            return "Elective that broadens your skill set and adds variety to your transcript."
        }
    }

    private func secondaryElective(career: String, grade: Int) -> String {
        switch career {
        case "Medical", "Healthcare": return grade == 11 ? "Psychology Honors" : "Nutrition Science"
        case "Engineering", "STEM": return grade == 11 ? "Robotics" : "Data Science"
        case "Business": return grade == 11 ? "Marketing" : "Personal Finance"
        case "Humanities", "Liberal Arts": return grade == 11 ? "Philosophy" : "Film Studies"
        default: return grade == 11 ? "Speech & Debate" : "Peer Mentoring"
        }
    }

    private func seniorCapstone(career: String) -> String {
        switch career {
        case "Medical", "Healthcare": return "Senior Research Project (Health Sciences)"
        case "Engineering", "STEM": return "Senior Research Project (STEM)"
        case "Business": return "Senior Internship (Business)"
        case "Humanities", "Liberal Arts": return "Senior Thesis (Humanities)"
        default: return "Senior Seminar / Independent Study"
        }
    }
}
