# LADDER — Full App Audit Prompt
# Open Claude Code in your Xcode project terminal and paste the prompt below.
# It will audit every part of the app, find bugs, find risks, and fix what it can.

---

## PASTE THIS INTO CLAUDE CODE:

```
You are doing a full professional audit of the Ladder iOS app before AWS backend wiring.
The goal: find every bug, risk, crash path, and broken edge case. Fix what you can. Document what needs manual review.

Work through each section below one at a time. After each section, confirm findings before moving to the next.

---

SECTION 1 — CONNECTION ENGINE SAFETY

Check ConnectionEngine.swift for:
1. Retain cycles — does it hold strong references to StudentProfileModel or any @Model? If yes, make them weak.
2. onCollegeSaved() — if the same college is saved twice (save → unsave → re-save), does it create duplicate essay slots? Add a guard: only create slots if they don't already exist for that collegeId.
3. onCollegeRemoved() — does it clean up ALL data for that college (essay slots, application records, deadline entries)? If any cleanup is missing, add it.
4. onCareerPathChanged() — if called multiple times (user retakes quiz), does it append duplicate activity suggestions or replace them cleanly? It must replace, not append.

---

SECTION 2 — POST-ACCEPTANCE CHECKLIST SAFETY

Find where ApplicationModel.status is updated and the post-acceptance checklist generates.
Check:
1. If status changes: accepted → waitlisted → accepted again — does it generate 18 checklist items instead of 9? Add a guard: only generate post-acceptance items if checklistItems is empty or contains no postAcceptance category items.
2. If status goes back from accepted to any other status — should the post-acceptance items be removed? Add a confirm alert before status downgrade: "Are you sure? This will remove your post-acceptance checklist."

---

SECTION 3 — COLLEGE MATCH CALCULATOR SAFETY

Open CollegeMatchCalculator.swift and check:
1. What happens when studentSAT = 0 (user skipped SAT entry in onboarding)? Does it crash or silently return wrong tier? Add: if studentSAT == 0, return .match as a neutral default and don't run the calculation.
2. What happens when collegeSATRange is empty string, nil, or malformed (e.g. "N/A" or "1200" with no dash)? The parseSATRange function must handle all these gracefully — return (1000, 1400) as safe default.
3. What happens when collegeAcceptanceRate = 0.0 (data missing)? Should not classify as impossible reach. Add: if acceptanceRate == 0.0, treat as 0.50 (unknown).

---

SECTION 4 — GRADE FEATURE MANAGER SAFETY

Open GradeFeatureManager.swift and check:
1. What is the DEFAULT grade if the user never completed onboarding? If it defaults to 0 or nil, every gated feature will be locked forever. Default must be 9 (freshman — most restrictive but not broken).
2. What grade does a user see if they skip onboarding? Trace the flow: does GradeFeatureManager read from StudentProfileModel.grade, and is that field always set before the main tab view appears?
3. Are all 7 gated routes actually using GradeFeatureManager? List every route that checks grade and confirm the feature key matches what GradeFeatureManager expects.

---

SECTION 5 — CAREER QUIZ FLOW

Find CareerQuizView or CareerQuizViewModel and trace the full save flow:
1. When quiz completes, confirm careerPath is written to StudentProfileModel — not just a local variable.
2. Confirm ConnectionEngine.onCareerPathChanged() is called AFTER the SwiftData save, not before.
3. If the user taps "Retake Quiz" — does the old careerPath get replaced or does it create a duplicate career history entry? It should replace the current path and append one entry to career history (for year-over-year tracking), not create duplicates.
4. Is there a loading/confirmation state after quiz save? Or does the app just snap back instantly? If instant, add a brief success animation before navigating away.

---

SECTION 6 — SWIFTDATA THREAD SAFETY

Search the codebase for any SwiftData @Model writes that happen off the main thread (in async Task blocks, background queues, or callbacks).
1. All SwiftData writes MUST happen on @MainActor. Find any that don't and add @MainActor annotation or wrap in await MainActor.run { }.
2. Check if ConnectionEngine cascade methods that write to SwiftData models are called from background threads. If yes, fix them.

---

SECTION 7 — NAVIGATION DEAD ENDS

With 80+ routes defined in Route.swift:
1. Find any route cases that have no corresponding view — these will crash if navigated to.
2. Find any NavigationPath pushes that push to a route requiring data (e.g. a college ID) but might receive nil or empty string.
3. Check the LockedFeatureView — does tapping "Back" always work, or can a user get trapped?

---

SECTION 8 — COPPA / LEGAL COMPLIANCE

Open ConsentView.swift:
1. If a user enters age under 13 — does the parental consent flow ACTUALLY block access to the main app? Or does it just show a screen that can be dismissed?
2. Are all 6 legal documents actually loading their content, or do any show blank/placeholder text?
3. Is ConsentRecord being saved locally before navigating to onboarding? If the app crashes after consent but before onboarding, does it ask for consent again on next launch?

---

SECTION 9 — EMPTY STATE HANDLING

Check every major list view for empty states:
1. CollegeDiscoveryView — if no colleges match a filter, does it show a helpful empty state or a blank screen?
2. TasksView — if there are no tasks yet, does it show a blank screen or an onboarding prompt?
3. ScholarshipSearchView — if search returns no results, is there a message?
4. DashboardView — if savedCollegeIds is empty, does the urgency card crash or gracefully hide?
5. ApplicationDetailView — if checklistItems is empty, does it show something useful?

---

SECTION 10 — BUILD + WARNINGS CLEANUP

1. Run a full build and capture ALL warnings (not just errors). List every warning.
2. Fix any "unused variable" or "result unused" warnings in the 5 newly wired files specifically:
   - ConnectionEngine.swift
   - CollegeMatchCalculator.swift
   - The career quiz save flow file
   - The college save button file
   - The application status update file
3. Check for any force unwraps (!) in the 5 newly wired files. Replace with safe unwraps or guard statements.
4. Run the app on simulator, navigate through every tab, and confirm no console errors appear during normal use.

---

After completing all 10 sections, give me:
- A FIXED list: everything you found and fixed
- A RISK list: everything you found but couldn't fix automatically (needs manual review or design decision)
- A CLEAN list: sections that passed with no issues
- Overall verdict: is this app safe to wire AWS into, or are there blockers?
```

---

## What this audit checks:

| Section | What it finds |
|---------|---------------|
| 1. ConnectionEngine Safety | Retain cycles, duplicate data on re-save, incomplete cleanup |
| 2. Post-Acceptance Safety | Checklist duplication if status bounces |
| 3. Match Calculator Safety | Crashes when SAT=0, malformed college data |
| 4. Grade Manager Safety | Default grade bug, broken gating |
| 5. Career Quiz Flow | Data not saving, duplicate history entries |
| 6. SwiftData Threads | Writes off main thread = crashes |
| 7. Navigation Dead Ends | Routes with no view, nil data crashes |
| 8. COPPA Compliance | Legal gate actually blocking or just visual |
| 9. Empty States | Blank screens instead of helpful messages |
| 10. Build Warnings | Force unwraps, unused vars, console errors |
