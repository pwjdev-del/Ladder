-- 0002 — core student-facing tables (§2.2, §5, §6, §9, §11, §12).

-- -----------------------------------------------------------------------------
-- students — one per student user. PII fields DEK-encrypted at rest (§16.2).
-- -----------------------------------------------------------------------------
create table students (
    id                 uuid primary key default gen_random_uuid(),
    user_id            uuid not null unique references auth.users(id) on delete cascade,
    tenant_id          uuid not null references tenants(id) on delete cascade,
    grade_level        int,
    first_name_cipher  bytea,   -- DEK-encrypted
    last_name_cipher   bytea,
    dob_cipher         bytea,
    guardian_contact_cipher bytea,
    career_quiz_completed_at timestamptz,
    career_profile_vector_cipher bytea,
    created_at         timestamptz not null default now(),
    archived_at        timestamptz
);
create index idx_students_tenant on students(tenant_id);

alter table students enable row level security;

-- Students can only read their own row
create policy students_self
    on students
    for all
    using (user_id = auth.uid()
           and tenant_id::text = current_setting('app.tenant_id', true));

-- Counselor + admin can read students within their tenant (not their grades, see below)
create policy students_staff_read
    on students
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

-- Parent can read linked children via parent_links (policy applied to that table)

-- -----------------------------------------------------------------------------
-- grades — STUDENT-SELF-ONLY (§2.2, hard rule §20).
-- Encrypted at rest. NO counselor, admin, teacher, or founder policy exists.
-- -----------------------------------------------------------------------------
create table grades (
    id           uuid primary key default gen_random_uuid(),
    student_id   uuid not null references students(id) on delete cascade,
    tenant_id    uuid not null references tenants(id) on delete cascade,
    subject      text not null,
    period       text,
    score_cipher bytea not null,
    entered_at   timestamptz not null default now()
);
create index idx_grades_tenant_student on grades(tenant_id, student_id);

alter table grades enable row level security;

create policy grades_student_self_only
    on grades
    for all
    using (student_id in (select id from students where user_id = auth.uid())
           and tenant_id::text = current_setting('app.tenant_id', true));

-- Parents can VIEW (not write) grades of their linked children (§5 matrix)
create policy grades_parent_view
    on grades
    for select
    using (exists (select 1 from parent_links pl
                    where pl.parent_user_id = auth.uid()
                      and pl.student_id = grades.student_id)
           and tenant_id::text = current_setting('app.tenant_id', true));

-- -----------------------------------------------------------------------------
-- parent_links — many-to-many between parent accounts and students (§6.2).
-- -----------------------------------------------------------------------------
create table parent_links (
    parent_user_id uuid not null references auth.users(id) on delete cascade,
    student_id     uuid not null references students(id) on delete cascade,
    tenant_id      uuid not null references tenants(id) on delete cascade,
    relationship   text,
    created_at     timestamptz not null default now(),
    primary key (parent_user_id, student_id)
);

alter table parent_links enable row level security;

create policy parent_links_self
    on parent_links
    for all
    using ((parent_user_id = auth.uid()
            or student_id in (select id from students where user_id = auth.uid()))
           and tenant_id::text = current_setting('app.tenant_id', true));

-- -----------------------------------------------------------------------------
-- classes + teacher_schedules (§11.1, §12)
-- -----------------------------------------------------------------------------
create table classes (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    code         text not null,
    title        text not null,
    subject      text,
    grade_level  int,
    prereq_ids   uuid[] not null default '{}',
    max_capacity int not null default 30,
    created_at   timestamptz not null default now(),
    unique(tenant_id, code)
);

create table teacher_profiles (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    first_name_cipher bytea,
    last_name_cipher  bytea,
    teaching_style_tags text[] not null default '{}',
    notes_cipher bytea,
    created_at   timestamptz not null default now()
);

create table teacher_reviews (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    teacher_id   uuid not null references teacher_profiles(id) on delete cascade,
    period_label text not null,
    body_cipher  bytea not null,
    entered_by   uuid not null references auth.users(id),
    entered_at   timestamptz not null default now()
);

create table teacher_assignments (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    teacher_id   uuid not null references teacher_profiles(id) on delete cascade,
    class_id     uuid not null references classes(id) on delete cascade,
    period       text not null,
    room         text,
    created_at   timestamptz not null default now()
);

alter table classes enable row level security;
alter table teacher_profiles enable row level security;
alter table teacher_reviews enable row level security;
alter table teacher_assignments enable row level security;

-- Teacher reviews — ADMIN ONLY (§5).
create policy teacher_reviews_admin_only
    on teacher_reviews
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) = 'admin');

-- Teacher profiles + schedules — counselor + admin read, admin write (§5)
create policy teacher_profiles_staff_read
    on teacher_profiles
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy teacher_profiles_admin_write
    on teacher_profiles
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) = 'admin');

create policy teacher_assignments_staff_read
    on teacher_assignments
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy teacher_assignments_admin_write
    on teacher_assignments
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) = 'admin');

create policy classes_tenant_read
    on classes
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true));

create policy classes_staff_write
    on classes
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));
