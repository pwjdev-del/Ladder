# Stitch Prompt — Ladder Desktop (Mac + Web — Complete — 132 Screens)

You are designing the **complete Desktop version** of Ladder, a college preparation app for high school students, parents, counselors, and school administrators. This single design serves both the **Mac native app** and the **web app** — identical layouts. Optimized for **mouse/keyboard** with hover states, dense information, and multi-window workflows.

---

## DESIGN SYSTEM — "Evergreen Ascent"

### Colors (Light Mode)
- **Primary (Forest Green):** #42603f
- **Primary Container:** #5a7956
- **On Primary:** #ffffff
- **On Primary Container:** #e2ffda
- **Secondary (Lime):** #516600
- **Secondary Fixed:** #caf24d
- **Secondary Fixed Dim:** #afd531
- **On Secondary Fixed:** #161e00
- **Accent Lime:** #A1C621
- **Tertiary (Warm Tan):** #725232
- **Tertiary Container:** #8d6a48
- **Tertiary Fixed:** #ffdcbd
- **Surface (Warm Cream):** #fff8f2
- **Surface Container Lowest:** #ffffff
- **Surface Container Low:** #fbf2e8
- **Surface Container:** #f5ede2
- **Surface Container High:** #efe7dd
- **Surface Container Highest:** #eae1d7
- **Surface Variant:** #eae1d7
- **Surface Dim:** #e1d9cf
- **Surface Bright:** #fff8f2
- **On Surface (Text):** #1f1b15
- **On Surface Variant:** #434840
- **Outline:** #737970
- **Outline Variant:** #c3c8be
- **Error:** #ba1a1a
- **Error Container:** #ffdad6
- **On Error:** #ffffff
- **On Error Container:** #410002
- **Inverse Surface:** #343029
- **Inverse On Surface:** #f8efe5
- **Inverse Primary:** #a8d4a0

### Colors (Dark Mode)
- **Primary:** #a8d4a0
- **Primary Container:** #304e2e
- **On Primary:** #1a3518
- **On Primary Container:** #c4f0bb
- **Secondary:** #b3d430
- **Surface:** #1f1b15
- **Surface Container Lowest:** #1a1612
- **Surface Container Low:** #252119
- **Surface Container:** #2a2620
- **Surface Container High:** #353027
- **Surface Container Highest:** #403a30
- **Surface Variant:** #403a30
- **Surface Dim:** #1f1b15
- **Surface Bright:** #3a342a
- **On Surface:** #eae1d7
- **On Surface Variant:** #c3c8be
- **Outline:** #8d9385
- **Outline Variant:** #434840
- **Error:** #ffb4ab
- **Error Container:** #93000a

### Typography
- **Display Large:** Noto Serif Bold, 56pt
- **Display Medium:** Noto Serif Bold, 45pt
- **Display Small:** Noto Serif Bold, 36pt
- **Headline Large:** Noto Serif Bold, 32pt
- **Headline Medium:** Noto Serif SemiBold, 28pt
- **Headline Small:** Noto Serif Medium, 24pt
- **Title Large:** Manrope Bold, 22pt
- **Title Medium:** Manrope SemiBold, 16pt
- **Title Small:** Manrope SemiBold, 14pt
- **Body Large:** Manrope Regular, 16pt
- **Body Medium:** Manrope Regular, 14pt
- **Body Small:** Manrope Regular, 12pt
- **Label Large:** Manrope Bold, 14pt
- **Label Medium:** Manrope Bold, 12pt
- **Label Small:** Manrope SemiBold, 10pt
- **Italic variants:** Noto Serif BoldItalic (display), Noto Serif Italic (headline/body)
- **Letter Spacing:** Headlines: editorial tracking (-0.5), Labels: wide tracking (+2.0)

### Spacing (8pt grid)
- xxs: 2, xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48, xxxl: 64, xxxxl: 80

### Corner Radius
- sm: 8, md: 12, lg: 16, xl: 24, xxl: 32, xxxl: 40, pill: 9999

### Shadows
- **Ambient (cards):** rgba(31,28,20, 0.06), blur 20, y-offset 4
- **Floating (modals/dropdowns):** rgba(31,28,20, 0.06), blur 30, y-offset 10
- **Glow (CTAs, progress):** rgba(201,242,77, 0.30), blur 15, no offset
- **Primary Glow (buttons):** rgba(66,96,63, 0.15), blur 20, y-offset 4

### Component Styles
- **Primary Button:** Gradient primary→primaryContainer, pill shape, white text. Hover: brightness +5% + primary glow. Active: scale 0.98.
- **Accent Button:** Accent Lime background, dark text, glow shadow. Hover: brightness +5%.
- **Secondary Button:** Surface Container High background, on-surface text. Hover: outline appears.
- **Tertiary Button:** Text-only, underline on hover.
- **Cards:** Surface Container Low background, XL corner radius, ambient shadow. Hover: lift (shadow deepens, -2px y-translate).
- **Chips:** Surface Container High background, pill shape, Label Small. Hover: outline appears.
- **Text Fields:** Surface Container Lowest background, outline border, LG radius. Focus: primary border + primary glow.
- **Table Rows:** Hover: Surface Container High background. Selected: Surface Container background + left primary border.
- **Links:** Primary color text, underline on hover.
- **Tooltips:** Inverse Surface background, Inverse On Surface text, SM radius, floating shadow, appear on hover after 300ms.
- No divider lines — use spacing and elevation to separate content.

### Desktop Interaction States
- **Hover:** All interactive elements must have hover states
- **Focus:** 2px primary outline with 2px offset (keyboard navigation)
- **Active/Pressed:** Scale 0.98 + deeper shadow
- **Disabled:** 40% opacity, cursor: not-allowed
- **Right-click:** Context menus on cards, list items, table rows
- **Keyboard shortcuts:** ⌘K search, ⌘N new, ⌘/ toggle sidebar, Esc close modals
- **Tooltips:** On all icon-only buttons and truncated text

---

## DESKTOP NAVIGATION PATTERN

### Top Navigation Bar (Fixed, 64px height)
- **Left:** Ladder logo (graduation cap + "Ladder" wordmark) + sidebar toggle (hamburger)
- **Center:** Breadcrumb trail (e.g., "Colleges > Harvard > Deadlines")
- **Right:** Search button (⌘K hint) + Notification bell (badge) + Theme toggle (sun/moon) + Profile avatar dropdown (Edit Profile, Settings, Sign Out)

