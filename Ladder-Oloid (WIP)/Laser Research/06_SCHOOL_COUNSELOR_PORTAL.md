# School & Counselor Portal Design
_Sourced from: subtitles (12).txt, IMG_8192.txt, IMG_8239.txt, IMG 8238.txt_

---

## Why a Dual Portal Matters

The app was explicitly designed to serve TWO users: the student AND the counselor.

**From the transcripts:**
> "This is a tool for students AND counselors. You really want to hone in on that when pitching to investors."

> "We're taking two things off the counselor's plate: (1) preparing class schedule recommendations, and (2) informing students on how to go to college."

In large schools with 2,000–7,000 students and only 3–5 counselors, the counselor ratio makes individualized guidance impossible. Ladder doesn't replace counselors — it gives them leverage. Each counselor can now effectively serve 10× more students because the app handles the information delivery and initial recommendation, leaving counselors to handle edge cases, conflicts, and approvals.

---

## School Admin Profile

### Setup (done once by school admin or district):
- School name, district, address
- School type: public / charter / magnet / private
- Upload class catalog:
  - Class name
  - Grade levels (9, 10, 11, 12)
  - Prerequisites
  - Difficulty level (Standard / Honors / AP / Dual Enrollment)
  - Subject area
- Upload clubs directory:
  - Club name
  - Faculty advisor
  - Meeting schedule
  - Open tryout/signup date (if applicable)
- Upload athletics:
  - Sport name
  - Season (Fall / Winter / Spring)
  - Tryout date
  - Open to grades: (9-12, 10-12, etc.)
  - Varsity / JV / Freshman levels

### Why schools would use this:
1. Reduces counselor workload significantly
2. Students arrive to class selection meetings already knowing what they want
3. School gets aggregate data: which career paths are students choosing, which clubs are most popular
4. Counselors can digitally receive and review class preference submissions

**Initial focus:** Manatee County School District. The founders mentioned wanting to partner with Manatee County as the initial pilot district.

---

## Counselor Dashboard

### What a counselor sees:
- Their student roster (by homeroom or assigned group)
- Each student's current grade level and career path
- Each student's class preference submission for next year
- Flags for at-risk students:
  - Low volunteer hours
  - No clubs logged
  - No SAT registration in 11th grade
  - Missing major decision by junior year
- Quick view: who's on track vs. who needs intervention

### Counselor workflow for class scheduling:
1. Students submit class preferences via app (with AI-generated recommendations)
2. Counselor opens their dashboard → sees all students' preferences in one view
3. Counselor reviews each student's list:
   - Approve as-is: one tap
   - Flag a conflict (e.g., "You can't take Weight Training — you need Art credit"): sends notification to student
4. Student sees counselor's note in app, selects alternative from AI-suggested list
5. Final schedule approved → student's roadmap updates

### This replaces:
- Individual parent-teacher-counselor scheduling meetings
- Paper/email back-and-forth about class changes
- Students waiting weeks to find out their schedule

---

## School APIs

### Systems the app needs to potentially integrate with:

**Focus by PowerSchool (Manatee County)**
- Student information system used by Manatee County schools
- Students already log in to Focus for grades, attendance, unofficial transcripts
- **Goal:** API or OAuth connection so students can import grades directly (no manual transcript upload)
- **Reality check:** School district API access requires a formal partnership agreement. Start with manual transcript upload (PDF), then pursue API access as Ladder scales.

**PowerSchool (used by CSUSA / Charter Schools)**
- Similar student information system used by Charter Schools USA
- Same approach: manual first, API partnership second

**STARS (Florida):**
- UF's transcript submission system
- Students from Florida submit high school transcripts through STARS
- Ladder should: explain what STARS is, link to it, provide step-by-step tutorial for UF applicants

---

## Privacy Considerations

- Student data is extremely sensitive (grades, counselor notes, family income)
- FERPA (Family Educational Rights and Privacy Act) governs student records at schools
- **Key FERPA rules:**
  - Schools cannot share student records with third parties without written consent
  - Students (and parents, if under 18) must consent to any data sharing
  - All student data must be encrypted in transit and at rest
- **Ladder's approach:**
  - Student data is owned by the student
  - Schools can only see aggregate anonymized data (e.g., "40% of your 10th graders are interested in STEM")
  - Individual student records are only visible to that student and their explicitly designated counselor
  - Parent access toggle: under-18 students can optionally grant parent read-only access

---

## Pitch Angle for School District Partnerships

When pitching to Manatee County or CSUSA:

> "We reduce counselor workload by automating the class recommendation and college information delivery process. Counselors keep all decision-making authority — they just spend their time on approvals and edge cases instead of starting from scratch with every student. We need the district to share their course catalog data with us and optionally create counselor accounts. No student data leaves our encrypted servers."

Key validation contacts mentioned in transcripts:
- **Ms. Gaber** — private college counselor, charter school connection
- **Ms. Demlak** — high school counselor
- **Mr. Cesar** — school counselor, previously worked at after-school program with juniors/seniors
