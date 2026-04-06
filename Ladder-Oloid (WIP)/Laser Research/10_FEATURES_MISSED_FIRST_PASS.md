# Features Missed in First Pass
_Second deep read of all transcripts. Everything in here was NOT in the first research documents._

---

## 1. Freelance College Counselor Marketplace (MAJOR — Missed Entirely)

**Source:** subtitles (6).txt, subtitles (3).txt

This is a distinct third feature tier beyond student AND school counselor. There is a **third user type**: private freelance college counselors who join the platform as verified experts.

**How the co-founders described it:**
> "You should only allow top 50 counselors within state of Florida. If a counselor says, 'I like this, I want to be part of it,' then you are basically publishing them. Because many college counselors also do this as their side business."

> "They can have access to a database, access to the students within 50 mile radius or 100 mile radius of that location."

> "The college counselor makes the quizzes and the student has access to what college counselor's quiz they want to take for it."

> "Your app should be able to rank the quizzes. Which quiz is good for..."

**What this means for the product:**

### Counselor Marketplace Features:
- Private freelance counselors can apply to join Ladder as verified experts
- **Geographic limit:** 1 counselor per 50–100 mile radius region (scarcity = quality signal)
- Counselors can **create and publish their own career quizzes** within the app
- Students choose which counselor's quiz to take (with ratings/rankings)
- Counselors get visibility into students in their geographic area
- Students can book and pay for 1:1 sessions with counselors through the app
- Counselors have a profile: credentials, schools they specialize in, specializations (first-gen, STEM, sports, etc.)

### This creates a revenue stream:
- Ladder takes a % commission on counselor bookings
- Counselors pay a monthly listing fee to be on the platform
- Creates legitimate network effect: counselors market Ladder to their students

### Validation contacts mentioned:
- Ms. Gaber (private college counselor, also works at charter school)
- Ms. Demlak (school counselor)
- Strategy: get Ms. Gaber and Ms. Demlak to be the first two counselors on the platform → they become ambassadors

---

## 2. Acceptance Revocation Warning (Never Mentioned in First Pass)

**Source:** subtitles (3).txt

> "You can get freelancing counselors on our app, so we can suggest them kids. There's also one thing — a lot of students don't know that colleges can revoke acceptance. You didn't even know that. We got told by [counselor]. Yeah, they can revoke your acceptance. You still have to keep your grades on senior year."

**What this means:**
- The app needs a **Senior Year Grade Warning** feature
- After a student marks an application as "Accepted," the app shows a persistent alert:
  > "⚠️ Important: Your acceptance is conditional. If your senior year grades drop significantly, [College Name] can revoke your acceptance. Keep your GPA above [threshold]."
- This is genuinely life-changing information most students don't know
- Could also display the specific grade requirement each college states in their acceptance letter

---

## 3. Housing Application — Separate Tracker (Missed)

**Source:** subtitles (3).txt

> "Housing applications open by January, February, and a lot of them close by March and April."

**What's missing:** Housing applications have their own separate deadline cycle — earlier than most students realize. Current build has housing as a placeholder.

**Features needed:**
- Housing application deadline as a distinct tracked item per college
- Separate from admissions decision deadline
- Alert: "Housing applications for [School] open [date] — you must apply for housing even though your admissions decision hasn't come yet"
- Some schools: you apply for housing before you hear back on admissions (!)
- Housing preference quiz: dorm type preferences, roommate preferences

---

## 4. Bright Futures Scholarship Tracker (Florida-Specific, Missed)

**Source:** subtitles (6).txt

> "Our school required us to get 100 hours per year. So all of us have qualifications for Bright Futures Scholarship. Any other school... a lot of kids don't know what the SAT is, haven't heard about it until 11th grade, or the school doesn't offer the SAT at all."

**Florida Bright Futures is a huge, specific feature for the Florida market (the initial target):**

### Bright Futures Requirements (should be auto-tracked by Ladder):

