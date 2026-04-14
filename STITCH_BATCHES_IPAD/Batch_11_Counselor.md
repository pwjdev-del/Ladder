You are designing iPad screens for Ladder, a college preparation app. This is batch 11 of 12. Use these exact design tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (Display Large 56pt Bold, Display Medium 45pt, Display Small 36pt, Headline Large 32pt Bold, Headline Medium 28pt SemiBold, Headline Small 24pt Medium). Body/Labels = Manrope (Title Large 22pt Bold, Title Medium 16pt SemiBold, Title Small 14pt SemiBold, Body Large 16pt, Body Medium 14pt, Body Small 12pt, Label Large 14pt Bold, Label Medium 12pt Bold, Label Small 10pt SemiBold). Headlines editorial tracking (-0.5). Labels wide tracking (+2.0).

**Spacing (8pt grid):** xxs 2, xs 4, sm 8, md 16, lg 24, xl 32, xxl 48, xxxl 64, xxxxl 80

**Corner Radius:** sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 40, pill 9999

**Shadows:** Ambient (cards): rgba(31,28,20,0.06) blur 20 y4. Floating: same blur 30 y10. Glow: rgba(201,242,77,0.30) blur 15. Primary Glow: rgba(66,96,63,0.15) blur 20 y4.

**Components:** PrimaryBtn = gradient primary→primaryContainer pill white scale 0.95. AccentBtn = lime bg dark text glow. Cards = SurfaceContainerLow XL radius ambient shadow. Chips = SurfaceContainerHigh pill LabelSmall. TextFields = SurfaceContainerLowest outline border LG radius primary focus. No dividers. Min 44pt touch.

## iPad Navigation
Collapsible sidebar (280pt) replaces tab bar. 9 sections (Home/Tasks/Colleges/Applications/Advisor/Financial/Career/Housing/Reports) with sub-items. Selected = primary bg pill. Portrait = sidebar overlay. Detail area max 800pt single-column, full width for multi-column.

---

# Batch 11: Counselor — 13 Screens

---

## Screen O1: Caseload Manager

**Layout:** Full-width dashboard. Sidebar shows counselor-specific navigation.

- **Header Row:** "My Caseload" Headline Large. Student count badge: "(247 students)" Label Medium (On Surface Variant). Search field (TextField, 280pt width, magnifying glass icon). Filter dropdown ("All Grades" / "Grade 9" / "Grade 10" / "Grade 11" / "Grade 12"). View toggle: two icon buttons — table icon / grid icon (selected = Primary fill, unselected = Outline). "Bulk Actions" dropdown button (outline, Primary border, pill) — options: Message Selected, Export Selected, Flag Selected.

