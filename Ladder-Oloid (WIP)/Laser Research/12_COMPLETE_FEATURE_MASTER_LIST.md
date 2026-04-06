# Complete Feature Master List
_Every single feature from all brainstorm sessions, research files, and design files. The definitive reference._

---

## USER TYPES (3, not 1)

1. **Student** — 9th–12th grade, individual app user
2. **School Counselor** — school-employed counselor, sees their assigned students
3. **Freelance College Counselor** — private/independent counselor, marketplace participant

---

## MODULE 1: ONBOARDING & SETUP

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 1.1 | Student account creation (name, grade, school, DOB) | P1 | Built |
| 1.2 | First-gen student identifier (parents' education level) | P1 | subtitles (1) |
| 1.3 | Parent income bracket (FAFSA prep / Pell Grant predictor) | P2 | subtitles (1) |
| 1.4 | Florida residency flag → activates Bright Futures tracker | P2 | subtitles (6) |
| 1.5 | Free/reduced lunch eligibility → activates SAT fee waiver info | P2 | IMG_8200 |
| 1.6 | Middle school transcript upload (PDF or photo) | P1 | subtitles (9) |
| 1.7 | AI transcript parser (Gemini Vision → extract grades/GPA) | P1 | subtitles (2) |
| 1.8 | Academic resume builder (hobbies, accomplishments, goals) | P2 | subtitles (9) |
| 1.9 | Dream schools wishlist (up to 5 initial saves) | P1 | Built |
| 1.10 | Career quiz (initial) | P1 | subtitles (4) |
| 1.11 | Career path assignment (STEM/Medical/Business/Humanities/Sports) | P1 | subtitles (4) |
| 1.12 | Override option ("AI says STEM but I want Medical") | P1 | IMG_8192 |
| 1.13 | College preferences quiz (campus size, urban/rural, distance, cost) | P1 | subtitles (9) |

---

## MODULE 2: CAREER QUIZ SYSTEM

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 2.1 | Built-in Ladder career quiz (hobbies + lifestyle + career interests) | P1 | subtitles (4) |
| 2.2 | Annual retake prompt (September each year) | P1 | subtitles (11), IMG_8200 |
| 2.3 | Year-over-year comparison ("Last year: Medical → Now: STEM/Medical") | P2 | IMG_8200 |
| 2.4 | 5 career buckets with sub-major dropdowns | P1 | subtitles (4) |
| 2.5 | Freelance counselor-created quizzes (marketplace) | P3 | subtitles (6) |
| 2.6 | Quiz ranking/rating by students | P3 | subtitles (6) |
| 2.7 | College Board quiz link / screenshot import option | P2 | subtitles (2) |
| 2.8 | Wheel of Career visualization (spider chart across 6 life dimensions) | P2 | IMG_8200 |

---

## MODULE 3: ACADEMIC PLANNING

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 3.1 | Annual transcript upload | P1 | subtitles (2) |
| 3.2 | AI class recommendation engine (Easy / Moderate / Hard tiers) | P1 | subtitles (2), IMG_8192 |
| 3.3 | School class catalog (school uploads what they offer) | P2 | subtitles (12), subtitles (14) |
| 3.4 | Student class preference submission → counselor dashboard | P2 | IMG_8192 |
| 3.5 | Counselor review + approval / conflict flagging | P2 | IMG_8192 |
| 3.6 | Graduation credit checker (are you on track to graduate?) | P2 | IMG 8238 |
| 3.7 | Grade tracking (GPA updates each semester) | P1 | subtitles (2) |
| 3.8 | Senior year grade warning (acceptance can be revoked) | P2 | subtitles (3) |
| 3.9 | AP course suggestion with difficulty label | P1 | subtitles (2) |
| 3.10 | Dual enrollment / community college class tracking | P3 | subtitles (5) |

---

## MODULE 4: ACTIVITIES PORTFOLIO

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 4.1 | 4 general activities log (volunteering, clubs, athletics, job) | P1 | subtitles (2), (9) |
| 4.2 | Volunteer hour counter (with Bright Futures threshold warning) | P1 | subtitles (6) |
| 4.3 | Club log with leadership flag | P1 | subtitles (2) |
| 4.4 | Athletics log (school sport, club sport, position, season) | P1 | subtitles (2) |
| 4.5 | Job/work experience log | P1 | subtitles (2) |
| 4.6 | 6 career-specific activities log | P1 | subtitles (2), (9) |
| 4.7 | Activity impact rating (1–10 for college application value) | P2 | subtitles (2) |
| 4.8 | Research paper tracker | P1 | subtitles (2) |
| 4.9 | Internship / job shadow tracker | P1 | subtitles (2) |
| 4.10 | Awards & competitions tracker | P1 | subtitles (2) |
| 4.11 | Science fair project tracker | P2 | IMG_8237 |
| 4.12 | Informational interview log (with consent notes) | P2 | IMG_8237 |
| 4.13 | NCAA athlete track (separate GPA requirements, recruiting video) | P3 | IMG_8237 |
| 4.14 | Common App activities export (AI writes 150-char descriptions) | P2 | subtitles (2) |
| 4.15 | Grade-aware urgency flags ("Junior: time is limited for activities") | P1 | subtitles (11) |
| 4.16 | Peer tutoring as an activity (for 90th+ SAT scorers) | P3 | subtitles.txt |

---

## MODULE 5: COLLEGE DATABASE & DISCOVERY

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 5.1 | 6,900+ colleges seeded (College Scorecard API) | P1 | Research |
| 5.2 | Campus hero photo per college (Google Places API) | P1 | User request |
| 5.3 | School logo (Apistemic Logos API) | P1 | Research |
| 5.4 | School colors (ncaa-team-colors + logo extraction) | P2 | Research |
| 5.5 | Application deadlines (Common App PDF + Firecrawl) | P1 | college_requirements_research.md |
| 5.6 | Testing policy label (required/optional/blind) | P1 | college_requirements_db.json |
| 5.7 | Application platform(s) per school (Common App, STARS, direct) | P1 | subtitles (3) |
| 5.8 | College personality archetype (AI from CDS Section C7) | P1 | Plan doc |
| 5.9 | Admissions philosophy label (test-driven, EC-driven, holistic, open) | P1 | subtitles (5) |
| 5.10 | AI-generated page for unlisted college (Firecrawl on demand) | P2 | IMG8189 |
| 5.11 | College search with filters (major, size, cost, location, type) | P1 | Built (stub) |
| 5.12 | "Best for your major" filter (maps career bucket to strong programs) | P1 | subtitles (9) |
| 5.13 | Housing application deadline (separate from admissions) | P2 | subtitles (3) |
| 5.14 | College-specific portal name label (e.g., "Apply via STARS" for UF) | P1 | subtitles (3) |
| 5.15 | "What does this college want from YOU?" personalized gap analysis | P2 | subtitles (5) |
| 5.16 | Revocation warning (senior year grades) | P2 | subtitles (3) |

---

## MODULE 6: APPLICATION TRACKING

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 6.1 | Add colleges to application list | P1 | Built |
| 6.2 | Application status tracking (planning → submitted → accepted/rejected/waitlisted) | P1 | Built |
| 6.3 | Phase 1 checklist per college (pre-admission) | P1 | IMG8189 |
| 6.4 | Phase 2 checklist per college (post-acceptance, enrollment) | P1 | IMG8203 |
| 6.5 | Financial aid comparison (side-by-side net cost after aid) | P1 | Built (stub) |
| 6.6 | Deadline calendar (all deadlines in one timeline view) | P1 | Built |
| 6.7 | EventKit sync ("Add to Calendar" for each deadline) | P2 | Plan doc |
| 6.8 | Housing application tracker (separate deadlines per school) | P2 | subtitles (3) |
| 6.9 | Waitlist strategy (LOCI generator) | P2 | Built (stub) |
| 6.10 | Decision portal (final committed school confirmation) | P1 | Built (stub) |
| 6.11 | Global college checklists (shared between students who add same college) | P2 | IMG8189 |
| 6.12 | Post-acceptance email upload → AI parses specific deadlines | P3 | college_requirements_research.md |

---

## MODULE 7: AI ADVISOR

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 7.1 | Streaming chat advisor (personalized to student profile) | P1 | Built |
| 7.2 | AI system prompt includes: career path, GPA, activities, colleges | P1 | Built (partial) |
| 7.3 | Quick reply suggestions after each AI message | P1 | Built (stub) |
| 7.4 | Session types: advisor / mock interview / essay review | P1 | Built |
| 7.5 | Daily AI knowledge update (scrapes college news and policy changes) | P2 | subtitles (3) |
| 7.6 | Conversational initial questionnaire for undecided students | P1 | subtitles (9) |
| 7.7 | AI suggests salary ranges for career paths ("you could make $X doing Y") | P2 | subtitles (9) |
| 7.8 | AI class recommendations with explanation | P1 | subtitles (2) |
| 7.9 | AI-generated college page creation (Firecrawl + AI) | P2 | IMG8189 |

---

## MODULE 8: ESSAYS & WRITING

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 8.1 | Essay Hub (track essays per college, progress bars) | P1 | Built (stub) |
| 8.2 | Common App personal statement tracker | P1 | Plan doc |
| 8.3 | Supplemental essay tracker per school | P1 | Plan doc |
| 8.4 | AI essay review (structure, voice, grammar) | P2 | Built (stub) |
| 8.5 | LOCI generator (waitlist letter) | P2 | Built (stub) |
| 8.6 | Thank you note generator (for interviews) | P2 | Built (stub) |

---

## MODULE 9: SCHOLARSHIPS & FINANCIAL AID

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 9.1 | Scholarship search/browse | P1 | Built (stub) |
| 9.2 | Link to scholarshipsearch.net + quiz import | P2 | subtitles (1) |
| 9.3 | Scholarship action plan (what to do to apply for each) | P2 | subtitles (1) |
| 9.4 | SAT fee waiver checker (free/reduced lunch → fee waiver eligible) | P1 | IMG_8200 |
| 9.5 | College application fee waiver checker | P2 | IMG_8200 |
| 9.6 | FAFSA readiness tracker | P2 | subtitles (1) |
| 9.7 | Bright Futures tracker (Florida-specific, volunteer hours + GPA) | P2 | subtitles (6) |
| 9.8 | Financial aid comparison (net cost after aid per accepted school) | P1 | Built (stub) |
| 9.9 | Government funding / Title I program eligibility checker | P3 | subtitles (1) |

---

## MODULE 10: TEST PREP

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 10.1 | SAT/ACT score tracker (log each test attempt) | P1 | IMG_8200 |
| 10.2 | SAT registration reminders | P1 | IMG_8200 |
| 10.3 | PSAT reminder (October of 10th grade) | P2 | Plan doc |
| 10.4 | Test prep resource links (Khan Academy, etc.) | P2 | subtitles.txt |
| 10.5 | SAT tutoring referrals (partner-sponsored) | P3 | subtitles.txt |
| 10.6 | Peer tutoring network (90th+ scorers become tutors) | P3 | subtitles.txt |
| 10.7 | Score improvement advisor (AI suggests focus areas) | P2 | Built (stub) |

---

## MODULE 11: ROADMAP / TIMELINE

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 11.1 | 4-year timeline view (9th → 12th grade) | P1 | Built |
| 11.2 | Grade-aware content (different dashboard per grade level) | P1 | subtitles (5) |
| 11.3 | Milestone checklists per year | P1 | Built |
| 11.4 | Alternative path branches (community college, trade, military, gap year) | P2 | subtitles (5) |
| 11.5 | Early graduation path option | P3 | IMG_8237 |
| 11.6 | Duolingo-style streak and level system | P2 | IMG_8200 |
| 11.7 | "3 things to do this week" daily task widget | P1 | subtitles (6) |

---

## MODULE 12: COUNSELOR PORTAL

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 12.1 | School counselor account (separate from student account) | P2 | subtitles (14) |
| 12.2 | School profile: upload class catalog, clubs, athletics, dates | P2 | subtitles (14) |
| 12.3 | Counselor dashboard: see all assigned students | P2 | subtitles (12) |
| 12.4 | Class preference review + approval workflow | P2 | IMG_8192 |
| 12.5 | At-risk student flags (no activities, no SAT registration, etc.) | P3 | subtitles (11) |

---

## MODULE 13: FREELANCE COUNSELOR MARKETPLACE

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 13.1 | Freelance counselor account creation | P3 | subtitles (6) |
| 13.2 | Counselor profile (credentials, specialty, area) | P3 | subtitles (6) |
| 13.3 | Geographic limit (top 50 counselors statewide, 1 per 100-mile radius) | P3 | subtitles (6) |
| 13.4 | Counselor-created quizzes | P3 | subtitles (6) |
| 13.5 | Quiz ranking + rating by students | P3 | subtitles (6) |
| 13.6 | 1:1 session booking (in-app) | P3 | subtitles (6) |
| 13.7 | Ambassador program (Ms. Gaber, Ms. Demlak as founding counselors) | P2 | subtitles (6) |

---

## MODULE 14: MOCK INTERVIEWS

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 14.1 | College-specific mock interview (AI generates school-tailored questions) | P2 | Built (stub) |
| 14.2 | Student response recording or text input | P2 | Plan doc |
| 14.3 | AI real-time feedback | P2 | Plan doc |
| 14.4 | Post-interview comprehensive report | P2 | Built (stub) |
| 14.5 | Interview prep hub (common questions by school type) | P2 | Built (stub) |

---

## MODULE 15: HOUSING

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 15.1 | Housing preferences quiz (dorm type, room type, meal plan) | P2 | Built (stub) |
| 15.2 | Dorm comparison (per admitted school) | P2 | Built (stub) |
| 15.3 | Roommate finder + compatibility | P3 | Built (stub) |
| 15.4 | Housing application deadline tracker | P2 | subtitles (3) |

---

## MODULE 16: REPORTS & EXPORTS

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 16.1 | PDF portfolio export (activities, essays, accomplishments) | P2 | Plan doc |
| 16.2 | Common App activities section export (AI-generated 150-char descriptions) | P2 | Plan doc |
| 16.3 | Impact report (what Ladder helped the student achieve) | P3 | Built (stub) |

---

## MODULE 17: SETTINGS & PROFILE

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 17.1 | Profile settings (name, grade, school, GPA) | P1 | Built |
| 17.2 | Notification settings | P1 | Built |
| 17.3 | Push notifications for deadlines (3 days, 1 day, day-of) | P2 | Plan doc |
| 17.4 | Parent access toggle (read-only) | P3 | subtitles (8) |
| 17.5 | Data consent management (FERPA, COPPA) | P1 | subtitles (3) |

---

## MODULE 18: POST-COLLEGE (FUTURE PHASE)

| # | Feature | Priority | Source |
|---|---------|----------|--------|
| 18.1 | Career explorer (degree → jobs available + salary data) | P4 | IMG_8240 |
| 18.2 | College-level internship guide (Goldman Sachs-style recruiting) | P4 | IMG_8239 |
| 18.3 | Resume builder (1-page, personalize with company colors) | P4 | IMG_8240 |
| 18.4 | Post-graduation life coach mode | P4 | subtitles (5) |

---

## TOTAL FEATURE COUNT: 115 features across 18 modules
- **P1 (Core — must have):** ~50 features
- **P2 (Important — Phase 2/3):** ~40 features
- **P3 (Differentiating — Phase 4):** ~18 features
- **P4 (Future — Post-launch):** ~7 features
