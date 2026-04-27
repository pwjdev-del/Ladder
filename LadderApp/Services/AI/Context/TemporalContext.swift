import Foundation

// "What time it is for THIS student." Computed at prompt-assembly time.
// Drives grade-and-month-aware advice: 9th-grader-September != 12th-grader-November.

struct TemporalContext: Codable, Equatable {
    var today: Date
    var academicYear: String              // "2025-26"
    var currentGradeMonth: Int            // 1-10 (Aug=1 .. May=10)
    var currentMonth: String              // "October"
    var weeksUntilNextSAT: Int?
    var weeksUntilNextEssayDeadline: Int?
    var weeksUntilNextAppDeadline: Int?
    var seasonalPriorities: [String]      // grade+month -> priority strings
    var upcomingDeadlines: [Deadline]
}

struct Deadline: Codable, Equatable {
    var title: String
    var date: Date
    var kind: String                      // "SAT", "EA", "ED", "RD", "FAFSA", "Essay", "Scholarship"
    var college: String?
    var daysAway: Int
}

enum TemporalContextBuilder {

    static func build(for student: StudentContext, now: Date = Date()) -> TemporalContext {
        let cal = Calendar(identifier: .gregorian)
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)

        // Academic year runs Aug -> May of the following year.
        let academicYear: String = {
            if month >= 8 { return "\(year)-\(String((year + 1) % 100))" }
            return "\(year - 1)-\(String(year % 100))"
        }()

        // Month index within the academic year (Aug=1, Sep=2, ..., May=10).
        let gradeMonth: Int = {
            let offset = month >= 8 ? month - 7 : month + 5
            return max(1, min(10, offset))
        }()

        let monthName = DateFormatter().monthSymbols[month - 1]

        let upcoming = buildUpcoming(from: student, now: now)

        let satWeeks = weeksBetween(now, student.nextTestDate)
        let essayWeeks = weeksBetween(now, upcoming.first(where: { $0.kind == "Essay" })?.date)
        let appWeeks = weeksBetween(now, upcoming.first(where: { ["EA", "ED", "RD"].contains($0.kind) })?.date)

        return TemporalContext(
            today: now,
            academicYear: academicYear,
            currentGradeMonth: gradeMonth,
            currentMonth: monthName,
            weeksUntilNextSAT: satWeeks,
            weeksUntilNextEssayDeadline: essayWeeks,
            weeksUntilNextAppDeadline: appWeeks,
            seasonalPriorities: seasonalPriorities(grade: student.grade, month: month),
            upcomingDeadlines: upcoming
        )
    }

    // MARK: - Seasonal calendar (grade + month -> what matters now)
    // Hand-tuned priorities. Safe defaults; app can override from server.

    private static func seasonalPriorities(grade: Int, month: Int) -> [String] {
        switch (grade, month) {
        case (9, 8...9):   return ["Join 1-2 clubs", "Set up GPA tracker", "Explore careers"]
        case (9, 10...12): return ["Log volunteer hours", "Build study habits"]
        case (9, 1...5):   return ["Retake career quiz in spring", "Plan 10th-grade classes"]

        case (10, 8...9):  return ["PSAT prep", "Career quiz retake", "Add 1 career-specific activity"]
        case (10, 10...12):return ["PSAT (October)", "Deepen 1-2 activities", "First SAT practice test"]
        case (10, 1...5):  return ["Register for first real SAT", "Plan 11th-grade rigor"]

        case (11, 8...9):  return ["Lock college list shape", "Start SAT prep seriously", "Shortlist rec-letter teachers"]
        case (11, 10...12):return ["Take SAT", "Request rec letters", "Narrow college list", "Start personal statement"]
        case (11, 1...5):  return ["Retake SAT if needed", "Campus visits", "Essay brainstorm"]

        case (12, 8...9):  return ["Finalize college list", "Draft personal statement", "EA/ED strategy"]
        case (12, 10):     return ["EA/ED essays due", "Teacher rec letters confirmed", "FAFSA opens Oct 1"]
        case (12, 11):     return ["Submit EA/ED", "Finalize FAFSA", "RD essays"]
        case (12, 12...3): return ["RD applications", "Scholarship deadlines", "Aid comparison"]
        case (12, 4...5):  return ["Compare aid packages", "Decision deadline May 1", "Enrollment deposits"]

        default: return []
        }
    }

    private static func buildUpcoming(from student: StudentContext, now: Date) -> [Deadline] {
        var list: [Deadline] = []

        if let sat = student.nextTestDate {
            list.append(Deadline(title: "SAT", date: sat, kind: "SAT", college: nil, daysAway: daysBetween(now, sat)))
        }

        for app in student.applicationStatus {
            guard let d = app.deadline else { continue }
            list.append(Deadline(
                title: "\(app.college) \(app.type)",
                date: d,
                kind: app.type,
                college: app.college,
                daysAway: daysBetween(now, d)
            ))
        }

        return list
            .filter { $0.daysAway >= 0 }
            .sorted { $0.date < $1.date }
    }

    private static func daysBetween(_ from: Date, _ to: Date) -> Int {
        Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }

    private static func weeksBetween(_ from: Date, _ to: Date?) -> Int? {
        guard let to else { return nil }
        let days = daysBetween(from, to)
        return days >= 0 ? days / 7 : nil
    }
}
