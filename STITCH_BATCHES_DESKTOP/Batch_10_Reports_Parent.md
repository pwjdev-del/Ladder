You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 10 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

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

# Batch 10: Reports + Parent (12 screens)

## M1. PDF PORTFOLIO
Left panel (60%): PDF preview area (SurfaceContainerLowest, lg radius, ambient shadow). Multi-page preview with page navigation (arrows + page number). Zoom controls. Rendered portfolio showing student profile, academics, activities, essays, and achievements.

Right panel (40%): Section toggles: checkboxes for each portfolio section (Profile Summary, Academic Record, Test Scores, Activities, Essays, Awards, Recommendations). Each toggle has drag handle for reorder. Color picker for accent color (preset swatches + custom hex input). Action buttons: "Export PDF" (PrimaryBtn), "Share Link" (outlined), "Print" (outlined with printer icon). Export settings: page size, include/exclude sections.

## M2. RESUME BUILDER
Left panel (50%): Collapsible form sections (accordion cards, SurfaceContainerLow, XL radius). Sections: Contact Info, Education, Experience, Activities, Skills, Awards, References. Each section has drag handle for reorder. Fields within sections also draggable. "Add Item" text button per section.

Right panel (50%): Live preview of resume (SurfaceContainerLowest, ambient shadow, actual page proportions). Template selector at top: three options (Classic, Modern, Academic) as small thumbnail cards, selected = Primary border. Preview updates in real-time as form is edited. Action buttons below preview: "Download PDF" (PrimaryBtn) + "Print" (outlined).

## M3. ALTERNATIVE PATHS
2x2 card grid layout. Four path cards (SurfaceContainerLow, XL radius, ambient shadow, hover:lift): Community College (with transfer icon), Trade School / Vocational (with tools icon), Military (with shield icon), Gap Year (with globe icon). Each card: icon (48px), title (Title Large), brief description (Body Medium), "Learn More" link.

Click any card to expand into full detail view: pros/cons two-column list, typical timeline (vertical stepper), financial comparison table vs. 4-year university, step-by-step process guide, success stories (testimonial cards). "Back to Overview" breadcrumb link.

## M4. INTERNSHIP GUIDE
Left panel (55%): Guide content as accordion sections (SurfaceContainerLow cards). Sections: Finding Internships, Application Tips, Resume for Internships, Interview Prep, Making the Most of It, Turning It Into a Job. Each section expands to show rich text content with tips, checklists, and resource links.

Right panel (45%): Internship tracker table (Name | Company | Status | Dates). Status badges (Applied, Interview, Offered, Active, Completed). Stats card at top: total applications, interviews, offers. "Add Internship" AccentBtn.

## M5. IMPACT REPORT
Dashboard layout. Top stats row: 4 metric cards (Schools Applied, Scholarships Won, Total Aid, Activities Completed) with trend arrows. Journey timeline (horizontal, showing key milestones from freshman year to graduation). Growth charts section: GPA over time (line), test score improvement (bar), activity hours (area chart). All charts use Primary and Accent Lime colors. Action buttons: "Share" (outlined) + "Download PDF" (PrimaryBtn).

## M6. SOCIAL SHARE TEMPLATES
Template carousel at top: horizontally scrollable template cards (acceptance celebration, scholarship win, milestone achievement, journey summary). Each template thumbnail (SurfaceContainerLow, lg radius, hover:lift).

Selected template shows live preview (centered, actual social media dimensions). Editable caption TextField below preview. Customization options: background color, include/exclude stats, add photo. Action buttons: "Download Image" (PrimaryBtn) + system share button (outlined, opens native share sheet on web).

## N1. PARENT DASHBOARD
Child switcher tabs at top (pill chips if multiple children). Four stats cards row: GPA (with trend), Applications (submitted/total), Deadlines (next upcoming), Overall Progress (percentage ring).

Left panel (55%): College application status table. Columns: College | Status badge | Deadline | Decision Date. Sortable, hover state on rows.

Right panel (45%): Financial summary card (total estimated cost, total aid, net cost). Upcoming deadlines list (next 5, with countdown). Overall progress ring (large, Primary fill). Action buttons: "Message Student" (PrimaryBtn) + "Message Counselor" (outlined).

## N2. PARENT INVITE CODE
Centered card (500px max-width, SurfaceContainerLow, XXL radius, floating shadow). Title (Headline Medium, Noto Serif): "Connect with Your Child". Description explaining the code connection process. 6-digit code display (Display Small, monospace, letter-spaced, Primary, SurfaceContainerLowest background with lg radius). Code input field for parent to enter child's code. "Connect" PrimaryBtn. Success state: green checkmark animation, child's name and school displayed, "Go to Dashboard" button. Error state: Error red text, "Try Again" option.

## N3. MULTI-CHILD SWITCHER
Centered container (500px max-width). Child cards stacked vertically (SurfaceContainerLow, XL radius, ambient shadow, hover:lift). Each card: avatar (56px circle), name (Title Medium), grade + school (Body Small, On Surface Variant), last activity timestamp, "View Dashboard" PrimaryBtn. "Add Another Child" card at bottom (dashed border, Outline, center-aligned plus icon and text).

## N4. PARENT MESSAGING
Chat layout (master-detail). Left panel (280px): contact list with search TextField at top. Contact entries: avatar, name, role badge (Student/Counselor), unread count badge (Primary circle with white number). Selected contact highlighted.

Right panel: conversation view. Message bubbles: sent (Primary Container, right-aligned), received (SurfaceContainerHigh, left-aligned). Timestamp labels between message groups. Input area: TextField + send button + attachment icon. Banner notice at top of conversation (SurfaceContainerHigh, Label Small): "Messages are visible to [recipient name]."

## N5. PEER COMPARISON
School selector dropdown at top. Three comparison panels in a row:

GPA panel: bell curve distribution chart with student's position marked as a dot (Primary) with label. School average line (Outline dashed).

SAT panel: bell curve with student's score dot (Primary) and percentile label.

Activities panel: horizontal bar chart showing activity hours by category, with student's bar highlighted (Accent Lime) against school average (Outline).

Aggregate stats card below: percentile ranks, class rank if available. Privacy notice (Label Small, On Surface Variant): "Comparisons use anonymized, aggregate school data."

## N6. PARENT FINANCIAL
Single column layout (700px max-width, centered). App subscription costs card (if applicable). Per-school financial aid breakdown: expandable cards per college showing tuition, aid, net cost, loan projections. Total comparison table across all schools (green highlight on best values). FAFSA completion status badge. Scholarship application status badges (Applied, Pending, Awarded with amounts). Summary card at bottom with total potential aid.

---

**Deliverable:** Design all 12 screens at 1440px. Batch 10 of 12.
