# Missing Features — Complete List
_Everything mentioned in the brainstorm sessions that is NOT yet in the Stitch designs or the iOS build._

---

## Priority 1 — Core Product (Without These, Ladder Isn't Ladder)

### 1.1 Career / Life Quiz (Entry Quiz)
- **What it is:** The very first thing a new student does. Determines their career path bucket and drives ALL recommendations downstream.
- **How it works:**
  - Short, fun, entertaining (freshmen are 14 — keep it engaging)
  - Three question categories: hobbies, lifestyle/money goals, potential college interests
  - Output: places student in one of 5 buckets → STEM, Medical, Business, Humanities, Sports
  - Immediately shows a dropdown of specific majors within that bucket (just suggestions)
  - Student can override ("I don't want STEM, I want Medical") — AI adapts
  - **Retaken every year** — because interests change
  - Each retake triggers updated class and activity recommendations
- **What's built:** A stub `CareerQuizView.swift` that shows a placeholder screen. The actual quiz logic, questions, scoring, and routing do not exist.
- **Source:** subtitles (4).txt, subtitles (5).txt, IMG_8192.txt, IMG_8200.txt

### 1.2 Annual Transcript Upload + Class Recommendation Engine
- **What it is:** Each year, the student uploads their transcript. The AI parses it and recommends the next year's classes in Easy / Moderate / Hard tiers.
- **How it works:**
  - Year 0 (first login): Upload middle school transcript
  - AI reads grades → evaluates performance per subject
  - AI cross-references student's career path (from quiz) with available classes at their school
  - Suggests specific classes: "You want to go into STEM and you got an A in 8th grade science → I suggest AP Biology (moderate) or AP Computer Science Principles (moderate)"
  - School has its own profile listing the classes it offers — AI only suggests what's actually available
  - Easy / Moderate / Hard tier labels for each suggestion
  - Student picks their preferred classes → data goes to the school counselor
  - Counselor reviews, approves or makes changes → final schedule
  - Year 1 → Year 2 → repeat with updated transcript
- **What's built:** Nothing. The transcript upload flow, class suggestion logic, and counselor handoff are completely absent.
- **Source:** subtitles (2).txt, subtitles (12).txt, IMG_8192.txt

### 1.3 Activities Portfolio System (4 General + 6 Specific)
- **What it is:** A structured framework of extracurriculars the student should complete throughout high school to build a competitive application.
- **Full spec:** See `05_ACTIVITIES_SYSTEM.md`
- **What's built:** A stub `TasksView.swift` and `RoadmapView.swift`. The structured 4+6 activities framework does not exist.

### 1.4 College Images + Rich College Pages
- **What it is:** Every college card and profile should show a real photo of the campus.
- **What's built:** College cards use `AsyncImage` but there are no actual image URLs. The `CollegeModel` has no `imageURL` property. The current database JSON has only 6 colleges with mostly blank data.
- **What's needed:**
  - Add `imageURL` to `CollegeModel`
  - Source: College Scorecard API does NOT provide images. Use a combination of: Unsplash (for generic college photos), Wikipedia API (for official campus photos), or licensed images from a service like MapBox/Google Places
  - Store images in Supabase Storage with college ID as filename
  - Fallback: a gradient with the school's initials

### 1.5 Full College Database (6,500+ schools)
- **Current state:** `florida_colleges_admissions.json` has 6 schools: UF, FSU, USF, RIT, UT, FIU — most with blank data.
- **What's needed:**
  - Seed from College Scorecard API (free US government API, 6,500+ institutions)
  - Enrich top 500 with: deadlines, testing policy, transcript requirements, application platforms
  - Enrich all with: acceptance rate, average GPA, SAT/ACT ranges, tuition, enrollment size
  - College-specific portal names: UF uses STARS, USF has their own, most use Common App
  - Flag which colleges are test-optional, test-required, test-blind (post-COVID landscape)
- **Source:** college_requirements_research.md, college_requirements_db.json

---

## Priority 2 — Key Differentiators (What Makes Ladder Special)

### 2.1 AI-Generated College Pages
- **What it is:** If a student adds a college that doesn't yet have a page in Ladder's database, the AI automatically builds one.
- **How it works:**
  1. Student searches "Gonzaga University" — not in DB
  2. AI scrapes the college's admissions website using Firecrawl
  3. Creates a page with: admissions portal link, application checklist, deadlines, testing policy
  4. That page is now available globally — next student who adds Gonzaga gets the pre-built page
  5. As students go through the application process, the page gets enriched (post-acceptance checklist too)
