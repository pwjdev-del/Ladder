# Founder Ship Review — Ladder v1.0
_Date: 2026-05-14 · Target launch: 2026-05-27 · Reviewer: Founder/CEO (PWJ)_

---

## Decision

**SHIP_IT — conditional on three deploy-day gates the human tester must close.**

The strongest thing about this: SIA is no longer a chatbot with a system prompt — it is a per-student, isolation-asserted, summary-only-to-counselor counseling surface with a safety floor, an SSE-streamed UI, and a real warm-mentor persona. That is the product, and it is in the build.

The weakest thing about this: a five-step manual checklist (`PGRST_DB_PRE_REQUEST` dashboard config, Vault FSK enrollment, six edge-function deploys, schema push, Xcode build) stands between the codebase and a working app, and missing step 4 silently bricks every role on first query. This is not a code problem; it is a deploy-runbook problem, and it is the single thing that can turn a green build into a black launch.

What I would change: nothing in code before 5/27. The B-01 invite hash mismatch, B-03 dead host, B-06 quiz softlock, B-04 schedule picker, and S1-CR1 SIA `studentId` are all closed in `ae1a364` and verified (`invite-redeem/index.ts:91`, `AIGatewayClient.swift:76-78`, `CareerQuizView.swift:231` real question bank, `ScheduleBuilderView.swift:99-104` picker via Menu, `AdvisorChatViewModel.swift:198` passes studentId). The keyword scanner now includes `violence_to_others` entries (`ai-gateway/index.ts:391-399`). The four ship-blockers are genuinely closed.

What I would absolutely not change: the v1.0 scope cut. Deferring transfer flow, parent digest, marketplace, EC seed dataset, and theming was the single most important decision in the calendar — and the temptation to claw any one of them back in the last 13 days would have killed launch. Hold the line.

---

## Hard questions answered

**1. Are launch blockers closed in code?** Yes. Verified each one against the diffs. Invite redeem now uses HMAC-SHA256 + hex-string RPC (migration 0021 + edge function rewrite). AI/Audit/Flag clients route through `AppConfiguration.aiGatewayBaseURL` and the pinned URLSession. Career quiz Q1 branches into real `q2_build` and `q2_story` chains across three grade bands. Schedule builder has per-period class pickers backed by the `classes` table with a labeled fallback catalog. SiaChatInput carries `studentId` end-to-end.

**2. Are pending follow-ups blockers for 5/27 or post-launch?** The dashboard `PGRST_DB_PRE_REQUEST` step is a **deploy-day blocker** — without it migration 0022's 25 RESTRICTIVE policies brick the app for every role. The other items (vault FSK enrollment, SwiftData `@Model` `userId` attributes, `NSFileProtectionComplete` entitlement, founder service-role RPCs, invite re-issuance, S2-NEW crypto hygiene) are post-launch acceptable IF the SwiftData wipe holds on every signOut. The test plan now explicitly calls out the dashboard step as the critical pre-launch operation.

**3. Is keyword-only safety enough for ages 13–18?** No, but it is enough for v1.0 with an honest disclosure to TestFlight cohort and a v1.1 ticket to ship an ML classifier. The harm-to-others gap from the red-team has been closed in code (`SAFETY_SIGNALS_USER` now has `violence_to_others` prefix-match entries). The model is also instructed to handle implicit ideation in the system prompt, and Gemini's native finishReason filter writes a canned 988 response when it intercepts. For a TestFlight launch to a known cohort, this is adequate. For a full B2C public push to 13-year-olds, no — we would need the classifier first. The launch decision implicitly accepts this delta.

**4. Are we promising more than we deliver?** Drift 1 from the intent audit (AWS in `LegalTexts.swift`) is fixed in the re-audit verification. The counselor caseload-only narrowing in migration 0022 is correctly reflected in the build (`SiaEngine+Counselor.swift` reads only assigned students). Parent dashboard is now an intentional "coming soon" placeholder, not a deceptive mock. Marketing-vs-code alignment is sound.

**5. Is the SwiftData-wipe-as-sole-defense acceptable?** Yes for v1.0, NO without surfacing wipe failures. The wipe is the right safeguard, `SwiftDataWipeRegistry.register(modelContainer)` is called in `LadderApp.init()`, and the wipe runs before signOut completes. The acceptable mitigation: a wipe-failure UI alert that blocks signOut completion (S3-NEW-1). This is a 1-hour change. Until that lands, the wipe-failure-silent path is technically a STORY_FAIL vector. **Add this before TestFlight cuts.**

---

## What I'd ship instead — none

The version I would ship is the version on `fix/v1.0-audit-sweep` at `ae1a364`. The scope is right, the persona is right, the privacy story is right, and the demo tells a story: "SIA is the school counselor every kid wishes they had, and your data is portable when you move." That is a sentence I can stand behind in a press release.

---

## Things to watch in the first week post-launch

1. **First-session SIA opener** — Day-1 "raw box" experience is not strictly enforced; the model may surface profile context too early. Watch counselor feedback on whether first-conversation feel matches the warm-mentor brief.
2. **Wipe failures** — track every `.fault` log on `SwiftDataWipeRegistry.wipeAll`. Even one failure on a shared iPad is a FERPA incident.
3. **Gemini native blocks** — `finishReason='SAFETY'` rate. If it spikes, the canned 988 response is generic and may feel disconnected from what the student said.
4. **Invite redemption telemetry** — confirm zero `invite_invalid` rate from valid codes (B-01/B-02 regression canary).
5. **Founder TOTP lockout** — confirm S2-1 5-attempt throttle fires and recovers cleanly. Enterprise trust depends on this feeling professional.

---

## Deploy-day gates (the human must confirm these BEFORE the App Store submit)

1. `PGRST_DB_PRE_REQUEST=app.bind_session` is set in Supabase dashboard.
2. Founder Vault secret `founder_signing_key` is enrolled.
3. SwiftData wipe-failure UI alert lands (S3-NEW-1, ~1 hour). If it does not, document the risk in CHANGELOG and ship anyway — but only with explicit founder sign-off.

**Verdict: SHIP_IT** (with the three deploy gates above closed by the human before App Store submission).
