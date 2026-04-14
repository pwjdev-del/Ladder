# Stitch Screen Prompts — 10 New Features + 5 School/District Features

Same Stitch preset as all Ladder screens:
- Warm cream background (#FDF8F0), Forest green primary (#4A7C59)
- Noto Serif headlines, Manrope body
- No lines/dividers — tonal surface shifts
- Rounded cards, soft shadows, iOS native feel

---

## STUDENT FEATURES (10 screens)

---

### Screen 1: "What If" Admissions Simulator

Design a mobile iOS screen called "What If Simulator" for the Ladder college guidance app. This lets students see how improving their stats changes their match percentages at saved colleges — in real time.

**Layout (top to bottom):**

1. **Header** — Forest green gradient. White text "What If Simulator" with subtitle "See how changes affect your chances". Back chevron.

2. **Your Current Stats Card** — Cream card showing current profile in a row: "GPA: 3.78" | "SAT: 1340" | "APs: 4" | "Activities: 6". Small "Current Profile" label above.

3. **Simulator Sliders** — Each in its own card:
   - "What if my GPA was..." — Slider from 2.0 to 4.0, current position marked with a green dot at 3.78. As user drags, the number updates live. A "+0.22" delta badge appears when moved.
   - "What if my SAT was..." — Slider from 800 to 1600, current at 1340. Shows "+60" when moved to 1400.
   - "What if I took ___ more APs..." — Stepper: 0, +1, +2, +3, +4. Shows count.
   - "What if I added ___ more activities..." — Stepper: 0, +1, +2, +3.

4. **Impact Results** — Title "How Your Chances Change". A list of saved colleges, each showing:
   - School name (left)
   - Two circular progress indicators side by side: "Now: 45%" (gray-green) → "After: 67%" (bright green) with an upward arrow between them
   - Delta: "+22%" in green bold
   
   Show 4 schools:
   - "University of Florida" — 45% → 67% (+22%)
   - "Florida State" — 72% → 85% (+13%)
   - "UCF" — 88% → 94% (+6%)
   - "MIT" — 5% → 8% (+3%)

5. **Insight Card** — Green-tinted card at bottom: "💡 Biggest impact: Raising your SAT by 60 points would improve your UF chances by 22%. Focus on math — your reading score is already competitive."

**Style notes:** The sliders should feel interactive and satisfying. The before/after percentages should use a smooth animation feel. The insight card should feel like personalized AI advice. Make the delta badges pop with the lime accent color (#CAF24D).

---

### Screen 2: Deadline Heatmap Calendar

Design a mobile iOS screen called "Deadline Heatmap" for the Ladder college guidance app. This shows a full-month calendar view where each day is color-coded by deadline urgency — like a GitHub contribution graph but for college deadlines.

**Layout (top to bottom):**

1. **Header** — Cream background, "October 2026" with left/right month arrows. Small label "DEADLINE HEATMAP" in green.

2. **Month Grid** — Standard 7-column calendar grid (Sun-Sat). Each day cell is a rounded square:
   - Empty days (no deadlines): cream/white background
   - 1 deadline: light green background
   - 2 deadlines: medium green background
   - 3+ deadlines: dark forest green background with white text
   - Today: green ring border
   - Past days: slightly dimmed
   
   Show October with these highlighted:
   - Oct 15 (dark green, 3 deadlines): UCF EA, FAMU EA, Scholarship deadline
   - Oct 20 (light green, 1): SAT registration
   - Nov 1 (dark green, 3): UF EA, FSU EA, Housing deposit
   - Nov 15 (medium green, 2): UCF materials, FAMU materials

3. **Legend** — Small row below calendar: four colored squares with labels: "None" (cream), "1 deadline" (light green), "2 deadlines" (medium green), "3+ deadlines" (dark green)

4. **Selected Day Detail** — When Oct 15 is selected, show a card below:
   - "October 15, 2026 — 3 deadlines"
   - Three items:
     - "🏫 UCF — Early Action Application" with "Add to Calendar" button
     - "🏫 FAMU — Early Action Application" with "Add to Calendar" button
     - "💰 Gates Millennium Scholarship" with "Add to Calendar" button

5. **Upcoming Urgency Strip** — A horizontal scrolling strip at the bottom showing the next 5 deadlines as small cards: "UCF EA — 10 days" (orange), "SAT Reg — 15 days" (yellow), "UF EA — 17 days" (yellow), etc.

**Style notes:** The calendar grid should feel like a data visualization — clean, informative at a glance. The color gradient from cream → dark green should be smooth and distinctive. No borders on cells — just background color changes. Selected day should have a subtle scale-up animation.

---

### Screen 3: "My Chances" Acceptance Calculator

Design a mobile iOS screen called "My Chances" for the Ladder college guidance app. This shows calculated acceptance probability percentages for each saved college based on the student's profile vs school data.

**Layout (top to bottom):**

1. **Header** — Forest green gradient. "My Chances" in white Noto Serif. Subtitle: "Based on your GPA, SAT, and 6,300+ school data points."

2. **Student Profile Summary** — Compact card: "3.78 GPA • 1340 SAT • 4 APs • Medical Path • First-Gen ✓"

3. **Chance Cards** — Sorted from highest to lowest probability. Each card shows:
   
   **Card layout:**
   - Left: Large circular progress ring with percentage inside (e.g., "87%")
   - Center: School name, location, and category badge (Reach/Match/Safety)
   - Right: Small arrow icon
   
   Show 6 schools:
   - UCF — 87% — Safety badge (green)
   - FAU — 82% — Safety badge (green)
   - FSU — 64% — Match badge (lime)
   - USF — 71% — Match badge (lime)
   - UF — 34% — Reach badge (orange)
   - MIT — 6% — Reach badge (red)
   
   Each card has a subtle color tint matching the category: green tint for safety, neutral for match, warm/orange tint for reach.

4. **Factors Breakdown** (expandable per school) — When UF card is tapped, it expands to show:
   - "GPA: ✓ Competitive (3.78 vs 3.9 avg)"
   - "SAT: ⚠ Below median (1340 vs 1420 avg)"
   - "Rigor: ✓ 4 APs (school values rigor as Very Important)"
   - "First-Gen: ✓ Considered as positive factor"
   - "Tip: Raising SAT to 1420 would increase your chances to ~48%"

5. **Methodology Note** — Small text at bottom: "Calculated using admission rates, SAT/ACT ranges, and CDS admissions factor data from 6,322 schools. Estimates only — not guarantees."

**Style notes:** The circular progress rings should use the category colors (green/lime/orange/red). The Reach/Match/Safety badges should be clear and immediate. The expanded factors should feel like a mini gap analysis. Clean, data-confident design — this is Ladder's killer feature.

---

### Screen 4: AI "Why This School" Essay Seed

Design a mobile iOS screen called "Why This School" for the Ladder college guidance app. AI generates a personalized essay outline for the "Why [School]" supplemental essay using real school data + the student's profile.

**Layout (top to bottom):**

1. **Header** — Cream background. School name "University of Florida" in Noto Serif with a small school gradient badge. "Why UF?" as the title. Back chevron.

2. **Connection Score** — A horizontal card showing: "Your Connection Score: 84/100" with a progress bar. Label: "Based on 5 genuine connections found between you and UF."

3. **Generated Connections** — 3-4 cards, each showing a real connection:

   **Card 1:** Icon: stethoscope. "Medical Research Focus"
   "UF's College of Medicine ranks #1 in Florida for primary care. Your hospital volunteering (120 hrs) and AP Biology (score: 5) show you're already building toward this. Mention the Emerging Pathogens Institute as a specific research interest."

   **Card 2:** Icon: flask. "Hands-On Learning Culture"
   "UF rates 'Extracurricular Activities' as Important in admissions. Your 6 activities with 2 leadership roles align perfectly. Reference the Center for Undergraduate Research — UF funds 500+ student research projects annually."

   **Card 3:** Icon: people. "First-Generation Support"
   "UF considers First-Generation status in admissions. As a first-gen student, mention the Machen Florida Opportunity Scholars program — it provides mentorship, housing, and a book stipend specifically for first-gen students."

   **Card 4:** Icon: star. "Florida Bright Futures"
   "Your 3.78 GPA and projected Bright Futures FAS eligibility means UF would cost you $0 in tuition. This financial fit is worth mentioning — it shows you've researched the practical aspects."

4. **Essay Outline** — A card with "Suggested Structure":
   - "Para 1: Open with your hospital volunteering moment that solidified your medical path"
   - "Para 2: Connect to UF's medical research programs (Emerging Pathogens Institute, UF Health)"
   - "Para 3: Mention first-gen journey + Machen Scholars as a support system"
   - "Para 4: Close with how UF's 'Gator Nation' collaborative culture matches your leadership style"

5. **Action Buttons** — "Copy Outline" and "Start Writing in Essay Hub"

**Style notes:** Each connection card should feel like a genuine insight, not a template. Use school-specific details that prove the AI actually knows about UF. The connection score should feel earned, not arbitrary. This should make students say "wow, I didn't know that about this school."

---

### Screen 5: Application Season Dashboard Mode

Design a mobile iOS screen called "App Season Command Center" for the Ladder college guidance app. This is the Home tab's transformed state during October-January (peak application season) — a mission-control-style dashboard focused entirely on applications.

**Layout (top to bottom):**

1. **Countdown Ring** — Large circular countdown at the top: "12 DAYS" in bold inside a green ring, with "until UF Early Action" below. Animated ring depleting.

2. **Application Kanban Board** — Horizontal scrolling columns:
   - Column 1: "Drafting" (2) — FSU card, Georgetown card (each shows school name + deadline)
   - Column 2: "Ready to Submit" (1) — UCF card with a green "Submit Now" button
   - Column 3: "Submitted ✓" (2) — FAMU card (Nov 1), UNF card (Oct 15)
   - Column 4: "Decision" (1) — MIT card with "Waitlisted" orange badge
   
   Each card is draggable between columns (show a subtle drag handle). Cards show: school name, deadline type (EA/ED/RD), days remaining.

3. **Today's Tasks** — A checklist card:
   - "☐ Finalize FSU supplemental essay (due in 5 days)"
   - "☐ Request Ms. Johnson's rec letter for Georgetown"
   - "☑ Submit UCF application fee payment" (completed, strikethrough)
   - "☐ Upload SAT scores to Common App"

4. **Progress Stats Bar** — Horizontal stats: "5 Applied" | "2 Accepted" | "$12,400 in aid" | "47 days left in season"

5. **AI Advisor Quick Chat** — A small chat bubble at the bottom: "Ask anything about your applications..." with a sparkle icon. Tapping opens the advisor chat pre-loaded with application context.

**Style notes:** This should feel like a mission control center — urgent, focused, organized. The kanban board is the hero element. The countdown ring should feel weighty and motivating (not stressful). Use warm orange for urgency, green for completed. This replaces the normal Home tab during app season (Oct 1 - Jan 31).

---

### Screen 6: College Visit Planner + Map

Design a mobile iOS screen called "Campus Visit Planner" for the Ladder college guidance app. This helps students plan college campus visits with a map view and trip planner.

**Layout (top to bottom):**

1. **Map View** — Top half of screen shows a map of Florida with pins for saved colleges:
   - Green pin: UF (Gainesville)
   - Green pin: FSU (Tallahassee)
   - Green pin: UCF (Orlando)
   - Blue pin: USF (Tampa)
   - Gold pin: FIU (Miami)
   - Each pin has a small label with the school abbreviation
   - A dotted route line connects them in an optimized road trip order

2. **Trip Summary Card** — Below the map: "Florida College Tour — 5 Schools" with "Total drive time: 9h 42m" and "Suggested: 3-day trip"

3. **Visit Cards** — Scrollable list of schools in trip order:
   
   **Card 1:** "🟢 UCF — Orlando" — "Tour available: Mon-Fri 10am & 2pm" — Status: "Visited ✓ (Oct 3)" — 0 mi (start)
   **Card 2:** "🟢 UF — Gainesville" — "Tour: Mon-Sat 10am" — Status: "Scheduled (Oct 18)" — 112 mi from UCF
   **Card 3:** "🟢 FSU — Tallahassee" — "Tour: Mon-Fri 11am" — Status: "Not scheduled" — 164 mi from UF
   **Card 4:** "🔵 USF — Tampa" — "Tour: Tue-Thu 9am" — Status: "Not scheduled" — 275 mi from FSU
   **Card 5:** "🟡 FIU — Miami" — "Tour: Mon-Fri 10am" — Status: "Not scheduled" — 280 mi from USF

4. **Action Buttons** — "Plan My Trip" (generates suggested dates) and "Share with Parent" (sends trip plan)

**Style notes:** The map should feel modern (think Apple Maps style with cream/green overlay). The route line should be a dashed green line. Visit cards should clearly show the progression. Status badges: green checkmark for visited, blue clock for scheduled, gray for not yet planned.

---

### Screen 7: Scholarship Match Score

Design a mobile iOS screen called "Scholarship Match" for the Ladder college guidance app. This ranks scholarships by how well the student matches each one's criteria.

**Layout (top to bottom):**

1. **Header** — Forest green gradient. "Scholarship Match" title. Subtitle: "Ranked by how well you fit each scholarship's criteria."

2. **Your Profile Tags** — Horizontal scrolling chips showing factors used for matching: "3.78 GPA ✓", "First-Gen ✓", "FL Resident ✓", "Medical Path ✓", "Free Lunch ✓", "Hispanic ✓", "Service: 47hrs"

3. **Scholarship Cards** — Ranked by match percentage:

   **Card 1 (Best Match):**
   - Match: 92% (large green ring)
   - "Gates Millennium Scholarship"
   - Amount: "Full Ride — All Costs"
   - Deadline: "Sep 15, 2026"
   - Matched criteria: "✓ First-Gen ✓ Low Income ✓ GPA 3.3+ ✓ Leadership ✓ Community Service"
   - Missing: "⚠ Need 100 service hours (you have 47)"
   - "Apply" button

   **Card 2:**
   - Match: 85%
   - "Bright Futures FAS"
   - Amount: "100% FL Public Tuition"
   - Deadline: "Aug 31, 2027"
   - Matched: "✓ FL Resident ✓ GPA 3.5+ ✓ Community Service"
   - Missing: "⚠ Need SAT 1330 (you have 1340 ✓) ⚠ Need 100 hrs (you have 47)"

   **Card 3:**
   - Match: 78%
   - "Coca-Cola Scholars Foundation"
   - Amount: "$20,000"
   - Matched: "✓ GPA 3.0+ ✓ Leadership ✓ Community Impact"
   - Missing: "⚠ Need strong community impact essay"

   **Card 4:**
   - Match: 45%
   - "National Merit Scholarship"
   - Amount: "$2,500 + College-Specific"
   - Matched: "✓ GPA"
   - Missing: "⚠ Need PSAT score (not taken yet)"

4. **Total Potential Aid** — Bottom card: "If you win your top 3 matches: up to $180,000+ in scholarships"

**Style notes:** The match percentage rings should be prominent. Green for 75%+, lime for 50-75%, orange for below 50%. Matched criteria show green checkmarks, missing criteria show orange warnings with specific guidance on what to do. This should feel empowering, not discouraging.

---

### Screen 8: Parent Dashboard (Read-Only View)

Design a mobile iOS screen called "Parent View" for the Ladder college guidance app. This is a simplified, read-only dashboard that parents see after entering their child's invite code. No editing — just viewing.

**Layout (top to bottom):**

1. **Header** — Softer green gradient (lighter than student version). "Emma's College Journey" in Noto Serif. Small badge: "Parent View — Read Only". Ladder logo small in top right.

2. **At-a-Glance Stats** — Four cards in a 2x2 grid:
   - "5 Schools" / "Applied To" (building icon)
   - "2 Accepted" / "Decisions" (checkmark icon, green)
   - "$8,200/yr" / "Best Net Cost" (dollar icon)
   - "8 Days" / "Next Deadline" (calendar icon, orange)

3. **College Status List** — Clean list of schools with status:
   - "University of Florida" — "Early Action" — "Submitted Oct 15" — ✓ green
   - "FSU" — "Regular Decision" — "In Progress" — 🔵 blue
   - "UCF" — "Early Action" — "Accepted! 🎉" — ✓ green with confetti
   - "USF" — "Regular Decision" — "Not Started" — ⚪ gray
   - "FIU" — "Rolling" — "Planning" — ⚪ gray

4. **Financial Summary Card** — "Estimated Costs After Aid":
   - "UCF: $2,400/yr (Bright Futures + merit)" — green, best value highlighted
   - "UF: $6,200/yr (if accepted)"
   - "FSU: $5,800/yr (estimated)"
   
   Small note: "Final costs depend on financial aid packages received after acceptance."

5. **Upcoming Deadlines** — Simple list:
   - "Nov 1 — UF Early Action deadline (8 days)"
   - "Nov 15 — FSU materials due (22 days)"
   - "Dec 1 — FAFSA priority deadline (38 days)"

6. **Bottom Note** — Soft card: "Want to help? Ask Emma about scheduling campus visits together. 🏫" and a "Message Emma" button (opens text/email).

**Style notes:** This should feel calming and informative — parents should NOT feel anxious looking at this. Softer greens, more white space than the student version. No action buttons that could lead to editing. Everything is view-only. The "Accepted!" status should feel celebratory.

---

### Screen 9: Post-Acceptance "First 100 Days" Tracker

Design a mobile iOS screen called "First 100 Days" for the Ladder college guidance app. After a student commits to a school, this becomes their countdown to move-in day with daily micro-tasks.

**Layout (top to bottom):**

1. **Hero Header** — School-colored gradient (UF blue+orange or generic green). "Your First 100 Days at UF" in white Noto Serif. Large countdown: "67 Days Until Move-In" with a circular countdown ring. Move-in date: "August 21, 2027".

2. **Progress Overview** — Horizontal progress bar: "33 of 47 tasks completed (70%)". Small milestones marked on the bar: "Deposit ✓", "Housing ✓", "Orientation ◯", "Move-In ◯"

3. **This Week's Tasks** — 3-4 task cards:
   - "☑ Pay enrollment deposit — $200 ✓ Completed May 1" (green, completed)
   - "☑ Submit housing application ✓ Completed May 3" (green, completed)
   - "☐ Register for orientation — Multiple sessions Jun-Aug" (active, with "Register Now" button)
   - "☐ Submit immunization records — MMR, Hep B, Meningitis" (upcoming, with checklist)

4. **Timeline View** — Vertical timeline with month labels:
   - **May** (now): "Deposit ✓, Housing ✓, Meal Plan"
   - **June**: "Orientation, Placement Tests (Math), Course Registration"
   - **July**: "Immunizations, Buy Textbooks, Roommate Connection"
   - **August**: "Final Transcript, Packing List, Move-In Day 🎓"

5. **School-Specific Tips Card** — "Did you know? UF freshmen should download the ONE.UF app before orientation. Your GatorLink email will be firstname.lastname@ufl.edu"

6. **Packing Checklist Button** — "View Move-In Packing List →" with a box icon.

**Style notes:** This should feel exciting and organized — not overwhelming. The countdown ring should feel like a positive countdown (anticipation, not dread). Completed tasks should feel satisfying. The timeline should show the path clearly. Use the school's actual data (from our Perplexity research) for immunizations, orientation, placement tests.

---

### Screen 10: Peer Comparison (Anonymous)

Design a mobile iOS screen called "How Do I Compare?" for the Ladder college guidance app. This shows anonymous aggregate data comparing the student to other Ladder users applying to the same schools.

**Layout (top to bottom):**

1. **Header** — Cream background. "How Do I Compare?" title. Subtitle: "Anonymous data from Ladder students applying to the same schools. Updated weekly."

2. **School Selector** — Horizontal scrolling school chips: "UF" (selected, green), "FSU", "UCF", "USF". Selected shows green fill.

3. **Your Position Card** — For UF:
   - A horizontal bar showing distribution of applicants' GPAs. The student's position is marked with a green dot and arrow: "Your GPA: 3.78 — Higher than 68% of UF applicants on Ladder"
   - Same for SAT: "Your SAT: 1340 — Higher than 52% of UF applicants"
   - Same for Activities: "Your activities: 6 — More than 71% of UF applicants"

4. **Aggregate Stats** — Three comparison cards:
   - "Average GPA of Ladder UF applicants: 3.82" (your 3.78 is slightly below — yellow indicator)
   - "Average SAT of Ladder UF applicants: 1380" (your 1340 is below — orange indicator)
   - "Average Activities: 4.2" (your 6 is above — green indicator)

5. **Strength/Weakness Summary** — AI-generated card:
   - "💪 Strengths: Your extracurricular portfolio (6 activities, 2 leadership) is stronger than most UF applicants on Ladder."
   - "📈 Opportunity: Your SAT is 40 points below the Ladder average for UF. Consider one more practice session."

6. **Privacy Note** — "All comparisons use anonymized, aggregate data. No individual student data is ever shared. Minimum 10 applicants required per school to show data."

**Style notes:** The distribution bars should look like horizontal histograms with a clean, modern feel. The student's position marker should be prominent (green dot with label). This should feel encouraging and actionable, not discouraging. Use green for "above average", yellow for "near average", orange for "below average" — never red.

---

## SCHOOL & DISTRICT FEATURES (5 screens)

*These are the B2B features — sell Ladder to schools and districts so counselors can manage all their students in one place.*

---

### Screen 11: School Admin Dashboard (Principal/AP View)

Design a mobile iOS screen called "School Dashboard" for the Ladder college guidance app. This is what a school administrator (principal or assistant principal) sees — aggregate data about their school's college readiness.

**Layout (top to bottom):**

1. **Header** — Forest green gradient with school name: "Pineapple Cove Classical Academy" and "2026-2027 College Readiness Dashboard". Ladder logo small. School logo placeholder circle.

2. **Key Metrics Row** — Four large stat cards:
   - "247" / "Active Students" (person icon)
   - "89%" / "College-Bound Rate" (graduation cap, green)
   - "1,247" / "Applications Submitted" (paper plane)
   - "$2.1M" / "Total Aid Secured" (dollar, gold)

3. **Acceptance Rate Chart** — Bar chart showing acceptance rate by school type:
   - "FL Public (SUS): 78%" (long green bar)
   - "FL Private: 45%" (medium bar)
   - "Out of State: 32%" (shorter bar)
   - "Ivy/T20: 8%" (short bar)
   - Compared to "State Average" dotted line overlay

4. **Grade-Level Breakdown** — Four cards in a 2x2 grid:
   - "12th Grade (62 students): 85% applied, 42 accepted so far"
   - "11th Grade (58 students): 70% have SAT scores, avg 1210"
   - "10th Grade (65 students): 45% completed career quiz"
   - "9th Grade (62 students): 82% onboarded to Ladder"

5. **At-Risk Students Alert** — Orange-tinted card: "⚠ 12 students flagged: 5 no SAT registration (11th), 4 GPA below 2.5, 3 zero activities logged"

6. **Top Destinations** — "Where Our Students Are Going":
   - "UF — 12 accepted" with small UF badge
   - "UCF — 18 accepted"
   - "FSU — 9 accepted"
   - "Valencia (DE) — 24 enrolled"

**Style notes:** This should feel like a principal's executive dashboard — high-level, data-driven, clean. Charts should be simple and readable. The at-risk alert should be noticeable but constructive (not punitive). This is the screen that sells Ladder to school administrators.

---

### Screen 12: Counselor Caseload Manager

Design a mobile iOS screen called "My Caseload" for the Ladder college guidance app. This is what a school counselor sees daily — their assigned students organized by urgency and status.

**Layout (top to bottom):**

1. **Header** — Cream background. "My Caseload" title. "Ms. Rodriguez — 87 Students". Filter pills: "All" (selected), "Needs Action", "On Track", "At Risk".

2. **Urgency Summary** — Three cards in a row:
   - "🔴 8 Urgent" (red-tinted) — "Deadlines within 7 days"
   - "🟡 15 Action Needed" (yellow-tinted) — "Missing items"
   - "🟢 64 On Track" (green-tinted) — "No issues"

3. **Student Cards** (scrollable list, sorted by urgency):

   **Urgent Card (red left border):**
   - "Marcus Williams — Grade 12"
   - "⚠ UF EA deadline in 3 days — missing transcript"
   - "GPA: 2.4 ⬇ | SAT: 1080 | Activities: 1"
   - Quick actions: "Send Reminder" | "Schedule Meeting" | "View Full Profile"

   **Action Needed Card (yellow left border):**
   - "Aisha Johnson — Grade 11"
   - "No SAT registration — spring test dates closing soon"
   - "GPA: 3.6 | SAT: — | Activities: 4"
   - Quick actions: "Send SAT Info" | "View Profile"

   **On Track Card (green left border):**
   - "Emma Rodriguez — Grade 12"
   - "All apps submitted. 2 acceptances. Awaiting 3 decisions."
   - "GPA: 3.82 | SAT: 1340 | Activities: 6"
   - Quick action: "View Profile"

4. **Quick Stats** — Bottom card: "This week: 5 meetings scheduled, 12 transcript requests pending, 3 LoR letters to write"

5. **Bulk Actions Button** — "Send Deadline Reminders to All Urgent Students" (green button)

**Style notes:** This is a PRODUCTIVITY tool — counselors have 400+ students and need to triage fast. The urgency color coding must be immediately readable. Quick action buttons should be one-tap. The bulk actions button saves counselors hours. This screen is what makes counselors say "I need this tool."

---

### Screen 13: District Analytics Dashboard

Design a mobile iOS screen called "District Overview" for the Ladder college guidance app. This is what a county/district administrator sees — aggregate data across all schools in their district.

**Layout (top to bottom):**

1. **Header** — Deep green gradient. "Brevard County School District" and "2026-2027 College Readiness Report". Ladder logo + district seal placeholder.

2. **District-Wide Metrics** — Large stat cards in a row:
   - "4,872" / "Students on Ladder" (across 12 schools)
   - "91%" / "Onboarding Rate"
   - "78%" / "College-Bound Rate"
   - "$8.4M" / "Total Aid Secured"

3. **School Comparison Table** — Horizontal scrolling table:
   | School | Students | College-Bound | Avg GPA | Avg SAT | Aid/Student |
   | Pineapple Cove | 247 | 89% | 3.42 | 1180 | $8,500 |
   | Viera High | 412 | 82% | 3.28 | 1150 | $6,200 |
   | Melbourne High | 389 | 76% | 3.15 | 1120 | $5,800 |
   | Palm Bay High | 356 | 71% | 2.98 | 1050 | $4,200 |
   
   Sortable by any column. Color-coded: green for above district average, red for below.

4. **Equity Metrics** — Important card:
   - "First-Gen Students: 34% of students, securing 28% of aid" (gap indicator)
   - "Free/Reduced Lunch: 42% of students, 38% college-bound vs 89% non-FRL" (gap indicator)
   - "SAT Access: 67% of 11th graders have taken SAT (state avg: 72%)" (gap indicator)

5. **Bright Futures Eligibility** — "District Bright Futures Projection":
   - "FAS Eligible: 312 students (projected)"
   - "FMS Eligible: 489 students (projected)"
   - "Total Bright Futures savings: ~$4.2M in tuition"

6. **Export Report Button** — "Download District Report (PDF)" and "Share with School Board"

**Style notes:** This is an executive report — clean, authoritative, data-forward. The school comparison table is the centerpiece. Equity metrics should be prominent (this is what gets district funding). The Bright Futures projection makes the ROI tangible for Florida districts. This screen sells Ladder to superintendents.

---

### Screen 14: Class Scheduling Workflow (Counselor + Student)

Design a mobile iOS screen called "Class Schedule Review" for the Ladder college guidance app. This shows the counselor's view of a student's class preference submission — the counselor can approve, suggest changes, or flag conflicts.

**Layout (top to bottom):**

1. **Header** — "Class Schedule Review" with student name "Emma Rodriguez — Grade 12" and a status badge "Pending Review" (yellow).

2. **Student's Requested Schedule** — Cards for each period:
   - "Period 1: AP Calculus BC" — AI tag: "✓ Recommended for Medical Path" — Green checkmark from counselor
   - "Period 2: AP Biology" — AI tag: "✓ Aligns with career goal" — Green checkmark
   - "Period 3: AP English Literature" — AI tag: "✓ Meets graduation req" — Green checkmark
   - "Period 4: Spanish IV Honors" — AI tag: "✓ World Language req" — Green checkmark
   - "Period 5: Anatomy & Physiology" — AI tag: "⚠ Conflict: same period as AP Chemistry" — Red flag
   - "Period 6: PE/Health" — AI tag: "✓ Graduation requirement" — Green checkmark
   - "Period 7: Study Hall" — AI suggestion: "Consider replacing with Dual Enrollment: Intro to Health Science at Eastern Florida State"

3. **Conflict Resolution Card** — Orange card:
   - "⚠ Period 5 Conflict: Anatomy & AP Chemistry are both offered Period 5"
   - "Recommendation: Take AP Chemistry (stronger for medical school applications)"
   - Two buttons: "Accept Recommendation" | "Keep Student's Choice"

4. **AI Analysis Card** — Green card:
   - "This schedule includes 4 APs and 1 Honors course. Rigor level: High."
   - "Bright Futures impact: This course load supports FAS eligibility (weighted GPA boost: +0.4)"
   - "College readiness: 5/6 courses align with Medical career path"

5. **Action Buttons** — "Approve Schedule" (green), "Request Changes" (outline), "Schedule Meeting with Student" (outline)

**Style notes:** This is a WORKFLOW screen — counselor needs to review quickly and take action. Green checkmarks, red flags, and yellow warnings must be scannable. The AI recommendations add value by doing analysis the counselor doesn't have time for. The conflict resolution should be one-click. This saves counselors hours during scheduling season.

---

### Screen 15: Counselor Impact Report (for School Board)

Design a mobile iOS screen called "Counselor Impact Report" for the Ladder college guidance app. This generates a shareable report showing how the counseling department's work (via Ladder) translated into student outcomes — designed to present to school boards and district administrators.

**Layout (top to bottom):**

1. **Report Header** — White paper-style card with Ladder logo + school logo. "Pineapple Cove Classical Academy — Counseling Department Impact Report — 2026-2027". Generated date.

2. **Executive Summary Card** — Green-bordered card:
   - "Through Ladder, our counseling team supported 247 students across grades 9-12."
   - "Key outcome: 89% college-bound rate (up from 76% last year)"
   - "Total financial aid secured: $2.1M (up 34% from last year)"

3. **Counselor Workload Metrics** — Shows how Ladder saved time:
   - "Average student interactions per counselor: 847/year → 1,240/year (+46% via Ladder)"
   - "Time saved on transcript requests: 120 hours (automated via STARS/SSAR)"
   - "Deadline reminders sent automatically: 3,400+ (zero missed deadlines)"
   - "Career quiz completions: 92% of students (vs 15% paper-based last year)"

4. **Student Outcome Charts** — Two side-by-side bar charts:
   - Left: "Applications Submitted" — 2025: 890 → 2026: 1,247 (+40%)
   - Right: "Acceptances Received" — 2025: 612 → 2026: 894 (+46%)

5. **Equity Outcomes** — Important section:
   - "First-gen students with college plans: 78% (up from 52%)"
   - "Free/reduced lunch students applying to 4-year schools: 61% (up from 38%)"
   - "Students who completed FAFSA: 89% (up from 67%)"

6. **Bright Futures Impact** — "Projected Bright Futures awards: 89 FAS + 124 FMS = $1.8M in state scholarship money for our students"

7. **Testimonial Quotes** — Small cards with student/parent quotes:
   - "Ladder helped me find scholarships I didn't know existed. I'm the first in my family going to college." — Student, 12th Grade
   - "For the first time, I could see exactly where my daughter's applications stood." — Parent

8. **Footer** — "Powered by Ladder — Guiding Students to Success" with share/export buttons.

**Style notes:** This should look like a professional annual report — clean, authoritative, shareable with a school board. The equity outcomes section is critical — this is what gets continued funding. The "time saved" metrics justify the technology investment. Charts should be simple and impactful. This report is Ladder's B2B sales document — it sells the product to decision-makers.

---

## SUMMARY

| # | Screen | Type | Selling To |
|---|--------|------|-----------|
| 1 | What If Simulator | Student | Individual |
| 2 | Deadline Heatmap | Student | Individual |
| 3 | My Chances Calculator | Student | Individual |
| 4 | Why This School Essay Seed | Student | Individual |
| 5 | App Season Dashboard | Student | Individual |
| 6 | College Visit Planner | Student | Individual |
| 7 | Scholarship Match Score | Student | Individual |
| 8 | Parent Dashboard | Parent | Individual/School |
| 9 | First 100 Days Tracker | Student | Individual |
| 10 | Peer Comparison | Student | Individual (needs user base) |
| 11 | School Admin Dashboard | Admin | **School** |
| 12 | Counselor Caseload Manager | Counselor | **School** |
| 13 | District Analytics Dashboard | District Admin | **County/District** |
| 14 | Class Scheduling Workflow | Counselor + Student | **School** |
| 15 | Counselor Impact Report | Counselor/Admin | **School Board** |

**Total new screens: 15**
**Previous screens: 80**
**Grand total: 95 Stitch screens covering the entire Ladder platform**

These 5 B2B screens (11-15) are what turns Ladder from a consumer app into an **enterprise education platform**. The District Analytics Dashboard and Counselor Impact Report are what superintendents and school boards need to see to justify purchasing Ladder for their entire district.
