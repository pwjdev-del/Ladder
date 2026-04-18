-- 0007 — COPPA gate trigger on quiz_answers.
-- Phase 8 flagged: no DB-level check ensures a parental_consent legal_acceptance
-- exists before a child under 13 has quiz answers written.

create or replace function app.enforce_coppa_quiz_consent()
returns trigger
language plpgsql
as $$
declare
    v_dob date;
    v_age_years int;
    v_has_consent boolean;
begin
    -- Students store DOB encrypted with the tenant DEK. For the trigger to run
    -- server-side without loading the DEK, we require `students.grade_level` or
    -- a separate `students.is_under_13` boolean flag derived at signup.
    -- Simpler interim: block quiz_answer insert for students below grade 7
    -- unless a parental_consent row exists, since K-6 implies <13.
    select grade_level into v_age_years
    from students
    where id = NEW.student_id;

    if v_age_years is null or v_age_years >= 7 then
        return NEW;
    end if;

    -- Under 13 — require a parental consent legal_acceptance tied to this student.
    select exists (
        select 1 from legal_acceptances la
        where la.on_behalf_of_student_id = NEW.student_id
          and la.doc = 'parental_consent'
    ) into v_has_consent;

    if not v_has_consent then
        raise exception using
            errcode = 'check_violation',
            message = 'COPPA: parental_consent legal_acceptance required before quiz answers for students under 13 (CLAUDE.md §6.2, §17.3)';
    end if;

    return NEW;
end;
$$;

create trigger quiz_answers_coppa
    before insert on quiz_answers
    for each row
    execute function app.enforce_coppa_quiz_consent();

-- Same gate on grades (self-entered under-13 also requires consent).
create trigger grades_coppa
    before insert on grades
    for each row
    execute function app.enforce_coppa_quiz_consent();
