-- 0012 — admin-side teacher profile RPCs (§5)
--
-- Same encryption shortcut as 0011: names go in as UTF-8 bytes in the
-- `*_cipher` columns, preserving schema shape. Swap for real DEK envelope
-- encryption before public launch.

create or replace function public.add_teacher_profile(
    p_first_name text,
    p_last_name  text,
    p_tags       text[]
)
returns table(id uuid)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_tenant uuid;
    v_id     uuid;
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    if v_tenant is null then raise exception 'tenant_required'; end if;

    insert into teacher_profiles(
        tenant_id, first_name_cipher, last_name_cipher, teaching_style_tags
    ) values (
        v_tenant,
        convert_to(coalesce(p_first_name, ''), 'UTF8'),
        convert_to(coalesce(p_last_name, ''),  'UTF8'),
        coalesce(p_tags, '{}'::text[])
    )
    returning teacher_profiles.id into v_id;

    return query select v_id;
end;
$$;

grant execute on function public.add_teacher_profile(text, text, text[]) to authenticated;

-- View-style RPC: admin reads decrypted names. We use a SECURITY DEFINER
-- function rather than a view so we can bind the session and enforce role.
create or replace function public.list_teacher_profiles()
returns table(id uuid, first_name text, last_name text, teaching_style_tags text[])
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_tenant uuid;
    v_role   text;
begin
    perform app.bind_session();
    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    v_role   := current_setting('app.role', true);
    if v_tenant is null then raise exception 'tenant_required'; end if;
    if v_role not in ('admin', 'counselor') then raise exception 'forbidden'; end if;

    return query
    select t.id,
           convert_from(t.first_name_cipher, 'UTF8'),
           convert_from(t.last_name_cipher,  'UTF8'),
           t.teaching_style_tags
      from teacher_profiles t
     where t.tenant_id = v_tenant
     order by created_at desc;
end;
$$;

grant execute on function public.list_teacher_profiles() to authenticated;

-- Compatibility shim: a view named `teacher_profiles_plain` so iOS can
-- `.from("teacher_profiles_plain").select(...)` without changing later.
create or replace view public.teacher_profiles_plain as
  select * from public.list_teacher_profiles();
