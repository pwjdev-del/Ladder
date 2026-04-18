-- 0003 — scheduling engine + career quiz (§8.3, §11).

-- Scheduling windows — counselor/admin opens/closes (§11.2)
create table scheduling_windows (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    academic_year text not null,
    opens_at     timestamptz not null,
    closes_at    timestamptz not null,
    created_by   uuid not null references auth.users(id),
    created_at   timestamptz not null default now()
);

create table schedules (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    student_id   uuid not null references students(id) on delete cascade,
    window_id    uuid not null references scheduling_windows(id),
    state        text not null default 'DRAFT',
    picks_cipher bytea,
    submitted_at timestamptz,
    approved_at  timestamptz,
    approved_by  uuid references auth.users(id),
    notes_cipher bytea
);
create index idx_schedules_tenant_student on schedules(tenant_id, student_id);
create index idx_schedules_window on schedules(window_id);

-- Schedule audit (§11.3 — every state transition)
create table schedule_events (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    schedule_id  uuid not null references schedules(id) on delete cascade,
    from_state   text,
    to_state     text not null,
    actor_id     uuid not null references auth.users(id),
    diff_cipher  bytea,
    reason       text,
    ts           timestamptz not null default now()
);

alter table scheduling_windows enable row level security;
alter table schedules enable row level security;
alter table schedule_events enable row level security;

create policy windows_staff_write
    on scheduling_windows
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy windows_tenant_read
    on scheduling_windows
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true));

create policy schedules_student_self
    on schedules
    for all
    using (student_id in (select id from students where user_id = auth.uid())
           and tenant_id::text = current_setting('app.tenant_id', true));

create policy schedules_staff
    on schedules
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy schedule_events_staff_read
    on schedule_events
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

-- Career quiz answers — student-self (§8.3)
create table quiz_answers (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    student_id   uuid not null references students(id) on delete cascade,
    question_id  text not null,
    answer_cipher bytea not null,
    answered_at  timestamptz not null default now()
);
create index idx_quiz_answers_student on quiz_answers(student_id);

alter table quiz_answers enable row level security;

create policy quiz_answers_student_self
    on quiz_answers
    for all
    using (student_id in (select id from students where user_id = auth.uid())
           and tenant_id::text = current_setting('app.tenant_id', true));

-- Extracurricular sessions (§10) — iterative AI session state
create table extracurricular_sessions (
    id           uuid primary key default gen_random_uuid(),
    tenant_id    uuid not null references tenants(id) on delete cascade,
    student_id   uuid not null references students(id) on delete cascade,
    state_cipher bytea,
    updated_at   timestamptz not null default now()
);

alter table extracurricular_sessions enable row level security;

create policy extracurricular_student_self
    on extracurricular_sessions
    for all
    using (student_id in (select id from students where user_id = auth.uid())
           and tenant_id::text = current_setting('app.tenant_id', true));
