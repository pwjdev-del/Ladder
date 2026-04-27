# Ladder — SPEC v2 (post-PWJ Phase 1 sprint)
_Date: 2026-04-27 • Author: PWJ Product Manager_
_No interview conducted — founder delivered detailed vision directly. This document translates that vision into a buildable spec._

---

## 1. The Three Big Bets

**Bet 1 — The AI Brain.** Every competing product treats AI as a feature bolted on top. Ladder makes AI the substrate. Every piece of data the student has ever entered — career quiz answers, GPA, essays, college list, chat history, activity portfolio — is indexed, alive, and available to a personal advisor that reacts the moment anything changes. The brain gets smarter with every interaction because it builds a per-student long-term memory. No school counselor at a 1:400 ratio can do this. This is the product.

**Bet 2 — The Student Owns Their Data.** Students' data moves when students move. If a student transfers schools, their AI memory, their essays, their college list, their career history follow them. If they leave school altogether and go private, same. This isn't an incremental feature — it's an explicit promise that makes Ladder trustworthy to families who don't want to surrender their kid's data to an institution. School-to-school or school-to-private transitions are handled with a parent-approved transfer code, a clean audit trail, and a clear breakdown of what carries and what stays.

**Bet 3 — Extracurricular Intelligence, Not Extracurricular Lists.** Every college prep app tells kids "do a club." Ladder tells them which clubs, why those clubs, and whether their school actually has them. The ActivitySuggestionEngine (already built, currently quarantined) is extended with a curated, research-backed seed dataset that maps career clusters to specific named activities — not generic categories. Suggestions are filtered by the student's grade, GPA, time load, and geography. The AI advisor pulls from this context fluidly, not as a separate module.

---

## 2. Personal AI Assistant — Detailed Spec

### 2.1 The Core Mandate

The founder's framing verbatim: "The main selling point, the feature of this whole app, is the personal AI assistant who lives in your app, who reads everything you do, who reacts to everything you do, who learns from everything you as a person do."

This is not a chatbot with a system prompt. It is a session-persistent, memory-bearing, cascade-aware advisor. Three mandates follow: read, react, and learn.

### 2.2 Data Ownership Model

**Rule: the student's namespace is sacred.** All data a student inputs is stored under `auth.users.id` (the student's UUID), not under `tenant_id`. The tenant pointer is a routing label, not a data owner.

Affected data types and their ownership:
- Career quiz answers and career path history → student-owned
- GPA, SAT, transcript records → student-owned
- College list and MATCH/REACH/SAFETY classifications → student-owned
- Essay drafts → student-owned
- AI chat history (`student_ai_chats`) → student-owned
- Activity log (portfolio) → student-owned
- RIASEC responses → student-owned

**What school gets:** school-tenant counselors get the visibility defined in ADR-008 §2.11 — read access to `student_ai_chats` and `student_essays` for students assigned to them, gated by RLS, with explicit consent copy at signup. School admin gets none of the above. The school has zero write access to student-owned tables.

**What parent gets:** the parent-formatted summary defined in ADR-008 §2.10 — derived activity, lag detection, and counselor notes flagged `parent_visible = true`. Parents do not get raw chat transcripts or essay drafts.

**Privacy guarantee (marketing copy):** "Your AI counselor's notes about you, your essays, your goals — all of it lives in your account. Your school sees only what you choose to share."

Note: Per ADR-008 §2.11, for school-tenant students, the consent flow makes clear that the assigned counselor *can* see AI chats and essays. "Choose to share" in marketing copy refers to B2C students. Consent language must be different for school-tenant students at signup. This is a legal/copy requirement, not a system change.

### 2.3 Read-Everything Mandate

The AI advisor's system prompt is assembled at request time by a context injector that pulls from:

| Context source | When included |
|---|---|
| `students` row (grade, GPA, SAT, school, state, firstGen flag) | Always |
| Career path + major + career history (last 3 entries) | Always |
| Saved college list with MATCH/REACH/SAFETY tier | Always |
| Top 5 suggested activities (from `ActivitySuggestionEngine`) | Always |
| Active tasks overdue or due in 7 days | Always |
| Last 10 AI chat messages | Always (rolling window) |
| Long-term memory summary (§2.5) | Always |
| Relevant essay drafts | When student mentions essays or college |
| Transcript summary (GPA by year, AP courses, grade trends) | When student mentions academics, class planner, or SAT |
| State requirements status (FL Bright Futures progress) | When student is FL-resident or mentions scholarships |

