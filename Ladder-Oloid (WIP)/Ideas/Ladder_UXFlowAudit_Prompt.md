# Ladder — Fundamental UX & Flow Audit Prompt
# Paste this into Claude Code at your Xcode project root.
# This finds BROKEN USER JOURNEYS — screens that exist but can't be reached,
# data that's stored but never shown, features that are built but buried,
# and flows that dead-end or loop the user with no way out.
#
# This is NOT a code quality audit. This is a "can a real student actually USE this app" audit.

---

## PASTE THIS INTO CLAUDE CODE:

```
You are doing a FUNDAMENTAL UX FLOW AUDIT of the Ladder iOS app. Your job is to think like a real high school student using this app for the first time and find every place where:

1. A feature EXISTS in the codebase but the user has NO WAY TO REACH IT from the UI
2. Data is COLLECTED from the user but NEVER SHOWN BACK to them anywhere
3. A screen has NO EXIT (back button missing, no dismiss, user is trapped)
4. A screen has NO ENTRY (it's built but nothing navigates to it)
5. A button or action DOES NOTHING or navigates to the WRONG place
6. Information the user NEEDS is buried where they'd NEVER think to look
7. A flow PROMISES something but NEVER DELIVERS (e.g. "View your results" → blank screen)

Read CLAUDE.md at the project root first for full architecture context. Then work through every section below.

---

SECTION 1 — ORPHANED VIEWS (Built But Unreachable)

Search EVERY SwiftUI View file in the project. For each View:
1. Search the ENTIRE codebase for where that View is instantiated or navigated to
2. If a View is NEVER referenced by any NavigationLink, .navigationDestination, .sheet, .fullScreenCover, or direct instantiation in another view — it is ORPHANED
3. List every orphaned view with: file name, what it does, and where it SHOULD be reachable from

Also check Route.swift:
4. List every Route enum case
5. For each case, confirm there is BOTH: (a) a view that renders it, AND (b) at least one place in the app that navigates TO that route
6. Any route with no navigation trigger = orphaned route. List it.

Expected output: a table of orphaned views and orphaned routes.

---

SECTION 2 — PROFILE SECTION COMPLETENESS

Open ProfileView.swift and trace every piece of data the user entered during onboarding:
1. name — is it displayed in Profile? Can they edit it?
2. grade — is it displayed? Can they change it? (grade changes should fire ConnectionEngine cascades)
3. school — displayed? Editable?
4. isFirstGen — displayed? Editable?
5. GPA — displayed? Editable? Does editing trigger match recalculation?
6. SAT/ACT scores — displayed? Editable?
7. careerPath — displayed? Can they retake the quiz or override from Profile?
8. savedCollegeIds — is there a "My Saved Colleges" list accessible from Profile?
9. interests — displayed?
10. extracurriculars — displayed? Editable?
11. stateOfResidence — displayed? Editable? Or still hardcoded "FL"?
12. streakCount / totalPoints — displayed? Is there a leaderboard, XP view, or progress visualization?
13. selectedMajor (if it exists) — displayed? Editable?

For EACH item: report whether it's (a) visible in Profile, (b) editable from Profile, (c) completely missing from Profile.

KEY QUESTION: After onboarding, if a student goes to Profile expecting to see everything about themselves — what is MISSING? What data did they enter that they can never see or change again?

---

SECTION 3 — EVERY TAB'S "WHERE IS ___?" TEST

For each of the 5 tabs (Home/Dashboard, Tasks, Colleges, Advisor, Profile), answer these questions as if you're a confused student:

**Dashboard Tab:**
- "Where are my saved colleges?" — can I get to my saved college list from Dashboard?
- "Where is my streak / points / level?" — is gamification visible on Dashboard?
- "Where are my upcoming deadlines?" — is there a deadline summary or do I have to dig?
- "What should I do today?" — does Dashboard give me a clear next action?

**Tasks Tab:**
- "Where did this task come from?" — does each task explain WHY it exists?
- "I finished a task but nothing happened" — does completing a task trigger any reward, XP, or cascade?
- "These tasks don't apply to me" — are tasks filtered by grade? By career path?

**Colleges Tab:**
- "I saved a college but where did it go?" — after hearting a college, where is the saved list?
- "How do I compare colleges?" — is there a comparison view? Is it reachable?
- "What are my chances?" — is the match/reach/safety info visible on college cards AND in a summary view?
- "I got accepted, now what?" — from the college detail, can I update my application status? Does it trigger the post-acceptance checklist?

**Advisor Tab:**
- "The AI doesn't know anything about me" — is student context actually injected into the system prompt? Check AIService.swift.
- "I asked a question but got a generic response" — is the advisor using hardcoded keyword matching as fallback? If so, when does it fall back?
- "Where are my old conversations?" — are chat sessions saved and accessible?

**Profile Tab:**
- "Where is the leaderboard?" — is there ANY leaderboard, ranking, or competitive element? If it exists, HOW do you get to it from Profile?
- "Where are my achievements / badges?" — does anything in the app track accomplishments visually?
- "How do I change my career path?" — is there a retake quiz button or career override in Profile?
- "How do I log out?" — is there a sign out button? Does it actually work with the auth system?
- "How do I delete my account?" — is there an account deletion option? (Required for App Store)

For each question: answer with the EXACT navigation path a user would take (e.g., "Profile → Settings gear → Career Path → Retake Quiz") or say "NO PATH EXISTS."

---

SECTION 4 — DATA IN, NEVER OUT (Collected But Invisible)

Search StudentProfileModel and every other @Model class. For each stored field:
1. Is this field EVER displayed in any View? Search for the property name across all View files.
2. Is this field EVER used in any calculation, filter, or conditional? Search across ViewModels and Engines.
3. If a field is stored but NEVER read by any View or ViewModel — it's dead data. List it.

Common suspects:
- streakCount — is it displayed anywhere or just incremented silently?
- totalPoints — same question
- careerPath history entries — if ConnectionEngine saves career history, can the user ever SEE their history?
- extracurriculars array — is it used beyond onboarding?
- interests array — same
- isFirstGen — is it ever surfaced in scholarship filtering or AI context?

Expected output: a table of every dead-data field with where it's written vs where (if anywhere) it's read.

---

SECTION 5 — NAVIGATION DEAD ENDS & TRAPS

Trace these specific user flows end-to-end. For each, document every screen transition and flag where the flow BREAKS:

**Flow 1: First-time user onboarding → Dashboard**
Start at app launch → consent → onboarding steps 1-5 → main app.
- Does every "Next" button work?
- Can you go BACK at every step?
- If you skip a step, does the app crash or gracefully handle missing data?
- After onboarding completes, does Dashboard show PERSONALIZED content or generic placeholder?

**Flow 2: Save a college → Track application → Get accepted → See post-acceptance checklist**
Start at Colleges tab → find a college → tap heart → go to saved list → create application → change status to accepted.
- At which step does the flow BREAK? Can you even complete this entire journey?
- Is the saved college list accessible? From where?
- Can you change application status? From where?
- Does the post-acceptance checklist actually appear? Where?

**Flow 3: Take career quiz → See activity suggestions → Track an activity**
Start at career quiz → complete it → see results → find activity suggestions → log/track an activity.
- After quiz results, does the app TELL you where to find your suggested activities?
- Is there a dedicated activities list/tracker view? Is it reachable?
- Can you mark an activity as started/completed?

**Flow 4: Profile editing loop**
Go to Profile → try to edit GPA → try to edit SAT → try to change grade → try to change career.
- For each: can you actually edit it? Does it save? Does it trigger cascades?
- If you change your GPA, does your match/reach/safety list update?

**Flow 5: Scholarship search → Find one → Save it → Apply**
Go to scholarship search → filter → find a scholarship → save → get to application link.
- Does the scholarship search actually return results?
- Can you save a scholarship? Where does it go?
- Is there an external link to actually apply?

**Flow 6: Essay writing flow**
Find essay hub → select an essay → write/edit → get AI feedback.
- Is essay hub reachable? From which tab?
- Are essay slots pre-populated based on saved colleges?
- Does the AI actually review essays or is it placeholder?

For each flow: document the EXACT point where it breaks or dead-ends, and what the user sees.

---

SECTION 6 — BUTTONS THAT DO NOTHING

Search for every Button, NavigationLink, and .onTapGesture in the entire project. For each:
1. Does the action contain actual logic, or is it: empty closure `{ }`, print statement only, TODO comment, or placeholder Alert?
2. List every button whose action is effectively a no-op.
3. Prioritize by visibility — a no-op button on the Dashboard is worse than one buried in Settings.

Also search for:
- `// TODO` inside button actions
- Empty `action:` closures
- `print("tapped")` as the only action
- Buttons that show an alert saying "Coming soon" or similar

