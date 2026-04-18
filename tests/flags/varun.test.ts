// tests/flags/varun.test.ts
// CLAUDE.md §15 — Varun dependency validator tests.

import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { validateFlags } from '../../LadderBackend/supabase/functions/varun-validate/index.ts';

Deno.test('rule 1: auth OFF cascades everything OFF', () => {
  const r = validateFlags({ flags: { 'feature.auth': false, 'feature.career_quiz': true } });
  assertEquals(r.ok, false);
  assertEquals(r.corrected?.['feature.career_quiz'], false);
});

Deno.test('rule 4: scheduling requires classes + teacher_data + student_profile', () => {
  const r = validateFlags({
    flags: {
      'feature.auth': true,
      'feature.scheduling': true,
      'feature.classes': false,
      'feature.teacher_data': false,
      'feature.student_profile': false,
    },
  });
  assertEquals(r.ok, false);
  assertEquals(r.violations.length, 3);
});

Deno.test('rule 5: flex_scheduling requires scheduling', () => {
  const r = validateFlags({
    flags: { 'feature.auth': true, 'feature.flex_scheduling': true, 'feature.scheduling': false },
  });
  assertEquals(r.violations.some((v) => v.rule === 'rule_5_flex_requires_scheduling'), true);
});

Deno.test('rule 7: class_suggester requires career_quiz + grades_self_entry', () => {
  const r = validateFlags({
    flags: {
      'feature.auth': true,
      'feature.class_suggester': true,
      'feature.career_quiz': false,
      'feature.grades_self_entry': false,
    },
  });
  assertEquals(r.violations.length, 2);
});

Deno.test('rule 9: teacher_reviews requires teacher_data', () => {
  const r = validateFlags({
    flags: { 'feature.auth': true, 'feature.teacher_reviews': true, 'feature.teacher_data': false },
  });
  assertEquals(r.violations.some((v) => v.rule === 'rule_9_teacher_reviews_requires_teacher_data'), true);
});

Deno.test('explain: violations include fix hints', () => {
  const r = validateFlags({
    flags: { 'feature.auth': true, 'feature.invite_codes': true },
  });
  // auth=true satisfies rule 10.
  assertEquals(r.ok, true);
});