### Left Sidebar (240px, collapsible to 64px icon-only mode)
Background: Surface Container Low

**Student Navigation:**
1. **Dashboard** (house icon)
2. **Tasks** (checkmark icon) — Sub: Checklist, Roadmap, Activities
3. **Colleges** (graduationcap icon) — Sub: Discovery, My List, Compare, Visit Planner
4. **Applications** (doc icon) — Sub: Tracker, Deadlines, Season Dashboard
5. **Advisor** (sparkles icon) — Sub: Chat, Essay Hub, Score Prep, Interview Prep
6. **Financial** (dollar icon) — Sub: Scholarships, Aid Comparison, FAFSA
7. **Career** (briefcase icon) — Sub: Quiz, Explorer
8. **Housing** (building icon) — Sub: Preferences, Dorms, Roommates
9. **Reports** (chart icon) — Sub: Portfolio, Resume, Paths

**Bottom:** Settings gear + Help icon
**Collapsed:** Icons only + tooltips
**Selected:** Primary background pill
**Hover:** Surface Container High background

### Role Switcher (B2B)
- Top nav dropdown if user has multiple roles: "Student View" | "Counselor View" | "Admin View"
- Sidebar changes navigation items based on role

### Content Area
- Max content width: 1200px centered with auto margins
- Padding: xl (32px) on sides
- Independent scroll from sidebar

---

## ALL 132 SCREENS

---

## SECTION A: AUTH & ONBOARDING (16 screens)

### A1. SPLASH SCREEN / LOADING
- Full-screen gradient (primary → surface)
- Centered: Ladder logo (graduation cap in rotated square) + "Ladder" wordmark
- Subtle lime glow pulse animation
- Loading bar or spinner below
- Web: Also serves as initial load screen

### A2. LOGIN
**Layout: Split screen**
Left half (50%):
- Brand panel: Gradient green background
- Large Ladder logo centered
- "Your Future, Designed by You" (Display Small, Noto Serif)
- Decorative geometric shapes + floating graduation cap icons
- Student testimonial quote at bottom (optional)

Right half (50%):
- Centered form (max-width 420px):
  - "Welcome Back" (Headline Large)
  - Email field (envelope icon)
  - Password field (lock icon, show/hide toggle)
  - "Forgot Password?" link (right-aligned)
  - Error message (error color)
  - "Log In" accent button (full width, glow)
  - Divider "Or continue with"
  - Google + Apple buttons (side by side)
  - "Don't have an account? Create Account" link

### A3. SIGN UP
**Layout: Same split as Login**
Right form:
- "Create Account" headline
- Email field
- Password field + strength indicator bar (red→amber→green)
- Confirm password field
- Terms checkbox with links
- "Create Account" accent button
- "Already have an account? Log In" link

### A4. FORGOT PASSWORD
**Layout: Centered card (max-width 420px) on brand background**
- "Reset Password" headline
- Description text
- Email field
- "Send Reset Link" button
- "Back to Login" link
- **Success:** Check icon + "Check your email" + "Open Mail App" button

### A5. ROLE SELECTION
**Layout: Centered (max-width 600px)**
- "How will you use Ladder?" headline
- 2x2 grid of role cards:
  - Student (graduation cap), Parent (heart), Counselor (person.badge), Admin (building)
  - Each: Icon, title, description
  - Hover: Border highlight + shadow lift
  - Selected: Primary border + checkmark
- "Continue" button

### A6. ONBOARDING — STEP 1: WELCOME
**Layout: Centered (max-width 680px)**
- Step bar (5 steps, step 1 active — labels: Welcome, Basic Info, Academics, Dream Schools, Ready)
- Hero gradient rectangle with sparkles icon (centered)
- "Your Future, Designed by You" (Headline Large)
- Subtitle text
- "Let's Get Started" accent button

### A7. ONBOARDING — STEP 2: BASIC INFO
**Layout: Centered form (max-width 680px)**
- Two-column: First Name + Last Name
- Full: School (autocomplete dropdown on type)
- Full: Student ID (optional)
- Grade: 4 button selector (9th-12th), hover state each
- First-gen toggle
- "Continue" + "Back"

### A8. ONBOARDING — STEP 3: ACADEMIC PROFILE
**Layout: Centered form (max-width 680px)**
- GPA: Number input with +/- stepper (0.0-5.0)
- SAT + ACT: Side by side
- AP/Honors: Chip flow with X to remove, "Add Course" button (autocomplete dropdown)
- "Continue" + "Back"

### A9. ONBOARDING — STEP 4: DREAM SCHOOLS
**Layout: Centered (max-width 800px)**
- Search bar with autocomplete dropdown
- Selected: Removable chips above grid
- College grid: **4 columns** on desktop. Cards: Building icon, name, location, checkmark if selected. Hover: border highlight.
- "Continue" + "Back"

### A10. ONBOARDING — STEP 5: READY TO LEAD
**Layout: Centered (max-width 680px)**
- Trophy icon, "Ready to Lead?" headline
- Profile summary card (horizontal): Avatar+name+grade | GPA+SAT+career | Milestones+targets
- "Enter Dashboard" accent button + "Review Profile" secondary

### A11. PARENT ONBOARDING / INVITE CODE ENTRY
**Layout: Centered card (max-width 450px)**
- "Join Your Child on Ladder" headline
- Parent-student connection illustration
- 6-digit code input (6 individual boxes)
- Helper text: "Your child shared this code from their profile"
- "Connect" button
- Success: Checkmark animation, "Connected to [Name]!", "Go to Dashboard"
- Error: Shake animation, "Invalid code"

### A12. COUNSELOR ONBOARDING / SCHOOL CODE ENTRY
**Layout: Centered card (max-width 450px)**
- "Welcome, Counselor" headline
- School code field
- "Join School" button
- "I'm a freelance counselor" link → verification flow
- Success: School name + logo + student count, "Enter Dashboard"

### A13. COPPA AGE GATE
**Layout: Centered card (max-width 450px)**
- "Before We Begin" headline
- "What is your date of birth?" — date picker (dropdown selectors)
- "Continue" button
- Under-13: "Parental Consent Required" — parent email field, "Send Consent Request"