Context window budget is managed server-side in the `ai-gateway` Edge Function (ADR-005). The injector is responsible for ranking and truncating to fit the model's context window, prioritizing recency and query relevance.

**Existing infra to build on:** the `ConnectionEngine` cascade architecture (IDEAS_DIGEST §9, currently quarantined at `Services/Legacy/Engines/ConnectionEngine.swift`, promoted to `Services/Engines/ConnectionEngine.swift` in ADR-008 Phase 2) is the trigger backbone. The AI context injector subscribes to the same state changes the ConnectionEngine cascades.

### 2.4 React-to-Everything Mandate

When any of the following events fire, the AI surfaces a proactive, ranked nudge to the student:

| Trigger event | Example nudge |
|---|---|
| Career path changes (quiz retaken, override picked) | "You shifted to Medical — your activity list just updated. Want to review what to prioritize?" |
| A college is saved | "You saved Duke — EA deadline is Oct 15. Want to build your essay timeline now?" |
| GPA or transcript updated | "Your GPA went up to 3.7. That moves 4 colleges from Reach to Match. Want to see them?" |
| A task goes overdue | "Your SAT registration deadline passed 3 days ago. Here's what to do now." |
| Grade level advances (annual) | "You're a junior now — this year is the hardest. Here's your priority list." |
| Essay draft edited | "You just saved your Common App essay draft. Want AI feedback on the first paragraph?" |
| Application status changes | "You got deferred from UF — here's how to write a strong LOCI." |

**Nudge delivery:** nudges surface as a ranked card on the Home tab urgency section, not as push notifications. One nudge visible at a time; student can dismiss or act. Dismissed nudges are logged (used for the learn-everything mandate). No more than 2 new nudges generated per session to prevent fatigue.

**Existing infra to build on:** the `NudgeRules` + `HandoffRouter` patterns referenced in the promoted Sia stack. The nudge card component plugs into the existing Dashboard urgency card pattern already designed for the Home tab (IDEAS_DIGEST §8, save-a-college cascade).

### 2.5 Learn-from-Everything Mandate

The AI advisor builds long-term memory per student. Memory is stored as compressed summary embeddings (vector) in a `student_memory_summaries` table, written by a `MemoryExtractorService` that runs at the end of each chat session.

**What gets extracted and stored:**

| Memory type | Example |
|---|---|
| Stated preferences | "Prefers large schools with strong Greek life; mentioned this in 3 separate sessions" |
| Rejected suggestions | "Dismissed 'join debate club' nudge 2x — do not resurface" |
| Communication tone preference | "Responds better to direct lists than paragraph explanations" |
| Goal clarity | "Undecided between pre-med and biomedical engineering as of Feb 2026" |
| Life context | "Works 15 hours/week; mentioned time constraints on extracurriculars" |

**How memory enters the context:** the `ai-gateway` context injector fetches the 3 most semantically relevant memory summaries (cosine similarity against the current user message embedding) and prepends them to the system prompt block.

**Privacy guardrail:** `student_memory_summaries` is student-owned per §2.2. School and parent surfaces have no read access. Memory can be cleared by the student from Profile → AI Settings → "Clear advisor memory."

**Required new schema:**
- `student_memory_summaries(id, student_user_id, summary_text, embedding vector(1536), created_at, session_id)`
- `student_nudge_log(id, student_user_id, nudge_type, trigger_event, dismissed boolean, acted boolean, created_at)` — feeds the learn mandate; dismissed nudges are suppressed from re-surfacing for 30 days.

**Required new infra note for architect:** vector similarity search requires `pgvector` extension enabled on the Supabase project. The migration `LadderBackend/supabase/migrations/0001_*.sql` should already reference this (per PLAN.md). Confirm before the AI brain spec lands.

### 2.6 User-Facing Product Principle

The AI is a counselor, not a boss. Per IDEAS_DIGEST §9 "suggestions-not-mandates rule" (already enforced in `ai-gateway/index.ts` system prompt, ADR-005): the AI always frames output as a suggestion, never a directive. The advisor's tone should feel like a knowledgeable older sibling, not a compliance checklist.

