-- LadderBackend/supabase/migrations/0022_founder_restrictive_caseload.sql
--
-- DEPENDS ON: 0020 (founder TOTP) — app.bind_session pre-request hook must be live
-- before these RESTRICTIVE guards make sense. The RESTRICTIVE policies evaluate
-- NOT app.is_founder() for every authenticated query; if bind_session() is not wired
-- as a db-pre-request hook (S1-2), app.role will be NULL and is_founder() returns
-- false anyway — so the guard is a no-op until A1's hook is live. Ship both together.
--
-- DEPENDS ON: 0009 (app.is_founder() helper) — function already defined there.
--   DO NOT redefine app.is_founder() here. It is SECURITY DEFINER stable and shared.
--
-- Findings closed:
--   S3-4 — RESTRICTIVE founder guard on every tenant-scoped policy table
--   D4   — Counselor read of student_memory_summaries narrowed from tenant-wide
--           to caseload-only. Same narrowing applied to sia_safety_events.
--
-- =============================================================================
-- § 1 — S3-4: RESTRICTIVE guards on tenant-scoped tables
-- =============================================================================
--
-- Threat: S1-2 fix (bind_session as db-pre-request) goes live. A future bug mints
-- a JWT with app_metadata.role='founder' AND a tenant_id claim. Without a
-- RESTRICTIVE guard, the founder JWT would satisfy standard tenant-scoped policies
-- (e.g. students_staff_read: tenant_id match + role in ('counselor','admin')).
-- Role 'founder' is not in those lists, so the immediate risk is low — but any
-- future policy using "role NOT IN (...)" or a broad wildcard could open a path.
--
-- Defense-in-depth: add one RESTRICTIVE policy per table that uses
-- current_setting('app.tenant_id', ...) in its USING clause. The RESTRICTIVE
-- policy blocks ALL operations on the table when app.is_founder() is true.
-- Founders reach their own data via separate non-tenant-scoped policies
-- (e.g. tenants_founder_read, success_metrics_founder_read, founders_read_all_safety_events).
--
-- IMPORTANT: sia_safety_events is EXCLUDED from the no-founder RESTRICTIVE guard
-- because founders_read_all_safety_events (0019) is an INTENTIONAL compliance
-- bypass (see DECISIONS.md + migration 0019 comment). Adding NOT is_founder()
-- RESTRICTIVE on that table would silently break the mandatory-reporting audit path.
-- All other tables below follow the standard guard.
--
-- Tables covered (all have tenant-scoped policies using current_setting('app.tenant_id')):
--   students                 (0002: students_self, students_staff_read)
--   grades                   (0002: grades_student_self_only, grades_parent_view)
--   parent_links             (0002: parent_links_self)
--   teacher_reviews          (0002: teacher_reviews_admin_only)
--   teacher_profiles         (0002: teacher_profiles_staff_read, teacher_profiles_admin_write)
--   teacher_assignments      (0002: teacher_assignments_staff_read, teacher_assignments_admin_write)
--   classes                  (0002: classes_tenant_read, classes_staff_write)
--   scheduling_windows       (0003: windows_staff_write, windows_tenant_read)
--   schedules                (0003: schedules_student_self, schedules_staff)
--   schedule_events          (0003: schedule_events_staff_read)
--   quiz_answers             (0003: quiz_answers_student_self)
--   extracurricular_sessions (0003: extracurricular_student_self)
--   invite_codes             (0004: invite_staff_write, invite_student_parent_create)
--   feature_flags            (0004: flags_tenant_read)
--   audit_log                (0004: audit_tenant_staff_read)
--   ai_usage_ledger          (0004: ai_usage_tenant_read)
--   success_metrics          (0005: success_metrics_admin_write)
--   legal_acceptances        (0005: legal_staff_read)
--   impersonation_grants     (0005: impersonation_admin_issue)
--   counselor_assignments    (0009: counselor_assignments_self_read, counselor_assignments_admin_manage)
--   student_ai_chats         (0009: ai_chats_student_self, ai_chats_counselor_read)
--   student_essays           (0009: essays_student_self, essays_counselor_read)
--   counselor_notes          (0009: counselor_notes_counselor_own, counselor_notes_parent_read, counselor_notes_admin_read)
--   student_memory_summaries (0014: students_own_summaries, counselors_read_tenant_summaries)
--   student_nudge_log        (0014: students_own_nudges)
-- =============================================================================

