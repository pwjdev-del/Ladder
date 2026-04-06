# Perplexity Research Prompt — Comprehensive US College Application & Enrollment Data

## System Role

You are a senior higher education data researcher compiling a structured, machine-readable database of US college application requirements, deadlines, and post-acceptance enrollment processes. Your output will be directly ingested into a college guidance app database. Accuracy is paramount — cite only primary sources (official school websites, Common Data Set documents, admissions office pages). If a data point cannot be verified from a primary source, mark it as `"UNVERIFIED"` rather than guessing.

---

## Mission

Compile a **single, unified document** containing structured data for US colleges and universities across the following priority tiers. For each school, collect every field listed in the Field Specification below. Output everything in **one continuous document** organized by tier, with each school as a clearly labeled section.

---

## Priority Tiers

### Tier 1 — Florida State University System (12 schools) — COMPLETE ALL FIELDS
1. University of Florida (UF)
2. Florida State University (FSU)
3. University of Central Florida (UCF)
4. University of South Florida (USF)
5. Florida International University (FIU)
6. University of North Florida (UNF)
7. Florida Atlantic University (FAU)
8. Florida A&M University (FAMU)
9. University of West Florida (UWF)
10. Florida Gulf Coast University (FGCU)
11. Florida Polytechnic University
12. New College of Florida

### Tier 2 — Top Florida Private & College System (15 schools) — COMPLETE ALL FIELDS
1. University of Miami
2. Rollins College
3. Stetson University
4. Jacksonville University
5. University of Tampa
6. Embry-Riddle Aeronautical University (Daytona Beach)
7. Nova Southeastern University
8. Florida Institute of Technology
9. Barry University
10. Palm Beach Atlantic University
11. Flagler College
12. Eckerd College
13. Lynn University
14. Ringling College of Art and Design
15. Saint Leo University

### Tier 3 — Ivy League + Top 30 National Universities (30 schools) — COMPLETE ALL FIELDS
1. Harvard University
2. Yale University
3. Princeton University
4. Columbia University
5. Stanford University
6. MIT
7. University of Chicago
8. University of Pennsylvania
9. Duke University
10. Northwestern University
11. Dartmouth College
12. Brown University
13. Cornell University
14. Johns Hopkins University
15. Vanderbilt University
16. Rice University
17. Washington University in St. Louis
18. Georgetown University
19. Emory University
20. University of Notre Dame
21. Carnegie Mellon University
22. University of Virginia
23. University of Michigan — Ann Arbor
24. UCLA
25. UC Berkeley
26. Georgia Institute of Technology
27. University of North Carolina — Chapel Hill
28. NYU
29. Tufts University
30. University of Southern California

### Tier 4 — Top Liberal Arts Colleges (20 schools) — COMPLETE ALL FIELDS
1. Williams College
2. Amherst College
3. Swarthmore College
4. Pomona College
5. Wellesley College
6. Bowdoin College
7. Middlebury College
8. Claremont McKenna College
9. Carleton College
10. Hamilton College
11. Haverford College
12. Colby College
13. Davidson College
14. Grinnell College
15. Washington and Lee University
16. Colgate University
17. Harvey Mudd College
18. Smith College
19. Oberlin College
20. Bates College

### Tier 5 — Large State Flagships & High-Volume Schools (25 schools) — COMPLETE ALL FIELDS
1. Penn State University
2. Ohio State University
3. Texas A&M University
4. University of Texas — Austin
5. University of Wisconsin — Madison
6. University of Illinois — Urbana-Champaign
7. Purdue University
8. Indiana University — Bloomington
9. University of Minnesota — Twin Cities
10. University of Washington — Seattle
11. University of Colorado — Boulder
12. University of Arizona
13. Arizona State University
14. University of Oregon
15. Oregon State University
16. Michigan State University
17. University of Maryland — College Park
18. Rutgers University — New Brunswick
19. University of Pittsburgh
20. University of Connecticut
21. University of Massachusetts — Amherst
22. Virginia Tech
23. Clemson University
24. University of Georgia
25. Auburn University

