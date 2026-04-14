You are designing iPad screens for Ladder, a college preparation app. This is batch 9 of 12. Use these exact design tokens.

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

# Batch 9: Housing + Profile & Settings — 13 Screens

---

## Screen K1: Housing Preferences Quiz

**Layout:** Centered single column (600pt max width). Sidebar hidden during quiz flow.

- **Header:** "Find Your Perfect Housing" Headline Large (Noto Serif, 32pt Bold), centered.
- **Category Progress Icons:** Horizontal row of 6 category circles (40pt each, 12pt gap), centered. Each circle contains an emoji icon. Categories: Sleep, Clean, Noise, Social, Study, Temp. Completed = Primary #42603f fill + white icon. Current = Primary outline + pulse animation. Upcoming = Outline Variant #c3c8be fill.
- **Question Text:** Below progress. Headline Small (24pt Medium), centered. E.g., "When do you usually go to sleep?"
- **2x2 Emoji Answer Grid:** Four large touch-target cards (140pt x 140pt, 16pt gap, centered). Each card:
  - SurfaceContainerLow #fbf2e8 bg, XL radius (24pt), ambient shadow.
  - Large emoji center (48pt). Label below emoji in Label Large (14pt Bold). Short descriptor in Body Small (12pt, On Surface Variant).
  - E.g., Night Owl with owl emoji / Early Bird with bird emoji / Flexible with arrows emoji / Varies with dice emoji.
  - On select: Primary #42603f border (3pt), Primary background tint (8% opacity), small checkmark badge top-right in Primary circle.
  - Unselected: Outline Variant border (1pt).
  - Min 44pt touch target (exceeds — 140pt).
- **"Next" Button:** PrimaryBtn (gradient pill, 48pt height, 200pt width), centered below grid. Disabled state = 40% opacity until answer selected. On last question becomes "See Results" AccentBtn.
- **Progress Bar:** Bottom of content. Thin bar (4pt height, pill radius). Primary fill proportional to completion. Track = Outline Variant.

---

## Screen K2: Dorm Comparison

**Layout:** Side-by-side comparison (2–3 slots). Full width.

- **Header:** "Compare Dorms" Headline Large. "Add Dorm" outline button (plus icon, pill) top right.
- **Dorm Headers:** Top row. Each column (equal width, 16pt gap): Dorm photo (160pt height, XL radius, object-fit cover). Dorm name (Title Medium bold) below. College name (Body Small, On Surface Variant).

- **Comparison Rows:** Full-width table, alternating bg (Surface / SurfaceContainerLow).
  - **Cost:** "Cost / Semester" label. Dollar values (Title Small). Lowest = green text.
  - **Room Type:** "Single", "Double", "Suite" Body Medium.
  - **Distance:** "Distance to Campus" label. "0.2 mi" / "On Campus" Body Medium.
  - **Meal Plan:** "Required" / "Optional" + cost. Body Medium.
  - **Amenities:** Icon grid row — laundry, AC, wifi, kitchen, gym, study room. Filled icon = included (Primary), outline icon = not included (Outline Variant). 24pt each.
  - **Move-in Date:** Date in Body Medium.
  - **Rating:** 1–5 star row. Filled stars = Accent Lime. Empty = Outline Variant.
  - **Photo Row:** Per dorm — horizontal scroll of 3–4 thumbnail photos (80pt x 60pt, md radius). Tap to enlarge.

- **"Select Preferred" Button:** PrimaryBtn per column (pill, 44pt). Below all rows.
- **AI Recommendation Card:** Bottom card (SurfaceContainerLow, XL radius, sparkles icon). "Based on your preferences, [Dorm X] is your best match because..." Body Medium.

---

## Screen K3: Roommate Compatibility Quiz

**Layout:** Same centered layout as K1 (600pt max width). Sidebar hidden.

- **Header:** "Roommate Compatibility" Headline Large, centered. Subtitle: "Help us find your ideal roommate" Body Medium.
- **Category Progress Icons:** Horizontal row of 7+ categories: Food Sharing, Guests, Music, Study Habits, Weekends, Pets, Decoration. Same circle style as K1 — completed = Primary fill, current = Primary outline + pulse, upcoming = Outline Variant.
- **Question Text:** Headline Small, centered. More detailed questions than K1. E.g., "How do you feel about sharing food and groceries?"
- **2x2 Emoji Answer Grid:** Same 140pt x 140pt cards as K1 with emoji + label + descriptor. Same selection behavior (Primary border, tint, checkmark).
  - E.g., for sharing food: "Share Everything" (handshake emoji), "Ask First" (raised hand emoji), "Keep Separate" (divider emoji), "Flexible" (arrows emoji).
