# QA runbook — iOS simulator (Phase 7 of the CEO pipeline)

The CEO pipeline's Phase 7 QA step runs on a machine with Xcode and a live
simulator. The code-space agent cannot execute it from CI. This runbook is
what Kathan (or any engineer) executes locally before Phase 9 opens the PR.

## Pre-flight

```sh
make bootstrap       # one-time
cp .env.example .env
$EDITOR .env         # fill Supabase + Gemini + AWS + HMAC secrets
make dev             # starts Supabase, seeds LWRPA + 2 families, opens Xcode
```

## Golden-path test matrix

Test in this order. For each, note the screen, result, and any observed bug.

### 1. Landing — baseline render
- Launch on iPhone 15 sim. See 3 affordances + logo.
- Tap "Log in with your ID" → `B2CLoginView` renders.
- Tap back. Tap "Sign in through your school" → school picker with LWRPA visible.

### 2. Founder 30s trigger (§14.1)
- Back to Landing. Press-and-hold logo.
- Expected haptics: soft @15s, medium @25s, success @30s.
- Expected visuals: logo desaturates slightly at ~5s; ring starts appearing at ~15s; fills to 100% at 30s.
- At 30s, navigation pushes to `FounderLoginView`.
- Repeat with a 25s release — nothing should happen. Ring fades out.

### 3. School login flow
- Landing → "Sign in through your school" → pick LWRPA.
- Theme accent color should switch to LWRPA's `#0A4B8F`.
- "Sign in" section visible; "First time? Use your invite code" section visible.
- Paste any code and tap "Join with invite code" → `InviteRedemptionView`.

### 4. B2C signup — COPPA gate
- Landing → "Sign up as a student".
- Set DOB to 2017-01-01 (age ~9).
- See footnote: "Because you're under 13, a parent needs to approve…"
- Submit button should stay enabled (client doesn't block signup; backend COPPA trigger gates quiz writes).

### 5. Career quiz — grade-band picker
- Post-auth Student home → Career quiz.
- Segmented picker for K–2 / 3–5 / 6–8.
- Pick K–2 → first question renders.
- Pick an option → advances. (The full adaptive tree is backend-gated.)

### 6. Schedule builder gates
- Student → "Next year's schedule" while quiz is stale → see "Take the career quiz first" empty state.
- Simulate quiz freshness in code or DB → see scheduling window status.

### 7. Counselor queue — conflict rendering
- Switch to counselor role (manually in auth), open Counselor → Queue.
- Expect left rail to show submitted schedules with red/green pips.
- Tap a row → detail view shows ScheduleGrid + issue panel + Approve/Send back/Modify.

### 8. Founder backdoor safety
- Trigger 30s logo hold + sign in as founder.
- Verify: every tab (Schools, Solo people, Flags, Varun) renders WITHOUT student names, grades, quiz answers.
- Attempt to navigate to a student-facing view (via deep link or debug toggle).
  - Expected: `preconditionFailure` traps the app in Debug. In Release builds, `FounderBlockedView` renders with the §14.4 denial copy.

### 9. Varun flag editor
- Founder → Schools grid → school detail → Manage flags.
- Toggle `feature.scheduling` ON while `feature.classes` is OFF.
- Expected: Save button disabled; "Varun says" panel surfaces rule_4 with a one-tap "Apply fix".

### 10. Dynamic Type
- iOS Settings → Display & Brightness → Text Size → AX3.
- Return to app. Body text should scale. Dense tables (counselor queue) should clamp to xxxLarge.

## Regressions to check
- Legacy AWS flows (AWSManager, AppSyncManager) are quarantined but still compiled. Verify `LoginView.swift` (old) vs `B2CLoginView.swift` (new) do not both register as first screen.
- SwiftData + Supabase two-source-of-truth: ensure no stale offline SwiftData surfaces post-auth.

## Ship blockers to re-verify after fix
- `TenantContext.requireNonFounder` crashes the app in Debug if a founder lands on a tenant screen. Expected and correct per §14.4.
- `PinnedKeys.preflightOrCrash()` crashes a Release build if pins are placeholder. Test via `xcodebuild -configuration Release` after inserting a real pin byte swap.

## Exit criteria
Report findings in the PR body under "QA results". If any blocker surfaces, halt Phase 9 until a fix lands.
