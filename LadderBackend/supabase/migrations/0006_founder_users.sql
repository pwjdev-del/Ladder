-- 0006 — separate founder_users table per §14.1.
-- Founder credentials never live alongside tenant users. Separate signing
-- key scope possible later; for now, WebAuthn passkey enrolment is tracked
-- on this row.

create table founder_users (
    id              uuid primary key default gen_random_uuid(),
    auth_user_id    uuid not null unique references auth.users(id) on delete restrict,
    display_name    text not null,
    passkey_cred_id bytea,
    passkey_public_key bytea,
    totp_secret_cipher bytea,
    created_at      timestamptz not null default now(),
    last_login_at   timestamptz
);

alter table founder_users enable row level security;

-- Only the calling founder can read their own row. Never broadcast founder
-- list (prevents tenant-side enumeration).
create policy founder_users_self
    on founder_users
    for all
    using (auth_user_id = auth.uid());

-- Helper RPC: founder_login(founder_id, password, totp).
-- Real implementation verifies argon2id password, TOTP, then issues a
-- Supabase JWT with custom claim role=founder, tenant_id=null.
-- Stubbed here to anchor the contract — client calls POST /rest/v1/rpc/founder_login.
create or replace function public.founder_login(
    p_founder_id text,
    p_password text,
    p_totp text
) returns jsonb
language plpgsql
security definer
as $$
begin
    -- TODO: verify credentials in Edge Function, not in SQL. This stub
    -- returns 501 so callers can detect the unwired state.
    return jsonb_build_object(
        'status', 'not_implemented',
        'hint', 'move credential verification to LadderBackend/supabase/functions/founder-login'
    );
end;
$$;
