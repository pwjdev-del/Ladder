# Ladder — Ideas Digest

> Reconnaissance manifest of every intended feature, design decision, business rule, and user flow brainstormed in `/Ideas/`. Sources cited inline.

---

## 1. North Star / Vision

Ladder is an iOS-native, AI-driven college guidance platform that gives every U.S. high schooler a personal college counselor in their pocket from **9th grade through acceptance** — career discovery, activity tracking, college research, application management, AI advising, scholarships, and financial aid in one app. Pitch lines: *"a $5,000 college counselor for $8/month"*, *"Duolingo of college guidance — start in 9th, get accepted in 12th"*, *"Making America Smart Again"* (Ladder_Business_Economics.md, Ladder_CLAUDE.md, subtitles (1).txt). Mission framing in transcripts is explicit: democratize what rich families pay private counselors for, target first-gen and low-income students first, "Develop America through education" (subtitles (1).txt, IMG_8239.txt).

---

## 2. User Personas

- **Student (primary, grades 9–12)** — full journey owner; takes career quiz yearly, uploads transcripts, tracks activities, builds college list, manages applications, gets AI advice (Ladder_CLAUDE.md, Ladder_Flowchart.html).
- **First-generation / low-income student (priority subsegment)** — explicit GTM target; "kids whose family has never gone to college" (subtitles (1).txt, subtitles (13).txt).
- **Parent / guardian** — view-only "Parent access mode"; can upload transcripts on child's behalf; FAFSA-style data (income, education) collected for scholarship matching (Ladder_CLAUDE.md Sprint 4, subtitles (8).txt, subtitles (1).txt).
- **School / public-school counselor** — currently overwhelmed (1:400 ratios, "Ms. Durbel couldn't do her job to save her life"); Ladder is positioned as a tool that takes work off their plate (IMG 8238.txt, subtitles (11).txt).
- **Freelance / private college counselor (marketplace)** — "top 50 per state" can be published in-app, build custom quizzes, students within ~100mi radius can book them; side-business for counselors (Ladder_Flowchart.html, subtitles (6).txt).
- **Counselor "ambassadors" (credibility seeds)** — Ms. Gaber, Ms. Demlek named explicitly as endorsement targets (subtitles (6).txt, IMG 8238.txt).
- **School admin** — uploads class catalog, clubs, sports, tryout dates so AI tailors to that school's offerings; FERPA/DPA gated (Ladder_GapAnalysis.html, subtitles (12).txt).
- **School district / county (B2B buyer, Year 2+)** — Manatee County, CSUSA mentioned; would license at $2–5/student/year (Ladder_Business_Economics.md, subtitles (8).txt).

---

## 3. Core Features (Must-have)

