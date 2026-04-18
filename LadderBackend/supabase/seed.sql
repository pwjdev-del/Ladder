-- Development seed — LWRPA pilot + two B2C families + fixtures for tests/isolation.
-- Never run in production.

-- Clean slate (safe because test-only DB)
truncate table
    schedule_events, schedules, scheduling_windows,
    quiz_answers, extracurricular_sessions, grades, parent_links,
    teacher_assignments, teacher_reviews, teacher_profiles, classes,
    invite_codes, feature_flags, audit_log, ai_usage_ledger,
    success_metrics, legal_acceptances, impersonation_grants,
    students, user_profiles, tenants
restart identity cascade;

-- LWRPA pilot
insert into tenants (id, type, slug, display_name, primary_color_hex, plan)
values
    ('00000000-0000-0000-0000-000000000001', 'school', 'lwrpa',
     'Lakewood Ranch Preparatory Academy', '#0A4B8F', 'pilot'),
    ('00000000-0000-0000-0000-000000000002', 'school', 'beta-school',
     'Beta Test School', '#B8860B', 'pilot'),
    ('00000000-0000-0000-0000-000000000010', 'family', 'family-smith',
     'Smith Family', null, 'free'),
    ('00000000-0000-0000-0000-000000000011', 'family', 'family-jones',
     'Jones Family', null, 'free');

-- NOTE: user_profiles rows are created by Supabase Auth signup trigger in real
-- usage. For local dev + tests, `scripts/seed-users.ts` signs up fixture users
-- via the Supabase Auth API and patches their profile claims here.
