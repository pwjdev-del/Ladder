-- 0010 — parent invite RPC (B2C §6.2)
--
-- Student-callable function that generates a one-time parent invite code,
-- hashes it server-side (never stored plaintext), and returns the code to
-- the caller exactly once. Tenant comes from the bound session setting;
-- auth.uid() is the creating student.

create or replace function public.generate_parent_invite(
    p_parent_email text,
    p_relationship text default 'parent'
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_code     text;
    v_tenant   uuid;
    v_expires  timestamptz := now() + interval '14 days';
begin
    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    if p_parent_email is null or length(trim(p_parent_email)) = 0 then
        raise exception 'parent_email_required';
    end if;

    -- 12-char code: LDR- + 8 hex chars
    v_code := 'LDR-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id, kind, code_hash, code_prefix,
        created_by, intended_email, expires_at
    ) values (
        v_tenant, 'b2c_parent',
        digest(v_code, 'sha256'),
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_parent_email)),
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

grant execute on function public.generate_parent_invite(text, text) to authenticated;
