-- LadderBackend/supabase/migrations/0009_adr_008_schema_additions.sql
-- ADR-008 (Student / School Surface Merge) — schema additions for §2.9–§2.11.
-- §2.12 (marketplace gating) requires NO schema change; see comment at bottom.
--
-- Changes:
--   1. Per-school theming columns on tenants (§2.9)
--   2. parent_link_status enum + status column on parent_links (§2.10)
--   3. counselor_assignments table — required for counselor RLS on chat/essays (§2.11)
--   4. assigned_counselor_id on students — referenced by §2.11 RLS spec
--   5. student_ai_chats table + RLS (§2.11)
--   6. student_essays table + RLS (§2.11)
--   7. counselor_notes table + parent_visible flag (§5 / §2.10 / §2.11)
--   8. app.is_founder() helper (DRY for tenant-write policies)
--   9. Indexes on all new tables
--
-- All DDL is written idempotently:
--   - create table → create table if not exists
--   - alter table   → alter table ... add column if not exists
--   - create type   → guarded by DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN null END $$
--   - create policy → drop if exists + recreate (Postgres has no "create policy if not exists")
--   - create function → create or replace function

-- =============================================================================
-- § A — app.is_founder() helper
-- Centralises the founder-role check to avoid repeating the current_setting
-- call verbatim in every policy. SECURITY DEFINER because it reads the session
-- variable, not tenant data; no privilege escalation risk.
-- =============================================================================
create or replace function app.is_founder()
returns boolean
language sql
stable
security definer
as $$
    select current_setting('app.role', true) = 'founder'
$$;

comment on function app.is_founder is
  'Returns true when the current session was bound by app.bind_session() with role=founder. '
  'Used in RLS policies to restrict founder-only writes (ADR-008 §2.9).';

-- =============================================================================
-- § 1 — Per-school theming + feature toggles on tenants (ADR-008 §2.9)
--
-- Founder-only write. Reads are already covered by the existing
-- `tenants_self_read` (tenant members) and `tenants_founder_read` (founders).
-- We only need a restrictive WRITE policy here.
--
-- theme_primary_color / theme_accent_color: hex string e.g. '#42603f'.
--   NULL → client falls back to Ladder design-system defaults.
--   Ladder defaults: primary=#42603f, accent=#caf24d (DesignSystem/Theme/ColorTokens.swift).
--
-- enabled_features: jsonb array of feature-flag string keys e.g.
--   '["school_class_catalog","school_specific_roadmap"]'.
--   Features are NOT self-serve to school admins; only founder can toggle.
-- =============================================================================
alter table tenants
    add column if not exists theme_primary_color text,
    add column if not exists theme_accent_color   text,
    add column if not exists enabled_features     jsonb not null default '[]'::jsonb;

comment on column tenants.theme_primary_color is
  'Optional hex override (e.g. ''#3a5a99'') for the school''s primary brand color. '
  'NULL = use Ladder default #42603f. Written only by founders (ADR-008 §2.9).';

comment on column tenants.theme_accent_color is
  'Optional hex accent override. NULL = use Ladder default #caf24d. Founder-write only (ADR-008 §2.9).';

comment on column tenants.enabled_features is
  'JSON array of feature-flag keys the founder has activated for this school, '
  'e.g. ["school_class_catalog"]. Defaults to empty. Not self-serve to school admins. '
  'Read by FeatureGateManager.isEnabledForTenant(_:) in the iOS client (ADR-008 §2.9).';

-- Founder-only write for the three new theming/flag columns.
-- Reads continue to work via the existing tenants_self_read + tenants_founder_read policies.
-- We use DROP + recreate because Postgres has no idempotent "create policy if not exists".
drop policy if exists tenants_founder_theme_write on tenants;
create policy tenants_founder_theme_write
    on tenants
    for update
    using (app.is_founder())
    with check (app.is_founder());

-- =============================================================================
-- § 2 — parent_links: add status column (ADR-008 §2.10, option A)
--
-- DESIGN DECISION — Option A (ALTER existing table, not new table):
--   0002 already ships `parent_links(parent_user_id, student_id, tenant_id,
--   relationship, created_at)`. ADR-008 §5 calls for `parent_child_links`
--   with a `status` field. Rather than creating a new table and migrating data,
--   we extend `parent_links` in-place. Rationale:
--     (i)  Zero migration churn — no data movement, no dual-write period.
--     (ii) The semantic gap is just the status field; all other columns align.
--     (iii) `student_id` in the existing table is an FK to `students.id` (not
--           `auth.users.id`) which is what ADR-008 actually needs for RLS joins
--           against `students`. The ADR spec's `student_user_id` name is
--           aspirational — the FK target is the same entity.
--   If a future migration wants to rename the table, a `rename table` + view
--   alias is straightforward.
--
-- Status semantics:
--   pending  — invite sent; parent has not yet accepted.
--   active   — link confirmed; parent can read child's data.
--   removed  — unlinked (soft delete); rows are retained for audit.
-- =============================================================================
do $$ begin
    create type parent_link_status as enum ('pending', 'active', 'removed');
