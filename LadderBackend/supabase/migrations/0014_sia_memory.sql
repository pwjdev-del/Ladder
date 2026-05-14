-- LadderBackend/supabase/migrations/0014_sia_memory.sql
-- SIA memory persistence + behavioral nudge log (T009).
--
-- Tables:
--   student_memory_summaries  — SIA session summaries + embeddings (RAG retrieval)
--   student_nudge_log         — behavioral nudge metadata (dismissed/acted tracking)
--
-- RLS decisions (DECISIONS.md D-002 + D-003):
--   D-002: counselors can read student_memory_summaries (not raw chat).
--          counselors have ZERO access to student_nudge_log — deliberate stricter default.
--   D-003: hard per-student isolation via auth.uid() = student_user_id for students.
--          counselor read on summaries is further restricted to same-tenant students
--          (counselor's session app.tenant_id must match the student's tenant_id).
--
-- pgvector (CREATE EXTENSION vector) is already enabled in migration 0001.
-- Do NOT re-enable it here.
--
-- tenant_id is added to both tables even though it is not in the spec wireframe.
-- Rationale: every behavioral table in this schema carries tenant_id for
--   (a) same-tenant RLS enforcement via current_setting('app.tenant_id', true),
--   (b) multi-tenant index efficiency,
--   (c) future hard-delete compliance sweeps scoped by tenant.
-- Omitting it would make the counselor policy unsound and break the project-wide
-- RLS contract established in 0001.

-- =============================================================================
-- student_memory_summaries
-- One row per SIA session summary. embedding is a 1536-dim vector for RAG.
-- session_id is nullable: allows non-session-scoped global summaries (e.g. weekly
-- digests) as well as per-session summaries.
-- =============================================================================
create table if not exists student_memory_summaries (
    id                uuid        primary key default gen_random_uuid(),
    tenant_id         uuid        not null references tenants(id) on delete cascade,
    student_user_id   uuid        not null references auth.users(id) on delete cascade,
    summary_text      text        not null,
    embedding         vector(1536),
    session_id        uuid,
    created_at        timestamptz not null default now()
);

-- Primary lookup: student's own history (most common query path).
create index if not exists student_memory_summaries_student_idx
    on student_memory_summaries(student_user_id);

-- Tenant-scoped student lookup: used by counselor policy and compliance sweeps.
create index if not exists student_memory_summaries_tenant_student_idx
    on student_memory_summaries(tenant_id, student_user_id);

-- ANN index for embedding similarity search (cosine). Only built when embedding
-- IS NOT NULL; the partial predicate keeps the index small while the column is
-- sparsely populated early in rollout.
-- ivfflat lists=100 is appropriate for up to ~1M rows; tune upward at scale.
create index if not exists student_memory_summaries_embedding_idx
    on student_memory_summaries
    using ivfflat (embedding vector_cosine_ops)
    with (lists = 100)
    where embedding is not null;

comment on table student_memory_summaries is
  'SIA per-session summaries with optional embeddings for RAG retrieval. '
  'Counselors can read summaries (NOT raw chat) for their assigned tenant students '
  'per DECISIONS.md D-002. Nudge log is strictly student-only — no counselor policy exists there.';

comment on column student_memory_summaries.embedding is
  'text-embedding-3-small 1536-dim vector. NULL until the SIA pipeline generates it. '
  'ANN search via ivfflat cosine index (partial, where embedding is not null).';

comment on column student_memory_summaries.session_id is
  'Optional reference to the originating SIA session. NULL for aggregate summaries '
  '(e.g. weekly digest). Not a hard FK — the sessions table does not exist yet (T011).';

