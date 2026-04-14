You are designing iPad screens for Ladder, a college preparation app. This is batch 12 of 12. Use these exact design tokens.

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

# Batch 12: Admin + District + Utility — 16 Screens

---

## Screen P1: School Admin Dashboard

**Layout:** Full-width dashboard. Sidebar shows admin-specific navigation.

- **Row 1 — Metric Cards (4 equal-width, 16pt gap):** Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - "Total Students" — count (Display Small, Primary) + trend arrow (up green or down red) + "vs last year" Body Small. People icon.
  - "College-Bound %" — percentage (Display Small, Accent Lime) + trend. Graduation-cap icon.
  - "Apps Sent" — count (Display Small, Primary) + trend. Send icon.
  - "Aid Secured" — dollar amount (Display Small, Accent Lime) + trend. Dollar icon.

- **Row 2 — Charts (60% / 40% split, 16pt gap):**
  - **Acceptance by Type Bar Chart (60%):** Card (SurfaceContainerLow, XL radius). "Acceptances by Type" Title Medium. Grouped horizontal bars: ED (purple), EA (blue), RD (green), Rolling (amber). Counts per bar. Legend below.
  - **Grade Distribution Donut (40%):** Card (SurfaceContainerLow, XL radius). "Students by Grade" Title Medium. Donut chart (180pt diameter). Segments: Grade 9 (teal), 10 (blue), 11 (amber), 12 (Primary). Center: total count. Legend below.

- **Row 3 — Tables (50% / 50%, 16pt gap):**
  - **At-Risk Alerts Mini Table (50%):** Card. "At-Risk Students" Title Medium + count badge (Error). Compact table: Student | Grade | Risk Level (badge) | Days Inactive. 5 rows max + "View All" link.
  - **Top Destinations Ranked List (50%):** Card. "Top College Destinations" Title Medium. Ranked list: # | College Name | Accepted count | Applied count. 10 rows. Medal icons for top 3 (gold/silver/bronze).

- **Bottom Action Row:**
  - "View All Students" PrimaryBtn (pill, 48pt). People icon.
  - "View Counselors" Outline button (Primary border, pill, 44pt).
  - "Download Report" AccentBtn (lime bg, glow, pill, 48pt). Download icon.

---

## Screen P2: Class Catalog

**Layout:** Two-panel — Left 55%, Right 45%.

**Left Panel (55%) — Catalog Table:**
- Header: "Class Catalog" Headline Large + course count badge. "Upload CSV" outline button (upload icon, Primary border, pill) + "Download Template" link (Primary text).
- **Course Table:** Full-width, sortable. Columns: Name (flex) | Dept (80pt) | Level (70pt) | Credits (60pt) | Teacher (100pt) | Periods (80pt) | Capacity (70pt).
  - Header row: SurfaceContainerHigh bg, Label Large, wide tracking. Tap header to sort (arrow indicator).
  - Rows: alternating Surface / SurfaceContainerLow. 44pt height. Editable inline — tap cell to edit (Primary border focus).
  - Level column: chips — "AP" (Primary bg, white), "Honors" (blue bg, white), "Standard" (outline), "DE" (Accent Lime bg, dark).
  - Capacity: "28/30" with mini progress bar.
  - Selected row: Primary left border + SurfaceContainerHigh bg.

**Right Panel (45%) — Course Form:**
- Header: "Course Details" Title Large. (Shows "Add Course" for new, or course name for editing.)
- Form fields (TextFields, vertical stack):
  - Course Name (required).
  - Department — dropdown (Math, Science, English, Social Studies, World Languages, Arts, PE, Electives).
  - Level — dropdown (AP, Honors, Standard, DE).
  - Credits — number field.
  - Teacher — autocomplete from staff list.
  - Periods — multi-select checkboxes (1–7).
  - Prerequisites — tag input (search + add).
  - Description — text area (120pt height).
  - Capacity — number field.
- **Action Buttons:**
  - "Save" PrimaryBtn (gradient pill, 48pt, full width).
  - "Delete" Outline button (Error border, Error text, pill, 44pt, full width). Confirmation modal on tap.
