# Stitch Screen Prompts — Remaining 5 Screens for Ladder App

Use the same Stitch preset/style as all previous Ladder screens:
- Warm cream background (#FDF8F0)
- Forest green primary (#4A7C59)
- Noto Serif for headlines, Manrope for body
- No lines or dividers — use tonal surface shifts
- Rounded cards with soft shadows
- iOS native feel, modern material design

---

## Screen 1: GPA Tracker — Semester-by-Semester Grade Entry

**Prompt for Stitch:**

Design a mobile iOS screen called "GPA Tracker" for the Ladder college guidance app. This screen lets high school students log their courses and grades each semester to track their GPA over time.

**Layout (top to bottom):**

1. **Header** — Forest green gradient bar at top with white text "GPA Tracker" and a back chevron. Below it, show two large stat numbers side by side: "3.78 Unweighted" and "4.21 Weighted" with small labels underneath.

2. **GPA Trend Chart** — A line chart in a cream card showing GPA progression across semesters. X-axis: "9th Fall", "9th Spring", "10th Fall", "10th Spring", "11th Fall". Y-axis: 2.0 to 4.5. Two lines: solid green for unweighted, dashed lime for weighted. A horizontal dotted line at 3.5 labeled "Bright Futures FAS".

3. **Semester Selector** — Horizontal scrolling pills/chips: "9th Fall", "9th Spring", "10th Fall" (selected, filled green), "10th Spring", "11th Fall". Selected chip is filled forest green with white text.

4. **Course List for Selected Semester** — Each course is a card row showing:
   - Course name (left, e.g., "AP Biology")
   - Grade badge (right, e.g., "A" in a green circle, "B+" in a lime circle)
   - Below the name: small text showing "AP • 1.0 credit" with a small green "AP" tag
   - Show 5-6 courses: "AP Biology (A)", "Honors English III (A-)", "AP US History (B+)", "Pre-Calculus Honors (A)", "Spanish III (B+)", "PE/Health (A)"

5. **Add Course Button** — At the bottom of the course list, a subtle "+ Add Course" button with a plus icon.

6. **Bright Futures Eligibility Card** — A card at the bottom with a star icon showing:
   - "FAS Eligible: Yes ✓" in green
   - "GPA: 3.78 / 3.50 required"
   - "Your weighted GPA qualifies for Florida Academic Scholars (100% tuition)"

**Style notes:** No dividers between courses — use alternating surface tones (cream and slightly darker cream). Grade circles use: A/A- = forest green, B+/B = lime green, B-/C+ = orange, C and below = muted red. The chart should feel clean and minimal like a banking app chart.

---

## Screen 2: Career Explorer — Degree to Jobs + Salary

**Prompt for Stitch:**

Design a mobile iOS screen called "Career Explorer" for the Ladder college guidance app. This screen helps high school students explore what jobs they can get with different college majors and what those jobs pay.

**Layout (top to bottom):**

1. **Header** — Forest green gradient with white text "Career Explorer" and subtitle "See where your degree can take you". Back chevron top left.

2. **Career Path Badge** — A horizontal card showing the student's career path: a circle icon (stethoscope for Medical) with "Your Path: Medical" and a small "Change" link.

3. **Major Selector** — Horizontal scrolling cards, each showing a major name with a small icon. "Pre-Medicine" (selected, green border + checkmark), "Biomedical Science", "Nursing", "Public Health", "Pharmacy". Selected major has a green left border accent.

4. **Salary Range Banner** — A wide card showing: "Pre-Medicine Career Outlook" as the title. Below, a horizontal bar chart showing salary ranges:
   - "Entry Level: $55K - $75K" (short green bar)
   - "Mid-Career: $150K - $280K" (long green bar)
   - "Senior/Specialist: $300K - $500K+" (longest green bar, extends past card with a "+" symbol)
   - Small text: "Source: Bureau of Labor Statistics, 2025"

5. **Job Cards** — 3-4 cards stacked vertically, each showing a specific job:
   - Card 1: "Family Medicine Physician" — Icon: stethoscope — Median: "$235,000" — Growth: "3% ▲" in green — Education: "MD/DO + Residency (11+ years)" — A small tag "High Demand"
   - Card 2: "Surgeon" — Icon: scalpel — Median: "$409,000" — Growth: "3% ▲" — Education: "MD + Surgical Residency (13+ years)"
   - Card 3: "Physician Assistant" — Icon: medical cross — Median: "$126,000" — Growth: "28% ▲▲" in bright green — Education: "Master's (6-7 years)" — Tag: "Fastest Growing"
   - Card 4: "Registered Nurse (BSN)" — Median: "$86,000" — Growth: "6% ▲" — Education: "Bachelor's (4 years)" — Tag: "Most Accessible"

6. **"Related Majors" Section** — Small chips at the bottom: "Biomedical Engineering", "Health Informatics", "Kinesiology" — tappable to explore those paths.

**Style notes:** Salary bars should be horizontal, using forest green gradient fill. Job cards should feel like modern fintech cards — clean, data-dense but not cluttered. Growth arrows in green for positive. Each card has a subtle right-chevron for "learn more."

---

## Screen 3: Counselor Student Detail View

**Prompt for Stitch:**

Design a mobile iOS screen called "Student Profile — Counselor View" for the Ladder college guidance app. This is what a school counselor sees when they tap on a specific student from their dashboard.

**Layout (top to bottom):**

1. **Student Header** — A card with the student's avatar (circle with initials "ER"), name "Emma Rodriguez", "Grade 11 • GPA 3.82 • Medical Path", and a green status badge "On Track".

2. **Quick Stats Row** — Four stat boxes in a horizontal row:
   - "3.82" / "GPA" (green)
   - "1340" / "SAT" (green)
   - "6" / "Activities" (green)
   - "47h" / "Service" (orange, below 100h threshold)

3. **Alert Banner** (conditional) — An orange-tinted card: "⚠️ Service hours behind — needs 53 more hours for Bright Futures FAS by graduation"

4. **College List Section** — Title "Saved Colleges (5)" with school cards:
   - "University of Florida" — "EA: Nov 1" — Status chip: "Planning"
   - "FSU" — "RD: Jan 15" — Status chip: "In Progress"
   - "UCF" — "EA: Oct 15" — Status chip: "Submitted ✓"

5. **Academic Progress** — A condensed version of the GPA chart showing trend line across semesters. Title: "Grade Trend". Small and compact.

6. **Activities Summary** — A list showing top activities:
   - "🏥 Hospital Volunteering — 120 hrs — T2 State Level — Leadership ★"
   - "🔬 Science Fair — Regional Winner — T2"
   - "📚 National Honor Society — Member — T3"

7. **Action Buttons** — Two buttons at the bottom:
   - "Send Message" (outline button)
   - "Flag for Review" (red outline button)

**Style notes:** This is a counselor's productivity view — information-dense but organized. Use tonal card backgrounds to separate sections. No decorative elements — pure data. The alert banner should be noticeable but not alarming.

---

## Screen 4: Roommate Compatibility Quiz

**Prompt for Stitch:**

Design a mobile iOS screen called "Roommate Quiz" for the Ladder college guidance app. This is a compatibility questionnaire that helps match incoming freshmen with compatible roommates.

**Layout (top to bottom):**

1. **Header** — Cream background with "Find Your Roommate" title and subtitle "Answer honestly — better matches come from honest answers". Progress bar showing "Question 3 of 10" with a green fill at 30%.

2. **Question Card** — A large card with:
   - Small icon (moon/sun) in a green circle
   - Question: "What's your sleep schedule?"
   - Four options as tappable cards (not radio buttons):
     - "🌙 Night Owl — I'm most productive after 10pm" (card with moon icon)
     - "☀️ Early Bird — I'm up before 7am naturally" (card with sun icon)
     - "🔄 Flexible — I adapt to whatever works" (card with arrows icon)
     - "📚 Varies — Depends on exams and deadlines" (card with book icon)
   - Selected option has a green left border and subtle green background tint

3. **Categories Covered** (shown at bottom as small dots/icons):
   - Sleep 💤 (completed, green)
   - Cleanliness 🧹 (completed, green)
   - Noise 🔊 (current, pulsing green)
   - Social 👥 (upcoming, gray)
   - Study 📖 (upcoming, gray)
   - Temperature ❄️ (upcoming, gray)

4. **Next Button** — Full-width forest green button "Next Question →" at the bottom.

**Other questions to show in different states (for the designer to understand the variety):**
- "How clean do you keep your space?" — Very Clean / Organized Mess / Relaxed / Clean Common Areas Only
- "How do you feel about guests?" — The More the Merrier / Occasional Friends / Prefer Privacy / Weekends Only
- "Study music or silence?" — Need Complete Silence / Soft Background Music / Doesn't Matter / I Study Elsewhere

**Style notes:** This should feel fun and friendly — not like a boring form. Use emoji in the options to make it feel approachable for 18-year-olds. The cards should feel tappable and satisfying. The selected state should have a subtle bounce animation feel. Clean and modern — think Hinge/Bumble quiz vibes but educational.

---

## Screen 5: PDF Portfolio Preview

**Prompt for Stitch:**

Design a mobile iOS screen called "My Portfolio" for the Ladder college guidance app. This shows a preview of the student's exportable PDF portfolio document that they can share with counselors, parents, or print.

**Layout (top to bottom):**

1. **Top Bar** — "My Portfolio" title, back chevron, and a "Share" button (paper plane icon) on the right.

2. **PDF Preview Card** — A large card that looks like a paper document with a subtle shadow, showing a preview of the PDF:
   
   **Inside the "paper":**
   - Ladder logo (small, top left) + "Student Portfolio" (top right)
   - Student name: "Kathan Patel" in Noto Serif, large
   - "Grade 11 • Pineapple Cove Classical Academy • GPA: 3.78 (4.21W)"
   - A thin green line separator
   
   - **Section: Academic Summary**
     - "SAT: 1340 (Math: 690, Reading: 650)"
     - "AP Courses: AP Biology (5), AP US History (4), AP English Lang (4)"
     - "Career Path: Medical — The Healer"
   
   - **Section: Activities (4 of 6)**
     - "1. Hospital Volunteering — Team Lead — 120 hrs/yr — Tier 2"
     - "2. Science Club — President — 80 hrs/yr — Tier 3"
     - "3. Varsity Swimming — Captain — 200 hrs/yr — Tier 2"
     - "4. Part-time Tutor — Math — 60 hrs/yr — Tier 4"
   
   - **Section: Colleges Applied**
     - "University of Florida (EA) — Submitted"
     - "Florida State University (RD) — In Progress"
     - "UCF (EA) — Accepted ✓"
   
   - Small footer: "Generated by Ladder • April 2026"

3. **Section Toggles** — Below the preview, toggle switches to include/exclude sections:
   - "Academic Summary" ✓ (on)
   - "Activities & Leadership" ✓ (on)
   - "College Applications" ✓ (on)
   - "Test Score History" ○ (off)
   - "Service Hours Log" ○ (off)
   - "Essay Excerpts" ○ (off)

4. **Action Buttons** — Two buttons:
   - "Export as PDF" (filled forest green, full width)
   - "Share with Counselor" (outline green, full width)

**Style notes:** The PDF preview should look like an actual paper document — white background with a subtle drop shadow, slightly smaller than the screen width to show "paper edges." The content inside should use a clean, professional font layout. The toggle section below should feel like settings — functional, not decorative. This screen bridges the app experience with the real-world document the student will use.

---

## HOW TO USE THESE PROMPTS

1. Go to Stitch (stitch.run or your Stitch tool)
2. Use the same project/preset as all previous Ladder screens
3. Paste each prompt one at a time
4. Generate the screen
5. Download the HTML/image
6. Tell Claude "screens are ready" and point to the download folder

These 5 screens + the 75 already designed = **80 total Stitch screens** covering the entire app.
