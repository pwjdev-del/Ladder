# Ladder — Gap Analysis Verification Prompt
> Paste this into Claude Code at your Xcode project root.

---

You are doing a feature existence audit of the Ladder iOS app. For each item below, search the codebase and tell me:
- **EXISTS**: Yes / No
- **WHERE**: file name(s)
- **HOW COMPLETE**: fully built / skeleton / placeholder / partially done
- **ISSUES**: anything worth flagging

Search Views, ViewModels, Models, and Engine files thoroughly.

---

## CAREER QUIZ & DISCOVERY

1. **CareerExplorer** — does the app show potential jobs + salary estimates based on career path?
   Search: `CareerExplorer`, `careerExplorer`, `"jobs in"`, `"salaries"`, `job salary`

2. **Major dropdown after career result** — after quiz gives STEM, does it show a dropdown of STEM majors?
   Search: `major`, `stemMajors`, `medicalMajors`, `majorDropdown`

3. **Student career override** — can student say "I want Medical not STEM" after the quiz suggests otherwise?
   Search: `override`, `careerOverride`, `additionalInfo`, `"additional request"`

---

## ONBOARDING

4. **Academic resume upload** — is there an upload or input for an LRPA-style academic resume (hobbies, accomplishments)?
   Search: `academicResume`, `lrpa`, `resumeUpload`, `"academic resume"`

5. **Middle school transcript upload** — is there any transcript upload UI in onboarding?
   Search: `middleSchool`, `middleSchoolTranscript`, `transcriptUpload`, `TranscriptUpload`

6. **AI onboarding questionnaire** — is there an AI-driven step asking "Do you have plans for your future?"
   Search: `OnboardingQuestionnaire`, `"future plans"`, `AIQuestionnaire`, `"what are your plans"`

7. **Parent income / education data** — is there anything collected beyond the `isFirstGen` flag?
   Search: `parentIncome`, `householdIncome`, `parentEducation`, `firstGenScholarship`

---

## CLASS PLANNING

8. **ClassPlanner** — does the app suggest specific AP/elective classes based on career + past grades?
   Search: `ClassPlanner`, `ClassPlannerView`, `classSuggestion`, `recommendedClasses`

9. **Easy / Moderate / Hard class difficulty** — does any view show class difficulty levels per student?
   Search: `ClassDifficulty`, `classDifficulty`, `difficulty` (in class context)

10. **Annual transcript upload UI** — is there a view for students to upload their yearly transcript?
    Search: `TranscriptUploadView`, `uploadTranscript`, `transcript` (in Views folder)

11. **Class preference for counselor** — can students pick preferred classes to share with their counselor?
    Search: `classPreference`, `counselorPreference`, `schedulingPreference`

---

## ACTIVITIES

12. **Professional interview as activity type** — is "professional interview" one of the 6 career-specific options?
    Search: `professionalInterview`, `interview` (in ActivitySuggestion context), `ActivityType`

13. **Science fair as activity type** — is science fair listed for STEM students?
    Search: `scienceFair`, `"science fair"`, `ActivityType`

14. **Activity longevity / start date** — do activity entries have a start date to track how long a student has done it?
    Search: `ActivityModel`, `activityStartDate`, `startDate` (in activity context), `longevity`

15. **NCAA athlete track** — is there any NCAA-specific guidance or athletic recruitment path?
    Search: `NCAA`, `athleticRecruitment`, `teamManager`, `scorekeeper`

16. **"Finish activities by sophomore year" goal** — does the app communicate the 9th-10th grade activity push timeline?
    Search: `sophomoreGoal`, `activityTimeline`, `"sophomore year"` (in activity context)

---

## COLLEGE DISCOVERY & APPLICATIONS

17. **College admissions portal link** — does `CollegeModel` have a `portalURL` field? Do college pages show a direct apply link?
    Search: `portalURL`, `admissionsPortal`, `portalLink`, look at all fields in `CollegeModel`

18. **College tour / choosing tips** — is there any guidance on touring or choosing a college?
    Search: `collegeTips`, `tourTips`, `choosingCollege`, `"choosing a college"`

19. **College preference quiz** — is there a dedicated college preference quiz (campus size, dorm type, urban/suburban)?
    Search: `CollegePreferenceQuiz`, `collegePreference`, `dormPreference`, `campusSize`, `urbanRural`

