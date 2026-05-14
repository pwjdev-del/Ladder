-- Migration: 0016_d002_counselor_chat_revoke.sql
-- Closes D-002 gap introduced in 0009_adr_008_schema_additions.sql.
--
-- DECISION D-002 (DECISIONS.md):
--   Counselor sees: SIA-generated topic summary + active safety flags +
--   last-active timestamp.  Counselor CANNOT scroll the student's raw chat
--   history.  The surface for counselor-visible AI insight is
--   student_memory_summaries (created in 0014_sia_memory.sql), NOT
--   student_ai_chats.
--
-- DO NOT restore a counselor SELECT policy on student_ai_chats without a
-- DECISIONS.md revision and sign-off from the product owner.

-- ── Revoke counselor read access on raw chat rows ────────────────────────────
drop policy if exists ai_chats_counselor_read on student_ai_chats;

-- ── Sanity check: assert no counselor SELECT policy remains ──────────────────
-- This block raises an exception and rolls back the transaction if any
-- policy targeting the 'counselor' role still exists on student_ai_chats,
-- preventing silent reintroduction via a conflicting migration.
do $$
declare
    v_count integer;
begin
    select count(*)
      into v_count
      from pg_policies
     where schemaname = 'public'
       and tablename  = 'student_ai_chats'
       and (
           -- policy body references the counselor role string
           qual        ilike '%counselor%'
        or with_check  ilike '%counselor%'
        or policyname  ilike '%counselor%'
       );

    if v_count > 0 then
        raise exception
            'D-002 violation: % counselor-touching policy(ies) still exist on '
            'student_ai_chats after revoke. Check migrations applied after 0016.',
            v_count;
    end if;
end;
$$;
