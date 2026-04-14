You are designing iPad screens for Ladder, a college preparation app. This is batch 3 of 12 (screens listed below). Use these exact design tokens for all screens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (Display Large 56pt Bold, Display Medium 45pt, Display Small 36pt, Headline Large 32pt Bold, Headline Medium 28pt SemiBold, Headline Small 24pt Medium). Body/Labels = Manrope (Title Large 22pt Bold, Title Medium 16pt SemiBold, Title Small 14pt SemiBold, Body Large 16pt, Body Medium 14pt, Body Small 12pt, Label Large 14pt Bold, Label Medium 12pt Bold, Label Small 10pt SemiBold). Headlines use editorial tracking (-0.5). Labels use wide tracking (+2.0).

**Spacing (8pt grid):** xxs 2, xs 4, sm 8, md 16, lg 24, xl 32, xxl 48, xxxl 64, xxxxl 80

**Corner Radius:** sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 40, pill 9999

**Shadows:** Ambient (cards): rgba(31,28,20, 0.06) blur 20 y-offset 4. Floating (modals): same blur 30 y-offset 10. Glow (CTAs): rgba(201,242,77, 0.30) blur 15 no offset. Primary Glow: rgba(66,96,63, 0.15) blur 20 y-offset 4.

**Components:** Primary Button = gradient primary→primaryContainer, pill, white text, scale 0.95 on press. Accent Button = Accent Lime bg, dark text, glow shadow. Cards = Surface Container Low bg, XL radius, ambient shadow. Chips = Surface Container High bg, pill, Label Small. Text Fields = Surface Container Lowest bg, outline border, LG radius, primary border on focus. No divider lines — use spacing and elevation. Min 44pt touch targets.

## iPad Navigation
Collapsible sidebar (280pt) replaces iPhone tab bar. Sidebar: Ladder logo top, 9 nav sections (Home, Tasks, Colleges, Applications, Advisor, Financial, Career, Housing, Reports) with expandable sub-items. Selected = primary bg pill. Bottom = avatar + name + grade. Portrait = sidebar overlays. Detail area max-width 800pt for single-column views. Landscape = sidebar always visible.

---

## Screens to Design

### D1. COLLEGE DISCOVERY
Three-column master-detail. Left (280pt): Contained header, search + filter, filter chips vertical (All/Ivy/State/HBCU/Liberal Arts/CC/Technical/Religious/Military), sort by, "6,322 colleges" count. Center: 3-column LazyVGrid of CollegeCards (image hero 140pt, heart button, match % badge lime, name, location, 3 tags). Right (400pt, appears on college tap): Inline profile summary (hero + stats row + section tabs + actions + "Open Full Profile"). Empty state.

### D2. COLLEGE PROFILE (Full)
Wide two-column. Left (65%): Hero (gradient overlay, match % badge, name, location, type tags), section tabs (Overview | Deadlines | Personality | Actions). Overview: about card + "Known For" tags. Deadlines: type/date/platform cards + testing policy. Personality: AI summary + radar chart (Rigor, Social, Greek, Athletics, Diversity, Beauty) + importance ratings. Actions: 2x3 grid (Start App, Mock Interview, LOCI, Compare, Match Score, Why This School). Right (35%): Stats card stack (acceptance, tuition in/out, SAT, ACT, enrollment, grad rate, student-faculty) + "Your Fit" card + "Start Application" + "Add to List".

### D3. COLLEGE COMPARISON
Multi-column comparison table. Top: 2-3 college selector slots (search + X remove). Comparison rows: Acceptance, Tuition, SAT, ACT, Enrollment, Grad Rate, Student-Faculty, Campus Size, Setting, Match %, Deadline, Fee. Green highlight on best. Photo row top. AI "Which is right for me?" card.

### D4. MATCH SCORE DETAIL
Two-column. Left (55%): College name + overall match % ring (glow) + "How We Calculate" headline + factor breakdown (GPA/Test/Major/Location/Financial/Culture/Size bars green/amber/red, expandable). Right (45%): "How to Improve" AI card + similar colleges comparison + "What-If Simulator" link.

### D5. ADVANCED FILTERS
Full-screen filter drawer (500pt from right). Categories: Location (state multi-select, region, distance slider), Academics (major, grad rate, student-faculty), Admissions (acceptance/SAT/ACT ranges, test policy), Cost (tuition, aid, net cost sliders), Campus (size, setting, type), Culture (diversity, Greek, athletics, HBCU, Women's). "Apply Filters" accent button + count + "Reset All".

### D6. CAMPUS PHOTO GALLERY
Full-width. College name header. 3-column masonry grid. Full-screen viewer on tap (swipe). Category tabs (Campus, Dorms, Dining, Athletics, Labs, Library, Student Life). Empty state.

### D7. "BEST FOR YOUR MAJOR"
Ranked list. "Best Colleges for [Major]" headline + career badge. Ranked cards: rank number + college name + match % + program details + "Why this school for your major" explanation + strength tags. Filterable.

---

Design all 7 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 3 of 12.
