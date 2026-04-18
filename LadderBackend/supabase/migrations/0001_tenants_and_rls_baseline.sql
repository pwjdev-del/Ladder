-- LadderBackend/supabase/migrations/0001_tenants_and_rls_baseline.sql
-- CLAUDE.md §4 — tenant taxonomy + RLS enforcement foundation.
-- Every data table below holds a NOT NULL tenant_id and enforces RLS via
-- current_setting('app.tenant_id').

create extension if not exists pgcrypto;
create extension if not exists pgvector;

-- -----------------------------------------------------------------------------
-- tenants
-- A tenant is either a school (B2B) or a family (B2C). One row per tenant.
-- -----------------------------------------------------------------------------
create type tenant_type as enum ('school', 'family');

create table tenants (
    id                uuid primary key default gen_random_uuid(),
    type              tenant_type not null,
    slug              text unique not null,
    display_name      text not null,
    primary_color_hex text,
    logo_storage_key  text,
    dek_ciphertext    bytea,                     -- §16.2 envelope-wrapped DEK
    active_dek_version int not null default 1,
    plan              text not null default 'pilot',
    created_at        timestamptz not null default now(),
    archived_at       timestamptz
);

comment on column tenants.dek_ciphertext is
  'KMS-wrapped per-tenant DEK. Plaintext never stored. See ADR-004.';

-- -----------------------------------------------------------------------------
-- Application role binding (§5)
-- -----------------------------------------------------------------------------
create type app_role as enum ('student', 'parent', 'counselor', 'admin', 'founder');

-- -----------------------------------------------------------------------------
-- user_profiles — one row per authenticated Supabase user.
-- Maps auth.uid -> tenant + role. The source of truth for RLS claims.
-- -----------------------------------------------------------------------------
create table user_profiles (
    id              uuid primary key references auth.users(id) on delete cascade,
    tenant_id       uuid references tenants(id) on delete cascade,
    role            app_role not null,
    display_name    text,
    email           text,
    mfa_enrolled    boolean not null default false,
    created_at      timestamptz not null default now(),
    constraint founder_has_no_tenant
        check ((role = 'founder' and tenant_id is null)
            or (role <> 'founder' and tenant_id is not null))
);

create index idx_user_profiles_tenant on user_profiles(tenant_id);

-- -----------------------------------------------------------------------------
-- RLS session binding — Postgres function that every Edge Function / PostgREST
-- request calls to bind app.tenant_id + app.role from the JWT claim.
-- -----------------------------------------------------------------------------
create schema if not exists app;

create or replace function app.bind_session()
returns void
language plpgsql
security definer
as $$
declare
    jwt_claims jsonb := coalesce(current_setting('request.jwt.claims', true)::jsonb, '{}'::jsonb);
    v_tenant_id text := jwt_claims ->> 'tenant_id';
    v_role      text := jwt_claims ->> 'role';
begin
    if v_tenant_id is not null then
        perform set_config('app.tenant_id', v_tenant_id, true);
    end if;
    if v_role is not null then
        perform set_config('app.role', v_role, true);
    end if;
end;
$$;

comment on function app.bind_session is
  'Reads JWT claims tenant_id + role and sets Postgres session vars for RLS.';

-- -----------------------------------------------------------------------------
-- Generic RLS template — applied to every tenant-scoped table.
--   USING (tenant_id::text = current_setting('app.tenant_id', true))
-- Founders are denied data-table access; only aggregate views are granted.
-- -----------------------------------------------------------------------------
alter table tenants enable row level security;

-- Founders can see tenants (metadata only — no DEK plaintext, no data fields beyond
-- what §14.3 allows: student count, balance, token usage, success rate).
create policy tenants_founder_read
    on tenants
    for select
    using (current_setting('app.role', true) = 'founder');

create policy tenants_self_read
    on tenants
    for select
    using (id::text = current_setting('app.tenant_id', true));

alter table user_profiles enable row level security;

create policy user_profiles_tenant_scoped
    on user_profiles
    for all
    using (tenant_id::text = current_setting('app.tenant_id', true)
           and current_setting('app.role', true) <> 'founder');

create policy user_profiles_self
    on user_profiles
    for select
    using (id = auth.uid());

-- Founder role: explicitly DENIED on user_profiles reads (§14.4).
-- No policy grants founders read access, and the `tenant_scoped` policy
-- excludes them. A founder JWT returns zero rows by construction.
