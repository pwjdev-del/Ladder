# Ship Checklist — Ladder v1.0.0-rc.1
_Date: 2026-05-14 · Target submit: 2026-05-27_

---

## Before Merging `fix/v1.0-audit-sweep` to `main` (90 minutes)

This section is for the human founder to review code and understand the final state of the app before it ships.

### Code Review (60 minutes)

- [ ] **Read FOUNDER_SHIP_REVIEW_2026-05-14.md** in full. This is the CEO's final verdict, your decision gate, and the rationale for shipping with known issues.
  - [ ] Understand the 3 deploy-day gates (see "Before Deploying" section below).
  - [ ] Understand the 7 deferred items and WHY each was deferred (see CHANGELOG.md "Deferred to v1.0.1+").
  - [ ] Understand the risk acceptance: keyword-only safety + wipe-failure-silent are v1.0 acceptable IF TestFlight discloses them and v1.1 commits to fixes.

- [ ] **Read the diff between `ae1a364^..HEAD` (all commits shipped in this sweep).** Terminal command:
  ```
  cd ~/Desktop/LadderApp && git log --oneline ae1a364^..HEAD
  ```
  You should see 3 commits:
  - `ae1a364` — 30+ findings closed across 4 audits (core sweep)
  - `83a6e03` — PKCE-aware signup (session establishment fix)
  - `469e447` — 3 S1s + 4 S2s from code review / security re-audit (patch)
  
  Optional: run `git show ae1a364 | head -300` to see the largest commit.

- [ ] **Verify CHANGELOG.md is accurate.** You should see:
  - 16 Security + Bug Fixes items (each ≤25 words)
  - 4 AI Safety items (each ≤25 words)
  - 4 Product items
  - 5 Infrastructure items
  - 7 Deferred items with explicit WHY
  - 4 Known Issues at the end

### Scope Lock (15 minutes)

- [ ] **Sign off:** This is the v1.0 product. You are NOT adding the transfer flow, parent digest, marketplace, EC seed dataset, or theming. The Founder dashboard is intentional; the parent surface is intentional "coming soon". Any temptation to claw back v1.0.1 items will be rejected at PR review.

### Approval Gate (15 minutes)

- [ ] **Check the CI status:** Branch `fix/v1.0-audit-sweep` should show:
  - [ ] Deno Check: PASS (all 6 edge functions syntax valid)
  - [ ] SQL Migrations: PASS (0020–0023 clean DDL)
  - [ ] Swift Parse: PASS (no compile errors)
  - [ ] Git Checks: PASS (no merge markers, no trailing whitespace)

- [ ] **Merge the branch to `main`.** Once you're confident in the code review above, run:
  ```
  git checkout main && git merge fix/v1.0-audit-sweep
  ```

- [ ] **Tag the release candidate.** Run:
  ```
  git tag -a v1.0.0-rc.1 -m "Release candidate for App Store submission"
  git push origin main && git push origin v1.0.0-rc.1
  ```

---

## Before Deploying to Staging/Production (30 minutes)

These are the 3 deploy-day gates the CEO named. **If you skip any of them, the app will silently break for every user on first request.**

### Gate 1: Supabase Dashboard PGRST_DB_PRE_REQUEST (5 minutes)

**This is the single most critical step.** Without it, migration 0022's 25 RESTRICTIVE policies evaluate to NULL → every SELECT/INSERT returns 0 rows → app is bricked for students, counselors, and founders.

