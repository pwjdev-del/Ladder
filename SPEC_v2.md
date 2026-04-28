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

**Privacy guarantee — two variants:**
- **B2C students:** "Your AI counselor's notes about you, your essays, your goals — all of it lives in your account. Your data, your account."
- **School-tenant students:** "Your school's admin and counselor will see your AI chats, essays, and progress while you're enrolled here. When you transfer schools or leave, they lose access and the new school sees everything."

**Rationale (founder decision 2026-04-27):** "Your data is yours" means **tenant-portability**, not hiding from your current school. While enrolled at school A, that school (admin and counselor) has full visibility. Transfer A → B: data ports; A loses access automatically. Convert to private: school visibility revoked. Pure B2C from day 1: no school ever has access. The consent flow for school-tenant students makes this explicit at signup.

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

**NEW 3-stage approval model (founder decision 2026-04-27):** Students are NOT in the parent-approval loop. Students can sign up without a parent. Transfers require founder approval, then school-B admin approval.

**State diagram:**

```
Student initiates → [transfer_request: pending_founder_review]
    → Founder/Employee dashboard: "Pending Transfers"
    → Founder approves → [transfer_request: founder_approved_pending_school]
    → Founder denies → [transfer_request: denied] → terminal
    → Request lands in School B admin dashboard: "Incoming Transfers"
    → School B admin approves → [transfer_request: school_approved_complete] — tenant_id updated, school A loses access
    → School B admin denies → [transfer_request: denied] → terminal
```

**Step-by-step:**

1. Student opens Profile → "Transfer to a new school" (visible to school-tenant students only; hidden for B2C)
2. Student confirms intent (1-tap confirmation modal) and selects the destination school (or enters school name/ID)
3. Backend creates `transfer_requests` row: `{student_user_id, from_tenant_id, to_tenant_id (initially null), status: 'pending_founder_review'}`
4. Request lands in a **new "Pending Transfers" surface in the FounderDashboard**. Founder or authorized Ladder employee reviews each request.
5. Founder approves → backend marks `status = 'founder_approved_pending_school'`, sets `to_tenant_id` to the destination school's tenant ID, writes audit log.
6. Automatic notification triggers to School B admin: "Incoming student transfer request from [Student] at [School A]."
7. Request lands in **School B Admin Dashboard → "Incoming Transfers"** panel.
8. School B admin reviews and approves or denies:
   - **Approve** → backend: `students.tenant_id` updated from school A to school B, `assigned_counselor_id` set to NULL, `status = 'school_approved_complete'`, timestamp `completed_at`, audit log written.
   - **Deny** → backend: `status = 'denied'`, `denial_reason` recorded, audit log written.
9. On approval: school A counselors/admins lose visibility immediately (RLS enforces via `tenant_id` change). School A counselor notes archived and marked read-only.
10. Student is notified in-app: "Your transfer to [School B] was approved. Welcome!"

### 3.3 Flow B: School-to-Private Conversion

**Parent approval removed (founder decision 2026-04-27).** Students own the decision to go private.

**State diagram:**

```
Student initiates → [conversion_request: pending_completion]
    → Backend immediately:
       — sets students.tenant_id = NULL
       — sets assigned_counselor_id = NULL
       — marks archived = true for all school A counselor notes
       — writes audit log
    → [conversion_request: complete]
```

**Step-by-step:**

1. Student opens Profile → "Convert to private account (no school)" (visible to school-tenant students only)
2. Confirmation modal lists what turns off and what stays on (see §3.5)
3. Backend immediately:
   - Sets `students.tenant_id` to NULL
   - Sets `students.assigned_counselor_id` to NULL
   - Marks all counselor notes `archived = true` (student can read as history; school A staff cannot access)
   - Writes audit log entry
4. Student is notified in-app: "Your account is now private. Your data is all here."
5. All school-tenant features (counselor chat, school class catalog, school-specific roadmap) turn off immediately.

### 3.4 Signup Without Parent (Both Flows)

**Founder decision 2026-04-27:** Parents are NOT required for signup. Students can create an account without any parent linked. Parent linking is optional.

**B2C Signup flow:** email/password only. No parent email gate. No parent invite code required. Parent linking can be added later by the student (via an invite code the parent uses to link, or manually by the parent in their own signup).

**School-tenant signup flow:** school email required (tenant-gated). No parent gate. School admin or founder can link parents later via a separate flow if the school chooses.

**Consequence for transfer flow:** students without a linked parent can still transfer schools (approval is founder + school B admin, not parent-mediated).

### 3.5 What Carries Over (Both Flows)

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

