// LadderBackend/tests/safety_keywords.test.ts
//
// Unit tests for the word-boundary safety-keyword detection (S2 #3).
// Run with:
//   deno test --allow-env --allow-net LadderBackend/tests/safety_keywords.test.ts
//
// These tests do NOT require a running Supabase instance.
//
// checkUserSafetySignals() now returns { triggered: boolean, matchedKeywords: string[] }.
// Tests use .triggered to preserve all existing semantics.

import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { checkUserSafetySignals } from '../supabase/functions/ai-gateway/index.ts';

// ---------------------------------------------------------------------------
// False-positive cases — must NOT trigger a safety flag
// ---------------------------------------------------------------------------

Deno.test("false-positive: 'I want to die laughing' does NOT flag", () => {
  assertEquals(checkUserSafetySignals("I want to die laughing").triggered, false);
});

Deno.test("false-positive: 'I'll kill myself if I see one more chem problem' does NOT flag", () => {
  assertEquals(checkUserSafetySignals("I'll kill myself if I see one more chem problem").triggered, false);
});

// ---------------------------------------------------------------------------
// True-positive cases — must trigger a safety flag
// ---------------------------------------------------------------------------

Deno.test("true-positive: 'I want to die' flags", () => {
  assertEquals(checkUserSafetySignals("I want to die").triggered, true);
});

Deno.test("true-positive: 'I want to kill myself' flags", () => {
  assertEquals(checkUserSafetySignals("I want to kill myself").triggered, true);
});

// ---------------------------------------------------------------------------
// Additional boundary checks
// ---------------------------------------------------------------------------

Deno.test("case-insensitive: 'I Want To Die' flags", () => {
  assertEquals(checkUserSafetySignals("I Want To Die").triggered, true);
});

Deno.test("phrase at end of sentence: 'things are bad, I want to die' flags", () => {
  assertEquals(checkUserSafetySignals("things are bad, I want to die").triggered, true);
});

Deno.test("unrelated message does NOT flag", () => {
  assertEquals(checkUserSafetySignals("What AP classes should I take junior year?").triggered, false);
});

// ---------------------------------------------------------------------------
// matchedKeywords populated on true-positive
// ---------------------------------------------------------------------------

Deno.test("matchedKeywords is non-empty on true-positive", () => {
  const result = checkUserSafetySignals("I want to die");
  assertEquals(result.triggered, true);
  assertEquals(result.matchedKeywords.length > 0, true);
});

Deno.test("matchedKeywords is empty on false-positive idiom", () => {
  const result = checkUserSafetySignals("I want to die laughing");
  assertEquals(result.triggered, false);
  assertEquals(result.matchedKeywords.length, 0);
});