- [ ] 1. Go to [Supabase Dashboard](https://app.supabase.com) → Select your Ladder project
- [ ] 2. Click **Settings** (bottom left) → **API**
- [ ] 3. Scroll to **"Extra options"** section
- [ ] 4. Find the field labeled `PGRST_DB_PRE_REQUEST` (may be empty)
- [ ] 5. Set its value to:
  ```
  app.bind_session
  ```
- [ ] 6. Click **Save** → Wait 30 seconds for the change to propagate
- [ ] 7. **Verify it worked:** In Supabase **SQL Editor**, run:
  ```sql
  SELECT current_setting('app.role', true);
  ```
  If you see output (even `null`) without an error, the hook is active. ✅

### Gate 2: Vault Founder Signing Key (5 minutes)

The founder TOTP decryption key must be enrolled before any founder can log in. This is a one-time setup.

- [ ] 1. Open Terminal and run:
  ```
  openssl rand -hex 32
  ```
- [ ] 2. Copy the 64-character hex string it prints out
- [ ] 3. Go to [Supabase Dashboard](https://app.supabase.com) → **Settings** → **Vault**
- [ ] 4. Click **New secret**
- [ ] 5. Fill in:
  - **Name:** `founder_signing_key` (exactly)
  - **Value:** Paste the 64-character string
  - **Region:** Select your region
- [ ] 6. Click **Save**
- [ ] 7. Verify in Terminal that the secret exists:
  ```
  npx supabase secrets list
  ```
  You should see `founder_signing_key` in the output. ✅

### Gate 3: Deploy Edge Functions + SwiftData Alert (15 minutes)

Push the 6 Edge Functions and apply the wipe-failure UI alert before App Store submission.

- [ ] **Push database migrations first:**
  ```
  cd ~/Desktop/LadderApp && npx supabase db push
  ```
  Confirm output: `Finished supabase db push.`

- [ ] **Deploy all six edge functions (run each line):**
  ```
  npx supabase functions deploy ai-gateway
  npx supabase functions deploy founder-login
  npx supabase functions deploy invite-redeem
  npx supabase functions deploy bootstrap-user
  npx supabase functions deploy counselor-invite
  npx supabase functions deploy varun-validate
  ```
  Each should show: `Deployed Function <name>`

- [ ] **SwiftData wipe-failure alert (S3-NEW-1):**
  - [ ] Status: Should fix before TestFlight (not strictly blocking)
  - [ ] Location: `SupabaseAuthService.swift:289-296` (wipe result not surfaced to UI)
  - [ ] Change: Add `.alert("Sign-out failed", isPresented: $wipeFailureShown, actions: { Button("Restart app") { ... } })` that blocks signOut completion
  - [ ] If this is done: check it off. If deferred: document the risk acceptance in CHANGELOG.md (already done — see **Known Issues** section).

---

## Pre-TestFlight Verification (30 minutes)

Before you submit to TestFlight, run this test plan with a real device and real Supabase. **Do not skip this.**

- [ ] Open `TEST_PLAN_2026-05-14.md` and run through every test listed (Test 1 through Test 5, ~45 minutes).
  - [ ] **Test 1:** Student signup + SIA greeting (8 min)
  - [ ] **Test 2:** SIA conversation and streaming (5 min)
  - [ ] **Test 3:** Career quiz and question bank (6 min)
  - [ ] **Test 4:** Schedule builder and class picker (8 min)
  - [ ] **Test 5:** Sign out and back in (5 min)

- [ ] **Key subjective judgment calls (only you can answer):**
  - [ ] Does SIA's tone feel warm and human, or robotic?
  - [ ] Does the parent "Coming soon" screen feel intentional or look like a bug?
  - [ ] Do the career quiz questions feel age-appropriate for 16-year-olds?
  - [ ] Does founder TOTP feel professional and trustworthy?
  - [ ] Does sign-out/sign-in complete in ≤2 seconds?

- [ ] **If ALL tests pass and your judgment is "ready to ship":** proceed to **Before App Store Submission** below. If ANY test fails or subjective judgment is "not ready": file a detailed issue in DECISIONS.md with the exact failure and a recommendation (ship anyway with risk note vs. fix before submit).

---

## Before App Store Submission (5 minutes)

Final checklist before uploading the binary to App Store Connect.

- [ ] **Confirm build #:** In Xcode, open **Build Settings** → search `CURRENT_PROJECT_VERSION` → set to `1` (v1.0.0-rc.1)
- [ ] **Confirm version #:** Build Settings → search `MARKETING_VERSION` → set to `1.0.0-rc.1`
- [ ] **Run one final simulator test (iPhone 17 Pro Max):** Press Play in Xcode, sign up as test student, tap Advisor tab, wait for SIA greeting to appear. If blank → do not submit.
- [ ] **Create a git tag for the submission:**
  ```
  git tag -a v1.0.0-rc.1-submitted -m "Submitted to App Store $(date)"
  git push origin v1.0.0-rc.1-submitted
  ```
- [ ] **Upload to App Store Connect** (1 hour via Xcode Organizer).
- [ ] **Fill in TestFlight metadata:** description, privacy policy URL, contact info.
- [ ] **Add yourself as external tester** — TestFlight requires at least one external email to unlock the 90-day TestFlight window. Add a known advisor (e.g., your co-founder, your legal counsel).
- [ ] **Share TestFlight link** — once ready, generate the TestFlight URL and send to your test group (founders, school admins, counselors, students from pilot schools).

---

## Post-Submit (Monitoring)

Once TestFlight is live, monitor these metrics daily for the first week:

- [ ] **First-session SIA tone:** Ask 3 students: "Does SIA sound like a warm mentor or a corporate chatbot?" If majority say "corporate," log an issue for v1.0.1 system prompt refinement.
- [ ] **Sign-out/sign-in latency:** Use Xcode profiler to confirm <2 seconds on a real device. If >3 seconds, profile the SwiftData wipe and `bind_session()` RPC roundtrip.
- [ ] **Wipe failures:** Monitor Xcode device logs for `SwiftDataWipeRegistry` `.fault` entries. Even one is a FERPA shared-iPad risk — trigger an immediate v1.0.1 patch if seen.
- [ ] **Invite redemption:** Confirm zero `invite_invalid` logs from known-good codes. Any regression → immediate patch.
- [ ] **Founder TOTP lockout:** Confirm the 5-attempt throttle fires and recovers cleanly. Enterprise trust depends on this feeling professional.

---

## Estimated Time Budget

- **Before merge:** 90 min (code review, diff analysis, CI check, scope lock)
- **Deploy:** 30 min (3 gates + edge function deploy)
- **TEST_PLAN:** 45 min (5 tests, subjective judgment)
- **App Store submission:** 1 hour (Xcode Organizer, metadata, TestFlight invite)
- **Total:** ~3 hours before TestFlight is live

---

## Emergency Rollback Plan (if needed)

If TestFlight reveals a critical bug (e.g., every student can see every student's data, wipe failure silent > 5% of sessions, SIA crashes on first message):

1. **Do not deploy to production.** Keep v1.0.0-rc.1 in TestFlight only.
2. **File a critical issue** in DECISIONS.md with:
   - Exact reproduction steps
   - User impact (affects 100% of users, 5% of users, etc.)
   - Recommended fix (code change, data migration, etc.)
   - Estimated fix time (1 hour, 1 day, etc.)
3. **If fix time is <6 hours:** Fix on `main`, tag v1.0.0-rc.2, re-submit to TestFlight.
4. **If fix time is >6 hours:** Announce to TestFlight testers: "Paused while we address <issue>. New build coming by <date>." Target re-submit within 48 hours.

Nothing ships to production until every critical issue is closed. This is your quality gate.
