// tests/scheduling/scheduling.test.ts
// CLAUDE.md §11 — scheduling engine tests. The deterministic core MUST
// produce identical conflict reports for identical inputs.

import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { validateSchedule, ClassInfo, ClassPick, PrereqCompletion } from '../../LadderBackend/domain/scheduling.ts';

const classes = new Map<string, ClassInfo>([
  ['algebra1', { id: 'algebra1', title: 'Algebra 1', max_capacity: 30, prereq_ids: [], offered_periods: ['P1', 'P3'] }],
  ['algebra2', { id: 'algebra2', title: 'Algebra 2', max_capacity: 30, prereq_ids: ['algebra1'], offered_periods: ['P2'] }],
  ['biology',  { id: 'biology',  title: 'Biology',   max_capacity: 30, prereq_ids: [], offered_periods: ['P1', 'P2'] }],
]);

Deno.test('period_conflict: two classes in same period flagged', () => {
  const picks: ClassPick[] = [
    { student_id: 'alice', class_id: 'algebra1', period: 'P1' },
    { student_id: 'alice', class_id: 'biology',  period: 'P1' },
  ];
  const result = validateSchedule({ picks, classes, prereqs: new Map(), section_caps: [] });
  assertEquals(result.ok, false);
  assertEquals(result.conflicts.filter((c) => c.kind === 'period_conflict').length, 2);
});

Deno.test('prereq_missing: algebra2 without algebra1 blocked', () => {
  const picks: ClassPick[] = [{ student_id: 'alice', class_id: 'algebra2', period: 'P2' }];
  const prereqs = new Map<string, PrereqCompletion>();
  prereqs.set('alice', { student_id: 'alice', completed_class_ids: [] });
  const result = validateSchedule({ picks, classes, prereqs, section_caps: [] });
  assertEquals(result.conflicts.some((c) => c.kind === 'prereq_missing'), true);
});

Deno.test('prereq_met: algebra2 after algebra1 ok', () => {
  const picks: ClassPick[] = [{ student_id: 'alice', class_id: 'algebra2', period: 'P2' }];
  const prereqs = new Map<string, PrereqCompletion>();
  prereqs.set('alice', { student_id: 'alice', completed_class_ids: ['algebra1'] });
  const result = validateSchedule({ picks, classes, prereqs, section_caps: [] });
  assertEquals(result.ok, true);
});

Deno.test('capacity_exceeded flagged when enrolled + requested > cap', () => {
  const picks: ClassPick[] = [
    { student_id: 's1', class_id: 'algebra1', period: 'P1' },
    { student_id: 's2', class_id: 'algebra1', period: 'P1' },
  ];
  const result = validateSchedule({
    picks,
    classes,
    prereqs: new Map(),
    section_caps: [{ class_id: 'algebra1', period: 'P1', enrolled: 29, cap: 30 }],
  });
  assertEquals(result.conflicts.some((c) => c.kind === 'capacity_exceeded'), true);
});

Deno.test('class_not_offered_in_period flagged', () => {
  const picks: ClassPick[] = [{ student_id: 'alice', class_id: 'algebra1', period: 'P4' }];
  const result = validateSchedule({ picks, classes, prereqs: new Map(), section_caps: [] });
  assertEquals(result.conflicts.some((c) => c.kind === 'class_not_offered_in_period'), true);
});

Deno.test('duplicate_class flagged', () => {
  const picks: ClassPick[] = [
    { student_id: 'alice', class_id: 'algebra1', period: 'P1' },
    { student_id: 'alice', class_id: 'algebra1', period: 'P3' },
  ];
  const result = validateSchedule({ picks, classes, prereqs: new Map(), section_caps: [] });
  assertEquals(result.conflicts.some((c) => c.kind === 'duplicate_class'), true);
});

Deno.test('deterministic — identical inputs produce identical conflict lists', () => {
  const picks: ClassPick[] = [
    { student_id: 'alice', class_id: 'algebra1', period: 'P1' },
    { student_id: 'alice', class_id: 'biology',  period: 'P1' },
  ];
  const a = validateSchedule({ picks, classes, prereqs: new Map(), section_caps: [] });
  const b = validateSchedule({ picks, classes, prereqs: new Map(), section_caps: [] });
  assertEquals(a, b);
});
