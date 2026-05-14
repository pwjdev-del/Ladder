-- 0017_sia_session_id_unique.sql
-- Follow-up to 0014_sia_memory.sql.
-- T012 (SIA memory sync) discovered that the upsert(onConflict: "session_id", ignoreDuplicates: true)
-- in MemoryExtractorService is a no-op without a UNIQUE constraint on session_id. Adding it here.
-- session_id is nullable (legacy rows may have NULL session_id), so we use a partial unique index.

CREATE UNIQUE INDEX IF NOT EXISTS student_memory_summaries_session_id_key
  ON public.student_memory_summaries (session_id)
  WHERE session_id IS NOT NULL;

COMMENT ON INDEX public.student_memory_summaries_session_id_key IS
  'Required for the iOS client''s upsert-by-session_id idempotency (T012, 2026-05-12). Partial because legacy rows may have NULL session_id.';