**Florida Academic Scholars (75% tuition):**
- Weighted GPA: 3.5+
- ACT: 29+ or SAT: 1290+
- 100 community service hours

**Florida Medallion Scholars (25% tuition):**
- Weighted GPA: 3.0+
- ACT: 26+ or SAT: 1170+
- 75 community service hours

### What the app should do:
- Ask student at setup: "Are you a Florida resident?"
- If yes: activate Bright Futures tracker
- Show which tier they're on track for (Academic vs. Medallion vs. neither)
- Track volunteer hours toward 75 or 100 hour threshold
- Show GPA requirement gap: "You need a 3.5 GPA — you're at 3.2. Here's how to close the gap."
- Alert when they hit eligibility: "You're now on track for Florida Academic Scholars!"
- Link to official Bright Futures portal for application

---

## 5. Counselor-Created Quizzes & Quiz Ranking (Missed)

**Source:** subtitles (6).txt

> "The college counselor makes the quizzes and the student has access to what college counselor's quiz they want to take for it. Your app should be able to rank the quizzes."

**This adds a whole UX layer to the career quiz:**
- The built-in Ladder career quiz is the default, but NOT the only option
- Counselors on the platform can build their own quizzes
- Students can browse available quizzes (sorted by rating, specialty, location)
- Quizzes are rated by students who've taken them
- A counselor in Manatee County who specializes in STEM students builds a quiz optimized for that student profile
- Students compare results across multiple quizzes

**Implementation note:** Think Duolingo + Teachers Pay Teachers hybrid. Counselors build structured assessments, students consume them.

---

## 6. Start as Individual Product First (Strategic — Missed)

**Source:** subtitles (3).txt

> "Maybe we can start off as just singular students. Your personal counselor for singular students. They help you by themselves. Of course they have to consent to all the data stuff."

> "If you create millions of users, then you can pitch this idea to the county, they will open up."

**Critical product strategy point:** The co-founders explicitly acknowledged that school district partnerships will NOT happen early. The path is:
1. Launch to individual students directly (no school needed)
2. Build user base + credibility
3. With user data and engagement, go to Manatee County and pitch
4. District integration (class catalog, counselor portal) comes AFTER scale

**This means the app must work without ANY school integration for Phase 1–2.** The school profile / class catalog system is a Phase 3+ feature, not Phase 2.

---

## 7. Counselor Ambassador Strategy (Missed)

**Source:** subtitles (6).txt

> "You need an endorsement on this from different college counselors. Good college counselors — you have to sell this idea to them. Acceptance will only happen if there is endorsement from qualified people."

> "Create competition within the college counselor [community] — identify top 50 counselors within state of Florida. If a counselor says, 'I like this, I want to be part of it,' then you are basically publishing them."

**What this means:**
- Before launch, secure 2–3 known college counselors as "Founding Advisor" partners
- Their face/name appears in the app: "Ladder is endorsed by [Ms. Gaber], College Counselor at [School]"
- They get free premium access + revenue share for referrals
- They become the marketing channel into school communities

---

## 8. College Grade Tier / "What Does This College Really Want?" Feature (Missed)

**Source:** subtitles (5).txt, subtitles (2).txt

> "Some colleges are test driven. College A is test score driven — the better your SAT, the easier you get in. College B: if your SAT is a bit low but your extracurriculars are good enough, you're going to that college."

**What's missing:** Each college profile should display not just stats, but the **admissions philosophy**:
- UF = "Test-Driven" (SAT/GPA weighted heavily)
- RIT = "Extracurricular-Driven" (portfolio, projects count more than test scores)
- NYU = "Holistic" (essays, interviews, fit)
- Small liberal arts = "Fit-Driven" (demonstrated interest, personality match)

This is a direct input from the co-founders and maps perfectly to the College Personality system.

---

## 9. "What You Need From This College to Get In" Personalized Breakdown (Missed)

**Source:** subtitles (5).txt

> "By junior year: what college is top in your major? What final things will get you a good chance of getting in? What does this college need from you?"

