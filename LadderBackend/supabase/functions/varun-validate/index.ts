// LadderBackend/supabase/functions/varun-validate/index.ts
// CLAUDE.md §15 — feature-dependency validator.
//
// Not an AI. Spec says "AI" but §15.2 defines 10 deterministic rules —
// this is a pure function with a trace mode. Also §15.4: no data reads.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

type FlagState = Record<string, boolean>;

interface ValidateRequest {
  flags: FlagState;
  tenant_type?: 'school' | 'family';
}

interface ValidateResult {
  ok: boolean;
  violations: Array<{ rule: string; message: string; fix?: Partial<FlagState> }>;
  corrected?: FlagState;
}

function f(flags: FlagState, key: string): boolean {
  return !!flags[key];
}

export function validateFlags(req: ValidateRequest): ValidateResult {
  const violations: ValidateResult['violations'] = [];
  const flags = { ...req.flags };

  // Rule 1: auth OFF ⇒ everything OFF
  if (!f(flags, 'feature.auth')) {
    for (const key of Object.keys(flags)) {
      if (key !== 'feature.auth' && flags[key]) {
        violations.push({
          rule: 'rule_1_auth_off_cascades',
          message: `feature.auth is OFF; ${key} must be OFF`,
          fix: { [key]: false },
        });
        flags[key] = false;
      }
    }
  }

  // Rule 2: school_login ON ⇒ auth ON + tenant_type='school'
  if (f(flags, 'feature.school_login')) {
    if (!f(flags, 'feature.auth')) {
      violations.push({
        rule: 'rule_2_school_login_requires_auth',
        message: 'feature.school_login requires feature.auth ON',
        fix: { 'feature.auth': true },
      });
    }
    if (req.tenant_type && req.tenant_type !== 'school') {
      violations.push({
        rule: 'rule_2_school_login_requires_school_tenant',
        message: 'feature.school_login requires tenant_type = school',
      });
    }
  }

  // Rule 3: b2c_signup ON ⇒ auth ON + parent_invite ON
  if (f(flags, 'feature.b2c_signup')) {
    if (!f(flags, 'feature.auth')) {
      violations.push({
        rule: 'rule_3_b2c_signup_requires_auth',
        message: 'feature.b2c_signup requires feature.auth ON',
        fix: { 'feature.auth': true },
      });
    }
    if (!f(flags, 'feature.parent_invite')) {
      violations.push({
        rule: 'rule_3_b2c_signup_requires_parent_invite',
        message: 'feature.b2c_signup requires feature.parent_invite ON',
        fix: { 'feature.parent_invite': true },
      });
    }
  }

  // Rule 4: scheduling ⇒ classes + teacher_data + student_profile
  if (f(flags, 'feature.scheduling')) {
    for (const dep of ['feature.classes', 'feature.teacher_data', 'feature.student_profile']) {
      if (!f(flags, dep)) {
        violations.push({
          rule: 'rule_4_scheduling_dependencies',
          message: `feature.scheduling requires ${dep} ON`,
          fix: { [dep]: true },
        });
      }
    }
  }

  // Rule 5: flex_scheduling ⇒ scheduling
  if (f(flags, 'feature.flex_scheduling') && !f(flags, 'feature.scheduling')) {
    violations.push({
      rule: 'rule_5_flex_requires_scheduling',
      message: 'feature.flex_scheduling requires feature.scheduling ON',
      fix: { 'feature.scheduling': true },
    });
  }

  // Rule 6: career_quiz ⇒ student_profile
  if (f(flags, 'feature.career_quiz') && !f(flags, 'feature.student_profile')) {
    violations.push({
      rule: 'rule_6_quiz_requires_student_profile',
      message: 'feature.career_quiz requires feature.student_profile ON',
      fix: { 'feature.student_profile': true },
    });
  }

  // Rule 7: class_suggester ⇒ career_quiz + grades_self_entry
  if (f(flags, 'feature.class_suggester')) {
    for (const dep of ['feature.career_quiz', 'feature.grades_self_entry']) {
      if (!f(flags, dep)) {
        violations.push({
          rule: 'rule_7_class_suggester_dependencies',
          message: `feature.class_suggester requires ${dep} ON`,
          fix: { [dep]: true },
        });
      }
    }
  }

  // Rule 8: extracurriculars_ai ⇒ career_quiz + student_profile
  if (f(flags, 'feature.extracurriculars_ai')) {
    for (const dep of ['feature.career_quiz', 'feature.student_profile']) {
      if (!f(flags, dep)) {
        violations.push({
          rule: 'rule_8_extracurriculars_dependencies',
          message: `feature.extracurriculars_ai requires ${dep} ON`,
          fix: { [dep]: true },
        });
      }
    }
  }

  // Rule 9: teacher_reviews ⇒ teacher_data
  if (f(flags, 'feature.teacher_reviews') && !f(flags, 'feature.teacher_data')) {
    violations.push({
      rule: 'rule_9_teacher_reviews_requires_teacher_data',
      message: 'feature.teacher_reviews requires feature.teacher_data ON',
      fix: { 'feature.teacher_data': true },
    });
  }

  // Rule 10: invite_codes ⇒ auth
  if (f(flags, 'feature.invite_codes') && !f(flags, 'feature.auth')) {
    violations.push({
      rule: 'rule_10_invite_codes_requires_auth',
      message: 'feature.invite_codes requires feature.auth ON',
      fix: { 'feature.auth': true },
    });
  }

  return {
    ok: violations.length === 0,
    violations,
    corrected: violations.length > 0 ? flags : undefined,
  };
}

serve(async (req) => {
  if (req.method !== 'POST') return new Response('method not allowed', { status: 405 });
  try {
    const body = (await req.json()) as ValidateRequest;
    const result = validateFlags(body);
    return new Response(JSON.stringify(result), {
      status: result.ok ? 200 : 409,
      headers: { 'content-type': 'application/json' },
    });
  } catch (e) {
    return new Response('bad request', { status: 400 });
  }
});
