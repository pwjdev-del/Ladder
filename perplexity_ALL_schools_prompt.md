# Perplexity Research System — COMPLETE US College Database (All ~6,800 Schools)

## How This Works — READ FIRST

Getting data for ALL ~6,800 US colleges requires a two-layer strategy:

### Layer 1: Automated API Pull (Claude will code this — NO Perplexity needed)
The **College Scorecard API** and **IPEDS/Urban Institute API** already have the following data for ALL ~7,000 Title IV schools — for free, via API. Claude will pull this programmatically. **Do NOT waste Perplexity time on these fields:**
- School name, city, state, zip, website URL
- Public/private/for-profit classification
- Campus setting (urban/suburban/rural)
- Undergraduate enrollment count
- Admission rate
- SAT 25th/50th/75th percentiles
- ACT 25th/50th/75th percentiles
- In-state tuition, out-of-state tuition
- Room & board costs
- Average net price (by income bracket)
- Graduation rate
- Pell Grant recipient rate
- Post-graduation median earnings
- Carnegie classification
- Latitude/longitude coordinates
- IPEDS Unit ID

### Layer 2: Perplexity Research (THIS PROMPT)
The following fields are **NOT in any free API** and must be researched from school websites, CDS documents, and admissions pages. **This is what Perplexity needs to find.**

Because 6,800 schools cannot be researched in one session, this prompt is designed to be run **STATE BY STATE**. Run it once per state (or batch of small states). Each run produces one document. Upload all state documents to Claude when done.

---

## MASTER PROMPT — Copy and paste this, replacing [STATE] with the target state

---

### START OF PROMPT — COPY BELOW THIS LINE

---

You are a senior higher education data researcher. Your task is to compile a structured, machine-readable database of **every degree-granting college and university in [STATE]** — including 4-year universities, 4-year colleges, 2-year community colleges, and technical colleges that grant associate's degrees or higher.

**Your output will be directly ingested into a software database.** Accuracy matters more than completeness — if a data point cannot be verified from a primary source (official school website, Common Data Set, admissions office page), mark it as `UNVERIFIED`. Never guess.

---

#### Step 1: Identify ALL Schools

