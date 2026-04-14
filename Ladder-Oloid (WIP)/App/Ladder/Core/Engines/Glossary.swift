import Foundation

/// College admissions terminology glossary — used for inline tooltips
/// to demystify acronyms like EA, ED, LOCI, FAFSA, CSS Profile.
enum Glossary {
    static let terms: [String: String] = [
        "EA": "Early Action — apply early (Nov 1) and hear back early (December). Non-binding: you can still apply elsewhere.",
        "ED": "Early Decision — apply early (Nov 1) and hear back early. Binding: if accepted, you must enroll.",
        "REA": "Restrictive Early Action — apply early but cannot apply ED elsewhere. Non-binding.",
        "RD": "Regular Decision — standard application deadline, usually January. Decisions in March-April.",
        "RA": "Rolling Admission — apply anytime, hear back within weeks.",
        "LOCI": "Letter of Continued Interest — sent after waitlist or deferral to express continued interest in the school.",
        "Common App": "The Common Application — single online form used by 1,000+ colleges. Includes a 650-word personal essay.",
        "Coalition App": "Coalition for College Application — alternative to Common App used by 150+ schools.",
        "FAFSA": "Free Application for Federal Student Aid — required for federal grants/loans/work-study. Opens Oct 1 of senior year.",
        "CSS Profile": "College Scholarship Service Profile — additional financial aid form required by ~250 private colleges.",
        "EFC / SAI": "Expected Family Contribution / Student Aid Index — what FAFSA estimates your family can pay annually.",
        "Net Price": "Total cost minus grants/scholarships — what you actually pay.",
        "Yield Protection": "When a college denies a strong applicant they assume will go elsewhere — to protect their yield rate.",
        "Demonstrated Interest": "Showing a college you're seriously interested via visits, emails, interviews. Some schools track this.",
        "Holistic Review": "Admissions process considering the whole student (essays, activities, character) — not just grades/scores.",
        "Test Optional": "School doesn't require SAT/ACT scores. Test Blind = won't even look at them.",
        "Need-Blind": "Admissions decision made without considering financial need.",
        "Need-Aware": "Admissions may consider ability to pay (most colleges).",
        "Reach School": "Acceptance rate is low compared to your stats — a stretch.",
        "Match School": "Your stats fit the typical accepted student profile.",
        "Safety School": "Your stats are well above the average admitted student.",
        "Gap Year": "Year between high school and college — for travel, work, service.",
        "Transcript": "Official record of your high school grades. Sent by your counselor.",
        "Recommendation Letter (LOR)": "Letter from teacher/counselor about your character/work.",
        "Common Data Set (CDS)": "Standardized data file colleges publish — includes acceptance rate, score ranges, etc."
    ]

    static func lookup(_ term: String) -> String? {
        terms[term]
    }

    /// All known terms sorted alphabetically
    static var sortedTerms: [(term: String, definition: String)] {
        terms.sorted { $0.key < $1.key }.map { (term: $0.key, definition: $0.value) }
    }
}
