-- 0018 — counselor invite RPC (B2C §6.1 counselor variant)
--
-- Counselor-callable function that generates a one-time invite code for a
-- prospective student. Plaintext code returned exactly once; backend stores
-- only the SHA-256 hash. Tenant and actor come from the bound session.
--
-- A student can redeem by looking up:
--   SELECT * FROM invite_codes
--   WHERE code_hash = digest($code, 'sha256')
--     AND kind = 'b2c_counselor'
--     AND (expires_at IS NULL OR expires_at > now())
--     AND revoked_at IS NULL
--     AND uses < max_uses;
-- The redemption path should increment `uses` and link the student.

-- Step 1: extend the enum with the new kind.
-- `IF NOT EXISTS` is not valid for ALTER TYPE ... ADD VALUE, but we guard
-- with a DO block so re-running is safe on a fresh DB.
do $$
begin
    if not exists (
        select 1 from pg_enum
        where enumlabel = 'b2c_counselor'
          and enumtypid = 'public.invite_kind'::regtype
    ) then
        alter type public.invite_kind add value 'b2c_counselor';
    end if;
end
$$;

-- Step 2: RPC
-- Takes an optional intended_email; all other parameters derived from session.
-- Code format: "CSL-XXXXXXXX" (12 chars, uppercase hex, no ambiguous chars).
create or replace function public.counselor_issue_invite(
    p_intended_email text default null
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_code    text;
    v_tenant  uuid;
    v_role    text;
    v_expires timestamptz := now() + interval '14 days';
begin
    -- bind_session sets app.tenant_id and app.role from the JWT claims.
    -- Re-using the same pattern as 0013 / 0011.
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    v_role   := current_setting('app.role', true);

    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    -- Only counselors (and admins) may issue counselor invites.
    if v_role not in ('counselor', 'admin') then
        raise exception 'forbidden';
    end if;

    -- CSL- prefix distinguishes counselor codes from student (LDR-) and
    -- parent (LDR-) codes so redemption paths can fast-fail on wrong kind.
    -- 8 hex chars from 4 random bytes → 16^8 = ~4 billion codes.
    v_code := 'CSL-' || upper(substr(encode(gen_random_bytes(4), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id,
        kind,
        code_hash,
        code_prefix,
        created_by,
        intended_email,
        expires_at
    ) values (
        v_tenant,
        'b2c_counselor',
        digest(v_code, 'sha256'),
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_intended_email)),
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

-- Counselors and admins can call this; authenticated covers both.
grant execute on function public.counselor_issue_invite(text) to authenticated;