### A14. FERPA / PARENTAL CONSENT FLOW
**Layout: Centered card (max-width 600px)**
- "Data Sharing Consent" headline
- Scrollable legal text (plain language FERPA explanation)
- Bullet points: What's shared, who sees it, how to revoke
- Consent checkbox + digital signature (name typed)
- "I Agree" button + "Decline" secondary

### A15. FORCE PASSWORD CHANGE
**Layout: Centered card (max-width 420px)**
- Lock icon
- "Set Your New Password" headline
- "Your counselor created your account"
- Temp password (read-only)
- New password + strength indicator
- Confirm password
- "Update Password" button

### A16. COUNSELOR VERIFICATION FLOW
**Layout: Centered multi-step card**
- Step 1: Identity — Name, email, phone, school/org, role dropdown
- Step 2: Credentials — Drag-and-drop document upload + file list
- Step 3: Pending — Hourglass icon, "Reviewing (1-2 business days)", "Contact Support" link

---

## SECTION B: STUDENT DASHBOARD & HOME (4 screens)

### B1. STUDENT DASHBOARD
**Layout: Three-column grid**

Row 1 (full width):
- **Welcome Banner** card (gradient green): Left: "Good morning, [Name]" + career path badge + grade badge. Center: Quick actions ("Continue Task", "View Deadlines", "Chat Advisor"). Right: Avatar + streak count.

Row 2 (three columns, equal):
- **Checklist Progress:** Circular ring (120px) + "X/Y completed" + progress bar + "View All Tasks"
- **Next Up:** Current task title + category chip + progress bar + description preview + "Continue" button
- **Urgent Deadline:** Dark card, red left border, deadline title + college + date + days remaining (large) + "View Application"

Row 3 (two columns):
- **Quick Stats (2x2):** GPA, SAT, Colleges Saved, Streak Days — icon, number, label, trend arrow
- **Daily Tip:** Gradient lime card, lightbulb icon, tip text, "See More Tips" link

### B2. WEEKLY "3 THINGS TO DO" WIDGET
**Layout: Card (embeddable in dashboard or standalone max-width 500px)**
- "This Week's Priorities" header
- 3 task cards: Priority badge (1/2/3), task title, category chip, due date, "Do It" button
- "See All Tasks" link
- AI-generated based on deadlines + grade + career path

### B3. NOTIFICATIONS CENTER
**Layout: Full page with master-detail**
Left (35%):
- "Notifications" header + unread badge
- Filter tabs: All | Deadlines | Tasks | Scholarships | Messages
- Notification list: Unread (bold, surface container BG), Read (regular). Icon + title + preview + time ago.
- Click to select, hover: highlight

Right (65%):
- Expanded notification detail
- Action buttons per type: "View Application", "Complete Task", "View Scholarship", Reply field
- Empty: "Select a notification"

### B4. STREAK & ACHIEVEMENTS
**Layout: Two-column**
Left (55%):
- Current streak: Fire icon + count (Display Medium)
- Streak calendar: Month grid, consecutive days in lime
- Longest streak stat
- Motivational text

Right (45%):
- Achievements grid (3 columns): Badge icon + title per achievement
- Locked: Grayed silhouette with "?" and unlock condition on hover tooltip
- Progress toward next achievement: Progress bar

---

## SECTION C: TASKS & CHECKLISTS (6 screens)

### C1. TASKS VIEW
**Layout: Three-panel**
Left (240px): Filter sidebar — search, category filters (vertical list with counts), sort options
Center (remaining - 360px): Task list — TO DO section (rows: checkbox, icon, title, desc preview, category chip, due date, priority dot; hover: row highlights + quick-action icons) + COMPLETED section (collapsible)
Right (360px): Task detail panel — title, category, priority, due date, description, subtasks, resources, notes, "Mark Complete" button. Empty: "Select a task"

### C2. TASK DETAIL (Full Page)
**Layout: Single column (max-width 700px)**
- Title (Headline Large), status badge, category + priority + due date
- Description, subtasks checklist, resources, notes textarea
- "Mark Complete" primary, "Edit" secondary, "Delete" tertiary (red)

### C3. ROADMAP (4-Year Timeline)
**Layout: Horizontal timeline**
- Grade tabs (underline indicator): 9 Freshman | 10 Sophomore | 11 Junior | 12 Senior
- Horizontal scroll: Quarter columns (Q1-Q4), milestone cards stacked vertically per quarter
- Connector lines (horizontal between quarters, vertical within)
- Completed: Green check + strikethrough. Current quarter: Primary border.
- Right sidebar (collapsible): Progress summary per quarter + overall grade progress

### C4. ACTIVITY / EXTRACURRICULAR TRACKER
**Layout: Master-detail**
Left (40%): "My Activities" + count, "Add Activity", filter tabs, activity cards (name, category chip, role, hours, years, impact badge)
Right (60%): Detail — name, org, category, role, years, hours chart, description, skills tags, awards, "Edit"/"Delete". Empty: "Select an activity"

### C5. PRE-ADMISSION CHECKLIST
**Layout: Single column (max-width 700px)**
- College name banner, application type
- Categories: Application Materials, Financial, Preparation
- Items: Checkbox, title, desc, due date, status (Complete/Pending/Overdue)
- Top progress bar

### C6. POST-ADMISSION CHECKLIST
**Layout: Single column (max-width 700px)**
- College name, celebration header
- Categories: Decision, Housing, Registration, Financial, Preparation
- Items with checkboxes + due dates
- Timeline showing open/close windows per task

---

## SECTION D: COLLEGE INTELLIGENCE (14 screens)

### D1. COLLEGE DISCOVERY
**Layout: Full-width with filter bar + detail drawer**
Top: "Discover Colleges" + count, search bar (⌘K hint), filter button
Filter bar: Horizontal chips + sort dropdown + view toggle (Grid | List)
**Grid:** 4-column cards (hero image, heart, match % badge, name, location, 3 tags). Hover: lift + "View Profile" overlay.
**List:** Table — Name, Location, Match %, Acceptance Rate, Tuition, SAT Range, Type. Sortable.
Detail drawer (480px, right): College summary on card click. "Open Full Profile" link. Close X.

### D2. COLLEGE PROFILE
**Layout: Hero + two-column**
Hero (full width, 300px): Gradient overlay, image, match % badge, name, location, type tags. "Start Application" + "Add to List" + "Compare" buttons.
Left (65%): Section tabs (Overview | Deadlines | Personality | Actions). Overview: About + Known For tags. Deadlines: Table (type, date, days, status). Personality: AI card + radar chart + importance ratings. Actions: 2x3 grid.
Right (35%): Quick Facts card (acceptance, tuition, SAT, ACT, enrollment, graduation, student-faculty). Your Fit card (comparison bars + Reach/Match/Safety badge). Financial card. Similar Colleges (3-4 mini cards).