- **Some questions use alternative input types:**
  - Likert scale: 5 horizontal circles (44pt each, Primary fill on select) with "Strongly Disagree" to "Strongly Agree" labels.
  - Slider: for noise tolerance, temperature preference. Primary track, Accent Lime thumb.
- **"Next" / "See Results" Button:** Same as K1.
- **Progress Bar:** Same thin bar at bottom.

---

## Screen K4: Roommate Finder

**Layout:** Master-detail — Left 40%, Right 60%.

**Left Panel (40%) — Matches List:**
- Header: "Potential Roommates" Headline Large. Count badge: "(14 matches)" Label Medium.
- **Sort Dropdown:** "Sort by: Best Match" Body Small, chevron.
- **Match Cards:** Vertical scroll. Each card (SurfaceContainerLow, XL radius, ambient shadow, 12pt padding):
  - Avatar circle (48pt, placeholder silhouette or initial). First name + last initial (Title Small bold). E.g., "Sarah M."
  - Compatibility % badge: circular badge (36pt). Color: Green (80%+) / Amber (60–79%) / Red (<60%). Percentage in white Label Small.
  - Top 3 trait chips: "Night Owl", "Quiet Study", "Neat". SurfaceContainerHigh pill LabelSmall.
  - College name (Body Small, On Surface Variant).
  - Selected card: Primary left border 4pt + slightly elevated.

**Right Panel (60%) — Profile Detail:**
- **Avatar** (80pt, centered) + Name (Headline Medium) + College (Body Medium, On Surface Variant).
- **Compatibility Ring:** Large ring chart (140pt diameter). Percentage in center (Display Small, Primary). "Compatibility" Label Medium below.
- **Radar Chart:** 6-axis radar (Sleep / Clean / Noise / Social / Study / Temp). Student's profile = Primary fill (20% opacity) + Primary stroke. Match's profile = Accent Lime fill (20% opacity) + Accent Lime stroke. Overlaid. 200pt diameter. Legend below.
- **Shared Preferences:** Section with green check items. "Both prefer: quiet study, neat room, early bedtime." Each item: ✓ green icon + text (Body Medium).
- **Differences:** Section with amber items. "Differs on: guest frequency, temperature." Each: ⚠ amber icon + text.
- **Action Buttons:**
  - "Send Introduction" PrimaryBtn (gradient pill, 48pt, full width). Envelope icon.
  - "Pass" outline button (Primary border, pill, 44pt, full width). X icon.
- **Privacy Note:** Body Small, Outline color. "Last names are hidden until both parties agree to connect. No personal contact info is shared."

---

## Screen K5: Housing Deadline Tracker

**Layout:** Timeline per college. Full width.

- **Header:** "Housing Deadlines" Headline Large.
- **College Tabs:** Horizontal tab row at top. Each tab = pill chip. Selected = Primary bg + white text. E.g., "University of Florida", "FSU", "UCF".

- **Per College Timeline:** Vertical timeline layout.
  - **Timeline Items:** Each item = card row (SurfaceContainerLow, LG radius, 16pt padding):
    - Left: Status indicator circle (24pt). Completed = Primary fill + white checkmark. Current = Primary outline + pulse. Upcoming = Outline Variant fill.
    - Center: Item name (Title Small bold). E.g., "Housing Application Opens", "Application Deadline", "Roommate Request Deadline", "Meal Plan Selection", "Move-in Date". Date below (Body Medium). Status chip: "Complete" green, "Due Soon" amber, "Upcoming" outline, "Overdue" red.
    - Right: Countdown text. "23 days" Label Medium or "Completed" green text.
    - Connector line between items: vertical line (Primary for completed, Outline Variant for upcoming, 2pt width).
  - **"Set Reminders" Toggles:** Each item has a small toggle switch (Primary when on) with "Remind me" label. 44pt touch.

---

## Screen L1: Profile View

**Layout:** Wide profile header + two-column grid below.

**Top Section — Profile Header:**
- Avatar (80pt circle, border 3pt Primary). Name in Headline Large (right of avatar). Career badge chip: "Pre-Med" Primary Container bg + white text pill. Grade: "12th Grade" Body Medium. School: "Coral Gables Senior High" Body Medium (On Surface Variant). Archetype: "The Ambitious Healer" Body Small italic.

- **Stats Row:** 4 equal-width stat cards (SurfaceContainerLow, XL radius, ambient shadow). Horizontal row below header.
  - "GPA" — "3.8" Title Large bold. "Weighted: 4.2" Body Small.
  - "SAT" — "1420" Title Large bold. "Goal: 1500" Body Small.
  - "Colleges" — "8" Title Large bold. "On your list" Body Small.
  - "Streak" — "23 days" Title Large bold (Accent Lime). Fire icon.