- **What's built:** Not started.
- **Source:** Export text - IMG8189.MOV

### 2.2 Post-Acceptance Checklist System
- **What it is:** After a student marks an application as "Accepted," a new checklist appears for what to do BEFORE enrollment day.
- **Items vary by school but general template includes:**
  - Pay enrollment deposit (each school has a different deadline — often not publicly listed)
  - Submit official final high school transcript (school sends with seal)
  - Submit immunization records
  - Apply for housing (separate deadline from admissions)
  - FAFSA/financial aid finalization
  - Accept/decline financial aid award letter
  - Register for orientation
  - Set up student email and portal account
  - Sign up for placement tests
- **Key insight from transcript:** These checklists are buried in admitted student portals behind login walls. They have no deadlines listed. Students get completely lost. Ladder solves this with a general template + crowdsourced specifics (students forward acceptance emails, AI parses them).
- **What's built:** The `ApplicationDetailView.swift` exists but only shows application status. The post-acceptance checklist is absent.
- **Source:** Export text - IMG8203.MOV, Export text - IMG8189.MOV

### 2.3 Wheel of Career / Wheel of Life Visualization
- **What it is:** A holistic visual dashboard (like a radar/spider chart) showing where the student stands across all key dimensions.
- **Dimensions suggested:**
  - Academic performance
  - Test prep readiness
  - Extracurricular breadth
  - Career clarity
  - Financial aid preparedness
  - Application completeness
- **Principle:** "You are not telling people this is what you have to do. You are telling people based on the information, this is what you can do NOW, this is HOW you can do it, this is WHERE you can do it, and if you don't have this, here are sources that can help." (4W + H framework)
- **Inspiration:** Real "Wheel of Life" coaching tool adapted for high school students
- **What's built:** Not started. The dashboard shows circular progress for task completion only.
- **Source:** IMG_8200.txt

### 2.4 Alternative Path Flows
- **What it is:** Branches in the 4-year roadmap for students who decide college isn't their path.
- **Paths to support:**
  1. **Community College** — 2 years to get prereqs, then transfer to 4-year
  2. **Trade School** — specific trades, certifications, timeline
  3. **Military** — requirements, benefits, GI Bill explanation, and "what next after service"
  4. **Gap Year** — activities, programs, how to use it productively
- **Key insight:** "A lot of kids are first-gen students. If a kid in a family that's never gone to college wants to go, they have no clue how." But also some truly don't want college — and Ladder should serve them too without judgment.
- **What's built:** Not started. All roadmap content assumes college.
- **Source:** subtitles (5).txt, IMG_8239.txt

---

## Priority 3 — Important Features (Strong Differentiation)

### 3.1 SAT Fee Waiver Checker
- **What it is:** Checks if the student is eligible for free SAT registrations (and potentially free college application fee waivers).
- **Eligibility criteria:** Students who receive free/reduced school meals qualify automatically.
- **Impact:** Reduces a major financial barrier to application. Students should take SAT 2–4 times in 11th grade.
- **Implementation:** Simple eligibility form (free/reduced lunch status) → displays waiver instructions + links to College Board waiver program.
- **Source:** IMG_8200.txt

### 3.2 School/Counselor Dual Portal
- **What it is:** Schools and counselors have their own login and dashboard, separate from students.
- **School side:**
  - Upload list of classes offered (with difficulty ratings)
  - Upload clubs available + tryout/signup dates
  - Upload athletics offered + tryout dates
  - See aggregate student data (what classes students are requesting)
- **Counselor side:**
  - See all their students in one view
  - Receive student class preference submissions
  - Approve or adjust class schedules
  - Track which students are on track / at risk
- **What's built:** Not started. All current auth is student-only.
- **Source:** subtitles (12).txt, IMG_8192.txt, IMG 8238.txt

### 3.3 Parent Profile / FAFSA-Prep Section
- **What it is:** When creating the student profile, also capture parent data for financial aid readiness.
- **Data needed:** Parent education level (first-gen identifier), household income (approximate), number of dependents.
- **Use:** Predict Pell Grant eligibility, flag scholarship opportunities, inform FAFSA readiness score.
- **Source:** subtitles (1).txt

