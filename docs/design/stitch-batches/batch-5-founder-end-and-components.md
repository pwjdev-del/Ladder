# Ladder Stitch — Batch 5 of 6: Founder backdoor finish + components start (10 screens)

Paste this whole file into Stitch as one brief.

---

## Brand tokens

forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · status-red `#C94A3F` · status-amber `#D9A54A`.
Playfair Display serif (600–700) headline. Manrope sans (400–600) body. Caps 11pt +10% tracking UPPER.
Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals.

**Founder screens 1–5 use the dark utilitarian mood** (forest-900 surface, lime accents, mono-caps labels). **Shared components 6–10 use the light tenant shell** unless the component is founder-specific.

## Do NOT design

No teacher UI. No grades for non-student. No founder view of student data. Every AI state-changing suggestion needs visible human approve.

## Reference

`batcave_dashboard`, `utility_bay_&_skill_arsenal` for founder mood. Existing splash + dashboard for tenant components.

---

# Screens (10)

## 1. `founder_solo_people` — B2C families list

B2C families (parent + linked student accounts). Per §14.4, **NEVER names — only family hashes + structure + billing.**

- Top bar on forest-900: "Solo people" title caps + search icon.
- Filter chip row: All · Trial · Past due · New this week.
- List rows (56pt tall) on forest-700 row fill:
  - Left: family hash mono "#A7C3" in lime (readable anonymizer, first 4 chars of a hash).
  - Middle: "1 parent · 2 kids" structure counts.
  - Right: billing chip — "Paid" (green), "Trial" (lime), "Past due" (red).
- Tap a row → detail sheet (second artboard): billing history only + same family hash + "Export payment receipts" button. No names. No child data. No quiz answers. No grades.

## 2. `founder_feature_flags_per_tenant` — flag editor with Varun blocked state

- Tenant picker at top (dropdown chip showing current school, tap opens a bottom sheet with the full tenant list).
- Flag list, each row 72pt tall:
  - Left: mono key label ("feature.scheduling") in cream.
  - Middle: description sub-line ink-400 ("Enables the student schedule builder").
  - Right: **3-state toggle**:
    - **ON** — lime fill, forest text.
    - **OFF** — stone-200 fill, ink-600 text.
    - **BLOCKED BY VARUN** — status-amber 2pt border, amber tint fill. Expanded inline panel below the row shows: "Varun says: rule_4 — scheduling requires classes + teacher_data + student_profile" + "Apply fix" chip that flips the dependent flags.
- Save pill at bottom sticky "Save changes" — disabled while any row is in blocked state.
- Empty / read-only state (if tenant is archived): everything disabled with banner "This tenant is archived. Unarchive to edit flags."

## 3. `founder_varun_panel` — 10-rule explainer + "why can't I?"

- Serif display "Varun".
- Small-caps subcopy stone-200: "FEATURE DEPENDENCY VALIDATOR · NOT AN AI · DOES NOT READ STUDENT DATA."
- Rule list: 10 rows, each 64pt. Per row:
  - Caps label "RULE 1", "RULE 2", … in lime.
  - Rule text in cream (e.g., "auth OFF ⇒ all other flags OFF").
  - Tap row → inline expand showing an example violation scenario and the auto-fix.
- Bottom **Ask Varun card** on forest-700 fill:
  - Title caps "ASK VARUN".
  - Input "Why can't I turn off {flag_key}?" — flag key is a dropdown.
  - Response area: text returned by Varun showing the rule trace chain (e.g., "Rule 4 blocks this because feature.scheduling is ON and requires feature.classes, feature.teacher_data, feature.student_profile.").

## 4. `founder_impersonation_banner` — red full-width active-grant banner

Shown sticky at the top of every founder screen while an admin-initiated impersonation grant is active (max 15 min TTL).

- Full-width bar, 56pt tall, ignores safe area (extends into the notch area tint).
- Background: status-red solid.
- Left: warning-triangle icon (white) + two-line text stack: "Impersonation active" (bold, 14pt) + grantReason subtext ("Debugging schedule submit for {tenant}") ink-900 at 85%.
- Right: mono countdown `MM:SS` (ticking down) + ghost pill "Audit" that opens the grant's audit trail.
- On expiry: banner transitions to green "Grant expired" for 2 seconds, then slides away.

## 5. `founder_blocked_from_tenant_data` — §14.4 denial view