1. **Career Discovery Quiz** — RIASEC-style, gamified ("Duolingo vibes"), short, entertaining; outputs one of 5 broad pathways: STEM / Medical / Business / Humanities / Sports (Law added later in Fix prompt). Asks hobbies, college interests, money/lifestyle preferences. Re-taken every year to track pivots (Ladder_Flowchart.html, subtitles (4).txt, subtitles (11).txt).
2. **5-Step Onboarding Wizard** — name/grade/school/firstGen → GPA/SAT/ACT/AP → 100+ dream-school tap-to-save → career interests + extracurriculars (Ladder_CLAUDE.md, Ladder_Architecture.html).
3. **ConnectionEngine** — `@Observable` service that observes `StudentProfileModel` and cascades changes across every feature; "the single most important architectural piece" (Ladder_CLAUDE.md, Ladder_WireUp.md). Cascades enumerated in Section 9.
4. **Activity Suggestion System** — 4 generals (Athletics, Volunteering ≥120 hrs, Clubs ≥1/yr, Leadership-overarching) + 6 career-specific activities rated 1–10 by importance per career cluster (Ladder_CLAUDE.md, IMG_8237.txt, subtitles (2).txt).
5. **College Discovery + Match/Reach/Safety auto-sort** — 6,500-college database; chips auto-computed from student GPA + SAT vs each college's acceptance rate and SAT range via `CollegeMatchCalculator` (Ladder_WireUp.md, Ladder_GapAnalysis.html).
6. **Application Tracker** — full status machine `planning → inProgress → submitted → accepted/rejected/waitlisted → committed`; per-college auto-generated checklist; platform tracking (Common App / Coalition / Direct / STARS / SSAR / SPARK) (Ladder_CLAUDE.md, Ladder_WireUp.md, college_requirements_db.json).
7. **Post-Acceptance Checklist Auto-Transform** — on `.accepted`, pre-app items deleted and replaced with: pay deposit, official transcripts, immunization, housing app, FAFSA, orientation, meal plan, portal login, decline other acceptances (Ladder_WireUp.md, IMG8189.MOV.txt).
8. **AI Advisor (Gemini chat)** — streaming via Edge Function; context-injected with full StudentProfileModel; "always frame as suggestions, never mandates"; "go bug your counselor by March 1st"-style specific actionable advice (Ladder_CLAUDE.md, IMG_8200.txt).
9. **Grade-Gated Features (`GradeFeatureManager`)** — radically different UX for 9/10/11/12; e.g. Application Tracker hidden until 11–12, Essay Hub until 12, SAT Strategy until 10, Scholarship Apply mode until 11 (Ladder_CLAUDE.md grade matrix).
10. **Roadmap (4-year milestones)** — PSAT → SAT → Apps → Graduation; should adapt to current grade (Ladder_Architecture.html).
11. **Tasks (grade-aware)** — filter by `task.minimumGrade ≤ profile.grade`; 9th sees activities/career-quiz, 12th sees Common App/FAFSA (Ladder_FixPrompt.md FIX 3).
12. **Deadlines Calendar** — reads `savedCollegeIds`, surfaces urgency cards ("MIT EA in 47 days") (Ladder_Architecture.html — only working cascade pre-fix).
13. **Essay Hub** — per-college essay slots auto-created on save; "Why [field]?" talking points regenerated on career change; AI feedback on drafts (Ladder_CLAUDE.md, Ladder_FixPrompt.md FIX 6).
14. **Scholarship Search** — match % by GPA/field/state; first-gen filtering via parent income/education; FL Bright Futures (120 vol hrs) tracked (Ladder_CLAUDE.md, subtitles (1).txt).
15. **State Requirements Engine** — FL graduation rules first (Bright Futures), multi-state planned; cascades into Dashboard, Scholarships, Roadmap (Ladder_FixPrompt.md FIX 4).
16. **Transcript Upload (annual) + Gemini Vision parse** — extracts GPA/classes/grades; cascades to class suggestions and AI context; "school can upload (auto-approved) or student uploads (counselor approves)" (Ladder_CLAUDE.md Sprint 3, subtitles (8).txt, IMG_8202.txt).
17. **Class Planner** — AI suggests Easy/Moderate/Hard classes (incl. AP) based on career path + past transcript; "we think you'll excel in AP Bio because of your 8th grade science grades"; student picks → data flows to counselor before scheduling meeting (IMG_8192.txt, subtitles (12).txt).
18. **Personalized AI College Pages (Firecrawl + Lambda)** — student saves an unlisted college → Lambda fires → Firecrawl scrapes admissions page → AI generates checklist + portal link; first student creates the page, all later students reuse it (IMG8189.MOV.txt, Ladder_CLAUDE.md Sprint 3).
19. **Streak + Points + Levels (Duolingo-style gamification)** — `streakCount`, `totalPoints`, level thresholds (Freshman → Sophomore → Junior → Senior → College Bound) with `LevelUpView` celebration sheet (Ladder_FixPrompt.md FIX 10, IMG_8200.txt).
20. **Auth + Consent** — 5-state machine (loading → unauth → consentRequired → onboarding → authenticated); COPPA age gate + 6 legal docs in `ConsentView` (Ladder_CLAUDE.md, Ladder_Audit_Prompt.md SECTION 8).

---

## 4. Secondary Features (Should-have)