### Tier 6 — HBCUs & Specialized (15 schools) — COMPLETE ALL FIELDS
1. Howard University
2. Spelman College
3. Morehouse College
4. Hampton University
5. Tuskegee University
6. North Carolina A&T State University
7. Xavier University of Louisiana
8. Clark Atlanta University
9. Fisk University
10. Bethune-Cookman University
11. Delaware State University
12. Morgan State University
13. Tennessee State University
14. Jackson State University
15. Prairie View A&M University

### Tier 7 — Additional Popular Schools (25 schools) — COMPLETE ALL FIELDS
1. Boston University
2. Boston College
3. Northeastern University
4. Tulane University
5. Wake Forest University
6. Lehigh University
7. Villanova University
8. Santa Clara University
9. Loyola Marymount University
10. University of San Diego
11. Fordham University
12. Syracuse University
13. George Washington University
14. American University
15. Drexel University
16. Stevens Institute of Technology
17. RPI (Rensselaer Polytechnic Institute)
18. Worcester Polytechnic Institute
19. Case Western Reserve University
20. University of Rochester
21. Brandeis University
22. College of William & Mary
23. University of Richmond
24. Pepperdine University
25. Southern Methodist University

### Tier 8 — UC System & CSU Flagships (15 schools) — COMPLETE ALL FIELDS
1. UC San Diego
2. UC Davis
3. UC Santa Barbara
4. UC Irvine
5. UC Santa Cruz
6. UC Riverside
7. UC Merced
8. Cal Poly San Luis Obispo
9. San Diego State University
10. San Jose State University
11. Cal State Long Beach
12. Cal State Fullerton
13. Sacramento State
14. Fresno State
15. Cal Poly Pomona

**Total: ~157 schools across 8 tiers**

---

## Field Specification — Collect ALL of the following for EACH school

### Section A: School Identity
```
school_name: [Official full name]
aliases: [Common abbreviations, e.g., "UF", "FSU"]
city: [City]
state: [State abbreviation]
type: [Public / Private Nonprofit / Private For-Profit]
setting: [Urban / Suburban / Rural / Small City]
religious_affiliation: [If any, e.g., "Jesuit Catholic", or "None"]
undergraduate_enrollment: [Total undergrad count, most recent]
website: [Official admissions URL]
ceeb_code: [4-digit College Board code]
act_code: [4-digit ACT code]
ipeds_unitid: [6-digit IPEDS Unit ID if findable]
```

### Section B: Application Requirements (2025-2026 Cycle)
```
application_platforms: [List all accepted: "Common App", "Coalition/Scoir", "Direct/School App", "ApplyTexas", "UC Application", etc.]
application_fee: [Dollar amount, e.g., "$75"]
fee_waiver_available: [Yes / No]
fee_waiver_methods: [e.g., "Common App waiver, NACAC waiver, school-specific"]

testing_policy: [Required / Test-Optional (permanent) / Test-Optional (temporary through YYYY) / Test-Free / Test-Blind / Flexible]
testing_policy_details: [Any nuances, e.g., "Test-optional for Fall 2026; scores considered if submitted; required for engineering applicants"]
sat_middle_50: [e.g., "1400-1540"]
act_middle_50: [e.g., "32-35"]
superscoring: [Yes SAT / Yes ACT / Yes Both / No / Not Applicable]

gpa_middle_50: [e.g., "3.8-4.0 unweighted" or "4.2-4.6 weighted"]
class_rank_policy: [Required / Recommended / Considered / Not Considered]

recommendation_letters_required: [Number, e.g., "2 (1 counselor + 1 teacher)"]
recommendation_letters_optional_additional: [e.g., "1 additional teacher or other recommender"]

personal_essay: [Required / Optional / Not Accepted]
supplemental_essays: [Number and brief description, e.g., "2 — Why Us (250 words) + Community (300 words)"]
portfolio_required: [Yes (for which programs) / Optional / No]

interview: [Required / Recommended / Optional (alumni) / Informational Only / Not Offered]
interview_format: [e.g., "Alumni interview via InitialView or on-campus"]

demonstrated_interest_tracked: [Yes (Important) / Yes (Considered) / No]
campus_visit_recommended: [Yes / No / Not tracked]
```

