# Stitch Prompt — Ladder iPad App (Complete — 132 Screens)

You are designing the **complete iPad version** of Ladder, a college preparation app for high school students, parents, counselors, and school administrators. This is a **touch-optimized widescreen** redesign of every single screen in the application. Every screen below must be designed for iPad landscape and portrait orientations.

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
- **Letter Spacing:** Headlines use editorial tracking (-0.5 / -2%), Labels use wide tracking (+2.0)

### Spacing (8pt base grid)
- xxs: 2, xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48, xxxl: 64, xxxxl: 80

### Corner Radius
- sm: 8, md: 12, lg: 16, xl: 24, xxl: 32, xxxl: 40, pill: 9999

### Shadows
- **Ambient (cards):** rgba(31,28,20, 0.06), blur 20, y-offset 4
- **Floating (modals/sheets):** rgba(31,28,20, 0.06), blur 30, y-offset 10
- **Glow (CTAs, progress rings):** rgba(201,242,77, 0.30), blur 15, no offset
- **Primary Glow (button press):** rgba(66,96,63, 0.15), blur 20, y-offset 4

### Component Styles
- **Primary Button:** Gradient primary→primaryContainer, pill shape, white text, scale 0.95 on press
- **Accent Button:** Accent Lime (#A1C621) background, dark text (#1f1b15), glow shadow
- **Secondary Button:** Surface Container High background, on-surface text
- **Tertiary Button:** Text-only with underline
- **Cards:** Surface Container Low background, XL corner radius, ambient shadow
- **Chips/Tags:** Surface Container High background, pill shape, Label Small text
- **Text Fields:** Surface Container Lowest background, outline border, LG corner radius, primary border on focus
- **Toggle Switches:** Primary color when on, outline when off
- **Progress Circular:** Stroke width 8, primary track, outline variant background track, glow shadow on active
- **Progress Linear:** 4pt height, primary fill, outline variant background, LG corner radius
- No divider lines anywhere — use spacing and elevation to separate content
- All interactive elements: minimum 44pt touch target (Apple HIG)

---

## iPad NAVIGATION PATTERN

**Replace the iPhone bottom tab bar with a collapsible sidebar + detail layout.**

### Sidebar (Left Panel — 280pt width, collapsible)
- App logo "Ladder" at top with graduation cap icon
- Navigation sections with expandable sub-items:
  1. **Home** (house icon) → Dashboard
  2. **Tasks** (checkmark.circle icon) → Checklist, Roadmap, Activities
  3. **Colleges** (graduationcap icon) → Discovery, My List, Compare, Visit Planner
  4. **Applications** (doc.text icon) → Tracker, Deadlines, Season Dashboard
  5. **Advisor** (sparkles icon) → Chat, Essay Hub, Score Improvement, Interview Prep
  6. **Financial** (dollarsign.circle icon) → Scholarships, Aid Comparison, FAFSA
  7. **Career** (briefcase icon) → Quiz, Explorer
  8. **Housing** (building.2 icon) → Preferences, Dorms, Roommates
  9. **Reports** (chart.bar icon) → Portfolio, Resume, Paths
- Sidebar background: Surface Container Low
- Selected item: Primary background pill with On Primary text
- Unselected: On Surface Variant text
- Bottom: Student avatar, name, grade, streak badge, settings gear icon
- Portrait mode: Sidebar collapses to overlay, swipe from left edge to reveal

### Detail Area (remaining width)
- Max content width: 800pt centered (for single-column views)
- Multi-column views use full width
- Contained card-style headers (no full-bleed gradients)

### Split View / Multitasking
- Landscape: Sidebar always visible + detail panel
- Portrait: Sidebar hidden, hamburger menu button
- iPadOS Split View: At 1/3 width → collapse to iPhone-like single column
- Stage Manager: Fluid resizing, adapts layout at breakpoints

---

## ALL 132 SCREENS

---

## SECTION A: AUTH & ONBOARDING (16 screens)

### A1. SPLASH SCREEN
- Full-screen gradient (primary → surface)
- Centered Ladder logo: Graduation cap icon inside rotated square
- "Ladder" wordmark below in Noto Serif Headline Large
- Subtle lime glow animation around logo
- Loading indicator (thin progress bar at bottom, or pulsing glow)

### A2. LOGIN
**Layout: Centered card on blurred background**
- Full-screen gradient background (primary → surface) with two decorative blurred circles (secondary & lime)
- Center card (max-width 480pt):
  - Logo badge (rotated square + graduation cap)
  - "Welcome Back" (Headline Large, Noto Serif)
  - Email text field (envelope icon)
  - Password text field (lock icon, show/hide toggle)
  - "Forgot Password?" link (right-aligned, primary color)
  - Error message area (error color text)
  - "Log In" accent button (full width, lime, glow shadow)
  - Divider line with "Or continue with" centered text
  - Google button + Apple Sign In button (side by side)
  - "Don't have an account? Create Account" link at bottom

### A3. SIGN UP
**Layout: Same centered card as Login**
- Logo badge
- "Create Account" headline
- Email text field
- Password text field (with strength indicator bar below: red→amber→green)
- Confirm Password text field
- "I agree to the Terms of Service and Privacy Policy" checkbox with links
- "Create Account" accent button
- "Already have an account? Log In" link

### A4. FORGOT PASSWORD
**Layout: Centered card**
- Logo badge
- "Reset Password" headline
- "Enter your email and we'll send you a reset link" body text
- Email text field
- "Send Reset Link" primary button
- "Back to Login" link
- **Success state:** Checkmark icon, "Check your email" message, "Open Mail App" button

### A5. ROLE SELECTION
**Layout: Centered card with 4 large role tiles**
- "How will you use Ladder?" headline
- 2x2 grid of role cards (touch-friendly, 160pt each):
  - **Student** — Graduation cap icon, "I'm a Student", "Track your college journey"
  - **Parent** — Heart icon, "I'm a Parent", "Follow your child's progress"
  - **Counselor** — Person.badge.plus icon, "I'm a Counselor", "Manage your students"
  - **School Admin** — Building icon, "I'm an Administrator", "Manage your school"
- Selected card: Primary border + checkmark overlay
- "Continue" button below

### A6. ONBOARDING — STEP 1: WELCOME
**Layout: Two-panel, centered**
- Progress bar top (5 steps, step 1 active)
- Left (50%): Large gradient green hero rectangle with sparkles icon
- Right (50%): "Your Future, Designed by You" (Display Small), subtitle "Ladder guides you through every step of the college journey", "Let's Get Started" accent button

### A7. ONBOARDING — STEP 2: BASIC INFO
**Layout: Centered form (max-width 600pt)**
- Progress bar (step 2 active)
- "Tell Us About You" headline
- Two-column: First Name + Last Name
- Full width: School name (with autocomplete dropdown)
- Full width: Student ID (optional)
- Grade selector: 4 large touch-friendly buttons (9th, 10th, 11th, 12th)
- First-generation college student toggle switch
- "Continue" + "Back" buttons

### A8. ONBOARDING — STEP 3: ACADEMIC PROFILE
**Layout: Centered form (max-width 600pt)**
- Progress bar (step 3 active)
- "Your Academics" headline
- GPA slider: Large touch target, range 0.0-5.0, current value displayed large
- SAT Score + ACT Score fields side by side
- AP/Honors Courses: Flow layout of chips with X to remove. "Add Course" button opens autocomplete picker. On iPad chips wrap into 3-4 columns.
- "Continue" + "Back" buttons

### A9. ONBOARDING — STEP 4: DREAM SCHOOLS
**Layout: Centered (max-width 700pt)**
- Progress bar (step 4 active)
- "Pick Your Dream Schools" headline
- Search bar at top with autocomplete
- Selected colleges shown as removable chips above grid
- College grid: **3 columns** on iPad. Cards: Building icon placeholder, college name, location, checkmark overlay if selected, lime border if selected.
- "Continue" + "Back" buttons

### A10. ONBOARDING — STEP 5: READY TO LEAD
**Layout: Centered (max-width 600pt)**
- Progress bar (step 5 complete)
- Trophy icon in gradient circle
- "Ready to Lead?" (Headline Large)
- Profile summary card (horizontal layout):
  - Left: Student initials avatar + name + grade
  - Center: GPA, SAT/ACT, career path
  - Right: Milestones count, top targets count
- "Enter Dashboard" accent button (full width)
- "Review Full Profile" secondary button

### A11. PARENT ONBOARDING / INVITE CODE ENTRY
**Layout: Centered card**
- "Join Your Child on Ladder" headline
- Illustration: Parent and student icons connected
- "Enter Invite Code" — 6-digit code input (6 separate boxes, large touch targets)
- "Your child shared this code from their profile" helper text
- "Connect" primary button
- **Success state:** Animated checkmark, "Connected to [Student Name]!", "Go to Dashboard" button
- **Error state:** "Invalid code" with shake animation

### A12. COUNSELOR ONBOARDING / SCHOOL CODE ENTRY
**Layout: Centered card**
- "Welcome, Counselor" headline
- "Enter your school's code to get started" subtitle
- School code text field (alphanumeric)
- "Join School" primary button
- "I'm a freelance counselor (no school code)" link → goes to verification flow
- **Success state:** School name + logo displayed, student count, "Enter Dashboard" button

### A13. COPPA AGE GATE
**Layout: Centered card**
- "Before We Begin" headline
- "What is your date of birth?" — Date picker (month/day/year wheels)
- "Continue" button
- **If under 13:** "Parental Consent Required" screen:
  - "We need your parent or guardian's email to continue"
  - Parent email text field
  - "Send Consent Request" button
  - "A verification email will be sent to your parent"

### A14. FERPA / PARENTAL CONSENT FLOW
**Layout: Centered card with legal text**
- "Data Sharing Consent" headline
- Scrollable legal text area (FERPA explanation in plain language)
- Bullet points: What data is shared, who can see it, how to revoke
- "I consent to data sharing as described above" checkbox
- "I agree" primary button + "Decline" secondary button
- Digital signature field (name typed)

### A15. FORCE PASSWORD CHANGE (First Login)
**Layout: Centered card**
- Lock icon
- "Set Your New Password" headline
- "Your counselor created your account. Please set a personal password."
- Current/Temporary password field (pre-filled, read-only)
- New password field (with strength indicator)
- Confirm new password field
- "Update Password" primary button

### A16. COUNSELOR VERIFICATION FLOW
**Layout: Multi-step centered card**
- Step 1: "Verify Your Identity"
  - Full name, email, phone
  - School/organization name
  - Role (School Counselor, Independent Counselor, College Advisor)
- Step 2: "Upload Credentials"
  - Drag-and-drop area for certification documents
  - Accepted formats: PDF, JPG, PNG
  - List of uploaded files with status
- Step 3: "Verification Pending"
  - Hourglass icon
  - "We're reviewing your credentials (typically 1-2 business days)"
  - "You'll receive an email when approved"
  - "Contact Support" link

---

## SECTION B: STUDENT DASHBOARD & HOME (4 screens)

### B1. STUDENT DASHBOARD
**Layout: Two-column grid in detail area**

Left column (60%):
- **Welcome Header Card** — Contained card with gradient green background. "Good morning, [Name]" (Headline Medium), career path badge ("Pre-Med"), grade badge ("11th Grade"). Profile avatar (48pt) with streak fire badge on right side of card. Quick action row: "Continue Task", "View Deadlines", "Chat Advisor" — three small accent buttons.
- **Next Up Card** — "NEXT UP" label chip with arrow. Current task title (Title Large), category chip, linear progress bar, completion %, "Continue" button.
- **Daily Tip Card** — Gradient lime→primary card. Lightbulb icon. Tip text (Body Large). "See More Tips" link.

Right column (40%):
- **Checklist Progress Card** — Circular progress indicator (100px, glow shadow), "Your Checklist" (Title Medium), "X of Y completed", "View All Tasks" accent button.
- **Urgent Deadline Card** — Dark card (inverse surface background) with 4px red left border accent. "URGENT" label (error color). Deadline title, college name, date, days remaining in large type (Display Small). "View Application" link.
- **Quick Stats Grid** — 2x2 grid of mini cards: GPA (book icon), SAT (pencil icon), Colleges Saved (heart icon), Streak Days (fire icon). Each: large number + label + subtle trend arrow.

### B2. WEEKLY "3 THINGS TO DO" WIDGET
**Layout: Card component (can be embedded in Dashboard or standalone)**
- "This Week's Priorities" (Title Large)
- 3 prioritized task cards stacked:
  - Priority number badge (1, 2, 3 in circles)
  - Task title
  - Category chip + due date
  - "Do It" accent button on each
- "See All Tasks" link at bottom
- AI-generated based on deadlines, grade, and career path

### B3. NOTIFICATIONS CENTER / INBOX
**Layout: Master-detail split**
Left (40%):
- "Notifications" header with badge count
- Filter tabs: All | Deadlines | Tasks | Scholarships | Messages
- Notification list:
  - Unread: Bold title, surface container background
  - Read: Regular weight, surface background
  - Each item: Icon (type-specific), title, preview text, time ago
  - Swipe to dismiss / mark read

Right (60%):
- Expanded notification detail
- Action buttons depending on type:
  - Deadline: "View Application" button
  - Task: "Complete Task" button
  - Scholarship: "View Scholarship" button
  - Message: Reply text field

### B4. STREAK & ACHIEVEMENTS VIEW
**Layout: Two-column**
Left (55%):
- Current streak: Large fire icon + day count (Display Medium)
- Streak calendar: Month grid with highlighted consecutive days (lime)
- Longest streak stat
- "Keep it going! Complete a task today to continue your streak" motivational text

Right (45%):
- Achievements / Badges grid (3 columns):
  - "First Login" badge
  - "5 Colleges Saved" badge
  - "Essay Started" badge
  - "SAT Prep Master" badge
  - "10-Day Streak" badge
  - etc. Locked badges shown as grayed silhouettes

---

## SECTION C: TASKS & CHECKLISTS (6 screens)

### C1. TASKS VIEW (Main List)
**Layout: Two-panel split**

Left panel (40%):
- "TASKS & CHECKLIST" contained header card (gradient green, not full-bleed)
- Circular progress (56pt) + "X of Y completed"
- Search bar with magnifying glass icon
- Filter chips (horizontal scroll): All, Academic, Extracurricular, Application, Financial, Housing, Test Prep
- **TO DO section:**
  - Task rows: Checkbox circle, category icon in colored background, task title, description (1 line truncated), category chip, due date, priority dot (red=high, amber=medium, none=low)
  - Tap row → shows detail in right panel
- **COMPLETED section:**
  - Collapsible (chevron toggle), count shown
  - Completed tasks: Green checkmark, strikethrough title, muted colors

Right panel (60%):
- **Selected task detail:**
  - Task title (Headline Medium)
  - Category chip + priority badge + due date
  - Full description (Body Large)
  - Subtasks checklist (if any): Indented checkboxes
  - Related resources / links
  - Notes text area
  - "Mark Complete" accent button
- Empty state: Checkmark icon, "Select a task to view details"

### C2. TASK DETAIL VIEW (Full screen, navigated from deep links)
**Layout: Wide single column (max-width 700pt)**
- Back button in toolbar
- Task title (Headline Large)
- Status badge (To Do / In Progress / Complete)
- Category + priority + due date row
- Full description
- Subtasks section: Indented checklist with add subtask button
- Related resources: Link cards
- Notes: Multi-line text area
- Action buttons: "Mark Complete" primary, "Edit" secondary, "Delete" tertiary (red)

### C3. ROADMAP VIEW (4-Year Timeline)
**Layout: Full-width horizontal timeline**
- Grade picker: 4 large tab buttons (Grade 9 Freshman | Grade 10 Sophomore | Grade 11 Junior | Grade 12 Senior)
- Horizontal scrolling timeline:
  - X-axis: Quarters (Q1 Fall, Q2 Winter, Q3 Spring, Q4 Summer)
  - Each quarter = column (min 240pt width)
  - Milestone cards stack vertically within each quarter:
    - Category chip (Academic, Social, Financial, Application)
    - Milestone title
    - Description (2 lines)
    - Completion checkbox + strikethrough if done
  - Vertical connecting line within column, horizontal connector between columns
  - Current quarter highlighted with primary border
  - Completed milestones: Green fill + checkmark

### C4. ACTIVITY / EXTRACURRICULAR TRACKER
**Layout: Two-panel**
Left (45%):
- "My Activities" header + count
- "Add Activity" button
- Activity cards list:
  - Activity name (Title Medium)
  - Category chip (Sports, Arts, Academic, Service, Leadership, Work)
  - Role/position
  - Hours logged
  - Years active (grade range)
  - Impact level badge (low/medium/high)

Right (55%):
- Selected activity detail:
  - Activity name (Headline Small)
  - Organization/team name
  - Category + role + years
  - Hours logged with history chart (mini bar chart by semester)
  - Description text area
  - Awards/achievements within this activity
  - "Edit" + "Delete" buttons
- Empty state: "Select an activity to view details"

### C5. PRE-ADMISSION CHECKLIST
**Layout: Single column (max-width 700pt)**
- "Before You're Accepted" header with school-specific icon
- College name + application type banner at top
- Checklist organized by category sections:
  - **Application Materials:** Common App, essays, recommendations, transcripts, test scores
  - **Financial:** FAFSA submitted, CSS Profile, scholarship apps
  - **Preparation:** Campus visit, interview, demonstrated interest
- Each item: Checkbox, title, description, due date, status (Complete/Pending/Overdue)
- Progress bar at top showing overall completion

### C6. POST-ADMISSION CHECKLIST
**Layout: Single column (max-width 700pt)**
- "After You're Accepted" header with celebration icon
- College name banner
- Checklist sections:
  - **Decision:** Accept/decline by date, deposit payment
  - **Housing:** Housing application, roommate selection, meal plan
  - **Registration:** Orientation signup, placement tests, course registration
  - **Financial:** Accept aid package, loan paperwork, scholarship acceptance
  - **Preparation:** Health forms, immunization records, laptop purchase
- Each item: Checkbox, title, due date, notes
- Timeline view showing when each task opens and closes

---

## SECTION D: COLLEGE INTELLIGENCE (14 screens)

### D1. COLLEGE DISCOVERY
**Layout: Three-column master-detail**

Left panel (280pt):
- "COLLEGE INTELLIGENCE" contained header card
- Search bar + filter button
- Filter chips (vertical stack): All, Ivy League, State Schools, HBCUs, Liberal Arts, Community Colleges, Technical, Religious, Military
- Sort by: Match %, Name, Acceptance Rate, Tuition
- College count: "6,322 colleges"

Center panel (remaining):
- College grid: **3-column LazyVGrid**
- CollegeCard: Image hero (140pt), favorite heart button (top-right), match % badge (bottom-right, lime background), college name (Title Medium), location (Body Small), 3 tag chips
- When a college is tapped → center narrows, right panel slides in

Right panel (400pt, conditional):
- Inline college profile summary:
  - Hero with match %, name, location
  - Quick stats row (acceptance, tuition, SAT, enrollment)
  - Section tabs (Overview, Deadlines, Personality, Actions)
  - Action buttons
  - "Open Full Profile" link
- Empty state: "Select a college to view details"

### D2. COLLEGE PROFILE (Full Detail)
**Layout: Wide two-column**

Left (65%):
- Hero section: Gradient overlay on image, match % badge (large), college name (Headline Large), location with pin icon, type tags
- Section picker: Horizontal tabs (Overview | Deadlines | Personality | Actions)
- **Overview tab:**
  - About card (Body Large text)
  - "Known For" tag chips (wrap into multiple columns)
  - Campus highlights / key stats paragraphs
- **Deadlines tab:**
  - Deadline cards: Type (Early Action, Regular, Rolling), date, days remaining, platform (Common App / Coalition / Direct)
  - Testing policy card (Test Optional / Required / Blind)
  - App fee card
- **Personality tab:**
  - AI-generated personality summary card
  - Culture radar chart (Academic Rigor, Social Life, Greek Life, Athletics, Diversity, Campus Beauty)
  - "What students say" quotes
  - Applicant importance ratings (GPA weight, Test weight, Essay weight, Activities weight)
- **Actions tab:**
  - 2x3 grid of action buttons:
    1. Start Application → Application Detail
    2. Mock Interview → Interview Prep
    3. Write LOCI → Essay Editor
    4. Compare Colleges → Comparison
    5. Match Score Detail → Match Score
    6. Why This School Essay → Essay Seed

Right sidebar (35%):
- Quick stats card stack:
  - Acceptance Rate (circular mini chart)
  - Tuition: In-State / Out-of-State
  - SAT Range (horizontal bar)
  - ACT Range
  - Enrollment
  - Graduation Rate
  - Student-Faculty Ratio
- "Your Fit" card: GPA comparison bar, SAT comparison bar, Reach/Match/Safety badge
- "Start Application" primary button
- "Add to My List" secondary button

### D3. COLLEGE COMPARISON (Side-by-Side)
**Layout: Multi-column comparison table**
- Top: 2-3 college selector slots. Tap to search and add. X to remove.
- Comparison table (scrollable):
  - Row categories: Acceptance Rate, Tuition (In/Out State), SAT Range, ACT Range, Enrollment, Graduation Rate, Student-Faculty Ratio, Campus Size, Setting (Urban/Rural/Suburban), Match %, Application Deadline, App Fee
  - Highlighted cells where one college is notably better (green tint)
  - Photo row at top for each college
- "Add Another College" button if fewer than 3
- "Which is right for me?" AI summary card at bottom with personalized recommendation

### D4. COLLEGE MATCH SCORE DETAIL
**Layout: Two-column**
Left (55%):
- College name + overall match % (large circular ring with glow)
- "How We Calculate Your Match" headline
- Factor breakdown list:
  - GPA Match: Your GPA vs admitted range → score bar (green/amber/red)
  - Test Score Match: Your SAT/ACT vs range → score bar
  - Major Availability: Does school offer your career field → check/x
  - Location Preference: Distance from home → score bar
  - Financial Fit: Estimated net cost vs budget → score bar
  - Campus Culture: Personality alignment → score bar
  - Size Preference: Your preference vs actual → score bar
- Each factor expandable for detail

Right (45%):
- "How to Improve Your Match" card: AI-generated suggestions (e.g., "Raise SAT by 50 points → +8% match")
- Comparison with similar colleges: Mini cards showing match % for 3-4 alternatives
- "What-If Simulator" link → goes to What-If screen

### D5. ADVANCED COLLEGE FILTERS
**Layout: Full-screen filter panel (drawer from right, 500pt)**
- Filter categories (vertically scrollable):
  - **Location:** State multi-select, Region picker, Distance from home slider
  - **Academics:** Major/field of study dropdown, Graduation rate range, Student-faculty ratio range
  - **Admissions:** Acceptance rate range slider, SAT range slider, ACT range slider, Test policy (Required/Optional/Blind)
  - **Cost:** Tuition range slider, Average aid slider, Net cost range
  - **Campus:** Size (Small <2K, Medium 2-10K, Large 10K+), Setting (Urban/Suburban/Rural), Type (Public/Private/Religious)
  - **Culture:** Diversity index, Greek life %, Athletics division, HBCU toggle, Women's college toggle
- "Apply Filters" accent button (with result count preview)
- "Reset All" link
- Active filter count badge

### D6. CAMPUS PHOTO GALLERY
**Layout: Full-width photo grid**
- College name header
- Photo grid: 3-column masonry layout
- Full-screen photo viewer on tap (swipe to navigate)
- Photo categories: Campus, Dorms, Dining, Athletics, Labs, Library, Student Life
- Filter tabs for categories
- "No photos available" empty state with "Suggest a photo" link

### D7. "BEST FOR YOUR MAJOR" FILTER RESULTS
**Layout: Ranked list**
- "Best Colleges for [Major/Career Path]" headline
- Career path badge
- Ranked college list:
  - Rank number
  - College card: Name, match %, ranking score, specific program details
  - "Why this school for your major" mini explanation
  - Tag chips: Program strengths
- Filterable by additional criteria (location, cost, etc.)

### D8. AI-GENERATED COLLEGE PAGE
**Layout: Same as College Profile (D2) but with AI banner**
- Prominent "AI-Generated Page" banner at top (secondary color background, sparkles icon)
- "This college isn't in our database yet. This page was generated by AI and may contain inaccuracies."
- College name + basic info generated from web data
- Sections: Overview, Key Stats (with "unverified" badges), Related Similar Colleges
- "Report Inaccuracy" button
- "Request Official Page" button

### D9. WHAT-IF ADMISSIONS SIMULATOR
**Layout: Interactive split**
Left (50%):
- "What If..." headline with sparkles
- Sliders with current and adjustable values:
  - GPA: Current [3.5] → Slider [0.0-5.0]
  - SAT: Current [1280] → Slider [400-1600]
  - ACT: Current [28] → Slider [1-36]
  - AP Courses: Current [4] → Stepper [0-15]
  - Activities: Current [6] → Stepper [0-20]
  - Service Hours: Current [50] → Stepper [0-500]
- "Reset to Current" link

Right (50%):
- Live-updating college cards (for each saved college):
  - College name
  - Current match %
  - Projected match % (with delta: ↑ green or ↓ red)
  - Reach/Match/Safety badge (may change)
- AI Insight card at bottom: Personalized suggestion (e.g., "Improving SAT to 1400 would move Harvard from Reach to High Reach and UF from Match to Safety")

### D10. MY CHANCES CALCULATOR
**Layout: Dashboard grid**
Top row: Three large circular progress rings:
  - **Reach** (X colleges) — tertiary color ring
  - **Match** (Y colleges) — primary color ring
  - **Safety** (Z colleges) — secondary/lime color ring

Below: Three column sections (Reach | Match | Safety):
- College cards in each column:
  - College name, acceptance probability bar (0-100%), key factor (why it's reach/match/safety)
  - Expandable: Full factor breakdown

Bottom:
- AI summary: "You have a balanced list. Consider adding 1 more safety school."
- Methodology note (small, muted)

### D11. WHY THIS SCHOOL ESSAY SEED GENERATOR
**Layout: Two-column**
Left (45%):
- College selector dropdown at top
- "AI-Generated Connection Points" headline
- Connection cards (4-6):
  - Icon + title ("Research Focus", "Hands-On Learning", "First-Gen Support", "Bright Futures Alignment", "Campus Community", "Career Services")
  - 2-3 sentence explanation of why this matters for YOU specifically
  - "Use This" toggle/check on each card
- "Generate More" button

Right (55%):
- "Your Essay Outline" headline
- Selected seeds appear as building blocks
- Outline sections:
  - Hook (2-3 suggestions)
  - Why This School (based on selected connection points)
  - Why You (your unique angle)
  - Conclusion (forward-looking)
- "Copy Outline" accent button
- "Open in Essay Editor" button
- Word count estimate

### D12. DEADLINE HEATMAP CALENDAR
**Layout: Full calendar + sidebar**
Left (65%):
- Month view calendar grid (7x5-6)
- Cell background color intensity = deadline density:
  - Cream (#fff8f2): 0 deadlines
  - Light green (#c4f0bb): 1 deadline
  - Medium green (#5a7956): 2-3 deadlines
  - Dark green (#42603f with white text): 4+ deadlines
- Selected day: Primary border
- Month navigation arrows + month/year title
- Dots below each day number for deadline types (color-coded)

Right (35%):
- Selected date header (full date)
- Deadline list for that day:
  - Cards: College name, deadline type (EA/ED/RD/Rolling), platform tag, urgent badge
  - Tap → navigate to Application Detail
- "Urgency This Week" summary strip: Next 7 days as mini bar chart

### D13. COLLEGE VISIT PLANNER + MAP
**Layout: Map + itinerary split**
Left (55%):
- Interactive map (MapKit) with college pins
- Pin colors: Green=Visited, Blue=Scheduled, Gray=Not Scheduled
- Optimized route line connecting scheduled visits
- Driving time labels between stops

Right (45%):
- "Campus Visit Plan" header
- Ordered visit cards:
  - College name
  - Date/time (editable date picker)
  - Status badge (Visited ✓, Scheduled ◎, Not Scheduled ○)
  - Notes text field
  - "Schedule Tour" link
- Drag to reorder visits
- Trip summary at bottom: Total schools, total miles, estimated days
- "Optimize Route" button
- "Export to Calendar" button

### D14. MY COLLEGE LIST (Saved Colleges)
**Layout: Two-column**
Left (60%):
- "My College List" header + count
- Sort: Match %, Date Added, Name, Deadline
- College cards (wider than Discovery):
  - Image, name, location, match %, type tags
  - Application status badge (Not Started, In Progress, Submitted, Decision)
  - Next deadline with countdown
  - Favorite heart, compare checkbox
- "Compare Selected" button (appears when 2+ checked)

Right (40%):
- Summary card:
  - Total schools: X
  - Reach/Match/Safety distribution (mini bar)
  - Earliest deadline
  - Applications submitted / total
- "List Health" AI card: "Your list is well-balanced" or "Consider adding more safety schools"

---

## SECTION E: APPLICATIONS (8 screens)

### E1. APPLICATION TRACKER (All Applications List)
**Layout: Two-panel**
Left (45%):
- "Applications" header + count
- Filter chips: All, In Progress, Submitted, Decision Received
- Application cards list:
  - College name + logo
  - Application type (EA, ED, RD, Rolling)
  - Status badge (Not Started, In Progress, Submitted, Under Review, Accepted, Rejected, Waitlisted, Enrolled)
  - Deadline + days remaining
  - Progress bar (checklist completion)

Right (55%):
- Selected application detail (same content as E2)
- Empty state: "Select an application to view details"

### E2. APPLICATION DETAIL VIEW
**Layout: Two-column**
Left (55%):
- Status card: College name, location, match %, status badge (large), application type, submission date
- **Progress Section:** "Application Progress" title, X/Y completed, linear progress bar
- **Checklist:**
  - Section headers: Personal Info, Essays, Recommendations, Test Scores, Financial Aid
  - Task rows: Checkbox, category icon, task title, priority dot, due date
  - Completed: Green check, strikethrough

Right (45%):
- **Timeline:** Vertical timeline showing:
  - Application started
  - Documents uploaded (each)
  - Submitted
  - Under review
  - Decision (if received)
- **Documents:** List of required/uploaded files with status icons (✓ uploaded, ⏳ pending, ✗ missing)
- **Notes:** Free-text notes area
- **Actions:** "Submit Application" primary, "Withdraw" destructive

### E3. DEADLINES CALENDAR
**Layout: Calendar + sidebar**
Left (65%):
- Full month calendar grid
- Navigation: ← Month Year →
- View toggles: Month | Week | List
- Deadline indicators on days: Colored dots (red=urgent, amber=soon, green=safe)
- Selected day: Primary border

Right (35%):
- Selected date: Full date header
- Deadline list:
  - Cards: College name, deadline type, platform tag (Common App/Coalition/Direct), urgent badge
  - Tap → navigate to Application Detail
- Upcoming this week strip
- Overdue section (red cards, if any)

### E4. APPLICATION SEASON DASHBOARD (Kanban)
**Layout: Full-width Kanban board**
Top bar:
- Countdown ring (days to earliest deadline, compact)
- Stats: Total apps X, Submitted Y, Accepted Z
- "Chat with Advisor" quick button

Main Kanban area (4 columns, horizontally scrollable on smaller widths):
- **Drafting** — Cards with college name, progress bar, deadline, status color
- **Ready to Submit** — Cards with "Submit Now" button
- **Submitted** — Cards with submission date, "Under Review" label
- **Decision Received** — Cards with Accept ✓ / Reject ✗ / Waitlist ⏳ badge

Cards are **drag-and-drop** between columns (touch-based on iPad).
Tap card → drawer slides up with quick detail.

Bottom strip: "Today's Action Items" — horizontal scroll of task chips

### E5. APPLICATION SUBMISSION TRACKER
**Layout: Single column (max-width 700pt)**
- College name header
- Submission progress stepper (horizontal):
  1. Personal Info ✓
  2. Essays ✓
  3. Recommendations ◎
  4. Test Scores ✓
  5. Payment ○
  6. Submit ○
- Current step detail section showing what's needed
- Warning badges on incomplete items
- "Review & Submit" button (enabled only when all steps complete)
- Post-submit: Confirmation card with submission ID, date, "View Confirmation" link

### E6. DECISION PORTAL
**Layout: Two-column**
Left (55%):
- "Decisions" headline
- Decision cards by college:
  - College name + logo
  - Decision: Accepted (green), Rejected (red), Waitlisted (amber), Deferred (blue)
  - Decision date
  - Financial aid package summary (if accepted)
  - "Respond by [date]" countdown (if accepted)
  - Action buttons: Accept Offer, Decline, View Financial Aid

Right (45%):
- **Decision Summary:**
  - Accepted: X schools
  - Rejected: Y schools
  - Waitlisted: Z schools
  - Pending: W schools
- Donut chart visualization
- "Compare Accepted Schools" button → side-by-side of only accepted schools
- "Need Help Deciding?" → AI Advisor chat

### E7. WAITLIST TRACKER & LOCI
**Layout: Two-column**
Left (55%):
- "Waitlisted Schools" header
- School cards:
  - College name, waitlist position (if shared), date waitlisted
  - LOCI status: Not Sent / Draft / Sent with date
  - "Write LOCI" button → opens Essay Editor
  - Additional materials sent checklist
  - "Remove from Waitlist" secondary button

Right (45%):
- "Waitlist Strategy" AI card:
  - Tips for each school based on their waitlist history
  - "What to include in your LOCI" checklist
  - "Schools that historically accept from waitlist" insight
- Selected school LOCI preview (if drafted)

### E8. VOLUNTEERING / SERVICE HOURS LOG
**Layout: Two-panel**
Left (45%):
- "Service Hours" header + total hours badge
- "Log Hours" button
- Entries list:
  - Organization name
  - Date + hours
  - Category (Community, School, Religious, Environmental, etc.)
  - Verified badge (if counselor confirmed)

Right (55%):
- Log entry form (or selected entry detail):
  - Organization name
  - Date picker
  - Hours (number input)
  - Category dropdown
  - Description text area
  - Supervisor name + contact (for verification)
  - "Save" button
- Hours summary chart: Monthly bar chart showing hours over time
- Total hours + category breakdown

---

## SECTION F: AI ADVISOR (8 screens)

### F1. AI ADVISOR HUB (Landing)
**Layout: Dashboard grid**
- "Your AI Advisor" headline with sparkles
- 2x2 grid of tool cards:
  1. **Chat** — Sparkles icon, "Ask Anything", "Get personalized college advice", "Start Chat" button
  2. **Essay Hub** — Pencil icon, "Essay Assistant", "Write and review essays", "Open Hub" button
  3. **Score Improvement** — Chart icon, "SAT/ACT Prep", "Get your study plan", "View Plan" button
  4. **Interview Prep** — Person icon, "Mock Interviews", "Practice with AI", "Start Practice" button
- Recent conversation preview card below grid
- "View All Conversations" link

### F2. AI CHAT CONVERSATION
**Layout: Chat with sidebar**
Left sidebar (280pt):
- "AI Advisor" header + sparkles
- **Conversation History:** Past chat sessions (title, date, preview snippet). Tap to load.
- "New Conversation" button
- Divider
- **Quick Tools:** Links to Essay Hub, Score Improvement, Interview Prep, Career Quiz

Right (remaining):
- **Empty state (no messages):**
  - Large sparkles icon in gradient circle
  - "Hi! I'm your college advisor" (Headline Medium)
  - "I can help with applications, essays, test prep, and more"
  - Quick prompts 2x2 grid:
    - "Help me pick colleges for my profile"
    - "Review my Common App essay"
    - "Create a study plan for the SAT"
    - "What extracurriculars should I do?"
- **Messages:**
  - User: Right-aligned, primary background, white text, rounded bubble, max-width 500pt
  - Advisor: Left-aligned, surface container background, "Advisor" label + sparkles icon, rounded bubble
  - Typing indicator: 3 animated dots
- **Input bar (bottom sticky):**
  - Multi-line TextField (1-6 lines on iPad)
  - Attach button (paperclip, for essay uploads)
  - Send button (arrow.up.circle.fill, lime when text present, disabled gray when empty)

### F3. CHAT HISTORY / CONVERSATION LIST
**Layout: Full list (max-width 700pt)**
- "Conversation History" header
- Search bar
- Conversations list:
  - Title (auto-generated or user-named)
  - Date + time
  - Preview (first user message, truncated)
  - Message count badge
  - Swipe to delete
- Tap → loads conversation in Chat screen

### F4. ESSAY HUB
**Layout: Two-column**
Left (50%):
- Header card: Sparkles icon, "AI-Powered Essay Assistant" (Title Large), description text
- "Start New Essay" accent button
- **Common App Prompts** (7 cards):
  - Number badge (1-7)
  - Prompt title
  - Description (2 lines, truncated)
  - Arrow icon → opens in editor
- **Supplemental Prompts** section:
  - Grouped by college
  - College name header
  - Prompt cards within

Right (50%):
- **My Essays** list:
  - Essay title
  - Type badge (Common App / Supplement / Additional)
  - College name (for supplements)
  - Status chip (Not Started / Draft / In Review / Complete)
  - Word count / target
  - Progress bar
  - "Open" button
- Empty state: Document icon, "No essays yet — start one from the prompts"

### F5. ESSAY EDITOR / WRITER
**Layout: Full-width writing workspace**
Top toolbar:
- Back button
- Essay title (editable)
- College + prompt reference (muted, collapsible)
- Word count / target
- "Get AI Review" accent button
- Save indicator (auto-save)

Main area (max-width 700pt, centered):
- Large text editor area
- Minimal formatting: Bold, Italic, paragraph breaks
- Placeholder text: "Start writing your essay here..."
- Prompt text pinned at top (collapsible, muted)

Right margin tools (collapsible panel, 280pt):
- "AI Suggestions" section: Tone, structure, word choice tips
- "Outline" section: Drag to reorder sections
- "Version History" section: Previous saves with restore option

### F6. ESSAY AI REVIEW RESULTS
**Layout: Two-column (overlay/modal on essay editor)**
Left (55%):
- Essay text with inline highlights:
  - Green: Strong passages
  - Amber: Could improve
  - Red: Needs attention
- Click highlight → shows specific feedback in right panel

Right (45%):
- **Overall Score:** Circular ring (0-100) with grade letter
- **Strengths** card: Bulleted list of what works well
- **Areas to Improve** card: Bulleted list with specific suggestions
- **Structure Analysis:** Opening (rating), Body (rating), Conclusion (rating)
- **Tone Assessment:** Authentic / Generic / Overly Formal
- **Action Items:** Numbered list of specific changes to make
- "Apply Suggestions" button (AI auto-edits)
- "Rewrite Section" button (for selected text)

### F7. SCORE IMPROVEMENT PLAN (SAT/ACT)
**Layout: Dashboard + sidebar**
Left (65%):
- **SAT Journey Card:** Two large score circles (Current: XXX, Target: XXX) connected by arrow, "You need X more points" subtitle
- **Recommended Study Plan:** Timeline view:
  - Phase cards (Weeks 1-2, 3-6, 7-8, Test Day):
    - Icon + phase name + focus area
    - Bullet list of tasks (5-8 per phase)
    - Estimated hours per week
  - Phase connections with arrows

Right (35%):
- **Free Resources:**
  - Khan Academy (link + description)
  - College Board Official Practice (link)
  - Fee Waiver Info
- **Practice Test Log:** Date, score, section breakdown. "Log Score" button. Mini trend chart.
- **Study Calendar:** Mini month with study days highlighted lime
- **Test Dates:** Upcoming SAT/ACT dates with registration deadlines

### F8. INTERVIEW PREP / MOCK INTERVIEW
**Layout: Two modes**

**Prep Mode (Landing):**
- "Interview Preparation" header
- Common question cards (10):
  - "Tell me about yourself"
  - "Why this school?"
  - "What's your biggest achievement?"
  - etc.
  - Each card: Question, difficulty badge, tip preview, "Practice" button
- "Start Full Mock Interview" accent button
- Tips & Resources section: Articles on body language, common mistakes, dress code

**Mock Interview Mode:**
- Full-screen chat-like interface:
  - AI interviewer question (large text, left-aligned)
  - Text response area (or voice note option indicator)
  - Timer showing elapsed time
  - "Next Question" / "Skip" buttons
  - Progress: Question 3 of 10
- **Results screen after interview:**
  - Overall performance score (0-100 ring)
  - Feedback per question: Your answer summary, AI assessment (Strong/Adequate/Needs Work), improvement suggestion
  - "Review All Answers" expandable list
  - "Retake Interview" button

---

## SECTION G: ACADEMIC PLANNING (8 screens)

### G1. GPA TRACKER
**Layout: Chart + entry split**
Left (55%):
- "GPA Tracker" header
- Trend line chart (large):
  - X-axis: Semesters (9th Fall → 12th Spring)
  - Y-axis: GPA (0.0-5.0)
  - Two lines: Unweighted (primary) + Weighted (secondary)
  - Data points with tooltips on tap
- Semester selector pills below chart (scroll horizontal)
- Current GPA display: Unweighted [X.XX] | Weighted [X.XX]
- Bright Futures eligibility card: Green check or amber warning + required GPA

Right (45%):
- Selected semester detail card
- Course table:
  - Course Name | Credits | Grade | Weight (Regular/Honors/AP/DE)
  - Grade badges color-coded (A=green, B=blue, C=amber, D/F=red)
- "Add Course" button → inline form
- Semester GPA calculation (live update)
- "Save Changes" button

### G2. TRANSCRIPT UPLOAD + AI PARSE
**Layout: Upload → Review**
Left (40%):
- "Upload Transcript" header
- Large upload area:
  - Camera capture button (photograph transcript)
  - File picker button (PDF, JPG, PNG)
  - Drag-and-drop zone
- Processing state: Animated loading with "AI is reading your transcript..."
- Upload history: Previous uploads with dates

Right (60%):
- **Parsed Results:**
  - Semester tabs across top
  - Course table per semester:
    - Course Name | Grade | Credits | Weight | Status
    - Status: ✓ Verified (green), ⚠ Needs Review (amber), ✗ Not Found (red)
  - Calculated GPA per semester + cumulative
  - Flagged items highlighted with amber background
  - "Confirm All" accent button
  - "Edit" button per row
  - "Import to GPA Tracker" button

### G3. AP COURSE SUGGESTIONS
**Layout: Two-column**
Left (55%):
- "Recommended AP Courses" header with sparkles
- Based on: Career path badge, current GPA, grade level
- Course cards:
  - AP Course name
  - Difficulty rating (1-5 stars or bar)
  - "Why this course" AI explanation (2 lines)
  - Prerequisites listed
  - Average grade at your school (if available)
  - Bright Futures impact badge
  - "Add to Schedule" button

Right (45%):
- "Your Current APs" list: Current AP courses with grades
- "AP Exam Scores" section: Past AP exam scores
- "College Credit Map" card: Which colleges accept which AP credits
- "Load Balance" card: AI assessment of course load difficulty per semester

### G4. DUAL ENROLLMENT GUIDE
**Layout: Two-column**
Left (55%):
- "Dual Enrollment Guide" header
- "What is Dual Enrollment?" explainer card
- Available courses list:
  - Course name, college offering it, credits (high school + college)
  - Cost per credit
  - Transferability info
  - Schedule (days/times)
- Filter: By subject, by college, by schedule

Right (45%):
- "Your DE Courses" list: Currently enrolled courses with progress
- Credits tracker: High school credits earned, college credits earned
- Cost savings calculator: "You've saved $X vs taking these in college"
- Transfer guide: Which colleges accept these credits

### G5. AI CLASS SCHEDULER (Student View)
**Layout: Schedule grid + AI sidebar**
Main area (70%):
- Weekly schedule grid:
  - Rows: Period 1-7 (or time slots)
  - Columns: Mon-Fri
  - Filled cells: Course name, teacher, room. Color-coded by department (green=science, blue=english, amber=math, purple=social studies, etc.)
  - AI-recommended: Green dashed border + sparkles badge
  - Empty cells: "+" button to add class
- Tap cell → bottom drawer with 3-4 alternative options

Right sidebar (30%):
- **AI Recommendations:**
  - Career path alignment score (circular progress)
  - Bright Futures progress bar
  - Total credits
  - Difficulty assessment (1-5 bar)
- **Suggested Changes:** AI-flagged optimizations
- "Apply AI Suggestions" accent button
- "Submit to Counselor for Approval" primary button

### G6. RESEARCH & INTERNSHIP TRACKER
**Layout: Two-panel**
Left (45%):
- "Research & Internships" header
- "Add New" button
- Filter tabs: All | Research | Internships | Competitions
- Entry cards:
  - Title
  - Organization/lab
  - Type badge
  - Date range
  - Status (Active, Completed, Applied, Accepted)
  - Hours logged

Right (55%):
- Selected entry detail:
  - Title (Headline Small)
  - Organization, supervisor, contact
  - Description
  - Skills developed (tag chips)
  - Outcomes / publications / awards
  - Hours log (mini chart)
  - Documents section (papers, certificates)
  - "Edit" + "Delete" buttons

### G7. SUPPLEMENTAL ESSAY TRACKER
**Layout: Master-detail**
Left (35%):
- "Supplemental Essays" header
- College list with progress:
  - College name
  - X/Y essays complete badge
  - Progress bar
  - Overall status chip
- Click college → shows its essays in right panel

Right (65%):
- Selected college header (name + deadline)
- Essay cards:
  - Prompt text (full, Body Large)
  - Status badge (Not Started / Draft / In Review / Complete)
  - Word count / limit
  - Progress bar
  - "Open in Editor" button
  - Last edited date
- "Start All Essays" button at bottom

### G8. CAREER-SPECIFIC ACTIVITY SUGGESTIONS
**Layout: Two-column**
Left (55%):
- "Suggested Activities for [Career Path]" header with sparkles
- Career path badge
- Suggestion cards (AI-generated):
  - Activity name
  - Category (Sports, Arts, Academic Club, Service, Leadership, Work, Research)
  - "Why this matters" explanation
  - Difficulty/commitment level
  - Impact rating
  - "Add to My Activities" button
- Grouped by: "High Impact", "Medium Impact", "Quick Wins"

Right (45%):
- "Your Current Activities" list
- Coverage analysis: Radar chart showing activity diversity (Leadership, Service, Academic, Creative, Athletic)
- "Gaps to Fill" card: AI identifies missing areas
- "Typical Profile of Admitted [Career] Students" comparison card

---

## SECTION H: CAREER (4 screens)

### H1. CAREER QUIZ (3-Stage RIASEC)
**Layout: Centered quiz card (max-width 600pt)**

Progress bar top (segmented by stage + question)

**Stage 1: General Interest (15 questions):**
- Question icon + question text (Headline Small)
- 2x2 grid of answer options (large touch targets, 140pt each)
- Each option: Icon + short label + description
- Tap to select (primary border + checkmark)
- Back / Next buttons + keyboard support

**Stage 2: Branching Deep Dive (10 questions, personalized based on Stage 1):**
- Same layout but more specific questions
- "Based on your interests in..." intro text before each question

**Stage 3: AI Personalization (5 questions):**
- Open-ended text responses
- "Tell us about a project you're proud of"
- "What problems do you want to solve?"
- Text area inputs

### H2. CAREER QUIZ RESULTS
**Layout: Rich result card (max-width 700pt)**
- Sparkles icon in gradient circle (animated)
- Archetype title: "The Ambitious Healer" (Display Small)
- RIASEC code: "ISA" with explanation
- Description paragraph (Body Large)
- Three cards side by side:
  1. **Your Traits:** Tag chips (Analytical, Empathetic, Detail-Oriented, etc.)
  2. **Recommended Paths:** Career rows with arrow icons (Doctor, Biomedical Engineer, Physical Therapist, etc.)
  3. **Classes to Take:** Checklist (AP Biology ✓, AP Chemistry, Statistics, etc.)
- "Your Personality Map" radar chart (RIASEC hexagon)
- "Save to Profile" accent button
- "Retake Quiz" secondary button
- "Explore Careers" link → Career Explorer

### H3. CAREER EXPLORER (Degree → Jobs + Salary)
**Layout: Interactive dashboard**
Top: Major/career path selector (horizontal scrolling cards with icons: Medicine, Engineering, Business, Arts, etc.)

Left (50%):
- Selected career detail:
  - Career title (Headline Large)
  - Description
  - Education required (timeline: Bachelor's → MD → Residency)
  - Salary visualization: Horizontal bars for Entry ($X), Mid-Career ($Y), Senior ($Z)
  - Job growth projection: % growth + "High Demand" tag

Right (50%):
- **Related Jobs** cards (2-column grid):
  - Job title
  - Median salary
  - Growth %
  - Education required
  - Tags (High Demand, Fastest Growing, Most Stable)
  - Tap for full detail
- **Related Majors** row: Chip links
- "Set as My Career Path" button

### H4. POST-GRADUATION PLANNING MODE
**Layout: Dashboard**
- "Life After College" header
- Mode switcher: Pre-Graduation | Post-Graduation timeline
- Checklist sections:
  - **Housing:** Apartment search, lease signing, move-in prep
  - **Career:** Job applications, interview prep, networking
  - **Financial:** Student loan repayment plan, budgeting, credit building
  - **Life:** Health insurance, utilities, grocery planning
- Timeline: Month-by-month from May (graduation) through September (settled)
- Resources section: Article links, tools, guides

---

## SECTION I: FINANCIAL (6 screens)

### I1. SCHOLARSHIP SEARCH
**Layout: Filterable list + detail panel**
Left (45%):
- Search bar (wide)
- Filter chips (horizontal scroll): All, Merit, Need-Based, Local, STEM, Arts, First-Gen, Minority, Athletic
- Sort: Match %, Amount, Deadline
- Scholarship cards:
  - Name (Title Medium)
  - Provider
  - Amount (lime color, large)
  - Deadline + days remaining
  - Match % badge
  - Eligibility preview (1 line)
  - Tag chips
  - Bookmark star button

Right (55%):
- **Selected scholarship detail:**
  - Name (Headline Small), provider
  - Amount (Headline Large, lime)
  - Deadline countdown
  - Full eligibility criteria list
  - Application instructions
  - Required materials checklist
  - External link / "Apply Now" button
  - Match breakdown: ✓ You qualify / ⚠ Check eligibility / ✗ Not eligible — per criterion
- Empty state: "Select a scholarship to view details"

### I2. SCHOLARSHIP DETAIL (Full Page)
**Layout: Single column (max-width 700pt)** — navigated from search or links
- Provider logo (if available)
- Scholarship name (Headline Large)
- Amount (Display Small, lime)
- Deadline with countdown
- About section: Full description
- Eligibility: Detailed criteria list with status icons
- Application Process: Step-by-step instructions
- Required Materials: Checklist
- Past recipients / success rate info (if available)
- "Apply Now" accent button
- "Save" secondary button
- "Share" button

### I3. SCHOLARSHIP MATCH SCORE
**Layout: Ranked table + detail**
Left (45%):
- "Your Scholarship Matches" header
- Total potential aid card: "$XX,XXX in potential scholarships"
- Ranked list:
  - Rank number
  - Scholarship name
  - Amount
  - Match % (with colored bar: green >80%, amber 50-80%, red <50%)
  - Deadline
  - Status badge (Applied, Saved, New)

Right (55%):
- Selected scholarship detail:
  - Match % breakdown:
    - ✓ GPA meets requirement (green)
    - ✓ SAT meets requirement (green)
    - ⚠ Community service hours close (amber)
    - ✗ Major not listed (red)
  - Profile tags that matched
  - "How to improve match" AI suggestions
  - "Apply" button

### I4. SCHOLARSHIP ACTION PLAN
**Layout: Timeline + tasks**
- "Your Scholarship Plan" header with sparkles
- AI-generated action plan:
  - Priority scholarships ranked by ROI (amount × match probability / effort)
  - Monthly timeline: Which scholarships to apply for when
  - Task cards per scholarship:
    - Application deadline
    - Required essays (with link to Essay Hub)
    - Required documents
    - Estimated time to complete
  - Total potential earnings summary

### I5. FINANCIAL AID COMPARISON
**Layout: Side-by-side comparison table**
- Top: School selector slots (2-3 colleges you've been accepted to)
- Comparison rows:
  - Tuition
  - Room & Board
  - Fees
  - **Total Cost of Attendance**
  - Grants & Scholarships
  - Federal Aid
  - Institutional Aid
  - Student Loans
  - Work-Study
  - **Net Cost (what you actually pay)**
  - **4-Year Total Cost**
- Color highlighting: Green for best value per row
- "Which should I choose?" AI recommendation card
- "Export Comparison" button

### I6. FAFSA READINESS SCORE / NET COST CALCULATOR
**Layout: Two-column**
Left (55%):
- "FAFSA Readiness" header
- Readiness score: Large circular ring (0-100)
- Checklist:
  - FSA ID created ☐
  - Parent tax returns ready ☐
  - Student tax returns ready ☐
  - W-2s collected ☐
  - Bank statements ready ☐
  - CSS Profile (if needed) ☐
  - Priority deadline known ☐
- Each item with "Learn More" expandable info

Right (45%):
- **Net Cost Calculator:**
  - Family income input (slider or range selector)
  - Assets input
  - Number in college
  - Selected college dropdown
  - **Estimated Net Cost:** Large number
  - **Estimated Aid:** Breakdown (grants, loans, work-study)
- "This is an estimate" disclaimer
- "Compare Across Schools" link

---

## SECTION J: TEST PREP (4 screens)

### J1. TEST PREP RESOURCES HUB
**Layout: Card grid**
- "Test Prep Resources" header
- Resource cards (2-column grid):
  1. **Khan Academy SAT Prep** — Free, comprehensive, linked to College Board
  2. **College Board Official Practice** — 8 free practice tests
  3. **ACT Academy** — Free ACT prep
  4. **SAT Fee Waiver Info** — Eligibility info
  5. **Local Prep Programs** — Based on location
  6. **Ladder Study Plan** — Link to Score Improvement screen
- Each card: Logo/icon, title, description, "Open" external link button, "Free" or cost badge
- "View Your Study Plan" accent button at top

### J2. SAT/PSAT REGISTRATION REMINDERS
**Layout: Timeline + action cards**
- "Upcoming Test Dates" header
- Timeline of test dates:
  - SAT dates (next 12 months) with registration deadlines
  - PSAT date (October)
  - ACT dates with registration deadlines
- Each date card:
  - Test name + date
  - Registration deadline + countdown
  - "Register Now" external link button
  - Fee + fee waiver eligibility note
  - "Set Reminder" toggle
- "You're registered for: [test + date]" banner if applicable

### J3. PRACTICE TEST SCORE LOG
**Layout: Chart + entry list**
Left (55%):
- Trend chart: X-axis = test dates, Y-axis = scores
- SAT line + ACT line (if both)
- Target score reference line (dashed)
- Section breakdown mini charts: Math + Reading/Writing

Right (45%):
- Score entries list:
  - Date
  - Test type (SAT/ACT/PSAT)
  - Total score
  - Section scores
  - Source (Official, Practice Test #X, Khan Academy)
- "Log New Score" button → form:
  - Date, test type, total score, section scores, source dropdown

### J4. STUDY SCHEDULE PLANNER
**Layout: Calendar + plan**
Left (60%):
- Monthly calendar with study days highlighted in lime
- Suggested study blocks (AI-generated based on test date + score gap)
- Click day → shows that day's study plan

Right (40%):
- Selected day's plan:
  - Study session cards:
    - Subject (Math / Reading / Writing)
    - Focus area ("Algebra & Functions", "Evidence-Based Reading")
    - Duration (45 min)
    - Resource link (Khan Academy lesson, practice set)
  - "Mark Completed" checkboxes
- Weekly stats: Hours studied this week, questions practiced, improvement estimate

---

## SECTION K: HOUSING (5 screens)

### K1. HOUSING PREFERENCES QUIZ
**Layout: Centered quiz (max-width 600pt)**
- "Find Your Perfect Housing" header
- Progress by category (icons): Sleep 💤 | Clean 🧹 | Noise 🔊 | Social 🎉 | Study 📚 | Temp 🌡️
- Current question:
  - Category icon + category name
  - Question text
  - 2x2 emoji-based answer grid (large touch targets):
    - e.g., "Sleep Schedule": Night Owl 🦉 / Early Bird 🐦 / Flexible 🔄 / Varies 🎲
  - Each option: Emoji + label + brief description
- "Next" button
- Progress bar showing completion

### K2. DORM COMPARISON
**Layout: Side-by-side comparison table**
- Top: 2-3 dorm selector dropdown slots
- Comparison rows:
  - Monthly cost
  - Room type (Single, Double, Suite)
  - Distance to campus (with mini map indicator)
  - Meal plan included?
  - Amenities: Laundry, AC, Kitchen, Parking, Gym, Study Room (icon grid)
  - Move-in date
  - Rating (stars)
- Photo row per dorm (horizontal scroll)
- "Select Preferred" accent button per dorm
- "Can't decide?" AI recommendation

### K3. ROOMMATE COMPATIBILITY QUIZ
**Layout: Same pattern as Housing Preferences Quiz (K1)**
- More detailed questions:
  - Sharing food? Guest policy? Music volume? Study in room or library?
  - Weekend habits? Pet preferences? Decoration style?
- Results stored for Roommate Finder matching

### K4. ROOMMATE FINDER (Match List)
**Layout: Master-detail**
Left (40%):
- "Potential Roommates" header + count
- Sort: Compatibility %, Name
- Match cards:
  - Avatar (initials)
  - First name + last initial
  - Compatibility % badge (green >80%, amber 50-80%, red <50%)
  - Top 3 matching traits
  - College name (if same school)

Right (60%):
- Selected match profile:
  - Avatar + name
  - Compatibility % (large circular ring)
  - Radar chart: Category breakdown (Sleep, Clean, Noise, Social, Study, Temp)
  - Shared preferences list (green checks)
  - Different preferences list (amber notes)
  - "Send Introduction" primary button
  - "Pass" secondary button
- Privacy note: "Only first names shown. Full contact shared after mutual match."

### K5. HOUSING DEADLINE TRACKER
**Layout: Timeline per college**
- "Housing Deadlines" header
- College tabs (horizontal): College A | College B | College C
- Per college timeline:
  - Housing application open date
  - Housing application deadline
  - Roommate selection deadline
  - Meal plan selection deadline
  - Move-in date
- Each item: Date, days remaining/ago, status (Upcoming, Due Soon, Overdue, Complete)
- "Set Reminders" toggle per deadline

---

## SECTION L: PROFILE & SETTINGS (8 screens)

### L1. PROFILE VIEW (Main)
**Layout: Wide profile + settings grid**

Top section (full width):
- Profile card: Avatar (80pt, initials + gradient background), student name (Headline Medium), career path badge, grade badge, school name, archetype badge (from career quiz)
- Stats row (4 cards horizontal): GPA, SAT, Colleges Saved, Streak Days — each with icon, large number, label, trend arrow

Bottom (two columns):
Left:
- **Academics** section: Menu rows with icons, titles, detail text, chevrons:
  - AP Courses (count)
  - Extracurriculars (count)
  - Test Score History
  - GPA Tracker
- **College Planning** section:
  - My College List (count)
  - 4-Year Roadmap (progress %)
  - Application Tracker (submitted/total)
  - Career Path

Right:
- **Tools & Features** section:
  - AI Advisor
  - Essay Hub
  - Scholarship Search
  - Housing
- **Account** section:
  - Edit Profile
  - Notification Preferences
  - Privacy & Data
  - Help & Support
  - Share Invite Code (for parents)
  - Sign Out (red)

### L2. PROFILE SETTINGS (Edit Form)
**Layout: Centered form (max-width 680pt)**
- Avatar centered: Initials circle + "Change Photo" button + "Remove" link
- **Personal Information:**
  - Two-column: First Name + Last Name
  - Full: School (autocomplete)
  - Full: Student ID
  - Grade dropdown
  - First-gen toggle
- **Academic Profile:**
  - Two-column: GPA + Career Path dropdown
  - Two-column: SAT Score + ACT Score
- **Contact:**
  - Email (read-only with "Change Email" link)
  - Phone (optional)
- "Save Changes" primary button + "Cancel" link

### L3. NOTIFICATION SETTINGS
**Layout: Two-column toggle grid (max-width 680pt)**
Left — **Reminders:**
- Deadline Reminders: toggle + "Get notified X days before deadlines" description
- Task Reminders: toggle + "Daily task reminder at 9am"
- Streak Reminder: toggle + "Don't break your streak!"
- Test Date Reminders: toggle + "SAT/ACT registration alerts"

Right — **Content:**
- Daily Tip: toggle + "Personalized college tip each morning"
- New Scholarships: toggle + "When new scholarships match your profile"
- Application Updates: toggle + "Status changes on your applications"
- AI Advisor Tips: toggle + "Proactive suggestions from your advisor"

### L4. THEME SETTINGS
**Layout: Centered card (max-width 400pt)**
- "Appearance" header
- Three large selectable cards:
  - **System** (default): Phone icon, "Follow device settings"
  - **Light**: Sun icon, preview thumbnail of light mode
  - **Dark**: Moon icon, preview thumbnail of dark mode
- Selected: Primary border + checkmark
- Live preview: Background changes immediately on selection

### L5. PRIVACY SETTINGS
**Layout: Centered list (max-width 600pt)**
- "Privacy & Data" header
- Toggle rows:
  - "Share anonymous usage data" toggle + explanation
  - "Allow peer comparison" toggle + "Your data is always anonymous"
  - "Visible to counselor" toggle + "Let your school counselor see your progress"
  - "Visible to parent" toggle + "Let connected parents see your dashboard"
- Action rows:
  - "Download My Data" → Data Export screen
  - "Delete My Account" → Confirmation flow (red)
- "Privacy Policy" link
- "FERPA Rights" link

### L6. LANGUAGE PREFERENCES
**Layout: Centered selection (max-width 400pt)**
- "Language" header
- Language options (radio list):
  - English (default) ✓
  - Español (Spanish)
  - Kreyòl Ayisyen (Haitian Creole)
- "More languages coming soon" note
- "Save" button

### L7. HELP & SUPPORT
**Layout: Centered card list (max-width 600pt)**
- "Help & Support" header
- **FAQ section:** Expandable accordion items:
  - "How does the match score work?"
  - "Is my data safe?"
  - "How do I connect with my counselor?"
  - "Can my parent see my essays?"
  - etc.
- **Contact section:**
  - "Email Support" button
  - "Report a Bug" button
  - "Feature Request" button
- **Resources:**
  - "User Guide" link
  - "Video Tutorials" link
- App version at bottom

### L8. LEGAL / ABOUT
**Layout: Centered (max-width 600pt)**
- "About Ladder" header
- App icon + version number + build number
- Links (tappable rows):
  - Terms of Service
  - Privacy Policy
  - FERPA Notice
  - COPPA Compliance
  - Accessibility Statement
  - Open Source Licenses
- "Made with ❤️ for students everywhere"

---

## SECTION M: REPORTS & EXPORT (6 screens)

### M1. PDF PORTFOLIO PREVIEW + EXPORT
**Layout: Preview + controls**
Left (60%):
- PDF preview: Scrollable document mockup:
  - Ladder logo header
  - Student name + school + grade + graduation year
  - Sections:
    - Academic Summary (GPA chart, courses)
    - Activities & Leadership
    - Applications & Decisions
    - Test Scores
    - Service Hours
    - Awards & Honors

Right (40%):
- **Include Sections** toggles:
  - Academic Summary (ON/OFF)
  - Activities (ON/OFF)
  - Applications (ON/OFF)
  - Test History (ON/OFF)
  - Service Hours (ON/OFF)
  - Essays (ON/OFF)
  - Awards (ON/OFF)
- **Accent color:** Color picker (defaults to primary green)
- "Export as PDF" accent button
- "Share with Counselor" secondary button
- "Print" button

### M2. RESUME BUILDER
**Layout: Editor + live preview split**
Left (50%):
- Collapsible form sections:
  - **Contact Info:** Name, email, phone, address
  - **Education:** School, GPA, graduation, relevant courses
  - **Experience:** Add entries (role, organization, dates, bullet points)
  - **Skills:** Tag chips with add
  - **Activities:** Select from tracked activities
  - **Awards & Honors:** Add entries
  - **Service:** Auto-populated from service hours log
- Drag sections to reorder
- "Add Section" button for custom sections

Right (50%):
- Live resume preview in professional template
- Template selector: Classic | Modern | Academic
- Updates in real-time as user edits
- "Download PDF" accent button
- "Print" button

### M3. ALTERNATIVE PATHS GUIDE
**Layout: Card grid + detail**
- "Explore All Paths" header
- "Not everyone takes the traditional 4-year route — and that's okay" subtitle
- Path cards in 2x2 grid:
  1. **Community College** — Building icon, "Start local, transfer anywhere", cost comparison
  2. **Trade School** — Wrench icon, "Skilled careers in 1-2 years", salary data
  3. **Military** — Shield icon, "Serve and earn education benefits", GI Bill info
  4. **Gap Year** — Globe icon, "Travel, work, or volunteer first", program examples
- Tap card → full detail view:
  - Description, pros/cons table, typical timeline, financial comparison vs 4-year, application process, success stories, resources list
  - "Save to Profile" button if interested

### M4. INTERNSHIP GUIDE
**Layout: Two-column**
Left (55%):
- "Finding Internships" header
- Guide sections (expandable cards):
  - "When to Start Looking" (by grade level)
  - "Where to Find Internships" (websites, school board, cold outreach)
  - "How to Apply" (resume, cover letter, follow-up)
  - "Interview Tips" (link to Interview Prep)
  - "Making the Most of It" (networking, skills)
- Resource links per section

Right (45%):
- "Your Internship Tracker" — linked to Research & Internship Tracker
- Quick stats: Applications sent, interviews, offers
- Upcoming deadlines
- "Add Internship" button

### M5. IMPACT REPORT (Student)
**Layout: Dashboard**
- "Your Ladder Journey" header
- Stats row: Days on Ladder, Tasks Completed, Colleges Researched, Essays Written, Hours Studied
- Journey timeline: Key milestones (Joined → First College Saved → Quiz Completed → First Application → Accepted!)
- Growth charts: GPA trend, SAT improvement, activities added over time
- "Share Your Story" button (generates shareable graphic)
- "Download Report" button

### M6. SOCIAL MEDIA SHARE TEMPLATES
**Layout: Template selector**
- "Share Your Achievement" header
- Template options (horizontal scroll):
  - "I got accepted to [College]!" celebration card
  - "My college journey by the numbers" stats card
  - "Decision day!" announcement card
  - "Committed to [College]!" commitment card
- Template preview (live):
  - Ladder-branded card with student's data filled in
  - College colors (if available)
  - Editable caption text
- "Download Image" button
- "Share to..." buttons (system share sheet)

---

## SECTION N: PARENT SCREENS (6 screens)

### N1. PARENT DASHBOARD (Read-Only)
**Layout: Overview grid**
- Top: Child switcher tabs (if multiple children): [Child 1 avatar+name] | [Child 2 avatar+name]
- Stats row (4 cards): Schools Applied, Acceptances, Total Aid Awarded, Upcoming Deadlines

Two columns below:
Left (55%):
- **College Application Status** list:
  - College name
  - Status badge (Applied, Accepted, Rejected, Waitlisted)
  - Deadline
  - Last updated date
- "View All Applications" link

Right (45%):
- **Financial Summary** card: Total cost estimates, total aid, estimated net cost
- **Upcoming Deadlines** timeline: Next 5 deadlines with college name + date
- **Checklist Progress** circular ring + "X of Y tasks complete"

Bottom: "Message [Student Name]" button + "Message Counselor" button

### N2. PARENT INVITE CODE ACCEPTANCE
(Same as A11 — Parent Onboarding / Invite Code Entry, from parent's perspective)

### N3. MULTI-CHILD SWITCHER
**Layout: Centered card (max-width 500pt)**
- "Your Children" header
- Child cards (vertical):
  - Avatar + student name + grade + school
  - Recent activity preview
  - "View Dashboard" button
- "Add Another Child" button with invite code entry
- Currently viewing indicator

### N4. PARENT-STUDENT/COUNSELOR MESSAGING
**Layout: Chat interface (same pattern as AI Chat)**
Left (280pt):
- Contact list:
  - Student name(s)
  - Counselor name (if connected)
  - Unread message badge

Right (remaining):
- Chat messages
- Input bar with text field + send button
- "This message will be visible to [recipient]" notice

### N5. PEER COMPARISON (Anonymous)
**Layout: Dashboard with charts**
- School selector dropdown at top
- "How does [Student] compare?" headline
- Three comparison panels (side by side):
  - GPA distribution: Bell curve with student's dot highlighted
  - SAT distribution: Bell curve with student's dot
  - Activities count: Bar chart with student's bar highlighted
- Aggregate stats: "School average GPA: X.XX, Your child: Y.YY"
- Strength/weakness summary card
- Privacy note: "All data is anonymous. No individual students are identifiable."

### N6. PARENT FINANCIAL OVERVIEW
**Layout: Single column (max-width 700pt)**
- "Financial Overview" header
- **Application Costs** card: App fees per school, total fees
- **Financial Aid Summary** per school:
  - School name
  - Aid awarded: Grants, scholarships, loans, work-study
  - Net cost
- **Total Comparison** table: All schools side by side (mini version of Financial Aid Comparison)
- "FAFSA Status" badge: Submitted ✓ / Not Yet
- "Scholarship Status" badge: X applied, Y awarded

---

## SECTION O: COUNSELOR SCREENS (13 screens)

### O1. COUNSELOR DASHBOARD / CASELOAD MANAGER
**Layout: Full data dashboard**

Top bar:
- "My Caseload" headline + student count
- Search bar + filter dropdown (Grade, Status, Urgency, Last Active)
- View toggle: Table | Card Grid
- "Bulk Actions" dropdown

Summary cards row:
- **At-Risk** (error color) — count
- **Needs Attention** (amber) — count
- **On Track** (primary/green) — count
- Total Applications Submitted — count

Main area (Table view):
- Student table:
  | ☐ | Student Name + Avatar | Grade | GPA | SAT | Apps (X/Y) | Next Deadline | Days Left | Status Badge | Actions |
  - Sortable columns
  - Select checkboxes for bulk actions
  - Status: Color-coded (At-Risk red, Needs Attention amber, On Track green)
  - Actions: View, Message, Flag (icon buttons)
  - Row tap → Student Detail

Card Grid view (alternative):
- Student cards in 3-column grid: Avatar, name, grade, GPA, status badge, quick actions

### O2. COUNSELOR STUDENT DETAIL VIEW
**Layout: Three-column**
Left (30%):
- Student card: Avatar (64pt), name, grade, school, GPA badge, SAT badge, status badge
- Quick stats: GPA, SAT, ACT, AP Count, Activities, Service Hours
- Alert banner (conditional): Red/amber with concern description

Center (40%):
- **College List** table: College name, match %, status badge, deadline
- **Academic Progress** chart: GPA trend line
- **Activities Summary:** Activity cards with hours + leadership
- **Essay Progress:** Status per college

Right (30%):
- **Upcoming Deadlines** timeline
- **Counselor Notes:** Private notes text area + "Add Note"
- **Schedule Approvals:** Pending class schedule with approve/deny
- Action buttons: "Send Message", "Flag for Review", "Schedule Meeting", "Generate Report"

### O3. CLASS SCHEDULE APPROVAL WORKFLOW
**Layout: Approval split**
Left (50%):
- Student name + grade header
- Requested schedule table:
  | Period | Course | Teacher | Room | AI Status |
  - AI status icons:
    - ✓ Green: Recommended (meets all criteria)
    - ⚠ Amber: Conflict (schedule overlap, workload concern)
    - ℹ Blue: Alternative available (better option exists)
    - ✗ Red: Not recommended (missing prerequisite, exceeds load)
  - Tap icon → detailed explanation

Right (50%):
- **AI Analysis:**
  - Rigor Level (1-5 bar)
  - Bright Futures alignment check
  - Career path alignment score
  - Prerequisite verification results
  - Workload assessment (manageable / heavy / excessive)
- **Conflicts** (if any): Description + suggested resolution
- Action buttons:
  - "Approve Schedule" (green/primary)
  - "Request Changes" (amber) → opens notes
  - "Schedule Meeting" (secondary)

### O4. GENERIC DEADLINE CALENDAR (Counselor Reference)
**Layout: Full calendar view**
- Month calendar grid showing major college deadlines (NOT student-specific)
- Color-coded by deadline type:
  - Early Decision: Purple
  - Early Action: Blue
  - Regular Decision: Green
  - Rolling: Amber
- Tap date → list of colleges with that deadline
- "This is a reference calendar — no student data shown" note
- Export to calendar button

### O5. COUNSELOR IMPACT REPORT
**Layout: Report dashboard**
- "Your Impact Report" headline
- **Executive Summary** card: Students served, applications completed, acceptance rate improvement, hours saved
- **Workload Metrics:** AI interactions, schedule approvals, messages sent, meetings held
- **Outcome Charts:**
  - Applications year-over-year (bar chart)
  - Acceptances year-over-year (bar chart)
  - Average acceptance rate trend (line chart)
- **Equity Outcomes:** First-gen acceptance rate, aid per student, diversity metrics
- **Bright Futures Projection:** Students qualifying %, projection
- **Testimonial Quotes** area: Student quotes in cards
- "Export as PDF" accent button + "Share with Admin" secondary button

### O6. COUNSELOR VERIFICATION FLOW
(Same as A16)

### O7. BULK STUDENT IMPORT (CSV Wizard)
**Layout: Step wizard (4 steps)**

Step indicator: Upload → Preview → Confirm → Credentials

**Step 1 — Upload:**
- Large drag-and-drop zone (dashed border, cloud upload icon)
- "Drop CSV file here" text
- "Browse Files" button
- Format guide: Expected columns (First Name, Last Name, DOB, Grade, Email)
- "Download Template" link

**Step 2 — Preview:**
- Data table:
  | First Name | Last Name | DOB | Grade | Auto-Generated Login ID | Auto-Generated Password | Status |
  - Login ID format: firstname.lastname.MMDD
  - Password format: Firstname.YY!
  - Status: ✓ Valid (green) or ✗ Error (red) with error description
- Summary: "X valid, Y errors"
- "Fix Errors" or "Skip Invalid" options

**Step 3 — Confirm:**
- Summary card: "Import X students into Grade Y"
- Sample credential cards preview (3-4)
- "Import Students" accent button

**Step 4 — Credentials:**
- Credential cards grid (2x3 per page):
  - Student name, Login ID, Temporary Password
  - QR code (app download link)
  - School name + Ladder logo
- "Print Cards" button + "Download PDF" button + "Email to Students" button

### O8. STUDENT AUTO-ID GENERATOR (Single Student)
**Layout: Centered form (max-width 500pt)**
- "Add Student" header
- Form fields:
  - First Name
  - Last Name
  - Date of Birth (date picker)
  - Grade dropdown
  - Email (optional)
- **Generated Credentials** preview card (live-updating):
  - Login ID: firstname.lastname.MMDD
  - Temporary Password: Firstname.YY!
- "Create Student Account" accent button
- "Print Credential Card" button (after creation)

### O9. COUNSELOR MESSAGING CENTER
**Layout: Chat master-detail (same pattern as AI Chat)**
Left (280pt):
- "Messages" header + unread badge
- Filter: All | Students | Parents | Staff
- Contact list:
  - Name + avatar
  - Last message preview + time
  - Unread badge
  - Status dot (online/offline)

Right (remaining):
- Chat conversation
- Input bar
- "This message is logged per school policy" notice
- Attachment button (for documents)

### O10. SCHOOL YEAR ROLLOVER MANAGEMENT
**Layout: Step wizard**
- "School Year Rollover" header
- "Promote students to next grade, archive graduates, reset checklists" description
- **Preview changes:**
  - Table: Current Grade → New Grade | Student Count | Action
  - Grade 9 → Grade 10: XX students — Promote
  - Grade 10 → Grade 11: XX students — Promote
  - Grade 11 → Grade 12: XX students — Promote
  - Grade 12 → Graduate: XX students — Archive
  - New Grade 9: No students (add via import)
- **What will be reset:** Checklist items, weekly tasks, seasonal features
- **What will be preserved:** GPA history, test scores, applications, essays
- "Execute Rollover" accent button (with "Are you sure?" confirmation)
- "Schedule for August 1" alternative button

### O11. COUNSELOR ANNOUNCEMENT COMPOSER
**Layout: Composer form**
- "New Announcement" header
- Audience selector: All Students | Grade 9 | Grade 10 | Grade 11 | Grade 12 | Custom
- Title field
- Message body (rich text: bold, italic, bullets, links)
- Attachment area
- Priority: Normal | Important | Urgent
- Schedule: Send now | Schedule for date/time
- Preview card showing how it will appear to students
- "Send" accent button

### O12. AT-RISK STUDENT ALERTS DASHBOARD
**Layout: Alert list + detail**
Left (45%):
- "At-Risk Students" header + count
- Alert cards:
  - Student name + avatar
  - Risk level badge (High, Medium)
  - Risk reason: "No activity in 14 days", "Missing 3 deadlines", "GPA dropped below 2.5"
  - Days since last activity
  - "Dismiss" swipe action

Right (55%):
- Selected student detail:
  - Full risk assessment
  - Activity timeline (showing inactivity gap)
  - Upcoming missed/at-risk deadlines
  - Suggested interventions (AI-generated)
  - "Send Check-In Message" button
  - "Flag for Meeting" button
  - "Dismiss Alert" button

### O13. COUNSELOR MARKETPLACE / PROFILE
**Layout: Two views**

**Browse view (for students/parents):**
- "Find a Counselor" header
- Search + filters (specialty, location, price range, rating)
- Counselor cards:
  - Photo, name, credentials
  - Specialty tags (College, Financial Aid, Athletic)
  - Rating (stars)
  - Price range
  - "View Profile" button
  - "Book Session" button

**Profile view:**
- Large photo + name + credentials
- Bio text
- Specialties (tag chips)
- Experience (years, students helped)
- Reviews list with ratings
- Availability calendar
- Pricing table
- "Book Session" accent button
- "Send Message" secondary button
- "Become an Ambassador" link (if not yet)

---

## SECTION P: SCHOOL ADMIN SCREENS (7 screens)

### P1. SCHOOL ADMIN DASHBOARD
**Layout: Metrics + charts grid**
Row 1 — Metric cards (4):
- Total Students (number + trend)
- College-Bound % (number + school benchmark)
- Applications Sent (total)
- Total Aid Secured ($amount)

Row 2:
- Left (60%): Acceptance rate by school type — bar chart (Ivy, State, HBCU, CC, Trade, etc.)
- Right (40%): Grade-level breakdown — donut/pie chart (9-12 with student counts)

Row 3:
- Left (50%): At-risk student alert list — mini table (name, grade, concern, action)
- Right (50%): Top college destinations — ranked list (college name, students accepted)

Bottom: "View All Students" + "View All Counselors" + "Download Report" buttons

### P2. CLASS CATALOG MANAGEMENT
**Layout: Table + form**
Left (55%):
- "Class Catalog" header + course count
- Upload area: "Upload CSV" + "Download Template"
- Course table:
  | Course Name | Department | Level (Regular/Honors/AP/DE) | Credits | Teacher | Periods | Capacity |
  - Editable cells
  - Add row / delete row
  - Sort by column

Right (45%):
- Selected course detail/edit form:
  - Course name, department dropdown, level, credits
  - Teacher assignment
  - Available periods
  - Prerequisites
  - Description
  - Capacity
  - "Save" + "Delete" buttons
- "Publish Catalog" button (makes available to students/counselors)

### P3. SCHOOL PROFILE MANAGEMENT
**Layout: Form (max-width 700pt)**
- "School Profile" header
- School logo upload
- School name, address, district
- Principal name, contact
- School type (Public, Private, Charter, Magnet)
- Enrollment count
- Student-teacher ratio
- Graduation rate
- College-going rate
- Available programs (tag chips: AP, IB, DE, CTE, etc.)
- Clubs & organizations (editable list)
- Key dates (semester start/end, finals, graduation)
- "Save Profile" button
- "View Public Profile" link

### P4. AMBASSADOR PROGRAM SIGNUP
**Layout: Centered marketing page**
- "Become a Ladder Ambassador" header
- Benefits list:
  - Free premium access for your school
  - Priority support
  - Impact report features
  - Professional development credits
- Requirements:
  - Active counselor or admin
  - 50+ students using Ladder
  - Quarterly feedback submission
- Signup form: Name, school, role, email, why you want to join
- "Apply" accent button

### P5. DATA EXPORT VIEW
**Layout: Centered card (max-width 600pt)**
- "Export School Data" header
- Export options (radio list):
  - Student roster (CSV)
  - Application data (CSV)
  - GPA/Academic data (CSV)
  - Full school report (PDF)
  - FERPA-compliant data package (ZIP)
- Date range selector
- Grade filter (or "All Grades")
- "Generate Export" button
- Processing indicator
- "Your export will be ready for download in X minutes"
- Download history list: Past exports with dates + download links

### P6. DPA (DATA PROCESSING AGREEMENT) MANAGEMENT
**Layout: Two-column**
Left (55%):
- "Data Processing Agreements" header
- DPA list:
  - Agreement name
  - Status (Active, Pending, Expired)
  - Signed date
  - Expiry date
  - Signatory
- "Upload New DPA" button

Right (45%):
- Selected DPA detail:
  - Document preview / PDF viewer
  - Status badge
  - Key terms summary
  - Signatures
  - "Renew" button (if expiring)
  - "Download" button

### P7. SCHOOL-WIDE ANNOUNCEMENT MANAGER
**Layout: List + composer (same pattern as O11 but with admin scope)**
- Additional features:
  - Audience: Entire school, specific grades, counselors only, parents only
  - Analytics: Sent count, read count, click rate per announcement
  - Past announcements list with performance metrics

---

## SECTION Q: DISTRICT ADMIN SCREENS (4 screens)

### Q1. DISTRICT ANALYTICS DASHBOARD
**Layout: Executive dashboard**
Top: District name + metric row (Schools, Students, College-Bound %, Total Aid)

Main:
- **School Comparison Table** (full width):
  | School Name | Principal | Students | Avg GPA | Avg SAT | College-Bound % | Acceptance Rate | At-Risk Count |
  - Sortable, filterable
  - Click row → drills into school
- **Equity Metrics** (below, two columns):
  - Left: Cards (First-Gen Rate, Free Lunch %, SAT Access Gap, Bright Futures Rate)
  - Right: Bright Futures projection chart (line chart, projected vs target)

Bottom: "Export District Report" button + "Schedule Monthly Report" button

### Q2. SCHOOL COMPARISON VIEW
**Layout: Side-by-side comparison**
- School selector: Pick 2-3 schools to compare
- Comparison table:
  - Metrics: Enrollment, Avg GPA, Avg SAT, College-Bound %, Acceptance Rate, Aid per Student, At-Risk %, Counselor-to-Student Ratio
  - Bar chart comparisons per metric
  - Highlighted: Best performer per row (green), needs attention (red)
- "Export Comparison" button

### Q3. EQUITY METRICS DASHBOARD
**Layout: Analytics dashboard**
- "Equity & Access" header
- Metric cards: First-Gen Rate, Free/Reduced Lunch %, SAT Access Gap, AP Access Rate, College Enrollment Gap
- Demographic breakdown charts:
  - College-going rate by demographic
  - Aid distribution by income level
  - AP participation by demographic
- Year-over-year trend charts per metric
- "Equity Action Plan" link/section: AI-generated suggestions for improvement
- "Export Report" button

### Q4. DISTRICT REPORT GENERATOR
**Layout: Wizard**
- "Generate Report" header
- Report type selector: Monthly Summary | Quarterly Review | Annual Report | Custom
- Sections to include (checkboxes): Enrollment, Academics, College Outcomes, Equity, Financial, At-Risk, Bright Futures
- Date range
- Schools to include (multi-select)
- Format: PDF | PPTX | CSV Data Dump
- "Generate" accent button
- Processing indicator
- Download when ready

---

## SECTION R: SPECIAL / UTILITY SCREENS (5 screens)

### R1. FIRST 100 DAYS TRACKER
**Layout: Timeline + checklist split**
Left (55%):
- Vertical timeline (May → August) with milestone nodes:
  - Accept offer ✓
  - Submit deposit ✓
  - Housing application ◎
  - Orientation signup ○
  - Course registration ○
  - Health forms ○
  - Move-in day ○
- School-specific tips inline at relevant milestones

Right (45%):
- Countdown ring (large): "X days to move-in"
- "This Week's Tasks" checklist (5-7 items)
- "Packing Checklist" (collapsible categories: Documents, Room, Tech, Clothing, Personal)
- Checkboxes with completion tracking
- "Share with Parent" button

### R2. GLOBAL SEARCH / COMMAND PALETTE
**Layout: Overlay modal (centered, max-width 600pt)**
- Large search input at top
- "Search colleges, tasks, essays, scholarships..." placeholder
- Results grouped by type:
  - **Colleges:** Name, match %
  - **Tasks:** Title, status
  - **Essays:** Title, college
  - **Scholarships:** Name, amount
  - **Settings:** Setting name
- Recent searches section
- Keyboard shortcut indicators (for hardware keyboard users)

### R3. OFFLINE MODE / SYNC STATUS
**Layout: Banner + detail view**
- Banner (top of screen when offline): "You're offline. Changes will sync when connected." (amber background)
- Sync status detail view (from settings):
  - Last synced: Date + time
  - Pending changes: X items
  - List of pending items with status (queued, syncing, failed)
  - "Sync Now" button (when online)
  - "Resolve Conflicts" section (if any)

### R4. CONTENT MODERATION DASHBOARD (Admin/Counselor)
**Layout: Report queue**
- "Content Reports" header + pending count
- Report list:
  - Reporter name, date
  - Content type (Message, Essay, Profile)
  - Content preview
  - Severity badge (Low, Medium, High, Critical)
  - Status (Pending, Reviewed, Resolved)
- Selected report detail:
  - Full content view
  - Reporter info
  - AI moderation assessment (AWS Comprehend results)
  - Actions: Approve, Remove Content, Warn User, Suspend User
- Audit trail: Actions taken with timestamps

### R5. DATA DELETION REQUEST (GDPR/Privacy)
**Layout: Centered card (max-width 500pt)**
- "Delete My Data" header
- Warning icon (red)
- "This action is permanent and cannot be undone" message
- What will be deleted: All profile data, essays, applications, chat history, scores
- What will NOT be deleted: Anonymized aggregate data, school records (FERPA)
- Confirmation: Type "DELETE" in text field
- "Delete Everything" destructive button (red)
- "Cancel" link
- "Download My Data First" link (goes to export)

---

## iPad-SPECIFIC DESIGN NOTES

1. **Touch targets:** Minimum 44pt for all interactive elements (Apple HIG)
2. **Press states:** Scale 0.95 + opacity 0.8 (no hover — iPad is touch-first)
3. **Multitasking:** Support Split View (1/3, 1/2, 2/3 widths) and Slide Over. At 1/3 width, collapse to single-column (iPhone-like) layout.
4. **Keyboard:** Hardware keyboard: Tab between fields, Return to submit, ⌘K for search
5. **Drag and drop:** Kanban cards, college list reorder, file uploads, resume section reorder
6. **Apple Pencil:** Annotation on essay previews, highlighting on transcript review (nice-to-have)
7. **Stage Manager:** Fluid resizing on iPadOS 16+, adapt layout at width breakpoints
8. **Orientation:** Landscape = sidebar always visible. Portrait = sidebar collapses to overlay.
9. **No bottom tab bar.** Sidebar navigation exclusively. The 5 iPhone tabs → sidebar sections with sub-items.
10. **Content width:** Max-width containers (600-800pt) for single-column views, multi-column for data-heavy screens.
11. **Transitions:** Slide transitions for navigation, fade for modals, spring animations for interactive elements.
12. **Empty states:** Every list/table screen has a designed empty state with illustration, message, and call-to-action.

---

## DESIGN DELIVERABLES

Design all **132 screens** listed above as high-fidelity iPad mockups in **landscape orientation** (primary) with portrait adaptation notes. Use the exact Evergreen Ascent color tokens, Noto Serif + Manrope typography, and spacing system specified. Every screen should feel like a premium, purpose-built iPad experience — not a stretched iPhone app.

The screens are organized in 18 sections (A through R). Please maintain this organization in your designs.