- **Major dropdown after career cluster** — picks Computer Science vs Mechanical Eng vs Biology etc., with cluster-scoped lists (Ladder_FixPrompt.md FIX 2).
- **Career Override** — "I want Medical not STEM" picker, both post-quiz and from Profile (Ladder_FixPrompt.md FIX 1, IMG_8192.txt).
- **Junior-year major re-prompt banner** on Dashboard if `grade==11 && selectedMajor==nil` (Ladder_FixPrompt.md FIX 7).
- **College Preference Quiz** — campus size, in/out-of-state, urban/suburban/rural, dorm style, research vs teaching (Ladder_FixPrompt.md FIX 9). Alternative: redirect to College Board's quiz, screenshot upload + AI parse (IMG_8202.txt, subtitles (2).txt).
- **`portalURL` per college + "Apply Now" button** opening SafariView (Ladder_FixPrompt.md FIX 5).
- **Letters of Recommendation tracker** ("bug your counselor by March 1st") (subtitles (6).txt).
- **LOCI (Letter of Continued Interest) / Decision Portal** view (Ladder_GapAnalysis.html).
- **App Season Dashboard** for 12th graders (grade-gated route).
- **Career Explorer** — show jobs + salary estimates per career path; "put in your degree, see jobs" (Ladder_CLAUDE.md cascade, IMG_8240.txt).
- **Scholarship integration with scholarshipsearch.net** — link out, screenshot import, AI creates action checklist (subtitles (1).txt, Ladder_FixPrompt.md FIX 11).
- **SAT fee waiver detection** — auto-check eligibility via free-lunch program (IMG_8200.txt).
- **AI Advisor structured onboarding mode** — yes/no/not-sure quick-tap branching when major/colleges empty (Ladder_FixPrompt.md FIX 12).
- **Mock Interview with recording** — voice + AI coaching (Ladder_CLAUDE.md Sprint 3).
- **Resume Builder** — 1-page templates, Canva-style, brand-color personalization tip (IMG_8240.txt).
- **PDF portfolio export** — 4-year activity portfolio, sharable with counselors/colleges (Ladder_CLAUDE.md Sprint 4).
- **Class preference share with counselor** — generate PDF of recommended schedule, AirDrop/email to counselor (Ladder_FixPrompt.md FIX 13, subtitles (12).txt).
- **Saved Colleges view** — dedicated list reachable from Profile/Dashboard (Ladder_UXFix_Prompt.md FIX 12).
- **Edit Profile sheet** — every onboarding field editable post-onboarding with cascade triggers (Ladder_UXFix_Prompt.md FIX 10).
- **Achievements / badges** on iPhone Profile (currently iPad-gated) (Ladder_UXFix_Prompt.md FIX 13).
- **Push notifications** — deadlines + streak reminders (Ladder_CLAUDE.md Sprint 4).
- **"Colleges can revoke acceptance" senior-year warning** (subtitles (3).txt).
- **"Apply before Nov 1" early-application warning** (subtitles (3).txt).
- **NCAA athlete track** — team manager / scorekeeper options, highlight video, GPA maintenance (IMG_8237.txt).
- **Activity longevity tracking** — start date per activity; "loyalty / 4-year vs 1-year join" matters to colleges (subtitles (6).txt).
- **STARS vs Common App vs Institutional Portal vs SSAR vs SPARK** as distinct platform options with per-college guidance (subtitles (3).txt, college_requirements_db.json).

---

## 5. Stretch / Future Ideas