20. **STARS platform in checklist** — is STARS listed as a distinct platform with specific guidance (vs Common App)?
    Search: `STARS`, `"USF"` (in checklist/application context), `platform` in `ChecklistItemModel`

21. **"Colleges can revoke acceptance" warning** — any warning that senior year grades can cost you your acceptance?
    Search: `revoke`, `revokeAcceptance`, `"senior year grades"`, `"keep your grades"`

22. **Early application Nov 1st warning** — does the app warn about applying before November 1st?
    Search: `earlyApplication`, `"November 1"`, `"Nov 1"`, `earlyDeadline`

23. **Letters of recommendation tracking** — is there any LOR tracking in the checklist or standalone?
    Search: `LetterOfRecommendation`, `LOR`, `lor`, `letterOfRec`, `recommendation`

24. **Decision Portal / LOCI completeness** — how complete is this view? Real screen or placeholder?
    Search: `LOCIView`, `DecisionPortalView`, `LOCI`, `"letter of continued interest"`

25. **App Season Dashboard completeness** — is this a real view or a placeholder?
    Search: `AppSeasonDashboard`, `appSeason`, `applicationSeason`

---

## ESSAYS & AI

26. **Essay Hub AI "Why [field]?" talking points** — does `onCareerPathChanged()` actually populate any essay talking points?
    Search: `whyField`, `careerTalkingPoints`, `essayTalkingPoints` (in EssayHub)

27. **AI advisor branching flow** — is there a structured yes/no questionnaire in AdvisorHub, or is it purely free chat?
    Search: `AdvisorChatViewModel`, `planningFlow`, `branchingFlow`, `structuredFlow`

---

## SCHOLARSHIPS & FINANCIAL AID

28. **scholarshipsearch.net redirect or screenshot import** — any link to the site or screenshot upload?
    Search: `scholarshipsearch`, `scholarshipRedirect`, `"screenshot"`, `"external scholarship"`

29. **SAT fee waiver detection** — does the app inform students about free SAT eligibility via free lunch program?
    Search: `feeWaiver`, `satFeeWaiver`, `freeLunch`, `"free SAT"`, `freeMeals`

30. **Financial Aid Comparison view completeness** — is this fully built or a placeholder?
    Search: `FinancialAidComparison`, `financialAidComparison`, `FinancialAid` (in Views)

---

## DASHBOARD & GRADE PROGRESSION

31. **Dashboard grade-awareness** — does `DashboardView` change greeting, subtitle, or quick action cards by grade?
    Search: `DashboardView` (look at how `gradeManager` is used), `grade` (in DashboardViewModel)

32. **Roadmap grade-adaptive milestones** — does the Roadmap highlight current-grade milestones, or shows all at once?
    Search: `RoadmapView`, `RoadmapMilestoneModel`, `currentGrade` (in Roadmap context)

33. **TasksView grade-awareness** — does TasksView filter tasks by student grade?
    Search: `TasksView`, `TasksViewModel`, `grade` (in TasksView context)

34. **Junior year major re-prompt** — is there a trigger asking "Have you decided your major?" when grade hits 11?
    Search: `juniorPrompt`, `majorConfirmation`, `"11th grade"`, `"have you decided"`

---

## GAMIFICATION

35. **Level system** — is there a level/tier system beyond `streakCount` and `totalPoints`?
    Search: `level`, `userLevel`, `levelUp`, `LevelSystem`

---

## STATE REQUIREMENTS

36. **Bright Futures FL tracking** — does the app specifically flag Bright Futures eligibility for FL students?
    Search: `brightFutures`, `BrightFutures`, `"bright futures"`, `volunteerHours` (FL context)

37. **`stateOfResidence` cascade** — is `stateOfResidence` still hardcoded to `"FL"`? Is the cascade wired to StateRequirementsEngine?
    Search: `stateOfResidence`, `onStateChanged`, `StateRequirementsEngine` (in ConnectionEngine)

---

## RESUME

38. **Resume builder** — is there a resume builder or template view in the app?
    Search: `ResumeBuilder`, `ResumeBuilderView`, `resumeTemplate`, `resumeExport`

---

## AFTER YOU SEARCH ALL 38 ITEMS, give me:

- ✅ **CONFIRMED BUILT** — exists and working
- 🔶 **SKELETON / PARTIAL** — exists but incomplete or placeholder
- ❌ **NOT FOUND** — does not exist anywhere in codebase
- ⚠️ **NEW RISKS** — anything you spotted while searching that looks broken or risky