- **Summary Cards Row:** 4 cards (SurfaceContainerLow, XL radius, ambient shadow, equal width):
  - "At-Risk" — count (Title Large bold, Error #ba1a1a). Red left border 4pt. Exclamation icon.
  - "Needs Attention" — count (Title Large bold, amber #b8860b). Amber left border. Warning icon.
  - "On Track" — count (Title Large bold, Primary #42603f). Green left border. Check icon.
  - "Apps Submitted" — count (Title Large bold, Accent Lime). Lime left border. Send icon.

- **Table View (default):** Full-width table. Header row (SurfaceContainerHigh bg, Label Large text, wide tracking, sortable — tap header to sort, arrow indicator).
  - Columns: ☐ (checkbox, 40pt) | Student (avatar 32pt + name, flex) | Grade (60pt) | GPA (60pt) | SAT (60pt) | Apps X/Y (80pt) | Next Deadline (120pt) | Days Left (70pt) | Status Badge (90pt) | Actions (80pt).
  - Row styling: alternating Surface / SurfaceContainerLow. 48pt row height.
  - Status badges: "At-Risk" red chip, "Attention" amber chip, "On Track" green chip, "Inactive" outline chip.
  - Actions column: three-dot menu → View, Message, Flag.
  - Checkbox column: select individual or "Select All" header checkbox. Selected rows = Primary tint bg. Bulk action bar appears at bottom when items selected.

- **Card Grid View (alternative):** 3-column grid. Each student card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Avatar (48pt) + name (Title Small bold) + grade (Body Small). GPA + SAT (Body Medium). Status badge. "Apps: 3/8" progress bar. Next deadline. "View" link.

---

## Screen O2: Student Detail

**Layout:** Three-column — Left 30%, Center 40%, Right 30%.

**Left Column (30%) — Student Card:**
- Avatar (64pt circle, Primary border 2pt). Name (Title Large bold). Grade (Body Medium). GPA: "3.8 W / 3.5 UW" Title Small. SAT: "1420" Title Small. Status badge: "On Track" green chip or "At-Risk" red chip.
- **Quick Stats:** Mini stat list: "Activities: 6", "Service Hours: 120", "Essays: 8/12", "Colleges: 8". Body Medium, icon + text per row.
- **Alert Banner (if applicable):** Red-tinted card (Error Container bg, Error text). "Inactive for 14 days" or "Missed 2 deadlines". Exclamation icon.

**Center Column (40%) — Academic Detail:**
- **College List Table:** "Applications" Title Medium. Table: College | Type (ED/EA/RD) chip | Status badge | Deadline. Compact rows (40pt). Sortable.
- **GPA Trend Chart:** Small line chart (200pt height). Semester labels. Primary line. Title Small header.
- **Activities Summary:** "Activities" Title Medium. Compact list: activity name + role + years. 5–6 items max with "View All" link.
- **Essay Progress:** "Essays" Title Medium. Horizontal progress bar (Primary fill). "8 of 12 complete" Label Medium. Per-college mini bars below.

**Right Column (30%) — Actions & Notes:**
- **Upcoming Deadlines:** "Deadlines" Title Medium. Vertical mini timeline. Next 5 deadlines: date + task + school. Color-coded by urgency (red <7 days, amber <30, green >30).
- **Counselor Notes:** "Notes" Title Medium. Scrollable note list. Each note: date (Label Small) + text (Body Small). "Add Note" button at top (outline, plus icon, Primary border, 36pt height). Tap opens text area overlay.
- **Schedule Approvals:** "Pending Approvals" Title Medium. If any schedule needs approval, shows mini card with "Review" link → navigates to O3.
- **Action Buttons:** Vertical stack:
  - "Message" PrimaryBtn (pill, 44pt, full width). Chat icon.
  - "Flag" Outline button (amber border, 44pt). Flag icon.
  - "Schedule Meeting" Outline button (Primary border, 44pt). Calendar icon.
  - "Generate Report" Outline button (Primary border, 44pt). Download icon.

---

## Screen O3: Class Approval

**Layout:** Two-panel split — Left 50%, Right 50%.

**Left Panel (50%) — Schedule:**
- **Student Header:** Avatar (48pt) + name (Title Medium) + grade + GPA. Compact row.
- **Schedule Table:** Full-width. Columns: Period (50pt) | Course (flex) | Teacher (100pt) | Room (60pt) | AI Status (50pt).
  - Header row: SurfaceContainerHigh bg, Label Large.
  - AI Status icons per row: ✓ green check (approved/good), ⚠ amber warning (concern), info-circle blue (informational), ✗ red X (conflict/issue).
  - Tap any AI status icon → popover tooltip (SurfaceContainerLowest, md radius, floating shadow). Shows AI explanation: "This course aligns well with the student's Pre-Med path" or "Prereq not met: requires Algebra 2." Body Small.
  - Row heights 44pt min.

**Right Panel (50%) — AI Analysis:**
- **Analysis Card:** SurfaceContainerLow, XL radius, ambient shadow.
  - **Rigor Assessment:** "Academic Rigor" Title Medium. 1–5 rating with filled circles (Primary). "4/5 — Strong schedule" Body Medium.
  - **Bright Futures Check:** "Bright Futures Compliance" Title Medium. Checklist: required courses ✓/✗. Overall: "Meets requirements" green or "Missing: X" amber.
  - **Career Alignment:** "Career Path Alignment" Title Medium. Ring chart (80pt) + percentage. "Pre-Med alignment: 85%".
  - **Prerequisites:** "Prerequisite Check" Title Medium. All prereqs met ✓ or flagged ⚠ with explanation.
  - **Workload Assessment:** "Workload" Title Medium. Bar visualization (low/moderate/heavy/overloaded). Current position indicated.

- **Conflicts & Resolutions:** If any conflicts exist. Card with red left border. Each conflict: description + "Suggested Resolution" AI recommendation. Body Medium.

- **Action Buttons:** Three buttons in a row:
  - "Approve" — Green bg (#42603f), white text, pill, 48pt. Check icon.
  - "Request Changes" — Amber bg (#b8860b), white text, pill, 48pt. Edit icon.
  - "Schedule Meeting" — Outline (Primary border), pill, 44pt. Calendar icon.

---

## Screen O4: Generic Deadline Calendar

**Layout:** Full-width calendar. Month grid view.

- **Header:** "College Deadlines" Headline Large. Month navigation (< Month Year >). "Reference only — not student-specific" Body Small (Outline, italic). "Export" outline button (download icon, pill).

- **Month Grid:** 7-column (Sun–Sat), 5–6 rows. Day cells (min 80pt x 80pt):
  - Day number (Body Medium, top-left).
  - Deadline indicators: small colored dots (8pt) stacked vertically:
    - ED = purple dot (#6b3d99).
    - EA = blue dot (#3d6b99).
    - RD = green dot (Primary #42603f).
    - Rolling = amber dot (#b8860b).
  - Multiple deadlines on one day = multiple dots.
  - Today: Primary circle behind day number.
  - Tap day → popover (SurfaceContainerLowest, LG radius, floating shadow): list of colleges with deadlines that day. Each: college name, deadline type chip, "View College" link.

- **Legend:** Below calendar. Horizontal row of legend items: purple dot + "Early Decision", blue dot + "Early Action", green dot + "Regular Decision", amber dot + "Rolling". Body Small.

- **"Reference Only" Note:** Bottom banner (SurfaceContainerHigh, LG radius). Info icon + "This calendar shows general college deadlines. For your personalized deadlines, visit your Application Tracker." Body Small.

---

## Screen O5: Counselor Impact Report

**Layout:** Dashboard. Full width.

- **Header:** "Your Impact" Headline Large (Noto Serif). School year selector dropdown.

- **Executive Summary Card:** Featured card (SurfaceContainerLow, XL radius, Accent Lime top border 4pt). Four stats inline: "Students: 247" | "Apps Facilitated: 1,284" | "Acceptance Rate: 78%" | "Hours Saved: ~340". Title Medium values, Body Small labels.

- **Workload Metrics Card:** "Workload" Title Medium. Stats: avg students per counselor, apps reviewed/week, meetings/week. Compared to national average. Body Medium.

- **Outcome Charts (2-column, 16pt gap):**
  - **Applications & Acceptances YoY:** Grouped bar chart. X-axis = years. Two bars per year: Applications (Primary) and Acceptances (Accent Lime). Title Small header.
  - **Acceptance Rate Trend:** Line chart. Primary line. Year labels. Target dashed line.

- **Equity Outcomes Card:** "Equity Metrics" Title Medium. Stats: First-gen acceptance rate, free/reduced lunch college-bound %, underrepresented minority outcomes. Compared to school averages. Green/amber indicators.

- **Bright Futures Projection:** "Bright Futures" Title Medium. Bar chart: eligible students by grade. Projected vs actual. Primary = actual, Outline Variant dashed = projected.

- **Testimonials Section:** 1–2 quote cards (SurfaceContainerLow, XL radius, quote icon). Student/parent quote + attribution. Body Medium italic.

- **Action Buttons:**
  - "Export PDF" AccentBtn (lime bg, glow, pill, 48pt). Download icon.
  - "Share with Admin" PrimaryBtn (gradient pill, 48pt). Share icon.

---

## Screen O6: Verification Flow

**Layout:** Multi-step wizard, centered (600pt max width).

- **Step Indicator:** Horizontal step dots at top. Step 1: Identity, Step 2: Credentials, Step 3: Review. Completed = Primary fill. Current = Primary outline + pulse. Upcoming = Outline Variant.

- **Step 1 — Identity Verification:**
  - "Verify Your Identity" Headline Medium, centered.
  - Form: Full Name (TextField), School Name (autocomplete TextField), Role (dropdown: Counselor / Admin / Teacher), School Email (TextField — must be .edu or verified school domain). School District (TextField).
  - "Next" PrimaryBtn (pill, 48pt, full width).

- **Step 2 — Credential Upload:**
  - "Upload Credentials" Headline Medium, centered.
  - Upload zones (2): "School ID / Badge" and "Professional License or Certificate". Each: dashed-border zone (Outline dashed 2pt, XL radius, 120pt height). Camera + file icons. "Upload" label.
  - Uploaded file shows thumbnail + filename + "Remove" link.
  - "Next" PrimaryBtn.

- **Step 3 — Pending Review:**
  - "Under Review" Headline Medium, centered. Clock icon (64pt, Primary, centered).
  - "Your verification is being reviewed. This typically takes 1–2 business days." Body Large, centered.
  - "You'll receive an email at [email] when approved." Body Medium.
  - Status card (SurfaceContainerLow, XL radius): "Status: Pending Review" amber chip. Submitted date. Estimated review date.
  - "Return to Dashboard" PrimaryBtn (pill, 48pt).

---

## Screen O7: Bulk Student Import

**Layout:** 4-step wizard, full width.

- **Step Indicator:** Horizontal step bar. Steps: Upload, Preview, Confirm, Credentials. Same styling as O6 steps.

- **Step 1 — Upload:**
  - "Import Students" Headline Large, centered.
  - Drag-and-drop zone (Outline dashed 2pt, XL radius, 200pt height, centered 500pt width). Cloud-upload icon + "Drag CSV file here" Title Small + "or" + "Browse Files" outline button.
  - "Download Template" link (Primary text, download icon). Downloads sample CSV.

- **Step 2 — Preview:**
  - "Review Import" Headline Large.
  - Preview table (full width): Columns: First Name | Last Name | DOB | Grade | Auto-Login | Auto-Password | Status.
  - Status column: ✓ green (valid) or ✗ red (error — duplicate, missing field, invalid format). Error tooltip on hover/tap.
  - Error rows: red tint bg. Summary above table: "248 valid, 3 errors" with link to jump to errors.
  - "Fix Errors" amber button if errors exist. "Next" PrimaryBtn when clean.

- **Step 3 — Confirm & Import:**
  - "Confirm Import" Headline Large. Summary card: "248 students will be imported" Title Medium. Grade breakdown: "Grade 9: 65, Grade 10: 62, Grade 11: 60, Grade 12: 61" Body Medium.
  - Sample credential card preview (SurfaceContainerLow, XL radius): shows what a printed card will look like.
  - "Import" AccentBtn (lime bg, glow, 48pt, full width). "Cancel" outline button.
  - Processing state: progress bar + "Importing... 142/248" animation.

- **Step 4 — Credential Cards:**
  - "Student Credentials" Headline Large.
  - Card grid (2 x 3 per page). Each credential card (SurfaceContainerLow, XL radius, 16pt padding, 200pt x 140pt):
    - School logo placeholder (24pt, top-left). Student name (Title Small bold). Login ID (Body Medium, monospace). Password (Body Medium, monospace). QR code placeholder (48pt square, bottom-right).
  - Action buttons: "Print All" AccentBtn (printer icon, lime bg, 48pt). "Download PDF" PrimaryBtn (download icon, pill, 48pt). "Email to Students" Outline button (mail icon, pill, 44pt).

---

## Screen O8: Auto-ID Generator

**Layout:** Centered form (500pt max width).

- **Header:** "Create Student Account" Headline Large, centered.

- **Input Form:** Vertical stack of TextFields (SurfaceContainerLowest, Outline border, LG radius, Primary focus):
  - "First Name" — required.
  - "Last Name" — required.
  - "Date of Birth" — date picker (MM/DD/YYYY).
  - "Grade" — dropdown (9/10/11/12).
  - "Email (optional)" — TextField.

- **Live Credential Preview Card:** SurfaceContainerLow, XL radius, ambient shadow, xxl padding. Updates in real-time as form is filled.
  - School logo placeholder (32pt, top-left). "Student Credential" Label Medium header.
  - **Login ID:** "firstname.lastname.MMDD" displayed in monospace Body Large. Primary color. E.g., "sarah.johnson.0315".
  - **Password:** "Firstname.YY!" displayed in monospace Body Large. Primary color. E.g., "Sarah.08!".
  - Dashed line separator.
  - QR code placeholder (64pt square). "Scan to log in" Body Small.

- **Action Buttons:**
  - "Create Account" AccentBtn (lime bg, glow, 48pt, full width). Check icon.
  - "Print Card" Outline button (printer icon, Primary border, pill, 44pt, full width).

---

## Screen O9: Messaging Center

**Layout:** Chat master-detail — Left 280pt + Right conversation area.

**Left Sidebar (280pt) — Contacts:**
- Header: "Messages" Title Large. Unread badge (Primary circle, white count).
- **Filter Chips:** All | Students | Parents | Staff. Pill chips, horizontal scroll.
- **Contact List:** Vertical scroll. Each row (56pt height, 12pt padding):
  - Avatar (40pt circle). Name (Title Small). Role chip mini (Body Small, e.g., "Student", "Parent"). Last message preview (Body Small, Outline, 1 line truncated). Time (Label Small, right). Unread: bold name + blue dot (8pt).
  - Selected: SurfaceContainerHigh bg.

**Right Area — Conversation:**
- **Conversation Header:** Name (Title Medium) + role chip. Status dot (green = online).
- **"Logged per policy" Notice:** Top banner (SurfaceContainerHigh, sm radius). Shield icon + "All messages are logged per school communication policy." Body Small (Outline). Persistent, not dismissible.
- **Messages:** Vertical scroll. Sent (right-aligned, Primary Container bg, On Primary text, LG radius). Received (left-aligned, SurfaceContainerHigh bg, On Surface text, LG radius). Timestamps below clusters. Date separators.
- **Attachment Support:** Attached files appear as mini cards in messages: file icon + name + size + "Download" link.
- **Input Area:** Bottom. TextField (full width) + attachment button (paperclip, 44pt) + send button (PrimaryBtn circle, 44pt, arrow-up). Placeholder: "Type a message..."

---

## Screen O10: School Year Rollover

**Layout:** Wizard — centered (700pt max width).

- **Header:** "School Year Rollover" Headline Large. Year: "2025–2026 → 2026–2027" Title Medium (On Surface Variant).

- **Preview Table:** Full-width. Columns: Current Grade | New Grade | Student Count | Action.
  - "Grade 9 → Grade 10" | "65 students" | "Promote" green chip.
  - "Grade 10 → Grade 11" | "62 students" | "Promote" green chip.
  - "Grade 11 → Grade 12" | "60 students" | "Promote" green chip.
  - "Grade 12 → Graduate" | "61 students" | "Archive" amber chip.
  Each row: SurfaceContainerLow bg, 48pt height.

- **What Changes Section:** Two-column card:
  - **"What's Reset"** (left, amber left border): Grade level, task lists, semester data, schedule. Bulleted Body Medium.
  - **"What's Preserved"** (right, green left border): GPA history, test scores, college list, essays, activities, profile. Bulleted Body Medium.

- **Action Buttons:**
  - "Execute Rollover Now" AccentBtn (lime bg, glow, 48pt, full width). Warning icon. Opens confirmation modal.
  - "Schedule for August 1" PrimaryBtn (gradient pill, 48pt, full width). Calendar icon.
  - **Confirmation Modal (if Execute Now):** Overlay (dark scrim). Card (SurfaceContainerLowest, XL radius, xxxl padding). "Are you sure?" Headline Small. "This will promote all students and archive graduates. This cannot be undone." Body Medium. "Confirm" red button + "Cancel" outline.

---

## Screen O11: Announcement Composer

**Layout:** Centered form (600pt max width).

- **Header:** "New Announcement" Headline Large.

- **Audience Selector:** "Send To" Label Medium. Segmented control: "All Students" | "Grade 9" | "Grade 10" | "Grade 11" | "Grade 12" | "Custom". Selected = Primary bg + white text. "Custom" opens multi-select dropdown.

- **Title Field:** TextField (full width). "Announcement Title" placeholder. Title Medium input.

- **Rich Text Body:** Large text area (SurfaceContainerLowest, Outline border, LG radius, 200pt min height). Basic formatting toolbar above: Bold, Italic, Bullet List, Link. Body Large input.

- **Attachment:** "Attach File" outline button (paperclip icon, Primary border, LG radius, 44pt). Attached file shows as chip with X remove.

- **Priority Selector:** "Priority" Label Medium. Three radio cards (horizontal, 120pt each):
  - "Normal" — blue dot + label. Default.
  - "Important" — amber dot + label.
  - "Urgent" — red dot + label + "Sends push notification" Body Small.
  Selected = Primary border + check.

- **Schedule:** "Send" Label Medium. Two radio options: "Now" | "Schedule for Later" (shows date+time picker when selected).

- **Preview Card:** "Preview" Title Medium. Card (SurfaceContainerLow, XL radius) showing how the announcement will appear to students. Rendered with actual content.

- **"Send" Button:** AccentBtn (lime bg, glow, 48pt, full width). Send icon. "Send Announcement".

---

## Screen O12: At-Risk Alerts

**Layout:** Two-panel — Left 45%, Right 55%.

**Left Panel (45%) — Alert List:**
- Header: "At-Risk Alerts" Headline Large. Count: "(8 alerts)" Label Medium (Error color).
- **Alert Cards:** Vertical scroll. Each card (SurfaceContainerLow, XL radius, 12pt padding):
  - Student avatar (40pt) + name (Title Small bold).
  - Risk level badge: "High" red chip or "Medium" amber chip.
  - Reason: "Inactive 21 days" or "Missed 3 deadlines" Body Medium.
  - "Days Inactive: 21" Label Small (Error).
  - Swipe left to dismiss (reveals green "Dismiss" action). Or tap X button (44pt).
  - Selected card: Primary left border 4pt.

**Right Panel (55%) — Detail:**
- **Student Header:** Avatar (56pt) + name (Title Large) + grade + status badge.
- **Risk Assessment Card:** SurfaceContainerLow, XL radius, red left border 4pt. "Risk Level: High" Title Medium (Error). "Last active: 21 days ago. Missed 3 consecutive deadlines. GPA dropped 0.3 points." Body Medium.
- **Activity Timeline Gap:** Visual timeline showing activity over last 60 days. Bars per day (green = active, empty = inactive). Gap clearly visible.
- **Missed Deadlines:** List: deadline name + date + "Missed" red chip. 3–5 items.
- **AI Intervention Suggestions Card:** Sparkles icon. "Suggested Actions" Title Medium. Bulleted list:
  - "Send a check-in message — students who receive outreach within 7 days of inactivity are 3x more likely to re-engage."
  - "Schedule a brief meeting to discuss application timeline."
  - "Connect with parent/guardian."
  Body Medium.
- **Action Buttons:**
  - "Send Check-In" PrimaryBtn (gradient pill, 48pt). Chat icon.
  - "Flag for Meeting" Outline button (amber border, 44pt). Calendar icon.
  - "Dismiss Alert" Outline button (Outline border, 44pt). X icon.

---

## Screen O13: Counselor Marketplace

**Layout:** Browse view → Profile detail.

**Browse View:**
- Header: "Find a Counselor" Headline Large. Search field (TextField, magnifying glass icon).
- **Filter Row:** Chips: All | College Admissions | Financial Aid | Test Prep | Career | Special Needs. Selected = Primary bg + white. Sort dropdown: "Best Match" / "Rating" / "Price Low-High".

- **Counselor Cards (3-column grid, 16pt gap):** Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Photo placeholder (64pt circle, centered). Name (Title Medium bold). Credentials (Body Small, On Surface Variant). E.g., "M.Ed., 15 years experience".
  - Specialty tags: chips (SurfaceContainerHigh, pill). "AP Planning", "Ivy League", "Financial Aid".
  - Rating: 1–5 stars (Accent Lime filled, Outline Variant empty) + count "( 47 reviews)".
  - Price: "$75/session" Label Large (Primary).
  - Two buttons: "View Profile" PrimaryBtn small (pill, 36pt). "Book" AccentBtn small (pill, 36pt).

**Profile View (on "View Profile" tap — replaces browse or slides in):**
- Back arrow. Photo (96pt circle, Primary border 3pt). Name (Headline Medium). Credentials (Body Large).
- **Bio:** "About" Title Medium. 3–4 paragraphs Body Medium.
- **Specialties:** Chip wrap. E.g., "College Admissions", "Essay Review", "AP Course Selection", "Financial Aid".
- **Experience:** "Experience" Title Medium. Bullet list: years, schools, roles.
- **Reviews:** "Reviews" Title Medium. Star rating summary (large stars + count). 2–3 review cards: rating stars, quote text, reviewer initial + date.
- **Availability Calendar:** "Availability" Title Medium. Mini week view showing available time slots (green cells). Tappable to select.
- **Pricing:** "Pricing" Title Medium. "Single Session: $75" | "4-Pack: $260" | "Monthly: $200". Cards per tier.
- **Action Buttons:**
  - "Book Session" AccentBtn (lime bg, glow, 48pt, full width). Calendar-plus icon.
  - "Send Message" PrimaryBtn (gradient pill, 48pt, full width). Chat icon.
  - "Become an Ambassador" Outline button (star icon, Primary border, pill, 44pt, full width). For counselors who want to join.

---

**Deliverable:** Design all 13 screens. Batch 11 of 12.