### 2.7 P0 Requirements for AI Brain

- [ ] Context injector assembles full student profile + rolling chat window + memory summaries before every AI request
- [ ] Proactive nudge generated and surfaced on Home tab when any of the 7 trigger events fire
- [ ] `MemoryExtractorService` runs after each chat session and writes summary to `student_memory_summaries`
- [ ] Student data stored under student UUID, never under tenant namespace
- [ ] "Clear advisor memory" action available in Profile → AI Settings

### 2.8 P1 (Post v1 AI Brain)

- [ ] Tone adaptation (detected from dismissal + response patterns, adjusted over time)
- [ ] Cross-device sync for memory summaries (iCloud backup fallback while Supabase is primary)
- [ ] AI proactively surfaces memory conflicts ("You said in January you wanted pre-med, but you just saved 5 business schools — want to talk about that?")

---

## 3. School Transfer + Conversion Flows — Detailed Spec

### 3.1 Overview

Students own their data. When a student moves schools — or exits the school system entirely — their data follows them. The school they leave loses access. The school they join gains access to the pointer, not the data.

There are two distinct flows:

- **Flow A: School-to-School Transfer** — student moves from school A to school B
- **Flow B: School-to-Private Conversion** — student exits school system; account becomes a B2C account

### 3.2 Flow A: School-to-School Transfer

**State diagram:**

```
Student initiates → [transfer_request: pending_parent]
    → Parent receives email
    → Parent approves → [transfer_request: approved, transfer_code issued]
    → Parent denies → [transfer_request: denied] → terminal
Student shares code with new school
    → New school admin enters code in Admin dashboard → Backend verifies HMAC + approval status
    → Verification passes → [transfer: complete] — tenant_id updated, school A loses visibility
    → Code expired (30d) → [transfer_request: expired] → student must restart
```

**Step-by-step:**

1. Student opens Profile → "Transfer to a new school" (visible to school-tenant students only; hidden for B2C)
2. Student confirms intent (1-tap confirmation modal with plain-English description of what happens)
3. Backend generates `transfer_code`: HMAC-SHA256 signed with a server-side secret, embedding `student_user_id + requested_at + expiry`. Stored in `school_transfers` table with `status = 'pending_parent'`.
4. Backend sends an email to `parent_email` from `parent_child_links` (ADR-008 §2.10). If no parent linked, student is prompted to enter parent email before proceeding.
5. Parent email contains: which student, current school, what transfers/what doesn't (see §3.4), a one-click Approve link, a one-click Deny link. No account required to approve.
6. Parent clicks Approve → backend marks `school_transfers.status = 'approved'`, `transfer_code` becomes valid for use.
7. Student shares transfer_code (displayed in-app, copy-able) with new school's admin.
8. New school admin opens Admin Dashboard → "Accept Transfer Student" → enters code.
9. Backend verifies: HMAC signature is valid, `status = 'approved'`, `expiry > now()`. On success:
   - `students.tenant_id` updated from school A's `tenant_id` to school B's `tenant_id`
   - `students.assigned_counselor_id` set to NULL (school B will assign)
   - `school_transfers.status` set to `'complete'`
   - School A counselors and admin immediately lose visibility (RLS enforces via `tenant_id`)
   - School A's counselor notes remain in `counselor_notes` table but are flagged `archived = true`; student can see them as read-only; school A staff cannot see them after transfer (RLS: counselor access requires `students.tenant_id = counselor.tenant_id`)
10. Student is notified in-app: "You're now at [New School]. Welcome!"

### 3.3 Flow B: School-to-Private Conversion

**State diagram:**

```
Student initiates → [conversion_request: pending_parent]
    → Parent receives email
    → Parent approves → [conversion: complete] — tenant_id set to NULL, role stays 'student'
    → Parent denies → [conversion_request: denied] → terminal
```

**Step-by-step:**

1. Student opens Profile → "Convert to private account (no school)" (visible to school-tenant students only)
2. Confirmation modal lists what turns off and what stays on (see §3.5)
3. Backend sets `school_transfers.flow_type = 'to_private'`, `status = 'pending_parent'`
4. Parent email: same structure as Flow A, but destination is "private account (no school)" instead of a new school. Approve and Deny links work identically.
5. Parent approves → backend:
   - `students.tenant_id` set to NULL
   - `students.assigned_counselor_id` set to NULL
   - `school_transfers.status` set to `'complete'`