- **Counselor Marketplace** — top 50 freelance counselors per state; ranked; students pick within 100mi radius; counselors author quizzes (subtitles (6).txt, Ladder_Flowchart.html).
- **School admin profile** — institutional partnership unlocks class catalog, club/sport offerings, tryout dates (Ladder_GapAnalysis.html — "Not Built, requires Manatee/CSUSA").
- **Focus / PowerSchool / CSUSA SSO** — encrypted handshake to auto-pull official transcripts; legally requires county partnership (subtitles (8).txt, IMG_8202.txt).
- **NCES API** for aggregate school district info (subtitles (3).txt).
- **Alternative-paths branches for seniors who didn't prep** — community college → transfer, trade school, military, gap year, "career life coach" mode (subtitles (5).txt, Ladder_GapAnalysis.html).
- **Housing application tracker + roommate finder** — post-acceptance, integrated with college housing portals (Ladder_CLAUDE.md Sprint 4).
- **Jobs / internship listings by degree** — post-college expansion (IMG_8240.txt).
- **Sponsor / SAT-tutoring company integration** — sponsors pay, app recommends their services (subtitles.txt, Ladder_GapAnalysis.html).
- **Daily AI updates** — "AI is trained as a college counselor, updates every single day" (continuous knowledge updating, not built) (IMG8189.MOV.txt).
- **Anonymized data insights** sold to colleges/researchers (Ladder_Business_Economics.md Year 3+).
- **Counselor portal** — manage multiple students, see notes, approve transcripts (Ladder_CLAUDE.md Sprint 4).
- **Web sign-up flow** to bypass Apple's 30% cut at scale (Ladder_Business_Economics.md).
- **Cross-app expansion beyond US** — explicitly deferred ("focus, focus, focus, FL first") (IMG_8239.txt).

---

## 6. Business Model & Economics

**Pricing (CANON, 3-tier B2C — earlier Pro/School brainstorm explicitly discarded)** (Ladder_ClaudeCode_Response.md, Ladder_Business_Economics.md):

- **FREE "Explorer"** — $0/mo. Search, basic career quiz, dashboard, 10 AI msgs/mo (Gemini Flash-Lite), scholarship browsing, basic graduation tracker.
- **STANDARD "Climber"** — $7.99/mo or $59.99/yr ($5/mo effective). Unlimited AI (Flash), ConnectionEngine personalization, MATCH/REACH/SAFETY, app tracker + checklists, Essay Hub w/ AI feedback, deadline calendar, financial aid comparison, post-acceptance checklist.
- **PREMIUM "Summit"** — $14.99/mo or $99.99/yr ($8.33/mo effective). AI essay review (Gemini Pro), mock interview voice+analysis, transcript Vision parse, priority Pro responses, PDF portfolio export, parent view.

**Unit economics**: COGS ~$0.013 free / ~$0.057 Standard / ~$0.16 Premium per user/mo. Apple cut: 30% Y1 → 15% Y2+ (Small Business Program = 15% from day 1 if <$1M ARR). Standard profit ≈ $6.73/user/mo; LTV (~18 mo) Standard $122 / Premium $229. CAC target <$5 organic → LTV:CAC 35:1–58:1.

**Projections**: Y1 10K users → ~$169K ARR; Y2 50K → ~$1.17M ARR; Y3 200K → ~$5.97M ARR. Conversion target 15–25%; churn target <5%/mo (Ladder_Business_Economics.md, Ladder_Economics_SimpleGuide.md).

**Revenue streams beyond subs**: B2B school licenses ($2–5/student/yr, Y2), college advertising (Y2–3), scholarship referrals (Y2), one-time premium content packs (Y1), anonymized data (Y3+).

**GTM**: Phase 1 organic (TikTok/Reels "things your counselor won't tell you", Reddit r/ApplyingToCollege, school partnerships, word-of-mouth) → Phase 2 B2B2C district sales → Phase 3 partnerships (College Board, ACT, FAFSA, white-label).

**Target audience priority**: first-gen + low-income students in public schools first, FL-first, then expand state-by-state (subtitles (1).txt — explicit "target only first-generation students... develop America through education").

**Risk register**: Apple cut at scale, AI cost spikes, low conversion, competition (CollegeVine), College Scorecard API defunding, post-acceptance churn, COPPA/FERPA regulatory.

**Tagline options**: "$5,000 college counselor for $8/month" / "Duolingo of college guidance" / "Making America Smart Again" (subtitles (1).txt).

---

## 7. Architecture / Tech Decisions Made

