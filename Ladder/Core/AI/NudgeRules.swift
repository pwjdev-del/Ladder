import Foundation

// Rules engine for the ambient nudge system — Prompt 8 of the master prompts.
// Pure functions: StudentContext + TemporalContext + SchoolContext -> [NudgeIntent].
// SiaEngine calls this for Home cards ("3 things this week") and for push
// notifications (filtered to critical/high).

struct NudgeIntent: Equatable {
    let title: String
    let rawMessage: String
    let priority: SiaPriority
    let specialist: SessionType?
    let deepLink: String?
    let topic: String           // for behavior tracking / dedupe
}

enum NudgeRules {

    static func evaluate(
        student: StudentContext,
        temporal: TemporalContext,
        school: SchoolContext
    ) -> [NudgeIntent] {
        var out: [NudgeIntent] = []

        let month = temporal.currentMonth      // e.g. "October"
        let grade = student.grade
        let monthIdx = monthNumber(temporal.currentMonth)

        // ─── GRADE 9 ───
        if grade == 9 {
            if student.clubs.isEmpty && monthIdx >= 10 {
                out.append(.init(
                    title: "Pick one club",
                    rawMessage: "Pick one club this week. Any club. Starting matters more than picking the perfect one.",
                    priority: .normal, specialist: nil, deepLink: nil, topic: "clubs"
                ))
            }
            if student.volunteerHours == 0 && monthIdx >= 11 {
                out.append(.init(
                    title: "Start logging hours",
                    rawMessage: "Start tracking volunteer hours now. Spreading them over 4 years is way easier than senior-year cram.",
                    priority: .low, specialist: nil, deepLink: nil, topic: "volunteer"
                ))
            }
            if student.careerQuizHistory.isEmpty && monthIdx >= 1 && monthIdx <= 5 {
                out.append(.init(
                    title: "Take the career quiz",
                    rawMessage: "12 minutes — it personalizes the rest of the app to you.",
                    priority: .low, specialist: .careerExplorer, deepLink: "career/quiz", topic: "careerQuiz"
                ))
            }
        }

        // ─── GRADE 10 ───
        if grade == 10 {
            if month == "October" {
                out.append(.init(
                    title: "PSAT this month",
                    rawMessage: "Register if you haven't. It's practice — no score pressure, but National Merit eligibility kicks in next year.",
                    priority: .normal, specialist: nil, deepLink: nil, topic: "psat"
                ))
            }
            let ecCount = student.clubs.count + student.jobs.count + student.athletics.count + student.careerElectives.count
            if ecCount < 3 && monthIdx >= 1 && monthIdx <= 5 {
                out.append(.init(
                    title: "Deepen your activities",
                    rawMessage: "Colleges want depth in 2-3 activities. You're at \(ecCount) — time to deepen or add one.",
                    priority: .normal, specialist: nil, deepLink: nil, topic: "ec-depth"
                ))
            }
            if student.satScores.isEmpty && monthIdx >= 4 && monthIdx <= 8 {
                out.append(.init(
                    title: "Start SAT prep",
                    rawMessage: "Sophomore summer is SAT-prep season. Want to set a target and build a plan?",
                    priority: .normal, specialist: .satTutor, deepLink: "sat", topic: "sat-start"
                ))
            }
        }

        // ─── GRADE 11 (critical year) ───
        if grade == 11 {
            if student.satScores.isEmpty, let weeks = temporal.weeksUntilNextSAT, weeks < 12 {
                let waiver = student.feeWaiverEligible ? " You qualify for a fee waiver — your counselor can set it up." : ""
                out.append(.init(
                    title: "Register for the SAT",
                    rawMessage: "Register for the upcoming SAT this week.\(waiver)",
                    priority: .critical, specialist: .satTutor, deepLink: "sat/register", topic: "sat-register"
                ))
            }
            if student.savedColleges.count < 5 && monthIdx >= 1 && monthIdx <= 5 {
                out.append(.init(
                    title: "Build your college list",
                    rawMessage: "Aim for 8-12 schools by summer. You're at \(student.savedColleges.count).",
                    priority: .normal, specialist: nil, deepLink: "colleges", topic: "college-list"
                ))
            }
            if student.recLetters.isEmpty && monthIdx >= 4 && monthIdx <= 5 {
                out.append(.init(
                    title: "Ask for rec letters",
                    rawMessage: "Ask 2 11th-grade teachers for rec letters before summer — they know you best, and they'll have summer to write thoughtfully.",
                    priority: .high, specialist: nil, deepLink: nil, topic: "rec-letters"
                ))
            }
            if student.state == "FL", let bf = student.brightFuturesStatus, !bf.hoursMet, let gap = bf.hoursGapToFAS {
                out.append(.init(
                    title: "Bright Futures hours",
                    rawMessage: "\(Int(gap)) more volunteer hours for Bright Futures FAS. Doable if you start now.",
                    priority: .high, specialist: nil, deepLink: "activities", topic: "bf-hours"
                ))
            }
        }

        // ─── GRADE 12 (application season) ───
        if grade == 12 {
            if month == "September" {
                out.append(.init(
                    title: "Common App is open",
                    rawMessage: "Common App is live. Start with your activities list and personal info. Submit rolling-admissions apps early — scholarships are first-come-first-served.",
                    priority: .high, specialist: nil, deepLink: "applications", topic: "commonapp"
                ))
            }
            if (student.fafsaStatus ?? "not started") != "filed" && monthIdx >= 10 {
                out.append(.init(
                    title: "File FAFSA",
                    rawMessage: "FAFSA is open. Filing Oct-Nov = ~2x the grant money vs late filers. Your parents need 30 min + last year's taxes.",
                    priority: .critical, specialist: nil, deepLink: "financial/fafsa", topic: "fafsa"
                ))
            }
            if let weeks = temporal.weeksUntilNextAppDeadline, weeks < 8 {
                let emptyEssay = student.essays.contains { $0.wordCount == 0 }
                if emptyEssay {
                    out.append(.init(
                        title: "EA deadline approaching",
                        rawMessage: "Your next application deadline is ~\(weeks) weeks out and you have an empty essay draft. Start today — draft 1 is supposed to be bad.",
                        priority: .critical, specialist: .essayCoach, deepLink: "essays", topic: "essay-urgent"
                    ))
                }
            }
        }

        // ─── CROSS-GRADE ───
        if student.state == "FL",
           let bf = student.brightFuturesStatus,
           !bf.satMet,
           let gap = bf.satGapToFAS,
           grade >= 11 {
            out.append(.init(
                title: "SAT gap for Bright Futures",
                rawMessage: "You're \(gap) points from Bright Futures FAS (1330 target).\(temporal.weeksUntilNextSAT.map { " \($0) weeks until the next test." } ?? "")",
                priority: .high, specialist: .satTutor, deepLink: "sat", topic: "bf-sat"
            ))
        }

        // Deadline-driven generic alert for anything within 14 days.
        for dl in temporal.upcomingDeadlines where dl.daysAway <= 14 && dl.daysAway >= 0 {
            out.append(.init(
                title: "\(dl.title) in \(dl.daysAway)d",
                rawMessage: "\(dl.title) deadline in \(dl.daysAway) days. Tap to review status.",
                priority: dl.daysAway <= 7 ? .critical : .high,
                specialist: nil,
                deepLink: dl.college.map { "colleges/\($0)" },
                topic: "deadline-\(dl.kind)"
            ))
        }

        return out
    }

    // MARK: - Helpers

    private static let monthNames = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]

    private static func monthNumber(_ name: String) -> Int {
        (monthNames.firstIndex(of: name) ?? 0) + 1
    }
}
