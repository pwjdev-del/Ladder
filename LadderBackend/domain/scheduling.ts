// LadderBackend/domain/scheduling.ts
// CLAUDE.md §11.4 — deterministic scheduling core.
// Given identical inputs, produces identical conflict reports every time.
// AI is a suggester, not a decider. See ADR-003.

export interface ClassPick {
  student_id: string;
  class_id: string;
  period: string;     // e.g. "P1", "P2", ...
  section_id?: string;
}

export interface ClassInfo {
  id: string;
  title: string;
  max_capacity: number;
  prereq_ids: string[];
  offered_periods: string[];
}

export interface PrereqCompletion {
  student_id: string;
  completed_class_ids: string[];
}

export interface SectionCapacity {
  class_id: string;
  period: string;
  enrolled: number;
  cap: number;
}

export type ConflictKind =
  | 'period_conflict'
  | 'prereq_missing'
  | 'capacity_exceeded'
  | 'class_not_offered_in_period'
  | 'duplicate_class';

export interface Conflict {
  kind: ConflictKind;
  student_id: string;
  class_id: string;
  period?: string;
  detail: string;
}

export interface ValidationInput {
  picks: ClassPick[];
  classes: Map<string, ClassInfo>;
  prereqs: Map<string, PrereqCompletion>;
  section_caps: SectionCapacity[];
}

export interface ValidationResult {
  ok: boolean;
  conflicts: Conflict[];
}

export function validateSchedule(input: ValidationInput): ValidationResult {
  const conflicts: Conflict[] = [];
  const { picks, classes, prereqs, section_caps } = input;

  // Group by student for period/duplicate checks.
  const picksByStudent = new Map<string, ClassPick[]>();
  for (const p of picks) {
    const arr = picksByStudent.get(p.student_id) ?? [];
    arr.push(p);
    picksByStudent.set(p.student_id, arr);
  }

  for (const [studentId, studentPicks] of picksByStudent) {
    // period_conflict: two picks in the same period
    const periodMap = new Map<string, string[]>(); // period -> class_ids
    const seenClasses = new Set<string>();
    for (const pick of studentPicks) {
      const bucket = periodMap.get(pick.period) ?? [];
      bucket.push(pick.class_id);
      periodMap.set(pick.period, bucket);

      // duplicate_class check
      if (seenClasses.has(pick.class_id)) {
        conflicts.push({
          kind: 'duplicate_class',
          student_id: studentId,
          class_id: pick.class_id,
          detail: `Student picked ${pick.class_id} more than once`,
        });
      }
      seenClasses.add(pick.class_id);

      // class_not_offered_in_period
      const klass = classes.get(pick.class_id);
      if (klass && !klass.offered_periods.includes(pick.period)) {
        conflicts.push({
          kind: 'class_not_offered_in_period',
          student_id: studentId,
          class_id: pick.class_id,
          period: pick.period,
          detail: `${klass.title} is not offered during ${pick.period}`,
        });
      }

      // prereq_missing
      if (klass) {
        const completed = prereqs.get(studentId)?.completed_class_ids ?? [];
        for (const prereq of klass.prereq_ids) {
          if (!completed.includes(prereq)) {
            conflicts.push({
              kind: 'prereq_missing',
              student_id: studentId,
              class_id: pick.class_id,
              detail: `Missing prerequisite ${prereq} for ${klass.title}`,
            });
          }
        }
      }
    }

    for (const [period, classIds] of periodMap) {
      if (classIds.length > 1) {
        for (const classId of classIds) {
          conflicts.push({
            kind: 'period_conflict',
            student_id: studentId,
            class_id: classId,
            period,
            detail: `Multiple classes in ${period}: ${classIds.join(', ')}`,
          });
        }
      }
    }
  }

  // capacity_exceeded: count fresh picks against section caps
  const demand = new Map<string, number>(); // key: class_id|period
  for (const p of picks) {
    const key = `${p.class_id}|${p.period}`;
    demand.set(key, (demand.get(key) ?? 0) + 1);
  }
  for (const cap of section_caps) {
    const key = `${cap.class_id}|${cap.period}`;
    const requested = demand.get(key) ?? 0;
    if (cap.enrolled + requested > cap.cap) {
      conflicts.push({
        kind: 'capacity_exceeded',
        student_id: '*',
        class_id: cap.class_id,
        period: cap.period,
        detail: `Section ${cap.class_id}/${cap.period} over capacity: ${cap.enrolled + requested}/${cap.cap}`,
      });
    }
  }

  return { ok: conflicts.length === 0, conflicts };
}
