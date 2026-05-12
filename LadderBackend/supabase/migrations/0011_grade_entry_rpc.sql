-- 0011 — student grade-entry RPC (§2.2)
--
-- IMPORTANT — encryption shortcut:
-- This RPC currently stores the score as UTF-8 bytes in `score_cipher`,
-- preserving the column shape without applying real envelope encryption.
-- BEFORE PUBLIC LAUNCH, swap the body to call into the DEK envelope path
-- (fetch tenants.dek_ciphertext, unwrap with KEK from edge function, encrypt).
-- The iOS contract does not change when that swap happens.

create or replace function public.record_grade(
    p_subject text,
    p_period  text,
    p_score   text
)
returns uuid
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_student uuid;
    v_tenant  uuid;
    v_id      uuid;
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    select id into v_student
      from students
     where user_id = auth.uid()
       and tenant_id = v_tenant
     limit 1;
    if v_student is null then
        raise exception 'student_record_missing';
    end if;

    insert into grades(student_id, tenant_id, subject, period, score_cipher)
    values (v_student, v_tenant, trim(p_subject), nullif(trim(p_period), ''), convert_to(p_score, 'UTF8'))
    returning id into v_id;

    return v_id;
end;
$$;

grant execute on function public.record_grade(text, text, text) to authenticated;

create or replace function public.list_my_grades()
returns table(id uuid, subject text, period text, score text, entered_at timestamptz)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_student uuid;
    v_tenant  uuid;
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    select s.id into v_student
      from students s
     where s.user_id = auth.uid()
       and s.tenant_id = v_tenant
     limit 1;
    if v_student is null then
        return;
    end if;

    return query
    select g.id,
           g.subject,
           g.period,
           convert_from(g.score_cipher, 'UTF8') as score,
           g.entered_at
      from grades g
     where g.student_id = v_student
       and g.tenant_id  = v_tenant
     order by g.entered_at desc;
end;
$$;

grant execute on function public.list_my_grades() to authenticated;