- **iOS native, SwiftUI + SwiftData, iOS 17+**, MVVM + Coordinator, `@Observable` everywhere (NOT `ObservableObject`) (Ladder_CLAUDE.md).
- **Backend**: Originally planned Supabase (auth/DB/storage/edge functions). **As of April 2026 (per superseded notice in Ladder_CLAUDE.md): switched to AWS** — Cognito (auth), Lambda, DynamoDB, S3, CloudFront. AWS wiring scheduled "Friday April 11" (Ladder_GapAnalysis.html, Ladder_Business_Economics.md).
- **AI**: Google Gemini via Edge Function proxy. Model tiering: Flash-Lite (free), Flash (Standard), Pro (Premium essay/interview). `AIService.swift` supports both `sendMessage()` and SSE `streamMessage()` via `AsyncThrowingStream`.
- **College data**: U.S. Dept of Ed College Scorecard API (free, government). 6,500 colleges. Cache locally, refresh weekly/monthly. Currently mock JSON seed.
- **Crawling**: Firecrawl + AWS Lambda for AI-generated college pages. Seed list = top 300 US + all FL state schools (scrape_colleges.py SCHEMA: name, EA deadline, RD deadline, testing policy, transcript req, application platforms).
- **Navigation**: `AppCoordinator` (`@Observable`) + per-tab `NavigationPath` + `Route.swift` enum (49–80+ cases). All navigation goes through coordinator.
- **5-tab structure**: Home / Tasks / Colleges / Advisor / Profile (`MainTabView`), each with independent NavigationPath.
- **Design system**: Brand colors `primary #42603f` (evergreen), `accent #caf24d` (lime), `surface #fff8f2`, `text #1f1b15`. Required components: `LadderPrimaryButton`, `LadderCard`, `LadderTextField`, `LadderFilterChip`, `CircularProgressView`, `LadderTabBar`. Light + dark mode throughout. "Always use these components, never one-off."
- **Coding rules**: SwiftData writes must be `@MainActor`; never call AIService without student profile context; suggestions never mandates; grade-gate every feature; no hardcoded strings for college requirements (use engine); test on iPhone 15 Pro Simulator; build must succeed before marking done.
- **Two-week pre-code research process**: Perplexity deep research → Claude Opus 4.6 detailed implementation plan → "first prompt should get you 90% of the way there" (subtitles (7).txt).
- **Privacy/Legal**: COPPA age gate, 6 legal docs, parental consent flow, FERPA-aware (start as individual students, not school-integrated), DPA for school admin onboarding (planned not built).

---

## 8. User Flows / Journeys

**5-state auth machine** (Ladder_CLAUDE.md): `.loading` (1s splash session check) → `.unauthenticated` (LoginView) → `.consentRequired` (ConsentView, COPPA + legal) → `.onboarding` (5-step wizard) → `.authenticated` (MainTabView).

**Onboarding 5-step**: Welcome → name/grade/school/firstGen → GPA/SAT/ACT/AP → 100+ dream-school tap-to-save → career interests + extracurriculars → "Review Full Profile" CTA lands on Dashboard.

**9th-grade flow** (Ladder_Flowchart.html): Onboarding → Career Quiz (5 broad pathways, suggestions only) → optional career override + major dropdown → Class Planner (Easy/Moderate/Hard) → student picks classes → counselor sees prefs → Activity Tracker (4 generals + 6 career-specific) → Roadmap milestones.

**10th-grade flow**: Re-take career quiz (pivot detection: "you shifted from Medical to Tech") → updated class suggestions → continue activity building toward 120 vol hrs → start thinking leadership.

**11th-grade flow** (the hardest year per transcripts): Major-decision re-prompt → SAT track (min 2x, suggested 3–4x; fee-waiver auto-check) → activities should be mostly DONE before SAT season → College Preference Quiz (or College Board redirect + screenshot upload) → College Matching ("UF is test-driven, RIT is extracurricular-based") → LOR tracker → scholarship apply mode unlocks.

