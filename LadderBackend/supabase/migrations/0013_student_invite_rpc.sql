-- 0013 — admin-side student invite RPC (B2B §6.1)
--
-- Used by the admin "Import students" sheet to bulk-generate one invite
-- code per student email. Plaintext code returned once to the caller;
-- backend persists only the SHA-256 hash.

create or replace function public.generate_student_invite(
    p_email text,
    p_grade int default null
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_code     text;
    v_tenant   uuid;
    v_role     text;
    v_expires  timestamptz := now() + interval '30 days';
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    v_role   := current_setting('app.role', true);
    if v_tenant is null then raise exception 'tenant_required'; end if;
    if v_role not in ('admin', 'counselor') then raise exception 'forbidden'; end if;
    if p_email is null or length(trim(p_email)) = 0 then
        raise exception 'email_required';
    end if;

    v_code := 'LDR-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id, kind, code_hash, code_prefix,
        created_by, intended_email, expected_grade_level, expires_at
    ) values (
        v_tenant, 'b2b_student_single',
        digest(v_code, 'sha256'),
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_email)),
        p_grade,
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

grant execute on function public.generate_student_invite(text, int) to authenticated;
