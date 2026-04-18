-- 0004 — invite codes, feature flags, audit log, AI usage ledger.

-- -----------------------------------------------------------------------------
-- invite_codes (§6.1 B2B, §6.2 B2C parent)
-- -----------------------------------------------------------------------------
create type invite_kind as enum ('b2b_student_single', 'b2b_student_bulk', 'b2b_class_level', 'b2c_parent');

create table invite_codes (
    id                 uuid primary key default gen_random_uuid(),
    tenant_id          uuid not null references tenants(id) on delete cascade,
    kind               invite_kind not null,
    code_hash          bytea not null,           -- sha256(code), never plaintext
    code_prefix        text not null,            -- first 4 chars for UI display ("ABCD-...")
    created_by         uuid not null references auth.users(id),
    intended_email     text,
    intended_student_id uuid references students(id),
    allowed_email_domain text,
    expected_grade_level int,
    max_uses           int not null default 1,
    uses               int not null default 0,
    expires_at         timestamptz,
    revoked_at         timestamptz,
    created_at         timestamptz not null default now(),
    unique(tenant_id, code_hash)
);
create index idx_invite_tenant_kind on invite_codes(tenant_id, kind);

alter table invite_codes enable row level security;

create policy invite_staff_write
    on invite_codes
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy invite_student_parent_create
    on invite_codes
    for insert
    with check (tenant_id::text = current_setting('app.tenant_id', true)
                and kind = 'b2c_parent'
                and created_by = auth.uid());

-- -----------------------------------------------------------------------------
-- feature_flags per tenant (§14.3, §15)
-- -----------------------------------------------------------------------------
create table feature_flags (
    tenant_id    uuid not null references tenants(id) on delete cascade,
    flag_key     text not null,
    enabled      boolean not null default false,
    updated_by   uuid references auth.users(id),
    updated_at   timestamptz not null default now(),
    primary key (tenant_id, flag_key)
);

alter table feature_flags enable row level security;

-- Founder-only write; Varun validator runs in a separate Edge Function before write.
create policy flags_founder_write
    on feature_flags
    for all
    using (current_setting('app.role', true) = 'founder');

-- Tenant users can read (UI gating)
create policy flags_tenant_read
    on feature_flags
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true));

-- -----------------------------------------------------------------------------
-- audit_log — append-only (§16.4)
-- -----------------------------------------------------------------------------
create table audit_log (
    id          uuid primary key default gen_random_uuid(),
    tenant_id   uuid references tenants(id) on delete set null,
    actor_id    uuid references auth.users(id) on delete set null,
    actor_role  app_role,
    action      text not null,
    target_type text,
    target_id   uuid,
    metadata    jsonb,          -- NEVER raw PII payload; only field names + counts
    ts          timestamptz not null default now()
);
create index idx_audit_tenant_ts on audit_log(tenant_id, ts desc);
create index idx_audit_actor_ts on audit_log(actor_id, ts desc);

alter table audit_log enable row level security;

-- Everyone inserts via ai-gateway / backend service functions.
-- No one can UPDATE or DELETE — Postgres REVOKE at grant time.
revoke update, delete on audit_log from public;
revoke update, delete on audit_log from authenticated;

create policy audit_tenant_staff_read
    on audit_log
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy audit_founder_read_metadata_only
    on audit_log
    for select
    using (current_setting('app.role', true) = 'founder');

-- -----------------------------------------------------------------------------
-- ai_usage_ledger — per-tenant token + cost tracking (§8.4, §14.3)
-- -----------------------------------------------------------------------------
create table ai_usage_ledger (
    id            uuid primary key default gen_random_uuid(),
    tenant_id     uuid not null references tenants(id) on delete cascade,
    feature       text not null,
    model         text not null,
    in_tokens     int not null,
    out_tokens    int not null,
    cost_usd_micro bigint not null,        -- USD * 1e6, integer math
    user_id_hash  bytea not null,          -- hmac(user_id, tenant_dek); founders cannot join
    ts            timestamptz not null default now()
);
create index idx_ai_usage_tenant_ts on ai_usage_ledger(tenant_id, ts desc);

alter table ai_usage_ledger enable row level security;

create policy ai_usage_tenant_read
    on ai_usage_ledger
    for select
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) in ('counselor', 'admin'));

create policy ai_usage_founder_aggregate_only
    on ai_usage_ledger
    for select
    using (current_setting('app.role', true) = 'founder');

-- Per-tenant token budgets (§8.4)
alter table tenants add column ai_token_budget_month int not null default 200000;
alter table tenants add column ai_token_used_month int not null default 0;
alter table tenants add column ai_budget_reset_at timestamptz not null default date_trunc('month', now() + interval '1 month');