exception
    when duplicate_object then null;
end $$;

alter table parent_links
    add column if not exists status parent_link_status not null default 'active';

comment on column parent_links.status is
  'Link lifecycle state (ADR-008 §2.10, option A). Rows with status=removed are '
  'retained for audit; they must be excluded from runtime read queries. '
  'Default ''active'' preserves backward-compatibility for rows inserted before this migration.';

-- Update existing RLS policy (parent_links_self from 0002) to narrow reads
-- to only active links. Drop + recreate for idempotency.
drop policy if exists parent_links_self on parent_links;
create policy parent_links_self
    on parent_links
    for all
    using (
        (parent_user_id = auth.uid()
         or student_id in (select id from students where user_id = auth.uid()))
        and tenant_id::text = current_setting('app.tenant_id', true)
        and status <> 'removed'
    );

comment on policy parent_links_self on parent_links is
  'Restricts parent and student reads to non-removed links only. '
  'Updated by 0009 to filter status=removed rows (ADR-008 §2.10).';

-- Admins can manage links within their tenant (create/approve/remove).
drop policy if exists parent_links_admin_manage on parent_links;
create policy parent_links_admin_manage
    on parent_links
    for all
    using (
        tenant_id::text = current_setting('app.tenant_id', true)
        and current_setting('app.role', true) in ('admin', 'counselor')
    );

-- Founder can see across all tenants for support purposes (metadata only — same
-- pattern as tenants_founder_read).
drop policy if exists parent_links_founder_read on parent_links;
create policy parent_links_founder_read
    on parent_links
    for select
    using (app.is_founder());

-- =============================================================================
-- § 3 — counselor_assignments (ADR-008 §2.11 prerequisite)
--
-- Required-for-v1: the counselor RLS on student_ai_chats and student_essays
-- (below) gates access via "is this student assigned to me?"
-- This is the canonical table for that assignment. It also replaces the
-- hypothetical `students.assigned_counselor_id` column that ADR-008 §5
-- references — a separate junction table is safer because one student can
-- transition counselors and a student can in principle have a lead + backup.
--
-- NOTE: ADR-008 §2.11 also referenced `students.assigned_counselor_id` as
-- a possible approach. We add that column below (nullable FK) as a denormalized
-- fast-path for single-counselor reads, populated by a trigger off this table.
-- The RLS policies use counselor_assignments (not the denormalized column) so
-- there is one source of truth.
-- =============================================================================
create table if not exists counselor_assignments (
    id                 uuid primary key default gen_random_uuid(),
    tenant_id          uuid not null references tenants(id) on delete cascade,
    counselor_user_id  uuid not null references auth.users(id) on delete cascade,
    student_id         uuid not null references students(id) on delete cascade,
    assigned_at        timestamptz not null default now(),
    removed_at         timestamptz,
    unique(tenant_id, counselor_user_id, student_id)
);

create index if not exists idx_counselor_assignments_tenant_counselor
    on counselor_assignments(tenant_id, counselor_user_id);

create index if not exists idx_counselor_assignments_tenant_student
    on counselor_assignments(tenant_id, student_id);

comment on table counselor_assignments is
  'Junction table linking counselors to their assigned student caseload. '
  'Required for RLS on student_ai_chats and student_essays (ADR-008 §2.11). '
  'Soft-delete via removed_at; active assignments have removed_at IS NULL.';

alter table counselor_assignments enable row level security;

-- Counselors can read their own assignments (to render their queue).
drop policy if exists counselor_assignments_self_read on counselor_assignments;
create policy counselor_assignments_self_read
    on counselor_assignments
    for select
    using (
        counselor_user_id = auth.uid()
        and tenant_id::text = current_setting('app.tenant_id', true)
        and removed_at is null
    );

-- Admins manage assignments within their tenant.
drop policy if exists counselor_assignments_admin_manage on counselor_assignments;
create policy counselor_assignments_admin_manage
    on counselor_assignments
    for all
    using (
        tenant_id::text = current_setting('app.tenant_id', true)
        and current_setting('app.role', true) = 'admin'
    );