First, compile the **complete list** of every degree-granting postsecondary institution in [STATE]. Use these sources:
- IPEDS/NCES College Navigator (https://nces.ed.gov/collegenavigator/) — filter by [STATE], degree-granting, currently operating
- College Scorecard (https://collegescorecard.ed.gov/) — filter by [STATE]
- [STATE]'s state higher education board/commission website for the official list of accredited institutions

Include:
- All public universities (flagship, regional, branch campuses)
- All public community/state colleges
- All private nonprofit 4-year colleges and universities
- All private for-profit degree-granting institutions
- All tribal colleges (if applicable)
- All specialized institutions (art schools, medical schools with undergrad programs, military academies, seminaries with accredited degree programs)

Exclude:
- Non-degree-granting institutions (trade schools that only offer certificates, not degrees)
- Institutions that have closed or lost accreditation
- Institutions that only offer graduate/professional degrees (no undergraduate enrollment)

**List the total count of schools found before proceeding.**

---

#### Step 2: Collect Data for Each School

For **every school** identified in Step 1, collect the following fields. These are the fields that are NOT available from the College Scorecard or IPEDS APIs — they require checking each school's website.

```
=== [SCHOOL OFFICIAL FULL NAME] ===
state: [STATE ABBREVIATION]
city: [City]
ipeds_unitid: [6-digit IPEDS Unit ID — look up at NCES College Navigator]
ceeb_code: [4-digit College Board code, or UNVERIFIED]
school_level: [4-Year / 2-Year / Combined]

--- APPLICATION PROCESS ---
application_platforms: [Common App / Coalition-Scoir / Direct-School-App / ApplyTexas / UC-Application / CFNC / Other — list all accepted]
application_fee: [$XX or "Free" or UNVERIFIED]
fee_waiver_available: [Yes / No / UNVERIFIED]
testing_policy: [Required / Test-Optional-Permanent / Test-Optional-Temporary-YYYY / Test-Free / Test-Blind / Open-Admission / UNVERIFIED]
testing_policy_notes: [Any specifics, e.g., "Required for nursing program" or "Temporary through 2027" — or "None"]
personal_essay_required: [Yes / No / Optional / UNVERIFIED]
supplemental_essays_count: [Number, or "0", or UNVERIFIED]
recommendation_letters_required: [Number, or "0", or UNVERIFIED]
interview_policy: [Required / Recommended / Optional / Not-Offered / UNVERIFIED]
demonstrated_interest: [Yes-Important / Yes-Considered / No / UNVERIFIED]

--- DEADLINES (2025-2026 cycle; if not published, use 2024-2025 and note it) ---
early_decision_1_deadline: [YYYY-MM-DD or Not-Offered]
early_decision_2_deadline: [YYYY-MM-DD or Not-Offered]
early_action_deadline: [YYYY-MM-DD or Not-Offered]
restrictive_early_action: [YYYY-MM-DD or Not-Offered]
regular_decision_deadline: [YYYY-MM-DD or Rolling]
priority_deadline: [YYYY-MM-DD or None]
financial_aid_priority_deadline: [YYYY-MM-DD or UNVERIFIED]
css_profile_required: [Yes / No]

--- ADMISSIONS FACTORS (from CDS Section C7 if available) ---
Search for "[School Name] Common Data Set 2024-2025" (or 2023-2024 if not available).
If CDS is found, rate each factor. If CDS is NOT found, write "CDS-NOT-FOUND" for all.

cds_year: [2024-2025 / 2023-2024 / CDS-NOT-FOUND]
factor_hs_record_rigor: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_class_rank: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_gpa: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_test_scores: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_essay: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_recommendations: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_interview: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_extracurriculars: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_talent_ability: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_character: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_first_generation: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_alumni_relation: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_geographic_residence: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_state_residency: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_volunteer_work: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_work_experience: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]
factor_interest_level: [Very-Important / Important / Considered / Not-Considered / CDS-NOT-FOUND]

--- TRANSCRIPT SUBMISSION ---
transcript_method: [Common-App-Counselor / SSAR / STARS / Naviance / Parchment / Official-Paper / Coalition-Scoir / School-Portal / UNVERIFIED]
self_reported_grades: [Yes-SSAR / Yes-Coalition / No-Official-Only / UNVERIFIED]

--- POST-ACCEPTANCE ENROLLMENT ---
enrollment_deposit_amount: [$XX or UNVERIFIED]
enrollment_deposit_deadline: [YYYY-MM-DD or May-1 or Rolling or UNVERIFIED]
housing_deposit_amount: [$XX or Included-In-Enrollment-Deposit or UNVERIFIED]
housing_application_deadline: [YYYY-MM-DD or UNVERIFIED]
orientation_required: [Yes / No / UNVERIFIED]
orientation_cost: [$XX or Free or UNVERIFIED]
immunization_requirements: [List vaccines required, e.g., "MMR, Meningococcal-ACWY, Hepatitis-B, Varicella" or UNVERIFIED]
immunization_deadline: [YYYY-MM-DD or Before-Move-In or UNVERIFIED]
placement_tests_required: [List, e.g., "Math, Foreign-Language" or "None" or UNVERIFIED]

--- MERIT SCHOLARSHIPS ---
automatic_merit_scholarships: [Yes / No / UNVERIFIED]
top_merit_scholarship_name: [Name or UNVERIFIED]
top_merit_scholarship_amount: [$XX or Full-Tuition or UNVERIFIED]
top_merit_criteria_brief: [Brief criteria or UNVERIFIED]

--- SOURCES ---
sources: [List all URLs checked for this school]
```

---

#### Step 3: State-Level Summary

After all schools in [STATE], include:
```
=== [STATE] SUMMARY ===
total_schools_found: [Number]
total_4year: [Number]
total_2year: [Number]
total_private_nonprofit: [Number]
total_public: [Number]
total_for_profit: [Number]
fields_verified_percentage: [Approximate % of fields that are NOT "UNVERIFIED"]
most_common_testing_policy: [e.g., "Test-Optional-Permanent (67%)"]
most_common_application_platform: [e.g., "Common App (45%), Direct (55%)"]
state_higher_ed_board_url: [URL]
state_financial_aid_agency_url: [URL]
notes: [Any state-specific patterns, e.g., "All public universities use SSAR" or "State has a common application portal"]
```

---

#### Output Rules

1. **One continuous document** — do not stop or split. If the state has 200 schools, output all 200.
2. **Use the EXACT field names** above — no renaming, no reformatting. They will be parsed by code.
3. **Every field present for every school** — use `UNVERIFIED` for unknown values. Never leave a field blank.
4. **Dates in YYYY-MM-DD format.** Currency as `$X,XXX`.
5. **Separate each school with `===` lines** as shown in the template.
6. **Community colleges and open-admission schools**: For these, many admissions fields will naturally be "Not-Offered" or "Open-Admission" — that is correct, fill them in accordingly. They still need enrollment process fields (deposits, orientation, immunization).
7. **If you run out of space**: End with `=== CONTINUATION NEEDED FROM [LAST SCHOOL COMPLETED] ===` and I will prompt you to continue.

---

#### Research Priority

1. **Official school admissions website** — always primary source
2. **School's Common Data Set PDF** — search "[School Name] Common Data Set 2024-2025"
3. **School's "Admitted Students" / "Next Steps" / "New Student Checklist" page** — for enrollment process fields
4. **NCES College Navigator** (nces.ed.gov/collegenavigator) — for IPEDS Unit ID and basic verification
5. **School's financial aid page** — for scholarship and CSS Profile information
6. **State higher education board website** — for complete list of accredited institutions in state

**Never use third-party ranking sites (Niche, US News, CollegeBoard BigFuture) as primary data sources.** Only use them to cross-reference if the school's own website is ambiguous.

---

### END OF PROMPT — COPY ABOVE THIS LINE

---

## State Batch Schedule

Run the master prompt above for each batch below. Replace `[STATE]` with the state name. Approximate school counts are from IPEDS.

### Batch 1 — Florida (HOME STATE — DO FIRST)
| Run | State | Approx. Schools | Notes |
|-----|-------|-----------------|-------|
| 1 | Florida | ~220 | Include ALL SUS, FCS, and private institutions |

### Batch 2 — Large States (100+ schools each, run individually)
| Run | State | Approx. Schools |
|-----|-------|-----------------|
| 2 | California | ~460 |
| 3 | New York | ~310 |
| 4 | Texas | ~270 |
| 5 | Pennsylvania | ~260 |
| 6 | Ohio | ~200 |
| 7 | Illinois | ~180 |
| 8 | North Carolina | ~140 |
| 9 | Georgia | ~130 |
| 10 | Virginia | ~120 |
| 11 | Massachusetts | ~120 |
| 12 | Michigan | ~110 |
| 13 | Indiana | ~100 |
| 14 | Tennessee | ~110 |
| 15 | Missouri | ~130 |

### Batch 3 — Medium States (50–99 schools each, can combine 2 per run)
| Run | States | Approx. Schools |
|-----|--------|-----------------|
| 16 | Alabama + Mississippi | ~75 + ~45 |
| 17 | Minnesota + Wisconsin | ~75 + ~75 |
| 18 | New Jersey + Connecticut | ~65 + ~45 |
| 19 | Louisiana + Arkansas | ~80 + ~50 |
| 20 | South Carolina + Kentucky | ~75 + ~75 |
| 21 | Maryland + Delaware + DC | ~60 + ~12 + ~20 |
| 22 | Arizona + New Mexico | ~80 + ~40 |
| 23 | Colorado + Utah | ~70 + ~40 |
| 24 | Washington + Oregon | ~80 + ~60 |
| 25 | Iowa + Kansas + Nebraska | ~65 + ~60 + ~40 |
| 26 | Oklahoma + West Virginia | ~55 + ~45 |

### Batch 4 — Small States (under 50 schools each, combine 3-5 per run)
| Run | States | Approx. Schools |
|-----|--------|-----------------|
| 27 | Maine + New Hampshire + Vermont + Rhode Island | ~30 + ~25 + ~25 + ~15 |
| 28 | Hawaii + Alaska + Idaho + Montana + Wyoming | ~15 + ~8 + ~15 + ~20 + ~10 |
| 29 | North Dakota + South Dakota + Nevada | ~20 + ~20 + ~25 |
| 30 | Puerto Rico + US Virgin Islands + Guam + Other Territories | ~70 + ~3 + ~2 |

**Total: ~30 Perplexity runs to cover the entire United States**

---

## After All Runs Are Complete

Upload all state documents to Claude. Claude will:
1. Parse all school data from Perplexity output
2. Merge with College Scorecard API data (automated pull of enrollment, costs, scores, rates)
3. Merge with FairTest testing policy data
4. Merge with IPEDS admissions data
5. Produce the complete database (~6,800 schools, ~80 fields each)
6. Import into Ladder app's SwiftData models + Supabase backend

---

## Quick-Start Checklist

- [ ] Run Batch 1 (Florida) — upload to Claude
- [ ] Run Batches 2-15 (large states, one per run) — upload each
- [ ] Run Batches 16-26 (medium states, 2-3 per run) — upload each
- [ ] Run Batches 27-30 (small states + territories, 3-5 per run) — upload each
- [ ] Tell Claude "all state data uploaded — merge and build the database"

---

## Field Count Per School

| Category | Fields | Source |
|----------|--------|--------|
| Identity (API) | 16 fields | College Scorecard — automated |
| Application Process | 10 fields | Perplexity research |
| Deadlines | 8 fields | Perplexity research |
| CDS C7 Factors | 18 fields | Perplexity research |
| Transcript | 2 fields | Perplexity research |
| Post-Acceptance | 9 fields | Perplexity research |
| Merit Scholarships | 4 fields | Perplexity research |
| **API fields (automated)** | **~25 fields** | **College Scorecard + IPEDS** |
| **Perplexity fields** | **~51 fields** | **Per school, from prompt** |
| **Total per school** | **~76 fields** | **Combined** |

**At 6,800 schools x 76 fields = ~516,800 data points in the final database.**
