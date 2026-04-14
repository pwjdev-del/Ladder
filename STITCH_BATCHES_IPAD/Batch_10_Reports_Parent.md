You are designing iPad screens for Ladder, a college preparation app. This is batch 10 of 12. Use these exact design tokens.

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

# Batch 10: Reports + Parent — 12 Screens

---

## Screen M1: PDF Portfolio

**Layout:** Two-panel — Left 60%, Right 40%.

**Left Panel (60%) — PDF Preview:**
- **Preview Area:** Full-height scrollable PDF preview (SurfaceContainerLowest bg, md shadow inset effect, 16pt padding). Shows a rendered preview of the student portfolio document:
  - **Page 1:** Ladder logo (centered, 40pt). Student name (Headline Large). School + grade + year. Horizontal rule (Primary, 1pt).
  - **Academic Summary Section:** "Academic Summary" Title Medium. GPA table (Unweighted / Weighted / Trend). Class rank if available.
  - **Activities Section:** "Extracurricular Activities" Title Medium. Table: Activity | Role | Years | Hours/Week.
  - **Applications Section:** "College Applications" Title Medium. Table: College | Type | Status | Decision.
  - **Test Scores Section:** "Standardized Tests" Title Medium. SAT/ACT breakdown.
  - **Service Section:** "Community Service" Title Medium. Total hours + list.
  - **Awards Section:** "Honors & Awards" Title Medium. Bulleted list with year.
- Preview renders with clean typography matching the design system. Page breaks visible.