**12th-grade flow**: Application checklist per college (transcripts, SAT, essays, LOR, deposit) → before-Nov-1 early app warning → status tracking (Applied/Deferred/Accepted/Denied) → on `.accepted` post-acceptance checklist auto-transforms → housing apps Jan/Feb–Mar/Apr → final transcript after graduation. Branch for unprepared seniors: community college → transfer / trade school / military / gap year / "career life coach" mode.

**Save-a-college flow**: Tap heart in Discovery/Profile → `onCollegeSaved(collegeId)` cascade → adds to deadlines calendar, creates ApplicationModel, generates pre-app checklist, creates essay slots, adds to financial-aid comparison, updates Dashboard urgency card.

**Career-quiz-to-activities flow**: Complete quiz → results screen with "Explore Suggested Activities →" + "View College Matches →" CTAs → ActivitySuggestions view shows 4 generals + 6 career-specific rated 1–10.

**Cross-tab deep links** intended (Ladder_UXFlowAudit_Prompt.md SECTION 8): Dashboard deadline card → college detail; Tasks "Submit essay" → Essay Hub; Profile career chip → CareerExplorer; Advisor mention of a college → that college's detail; Notification → relevant scholarship/college.

---

## 9. Domain Rules / Logic (Engines)

**ConnectionEngine cascades** (Ladder_CLAUDE.md, Ladder_Architecture.html — *the* central architecture):

- `careerPath` change → CollegeDiscovery filter, ActivitySuggestions, ClassPlanner AP recs, ScholarshipSearch field filter, Dashboard quick actions, EssayHub "Why [field]?" points, CareerExplorer jobs/salaries.
- `savedCollegeIds` change → DeadlinesCalendar (only working pre-fix), ApplicationModel auto-create, ChecklistItems pre-app, EssayHub slots, FinancialAidComparison, Dashboard urgency.
- `gpa` + `satScore` change → MATCH/REACH/SAFETY auto-sort, ChancesCalculator, merit-scholarship filter, AI system-prompt context, Roadmap urgency.
- `grade` change → GradeFeatureManager lock/unlock, Dashboard greeting/hero/quick actions, Roadmap highlight current year, Tasks filter, Discovery hide for 9–10/surface for 11–12.
- `applicationStatus → .accepted` → delete pre-app checklist, generate post-acceptance (deposit, transcripts, immunization, housing, FAFSA, orientation, meal plan, portal login, decline others), Dashboard switches to post-acceptance mode, FinancialAidComparison marks committed.
- `stateOfResidence` change → GraduationTracker swap, state-specific scholarships (FL Bright Futures, Florida Medallion), Roadmap state deadlines, AI state context.
- `transcript upload` → ClassPlanner refresh, AI academic context, ChancesCalculator, ScholarshipEligibility, AP suggestions.

**CollegeMatchCalculator** (Ladder_WireUp.md): inputs `studentGPA`, `studentSAT`, `collegeAcceptanceRate`, `collegeSATRange`. Tiers `safety / match / reach`. Highly selective (<20% accept) caps at reach unless SAT≥75th & GPA≥3.7 → match. Moderately selective (<50%): SAT75th + strongGPA → safety, SAT50th + avgGPA → match, else reach. Less selective: SAT50th + avg → safety, SAT25th or avg → match, else reach. SAT range parsed from "1200-1480"; defaults (1000,1400) on malformed. Safety guards (Ladder_Audit_Prompt.md): if studentSAT==0 default `.match`; if accept==0 treat as 0.50.

**GradeFeatureManager grade matrix**:
| Feature | 9 | 10 | 11 | 12 |
|---|---|---|---|---|
| Career Quiz | Full | Retake | Retake | Full |
| College Discovery | Browse | Browse | Full | Full |
| Application Tracker | Hidden | Hidden | Prep | Full |
| SAT Strategy | Hidden | PSAT prep | Full SAT | Score improvement |
| Scholarship Search | Browse | Browse | Apply | Full |
| Essay Hub | Hidden | Hidden | Practice | Full |
| Post-Acceptance | Hidden | Hidden | Hidden | On accept |

