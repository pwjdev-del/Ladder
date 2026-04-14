You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 9 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

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

# Batch 9: Housing + Profile (13 screens)

## K1. HOUSING QUIZ
Centered container (600px max-width). Category progress icons at top (row of icons representing quiz sections, completed ones filled in Primary, current has ring indicator, upcoming in Outline Variant). Question text (Headline Small, Noto Serif). 2x2 option grid: each option is a card with emoji icon (32px), label (Title Small), and description (Body Small). Hover: Primary border highlight. Selected: Primary fill with white text and checkmark. Progress bar below (Primary fill, pill radius). Navigation: "Back" (outlined) and "Next" (PrimaryBtn).

## K2. DORM COMPARISON
Side-by-side comparison for 2-3 dorm options. Dorm selector dropdowns at top. Each column shows: photo carousel (XL radius, 200px height), dorm name (Title Large), comparison rows: Cost per Semester, Room Type (Single/Double/Suite), Distance to Campus, Amenities (icon chips), Meal Plan options, Student Rating (star rating). Green highlight on best value per row. AI recommendation card at bottom (SurfaceContainerLow, sparkles icon): suggesting best fit with reasoning. "Select as Preferred" PrimaryBtn per column.

## K3. ROOMMATE QUIZ
Same layout as K1 (centered 600px, category progress icons, 2x2 grid). More detailed lifestyle questions: sleep schedule, noise tolerance, study habits, cleanliness level, guest policy, temperature preference, shared items policy. Each option with descriptive emoji and text. Progress bar and navigation buttons.

## K4. ROOMMATE FINDER
Left panel (35%): Ranked match list. Each entry: avatar (40px circle), name, compatibility percentage (colored: green >80%, amber 60-80%), top 3 trait chips. Selected entry highlighted with Primary left border. Scrollable list sorted by match %.

Right panel (65%): Selected match detail. Large compatibility ring (centered, Primary fill showing %). Radar chart comparing your preferences vs. theirs (6 axes: Sleep, Cleanliness, Noise, Social, Study, Sharing). Shared preferences section (green checkmark chips). Different preferences section (amber chips with both values shown). Action buttons: "Send Introduction" (PrimaryBtn) + "Pass" (outlined). Privacy notice at bottom (Label Small, On Surface Variant): "Only shared preferences are visible. Contact info exchanged after mutual match."

## K5. HOUSING DEADLINES
College tabs at top (pill chips, horizontally scrollable). Per selected college: vertical timeline with milestone nodes. Milestones: Housing Application Opens, Housing Application Deadline, Roommate Selection Deadline, Meal Plan Selection, Move-In Date. Each milestone shows: date, status badge (Completed green, Upcoming amber, Overdue red), countdown (days remaining). "Set Reminders" bell icon button per milestone. Overall progress indicator per college.

## L1. PROFILE VIEW
Top section: Avatar (96px circle, SurfaceContainerHigh border), name (Headline Medium, Noto Serif), career path label, grade + school, archetype badge (from career quiz). Stats row: 4 metric cards (GPA, SAT Score, Activities Count, Applications). Two-column layout below. Left column: Academics section (GPA, courses, test scores) + College Planning section (college list, deadlines, essays status). Right column: Tools section (quick links to features) + Account section with "Sign Out" (Error red text, underline-on-hover). All sections are collapsible cards (SurfaceContainerLow, XL radius).

## L2. PROFILE SETTINGS
Centered form (680px max-width). Avatar at top (96px circle) with "Change Photo" link below (Primary, underline-on-hover). Three form sections as collapsible cards: Personal Information (name, DOB, gender, ethnicity), Academic Information (school, grade, GPA, intended major, career path), Contact Information (email, phone, address). All fields use TextFields (SurfaceContainerLowest, outline, focus:primary glow). "Save Changes" (PrimaryBtn) + "Cancel" (outlined) at bottom.

## L3. NOTIFICATION SETTINGS
Two-column layout (680px max-width, centered). Left column: Reminders section with toggles for Deadline Reminders, Application Due Dates, Test Date Reminders, Scholarship Deadlines, Meeting Reminders. Right column: Content section with toggles for New Scholarship Matches, AI Recommendations, Weekly Progress Summary, Tips & Resources. Web-specific section below: Email Notification toggle + Browser Push Notification toggle. Each toggle: label + description (Body Small, On Surface Variant) + switch (Primary when on).

## L4. THEME SETTINGS
Centered container (400px max-width). Three theme option cards stacked vertically: System Default, Light Mode, Dark Mode. Each card (SurfaceContainerLow, XL radius): theme name (Title Medium), small preview showing the app in that theme (160px height, md radius). Selected card: Primary border (2px) with checkmark badge. Live preview applies immediately on selection.

## L5. PRIVACY SETTINGS
Centered container (600px max-width). Toggle sections: Data Collection (allow anonymous usage analytics), Peer Comparison (include my data in aggregate comparisons), Counselor Access (allow counselor to view my profile), Parent Access (allow linked parent to view my progress). Each toggle with description text (Body Small, On Surface Variant). Separator space before danger zone: "Download My Data" (outlined button) + "Delete My Account" (Error red outlined button, hover:Error fill with white text). Policy links at bottom: Privacy Policy, Terms of Service (Primary, underline-on-hover).

## L6. LANGUAGE
Centered container (400px max-width). Radio button group: English (default), Espanol, Kreyol Ayisyen. Each option: radio circle + language name (Title Medium) + native name in parentheses. Selected radio filled Primary. "Save" PrimaryBtn at bottom.

## L7. HELP & SUPPORT
Centered container (600px max-width). FAQ section: accordion items (question as Title Small, answer as Body Medium, expand/collapse with chevron icon). Contact section: "Email Support" button (outlined, opens mailto), "Live Chat" button (PrimaryBtn, if available). Resources section: links to user guide, video tutorials, community forum. App version at bottom (Label Small, On Surface Variant).

## L8. LEGAL
Centered container (600px max-width). App icon (48px) + version number at top. Links list: Terms of Service, Privacy Policy, FERPA Compliance, COPPA Compliance, Accessibility Statement, Open Source Licenses. Each link: icon + label (Title Small, Primary, underline-on-hover) + brief description (Body Small, On Surface Variant). All links open in new tab/window.

---

**Deliverable:** Design all 13 screens at 1440px. Batch 9 of 12.