### Section C: Application Deadlines (2025-2026 Cycle)
```
early_decision_1: [Date or "Not Offered"]
early_decision_1_notification: [Date]
early_decision_2: [Date or "Not Offered"]
early_decision_2_notification: [Date]
early_action: [Date or "Not Offered"]
early_action_notification: [Date]
restrictive_early_action: [Date or "Not Offered" — label as REA/SCEA if applicable]
restrictive_early_action_notification: [Date]
regular_decision: [Date or "Rolling"]
regular_decision_notification: [Date or "Rolling beginning DATE"]
priority_deadline: [Date or "None"]
financial_aid_priority_deadline: [Date]
fafsa_deadline: [Date or "As soon as possible after October 1"]
css_profile_required: [Yes / No]
css_profile_deadline: [Date or "N/A"]
scholarship_deadline: [Date if separate from admission deadline, or "Same as admission deadline"]
```

### Section D: Admissions Philosophy (from CDS Section C7 or equivalent)
```
Rate each factor: Very Important / Important / Considered / Not Considered

rigor_of_secondary_school_record: []
class_rank: []
academic_gpa: []
standardized_test_scores: []
application_essay: []
recommendation: []
interview: []
extracurricular_activities: []
talent_ability: []
character_personal_qualities: []
first_generation: []
alumni_relation: []
geographical_residence: []
state_residency: []
religious_affiliation_commitment: []
racial_ethnic_status: [] (Note: post-SFFA ruling status)
volunteer_work: []
work_experience: []
level_of_applicant_interest: []

admissions_archetype: [Classify as one: "Holistic" / "Test-Driven" / "Academic-Formula" / "Open Admission" / "Portfolio-Based" / "Unique"]
archetype_explanation: [1-2 sentence justification based on the factor ratings above]
```

### Section E: Transcript Submission
```
transcript_method: [e.g., "Common App + counselor upload", "SSAR (Self-Reported Student Academic Record)", "STARS", "Naviance", "Parchment", "Official paper transcript", "Coalition/Scoir", "School-specific portal"]
self_reported_grades_accepted: [Yes (SSAR) / Yes (Coalition) / No — official only]
mid_year_report_required: [Yes / No / Recommended]
final_transcript_required: [Yes / No]
final_transcript_deadline: [Date, e.g., "July 1 after enrollment"]
```

### Section F: Post-Acceptance Enrollment Process
```
enrollment_deposit_amount: [Dollar amount, e.g., "$200"]
enrollment_deposit_deadline: [Date, typically May 1 — National Candidates Reply Date]
deposit_refundable: [Yes fully / Yes partially / No / Refundable until DATE]
housing_deposit_amount: [Dollar amount if separate from enrollment deposit]
housing_deposit_deadline: [Date]
housing_application_opens: [Date]
housing_application_deadline: [Date]
housing_deposit_refundable: [Yes / No / Partial]

orientation_name: [e.g., "Preview", "Gator Days", "Seminole Sensation"]
orientation_dates: [Date range or "Multiple sessions June-August"]
orientation_mandatory: [Yes / No / Strongly Recommended]
orientation_cost: [Dollar amount or "Free"]
orientation_format: [In-person / Virtual / Hybrid]

placement_tests_required: [List, e.g., "Math placement exam, Foreign language placement exam"]
placement_test_deadline: [Date or "Before orientation"]
placement_test_format: [Online / In-person at orientation / Either]

immunization_requirements: [List required vaccines, e.g., "MMR (2 doses), Meningococcal (ACWY), Hepatitis B series, Varicella (2 doses)"]
immunization_form_deadline: [Date]
meningococcal_waiver_available: [Yes / No]
health_insurance_required: [Yes (must show proof or enroll in school plan) / Recommended / No]

new_student_portal_name: [e.g., "myUFL ONE.UF", "myFSU", "myKnight"]
student_email_format: [e.g., "firstname.lastname@ufl.edu", "abc1234@knights.ucf.edu"]

course_registration_opens: [Date or "During orientation"]
first_semester_classes_start: [Date for Fall 2026]
move_in_day: [Date for Fall 2026]
```