6. No transfer code needed — the receiving party is the student themselves (no school admin step).
7. Student is notified in-app: "Your account is now private. Your data is all here."

### 3.4 What Carries Over (Both Flows)

| Data | Carries? | Notes |
|---|---|---|
| Career path history | Yes | Student-owned |
| College list (saved colleges) | Yes | Student-owned |
| MATCH/REACH/SAFETY classifications | Yes | Recomputed on first session at new school |
| Essay drafts | Yes | Student-owned |
| AI chat history | Yes | Student-owned |
| AI memory summaries | Yes | Student-owned |
| Activity log / portfolio | Yes | Student-owned |
| GPA, SAT scores, transcript records | Yes | Student-owned |
| Scholarship tracking | Yes | Student-owned |
| Gamification (streak, points, level) | Yes | Student-owned |
| Application tracker status | Yes | Student-owned |
| School A's class catalog suggestions | No | Class catalog belongs to school A's tenant |
| School A's counselor notes | Read-only archive | Archived, visible to student, invisible to school A post-transfer |
| School A's roadmap variant (if school-specific feature enabled) | No | School-specific feature; new school starts fresh |
| School A counselor's AI conversation access | Revoked | RLS enforces immediately on `tenant_id` change |

### 3.5 Feature States After School-to-Private Conversion

| Feature | Before (school-tenant) | After (private/B2C) |
|---|---|---|
| AI advisor | On | On |
| Career quiz | On | On |
| College list + matching | On | On |
| Activity tracking | On | On |
| Essay Hub | On | On |
| Scholarship search | On | On |
| Application tracker | On | On |
| Counselor messaging | On | OFF — no counselor assigned |
| Counselor's visibility into chats/essays | On | OFF — RLS removes access |
| School class catalog | On | OFF — school-specific feature |
| School-specific roadmap variant | On | OFF — school-specific feature |
| School counselor notes (new) | On | OFF — no counselor |
| Counselor Marketplace ("Find a Counselor") | OFF (school tenant) | ON — B2C students see marketplace per ADR-008 §2.12 |
| Parent dashboard (if parent linked) | On | On — parent_child_links survives |

### 3.6 Parent Email Template (Functional Specification)

Subject: `[Action Required] Your child's Ladder school transfer request`