---

SECTION 7 — MISSING BACK BUTTONS & ESCAPE ROUTES

For every view that's presented as a .sheet, .fullScreenCover, or pushed via NavigationPath:
1. Does it have a dismiss/back mechanism?
2. Can swiping down dismiss sheets? (default behavior, but can be disabled)
3. For fullScreenCover views — is there an explicit close/X button? (swipe down does NOT work for fullScreenCover)
4. For NavigationPath pushes — is the navigation bar visible? Can the system back button appear?

List every view where a user could get STUCK with no way to go back.

---

SECTION 8 — CROSS-TAB NAVIGATION GAPS

Check if the app supports cross-tab deep linking. These are common "where is it?" moments:

1. Dashboard shows "MIT deadline in 5 days" → tapping it should go to MIT's college detail in the Colleges tab. Does it?
2. Tasks tab shows "Submit Common App essay" → tapping should go to Essay Hub. Does it?
3. Profile shows career path "STEM" → tapping should go to career quiz results or career explorer. Does it?
4. Advisor gives advice about a specific college → tapping the college name should go to that college's detail. Does it?
5. Notification/alert says "Your scholarship deadline is tomorrow" → does tapping go to the scholarship? Or just opens the app to whatever tab was last open?

For each: does the deep link work? If not, what happens instead (nothing, wrong screen, crash)?