-- ── students ──────────────────────────────────────────────────────────────────
drop policy if exists students_no_founder on students;
create policy students_no_founder
    on students
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy students_no_founder on students is
  'RESTRICTIVE guard: blocks all founder-role sessions from satisfying any PERMISSIVE '
  'policy on this table. Founders access tenant data via separate founder-scoped '
  'policies only. S3-4 fix — see SECURITY_AUDIT_2026-05-14.md.';

-- ── grades ────────────────────────────────────────────────────────────────────
drop policy if exists grades_no_founder on grades;
create policy grades_no_founder
    on grades
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy grades_no_founder on grades is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on grades. '
  'S3-4 fix.';

-- ── parent_links ──────────────────────────────────────────────────────────────
drop policy if exists parent_links_no_founder on parent_links;
create policy parent_links_no_founder
    on parent_links
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy parent_links_no_founder on parent_links is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on parent_links. '
  'S3-4 fix.';

-- ── teacher_reviews ───────────────────────────────────────────────────────────
drop policy if exists teacher_reviews_no_founder on teacher_reviews;
create policy teacher_reviews_no_founder
    on teacher_reviews
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy teacher_reviews_no_founder on teacher_reviews is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on teacher_reviews. '
  'S3-4 fix.';

-- ── teacher_profiles ──────────────────────────────────────────────────────────
drop policy if exists teacher_profiles_no_founder on teacher_profiles;
create policy teacher_profiles_no_founder
    on teacher_profiles
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy teacher_profiles_no_founder on teacher_profiles is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on teacher_profiles. '
  'S3-4 fix.';

-- ── teacher_assignments ───────────────────────────────────────────────────────
drop policy if exists teacher_assignments_no_founder on teacher_assignments;
create policy teacher_assignments_no_founder
    on teacher_assignments
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy teacher_assignments_no_founder on teacher_assignments is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on teacher_assignments. '
  'S3-4 fix.';

-- ── classes ───────────────────────────────────────────────────────────────────
drop policy if exists classes_no_founder on classes;
create policy classes_no_founder
    on classes
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy classes_no_founder on classes is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on classes. '
  'S3-4 fix.';

-- ── scheduling_windows ────────────────────────────────────────────────────────
drop policy if exists scheduling_windows_no_founder on scheduling_windows;
create policy scheduling_windows_no_founder
    on scheduling_windows
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy scheduling_windows_no_founder on scheduling_windows is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on scheduling_windows. '
  'S3-4 fix.';

-- ── schedules ─────────────────────────────────────────────────────────────────
drop policy if exists schedules_no_founder on schedules;
create policy schedules_no_founder
    on schedules
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy schedules_no_founder on schedules is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on schedules. '
  'S3-4 fix.';

-- ── schedule_events ───────────────────────────────────────────────────────────
drop policy if exists schedule_events_no_founder on schedule_events;
create policy schedule_events_no_founder
    on schedule_events
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy schedule_events_no_founder on schedule_events is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on schedule_events. '
  'S3-4 fix.';

-- ── quiz_answers ──────────────────────────────────────────────────────────────
drop policy if exists quiz_answers_no_founder on quiz_answers;
create policy quiz_answers_no_founder
    on quiz_answers
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy quiz_answers_no_founder on quiz_answers is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on quiz_answers. '
  'S3-4 fix.';

-- ── extracurricular_sessions ──────────────────────────────────────────────────
drop policy if exists extracurricular_sessions_no_founder on extracurricular_sessions;
create policy extracurricular_sessions_no_founder
    on extracurricular_sessions
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy extracurricular_sessions_no_founder on extracurricular_sessions is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on extracurricular_sessions. '
  'S3-4 fix.';

-- ── invite_codes ──────────────────────────────────────────────────────────────
drop policy if exists invite_codes_no_founder on invite_codes;
create policy invite_codes_no_founder
    on invite_codes
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy invite_codes_no_founder on invite_codes is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on invite_codes. '
  'S3-4 fix.';