### Section G: Financial Aid & Scholarships
```
merit_scholarships_available: [Yes / No]
top_merit_scholarship_name: [e.g., "Benacquisto Scholarship", "Presidential Scholarship"]
top_merit_scholarship_amount: [e.g., "Full tuition + $300/semester stipend"]
top_merit_scholarship_criteria: [Brief, e.g., "National Merit Finalist who enrolls at a Florida public university"]
automatic_merit_awards: [Yes (based on GPA/test scores) / No (all competitive)]
average_merit_award: [Dollar amount if available]
meets_full_demonstrated_need: [Yes / No / For families under $INCOME]
average_net_price_family_income_0_30k: [Dollar amount]
average_net_price_family_income_30_48k: [Dollar amount]
average_net_price_family_income_48_75k: [Dollar amount]
average_net_price_family_income_75_110k: [Dollar amount]
average_net_price_family_income_110k_plus: [Dollar amount]
institutional_aid_application: [CSS Profile / FAFSA only / School-specific form]
```

### Section H: Florida-Specific (ONLY for Florida schools in Tiers 1 & 2)
```
bright_futures_eligible: [Yes / No]
bright_futures_fas_per_credit: [Dollar amount per credit hour for FAS]
bright_futures_fms_per_credit: [Dollar amount per credit hour for FMS]
benacquisto_eligible: [Yes (public) / No]
prepaid_plan_accepted: [Yes / No]
dual_enrollment_credits_accepted: [Yes (max N credits) / Policy details]
ssar_required: [Yes / No — Self-Reported Student Academic Record]
florida_residency_tuition: [In-state tuition per credit hour]
out_of_state_tuition: [Out-of-state tuition per credit hour]
```

---

## Output Format Requirements

1. **One continuous document** — do not split across multiple responses. If the response is long, that is expected and desired.

2. **Each school as a clearly labeled section** with a horizontal rule separator:
```
---
## [TIER NUMBER] — [SCHOOL NAME] ([STATE ABBREVIATION])
```

3. **Every field listed** — if a value cannot be found from primary sources, write `"UNVERIFIED"` — never leave a field blank and never guess.

4. **Use the exact field names** from the specification above as labels.

5. **Cite the source URL** at the end of each school section:
```
Sources: [URL1], [URL2], [URL3]
```

6. **Date format**: Use `YYYY-MM-DD` for all dates (e.g., `2025-11-01` for November 1, 2025).

7. **Currency format**: Use `$X,XXX` with commas (e.g., `$6,380`).

8. After all school sections, include a **Summary Statistics** section:
   - Total schools researched
   - Number of fields populated vs. UNVERIFIED (by tier)
   - Most common testing policy breakdown
   - Most common application platform breakdown
   - Average application fee
   - Date range of EA/ED/RD deadlines

---

## Research Priority Instructions

1. **Always check the school's official admissions website first** — not third-party aggregators.
2. **For CDS Section C7 data**: Search for "[School Name] Common Data Set 2024-2025" — most schools publish this as a PDF or webpage. If 2024-2025 is not available, use 2023-2024 and note the year.
3. **For post-acceptance enrollment data**: Check the school's "Admitted Students" or "Next Steps" or "New Student" or "Orientation" pages.
4. **For financial aid**: Check the school's net price calculator page and financial aid office page.
5. **For Florida schools**: Also check the Florida Bright Futures page (floridastudentfinancialaidsg.org) and each school's financial aid page for Bright Futures per-credit rates.
6. **For deadlines**: Use the 2025-2026 application cycle (students applying Fall 2025 for Fall 2026 enrollment). If 2025-2026 dates are not yet published, use 2024-2025 dates and note `"(2024-2025 cycle — 2025-2026 not yet published)"`.

---

## Quality Checks Before Submitting

- [ ] Every school from all 8 tiers is included
- [ ] Every field from Sections A through H is present for each school (Section H only for Florida schools)
- [ ] No field is left blank — use "UNVERIFIED" for unknown values
- [ ] All dates are in YYYY-MM-DD format
- [ ] All dollar amounts use $ with commas
- [ ] Source URLs are listed for each school
- [ ] Summary statistics section is included at the end
- [ ] Document is one continuous output, not split across responses