- **"Publish Catalog" Button:** AccentBtn at very bottom of panel (lime bg, glow, 48pt, full width). "Publish to Students" with globe icon.

---

## Screen P3: School Profile

**Layout:** Centered form (700pt max width).

- **Header:** "School Profile" Headline Large.
- **Logo Upload:** School logo placeholder (96pt square, XL radius). "Upload Logo" link (Primary text). Drag-and-drop or click.

- **Form Fields (vertical stack, TextFields):**
  - School Name (required).
  - Address (street, city, state, zip — 2-column for city/state).
  - District (autocomplete).
  - Principal Name.
  - School Type — dropdown: Public, Private, Charter, Magnet.
  - Enrollment — number.
  - Student-Teacher Ratio — number input (e.g., "22:1").
  - Graduation Rate — percentage (e.g., "94%").
  - College-Going Rate — percentage.
  - Programs — tag chip input. Type to add: "IB", "AICE", "AP Capstone", "CTE". Each = removable chip.
  - Clubs — editable list. Each row: club name + "Remove" X. "Add Club" button.
  - Key Dates — date fields: First Day, Last Day, Graduation, Spring Break, Winter Break.

- **Action Buttons:**
  - "Save" PrimaryBtn (gradient pill, 48pt, full width).
  - "View Public Profile" Outline button (Primary border, pill, 44pt, full width). External-link icon.

---

## Screen P4: Ambassador Signup

**Layout:** Marketing page — centered (600pt max width). Visually richer than standard forms.

- **Hero Section:** "Become a Ladder Ambassador" Headline Large (Noto Serif), centered. Subtitle: "Help more students reach their potential" Body Large, centered.

- **Benefits List:** Card (SurfaceContainerLow, XL radius, Accent Lime left border 4pt). "Benefits" Title Medium.
  - ✓ "Free Ladder Premium for your school" Body Medium.
  - ✓ "Priority support from the Ladder team" Body Medium.
  - ✓ "Impact reports for your administration" Body Medium.
  - ✓ "Professional development credits" Body Medium.
  Green checkmarks (Primary).

- **Requirements List:** Card (SurfaceContainerLow, XL radius). "Requirements" Title Medium.
  - "Active counseling role at a school or district" Body Medium.
  - "50+ students actively using Ladder" Body Medium.
  - "Quarterly feedback on platform improvements" Body Medium.
  Bullet points (Outline color).

- **Signup Form:**
  - Name (TextField).
  - School (TextField, autocomplete).
  - Role (dropdown: Counselor, Department Head, Administrator).
  - School Email (TextField).
  - "Why do you want to be an ambassador?" — text area (120pt height).

- **"Apply" Button:** AccentBtn (lime bg, glow, 48pt, full width). "Apply Now" with star icon.

---

## Screen P5: Data Export

**Layout:** Centered (600pt max width).

- **Header:** "Export Data" Headline Large.

- **Export Type Radios:** Vertical list of radio cards (SurfaceContainerLow, LG radius, 16pt padding, 8pt spacing):
  - "Student Roster (CSV)" — People icon + description.
  - "Application Data (CSV)" — Clipboard icon + description.
  - "Academic Data (CSV)" — Chart icon + description.
  - "Full Report (PDF)" — File icon + description.
  - "FERPA-Compliant Package (ZIP)" — Shield icon + description.
  Selected = Primary border (3pt) + Primary radio fill.

- **Filters:**
  - Date Range: two date pickers side by side ("From" / "To").
  - Grade Filter: multi-select chips (All / 9 / 10 / 11 / 12).

- **"Generate" Button:** AccentBtn (lime bg, glow, 48pt, full width). Download icon + "Generate Export".
  - Processing state: progress bar + "Generating..." + spinner.

- **Download History:** "Recent Exports" Title Medium. Table: Filename | Type | Date | Size | "Download" link. 5 most recent.

---