-- ── feature_flags ─────────────────────────────────────────────────────────────
-- flags_founder_write uses app.is_founder() directly (not tenant_id scoped) so
-- a RESTRICTIVE guard would break it. We add the guard but exclude the founder
-- write path by noting that flags_founder_write does NOT use tenant_id scoping —
-- but a buggy claim with role=founder AND tenant_id would still satisfy
-- flags_tenant_read (tenant_id match, no role check). Guard is therefore needed.
-- flags_founder_write USING clause: app.is_founder() — when NOT app.is_founder()
-- is RESTRICTIVE, that policy also gets blocked. This is correct: a session with
-- a buggy founder claim cannot write flags. A legitimate founder session
-- (is_founder()=true) is blocked by RESTRICTIVE = zero rows. This is intentional —
-- founders write flags only through the vetted edge function (service role, bypasses RLS).
drop policy if exists feature_flags_no_founder on feature_flags;
create policy feature_flags_no_founder
    on feature_flags
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy feature_flags_no_founder on feature_flags is
  'RESTRICTIVE guard: blocks founder-role sessions from all PERMISSIVE policies. '
  'Legitimate founder flag writes flow through the Edge Function (service role, bypasses RLS). '
  'S3-4 fix.';

-- ── audit_log ─────────────────────────────────────────────────────────────────
-- audit_founder_read_metadata_only is a legitimate founder policy (no tenant_id scoping).
-- RESTRICTIVE guard here would break it. However per S3-4 the threat is specifically
-- a buggy founder+tenant_id claim satisfying tenant-scoped policies. audit_tenant_staff_read
-- requires role in ('counselor','admin'), so founder role does not satisfy it.
-- We still add the guard for defense-in-depth against future policy drift.
-- audit_founder_read_metadata_only uses: current_setting('app.role') = 'founder'
-- When RESTRICTIVE NOT is_founder() applies, a legitimate founder cannot read
-- audit_log via PostgREST. This is acceptable: audit reads for founders go through
-- a vetted RPC or edge function. NOTE: if you need direct PostgREST audit reads
-- for founders, REMOVE this guard and document in DECISIONS.md.
drop policy if exists audit_log_no_founder on audit_log;
create policy audit_log_no_founder
    on audit_log
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy audit_log_no_founder on audit_log is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on audit_log '
  'via PostgREST. Founder audit reads must go through a vetted service-role RPC. '
  'S3-4 fix. NOTE: if direct PostgREST audit reads for founders are needed, '
  'document in DECISIONS.md and remove this policy.';

-- ── ai_usage_ledger ───────────────────────────────────────────────────────────
-- ai_usage_founder_aggregate_only is a legitimate founder policy (no tenant join).
-- Same reasoning as audit_log above — guard blocks it via PostgREST, forcing
-- founder aggregate reads through an RPC. Acceptable for v1.0.
drop policy if exists ai_usage_ledger_no_founder on ai_usage_ledger;
create policy ai_usage_ledger_no_founder
    on ai_usage_ledger
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy ai_usage_ledger_no_founder on ai_usage_ledger is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on ai_usage_ledger '
  'via PostgREST. Founder aggregate reads must go through a vetted service-role RPC. '
  'S3-4 fix.';

-- ── success_metrics ───────────────────────────────────────────────────────────
-- success_metrics_founder_read is a legitimate founder policy (no tenant join).
-- Same pattern: guard blocks PostgREST founder reads; service-role RPC is the safe path.
drop policy if exists success_metrics_no_founder on success_metrics;
create policy success_metrics_no_founder
    on success_metrics
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy success_metrics_no_founder on success_metrics is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on success_metrics '
  'via PostgREST. S3-4 fix.';

-- ── legal_acceptances ─────────────────────────────────────────────────────────
drop policy if exists legal_acceptances_no_founder on legal_acceptances;
create policy legal_acceptances_no_founder
    on legal_acceptances
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy legal_acceptances_no_founder on legal_acceptances is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on legal_acceptances. '
  'S3-4 fix.';

-- ── impersonation_grants ──────────────────────────────────────────────────────
drop policy if exists impersonation_grants_no_founder on impersonation_grants;
create policy impersonation_grants_no_founder
    on impersonation_grants
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy impersonation_grants_no_founder on impersonation_grants is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on impersonation_grants. '
  'S3-4 fix.';

-- ── counselor_assignments ─────────────────────────────────────────────────────
drop policy if exists counselor_assignments_no_founder on counselor_assignments;
create policy counselor_assignments_no_founder
    on counselor_assignments
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy counselor_assignments_no_founder on counselor_assignments is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on counselor_assignments. '
  'S3-4 fix.';