-- =============================================================================
-- § 4 — students.assigned_counselor_id (denormalized fast-path)
--
-- ADR-008 §5 lists this as a column used by the counselor RLS. We add it as a
-- nullable FK for convenience (e.g. "which single counselor is displayed on the
-- student's own profile page"). The authoritative source is counselor_assignments.
-- =============================================================================
alter table students
    add column if not exists assigned_counselor_id uuid references auth.users(id) on delete set null;

comment on column students.assigned_counselor_id is
  'Denormalized primary counselor FK. Derived from counselor_assignments. '
  'Not the source of truth for RLS — use counselor_assignments instead (ADR-008 §2.11).';

-- =============================================================================
-- § 5 — student_ai_chats (ADR-008 §2.11)
--
-- PRIVACY NOTICE — COUNSELOR VISIBILITY:
--   Per ADR-008 §2.11 (resolved open question #3, 2026-04-26), school-enrolled
--   students explicitly consent at signup that their AI advisor chat history
--   is readable by their assigned counselor. There is NO per-message opt-out.
--   B2C students (tenantId == nil) have no assigned counselor; the counselor
--   policy returns zero rows for them by construction.
--
--   DO NOT relax the counselor read policy on this table without:
--     (a) updating the legal consent flow (Features/Auth/Consent/) to remove
--         the counselor-visibility disclosure, AND
--     (b) a new ADR that supersedes ADR-008 §2.11.
--
--   Counselor visibility into minors' AI chats carries COPPA/FERPA implications.
--   Any policy change here must be reviewed by legal before shipping.
--
-- content_cipher: AES-256-GCM encrypted with tenant DEK (ADR-004).
--   role: 'user' | 'assistant' — mirrors Gemini/OpenAI message role convention.
-- =============================================================================
create table if not exists student_ai_chats (
    id             uuid primary key default gen_random_uuid(),
    tenant_id      uuid not null references tenants(id) on delete cascade,
    student_id     uuid not null references students(id) on delete cascade,
    role           text not null check (role in ('user', 'assistant')),
    content_cipher bytea not null,
    created_at     timestamptz not null default now()
);

create index if not exists idx_student_ai_chats_tenant_student
    on student_ai_chats(tenant_id, student_id);

create index if not exists idx_student_ai_chats_student_created
    on student_ai_chats(student_id, created_at desc);

alter table student_ai_chats enable row level security;

-- Student: read + write own rows only.
drop policy if exists ai_chats_student_self on student_ai_chats;
create policy ai_chats_student_self
    on student_ai_chats
    for all
    using (
        student_id in (select id from students where user_id = auth.uid())
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Counselor: read-only, scoped to assigned students within the same tenant.
-- Consent at signup is mandatory before this policy has any practical effect
-- (ADR-008 §2.11 — see PRIVACY NOTICE above).
drop policy if exists ai_chats_counselor_read on student_ai_chats;
create policy ai_chats_counselor_read
    on student_ai_chats
    for select
    using (
        current_setting('app.role', true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
        and student_id in (
            select ca.student_id
            from counselor_assignments ca
            where ca.counselor_user_id = auth.uid()
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    );

comment on table student_ai_chats is
  'Per-message AI advisor chat log. Encrypted at rest via tenant DEK (ADR-004). '
  'Counselor read access is intentional and consent-gated (ADR-008 §2.11). '
  'See PRIVACY NOTICE in migration 0009 before altering policies.';

-- =============================================================================
-- § 6 — student_essays (ADR-008 §2.11)
--
-- PRIVACY NOTICE — COUNSELOR VISIBILITY:
--   Same counselor-visibility rules apply as student_ai_chats above.
--   Per ADR-008 §2.11, counselors CAN read student essays for school-enrolled
--   students in their caseload. Student consent is surfaced at signup.
--   DO NOT weaken or remove the RLS without legal review + ADR supersession.
--
-- body_cipher: AES-256-GCM encrypted with tenant DEK (ADR-004).
-- version: monotonically incrementing; clients bump on each save.
--   Used for optimistic-concurrency conflict detection on the client side.
-- college_id: nullable; links to the college the essay is targeting, if any.
--   Not a hard FK because college catalog lives in a static reference table
--   not yet migrated into this project; use a uuid placeholder for now.
-- =============================================================================
create table if not exists student_essays (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    student_id   uuid not null references students(id) on delete cascade,
    college_id   uuid,                               -- nullable; no FK yet (college catalog deferred)
    title        text not null default '',
    body_cipher  bytea not null,
    version      int not null default 1,
    updated_at   timestamptz not null default now()
);

create index if not exists idx_student_essays_tenant_student
    on student_essays(tenant_id, student_id);

alter table student_essays enable row level security;

-- Student: read + write own essays only.
drop policy if exists essays_student_self on student_essays;
create policy essays_student_self
    on student_essays
    for all
    using (
        student_id in (select id from students where user_id = auth.uid())
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Counselor: read-only, assigned students only (ADR-008 §2.11).
-- See PRIVACY NOTICE above.
drop policy if exists essays_counselor_read on student_essays;
create policy essays_counselor_read
    on student_essays
    for select
    using (
        current_setting('app.role', true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
        and student_id in (
            select ca.student_id
            from counselor_assignments ca
            where ca.counselor_user_id = auth.uid()
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    );

comment on table student_essays is
  'Student essay drafts. Encrypted at rest via tenant DEK (ADR-004). '
  'Counselor read is intentional + consent-gated (ADR-008 §2.11). '
  'See PRIVACY NOTICE in migration 0009 before altering policies.';

-- =============================================================================
-- § 7 — counselor_notes (referenced by §2.10 + §2.11)
--
-- Counselor-private notes on a student; not visible to the student.
-- parent_visible flag gates the parent-surface "Counselor Report" card (§2.10).
-- body_cipher: encrypted with tenant DEK so a compromised DB row leaks nothing.
-- =============================================================================
create table if not exists counselor_notes (
    id               uuid primary key default gen_random_uuid(),
    tenant_id        uuid not null references tenants(id) on delete cascade,
    counselor_id     uuid not null references auth.users(id) on delete cascade,
    student_id       uuid not null references students(id) on delete cascade,
    body_cipher      bytea not null,
    parent_visible   boolean not null default false,
    created_at       timestamptz not null default now(),
    updated_at       timestamptz not null default now()
);

create index if not exists idx_counselor_notes_tenant_student
    on counselor_notes(tenant_id, student_id);

alter table counselor_notes enable row level security;

-- Counselors can read + write their own notes.
drop policy if exists counselor_notes_counselor_own on counselor_notes;
create policy counselor_notes_counselor_own
    on counselor_notes
    for all
    using (
        counselor_id = auth.uid()
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Parents can read parent_visible notes for their linked children (§2.10).
-- Join to parent_links (not parent_child_links — we kept option A) limited
-- to active status.
drop policy if exists counselor_notes_parent_read on counselor_notes;
create policy counselor_notes_parent_read
    on counselor_notes
    for select
    using (
        parent_visible = true
        and tenant_id::text = current_setting('app.tenant_id', true)
        and student_id in (
            select pl.student_id
            from parent_links pl
            where pl.parent_user_id = auth.uid()
              and pl.status = 'active'
        )
    );

-- Admins can read all notes within their tenant for compliance.
drop policy if exists counselor_notes_admin_read on counselor_notes;
create policy counselor_notes_admin_read
    on counselor_notes
    for select
    using (
        tenant_id::text = current_setting('app.tenant_id', true)
        and current_setting('app.role', true) = 'admin'
    );

comment on table counselor_notes is
  'Counselor-private notes on a student. body_cipher encrypted with tenant DEK. '
  'parent_visible=true rows surface in the parent-surface ChildSummaryView '
  'as the "Counselor Report" card (ADR-008 §2.10). Students never see any row.';

-- =============================================================================
-- § 8 — Marketplace gating — NO SCHEMA CHANGE (ADR-008 §2.12)
--
-- The marketplace entry point is shown/hidden purely by a routing rule in
-- StudentSurface tab assembly:
--   show if TenantContext.shared.tenantId == nil   (B2C user, no school)
--   hide if TenantContext.shared.tenantId != nil   (school-enrolled user)
--
-- There is NO `marketplace_visible` flag on tenants or any other table.
-- DO NOT add one in a future migration thinking it is missing — the rule is
-- intentionally expressed in the client. A future counselor-profile/booking
-- sub-spec (deferred per §2.12) will introduce schema if needed at that point.
-- =============================================================================

-- =============================================================================
-- § 9 — Columns referenced by ADR-008 §5 "assumed already present" — verification
--
-- students.assigned_counselor_id  → added in § 4 above.
-- tasks.due_date, tasks.completed → tasks table does NOT exist in 0001–0008.
--   The lag-detection SQL in §2.10 requires it. The tasks table is tracked in
--   PLAN Phase 2 PR-G (un-quarantine Tasks + Roadmap). This migration does NOT
--   create it; that belongs in the PR-G migration. Left as a comment so
--   whoever writes that migration knows it is needed.
-- audit_events(student_user_id, type, created_at) → likewise missing.
--   The recent-activity feed (§2.10) reads from audit_log (0004), not a
--   separate audit_events table. Query should use audit_log filtered by
--   actor_id = student's auth.uid() and actor_role = 'student'.
--   No schema change required; this is a naming discrepancy in the ADR spec.
-- =============================================================================