## Screen P6: DPA Management

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — DPA List:**
- Header: "Data Processing Agreements" Headline Large. "Upload New" AccentBtn small (lime bg, plus icon, pill, 36pt).
- **DPA List:** Vertical scroll. Each row (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - DPA name / vendor name (Title Small bold).
  - Status badge: "Active" green chip, "Pending" amber chip, "Expired" red chip.
  - Signed date (Body Small). Expiry date (Body Small). Signatory name (Body Small, On Surface Variant).
  - Selected row: Primary left border 4pt.

**Right Column (45%) — Detail:**
- **Document Preview:** Large preview area (SurfaceContainerLowest, md radius, 300pt height). Rendered PDF/document preview. Scrollable.
- **Status Badge:** Large badge at top: "Active" green or "Expired" red or "Pending" amber. Title Medium size.
- **Terms Summary:** "Key Terms" Title Medium. Bulleted list Body Medium: data types covered, retention period, deletion terms.
- **Signatures:** "Signed by" Body Medium. School representative + vendor representative names + dates.
- **Action Buttons:**
  - "Renew" PrimaryBtn (gradient pill, 48pt, full width). Refresh icon. (Shown only if expiring/expired.)
  - "Download" Outline button (download icon, Primary border, pill, 44pt, full width).

---

## Screen P7: Announcement Manager

**Layout:** Same as O11 announcement composer but with analytics added.

- **Header:** "Announcements" Headline Large. "New Announcement" AccentBtn (lime bg, plus icon, pill).

- **Past Announcements List:** Below composer. Each row (SurfaceContainerLow, XL radius, 16pt padding, 12pt spacing):
  - Title (Title Small bold). Date sent (Body Small). Audience chip (e.g., "All Students", "Grade 12").
  - Priority badge: Normal (blue), Important (amber), Urgent (red).
  - **Analytics Row:** "Sent: 247" | "Read: 189 (77%)" | "Clicked: 34 (14%)" — Body Small with mini bar indicators (Primary fill for read rate, Accent Lime for click rate).
  - "View" / "Resend" / "Delete" action links.

- **Composer (same as O11):** Audience selector, title, rich text body, attachment, priority, schedule, preview, send button. Available via "New Announcement" button.

---

## Screen Q1: District Analytics Dashboard

**Layout:** Executive dashboard. Full width.

- **Header:** District name (Headline Large). Metric cards row.

- **Top Metric Cards (4 equal-width, 16pt gap):** SurfaceContainerLow, XL radius, ambient shadow:
  - "Schools" — count (Display Small, Primary). Building icon.
  - "Students" — count (Display Small, Primary). People icon.
  - "College-Bound %" — percentage (Display Small, Accent Lime). Trending-up icon.
  - "Total Aid Secured" — dollar (Display Small, Accent Lime). Dollar icon.

- **School Comparison Table:** Full-width sortable table (SurfaceContainerLow, XL radius). Columns: School Name (flex) | Principal (120pt) | Students (80pt) | Avg GPA (70pt) | Avg SAT (70pt) | College-Bound % (90pt) | Acceptance Rate (90pt) | At-Risk % (80pt).
  - Header: SurfaceContainerHigh bg, Label Large, sortable (tap to sort).
  - Rows: 44pt height, alternating bg. Best value per column = green text. Worst = red text.

- **Bottom Row (50/50):**
  - **Equity Metrics Cards:** 3 mini cards. First-Gen %, Free/Reduced Lunch College-Bound %, AP Access Gap. Each with trend arrow.
  - **Bright Futures Projection Chart:** Bar chart by school. Eligible students count. Primary bars. Target dashed line.

- **Action Buttons:**
  - "Export Dashboard" AccentBtn (lime bg, glow, pill, 48pt). Download icon.
  - "Schedule Weekly Report" PrimaryBtn (gradient pill, 48pt). Calendar icon.

---

## Screen Q2: School Comparison

**Layout:** Full width. 2–3 school comparison.

- **Header:** "Compare Schools" Headline Large.
- **School Selector:** 2–3 dropdown slots at top. Each: TextField with autocomplete from district schools. "Add School" button for 3rd slot.

- **Comparison Table:** Full-width. Rows with left label column (180pt):
  - Enrollment, Avg GPA, Avg SAT, College-Bound %, Acceptance Rate, Aid/Student, At-Risk %, Counselor Ratio.
  - Values per school column. Green highlight = best in row. Red = concern (worst or below threshold).
  - Bold rows: College-Bound %, Acceptance Rate, At-Risk %.

- **Bar Comparisons:** Below table. Horizontal grouped bars per metric (3 bars per group, one per school, color-coded). Primary / Accent Lime / Tertiary for schools 1/2/3.

- **"Export" Button:** Outline button (download icon, Primary border, pill, 44pt). "Export Comparison".

---

## Screen Q3: Equity Metrics Dashboard

**Layout:** Dashboard. Full width.

- **Header:** "Equity & Access" Headline Large (Noto Serif).

- **Metric Cards Row (5 equal-width, 12pt gap):** Each card (SurfaceContainerLow, XL radius):
  - "First-Gen %" — percentage + trend. Person-plus icon.
  - "Free/Reduced Lunch" — percentage + trend. Utensils icon.
  - "SAT Access Gap" — point difference + trend. Chart icon.
  - "AP Access" — percentage taking AP + trend. Book icon.
  - "Enrollment Gap" — gap percentage + trend. Users icon.
  Values: Accent Lime if improving, Error if worsening.

- **Demographic Charts (2-column, 16pt gap):**
  - **College-Going Rate by Demographic:** Grouped bar chart. Groups: White, Black, Hispanic, Asian, Other. Bars: Applied vs Accepted. Primary / Accent Lime.
  - **Aid Distribution by Income:** Stacked bar chart. Income brackets (x-axis). Stacked: Grants, Scholarships, Loans, Self-Pay. Color segments.
  - **AP Enrollment by Demographic:** Horizontal bars. Groups by demographic. Bar = % taking AP. Primary fill.

- **Year-over-Year Trends:** Line chart. 3–5 years. Multiple lines for key equity metrics. Primary, Accent Lime, Tertiary colors.

- **AI Action Plan Card:** SurfaceContainerLow, XL radius, sparkles icon. "Recommended Actions" Title Medium. Numbered suggestions: "Increase AP enrollment outreach for first-gen students", "Expand SAT fee waiver awareness", "Target scholarship matching for underrepresented groups". Body Medium.

- **"Export" Button:** AccentBtn (lime bg, glow, pill, 48pt). "Export Equity Report".

---

## Screen Q4: District Report Generator

**Layout:** Wizard — centered (600pt max width).

- **Header:** "Generate Report" Headline Large.

- **Report Type:** Radio cards (SurfaceContainerLow, LG radius, 16pt padding, 8pt spacing):
  - "Monthly Report" | "Quarterly Report" | "Annual Report" | "Custom Report".
  Selected = Primary border + radio fill.

- **Sections Checkboxes:** "Include Sections" Title Medium. Checkbox list (Primary fill on checked):
  - ☑ Student Demographics
  - ☑ Academic Metrics
  - ☑ Application Outcomes
  - ☑ Financial Aid Summary
  - ☑ Equity Metrics
  - ☐ Individual School Breakdowns
  - ☐ Year-over-Year Comparison

- **Date Range:** Two date pickers side by side ("Start" / "End").

- **Schools:** Multi-select dropdown. "All Schools" default or select individual schools. Selected shown as chips below.

- **Format:** Radio row: "PDF" | "PowerPoint (PPTX)" | "Spreadsheet (CSV)". Selected = Primary border.

- **"Generate" Button:** AccentBtn (lime bg, glow, 48pt, full width). "Generate Report" with sparkles icon.
  - Processing: progress bar + "Generating your report..." + estimated time.
  - Complete: download card with file icon + name + size + "Download" PrimaryBtn.

---

## Screen R1: First 100 Days Tracker

**Layout:** Two-panel — Left 55%, Right 45%.

**Left Panel (55%) — Timeline:**
- Header: "First 100 Days" Headline Large. College name + logo below.
- **Vertical Timeline (May → August):** Left-aligned vertical timeline. Connector line (Primary for completed, Outline Variant for pending, 2pt width).
  - **Each node:** Circle (24pt). Completed = Primary fill + white checkmark (✓). In progress = Primary outline + pulse animation (◎). Upcoming = Outline Variant fill (○).
  - **Node labels:** Task name (Title Small bold). Date (Body Small). School-specific tip inline (Body Small, On Surface Variant, italic). E.g., "UF tip: Housing fills fast — apply by June 1."
  - **Tasks:**
    - "Accept Offer ✓" (May)
    - "Pay Deposit ✓" (May)
    - "Apply for Housing ◎" (June)
    - "Register for Orientation ○" (June)
    - "Course Registration ○" (July)
    - "Health Records ○" (July)
    - "Move-in Day ○" (August)

**Right Panel (45%) — Quick Access:**
- **Countdown Ring:** Large ring chart (140pt). Days remaining to move-in in center (Display Small, Primary). "Days to Move-in" Label Medium.
- **This Week's Tasks Card:** SurfaceContainerLow, XL radius. "This Week" Title Medium. Checklist: 2–3 items with checkboxes + due date. Priority indicators.
- **Packing Checklist Card:** SurfaceContainerLow, XL radius. "Packing List" Title Medium. Collapsible categories:
  - "Documents" — ID, insurance, transcripts. Checkboxes.
  - "Room Essentials" — bedding, towels, desk lamp. Checkboxes.
  - "Tech" — laptop, charger, printer. Checkboxes.
  - "Clothing" — weather-appropriate list. Checkboxes.
  - "Personal" — medications, photos, comfort items. Checkboxes.
  Each category: Title Small header + chevron to expand/collapse. Items = Body Medium + checkbox.
- **"Share with Parent" Button:** Outline button (share icon, Primary border, pill, 44pt, full width).

---

## Screen R2: Global Search

**Layout:** Overlay modal (600pt width, centered, floating shadow, XL radius, SurfaceContainerLowest bg). Dark scrim behind.

- **Search Input:** Large TextField at top (48pt height, no border, large placeholder "Search Ladder..."). Magnifying glass icon left. Clear X right. Auto-focus on open. Title Medium input size.

- **Results (appear as user types):** Grouped sections below input. Each section:
  - Section header: "Colleges" / "Tasks" / "Essays" / "Scholarships" / "Settings" — Label Large, wide tracking, On Surface Variant.
  - Result items: each row (44pt height, 12pt padding). Left icon (category-specific), result text (Body Medium), breadcrumb path (Body Small, Outline). Tap navigates.
  - Max 3 results per section with "View all X results" link.

- **Recent Searches (shown when input empty):** "Recent" Label Medium. List of recent search terms with clock icon. Tap to re-search. "Clear History" link.

- **Keyboard Shortcut Hints:** Bottom of modal. "Cmd+K to open search" Body Small (Outline). "Esc to close."

- **Empty State:** When query has no results. "No results for '[query]'" Body Medium. "Try different keywords or check spelling." Body Small.

---

## Screen R3: Offline Mode / Sync Status

**Layout:** Amber banner + detail card.

- **Banner (persistent, top of screen):** Amber background tint (amber at 15%). Cloud-off icon + "You're offline" Title Small (amber text). Dismissible X on right (but re-appears on navigation). Full width, 44pt height.

- **Detail View (accessible from banner tap or Settings):** Centered card (500pt max width, SurfaceContainerLow, XL radius, ambient shadow, xxl padding).
  - "Sync Status" Headline Medium.
  - **Last Synced:** Clock icon + "Last synced: 2 hours ago" Body Medium.
  - **Pending Changes:** "3 changes waiting to sync" Title Small. List of pending items:
    - Each row: action icon + description + status chip.
    - "Essay draft saved" — edit icon + "Queued" amber chip.
    - "Score logged" — chart icon + "Queued" amber chip.
    - "Profile updated" — user icon + "Failed" red chip (with retry button).
    - Status types: "Queued" amber, "Syncing" blue + spinner, "Failed" red + retry icon.
  - **"Sync Now" Button:** PrimaryBtn (gradient pill, 48pt, full width). Refresh icon. Disabled if truly offline (grayed).
  - **Conflict Resolution (if applicable):** Card with amber border. "1 conflict found" Title Small. Description: "Your essay was edited on another device." Options: "Keep This Version" / "Keep Other Version" / "View Diff". Buttons per option.

---

## Screen R4: Content Moderation

**Layout:** Report queue — master-detail.

**Left Panel (45%) — Queue:**
- Header: "Moderation Queue" Headline Large. Count badge: "(12 pending)".
- **Report Cards:** Vertical scroll. Each card (SurfaceContainerLow, LG radius, 12pt padding):
  - Reporter: "Reported by: [Name]" Body Small. Date: Body Small.
  - Content type chip: "Essay" / "Message" / "Profile" / "Review". Pill chip.
  - Preview: 2-line truncated preview of reported content. Body Medium.
  - Severity badge: "Low" green, "Medium" amber, "High" red, "Critical" red pulsing.
  - Status: "Pending" amber, "Reviewed" blue, "Resolved" green.
  - Selected card: Primary left border 4pt.

**Right Panel (55%) — Detail:**
- **Full Content:** Reported content displayed in full (SurfaceContainerLowest, LG radius, 16pt padding). Scrollable. Flagged portions highlighted with red underline.
- **Reporter Info:** "Reported by: [Name]" Body Medium. Date + time. Reason: Body Medium.
- **AI Assessment Card:** SurfaceContainerLow, XL radius, sparkles icon. "AI Assessment" Title Medium. "Severity: Medium. Contains potentially inappropriate language in paragraph 2. No personal attacks detected." Body Medium.
- **Action Buttons:** Vertical stack, 12pt gap:
  - "Approve Content" — green outline button (check icon, 44pt, full width). Content stays.
  - "Remove Content" — red outline button (trash icon, 44pt, full width). Content removed + notification sent.
  - "Warn User" — amber outline button (alert icon, 44pt, full width). Warning message sent.
  - "Suspend User" — red filled button (ban icon, 48pt, full width). Confirmation modal required.
- **Audit Trail:** "History" Title Medium. Chronological list of actions taken on this report. Timestamp + action + moderator name. Body Small.

---

## Screen R5: Data Deletion Request

**Layout:** Centered (500pt max width). Warning-heavy design.

- **Warning Icon:** Large red circle (80pt) with exclamation mark (white, 40pt), centered. Subtle pulse animation.

- **Header:** "Delete Your Account" Headline Large (Error #ba1a1a), centered.
- **"This action is permanent" Message:** Body Large, centered, Error color. "Once deleted, your account and all associated data cannot be recovered."

- **What's Deleted Section:** Card (Error Container #ffdad6 bg, LG radius, 16pt padding).
  - "Will be permanently deleted:" Title Small (Error).
  - Bulleted list (Body Medium): Profile information, College list and applications, Essays and drafts, GPA and test scores, Scholarship applications, Messages, Activity history.

- **What's NOT Deleted Section:** Card (SurfaceContainerLow, LG radius, 16pt padding).
  - "Will NOT be deleted:" Title Small (Primary).
  - Bulleted list (Body Medium): Anonymized aggregate data (used for school statistics), Counselor notes (retained per school policy), Submitted applications to colleges (already sent).

- **Confirmation Field:** "Type DELETE to confirm" Label Medium. TextField (Error border, LG radius). Input must exactly match "DELETE" (case-sensitive). Validation indicator: red X until match, green check when matched.

- **"Delete Everything" Button:** Full-width button (Error #ba1a1a bg, white text, pill, 48pt). Trash icon. Disabled until "DELETE" typed correctly. On tap: confirmation modal ("Are you absolutely sure? This cannot be undone." + "Yes, Delete Everything" red button + "Cancel" outline).

- **Alternative Actions:** Below delete button.
  - "Cancel" — outline button (Primary border, pill, 44pt, full width).
  - "Download My Data First" — link text (Primary, underlined). Navigates to data export.

---

**Deliverable:** Design all 16 screens. Batch 12 of 12.
