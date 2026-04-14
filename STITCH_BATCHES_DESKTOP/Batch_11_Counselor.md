You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 11 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Noto Serif for headlines (56/45/36/32/28/24pt). Manrope for body (22/16/14pt titles, 16/14/12pt body, 14/12/10pt labels). Editorial tracking -0.5 headlines, wide +2.0 labels.

**Spacing (8pt):** xxs2 xs4 sm8 md16 lg24 xl32 xxl48 xxxl64 xxxxl80. Radius: sm8 md12 lg16 xl24 xxl32 xxxl40 pill9999.

**Shadows:** Ambient rgba(31,28,20,.06) blur20 y4. Floating blur30 y10. Glow rgba(201,242,77,.30) blur15. PrimaryGlow rgba(66,96,63,.15) blur20 y4.

**Components:** PrimaryBtn gradient pill white hover:brightness+glow. AccentBtn lime dark glow. Cards SurfaceContainerLow XL ambient hover:lift. Chips SurfaceContainerHigh pill hover:outline. TextFields SurfaceContainerLowest outline focus:primary glow. TableRows hover:SurfaceContainerHigh. Links primary underline-on-hover. No dividers. Tooltips on icon buttons. Right-click context menus.

## Desktop Navigation
Top bar (64px): Logo+sidebar toggle | breadcrumbs | search(Cmd+K) + bell + theme + profile dropdown.
Left sidebar (240px, collapsible to 64px): 9 sections with sub-items. Selected=primary pill. Icons+tooltips when collapsed.
Content: max 1200px centered, xl padding. Keys: Cmd+K search, Cmd+N new, Cmd+/ sidebar, Esc close.

---

# Batch 11: Counselor (13 screens)

## O1. CASELOAD MANAGER
Full-width dashboard layout. Top action bar: search TextField (Cmd+K hint), filter chips (Grade, Status, GPA Range, Application Status), view toggle (table/card grid icons), "Export CSV" outlined button, bulk actions dropdown (disabled until rows selected).

Summary cards row (4 cards): At-Risk (Error red accent, count), Needs Attention (amber accent, count), On Track (Primary accent, count), Applications Submitted (Accent Lime accent, count).

Table view: columns: Checkbox | Student Name (avatar + name) | Grade | GPA | SAT | Applications (X/Y) | Next Deadline | Days Until | Status badge (At-Risk red, Attention amber, On Track green). Sortable column headers with arrow indicators. Row hover (SurfaceContainerHigh). Row selection via checkbox. Pagination bar: showing range, page selector, rows per page (25/50/100 dropdown).

Card grid alternative: 4-column grid. Each card (SurfaceContainerLow, XL radius, hover:lift): avatar, name, grade, GPA, status badge, next deadline, quick action icons (message, flag, view).

## O2. STUDENT DETAIL
Top section: student header bar with avatar (64px), name (Headline Medium), grade, school. Action buttons right-aligned: "Message" (PrimaryBtn), "Flag" (outlined, amber icon), "Schedule Meeting" (outlined).

Left panel (60%): College application table (College | Status | Deadline | Decision). GPA trend chart (line graph, semesters). Activities list (name, type chip, hours, years). Essays status table (College | Prompt | Status badge | Word Count).

Right panel (40%): Stats card (SurfaceContainerLow): GPA, SAT, Class Rank, Activities Count. Alert banner if at-risk (Error Container background, Error text, with specific risk reason). Upcoming deadlines list (next 5, countdown). Counselor notes section (reverse chronological) + "Add Note" TextField with "Save" button. Schedule approval requests (pending items from AI scheduler).

## O3. CLASS APPROVAL
Left panel (50%): Student's proposed schedule table. Columns: Period | Course | Teacher | AI Status icon (checkmark green = approved, warning amber = review needed, info blue = suggestion, X red = conflict). Tooltip on each status icon explaining the AI reasoning. Hover rows for detail.

Right panel (50%): AI analysis card (SurfaceContainerLow, XL radius). Sections: Rigor Assessment (score + description), Bright Futures Alignment (progress bar + status), Career Path Alignment (match %), Prerequisite Check (all met / issues listed), Workload Analysis (difficulty meter). Conflicts section listing any scheduling issues with suggested resolutions. Action buttons: "Approve Schedule" (PrimaryBtn), "Request Changes" (outlined, opens note field), "Schedule Meeting" (outlined).

## O4. GENERIC DEADLINE CALENDAR
Month grid view (7 columns, 5-6 rows). Navigation: month/year selector with arrows. Deadline markers on dates, color-coded by type: Early Decision (purple chip), Early Action (blue chip), Regular Decision (green chip), Rolling (amber chip). Click any date to expand and show list of colleges with that deadline. Legend at top right showing color codes.

Banner note (SurfaceContainerHigh, Label Medium): "Reference calendar showing general college deadlines. Not linked to individual student applications." Export button (outlined, calendar icon): exports to iCal/Google Calendar.

## O5. IMPACT REPORT (COUNSELOR)
Executive summary card (SurfaceContainerLow, XXL radius, PrimaryGlow shadow): total students, acceptance rate, avg scholarships, avg GPA improvement. Workload metrics row: students per counselor, avg meetings per week, response time.