**Bottom Section — Two-Column Grid:**

**Left Column:**
- **Academics Card:** SurfaceContainerLow, XL radius. "Academics" Title Medium header. Grid of nav items (2-column): "AP Courses" (book icon), "Activities" (trophy icon), "Test Scores" (chart icon), "GPA Tracker" (trending-up icon). Each item = row with icon + label (Body Medium) + chevron. 44pt height each.
- **College Planning Card:** Same style. "College Planning" Title Medium. Items: "College List" (building icon), "Roadmap" (map icon), "Application Tracker" (clipboard icon), "Career Path" (compass icon).

**Right Column:**
- **Tools Card:** "Tools" Title Medium. Items: "AI Advisor" (sparkles icon), "Essay Hub" (edit icon), "Scholarships" (dollar icon), "Housing" (home icon).
- **Account Card:** "Account" Title Medium. Items: "Edit Profile" (user icon), "Notifications" (bell icon), "Privacy" (shield icon), "Help & Support" (help-circle icon), "Invite Code" (link icon), "Sign Out" (log-out icon, Error #ba1a1a text).

---

## Screen L2: Profile Settings

**Layout:** Centered form (680pt max width). Back arrow top-left.

- **Avatar Section:** Center-aligned. Avatar (96pt circle, Primary border 3pt). "Change Photo" link below (Primary text). "Remove" link (Outline text). Tap opens photo picker (camera / gallery / remove options).

- **Personal Information Section:** "Personal" Title Medium header.
  - First Name + Last Name: side-by-side TextFields (SurfaceContainerLowest, Outline border, LG radius, Primary focus).
  - School: TextField with autocomplete dropdown. Search icon.
  - Student ID: TextField (optional).
  - Grade: Dropdown (9th / 10th / 11th / 12th / College Freshman).
  - First-Generation Student: Toggle switch (Primary when on) + "I am a first-generation college student" Body Medium.

- **Academic Information Section:** "Academic" Title Medium header.
  - GPA: TextField (number input). "Unweighted" label.
  - Career Path: Dropdown populated from career quiz results.
  - SAT Score: TextField (number, 400–1600).
  - ACT Score: TextField (number, 1–36).

- **Contact Information Section:** "Contact" Title Medium header.
  - Email: Read-only field (gray bg). "Change email" link (Primary text) → verification flow.
  - Phone: TextField with formatting.

- **Action Buttons:** "Save" PrimaryBtn (gradient pill, 48pt, full width). "Cancel" outline button below (Primary border, pill).

---

## Screen L3: Notification Settings

**Layout:** Two-column form (680pt total width). Back arrow top-left.

- **Header:** "Notifications" Headline Large.

**Left Column — Reminders:**
- "Reminders" Title Medium header.
- Each toggle row (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - Toggle switch (Primary when on) on right. 44pt touch.
  - **Deadline Reminders:** Title Small. "Get notified before application deadlines." Body Small (On Surface Variant).
  - **Task Reminders:** Title Small. "Daily reminders for upcoming tasks." Body Small.
  - **Streak Reminders:** Title Small. "Don't break your streak! Evening nudge." Body Small.
  - **Test Date Reminders:** Title Small. "SAT/ACT registration and test date alerts." Body Small.

**Right Column — Content:**
- "Content" Title Medium header.
- Same toggle row style:
  - **Daily Tips:** Title Small. "Daily college prep tip or motivation." Body Small.
  - **New Scholarships:** Title Small. "Alerts when new matching scholarships are found." Body Small.
  - **App Updates:** Title Small. "New features and improvements." Body Small.
  - **AI Tips:** Title Small. "Personalized AI advisor suggestions." Body Small.

---

## Screen L4: Theme Settings

**Layout:** Centered (400pt max width). Back arrow top-left.

- **Header:** "Appearance" Headline Large, centered.

- **Three Selectable Cards:** Vertical stack, 16pt gap. Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding, full width):
  - **System Default:** Phone/tablet icon (32pt, centered). "System" Title Medium. "Match your device settings" Body Small. Preview thumbnail (80pt x 48pt, md radius): half light / half dark split.
  - **Light Mode:** Sun icon (32pt, centered). "Light" Title Medium. "Warm, paper-like feel" Body Small. Preview: light Surface #fff8f2 miniature screen.
  - **Dark Mode:** Moon icon (32pt, centered). "Dark" Title Medium. "Easy on the eyes" Body Small. Preview: dark Surface #1f1b15 miniature screen.
  - Selected card: Primary border (3pt) + green checkmark badge in top-right corner (24pt circle, Primary bg, white check).
  - Unselected: Outline Variant border (1pt).
  - Tap triggers live preview — the entire screen theme transitions smoothly (300ms ease).
  - Min 44pt touch per card.

---

## Screen L5: Privacy Settings

**Layout:** Centered (600pt max width). Back arrow top-left.

- **Header:** "Privacy & Data" Headline Large.

- **Toggle Settings:** Vertical stack of toggle rows (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - **Anonymous Usage Data:** Toggle (Primary when on). "Help improve Ladder by sharing anonymous usage data." Body Small.
  - **Peer Comparison:** Toggle. "Allow your anonymized stats to appear in school comparisons." Body Small.
  - **Visible to Counselor:** Toggle. "Let your school counselor view your progress and college list." Body Small.
  - **Visible to Parent/Guardian:** Toggle. "Allow connected parent/guardian to view your dashboard." Body Small.

- **Actions Section:** "Your Data" Title Medium. 16pt top margin.
  - **"Download My Data"** — Outline button (download icon, Primary border, LG radius, 44pt height, full width). "Download a copy of all your Ladder data."
  - **"Delete My Account"** — Outline button (trash icon, Error #ba1a1a border, Error text, LG radius, 44pt height, full width). "Permanently delete your account and all data."

- **Links Section:** Vertical list of link rows (48pt each, full width). Primary text + arrow-right icon:
  - "Privacy Policy"
  - "FERPA Rights"
  Each tappable, opens in-app browser or external link.

---

## Screen L6: Language Preferences

**Layout:** Centered (400pt max width). Back arrow top-left.

- **Header:** "Language" Headline Large, centered.

- **Radio Options:** Vertical stack of selectable rows (SurfaceContainerLow, LG radius, 16pt padding, 8pt spacing):
  - **English:** Radio circle (Primary fill when selected, Outline Variant when not). "English" Title Medium. Checkmark if selected.
  - **Espanol:** Radio circle. "Espanol" Title Medium.
  - **Kreyol Ayisyen:** Radio circle. "Kreyol Ayisyen" Title Medium.
  - Selected row: Primary left border (4pt) + Primary radio fill.
  - Each row 48pt min height, 44pt touch target on radio.

- **"More Coming" Note:** Body Small, Outline color, centered. "More languages coming soon. Request one at support@ladderedu.com."

- **"Save" Button:** PrimaryBtn (gradient pill, 48pt height, full width). Centered below options.

---

## Screen L7: Help & Support

**Layout:** Centered (600pt max width). Back arrow top-left.

- **Header:** "Help & Support" Headline Large.

- **FAQ Accordion:** "Frequently Asked Questions" Title Medium. Each FAQ item (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - Question in Title Small (bold) + chevron (rotates on expand). 44pt touch.
  - Answer in Body Medium, hidden by default. Expands with 200ms animation.
  - Questions:
    - "How is my match score calculated?"
    - "Is my data safe?"
    - "How do I connect with my counselor?"
    - "Can my parent see my essays?"

- **Contact Section:** "Get in Touch" Title Medium. 16pt top margin.
  - "Email Support" — card row (envelope icon + "support@ladderedu.com" + arrow). Opens email.
  - "Report a Bug" — card row (bug icon + "Let us know what went wrong" + arrow). Opens form.
  - "Feature Request" — card row (lightbulb icon + "Suggest an improvement" + arrow). Opens form.

- **Resources Section:** "Resources" Title Medium.
  - "User Guide" — card row (book icon + arrow).
  - "Video Tutorials" — card row (play-circle icon + arrow).

- **Version:** Centered at bottom. "Ladder v2.1.0" Body Small, Outline color.

---

## Screen L8: Legal / About

**Layout:** Centered (600pt max width). Back arrow top-left.

- **App Identity:** Center-aligned. App icon (80pt, XL radius, Ladder logo). "Ladder" Headline Medium below. "Version 2.1.0 (Build 145)" Body Small (Outline color).

- **Legal Links:** Vertical list of tappable rows (SurfaceContainerLow, LG radius, 48pt height, 8pt spacing):
  - "Terms of Service" — Title Small + arrow-right icon.
  - "Privacy Policy" — Title Small + arrow-right.
  - "FERPA Compliance" — Title Small + arrow-right.
  - "COPPA Compliance" — Title Small + arrow-right.
  - "Accessibility Statement" — Title Small + arrow-right.
  - "Open Source Licenses" — Title Small + arrow-right.
  Each row 44pt min touch target. Primary text. Opens in-app browser.

- **Footer:** Centered. "Made with love for students." Body Medium (On Surface Variant), italic. Below: "Ladder Education, Inc." Body Small (Outline color). Copyright year.

---

**Deliverable:** Design all 13 screens. Batch 9 of 12.