### D3. COLLEGE COMPARISON
**Layout: Multi-column table**
Top: 2-3 school selector slots with search. X to remove.
Table rows: Acceptance Rate, Tuition In/Out, SAT, ACT, Enrollment, Graduation Rate, Campus Size, Setting, Match %, Deadline, Fee. Green highlight on best values. Photo row top. AI recommendation card bottom.

### D4. MATCH SCORE DETAIL
**Layout: Two-column**
Left (55%): Overall match ring + factor breakdown (GPA, Test, Major, Location, Financial, Culture, Size — bars colored green/amber/red + expandable)
Right (45%): "How to Improve" AI card, comparison with similar colleges, "What-If Simulator" link

### D5. ADVANCED FILTERS
**Layout: Right drawer (480px)**
Categories: Location (state multi-select, region, distance slider), Academics (major dropdown, grad rate, student-faculty), Admissions (acceptance range, SAT range, ACT range, test policy), Cost (tuition range, aid range, net cost), Campus (size, setting, type), Culture (diversity, Greek, athletics, HBCU, Women's)
"Apply Filters" button (with count) + "Reset All"

### D6. CAMPUS PHOTO GALLERY
**Layout: Masonry grid + lightbox**
College name header. 3-column masonry. Category tabs. Click: Full-screen lightbox with swipe. Empty: "No photos available"

### D7. "BEST FOR YOUR MAJOR"
**Layout: Ranked list**
"Best Colleges for [Major]" + career badge. Ranked cards: Rank, name, match %, program details, "Why this school" explanation, strengths tags. Filterable.

### D8. AI-GENERATED COLLEGE PAGE
**Layout: Same as D2 but with AI banner**
"AI-Generated" banner (secondary BG, sparkles). Inaccuracy disclaimer. Sections with "unverified" badges. "Report Inaccuracy" + "Request Official Page"

### D9. WHAT-IF SIMULATOR
**Layout: Interactive split**
Left (45%): Sliders + number inputs (GPA, SAT, ACT, APs, Activities, Service Hours). Current vs adjustable. "Reset to Current" link.
Right (55%): Live-updating college cards (name, current match %, projected match % with delta arrows, badge changes). AI insight card.

### D10. MY CHANCES CALCULATOR
**Layout: Dashboard**
Top: Three rings (Reach, Match, Safety with counts + colors). Three columns below with college cards grouped by category (probability bars, key factors, expandable). AI summary. Methodology note.

### D11. WHY THIS SCHOOL ESSAY SEED
**Layout: Two-column**
Left (40%): College selector + AI connection cards (6 topics with "Use This" toggles) + "Generate More"
Right (60%): Essay outline workspace — sections (Hook, Why School, Why You, Conclusion) built from selections. "Copy" + "Open in Editor"

### D12. DEADLINE HEATMAP
**Layout: Calendar + sidebar**
Left (70%): Month grid — cell BG color intensity by deadline count. Dots for types. Selected: primary border.
Right (30%): Selected day deadlines + weekly urgency chart.

### D13. COLLEGE VISIT PLANNER
**Layout: Map + itinerary**
Left (55%): Embedded map, college pins (green=visited, blue=scheduled, gray=not), route line, drive times.
Right (45%): Ordered visit cards (drag to reorder): name, date picker, status, notes, "Schedule Tour" link. Trip summary. "Optimize Route" + "Export to Calendar"

### D14. MY COLLEGE LIST
**Layout: Two-column**
Left (65%): Sort bar + college cards (wider, with app status badge + deadline countdown + compare checkbox). "Compare Selected" button.
Right (35%): Summary card (total, distribution, earliest deadline, submitted count). "List Health" AI card.

---

## SECTION E: APPLICATIONS (8 screens)

### E1. APPLICATION TRACKER
**Layout: Master-detail**
Left (40%): Filter chips + application cards (name, type, status badge, deadline, progress bar)
Right (60%): Selected detail (= E2 content). Empty: "Select an application"

### E2. APPLICATION DETAIL
**Layout: Three-column**
Left (30%): Status card (name, location, match ring, type, status), key dates timeline, quick actions (Edit, Withdraw, Archive)
Center (45%): Progress bar + checklist sections (Personal Info, Essays, Recommendations, Test Scores, Financial) with checkboxes and priority dots. Hover: edit button appears.
Right (25%): Application timeline (vertical), documents list (status icons), notes textarea.

### E3. DEADLINES CALENDAR
**Layout: Calendar + sidebar**
Main (75%): Month grid, view toggles (Month | Week | List), deadline dot colors, selected highlight.
Sidebar (25%): Selected date deadlines (cards), upcoming week, overdue (red).

### E4. APPLICATION SEASON DASHBOARD
**Layout: Full Kanban**
Top: Countdown ring + stats + "Chat Advisor" button.
4 columns: Drafting | Ready | Submitted | Decision. Drag-and-drop cards (name, deadline, progress, status). Click card → detail drawer.
Bottom: Today's action items strip.

### E5. SUBMISSION TRACKER
**Layout: Single column (max-width 700px)**
College header. Horizontal stepper: Personal Info → Essays → Recommendations → Test Scores → Payment → Submit (✓/◎/○ per step). Current step details. Warnings. "Review & Submit" button. Post-submit confirmation.

### E6. DECISION PORTAL
**Layout: Two-column**
Left (55%): Decision cards per college: name, decision badge (Accepted green / Rejected red / Waitlisted amber / Deferred blue), date, aid summary, "Respond by" countdown, action buttons.
Right (45%): Summary (accepted/rejected/waitlisted/pending counts + donut chart). "Compare Accepted" button. "Need Help Deciding?" → Advisor.

### E7. WAITLIST TRACKER & LOCI
**Layout: Two-column**
Left (55%): Waitlisted schools (name, position, date, LOCI status, "Write LOCI" button, materials checklist).
Right (45%): "Waitlist Strategy" AI card + tips + LOCI preview.

### E8. SERVICE HOURS LOG
**Layout: Master-detail**
Left (40%): Total hours badge, "Log Hours" button, entries list (org, date, hours, category, verified badge).
Right (60%): Entry form/detail (org, date, hours, category, description, supervisor, "Save"). Hours chart (monthly bars) + category breakdown.

---

## SECTION F: AI ADVISOR (8 screens)

### F1. ADVISOR HUB
**Layout: 2x2 card grid (max-width 800px)**
"Your AI Advisor" header. Cards: Chat (sparkles), Essay Hub (pencil), Score Improvement (chart), Interview Prep (person). Each: icon, title, desc, button. Recent conversation preview below.

### F2. AI CHAT
**Layout: Sidebar + chat**
Left (240px): Conversation history list + "New Chat" + Quick Tool links (Essay, Score, Interview, Career).
Right: Empty → sparkles icon + greeting + 2x2 prompt cards. Messages → user (right, primary BG) / advisor (left, surface BG, "Advisor" label). Max-width 720px centered. Input bar: text field + attach (paperclip) + send (arrow). "Enter to send, Shift+Enter for newline" hint.

### F3. CHAT HISTORY
**Layout: Full list (max-width 700px)**
Search + conversation cards (title, date, preview, count). Hover: highlight + delete icon.

### F4. ESSAY HUB
**Layout: Three-column**
Left (240px): "Start New Essay" button + My Essays list (title, type badge, status chip, word count). Selected highlighted.
Center (remaining): Selected essay workspace — title (editable), prompt text (muted), large text editor + formatting toolbar. Or: Prompt selection grid (7 Common App cards).
Right (320px): AI Feedback panel — "Get Review" button, feedback cards (Strengths, Improve, Suggestions), score ring. Common App prompts (collapsible).

### F5. ESSAY EDITOR
**Layout: Full writing workspace**
Top toolbar: Back, title (editable), college+prompt ref (collapsible), word count, "Get AI Review" button, auto-save indicator.
Center (max-width 700px): Large text editor. Minimal formatting (Bold, Italic, paragraph).
Right margin (280px, collapsible): AI Suggestions, Outline (draggable), Version History.

### F6. ESSAY AI REVIEW
**Layout: Overlay on editor, two-column**
Left (55%): Essay text with inline highlights (green=strong, amber=improve, red=attention). Click highlight → shows feedback in right.
Right (45%): Score ring (0-100), Strengths, Areas to Improve, Structure Analysis, Tone Assessment, Action Items. "Apply Suggestions" + "Rewrite Section" buttons.

### F7. SCORE IMPROVEMENT
**Layout: Dashboard + sidebar**
Main (70%): SAT Journey card (current/target score circles + gap). Study plan: 4 horizontal phase cards (Weeks 1-2, 3-6, 7-8, Test Day) with tasks + hours. Expandable.
Sidebar (30%): Resources (Khan Academy, College Board, Fee Waiver), Practice Test Log (scores + trend chart + "Log Score"), Study Calendar (mini month with study days), Upcoming Test Dates.

### F8. INTERVIEW PREP / MOCK
**Prep landing:** Common question cards (10), difficulty badges, tips, "Practice" buttons. "Start Full Mock" accent button. Tips section.
**Mock mode:** Chat-like (AI question left, response area, timer, progress, Next/Skip). Results: Score ring, per-question feedback (Strong/Adequate/Needs Work + suggestions), "Retake" button.

---

## SECTION G: ACADEMIC PLANNING (8 screens)

### G1. GPA TRACKER
Left (55%): Trend chart (semesters x-axis, GPA y-axis, unweighted + weighted lines, tap points for tooltips). Semester pills. Current GPA display. Bright Futures card.
Right (45%): Semester detail: Course table (Name | Credits | Grade | Weight — editable). "Add Course." Live GPA calc. "Save."

### G2. TRANSCRIPT UPLOAD
Left (40%): Upload area (drag-and-drop + browse + camera). Processing spinner. Upload history.
Right (60%): Parsed results: Semester tabs, course table (Name | Grade | Credits | Weight | Status ✓/⚠/✗). GPA per semester + cumulative. "Confirm All" + "Import to GPA Tracker."

### G3. AP COURSE SUGGESTIONS
Left (55%): "Recommended APs" + sparkles. Cards: Course name, difficulty (1-5), AI explanation, prerequisites, school avg grade, Bright Futures badge, "Add to Schedule."
Right (45%): Current APs, AP Exam Scores, College Credit Map, Load Balance assessment.

### G4. DUAL ENROLLMENT GUIDE
Left (55%): Explainer card + available courses list (name, college, credits, cost, transferability, schedule). Filters.
Right (45%): Your DE courses + progress, credits tracker, cost savings calculator, transfer guide.

### G5. AI CLASS SCHEDULER
Main (70%): Weekly grid (Period 1-7 × Mon-Fri). Cells: course, teacher, room (color-coded by dept). AI-recommended: green dashed border. Empty: "+" button. Click → alternative options dropdown.
Sidebar (30%): AI summary (career alignment score, Bright Futures bar, credits, difficulty). Suggestions. "Submit to Counselor" button.

### G6. RESEARCH & INTERNSHIP TRACKER
Left (40%): "Research & Internships" + filter tabs + entry cards (title, org, type, dates, status, hours).
Right (60%): Detail: title, org, supervisor, description, skills tags, outcomes/publications, hours chart, documents. "Edit"/"Delete."

### G7. SUPPLEMENTAL ESSAY TRACKER
Left (30%): College list (name, X/Y complete, progress bar).
Right (70%): Selected college: Essay table (prompt, status, word count, progress, "Open Editor").

### G8. CAREER ACTIVITY SUGGESTIONS
Left (55%): "Suggested for [Career]" + sparkles. Cards grouped (High/Medium/Quick Win): name, category, "Why", commitment, impact, "Add." 
Right (45%): Current activities, coverage radar chart, "Gaps to Fill" card, typical admitted student comparison.

---

## SECTION H: CAREER (4 screens)

### H1. CAREER QUIZ
Centered (max-width 640px). Progress bar. Stage 1 (15 Qs): 2x2 option grid (hover: border). Stage 2 (10 Qs): Branching. Stage 3 (5 Qs): Open text. "Previous"/"Next" + "1-4 key select" hint.

### H2. CAREER QUIZ RESULTS
Centered (max-width 800px). Sparkles + archetype title (Display Small) + RIASEC code. Description. Three cards: Traits (chips), Paths (list), Classes (checklist). RIASEC hexagon chart. "Save to Profile" + "Retake" + "Explore Careers" link.

### H3. CAREER EXPLORER
Top: Career selector (horizontal cards with icons or dropdown). Left (50%): Career detail (title, desc, education timeline, salary bars). Right (50%): Related jobs grid (2-col, title, salary, growth, education, tags). Related majors. "Set as Career Path."

### H4. POST-GRADUATION MODE
Dashboard. Mode switcher: Pre/Post-Graduation. Checklists: Housing, Career, Financial, Life. Month-by-month timeline (May→Sept). Resources.

---

## SECTION I: FINANCIAL (6 screens)

### I1. SCHOLARSHIP SEARCH
**Layout: Table + detail drawer**
Top: Search + chips (All, Merit, Need, Local, STEM, Arts, First-Gen, Minority, Athletic) + sort.
Table: Name | Provider | Amount | Deadline | Match % | Status. Sortable, hover highlight, bookmark star. Click → detail drawer (480px right): Full info, eligibility (✓/⚠/✗ per criterion), "Apply Now" + "Save."

### I2. SCHOLARSHIP DETAIL (Full Page)
Single column (max-width 700px): Provider logo, name, amount (Display Small, lime), deadline countdown, about, eligibility list, application process, materials checklist, "Apply Now" + "Save" + "Share."

### I3. SCHOLARSHIP MATCH SCORE
Left (45%): Total potential aid card + ranked list (rank, name, amount, match % bar, deadline, status).
Right (55%): Detail: Match breakdown (✓/⚠/✗ per criterion), profile tags, AI improvement suggestions, "Apply."

### I4. SCHOLARSHIP ACTION PLAN
Timeline: AI-prioritized by ROI. Monthly plan: which to apply for when. Task cards per scholarship. Total potential earnings.

### I5. FINANCIAL AID COMPARISON
Side-by-side (2-3 schools): Tuition, R&B, Fees, Total COA, Grants, Federal Aid, Institutional, Loans, Work-Study, Net Cost, 4-Year Total. Green highlight on best. AI recommendation. "Export."

### I6. FAFSA READINESS / NET COST CALCULATOR
Left (55%): Readiness score ring + checklist (FSA ID, tax returns, W-2s, bank statements, CSS Profile, deadline).
Right (45%): Calculator: Family income slider, assets, family size, college dropdown → estimated net cost + aid breakdown. Disclaimer. "Compare Across Schools" link.

---

## SECTION J: TEST PREP (4 screens)

### J1. TEST PREP RESOURCES HUB
2-column card grid: Khan Academy SAT, College Board Practice, ACT Academy, Fee Waiver Info, Local Programs, Ladder Study Plan. Each: logo, title, desc, "Open" link, cost badge.

### J2. SAT/PSAT REGISTRATION REMINDERS
Timeline: Next 12 months test dates (SAT, PSAT, ACT) with registration deadlines. Cards: test, date, registration deadline countdown, "Register" link, fee info, "Set Reminder" toggle. Banner if registered.

### J3. PRACTICE TEST SCORE LOG
Left (55%): Trend chart (dates × scores, SAT + ACT lines, target dashed). Section mini charts.
Right (45%): Score entries (date, type, total, sections, source). "Log New Score" → form.

### J4. STUDY SCHEDULE PLANNER
Left (60%): Monthly calendar, study days highlighted lime, AI-generated study blocks. Click day → plan.
Right (40%): Selected day: Session cards (subject, focus area, duration, resource link, "Completed" checkbox). Weekly stats.

---

## SECTION K: HOUSING (5 screens)

### K1. HOUSING PREFERENCES QUIZ
Centered (max-width 600px). Category progress icons (Sleep, Clean, Noise, Social, Study, Temp). 2x2 emoji options (larger on desktop, hover highlight). Progress bar.

### K2. DORM COMPARISON
Side-by-side (2-3 slots): Cost, room type, distance, amenities icons, meal plan, move-in, rating stars. Photo row. "Select Preferred" + AI recommendation.

### K3. ROOMMATE COMPATIBILITY QUIZ
Same pattern as K1, more detailed questions.

### K4. ROOMMATE FINDER
Left (35%): Ranked matches (avatar, name, compatibility %, top traits). Sort by compatibility.
Right (65%): Profile: compatibility ring, radar chart, shared prefs (green), different (amber), "Send Introduction" + "Pass." Privacy note.

### K5. HOUSING DEADLINE TRACKER
College tabs. Per college: Timeline (app open, app deadline, roommate deadline, meal plan, move-in). Status + countdown per item. "Set Reminders" toggles.

---

## SECTION L: PROFILE & SETTINGS (8 screens)

### L1. PROFILE VIEW
Top: Avatar (96px) + name + career path + grade + school + archetype. Stats row: GPA, SAT, ACT, Colleges, Streak.
Two columns: Left (Academics: APs, Activities, Test History, GPA Tracker; College Planning: My List, Roadmap, Tracker, Career). Right (Tools: Advisor, Essay Hub, Scholarships, Housing; Account: Edit Profile, Notifications, Privacy, Help, Invite Code, Sign Out).

### L2. PROFILE SETTINGS
Centered form (max-width 680px): Avatar + "Change Photo." Personal: First+Last, School (autocomplete), Student ID, Grade, First-gen. Academic: GPA, Career Path, SAT, ACT. Contact: Email (read-only + change link), phone. "Save" + "Cancel."

### L3. NOTIFICATION SETTINGS
Two-column (max-width 680px). Left Reminders: Deadline, Task, Streak, Test Date toggles. Right Content: Daily Tip, Scholarships, App Updates, AI Tips. Web-specific: Email notifications, browser push toggles.

### L4. THEME SETTINGS
Centered (max-width 400px). Three cards: System, Light, Dark. Each: icon + label + preview thumbnail. Selected: primary border. Live preview on selection.

### L5. PRIVACY SETTINGS
Centered (max-width 600px). Toggles: Anonymous usage data, Peer comparison, Visible to counselor, Visible to parent. Links: Download Data, Delete Account (red), Privacy Policy, FERPA Rights.

### L6. LANGUAGE PREFERENCES
Centered (max-width 400px). Radio list: English ✓, Español, Kreyòl Ayisyen. "More coming" note. "Save."

### L7. HELP & SUPPORT
Centered (max-width 600px). FAQ accordion. Contact: Email Support, Report Bug, Feature Request buttons. Resources: User Guide, Video Tutorials. Version.

### L8. LEGAL / ABOUT
Centered (max-width 600px). App icon + version. Links: Terms, Privacy, FERPA, COPPA, Accessibility, Licenses.

---

## SECTION M: REPORTS & EXPORT (6 screens)

### M1. PDF PORTFOLIO
Left (60%): PDF preview mockup (scrollable). Right (40%): Section toggles (Academic, Activities, Applications, Tests, Service, Essays, Awards ON/OFF), accent color picker, "Export PDF" + "Share with Counselor" + "Print."

### M2. RESUME BUILDER
Left (50%): Collapsible form sections (Contact, Education, Experience, Skills, Activities, Awards). Drag to reorder. "Add Section."
Right (50%): Live preview (professional template). Template selector (Classic | Modern | Academic). "Download PDF" + "Print."

### M3. ALTERNATIVE PATHS GUIDE
2x2 cards: Community College, Trade School, Military, Gap Year. Each: icon, title, tagline, "Explore →". Click: Full detail (desc, pros/cons, timeline, financial comparison, process, stories, resources). "Save to Profile."

### M4. INTERNSHIP GUIDE
Left (55%): Guide sections (accordion): When to Look, Where to Find, How to Apply, Interview Tips, Making the Most.
Right (45%): Your Internship Tracker + stats + deadlines + "Add Internship."

### M5. IMPACT REPORT (Student)
Dashboard: Stats row (Days, Tasks, Colleges, Essays, Hours). Journey timeline (milestones). Growth charts (GPA, SAT, activities over time). "Share" + "Download."

### M6. SOCIAL SHARE TEMPLATES
Template carousel: "Accepted!", "My Journey", "Decision Day!", "Committed!" Each: Ladder-branded card with student data. Live preview. Editable caption. "Download Image" + system share.

---

## SECTION N: PARENT SCREENS (6 screens)

### N1. PARENT DASHBOARD
Top: Child switcher tabs. Stats (4 cards): Schools, Acceptances, Aid, Deadlines.
Left (55%): College status table (name, status badge, deadline, updated).
Right (45%): Financial summary + upcoming deadlines timeline + checklist progress ring.
Bottom: "Message Student" + "Message Counselor."

### N2. PARENT INVITE CODE ACCEPTANCE
(= A11)

### N3. MULTI-CHILD SWITCHER
Centered (max-width 500px): Child cards (avatar, name, grade, school, activity preview, "View Dashboard"). "Add Another Child" button.

### N4. PARENT MESSAGING
Chat layout (= F2 pattern). Left: Contact list (student(s) + counselor + unread badges). Right: Chat + input. "Visible to [recipient]" notice.

### N5. PEER COMPARISON
School selector. Three panels: GPA bell curve, SAT bell curve, Activities bar chart — student's dot highlighted. Aggregate stats table. Strengths/weaknesses. Privacy note.

### N6. PARENT FINANCIAL OVERVIEW
Single column (max-width 700px): App costs card, per-school aid breakdown, total comparison mini-table, FAFSA status badge, scholarship status.

---

## SECTION O: COUNSELOR SCREENS (13 screens)

### O1. CASELOAD MANAGER
**Layout: Full data dashboard**
Top: "My Caseload" + count + search + filter + view toggle (Table | Cards) + "Export CSV" + "Bulk Actions"
Summary cards: At-Risk (red), Needs Attention (amber), On Track (green), Apps Submitted.
**Table:** | ☐ | Student+Avatar | Grade | GPA | SAT | Apps X/Y | Next Deadline | Days Left | Status | Actions |. Sortable, filterable, selectable, hover row highlight. Actions: View/Message/Flag icons. Pagination (25/50/100).
**Card Grid:** 4-column student cards with quick actions.

### O2. STUDENT DETAIL
Top: Student header (avatar, name, grade, GPA, SAT, status). Buttons: Message, Flag, Schedule Meeting.
Left (60%): College list table, GPA trend chart, activities summary, essay status.
Right (40%): Quick stats card, alert banner (conditional), upcoming deadlines, counselor notes + "Add Note", schedule approvals.

### O3. CLASS APPROVAL
Left (50%): Student name + schedule table (Period | Course | Teacher | Room | AI Status ✓/⚠/ℹ/✗). Tap icon → explanation tooltip.
Right (50%): AI Analysis (rigor 1-5, Bright Futures, career alignment, prereqs, workload). Conflicts + resolutions. Approve (green) / Request Changes (amber) / Schedule Meeting.

### O4. GENERIC DEADLINE CALENDAR
Full month grid, college deadlines (not student-specific). Color by type (ED=purple, EA=blue, RD=green, Rolling=amber). Tap date → college list. "Reference only" note. Export.

### O5. COUNSELOR IMPACT REPORT
Executive summary card. Workload metrics. Outcome charts (year-over-year bars). Equity outcomes. Bright Futures projection. Testimonials. "Export PDF" + "Share with Admin."

### O6. VERIFICATION FLOW (= A16)

### O7. BULK STUDENT IMPORT
4-step wizard: Upload (drag-and-drop zone + template download) → Preview (data table with auto-generated IDs, ✓/✗ status) → Confirm (summary + sample cards) → Credentials (printable 3x2 cards with QR code, "Print" + "Download PDF" + "Email").

### O8. AUTO-ID GENERATOR (Single)
Centered form (max-width 500px): First Name, Last Name, DOB, Grade, Email (opt). Live credential preview (Login ID: firstname.lastname.MMDD, Password: Firstname.YY!). "Create" + "Print Card."

### O9. MESSAGING CENTER
Master-detail chat. Left (280px): Filter (All/Students/Parents/Staff), contacts with previews + unread badges. Right: Conversation + input + "Logged per school policy" notice + attachment button.

### O10. SCHOOL YEAR ROLLOVER
Step wizard: Preview table (Current Grade → New Grade, count, action). What's reset vs preserved. "Execute Rollover" (with confirmation modal) or "Schedule for August 1."

### O11. ANNOUNCEMENT COMPOSER
Audience selector + title + rich text body + attachment + priority (Normal/Important/Urgent) + schedule (now / later). Preview card. "Send."

### O12. AT-RISK ALERTS
Left (45%): Alert cards (student, risk level, reason, days inactive, "Dismiss" swipe).
Right (55%): Detail: Risk assessment, activity timeline (gap visualization), missed deadlines, AI intervention suggestions, "Send Check-In" + "Flag for Meeting" + "Dismiss."

### O13. COUNSELOR MARKETPLACE
**Browse:** Search + filters + counselor cards (photo, name, credentials, specialty tags, rating, price, "View" + "Book").
**Profile:** Photo, bio, specialties, experience, reviews, availability calendar, pricing, "Book Session" + "Send Message" + "Become Ambassador."

---

## SECTION P: SCHOOL ADMIN (7 screens)

### P1. ADMIN DASHBOARD
Row 1: 4 metric cards (Students, College-Bound %, Apps, Aid).
Row 2: Acceptance chart (bar, 60%) + grade donut (40%).
Row 3: At-risk alerts (50%) + top destinations (50%).
Bottom: "View Students" + "View Counselors" + "Download Report."

### P2. CLASS CATALOG
Left (55%): "Upload CSV" + template + course table (Name | Dept | Level | Credits | Teacher | Periods | Capacity — editable, sortable).
Right (45%): Selected course form + "Publish Catalog."

### P3. SCHOOL PROFILE
Form (max-width 700px): Logo upload, name, address, district, principal, type, enrollment, ratios, rates, programs (tag chips), clubs (list), key dates. "Save" + "View Public."

### P4. AMBASSADOR SIGNUP
Marketing page: Benefits, requirements, form (name, school, role, email, motivation). "Apply."

### P5. DATA EXPORT
Centered (max-width 600px): Export type radios (roster CSV, apps CSV, academic CSV, full PDF, FERPA ZIP). Date range. Grade filter. "Generate." Processing + download history.

### P6. DPA MANAGEMENT
Left (55%): DPA list (name, status, signed date, expiry, signatory).
Right (45%): Detail: Document viewer, status, terms, signatures, "Renew" + "Download."

### P7. ANNOUNCEMENT MANAGER
= O11 with admin scope + analytics (sent, read, click rate per announcement). Past announcements with metrics.

---

## SECTION Q: DISTRICT ADMIN (4 screens)

### Q1. DISTRICT DASHBOARD
Top: Name + metrics row. School comparison table (sortable, filterable, click to drill). Equity metrics cards + Bright Futures projection chart. "Export" + "Schedule Report."

### Q2. SCHOOL COMPARISON
2-3 school selector + comparison table (Enrollment, GPA, SAT, College-Bound, Acceptance, Aid, At-Risk, Counselor Ratio). Bar comparisons. Green=best, red=concern. "Export."

### Q3. EQUITY METRICS
"Equity & Access" header. Metric cards. Demographic breakdown charts. Year-over-year trends. AI action plan suggestions. "Export."

### Q4. REPORT GENERATOR
Wizard: Type (Monthly/Quarterly/Annual/Custom), sections (checkboxes), date range, schools (multi-select), format (PDF/PPTX/CSV). "Generate." Processing + download.

---

## SECTION R: SPECIAL / UTILITY (5 screens)

### R1. FIRST 100 DAYS TRACKER
Left (55%): Vertical timeline (May→Aug) with milestone nodes (✓/◎/○). School-specific tips inline.
Right (45%): Countdown ring (days to move-in). This week's tasks. Packing checklist (collapsible categories). "Share with Parent."

### R2. GLOBAL SEARCH / COMMAND PALETTE
Overlay modal (max-width 600px): Large search input. Results grouped (Colleges, Tasks, Essays, Scholarships, Settings). Recent searches. Keyboard shortcut hints. Triggered by ⌘K.

### R3. OFFLINE MODE / SYNC STATUS
Banner: "You're offline" (amber). Detail: Last synced, pending changes count + list (queued/syncing/failed), "Sync Now," conflict resolution.

### R4. CONTENT MODERATION (Admin/Counselor)
Report queue: Cards (reporter, date, type, preview, severity, status). Detail: Full content, reporter info, AI assessment, actions (Approve/Remove/Warn/Suspend). Audit trail.

### R5. DATA DELETION REQUEST
Centered (max-width 500px): Warning icon, "Permanent" message. What's deleted vs not. Type "DELETE" to confirm. "Delete Everything" (red). "Cancel." "Download Data First" link.

---

## DESKTOP-SPECIFIC DESIGN NOTES

1. **Min window:** 1024×768. Below: simplified single-column or resize prompt.
2. **Breakpoints:** 1024-1279 (sidebar collapsed), 1280-1439 (standard), 1440+ (full), 1920+ (max 1200px centered).
3. **Hover states on everything:** Cards lift, buttons glow, links underline, rows highlight, icons color.
4. **Keyboard:** ⌘K search, ⌘N new, ⌘/ sidebar, Esc close, 1-5 nav sections.
5. **Right-click:** Context menus on cards, items, rows.
6. **Tooltips:** All icon buttons + truncated text.
7. **Loading:** Skeleton screens matching layout.
8. **Empty states:** Icon + message + CTA on every list/table.
9. **Toasts:** Top-right slide-in (green success, red error, primary info).
10. **Modals:** Centered overlay + backdrop blur + max-width 600px + focus trap.
11. **Data tables (B2B):** Column resize, reorder, selection, bulk toolbar, CSV export, pagination, visibility toggles.
12. **Dark mode:** Full support using dark tokens. Toggle in top nav.
13. **Browser tab:** Graduation cap favicon + dynamic title ("Ladder — Dashboard").
14. **Print:** Clean print styles for reports, credentials, portfolios.
15. **Scroll:** Smooth, sticky table headers, back-to-top on long pages.

## WEB-SPECIFIC NOTES
1. **SEO:** College profiles server-rendered. URL: `/colleges/harvard-university`
2. **URL routing:** Unique URL per screen (`/dashboard`, `/tasks`, `/colleges`, `/advisor/chat/[id]`, `/applications/[id]`)
3. **Open Graph:** College pages with OG image/title/desc for social sharing
4. **Cookie consent:** GDPR/CCPA banner
5. **PWA:** Add-to-homescreen, offline cache
6. **Browser push:** Optional notification permission

---

## DESIGN DELIVERABLES

Design all **132 screens** as high-fidelity desktop mockups at **1440px width**. Use the exact Evergreen Ascent tokens, Noto Serif + Manrope, spacing system. Every screen should feel like a polished professional SaaS product. B2B screens should feel especially powerful and data-rich.

Sections A through R. Maintain this organization.