### 3.4 Scholarship Action Plans (Beyond Search)
- **Current state:** `ScholarshipSearchView.swift` exists as a stub.
- **What was envisioned:** 
  - Link to scholarshipsearch.net or similar
  - Student takes scholarship-matching quiz on that platform
  - Screenshots results → uploads to Ladder
  - Ladder reads those screenshots → creates action plan per scholarship ("here's what you need to do to complete most of these")
  - Track scholarship application status same as college applications
- **Source:** subtitles (1).txt, IMG_8239.txt

### 3.5 Academic Resume Builder
- **What it is:** A guided form that helps freshmen create their first academic resume at the start of 9th grade.
- **Based on:** The LRPA academic resume format (mentioned in transcript).
- **Sections:** Hobbies, accomplishments, extracurriculars, goals, GPA.
- **This feeds into:** The career quiz, activity recommendations, and college applications.
- **What's built:** Not started.
- **Source:** subtitles (9).txt

### 3.6 NCAA / Student Athlete Track
- **What it is:** A customizable path for students who want to play college sports.
- **Specific requirements:**
  - NCAA eligibility: GPA maintenance requirements (stricter than general college admission)
  - Recruiting video guidance (what coaches need to see)
  - Highlight reel checklist
  - Athletic GPA tracking separate from academic GPA
  - Division I vs. II vs. III distinctions
  - Team managers / scorekeepers also count as "athletics" for the activities portfolio
- **Source:** IMG_8237.txt

---

## Priority 4 — Future Phase Features

### 4.1 Post-College Career Section
- **What it is:** After a student enrolls in college, Ladder pivots to career planning mode.
- **Features:**
  - Input your major/degree → see list of jobs available
  - AI enriches each job with: salary range, day-in-the-life, required skills, companies hiring
  - Internship matcher (Goldman Sachs-style recruiting happens at campus level — app guides students)
  - College-level resume builder (1-page rule, personalize with company brand colors)
  - Interview prep beyond college admissions
- **Source:** IMG_8239.txt, IMG_8240.txt

### 4.2 Career Life Coach Mode
- **What it is:** For students who join the app late (senior year) or who are completely lost.
- **Features:**
  - "I don't know what I want to do" entry point
  - Intensive career discovery session
  - Fast-tracks to community college / gap year / trade school options
  - No judgment framing
- **Source:** subtitles (5).txt

### 4.3 Messaging / Counselor Chat
- **What it is:** In-app messaging between student and their assigned school counselor.
- **Already in the Route enum:** `case messaging(recipientId: String)` — but placeholder only.
- **Source:** Route.swift

### 4.4 Interview with Field Professionals (Portfolio Item)
- **What it is:** Students conduct an informational interview with a professional in their target field.
- **Counts as:** One of the 6 career-specific portfolio activities.
- **App support:** Template questions, recording consent guidance, upload interview summary.
- **Source:** IMG_8237.txt

---

## Summary: Features in Stitch Designs vs. In Transcripts vs. In Build

| Feature | In Stitch Designs | In Build | In Transcripts |
|---------|------------------|----------|----------------|
| Career Quiz | Partial (CareerQuizView stub) | Stub only | Yes — full spec |
| Transcript Upload | No | No | Yes |
| Class Recommendation Engine | No | No | Yes |
| 4+6 Activities Framework | Partial (TasksView) | Stub | Yes — full spec |
| Wheel of Career visualization | No | No | Yes |
| Full College DB (6,500+) | N/A | No (6 schools) | Yes |
| College Images | In designs | Not wired | Referenced |
| AI-Generated College Pages | No | No | Yes |
| Post-Acceptance Checklist | No | No | Yes |
| Alternative Paths (military etc.) | No | No | Yes |
| SAT Fee Waiver Checker | No | No | Yes |
| School/Counselor Portal | No | No | Yes |
| Parent/FAFSA Profile | Partial (onboarding Q) | Partial | Yes |
| Scholarship Action Plans | Stub | Stub | Yes |
| Academic Resume Builder | No | No | Yes |
| NCAA Athlete Track | No | No | Yes |
| Post-College Career | No | No | Yes |
| Gamification/Streaks | Dashboard streak badge | Partial | Yes (Duolingo ref) |