-- =============================================================================
-- student_nudge_log
-- Behavioral metadata: which nudges were shown, dismissed, and acted upon.
-- COUNSELOR ACCESS: NONE — see D-002. Only the student and service-role see this.
-- nudge_type: categorizes the nudge (e.g. ''deadline_reminder'', ''essay_draft'',
--   ''grade_entry''). Free-form text; validated at the application layer.
-- trigger_event: optional machine event that caused the nudge (e.g. ''quiz_idle_7d'').
-- =============================================================================
create table if not exists student_nudge_log (
    id                uuid        primary key default gen_random_uuid(),
    tenant_id         uuid        not null references tenants(id) on delete cascade,
    student_user_id   uuid        not null references auth.users(id) on delete cascade,
    nudge_type        text        not null,
    trigger_event     text,
    dismissed         boolean     not null default false,
    acted             boolean     not null default false,
    created_at        timestamptz not null default now()
);

-- Primary lookup: student's own nudge history.
create index if not exists student_nudge_log_student_idx
    on student_nudge_log(student_user_id);

-- Tenant-scoped student lookup: for compliance sweeps.
create index if not exists student_nudge_log_tenant_student_idx
    on student_nudge_log(tenant_id, student_user_id);

-- Partial index for undismissed nudges — the common active-nudge query.
create index if not exists student_nudge_log_active_idx
    on student_nudge_log(student_user_id, created_at desc)
    where dismissed = false;

comment on table student_nudge_log is
  'Behavioral nudge metadata: shown, dismissed, acted. '
  'COUNSELOR ACCESS IS ZERO — deliberately stricter than summaries per DECISIONS.md D-002. '
  'No counselor, admin, founder, or parent policy is defined on this table.';

-- =============================================================================
-- RLS — student_memory_summaries
-- =============================================================================
alter table student_memory_summaries enable row level security;

-- Student: full CRUD on their own summaries.
drop policy if exists students_own_summaries on student_memory_summaries;
create policy students_own_summaries
    on student_memory_summaries
    for all
    to authenticated
    using (
        auth.uid() = student_user_id
        and tenant_id::text = current_setting('app.tenant_id', true)
    )
    with check (
        auth.uid() = student_user_id
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Counselor: SELECT-only, restricted to students in the counselor's tenant.
-- Tenant restriction is enforced by current_setting('app.tenant_id', true) which
-- is bound from the counselor's JWT at session start (app.bind_session()).
-- A counselor whose JWT carries tenant_id=X can only see summaries where
-- tenant_id = X. Cross-tenant reads are structurally impossible.
-- No assignment check is applied here (unlike ai_chats) — per D-002, counselors
-- can see all summaries for students within their tenant, not only their caseload.
-- If per-caseload scoping is required later, add a join to counselor_assignments.
drop policy if exists counselors_read_tenant_summaries on student_memory_summaries;
create policy counselors_read_tenant_summaries
    on student_memory_summaries
    for select
    to authenticated
    using (
        current_setting('app.role', true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

comment on policy counselors_read_tenant_summaries on student_memory_summaries is
  'Counselors can SELECT summaries for all students in their own tenant. '
  'Same-tenant enforcement is via current_setting(app.tenant_id) from the counselor JWT. '
  'Cross-tenant reads are structurally blocked. D-002 / D-003.';

-- =============================================================================
-- RLS — student_nudge_log
-- COUNSELOR, ADMIN, PARENT, FOUNDER: NO POLICY EXISTS ON THIS TABLE.
-- The absence of any policy for those roles is the enforcement mechanism.
-- =============================================================================
alter table student_nudge_log enable row level security;

-- Student: full CRUD on their own nudge rows.
drop policy if exists students_own_nudges on student_nudge_log;
create policy students_own_nudges
    on student_nudge_log
    for all
    to authenticated
    using (
        auth.uid() = student_user_id
        and tenant_id::text = current_setting('app.tenant_id', true)
    )
    with check (
        auth.uid() = student_user_id
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

comment on policy students_own_nudges on student_nudge_log is
  'Students can read and write their own nudge rows only. '
  'No other role has a policy on this table — counselors, admins, parents, and founders '
  'receive zero rows from any query by design (DECISIONS.md D-002).';