Shown if a founder session somehow reaches a tenant-data surface. The UI refuses to render tenant data; shows this in its place.

- Background: forest-900 solid, no header nav.
- Centered vertically:
  - Lock-with-shield icon in lime (96pt).
  - Serif display "Not available for founder sessions."
  - Body copy stone-200: "§14.4 — founder sessions are denied tenant data at the API, DB, and UI layers. This is by design."
- Secondary ghost link "View audit trail" that opens the attempted route's audit entry.
- No Back button, no tab bar — the only way out is via the system back gesture or Home.

## 6. `component_invite_code_display` — shown-once code card (detailed spec)

Already summarized in Batch 1 screen 6 but deliver the full states sheet here as a reusable component.

Five sub-artboards on one page:

- **State A default** (just-revealed): yellow-tint fill, status-amber 1pt border, 48pt mono code crisp, lime "Copy" pill, amber helper text, 10s lime countdown bar.
- **State B mid-countdown** (5s remaining): same but bar half-filled.
- **State C blurred** (post-countdown): code rendered blurred (8pt blur), helper text updated to "Code hidden. Generate a new one if needed." Copy button disabled.
- **State D copied** (just after tap): pill shows checkmark + "Copied" for 1.2s.
- **State E error** (code revoked mid-view): bar turns red, copy button replaced by "This code was revoked" in red.

Light-shell and dark-shell variants on the same page (dark variant used inside the founder surface — amber tint on forest-700 with slightly lower opacity).

## 7. `component_schedule_grid` — 7 × 5 grid in 3 density variants

Three sub-artboards on one page:

**Variant A — student builder (roomy):**
- 8 columns (period label + 5 days) × 8 rows (day header + 7 periods). Cell 72pt tall.
- Empty cell: "— pick a class —" in ink-400. Tap → opens the pick sheet.
- Filled cell: class title + small code caps + ghost "change".

**Variant B — counselor review (dense):**
- Cell 48pt tall. Class title + code caps only.
- Conflicting cells: red 2pt border + red-tinted fill + small caution triangle top-right.
- Tap a conflict cell opens a tooltip with the conflict message.

**Variant C — admin view (dense + teacher initials):**
- Same as counselor but each filled cell also shows a small rounded avatar initials chip with the teacher's initials in the top-right corner.

Keyboard focus + VoiceOver labels called out for each variant.

## 8. `component_data_dense_table` — sortable table

For counselor queue, admin tables, founder cards-of-cards views.

- Header row: caps labels with arrow icon on hover/focus indicating sort direction.
- Data rows: 44pt tall, 12pt horizontal padding.
- First column is sticky (stays pinned on horizontal scroll).
- Dynamic Type clamped to xxxLarge.
- Row states: default, hover, pressed, selected (lime tint bg), disabled (50% opacity).
- Zebra-striping optional toggle (show with and without).
- Empty state inside the table: centered icon + "No rows yet" + optional primary pill.
- Pagination footer: page indicator + prev/next chevrons.

Deliver both light-shell and founder-dark-shell variants.

## 9. `component_feature_flag_toggle` — 3-state toggle

Used in `founder_feature_flags_per_tenant` and Varun-powered surfaces.

Three states on one artboard with callouts:

- **ON:** lime-500 fill, forest-900 thumb (small circle on the right), label in cream on forest-700 row.
- **OFF:** stone-200 fill, paper thumb on the left, label in ink-600.
- **BLOCKED BY VARUN:** status-amber 2pt border with amber 15% fill, thumb locked to the OFF position with a tiny lock glyph. Row expands inline with Varun rule explainer + "Apply fix" chip.

On-tap ripple: lime 20% radial wipe 300ms from tap point.

## 10. `component_impersonation_banner` — alt placements

Already described in screen 4 above as used in founder; deliver here as a reusable component with **three placements**:

- **A — top-of-screen sticky** (default, over safe area), 56pt tall. The canonical founder view.
- **B — inline card** (used inside any scrollable view that starts an impersonation), same content, 16pt radius card, not sticky.
- **C — compact strip** (used during real-time operations where vertical space is scarce), 32pt tall, single-line "Impersonation · MM:SS · Audit".

Expiry + grant-revocation animations called out in notes.

---

Deliver `{screen_name}/screen.png` + `{screen_name}/code.html` + `{screen_name}/notes.md` for each.