**Right Panel (40%) — Controls:**
- Header: "Customize Portfolio" Title Large.
- **Section Toggles:** Vertical list. Each row (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - Toggle switch (Primary when ON) + Section name (Title Small). Toggling off removes that section from the PDF preview in real time.
  - Sections: Academic Summary, Activities, Applications, Test Scores, Community Service, Awards, Personal Statement excerpt.
- **Accent Color Picker:** "Accent Color" Label Medium. Row of 5 color circles (32pt each, 8pt gap): Primary #42603f (default), Accent Lime #A1C621, Tertiary #725232, #3d6b99 blue, #6b3d99 purple. Selected = white checkmark + ring border.
- **Action Buttons:** Vertical stack, 12pt gap:
  - "Export PDF" AccentBtn (lime bg, glow, full width, 48pt). Download icon.
  - "Share with Counselor" PrimaryBtn (gradient pill, full width, 48pt). Share icon.
  - "Print" Outline button (Primary border, pill, full width, 44pt). Printer icon.

---

## Screen M2: Resume Builder

**Layout:** Two-panel — Left 50%, Right 50%.

**Left Panel (50%) — Editor:**
- Header: "Resume Builder" Headline Large.
- **Collapsible Form Sections:** Vertical accordion. Each section (SurfaceContainerLow, LG radius, 12pt padding):
  - Section header: Title Small (bold) + chevron (rotates on expand) + drag handle (6 dots icon, left side) for reorder. 44pt touch.
  - Expanded content: form fields per section.
  - **Contact:** Name, email, phone, address (all TextFields).
  - **Education:** School name, GPA, graduation date, relevant coursework (tag input).
  - **Experience:** Title, organization, dates, bullet points (add/remove).
  - **Skills:** Tag input chips — type and press enter to add. Removable X per chip.
  - **Activities:** Activity name, role, dates, description.
  - **Awards:** Award name, issuer, date.
  - **Community Service:** Organization, role, hours, description.
- **"Add Section" Button:** Outline button (plus icon, Primary border, LG radius, 44pt, full width). Dropdown: Custom Section name input.
- Drag-to-reorder: Sections can be dragged by handle to change order. Drop zone highlighted with Primary dashed border.

**Right Panel (50%) — Live Preview:**
- **Template Selector:** Horizontal row of 3 mini thumbnails at top (60pt x 80pt each, md radius). Labels below: "Classic", "Modern", "Academic". Selected = Primary border + check.
- **Live Resume Preview:** Scrollable rendered preview (SurfaceContainerLowest bg, ambient shadow). Updates in real-time as form is edited. Shows formatted resume with chosen template styling.
- **Action Buttons:** Bottom of preview:
  - "Download PDF" AccentBtn (lime bg, glow, pill, 48pt). Download icon.
  - "Print" Outline button (printer icon, Primary border, pill, 44pt).

---

## Screen M3: Alternative Paths Guide

**Layout:** 2x2 card grid initially, expanding to full detail.

- **Header:** "Explore All Paths" Headline Large. Subtitle: "College isn't the only route to success" Body Medium (On Surface Variant).

- **2x2 Path Cards (initial view, 16pt gap):** Each card (SurfaceContainerLow, XL radius, ambient shadow, xxl padding):
  - **Community College:** Building icon (48pt, Primary). "Community College" Title Medium. "Start local, transfer up" Body Medium. "Average savings: $30,000+" Accent Lime Label Medium.
  - **Trade School:** Wrench icon (48pt, Primary). "Trade & Vocational" Title Medium. "Hands-on career training" Body Medium. "Avg starting salary: $45,000" Accent Lime Label Medium.
  - **Military:** Shield icon (48pt, Primary). "Military Service" Title Medium. "Serve and earn education benefits" Body Medium. "GI Bill: Full tuition" Accent Lime Label Medium.
  - **Gap Year:** Globe icon (48pt, Primary). "Gap Year" Title Medium. "Explore before you commit" Body Medium. "Structured programs available" Label Medium.
  - Each card tappable (44pt+ touch). On tap → expands to full detail view.

- **Detail View (on card tap):** Replaces grid with single-column detail (700pt max):
  - Back arrow to return to grid.
  - Icon (64pt) + Path name (Headline Large) + tagline (Body Large).
  - "Description" — 3–4 paragraphs Body Medium.
  - "Pros & Cons" — Two-column: Pros (green check items) | Cons (amber warning items).
  - "Typical Timeline" — Horizontal timeline visualization (similar to career education timeline).
  - "Financial Comparison" — Cost card comparing to 4-year university. Bar chart: traditional vs this path.
  - "How to Get Started" — Numbered steps.
  - "Success Stories" — 1–2 quote cards (SurfaceContainerLow, XL radius, quote marks icon). Name, path, outcome.
  - "Resources" — Link list (Primary text, arrow-right).
  - "Save to Profile" PrimaryBtn (pill, 48pt).

---

## Screen M4: Internship Guide

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — Guide Content:**
- Header: "Internship Guide" Headline Large. Subtitle: "Your complete guide to landing an internship" Body Medium.
- **Accordion Sections:** Each section (SurfaceContainerLow, XL radius, 16pt padding, 12pt spacing):
  - **"When to Look"** — Title Medium + chevron. Expanded: timeline by grade (9th: explore, 10th: shadow, 11th: apply, 12th: intern). Body Medium content.
  - **"Where to Find"** — Title Medium. Expanded: resource list (Handshake, LinkedIn, local orgs, school career center, cold outreach). Each with link.
  - **"How to Apply"** — Title Medium. Expanded: resume tips, cover letter template, application tracker link.
  - **"Interview Tips"** — Title Medium. Expanded: preparation checklist, common questions, STAR method explanation.
  - **"Making the Most of It"** — Title Medium. Expanded: first week tips, building relationships, asking for recommendations.
  - Each accordion 44pt header touch target. Chevron rotates 180deg on expand.

**Right Column (45%) — Your Status:**
- **Internship Tracker Link Card:** Card (SurfaceContainerLow, XL radius, Primary left border 4pt). "Your Internship Tracker" Title Medium. "Track applications and progress" Body Small. Arrow-right. Navigates to G6.
- **Stats Card:** Three mini stat circles in a row: "Applied: 3" | "Interviews: 1" | "Offers: 0". Primary ring progress.
- **Upcoming Deadlines Card:** Card listing upcoming internship deadlines. Each: name + date + countdown. Sorted by nearest.
- **"Add Internship" Button:** AccentBtn (lime bg, glow, full width, 48pt). Plus icon.

---

## Screen M5: Impact Report (Student)

**Layout:** Dashboard — full width.

- **Header:** "Your Journey" Headline Large (Noto Serif). Subtitle: "See how far you've come" Body Medium.

- **Stats Row:** 5 equal-width stat cards (SurfaceContainerLow, XL radius, ambient shadow). Horizontal row:
  - "Days Active" — "187" Title Large bold. Calendar icon.
  - "Tasks Done" — "234" Title Large bold. Check-circle icon.
  - "Colleges" — "8" Title Large bold. Building icon.
  - "Essays" — "12" Title Large bold. Edit icon.
  - "Service Hours" — "156" Title Large bold. Heart icon.

- **Journey Timeline:** Horizontal scrollable timeline (160pt height). Nodes connected by line (Primary, 2pt):
  - "Joined Ladder" (date, check). "Added First College" (date, check). "Took Career Quiz" (date, check). "Submitted First App" (date, check). "Accepted!" (date, star icon, Accent Lime glow).
  Each node: circle (Primary fill for completed, outline for pending) + label below + date in Body Small.

- **Growth Charts (2-column, 16pt gap):**
  - **GPA Trend:** Line chart (Primary line, semester labels). "GPA Growth" Title Small header.
  - **SAT/ACT Trend:** Line chart (Primary line for SAT, Accent Lime for ACT). "Test Score Growth" Title Small.
  - **Activities Growth:** Bar chart showing activities per year. "Activities Over Time" Title Small.

- **Action Buttons:** Row at bottom:
  - "Share My Story" AccentBtn (lime bg, glow, pill, 48pt). Share icon.
  - "Download Report" PrimaryBtn (gradient pill, 48pt). Download icon.

---

## Screen M6: Social Share Templates

**Layout:** Template selector + live preview.

- **Header:** "Share Your Achievement" Headline Large.

- **Template Selector:** Horizontal scroll row of template cards (200pt x 140pt each, 12pt gap). Each card (SurfaceContainerLow, XL radius, ambient shadow):
  - **"Accepted!"** — Celebration confetti bg. School name + "Accepted!" text preview.
  - **"By the Numbers"** — Stats grid preview. GPA, SAT, activities, service hours.
  - **"Decision Day!"** — Cap and gown icon. School name + date.
  - **"Committed!"** — School colors bg. Ladder logo + school logo.
  Selected template: Primary border (3pt) + check badge.

- **Live Preview:** Large preview card (400pt x 400pt, centered, XL radius, ambient shadow). Renders the selected template with actual student data:
  - Student name (or initials for privacy). College name and logo placeholder. College colors as accent. Stats populated from profile.
  - Editable caption field below preview (TextField, full width). Placeholder: "Add a caption..."

- **Action Buttons:** Row below preview:
  - "Download Image" AccentBtn (lime bg, glow, pill, 48pt). Download icon.
  - Share buttons: system share sheet trigger (outline button, share icon, pill, 44pt).

---

## Screen N1: Parent Dashboard

**Layout:** Overview grid. Full width with sidebar showing parent-specific navigation.

- **Top Section — Child Switcher:** If multiple children, horizontal tab pills at top. Each: child's first name + avatar (24pt). Selected = Primary bg + white text.

- **Stats Row:** 4 stat cards (SurfaceContainerLow, XL radius, ambient shadow):
  - "Schools Applied" — "5" Title Large bold. Building icon.
  - "Acceptances" — "3" Title Large bold (Accent Lime). Check-circle icon.
  - "Total Aid Offered" — "$45,200" Title Large bold (Accent Lime). Dollar icon.
  - "Upcoming Deadlines" — "4" Title Large bold. Calendar icon with alert dot.

- **Left Column (55%) — College Status:**
  - "College Applications" Title Medium header.
  - College list table. Each row (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
    - College name (Title Small). Status badge: "Accepted" green chip, "Pending" amber, "Denied" red, "Applied" blue, "Waitlisted" purple.
    - Deadline: Body Small. "Updated: 2 days ago" Body Small (Outline).

- **Right Column (45%) — Summary:**
  - **Financial Summary Card:** "Financial Overview" Title Medium. Total COA, total aid, net cost comparison. Mini bar chart (2–3 schools).
  - **Upcoming Deadlines Timeline:** Vertical mini timeline. Next 5 deadlines with date + task + school. Sorted by nearest.
  - **Checklist Progress Ring:** Ring chart (100pt). "72% Complete" center. "Overall Progress" Label Medium.

- **Bottom Action Row:**
  - "Message Student" PrimaryBtn (pill, 48pt). Chat icon.
  - "Message Counselor" Outline button (Primary border, pill, 44pt). Chat icon.

---

## Screen N2: Parent Invite Code

**Layout:** Centered card (500pt max width).

- **Header:** "Connect with Your Child" Headline Large, centered.
- **Instruction Text:** "Enter the 6-digit code your child shared with you" Body Large, centered, On Surface Variant.

- **Code Entry Card:** SurfaceContainerLow, XL radius, ambient shadow, xxl padding.
  - 6 individual digit input boxes (48pt x 56pt each, md radius, SurfaceContainerLowest bg, Outline border, 8pt gap). Primary border on focus. Large centered digit (Title Large). Auto-advance to next box on input.
  - "Connect" PrimaryBtn below (gradient pill, 48pt, full width). Disabled until all 6 digits entered.

- **Success State:** Card transforms — green checkmark animation (80pt circle, Primary bg, white check). "Connected!" Headline Small. "You can now view [Child Name]'s dashboard." Body Medium. "Go to Dashboard" AccentBtn.

- **Error State:** Red shake animation on code boxes. "Invalid code. Please check with your child and try again." Body Medium, Error color. "Try Again" outline button.

- **Alternative:** "Don't have a code?" Body Small link. "Ask your child to generate one from their Profile > Invite Code." Body Small.

---

## Screen N3: Multi-Child Switcher

**Layout:** Centered (500pt max width).

- **Header:** "Your Children" Headline Large, centered.

- **Child Cards:** Vertical stack, 16pt gap. Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Left: Avatar (56pt circle, Primary border 2pt).
  - Center: Name (Title Medium bold). Grade + school below (Body Medium, On Surface Variant). Activity preview: "3 apps submitted, 2 accepted" Body Small.
  - Right: "View Dashboard" PrimaryBtn small (pill, 36pt). Chevron-right.
  - Entire card tappable (44pt+ height).

- **"Add Another Child" Button:** Dashed-border card (Outline #737970 dashed 2pt, XL radius, 80pt height). Centered: plus icon (32pt, Primary) + "Add Another Child" Title Small (Primary). Navigates to invite code flow.

---

## Screen N4: Parent Messaging

**Layout:** Chat master-detail — Left 280pt sidebar + Right chat area.

**Left Sidebar (280pt) — Contacts:**
- Header: "Messages" Title Large. Unread count badge (Primary circle, white number).
- **Filter Chips:** "All" | "Student" | "Counselor". Pill chips.
- **Contact List:** Each contact row (48pt height, 12pt padding):
  - Avatar (36pt circle). Name (Title Small). Preview of last message (Body Small, Outline, 1 line truncated). Time (Label Small, right-aligned).
  - Unread: blue dot indicator (8pt circle). Bold name text.
  - Selected contact: SurfaceContainerHigh bg.

**Right Area — Conversation:**
- **Conversation Header:** Contact name (Title Medium) + role chip ("Student" / "Counselor"). Online/offline status dot.
- **"Visible to [recipient]" Notice:** Top banner (SurfaceContainerHigh, sm radius, 8pt padding). Info icon + "This conversation is visible to [Student Name]" Body Small. Dismissible.
- **Messages:** Vertical scroll. Sent messages right-aligned (Primary Container bg, On Primary text, LG radius, right tail). Received messages left-aligned (SurfaceContainerHigh bg, On Surface text, LG radius, left tail). Timestamp (Label Small, Outline) below each cluster. Date separators centered.
- **Input Area:** Bottom bar (SurfaceContainerLowest bg). TextField full width + attachment button (paperclip icon, 44pt) + send button (PrimaryBtn circle, 44pt, arrow-up icon).

---

## Screen N5: Peer Comparison

**Layout:** Dashboard. Full width.

- **Header:** "Peer Comparison" Headline Large. School selector dropdown (TextField style).

- **Three Chart Panels (equal width, 16pt gap, horizontal row):**
  - **GPA Bell Curve:** Normal distribution curve (Outline Variant fill, Primary stroke). Student's position = vertical Primary dashed line + dot. "Your GPA: 3.8" label. Percentile: "Top 15%" Label Medium (Primary).
  - **SAT Bell Curve:** Same visualization. "Your SAT: 1420" label. Percentile.
  - **Activities Bar Chart:** Horizontal bars for activity categories (Leadership, Service, Academic, Creative, Athletic). Student's bar highlighted (Primary). Average bar (Outline Variant). "Your Activities" vs "School Average" legend.

- **Aggregate Stats Card:** SurfaceContainerLow, XL radius. "School Overview" Title Medium. Stats: Avg GPA, Avg SAT, College-Bound %, Avg Activities count. Body Medium.

- **Strengths/Weaknesses Card:** SurfaceContainerLow, XL radius. Two columns: "Strengths" (green check items) | "Areas to Improve" (amber items). E.g., "Above average GPA" vs "Below average service hours".

- **Privacy Note:** Bottom. Info icon + "All comparisons use anonymized, aggregate data. No individual student data is shared." Body Small (Outline).

---

## Screen N6: Parent Financial Overview

**Layout:** Single centered column (700pt max width).

- **Header:** "Financial Overview" Headline Large.

- **App Costs Card:** SurfaceContainerLow, XL radius, 16pt padding. "Application Costs" Title Medium. Table: College | App Fee | Fee Waiver | Status (Paid/Waived/Pending). Total row bold.

- **Per-School Aid Breakdown:** Each school gets a card (SurfaceContainerLow, XL radius, 16pt padding, 12pt spacing):
  - School name (Title Medium) + status chip. Expandable accordion.
  - Expanded rows: Grants (green text), Scholarships (Accent Lime text), Federal Loans (amber text), Private Loans (red text), Work-Study. Net Cost at bottom (Title Large, bold).
  - Stacked bar visual: color segments for each aid type.

- **Total Comparison Mini-Table:** Card (SurfaceContainerLow, XL radius). Columns: School | Net Cost/Year | 4-Year Total. Sorted by lowest net cost. Best value = green highlight.

- **Status Badges Row:**
  - "FAFSA Status" — badge (green "Submitted" or amber "Not Started" or red "Overdue").
  - "Scholarship Status" — badge ("3 Applied, 1 Awarded" with amounts).

---

**Deliverable:** Design all 12 screens. Batch 10 of 12.