### 3.6 Feature States After School-to-Private Conversion

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

### 3.7 Founder + School Admin Notification Spec

**Founder dashboard notification (in-app, at "Pending Transfers" surface):**
- Student name, requesting school, destination school (if selected)
- Timestamp of request
- Action buttons: Approve | Deny
- Deny reason text box (optional)

**In-app notification to founder:** "New transfer request: [Student] from [School A]" (triggers immediately on student initiation)

**School Admin notification (email + in-app, at "Incoming Transfers" panel):**
- Student name, requesting school
- Timestamp of founder approval
- What carries over (data continuity statement)
- Action buttons: Approve | Deny (with reason text box)

Email provider (Resend or equivalent) is NOT yet built — this is an open infra dependency (see §5).

### 3.8 Audit Log Shape

Every state transition in the transfer flow writes to `audit_events`:

```
{
  event_type: 'school_transfer' | 'private_conversion',
  flow: 'a_to_b' | 'to_private',
  actor_role: 'student' | 'founder' | 'school_admin',
  actor_user_id: uuid,
  target_student_id: uuid,
  from_tenant_id: uuid | null,
  to_tenant_id: uuid | null,
  status_transition: 'initiated → pending_founder_review' | 'founder_approved_pending_school' | etc.,
  created_at: timestamptz
}
```

Audit log entries are immutable (no update/delete RLS policy). Permanent record.

### 3.9 Required New Schema

**New table — `transfer_requests`:**
- `id uuid primary key`
- `student_user_id uuid not null references auth.users(id)`
- `from_tenant_id uuid not null`
- `to_tenant_id uuid null` (populated after founder approval)
- `status text not null check (status in ('pending_founder_review', 'founder_approved_pending_school', 'school_approved_complete', 'denied'))`
- `founder_decision_at timestamptz null`
- `school_decision_at timestamptz null`
- `completed_at timestamptz null`
- `denial_reason text null`
- `created_at timestamptz not null default now()`

**Columns added to `counselor_notes`:**
- `archived boolean not null default false`

**Why no transfer_code:** codes are replaced by the 3-stage approval workflow. Founder approval + school admin approval are the gates, not a shareable code.

### 3.10 P0 Requirements for Transfer

- [ ] Student can initiate transfer from Profile → transfer_request created in `pending_founder_review` status
- [ ] Founder/employee reviews pending transfers in FounderDashboard → "Pending Transfers" surface and approves/denies
- [ ] On founder approval: notification to school B admin; transfer_requests.to_tenant_id set; status → `founder_approved_pending_school`
- [ ] School B admin reviews and approves/denies from Admin Dashboard → "Incoming Transfers" panel
- [ ] On school approval: `students.tenant_id` updates; school A loses visibility immediately; audit trail written
- [ ] School-to-private conversion: immediate (no approval gate); `tenant_id` set to NULL; counselor notes archived
- [ ] All student-owned data carries over unchanged; full audit trail for every state transition

### 3.11 P1 (Post v1 Transfer)

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

## 6. Product Decisions (Resolved by Founder 2026-04-27)

**Q1 — Privacy guarantee variants (RESOLVED).**
**Decision:** Two marketing copy variants. B2C: "Your data, your account." School-tenant: "Your school's admin and counselor will see your AI chats, essays, and progress while you're enrolled here." Rationale: "your data is yours" means tenant-portability (§2.2), not hiding from current school. Consent flow for school students makes this explicit at signup.

**Q2 — Parent approval removed from transfers (RESOLVED).**
**Decision:** Parents are NOT required for signup or transfers. Students can create an account without a parent linked. Parent linking is optional (§3.4). Transfer approval is founder (founder/employee dashboard) + school B admin (school admin dashboard), not parent-mediated. Students without linked parents can still transfer.

**Q3 — Transfer code model replaced (RESOLVED).**
**Decision:** No transfer codes. 3-stage approval workflow instead (§3.2): Student initiates → Founder reviews in "Pending Transfers" dashboard → School B admin reviews in "Incoming Transfers" dashboard. Founder approval triggers notification to school B admin. School admin approval triggers `tenant_id` update and school A access revocation. Removes friction of student sharing codes.

**Q4 — Extracurricular seed dataset ownership (DEFAULT — PENDING FOUNDER CONFIRMATION).**
**Recommendation:** Founder + AI co-curate initially. Long-term: hire a part-time admissions counselor (per Ideas folder mentions of potential ambassadors) to refresh annually before app season starts (August). Mark as DEFAULT; founder to confirm implementation plan before Batch runs. No blocker — seed curation can parallelize with engine promotion work (§4.1, §4.7).
