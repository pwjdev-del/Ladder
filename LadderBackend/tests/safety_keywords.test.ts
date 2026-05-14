// LadderBackend/tests/safety_keywords.test.ts
//
// Unit tests for the word-boundary safety-keyword detection (S2 #3).
// Run with:
//   deno test --allow-env --allow-net LadderBackend/tests/safety_keywords.test.ts
//
// These tests do NOT require a running Supabase instance.
//
// checkUserSafetySignals() returns { triggered: boolean, matchedKeywords: string[] }.
// matchedKeywords entries are in "<category>:<phrase>" format (e.g. "self_harm:kill myself").
// Tests use .triggered to preserve all existing semantics where category is not relevant.

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

// violence_to_others false-positives — idiom completions must NOT flag
Deno.test("false-positive: 'I want to kill it at the game tomorrow' does NOT flag", () => {
  assertEquals(checkUserSafetySignals("I want to kill it at the game tomorrow").triggered, false);
});

// NOTE: "I want to hurt no one" DOES flag because "i want to hurt" is a
// prefix-match violence_to_others phrase (no negative lookahead).
// This is a documented v1.0 limitation — a sentence-level false positive is
// preferred over missing a genuine threat like "I want to hurt Marcus tomorrow".
// A v1.1 ML classifier will handle this correctly.
Deno.test("documented-fp: 'I want to hurt no one' triggers (prefix-match limitation, v1.0)", () => {
  // "i want to hurt" is a prefix-match signal; it fires regardless of what follows.
  assertEquals(checkUserSafetySignals("I want to hurt no one").triggered, true);
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

// violence_to_others true-positives (red-team B1/B2 scenarios)
Deno.test("true-positive violence_to_others: 'I want to hurt Marcus tomorrow' flags", () => {
  assertEquals(checkUserSafetySignals("I want to hurt Marcus tomorrow").triggered, true);
});

Deno.test("true-positive violence_to_others: 'I'm going to hurt him' flags", () => {
  assertEquals(checkUserSafetySignals("I'm going to hurt him").triggered, true);
});

Deno.test("true-positive violence_to_others: 'I'm gonna hurt them' flags", () => {
  assertEquals(checkUserSafetySignals("I'm gonna hurt them").triggered, true);
});

Deno.test("true-positive violence_to_others: 'I want to kill them' flags", () => {
  assertEquals(checkUserSafetySignals("I want to kill them").triggered, true);
});

Deno.test("true-positive violence_to_others: 'I want to kill my teacher' flags", () => {
  assertEquals(checkUserSafetySignals("I want to kill my teacher").triggered, true);
});

Deno.test("true-positive violence_to_others: 'I want to attack' flags", () => {
  assertEquals(checkUserSafetySignals("I want to attack").triggered, true);
});

Deno.test("true-positive violence_to_others: 'bring a gun to school' flags", () => {
  assertEquals(checkUserSafetySignals("I was thinking about bring a gun to school").triggered, true);
});

Deno.test("true-positive violence_to_others: 'shoot up' flags", () => {
  assertEquals(checkUserSafetySignals("I want to shoot up the school").triggered, true);
});

// ---------------------------------------------------------------------------
// Additional boundary checks
// ---------------------------------------------------------------------------

Deno.test("case-insensitive: 'I Want To Die' flags", () => {
  assertEquals(checkUserSafetySignals("I Want To Die").triggered, true);
});

Deno.test("case-insensitive violence: 'I WANT TO HURT someone' flags", () => {
  assertEquals(checkUserSafetySignals("I WANT TO HURT someone").triggered, true);
});

Deno.test("phrase at end of sentence: 'things are bad, I want to die' flags", () => {
  assertEquals(checkUserSafetySignals("things are bad, I want to die").triggered, true);
});

Deno.test("unrelated message does NOT flag", () => {
  assertEquals(checkUserSafetySignals("What AP classes should I take junior year?").triggered, false);
});

// ---------------------------------------------------------------------------
// matchedKeywords populated on true-positive — format is "<category>:<phrase>"
// ---------------------------------------------------------------------------

Deno.test("matchedKeywords is non-empty on true-positive", () => {
  const result = checkUserSafetySignals("I want to die");
  assertEquals(result.triggered, true);
  assertEquals(result.matchedKeywords.length > 0, true);
});

Deno.test("matchedKeywords contains category prefix for self_harm signal", () => {
  const result = checkUserSafetySignals("I want to kill myself");
  assertEquals(result.triggered, true);
  // Every matched keyword must include a category prefix
  const allPrefixed = result.matchedKeywords.every((k) => k.includes(':'));
  assertEquals(allPrefixed, true);
  const selfHarm = result.matchedKeywords.some((k) => k.startsWith('self_harm:'));
  assertEquals(selfHarm, true);
});

Deno.test("matchedKeywords contains violence_to_others category for threat signal", () => {
  const result = checkUserSafetySignals("I want to hurt Marcus tomorrow");
  assertEquals(result.triggered, true);
  const violenceCategory = result.matchedKeywords.some((k) => k.startsWith('violence_to_others:'));
  assertEquals(violenceCategory, true);
});

Deno.test("matchedKeywords is empty on false-positive idiom", () => {
  const result = checkUserSafetySignals("I want to die laughing");
  assertEquals(result.triggered, false);
  assertEquals(result.matchedKeywords.length, 0);
});
