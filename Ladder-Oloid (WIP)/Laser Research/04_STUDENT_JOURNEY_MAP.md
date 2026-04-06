# Student Journey Map — 9th Grade Through College
_Sourced from: subtitles (2).txt, (5).txt, (9).txt, (11).txt, (12).txt, IMG_8200.txt, IMG_8237.txt_

---

## The Big Picture

The Ladder experience is not a static app — it is a **4-year journey** that evolves with the student. The design principle: the app should be doing different things and showing different content depending on what grade the student is in and where they are on their college prep timeline.

The current build treats all students the same. The real Ladder must adapt.

---

## Year 0: First Login (Setup)

**Regardless of grade level when they join:**

1. Sign up / create account
2. Input: name, current grade, school name
3. **Upload middle school transcript (if entering 9th grade) OR most recent transcript**
   - PDF or HEIC/photo upload
   - AI parses grades per subject
   - Stores to student profile
4. Fill out **Academic Resume** (guided form):
   - Current hobbies
   - Any accomplishments so far
   - Sports / clubs already involved in
   - Goals (open-ended text)
5. **Take Career Quiz** (see `02_CAREER_QUIZ_DESIGN.md`)
   - AI uses transcript + quiz answers together for better recommendations
6. AI-generated output:
   - Assigned career path bucket (STEM / Medical / Business / Humanities / Sports)
   - "Here's what your first year should look like…"
   - Suggested class list for next semester (Easy / Moderate / Hard tiers)
   - First activities to start working on

---

## 9th Grade (Foundation Year)

**Goal: Plant the seeds. Don't overwhelm. Start early.**

### What the app guides the student to do:
- Start at least 1 extracurricular per category (athletics, volunteering, clubs, job)
- Begin tracking volunteer hours (Florida Bright Futures minimum: 120 hours)
- Take the career quiz at the start of the year
- Select preferred classes using app → data goes to counselor
- Set up their "Portfolio" — the running log of everything they're doing

### Milestones:
- [ ] Career quiz completed
- [ ] Academic resume filed
- [ ] At least 1 club joined
- [ ] Volunteer hours log started
- [ ] 9th grade class list submitted to counselor

### What the AI advisor focuses on:
- Orientation: "Here's how high school works for college prep"
- Career path explanations: "Here's what STEM students typically do in high school"
- Gentle encouragement: "You don't need to know your major yet — just explore"

---

## 10th Grade (Exploration Year)

**Goal: Deepen interests, broaden extracurriculars, get first major taste of SAT.**

### What the app guides the student to do:
- **Retake career quiz** (interests may have shifted after 9th grade)
- Upload 9th grade transcript → AI recalibrates class recommendations
- Aim to complete most extracurriculars before junior year (to free up time for SAT prep)
- Take PSAT in October (prep for National Merit Scholar consideration in 11th grade)
- Consider first SAT practice test or Khan Academy prep
- Pick 2–3 career-specific activities from their bucket's recommended list
- Begin research on potential colleges (not committing — just exploring)

### Key insight from transcript:
> "10th grade is the easiest year to get activities done. Once you're in 11th, you're studying for SATs and applying to colleges — you won't have time."

### Milestones:
- [ ] Career quiz retaken (compare to 9th grade results)
- [ ] 10th grade transcript uploaded
- [ ] 2+ career-specific activities logged
- [ ] PSAT taken
- [ ] First college wishlist started (no commitment)

---

## 11th Grade (The Hardest Year)

**Goal: SAT, finalize major, start college list, crush extracurriculars.**

### What the app guides the student to do:
- **Take SAT 2–4 times** (the app tracks which sessions they've registered for)
- **Check SAT fee waiver eligibility** (free meals at school = likely eligible)
- Re-take career quiz and make a final major decision by end of junior year
- Upload 10th grade transcript → full college recommendations generated
- Build college list: reach schools, match schools, safety schools
- Begin college preference quiz: campus size, urban/rural, distance from home, cost range
- Start Common App account and begin essay brainstorming
- Get letters of recommendation lined up (ask teachers BEFORE senior year)

### Key insight from transcript:
> "By junior year, they should know what they want. We're not forcing it, but we suggest they have a decision by junior year because applications open junior year, senior year."

### Milestones:
- [ ] SAT taken at least once
- [ ] SAT score recorded in app
- [ ] Career quiz finalized / major decided
- [ ] College list: min 5 schools (2 reach, 2 match, 1 safety)
- [ ] College preference inputs completed
- [ ] Teacher recommendation requests sent
- [ ] Common App account created

---

## 12th Grade (Application Season)

**Goal: Submit, track, decide, enroll.**

### What the app guides the student to do:
- Complete and submit all applications before each deadline (EA → ED → RD)
- Track application status per school (planning → submitted → awaiting decision → accepted/rejected/waitlisted)
- If waitlisted: LOCI generator (Letter of Continued Interest)
- If accepted at multiple schools: financial aid comparison view
- **Mark final choice by May 1 (National Decision Day)**
- Switch to post-acceptance checklist for the chosen school

### Milestones:
- [ ] All EA applications submitted
- [ ] All ED applications submitted
- [ ] All RD applications submitted
- [ ] Decisions received for all schools
- [ ] Financial aid packages compared
- [ ] Final school committed (May 1)
- [ ] Post-acceptance checklist begun

---

## Summer Before College

**Goal: Prepare for Day 1.**

App pivots to enrollment preparation mode:
- Post-acceptance checklist (deposit, housing, immunization, placement tests, orientation)
- Housing application tracker
- Move-in checklist
- Early college career planning prompts: "Your co-op season starts in 2 years — here's how to prepare"

---

## Alternative Path Branches

### Branch: Community College
Triggered when: student selects "Community College" in preferences OR counselor suggests it
- 2-year plan view instead of 4-year
- Focus on: meeting transfer requirements, AA/AS degree completion
- Transfer target school tracking (instead of freshman application tracking)

### Branch: Trade School
- Trades list (HVAC, plumbing, electrical, cosmetology, culinary, etc.)
- Program search (community colleges + vocational schools)
- Certification timeline instead of graduation timeline
- Apprenticeship / journeyman path explanation

### Branch: Military
- Branch options: Army, Navy, Air Force, Marines, Coast Guard, Space Force
- ROTC scholarship info (can also go to college through ROTC)
- ASVAB prep resources
- GI Bill explanation: "You can still go to college after service"
- Physical/academic requirements per branch

### Branch: Gap Year
- Gap year program search
- Suggested structured activities (AmeriCorps, international programs, work experience)
- "How to use a gap year to strengthen your college application" guide

---

## How Grade Level Affects the Dashboard

The main dashboard should show different content depending on grade:

| Grade | Primary Focus | Urgent Widget |
|-------|--------------|---------------|
| 9th | Activities & Habits | "Start volunteering this month" |
| 10th | SAT prep begins, activities completion | "PSAT is in X weeks" |
| 11th | SAT scores, college list | "SAT registration deadline: [date]" |
| 12th (Aug–Jan) | Applications open | "EA deadline in X days: [school]" |
| 12th (Feb–May) | Decisions & financial aid | "Compare your aid packages" |
| Post-graduation | Enrollment prep | "Post-acceptance checklist: [school]" |