---

SECTION 9 — EMPTY STATES THAT KILL THE EXPERIENCE

For EVERY list view and collection view in the app, check what happens when the list is EMPTY:

1. No saved colleges → what does the Colleges "My Saves" section show?
2. No applications → what does the Application Tracker show?
3. No tasks completed → what does the Tasks tab show?
4. No chat history → what does the Advisor tab show?
5. No scholarships saved → what does the Scholarship section show?
6. No essays started → what does Essay Hub show?
7. No activities logged → what does the Activity section show?
8. Brand new user with zero data → what does Dashboard show?

For each: report whether it shows (a) a helpful empty state with a CTA, (b) a blank white screen, (c) a loading spinner that never resolves, or (d) a crash.

---

SECTION 10 — SETTINGS & ACCOUNT MANAGEMENT GAPS

Check for these essential app settings that MUST exist for App Store submission:

1. Sign out button — exists? Works?
2. Delete account — exists? (REQUIRED by App Store since June 2022)
3. Change password — exists?
4. Change email — exists?
5. Notification preferences — exists?
6. Privacy policy link — exists and loads?
7. Terms of service link — exists and loads?
8. App version number — displayed?
9. Contact support / feedback — exists?
10. Data export (GDPR if applicable) — exists?

For each: EXISTS / MISSING / PLACEHOLDER.

---

SECTION 11 — FEATURE DISCOVERABILITY AUDIT

These features are BUILT but might be INVISIBLE to users. For each, document the exact navigation path to reach it:

1. CollegeMatchCalculator (match/reach/safety) — where does the user SEE this?
2. ConnectionEngine cascades — when career changes, does the user SEE anything update in real-time or does it happen silently?
3. GradeFeatureManager locked features — when a 9th grader hits a locked feature, what do they see? Is the locked message helpful or just "locked"?
4. StateRequirementsEngine — where does the user SEE state-specific graduation requirements?
5. ActivitySuggestionEngine — where does the user SEE their personalized activity suggestions?
6. Post-acceptance checklist — where does it appear after marking a college as accepted?
7. Essay slots auto-created by saving a college — where do they appear?
8. Career history (year-over-year tracking) — can the user SEE their career path changes over time?

For each: give the navigation path or say "USER CANNOT SEE THIS."

---

## AFTER ALL 11 SECTIONS, PRODUCE THIS REPORT:

### 🔴 CRITICAL (User literally cannot complete a core journey)
List every flow that is fundamentally broken — user gets stuck, feature unreachable, data invisible.

### 🟡 MAJOR (User can work around it but will be confused)
List every UX gap that makes the app feel broken — missing back buttons, no-op buttons, hidden features.

### 🟢 MINOR (Polish issues)
List empty states, missing settings, discoverability improvements.

### 📋 ORPHANED ASSETS (Built but wasted)
List every view, route, and data field that exists in code but is unreachable by users.

### 🔧 RECOMMENDED FIX ORDER
Number the top 15 fixes in priority order. For each, give:
- What's broken (1 sentence)
- Where the fix goes (file name)
- What the fix is (1-2 sentences)
- Estimated complexity: trivial / moderate / significant
```

---

## What this audit catches that previous audits didn't:

| Previous Audits | This Audit |
|-----------------|------------|
| Code safety (crashes, retain cycles) | Can users REACH the feature? |
| Data integrity (duplicates, nil crashes) | Is stored data ever SHOWN BACK? |
| Build warnings & force unwraps | Do buttons actually DO anything? |
| Thread safety | Can users ESCAPE every screen? |
| Feature existence (built vs not built) | Feature DISCOVERABILITY (built but buried) |
| COPPA compliance | App Store account management requirements |

This audit answers the question: **"If I hand this app to a 9th grader right now, what will they be confused by, stuck on, or unable to find?"**