Body must include (in plain English, not legalese):
- Student's name and their current school
- What is happening ("They requested to transfer to [New School]" or "They requested to remove their school connection")
- What carries over (their profile, AI counselor history, essays, college list — everything they've built stays with them)
- What turns off (clearly enumerated per §3.5 — no surprises)
- One-click Approve button (deep link to backend endpoint)
- One-click Deny button (same)
- Footer: "If you didn't expect this request, tap Deny and contact us at [support email]."

The email is sent via a Supabase Edge Function. Email provider (Resend or equivalent) is NOT yet built — this is an open infra dependency (see §5).

### 3.7 Audit Log Shape

Every state transition in the transfer flow writes to `audit_events`:

```
{
  event_type: 'school_transfer' | 'private_conversion',
  flow: 'a_to_b' | 'to_private',
  actor_role: 'student' | 'parent' | 'school_admin',
  actor_user_id: uuid,
  target_student_id: uuid,
  from_tenant_id: uuid | null,
  to_tenant_id: uuid | null,
  transfer_code_hash: text,  // HMAC hash, not the plaintext code
  status_transition: 'initiated → pending_parent' | 'pending_parent → approved' | etc.,
  created_at: timestamptz
}
```

Audit log entries are immutable (no update/delete RLS policy). Permanent record.

### 3.8 Required New Schema

- `school_transfers(id uuid pk, student_user_id uuid, flow_type text check (flow_type in ('a_to_b', 'to_private')), from_tenant_id uuid, to_tenant_id uuid nullable, transfer_code_hash text, status text check (status in ('pending_parent', 'approved', 'denied', 'complete', 'expired')), expires_at timestamptz, parent_email text, created_at, updated_at)`
- Index on `transfer_code_hash` for O(1) admin lookup
- `counselor_notes` table: add `archived boolean not null default false` column

### 3.9 P0 Requirements for Transfer

- [ ] Student can initiate transfer from Profile; backend generates HMAC-signed transfer_code and emails parent
- [ ] Parent one-click approval/denial via email link (no app account required to approve)
- [ ] New school admin can enter transfer_code in Admin Dashboard to accept student; backend verifies and updates `tenant_id`
- [ ] School-to-private conversion: same parent-approval flow, but tenant_id set to NULL
- [ ] All student-owned data carries over unchanged; school A counselors lose visibility immediately
- [ ] Full audit trail written to `audit_events` for every state transition

### 3.10 P1 (Post v1 Transfer)

- [ ] In-app transfer status tracker ("Your transfer code is valid for 27 more days")
- [ ] Transfer code re-generation (if expired, student can request a new one — requires fresh parent approval)
- [ ] School admin sees a roster of incoming/outgoing transfers in Admin Dashboard

---

## 4. Extracurricular Research Engine — Detailed Spec

### 4.1 The Problem with "Join a Club"

The existing `ActivitySuggestionEngine` (quarantined at `Services/Legacy/Engines/ActivitySuggestionEngine.swift`, to be promoted per ADR-008) maps 6 career clusters to 6 generic activity types rated 1–10. That's a useful skeleton. But "internship/job (importance: 9 for Medical)" tells a 9th grader nothing. They need to know: Science Olympiad. HOSA. Volunteering at a hospital (and which hospital has a student program). Cold-email guide to get research under a professor.

The engine must surface specific named activities, not categories.

### 4.2 Extended Suggestion Model

The promoted `ActivitySuggestionEngine` is extended with a richer suggestion object:

```json
{
  "id": "stem-science-olympiad",
  "name": "Science Olympiad",
  "description": "Team-based STEM competition covering 23 events across biology, chemistry, physics, engineering, and earth science. One of the most recognized extracurriculars for STEM applicants.",
  "career_clusters": ["STEM", "Medical"],
  "grade_levels": [9, 10, 11],
  "time_commitment_hrs_per_week": 3,
  "prerequisite_skills": ["general science interest"],
  "geographic_constraint": "national",
  "prestige_tier": 4,
  "source_citation": "Common Data Set aggregates; r/A2C accepted profile survey 2024",
  "school_club_match_key": "Science Olympiad",
  "online_available": false,
  "guide_link": null,
  "tags": ["competition", "team", "STEM"]
}
```

### 4.3 Research Seed — Source Hierarchy

The seed dataset (`LadderBackend/data/extracurricular_seed.json`) is curated from these sources, in credibility order:

1. **Common Data Set** — aggregate college-reported data on admitted class profiles (athletics, arts, leadership, research)
2. **NACAC State of College Admission** — annual survey of what AOs weigh
3. **Crimson Education public admitted-student profiles** — named activities per major/school
4. **Reddit r/ApplyingToCollege accepted profile threads** — high-volume, real-student data; filter for T50 admits
5. **College Confidential "what got me in" archives** — older but large sample
6. **US News College Rankings "admitted students" editorial** — curated summaries

Research artifact is a manual curation task. The architect should plan for 3-5 days of human research work to produce the first version of `extracurricular_seed.json` with 50-100 high-quality entries per career cluster (300-600 entries total). This is a Phase 4+ task, not blocked on any engineering.

### 4.4 Constraint Filter Logic

The engine does not suggest activities the student cannot actually do. Before surfacing a suggestion, apply these filters in order:

1. **Grade filter:** `suggestion.grade_levels` must include `student.grade`. (Don't suggest 12th-grade-only activities to a 9th grader.)
2. **GPA + class load filter:** if `student.gpa < 3.0` AND `student.ap_count >= 2`, suppress activities with `time_commitment_hrs_per_week > 5`. Struggling students don't need more load, they need depth in 1-2 things.
3. **Existing commitment filter:** if `student.active_activities.count >= 4`, surface only suggestions ranked prestige_tier 4–5 (depth over breadth signal). If `count >= 6`, surface a "You're at capacity — consider cutting one lower-value activity" nudge instead of adding.
4. **Geography filter for non-national activities:** `suggestion.geographic_constraint` must match `student.state` (or 'national' passes always). City-tier suggestions additionally check `student.city_or_metro`.
5. **School catalog cross-reference (school-tenant only):** if `school_admin` has uploaded a club catalog to the tenant, check if `suggestion.school_club_match_key` appears in that catalog. Three outcomes:
   - Match found → badge "Available at [School Name]"
   - No match → badge "Not at your school — you could start one" with a starter guide link
   - No catalog uploaded → no badge shown

### 4.5 B2C vs School-Tenant Suggestion Behavior

| | School-tenant student | B2C student |
|---|---|---|
| School catalog cross-reference | Yes, if admin uploaded catalog | No (no catalog) |
| City-specific suggestions | Yes (based on `students.city`) | Yes (based on `students.city`) |
| National suggestions | Yes | Yes |
| Remote/online suggestions | Yes | Yes |
| "Start a club" guide | Yes, with school context | Yes, generic |

City-tier suggestions example (to be added per metro in the seed): "NYC students: Stuyvesant STEM programs, Cooper Union Saturday programs, AMNH research internship, NYC DOE Youth Program." These are real named programs, curated per city, added to `extracurricular_seed.json` with `geographic_constraint: "NYC"`.

### 4.6 AI Advisor Integration

The AI advisor does NOT query the suggestion engine via a separate API call. The top 5 suggestions from the engine (post-filter) are included in the AI's context injection package (§2.3) as a structured block. When the student mentions extracurriculars, the AI weaves in that context naturally.

Example: student asks "what should I be doing this summer for med school?" — the AI advisor's context already contains their grade (10), GPA (3.6), career path (Medical), and top 5 filtered suggestions. The advisor answers with specific named suggestions, not a generic list.

The engine is a context source, not a separate query. This is a critical design decision — it keeps the advisor experience seamless.

### 4.7 Seed JSON Schema (formal, for the architect)

File path: `LadderBackend/data/extracurricular_seed.json`

```json
{
  "version": "1.0",
  "generated_at": "2026-04-27",
  "entries": [
    {
      "id": "string (slug, unique)",
      "name": "string",
      "description": "string (2-3 sentences, specific not generic)",
      "career_clusters": ["STEM" | "Medical" | "Business" | "Humanities" | "Sports" | "Law"],
      "grade_levels": [9 | 10 | 11 | 12],
      "time_commitment_hrs_per_week": "number",
      "prerequisite_skills": ["string"],
      "geographic_constraint": "national" | "state:FL" | "city:NYC" | "city:LA" | "remote",
      "prestige_tier": 1 | 2 | 3 | 4 | 5,
      "school_club_match_key": "string | null",
      "online_available": "boolean",
      "guide_link": "string | null",
      "source_citation": "string",
      "tags": ["string"]
    }
  ]
}
```

`prestige_tier` scale: 1 = low (any student can do), 3 = moderate (regional recognition), 5 = national-level (USAMO, Intel Science Fair, NMSF). Tier informs depth-over-breadth logic in §4.4.

### 4.8 Sample Entries by Career Cluster (illustrative, not exhaustive)

**STEM, grades 9-11:**
- Science Olympiad (national, tier 4)
- USACO Bronze → Silver competition (national, tier 4, online)
- USNCO (National Chemistry Olympiad) (national, tier 5)
- Build an open-source project on GitHub (national/remote, tier 2-4 depending on reach)
- Cold-email a professor for a summer research position (national, tier 3, guide included)

**Medical, grades 10-12:**
- HOSA (Health Occupations Students of America) (national, tier 4)
- Hospital volunteering — 100+ hours, patient-facing (local, tier 3)
- USABO (Biology Olympiad) (national, tier 5)
- Shadow a physician — 40+ hours (local, tier 2, guide to find opportunities)
- Red Cross First Aid certification + volunteer (national/local, tier 2)

**Business, grades 9-12:**
- DECA (national, tier 4)
- FBLA — Future Business Leaders of America (national, tier 3)
- Start a small business or freelance service (any geo, tier 3)
- Junior Achievement programs (local, tier 2)

**Humanities, grades 9-12:**
- Model United Nations — regional/national (national, tier 3-4)
- Start a literary magazine or newspaper at school (school-based, tier 2-3)
- Participate in speech and debate (NFL/NSDA) (national, tier 4)
- Submit to recognized youth writing competitions (national, tier 3)

**Sports:**
- Varsity sport with statistical tracking (school-based, tier 3-4)
- NCAA prep — highlight reel, coach outreach guide (national, tier 4-5 if D1-track)
- Refereeing / officiating for income + leadership (local, tier 2)
- Teach sports to younger kids / youth coaching (local, tier 2)

These are illustrative. The full seed requires the 3-5 day research sprint.

### 4.9 P0 Requirements for Extracurricular Engine

- [ ] `extracurricular_seed.json` populated with minimum 50 entries per career cluster, each with full schema fields
- [ ] Engine filter logic (grade, GPA/load, existing commitment count, geography) applied before suggestions surface
- [ ] School catalog cross-reference active for school-tenant students (requires admin to have uploaded catalog)
- [ ] Top 5 filtered suggestions included in AI advisor context injection package

### 4.10 P1 (Post v1 Extracurricular Engine)

- [ ] Student can mark a suggestion as "Not for me" — permanently suppressed from suggestions, logged as negative signal
- [ ] City-specific suggestion expansion beyond NYC/LA to top 20 metros
- [ ] Prestige-tier visual indicator in the UI ("highly selective colleges value this")
- [ ] "Start a club guide" — linked from suggestions not available at the student's school
- [ ] Activity longevity tracking per IDEAS_DIGEST §4 — start date per activity; display "4-year commitment" vs "1-year join" signal to the student

---

## 5. Sequencing

These three features are POST the current Phase 1-4 sprint plan. The sprint plan (PLAN.md) must complete Phases 1-4 first. Estimated earliest landing:

- **AI Brain:** after `MemoryExtractorService` is promoted (ADR-008 Phase 2, Batch 3), `AdvisorChatView` is un-quarantined (Batch 4, PR-I per ADR-008 §2.8), and `pgvector` is confirmed active in the Supabase project. Earliest: post-Batch 4.
- **School Transfer + Private Conversion:** depends on `parent_child_links` table (ADR-008 §5, in migrations 0002+0009), email Edge Function (NOT YET BUILT — Resend or equivalent, new dependency), and real Supabase auth (Phase 1 #1). The email Edge Function is a prerequisite that must be added to the backlog explicitly.
- **Extracurricular Engine:** depends on `ActivitySuggestionEngine` promotion (ADR-008 Phase 2, PR-G per §2.8) and the research artifact (3-5 days manual curation, parallelizable with any sprint). Earliest: post-Batch 4 engine promotion, assuming research runs in parallel.

**Critical new dependency not in PLAN.md:** an email delivery Edge Function (Resend API or equivalent). Required for the transfer flow parent approval email (§3.6) and potentially for nudge digests. This must be scoped and added to PLAN.md Phase 4 or a new Phase 5 before transfer work begins. The architect should spec this function alongside the invite-redeem Edge Function pattern already in the repo (`LadderBackend/supabase/functions/invite-redeem/index.ts`).

---

## 6. Open Questions for the Founder (max 4)

**Q1 — Consent copy discrepancy for school-tenant students.**
The marketing privacy guarantee ("your school sees only what you choose to share") contradicts ADR-008 §2.11, which gives school counselors automatic read access to AI chats and essays for school-enrolled students. The consent flow at signup must make this explicit. Should the marketing copy be revised to have two variants (B2C vs school-tenant), or should the counselor access model change to an opt-in per item? This is a legal and trust decision, not a product one.

**Q2 — Parent approval without a parent-linked account.**
The transfer flow requires emailing the parent. If no parent is linked in `parent_child_links` (ADR-008 §2.10 — established at signup or via invite code), the transfer cannot proceed. For students who signed up without linking a parent (common for older students, B2C signups), what is the fallback? Options: (a) student must link a parent before any transfer; (b) student manually enters parent email at transfer time (one-time, not persisted); (c) students over 18 can self-approve. The founder needs to pick one.

**Q3 — Transfer code delivery to the new school.**
The spec assumes the student shares the transfer_code with the new school admin manually (copy/paste or screenshot). Is that the intended UX, or should the student be able to enter the new school's admin email and have the backend email the code directly to the new admin? The second option removes friction but requires the new school admin's email to be discoverable (which requires a school directory or the student to look it up).

**Q4 — Extracurricular seed dataset ownership.**
The seed JSON requires 3-5 days of manual human curation per research sprint. Who does this research — the founder, an intern, or a contracted education researcher? And how does the seed stay current (college admissions trends shift year-to-year)? Define a refresh cadence and ownership before the Batch runs.