Default grade must be 9 (most restrictive but functional) if onboarding skipped. Locked features show `LockedFeatureView` with blurred preview + "Unlocks in Xth Grade".

**ActivitySuggestionEngine ratings (1–10 by career cluster)** (Ladder_CLAUDE.md):
| Activity | STEM | Medical | Business | Humanities | Sports |
|---|---|---|---|---|---|
| Research paper (mandatory all) | 10 | 10 | 8 | 10 | 6 |
| Internship/job | 8 | 9 | 10 | 7 | 6 |
| Professional interview | 7 | 8 | 8 | 9 | 7 |
| Science fair/competition | 10 | 10 | 6 | 5 | 5 |
| Awards | 8 | 8 | 8 | 9 | 10 |
| Journals/portfolio | 7 | 7 | 7 | 10 | 8 |

4 generals required for everyone: Athletics, Volunteering (≥120 hrs FL Bright Futures), Clubs (≥1/yr, longevity matters), Leadership (overarching across all).

**StateRequirementsEngine** — FL first (Bright Futures: 120 vol hrs), then multi-state. Cascades into GraduationTracker, Scholarships, Roadmap, AI context.

**Post-acceptance checklist** (9 items): pay enrollment deposit, official transcripts, immunization/health forms, housing app, FAFSA verification, orientation, meal plan, student email/portal, decline other acceptances.

**Pricing logic for AI**: free tier → Flash-Lite (10 msgs/mo cap), paid → Flash, premium-only features → Pro.

**Suggestions-not-mandates rule**: hard-coded into AI system prompt; "make sure you always suggest — it feels like suggestion more than force, at any given point" (IMG_8200.txt).

**Auto-dedup guards** (Ladder_Audit_Prompt.md): re-saving a college must not duplicate essay slots; re-taking quiz replaces careerPath, appends one history entry; status `accepted → other → accepted` must not double the post-acceptance checklist.

---

## 10. Data / Content Sources

- **College Scorecard API** (api.data.gov/ed/collegescorecard) — 6,500 colleges, FREE government data, 1K req/IP/hr; cache locally. Currently seeded as static mock JSON; real call not implemented.
- **Firecrawl** — scrapes public admissions pages; SCHEMA: college_name, EA deadline, RD deadline, testing policy, transcript requirement, application platforms (scrape_colleges.py).
- **Seed list**: top 300 US universities + all FL state schools. Explicit colleges in research files: UF, FSU, USF, UCF, FIU, RIT, Univ of Tampa.
- **Sample data captured** (florida_colleges_admissions.json): UF Nov 1 EA / Jan 15 RD / Test Required / STARS / CommonApp; FSU Oct 15 / Dec 1 / SSAR / CommonApp+Institutional; USF Nov 1 / Mar 1 / STARS / CommonApp+Institutional; UCF Oct 15 / May 1 / SPARK; FIU Nov 3 / Dec 17 / SSAR.
- **Crowdsourced post-acceptance data** (the hard problem): students forward "Welcome to X University" emails or upload portal screenshots → AI Vision parses checklist → app "learns" each college's defaults over time. Generalize items ("pay deposit", not "pay $50 deposit"). Behind login walls / 2FA so cannot scrape directly (college_requirements_research.md).
- **Transcript sources**: middle-school + annual high-school transcripts. Channels: school auto-upload (auto-approved), student upload (counselor approval required), parent upload, encrypted Focus/PowerSchool/CSUSA handshake (county-permission-gated).
- **Scholarship data**: external (scholarshipsearch.net redirect + screenshot import) + internal database; first-gen tagging via parent income/education; state-specific (FL Bright Futures, Florida Medallion).
- **NCES** API for aggregate school/district info only.
- **College Board quiz redirect** as alternative to building a college preference quiz from scratch (subtitles (2).txt).

---

## 11. Open Questions / Concerns the Founder Raised

