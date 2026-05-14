-- Migration 0014: rate_limit_buckets
-- Supports per-user per-minute rate limiting in the ai-gateway Edge Function.
-- Each row represents one user's request count for a single calendar minute.
-- Old rows (window_start < now - 10 min) are purged by the cleanup function
-- below, called opportunistically at the end of each gateway invocation via
-- a NOTIFY or scheduled pg_cron job (pg_cron setup is a deploy-time concern).

-- ---------------------------------------------------------------------------
-- Table
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rate_limit_buckets (
  bucket_key   text        NOT NULL,   -- "<user_id>:<YYYY-MM-DDTHH:MM>"
  count        integer     NOT NULL DEFAULT 1,
  window_start timestamptz NOT NULL,
  PRIMARY KEY (bucket_key)
);

-- Index for the periodic cleanup query.
CREATE INDEX IF NOT EXISTS rate_limit_buckets_window_start_idx
  ON public.rate_limit_buckets (window_start);

-- RLS: this table is internal infrastructure written only by the service role
-- (from the ai-gateway Edge Function). No user-facing reads or writes.
ALTER TABLE public.rate_limit_buckets ENABLE ROW LEVEL SECURITY;

-- Deny all access from the anon / authenticated roles.
-- The Edge Function uses the service_role key, which bypasses RLS entirely.
-- Explicit deny policies keep the surface clean.
CREATE POLICY rate_limit_no_access ON public.rate_limit_buckets
  AS RESTRICTIVE
  FOR ALL
  USING (false);

-- ---------------------------------------------------------------------------
-- RPC: upsert_rate_limit_bucket
-- Called by the ai-gateway Edge Function (service_role) to atomically
-- increment a user's request count for the current minute.
-- Returns the new count so the caller can compare it against the limit.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.upsert_rate_limit_bucket(
  p_bucket_key  text,
  p_window_start timestamptz
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER   -- runs as the function owner (service), not the caller
SET search_path = public
AS $$
DECLARE
  v_count integer;
BEGIN
  INSERT INTO public.rate_limit_buckets (bucket_key, count, window_start)
  VALUES (p_bucket_key, 1, p_window_start)
  ON CONFLICT (bucket_key) DO UPDATE
    SET count = rate_limit_buckets.count + 1
  RETURNING count INTO v_count;

  RETURN v_count;
END;
$$;

-- Only the service role may call this RPC.
REVOKE EXECUTE ON FUNCTION public.upsert_rate_limit_bucket(text, timestamptz) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.upsert_rate_limit_bucket(text, timestamptz) FROM anon;
REVOKE EXECUTE ON FUNCTION public.upsert_rate_limit_bucket(text, timestamptz) FROM authenticated;

-- ---------------------------------------------------------------------------
-- Cleanup: purge buckets older than 10 minutes.
-- Call via pg_cron (every 5 min) or a manual maintenance script.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.purge_old_rate_limit_buckets()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  DELETE FROM public.rate_limit_buckets
  WHERE window_start < now() - INTERVAL '10 minutes';
$$;

REVOKE EXECUTE ON FUNCTION public.purge_old_rate_limit_buckets() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.purge_old_rate_limit_buckets() FROM anon;
REVOKE EXECUTE ON FUNCTION public.purge_old_rate_limit_buckets() FROM authenticated;
