-- Migration: 0019_sia_safety_events.sql
-- Creates the sia_safety_events table that the ai-gateway Edge Function writes to
-- whenever a safety signal is detected in a SIA chat session (T015).
--
-- Column names match the actual INSERT in ai-gateway/index.ts exactly:
--   tenant_id, student_id, flag_type, triggered_by, created_at
--
-- NOTE on naming drift from original spec:
--   Spec used student_user_id → code uses student_id
--   Spec used source           → code uses triggered_by
-- This migration uses the code's names. Do NOT rename without updating index.ts.
--
-- RLS rules (D-002 + D-003):
--   Students:   NO access. Safety events are for counselor triage. v1.1 decision.
--   Employees:  NO access.
--   Counselors: SELECT + UPDATE within their own tenant.
--   Founders:   SELECT across all tenants (compliance audit only — intentional
--               bypass of the tenant data wall; see comment on policy below).
--   Edge Function (service role): bypasses RLS for INSERT. No INSERT policy needed.

-- ── Table ─────────────────────────────────────────────────────────────────────

create table sia_safety_events (
    id            uuid        primary key default gen_random_uuid(),
    tenant_id     uuid        not null references tenants(id),
    -- student_id references auth.users.id directly.
    -- Matches the ai-gateway insert: student_id: user.user.id
    student_id    uuid        not null references auth.users(id),
    flag_type     text        not null,
    -- triggered_by: origin of the signal, e.g. 'response_scan', 'user_input_scan'
    -- Matches the ai-gateway insert: triggered_by: 'response_scan'
    triggered_by  text        not null,
    -- context_snippet: optional short excerpt for counselor triage context.
    -- NOT written by the Edge Function (v1.0). Counselors or future scan logic may populate.
    context_snippet text,
    created_at    timestamptz not null default now(),
    -- reviewed_at / reviewed_by / notes: counselor acknowledgment workflow.
    reviewed_at   timestamptz,
    reviewed_by   uuid        references auth.users(id),
    notes         text,
    -- Enforce known flag_type values. Extend this list in a new migration as needed.
    constraint sia_safety_events_flag_type_check
        check (flag_type in (
            'crisis_resource_mentioned',
            'crisis_topic_in_response',
            'user_input_crisis_signal'
        )),
    -- Enforce known triggered_by values.
    constraint sia_safety_events_triggered_by_check
        check (triggered_by in (
            'response_scan',
            'user_input_scan'
        ))
);

comment on table sia_safety_events is
  'Safety signals raised by the ai-gateway during SIA chat sessions. '
  'Written by the Edge Function (service role). Read by counselors for triage. '
  'Students cannot read their own rows — counselor visibility is intentional per D-002.';

comment on column sia_safety_events.student_id is
  'auth.users.id of the student whose session triggered the event. '
  'Matches the Edge Function insert column name (student_id, not student_user_id).';

comment on column sia_safety_events.triggered_by is
  'Origin of the safety signal: response_scan (model output) or user_input_scan '
  '(student message). Matches the Edge Function insert column name '
  '(triggered_by, not source).';

-- ── Indexes ───────────────────────────────────────────────────────────────────

-- Primary counselor dashboard query: unreviewed events for their tenant, newest first.
-- Partial index — only unreviewed rows are hot; reviewed rows are cold archive.
create index sia_safety_events_tenant_unreviewed_idx
    on sia_safety_events (tenant_id, created_at desc)
    where reviewed_at is null;

-- Support lookups by student (e.g. counselor viewing a student's safety history).
-- Also speeds the FK join if any upstream query joins on student_id.
create index sia_safety_events_student_idx
    on sia_safety_events (student_id);

-- ── RLS ───────────────────────────────────────────────────────────────────────

alter table sia_safety_events enable row level security;

-- Counselors: SELECT unreviewed + reviewed events for students in their tenant.
-- The app must set app.role and app.tenant_id in the session before querying.
create policy "counselors_read_tenant_safety_events"
    on sia_safety_events
    for select
    to authenticated
    using (
        current_setting('app.role',      true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Counselors: UPDATE to record reviewed_at, reviewed_by, notes.
-- Same tenant-scoping as SELECT above.
create policy "counselors_acknowledge_tenant_safety_events"
    on sia_safety_events
    for update
    to authenticated
    using (
        current_setting('app.role',      true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
    )
    with check (
        current_setting('app.role',      true) = 'counselor'
        and tenant_id::text = current_setting('app.tenant_id', true)
    );

-- Founders: READ across ALL tenants for compliance audit.
-- *** INTENTIONAL TENANT DATA-WALL BYPASS ***
-- Safety events are a compliance surface. Founders must be able to audit them
-- across all tenants for legal/safeguarding obligations (e.g. FERPA, mandatory
-- reporting). This is the only table where the standard "founder cannot see
-- tenant data" rule (ADR-008 §14.4) is explicitly suspended. Document any
-- change to this policy in DECISIONS.md before modifying.
create policy "founders_read_all_safety_events"
    on sia_safety_events
    for select
    to authenticated
    using (
        current_setting('app.role', true) = 'founder'
    );

-- No student policy. No employee policy. No anonymous policy.
-- INSERT is performed by the Edge Function under service-role, which bypasses RLS.
-- No INSERT policy is defined here — adding one would not restrict service-role but
-- would erroneously allow authenticated users with no specific policy to insert.