-- ── student_ai_chats ──────────────────────────────────────────────────────────
drop policy if exists student_ai_chats_no_founder on student_ai_chats;
create policy student_ai_chats_no_founder
    on student_ai_chats
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy student_ai_chats_no_founder on student_ai_chats is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on student_ai_chats. '
  'S3-4 fix. ADR-008 §14.4: founder cannot see tenant student PII.';

-- ── student_essays ────────────────────────────────────────────────────────────
drop policy if exists student_essays_no_founder on student_essays;
create policy student_essays_no_founder
    on student_essays
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy student_essays_no_founder on student_essays is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on student_essays. '
  'S3-4 fix. ADR-008 §14.4.';

-- ── counselor_notes ───────────────────────────────────────────────────────────
drop policy if exists counselor_notes_no_founder on counselor_notes;
create policy counselor_notes_no_founder
    on counselor_notes
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy counselor_notes_no_founder on counselor_notes is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on counselor_notes. '
  'S3-4 fix.';

-- ── student_memory_summaries ──────────────────────────────────────────────────
drop policy if exists student_memory_summaries_no_founder on student_memory_summaries;
create policy student_memory_summaries_no_founder
    on student_memory_summaries
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy student_memory_summaries_no_founder on student_memory_summaries is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on student_memory_summaries. '
  'S3-4 fix. ADR-008 §14.4.';

-- ── student_nudge_log ─────────────────────────────────────────────────────────
drop policy if exists student_nudge_log_no_founder on student_nudge_log;
create policy student_nudge_log_no_founder
    on student_nudge_log
    as restrictive
    for all
    to authenticated
    using (not app.is_founder());

comment on policy student_nudge_log_no_founder on student_nudge_log is
  'RESTRICTIVE guard: founder sessions cannot satisfy any PERMISSIVE policy on student_nudge_log. '
  'S3-4 fix.';

-- =============================================================================
-- § 2 — D4: Caseload-only counselor read of student_memory_summaries
-- =============================================================================
--
-- Decision D4 (FIX_PLAN_2026-05-14, DECISIONS.md D-002 update):
-- The existing counselors_read_tenant_summaries policy (0014_sia_memory.sql:138)
-- grants tenant-wide read to any counselor in the tenant. D4 narrows this to
-- the counselor's assigned caseload only, matching the existing ai_chats_counselor_read
-- and essays_counselor_read patterns already in 0009.
--
-- Join path note: student_memory_summaries.student_user_id → auth.users.id
-- counselor_assignments.student_id → students.id (PK, not auth.users.id)
-- students.user_id → auth.users.id
-- Therefore the join is:
--   counselor_assignments ca
--     JOIN students s ON s.id = ca.student_id
--   WHERE ca.counselor_user_id = auth.uid()
--     AND s.user_id = student_memory_summaries.student_user_id
--     AND ca.removed_at IS NULL
-- We also scope ca.tenant_id to prevent a cross-tenant assignment edge case.
-- =============================================================================

drop policy if exists counselors_read_tenant_summaries on student_memory_summaries;

