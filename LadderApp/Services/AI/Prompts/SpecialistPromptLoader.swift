import Foundation

// Loads the 8 specialist system prompts from the bundled resource
// `sia_specialist_prompts.md` (canonical source: Ladder_AI_Master_Prompts_v2.md).
//
// At load time:
//   1. Read the file once, cache.
//   2. Split into sections by the `# PROMPT N — ...` headings.
//   3. Extract the fenced code block body of each section (between ``` markers).
//   4. Rename all "Ladder" -> "Sia" (brand rename).
//
// Fallback: if the bundle file is missing, fall back to `SpecialistPrompts`
// constants so the app keeps running in dev.

enum SpecialistPromptLoader {

    // Mapping between our SessionType and the PROMPT N headings in the .md file.
    private static let headingIndex: [SessionType: Int] = [
        .counselor:       1,  // Personal Counselor
        .satTutor:        2,
        .essayCoach:      3,
        .interviewCoach:  4,
        .careerExplorer:  5,
        .classPlanner:    6,
        .scoreAdvisor:    7
        // PROMPT 8 (Ambient Guide) is rules-engine, not a chat session.
    ]

    /// Returns the specialist prompt body for the given session type.
    /// Loads from bundled markdown when available; otherwise falls back
    /// to the skeleton constants in `SpecialistPrompts`.
    static func prompt(for type: SessionType) -> String {
        if let n = headingIndex[type], let body = cached.sections[n] {
            return body
        }
        return SpecialistPrompts.prompt(for: type)
    }

    /// Ambient nudge rules prompt (PROMPT 8). Used by SiaEngine for nudge copy.
    static var ambientGuidePrompt: String {
        cached.sections[8] ?? ""
    }

    // MARK: - Cached parse

    private struct ParsedPrompts {
        let sections: [Int: String]
    }

    private static let cached: ParsedPrompts = {
        guard let url = Bundle.main.url(forResource: "sia_specialist_prompts", withExtension: "md"),
              let raw = try? String(contentsOf: url, encoding: .utf8) else {
            return ParsedPrompts(sections: [:])
        }
        return ParsedPrompts(sections: parse(raw))
    }()

    // Parse: find each `# PROMPT N — …` heading, then extract the first fenced
    // code block that follows (the prompt body lives inside ```...```).
    private static func parse(_ raw: String) -> [Int: String] {
        var result: [Int: String] = [:]
        let lines = raw.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            let line = lines[i]
            if let n = promptNumber(in: line) {
                // Find opening ``` after the heading.
                var j = i + 1
                while j < lines.count && !lines[j].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    j += 1
                }
                guard j < lines.count else { i += 1; continue }
                let start = j + 1
                var k = start
                while k < lines.count && !lines[k].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    k += 1
                }
                let body = lines[start..<k].joined(separator: "\n")
                result[n] = brandRename(body)
                i = k + 1
            } else {
                i += 1
            }
        }
        return result
    }

    // Matches: `# PROMPT 3 — ESSAY COACH` (em-dash). Tolerates hyphen too.
    private static func promptNumber(in line: String) -> Int? {
        guard line.hasPrefix("# PROMPT ") else { return nil }
        let after = line.dropFirst("# PROMPT ".count)
        let digits = after.prefix { $0.isNumber }
        return Int(digits)
    }

    // Rename all brand references from "Ladder" to "Sia".
    // Preserves word boundaries so we don't corrupt unrelated strings
    // (there are none in these prompts, but be safe).
    private static func brandRename(_ s: String) -> String {
        var out = s
        let replacements: [(String, String)] = [
            ("Ladder's ",          "Sia's "),
            ("Ladder AI",          "Sia"),
            ("You are Ladder ",    "You are Sia "),
            ("You are Ladder\n",   "You are Sia\n"),
            ("You are Ladder —",   "You are Sia —"),
            ("— Ladder",           "— Sia"),
            ("\"Ladder\"",         "\"Sia\""),
            ("hand you back to Ladder", "hand you back to Sia"),
            ("back to Ladder",     "back to Sia")
        ]
        for (from, to) in replacements {
            out = out.replacingOccurrences(of: from, with: to)
        }
        return out
    }
}
