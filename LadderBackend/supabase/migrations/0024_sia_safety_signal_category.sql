-- Migration: 0024_sia_safety_signal_category.sql
-- Adds columns and constraint extensions to sia_safety_events required by the
-- red-team safety hardening (2026-05-14):
--
--   1. signal_keywords text[]   — keyword phrases that triggered the event,
--                                 prefixed with a signal category:
--                                 e.g. ["self_harm:kill myself",
--                                       "violence_to_others:i want to hurt"]
--   2. message_excerpt text     — PII-redacted excerpt of the triggering message
--                                 (written by user_input_scan and gemini_native_filter paths)
--   3. severity        text     — initial triage severity ('high', 'medium', 'low')
--   4. model_response_id text   — placeholder for future linking to Gemini response IDs
--
--   flag_type nullable          — the user_input_scan insert path does not set flag_type;
--                                 the NOT NULL constraint on the original table blocks
--                                 those inserts at runtime. Make it nullable here.
--
--   flag_type check extended    — adds 'gemini_native_block' for Fix 2 (native filter).
--   triggered_by check extended — adds 'gemini_native_filter' for Fix 2 (native filter).
--
-- DO NOT edit migration 0019. All changes are additive ALTER TABLE statements.

-- ── 1. Make flag_type nullable ─────────────────────────────────────────────────
-- The user_input_scan insert path (gateway L~695) does not set flag_type.
-- The original NOT NULL was overly strict; flag_type is meaningful only for
-- response_scan and gemini_native_filter rows.
alter table sia_safety_events
    alter column flag_type drop not null;

-- ── 2. Add new columns (idempotent via IF NOT EXISTS) ──────────────────────────

alter table sia_safety_events
    add column if not exists signal_keywords   text[],
    add column if not exists message_excerpt   text,
    add column if not exists severity          text,
    add column if not exists model_response_id text;

comment on column sia_safety_events.signal_keywords is
  'Phrases that triggered the safety event, each prefixed with a signal category: '
  '"<category>:<phrase>". Categories: self_harm | violence_to_others | abuse | general_crisis | gemini_native. '
  'Populated by user_input_scan and gemini_native_filter paths in the ai-gateway Edge Function.';

comment on column sia_safety_events.message_excerpt is
  'PII-redacted excerpt (≤500 chars) of the student message that triggered the event. '
  'Written by user_input_scan and gemini_native_filter paths.';

comment on column sia_safety_events.severity is
  'Initial triage severity set by the gateway. Values: ''high'', ''medium'', ''low''. '
  'Counselors may override via the notes + reviewed_at workflow.';

comment on column sia_safety_events.model_response_id is
  'Placeholder for future linkage to Gemini candidateId / response UUID. '
  'Not populated in v1.0; reserved for v1.1 audit trail.';

-- ── 3. Extend flag_type check constraint ──────────────────────────────────────
-- Drop the old constraint and recreate it with the new value.
-- 'gemini_native_block' is raised when Gemini's own safety filter returns a
-- non-STOP finishReason (SAFETY | BLOCKED | RECITATION | OTHER).
alter table sia_safety_events
    drop constraint if exists sia_safety_events_flag_type_check;

alter table sia_safety_events
    add constraint sia_safety_events_flag_type_check
        check (flag_type is null or flag_type in (
            'crisis_resource_mentioned',
            'crisis_topic_in_response',
            'user_input_crisis_signal',
            'gemini_native_block'
        ));

-- ── 4. Extend triggered_by check constraint ───────────────────────────────────
-- 'gemini_native_filter' is used when the gateway detects a blocked finishReason.
alter table sia_safety_events
    drop constraint if exists sia_safety_events_triggered_by_check;

alter table sia_safety_events
    add constraint sia_safety_events_triggered_by_check
        check (triggered_by in (
            'response_scan',
            'user_input_scan',
            'gemini_native_filter'
        ));

-- ── 5. Index for signal category queries ──────────────────────────────────────
-- Counselors can filter by category prefix in signal_keywords using the GIN index.
-- e.g. WHERE signal_keywords && ARRAY['violence_to_others:i want to hurt']
create index if not exists sia_safety_events_signal_keywords_idx
    on sia_safety_events using gin(signal_keywords);