create policy counselors_read_caseload_summaries
    on student_memory_summaries
    for select
    to authenticated
    using (
        current_setting('app.role', true) = 'counselor'
        and exists (
            select 1
            from counselor_assignments ca
            join students s on s.id = ca.student_id
            where ca.counselor_user_id = auth.uid()
              and s.user_id = student_memory_summaries.student_user_id
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    );

comment on policy counselors_read_caseload_summaries on student_memory_summaries is
  'Counselors can SELECT memory summaries only for students in their assigned caseload '
  '(counselor_assignments with removed_at IS NULL). '
  'Replaces counselors_read_tenant_summaries (0014) which granted tenant-wide read. '
  'Decision D4 (FIX_PLAN_2026-05-14) + DECISIONS.md D-002 update. '
  'Join path: counselor_assignments.student_id → students.id → students.user_id '
  '= student_memory_summaries.student_user_id (auth.users.id). '
  'Cross-tenant reads are structurally blocked by ca.tenant_id = app.tenant_id.';

-- =============================================================================
-- § 3 — D4: Caseload-only counselor read of sia_safety_events
-- =============================================================================
--
-- 0019_sia_safety_events defines counselors_read_tenant_safety_events with
-- tenant-wide scope (same pattern as the summaries policy we just narrowed).
-- D4 + D-002 require consistent caseload-only scoping across all counselor
-- read surfaces. We apply the same narrowing here.
--
-- EXCEPTION: founders_read_all_safety_events (0019) is NOT touched.
-- That is an intentional mandatory-reporting compliance bypass per DECISIONS.md.
--
-- sia_safety_events.student_id → auth.users.id (naming drift noted in 0019).
-- Same join path as summaries but using sia_safety_events.student_id:
--   counselor_assignments ca JOIN students s ON s.id = ca.student_id
--   WHERE s.user_id = sia_safety_events.student_id
--
-- counselors_acknowledge_tenant_safety_events (UPDATE policy, 0019) also has
-- tenant-wide scope. We narrow it to caseload for the same reason.
-- =============================================================================

drop policy if exists "counselors_read_tenant_safety_events" on sia_safety_events;

create policy counselors_read_caseload_safety_events
    on sia_safety_events
    for select
    to authenticated
    using (
        current_setting('app.role', true) = 'counselor'
        and exists (
            select 1
            from counselor_assignments ca
            join students s on s.id = ca.student_id
            where ca.counselor_user_id = auth.uid()
              and s.user_id = sia_safety_events.student_id
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    );

comment on policy counselors_read_caseload_safety_events on sia_safety_events is
  'Counselors can SELECT safety events only for students in their assigned caseload. '
  'Replaces counselors_read_tenant_safety_events (0019) which granted tenant-wide read. '
  'Decision D4 (FIX_PLAN_2026-05-14) + DECISIONS.md D-002 update. '
  'Join path: counselor_assignments.student_id → students.id → students.user_id '
  '= sia_safety_events.student_id (auth.users.id). '
  'founders_read_all_safety_events (0019) is intentionally preserved — '
  'mandatory reporting compliance bypass per DECISIONS.md.';

drop policy if exists "counselors_acknowledge_tenant_safety_events" on sia_safety_events;

create policy counselors_acknowledge_caseload_safety_events
    on sia_safety_events
    for update
    to authenticated
    using (
        current_setting('app.role', true) = 'counselor'
        and exists (
            select 1
            from counselor_assignments ca
            join students s on s.id = ca.student_id
            where ca.counselor_user_id = auth.uid()
              and s.user_id = sia_safety_events.student_id
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    )
    with check (
        current_setting('app.role', true) = 'counselor'
        and exists (
            select 1
            from counselor_assignments ca
            join students s on s.id = ca.student_id
            where ca.counselor_user_id = auth.uid()
              and s.user_id = sia_safety_events.student_id
              and ca.tenant_id::text = current_setting('app.tenant_id', true)
              and ca.removed_at is null
        )
    );

comment on policy counselors_acknowledge_caseload_safety_events on sia_safety_events is
  'Counselors can UPDATE (acknowledge: reviewed_at, reviewed_by, notes) only for '
  'students in their assigned caseload. Replaces counselors_acknowledge_tenant_safety_events (0019). '
  'D4 + DECISIONS.md D-002. Same join path as counselors_read_caseload_safety_events.';

-- =============================================================================
-- § 4 — Out-of-scope findings (for human review, not actioned here)
-- =============================================================================
--
-- [OOS-1] Founder-scoped read policies that are now blocked via PostgREST by
-- the RESTRICTIVE guards added above:
--   - success_metrics_founder_read (0005)
--   - audit_founder_read_metadata_only (0004)
--   - ai_usage_founder_aggregate_only (0004)
-- These policies still exist but are unreachable from PostgREST while a founder
-- session is active (RESTRICTIVE NOT is_founder() blocks the row). Founders must
-- read this data via service-role RPCs. This is intentional (founder dashboard
-- should use RPCs, not raw PostgREST), but the RPCs need to exist — verify with A2.
--
-- [OOS-2] sia_safety_events: founders_read_all_safety_events (0019) is preserved
-- intentionally. The RESTRICTIVE guard in § 1 does NOT cover sia_safety_events
-- because the mandatory-reporting founder read is a documented DECISIONS.md exception.
-- If S3-4's threat model is extended to cover safety events, that decision must be
-- revisited in DECISIONS.md and a new migration created.
-- =============================================================================