Outcome charts: acceptance rates year-over-year (grouped bar chart), college destinations (horizontal bar, top 10), scholarship totals (line chart trending up). Equity outcomes section: demographic breakdown charts showing access and outcomes by group. Bright Futures projection card: eligible students count + projected vs. actual.

Testimonials section: quote cards from students/parents. Action buttons: "Export PDF" (PrimaryBtn) + "Share with Admin" (outlined).

## O6. VERIFICATION
Centered card (600px, SurfaceContainerLow, XXL radius, floating shadow). School logo at top. Verification code input (6-digit, large monospace fields). "Verify" PrimaryBtn. Success state: green checkmark, counselor name + school displayed, role badge. Error state: Error text with retry option. Help link at bottom.

## O7. BULK IMPORT
4-step wizard with step indicator at top (numbered circles connected by line, completed = Primary fill, current = Primary border, upcoming = Outline).

Step 1 - Upload: Drag-and-drop zone (dashed border, XL radius) + "Download Template" link + "Browse Files" AccentBtn. Accepts CSV/XLSX.

Step 2 - Preview: Data table showing parsed rows. Auto-generated student IDs. Validation column: checkmark green for valid, X red for errors (hover for detail). Error summary card above table. Edit inline to fix errors.

Step 3 - Confirm: Summary card (total students, valid count, error count). Sample student cards (3 previews showing how data will appear). "Import X Students" PrimaryBtn.

Step 4 - Credentials: 3x2 printable credential cards per page. Each card: student name, ID, QR code, temporary password. Action buttons: "Print Cards" (PrimaryBtn), "Download PDF" (outlined), "Email Credentials" (outlined).

## O8. AUTO-ID GENERATOR
Centered form (500px max-width). Input fields: Student Name (first + last), Date of Birth (date picker), Grade (dropdown), Email (optional). Live credential preview card below form (SurfaceContainerLow, lg radius): shows generated student ID format, QR code placeholder, temporary password (masked with reveal toggle). "Create Student" (PrimaryBtn) + "Print Card" (outlined).

## O9. MESSAGING
Master-detail chat layout. Left panel (280px): filter dropdown (All, Students, Parents, Admin), search TextField. Contact list: avatar, name, role badge, last message preview (truncated), timestamp, unread badge (Primary circle).

Right panel: conversation header (name, role, status dot). Message bubbles: sent (Primary Container, right), received (SurfaceContainerHigh, left). Timestamps between groups. "Logged per school policy" banner (SurfaceContainerHigh, Label Small, top of conversation). Input area: TextField + attachment icon (paperclip) + send button.

## O10. SCHOOL YEAR ROLLOVER
Preview table (full width): columns: Student Name | Current Grade | New Grade | Status (Promoting / Graduating / Held). Counts summary above: promoting per grade, graduating, total affected. Below table: two sections side by side. Left: "Will Be Reset" list (schedules, temporary flags, session data). Right: "Will Be Preserved" list (transcripts, activities, college lists, documents). "Execute Rollover Now" (PrimaryBtn, red-tinted for caution, opens confirmation modal: "This action cannot be undone. Type ROLLOVER to confirm.") or "Schedule for August 1" (outlined). 

## O11. ANNOUNCEMENT COMPOSER
Form layout (700px max-width). Audience selector: checkboxes/chips for All Students, By Grade (multi-select), By Status, Parents, Counselors. Title TextField. Rich text editor (toolbar: bold, italic, link, list, heading) for body content. Attachment upload area (drag-and-drop or browse). Priority selector: Normal (default) / Important (amber) / Urgent (Error red). Schedule: "Send Now" radio or date/time picker for scheduled send. Preview card below showing how announcement will appear to recipients. "Send Announcement" PrimaryBtn.

## O12. AT-RISK ALERTS
Left panel (45%): Alert cards stacked vertically (SurfaceContainerLow, XL radius). Each card: risk level indicator (left border: red = high, amber = medium, blue = low), student name + avatar, risk reason (Body Small), days since last activity. Cards sorted by severity. Filter chips at top: All, High Risk, Medium, Low.

Right panel (55%): Selected student assessment. Risk score ring (large, colored by severity). Activity timeline showing gaps (visual timeline with dots for activity, gaps highlighted). Missed deadlines list with dates. AI-suggested interventions card (SurfaceContainerLow, sparkles icon): specific action recommendations. Action buttons: "Send Check-In Message" (PrimaryBtn), "Flag for Follow-Up" (outlined, amber), "Dismiss Alert" (text button, On Surface Variant).

## O13. COUNSELOR MARKETPLACE
Browse view: search TextField + filter chips (Specialty, Price Range, Rating, Availability). Counselor cards in 3-column grid (SurfaceContainerLow, XL radius, hover:lift): professional photo (circle, 80px), name (Title Medium), credentials (Label Small), specialty tags (chips), star rating + review count, price range.

Click card for profile view: large photo, full bio, specialties list, review cards (star rating + text + author), availability calendar, pricing tiers table. Action buttons: "Book Session" (PrimaryBtn), "Send Message" (outlined). "Become an Ambassador" AccentBtn in sidebar for counselors interested in joining the marketplace.

---

**Deliverable:** Design all 13 screens at 1440px. Batch 11 of 12.