**Feature idea:** On each College Profile page, after the student has a career path and GPA entered:
- Show a personalized "Your Chance" breakdown:
  - "Your SAT: 1180 | Their Median: 1310 | Gap: 130 points"
  - "Your GPA: 3.4 | Their 25th percentile: 3.6 | Gap: 0.2"
  - "Your Activities: 3/10 | Their typical applicant: 7–8/10"
- A specific "What to improve" action list for that college

This is the match score system but made actionable.

---

## 10. Senior Year Graduation Requirements Checker (Missed)

**Source:** IMG 8238.txt

> "This tracks what you've taken, and then it has a checklist. It'll tell you if you're missing a credit here — going through the checklist."

**Feature:** A graduation credit checker. Especially for students transferring schools or those who joined Ladder late:
- Input: current completed credits
- App cross-references with state graduation requirements (Florida: 24 credit minimum)
- Shows: "You're missing 1 Art credit and 1 PE credit to graduate"
- Alert if student is at risk of not meeting graduation requirements
- Connects to college counselor view

---

## 11. SAT Tutoring Referral System (Partially Missed)

**Source:** subtitles.txt

> "Kids like us got emails that we are eligible SAT tutors. SAT emails you if you get more than 90th percentile in math or English — you are an eligible SAT tutor."

**Feature expansion:** Not just referring to prep services. Creating a **peer tutoring network**:
- High scorers (90th+ percentile) get flagged as eligible tutors
- They can create a tutoring profile in Ladder
- Students in 10th–11th grade can find peer tutors nearby or online
- Tutors get paid (Ladder takes commission) OR earn volunteer hours for tutoring

---

## 12. Tech Stack Decisions (From the Transcripts Themselves)

**Source:** subtitles (7).txt

The founders themselves decided on this stack before any development started:
- Mobile app (not website) — because "Duolingo-style interaction works better as an app"
- Supabase for database and auth
- Firebase (mentioned as alternative/supplement)
- Claude AI (they used Opus 4.6 for the implementation plan)
- Perplexity for research
- Anti-Gravity (referenced as a STEM building tool, possibly Anthropic's tool kit)

**Notable:** The founders mentioned using "opus 4.6" to create the implementation plan before development. They did the full planning + research cycle (Perplexity deep research → Claude implementation plan) before starting to code.

---

## 13. College Advisor "Bank" — Pre-Loaded Q&A Knowledge (Missed)

**Source:** subtitles (3).txt, (6).txt

> "The AI counselor should update every single day. It is supposed to be an expert in colleges till every single day. It updates every single day."

**Feature:** The AI advisor's knowledge base needs to be actively maintained:
- New college information scraped regularly (deadlines change, policies change)
- The AI should know: "USF takes STARS, FSU has their own system, UF uses the Gator Portal"
- Counselors can contribute to the knowledge base (their expertise feeds the AI)
- Students who complete processes log what they did → contributes to the knowledge base

This is a living, community-maintained knowledge system, not a static FAQ.

---

## Summary: What Was Missed vs. First Pass

| Feature | Status in First Research |
|---------|------------------------|
| Freelance Counselor Marketplace | ❌ Completely missed |
| Acceptance Revocation Warning | ❌ Completely missed |
| Housing App Timeline Tracker | ❌ Partially missed |
| Bright Futures Tracker (Florida) | ❌ Completely missed |
| Counselor-Created Quizzes + Ranking | ❌ Completely missed |
| Launch as individual product first (strategy) | ❌ Missed |
| Counselor Ambassador program | ❌ Completely missed |
| College Admissions Philosophy (test-driven vs. EC-driven) | ⚠️ Partially covered |
| "What You Need From This College" gap analysis | ⚠️ Partially covered |
| Graduation Credit Checker | ❌ Completely missed |
| SAT Peer Tutoring Network | ❌ Completely missed |
| AI Knowledge Bank (daily updates) | ❌ Completely missed |