- **FERPA / data privacy** — "FL Dept of Ed law protects student names, grades, IDs"; can't pull data publicly without consent; "the data you put in is your responsibility" disclaimer needed; "look at how Facebook handles it" (subtitles (3).txt, subtitles (8).txt).
- **County / SSO partnerships are credibility-gated** — "Why would Manatee County give API to two strangers? Build credibility by creating engagement → millions of users → THEN pitch to county" (subtitles (3).txt).
- **Post-acceptance data collection is fundamentally hard** — every college's portal is different, behind 2FA, bad UI; no automation possible without crowdsourced uploads (college_requirements_research.md, IMG_8203.txt).
- **AI parse risk** — "never give wrong information as optional"; if checklist data isn't in a verified PDF, don't fabricate (IMG_8203.txt).
- **Should schools choose class difficulty?** "No — it's a suggestion based on the kid's transcript" (IMG_8192.txt).
- **App vs web** — "Apps feel rigid (no horizontal); websites scroll sideways but look bad as apps" → settled on iOS app (Duolingo-style) but acknowledged Apple developer cert hurdle (subtitles (7).txt).
- **Apple's 30% cut at scale** is the #1 margin threat; web sign-up flow may be required (Ladder_Business_Economics.md, Ladder_Economics_ClaudeCode_Prompt.md).
- **Conversion rate is a guess** — "15% is optimistic, could be 5%" (Ladder_Economics_SimpleGuide.md).
- **Does a 9th grader open this weekly?** — the moat thesis but unproven (Ladder_Economics_ClaudeCode_Prompt.md sec 7).
- **Do counselors actually endorse?** — needs Ms. Gaber + Ms. Demlek interviews; "acceptance only happens with endorsement from qualified people" (subtitles (6).txt).
- **Naming** — name is placeholder, "Amazon was Abracadabra before it started" (subtitles (10).txt).
- **Will state-by-state scope balloon?** — "FL focus, focus, focus" hard rule (IMG_8239.txt).
- **What about students who don't want college?** — explicitly acknowledged as not the audience but parent-driven cases included.
- **Sponsor model ethics** — "if sponsors pay, we recommend their SAT tutoring services to students... actually scratch that, look for companies that want to support students" (subtitles.txt).
- **Counselor data privacy when freelancers join the marketplace** — unresolved.
- **Crash safety unknowns flagged in audits** — retain cycles in ConnectionEngine, SwiftData off-main-thread writes, force unwraps in newly wired files, COPPA gate possibly bypassable, blank empty states, ~15 orphaned routes (Ladder_Audit_Prompt.md, Ladder_UXFlowAudit_Prompt.md).

---

## 12. iPad / Multi-platform Mentions

- **Almost no explicit iPad strategy in the Ideas folder.** Project is positioned as **iOS native, SwiftUI + SwiftData, iOS 17+**, optimized and tested on **iPhone 15 Pro Simulator** (Ladder_CLAUDE.md coding rule #9).
- **One iPad-specific bug** flagged: achievements/badges section on `ProfileView` is gated to iPad only via `horizontalSizeClass` / `userInterfaceIdiom == .pad` check — "iPhone users (99% of your users) never see them"; fix is to remove the iPad-only gate and make it adaptive (Ladder_UXFix_Prompt.md FIX 13). This is the founder's stated assumption about the user base.
- **Web platform**: discussed and rejected as the primary channel ("apps feel right, Duolingo-style") but kept as fallback for **web-based subscription sign-up** to bypass Apple's 30% cut at scale (Ladder_Business_Economics.md sec 11, subtitles (7).txt).
- **Counselor portal / Parent access mode / School admin** are all listed as future surfaces (Sprint 4) but no platform decision documented — implied iOS for parents, likely web for counselor/school admin (B2B), but not specified.
- **No mention of Android / Google Play** beyond a passing note about cert costs being unknown (subtitles (7).txt).
- **No iPad-specific layouts, split-view, multi-column, Stage Manager, Apple Pencil, or keyboard shortcuts** discussed anywhere in the Ideas folder. iPad parity (per the user's separate `ladder-ipad-parity` skill memory) is a directive that does **not** originate from these brainstorm docs — it is an external mandate.
