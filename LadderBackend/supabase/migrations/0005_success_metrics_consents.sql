-- 0005 — annual success metrics (§13), legal consents (§17.3), impersonation grants (§14.5).

create table success_metrics (
    id                 uuid primary key default gen_random_uuid(),
    tenant_id          uuid not null references tenants(id) on delete cascade,
    period_label       text not null,
    college_acceptance_count int,
    graduation_rate    numeric(5,2),
    custom_fields      jsonb not null default '{}'::jsonb,
    submitted_by       uuid not null references auth.users(id),
    submitted_at       timestamptz not null default now(),
    unique(tenant_id, period_label)
);

alter table success_metrics enable row level security;

create policy success_metrics_admin_write
    on success_metrics
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) = 'admin');

create policy success_metrics_founder_read
    on success_metrics
    for select
    using (current_setting('app.role', true) = 'founder');

-- -----------------------------------------------------------------------------
-- legal_acceptances — §17.3 T&Cs + Privacy + Parental Consent + AI Addendum
-- -----------------------------------------------------------------------------
create type legal_doc as enum ('terms', 'privacy', 'parental_consent', 'ai_addendum', 'dpa', 'liability');

create table legal_acceptances (
    id             uuid primary key default gen_random_uuid(),
    tenant_id      uuid references tenants(id) on delete cascade,
    user_id        uuid not null references auth.users(id) on delete cascade,
    doc            legal_doc not null,
    doc_version    text not null,
    accepted_at    timestamptz not null default now(),
    ip_hash        bytea,
    user_agent_hash bytea,
    dwell_seconds  int,
    on_behalf_of_student_id uuid references students(id)
);

create index idx_legal_user on legal_acceptances(user_id);

alter table legal_acceptances enable row level security;

create policy legal_self
    on legal_acceptances
    for all
    using (user_id = auth.uid());

create policy legal_staff_read
    on legal_acceptances
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

-- -----------------------------------------------------------------------------
-- impersonation_grants (§14.5) — admin-initiated, time-limited, audited.
-- -----------------------------------------------------------------------------
create table impersonation_grants (
    id             uuid primary key default gen_random_uuid(),
    tenant_id      uuid not null references tenants(id) on delete cascade,
    granted_by_user_id uuid not null references auth.users(id),
    grantee_user_id uuid not null references auth.users(id),
    reason         text not null,
    issued_at      timestamptz not null default now(),
    expires_at     timestamptz not null,
    revoked_at     timestamptz,
    constraint impersonation_max_ttl
        check (expires_at - issued_at <= interval '15 minutes')
);

alter table impersonation_grants enable row level security;

create policy impersonation_admin_issue
    on impersonation_grants
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) = 'admin');
