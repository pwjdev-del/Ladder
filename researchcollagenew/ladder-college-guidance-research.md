# Ladder College Guidance App — Comprehensive Research Report

*Compiled: April 4, 2026*
*Sources: All 8 research areas compiled from primary source investigation*

---

## Executive Summary

This report consolidates comprehensive research across eight critical domains for building the Ladder college guidance app. Three foundational findings shape the entire product strategy. First, **no single free data source covers the full range of application and enrollment data** needed for ~4,000 US institutions. Building a comprehensive database requires a layered architecture: free government APIs (College Scorecard + Urban Institute/IPEDS) for foundation data, a paid Peterson's license for CDS-aligned fields (deadlines, fees, deposit amounts), FairTest for testing policy, and direct school collection for enrollment-process fields (housing dates, orientation, immunization) that no aggregator currently covers. Second, **Florida represents a uniquely high-value market**: the state's Bright Futures Scholarship program (merit-only, no income limits, covering up to 100% of tuition for FAS recipients), the SUS public university system ($4,940–$6,723/year in-state tuition), and a 432:1 student-to-counselor ratio (73% above the ASCA-recommended 250:1) create acute demand for accessible college guidance tools. Third, **the private counseling market is both large and inaccessible** to most families — the national average comprehensive counseling package costs $6,450, school counselors average only 38–45 minutes of college guidance per student over four years, and the total market is valued at $2.9B with 7.9–12.8% projected CAGR — validating the democratization thesis.

The research also establishes detailed data for the admissions intelligence layer of the app. CDS Section C7 data for 30 schools reveals a clear taxonomy: holistic schools (Stanford, Yale, Columbia, Northwestern — essays/character/extracurriculars all "Very Important," tests only "Considered"), test-driven schools (Princeton, Dartmouth, Georgetown — tests rated "Very Important"), academic-formula schools (USF, UCF — only rigor/GPA/tests matter), and unique cases (Harvard rates everything "Considered" as a deliberate philosophical signal). On SAT/ACT testing strategy: the Class of 2025 was the first to surpass 2M SAT takers since before COVID, 97% took the digital format, and Khan Academy's free platform has research-validated gains of 90–115 points for 6–20 hours of study. The extracurriculars research confirms that admissions at selective schools has decisively shifted to the "spike" model — depth over breadth — with an optimal count of approximately 4 activities (peak acceptance rate at 30% in Pioneer Academics data) and the industry-standard 4-tier classification framework providing a structured way to evaluate student profiles. Financial aid data covers FAFSA Simplification Act changes (EFC→SAI, ~36 questions now vs. 100+), the full state-deadline table for all 50 states, the 40 largest scholarships with exact amounts and deadlines, and critical 2026 legislative changes to Parent PLUS Loans.

---

## Table of Contents

1. [Area 1 & 2: College Data Sources, APIs & Post-Acceptance Enrollment Data](#area-1--2-college-data-sources-apis--post-acceptance-enrollment-data)
2. [Area 3: Florida-Specific College Planning](#area-3-florida-specific-college-planning)
3. [Area 4: Common Data Set Section C7 Admissions Factors](#area-4-common-data-set-section-c7-admissions-factors)
4. [Area 5: SAT/ACT Testing Strategy](#area-5-satact-testing-strategy)
5. [Area 6: Financial Aid & Scholarships](#area-6-financial-aid--scholarships)
6. [Area 7: Extracurricular Activities in College Admissions](#area-7-extracurricular-activities-in-college-admissions)
7. [Area 8: College Counselor Industry Research](#area-8-college-counselor-industry-research)
8. [Data Architecture for Ladder App](#data-architecture-for-ladder-app)

---

## Area 1 & 2: College Data Sources, APIs & Post-Acceptance Enrollment Data

*Research compiled April 4, 2026*

### Table of Contents (Area 1 & 2)
1. [Federal / Government Sources](#federal--government-sources)
2. [Application Platform Sources](#application-platform-sources)
3. [Common Data Set (CDS)](#common-data-set-cds)
4. [Third-Party Data Sources](#third-party-data-sources)
5. [Open-Source Projects & Datasets](#open-source-projects--datasets)
6. [Field Coverage Matrix](#field-coverage-matrix)
7. [Data Gap Analysis](#data-gap-analysis)
8. [Recommended Data Architecture](#recommended-data-architecture)

---

### Federal / Government Sources

#### 1. College Scorecard API

| Attribute | Details |
|---|---|
| **URL** | https://collegescorecard.ed.gov/data/ |
| **API Endpoint** | `https://api.data.gov/ed/collegescorecard/v1/schools` |
| **Access Method** | REST API (GET requests); free API key required via api.data.gov |
| **Authentication** | API key parameter: `?api_key=YOUR_API_KEY` |
| **Format** | JSON |
| **Cost** | Free |
| **Rate Limit** | 1,000 requests/IP/hour (increase available via scorecarddata@rti.org) |
| **Update Frequency** | Last updated March 23, 2026; data refreshed annually, with some subsets (e.g., earnings) updated mid-year |
| **Institution Coverage** | ~6,000–7,000 institutions (all Title IV-participating) |
| **Bulk Download** | Yes — full ZIP (~445 MB), most-recent ZIP (~23 MB), field-of-study ZIP (~16 MB); CSV inside |

**Available Data Fields (Key Categories):**

- `school.name`, `school.state`, `school.city`, `school.zip`
- `school.school_url`, `school.price_calculator_url`
- `school.ownership` (public/private/for-profit)
- `school.degrees_awarded.predominant` (associate/bachelor's/graduate)
- `school.locale` (urban/suburban/rural codes)
- `school.carnegie_basic` (Carnegie classification)
- `school.main_campus`, `school.branches`
- `school.accreditor`
- `latest.admissions.admission_rate.overall` — acceptance rate
- `latest.admissions.sat_scores.*` — SAT 25th/50th/75th percentile for reading and math
- `latest.admissions.act_scores.*` — ACT 25th/50th/75th percentile (composite, math, English, writing)
- `latest.cost.tuition.in_state`, `latest.cost.tuition.out_of_state`
- `latest.cost.avg_net_price.*` — net price by income bracket
- `latest.cost.room_and_board`
- `latest.student.size` — total enrollment
- `latest.completion.rate_suppressed.*` — graduation rates
- `latest.earnings.*` — post-graduation earnings
- `latest.aid.pell_grant_rate`
- `location.lat`, `location.lon`

**Does NOT Include:**
- Application deadlines (EA, ED, RD)
- Testing policy (test-optional/required/blind)
- Application fees
- Supplemental essay counts
- Enrollment deposit amount or deadline
- Housing application dates
- Placement test requirements
- Immunization requirements
- Orientation dates
- Transcript submission method (SSAR/STARS/Naviance/official)

**Usage Note:** Wildcard queries like `fields=id,school,latest` return all nested objects. Pagination supported (max 100 per page). Data dictionary: https://collegescorecard.ed.gov/assets/CollegeScorecardDataDictionary.xlsx

---

#### 2. IPEDS (Integrated Postsecondary Education Data System)

| Attribute | Details |
|---|---|
| **URL** | https://nces.ed.gov/ipeds/use-the-data |
| **Access Methods** | (a) Custom Data Files (CSV, from 1980-81); (b) Complete Data Files (CSV); (c) Access Database (from 2004-05, ~64–92 MB compressed); (d) Urban Institute Education Data API (JSON) |
| **Urban Institute API** | https://educationdata.urban.org/api/v1/ — free, open, JSON, R/Stata/Python packages available |
| **Format** | CSV, MS Access (.mdb), JSON (via Urban Institute API) |
| **Cost** | Free (mandatory government data) |
| **Update Frequency** | Annual; provisional ~9 months after collection period closes; final ~18 months after. 2024-25 provisional released March 2026 |
| **Institution Coverage** | ~7,000+ institutions (all Title IV participants, ~200 non-Title IV voluntary) |

**IPEDS Survey Components Relevant to App:**

**IC (Institutional Characteristics) — Fall Collection:**
- Institution address, phone, website URLs
- Control/affiliation (public, private nonprofit, for-profit)
- Calendar system (semester, quarter, trimester)
- Award levels and program types
- Student services offered
- Note: Tuition/fees now in separate CST survey component as of 2024-25

**ADM (Admissions) — Winter Collection:**
Available via Urban Institute API: `https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-requirements/{year}/`

Key fields:
- `reqt_hs_diploma` — secondary school diploma required/recommended/considered
- `reqt_hs_rank` — class rank
- `reqt_test_scores` — admission test scores (required/recommended/considered/not required)
- `reqt_sat_scores` — SAT scores specifically
- `reqt_other_test` — other tests
- `reqt_toefl` — TOEFL requirement
- `reqt_hs_gpa` — GPA requirement
- `reqt_hs_record` — transcript requirement
- `reqt_college_prep` — college prep program
- `reqt_recommendations` — recommendations
- `reqt_personal_statement` — personal statement required
- `open_admissions_policy` — open admissions flag (0=No, 1=Yes)
- `sat_number_submitting`, `sat_percent_submitting`
- `act_number_submitting`, `act_percent_submitting`
- SAT/ACT score percentiles (25th, 50th, 75th) for reading, math, composite, English, writing, science
- `no_entering_freshmen`
- `sat_act_report_period` (scores not required = 3)

Available via: `https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-enrollment/{year}/`
- `number_applied`, `number_admitted`, `number_enrolled_ft`, `number_enrolled_pt` (by sex)

**Does NOT Include:**
- Specific deadlines (EA, ED, RD closing dates — these are in CDS not IPEDS)
- Application fees (not collected in IPEDS)
- Number of supplemental essays
- Enrollment deposit details
- Housing application dates
- Orientation requirements
- Immunization requirements
- Transcript submission method

**Critical Note on Testing Policy:** IPEDS field `reqt_test_scores` (value 3 = "Considered but not required") is the closest to "test-optional," but this classification is coarse and lags behind actual policies. The `sat_act_report_period = 3` field ("Test scores not required") is a cleaner indicator. **FairTest's database is more current and granular for testing policy.**

---

#### 3. Federal Student Aid (FSA) — OPE School Code List

| Attribute | Details |
|---|---|
| **URL** | https://catalog.data.gov/dataset/federal-school-code-list-for-free-application-for-federal-student-aid-fafsa-6cefe |
| **Access Method** | Direct download (Excel XLS + PDF); updated quarterly |
| **Format** | XLS |
| **Cost** | Free (public domain, CC Zero) |
| **Update Frequency** | Quarterly |
| **Institution Coverage** | All Title IV-participating schools |

**Available Fields:**
- Federal School Code (FSC) — unique identifier for FAFSA routing
- School name, address
- OPE ID (links to IPEDS UNITID via College Scorecard crosswalk files)

**Purpose for App:** Used as a master school ID list; links FAFSA codes to IPEDS UNITIDs. Not a source of application or enrollment process data.

---

### Application Platform Sources

#### 4. Common App

| Attribute | Details |
|---|---|
| **URL** | https://www.commonapp.org/explore |
| **Member Count** | 1,133+ colleges (as of 2025-26 cycle) |
| **Machine-Readable Export** | No public API or bulk download for member school data |
| **School Search Tool** | Web interface at commonapp.org/explore — lists school name, location, first-year/transfer availability |
| **Cost** | No developer access available |

**What Common App Collects Per School (visible to applicants but not via API):**
- Application deadlines (EA, ED, RD) — schools set these in their College Information section
- Whether the school has Early Action, Early Decision I, Early Decision II, Regular Decision
- Decision plan closing dates and notification dates
- Application fee (and waiver availability)
- Requirements (essays, school forms, recommendations)
- Testing policy
- CEEB code (4-digit college code)

**What IS Accessible:**
- The web interface at commonapp.org/explore can be read programmatically; each school has a profile page
- Common App does NOT publish a machine-readable data export for developers
- STARS (School Transcript and Reporting System): 36 colleges used STARS for transcript submission in 2024-25; this is visible in school-specific settings
- 2025-26 What's New PDF: https://www.commonapp.org/files/Whats-New-25-26.pdf

**Key Insight:** Common App's per-school data (deadlines, fees, essay prompts) is only accessible by reading individual school profile pages. No public API exists. Schools update their own requirements each cycle (opens ~August 1).

---

#### 5. Coalition Application / Scoir

| Attribute | Details |
|---|---|
| **URL** | https://www.coalitionforcollegeaccess.org/ |
| **Member Count** | 170+ schools |
| **Application Platform** | Now hosted exclusively on Scoir (https://www.scoir.com) |
| **Machine-Readable Export** | No public API for developer access to school requirement data |
| **Member List** | Browsable at coalitionforcollegeaccess.org/our-members — filterable by state, public/private |

**What Scoir Collects Per School:**
- Application rounds (EA, ED, RD)
- Document requirements per round (required vs. optional vs. do-not-send)
- Application deadlines per round
- Transcript submission preferences
- Recommendation requirements

**Developer Access:** No public API. Scoir is a platform for high school counselors and colleges — data is institutional access only. Schools configure their own requirements in the Scoir portal.

**Key Insight:** Coalition/Scoir is relevant for ~170 selective schools but is not a data source accessible to external developers. Deadline and requirement data must be gathered from individual school pages.

---

#### 6. Universal College Application (UCA)

| Attribute | Details |
|---|---|
| **URL** | https://www.universalcollegeapp.com/ |
| **Status** | Still active (2025-26 application available) but severely diminished |
| **Member Count** | Effectively 1 active school (University of Charleston, WV only); most members migrated to Common App |
| **Machine-Readable Export** | No |

**Recommendation:** Treat the UCA as effectively defunct for practical purposes. No meaningful data source for a comprehensive database.

---

### Common Data Set (CDS)

#### Overview

The CDS initiative is a collaboration between **College Board, Peterson's, and U.S. News & World Report** to standardize institutional data reporting. There is **no centralized database or API** — each institution publishes its own CDS annually, typically as a PDF or Excel file on its website.

**No bulk CDS database exists publicly.** Each school self-reports and hosts its own document.

#### Complete CDS Section C Fields (2024-2025)

**C1: Application Volume**
- Total applicants (by gender: men, women, other, unknown)
- Total admits
- Total enrolled (full-time and part-time by gender)

**C2: Wait-list Data**
- Number offered wait-list placement; number accepting; number admitted
- Residency breakdown (in-state, out-of-state, international, unknown)

**C3: High School Completion Requirement**
- Diploma required (GED accepted or not); or not required

**C4: General College-Preparatory Program**
- Required / Recommended / Neither

**C5: Distribution of Required/Recommended HS Units**
- English, Math, Science (lab), Foreign Language, Social Studies, History, Academic Electives, Computer Science, Visual/Performing Arts, Other

**C6: Open Admission Policy**
- Open to all; open to most with selective exceptions; selective for some programs

**C7: Relative Importance of Admission Factors**
- Rating (Not Considered / Considered / Important / Very Important) for:
  - Academic: HS record rigor, class rank, GPA, standardized test scores, application essay, recommendations
  - Nonacademic: interview, extracurriculars, talent/ability, character/personal qualities, first generation, alumni relation, geographical residence, state residency, religious affiliation, volunteer work, work experience, level of applicant's interest

**C8: SAT and ACT Policies**
- C8A: Use of SAT/ACT in admission decisions (Yes/No); if yes, policy for Fall 2026:
  - Required for some / Recommended / Required for all / Test-optional (consider if submitted) / Test-blind (not considered)
  - Applies to: SAT or ACT; ACT Only; SAT Only
- C8D: Scores used for academic advising?
- C8E: Latest date for score receipt (Fall admission)
- C8F: Free-text policy clarification
- C8G: Tests used for placement (SAT, ACT, AP, CLEP, Institutional Exam, State Exam)

**C9: Score Profiles of Enrolled Students**
- % and # submitting SAT; % and # submitting ACT
- 25th / 50th / 75th percentiles for: SAT Composite, SAT EBRW, SAT Math, ACT Composite, ACT Math, ACT English, ACT Writing, ACT Science, ACT Reading

**C10: Class Rank**
- % in top 10th, 25th, 50th, bottom 50th, bottom 25th

**C11: GPA Distribution of Enrolled Students**
- Ranges from 4.0 down to Below 1.0; separately for score-submitters and non-submitters

**C12: Average High School GPA**
- % submitting; average GPA on 4.0 scale

**C13: Application Fee**
- Amount; waivable for financial need? Online fee (same/reduced)? Fee-free?

**C14: Application Closing Date**
- Fall closing date; priority date

**C15: Non-Fall Acceptance**
- Accepts students for terms other than fall?

**C16: Admission Decision Notification**
- Rolling (beginning date); by date; other

**C17: Reply Policy for Admitted Applicants**
- Must reply by date / no set date / May 1 or within N weeks
- **Housing deposit deadline** (Month/Day)
- **Housing deposit amount**
- Refundable? (Yes full / Yes partial / No)

**C18: Deferred Admission**
- Allowed? Maximum postponement period?

**C19: Early Admission of HS Students**

**C21: Early Decision**
- ED plan offered? ED I closing date + notification date; ED II closing date + notification date
- Number ED applications received; number admitted under ED

**C22: Early Action**
- EA plan offered? EA closing date + notification date; Restrictive EA?

#### Other CDS Sections Relevant to App

**Section G: Annual Expenses**
- Tuition (in-state, out-of-state), room & board, required fees, books/supplies, personal expenses

**Section F: Student Life**
- Housing options (coed dorms, men/women only, fraternity/sorority, cooperative, disabled housing, international, married)
- % living in college-owned housing

**Section H: Financial Aid** (aid data, deadlines for financial aid applications)

#### CDS Aggregators

| Source | Coverage | Format | Access | Notes |
|---|---|---|---|---|
| **College Transitions CDS Repository** | 211 schools, 2017-18 through 2024-25 | PDF links | Free, web-only | https://www.collegetransitions.com/dataverse/common-data-set-repository/ |
| **Road2College R2C Insights** | Selected schools | Web tool | Subscription | Aggregates key CDS metrics |
| **College Raptor** | Uses IPEDS primarily | Web | Free/subscription | |
| **BigFuture (College Board)** | 3,000+ schools | Web | No API | Survey questions largely CDS-based; data submitted by institutions |
| **Peterson's** | 4,200 schools | API + flat files | **Paid license** | Self-reported CDS-aligned data |
| **Niche.com** | 125k institutions | Web + licensed | **Paid for bulk** | Compiles IPEDS + proprietary surveys |
| **US News** | ~1,500 ranked schools | Web | No API | CDS-derived but no bulk access |

**Key Finding:** There is no free, machine-readable, bulk export of CDS data for all ~4,000 schools. The CDS system is fundamentally decentralized — data lives on each school's website as a PDF or Excel file. Building a comprehensive database requires either: (a) licensing Peterson's data, (b) collecting from individual school websites, or (c) a combination.

---

### Third-Party Data Sources

#### 7. Peterson's Data

| Attribute | Details |
|---|---|
| **URL** | https://petersonsdata.com |
| **Contact** | 720-334-8731 / data-info@petersons.com |
| **Coverage** | ~4,200 two- and four-year undergraduate institutions (US, Canada, Mexico, some international) |
| **Format** | API (improved version released 2022) + flat file delivery in 31 structured tables |
| **Cost** | **Paid — contact for pricing** (no public pricing listed) |
| **Update Frequency** | Multiple times per year; schools self-report via annual survey + Peterson's team supplements with research |
| **CDS Alignment** | Fully CDS-aligned as of March 2022 |

**Data Sets Available:**
- Undergraduate and Financial Aid Data Set
- Graduate Data Set
- Scholarship Data Set
- Specialty Data
- Custom data collection (Special Projects Team)

**Relevant Fields Covered:**
- Comprehensive CDS-aligned data (all CDS sections)
- Application deadlines (likely — CDS-sourced)
- Testing policies (CDS C8A)
- Application fees (CDS C13)
- Housing deposit data (CDS C17)
- Costs, financial aid, admissions statistics

**Assessment:** Peterson's is the strongest single commercial source for structured, CDS-aligned data at scale. It covers more schools and is updated more frequently than any public free source. The key limitation is that enrollment-process data (immunization deadlines, placement tests, orientation dates, portal setup) is NOT part of the CDS framework and would not be in Peterson's data.

---

#### 8. CollegeBoard / BigFuture

| Attribute | Details |
|---|---|
| **URL** | https://bigfuture.collegeboard.org/college-search |
| **School Count** | 4,300+ |
| **Developer Access** | No public API |
| **Data Collection** | Annual BigFuture College Profiles survey; schools self-report; questions largely CDS-based |
| **Fields** | Programs, costs, application requirements, deadlines |
| **Access** | Web only; no bulk download or API |
| **Institutions Submit Via** | highered.collegeboard.org/recruitment-admissions/bigfuture-profile-management |

**Assessment:** Contains the right data (deadlines, requirements) for 4,300+ schools but it is not accessible via API. Web-reading of individual school pages is technically possible but rate-limited and against terms of service. CEEB codes (4-digit) are available via College Board's K-12 School Code Search tool.

---

#### 9. Niche.com

| Attribute | Details |
|---|---|
| **URL** | https://www.niche.com/about/licensing/ |
| **Coverage** | 125k institutions (colleges + K-12) |
| **Data Sources** | IPEDS, OPE, NSF, Niche student surveys, Niche partner accounts (school-submitted data) |
| **Available Fields** | Niche grades/rankings, academic/outcome data, diversity data, gender data, enrollment by grade, athletic data |
| **API** | No publicly documented API |
| **Cost** | **Paid — custom pricing ("request a call")** |
| **Format** | Structured data in licensed delivery format |

**Assessment:** Niche's value-add is primarily proprietary rankings, student reviews, and aggregated qualitative data. Underlying factual data (admissions numbers, costs) is sourced from IPEDS anyway. Not recommended as a primary source for application-process fields — CDS or Peterson's would be more relevant.

---

#### 10. US News & World Report

| Attribute | Details |
|---|---|
| **URL** | https://www.usnews.com/best-colleges |
| **Coverage** | ~1,500 ranked institutions |
| **API** | No public API |
| **Data Access** | Web only; no bulk download |
| **Fields** | CDS-derived: acceptance rates, SAT/ACT ranges, tuition, graduation rates, rankings |
| **Cost** | Subscription for full data access on website |

**Assessment:** Data is CDS-derived and covers fewer schools than Peterson's or CollegeBoard. No usable programmatic access. Not recommended as a primary data source.

---

#### 11. Naviance (PowerSchool)

| Attribute | Details |
|---|---|
| **URL** | https://ps.powerschool-docs.com/naviance/ |
| **Type** | High school counseling platform (not a college data source) |
| **College Database** | Internal database of colleges with application data — used by counselors |
| **Developer Access** | No public API; unofficial GitHub project (smo-key/naviance-api, 2015) reverse-engineered login — not viable |
| **Data Export** | College application data can be imported/exported via CSV using fields: College Board ID (CEEB), ACT Code, NCES ID, application type (EA/ED/RD), deferred status, waitlist, final result, admit status |

**Assessment:** Naviance is not a data source — it is a platform for high school counselors to manage student applications. Its internal college database is proprietary and not accessible to developers. However, Naviance is a **key transcript transmission channel** for thousands of high schools (competitor to SSAR/STARS).

---

#### 12. National Student Clearinghouse

| Attribute | Details |
|---|---|
| **URL** | https://www.studentclearinghouse.org |
| **Purpose** | Enrollment and degree verification (not application data) |
| **Data Access** | Fee-per-verification ($4.95/enrollment, $19.95/degree); API for high-volume users |
| **Coverage** | Near-universal coverage of US postsecondary students |
| **Relevance** | Post-enrollment verification — not relevant to application requirements data |

**Assessment:** Not relevant for building pre-application or post-acceptance enrollment process data.

---

#### 13. CollegeAI API

| Attribute | Details |
|---|---|
| **URL** | https://collegeai.com/data |
| **Coverage** | Every US college |
| **Fields** | Tuition, net price, aid, salary outcomes, rankings, required tests, acceptance rate, SAT/ACT ranges, class size, demographics, sports/clubs |
| **Cost** | Not publicly disclosed (contact for pricing) |
| **Format** | REST API |

**Assessment:** Primarily aggregates College Scorecard + IPEDS + Niche rankings. Testing requirement field ("Required tests") is available but likely sourced from IPEDS, so the caveats about IPEDS testing policy data apply. Limited additional value over Scorecard + IPEDS directly.

---

#### 14. FairTest (National Center for Fair & Open Testing)

| Attribute | Details |
|---|---|
| **URL** | https://fairtest.org/test-optional-list/ |
| **Coverage** | 2,085+ bachelor's degree-granting institutions |
| **Data** | Testing policy type: Test-Optional, Test-Free; restrictions; permanent vs. temporary |
| **Bulk Access** | Available on request (includes IPEDS UnitIDs + additional policy information) |
| **Format** | Not specified (contact FairTest directly) |
| **Cost** | Likely free for non-commercial educational use (contact for terms) |
| **Update Frequency** | Maintained actively; reflects current cycle |

**Assessment:** FairTest is the most comprehensive and current source for testing policy classifications at the 2,000+ school scale. It distinguishes: Test-Required, Test-Optional (permanent), Test-Optional (temporary), and Test-Free. IPEDS testing fields lag by 1–2 years and use coarser categories. **Strongly recommended as a supplement to IPEDS for testing policy.**

---

#### 15. Urban Institute Education Data Portal

| Attribute | Details |
|---|---|
| **URL** | https://educationdata.urban.org/documentation/ |
| **Type** | Free REST API wrapping IPEDS + College Scorecard + other federal data |
| **Authentication** | None required |
| **Format** | JSON |
| **Cost** | Free (ODC-By license) |
| **R/Stata/Python packages** | Available on GitHub |

**Key Endpoints for College App:**
- `https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-requirements/{year}/`
- `https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-enrollment/{year}/`
- `https://educationdata.urban.org/api/v1/college-university/ipeds/directory/{year}/`
- `https://educationdata.urban.org/api/v1/college-university/scorecard/student-characteristics/aid-applicants/{year}/`

**Assessment:** The cleanest way to access IPEDS admissions data programmatically. Far easier than raw IPEDS downloads. Highly recommended as primary API for government data.

---

### Open-Source Projects & Datasets

#### 16. Existing GitHub Repositories

| Repository | Fields | Notes |
|---|---|---|
| **karllhughes/colleges** | Name, location, domain — sourced from OPE data | Basic list only; last updated 2016 |
| **hipo/university-domains-list** | Name, country, domains, web pages — worldwide | No admissions data |
| **ryan-serpico/us-college-coordinates** | Coordinates for 6,681 colleges from College Scorecard | Geocoordinates only |
| **lux-org/lux-datasets/college.csv** | AdmissionRate, ACTMedian, SATAverage, AverageCost, Expenditure, MedianDebt, MedianEarnings — ~1,295 schools | Subset of College Scorecard data; no deadline/policy data |

**No GitHub repository exists** that contains application deadlines, testing policies, essay requirements, or enrollment-process data for all ~4,000 US colleges. This data does not exist in any free, machine-readable bulk format.

#### 17. Kaggle Datasets

- **Graduate Admissions Dataset** (mohansacharya) — Indian graduate school admissions prediction data; no relevance
- **Student Admission Dataset** (amanace) — Simulated data; no relevance
- **General Kaggle discussions** have no substantive US college application data compilation

**Finding:** No Kaggle dataset provides the application requirement or enrollment process fields needed.

#### 18. Other Open-Source Notes

- **collegefacts.org** — A developer-built site aggregating IPEDS data for "thousands of colleges"; CDS-like data; no API
- **OpenEdu MCP Server** (Cicatriiz/openedu-mcp on GitHub, 2025) — Educational MCP server using free APIs; no college-specific application data

---

### Field Coverage Matrix

The table below maps each required data field against available data sources.

Legend: ✅ Available | ⚠️ Partial/Indirect | ❌ Not Available | 💰 Paid Only

#### Area 1: Application Requirements

| Field | College Scorecard | IPEDS/Urban API | Common Data Set | Peterson's | Common App | BigFuture | FairTest |
|---|---|---|---|---|---|---|---|
| Early Action deadline | ❌ | ❌ | ✅ (C22) | 💰 | ❌* | ❌* | ❌ |
| Early Decision deadline | ❌ | ❌ | ✅ (C21) | 💰 | ❌* | ❌* | ❌ |
| Regular Decision deadline | ❌ | ❌ | ✅ (C14) | 💰 | ❌* | ❌* | ❌ |
| Application platform (Common App/Coalition/direct) | ❌ | ❌ | ❌ | ⚠️ | ✅ (member list) | ⚠️ | ❌ |
| Testing policy (required/optional/blind) | ⚠️ (SAT % submitting) | ⚠️ (reqt_test_scores) | ✅ (C8A) | 💰 | ❌ | ❌ | ✅ (2,085 schools) |
| Supplemental essay count | ❌ | ❌ | ❌ | ❌ | ❌* | ❌ | ❌ |
| Application fee amount | ❌ | ❌ | ✅ (C13) | 💰 | ❌* | ❌ | ❌ |
| Transcript submission method (SSAR/STARS/Naviance) | ❌ | ❌ | ❌ | ❌ | ⚠️ (STARS list) | ❌ | ❌ |
| Admissions philosophy classification | ❌ | ❌ | ⚠️ (C7 factors) | ❌ | ❌ | ❌ | ❌ |

*Common App and BigFuture contain this data on individual school pages but have no API/bulk export.

#### Area 2: Post-Acceptance Enrollment

| Field | College Scorecard | IPEDS/Urban API | Common Data Set | Peterson's | Any Free Source |
|---|---|---|---|---|---|
| Enrollment deposit deadline | ❌ | ❌ | ✅ (C17) | 💰 | ❌ |
| Enrollment deposit amount | ❌ | ❌ | ✅ (C17) | 💰 | ❌ |
| Housing application open/close dates | ❌ | ❌ | ❌ | ❌ | ❌ |
| Required immunization records/deadlines | ❌ | ❌ | ❌ | ❌ | ❌ |
| Final transcript submission deadline | ❌ | ❌ | ❌ | ❌ | ❌ |
| Placement test requirements | ⚠️ | ⚠️ (C8G via CDS) | ⚠️ (C8G) | ⚠️ | ❌ |
| Student portal/email setup process | ❌ | ❌ | ❌ | ❌ | ❌ |
| Orientation dates and registration | ❌ | ❌ | ❌ | ❌ | ❌ |

---

### Data Gap Analysis

#### Critical Gaps — No Bulk Source Exists

The following data fields are **not available from any known bulk data source** and would require direct collection from individual school websites:

**Area 1 (Application):**
1. **Supplemental essay count and prompts** — Essay prompts change annually and are only published on individual school application portals (Common App college-specific sections, Coalition essays, direct portals). No aggregator has machine-readable access.
2. **Transcript submission method** (SSAR, STARS, Naviance, Parchment, official paper) — Only Common App's STARS participation list (36 schools in 2024-25) is semi-public.
3. **Admissions philosophy classification** — No standardized field in any data source; would require interpretation.

**Area 2 (Post-Acceptance):**
1. **Housing application open/close dates** — School-specific, published on individual housing office pages; no aggregator.
2. **Immunization records requirements and deadlines** — School health center specific; no aggregator.
3. **Final transcript submission deadline** — Registrar-specific; no aggregator.
4. **Student portal / email setup process** — IT department specific; no aggregator.
5. **Orientation dates and registration requirements** — Published annually by each school's orientation office; no aggregator.

#### Fields Available in CDS But Not in Free APIs

The following fields exist in the CDS but require either licensing Peterson's data or individual school CDS collection:
- Application fee amount (CDS C13)
- Exact EA/ED/RD closing dates (CDS C14, C21, C22)
- Housing deposit deadline and amount (CDS C17)
- Enrollment reply deadline (CDS C17)
- Detailed testing policy with nuance (CDS C8A, C8F)

#### Fields Available in Free APIs But Insufficient for App

- **Testing policy via IPEDS:** The `reqt_test_scores` field (0=not required/recommended, 1=required, 2=recommended, 3=considered) does not reliably capture "test-optional" as a modern policy category. It lags by 1-2 years. Use FairTest's database instead for this field.
- **Admission rate / selectivity:** Available via College Scorecard (current); good for admissions philosophy classification.
- **SAT/ACT score ranges:** Available via both IPEDS and College Scorecard; usable for admissions classification.

---

### Recommended Data Architecture

For a comprehensive college guidance app database covering ~4,000 institutions, a layered approach is necessary:

#### Layer 1: Free Government Data (Foundation)
**Sources:** College Scorecard API + Urban Institute Education Data API (IPEDS)
**What you get:**
- Master list of all institutions with UNITID/OPEID identifiers
- Location, type, control, Carnegie classification
- Admission rates, SAT/ACT score ranges (lagged ~1 year)
- Enrollment size, costs, completion rates
- Coarse testing policy indicator (IPEDS)
- Cover: ~7,000 institutions

**API calls needed:**
```
# All institutions with key fields:
https://api.data.gov/ed/collegescorecard/v1/schools?api_key=KEY&fields=id,school.name,school.state,school.city,school.school_url,latest.admissions.admission_rate.overall,latest.admissions.sat_scores.average.overall,latest.student.size,latest.cost.tuition.in_state,latest.cost.tuition.out_of_state&per_page=100

# IPEDS admissions requirements:
https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-requirements/2022/
```

#### Layer 2: Paid Licensing (CDS-Aligned Fields)
**Source:** Peterson's Data
**What you get:**
- CDS-aligned data for ~4,200 schools in structured tables
- Application deadlines (EA, ED, RD)
- Application fees
- Housing deposit amount and deadline
- Enrollment reply policy
- Testing policy (CDS C8A format)
- Updated multiple times per year

**Contact:** data-info@petersons.com / 720-334-8731

#### Layer 3: Specialized Free Sources (Testing Policy)
**Source:** FairTest database (contact for bulk export with IPEDS UnitIDs)
**What you get:**
- 2,085+ schools with current testing policies
- Distinctions: test-required, test-optional (permanent), test-optional (temporary), test-free
- Restrictions and notes

#### Layer 4: Application Platform Lists (Platform Routing)
**Source:** Common App member search (commonapp.org/explore, 1,133+ schools) + Coalition member list (coalitionforcollegeaccess.org/our-members, ~170 schools)
- These pages can be read programmatically to build platform routing logic
- No bulk API; requires web reading

#### Layer 5: Direct School Collection (Remaining Critical Fields)
The following fields have no bulk source and require direct collection from each school's website:
- Supplemental essay count and prompts (cycle-specific)
- Transcript submission method
- Housing application dates
- Immunization requirements
- Final transcript deadline
- Orientation dates
- Student portal setup process
- Placement test requirements (details beyond IPEDS C8G)

**Approach options:**
1. **Manual curation for top N schools** (top 500–1,000 by applicant volume)
2. **Automated collection pipeline** reading registrar/housing/orientation pages
3. **Partnership with existing platforms** (e.g., Scoir, which already aggregates this data for counselors)
4. **User-contributed updates** (counselors or students confirm/update school-specific data)

---

### Summary Table: All Data Sources

| Source | URL | Access | Cost | Format | Coverage | Key Fields for App |
|---|---|---|---|---|---|---|
| College Scorecard API | collegescorecard.ed.gov/data/api/ | API key (free) | Free | JSON | ~7,000 | Admission rate, SAT/ACT ranges, costs, size, location |
| IPEDS via Urban Institute | educationdata.urban.org | Open API | Free | JSON | ~7,000 | Testing requirements (coarse), admission volume, enrollment |
| IPEDS Bulk Download | nces.ed.gov/ipeds/use-the-data | Direct download | Free | CSV/Access | ~7,000 | All IPEDS survey data |
| FSA School Code List | catalog.data.gov (ED) | Direct download | Free (CC0) | XLS | All Title IV | School codes, IDs only |
| Common App Member List | commonapp.org/explore | Web reading | Free | HTML | 1,133 | Platform routing; per-school pages have deadlines/fees |
| Coalition Member List | coalitionforcollegeaccess.org/our-members | Web reading | Free | HTML | ~170 | Platform routing |
| Universal College App | universalcollegeapp.com | Web | Free | HTML | ~1 (effectively) | Ignore |
| CDS Template | commondataset.org | PDF download | Free | PDF | Framework only | Full admissions/enrollment template; NO aggregated data |
| College Transitions CDS | collegetransitions.com/dataverse/... | Web (PDF links) | Free | PDF | 211 schools | CDS PDFs for selective schools |
| Peterson's Data | petersonsdata.com | API + flat file | **Paid** | 31-table DB | 4,200 | CDS-aligned fields incl. deadlines, fees, housing deposit |
| BigFuture (CollegeBoard) | bigfuture.collegeboard.org | Web only | Free/no API | HTML | 4,300+ | Deadlines, requirements (no bulk access) |
| Niche Licensing | niche.com/about/licensing/ | License | **Paid** | Custom | 125k | Rankings, reviews, IPEDS-derived stats |
| US News | usnews.com/best-colleges | Web only | Subscription | HTML | ~1,500 | CDS-derived stats (no bulk access) |
| FairTest | fairtest.org/test-optional-list/ | Request bulk | Free/request | TBD | 2,085+ | Testing policy (test-optional/free/required) |
| CollegeAI API | collegeai.com/data | API | Contact | REST | All US | Testing req, acceptance rate, SAT/ACT, costs |
| Urban Institute API | educationdata.urban.org | Open API | Free | JSON | IPEDS scope | Best programmatic interface to IPEDS |
| National Student Clearinghouse | studentclearinghouse.org | Per-verification API | Paid | API | Near-universal | Enrollment/degree verification only |

---

*End of Area 1 & 2. All findings based on primary source investigation as of April 4, 2026.*

---

## Area 3: Florida-Specific College Planning

*Research compiled for Florida high school college guidance app*
*Sources: Florida Student Financial Aid SG, Florida Bright Futures Gov, FLDOE, Florida BOG, individual SUS university pages, International College Counselors, CollegeTuitionCompare*

---

### 1. Florida Bright Futures Scholarship Program

**Program URL:** https://www.floridabrightfutures.gov
**Application/Track URL:** https://www.floridastudentfinancialaidsg.org/SAPHome/SAPHome
**Official PDF – FAS/FMS requirements:** https://www.floridastudentfinancialaidsg.org/pdf/fas-fms.pdf
**Student Handbook:** https://www.floridastudentfinancialaidsg.org/pdf/bfhandbookchapter1.pdf

---

#### Overview
The Florida Bright Futures Scholarship Program is a state-funded, merit-based scholarship for Florida high school graduates who plan to attend a Florida postsecondary institution. It is **NOT need-based — there are NO income limits**. Award eligibility depends solely on academic achievement, test scores, and service hours.

---

#### General Eligibility Requirements (All Bright Futures Awards)
- Be a Florida resident and U.S. citizen or eligible noncitizen
- Complete the **Florida Financial Aid Application (FFAA)** no later than **August 31** after high school graduation
- Earn a standard Florida high school diploma (or equivalent) from a Florida public or registered FDOE private high school, or complete a home education program
- Not have been found guilty of (or pled nolo contendere to) a felony charge
- Be accepted by and enrolled in a degree or certificate program at an eligible Florida public or independent postsecondary institution
- Be enrolled in at least **6 non-remedial semester credit hours** per term

---

#### Award 1: Florida Academic Scholars (FAS)

| Requirement | Detail |
|-------------|--------|
| **Weighted GPA** | 3.50 minimum (Bright Futures GPA — see calculation method below) |
| **ACT Score** | 29 composite minimum (without Writing) |
| **SAT Score** | 1330 combined minimum (Reading+Writing and Math only; no Essay) |
| **CLT Score** | 95 overall minimum |
| **Required Coursework** | 16 college-preparatory credits (see below) |
| **Service/Work Hours** | 100 volunteer service hours OR 100 paid work hours OR combination totaling 100 hours |
| **Award Amount** | 100% of tuition and applicable fees at Florida public universities |
| **Per-Credit-Hour Value** | ~$205–$213/credit hour (varies by institution; ~$212.71/credit at UF; $207.73 at UNF; $205.57 at FIU) |
| **Additional Stipend** | $300/semester at private institutions toward additional educational costs |
| **Academic Top Scholars Award** | Additional $44/credit hour for the highest-ranked student in each county |

**Score thresholds by graduating class:**
- Class of 2025-26: ACT 29 / CLT 95 / SAT 1330
- Class of 2026-27: ACT 29 / CLT 95 / SAT 1330

**Required 16 College-Preparatory Course Credits (FAS):**
- 4 credits English (3 must include substantial writing)
- 4 credits Mathematics (at or above Algebra I level)
- 3 credits Natural Science (2 must have substantial laboratory component)
- 3 credits Social Science
- 2 credits World Language (sequential, in same language)

**Alternative Pathway — AP Capstone Diploma (current 10th/11th/12th graders in 2025-26):**
- Score of 3+ on AP Seminar and AP Research
- Scores of 3+ on four additional AP Exams of student's choice
*(For 9th graders in 2025-26 and thereafter, slightly different AP Capstone requirements apply)*

**FAS Renewal Requirements (college):**
- Minimum cumulative unweighted GPA of 3.0
- FAS students with 2.75–2.99 renew as FMS (one-time restoration opportunity to restore FAS)
- Funded for up to 5 academic years / maximum 120 credit hours
- Graduate in ≤7 semesters or ≤105 credit hours → eligible for 1 semester of graduate funding (up to 15 credit hours)

---

#### Award 2: Florida Medallion Scholars (FMS)

| Requirement | Detail |
|-------------|--------|
| **Weighted GPA** | 3.00 minimum (Bright Futures GPA) |
| **ACT Score** | 24 composite minimum |
| **SAT Score** | 1190 combined minimum |
| **CLT Score** | 82 overall minimum |
| **Required Coursework** | Same 16 college-preparatory credits as FAS |
| **Service/Work Hours** | 75 volunteer service hours OR 100 paid work hours OR combination totaling 100 hours |
| **Award Amount** | 75% of tuition and applicable fees at Florida public universities |
| **Per-Credit-Hour Value** | ~$154–$160/credit hour (varies by institution; ~$159.53/credit at UF; $154.17 at FIU; $158.42 at UWF) |

**Score thresholds by graduating class:**
- Class of 2025-26: ACT 24 / CLT 82 / SAT 1190
- Class of 2026-27: ACT 24 / CLT 82 / SAT 1190

**FMS Renewal Requirements (college):**
- Minimum cumulative unweighted GPA of 2.75
- Funded for up to 5 academic years / maximum 120 credit hours

---

#### Award 3: Gold Seal Vocational Scholars (GSV)

| Requirement | Detail |
|-------------|--------|
| **Weighted GPA (non-elective courses)** | 3.00 minimum (weighted GPA in non-elective high school courses) |
| **CTE GPA** | 3.5 unweighted GPA in Career and Technical Education courses |
| **CTE Credits** | At least 3 full credits in a single Career and Technical Education program |
| **ACT Scores** | English: 17, Reading: 19, Math: 19 |
| **SAT (March 1, 2024+)** | Evidence-Based Reading & Writing: 490, Math: 480 |
| **SAT (prior to March 1, 2024)** | Reading: 24, Writing: 25, Math: 24 |
| **PERT Scores** | Reading: 106, Writing: 103, Math: 114 |
| **Service/Work Hours** | 30 volunteer hours OR 100 paid work hours OR combination for 100 total (75 hours for students entering 9th grade in 2024-25 and thereafter) |
| **Award — Career certificate program** | $39/credit hour |
| **Award — Applied technology diploma** | $39/credit hour |
| **Award — Technical degree education program** | $48/credit hour |
| **Award — Bachelor of Science/Applied Science** | $48/credit hour |

*Students must be pursuing a certificate or vocational degree program.*

**GSV Renewal GPA:** 2.75 cumulative unweighted

---

#### Award 4: Gold Seal CAPE Scholars (GSC)

| Requirement | Detail |
|-------------|--------|
| **GPA** | No GPA requirement |
| **Test Scores** | No ACT/SAT/CLT score required |
| **CAPE Credits** | Earn minimum 5 postsecondary credit hours through CAPE Industry Certifications that articulate for college credit |
| **Service/Work Hours** | 30 volunteer hours OR 100 paid work hours OR combination for 100 total (75 hours for students entering 9th grade in 2024-25 and thereafter) |
| **Award — Career certificate or applied technology diploma** | $39/credit hour |
| **Award — Technical degree or Bachelor of Science/Applied Science** | $49/credit hour |
| **Special provision** | If CAPE program articulates to BS degree, student may receive award for up to 60 credit hours toward a BS degree |

*GSC is for students who already received or are pursuing an applied technology diploma, AAS, or AS degree, or a career certificate.*

**GSC Renewal GPA:** 2.75 cumulative unweighted

---

#### Income Limits
**There are NO income limits for the Bright Futures Scholarship.** The scholarship is purely merit-based. No financial need documentation is required. Students do not need to file the FAFSA to receive Bright Futures (the FFAA is a separate, Florida-only application).

---

#### Application Process and Deadlines

1. **Create an account** at the Florida Bright Futures website (https://www.floridabrightfutures.gov)
2. **Watch for an email from FDOE** with instructions to complete the Florida Financial Aid Application (FFAA)
3. **Complete the FFAA** during senior year — the window opens **October 1** of the student's senior year and closes **August 31** after high school graduation
   - Mid-year graduates: submit FFAA by December 31; scores through January 31 accepted
4. **Complete required coursework** (16 college-prep credits for FAS/FMS)
5. **Earn required GPA** in those courses
6. **Complete required service/work hours** — all hours must be documented in writing, signed by student, parent/guardian, and organization representative. Hours must be completed and documented on the high school transcript.
7. **Achieve required test scores** — tests must be taken **no later than August 31** of the graduation year (or January 31 for mid-year graduates). OSFA directly obtains official ACT, CLT, and SAT scores.
8. **Check your online account** for early evaluations (posted beginning March of senior year, based on 7th-semester transcript) and final evaluations (posted beginning July, based on final transcript)

**Public high school students:** Florida public high schools automatically send transcripts to OSFA — no action needed.
**Private/home school/out-of-state:** Must submit transcripts via secure upload or mail.

---

#### How the Bright Futures GPA is Calculated

The Bright Futures GPA is **not** the same as the student's school-reported GPA. Key features:

- **Only 16 specific college-preparatory credits are used** (4 English, 4 Math, 3 Natural Science, 3 Social Studies, 2 World Language)
- Students may use up to **2 additional credits** from qualifying academic or AP/IB/AICE fine arts courses to replace weaker grades and raise their GPA
- The GPA is calculated as **unrounded and weighted, to two decimal places**
- **Weighting:** The following courses receive **+0.25 quality points per semester (or +0.50 per year-long course)**:
  - Advanced Placement (AP)
  - Honors
  - International Baccalaureate (IB)
  - Pre-IB
  - Advanced International Certificate of Education (AICE)
  - Pre-AICE
  - Academic Dual Enrollment
- **Example:** An 'A' = 4.00 quality points for a standard course; an 'A' = **4.50 quality points** for a weighted year-long AP/IB/AICE/DE/Honors course
- Plusses and minuses are **not** used (grades are recorded as A, B, C, D, F)
- The calculation uses **semester-by-semester grades**, not end-of-year only
- **No class rank** is used
- This is distinct from UF's GPA weighting, which gives +1.0 for AP/IB/AICE/DE and +0.5 for Honors

**Practical implication:** A student with a 3.3 unweighted GPA who takes AP and honors courses can realistically achieve a 3.5+ Bright Futures GPA. Students should aim to take as many AP, IB, AICE, Honors, or dual enrollment courses as possible in the 16 required subject areas.

---

### 2. Florida Dual Enrollment Program

**FLDOE Dual Enrollment page:** https://www.fldoe.org/schools/higher-ed/fl-college-system/dual-enroll-transfer/
**Florida Statute § 1007.271:** https://www.flhouse.gov/Statutes/2025/1007.271/

---

#### What Is Dual Enrollment?

Dual enrollment (DE) is the **enrollment of an eligible secondary student (grades 6–12) or home education student in a postsecondary course that counts toward BOTH:**
- High school graduation requirements (earns high school credit)
- A postsecondary degree, career certificate, or associate/baccalaureate degree (earns college credit simultaneously)

A student receives **two transcripts**: a high school transcript showing the credit and a college transcript showing the same course at the postsecondary level.

---

#### Types of Dual Enrollment

1. **College Credit Dual Enrollment (Academic DE):** Courses that count toward an Associate in Arts (AA) or Associate in Science (AS) degree, or a baccalaureate degree. These are general education and upper-level academic courses.
2. **Career Dual Enrollment:** Courses that count toward a career certificate, applied technology diploma, or technical degree. Lower GPA threshold to participate.

---

#### Eligibility Requirements (Florida Statute § 1007.271)

**Academic (College Credit) DE — Initial Eligibility:**
- 3.0 unweighted cumulative high school GPA
- Demonstrated college-level communication and computation skills (placement tests: PERT, SAT, ACT, CLT 10, or CLT depending on course)
- Enrollment in a Florida public or registered private secondary school (or home education program)
- Parent/guardian permission

**Career Dual Enrollment — Initial Eligibility:**
- 2.0 unweighted cumulative high school GPA
- Guidance counselor recommendation

**Continued Eligibility:**
- Maintain 3.0 unweighted high school GPA (academic DE) or 2.0 (career DE)
- Maintain minimum postsecondary GPA established by the institution (typically 2.0–2.5 college GPA)

**Note:** Individual institutions may set **additional** initial eligibility requirements (e.g., minimum PERT scores). These are outlined in each school's Dual Enrollment Articulation Agreement.

---

#### Which Courses Count

**Eligible:**
- All college-level academic and career courses
- Courses can be taken on the high school campus (taught by postsecondary or credentialed high school faculty), on the college/university campus, or online
- Can be taken during school hours, after school, and during summer term

**Ineligible for Dual Enrollment:**
- Developmental/remedial/college-preparatory courses (Level 0 courses)
- Physical education courses that focus primarily on the physical execution of a skill (evaluated individually — recreation/leisure studies reviewed on case-by-case basis)
- Applied performing arts courses that require individual skill assessment for transfer purposes

---

#### How Dual Enrollment Credits Transfer Within Florida

**Florida's Statewide Course Numbering System (SCNS)** governs guaranteed transfer of DE credits within Florida.

**SCNS Overview:**
- All public postsecondary institutions in Florida (and 37 participating nonpublic institutions) use a common **3-letter prefix + 4-digit number** course identification system
- The SCNS is governed by Florida Statute § 1007.24 and administered by the FLDOE
- **Course equivalency** is determined by matching the **prefix and last 3 digits** of the course number (the first digit indicates level: 1-2 = lower division, 3-4 = upper division, 5-9 = graduate)
- SCNS website: https://flscns.fldoe.org

**Transfer Guarantee (Florida Statute § 1007.24(7)):**
> Any student who transfers among postsecondary institutions that are fully accredited by a regional or national accrediting agency and participate in the SCNS **shall be awarded credit** by the receiving institution for courses satisfactorily completed at the previous institution when judged equivalent — **regardless of whether the previous institution was public or private.**

**For dual enrollment specifically:**
- DE courses completed in high school **transfer on the same basis** as courses completed at the college
- The AA degree from a Florida College System (FCS) institution is **guaranteed to transfer** to any Florida public university and satisfy the institution's General Education requirements entirely
- Dual enrollment courses are **weighted the same as AP, IB, and AICE** on the high school GPA (prohibited by statute to weight them differently)

**Exceptions to Guaranteed Transfer (even within Florida SCNS):**
- Courses not offered by the receiving institution
- Developmental/remedial (Level 0) courses
- Courses in the X900-999 series (special topics, internships, practicums)
- Applied performing arts: ART, DAA, interior design, applied music (MVB, MVH, etc.), theater (TPP, 000–299)
- Criminal justice skills courses
- Courses where faculty credentials at sending institution don't match accreditation requirements of receiving institution

---

#### Transfer to Out-of-State Schools

DE credits are **not guaranteed** to transfer to out-of-state schools. Transfer depends on:
- The receiving institution's own transfer credit policies
- Whether the course has an equivalent at the receiving school
- Whether the sending institution is regionally accredited (most Florida colleges and universities are SACSCOC-accredited, which most out-of-state schools recognize)
- AP/IB credit is often more reliable for out-of-state transfer than DE credit
- Many selective out-of-state institutions may award elective credit rather than fulfilling major or general education requirements

**Best practice:** Students planning to attend out-of-state schools should use AP/IB exams as their primary acceleration pathway, as these have widely accepted national standards.

---

#### Who Pays for Dual Enrollment

**For public high school students:**
- **FREE** — students are **exempt from registration, tuition, and laboratory fees** per Florida Statute § 1007.271
- School districts pay public postsecondary institutions the standard tuition rate per credit hour from FEFP (Florida Education Finance Program) funds
- School districts also pay for instructional materials for public high school students earning high school graduation credit through DE
- For summer term DE, public postsecondary institutions receive an amount equivalent to the standard tuition rate per credit hour (subject to annual appropriation)

**For private school students:**
- Also free — costs associated with tuition and fees cannot be passed to the student, per the private school articulation agreement requirements
- The private school must have an articulation agreement with the postsecondary institution

**For students who have already graduated (post-graduation):**
- Students who enroll in postsecondary courses after high school graduation are **charged full cost of instruction** (roughly equivalent to out-of-state tuition rate)

---

#### Community College vs. State University Dual Enrollment

| Feature | Florida College System (FCS/Community Colleges) | State University System (SUS) |
|---------|------------------------------------------------|-------------------------------|
| **Scale** | Very common — every district has an articulation agreement | Less common — optional; each university president may designate a representative |
| **Typical courses** | General education: English Comp, College Algebra, Math, Humanities, Social Sciences, Natural Sciences | Higher-level academic courses; some universities have formal DE partnerships |
| **Leading to** | AA degree (guaranteed to transfer to all FL public universities) or AS/AAS degrees | May fulfill major prerequisites; more specialized |
| **Access** | Guaranteed by law if student meets eligibility | Depends on individual university participation |
| **Availability** | On-site at high school, at FCS campus, or online | Typically at university campus or online |
| **Example** | Valencia College, Miami Dade College, St. Petersburg College | UCF, UF, FSU formal DE partnerships |

---

### 3. Florida High School Graduation Requirements

**Primary Source:** FLDOE Standard Diploma Requirements: https://www.fldoe.org/core/fileparse.php/7764/urlt/standarddiplomarequirements.pdf
**Florida Statute § 1003.4282:** https://www.leg.state.fl.us/Statutes/index.cfm?App_mode=Display_Statute&URL=1000-1099%2F1003%2FSections%2F1003.4282.html

---

#### Diploma Options

Students may earn a standard diploma through one of five paths:
1. **24-Credit Standard Diploma** (most common — full 4 years)
2. **18-Credit ACCEL Option** (Academically Challenging Curriculum to Enhance Learning — accelerated early graduation)
3. **Career and Technical Education (CTE) Pathway** (at least 18 credits)
4. **International Baccalaureate (IB) Curriculum**
5. **Advanced International Certificate of Education (AICE) Curriculum**

---

#### 24-Credit Standard Diploma Requirements

**Minimum GPA:** 2.0 on a 4.0 scale (cumulative, all cohort years)

| Subject Area | Credits Required | Specific Requirements |
|-------------|------------------|-----------------------|
| **English Language Arts (ELA)** | 4 | ELA 1, 2, 3, 4; Honors, AP, AICE, IB, and DE courses may satisfy; must pass Grade 10 ELA statewide assessment (or concordant score) |
| **Mathematics** | 4 | Must include Algebra I (with EOC — counts 30% of final grade) and Geometry; one credit must be earned in the student's final year of high school; Industry Certifications leading to college credit may substitute for up to 2 math credits (not Algebra I or Geometry); identified computer science credit may substitute for 1 math credit (not Algebra I or Geometry) |
| **Science** | 3 | Must include Biology I; 2 credits must have a laboratory component; 2 additional credits must be equally rigorous science courses; Industry Certifications may substitute for 1 science credit (not Biology I); computer science credit may substitute for 1 science credit (not Biology I) |
| **Social Studies** | 3 | 1 credit World History, 1 credit U.S. History (with EOC), 0.5 credit U.S. Government, 0.5 credit Economics with Financial Literacy |
| **Fine/Performing Arts, Speech/Debate, or Practical Arts** | 1 | Eligible courses specified in Florida Course Code Directory |
| **Physical Education** | 1 | Must include integration of health; exemptions for students who participate in athletics, marching band, or cheerleading for 2 seasons |
| **Electives** | 8 | Significant flexibility — see below |
| **Online Course** | 1 (minimum) | At least one course must be completed through distance/online learning; note: not required for ACCEL or CTE pathway |
| **TOTAL** | **24** | |

**Statewide Assessments Required for Standard Diploma:**
- Grade 10 ELA (or concordant score)
- Algebra I EOC (or concordant/comparative score)
Students may use multiple pathways to demonstrate proficiency.

---

#### Elective Options (8 Credits)

Electives are highly flexible and may include:
- Additional courses in any core academic area
- Foreign/World Language courses (strongly recommended for SUS admission — 2 credits in the same language required for SUS)
- Career and Technical Education (CTE) courses
- Fine and performing arts
- Computer science / coding
- Dual enrollment courses
- AP, IB, or AICE courses beyond those counted in core credits
- JROTC
- Work-based learning programs

---

#### Standard Diploma vs. Scholar Designation vs. Merit Designation vs. Industry Scholar Designation

| Designation | Requirements |
|-------------|-------------|
| **Standard Diploma** | Complete 24 credits, earn 2.0+ GPA, pass required assessments |
| **Scholar Designation** | All standard requirements PLUS: 1 credit Algebra II (or equally rigorous math); 1 additional science credit (equally rigorous); 2 credits in the same World Language; at least 1 credit in AP, IB, AICE, or dual enrollment; pass U.S. History EOC |
| **Merit Designation (formerly Industry Scholar)** | All standard requirements PLUS: attain one or more approved industry certifications; earn the credit through an industry certification course (does NOT count for SUS admission) |

**Scholar Designation** is the "college prep track" — it aligns with SUS admission requirements and signals readiness for selective Florida universities. High-achieving students pursuing SUS schools should aim for the Scholar Designation.

---

#### Foreign Language Requirement

- Foreign language is **NOT required** for the standard diploma
- However, **2 credits of the same World Language** are required for admission to the Florida SUS (Board of Governors Regulation 6.002)
- The Scholar Designation also requires 2 credits of the same World Language
- Students planning to attend a SUS school should ensure they complete 2 years of World Language

---

#### Online Course Requirement

- Students in the 24-credit standard diploma track must complete at least **1 online course**
- This is not required for ACCEL, CTE Pathway, IB, or AICE diploma options
- Florida Virtual School (FLVS) and district virtual schools commonly fulfill this requirement

---

#### Community Service Requirements

There is **no statewide community service requirement for high school graduation** in Florida. Community service hours are required specifically for the **Bright Futures Scholarship** (not for the diploma itself). Individual school districts or schools may have their own local requirements — students should check with their school.

---

#### 18-Credit ACCEL Option

For early graduates:
- At least 18 credits total
- Same core subject requirements as the 24-credit option (English, Math, Science, Social Studies, PE, Fine Arts)
- Physical Education NOT required
- Online course NOT required
- Allows students to graduate in fewer than 8 semesters

---

#### CTE Pathway Diploma Option

- At least 18 credits total
- 4 elective credits include: 2 CTE credits resulting in a completed industry certification, plus 2 work-based learning or elective credits (may include financial literacy)
- PE not required
- Fine/Performing Arts/Practical Arts not required
- Online course not required
- Minimum 2.0 GPA

---

### 4. STARS — Self-Reported Transcript and Academic Record System

**UF STARS URL:** https://admissions.ufl.edu/apply/freshman/stars
**UF Freshman Application:** https://admissions.ufl.edu/apply/freshman/

---

#### What Is STARS?

STARS (Self-Reported Transcript and Academic Record System) is a **self-reported academic record system** used by most Florida SUS universities in place of requiring an official high school transcript during the initial application review. Students manually enter their own high school courses and grades exactly as they appear on their transcripts.

**STARS is used by:** UF, USF, and other SUS schools during the freshman admissions process. (USF calls it the same thing.)

STARS was formerly called the **SSAR (Self-Reported Student Academic Record)** at UF.

---

#### How UF's STARS Process Works

1. **Apply first:** Students submit their application through **Common App** (UF only accepts Common App for freshman applicants). Apply as a first-year student even if you have college credit or will graduate with your AA.

2. **Create your Gator Portal:** Within 24–48 hours of submitting the Common App, UF sends instructions to create a Gator Portal account (UF's applicant portal).

3. **Access STARS link:** After submitting the application, a link to create the STARS appears in the Gator Portal.

4. **Complete STARS:** Enter ALL high school and college courses (including dual enrollment) and grades **exactly as they appear on your official transcript**. This includes:
   - Every course taken in grades 9–12 (and any college courses)
   - Grades earned each semester/year
   - Course names exactly as listed on the transcript
   - Course level (regular, honors, AP, IB, AICE, dual enrollment)
   - Current-year (senior year) courses and anticipated grades

5. **Submit and link:** Submit the completed STARS and link it to your Common App application in the Gator Portal.

6. **Upload test scores:** Self-report SAT, ACT, and/or CLT scores through the Gator Portal (have official score reports available for accuracy). Official scores must also be sent by the testing agency using UF's institution code.

---

#### Is STARS Self-Reported?

**Yes — entirely self-reported.** STARS replaces the official transcript for the initial admissions review. However:
- **Accuracy is critical.** Admissions reviews STARS for consistency. If an error is detected, UF will email the student to correct and resubmit.
- If admitted and enrolled, students must submit **official final transcripts from all schools attended by July 1** for verification.
- If inaccuracies are found between the STARS and the official transcript, the consequences can include: **loss of admission, rescission of scholarship, cancellation of course registration.**
- A high school transcript submitted through Naviance, Parchment, or another third-party service does **NOT** substitute for the STARS.
- The "Courses & Grades" section of Common App also does **NOT** satisfy the STARS requirement.

---

#### STARS Exemptions

Not all applicants complete the STARS. Exemptions:
- GED graduates (submit official GED results + partial high school transcript)
- Transfer students
- International students who attended a non-U.S. high school **except:**
  - Students who attended a U.S. regionally accredited high school
  - Department of Defense Education Activity (DODEA) schools
  - American-style high schools abroad
  - Schools in Vietnam following the national curriculum

---

#### STARS Timeline

| Milestone | Timing |
|-----------|--------|
| STARS portal opens | August prior to senior year |
| Application submitted (Common App) | Before Early Action or Regular Decision deadlines |
| STARS link appears in Gator Portal | After submitting Common App |
| STARS completed and linked | As soon as possible after application |
| Early Action deadline (FL residents) | November 1; all materials by November 8 |
| Regular Decision deadline | March 1 |
| Official final transcripts due (if admitted) | July 1 |

---

#### STARS at Other SUS Schools

- **USF** uses the same STARS system (formerly called SSAR at USF as well). USF's STARS portal is accessed through the USF Applicant Portal after submitting the application. The window opens in August before senior year.
- **Most other SUS schools** use similar self-reported transcript systems. Students should check each institution's specific portal.

---

### 5. Florida State University System (SUS) — All 12 Schools

**SUS Overview:** Florida's higher education system has been ranked #1 in the nation by U.S. News & World Report for nine consecutive years.
**Official BOG Cost of Attendance (2025-26):** https://www.flbog.edu/wp-content/uploads/2025/07/Cost-of-Attendance-2025-26-For-Website.pdf

---

*Note on GPA data: All GPA figures below are weighted/recalculated GPAs for admitted freshmen (middle 50%), based on 2025 admissions cycle (entering fall 2025). Tuition figures are 2025-2026 annual in-state tuition and fees only (not room/board). SAT/ACT ranges are middle 50% (25th–75th percentile) for fall admits.*

---

#### 1. University of Florida (UF)
**Location:** Gainesville, FL
**Website:** www.ufl.edu | www.admissions.ufl.edu
**Phone:** 352-392-3261

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~24% (2024-25 cycle: 24.20%; 73,557 apps, 17,804 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.5–4.7 (weighted) |
| **Middle 50% SAT (Fall 2025)** | 1,390–1,510 |
| **Middle 50% ACT (Fall 2025)** | 31–34 |
| **Undergraduate Enrollment** | ~34,900 undergrads (~54,800 total) |
| **In-State Tuition & Fees (2025-26)** | **$6,380/year** |
| **Application Deadline** | Early Action (FL residents only): Nov. 1; Regular Decision: Jan. 15 |

**Notable Programs/Strengths:**
- Ranked #4 Public University (*Forbes*); lowest tuition among Top 50 national universities
- 120 majors across 16 colleges
- Leader in AI (200+ AI courses, AI undergraduate certifications)
- #5 alumni network for internships/career (*The Princeton Review*)
- Only university to win 3 NCAA DI titles in both football and basketball
- Special enrollment pathways: PaCE (hybrid online-to-campus), Innovation Academy (spring/summer), Gator Engineering at Santa Fe, Gator Design & Construction at Santa Fe
- Burnett Honors College

---

#### 2. Florida State University (FSU)
**Location:** Tallahassee, FL
**Website:** www.fsu.edu | admissions.fsu.edu
**Phone:** 850-644-6200

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~24–30% (2024-25 IPEDS: 24.22%, 78,272 apps; 2025 cycle: 30% admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.3–4.6 (weighted) |
| **Middle 50% SAT (Fall 2025)** | 1,370–1,460 |
| **Middle 50% ACT (Fall 2025)** | 30–33 |
| **Undergraduate Enrollment** | ~32,292 undergrads |
| **In-State Tuition & Fees (2025-26)** | **$5,654/year** |
| **Application Deadline** | EA (FL residents): Oct. 15; Regular Decision: Dec. 1 |

**Notable Programs/Strengths:**
- 275+ degree programs, 55+ combined Bachelor's/Master's pathways
- FSU Health initiative (academic health center opening Tallahassee 2026)
- University Honors Program (apply by Dec. 1; Middle 50%: GPA 4.4–4.7, SAT 1400–1510, ACT 31–34)
- Flying High Circus (only university-affiliated circus in U.S.)
- Notable: Business (Dedman College), Film, Music (one of top music schools), Law, Medicine

---

#### 3. University of Central Florida (UCF)
**Location:** Orlando, FL
**Website:** www.ucf.edu
**Phone:** 407-823-2000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~40% (2024-25: 40.11%, 61,456 apps, 24,653 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.11–4.57 (weighted) |
| **Middle 50% SAT (Fall 2025)** | 1,310–1,430 |
| **Middle 50% ACT (Fall 2025)** | 28–32 |
| **Undergraduate Enrollment** | ~59,155 (largest in Florida by enrollment) |
| **In-State Tuition & Fees (2025-26)** | **$5,954/year** |
| **Application Deadline** | May 1 (rolling admissions) |

**Notable Programs/Strengths:**
- #1 supplier of aerospace/defense graduates (7 years, *Aviation Week Network*)
- #1 world hospitality and tourism school (*ShanghaiRanking*)
- #5 world undergraduate game design (*Princeton Review/PC Gamer*)
- Burnett Honors College (separate application)
- New majors: Health Information Management, Interdisciplinary Healthcare Studies, Business Analytics
- 650+ clubs, NCAA Division I sports, strong Greek life
- Strong programs: Engineering, Computer Science, Optics, Hospitality, Digital Media, Health Sciences

---

#### 4. University of South Florida (USF)
**Location:** Tampa, FL (+ St. Petersburg and Sarasota-Manatee campuses)
**Website:** www.usf.edu
**Phone:** (Tampa) 813-974-2011

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~43% (2024-25: 43.19%, 68,576 apps, 29,621 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.03–4.55 (weighted, fall); 3.61–4.18 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,260–1,410 |
| **Middle 50% ACT (Fall 2025)** | 27–31 |
| **Undergraduate Enrollment** | ~38,525 undergrads (~49,622 total) |
| **In-State Tuition & Fees (2025-26)** | **$6,410/year** |
| **Application Deadline** | Rolling |

**Notable Programs/Strengths:**
- USF Health Morsani College of Medicine — #1 in Florida (*U.S. News*)
- Bellini College of AI, Cybersecurity, and Computing (first in Florida dedicated to AI/cybersecurity)
- 240+ majors across 14 colleges, 740+ clubs
- Tampa: Computer Science, Nursing, Engineering, Design, Art & Performance
- St. Pete: Marine Biology, Graphic Arts, Sustainability Studies, Digital Communication
- Sarasota-Manatee: Business Analytics, Education, Nursing
- Carnegie R1 Research University; $750M research funding (FY2025)

---

#### 5. Florida International University (FIU)
**Location:** Miami, FL
**Website:** www.fiu.edu
**Phone:** 305-348-2000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~50–55% (2024-25: 54.66%, 32,855 apps, 17,957 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.1–4.6 (weighted, fall); 3.9–4.5 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,250–1,390 |
| **Middle 50% ACT (Fall 2025)** | 27–31 |
| **Undergraduate Enrollment** | ~44,363 undergrads (~53,953 total) |
| **In-State Tuition & Fees (2025-26)** | **$6,566/year** |
| **Application Deadline** | EA (FL residents): Nov. 3; Regular: Dec. 17 |

**Notable Programs/Strengths:**
- Medina Aquarius Program (world's only underwater research habitat)
- Strong in Business (top-ranked), International Relations, Education, Engineering
- New: Business and Government Leadership major; CS add-on to biology/psychology
- New Baptist Health Center (pediatric academic hospital partnership)
- 5,900 first-year students enrolled (2025)
- #1 most diverse college in U.S. (*U.S. News*); large Latin American focus
- Growing research enterprise; breaking ground on 1,200-bed residential hall

---

#### 6. Florida Atlantic University (FAU)
**Location:** Boca Raton, FL (+ Jupiter, Davie, Fort Lauderdale, Dania Beach, and Treasure Coast campuses)
**Website:** www.fau.edu
**Phone:** 561-297-3000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~59–66% (2024-25: 66.13%, 31,511 apps; 2025 cycle: 59%) |
| **Middle 50% GPA (Admitted Fall 2025)** | 3.78–4.35 (weighted, fall) |
| **Middle 50% SAT (Fall 2025)** | 1,100–1,280 |
| **Middle 50% ACT (Fall 2025)** | 22–28 |
| **Undergraduate Enrollment** | ~23,755 |
| **In-State Tuition & Fees (2025-26)** | **$5,976/year** |
| **Application Deadline** | EA: Oct. 15; Merit scholarship: Jan. 15 |

**Notable Programs/Strengths:**
- Carnegie R1 Research University
- Max Planck Florida Institute for Neuroscience partnership (brain research)
- Wilkes Honors College (GPA 4.12–4.58, SAT 1240–1430, ACT 26–32)
- BS/MD program (requires 4.3+ GPA, 1490+ SAT or 33+ ACT)
- 57,740 applications (26% increase 2024-25)
- Notable: Marine Biology, Engineering, Business, Nursing, Education, Computer Science

---

#### 7. Florida Gulf Coast University (FGCU)
**Location:** Fort Myers, FL
**Website:** www.fgcu.edu
**Phone:** 800-590-3428

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~63–77% (2024-25: 63.44%; other sources: 76–77%) |
| **Middle 50% GPA (Admitted Fall 2025)** | 3.79–4.54 (weighted, fall); 3.12–4.21 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,070–1,240 |
| **Middle 50% ACT (Fall 2025)** | 21–26 |
| **Undergraduate Enrollment** | ~14,227 (~16,000 total) |
| **In-State Tuition & Fees (2025-26)** | **$6,118/year** |
| **Application Deadline** | Rolling |

**Notable Programs/Strengths:**
- No tuition increase in 10 years (strong value proposition)
- 61% of students graduate with NO debt
- School of Nursing: 100% NCLEX pass rate
- 66 undergraduate majors, 54 minors; 20:1 student-to-faculty ratio; 74% classes by full-time faculty
- New: B.S. in Computer Science, B.S. in Hospitality & Tourism Management
- $22M donation toward Marieb College of Health & Human Services
- Service learning and sustainability as institutional hallmarks
- Strong health sciences programs

---

#### 8. University of North Florida (UNF)
**Location:** Jacksonville, FL
**Website:** www.unf.edu
**Phone:** 904-620-1000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~53% (2024-25: 53.24%, 21,778 apps, 11,594 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 4.00–4.53 (weighted, fall); 3.23–3.71 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,100–1,300 |
| **Middle 50% ACT (Fall 2025)** | 22–28 |
| **Undergraduate Enrollment** | ~14,264 (~16,453 total, highest in UNF history) |
| **In-State Tuition & Fees (2025-26)** | **$6,390/year** |
| **Application Deadline** | Rolling |

**Notable Programs/Strengths:**
- Osprey Ridge honors residence hall (new, fall 2025)
- BS in Advanced Manufacturing Engineering (only program of its kind in Florida)
- UNF Flight Deck Esports & Innovation Arena (opening 2026)
- 100+ majors, 81 minors; 200+ clubs
- Starting Fall 2025: guaranteed experiential internship, research, or professional opportunity for every undergraduate student
- New majors: Environmental Natural Science, Environmental Principles & Practice, Fintech
- Jacksonville ranked #2 Hottest Job Market in America (*Wall Street Journal*) and 4th Fastest-Growing City in U.S. (Census)
- Notable: Business (Coggin), Nursing, Education, Health Sciences, Computer Science

---

#### 9. University of West Florida (UWF)
**Location:** Pensacola, FL
**Website:** www.uwf.edu
**Phone:** 850-474-2000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~55–58% (2024-25: 58.24%, 10,201 apps, 5,941 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 3.58–4.22 (weighted, fall); 3.47–4.08 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,020–1,230 |
| **Middle 50% ACT (Fall 2025)** | 20–27 |
| **Undergraduate Enrollment** | ~9,661 (~14,371 total; tracking toward 15,000) |
| **In-State Tuition & Fees (2025-26)** | **$6,360/year** |
| **Application Deadline** | April 1 |

**Notable Programs/Strengths:**
- Kugelman Honors Program
- New Civil Engineering major (fall 2025)
- $32.5M Triumph Gulf Coast grant for cybersecurity and AI research
- New president: Manny Diaz Jr. (July 2025)
- 130+ organizations, 17 Greek chapters, 15 NCAA Division II teams
- 80% of grads employed ($40K+) or in continuing education within 1 year of graduation
- New state-of-the-art sports medicine facility
- Notable: Computer Science, Cybersecurity, Intelligent Systems, Education, Business, Health Sciences

---

#### 10. Florida A&M University (FAMU)
**Location:** Tallahassee, FL
**Website:** www.famu.edu
**Phone:** 850-599-3796

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~20–39% (2024-25 IPEDS: 20.56%; NEXT Magazine: 39%) |
| **Middle 50% GPA (Admitted Fall 2025)** | 3.69–4.25 (weighted, fall); 3.16–3.88 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,080–1,230 |
| **Middle 50% ACT (Fall 2025)** | 22–27 |
| **Undergraduate Enrollment** | ~7,796 (~9,265 total; tracking toward 10,000) |
| **In-State Tuition & Fees (2025-26)** | **$5,645/year** |
| **Application Deadline** | May 1 |

**Notable Programs/Strengths:**
- Florida's only HBCU and only public HBCU land-grant institution
- #1 public HBCU nationally by enrollment
- 94.6% freshman-to-sophomore retention rate
- 54 majors across 14 colleges/schools
- Three areas of distinction: (1) Health, Pharmacological Research & Allied Health Sciences; (2) Business Innovation in Supply Chain, Accounting & Cyber Policy; (3) Architecture, Agricultural Engineering & Environmental Design
- Award-winning Marching "100" band (performed at Grammy Awards, Super Bowl)
- "Set Friday" tradition — stepping and musical performances
- Strong pharmacy, nursing, law, journalism programs

---

#### 11. Florida Polytechnic University (Florida Poly)
**Location:** Lakeland, FL
**Website:** www.floridapoly.edu
**Phone:** 863-583-9050

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~45–58% (2024-25 IPEDS: 57.52%, 4,110 apps, 2,364 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | ~4.1 (fall); ~3.96 (summer) |
| **Middle 50% SAT (Fall 2025)** | 1,160–1,360 |
| **Middle 50% ACT (Fall 2025)** | 25–31 |
| **Undergraduate Enrollment** | ~1,569 (~1,618 total; 1,770 in 2025-26 academic year) |
| **In-State Tuition & Fees (2025-26)** | **$4,940/year** (lowest tuition in SUS) |
| **Application Deadline** | March 3 (rolling) |

**Notable Programs/Strengths:**
- Florida's only STEM-exclusive public university — **all 13 majors** are STEM-focused:
  - Applied Mathematics, Business Analytics, Computer Engineering, Computer Science, Data Science, Electrical Engineering, Environmental Engineering, Industrial Engineering, Information Technology, Interdisciplinary Engineering, Mechanical Engineering, Physics
- Highest graduate salaries among all Florida SUS universities (*MyFloridaFuture*)
- Top 10 Best Career Outcomes (*WalletHub*)
- Top 20 Public Engineering Programs Without Ph.D. (*U.S. News*)
- **100% of students complete an internship** as a graduation requirement
- Launching NAIA athletics in Fall 2026 (baseball, soccer, cross country, softball — with scholarships)
- Futuristic campus designed by Santiago Calatrava
- **Lowest in-state tuition in the SUS** at $4,940/year

---

#### 12. New College of Florida (NCF)
**Location:** Sarasota, FL
**Website:** www.ncf.edu
**Phone:** 941-487-5000

| Metric | Data |
|--------|------|
| **Acceptance Rate** | ~73–74% (2024-25 IPEDS: 73.20%, 1,623 apps, 1,188 admitted) |
| **Middle 50% GPA (Admitted Fall 2025)** | 3.7–4.3 (weighted) |
| **Middle 50% SAT (Fall 2025)** | 1,060–1,240 |
| **Middle 50% ACT (Fall 2025)** | 22–27 |
| **Undergraduate Enrollment** | ~710–900 (Florida's smallest public university) |
| **In-State Tuition & Fees (2025-26)** | **$6,723/year** |
| **Application Deadlines** | Nov. 1, April 15 |

**Notable Programs/Strengths:**
- Florida's designated public liberal arts college — unique non-traditional structure
- 50 Areas of Concentration (majors) in humanities, sciences, and interdisciplinary programs (new: International & Area Studies)
- **Average class size: 13 students; 8:1 student-to-faculty ratio** (most intimate learning environment in SUS)
- Narrative evaluations alongside GPAs (professors write narrative assessments of student progress)
- Independent Study Projects (ISPs): Students complete self-directed research/projects each January
- Thesis required for graduation
- 18 NAIA athletic teams
- Notable: Humanities, Natural Sciences, Psychology, Political Science, Environmental Studies, Economics

---

#### SUS 2025-26 In-State Tuition Summary Table

| University | In-State Tuition & Fees (2025-26) |
|------------|-----------------------------------|
| Florida Polytechnic | $4,940 |
| FAMU | $5,645 |
| FSU | $5,654 |
| FAU | $5,976 |
| UCF | $5,954 |
| FGCU | $6,118 |
| UF | $6,380 |
| UNF | $6,390 |
| USF | $6,410 |
| FIU | $6,566 |
| UWF | $6,360 |
| NCF | $6,723 |

*Source: Florida Board of Governors 2025-26 Cost of Attendance document (https://www.flbog.edu/wp-content/uploads/2025/07/Cost-of-Attendance-2025-26-For-Website.pdf)*

---

### 6. Florida Prepaid College Plans

**Official Website:** www.myfloridaprepaid.com
**Phone:** 1-800-552-GRAD (4723)
**Bright Futures + Prepaid Interaction Guide:** https://www.myfloridaprepaid.com/learn/blog/florida-bright-futures-scholarships-and-florida-prepaid-an-amazing-combo-2/

---

#### What Is Florida Prepaid?

The **Stanley G. Tate Florida Prepaid College Program** is the largest and longest-running prepaid tuition program in the United States. It is a **529 prepaid tuition plan** that allows families to lock in the future cost of tuition at today's prices at any Florida public college or university. The program is **guaranteed by the State of Florida** — families can never lose their investment.

**Key principle:** You pay today's rate (or a projected rate based on your child's age) now, and Florida Prepaid guarantees to cover whatever tuition actually costs when your child enrolls — even if tuition increases significantly.

---

#### How It Works

1. **Enroll during Open Enrollment** (annually February 1 – April 30; applications accepted year-round, but prices are locked in during Open Enrollment)
2. **Choose a plan type** based on your child's age and your budget
3. **Select a payment option:** lump sum, fixed monthly payments (to age 18), or 5-year payment schedule
4. **Florida Prepaid pays the school directly** for covered tuition and fees when your child enrolls
5. If actual tuition costs are **less** than projected: Florida Prepaid refunds the difference
6. If actual tuition costs are **more** than projected: Florida Prepaid covers the difference — guaranteed

**Eligibility to enroll:** The beneficiary (child) must be a Florida resident (or have a Florida resident parent/guardian) and must be age newborn through 11th grade. Beneficiary must have a valid Social Security number.

**Time limit:** Plan benefits must be used within **10 years** after the expected date of college enrollment (military service time excluded; extensions can be requested).

---

#### Plan Types (as of 2025-26 enrollment)

| Plan | Coverage | Notes |
|------|----------|-------|
| **1-Year University Plan** | 30 credit hours of tuition, tuition differential fee, and local fees at any SUS school | Buy one year at a time; can purchase multiple 1-Year plans |
| **2-Year University Plan** | 60 credit hours | |
| **4-Year University Plan** | 120 credit hours | Most comprehensive; covers full undergraduate degree |
| **2+2 Plan** | 60 credit hours at FCS (community college) + 60 hours at SUS (university) | For students planning AA → Bachelor's pathway |
| **4-Year Florida College Plan** | 120 credit hours at a Florida College System (community/state college) | Lower cost; for students staying at FCS schools |
| **2-Year Florida College Plan** | 60 credit hours at FCS | |
| **1-Year Dormitory Plan** | 2 semesters of on-campus housing (optional add-on) | |

**2025-26 Open Enrollment Pricing (starting monthly rates for newborns):**
- 1-Year University Plan: ~$29–$34/month
- 4-Year University Plan: ~$120–$140/month
- Plans can also be paid as a lump sum

---

#### What Florida Prepaid Covers

**Covered (plans purchased from 2011 to present):**
- Tuition (matriculation fee — basic instruction cost per credit hour)
- Tuition Differential Fee (SUS-only fee; covered by plans with university benefits)
- Local Fees (athletics, activities & services, health, technology — mandatory fees)

**NOT Covered:**
- Campus Fees (transportation, facilities, lab fees, green fees — these are institution-specific)
- Room and board (unless Dormitory Plan added)
- Books, supplies
- Personal expenses
- Graduate school (must apply unused undergraduate hours)

**Value at Out-of-State/Private/Trade Schools:**
- The plan pays the same amount it would pay to a Florida school — which may not cover the full out-of-state tuition. Students must pay the difference out of pocket.

---

#### How Florida Prepaid Interacts with Bright Futures

When a student has **both** Florida Prepaid and a Bright Futures Scholarship, the programs work together in a complementary way:

**Standard Application Order:**
1. **Florida Prepaid is applied first** — the college/university bills Florida Prepaid for tuition and covered fees
2. **Bright Futures is then applied** to remaining qualifying expenses (remaining fees, and if there's balance, it can cover books, transportation, or other educational expenses)
3. **Any remaining Bright Futures funds are refunded** to the student (typically deposited directly to the student's bank account if connected to the university portal) — this cash can be used for housing, food, transportation, books, etc.

**Strategic Options for Families:**
Families can choose to **defer or opt out** of using their Prepaid Plan in a given semester and use only Bright Futures, allowing the Prepaid credits to be saved for later (including potentially graduate school). This is sometimes advantageous when:
- FAS scholarship covers 100% of tuition and fees anyway
- The family wants to save Prepaid credits for graduate school (at undergraduate rates)
- The student may later transfer to an out-of-state institution where Prepaid value is limited

*To opt out of using Prepaid in a given semester, the student must notify the university in writing.*

**Important Distinction:**
- Bright Futures requires the FFAA (Florida Financial Aid Application), NOT the federal FAFSA
- Having Florida Prepaid does not disqualify students from FAFSA-based federal aid — only 5.64% of parent assets factor into the Student Aid Index (SAI) calculation
- Even with both Prepaid and Bright Futures, significant expenses remain uncovered: room, board, textbooks, transportation, personal expenses, and campus fees

**Example Scenario (FAS student at UF, 2025-26):**
- Tuition + fees: ~$6,380/year (30 credit hours = 15/semester)
- Florida Prepaid (4-Year University Plan): covers tuition differential fee + local fees → pays majority of the $6,380
- FAS Bright Futures: covers 100% of tuition and applicable fees (at ~$212.71/credit hour)
- Result: Prepaid covers what it contractually covers; any remaining tuition/fees covered by Bright Futures; any remaining Bright Futures balance (~$300/semester equivalent) refunded to student for other expenses

---

### Quick Reference: Key Florida Deadlines Checklist

| Deadline | Action |
|---------|--------|
| **August of sophomore/junior year** | Begin earning Bright Futures service/work hours |
| **October 1 (senior year)** | FFAA window opens for Bright Futures |
| **November 1 (senior year)** | UF Early Action deadline (FL residents only); FSU Early Action deadline |
| **December 1 (senior year)** | FSU Regular Decision deadline; FSU Honors Program application deadline |
| **January 15 (senior year)** | UF Regular Decision deadline |
| **February 1 – April 30** | Florida Prepaid Open Enrollment window |
| **March–April (senior year)** | Bright Futures early evaluation (7th-semester) notifications posted |
| **August 31 (after graduation)** | HARD DEADLINE: FFAA must be submitted; all qualifying test scores must be completed |
| **July (after graduation)** | Bright Futures final evaluations posted; UF official final transcripts due |

---

*All data sourced from official Florida agency and university websites. Admissions statistics reflect 2024-25 and 2025-26 cycles as most recently available. Award dollar amounts per credit hour may vary slightly by institution due to varying fee structures. Students should always verify current figures directly with their target institution's financial aid office.*

---

## Area 4: Common Data Set Section C7 Admissions Factors

*College Guidance App Reference — Compiled April 2026*

---

### PART 1: Understanding CDS Section C7

#### What is Section C7?

Section C7 of the Common Data Set is the "Basis for Selection" section within the broader "First-Time, First-Year Admission" chapter (Section C). It is the primary standardized mechanism by which US colleges and universities publicly disclose how they weight each admissions factor in their holistic review process.

The Common Data Set Initiative is a collaborative effort among data providers in the higher education community and publishers — specifically the College Board, Peterson's, and U.S. News & World Report. Every year, participating institutions complete the CDS template and post it publicly. The CDS is a set of standards and definitions of data items, not a survey database; schools self-report and self-post.

**C7 is considered "the holy grail"** of the CDS by college counselors because it is the closest thing to a public rubric for admissions officers' evaluation criteria. Source: [College Transitions CDS Repository](https://www.collegetransitions.com/dataverse/common-data-set-repository/) and [College Prep Counseling](https://www.collegeprepcounseling.com/blog/n2l6v7cem18vpgnw3jmbzzf9nenyd1).

#### Full List of CDS Section C7 Admissions Factors

From the official [CDS 2024-2025 Template](https://commondataset.org/wp-content/uploads/2024/11/CDS-2024-2025-TEMPLATE.pdf), C7 lists the following 18 factors, divided into Academic and Nonacademic categories:

**Academic Factors:**
1. Rigor of secondary school record
2. Class rank
3. Academic GPA
4. Standardized test scores
5. Application Essay
6. Recommendation(s)

**Nonacademic Factors:**
7. Interview
8. Extracurricular activities
9. Talent/ability
10. Character/personal qualities
11. First generation
12. Alumni/ae relation
13. Geographical residence
14. State residency
15. Religious affiliation/commitment
16. Racial/ethnic status *(note: some older templates include this; post-SFFA ruling many schools leave blank)*
17. Volunteer work
18. Work experience
19. Level of applicant's interest

> **Note:** The 2024-2025 template officially lists 18 factors (Racial/ethnic status was removed from C7 after the Supreme Court's SFFA ruling in June 2023). Some schools' recent CDS filings still include it as "Not Considered." The task prompt lists 19 factors; "Racial/ethnic status" is included in the older template.

#### Rating Categories (Exactly as Listed in C7)

Each school must rate each factor as one of:
- **Very Important** — Heavily weighted; can make or break an application
- **Important** — Meaningfully considered; above baseline weight
- **Considered** — Factored in but not decisive
- **Not Considered** — Explicitly not part of the review process

#### Where to Find Schools' CDS Reports

**Primary method:** Google `[School Name] Common Data Set [year]` — most schools publish directly on their Institutional Research or Provost office websites.

**Aggregators:**
- [commondatasets.fyi](https://www.commondatasets.fyi/) — Structured C7 data table for 100+ schools; free; data current through 2023-2024
- [College Transitions CDS Repository](https://www.collegetransitions.com/dataverse/common-data-set-repository/) — Links to PDFs for 300+ schools from 2017-18 through 2024-25
- [GradGPT Common Data Set](https://www.gradgpt.com/common-data-set/) — Visualized CDS data including C7 for many schools
- [commondatasets.com](https://commondatasets.com/) — Older aggregator with C7 tables

**Direct institutional PDF URLs (for this report's 30 schools):**
- Harvard: `https://bpb-us-e1.wpmucdn.com/sites.harvard.edu/dist/6/210/files/2024/05/CDS_2023-2024-Final-4755619e875b1241.pdf`
- Harvard 2024-25: Available via Scribd (posted Dec 2025)
- Cornell: `https://irp.dpb.cornell.edu/wp-content/uploads/2025/07/CDS-2024-2025-v6-print.pdf`
- Northwestern: `https://www.enrollment.northwestern.edu/data/2024-2025.pdf`
- Caltech: `https://iro.caltech.edu/documents/28464/Caltech_CDS_2023-2024_June_2024.pdf`
- Rice: `https://ideas.rice.edu/wp-content/uploads/2025/10/CDS_2024-25_WEBSITE.pdf`
- Duke: `https://provost.duke.edu/sites/default/files/CDS-2023-24-FINAL.pdf`
- UMich: `https://obp.umich.edu/wp-content/uploads/pubdata/cds/CDS_2024-25_UMAA.pdf`
- UCLA: `https://apb.ucla.edu/file/adc17998-724b-4ab0-a4d3-05b572fa1905`
- UVA: `https://ira.virginia.edu/sites/g/files/jsddwu1106/files/2023-2024%20CDS_FINAL_508.pdf`
- Georgia Tech: `https://irp.gatech.edu/files/CDS/CDS_2023-2024_V3.pdf`
- UF: `https://data-apps.ir.aa.ufl.edu/public/cds/CDS_2024-2025_UFMAIN_Post_v1.pdf`
- BU: `https://www.bu.edu/asir/files/2025/03/cds-2025.pdf`
- UCF: `https://analytics.ucf.edu/wp-content/uploads/2025/08/Common-Data-Set-2024-2025.pdf`
- Georgetown: `https://oads.georgetown.edu/commondataset/`
- Notre Dame: `https://iris.nd.edu/institutional-research/common-data-set-cds/`

---

### PART 2: Data Collection Strategy — Bulk/Aggregated Sources

#### Does the Common Data Set Initiative Publish Compiled Data?

**No.** Per [commondataset.org](https://www.commondataset.org/), "The CDS is a set of standards and definitions of data items rather than a survey instrument or set of data represented in a database." The Initiative only publishes the template/form; individual schools self-report and self-host their data. There is no centralized CDS database from the Initiative itself.

#### GitHub Repositories with Compiled CDS Data

- **[groverneev/College-Statistics](https://github.com/groverneev/College-Statistics)** — A data visualization dashboard for comparing colleges using CDS metrics; covers historical trends for admissions and test scores. Partial CDS data.
- **[CyberSkyline/schools](https://github.com/CyberSkyline/schools)** — Database of colleges/universities but uses IPEDS and College Scorecard data, not raw CDS C7 factor data.
- No comprehensive GitHub repo with pre-compiled C7 factor ratings for all schools was found. This remains a gap requiring custom extraction.

#### Commercial/API Sources

- **College Board, Peterson's, U.S. News:** All use CDS data in their products, but none offer a public free API for C7 data.
- **IPEDs (nces.ed.gov):** Covers enrollment, graduation, and financial data but not C7 admissions factor ratings.
- **CollegeScorecard (ED):** Contains outcomes data but not C7 factor ratings.
- **No commercial API** was found that specifically exposes CDS C7 factor ratings across schools.

#### commondataset.org Assessment

The [official CDS website](https://www.commondataset.org/) provides:
- Annual template PDFs (the form schools fill out)
- Definitions and standards documentation
- Advisory board information
- **Does NOT provide:** Any compiled school-level CDS data, search tools, or APIs

**Conclusion for App Development:** C7 data must be collected manually from individual school PDFs or via third-party aggregators like commondatasets.fyi and College Transitions' repository. A custom pipeline to fetch and parse PDFs would be needed for bulk collection. The commondatasets.fyi site appears to have done this for 100+ schools and presents structured C7 data tables.

---

### PART 3: Sample C7 Data for 30 Schools

#### Methodology Notes

- Data sourced from most recent available CDS (2024-2025 where available, otherwise 2023-2024)
- Primary sources: Official institutional PDF publications and commondatasets.fyi
- Rating abbreviations: **VI** = Very Important, **I** = Important, **C** = Considered, **NC** = Not Considered
- Harvard's C7 is unusual: they rate almost all factors as "Considered" — this is intentional and reflects their fully holistic approach where everything is weighed contextually

---

#### Master C7 Data Table — All 30 Schools

Legend: VI = Very Important | I = Important | C = Considered | NC = Not Considered

| Factor | Harvard | MIT | Stanford | Yale | Princeton | Columbia | UPenn | Duke |
|--------|---------|-----|----------|------|-----------|----------|-------|------|
| **Rigor of secondary school record** | C | I | VI | VI | VI | VI | VI | VI |
| **Class rank** | NC | C | VI | VI | VI | VI | I | I |
| **Academic GPA** | C | I | VI | VI | VI | VI | VI | VI |
| **Standardized test scores** | C | I | C | C | VI | C | C | C |
| **Application Essay** | C | I | VI | VI | VI | VI | VI | C |
| **Recommendation(s)** | C | I | VI | VI | VI | VI | VI | VI |
| **Interview** | C | NC | C | C | C | NC | NC | C |
| **Extracurricular activities** | C | I | VI | VI | VI | VI | I | VI |
| **Talent/ability** | C | I | VI | VI | VI | I | I | VI |
| **Character/personal qualities** | C | VI | VI | VI | VI | VI | VI | VI |
| **First generation** | C | C | C | C | C | C | C | C |
| **Alumni/ae relation** | C | NC | C | C | C | C | C | C |
| **Geographical residence** | C | C | C | C | C | C | C | C |
| **State residency** | NC | NC | NC | C | NC | NC | C | C |
| **Religious affiliation/commitment** | NC | NC | NC | NC | NC | NC | NC | C |
| **Racial/ethnic status** | — | — | — | — | — | — | — | — |
| **Volunteer work** | C | C | C | C | C | C | I | C |
| **Work experience** | C | C | C | C | C | C | I | C |
| **Level of applicant's interest** | NC | NC | NC | NC | NC | NC | NC | C |

*Sources: [Harvard CDS 2023-24](https://bpb-us-e1.wpmucdn.com/sites.harvard.edu/dist/6/210/files/2024/05/CDS_2023-2024-Final-4755619e875b1241.pdf) | [MIT CDS via commondatasets.fyi](https://www.commondatasets.fyi/mit) | [Stanford CDS via commondatasets.fyi](https://www.commondatasets.fyi/stanford) | [Yale CDS via commondatasets.fyi](https://www.commondatasets.fyi/yale) | [Princeton CDS via commondatasets.fyi](https://www.commondatasets.fyi/princeton) | [Columbia CDS via commondatasets.fyi](https://www.commondatasets.fyi/columbia) | [UPenn CDS via commondatasets.fyi](https://www.commondatasets.fyi/upenn) | [Duke CDS 2023-24 PDF](https://provost.duke.edu/sites/default/files/CDS-2023-24-FINAL.pdf)*

---

| Factor | Caltech | Northwestern | Johns Hopkins | Brown | Dartmouth | Cornell | Rice | Vanderbilt |
|--------|---------|-------------|--------------|-------|-----------|---------|------|-----------| 
| **Rigor of secondary school record** | VI | VI | VI | VI | VI | VI | VI | VI |
| **Class rank** | I | VI | VI | VI | VI | I | VI | VI |
| **Academic GPA** | I | VI | VI | VI | VI | I | VI | VI |
| **Standardized test scores** | I | C | C | VI | VI | C | VI | I |
| **Application Essay** | VI | VI | VI | VI | VI | VI | VI | VI |
| **Recommendation(s)** | VI | VI | VI | VI | VI | VI | VI | I |
| **Interview** | NC | C | NC | NC | C | C | NC | C |
| **Extracurricular activities** | I | VI | I | I | VI | VI | I | VI |
| **Talent/ability** | C | VI | I | VI | I | VI | I | I |
| **Character/personal qualities** | VI | VI | I | VI | VI | VI | I | VI |
| **First generation** | C | C | C | C | C | C | I | C |
| **Alumni/ae relation** | NC | C | NC | C | C | C | I | C |
| **Geographical residence** | C | C | C | C | C | C | I | C |
| **State residency** | NC | NC | NC | C | NC | C | I | C |
| **Religious affiliation/commitment** | NC | NC | NC | NC | NC | NC | NC | NC |
| **Racial/ethnic status** | — | — | — | — | — | — | — | — |
| **Volunteer work** | C | C | I | C | C | C | I | C |
| **Work experience** | C | C | I | C | C | C | I | C |
| **Level of applicant's interest** | NC | C | NC | NC | C | NC | I | NC |

*Sources: [Caltech CDS 2023-24 PDF](https://iro.caltech.edu/documents/28464/Caltech_CDS_2023-2024_June_2024.pdf) | [Northwestern CDS 2024-25 PDF](https://www.enrollment.northwestern.edu/data/2024-2025.pdf) | [Johns Hopkins CDS via commondatasets.fyi](https://www.commondatasets.fyi/johns-hopkins) | [Brown CDS via commondatasets.fyi](https://www.commondatasets.fyi/brown) | [Dartmouth CDS via commondatasets.fyi](https://www.commondatasets.fyi/dartmouth) | [Cornell CDS via commondatasets.fyi](https://www.commondatasets.fyi/cornell) | [Rice CDS 2024-25 PDF](https://ideas.rice.edu/wp-content/uploads/2025/10/CDS_2024-25_WEBSITE.pdf) | [Vanderbilt CDS via Cosmic College Consulting](https://www.cosmic.nyc/blog/vanderbilt-admissions-2024-2025)*

---

| Factor | Notre Dame | Georgetown | UCLA | UC Berkeley | UMich | UVA | Georgia Tech | UNC Chapel Hill |
|--------|-----------|-----------|------|------------|-------|-----|-------------|----------------|
| **Rigor of secondary school record** | VI | VI | VI | VI | VI | VI | VI | VI |
| **Class rank** | VI | VI | NC | NC | NC | VI | NC | NC |
| **Academic GPA** | VI | VI | VI | VI | VI | VI | VI | I |
| **Standardized test scores** | I | VI | NC | NC | I | C | I | C |
| **Application Essay** | VI | VI | VI | VI | I | I | VI | I |
| **Recommendation(s)** | VI | VI | NC | C | I | I | C | I |
| **Interview** | NC | I | NC | NC | NC | NC | NC | NC |
| **Extracurricular activities** | VI | I | I | I | C | I | I | I |
| **Talent/ability** | VI | VI | I | C | C | I | C | I |
| **Character/personal qualities** | VI | VI | I | I | I | VI | VI | I |
| **First generation** | I | C | C | C | I | C | C | I |
| **Alumni/ae relation** | C | C | NC | NC | NC | C | NC | C |
| **Geographical residence** | C | C | C | NC | C | C | I | C |
| **State residency** | C | C | C | NC | C | VI | VI | I |
| **Religious affiliation/commitment** | I | NC | NC | NC | NC | NC | NC | NC |
| **Racial/ethnic status** | — | — | NC | — | — | — | C | — |
| **Volunteer work** | VI | C | I | I | C | C | C | I |
| **Work experience** | C | C | I | I | C | C | C | I |
| **Level of applicant's interest** | NC | NC | NC | NC | C | NC | NC | NC |

*Sources: [Notre Dame CDS 2024-25 via Next Gen Admit](https://nextgenadmit.com/notre-dame-admission-statistics/) | [Georgetown CDS 2024-25 via The Koppelman Group](https://www.koppelmangroup.com/blog/2026/3/8/georgetown-admissions-statistics-2025) | [UCLA CDS 2023-24 PDF](https://apb.ucla.edu/file/adc17998-724b-4ab0-a4d3-05b572fa1905) | [UC Berkeley CDS via Admit Report](https://admitreport.com/blog/uc-berkeley-common-data-set) | [UMich CDS 2024-25 PDF](https://obp.umich.edu/wp-content/uploads/pubdata/cds/CDS_2024-25_UMAA.pdf) | [UVA CDS 2023-24 PDF](https://ira.virginia.edu/sites/g/files/jsddwu1106/files/2023-2024%20CDS_FINAL_508.pdf) | [Georgia Tech CDS 2023-24 PDF](https://irp.gatech.edu/files/CDS/CDS_2023-2024_V3.pdf) | [UNC CDS 2024-25 via Cosmic College Consulting](https://www.cosmic.nyc/blog/unc-chapel-hill-admissions-2024-2025)*

---

| Factor | NYU | Boston Univ. | Univ. of Florida | Florida State | USF | UCF |
|--------|-----|-------------|-----------------|--------------|-----|-----|
| **Rigor of secondary school record** | VI | VI | VI | VI | VI | VI |
| **Class rank** | VI | C | I | I | C | I |
| **Academic GPA** | VI | VI | VI | I | VI | VI |
| **Standardized test scores** | VI | C | VI | I | VI | C |
| **Application Essay** | VI | VI | I | I | NC | C |
| **Recommendation(s)** | VI | I | C | NC | NC | NC |
| **Interview** | — | C | NC | NC | NC | NC |
| **Extracurricular activities** | — | I | C | I | NC | C |
| **Talent/ability** | VI | I | C | I | NC | C |
| **Character/personal qualities** | VI | I | C | I | NC | C |
| **First generation** | VI | C | C | I | NC | C |
| **Alumni/ae relation** | VI | C | C | NC | NC | NC |
| **Geographical residence** | VI | C | C | I | NC | NC |
| **State residency** | VI | NC | C | I | NC | C |
| **Religious affiliation/commitment** | VI | NC | NC | NC | NC | NC |
| **Racial/ethnic status** | — | — | — | — | — | — |
| **Volunteer work** | VI | C | C | I | NC | C |
| **Work experience** | VI | C | C | I | NC | C |
| **Level of applicant's interest** | VI | C | C | NC | NC | C |

*Sources: [NYU CDS 2024-25 via The Koppelman Group](https://www.koppelmangroup.com/blog/2026/1/27/new-york-university-nyu-admissions-statistics-2025) | [BU CDS 2024-25 PDF](https://www.bu.edu/asir/files/2025/03/cds-2025.pdf) | [UF CDS 2024-25 PDF](https://data-apps.ir.aa.ufl.edu/public/cds/CDS_2024-2025_UFMAIN_Post_v1.pdf) | [FSU CDS 2024-25 via GradGPT](https://www.gradgpt.com/common-data-set/florida-state-university) | [USF CDS 2024-25 via GradGPT](https://www.gradgpt.com/common-data-set/university-of-south-florida) | [UCF CDS 2024-25 PDF](https://analytics.ucf.edu/wp-content/uploads/2025/08/Common-Data-Set-2024-2025.pdf)*

---

### Individual School Profiles

#### 1. Harvard University
**CDS Year:** 2023-2024 (2024-2025 also available; same ratings)
**Official URL:** https://bpb-us-e1.wpmucdn.com/sites.harvard.edu/dist/6/210/files/2024/05/CDS_2023-2024-Final-4755619e875b1241.pdf

Harvard's C7 is uniquely flat — virtually every factor is rated "Considered." This is a deliberate reflection of their fully contextual holistic review. No factor is rated "Very Important" or "Important." Harvard evaluates everything in context, making direct cross-school comparisons of their C7 ratings misleading without understanding their philosophy.

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | Considered |
| Class rank | Not Considered |
| Academic GPA | Considered |
| Standardized test scores | Considered |
| Application Essay | Considered |
| Recommendation(s) | Considered |
| Interview | Considered |
| Extracurricular activities | Considered |
| Talent/ability | Considered |
| Character/personal qualities | Considered |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 2. MIT (Massachusetts Institute of Technology)
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/mit

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | Important |
| Class rank | Considered |
| Academic GPA | Important |
| Standardized test scores | Important |
| Application Essay | Important |
| Recommendation(s) | Important |
| Interview | Important |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** MIT rates almost everything "Important" with only Character/personal qualities as "Very Important." Like Harvard, this reflects a contextual holistic approach but with more explicit weight on personal character.

---

#### 3. Stanford University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/stanford

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 4. Yale University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/yale

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 5. Princeton University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/princeton

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** Princeton is one of the few schools that rates standardized test scores as "Very Important," even post-test-optional era. Princeton re-instated testing requirements.

---

#### 6. Columbia University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/columbia

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 7. University of Pennsylvania (UPenn)
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/upenn

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 8. Duke University
**CDS Year:** 2023-2024
**Official URL:** https://provost.duke.edu/sites/default/files/CDS-2023-24-FINAL.pdf

Duke's C7 uses a binary approach: either "Very Important" or "Considered" — with nothing in "Important" or "Not Considered" for most factors.

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | Considered |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

#### 9. California Institute of Technology (Caltech)
**CDS Year:** 2023-2024
**Official URL:** https://iro.caltech.edu/documents/28464/Caltech_CDS_2023-2024_June_2024.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | Important |
| Standardized test scores | Important |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Considered |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 10. Northwestern University
**CDS Year:** 2024-2025
**Official URL:** https://www.enrollment.northwestern.edu/data/2024-2025.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

#### 11. Johns Hopkins University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/johns-hopkins

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 12. Brown University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/brown

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** Brown rates standardized test scores as "Very Important" — unusual for a test-optional school. This may reflect data from a cycle before Brown's test-optional policy or their updated stance.

---

#### 13. Dartmouth College
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/dartmouth

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

#### 14. Cornell University
**CDS Year:** 2023-2024
**Official URL:** https://www.commondatasets.fyi/cornell

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | Important |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 15. Rice University
**CDS Year:** 2024-2025
**Official URL:** https://ideas.rice.edu/wp-content/uploads/2025/10/CDS_2024-25_WEBSITE.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Important |
| Alumni/ae relation | Important |
| Geographical residence | Important |
| State residency | Important |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Important |

**Notable:** Rice has an unusually generous definition of "Important" — nearly everything nonacademic is rated Important, including alumni relation and geographical residence. This makes the Important tier very broad at Rice.

---

#### 16. Vanderbilt University
**CDS Year:** 2024-2025
**Source:** [Cosmic College Consulting analysis of official CDS](https://www.cosmic.nyc/blog/vanderbilt-admissions-2024-2025)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Important |
| Application Essay | **Very Important** |
| Recommendation(s) | Important |
| Interview | Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 17. University of Notre Dame
**CDS Year:** 2024-2025
**Source:** [Next Gen Admit analysis of Notre Dame CDS 2024-25](https://nextgenadmit.com/notre-dame-admission-statistics/)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Important |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Not Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Important |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Important |
| Volunteer work | **Very Important** |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** Notre Dame is the only school in this set rating religious affiliation/commitment as "Important" and volunteer work as "Very Important" — reflecting their Catholic mission.

---

#### 18. Georgetown University
**CDS Year:** 2024-2025
**Sources:** [The Koppelman Group Georgetown analysis](https://www.koppelmangroup.com/blog/2026/3/8/georgetown-admissions-statistics-2025) | [Next Gen Admit](https://nextgenadmit.com/georgetown-admission-statistics/)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | Important |
| Extracurricular activities | Important |
| Talent/ability | **Very Important** |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** Georgetown requires interviews (unique among this set of schools) and rates test scores as "Very Important." Georgetown does not use test-optional admissions.

---

#### 19. UCLA (University of California, Los Angeles)
**CDS Year:** 2023-2024
**Official URL:** https://apb.ucla.edu/file/adc17998-724b-4ab0-a4d3-05b572fa1905

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Not Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | Not Considered |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

**Notable:** UCLA is test-free (not test-optional) — test scores are "Not Considered." Recommendations are also not considered (UC system uses PIQs instead). Essays are "Very Important."

---

#### 20. UC Berkeley
**CDS Year:** 2023-2024
**Source:** [Admit Report UC Berkeley CDS analysis](https://admitreport.com/blog/uc-berkeley-common-data-set)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Not Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | Considered |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Considered |
| Character/personal qualities | Important |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Not Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 21. University of Michigan (Ann Arbor)
**CDS Year:** 2024-2025
**Official URL:** https://obp.umich.edu/wp-content/uploads/pubdata/cds/CDS_2024-25_UMAA.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Important |
| Application Essay | Important |
| Recommendation(s) | Important |
| Interview | Not Considered |
| Extracurricular activities | Considered |
| Talent/ability | Considered |
| Character/personal qualities | Important |
| First generation | Important |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

#### 22. University of Virginia (UVA)
**CDS Year:** 2023-2024
**Official URL:** https://ira.virginia.edu/sites/g/files/jsddwu1106/files/2023-2024%20CDS_FINAL_508.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | Important |
| Recommendation(s) | Important |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | **Very Important** |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

**Notable:** UVA rates state residency as "Very Important" — reflecting Virginia's in-state/out-of-state distinction (typically ~73% in-state for the College of Arts & Sciences).

---

#### 23. Georgia Institute of Technology (Georgia Tech)
**CDS Year:** 2023-2024
**Official URL:** https://irp.gatech.edu/files/CDS/CDS_2023-2024_V3.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | Important |
| Recommendation(s) | Considered |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Considered |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Important |
| State residency | **Very Important** |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Not Considered |

---

#### 24. UNC Chapel Hill
**CDS Year:** 2024-2025
**Source:** [Cosmic College Consulting UNC analysis](https://www.cosmic.nyc/blog/unc-chapel-hill-admissions-2024-2025)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | Important |
| Standardized test scores | Considered |
| Application Essay | Important |
| Recommendation(s) | Important |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Important |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Important |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 25. New York University (NYU)
**CDS Year:** 2024-2025
**Source:** [The Koppelman Group NYU analysis](https://www.koppelmangroup.com/blog/2026/1/27/new-york-university-nyu-admissions-statistics-2025) | [Cosmic College Consulting NYU](https://www.cosmic.nyc/blog/nyu-admissions-2024-2025)

NYU's C7 is unusual: The Koppelman Group analysis shows virtually everything as "Very Important," while the Cosmic College Consulting analysis shows a more differentiated picture. The Koppelman Group data draws directly from the CDS.

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | **Very Important** |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | **Very Important** |
| Recommendation(s) | **Very Important** |
| Interview | — |
| Extracurricular activities | Considered |
| Talent/ability | Considered |
| Character/personal qualities | **Very Important** |
| First generation | Considered |
| Alumni/ae relation | **Very Important** |
| Geographical residence | **Very Important** |
| State residency | **Very Important** |
| Religious affiliation/commitment | **Very Important** |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | **Very Important** |

> **Data Note:** NYU's CDS C7 data shows almost all factors as "Very Important" — this appears to be NYU's actual CDS filing, not data interpretation error. It may reflect NYC's diverse applicant pool and NYU's desire to signal broad holistic review. This should be treated with some skepticism and verified against the primary CDS PDF directly from NYU's institutional research office.

---

#### 26. Boston University (BU)
**CDS Year:** 2024-2025
**Official URL:** https://www.bu.edu/asir/files/2025/03/cds-2025.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | **Very Important** |
| Recommendation(s) | Important |
| Interview | Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Considered |
| Alumni/ae relation | Considered |
| Geographical residence | Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

#### 27. University of Florida (UF)
**CDS Year:** 2024-2025
**Official URL:** https://data-apps.ir.aa.ufl.edu/public/cds/CDS_2024-2025_UFMAIN_Post_v1.pdf

*Note: The official PDF C7 section had ambiguous layout in extraction. The GradGPT 2025 data (from the same CDS) provides: rigor=VI, class rank=NC, GPA=VI, tests=I, essay=I, recs=NC, interview=NC, extracurriculars=VI, talent=VI, character=I, first gen=C, alumni=NC, geo=C, state=C, religion=NC, volunteer=I, work=I, interest=NC. This is cross-referenced with the UF Honors/admissions guidance site.*

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Not Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | Important |
| Application Essay | Important |
| Recommendation(s) | Not Considered |
| Interview | Not Considered |
| Extracurricular activities | **Very Important** |
| Talent/ability | **Very Important** |
| Character/personal qualities | Important |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 28. Florida State University (FSU)
**CDS Year:** 2024-2025
**Source:** [GradGPT FSU CDS](https://www.gradgpt.com/common-data-set/florida-state-university) | [Next Gen Admit FSU](https://nextgenadmit.com/florida-state-admission-statistics/)

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | Important |
| Standardized test scores | Important |
| Application Essay | Important |
| Recommendation(s) | Not Considered |
| Interview | Not Considered |
| Extracurricular activities | Important |
| Talent/ability | Important |
| Character/personal qualities | Important |
| First generation | Important |
| Alumni/ae relation | Not Considered |
| Geographical residence | Important |
| State residency | Important |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Important |
| Work experience | Important |
| Level of applicant's interest | Not Considered |

---

#### 29. University of South Florida (USF)
**CDS Year:** 2024-2025
**Source:** [GradGPT USF CDS](https://www.gradgpt.com/common-data-set/university-of-south-florida)

USF is one of the most academically focused (formula-driven) schools — essentially only rigor, GPA, and test scores matter.

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Considered |
| Academic GPA | **Very Important** |
| Standardized test scores | **Very Important** |
| Application Essay | Not Considered |
| Recommendation(s) | Not Considered |
| Interview | Not Considered |
| Extracurricular activities | Not Considered |
| Talent/ability | Not Considered |
| Character/personal qualities | Not Considered |
| First generation | Not Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Not Considered |
| State residency | Not Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Not Considered |
| Work experience | Not Considered |
| Level of applicant's interest | Not Considered |

---

#### 30. University of Central Florida (UCF)
**CDS Year:** 2024-2025
**Official URL:** https://analytics.ucf.edu/wp-content/uploads/2025/08/Common-Data-Set-2024-2025.pdf

| Factor | Rating |
|--------|--------|
| Rigor of secondary school record | **Very Important** |
| Class rank | Important |
| Academic GPA | **Very Important** |
| Standardized test scores | Considered |
| Application Essay | Considered |
| Recommendation(s) | Not Considered |
| Interview | Not Considered |
| Extracurricular activities | Considered |
| Talent/ability | Considered |
| Character/personal qualities | Considered |
| First generation | Considered |
| Alumni/ae relation | Not Considered |
| Geographical residence | Not Considered |
| State residency | Considered |
| Religious affiliation/commitment | Not Considered |
| Volunteer work | Considered |
| Work experience | Considered |
| Level of applicant's interest | Considered |

---

### PART 4: School Classification

#### Classification Framework

**Test-driven:** Schools rating standardized test scores as "Very Important"
**Holistic:** Schools rating essay, recommendations, extracurriculars, and character as "Very Important" alongside strong academics
**Academic-formula:** Schools using primarily academic metrics (rigor, GPA) with limited holistic factors

> Note: Many classifications are nuanced — a school can be partially test-driven and holistic. These are primary characterizations.

---

#### Category 1: TEST-DRIVEN
*Schools rating standardized test scores as "Very Important"*

| School | Test Scores Rating | Notes |
|--------|-------------------|-------|
| **Princeton** | Very Important | Tests re-required; most comprehensive holistic with tests |
| **Dartmouth** | Very Important | Tests required; full holistic |
| **Brown** | Very Important | Unusual for Ivy with test-optional policy |
| **Rice** | Very Important | Tests rated VI; other academics also VI |
| **Georgetown** | Very Important | Tests required (not optional); also holistic |
| **NYU** | Very Important | Rates nearly everything VI; test-optional but tests still VI in CDS |
| **USF** | Very Important | Formula-driven; only rigor+GPA+tests matter |

---

#### Category 2: HOLISTIC
*Schools rating essay, recommendations, extracurriculars, and character as "Very Important" alongside academics — tests are NOT "Very Important"*

| School | Test Scores | Essay | Recs | Extracurriculars | Character | Classification Notes |
|--------|-------------|-------|------|-----------------|-----------|---------------------|
| **Stanford** | Considered | VI | VI | VI | VI | Quintessential holistic |
| **Yale** | Considered | VI | VI | VI | VI | Full holistic; tests considered only |
| **Columbia** | Considered | VI | VI | VI | VI | Holistic; essay+character+academics VI |
| **Northwestern** | Considered | VI | VI | VI | VI | Holistic across all categories |
| **Cornell** | Considered | VI | VI | VI | VI | Strong holistic; GPA only Important |
| **Notre Dame** | Important | VI | VI | VI | VI | Holistic + religious mission; volunteer=VI |
| **Vanderbilt** | Important | VI | I | VI | VI | Holistic; tests downgraded to Important |
| **Boston University** | Considered | VI | I | I | I | Moderate holistic |
| **UVA** | Considered | I | I | I | VI | Holistic with strong state residency emphasis |

---

#### Category 3: EXTRACURRICULAR-DRIVEN
*Schools where extracurriculars and talent are "Very Important" but test scores are only Considered/Important*

| School | Test Scores | Extracurriculars | Talent/Ability | Notes |
|--------|-------------|-----------------|----------------|-------|
| **University of Florida** | Important | **Very Important** | **Very Important** | Unusual public school profile |
| **Duke** | Considered | **Very Important** | **Very Important** | EC+talent=VI; tests only Considered |

---

#### Category 4: ACADEMICALLY SELECTIVE (Tests Important but Not VI)
*Strong academic focus; tests matter but not at VI level; extracurriculars and character Important-range*

| School | Test Scores | Academic Focus | Character |
|--------|-------------|---------------|-----------|
| **MIT** | Important | Everything Important | **Very Important** |
| **Caltech** | Important | Rigor+Essay+Recs=VI | **Very Important** |
| **Johns Hopkins** | Considered | Rigor+GPA+Essay+Recs=VI | Important |
| **UPenn** | Considered | Rigor+GPA+Essay+Recs=VI | **Very Important** |

---

#### Category 5: PUBLIC FORMULA-DRIVEN
*Primarily academic metrics; limited holistic factors*

| School | Primary Factors | Tests | Holistic Elements |
|--------|----------------|-------|------------------|
| **UCLA** | Rigor+GPA+Essay=VI | Not Considered | Extracurriculars=I |
| **UC Berkeley** | Rigor+GPA+Essay=VI | Not Considered | EC+Character+Volunteer=I |
| **University of Michigan** | Rigor+GPA=VI | Important | Limited holistic |
| **Georgia Tech** | Rigor+GPA+Character=VI | Considered | State residency=VI |
| **UNC Chapel Hill** | Rigor=VI; most =I | Considered | Many factors Important |
| **Florida State** | Rigor=VI only | Important | Wide "Important" net |
| **UCF** | Rigor+GPA=VI | Considered | Mostly Considered |
| **USF** | Rigor+GPA+Tests=VI | **Very Important** | Nothing else considered |

---

#### Category 6: UNIQUE/SPECIAL CASE

| School | Classification | Reason |
|--------|---------------|--------|
| **Harvard** | Unique holistic | Everything "Considered" — deliberate signal that nothing is dispositive |
| **Georgetown** | Test-driven + Holistic | Tests=VI AND essay+recs+talent+character=VI; most comprehensive |
| **Notre Dame** | Holistic + Mission-driven | Religious affiliation=Important; volunteer=VI; unique among this set |
| **Rice** | Test-driven + Broadly Important | Academics=VI; nearly everything else=Important |

---

### SUMMARY COMPARISON TABLE

| School | Rigor | GPA | Tests | Essay | Recs | Extracurriculars | Character | Classification |
|--------|-------|-----|-------|-------|------|-----------------|-----------|----------------|
| Harvard | C | C | C | C | C | C | C | Unique holistic |
| MIT | I | I | I | I | I | I | **VI** | Academic selective |
| Stanford | **VI** | **VI** | C | **VI** | **VI** | **VI** | **VI** | Holistic |
| Yale | **VI** | **VI** | C | **VI** | **VI** | **VI** | **VI** | Holistic |
| Princeton | **VI** | **VI** | **VI** | **VI** | **VI** | **VI** | **VI** | Test-driven + Holistic |
| Columbia | **VI** | **VI** | C | **VI** | **VI** | **VI** | **VI** | Holistic |
| UPenn | **VI** | **VI** | C | **VI** | **VI** | I | **VI** | Academic selective |
| Duke | **VI** | **VI** | C | C | **VI** | **VI** | **VI** | Holistic-leaning |
| Caltech | **VI** | I | I | **VI** | **VI** | I | **VI** | Academic selective |
| Northwestern | **VI** | **VI** | C | **VI** | **VI** | **VI** | **VI** | Holistic |
| Johns Hopkins | **VI** | **VI** | C | **VI** | **VI** | I | I | Academic selective |
| Brown | **VI** | **VI** | **VI** | **VI** | **VI** | I | **VI** | Test-driven |
| Dartmouth | **VI** | **VI** | **VI** | **VI** | **VI** | **VI** | **VI** | Test-driven + Holistic |
| Cornell | **VI** | I | C | **VI** | **VI** | **VI** | **VI** | Holistic |
| Rice | **VI** | **VI** | **VI** | **VI** | **VI** | I | I | Test-driven |
| Vanderbilt | **VI** | **VI** | I | **VI** | I | **VI** | **VI** | Holistic |
| Notre Dame | **VI** | **VI** | I | **VI** | **VI** | **VI** | **VI** | Holistic + Mission |
| Georgetown | **VI** | **VI** | **VI** | **VI** | **VI** | I | **VI** | Test-driven + Holistic |
| UCLA | **VI** | **VI** | NC | **VI** | NC | I | I | Public formula |
| UC Berkeley | **VI** | **VI** | NC | **VI** | C | I | I | Public formula |
| UMich | **VI** | **VI** | I | I | I | C | I | Academic selective |
| UVA | **VI** | **VI** | C | I | I | I | **VI** | Public holistic |
| Georgia Tech | **VI** | **VI** | C | I | C | I | **VI** | Public formula |
| UNC Chapel Hill | **VI** | I | C | I | I | I | I | Public holistic |
| NYU | **VI** | **VI** | **VI** | **VI** | **VI** | C | **VI** | Test-driven (broad) |
| Boston Univ. | **VI** | **VI** | C | **VI** | I | I | I | Holistic-leaning |
| Univ. Florida | **VI** | **VI** | I | I | NC | **VI** | I | Extracurricular-driven |
| Florida State | **VI** | I | I | I | NC | I | I | Public formula |
| USF | **VI** | **VI** | **VI** | NC | NC | NC | NC | Formula/test-driven |
| UCF | **VI** | **VI** | C | C | NC | C | C | Public formula |

---

### KEY INSIGHTS FOR COLLEGE GUIDANCE APP

#### 1. Test Policy vs. Test Rating — These Are Different Things
Many test-optional schools still rate tests as "Important" or "Considered" in C7 — meaning strong scores still help even if not required. Only UCLA and UC Berkeley list tests as "Not Considered" (test-free, not just test-optional). Dartmouth, Princeton, Brown, Georgetown, and Rice rate tests as "Very Important" and require them.

#### 2. The Harvard Anomaly
Harvard's flat "Considered" across the board is intentional — it signals that admissions is contextual and no single factor is definitively decisive. This should be explained to students rather than implying Harvard doesn't care about grades.

#### 3. Public University Divergence
Public universities show a clear split:
- **UC System (UCLA, Berkeley):** Test-free, essay-heavy, no recommendations
- **Southern state schools (USF):** Formula-driven with test-score emphasis
- **Virginia/UNC/Michigan:** Balanced public holistic with state residency considerations

#### 4. The Religious Mission Factor
Only Notre Dame rates religious affiliation/commitment as "Important." All other schools rate it "Not Considered" (or don't include it). Georgetown rates it as "Not Considered" despite being Jesuit.

#### 5. Demonstrated Interest
Level of applicant's interest (demonstrated interest/campus visits) is rated "Not Considered" by most elite schools. Rice is the notable exception among the elite tier (rates it "Important"). UCF and some others do consider it.

---

### DATA SOURCES AND RELIABILITY

| Source | Type | Reliability | Notes |
|--------|------|-------------|-------|
| Official institutional PDFs | Primary | Highest | Best source; self-reported by school |
| commondatasets.fyi | Aggregator | High | Structured extraction from PDFs; updated annually |
| GradGPT | Aggregator | High | JSON parsing of CDS data; cites sources |
| Next Gen Admit | Aggregator | High | Cites specific CDS year |
| Cosmic College Consulting | Blog analysis | Medium-High | Analyzes official CDS; human-verified |
| The Koppelman Group | Blog analysis | Medium-High | Draws directly from CDS |
| College Transitions Repository | Link aggregator | Medium | Links to PDFs but no data extraction |
| commondataset.org | Official initiative | Authoritative | Template only; no compiled data |

---

*Research compiled from official CDS PDFs and verified aggregators. CDS data is self-reported by institutions; the most recent available year was used for each school (2024-2025 where published, otherwise 2023-2024). For app development, recommend building a pipeline to fetch and parse official institutional PDFs annually.*

---

## Area 5: SAT/ACT Testing Strategy

**Research compiled for college guidance app | April 2026**

---

### 1. SAT Testing Statistics

#### Total Test Takers
- **Class of 2025**: More than **2 million students** took the SAT at least once — the first cohort to surpass 2 million since before COVID-19, and the fourth-largest SAT cohort in the test's 100-year history. Source: [College Board Newsroom, September 2025](https://newsroom.collegeboard.org/sat-participation-class-2025-surpasses-2-million-test-takers-first-time-2020)
- **Class of 2024**: **1,973,891** students. Source: [2024 Total Group SAT Suite Annual Report — College Board](https://reports.collegeboard.org/media/pdf/2024-total-group-sat-suite-of-assessments-annual-report-ADA.pdf)
- **68%** of 2025 SAT takers took the test during school day (not a weekend administration).
- **97%** of the class of 2025 took the digital SAT.

#### Average Score (Most Recent Data)
| Class | ERW | Math | Total |
|-------|-----|------|-------|
| 2019 (pre-COVID baseline) | 531 | 528 | 1059 |
| 2022 | 529 | 521 | 1050 |
| 2023 | 520 | 508 | 1028 |
| **2024** | **519** | **505** | **1024** |
| **2025** | **521** | **508** | **~1029** |

Source: [BestColleges SAT Statistics](https://www.bestcolleges.com/research/average-sat-score-full-statistics/); [College Board Newsroom 2025](https://newsroom.collegeboard.org/sat-participation-class-2025-surpasses-2-million-test-takers-first-time-2020)

> **Note**: The 2024 average of 1024 was the lowest since the test changed format in 2016. Scores ticked upward in 2025.

#### Score Distribution — Class of 2024
| Score Range | Number of Students | % of Test Takers |
|-------------|-------------------|-----------------| 
| 1400–1600 | 142,239 | 7% |
| 1200–1390 | 329,072 | 17% |
| 1000–1190 | 547,126 | 28% |
| 800–990 | 601,348 | 30% |
| 600–790 | 338,320 | 17% |
| 400–590 | 15,786 | 1% |

Source: [2024 Total Group SAT Suite Annual Report — College Board](https://reports.collegeboard.org/media/pdf/2024-total-group-sat-suite-of-assessments-annual-report-ADA.pdf)

#### Score Percentiles — Class of 2024
| Percentile | Total Score | ERW | Math |
|------------|-------------|-----|------|
| **75th** | **1190** | **600** | **590** |
| **50th (Median)** | **1010** | **510** | **500** |
| **25th** | **840** | **430** | **400** |

Source: [2024 Total Group SAT Suite Annual Report — College Board](https://reports.collegeboard.org/media/pdf/2024-total-group-sat-suite-of-assessments-annual-report-ADA.pdf)

#### Detailed Percentile Ranking Table (User Group — SAT Test Takers)
| SAT Total Score | Approximate Percentile |
|----------------|----------------------|
| 1600 | 99th+ |
| 1500 | 98th |
| 1400 | 93rd |
| 1300 | 86th |
| 1200 | 74th–76th |
| 1100 | 58th–63rd |
| 1024 (avg) | ~51st |
| 1000 | 47th |
| 900 | 29th–32nd |
| 800 | 14th–16th |

Source: [PrepScholar SAT Percentiles (updated 2025)](https://blog.prepscholar.com/sat-percentiles-and-score-rankings)

#### How Many Times Students Take the SAT
- The **average student takes the SAT 2–3 times**. There is no official cap; the College Board allows unlimited retakes. Source: [University of the Potomac](https://potomac.edu/how-many-times-can-you-take-the-sat/)
- Historical data (ETS/ERIC research, representative of patterns):
  - **~51%** of students take the SAT only once
  - **~38%** take it two or three times (the majority of this group takes it once in junior year, once in senior year)
  - Only **~10%** take it three times
  - Less than **2%** take it four or more times
  Source: [ERIC/ETS Study — "Score Change When Retaking the SAT"](https://files.eric.ed.gov/fulltext/ED562856.pdf)

#### Score Improvement on Retake
- **Average improvement from 1st to 2nd attempt**: approximately **40 points** on the total score. Source: [University of the Potomac](https://potomac.edu/how-many-times-can-you-take-the-sat/)
- For students scoring in the **lower half of the distribution**: second attempt total score is ~91 points higher than first attempt; superscore increases by ~136 points on average.
- For **higher-scoring students**: second attempt improvement averages ~22 points (ceiling effects); superscore improvement averages ~84 points.
- Retaking once improves admissions-relevant superscores by nearly **0.3 standard deviations (~90 points)** overall.
- Students in the bottom half of the distribution who retake once boost superscores by ~0.4 standard deviations (~120 points).
Source: [NBER Working Paper #24945 — "Take Two! SAT Retaking and College Enrollment"](https://www.nber.org/system/files/working_papers/w24945/w24945.pdf)

---

### 2. ACT Testing Statistics

#### Total Test Takers
- **Class of 2024**: Roughly **1.4 million high school seniors** took the ACT — approximately **36% of the U.S. high school graduating class**.
- A record-high **78%** of ACT exam takers tested through State and District programs (school-day, no cost to students).
Source: [ACT 2024 National Graduating Class Executive Summary](https://www.act.org/content/dam/act/unsecured/documents/2024-act-national-grad-class-executive-summary.pdf); [ACT Industry Insights](https://industryinsights.act.org/2024/10/graduating-class-data)

#### Average Score
| Year | Average Composite |
|------|------------------|
| 2019–20 | 20.6 |
| 2020–21 | 20.3 |
| 2021–22 | 19.8 |
| 2022–23 | 19.5 |
| **2023–24** | **19.4** |

The 2024 average of **19.4** is the lowest in at least three decades. Source: [BestColleges — Average ACT Score](https://www.bestcolleges.com/research/average-act-score/); [District Administration](https://districtadministration.com/briefing/act-scores-are-still-declining-new-data-shows/)

#### Score Distribution & Percentiles — 2024
| ACT Composite Score | Approximate Percentile |
|--------------------|-----------------------|
| 36 | 100th (99th+) |
| 34–35 | 99th |
| 30 | ~95th |
| 25 | ~83rd |
| **19.4 (avg)** | **~52nd** |
| 20 | ~63rd |
| 16 | ~40th |
| 13 | ~20th |

**Key percentile anchors:**
- **75th percentile**: ~25
- **50th percentile (median)**: ~20–21
- **25th percentile**: ~16

Source: [Magoosh ACT Percentiles](https://magoosh.com/act/act-percentiles/)

#### How Many Times Students Take the ACT
- Students can retake the ACT up to **12 times**.
- **35%** of the 2024 graduating class took the ACT more than once (source: ACT Executive Summary).
- Earlier data (2019) showed 45% of students take it more than once; the rate among voluntary test-takers (not school-day mandated) is higher.
- Among retakers: **57% improve** their score, **21% score the same**, and **22% score lower**. Source: [Manhattan Review](https://www.manhattanreview.com/act-retaking/)

#### Score Improvement on Retake (ACT)
- **Average composite score improvement (1st to most recent attempt)**: **1.14 composite points** on average (range: 8.3 months between first and last test). Source: [Chariot Learning — Seven Points About ACT Retakes](https://www.chariotlearning.com/seven-points-about-act-retakes/)
- **Average ACT Superscore improvement** (among the 35% who tested multiple times): **2.4 composite points** above their first test. Source: [ACT 2024 National Graduating Class Executive Summary](https://www.act.org/content/dam/act/unsecured/documents/2024-act-national-grad-class-executive-summary.pdf)
- Average ACT Superscore for the class of 2024: **19.9** (vs. 19.4 composite average). Source: [ACT Industry Insights](https://industryinsights.act.org/2024/10/graduating-class-data)
- Students who take the ACT more than once see average composite scores nearly **3 points higher** than students who only test once (per ACT Policy Briefing). Source: [ScoreSmart](https://score-smart.com/does-retaking-the-act-improve-your-score/)
- Students scoring **13–29** on first attempt improve composite by ~1 point on retest.
- Score gains increase with more time between tests; additional retakes yield diminishing returns.

---

### 3. SAT Prep Resources — Ranked by Effectiveness

#### Effectiveness Summary (Research-Based Ranking)

| Rank | Resource | Cost | Score Improvement Claimed/Studied | Type |
|------|----------|------|----------------------------------|------|
| 1 | **Khan Academy Official SAT Practice** | Free | +90 pts (6–8 hrs); +115 pts (20 hrs); 200+ pts possible | Self-paced, official |
| 2 | **Private Tutoring (elite)** | $150–$500+/hr | 200–330 pts over 150+ hrs of prep | 1-on-1 |
| 3 | **Princeton Review (live/tutoring)** | $499–$5,000+ | Score guarantees of 1400 or 1500; 180-pt guarantee on premium | Live/tutoring |
| 4 | **PrepScholar** | $397–$4,795 | 160-pt guarantee | Adaptive online |
| 5 | **Kaplan** | $199–$1,999 | Higher score guarantee (no specific point amount) | Live/self-paced |
| 6 | **Magoosh** | $129–$399 | 100-pt guarantee | Self-paced, mobile |
| 7 | **1600.io** | $19.99/mo | Not claimed; deep video explanations of real SATs | Video/book |
| 8 | **Erica Meltzer (Critical Reader)** | ~$33.50/book | Not claimed; highly rated for R&W | Books |
| 9 | **College Panda (SAT Math)** | ~$31.34/book | Not claimed; best-in-class for math | Books |
| 10 | **Private tutoring (entry-level)** | $45–$75/hr | Variable | 1-on-1 |

---

#### Detailed Profiles

##### Khan Academy — Free (Official College Board Partner)
- **Cost**: Free
- **What research shows**:
  - **6–8 hours** of study → average **+90 points**
  - **20 hours** of study → average **+115 points** (nearly double gains vs. non-users)
  - Over 16,000 students out of ~250,000 studied gained **200+ points**
  - Gains were consistent across gender, race, income, GPA, and parental education level
  - Score improvements correlated strongly with time invested (approximately linear relationship)
  - The platform offers 10,000+ practice questions and 8 full-length official practice tests
  Source: [College Board Newsroom, May 2017](https://newsroom.collegeboard.org/new-data-links-20-hours-personalized-official-sat-practice-khan-academy-115-point-average-score); [Khan Academy Blog](https://blog.khanacademy.org/studying-for-the-sat-for-20-hours-on-khan-academy/); [Forbes, November 2024](https://www.forbes.com/sites/rayravaglia/2024/11/26/khan-academy-sat-preparation-success-points-to-post-sat-future/)
- **Verdict**: Best free resource. Official partnership with College Board. Limitations: emphasizes content over strategy; top-score students may need supplemental material.

##### Princeton Review
- **Cost**:
  - On-Demand (self-paced): **$499** (SAT + ACT combined)
  - SAT Essentials (live group, 18 hrs): **$949**
  - SAT 1400+ (live, 36 hrs): **$2,199**
  - SAT 1500+ Tutoring (18 hrs): **~$5,000+** (includes 98th-percentile money-back guarantee)
  - Tutoring add-on: **$175–$278/hr**
- **Score guarantees**: 180-point improvement guarantee on premium digital SAT 1500+ course; 1400 score guarantee for qualifying students (must start at 1250+)
- **Strengths**: More practice material than Kaplan (2,000+ questions vs. 1,000), smaller class sizes (capped at ~25), experienced instructors
- Source: [PrepMaven Comparison](https://prepmaven.com/blog/test-prep/princeton-review-vs-kaplan-sat-prep/); [Education Data Initiative](https://educationdata.org/best-sat-prep-courses)

##### Kaplan
- **Cost**:
  - On-Demand (self-paced): **$199** (6 months access)
  - Live Online SAT: **$799** (18 hrs live instruction, 4 practice tests)
  - Live Online Plus: **$1,099** (adds 3 hrs tutoring)
  - Unlimited Prep (SAT + ACT + select AP): **$1,999** (through senior December)
  - Standard SAT Tutoring: **$1,999+** (10–40 hr blocks)
- **Score guarantee**: Higher score guarantee on most courses (no specific point promise on standard courses)
- **Official ACT partner** for live online prep
- **Strengths**: Founded 1938 (original test prep company); best textbooks; video explanations; flexible class scheduling
- Source: [Education Data Initiative](https://educationdata.org/best-sat-prep-courses); [PrepMaven](https://prepmaven.com/blog/test-prep/princeton-review-vs-kaplan-sat-prep/)

##### PrepScholar
- **Cost**:
  - Complete Online SAT Prep: **$397/year** (160-pt score increase guarantee, 150 hrs content, 4,000 practice questions)
  - SAT + Admissions Bootcamp: **$595**
  - Unlimited Live Classes + SAT/ACT: **$1,695**
  - 1-on-1 Tutoring + Online Prep (4–36 hrs): **$995–$4,795**
- **Approach**: Adaptive diagnostic identifies weakest areas; personalized study plan; focuses on "weakness first" methodology
- **Guarantee**: 160-point score increase or money back
- Source: [History Cooperative — PrepScholar Review](https://historycooperative.org/prepscholar-sat-review/); [My Engineering Buddy](https://www.myengineeringbuddy.com/blog/prepscholar-sat-act-prep-reviews-pricing-and-insights/)

##### Magoosh SAT
- **Cost**:
  - Premium (self-paced): **$129** (12 months access)
  - Premium + On-Demand Classes: **$399**
  - Mobile app included with Premium
- **Approach**: Video lessons, adaptive practice questions, mobile-first design, email tutor support
- **Guarantee**: 100-point improvement guarantee
- **Best for**: Budget-conscious students; mobile learners; consistent daily practice habit builders
- Source: [Magoosh Plans Page](https://sat.magoosh.com/plans); [My Engineering Buddy Magoosh Review](https://www.myengineeringbuddy.com/blog/magoosh-reviews-alternatives-pricing-offerings-in-2025/)

##### 1600.io
- **Cost**: **$19.99/month** (Premium Membership, cancel anytime)
- **What's included**: 6,000+ video explanations for every question on 30+ released SATs (including digital), interactive SAT Math Orange Book (1,200+ digital SAT-style problems), live online classes, SAT strategy course
- **Important caveat**: Does NOT provide actual SAT questions (copyright); explains official tests question by question. Students must access test PDFs separately from College Board/Khan Academy.
- **Best for**: Students who want deep, question-by-question analysis of real SATs. Especially strong for math.
- Source: [1600.io Products Page](https://1600.io/p/products); [Strategic Test Prep Rankings 2026](https://www.strategictestprep.com/post/best-digital-sat-prep-resources)

##### Erica Meltzer — The Critical Reader
- **Cost**: ~**$33.50** per book (Critical Reader, 6th Edition, March 2025 — updated for Digital SAT)
- **Approach**: Deep structural analysis of SAT Reading & Writing question types; step-by-step explanations; strategy-focused, not just content review
- **Best for**: Students struggling with the Reading and Writing section; high-scorers seeking to master question-type patterns
- Source: [Barnes & Noble listing](https://www.barnesandnoble.com/w/the-critical-reader-sixth-edition-erica-meltzer/1147403278); [Nucleus Tutoring Review](https://www.nucleustutoring.com/post/best-sat-prep-books)

##### College Panda — SAT Math
- **Cost**: ~**$31.34** per book
- **Approach**: Focuses exclusively on SAT Math; covers every math topic tested; uses original practice questions with strategic tips; geared toward the student aiming for a perfect or near-perfect math score
- **Caveat**: Does not cover Reading & Writing; often paired with Erica Meltzer for a comprehensive book-only study plan
- Source: [Nucleus Tutoring](https://www.nucleustutoring.com/post/best-sat-prep-books); [Barnes & Noble listing](https://www.barnesandnoble.com/w/the-college-pandas-sat-math-nielson-phu/1136252765)

##### Private Tutoring
- **Cost (2026 rates)**:
  | Tutor Level | Hourly Rate |
  |-------------|------------|
  | Entry-level (college students, first-time tutors) | $45–$75/hr |
  | Professional tutors (teaching background, SAT experience) | $75–$125/hr |
  | Company-certified tutors (proven track record) | $125–$300+/hr |
  | Elite specialists (5–10+ years, published guides) | $200–$500+/hr |
  | Elite independent (referral-driven, 500+ students) | $300–$1,000+/hr |

- **Total investment**: Most families spend **$1,500–$6,000+** for comprehensive prep (20–30 hours). Budget options start ~$900 for 20 hours; premium elite tutors can exceed $12,000.
- **Best for**: Students with specific weaknesses, busy schedules, or targeting very high scores (1500+)
- Source: [Private Prep 2026 Pricing Guide](https://privateprep.com/how-much-does-sat-tutoring-cost/)

#### Research on What Produces the Best Gains
1. **Most research-validated free method**: Khan Academy (College Board-backed studies showing 90–115+ point gains)
2. **Best gain per dollar**: Khan Academy (free, ~115 pts for 20 hrs) and College Panda + Erica Meltzer combo (~$65 total in books)
3. **Highest absolute gains**: Private tutoring (150+ hrs can yield 200–330 pt improvement) but cost is prohibitive
4. **Hours of prep → score improvement** (general benchmarks):
   | Prep Hours | Expected Score Gain |
   |------------|---------------------|
   | 10 hrs | +0–30 points |
   | 20 hrs | +30–70 points (official average 115 pts on Khan Academy) |
   | 40 hrs | +70–130 points |
   | 80 hrs | +130–200 points |
   | 150+ hrs | +200–330 points |
   Source: [PrepScholar Blog — How Long to Study for SAT](https://blog.prepscholar.com/how-long-ahead-of-the-sat-you-should-begin-studying-and-prepping)
5. ~40 points improvement per 7 hours of quality study (per Piqosity research). Source: [Piqosity](https://www.piqosity.com/how-long-should-you-study-for-the-sat-test/)

---

### 4. Superscoring

#### What Is SAT Superscoring?
SAT superscoring allows colleges to take the **highest section score** from each individual test sitting across multiple SAT attempts and combine them into a single, highest-possible composite score. For example:

| Test Date | Reading & Writing | Math | Total |
|-----------|------------------|------|-------|
| March (Attempt 1) | 650 | 580 | 1230 |
| October (Attempt 2) | 610 | 640 | 1250 |
| **Superscore** | **650** | **640** | **1290** |

In this example, the student's superscore is **1290**, even though neither individual sitting reached that score. Colleges that superscore consider this 1290 as the student's official score. Students should submit scores from all test dates to schools that superscore.

Source: [Ascend Now SAT Super Scoring Guide](https://ascendnow.org/online-tutoring/sat-act/sat-super-scoring/)

#### Average Benefit of Superscoring
- Retaking once improves admissions-relevant SAT superscores by ~**0.3 standard deviations (~90 points)**
- For lower-scoring students (bottom half of distribution): superscore increases by ~**136 points** on average after one retake
- For higher-scoring students: superscore increases by ~**84 points** after one retake
Source: [NBER Working Paper #24945](https://www.nber.org/system/files/working_papers/w24945/w24945.pdf)

#### Colleges That Superscore the SAT (Major Schools)
Most selective universities superscore the SAT. Notable exceptions include Harvard, Princeton, Cornell, and the University of California system. Source: [Achievable — Which Colleges Superscore](https://achievable.me/exams/act/resources/which-colleges-superscore-sat-and-act/)

| School | Superscore SAT? | Superscore ACT? |
|--------|----------------|----------------|
| MIT | Yes | Yes |
| Stanford | Yes | Yes (full score reports also required) |
| Yale | Yes | Yes |
| Caltech | Yes | Yes |
| Duke | Yes | Yes |
| Johns Hopkins | Yes | Yes |
| Northwestern | Yes | No |
| University of Pennsylvania | Yes | Yes |
| University of Chicago | Yes | Yes |
| Brown | Yes | Yes |
| Columbia | Yes | Yes |
| Dartmouth | Yes | Yes |
| Rice | Yes | Yes |
| Notre Dame | Yes | Yes |
| Vanderbilt | Yes | Yes |
| **Harvard** | **No** | **No** |
| **Princeton** | **No** | **No** |
| **Cornell** | **No** | **No** |
| **UCLA** | **No** | **No** |
| **UC Berkeley** | **No** | **No** |

**Note**: Harvard, Princeton, and Cornell use the single-highest sitting. The University of California schools do NOT superscore.

For a comprehensive list of SAT superscoring schools, see: [PrepScholar — Which Colleges Superscore the SAT](https://blog.prepscholar.com/which-colleges-superscore-the-sat)

#### ACT Superscoring
Yes — the ACT has superscoring. The ACT superscore is calculated by taking the **highest sub-score from each section** (English, Math, Reading, Science) across all test sittings and averaging them into a new composite.

ACT also offers the official "ACT Superscore" on score reports for participating institutions.

Many selective colleges superscore the ACT. A large and growing list can be found at: [PrepScholar — Colleges That Superscore ACT](https://blog.prepscholar.com/colleges-that-superscore-act-complete-list)

Notable ACT-superscoring schools include: Amherst, MIT, Stanford, Yale, Duke, Johns Hopkins, UPenn, University of Chicago, Brown, Columbia, Dartmouth, Rice, Vanderbilt, Middlebury, Hamilton, Davidson, Indiana University Bloomington, Miami University, Florida State University, NC State, and many others.

**Princeton Review's full ACT superscore list**: [princetonreview.com/college-advice/colleges-superscore-act](https://www.princetonreview.com/college-advice/colleges-superscore-act)

---

### 5. SAT Fee Waivers

#### Who Qualifies for an SAT Fee Waiver?
SAT fee waivers are available to **11th- and 12th-grade students** in the U.S., U.S. territories, and U.S. citizens living abroad who are in financial need. Students qualify if **one or more** of the following applies:

1. Enrolled in or eligible for the **National School Lunch Program (NSLP)** — families earning ≤185% of the federal poverty level
2. Annual family income falls within **USDA Food and Nutrition Service Income Eligibility Guidelines**
3. Enrolled in a federal, state, or local program aiding low-income families (e.g., **TRIO / Upward Bound**)
4. Family **receives public assistance** (SNAP, TANF, etc.)
5. Homeless, in **federally subsidized housing**, or in a **foster home**
6. **Ward of the state or orphan**

Source: [College Board SAT Fee Waiver Eligibility](https://satsuite.collegeboard.org/sat/registration/fee-waivers/fee-waiver-eligibility)

> **Income threshold context**: USDA eligibility for free lunch (not reduced-price) is approximately $24,000 for a family of 2, scaling to $48,000 for a family of 5 (at 130% of the federal poverty level). The NSLP's 185% threshold is higher. Exact income tables are updated annually by the USDA. Source: [CollegeVine Fee Waiver Guide](https://blog.collegevine.com/the-complete-guide-to-fee-waivers-in-the-college-application-process)

#### How to Apply for an SAT Fee Waiver
1. **Talk to your school counselor** — they are the gatekeepers for fee waivers and will verify eligibility
2. **Counselor provides fee waiver** — typically a paper form with a serial/code number
3. **Enter the code during online SAT registration** to waive fees
4. The College Board also automatically identifies eligible students in state/district testing programs

#### How Many SAT Fee Waivers Can a Student Get?
- Up to **2 fee waivers for the SAT** (covers 2 test dates)
- Source: [HBCU Lifestyle — College Board Fee Waiver](https://hbculifestyle.com/college-board-fee-waiver/); [CollegeVine](https://blog.collegevine.com/the-complete-guide-to-fee-waivers-in-the-college-application-process)

#### What Does the SAT Fee Waiver Cover?
- **100% of SAT registration fee** (currently $60 per test)
- **No late registration fees** for waiver tests
- **No regional/international fees**
- **No cancellation fees** (unused waiver returned upon cancellation)
- **Unlimited score reports** to colleges and scholarship programs (normally $13 per report beyond 4 free)
- **Fee reductions on score verification reports**
- **Waived application fees** at 2,000+ participating colleges (for seniors who have taken the SAT with a fee waiver)
- **Free CSS Profile** for financial aid applications at participating institutions
Source: [College Board — Fee Waiver Benefits](https://satsuite.collegeboard.org/sat/registration/fee-waivers/fee-waiver-benefits); [BigFuture — College App Fee Waiver FAQ](https://bigfuture.collegeboard.org/plan-for-college/apply-to-college/college-application-fee-waiver-faq)

#### College Application Fee Waivers via SAT Waiver
- Every income-eligible student who takes the SAT with a fee waiver (or is identified as fee-waiver eligible through a district/state program) can apply to **2,000+ participating colleges for free**
- Waivers apply across Common App, Coalition App, and Universal College Application platforms
- Seniors receive their college application fee waivers when SAT scores arrive; juniors receive them in fall of senior year
- Eligibility check: answer questions during Common App/Coalition App signup, or ask counselor to verify

---

### 6. ACT Fee Waivers

#### Who Qualifies for an ACT Fee Waiver?
To qualify, a student must meet **all three** of the following:
1. **Grade**: Currently enrolled in **11th or 12th grade**
2. **Location**: Taking the test in the **U.S., U.S. territories, or Puerto Rico**
3. **Financial need**: At least one of the following:
   - Participate (or could participate) in the **National School Lunch Program**
   - Family income at or below **USDA Income Eligibility Guidelines**
   - Enrolled in another federal/state/local program for low-income families
   - Family receives public assistance
   - Lives in federally subsidized housing
   - Lives in a foster home, is homeless, is a ward of the state, or is an orphan

**Sample USDA income thresholds (approximate; updated annually):**
| Household Size | Annual Income (free lunch threshold ~130% FPL) |
|---------------|----------------------------------------------|
| 1 | $23,606 |
| 2 | $31,894 |
| 3 | $40,182 |
| 4 | $48,470 |
| 5 | $56,758 |
| 6 | $65,046 |
| 7 | $73,344 |
| 8 | $81,622 |

Source: [CollegeVine — How to Get an ACT Fee Waiver](https://blog.collegevine.com/how-to-get-an-act-fee-waiver)

#### How to Apply for an ACT Fee Waiver
- Students **cannot apply directly** — fee waivers are **requested by the high school**
- Students should meet with their **school counselor/advisor** to determine eligibility and have the counselor request the waiver
- A waiver code is then provided to the student to use during online registration
Source: [CollegeVine](https://blog.collegevine.com/how-to-get-an-act-fee-waiver); [Piqosity](https://www.piqosity.com/act-cost-sat-cost-fee-waivers/)

#### How Many ACT Fee Waivers Can a Student Get?
- Up to **2 ACT fee waivers** (some sources say 4; the standard confirmed limit is 2 per the PrepScholar guide, which notes waivers are valid through August 31 each year — students may receive 1 in junior year and 1 in senior year)
- Source: [PrepScholar — ACT Fee Waiver Guide](https://blog.prepscholar.com/act-fee-waiver-complete-guide)

#### What Does the ACT Fee Waiver Cover?
- **Full ACT registration fee** (with or without Writing and/or Science)
- **Does not cover**: Late registration fees, test-date change fees, or extra services
- **One score report to your high school** + up to **six score reports to colleges**
- Students with a fee waiver can also request a **Waiver or Deferral of College Admission Application Fee** to submit directly to colleges
Source: [PrepScholar — ACT Fee Waiver Guide](https://blog.prepscholar.com/act-fee-waiver-complete-guide); [Piqosity](https://www.piqosity.com/act-cost-sat-cost-fee-waivers/)

---

### 7. SAT/ACT Prep Timeline

#### By Grade Level — When to Start

| Grade | Recommended Activity |
|-------|---------------------|
| **9th grade** | Focus on academics (GPA). Awareness only — no formal SAT/ACT prep needed. Take PSAT 8/9 if offered (diagnostic only). |
| **10th grade** | Take PSAT 10 (spring). Identify math/reading weak areas. Optional: begin light, non-structured exposure to SAT question types. Good time for diagnostic test. |
| **11th grade (fall)** | Begin formal prep (October–November). Take 2–3 full-length practice tests. Register for October PSAT/NMSQT (required for National Merit). |
| **11th grade (spring)** | PRIMARY testing window. Target March, May, or June SAT. Take Feb/April ACT. Aim to hit target score here. |
| **Summer before 12th** | Targeted 6–8 week intensive if spring score missed target. Focus on specific weak sections. |
| **12th grade (fall)** | Retake window: August/September/October SAT; September/October/December ACT. Must complete by October/November for EA/ED deadlines. |
| **12th grade (spring)** | Generally too late for most applications (exception: rolling admissions). Avoid if possible. |

Source: [Groza Learning Center — When to Start SAT/ACT Prep](https://grozalearningcenter.com/when-to-start-sat-act-prep-guide/); [Compass Education Group Timeline](https://www.compassprep.com/build-your-optimal-sat-or-act-timeline/)

#### Traditional Timeline (Most Common Path)
- **SAT**: First attempt in March (junior year) → begin prep in October/November of 10th grade or start of 11th
- **ACT**: First attempt in February of junior year → begin prep in October of 10th grade

#### Recommended Hours of Prep
| Target Score Improvement | Hours Recommended |
|--------------------------|------------------|
| 0–30 points | 10 hours |
| 30–70 points | 20 hours |
| 70–130 points | 40 hours |
| 130–200 points | 80 hours |
| 200–330 points | 150+ hours |

- **Minimum effective prep**: 10 hours (below this, results are inconsistent)
- **Sweet spot**: 40 hours spread over 2–3 months
- **Full prep**: 80–100 hours for significant gains of 150–200 points
- **Rule of thumb**: ~40 points improvement per 7 hours of quality study (Piqosity)
- **Khan Academy research**: 20 hours → 115 pts (College Board–backed study)
- General prep timeline: **3–6 months** recommended for thorough prep
Source: [PrepScholar Blog](https://blog.prepscholar.com/how-long-ahead-of-the-sat-you-should-begin-studying-and-prepping); [Piqosity](https://www.piqosity.com/how-long-should-you-study-for-the-sat-test/)

#### SAT Test Dates 2025–2026 (Digital SAT)
| Test Date | Registration Deadline | Late Registration |
|-----------|----------------------|------------------|
| August 23, 2025 | August 8, 2025 | August 12, 2025 |
| September 13, 2025 | August 29, 2025 | September 2, 2025 |
| October 4, 2025 | September 19, 2025 | September 23, 2025 |
| November 8, 2025 | October 24, 2025 | October 28, 2025 |
| December 6, 2025 | November 21, 2025 | November 25, 2025 |
| **March 14, 2026** | February 27, 2026 | March 3, 2026 |
| **May 2, 2026** | April 17, 2026 | April 21, 2026 |
| **June 6, 2026** | May 22, 2026 | May 26, 2026 |

**SAT School Day Testing Windows:**
- Fall 2025: October 1–31, 2025
- Spring 2026: March 2–April 30, 2026

Source: [Test Innovators SAT Test Dates](https://testinnovators.com/blog/sat-test-dates/); [Compass Prep](https://www.compassprep.com/sat-and-act-test-dates-and-deadlines/)

#### ACT Test Dates 2025–2026
| Test Date | Registration Deadline | Late Registration |
|-----------|----------------------|------------------|
| September 6, 2025 | August 1, 2025 | August 19, 2025 |
| October 18, 2025 | September 12, 2025 | September 30, 2025 |
| December 13, 2025 | November 7, 2025 | November 24, 2025 |
| **February 14, 2026** | January 9, 2026 | January 23, 2026 |
| **April 11, 2026** | March 6, 2026 | March 24, 2026 |
| **June 13, 2026** | May 8, 2026 | May 29, 2026 |
| **July 11, 2026** | June 5, 2026 | June 24, 2026 |

**ACT School Day Testing (Paper):**
- Fall 2025: October 14 and October 28, 2025
- Spring 2026: March 10, March 24, April 7, April 21, 2026

Source: [Test Innovators ACT Test Dates](https://testinnovators.com/blog/act-test-dates/); [Compass Prep](https://www.compassprep.com/sat-and-act-test-dates-and-deadlines/)

---

#### What Is the PSAT?

The PSAT (Preliminary SAT) is a suite of tests administered by the College Board:

| Test | Who Takes It | Scoring Scale | Purpose |
|------|-------------|---------------|---------| 
| **PSAT 8/9** | 8th and 9th graders | 240–1440 | Early diagnostic |
| **PSAT 10** | 10th graders | 320–1520 | Benchmark progress |
| **PSAT/NMSQT** | 11th graders (primarily) | 320–1520 | **National Merit qualifier** |

- Students take the **PSAT/NMSQT in October of junior (11th grade) year** — this is the qualifying test for the National Merit Scholarship Program
- PSAT scores are **not sent to colleges** and are not part of admissions (optional to self-report)
- ~**3.4–3.65 million students** take a PSAT or PSAT/NMSQT annually

Source: [Kaplan — National Merit Semifinalist Guide](https://www.kaptest.com/study/psat/how-to-become-a-national-merit-scholarship-finalist/); [College Board Newsroom 2025](https://newsroom.collegeboard.org/sat-participation-class-2025-surpasses-2-million-test-takers-first-time-2020)

---

#### National Merit Scholarship — PSAT Qualifying Scores

**How it works:**
1. Students take the **PSAT/NMSQT in October of 11th grade**
2. Scores are converted to a **Selection Index (SI)**: formula is **(2 × RW score + Math score) ÷ 10** on a scale of 48–228
3. Top 50,000 scoring students are recognized; from these:
   - **34,000** receive **Letters of Commendation**
   - **16,000** advance as **Semifinalists** (top ~1% per state)
4. Semifinalists complete a scholarship application (essay, academic record, SAT/ACT score confirmation) to become **Finalists**

**Class of 2026 Semifinalist Selection Index Cutoffs by State (PSAT/NMSQT)**
- Range: **210** (New Mexico, North Dakota, West Virginia, Wyoming) to **225** (Massachusetts, New Jersey, Washington D.C.)
- Average across all states: approximately **218–220**
- Cutoffs rose an average of **1.8 points** from class of 2025, with nearly all states seeing increases
- These represent all-time highs for most states

**Sample state cutoffs (Class of 2026):**
| State | SI Cutoff |
|-------|-----------| 
| Massachusetts | 225 |
| New Jersey | 225 |
| Washington D.C. | 225 |
| California | 224 |
| Maryland | 224 |
| Virginia | 224 |
| Washington (state) | 224 |
| Connecticut | 223 |
| New York | 223 |
| Texas | 222 |
| Colorado | 219 |
| Tennessee | 219 |
| North Carolina | 220 |
| Florida | ~220 |
| Alabama | 214 |
| Montana | 213 |
| New Mexico | 210 |
| North Dakota | 210 |
| Wyoming | 210 |

Source: [McElroy Tutoring — Class of 2026 NMSC Cutoffs](https://mcelroytutoring.com/blog-post.php?id=5332); [Kaplan — National Merit Guide](https://www.kaptest.com/study/psat/how-to-become-a-national-merit-scholarship-finalist/)

**PSAT/SAT score conversion for National Merit context:**
- A **Selection Index of 225** corresponds approximately to a PSAT score of ~1500–1520 (out of 1520)
- A **Selection Index of 210** corresponds approximately to a PSAT score of ~1390–1410

---

### 8. Digital SAT Changes

#### Overview of the Transition
- **International students**: Digital SAT launched in **March 2023**
- **U.S. students (high school)**: Mandatory digital SAT beginning **March 2024**
- **Class of 2025**: First graduating class where **97% took the digital SAT**
- The paper SAT has been fully discontinued for U.S. high school students

#### What Changed: Paper SAT → Digital SAT

| Feature | Old (Paper) SAT | New (Digital) SAT |
|---------|----------------|------------------|
| **Format** | Paper and pencil | Computer (Bluebook™ app on laptop/tablet) |
| **Total time** | ~3 hours | **2 hours 14 minutes** |
| **Total questions** | 154 | **98** |
| **Sections** | 4 sections (Reading, Writing & Language, No-calc Math, Calculator Math) | **2 sections** (Reading & Writing; Math), each split into 2 modules |
| **Reading passages** | Long multi-paragraph passages | **Short passages** (1–2 paragraphs per question in R&W) |
| **Adaptive** | No | **Yes** (multistage adaptive) |
| **Calculator** | No calculator in one Math section | **Built-in Desmos calculator** available for all math questions |
| **Score range** | 400–1600 | **400–1600** (unchanged) |
| **Essay** | Optional (discontinued 2021) | Not offered |
| **Scores returned** | Weeks later | **Days later** |
| **Personal device** | No | Students can use their **own laptop or school-issued device** |
| **Question navigation** | Within section | Within module only (cannot return to previous module) |

#### Digital SAT Structure (Detailed)
| Section | Module | Time | Questions | Scored |
|---------|--------|------|-----------|--------|
| Reading & Writing | Module 1 | 32 min | 27 | 25 |
| Reading & Writing | Module 2 | 32 min | 27 | 25 |
| — Break — | — | 10 min | — | — |
| Math | Module 1 | 35 min | 22 | 20 |
| Math | Module 2 | 35 min | 22 | 20 |
| **Total** | | **2h 14min** | **98** | **90** |

Each module contains 2 unscored (experimental/"pretest") questions that cannot be identified.

Source: [Test Innovators Digital SAT Guide](https://testinnovators.com/blog/digital-sat-guide/)

#### How Adaptive Testing Works
The digital SAT uses **multistage adaptive testing (MST)**:

1. **Module 1** (same for all students): Contains a mix of easy, medium, and hard questions at medium average difficulty. All students take identical Module 1.

2. **Performance in Module 1 determines Module 2**:
   - **High performance in Module 1 → Hard Module 2**: Fewer easy questions, higher overall difficulty ceiling
   - **Lower performance in Module 1 → Easier Module 2**: Fewer hard questions, lower difficulty floor

3. **Scoring impact**: Difficulty of questions answered correctly affects final scaled score. A student who earns the Hard Module 2 and scores well on it can reach higher scaled scores than a student on the Easy Module 2. The adaptive system means that **correct answers on harder questions carry more weight** in the final scaled score.

4. **Key implication for strategy**: It is critical to perform well in Module 1 to unlock the Hard Module 2 — this is the pathway to scores above approximately 1400. Students who stumble in Module 1 are capped at a lower potential maximum score in Module 2.

Source: [Test Innovators Digital SAT Guide](https://testinnovators.com/blog/digital-sat-guide/); [Gateway Abroad Educations](https://www.gatewayabroadeducations.com/article/digital-sat-format-adaptive-testing)

#### Built-In Digital Tools
- Embedded **Desmos graphing calculator** (for all math questions, including Module 1)
- **Highlighting tool** (for Reading & Writing passages)
- **Annotation/flag tool** (mark questions to review within module)
- **Digital scratch pad/whiteboard**

#### Impact on Prep Strategies

**What changed for students:**
1. **Shorter test** → Less endurance required; stamina less of a factor. Students can peak earlier in prep and maintain it.
2. **No more long reading passages** → Reading & Writing now tests comprehension on short paragraphs; vocabulary-in-context has returned to prominence
3. **Desmos calculator available for all math** → Students should learn Desmos; some algebraic problems are now faster to graph than to solve algebraically
4. **Adaptive modules** → Understanding module routing strategy matters. Going into Module 1 without a strategy to prioritize accuracy is more costly than before.
5. **Official practice available via Bluebook app** → Students must practice on the official Bluebook platform to simulate real test conditions (not just paper PDFs)
6. **Faster score return** → Students can take the test later in the season and still receive scores in time for application deadlines (scores returned in days, not weeks)

**Resources that matter now:**
- **Bluebook App** (free, official): Only place to practice the real adaptive digital format
- **Khan Academy**: Updated for digital SAT with official digital practice questions
- **College Board Question Bank** (free): Targeted practice by question type/difficulty
- Any book-based resource should be from **2023 or later** (pre-2023 materials are based on the old paper format)

---

### Area 5 Sources Summary

| Topic | Primary Source | URL |
|-------|---------------|-----|
| SAT 2024 statistics | College Board 2024 Total Group Annual Report | https://reports.collegeboard.org/media/pdf/2024-total-group-sat-suite-of-assessments-annual-report-ADA.pdf |
| SAT 2025 participation | College Board Newsroom | https://newsroom.collegeboard.org/sat-participation-class-2025-surpasses-2-million-test-takers-first-time-2020 |
| SAT retake statistics | NBER Working Paper #24945 | https://www.nber.org/system/files/working_papers/w24945/w24945.pdf |
| SAT percentiles | PrepScholar | https://blog.prepscholar.com/sat-percentiles-and-score-rankings |
| ACT 2024 statistics | ACT Executive Summary | https://www.act.org/content/dam/act/unsecured/documents/2024-act-national-grad-class-executive-summary.pdf |
| ACT percentiles | Magoosh ACT Blog | https://magoosh.com/act/act-percentiles/ |
| Khan Academy effectiveness | College Board Newsroom | https://newsroom.collegeboard.org/new-data-links-20-hours-personalized-official-sat-practice-khan-academy-115-point-average-score |
| Superscoring SAT list | PrepScholar | https://blog.prepscholar.com/which-colleges-superscore-the-sat |
| Superscoring ACT list | PrepScholar | https://blog.prepscholar.com/colleges-that-superscore-act-complete-list |
| Top schools superscore table | Achievable | https://achievable.me/exams/act/resources/which-colleges-superscore-sat-and-act/ |
| SAT fee waiver eligibility | College Board | https://satsuite.collegeboard.org/sat/registration/fee-waivers/fee-waiver-eligibility |
| SAT fee waiver benefits | College Board | https://satsuite.collegeboard.org/sat/registration/fee-waivers/fee-waiver-benefits |
| College app fee waivers | BigFuture | https://bigfuture.collegeboard.org/plan-for-college/apply-to-college/college-application-fee-waiver-faq |
| ACT fee waiver | PrepScholar | https://blog.prepscholar.com/act-fee-waiver-complete-guide |
| SAT/ACT test dates | Compass Prep | https://www.compassprep.com/sat-and-act-test-dates-and-deadlines/ |
| Prep hours research | PrepScholar | https://blog.prepscholar.com/how-long-ahead-of-the-sat-you-should-begin-studying-and-prepping |
| National Merit cutoffs | McElroy Tutoring | https://mcelroytutoring.com/blog-post.php?id=5332 |
| Digital SAT format | Test Innovators | https://testinnovators.com/blog/digital-sat-guide/ |
| Private tutoring costs | Private Prep | https://privateprep.com/how-much-does-sat-tutoring-cost/ |
| Princeton Review pricing | PrepMaven | https://prepmaven.com/blog/test-prep/princeton-review-vs-kaplan-sat-prep/ |
| PrepScholar pricing | History Cooperative | https://historycooperative.org/prepscholar-sat-review/ |
| Magoosh pricing | Magoosh Plans | https://sat.magoosh.com/plans |
| 1600.io pricing | 1600.io | https://1600.io/p/premium-sat-resources-bundle |

*Research compiled April 2026. Test dates, pricing, and policies subject to change. Always verify current information on official College Board (collegeboard.org) and ACT (act.org) websites.*


---

## Area 6: Financial Aid & Scholarships
*Research compiled for College Guidance App — US High School Students*
*Data current as of April 2026*

---

### 1. FAFSA (Free Application for Federal Student Aid)

**Official URL:** https://studentaid.gov/h/apply-for-aid/fafsa

### 2026-2027 FAFSA Opening Date
The 2026-2027 FAFSA became available on **September 24, 2025** — slightly ahead of the planned October 1, 2025 release date. This is the FAFSA high school seniors completing the 2026-2027 academic year (entering college fall 2026) should file.

### Federal FAFSA Deadline
- **2026-2027 Federal Deadline:** June 30, 2027 (11:59 PM Central Time)
- **Corrections/updates deadline:** September 12, 2027 (11:59 PM CT)
- **2025-2026 Federal Deadline:** June 30, 2026 (11:59 PM CT) — still open for current college students
- The FAFSA has an 18-month application cycle
- **Key rule:** The most important deadline is the one that comes first — school deadline, state deadline, or federal deadline. Many state deadlines fall months before the federal deadline.

### FAFSA Simplification Act — Key Changes
Enacted as part of the FAFSA Simplification Act (effective starting with the 2024-2025 FAFSA), these are the major changes:

1. **EFC → SAI:** Expected Family Contribution (EFC) replaced by Student Aid Index (SAI). The term change clarifies this number is an index, not the actual amount families must pay.
2. **Fewer questions:** FAFSA reduced from ~100 questions to ~36 questions.
3. **IRS direct data transfer:** Financial information pulled directly from IRS via the IRS Direct Data Exchange (DDX), reducing errors and simplifying completion.
4. **Retirement contributions excluded:** Pre-tax 401k, 403b, pension contributions no longer counted as income (previously added back in).
5. **Multiple college students:** Previously, the parent contribution was divided by the number of family members in college simultaneously. Under the new formula, the SAI is NOT divided — each student is assessed individually. This is a significant change that hurts middle-income families with multiple college-age children.
6. **Automatic zero SAI:** Students whose parents are not required to file federal tax returns receive an SAI of -$1,500 (automatically qualify for maximum Pell Grant).
7. **Expanded Pell Grant eligibility:** More students qualify due to simplified formula and poverty-based income thresholds.
8. **Non-custodial parent financial info:** For students from divorced or separated households, the FAFSA now uses the financial information of the parent who provided more financial support over the past 12 months, rather than the custodial parent.
9. **Prior-Prior Year (PPY) tax data:** FAFSA uses tax data from two years prior (e.g., the 2026-2027 FAFSA uses 2024 tax data).

### Student Aid Index (SAI)
The SAI replaces the EFC and functions similarly — it's a number colleges use to calculate financial need:

**Formula:** Cost of Attendance (COA) − SAI = Financial Need

- SAI can range from **-$1,500 to unlimited** (there is no maximum)
- A negative SAI (down to -$1,500) indicates the highest need
- Higher SAI = less need-based aid eligibility
- SAI of 0 means the student qualifies for maximum Pell Grant

**What goes into SAI calculation (dependent students — Formula A):**
1. **Parent income:** AGI, untaxed income (note: 401k contributions now excluded)
2. **Parent assets:** Cash, savings, investments, real estate (excluding primary home), business assets
3. **Student income:** AGI and untaxed income (50% assessment rate above $11,770 protection allowance)
4. **Student assets:** Assessed at 20% rate
5. **Household size:** Larger families receive higher Income Protection Allowances
6. **State of residence:** Affects state tax allowances

**Assets INCLUDED in SAI calculation:**
- Cash, savings accounts, checking accounts
- Investment accounts (stocks, bonds, mutual funds, ETFs)
- Investment real estate (vacation homes, rental properties)
- 529 accounts owned by the parent
- Business net worth (with adjustment for small businesses)
- Non-qualified annuities

**Assets EXCLUDED from SAI calculation:**
- Primary home equity
- Retirement accounts (401k, 403b, IRA, pension)
- Life insurance cash value
- Small businesses with fewer than 100 full-time employees that are family-owned

---

### 2. State-Level FAFSA Priority Deadlines (2026-2027)

*Source: Fastweb, Edvisors, SavingForCollege.com — verify at your state's higher education agency*

| State | Deadline | Notes |
|-------|----------|-------|
| **Alabama (AL)** | N/A | Check with financial aid office |
| **Alaska (AK)** | AK Education Grant: ASAP after Oct 1, 2025 | Awards until funds depleted |
| | AK Performance Scholarship: June 30, 2026 | Priority consideration |
| **Arizona (AZ)** | April 1, 2026 | Arizona Promise Scholarship priority |
| **Arkansas (AR)** | July 1, 2026 | Academic Challenge & ArFuture Grant (fall) |
| | January 10, 2027 | ArFuture Grant (spring term) |
| **California (CA)** | March 2, 2026 (postmarked) | Cal Grant & many state programs; GPA certification also required by this date |
| | September 2, 2026 | Additional community college Cal Grants |
| **Colorado (CO)** | N/A | Check with financial aid office |
| **Connecticut (CT)** | February 15, 2026 | Priority consideration |
| **Delaware (DE)** | May 15, 2026 | |
| **District of Columbia (DC)** | June 25, 2026 | Priority consideration |
| | July 1, 2026 | DC Tuition Assistance Grant (DCTAG) |
| **Florida (FL)** | May 15, 2026 | State priority deadline |
| **Georgia (GA)** | ASAP after Oct 1, 2025 | Awards until funds depleted |
| **Hawaii (HI)** | N/A | Check with financial aid office |
| **Idaho (ID)** | March 1, 2026 | Opportunity Grant priority |
| **Illinois (IL)** | ASAP after Oct 1, 2025 | Monetary Award Program (MAP); awards until funds depleted |
| **Indiana (IN)** | ASAP after Oct 1, 2025 | Adult Student Grant & Workforce Ready Grant |
| | April 15, 2026 | Frank O'Bannon Grant |
| | April 15, 2026 | 21st Century Scholarship |
| **Iowa (IA)** | July 1, 2026 | Earlier priority deadlines for some programs |
| **Kansas (KS)** | April 1, 2026 | Priority consideration |
| **Kentucky (KY)** | ASAP after Oct 1, 2025 | Awards until funds depleted |
| **Louisiana (LA)** | July 1, 2027 | Recommended by February 1, 2026 |
| **Maine (ME)** | May 1, 2026 | |
| **Maryland (MD)** | March 1, 2026 | |
| **Massachusetts (MA)** | May 1, 2026 | Priority consideration |
| **Michigan (MI)** | July 1, 2026 | Michigan Competitive Scholarship & Tuition Grant |
| **Minnesota (MN)** | 30 days after term starts | State Grant and North Star Promise |
| **Mississippi (MS)** | October 15, 2026 | MTAG and MESG Grants |
| | April 30, 2026 | HELP Grants |
| **Missouri (MO)** | February 2, 2026 | Priority; applications accepted through April 1, 2026 |
| **Montana (MT)** | ASAP after Oct 1, 2025 | Priority consideration |
| **Nebraska (NE)** | N/A | Check with financial aid office |
| **Nevada (NV)** | ASAP after Oct 1, 2025 | Silver State Opportunity Grant |
| | April 1, 2026 | Nevada Promise Scholarship |
| **New Hampshire (NH)** | N/A | Check with financial aid office |
| **New Jersey (NJ)** | September 15, 2026 | All other applicants (fall & spring) |
| | April 15, 2026 | Tuition Aid Grant renewal applicants |
| | February 15, 2026 | Spring-only applicants |
| **New Mexico (NM)** | N/A | Check with financial aid office |
| **New York (NY)** | June 30, 2027 | |
| **North Carolina (NC)** | June 1, 2026 | UNC System institutions |
| | August 15, 2026 | Community colleges |
| | ASAP after Oct 1, 2025 | Private institutions |
| **North Dakota (ND)** | ASAP after Oct 1, 2025 | Awards until funds depleted |
| **Ohio (OH)** | October 1, 2026 | |
| **Oklahoma (OK)** | N/A | Contact financial aid office |
| **Oregon (OR)** | ASAP after Oct 1, 2025 | Oregon Opportunity Grant; funds depleted |
| | March 1, 2026 | OSAC Private Scholarships |
| **Pennsylvania (PA)** | May 1, 2026 | Most applicants |
| | August 1, 2026 | Community college/two-year programs |
| **Rhode Island (RI)** | N/A | Check with financial aid office |
| **South Carolina (SC)** | ASAP after Oct 1, 2025 | CHE Need-based Grants; funds depleted |
| | August 1, 2026 | SC Tuition Grants |
| **South Dakota (SD)** | N/A | Check with financial aid office |
| **Tennessee (TN)** | March 2, 2026 | State Grant (prior-year recipients) & TN Promise |
| | September 1, 2026 | State Lottery (fall term) |
| | March 1, 2027 | State Lottery (spring term) |
| **Texas (TX)** | January 15, 2026 | Priority consideration |
| **Utah (UT)** | N/A | Check with financial aid office |
| **Vermont (VT)** | ASAP after Oct 1, 2025 | Awards until funds depleted |
| **Virginia (VA)** | ASAP after Oct 1, 2025 | |
| **Washington (WA)** | ASAP after Oct 1, 2025 | Awards until funds depleted |
| **West Virginia (WV)** | March 1, 2026 | PROMISE Scholarship (new applicants submit additional form) |
| | April 15, 2026 | WV Higher Education Grant & Invests Grant |
| **Wisconsin (WI)** | N/A | Check with financial aid office |
| **Wyoming (WY)** | N/A | Check with financial aid office |

**Florida SUS Institution Priority Deadlines (for institutional aid — students must also meet the May 15 state deadline):**
- UF: December 1 (priority)
- FSU: December 1 (priority)
- UCF: December 1 (priority)
- USF: March 1 (priority)
- FAU: April 1 (priority)
- FIU: March 1 (priority)
- FGCU: March 1 (priority)
- UNF: January 15 (priority)
- FAMU: February 1 (priority)
- UWF: February 15 (priority)
- New College: February 1 (priority)

---

### 3. CSS Profile

**Official URL:** https://cssprofile.collegeboard.org/

### What Is the CSS Profile?
The CSS Profile (College Scholarship Service Profile) is an online financial aid application administered by College Board. It is used by approximately **250–300 colleges and scholarship programs** to award non-federal institutional aid — grants, loans, and scholarships funded directly by the institution. It unlocks access to more than **$14 billion in institutional financial aid** annually.

The CSS Profile does NOT replace the FAFSA. Students must file both if the college requires both. The FAFSA is required for all federal and state aid; the CSS Profile is for the institution's own funds.

### CSS Profile vs. FAFSA — Key Differences

| Feature | FAFSA | CSS Profile |
|---------|-------|-------------|
| Cost | Free | $25 first school; $16 each additional school |
| Fee waiver | N/A | Free for families with AGI ≤ $100,000; also for SAT fee waiver recipients; orphans/wards of court under 24 |
| Administered by | U.S. Department of Education | College Board |
| Purpose | Federal + state aid eligibility | Institutional (non-federal) aid eligibility |
| Primary home equity | Excluded | **Included** (a major difference) |
| Non-custodial parent info | Usually not required | **Required** (even for divorced/separated families) |
| Small business assets | Largely protected | More thoroughly assessed |
| Medical/dental expenses | Not considered | **Considered** |
| Private school tuition for siblings | Not considered | **Considered** |
| Non-qualified annuities | Excluded | **Included** |
| Assessment of student assets | 20% | Generally higher |
| Assessment of parent assets | Up to 5.64% | Up to ~5% (varies by school) |
| Number of questions | ~36 | Much longer (~200+ data points) |
| Tax data | IRS Direct Data Exchange | Manual entry + may require tax docs |
| Deadlines | School/state/federal tiers | School-specific — often earlier than FAFSA |

### Additional Information Required by CSS Profile (not on FAFSA)
- Home equity (primary residence value minus mortgage balance)
- Non-custodial parent's complete financial information
- Detailed debt information (credit card debt, car loans, mortgages)
- Business expenses and net worth of small businesses
- Medical and dental expenses not covered by insurance
- Private school tuition paid for siblings
- Non-qualified annuity values
- Detailed breakdown of rental income and property
- Mortgage information
- Child support paid/received

### How Many Schools Require It?
Approximately **250–300 schools** require the CSS Profile. These are predominantly:
- Elite private universities (all Ivy League schools, MIT, Stanford, Duke, etc.)
- Selective liberal arts colleges (Amherst, Williams, Bowdoin, etc.)
- A handful of public universities (University of Michigan, UNC Chapel Hill, UVA, Georgia Tech)

See the full list at: https://profile.collegeboard.org/PPI/participatingInstitutions.aspx

**Sample schools requiring CSS Profile:** Harvard, Yale, Princeton, Columbia, Penn, Cornell, Dartmouth, Brown, MIT, Stanford, Duke, Vanderbilt, Northwestern, Georgetown, Notre Dame, Emory, Tufts, Boston College, NYU, USC, Michigan, UVA, UNC Chapel Hill, Georgia Tech, Davidson, Bowdoin, Colby, Middlebury, Williams, Amherst, Wellesley, and ~250 others.

### CSS Profile Deadlines
CSS Profile deadlines are **school-specific** and are often tied to the college's financial aid priority deadline — which may be the same as or earlier than the admissions application deadline. Many selective schools require CSS Profile by November 1 (for Early Decision/Early Action) and by January or February (for Regular Decision). Students should check the financial aid page of each college they apply to.

The CSS Profile opens on **October 1** each year, consistent with FAFSA.

---

### 4. Expected Family Contribution / Student Aid Index (SAI) by Income

*Based on 2026-2027 SAI formula. Assumes: two-parent household, one student, zero assets. Family of four unless noted. Source: The College Investor SAI Chart*

### SAI Estimates for Family of Four (2 dependents in household)

| Parent AGI | 1 Dependent | 2 Dependents | 3 Dependents | 4 Dependents |
|-----------|-------------|--------------|--------------|--------------|
| $50,000 | $3,066 | $1,504 | $0 | $0 |
| $75,000 | $7,953 | $6,004 | $4,504 | $2,924 |
| $100,000 | $15,824 | $12,614 | $9,792 | $7,332 |
| $125,000 | $24,090 | $20,880 | $17,848 | $14,474 |
| $150,000 | $32,356 | $29,146 | $26,114 | $22,740 |
| $200,000 | $48,683 | $45,473 | $42,441 | $39,067 |

*Note: These are estimates. Actual SAI depends on assets, state of residence, family size, and student income. Use the Federal Student Aid Estimator at https://studentaid.gov/aid-estimator/ for a personalized estimate.*

### Key SAI Patterns
- Each additional child reduces SAI by approximately $3,000
- Each additional $10,000 in parent income increases SAI by ~$1,750–$3,000 (higher income = larger increase)
- A family of four qualifies for $0 SAI up to roughly AGI of ~$65,000
- A family of two (single parent + student) qualifies for $0 SAI up to roughly AGI of ~$42,500
- At very high incomes (>$200,000), the SAI increases at approximately 32% of additional income
- The new SAI formula no longer divides the parent contribution by the number of family members in college simultaneously (important change from EFC)

### SAI Calculation — Key Formula Components (Dependent Student, Formula A)

**Step 1: Parents' Available Income**
- Start with parents' total income (AGI + untaxed income, excluding 401k contributions)
- Subtract allowances: U.S. income tax paid, state tax allowance, payroll tax allowance, employment expense allowance, Income Protection Allowance (varies by family size)
- Progressive assessment rate on adjusted available income: 22%–47%

**Step 2: Parents' Contribution from Assets**
- Net worth of assets (cash, savings, investments, real estate excl. primary home, business assets)
- Subtract Education Savings and Asset Protection Allowance
- Multiply remaining by 12% assessment rate

**Step 3: Student's Contribution from Income**
- Student income above $11,770 protection allowance assessed at 50%

**Step 4: Student's Contribution from Assets**
- 20% of student's net worth of assets (529s in student's name assessed here)

**SAI = Steps 1 + 2 + 3 + 4** (minimum -$1,500)

---

### 5. Top 20 Largest Need-Based Scholarships (Non-Institutional)

*For US high school students; ranked approximately by award value*

### 1. Jack Kent Cooke Foundation College Scholarship
- **Amount:** Up to $55,000/year (last-dollar funding, renewable for 4 years)
- **Total value:** Up to $220,000
- **Eligibility:** High school seniors; minimum 3.75 unweighted GPA; family AGI ≤ $95,000; demonstrated unmet financial need; strong leadership
- **Deadline:** November 12, 2025 (for Class of 2026)
- **URL:** https://www.jkcf.org/our-scholarships/college-scholarship-program/

### 2. QuestBridge National College Match
- **Amount:** Full 4-year scholarship (tuition, room, board, books) — value varies by partner college; can exceed $300,000 at top schools
- **Eligibility:** High school seniors; typically household income < $65,000 for family of 4; high academic achievement; strong character
- **Deadline:** September 30, 2025 (application); October 16, 2025 (Match Rankings Form)
- **Match Day:** December 1, 2025
- **URL:** https://www.questbridge.org/high-school-students/national-college-match

### 3. The Gates Scholarship (TGS)
- **Amount:** Last-dollar full cost of attendance (covers everything not already covered by other aid) — 300 scholarships annually
- **Eligibility:** High school seniors; Pell Grant-eligible; minimum 3.3 GPA; US citizen/permanent resident; must be African American, American Indian/Alaska Native, Asian & Pacific Islander, and/or Hispanic American
- **Deadline:** September 15, 2025 (Phase 1)
- **URL:** https://www.thegatesscholarship.org/

### 4. Horatio Alger National Scholarships
- **Amount:** $25,000 (105 national scholarships annually); state scholarships also available
- **Eligibility:** High school seniors (and juniors for some awards); US citizens; critical financial need (family AGI ≤ $55,000 for national award); minimum 2.0 GPA; demonstrated perseverance in overcoming adversity
- **Deadline:** February 15, 2026 (seniors); March 1, 2026 (juniors); application opens December 1
- **URL:** https://horatioalger.org/scholarships/

### 5. Dell Scholars Program
- **Amount:** $20,000 ($5,000/year for 4 years) + laptop, textbook resources, and academic support; 500 scholarships annually
- **Eligibility:** High school seniors; must have participated in an approved college-readiness program in grades 11 & 12; minimum 2.4 GPA; Pell Grant eligible; demonstrating financial need; US citizen/permanent resident; plan to enroll in full-time 4-year bachelor's degree program
- **Deadline:** February 15, 2026
- **URL:** https://www.dellscholars.org/scholarship/

### 6. Coca-Cola Scholars Program
- **Amount:** $20,000 (one-time); 150 scholarships annually
- **Eligibility:** Current high school seniors graduating in 2025-2026; minimum 3.0 GPA; US citizen/national/permanent resident; planning to attend accredited US college
- **Note:** This is primarily merit/leadership-based but financial need is not a stated requirement — included here due to community impact focus
- **Deadline:** September 30, 2025
- **URL:** https://www.coca-colascholarsfoundation.org/apply/

### 7. TheDream.US National Scholarship
- **Amount:** Up to $33,000 total (tuition and fees at partner colleges) — considered the "Pell Grant for Dreamers"
- **Eligibility:** Undocumented immigrants (with or without DACA/TPS); entered US before age 16 and before November 1, 2020; significant unmet financial need; HS GPA ≥ 2.5; planning to attend a partner college in applicant's state
- **Deadline:** ~February 28, 2026 (application closes; opens November 1, 2025)
- **URL:** https://www.thedream.us/scholarships/national-scholarship/

### 8. TheDream.US Opportunity Scholarship
- **Amount:** Up to $100,000 (tuition, fees, housing, meals for 4 years at partner colleges in targeted "locked-out" states)
- **Eligibility:** Undocumented students in states where public colleges don't offer in-state tuition; must relocate to partner college state
- **Deadline:** ~January 31, 2026 (application opens November 1, 2025)
- **URL:** https://www.thedream.us/scholarships/opportunity-scholarship/

### 9. Hagan Scholarship Foundation
- **Amount:** Up to $7,500/semester for up to 8 semesters = $60,000 total; plus $2,000 start-up stipend; 1,200 scholarships annually
- **Eligibility:** High school seniors attending public high school in a rural US county (typically <50,000 residents); minimum 3.5 unweighted GPA; ACT ≥ 24 or SAT ≥ 1150; family AGI ≤ $100,000; must work 240 hours between January 1 and start of college; plan to attend 4-year not-for-profit college
- **Deadline:** December 1, 2025
- **URL:** https://haganscholarships.org/

### 10. Ron Brown Scholar Program
- **Amount:** $40,000 ($10,000/year for 4 years); 20 scholarships annually
- **Eligibility:** Black/African American high school seniors; US citizen or permanent resident; academic excellence; leadership potential; community service; financial need
- **Deadline:** December 1, 2025 (final deadline); applications open September 3
- **URL:** https://ronbrown.org/

### 11. Amazon Future Engineer Scholarship
- **Amount:** $10,000/year (renewable for 4 years = $40,000 total); plus paid Amazon internship
- **Eligibility:** High school seniors with high financial need; planning to study computer science at a 4-year college; from underrepresented backgrounds
- **Deadline:** Varies (typically January/February)
- **URL:** https://www.amazonfutureengineer.com/scholarships

### 12. Lilly Endowment Community Scholarship Program
- **Amount:** Full tuition + required fees at eligible Indiana colleges (4-year value can exceed $100,000)
- **Eligibility:** Indiana high school seniors; must be Indiana county residents attending high school in that county; plan to attend accredited Indiana college full-time; each county nominates candidates (county-specific eligibility)
- **Deadline:** Varies by county (typically September–October of senior year)
- **URL:** https://www.indianacf.org/lilly-endowment-community-scholarship-program/

### 13. Elks National Foundation Most Valuable Student Scholarship
- **Amount:** Top 20 winners: $30,000 total (4-year); 480 runners-up: $4,000 total; 500 total scholarships
- **Eligibility:** US citizen high school seniors; enroll in 4-year degree at accredited US college; judged on scholarship, leadership, and financial need
- **Deadline:** November 12, 2025 (for 2026 competition; opens August 1)
- **URL:** https://www.elks.org/scholars/scholarships/mvs.cfm

### 14. Jackie Robinson Foundation Scholarship
- **Amount:** Up to $35,000 over 4 years (~$8,750/year)
- **Eligibility:** Minority high school seniors (graduating seniors); US citizen; demonstrated academic excellence and financial need; leadership ability; enrollment at an accredited 4-year US institution
- **Deadline:** ~February (check website)
- **URL:** https://www.jackierobinson.org/apply/

### 15. Greenhouse Scholars Whole Person College Program
- **Amount:** $20,000 total + mentoring, coaching, and professional development
- **Eligibility:** High-achieving, low-income students from CO, GA, IL, or NC; first-generation or underrepresented students; high school seniors demonstrating financial need
- **Deadline:** November 14, 2025
- **URL:** https://greenhousescholars.org/

### 16. Cameron Impact Scholarship
- **Amount:** Full tuition (4-year); 10–15 awards annually
- **Eligibility:** High school seniors (Class of 2027); US citizens; minimum 3.7 unweighted GPA; demonstrated excellence in leadership, community service, extracurriculars; strong work ethic; no stated income limit but financial need considered; accepts first 3,000 completed applications or by May 1, 2026 (whichever first)
- **Deadline:** May 1, 2026 (or when 3,000 applications received)
- **URL:** https://bryancameroneducationfoundation.org/cameron-impact-scholarship/

### 17. Burger King Scholars Program
- **Amount:** $1,000–$60,000 (varies; top national awards are $50,000+); tens of thousands of scholarships distributed
- **Eligibility:** Graduating high school seniors in US, Puerto Rico, Guam; minimum 2.5 GPA; demonstrates financial need; work experience preferred; strong community involvement
- **Deadline:** December 15, 2025 (or when 30,000 applications received)
- **URL:** https://www.burgerkingfoundation.org/programs/burger-king-sm-scholars

### 18. Davis-Putter Scholarship Fund
- **Amount:** Up to $15,000/year (based on financial need)
- **Eligibility:** Students actively involved in movements for social and economic justice; demonstrated financial need; any year of college (high school seniors applying to college eligible)
- **Deadline:** ~April 1 annually
- **URL:** https://davisputter.org/

### 19. Hispanic Scholarship Fund (HSF)
- **Amount:** $500–$5,000 per year
- **Eligibility:** US citizens, permanent residents, DACA students of Hispanic heritage; minimum 3.0 GPA (high school) or 2.5 GPA (college); plan to enroll full-time at accredited US 4-year institution
- **Deadline:** ~February 15 annually
- **URL:** https://www.hsf.net/scholarship

### 20. Chick-fil-A Community Scholars
- **Amount:** Up to $25,000 ($5,000/year for 5 years)
- **Eligibility:** US and Canadian residents who are Chick-fil-A restaurant employees or children of employees; high school seniors; demonstrated need and academic achievement; community involvement
- **Deadline:** November 1, 2025
- **URL:** https://www.chick-fil-a.com/spotlight/scholarship

---

### 6. Top 20 Largest Merit-Based Scholarships (Non-College-Specific)

*Ranked approximately by award value; scholarships that are merit-first, though some consider need as secondary factor*

### 1. QuestBridge National College Match (also in need-based)
- **Amount:** Full 4-year scholarship at partner colleges (can exceed $320,000+ at schools like Yale, Harvard, Stanford)
- **Selection:** Merit + significant financial need (not pure merit, but highly competitive academic program)
- **Deadline:** September 30, 2025
- **URL:** https://www.questbridge.org/

### 2. Regeneron Science Talent Search
- **Amount:** Top prize $250,000; finalists compete for >$1.8 million total; 300 Scholars each receive $2,000; 40 finalists receive awards ranging from $25,000 to $250,000
- **Eligibility:** US high school seniors; must submit an original scientific research paper; independent research project
- **Deadline:** November 2025 (application closes); Scholars announced January 2026; Finals week March 2026
- **URL:** https://www.societyforscience.org/regeneron-sts/

### 3. Davidson Fellows Scholarship
- **Amount:** $100,000, $50,000, or $25,000 (one-time); approximately 20 awards annually
- **Eligibility:** US students 18 or younger; must have completed a significant project in science, technology, engineering, mathematics, literature, music, philosophy, or "outside the box" thinking; projects must be completed within 18 months of application
- **Deadline:** February 18, 2026
- **URL:** https://www.davidsongifted.org/fellows-scholarship/

### 4. Jack Kent Cooke Foundation College Scholarship (also in need-based)
- **Amount:** Up to $55,000/year (up to $220,000 total)
- **Type:** Merit + need (strong academics required with 3.75+ GPA)
- **Deadline:** November 12, 2025
- **URL:** https://www.jkcf.org/

### 5. Cameron Impact Scholarship (also in need-based)
- **Amount:** Full tuition for 4 years
- **Merit focus:** Academic excellence + leadership + community service + work ethic; min 3.7 GPA
- **Deadline:** May 1, 2026
- **URL:** https://bryancameroneducationfoundation.org/

### 6. Coolidge Scholarship
- **Amount:** Full ride (tuition, room, board, fees) at **any** accredited US college — one of the few full-ride scholarships usable anywhere; 5–8 awards annually
- **Eligibility:** US high school juniors (apply junior year); outstanding academics; leadership; community involvement; pure merit, need-blind
- **Deadline:** ~December 16, 2025 (junior year deadline)
- **URL:** https://coolidgefoundation.org/scholarship/

### 7. National Merit Scholarship Program
- **Amount:**
  - National Merit $2,500 Scholarships: 2,500 one-time $2,500 awards
  - Corporate-sponsored Scholarships: ~830 awards; $2,500–$10,000 (one-time or renewable)
  - College-sponsored Merit Scholarships: ~3,600 renewable awards; $500–$2,000/year
- **Eligibility:** US high school students who take the PSAT/NMSQT in October of junior year; top ~1% scorers (Selection Index typically ≥ 210–220 depending on state); US citizen
- **Selection:** PSAT → Semifinalist → Finalist → Scholar (approximately 7,500 total scholarship winners from 15,000 Finalists)
- **URL:** https://www.nationalmerit.org/

### 8. Ron Brown Scholar Program (also in need-based)
- **Amount:** $40,000 ($10,000/year for 4 years); 20 scholarships annually
- **Type:** Merit (excellence) + need; African American students
- **Deadline:** December 1, 2025
- **URL:** https://ronbrown.org/

### 9. GE-Reagan Foundation Scholarship Program
- **Amount:** $10,000/year renewable for up to 4 years = $40,000 total
- **Eligibility:** US high school seniors; demonstrates exemplary leadership, drive, integrity, citizenship; minimum 3.0 GPA; US citizen
- **Deadline:** January 4, 2026 (for 2026 awards; opens October 2025)
- **URL:** https://www.reaganfoundation.org/education/scholarship-programs/ge-reagan-foundation-scholarship-program/

### 10. Gates Scholarship (also in need-based)
- **Amount:** Full cost of attendance (last-dollar); 300 awards annually; minority students from low-income households
- **Type:** Merit (3.3+ GPA) + need + minority status
- **Deadline:** September 15, 2025
- **URL:** https://www.thegatesscholarship.org/

### 11. Elks MVS Scholarship (also in need-based)
- **Amount:** Top 20: $30,000; 480 runners-up: $4,000; judged on merit, leadership, financial need
- **Deadline:** November 12, 2025
- **URL:** https://www.elks.org/scholars/scholarships/mvs.cfm

### 12. Coca-Cola Scholars Program (also in need-based list)
- **Amount:** $20,000 (one-time); 150 scholarships annually
- **Selection:** Leadership impact, service, academic performance (not strictly need-based)
- **Deadline:** September 30, 2025
- **URL:** https://www.coca-colascholarsfoundation.org/

### 13. Horatio Alger National Scholarship (also in need-based)
- **Amount:** $25,000; 105 national scholarships
- **Type:** Merit + need + overcoming adversity
- **Deadline:** February 15, 2026 (seniors)
- **URL:** https://horatioalger.org/

### 14. Dell Scholars Program (also in need-based)
- **Amount:** $20,000 + laptop + support; 500 awards
- **Type:** Mostly need-based with merit component (2.4 GPA min)
- **Deadline:** February 15, 2026
- **URL:** https://www.dellscholars.org/scholarship/

### 15. Hagan Scholarship (also in need-based)
- **Amount:** Up to $60,000 over 4 years (up to $7,500/semester × 8 semesters)
- **Type:** Need-based merit (3.5 GPA + ACT 24/SAT 1150 + rural school + income cap)
- **Deadline:** December 1, 2025
- **URL:** https://haganscholarships.org/

### 16. VFW Voice of Democracy Scholarship
- **Amount:** Top national winner: $35,000; total >$1.9 million distributed annually across state/national levels
- **Eligibility:** US high school students (9th–12th grade); US citizen or permanent resident; audio essay on patriotic theme
- **Deadline:** October 31, 2025 (submitted to local VFW post)
- **URL:** https://www.vfw.org/community/youth-and-education/youth-scholarships

### 17. Regeneron International Science and Engineering Fair (ISEF)
- **Amount:** Grand Awards from $1,500 to $75,000; Best of Category awards $5,000; top awards from affiliated organizations can be $50,000–$75,000
- **Eligibility:** High school students (9th–12th grade); original independent research project; must win at regional/state fair to qualify for ISEF
- **URL:** https://www.societyforscience.org/isef/

### 18. Burger King Scholars Program (also in need-based)
- **Amount:** $1,000–$60,000 (top awards $50,000+)
- **Type:** Merit + service + financial need
- **Deadline:** December 15, 2025
- **URL:** https://www.burgerkingfoundation.org/

### 19. Elks "Most Valuable Student" State Scholarships
- **Amount:** Varies by state; many state associations award additional $500–$4,000 scholarships beyond the national program
- **Eligibility:** Same as national MVS; state-level competition feeds into national
- **Deadline:** Varies by state (typically fall of senior year)
- **URL:** Check local Elks lodge

### 20. McDonald's HACER National Scholarship
- **Amount:** Up to $100,000 total over 4 years ($25,000/year)
- **Eligibility:** US residents who are high school seniors with at least one parent of Hispanic heritage; minimum 2.8 GPA; demonstrate leadership, community involvement, financial need; plan to enroll in 2- or 4-year US college
- **Deadline:** ~February 3, 2026
- **URL:** https://www.mcdonalds.com/us/en-us/community/hacer.html

---

### 7. Florida Benacquisto Scholarship

**Source:** Florida Department of Education, OSFA — https://www.floridastudentfinancialaidsg.org/

### What Is It?
The Benacquisto Scholarship Program is a **merit-based scholarship** for Florida high school graduates who receive recognition as **National Merit Scholars**. It is not a need-based program. It is funded by the Florida Legislature and administered by the Florida Department of Education's Office of Student Financial Assistance (OSFA).

### Eligibility Requirements
To qualify, a student must:
1. **Be a National Merit Scholar** — A National Merit Finalist becomes a Scholar by receiving one of the following qualifying awards:
   - National Merit $2,500 Scholarship (awarded by NMSC)
   - Corporate-sponsored Merit Scholarship
   - College-sponsored Merit Scholarship from an eligible Florida institution
   - **NOTE:** "Special" Corporate Scholarships and "Presidential" awards from colleges do NOT qualify
2. **Be a Florida resident** (out-of-state students no longer eligible as of 2022-2023)
3. **Earn a standard Florida high school diploma** (or equivalent — home education, non-Florida HS while parent on military/public service assignment)
4. **Enroll full-time** (minimum 12 credit hours per term) in a baccalaureate degree program
5. **Enroll at an eligible, regionally accredited Florida postsecondary institution** during the **fall term immediately following high school graduation**
6. **Be a US citizen or eligible non-citizen**

### Award Amount
**Formula: Benacquisto Award = Cost of Attendance (COA) − Bright Futures Award − National Merit Award**

In practice, Benacquisto fills the gap between Bright Futures + National Merit award and the full in-state cost of attendance. This means:
- The scholarship effectively pays **full in-state cost of attendance** (when combined with Bright Futures)
- COA includes tuition & fees, on-campus room & board, books, supplies, travel, and miscellaneous expenses
- At FSU, the Benacquisto disbursement typically ranges **$16,000–$25,000 per year** depending on credit hours (because Bright Futures covers tuition/fees, and Benacquisto covers the rest of COA)
- At UF, based on an in-state COA of approximately $23,150/year, Benacquisto covers COA minus Bright Futures (~$212/credit hour for FAS)

### How It Works at Specific Schools
- **UF, FSU, UCF, USF, FAU, FIU, New College, ERAU, UM:** All are eligible participating institutions (nine institutions participate as College-Sponsors with NMSC)
- **College-sponsored award students** (those who listed FSU/UF/UCF etc. as first choice with NMSC) must remain at that institution to maintain eligibility
- **National Merit $2,500 or Corporate-sponsored award students** may attend any eligible Florida institution and transfer between them (as long as they remain enrolled in Florida)
- Awards are disbursed each fall and spring semester only (not summer)
- Students may receive the award for up to **5 years following high school graduation** and no more than **10 semesters**

### Application Process
- **No separate application required** — eligibility is automatically determined through the NMSC roster sent to Florida institutions
- Students should retain copies of their National Merit Finalist letter and scholarship award letter
- For College-sponsored scholarships, students must list their chosen Florida college as first choice with NMSC **by May 1** of their senior year
- Institutional aid offices verify eligibility

### Renewal Requirements
- Minimum cumulative 3.0 GPA on a 4.0 scale (evaluated at end of spring semester each year)
- Must earn all credit hours enrolled at the end of the regular drop/add period each term
- Automatic renewal at end of academic year if requirements are met

### Can It Stack With Bright Futures?
**Yes — they are designed to stack together.** Benacquisto is specifically calculated as the remainder after Bright Futures and the National Merit award are applied. A student receiving Florida Academic Scholars (FAS = 100% tuition) receives Bright Futures for tuition/fees, and Benacquisto covers the remaining cost of attendance (room, board, books, transportation, etc.) up to the full COA. The student effectively receives their full in-state COA covered between the two programs plus the National Merit award.

Additional institutional merit scholarships from the university (e.g., UF Presidential Scholars award, FSU departmental awards) are generally additive and may result in a cash refund above the COA calculation.

---

### 8. Florida First Generation Matching Grant (FGMG)

**Source:** Florida Department of Education, OSFA — https://www.floridastudentfinancialaidsg.org/
**Florida Statutes:** Section 1009.701

### What Is This Program?
The First Generation Matching Grant (FGMG) Program is a **need-based grant** available to Florida resident undergraduate students who are the **first in their family to earn a bachelor's degree**. It is funded jointly by state General Revenue funds and private contributions from participating institutions. The state provides matching funds at a **2:1 ratio** (two dollars state funds per one dollar of private contribution). For 2025-2026, total appropriation was $10,617,326.

### Eligibility Requirements
- **Florida resident and US citizen** (or eligible non-citizen/permanent resident)
- **First-generation college student:** Neither parent has earned a baccalaureate degree or higher
  - A student raised by a single parent who did not earn a bachelor's degree also qualifies
- Degree-seeking undergraduate student (associate or bachelor's degree)
- Enrolled at a **Florida state university or Florida College System institution** (public community college)
- Enrolled in a **minimum of 6 credit hours per term**
- Demonstrate **substantial financial need** (must meet eligibility for Florida Public Student Assistance Grant based on FAFSA)
- Must complete FAFSA by the institution's deadline
- Must not have previously received a baccalaureate degree
- Must not be in default on any state or federal grant or loan

### Award Amount
- **Maximum annual award: up to $1,491** (varies; the BigFuture database shows this figure for 2025-2026)
- Awards are **not available for summer term**
- Actual award amounts vary by institution and available funding
- Each participating institution determines award amounts for their students

### Deadline
- **Deadline varies by institution** — institutions determine their own application procedures and deadlines
- **General guideline:** Complete FAFSA by the institution's priority deadline (typically December–March)
- FGMG opens: October 1, 2025; closes: August 31, 2026
- Institutions must certify private contributions to the Division of Florida Colleges by **December 1, 2024** (for 2024-2025)

### How to Apply
1. Complete the **FAFSA** by your institution's priority deadline
2. Contact the **financial aid office** at your Florida public university or community college for institution-specific application procedures
3. Each institution has its own application form and process
4. Award is determined by the institution based on financial need
5. No statewide application — this is entirely institution-administered

### Participating Institutions
Available at all Florida state universities (UF, FSU, UCF, USF, FAU, FIU, FGCU, UNF, FAMU, UWF, New College, Florida Poly) and Florida College System institutions (public community colleges).

---

### 9. Other Key Financial Aid Programs

### Federal Pell Grant

**URL:** https://studentaid.gov/understand-aid/types/grants/pell

| Item | Details |
|------|---------|
| **Maximum award 2025-2026** | **$7,395** |
| **Maximum award 2026-2027** | **$7,395** (same; subject to Congressional changes) |
| **Minimum award 2026-2027** | $740 |
| **Eligible students** | Undergraduate students with exceptional financial need (determined by SAI and income) |
| **Duration** | Up to 12 semesters (6 years) lifetime |
| **Repayment** | Never — it is a grant, not a loan |

**Income Thresholds for Maximum 2026-2027 Pell Grant (family of 4):**
- Married parents: AGI ≤ $54,600
- Unmarried parent: AGI ≤ $70,200

**How the Pell Grant is determined (2026-2027):**
1. If parents' AGI is below the threshold (tied to 225% of poverty line for unmarried parent, 175% for married), student may qualify for maximum Pell
2. IF the SAI is ≤ 0, student receives maximum Pell
3. If SAI is > $14,790 (twice the max Pell), student is NOT eligible for Pell
4. Partial Pell is awarded for SAI between 0 and ~$6,000 (decreasing amounts)

Approximately **6.1 million students** receive Pell Grants annually.

---

### Federal Work-Study (FWS)

**URL:** https://studentaid.gov/understand-aid/types/work-study

| Item | Details |
|------|---------|
| **What it is** | Need-based federal program funding part-time jobs for students to earn money to help pay education expenses |
| **Who determines award** | College financial aid office; included in financial aid package |
| **Where students work** | On-campus jobs or approved off-campus organizations (nonprofits, government agencies, community service organizations) |
| **Hours** | Maximum ~20 hours/week during school; up to 40 hours during breaks |
| **Pay** | At least federal minimum wage; paid directly to student (not applied to student account unless requested) |
| **Earnings** | Cannot exceed the total FWS award; student earns money through paychecks |
| **Benefit** | FWS earnings are partially excluded from the following year's FAFSA income calculation |
| **Federal share** | Historically 75% federal / 25% employer; NOTE: Starting July 1, 2026, the One Big Beautiful Bill Act changes the federal share to 25%, requiring colleges to cover 75% — this may reduce available work-study positions |

Work-study is a program, not automatic — students must have it included in their aid package and must find and hold a position.

---

### Federal Direct Subsidized vs. Unsubsidized Loans

**URL:** https://studentaid.gov/understand-aid/types/loans/subsidized-unsubsidized

#### Interest Rates (2025-2026)
| Loan Type | Borrower | Rate |
|-----------|----------|------|
| Direct Subsidized | Undergraduate | **6.39%** (fixed) |
| Direct Unsubsidized | Undergraduate | **6.39%** (fixed) |
| Direct Unsubsidized | Graduate/Professional | 7.94% (fixed) |

*Note: Rates for 2026-2027 will be set based on the May 2026 10-year Treasury auction + margin*

#### Key Differences

| Feature | Subsidized | Unsubsidized |
|---------|------------|--------------|
| Based on financial need | **Yes** — must demonstrate need | No — available to all eligible students |
| Who pays interest while in school | **U.S. Government** | Student (interest accrues from disbursement) |
| Who pays interest during grace period (6 months after leaving school) | **U.S. Government** | Student |
| Who pays interest during deferment | **U.S. Government** | Student |
| Available to | Undergraduate students only | Undergraduate AND graduate students |
| Lifetime borrowing limit | $23,000 (combined) | Part of total aggregate limit |

#### Annual Loan Limits (Dependent Undergraduates)
| Year | Total Limit | Subsidized Cap |
|------|-------------|----------------|
| Freshman | $5,500 | Up to $3,500 sub |
| Sophomore | $6,500 | Up to $4,500 sub |
| Junior/Senior/5th Yr | $7,500 | Up to $5,500 sub |

#### Aggregate (Lifetime) Limits
| Student Type | Total | Subsidized Limit |
|-------------|-------|-----------------|
| Dependent Undergraduate | $31,000 | $23,000 |
| Independent Undergraduate | $57,500 | $23,000 |

#### Origination Fees
- No origination fees for Direct Subsidized/Unsubsidized loans (effective as of 2020)

---

### Parent PLUS Loans

**URL:** https://studentaid.gov/understand-aid/types/loans/plus/parent

| Item | Details |
|------|---------|
| **Interest rate (2025-2026)** | **8.94%** fixed (set July 1, 2025; for loans disbursed July 1, 2025–June 30, 2026) |
| **Origination fee** | 4.228% (deducted from disbursement) |
| **Who can borrow** | Biological or adoptive parents of dependent undergraduate students; US citizen or eligible non-citizen; must pass credit check |
| **Credit check** | Yes — no major adverse credit history (defaults, bankruptcy, foreclosure, collections >$2,085, etc.) |
| **Borrowing limit (2025-2026)** | Up to full cost of attendance minus all other aid received |
| **NEW LIMITS (July 1, 2026)** | Annual cap of **$20,000/year** per dependent student; lifetime cap of **$65,000 per student** (One Big Beautiful Bill Act, July 2025) |
| **Repayment (before July 1, 2026)** | Multiple repayment plans including income-driven repayment (ICR) |
| **Repayment (after July 1, 2026)** | New PLUS loans restricted to Tiered Standard Repayment Plan only; income-driven repayment NO LONGER available for new PLUS loans |
| **PSLF eligibility (before July 1, 2026)** | Eligible via consolidation into Direct Consolidation Loan + ICR plan |
| **PSLF eligibility (after July 1, 2026)** | Not available for new PLUS loans under new law |

**Important 2026 Warning for Parents:** Parents who want to keep income-driven repayment access should consolidate existing PLUS loans into a Direct Consolidation Loan and enroll in IBR BEFORE July 1, 2026. Taking out any new PLUS loan after July 1, 2026 may eliminate IDR access on consolidated loans as well.

---

### Florida Student Assistance Grant (FSAG)

**Source:** OSFA Fact Sheet — https://www.floridastudentfinancialaidsg.org/PDF/factsheets/FSAG.pdf
**Florida Statutes:** Chapter 1009

| Item | Details |
|------|---------|
| **What it is** | Need-based grant for Florida resident undergraduate students |
| **Administering body** | Florida Department of Education, OSFA |
| **SAI cutoff (2025-2026)** | SAI ≤ 9,984 (approximately 1.5× the maximum Pell Grant) |
| **Maximum annual award** | **$3,260** (2025-2026); $1,630 per semester for full-time (≥12 credit hours) |
| **Minimum annual award** | $200 |
| **Sectors** | Florida Public (state universities & community colleges), Florida Private, Postsecondary, Career Education |
| **Enrollment requirement** | Minimum 6 credit hours per term (public); 12 credit hours per term (private) |
| **Renewal GPA** | Minimum 2.0 cumulative GPA |
| **Renewal credits** | Must complete 12 credit hours per semester (full-time); proportionally fewer for part-time |
| **Maximum eligibility** | 110% of credit hours required for program (typically 132 attempted credit hours for 120-hour program) |
| **How to apply** | Complete FAFSA by institution's priority deadline; institution determines awards |
| **Florida deadline** | **May 15, 2026** (state FAFSA priority deadline) |

**FSAG Sub-Programs:**
- **FSAG Public:** For students at state universities and Florida College System (public community college) institutions; minimum 6 credit hours
- **FSAG Private:** For students at eligible independent/private Florida institutions; minimum 12 credit hours
- **FSAG Postsecondary:** For certain career-focused programs
- **FSAG Career Education:** For clock-hour programs at eligible institutions

**Talented Twenty Priority:** High school graduates in the top 20% of their class (the Talented Twenty Program) receive priority FSAG funding at Florida public institutions.

---

### Summary Reference Table — Key Programs at a Glance

| Program | Type | Max Amount | Income Threshold | Deadline |
|---------|------|------------|-----------------|---------|
| Federal Pell Grant | Need-based federal grant | $7,395/yr | AGI ≈ $55K-$70K (family of 4) for max | June 30, 2027 (federal) |
| Federal Work-Study | Need-based employment | Varies | Must demonstrate need | Ongoing (school-specific) |
| Direct Subsidized Loan | Need-based loan | $3,500–$5,500/yr | Must demonstrate need | June 30 |
| Direct Unsubsidized Loan | Non-need-based loan | $5,500–$7,500/yr | No income limit | June 30 |
| Parent PLUS Loan | Non-need-based parent loan | $20,000/yr (new; after July 2026) | No income limit; credit check required | June 30 |
| FSAG | Need-based FL state grant | $3,260/yr | SAI ≤ 9,984 | May 15, 2026 |
| Benacquisto Scholarship | Merit-based FL scholarship | Full in-state COA | No income test | No application; automatic |
| FL First Gen Matching Grant | Need-based FL grant | ~$1,491/yr | Substantial need; first-gen | Institutional (varies) |
| FAFSA (2026-2027) | Application (not aid itself) | N/A | N/A | June 30, 2027 (federal) |
| CSS Profile | Application (not aid itself) | N/A | N/A | School-specific |

---

### Area 6 Data Sources & References

1. **FAFSA Deadlines (State & Federal):** [SavingForCollege.com](https://www.savingforcollege.com/article/fafsa-deadlines) | [Fastweb](https://www.fastweb.com/financial-aid/articles/financial-aid-and-fafsa-state-deadlines) | [Edvisors](https://www.edvisors.com/student-loans/fafsa/fafsa-deadlines/)
2. **FAFSA 2026-2027 Open Date:** [Vaughn College](https://www.vaughn.edu/blog/fafsa-for-2026-2027-now-open-important-updates/)
3. **FAFSA Simplification Act:** [Ascent Funding](https://www.ascentfunding.com/blog/fafsa-simplification-act-changes-to-the-fafsa/) | [Middlesex College](https://middlesexcollege.edu/financial-aid/fafsa-simplification/)
4. **SAI Chart:** [The College Investor](https://thecollegeinvestor.com/43805/student-aid-index-sai-chart/) | [College Money Method](https://www.collegemoneymethod.com/2026-27-fafsa-student-aid-index-sai-calculator/)
5. **SAI Formula:** [FSA Handbook 2025-2026](https://fsapartners.ed.gov/knowledge-center/fsa-handbook/2025-2026/application-and-verification-guide/ch3-student-aid-index-sai-and-pell-grant-eligibility)
6. **CSS Profile:** [cssprofile.collegeboard.org](https://cssprofile.collegeboard.org/) | [CollegeVine](https://blog.collegevine.com/every-school-that-requires-the-css-profile) | [InGenius Prep](https://ingeniusprep.com/blog/css-profile-schools/)
7. **CSS vs. FAFSA:** [Sallie Mae](https://www.sallie.com/resources/financial-aid/css-profile-vs-fafsa) | [Ameriprise](https://www.ameriprise.com/financial-goals-priorities/education-planning/fafsa-css-how-do-they-work)
8. **Pell Grant:** [BestColleges](https://www.bestcolleges.com/research/pell-grant-amount/) | [College Investor](https://thecollegeinvestor.com/58058/pell-grant-chart/) | [College Money Method](https://www.collegemoneymethod.com/income-limits-to-receive-the-pell-grant/)
9. **Student Loan Rates:** [TICAS](https://ticas.org/federal-student-loan-amounts-and-terms-for-loans/) | [Bankrate](https://www.bankrate.com/loans/student-loans/current-interest-rates/) | [ELFI](https://www.elfi.com/understanding-federal-student-loan-rates-for-2025-2026/)
10. **Parent PLUS Loans:** [Sallie Mae blog](https://www.salliemae.com/blog/what-is-a-parent-plus-loan/) | [NerdWallet](https://www.nerdwallet.com/student-loans/learn/parent-plus-loans-limits) | [StudentAid.gov](https://studentaid.gov/understand-aid/types/loans/plus/parent)
11. **Benacquisto Scholarship:** [OSFA Fact Sheet](https://www.floridastudentfinancialaidsg.org/PDF/factsheets/BSP.pdf) | [OSFA FAQ](https://www.floridastudentfinancialaidsg.org/PDF/factsheets/BSP_FAQ.pdf) | [UCF Financial Aid](https://www.ucf.edu/financial-aid/types/scholarships/benacquisto/) | [FSU Admissions](https://admissions.fsu.edu/first-year/scholarships)
12. **First Gen Matching Grant:** [OSFA Fact Sheet](https://www.floridastudentfinancialaidsg.org/pdf/factsheets/fgmg.pdf) | [BigFuture](https://bigfuture.collegeboard.org/scholarships/first-generation-matching-grant-program) | [FLDOE 2025-2026](https://www.fldoe.org/file/5659/25-26FGMGMemo.pdf)
13. **FSAG:** [OSFA FSAG Fact Sheet](https://www.floridastudentfinancialaidsg.org/PDF/factsheets/FSAG.pdf) | [OSFA 2025-26 FSAG Awards](https://www.floridastudentfinancialaidsg.org/PDF/PSI/2526-03a.pdf)
14. **Federal Work-Study:** [FSA Handbook 2025-2026](https://fsapartners.ed.gov/knowledge-center/fsa-handbook/2025-2026/vol6/ch2-federal-work-study-program)
15. **Scholarships:** [Jack Kent Cooke](https://www.jkcf.org/our-scholarships/college-scholarship-program/) | [QuestBridge](https://www.questbridge.org/) | [Gates Scholarship](https://www.thegatesscholarship.org/) | [Horatio Alger](https://horatioalger.org/) | [Dell Scholars](https://www.dellscholars.org/) | [Coca-Cola Scholars](https://www.coca-colascholarsfoundation.org/) | [National Merit](https://www.nationalmerit.org/) | [Davidson Fellows](https://www.davidsongifted.org/fellows-scholarship/) | [Regeneron STS](https://www.societyforscience.org/regeneron-sts/) | [Coolidge Scholarship](https://coolidgefoundation.org/)

*Last updated: April 2026. All deadlines and amounts subject to change. Always verify with the official source before advising students.*


---

## Area 7: Extracurricular Activities in College Admissions
### Comprehensive Research for College Guidance App

---

### 1. Which Extracurriculars Have the Highest Impact at Selective Schools?

#### The 4-Tier Extracurricular Classification System

The four-tier system is the standard framework used by admissions consultants and selective college admissions officers to evaluate extracurricular activities. The tier of an activity is determined not by the *type* of activity, but by the *level of achievement and distinction* the student has reached within it.

**Source:** [CollegeVine — Breaking Down the 4 Tiers of Extracurricular Activities](https://blog.collegevine.com/breaking-down-the-4-tiers-of-extracurricular-activities), [Inspira Advantage](https://www.inspiraadvantage.com/blog/tiers-of-extracurricular-activities), [PrepWell Academy](https://prepwellacademy.com/how-to-audit-your-child-s-extracurriculars/)

---

#### Tier 1 — Rare / National or International Distinction

**Definition:** Activities demonstrating exceptional achievement or leadership that are nationally or internationally recognized. These are seen by admissions officers as truly rare, often appearing in only a handful of applications per year, and have the highest possible impact on the admissions decision.

**Examples:**
- Being a highly recruited Division I athlete or nationally ranked player (e.g., top 100 in the country in tennis)
- Winning first place at the United States of America Mathematical Olympiad (USAMO)
- Qualifying for the International Biology Olympiad (IBO) or International Physics Olympiad (IPhO)
- Winning a prestigious national academic award (Intel/Regeneron Science Talent Search, Davidson Fellows)
- National recognition for musical prowess (e.g., Jack Kent Cooke Young Artist Award)
- Winning the Presidential Scholars Program
- Publishing a first-authored paper in a legitimate peer-reviewed journal (note: predatory/pay-to-publish high school journals do NOT qualify — see Section 4)
- Writing a novel that gains national media attention or is commercially published
- Starting an organization that receives national news coverage
- Raising a substantial (six-figure) amount of money for a self-initiated cause
- Attendance at a highly selective, merit-based national summer program (e.g., Anson L. Clark Scholars Program, RSI, PRIMES)
- Performing at Carnegie Hall or Lincoln Center as a selected soloist
- Being named a National Youth Poet Laureate or finalist

**Admissions impact:** Extremely high. A single Tier 1 activity can transform an application. Admissions officers may flag the application as a "special case" or "exceptional" for committee review.

---

#### Tier 2 — State / Regional Distinction

**Definition:** Activities demonstrating high levels of achievement and leadership at the state or regional level. These are impressive and notable, but somewhat less rare than Tier 1.

**Examples:**
- Being a state champion athlete or All-State selection in football, basketball, orchestra, band, or choir
- Holding a key leadership position (president or chair) in a well-respected organization: school-level Model UN chapter, state debate circuit leader
- Winning a regional competition such as the Junior Science and Humanities Symposium (JSHS), regional Science Olympiad invitational, or regional Scholastic Art & Writing Award Gold Key
- Being a finalist in prestigious national competitions (e.g., National Youth Poet Laureate finalist, National Merit Semifinalist)
- Creating a short film that wins a regional competition
- Volunteer work that receives regional or statewide news coverage (e.g., founding a program to welcome refugees that is featured in regional media)
- Serving as the state president or state-level officer of a recognized youth organization (e.g., state FFA president, FBLA state officer)
- Winning a competitive regional scholarship

**Admissions impact:** Substantial. Tier 2 activities significantly strengthen an application, especially at highly selective schools. They are the backbone of a competitive extracurricular profile.

---

#### Tier 3 — School-Level Leadership / Meaningful Participation

**Definition:** Active engagement in school or community-based clubs and organizations with a meaningful leadership role or recognition. These do not carry the distinction of higher tiers but demonstrate dedication, involvement, and initiative.

**Examples:**
- Serving as club president, vice president, or captain of a school sports team
- Being editor of the school newspaper or literary magazine
- Holding minor leadership positions (treasurer, secretary) in well-known clubs (Model UN, debate, Science Olympiad)
- Playing in a selective regional music ensemble (without achieving All-State level)
- Receiving a Player of the Week award or similar local/school-level athletic distinction
- Organizing and leading community service projects (food drives, hospital visits)
- Starting a small club at school with modest membership
- Self-driven mentoring of a younger student or tutoring program within school

**Admissions impact:** Moderate. Tier 3 activities round out a profile and demonstrate consistent involvement. They are essential for showing who the student is but should not be the centerpiece of an application to highly selective schools.

---

#### Tier 4 — Participation / Membership (No Distinction)

**Definition:** The most common activities seen by admissions committees. They show that the student is active and engaged outside the classroom but do not demonstrate meaningful leadership, achievement, or impact.

**Examples:**
- General membership in clubs (Model UN, debate, Science Olympiad, Key Club, NHS) without leadership
- Participating on a sports team without notable achievement (e.g., JV soccer player, member of track team)
- Taking karate or piano lessons for multiple years without competitive achievement
- Playing in the marching band without achieving a selective placement
- General/routine volunteering at a food bank, hospital, or senior center without leadership
- Attending a summer program that is not highly selective or merit-based

**Admissions impact:** Low in isolation, but still valuable for showing breadth of interests. Tier 4 activities are essentially "table stakes" for any applicant.

---

#### Expected Tier Distribution at Selective Schools

Per [PrepWell Academy](https://prepwellacademy.com/how-to-audit-your-child-s-extracurriculars/):

> "Ivy League and near-Ivies (Top 75 schools) will expect to see about 4 activities in the Tier I–II band and 4 activities in the Tier III–IV band."

This is a guideline, not a rule. An applicant with two extraordinary Tier 1 activities may be compelling even if remaining activities are Tier 3-4.

---

#### Specific Activities Ranked by Impact

According to [CollegeVine's chancing data](https://www.collegevine.com/faq/118874/what-extracurricular-activities-do-colleges-value-most) and former admissions officer commentary, what matters most is not the *type* of activity but the *level reached*. That said, certain activity types carry structural advantages:

| Activity Type | Typical Ceiling | Notes |
|---|---|---|
| Academic research (original, published) | Tier 1 | Must be legitimate; pay-to-publish journals are red flags |
| National academic competitions (USAMO, USABO, etc.) | Tier 1 | Highly valued; clear, verifiable national distinction |
| Recruited athletic excellence | Tier 1 | Explicit admission pathway; separate process |
| Entrepreneurship (real revenue, media coverage) | Tier 1–2 | Story/mission > financial details |
| Founding a nonprofit (with demonstrated impact) | Tier 1–2 | Dependent on scale and verifiability |
| Student body president / school leadership | Tier 2–3 | Common; president of a large, competitive school > small school |
| National arts competitions | Tier 1–2 | Jack Kent Cooke, Juilliard Pre-College, YoungArts |
| Journalism / publication | Tier 2–3 | Editor-in-chief of competitive school paper > contributor |
| Paid internship (relevant field) | Tier 2–3 | Company prestige and role depth matter |
| Community service (with leadership and impact) | Tier 1–4 | Entirely tier-dependent on scope and role |
| General club participation | Tier 4 | Rounds out profile only |

---

#### Depth vs. Breadth: What Does the Data Say?

**Admissions officers overwhelmingly prefer depth over breadth.** This is supported by multiple data sources:

- A 2025 survey of 150+ high-achieving applicants by Pioneer Academics (targeting Ivy League, MIT, Stanford, Duke admissions) found the **optimal number of activities is approximately 4**, with an average of 3.7 among admitted students. Acceptance rates by number of activities:
  | Activities | Acceptance Rate |
  |---|---|
  | 1 | 8% |
  | 2 | 15% |
  | 3 | 25% |
  | **4** | **30% (peak)** |
  | 5 | 25% |
  | 6 | 7% |

  Source: [Forbes — For Elite College Admissions, Fewer Activities May Mean More](https://www.forbes.com/sites/dereknewton/2025/06/16/for-elite-college-admissions-fewer-activities-may-mean-more/)

- **Optimal weekly hours:** 4–8 hours per week across all activities. Students dedicating over 10 hours/week saw a 10% decline in admissions rates. Students under 4 hours/week were nearly three times less likely to be admitted.

- [Empowerly / Veridian College Prep](https://empowerly.com/applications/course-rigor-activity-depth/) summarize admissions officers as evaluating three pillars of activity depth: **Longevity** (multi-year participation), **Commitment** (hours, progression within the activity), and **Impact** (what changed because they were there).

- [Spark Admissions](https://www.sparkadmissions.com/blog/what-do-admissions-officers-look-for-in-extracurriculars/) states: "Contemporary admissions officers have shifted toward valuing depth over breadth, quality over quantity, and authentic engagement over superficial participation."

- A University of Delaware study ([Phys.org, 2025](https://phys.org/news/2025-04-extracurricular-college-admissions-access.html)) found that some institutions are already considering reducing the max activities from 10 to 4–5 to force focus on quality; Lafayette College has already reduced its review to 6 activities.

---

#### Research, Publications, Internships, and Entrepreneurship

**Research & Publications:**
- "Evidence of substantial scholarship" can elevate an applicant at Harvard, per [ProPublica's investigation (2023)](https://www.propublica.org/article/college-high-school-research-peer-review-publications).
- Penn's admissions dean noted that nearly one-third of accepted students "engaged in academic research" in high school.
- However, the explosion of pay-to-publish high school "journals" has made admissions officers skeptical. As one longtime Ivy League admissions officer stated: "The number of outfits doing that has trebled or quadrupled in the past few years. A sophomore in high school is not going to be doing high-level neuroscience. And yet, a very high number of kids are including this."
- **True research (Tier 1):** First-authored paper in a legitimate peer-reviewed journal, RSI, PRIMES, or similar nationally selective programs.
- **Inflated research (not Tier 1):** Preprint/predatory journal publications from paid mentorship programs.

**Internships:**
- Paid internships at recognizable companies or research institutions signal career-readiness and real-world competence.
- Depth matters: a semester-long internship at a hospital emergency department > a one-week shadowing experience.
- For pre-professional majors (pre-med, engineering, business), a relevant internship can function as a Tier 2–3 activity.

**Entrepreneurship:**
- Admissions officers "highly prize student entrepreneurs" per [Ivy Coach](https://www.ivycoach.com/the-ivy-coach-blog/college-admissions/entrepreneurs-and-college-admission/).
- Focus on the *story* (mission, problem-solving, building from scratch), not financial metrics.
- A business with verifiable revenue, media coverage, or community impact reaches Tier 1–2 territory.
- Avoid clichés (e.g., "buy one, give one" charity models).

---

### 2. Community Service Statistics

#### What Harvard's Freshman Surveys Reveal

**Harvard Class of 2027 (most recent):**
- **>70%** of freshmen said they had volunteered in high school ([Harvard Crimson, 2023](https://features.thecrimson.com/2023/freshman-survey/academics-narrative/))
- Athletics: **53%** participated
- Student government: **40%** participated
- Student body president: **23%** had served in that role

**Harvard Class of 2024:**
- Community service was the most popular activity: **81.3%** of respondents had engaged in it
- Athletics: **61.7%**
- Student government: **40.2%**
- Music/band: **38.6%**
- ([Harvard Crimson, Class of 2024 Freshman Survey](https://features.thecrimson.com/2020/freshman-survey/academics-narrative/))

**Key takeaway:** The vast majority (~70-80%) of Harvard admits did community service, but it was an **additive** factor, not a threshold requirement. Many Harvard admits had zero formal service hours.

---

#### Hours Data and the Diminishing Returns Question

- A [2018 survey of 264 U.S. college admissions officers by IESD for x2VOL](https://www.forbes.com/sites/dereknewton/2018/04/05/new-survey-shows-value-of-community-service-in-college-admissions/) found:
  - **58%** agreed that "a student's community service experience has a positive impact on his or her acceptance"
  - **53%** said it serves as a tie-breaker "assuming all factors are equal"
  - At **private colleges**: this rose to **61%**

- An [OpenAdmits analysis (2025)](https://openadmits.com/blog/role-of-social-impact-and-volunteering-in-ivy-league-admissions) of Ivy League admissions patterns found:
  - Individuals who volunteered regularly (**300+ hours across 2+ years**) had acceptance rates **~20% higher** than those with irregular service
  - **68%** of accepted students engaged in multi-year service initiatives rather than one-time events
  - **74%** held a leadership or organizational role in their service

- **No hard minimum hour threshold exists.** College Confidential discussions and expert counselors ([Shemmassian Consulting](https://www.shemmassianconsulting.com/blog/ivy-league-colleges-and-community-service), [College Coach's Ian Fisher](https://blog.getintocollege.com/colleges-dont-care-about-community-service-college-coach-blog/)) consistently note: "Meaningful community service isn't measured in hours."

- **Practical guideline from consultants:** 100–200 hours over multiple years in 1–2 focused, consistent initiatives is far more valuable than 300+ hours spread across many disconnected one-off events.

---

#### Quality vs. Quantity: The Correct Framework

Per [IvyWise](https://www.ivywise.com/blog/does-community-service-matter-in-the-college-admissions-process/) and [Shemmassian Consulting](https://www.shemmassianconsulting.com/blog/ivy-league-colleges-and-community-service):

**What admissions officers actually look for:**
1. **Alignment with stated interests** — Service that connects to a student's intended major or career path (e.g., hospital volunteering for pre-med, tutoring for aspiring educators)
2. **Multi-year depth** — One or two consistent service activities across grades 9–12 > joining many clubs in junior year
3. **Leadership and measurable impact** — Did the student take on increasing responsibility? Did they found a program, lead volunteers, or create measurable outcomes?
4. **Authenticity** — Required/mandatory service is discounted significantly; admissions officers can detect "resume padding"

**Why admissions officers value community service (from the 2018 survey, ranked):**
1. Indicator that the student is likely to be active in student social life outside the classroom
2. Indicator that the student is likely to contribute to the school's mission
3. Indicator that the student shares the school's values

**Diminishing returns:** There is a point of diminishing returns. A student with 500 hours logged at one community service organization will not receive meaningfully more credit than one with 250 meaningful hours. The *story* of what the student did, learned, and how they grew matters more than raw hour counts.

---

### 3. "Spike" vs. "Well-Rounded" Application Strategy

#### What Is a "Spike"?

A "spike" in college admissions refers to a student who has demonstrated **deep expertise, exceptional achievement, or passionate specialization in one particular area**, as opposed to broad, surface-level participation in many activities. The spike becomes the defining feature of the applicant's profile — the thing they will be remembered for after the file is closed.

**Examples of spikes:**
- STEM: Robotics team captain + science research intern + USAMO qualifier + coding projects → "the engineer"
- Arts: Lead roles in theater + principal chair orchestra + YoungArts finalist + summer intensive → "the performer"
- Service/Advocacy: Founded nonprofit + press coverage + 3-year leadership + 500 beneficiaries → "the change agent"

---

#### What Research and Admissions Officers Say

The consensus from MIT, Stanford, Harvard, and other highly selective institutions has **shifted decisively toward the spike model** — but with nuance:

**Harvard:** Builds a "mosaic of talents" — they want a well-rounded *class*, not a well-rounded individual student. Former dean William Fitzsimmons: "If the class already had enough quarterbacks, they'd use remaining spots for different strengths." They admit published novelists, math olympiad winners, Olympic-level athletes, and social entrepreneurs — each exceptional at *one thing*.

**Stanford:** Values innovation and entrepreneurial thinking. Former Stanford admissions officer Grace Kim: "Think of it like a dinner party — each guest brings a unique flavor." They favor students who have **created something new or solved problems creatively**.

**MIT:** Despite being tech-focused, MIT explicitly rejects the narrow STEM-only stereotype. They "love passionate techies who also engage with arts, humanities, or social causes" — the "T-shaped" profile. MIT's website explicitly states they look for students who are "doing something interesting with the things they know."

**Princeton:** Former admissions dean Fred Hargadon: "If we need a quarterback and we've admitted two early, we won't take a third."

**CollegeVine:** "Highly selective colleges tend to favor students who have displayed exceptional leadership, initiative, and impact in a few activities (the 'spike' approach), rather than those who participate in a wide range of activities but without significant depth (the 'well-rounded' approach)."

---

#### Has the Trend Shifted?

Yes — the trend has been moving toward "spike" for the past 25+ years, but has accelerated recently:

| Era | Admissions Philosophy |
|---|---|
| Pre-1990s | "Whole man" — well-rounded character, athletics, legacy, broad achievement |
| 1990s–2000s | "Best class" — specialists in context; "depth over breadth" emerges |
| 2010s–Present | "Pointy excellence" — passionate specialists who together form a well-rounded class |

The **application explosion** is the key driver: with tens of thousands of applicants carrying 4.0 GPAs, varsity letters, and student government experience, well-rounded profiles no longer differentiate. Distinctive, deep achievements became the necessary differentiator.

Source: [Cosmic NYC / Admissions Consulting (2025)](https://www.cosmic.nyc/blog/parents-and-college-admissions-y3yns-m9zlr)

---

#### How Different School Types Weight This

| School Type | Preference | Why |
|---|---|---|
| **Ivy League + MIT/Stanford/Caltech** | Strong spike + academic competence | Building a mosaic class; needs specialists for labs, orchestras, teams, etc. |
| **Liberal Arts Colleges (Amherst, Williams, Swarthmore)** | Both — values intellectual curiosity | LAC ethos supports broad exploration; some value the well-rounded scholar-citizen |
| **Large Public Universities (Michigan, UNC, UCLA)** | GPA/test scores primary; ECs secondary | Scale of review limits holistic assessment; varies by major and honors programs |
| **Top Engineering Schools (Harvey Mudd, Carnegie Mellon)** | STEM spike + math/science rigor | Program-specific spike highly valued |
| **Schools ranked 40–100** | More flexibility; academics primary | As PrepScholar notes, "if you're mediocre academically, extracurriculars won't carry you" |

**Key nuance:** IvyWise counselors summarize the ideal profile as the **"T-shaped student"**:
- **Vertical line:** Deep expertise, exceptional achievement, or passion in one specific area
- **Horizontal line:** Broad academic competence and some engagement across other domains

A brilliant scientist who also plays jazz is more compelling than one who mediocrely participates in ten different clubs.

Source: [IvyWise — The Myth of the Well-Rounded Student](https://www.ivywise.com/ivywise-knowledgebase/the-myth-of-the-well-rounded-student-colleges-want-specialists/)

---

### 4. How Colleges Verify Extracurricular Claims

#### Do Colleges Actually Verify?

**Yes — but not systematically for every application.** Verification is triggered by unusualness, inconsistency, or high stakes.

The most comprehensive source: [Spark Admissions, 2025](https://www.sparkadmissions.com/blog/do-colleges-verify-your-extracurriculars/) and a former application reader's YouTube Q&A.

---

#### Primary Verification Methods

**1. Letters of Recommendation and School Counselor Reports**
The most reliable and common check. Counselors and teachers routinely mention major activities, leadership roles, and achievements. If a student claims to be president of the debate team but the counselor's report doesn't mention it — and all the student's classmates who are applying to the same school have it in their counselor letter — it will be noticed.

**2. Internal Consistency Review**
Admissions officers are "highly trained at spotting inconsistencies." If a student claims to have founded a national nonprofit while maintaining a 4.5 GPA, competing in five varsity sports, working a part-time job, and publishing three research papers — the total time commitment may be physically implausible. Red flags:
- Activities mentioned in the activities list but absent from essays
- Contradictory details between the Common App and supplemental essays
- A "spike" activity that no recommender mentions

**3. Online Search and Social Media**
A former application reader described his process: "I go to the internet — it's easier than calling a school counselor who has 150 other students to deal with." For unusual or extraordinary claims (national competition winner, major nonprofit founder, six-figure business), a Google search will typically either confirm or cast doubt within minutes. Instagram, Facebook, and LinkedIn are also checked.

**4. Direct Contact (Rare, High-Stakes Cases)**
In cases where an activity is central to the applicant's story AND seems extraordinary, admissions offices may call school counselors, program supervisors, or coaches. This is more common at Top 50 schools when claims involve large-scale leadership, major fundraising, or external recognition.

**5. UC System Formal Audit (Most Rigorous U.S. Public System)**
The University of California has a formalized process per [UC's official FAQ](https://www.universityofcalifornia.edu/faqs-uc-admissions): "We also select **random applications from the applicant pool each year** for verification of applicants' activities and achievements outside of the classroom through requests for documentation." Failure to document results in denial from all UC campuses. This is the most transparent and systematic verification system in U.S. college admissions.

---

#### What Happens If a Student Is Caught Lying?

The consequences escalate by when the lie is discovered:

| Discovery Timing | Consequence |
|---|---|
| During review (pre-decision) | Outright rejection |
| After admission offer, before enrollment | Admission rescinded |
| After enrollment begins | Expulsion |
| After graduation (rare) | Diploma revoked; financial aid may need to be repaid |

Some schools require students to sign honor pledges certifying the accuracy of all application materials, creating an explicit legal basis for action.

Notable real-world precedent: The Varsity Blues scandal (2019) led Ivy League schools to become significantly more proactive in checking unusual or high-profile extracurriculars.

---

#### Role of Guidance Counselor Reports in Corroboration

The School Report submitted by guidance counselors is a critical cross-check tool. Counselors:
- Describe the student's role in the school community
- Explicitly mention leadership positions, awards, and notable activities
- Provide context about the school's offerings and culture
- Rate the student on attributes including leadership and character

**A mismatch between what a student claims and what the counselor's report implies or omits is a significant red flag.** Admissions officers at selective schools note that counselors often call out students who have exaggerated — sometimes through deliberate omission, which is equally telling.

---

#### Role of Recommendation Letters

Teacher and counselor recommendations serve both as endorsements and as **corroboration signals**. Strong applications have recommendations that *independently confirm* the student's activities and character. Specifically:
- A student claiming to be the captain of the robotics team should have their computer science teacher mention the robotics program
- A student claiming 300+ community service hours for a specific nonprofit should be referenced by an advisor or recommender who observed them in that context
- Published research should be mentioned by a science teacher or research mentor

When strong activities are confirmed from multiple independent sources (activities list + essays + counselor report + recommendation letters), they carry maximum credibility.

---

### 5. Common App Activities Section Format

#### Exact Specifications (Official Common App Guide, 2025)

Source: [Common App Official PDF Resource](https://www.commonapp.org/static/a5d59a915bdc2031e62c468ad35e0de9/Resource_FY_Activities_ENG_2025.06.25_0.pdf) and [Command Education](https://www.commandeducation.com/resource/common-app-activities-list/)

| Field | Character Limit |
|---|---|
| **Number of activities** | Up to **10** |
| **Position / Leadership description** | **50 characters** |
| **Organization name** | **100 characters** |
| **Activity details / description** | **150 characters** |

Additional fields per activity (no character-limit constraints):
- **Activity type** (dropdown — see below)
- **Participation grade levels** (checkboxes: 9, 10, 11, 12, PG)
- **Timing** (During school year / During school break / All year)
- **Hours per week**
- **Weeks per year**
- **"I intend to participate in a similar activity in college"** (Yes/No)

---

#### Complete List of Activity Type Categories

The Common App provides **29 predefined categories** plus one catch-all:

1. Academic
2. Art
3. Athletics: Club
4. Athletics: JV/Varsity
5. Career-Oriented
6. Community Service (Volunteer)
7. Computer/Technology
8. Cultural
9. Dance
10. Debate/Speech
11. Environmental
12. Family Responsibilities
13. Foreign Exchange
14. Internship
15. Journalism/Publication
16. Junior R.O.T.C.
17. LGBT
18. Music: Instrumental
19. Music: Vocal
20. Religious
21. Research
22. Robotics
23. School Spirit
24. Science/Math
25. Social Justice
26. Student Govt./Politics
27. Theater/Drama
28. Work (Paid)
29. Other Club/Activity

**Guidance:** If an activity fits multiple categories, choose the more specific one (e.g., "Math Club" → "Science/Math" rather than "Academic"). "Other Club/Activity" is used when no specific category applies.

Source: [CollegeVine — How to Fill Out the Common App Activities Section](https://blog.collegevine.com/how-to-fill-out-the-common-app-activities-section) and [InGenius Prep Activity List Template](https://ingeniusprep.com/wp-content/uploads/2024/10/Common-App-Activities-List-Template.pdf)

---

#### How to Order Activities

Per the Common App's own instructions: **list activities in order of their importance to the applicant.** This is a key strategic decision.

Best practice guidance from [Shemmassian Academic Consulting](https://www.shemmassianconsulting.com/blog/common-app-activities-section):

1. **Lead with your most impressive and most objectively impactful activities** — ideally Tier 1 or Tier 2.
2. **Place activities most closely related to your intended major near the top** — this creates immediate alignment between your academic interest and your extracurricular commitment.
3. **Group related activities together** — creates thematic depth and demonstrates a "spike" or coherent narrative thread.
4. **Capture favorable attention early** — admissions officers often review the first 2–3 activities with the most attention.

**Example ordering for a STEM-focused applicant:**
1. Research internship (most impressive, major-related)
2. Science Olympiad captain (leadership, major-related)
3. Coding projects / app development (independent work)
4. Math Team co-captain (related)
5. Paid work (shows responsibility)
6. Community service (shows character)
7. Athletic activity (shows balance)
8–10. Other activities

---

#### Additional Information Section

The Common App's **Additional Information** section (650 characters, but expandable with additional text) allows students to:
- Expand on a major activity that cannot be adequately described in 150 characters
- Explain unusual circumstances (school didn't offer certain activities, family obligations limited participation)
- Provide context for any significant gaps or irregularities
- List more than 10 activities (this section can serve as an overflow for students with more than 10 meaningful activities)

**Strategic use:** This section should not duplicate what's in the activities list. Use it for the one or two activities that most define who you are and where the 150-character limit prevents you from conveying the full scope of your work.

---

### 6. How to Write Effective 150-Character Activity Descriptions

#### The Core Framework: Action + Context + Result

Every strong activity description should contain three elements within 150 characters:
- **Action:** What you specifically did (strong verb)
- **Context:** With whom, for whom, at what scale
- **Result:** What changed or was achieved

Source: [IvyWise — Write Impactful Common App Activity Descriptions](https://www.ivywise.com/ivywise-knowledgebase/impactful-common-app-activity-descriptions/)

---

#### 9 Expert-Validated Best Practices

**1. Start with a strong verb**
Skip passive phrases like "member of" or "helped with." Lead with action: organized, led, created, built, taught, designed, managed, launched, founded, directed, produced, coached, implemented, developed.

**2. Be specific about your role**
Identify ownership and individual contribution, not just the activity itself.

**3. Quantify impact**
Numbers command attention and create credibility. Include: number of people affected, dollar amounts raised, membership growth, frequency, duration, audience size.

**4. Clarify purpose or result**
What changed because you were there? Who benefited? What was the outcome?

**5. Add context if needed**
Not every reader will recognize a program's prestige. If you're 1 of 25 on a state council, say so.

**6. Use fragments, not sentences**
This is a resume, not an essay. Drop "the," "a," "I." Skip periods. Semicolons work well as separators.

**7. Use consistent structure**
Predictable rhythm (Action ; Action ; Result) helps admissions officers absorb information quickly.

**8. Use standard abbreviations only**
Acceptable: "wk" (week), "hrs" (hours), "mgmt" (management), "org" (organization), "K" (thousands), "2x/wk," "%" Common App counts spaces as characters. Avoid abbreviations for local/school-specific entities that readers won't recognize.

**9. Don't repeat position title in the description**
The position field (50 chars) already states your title. Use the 150-character description box entirely for accomplishments, not to restate the role.

---

#### Weak vs. Strong Descriptions: Comparison Table

| Weak | Strong | Why Strong Wins |
|---|---|---|
| "Volunteered at food pantry" | "Distributed food to 100+ families/wk; built volunteer schedules; tracked pantry stock" | Specific role, quantified impact, scope clear |
| "Organized food can drive for local families" | "Collected over 10,000 cans and provided Thanksgiving meals for 500 families in greater Cleveland" | Scale and outcome make it concrete and memorable |
| "As president of the student body, I was responsible for…" | "Implemented school initiatives such as free textbooks for low-income families, liaised with administration, curated meeting agendas" | Omits "I," leads with impact, uses strong verbs |
| "I tutored seventh graders in science" | "Tutor 7th graders to help them master challenging science concepts" | Present tense, fragment, role clear |
| "Worked on school podcast for two years; interviewed guests" | "Produced 20-episode podcast; hosted interviews, edited audio, managed release schedule" | Specifics (20 episodes) + multi-role ownership |
| "Led 5 blood drives" | "Led 5 blood drives (300+ units); recruited 50 volunteers; managed promotion & logistics" | Quantified output + scope of responsibility |
| "Made health graphics" | "Created 3 health infographics; shared by school district to boost vax awareness (10K+ reach)" | Outcome + scale + impact to real audience |
| "At the hospital, I transported patients with physical disabilities on wheelchairs…" | "Transported patients on wheelchairs, provided meals and blankets, assembled gift baskets, attended grand rounds" | Fragment, removes filler "at the hospital I," fits in 150 chars |

Sources: [IvyWise](https://www.ivywise.com/ivywise-knowledgebase/impactful-common-app-activity-descriptions/), [Shemmassian Academic Consulting](https://www.shemmassianconsulting.com/blog/common-app-activities-section), [Dewey Smart](https://www.deweysmart.com/resources/how-to-fill-out-the-common-app-activities-section-with-real-examples)

---

#### Abbreviation Guide

| Acceptable Abbreviations | Notes |
|---|---|
| wk / wkly | week / weekly |
| hrs | hours |
| yr | year |
| avg | average |
| mgmt | management |
| org / orgs | organization/organizations |
| K | thousands (e.g., $3.4K, 10K+ reach) |
| % | percent |
| + | "more than" (100+ families) |
| / | per (2x/wk, 10 hrs/wk) |
| & | and |
| w/ | with |
| b/w or b/t | between |
| govt | government |
| intl | international |
| natl | national |
| NHS | National Honor Society (only after first mention) |
| UN | United Nations |
| STEM, AP, IB | Universally recognized |

**Avoid:** Abbreviating your own school's club or organization names (the reader won't know what "FBHS-RC" means). Avoid overly informal abbreviations like "stdnts" that reduce clarity.

---

#### How to Quantify Impact Within 150 Characters

Framework from [Reddit r/ApplyingToCollege](https://www.reddit.com/r/ApplyingToCollege/comments/15jqpd8/150_characters_per_activity/):

> "Abbreviate everything. Mention raw stats, accolades, community impact, mentorship/leadership positions. Emphasize what YOU did, not what the organization did."

Quantification examples:
- **People:** "Taught 30 students," "Served 500 families," "Managed 15-person team"
- **Growth:** "Grew membership from 8 to 45 members," "Increased donations 40%"
- **Frequency:** "2x/week," "weekly," "52 sessions/yr"
- **Financial:** "$5K raised," "$2.3K for local shelter"
- **Scale of competition:** "1 of 25 statewide," "Top 10 nationally"
- **Output:** "Published 3 articles," "Produced 20 episodes," "Mentored 12 students"

---

### 7. Common App Honors Section

#### Exact Format Specifications

Source: [Expert Admissions](https://expertadmissions.com/how-to-fill-out-the-common-app-honors-section/), [InGenius Prep](https://ingeniusprep.com/blog/common-app-honors-section/), [MeetYourClass](https://www.meetyourclass.com/college-application-checklist/common-app-honors-section-guide)

| Field | Specification |
|---|---|
| **Number of honors allowed** | Up to **5** |
| **Title field** | Up to **100 characters** |
| **Grade level** | Checkboxes: 9, 10, 11, 12, PG |
| **Level of recognition** | School / State or Regional / National / International (check all that apply) |

**Note from Common App instructions:** "If you have received any honors related to your academic achievements beginning with the ninth grade..." — **Middle school honors do not belong here.**

---

#### What Counts as an Honor?

The Common App defines honors broadly as "academic honors." In practice, this encompasses:

**Academic Recognition:**
- National Merit Scholar (Commended, Semifinalist, Finalist)
- AP Scholar (various levels)
- Honor Roll / High Honor Roll (sustained)
- Presidential Scholars Program
- Departmental subject awards

**Competition Awards:**
- Science fair placements (school, regional, state, national levels)
- Math competition medals (AMC, AIME, MATHCOUNTS, ARML)
- Debate tournament awards
- Academic decathlon placements
- Writing/journalism awards

**Merit-Based Scholarships:**
- Any scholarship awarded on academic or achievement merit

**Arts Awards:**
- Scholastic Art & Writing Awards (Gold Key, Silver Key, Honorable Mention)
- YoungArts national finalist
- NFAA recognition

**Leadership/Service Recognition:**
- Presidential Volunteer Service Award
- National Youth Leadership Award (if merit-based/selective)

**Athletic with Academic Component:**
- Scholar-Athlete recognition (not just participation trophies)

---

#### How to Categorize Level of Recognition

The Common App allows you to check **one or more** level boxes:

| Level | Examples |
|---|---|
| **School** | Honor Roll, NHS (despite "National" in name, selection is school-based), departmental awards, school-level science fair |
| **State/Regional** | All-State recognition, state competition placements, regional Scholastic Art & Writing, regional science fair |
| **National** | National Merit, AP Scholar, Presidential Scholars, Regeneron STS, national debate placements |
| **International** | International olympiad qualifications (IBO, IPhO, IMO), YoungArts International recognition |

**Common mistake — National Honor Society:** Despite having "National" in its name, NHS is a **school-level honor**. The selection criteria are set and applied by each individual school chapter. Mark it as "School" only.

**Expert tip from Expert Admissions:** "Choose the highest applicable level that's truthful. When in doubt between two levels, choose the more conservative option. Consider the actual competition pool, not just the organization's reach."

---

#### Strategic Tips for the Honors Section

1. **Group similar awards** to maximize the 5-slot limit. Example: "Scholastic Writing Award: Gold Key ×2 (2022, 2023); Honorable Mention (2021)" counts as one entry but conveys three distinct recognitions.

2. **Select multiple grade levels** for ongoing honors (e.g., Honor Roll in grades 10, 11, 12 — check all three).

3. **Be honest about level.** Admissions officers at highly selective schools know the prestige hierarchy of competitions. Listing a local essay contest as a "national" honor is easily detectable.

4. **Prioritize selectivity.** An honor that only 5 students receive nationally > an honor that 50,000 students receive nationally. If you have more than 5 honors, choose by prestige and selectivity, not just name recognition.

5. **Honors vs. Activities overlap:** If a competition placement also qualifies as a Tier 1–2 extracurricular activity, list it in *both* sections — in Activities as an accomplishment (if the activity itself is the competition team), and in Honors for the specific award. The sections are designed to be used together.

---

### Area 7 Summary Reference Card

| Topic | Key Numbers / Facts |
|---|---|
| Common App activities limit | **10** |
| Activity description character limit | **150 characters** |
| Position/leadership character limit | **50 characters** |
| Organization name character limit | **100 characters** |
| Activity type categories | **29 specific + "Other"** |
| Optimal number of activities (elite schools) | **~4** (average among admitted: 3.7) |
| Optimal weekly hours | **4–8 hours/week** |
| Honors section limit | **5 honors** |
| Honors title character limit | **100 characters** |
| Honors recognition levels | School / State-Regional / National / International |
| Harvard freshmen who did community service | **70–81%** (varies by year) |
| Community service as admissions tie-breaker | **53–61%** of AOs agree (2018 survey) |
| UC system random audit rate | **~10% of applications** |
| Ivy League trend | "Pointy"/spike specialists, not generalists |
| Depth vs. breadth | Depth wins; 2–4 deep activities > 10 shallow ones |

---

### Area 7 Sources

1. [CollegeVine — Breaking Down the 4 Tiers of Extracurricular Activities](https://blog.collegevine.com/breaking-down-the-4-tiers-of-extracurricular-activities)
2. [Inspira Advantage — 4 Tiers of Extracurricular Activities](https://www.inspiraadvantage.com/blog/tiers-of-extracurricular-activities)
3. [PrepWell Academy — How to Audit Your Child's Extracurriculars](https://prepwellacademy.com/how-to-audit-your-child-s-extracurriculars/)
4. [PrepScholar — Extracurricular Strong Students](https://blog.prepscholar.com/extracurricular-strong-students-college-admissions-and-sat-/-act-strategies)
5. [CollegeVine FAQ — What Extracurricular Activities Do Colleges Value Most?](https://www.collegevine.com/faq/118874/what-extracurricular-activities-do-colleges-value-most)
6. [Harvard Crimson — Class of 2027 By the Numbers](https://features.thecrimson.com/2023/freshman-survey/academics-narrative/)
7. [Harvard Crimson — Class of 2024 By the Numbers](https://features.thecrimson.com/2020/freshman-survey/academics-narrative/)
8. [Forbes — New Survey Shows Value of Community Service in College Admissions (2018)](https://www.forbes.com/sites/dereknewton/2018/04/05/new-survey-shows-value-of-community-service-in-college-admissions/)
9. [Forbes — For Elite College Admissions, Fewer Activities May Mean More (2025)](https://www.forbes.com/sites/dereknewton/2025/06/16/for-elite-college-admissions-fewer-activities-may-mean-more/)
10. [OpenAdmits — The Role of Social Impact and Volunteering in Ivy League Admissions (2025)](https://openadmits.com/blog/role-of-social-impact-and-volunteering-in-ivy-league-admissions)
11. [Shemmassian Consulting — Ivy League Colleges and Community Service](https://www.shemmassianconsulting.com/blog/ivy-league-colleges-and-community-service)
12. [IvyWise — How Community Service Can Impact College Admission Chances](https://www.ivywise.com/blog/does-community-service-matter-in-the-college-admissions-process/)
13. [Cosmic NYC — Do Colleges Want Well-Rounded Students? Myth vs. Reality (2025)](https://www.cosmic.nyc/blog/parents-and-college-admissions-y3yns-m9zlr)
14. [IvyWise — The Myth of the Well-Rounded Student](https://www.ivywise.com/ivywise-knowledgebase/the-myth-of-the-well-rounded-student-colleges-want-specialists/)
15. [Spark Admissions — Do Colleges Verify Your Extracurriculars?](https://www.sparkadmissions.com/blog/do-colleges-verify-your-extracurriculars/)
16. [University of California — FAQs on UC Admissions](https://www.universityofcalifornia.edu/faqs-uc-admissions)
17. [Common App Official PDF — Approaching the Activities Section (2025)](https://www.commonapp.org/static/a5d59a915bdc2031e62c468ad35e0de9/Resource_FY_Activities_ENG_2025.06.25_0.pdf)
18. [Shemmassian Academic Consulting — How to Stand Out on the Common App Activities Section](https://www.shemmassianconsulting.com/blog/common-app-activities-section)
19. [IvyWise — Write Impactful Common App Activity Descriptions](https://www.ivywise.com/ivywise-knowledgebase/impactful-common-app-activity-descriptions/)
20. [Expert Admissions — How to Fill Out the Common App Honors Section](https://expertadmissions.com/how-to-fill-out-the-common-app-honors-section/)
21. [ProPublica — The Newest Way to Buy an Advantage in College Admissions (2023)](https://www.propublica.org/article/college-high-school-research-peer-review-publications)
22. [Ivy Coach — Applying to College as a High School Entrepreneur](https://www.ivycoach.com/the-ivy-coach-blog/college-admissions/entrepreneurs-and-college-admission/)
23. [Spark Admissions — What Do Admissions Officers Look for in Extracurriculars? (2025)](https://www.sparkadmissions.com/blog/what-do-admissions-officers-look-for-in-extracurriculars/)
24. [Phys.org — Analyzing Extracurricular Activities in College Admissions Process (2025)](https://phys.org/news/2025-04-extracurricular-college-admissions-access.html)


---

## Area 8: College Counselor Industry Research
*Compiled for a college guidance app aiming to democratize college counseling*
*Research date: April 2026 | Sources: IECA, ASCA, NACAC, HECA, AICEP, IBISWorld, Private Prep, Miami Herald, and others*

---

### 1. Average Cost of Private College Counselors in the US

#### National Average — Summary
The private college counseling market has no uniform pricing. Fees depend heavily on the counselor's credentials, years of experience, geography, and service scope. Families commonly spend **$500–$10,000**, with the industry average comprehensive package sitting around **$6,450–$6,500** as of 2022 (the most recent IECA survey data), reflecting a ~30% increase since 2019.

> **Key anchor figure**: The Independent Educational Consultants Association (IECA) reports the average comprehensive fee (January 2022) was **$6,450**, up ~30% from 2019. National average hourly rate per the same IECA data: **$230/hour**.
> — Source: [Campus Education Consulting citing IECA Summer Training Institute 2024](https://campuseducationconsulting.com/fees-and-payments/)

#### Hourly Rate Range (National)

| Tier | Hourly Rate | Who |
|------|-------------|-----|
| Budget / Entry-level | $85–$150/hr | New practitioners (0–4 years), newer consultants |
| Mid-range | $150–$300/hr | IECs with 5–9 years experience; typical IEC |
| Premium / Experienced | $300–$500/hr | 10+ year veterans, specialized expertise |
| Top-tier (former admissions officers) | $500–$2,500/hr | Former Ivy/highly selective admissions officers, elite firms |
| **National average** | **~$200–$230/hr** | Across all experience levels |

Sources:
- [College Refocus (2025)](https://www.collegerefocus.com/how-much-does-consultant-cost): $150/hr typical entry point
- [CollegePlannerPro](https://www.collegeplannerpro.com/independent-educational-consultants): ~$200/hr average, as low as $85/hr
- [HelloCollege](https://sayhellocollege.com/blog/college-admissions-counselor-cost/): Full-service companies $300–$600/hr, IECs ~$200–$250/hr
- [Private Prep 2025 Report](https://privateprep.com/cost-of-college-admissions-consultants-2025-report/): Hourly consulting $150–$2,500/hr
- [IECA FAQ](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/): Many IECs charge "just under $140/hour" — a floor figure from an older survey

#### Package Pricing by Service Tier

| Service Type | Price Range | Duration | What's Included |
|--------------|-------------|----------|-----------------|
| Budget / Single session | $85–$300 | 1–2 hrs | Essay review or school list only |
| Entry package (senior year only) | $1,500–$3,500 | 6 months | Limited essay + application support |
| Standard junior/senior year package | $4,000–$7,500 | 1–2 years | School list, essays, app strategy, interview prep |
| **Comprehensive junior/senior (typical)** | **$5,000–$10,000** | 2 years | Full guidance: testing, list, essays, apps, FA |
| Multi-year (9th–12th grade) comprehensive | $10,000–$25,000 | 4 years | Full HS strategy + all application support |
| Premium (elite IECs, 10+ years) | $15,000–$150,000 | 2–4 years | High-touch, small caseload |
| Top-tier (former admissions officers) | $18,000–$500,000 | 2–4 years | Exclusive, small caseload |

> The 2018 IECA survey found mean fees ranged from $850 to $10,000, averaging $4,000–$6,000. By 2022 this had risen 30% to an average of $6,450.
> — [Ivy Coach (2026)](https://www.ivycoach.com/the-ivy-coach-blog/college-admissions/fees-college-consultants/)

#### Pricing by Counselor Experience Level (Comprehensive Packages, National Average)

| Counselor Background | National Average (Comprehensive) | Notes |
|---------------------|----------------------------------|-------|
| New practitioners (0–4 years) | $3,500–$18,750 | Baseline tier |
| IECs with 5–9 years experience | $6,500–$37,500 | 15–20% premium |
| IECs with 10+ years | $12,000–$112,500 | 25–30% premium |
| Former highly selective university admissions officers | $18,000–$375,000 | 35–45% premium |

Source: [Private Prep 2025 Cost Report](https://privateprep.com/cost-of-college-admissions-consultants-2025-report/)

#### Top-Tier / Ivy-Focused Counselors
- Former Ivy League/highly selective admissions officers command **35–45% price premiums** over non-admissions-officer IECs.
- Multi-year packages from these counselors range nationally from **$18,000 to $375,000**.
- In the Tri-State area (NY/NJ/CT), this tier charges **$25,000–$500,000** for comprehensive 4-year guidance.
- Firms like Ivy Coach, IvyWise, and Crimson Education operate at the premium end.
- **IECA's note**: The number of IECs in the world charging over $40,000 "can be counted on one hand" — the extreme upper end is a very small segment. Most IECs charge about 1/9th of $40,000 for multi-year packages (~$4,400).
- Source: [IECA FAQ](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/)

#### Essay-Only / A La Carte (National)
- Essay-only hourly rate: **$100–$500/hr**
- Essay-only total cost (10–20 hours): **$1,000–$10,000**
- Source: [Private Prep 2025 Report](https://privateprep.com/cost-of-college-admissions-consultants-2025-report/)

---

### 2. Average Cost in Florida Specifically

#### Florida Pricing Overview
Florida falls within the **Southeast region**, which is generally priced **below the national average**. There is no IECA or NACAC survey isolating Florida specifically, but regional data and local market data provide strong directional signals.

**Key regional data point**: In a 2024 CollegePlannerPro pricing survey, IECs in the **Mid-Atlantic region** reported total cost per student of **$7,180**, versus **$4,784 in the Southeast** — making Southeast pricing approximately **33% below Mid-Atlantic**.
— Source: [CollegePlannerPro Blog (2024)](https://www.collegeplannerpro.com/blog/fee-structure)

#### Estimated Florida Pricing (Derived from Regional Data + Local Market)

| Service | Estimated Florida Range | Notes |
|---------|------------------------|-------|
| Hourly rate | $150–$300/hr | Below national avg of $230 |
| Comprehensive junior/senior package | $4,000–$8,000 | Below national avg of $6,450 |
| Essay-only services | $100–$350/hr | In line with national range |
| Premium/experienced IEC (10+ yrs) | $6,000–$20,000 | Below national equivalents |

#### Florida-Specific Market Examples

**Palm Beach County** (Premier College Advisors):
- Prep centers in the area charge $250/hour
- Individual IEC pricing available at below-market hourly rates
- A la carte packages available (FL Public In-State, Out-of-State, Private school tracks)
- Source: [Premier College Advisors (Palm Beach County)](https://premiercollegeadvisors.com/fees-and-payments/)

**Miami Herald Data** (national context, sourced from Miami-based publication):
- Average hourly: ~$250/hr
- Comprehensive packages: $4,000–$15,000+
- Source: [Miami Herald (Aug 2024)](https://www.miamiherald.com/careers-education/college-admissions-consultant-cost/)

#### Regional Differences Within Florida
No IECA survey data specifically isolates Miami vs. Tampa vs. smaller Florida cities. However, general patterns from national research suggest:

| Florida Region | Pricing Pressure | Expected Range (comprehensive package) |
|----------------|------------------|---------------------------------------|
| Miami-Dade/Broward | Higher (dense, affluent suburbs, high Latin American demand) | $5,000–$10,000+ |
| Palm Beach County | High (wealthy suburban market) | $5,000–$9,000 |
| Orlando / Tampa | Moderate | $4,000–$7,000 |
| Smaller cities (Gainesville, Tallahassee, etc.) | Lower | $2,500–$5,000 |

#### Florida vs. National Average
- **Florida is likely 20–33% below the national average** for equivalent services, based on Southeast regional survey data.
- The national comprehensive package average (~$6,450) compares to an estimated Florida average of approximately **$4,500–$5,500**.
- Premium Florida counselors in major metros (Miami, Boca Raton) may approach national averages for top-tier services.

---

### 3. Number of Independent Educational Consultants (IECs) in the US

#### Total IEC Population (All Types)

| Year | Full-Time IECs | International IECs | Part-Time IECs | Total Estimated |
|------|---------------|-------------------|---------------|-----------------|
| 2010 | ~1,500 | ~150 | ~4,000 | ~5,650 |
| 2015 | ~3,500 | ~350 | ~5,000 | ~8,850 |
| End of 2024 (est.) | **8,500–10,000** | ~1,500 | ~10,000–15,000 | **~20,000–26,500** |

Source: [IECA FAQ Page (updated March 2024)](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/)

#### IECA Membership
- **Total IECA members**: **2,800** member consultants (as of 2024)
- Geographic coverage: from across every state and 27+ nations
- IECA is the **largest professional organization** of independent educational consultants in the world
- Founded: **1976**, based in the Washington, DC region
- Source: [IECA Background Information](https://www.iecaonline.com/news-publications/ieca-news-center/background-information-on-ieca/)

> Note: An older IECA membership value document cited "over 1,500 members." The current figure of 2,800 reflects significant growth.

#### HECA Membership
- **Total HECA members**: **1,000+** professional college admission consultants
- Founded: more than 25 years ago (est. late 1990s), with initial membership of 38
- Geographic coverage: every region of the United States and internationally
- Members collectively serve **more than 40,000 high school seniors annually**
- HECA is the **only professional association devoted exclusively** to independent college admissions consulting (vs. IECA which also covers K-12 school placement and therapeutic programs)
- Annual dues: **$450** (all membership categories, runs March 1–February 28)
- Source: [HECA About Us](https://www.hecalive.org/about-us-nm), [Lumiere Education on HECA](https://www.lumiere-education.com/post/higher-education-consultants-association-heca-what-is-it)

#### NACAC Membership
- **Total NACAC members**: **28,000+** college counseling and admission professionals worldwide
- Includes both school-based counselors and IECs as well as college/university admissions staff
- Source: [NACAC Join Page](https://www.nacacnet.org/membership/join-nacac/)

#### Growth Trends
- IEC field has grown explosively: **~5.7× increase in full-time IECs** from 2010 (1,500) to 2024 (8,500–10,000)
- Demand driver: usage of IECs among high-achieving students rose from **3% → 26%** over roughly a decade (from a Lipman Hearne nationwide study cited by IECA)
- The broader college admissions consulting market reached **$2.9 billion in revenue in 2023** with a projected CAGR of ~1.1% (IBISWorld/Navagant), though other estimates cite faster growth (see Section 8)
- Source: [IECA FAQ](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/)

#### Geographic Distribution
- IECs are concentrated in suburban areas of large coastal cities (Northeast, West Coast, Southeast Florida)
- IECA members exist in nearly every state and 27 nations
- Private counselor density is highest in NYC metro, LA/Bay Area, and South Florida
- Southeast region IECs price ~33% below Mid-Atlantic (suggesting lower density/competition)

---

### 4. Private Counselors vs. School Counselors — What's Different

#### Core Difference in Focus
| Dimension | School Counselor (Public) | Private IEC |
|-----------|---------------------------|-------------|
| Job scope | College counseling + academic scheduling + personal counseling + behavioral issues + social/emotional support + test proctoring + college advising | College counseling only |
| Caseload | ~376 students nationally (2024-25); 600–1,000 in some states | Typically 12–40 students/year |
| Time per student (college) | **38–45 minutes total over 4 years** | **50–100+ hours over engagement period** |
| Time spent on college advising (% of job) | ~20–21% for public school counselors (NACAC data) | 100% |
| Campus visits per year | Very limited; often none | Scores of campus visits annually |
| Financial incentive | Salaried, no conflict of interest | Fee-based; no commission from schools |

Sources:
- [NACAC 2019 State of College Admission (Chapter 4)](https://nacacnet.org/wp-content/uploads/2022/10/soca2019_ch4.pdf): Public school counselors spend 20% of time on postsecondary counseling
- [Avalon Admission Blog](https://www.avalonadmission.com/avalon-admission-blog/how-much-time-will-you-get-with-your-school-counselor): "45 minutes is the amount of time, on average, that college counselors spend with students over the entirety of their four years of high school" (based on NACAC data)
- [Road2College](https://www.road2college.com/should-you-hire-a-private-college-counselor/): "public high school students in the U.S. receive an average of just 38 minutes of college counseling per year, according to the U.S. Department of Education"
- [EAB Survey (2024)](https://eab.com/about/newsroom/press/survey-college-plans-public-versus-private-schools/): Public school counselors spend 75% of time on non-college duties; private school counselors spend 55% on non-college duties

#### Specific Service Comparison

| Service | School Counselor | Private IEC |
|---------|------------------|-------------|
| College list building | Basic guidance; general familiarity | Curated, personalized, based on deep campus knowledge |
| Essay editing | Rarely; maybe 1 pass | Extensive: multiple drafts, all supplements, Common App |
| Application strategy | Minimal | Comprehensive: positioning, narrative, school list balance |
| Interview prep | Rarely | Often included in packages |
| Financial aid guidance | Basic info, FAFSA help | Detailed analysis, award letter comparison, negotiation |
| Summer program guidance | Rarely | Strategic recommendations for profile-building |
| Test prep advice | General guidance | Specific score targets, test timing strategy |
| Campus knowledge | Limited | Firsthand from extensive campus visits (50+ required for IECA membership) |
| 1-on-1 time | 38–45 minutes total (4 years) | 20–100+ hours per student |
| Scholarship search | Basic | More targeted |

#### Time Per Student: The Stark Gap
- **School counselor**: 45 minutes per student over 4 years of high school (NACAC)
- **Private IEC**: 45 minutes is spent on a **single college supplemental essay** — with 100 hours of guidance typical for a comprehensive package
- Sources: [Avalon Admission](https://www.avalonadmission.com/avalon-admission-blog/how-much-time-will-you-get-with-your-school-counselor), [IECA FAQ](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/)

#### What Private IECs Can Do That School Counselors Can't (or Don't Have Time For)
1. **Visit 50+ college campuses per year** — IECA Professional membership requires 50 campus visits in prior 5 years; most IECs visit schools annually to maintain firsthand knowledge
2. **Specialize**: IECs can specialize in gifted students, students with learning differences, athletes, artists, first-gen students, therapeutic placements
3. **Career + interest exploration**: Go deep on learning styles, interests, long-term fit
4. **Negotiate financial aid**: Follow up with schools, compare award letters, advise on appeals
5. **Unlimited availability**: Direct cell/email access vs. scheduled appointment with overworked school counselor
6. **Application narrative strategy**: Shape how a student's story is told across all components holistically

---

### 5. Counselor-to-Student Ratios

#### National Average (2024–25)
- **National average**: **372:1** (students per school counselor), 2024–25 school year
- A 1% improvement over 2023–24 (376:1) and the **lowest ratio since ASCA began tracking in 1986**
- Total: 132,270 school counselors serving 49.3 million students
- Source: [ASCA press release (Feb 2026)](https://www.schoolcounselor.org/getmedia/62807f33-a020-4c4f-ac6f-bf284803fd97/pr_ratios-24-25.pdf), [NAPSA reporting](https://www.napsa.com/acsa-provides-the-latest-school-counselor-to-student-ratio-data/)

#### High School Specifically
- High school student-to-counselor ratio: **195:1 to 224:1** (2024–25)
- This is the **first year high schools met the ASCA-recommended 250:1 ratio** nationally
- Elementary/middle school ratios remain far higher: **571:1 to 694:1**
- Source: [ASCA Data / NAPSA (Feb 2026)](https://www.napsa.com/acsa-provides-the-latest-school-counselor-to-student-ratio-data/)

#### ASCA and NACAC Recommended Ratio
- **Recommended ratio**: **250:1** (students per counselor)
- ASCA has recommended this since **1965**
- As of 2024–25, only **4 states** meet this recommendation: Colorado (247:1), Hawaii (243:1), New Hampshire (186:1), Vermont (172:1)
- Source: [ASCA School Counselor Roles & Ratios](https://www.schoolcounselor.org/about-school-counseling/school-counselor-roles-ratios), [NACAC Support for School Counselors](https://www.nacacnet.org/advocacy/support-for-school-counselors/)

#### Florida Specifically
- **Florida 2023–24**: **432:1** (students per counselor), according to FGCU data
- Florida ranked among the worst states nationally — **73% above the recommended 250:1 ratio**
- Some Florida districts are even higher
- Florida 2015–16 data: 484:1 (5,770 counselors for 2,792,234 students), from CSG South data
- Florida 2024–25 estimate: Based on ASCA PDF data, Florida has approximately 2,859,600 students and 3,486 counselors, producing an extremely high ratio
- Source: [FGCU 360 (July 2025)](https://fgcu360.com/2025/07/29/fgcu-grads-stepping-up-amid-school-counselor-shortages/), [CSG South (2019)](https://csgsouth.org/policies/school-counselor-legislation-in-the-south-2/)

#### Florida by County (Directional — No Precise County-Level ASCA Data Available)
Florida state law does not mandate the same counselor staffing levels. Districts vary significantly:
- Urban districts (Miami-Dade, Broward, Palm Beach) — large, resource-constrained; likely above state average
- Smaller districts — variable, sometimes worse due to fewer total counselors
- Wealthier suburban districts (e.g., Sarasota) may have smaller caseloads

#### How Ratios Affect College Outcomes
- Research shows lower student-to-counselor ratios correlate with:
  - Better standardized test performance
  - Higher attendance and graduation rates
  - Increased likelihood students talk with counselors about college plans
  - Lower discipline infractions
- Students at schools with no counselors (17% of all high schools, serving ~643,700 students) are effectively without any college guidance
- Source: [K-12 Dive (Feb 2026)](https://www.k12dive.com/news/more-students-have-access-to-school-counselors-data-shows/812609/), [ASCA Roles & Ratios page](https://www.schoolcounselor.org/about-school-counseling/school-counselor-roles-ratios)

#### College Advising Specifically (vs. General Counseling Ratio)
- The student-to-**college-counseling** ratio (counting only time devoted to college advising) is even higher
- NACAC 2018–19 data: Average student-to-college-counselor ratio was **309:1** at public secondary schools (overestimates focus as many counselors split duties)
- Public school counselors: only **20–21%** of their time goes to college advising; means effective college guidance ratio is closer to **1,800–2,000:1** on a time-equivalent basis

---

### 6. Professional Organizations and Certifications

#### Is There a License to Practice?
**No.** There is **no state licensing or regulatory body** governing independent educational consultants in any U.S. state. Anyone can call themselves an IEC or college counselor. Professional memberships and credentials are entirely voluntary and self-regulatory.
— Source: [IECA FAQ](https://www.iecaonline.com/news-publications/ieca-news-center/faqs-on-the-independent-educational-consulting-profession/)

---

#### IECA — Independent Educational Consultants Association
- **What it is**: The largest professional organization of IECs in the world. Not-for-profit. Founded 1976.
- **Members**: 2,800 member consultants globally; near-universal U.S. state coverage
- **Headquarters**: Washington, DC region
- **Website**: iecaonline.com
- **Focus**: College, K-12 boarding/day schools, therapeutic programs, graduate school, international placements, summer programs

##### IECA Membership Levels
**Associate Membership** (entry level):
- Bachelor's degree minimum (master's preferred)
- Evidence of educational consulting work
- Professional references
- New consultants starting out

**Professional Membership** (full, highest level):
Requirements include all of the following:
1. **Education**: Master's degree or higher in a relevant field, OR demonstrated combination of training/experience
2. **Experience**: Minimum 3 years in educational placement counseling or admissions, including ≥1 year of independent practice
3. **Campus visits** (prior 5 years): 50 visits for College specialty; 25 visits for School (K-12); 50 for Therapeutic; 25 for LD/Neurodiversity
4. **Students advised** (prior 5 years): 35 students in private practice, OR 50 total (≥10 in private practice)
5. **References**: 3 professional references
6. **Ethics pledge**: Annual signing of IECA's Principles of Good Practice
7. **Dues**: $600 annually for Professional membership
8. **Vetting**: References checked, marketing materials reviewed, transcripts verified

**Specialty designations** (self-selected at Professional level): College, School (K-12), Therapeutic, Graduate School, International, Learning Differences/Neurodiversity

Sources: [IECA Professional Membership Guide](https://www.iecaonline.com/journal-article/how-to-transition-from-associate-to-professional-membership/), [IECA Background Info](https://www.iecaonline.com/news-publications/ieca-news-center/background-information-on-ieca/)

##### IECA Key Ethics Rule
IECA members commit to: avoiding actions that distort or misrepresent the student's record, or that interfere with the college's evaluation process. They receive no commissions from schools. Extensive vetting distinguishes IECA membership from simply self-declaring as an IEC.

---

#### HECA — Higher Education Consultants Association
- **What it is**: The only professional organization devoted **exclusively** to independent college admissions consulting (college-only; not K-12 or therapeutic)
- **Members**: 1,000+ professional college admission consultants from every U.S. region and internationally
- **Founded**: 25+ years ago (late 1990s); grew from 38 initial members
- **Annual dues**: $450 (all membership categories; March 1–February 28 cycle)
- **Reach**: Members serve 40,000+ high school seniors annually
- **Website**: hecalive.org

##### HECA Membership Requirements (eligibility):
Must meet ONE of the following:
1. Bachelor's degree or higher + ≥2 years as educational consultant, OR ≥2 years as high school counselor + ≥1 year as educational consultant, having served ≥10 students
2. Bachelor's degree + completion of an approved certificate program (UCLA College Counseling Certificate, UC Irvine IEC Certificate, UC Riverside College Admissions Counseling Certificate, or UC Berkeley Certificate in College Admissions and Career Planning)
3. ≥1 college conference attendance in last 18 months + commitment to complete 20 college visits in first 2 years of membership

Sources: [HECA About Us](https://www.hecalive.org/about-us-nm), [Lumiere Education on HECA](https://www.lumiere-education.com/post/higher-education-consultants-association-heca-what-is-it)

**HECA vs. IECA**: IECA is larger (2,800 vs. 1,000+) and broader (covers K-12, therapeutic, graduate). HECA is exclusively focused on college admissions consulting for high school students.

---

#### NACAC — National Association for College Admission Counseling
- **What it is**: The largest membership body in the field; represents both school-based counselors AND college/university admissions staff AND IECs
- **Members**: 28,000+ professionals worldwide
- **Founded**: 1937
- **Focus**: Ethical standards for the college admissions process; advocacy for school counseling funding; professional development
- **Website**: nacacnet.org

##### NACAC IEC Membership Requirements (Independent Educational Consultants):
To join as an IEC member, one of the following must be met:
- Active HECA membership or IECA Professional membership (with proof), OR
- Completion of a practicum-based counseling program from a member-eligible institution + NACAC member recommendation letter, OR
- 2 years of experience as educational consultant/counselor OR bachelor's degree + 2 years of college admission counseling experience + NACAC member recommendation letter

Source: [NACAC What to Know Before You Apply](https://www.nacacnet.org/membership/what-to-know-before-you-apply/)

---

#### CEP — Certified Educational Planner
- **Issuing body**: American Institute of Certified Educational Planners (AICEP)
- **What it is**: The **highest professional credential** available to educational consultants. A board-certifying designation that requires passing a rigorous online proctored assessment
- **Eligible professionals**: IECs (college, K-12, therapeutic tracks) and school-based college counselors
- **Website**: aicep.org

##### CEP Initial Requirements:
1. Master's degree or higher in a relevant field (or extensive comparable experience including certificate programs)
2. Substantial professional experience — typically **4–5 years**
3. 3 professional references attesting to experience and expertise
4. 30 evaluative campus/site visits in the past 5 years
5. Documented continuing professional development hours
6. Professional commitment through association membership and leadership
7. Contribution through mentoring, speaking, articles, volunteer work
8. Pass a rigorous board-certifying online assessment (case study–based)
9. Pledge adherence to AICEP Principles of Good Practice

##### CEP Recertification (every 5 years):
- Minimum 70 evaluative visits to appropriate educational institutions
- Minimum 70 hours of continuing professional development
- Continued adherence to AICEP Principles of Good Practice

Sources: [AICEP About](https://www.aicep.org/page-18176), [CEP Requirements](https://www.aicep.org/page-18200), [CEP Standards](https://www.aicep.org/cep-standards)

> The CEP is selective: UC Berkeley Extension notes that one of their instructors is "one of only 37 Certified Educational Planners in California" — indicating the credential is rare even in major states.

---

#### Training Programs to Become a College Counselor

| Program | Institution | Format | Duration | Notes |
|---------|-------------|--------|----------|-------|
| College Counseling Certificate | UCLA Extension | 100% online | 1–2 years | Open to anyone; no eligibility requirements; widely accepted by HECA, NACAC |
| Certificate in College Admissions and Career Planning | UC Berkeley Extension | Online | 2 semesters | Requires master's in counseling or social work for some courses |
| Independent Educational Consultant Certificate | UC Irvine | Online | Variable | Accepted for HECA membership |
| College Admissions Counseling Certificate | UC Riverside | Online | Variable | Accepted for HECA membership |
| IECA Summer Training Institute | IECA | In-person intensive | 1 week | Annual event; industry-standard training |

Sources: [UCLA Extension review (Lumiere Education)](https://www.lumiere-education.com/post/ucla-s-college-counseling-credential-our-review), [UC Berkeley Extension](https://extension.berkeley.edu/public/category/courseCategoryCertificateProfile.do?method=load&certificateId=92644480)

---

### 7. Pricing Models

#### Overview of Pricing Model Types

##### 1. Hourly Billing
- **Typical range**: $85–$500/hr for most IECs; $500–$2,500/hr for elite tier
- **Best for**: Families needing targeted help (one area: essay only, school list only, financial aid strategy)
- **Pros**: Pay only for what you need; lower upfront commitment
- **Cons**: Can be harder to budget; total cost can exceed package pricing if engagement grows
- **National average hourly**: ~$200–$230/hr

##### 2. Comprehensive Package (Most Common)
- **Typical range**: $4,000–$10,000 for junior/senior year; $10,000–$25,000 for 9th–12th grade
- **What's included** (standard comprehensive package):
  - Initial evaluation and assessment
  - College list building (curated, personalized)
  - Testing strategy and timing guidance
  - Summer program guidance
  - Extracurricular activity planning
  - Essay brainstorming, drafting, and editing (all components)
  - Application review
  - Interview preparation
  - Financial aid guidance
  - Waitlist strategy
  - Decision-making support

**Example (A+ College Consulting)**:
- "Cum Laude" Package: 20 hours at $300/hr = $6,000
- "Magna Cum Laude" Package: 30 hours at $250/hr = $7,500
- Source: [A+ College Consulting Services](https://www.apluscollegeconsult.com/services-and-fees.html)

##### 3. A La Carte Services
- Essay review only: $100–$500/hr (or flat fee per essay: $200–$800/essay)
- School list consultation only: $300–$1,500 flat
- Interview prep only: $150–$400/session
- Financial aid consultation: $200–$500/hr
- Single consultation: $150–$400 flat

##### 4. Retainer / Annual Access Fee Model
- Some IECs charge an **annual access fee** as a base, then bill hourly for services
- Example (Weinstein Educational Consulting):
  - Initial consultation: $250
  - Annual access fee: $2,500 (required to use services)
  - Ongoing consulting: $250/hr
  - Full-service college package: $7,500 flat
  - Full-service with additional support: $20,000/year
- This model ensures counselor availability without a large upfront package payment
- Source: [Weinstein Educational Consulting](https://www.wec.education/services)

##### 5. Group Coaching / Workshops
- **Typical range**: $250–$2,000 for a series
- Far less personalized; lower-cost entry point
- Growing in popularity as scalable model
- Source: [College Refocus](https://www.collegerefocus.com/how-much-does-consultant-cost), [College Journey AI](https://collegejourney.ai/blog/college-prep/college-admission-counselor-costs)

##### 6. Sliding Scale / Pro Bono
- **Availability**: Limited but growing
- Most professional IECs do not publicly advertise sliding scale; some reserve pro bono slots
- **Examples of pro bono programs**:
  - **IvyWise Scholars**: Free full-service counseling for students with ≥3.5 GPA and household income <$75,000
  - **The College Sage**: Free counseling for Pell-eligible students; has served 150+ students annually for nearly 10 years
  - **Matriculate**: Free 1:1 college advising for low-income/first-generation students (non-profit)
- Sources: [IvyWise Scholars](https://www.ivywise.com/about-ivywise/ivywise-gives-back/ivywise-scholars/), [College Sage](https://www.thecollegesage.com/pro-bono-services-offered)
- HECA notes that its members "actively assist low-income students through pro-bono advice and volunteer service to non-profit organizations and local schools"

##### 7. Virtual vs. In-Person Pricing
- **Virtual counseling**: Typically **$75–$150/hr** at the lower end; allows access to counselors nationwide
- **In-person counseling**: Typically **$150–$300/hr**, reflecting overhead and travel costs
- Virtual is generally **10–30% less expensive** than equivalent in-person service
- Post-COVID, the vast majority of counseling has shifted to virtual/hybrid; most IECs now offer full virtual packages at no price difference
- Sources: [College Journey AI](https://collegejourney.ai/blog/college-prep/college-admission-counselor-costs), [CollegePlannerPro blog](https://www.collegeplannerpro.com/blog/fee-structure)

#### Payment Structure Options

| Payment Structure | Discount/Premium | Notes |
|-------------------|------------------|-------|
| Full payment upfront | 5–10% discount | Most favorable for client |
| Two-payment plan | 3–5% premium | 50% upfront, 50% at midpoint |
| Monthly payment plan | 8–12% premium | 12–24 monthly installments |
| Rush services (starting senior year) | 40–60% premium | Compressed timeline fees |

Source: [Private Prep 2025 Report](https://privateprep.com/cost-of-college-admissions-consultants-2025-report/)

---

### 8. Industry Trends

#### Is the Industry Growing?

**Yes — significantly.** Multiple estimates confirm consistent growth:

| Source | Market Size (US/Global) | Year | CAGR Estimate |
|--------|------------------------|------|---------------|
| IBISWorld / Navagant | $2.9B (US, 2023) | 2023 | 1.1% through 2028 |
| Growth Market Reports | $3.1B (global, 2024) | 2024 | 7.9% through 2033 |
| Market Intelo | $2.3B (global, 2024) | 2024 | 12.8% through 2033 |
| College Planning Apps (sub-segment) | $148M (global, 2025) | 2025 | 8.2% through 2033 |

Sources: [Navagant Industry Report Aug 2024](https://navagant.com/wp-content/uploads/2024/09/Education-Consulting-Industry-Report_Aug-2024.pdf), [Growth Market Reports](https://growthmarketreports.com/report/college-admissions-consulting-market), [Market Intelo](https://marketintelo.com/report/college-admissions-consulting-market), [Market Report Analytics](https://www.marketreportanalytics.com/reports/college-planning-apps-75392)

**Key growth driver**: Acceptance rates at elite institutions dropped from **31% (2002) → 10% (2022)** while the number of applications **tripled** in the same period. This has dramatically increased demand for professional guidance.

**IEC population growth**: Full-time IECs grew from 1,500 (2010) → 8,500–10,000 (2024), a **~5.7× increase in 14 years**.

#### Impact of COVID on Virtual Counseling Adoption
- COVID-19 forced rapid shift to virtual counseling (2020)
- Post-pandemic, **virtual counseling became the dominant delivery model** — most IECs now operate primarily or entirely online
- This expanded the addressable market: families anywhere in the U.S. can access premium counselors previously only available to local families
- The pandemic caused **college enrollment decline** (2020–2022) but pent-up demand drove record M&A activity in 2021 (61 transactions in education consulting space, per Navagant)
- Source: [Navagant Industry Report](https://navagant.com/wp-content/uploads/2024/09/Education-Consulting-Industry-Report_Aug-2024.pdf)

#### AI and Technology Disruption
- AI is actively entering college counseling but has not displaced human counselors
- Key AI use cases being adopted:
  - Answering routine procedural questions (FAFSA, deadlines, testing)
  - College matching and recommendation algorithms
  - Essay brainstorming tools
  - Application tracking and progress monitoring
- **Nearly 50% of students already using generative AI** on their own to navigate college applications (EAB survey, Feb 2026)
- School counselors are cautious: **fewer than 40%** see AI as a way to provide services directly to students (ASCA/Ball State survey)
- Key quote from NACAC CEO Angel Pérez: "As the technology grows and gets stronger, counselors can outsource the basic information that students need and focus on the human aspects"
- **DreamCollege.ai** (named "College Admissions Counseling Tool of the Year" by 2026 Worldwide EdTech Awards) announced School Edition in April 2026
- Source: [Hechinger Report (March 2026)](https://hechingerreport.org/ai-educators-college-counselors/), [DreamCollege.ai Press Release (April 2026)](https://www.innovationopenlab.com/news-biz/65242/schools-turn-to-human-ai-for-personalized-college-guidance-dreamcollegeai-expands-school-edition.html)

#### Major Competitor Platforms and Apps

##### School-Based Platforms (B2B, Sell to Schools/Districts)
| Platform | Market Position | Key Stats | Notes |
|----------|-----------------|-----------|-------|
| **Naviance** (PowerSchool) | Market leader | 8M+ students; 35% of U.S. high schools | Acquired by PowerSchool 2021; used by 40% of high schools (older stat); scattergrams, Common App integration |
| **Scoir** | Challenger | ~12% market share; growing 40–50%/yr | Free to students; modern UI; personalized financial aid estimates |
| **MaiaLearning** | Challenger | Adding 150–200 high schools/year; 1,000+ schools | Career exploration + college planning; less expensive than Naviance |
| **Cialfo** | International focus | Custom pricing | Strong in Asia-Pacific; direct college application submission |
| **BridgeU** | Global/International | Custom pricing | International university matching |

Sources: [Inside Higher Ed (March 2023)](https://www.insidehighered.com/news/admissions/traditional-age/2023/03/12/companies-offer-new-competition-naviance), [PNAS research on Naviance](https://www.pnas.org/doi/10.1073/pnas.2306017120), [Business Wire on Naviance (July 2025)](https://www.businesswire.com/news/home/20250722073696/en/PowerSchool-Unveils-Major-Enhancements-to-Naviance-for-the-2025-2026-School-Year)

##### Consumer-Facing Platforms (Direct to Students/Families)
| Platform | Model | Key Stats | Notes |
|----------|-------|-----------|-------|
| **CollegeVine** | Freemium + premium | $30.7M raised (Series B $24M, 2019); est. $15.3M ARR | Pivoted in 2024 to AI-driven recruitment network; connects students with 400+ partner colleges |
| **The Princeton Review** | Test prep + admissions | Major player | Tutoring, test prep, college counseling packages |
| **Kaplan** | Test prep + admissions | Major player | Broad test prep + college advising |
| **Crimson Education** | Premium counseling | Global; premium pricing | New Zealand-founded; Ivy-focused; data-driven |
| **IvyWise** | Premium counseling | Former admissions officers | Top-tier pricing; Ivy-focused |
| **College Guidance Network** | AI + human hybrid | Private | Co-founded after CEO's son got only 1 hr/year with counselor |

Sources: [CBInsights on CollegeVine](https://www.cbinsights.com/company/collegevine/financials), [CollegeVine marketing strategy](https://businessmodelcanvastemplate.com/blogs/marketing-strategy/collegevine-marketing-strategy), [Growth Market Reports](https://growthmarketreports.com/report/college-admissions-consulting-market)

##### IEC Practice Management Tools (B2B, Sell to Counselors)
| Platform | Price | Notes |
|----------|-------|-------|
| CounselMore | From $50/month | Most established; college search, app tracking, scheduling |
| CollegePlannerPro | From $65/month | IEC-focused; robust research tools |
| GetCollegeCounsel | From $99/month | Newer entrant; team collaboration |
| GuidedPath | Custom | Test prep resources + financial aid tools |
| edVIZE | Custom (AI-driven) | AI-powered college match |

Source: [Lumiere Education: 10 College Counseling Software](https://www.lumiere-education.com/post/10-college-counseling-software-you-should-know-about)

#### Market Context for a Democratizing App
- **The access gap is vast**: 17% of high schools have zero school counselors; the national average is 372 students per counselor — 49% worse than the 250:1 ASCA recommendation. Florida's ratio (432:1 in 2023–24) is even more severe.
- **Usage of private counselors is growing**: 26% of high-achieving students now use IECs, up from just 3% a decade ago (per Lipman Hearne study)
- **Typical private counselor is out of reach**: $6,450 average comprehensive package; $200–$230/hr average rate — effectively inaccessible for the majority of families (IECA's typical client has $75,000–$100,000 household income)
- **AI is the emerging democratization lever**: Platforms like DreamCollege.ai, EVA (College Guidance Network), and CounselorGPT are building AI tools specifically designed to deliver personalized, scalable college guidance without the $6,000–$10,000 price tag
- **The market is young and fragmented**: No single app has captured the consumer market for democratized college counseling. The college planning app sub-segment is valued at ~$148M (2025) and growing at 8.2% CAGR — significant white space exists.

---

### Area 8 Summary Data Table

| Metric | Figure | Source |
|--------|--------|--------|
| National avg hourly rate (IEC) | $200–$230/hr | IECA / Campus Education Consulting 2024 |
| National avg comprehensive package | $6,450 (2022 avg, up 30% since 2019) | IECA Summer Training Institute |
| Typical junior/senior package range | $4,000–$10,000 | Multiple sources |
| Top-tier (former admissions officers) | $18,000–$375,000 (national); up to $500,000 | Private Prep 2025 |
| Florida estimated comprehensive package | ~$4,500–$5,500 | Regional data (Southeast avg $4,784 per CoPlannerPro) |
| Florida hourly rate (Palm Beach example) | $250/hr | Premier College Advisors |
| Total full-time IECs in US (2024 est.) | 8,500–10,000 | IECA FAQ |
| Total IECs including part-time (2024 est.) | 20,000–26,500 | IECA FAQ |
| IECA members | 2,800 | IECA Background 2024 |
| HECA members | 1,000+ | HECA About Us |
| NACAC members | 28,000+ | NACAC website |
| National counselor:student ratio (2024–25) | 372:1 | ASCA (Feb 2026 release) |
| ASCA recommended ratio | 250:1 | ASCA (since 1965) |
| Florida counselor:student ratio (2023–24) | 432:1 | FGCU 360 citing ASCA |
| Avg time school counselor spends on student (college) | 38–45 minutes (entire 4 years) | NACAC / U.S. Dept. of Education |
| % time public school counselors spend on college counseling | 20–21% | NACAC 2019 State of College Admission |
| % of high-achieving students using IECs | 26% (up from 3% a decade ago) | Lipman Hearne study via IECA |
| College admissions consulting market size (US, 2023) | ~$2.9B | IBISWorld / Navagant |
| College admissions consulting global market (2024) | $2.3B–$3.1B | Various market research |
| Projected CAGR | 7.9%–12.8% through 2033 | Growth Market Reports / Market Intelo |
| Naviance high school penetration | 35–40% of US high schools; 8M+ students | PowerSchool (July 2025) |
| CollegeVine total funding | $30.7M (Series B 2019) | CBInsights |
| High schools with no counselor at all | ~17% (643,700 students) | U.S. Dept. of Education via ASCA |

*Research compiled April 2026. All figures should be verified against primary sources linked above before use in product materials or investor presentations. IECA pricing data reflects 2022 survey; 2025/2026 figures may reflect further 10–15% increases. Florida-specific private counselor pricing lacks dedicated survey data and is derived from regional benchmarks.*


---

## Data Architecture for Ladder App

*This section synthesizes findings from Areas 1 & 2 into a clear technical roadmap for building the Ladder college guidance database.*

---

### Overview

Building a comprehensive, accurate, and current database for ~4,000 U.S. colleges requires a **five-layer data architecture**. No single source covers all required fields. Free government APIs provide the institutional backbone; paid licensing fills CDS-aligned application fields; specialized free databases cover testing policy; web-collected lists handle platform routing; and direct school-by-school collection is necessary for enrollment-process data that exists nowhere in bulk form.

The architecture below maps each data requirement to its optimal source, access method, cost, and update strategy.

---

### Layer 1: Free Government Data Foundation

**Primary Sources:**
- [College Scorecard API](https://collegescorecard.ed.gov/data/) — `https://api.data.gov/ed/collegescorecard/v1/schools`
- [Urban Institute Education Data API (IPEDS)](https://educationdata.urban.org/documentation/) — `https://educationdata.urban.org/api/v1/`

**Access:** Free REST APIs (College Scorecard requires free API key via api.data.gov; Urban Institute is completely open, no auth required)

**What this layer provides:**
- **Master institution list**: ~7,000 Title IV-participating institutions with UNITID/OPEID identifiers
- **Core institutional attributes**: Name, state, city, ZIP, location (lat/lon), institutional type (public/private/for-profit), ownership, Carnegie classification, main campus flag, accreditor
- **Admissions statistics**: Overall acceptance rate, SAT 25th/50th/75th percentile (EBRW + Math), ACT 25th/50th/75th percentile (composite, math, English, writing, science), number applied/admitted/enrolled
- **Cost data**: In-state tuition, out-of-state tuition, room & board, net price by income bracket (5 brackets)
- **Outcomes**: Graduation/completion rates, post-graduation earnings
- **Aid**: Pell Grant rate
- **Coarse testing policy**: IPEDS `reqt_test_scores` field (required/recommended/considered/not required) — NOTE: lags by 1–2 years; insufficient alone for testing policy field

**Key API calls:**
```
# College Scorecard — All schools with core fields (paginated 100/call):
https://api.data.gov/ed/collegescorecard/v1/schools?api_key=KEY
  &fields=id,school.name,school.state,school.city,school.school_url,
  school.ownership,school.locale,school.carnegie_basic,
  latest.admissions.admission_rate.overall,
  latest.admissions.sat_scores.average.overall,
  latest.admissions.act_scores.midpoint.cumulative,
  latest.student.size,latest.cost.tuition.in_state,
  latest.cost.tuition.out_of_state
  &per_page=100

# Urban Institute IPEDS Admissions Requirements:
https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-requirements/2023/

# Urban Institute IPEDS Admissions Enrollment:
https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-enrollment/2023/

# Urban Institute IPEDS Directory (institutional metadata):
https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2023/
```

**Update cadence:** College Scorecard updated March 2026; IPEDS annual provisional ~9 months after collection period. Layer 1 data can be refreshed annually via automated pipeline.

**Coverage:** ~7,000 institutions (filters to ~4,000 bachelor's/associate's degree-granting schools for Ladder's scope)

---

### Layer 2: Paid CDS-Aligned Data Licensing

**Primary Source:** [Peterson's Data](https://petersonsdata.com)
- **Contact:** data-info@petersons.com / 720-334-8731
- **Cost:** Paid — contact for pricing
- **Format:** API + flat file delivery in 31 structured tables

**What this layer provides (fields NOT available in free APIs):**
- **Application deadlines**: Early Action closing date, Early Decision I/II closing dates, Regular Decision closing date (CDS C14, C21, C22)
- **Application fee**: Amount; waiver availability (CDS C13)
- **Decision notification dates**: EA/ED/RD notification dates (CDS C16)
- **Enrollment reply policy**: Must-reply-by date; May 1 standard deadline compliance (CDS C17)
- **Housing deposit**: Deadline and amount; refundable policy (CDS C17)
- **Testing policy** (CDS C8A format): Required for all / Required for some / Recommended / Test-optional / Test-blind, with which tests apply
- **Admissions factors** (CDS C7): All 18 factor ratings (Very Important / Important / Considered / Not Considered) for the full factor set
- **HS unit requirements** (CDS C5): English, Math, Science, Foreign Language, Social Studies, etc.
- **GPA data** (CDS C11, C12): Average HS GPA; distribution
- **Wait-list data** (CDS C2)
- **Deferred admission** (CDS C18)
- **Non-fall acceptance** (CDS C15)
- **Annual expenses** (CDS Section G): Tuition, room & board, required fees, books, personal
- **Financial aid deadlines** (CDS Section H)

**Coverage:** ~4,200 two- and four-year undergraduate US institutions
**Update frequency:** Multiple times per year; more current than any free source

**Alternative for selective manual collection:** [College Transitions CDS Repository](https://www.collegetransitions.com/dataverse/common-data-set-repository/) provides free PDF links for 211+ selective schools from 2017–2024-25. Parseable as a supplement for top schools. [commondatasets.fyi](https://www.commondatasets.fyi/) provides structured C7 data tables for 100+ schools with no API.

**Field extraction priority from Peterson's (for Ladder's MVP):**
1. EA/ED/RD deadlines — highest student value
2. Application fee — high frequency query
3. Testing policy (C8A) — needed for every school profile
4. Admissions factor ratings (C7) — powers the "what matters here" feature
5. Housing deposit deadline/amount — post-acceptance checklist
6. Enrollment reply deadline — post-acceptance checklist

---

### Layer 3: Specialized Testing Policy Database

**Primary Source:** [FairTest](https://fairtest.org/test-optional-list/)
- **Contact:** fairtest.org (request bulk export)
- **Coverage:** 2,085+ bachelor's degree-granting institutions
- **Cost:** Likely free for non-commercial educational use; contact FairTest
- **Format:** Bulk export includes IPEDS UnitIDs + policy details

**What this layer provides:**
- Current-cycle testing policy classifications, more granular and current than IPEDS or CDS:
  - **Test-Required**: SAT/ACT mandatory
  - **Test-Optional (permanent)**: Policy is permanent policy, not temporary
  - **Test-Optional (temporary)**: Pandemic-era extension; may revert
  - **Test-Free (Test-Blind)**: Scores submitted but not considered (UCLA, UC Berkeley)
- Policy restrictions and notes (e.g., "required for merit scholarship consideration," "optional except for homeschooled applicants")
- IPEDS UnitID cross-reference for database join

**Why FairTest over IPEDS alone:** IPEDS `reqt_test_scores` field uses coarse categories (0/1/2/3) and lags by 1–2 years. FairTest reflects current-cycle policy, distinguishes permanent from temporary opt-out, and covers more nuance. The IPEDS field can identify test-optional institutions directionally but should be overridden by FairTest where available.

**Join strategy:** Use IPEDS UnitID to join FairTest data onto Layer 1 institution records. Where FairTest data exists (2,085+ schools), use FairTest classification. For remaining schools, fall back to IPEDS `reqt_test_scores` with appropriate data-age disclaimer.

---

### Layer 4: Application Platform Routing

**Sources:**
- [Common App Member Search](https://www.commonapp.org/explore) — 1,133+ member schools
- [Coalition/Scoir Member List](https://www.coalitionforcollegeaccess.org/our-members) — ~170 member schools

**Access:** Web collection (no API; both pages are publicly browsable)
**Cost:** Free

**What this layer provides:**
- Binary flag: Is this school a Common App member? (Yes/No)
- Binary flag: Is this school a Coalition/Scoir member? (Yes/No)
- These two flags enable the app to route students to the correct application platform

**Collection approach:**
- Programmatic collection of both member lists creates a lookup table: `{school_name, common_app_member, coalition_member}`
- Join to master institution list via school name + state fuzzy matching, or via CEEB code (available in Common App but not directly exposed in bulk)
- Update annually each August when new application cycle opens

**Supplemental:** IPEDS CEEB crosswalk files allow matching College Board school codes to IPEDS UNITIDs, which can assist in linking Common App membership to the master database.

**Note on Universal College Application:** Effectively defunct (1 active school). Do not build infrastructure around UCA.

---

### Layer 5: Direct School Collection — Critical Enrollment-Process Data

**Fields with no bulk source (must be collected individually from each school's website):**

| Field | School Website Location | Collection Difficulty |
|---|---|---|
| Supplemental essay count & prompts | Common App school-specific supplement; school admissions page | High — changes annually; only accessible from Aug 1 forward |
| Transcript submission method (SSAR/STARS/Naviance/Parchment) | School admissions FAQ or application instructions | Medium — semi-stable year-to-year |
| Housing application open/close dates | School housing/residential life office website | High — published annually in spring/summer |
| Required immunization records & deadlines | School student health center website | Medium — changes rarely |
| Final transcript submission deadline | School registrar or admissions website | Medium — typically consistent (July 1 or similar) |
| Placement test requirements (Math, English, Foreign Language) | School registrar or advising website | Medium — changes occasionally |
| Student portal/email setup instructions | School IT or new student orientation website | Low — stable year-to-year |
| Orientation dates and registration | School orientation office website | High — published annually in spring |
| Enrollment deposit amount & deadline | School admissions or bursar website | Medium — also in CDS C17, but more current on school site |

**Collection strategy options (ranked by recommended approach for Ladder):**

**Option A — Manual curation for top N schools (Recommended for MVP)**
- Manually collect enrollment-process fields for the top 500–1,000 schools by total annual applicant volume
- This covers the vast majority of student queries (the top 300 schools by applicant volume receive >85% of all applications)
- Assign a research team or trained crowdsource model to collect and verify data annually
- Store with `last_verified` timestamp and `source_url` for transparency

**Option B — Automated pipeline (Recommended for scale)**
- Build web agents to fetch and parse:
  - Common App supplement pages (for essay count)
  - School housing/orientation pages (for key dates)
- Requires school-specific URL mapping and parser maintenance
- Supplement with structured data when pages update formats

**Option C — Partnership with existing platforms**
- Scoir already aggregates per-school application requirements for its 170+ Coalition member schools
- A data partnership or API access agreement with Scoir could provide structured enrollment-process data for selective schools
- PowerSchool/Naviance has per-school data but is not accessible via external API

**Option D — User-contributed/counselor-verified updates**
- Build a counselor verification layer: licensed counselors (IECA/HECA members) confirm or correct school-specific data fields
- Creates a self-improving database with authoritative provenance
- Aligns with Ladder's market positioning as a trusted counseling platform

---

### Cross-Layer ID Mapping

Consistent school identification across layers requires mapping multiple ID systems:

| ID System | Source | Format | Notes |
|---|---|---|---|
| **UNITID** (NCES Unit ID) | IPEDS | 6-digit integer | Primary key for all IPEDS/Scorecard data |
| **OPEID** | FSA/Scorecard | 8-digit with branch | Links to FAFSA school codes; branches have sub-codes |
| **CEEB Code** | College Board | 4-digit | Used by Common App, SAT score sends, BigFuture |
| **ACT Code** | ACT | 4-digit | Used by ACT score sends |
| **FSA School Code** | FSA School Code List | 6-digit | FAFSA routing; crosswalks to OPEID |

**Recommended primary key for Ladder database:** UNITID (NCES). All other IDs should be stored as alternate identifiers with crosswalk tables.

**Crosswalk file:** College Scorecard bulk download includes an IPEDS crosswalk file mapping UNITID ↔ OPEID. CEEB-to-UNITID crosswalk can be built from College Board K-12 School Code Search data (available for download).

---

### What to Build vs. License vs. Collect

| Data Category | Action | Source | Cost |
|---|---|---|---|
| Institutional identity, location, type | **Build** via API | College Scorecard / Urban Institute | Free |
| Admissions statistics (rates, SAT/ACT) | **Build** via API | College Scorecard / IPEDS | Free |
| Cost and financial data | **Build** via API | College Scorecard / IPEDS | Free |
| Testing policy (current, granular) | **Build** via request | FairTest bulk export | Free/request |
| Common App / Coalition membership | **Build** via web collection | commonapp.org, coalitionforcollegeaccess.org | Free |
| Application deadlines (EA/ED/RD) | **License** | Peterson's Data | Paid |
| Application fees, C7 factor ratings, housing deposit | **License** | Peterson's Data | Paid |
| CDS Section C7 (top 100 selective schools) | **Build** manually | Official CDS PDFs / commondatasets.fyi | Free |
| Supplemental essay count/prompts | **Collect manually** (top 500 schools) | Common App school pages | Staff time |
| Transcript submission method | **Collect manually** | School admissions pages | Staff time |
| Housing application dates | **Collect manually** | School housing pages | Staff time |
| Orientation dates | **Collect manually** | School orientation pages | Staff time |
| Placement test requirements | **Collect manually** | School registrar pages | Staff time |
| Immunization requirements | **Collect manually** | School health center pages | Staff time |
| Student portal setup | **Collect manually** | School IT/new student pages | Staff time |

---

### Recommended Build Sequence for Ladder MVP

**Phase 1 — Foundation (Weeks 1–4)**
1. Pull all ~7,000 institutions from College Scorecard API + IPEDS via Urban Institute API
2. Filter to ~4,000 degree-granting schools (remove non-degree-granting, closed, and primarily online-only)
3. Import FairTest bulk export; join on UNITID
4. Collect Common App and Coalition member lists; join via name/state matching
5. Database schema: institutions table, admissions table, costs table, testing_policy table, platform_routing table

**Phase 2 — Application Data (Weeks 5–10)**
1. Negotiate and execute Peterson's Data license
2. Ingest Peterson's 31-table flat file or API into application_requirements table
3. Priority fields: EA/ED/RD deadlines, application fees, testing policy (C8A), C7 factor ratings
4. QA check: cross-reference Peterson's deadlines against 30 manually verified school websites

**Phase 3 — Enrollment Process Data (Weeks 11–20)**
1. Manually collect enrollment-process fields for top 500 schools by applicant volume
2. Build `school_sources` table with URL + collection date for each field
3. Annual refresh protocol: set review reminders for August (application cycle opens), March–April (housing apps), May (orientation info)

**Phase 4 — Supplemental Essays (Annual Cycle)**
1. Build Common App supplement parser for essay prompts (releases ~August 1 each year)
2. Store prompts with `cycle_year` field; archive prior years
3. Consider user-contribution layer: students can submit/confirm prompts they encountered

---

### Data Freshness Strategy

| Data Layer | Staleness Risk | Refresh Strategy |
|---|---|---|
| Institutional identity | Low (schools rarely change type/location) | Annual |
| Admissions stats (acceptance rate, SAT/ACT) | Medium (changes year-to-year) | Annual (via API) |
| Testing policy | **High** (many schools changed policy 2020–2025) | Bi-annual; FairTest refresh + monitoring |
| Application deadlines | **Very High** (change every cycle) | Annual; Peterson's update + spot-checks |
| Application fees | Low-Medium | Annual |
| Housing/enrollment deposits | Medium | Annual |
| Supplemental essay prompts | **Extremely High** (change every cycle) | Annual; cycle-specific |
| Orientation dates | **Very High** | Annual; school-specific scrape |
| Immunization requirements | Low | Every 2 years |

**Staleness display strategy:** Show `data_as_of` timestamp on any school-specific field. For fields where staleness risk is "High" or above, display a disclaimer: "Verify directly with [school name] — this information changes each application cycle."

---

### Technology Stack Recommendations

- **Database:** PostgreSQL with JSONB columns for flexible CDS-derived fields
- **API integration:** Python (requests + pandas) for bulk Scorecard/IPEDS pulls; Node.js for real-time API calls
- **Data pipeline:** Apache Airflow or Prefect for scheduled refresh jobs
- **Web collection:** Playwright or Puppeteer for JavaScript-rendered school pages; BeautifulSoup for static HTML
- **ID resolution:** Custom fuzzy matching (fuzz + Levenshtein) for school name → UNITID resolution from web-collected sources
- **Monitoring:** Alerting on field staleness thresholds (flag any deadline field not refreshed in 400+ days)

---

### Key Contacts for Licensing and Data Partnerships

| Organization | Contact | Purpose |
|---|---|---|
| Peterson's Data | data-info@petersons.com / 720-334-8731 | CDS-aligned application data license |
| FairTest | fairtest.org | Bulk testing policy export with UNITIDs |
| College Scorecard (rate limit increases) | scorecarddata@rti.org | Higher API rate limits (>1,000/hour) |
| Scoir (Coalition platform) | scoir.com | Potential data partnership for Coalition schools |
| Urban Institute Education Data | educationdata.urban.org | Open API; no special contact needed |

---

### Summary: Data Coverage After All Five Layers

| Field | Coverage After All Layers |
|---|---|
| School identity, location, type | ~7,000 schools (Layer 1) |
| Acceptance rate, SAT/ACT ranges | ~6,000 schools (Layer 1) |
| In-state/out-of-state tuition | ~6,000 schools (Layer 1) |
| Testing policy (current, granular) | ~4,000+ schools (Layers 1 + 3) |
| Common App membership | 1,133 schools (Layer 4) |
| Coalition/Scoir membership | ~170 schools (Layer 4) |
| EA/ED/RD deadlines | ~4,200 schools (Layer 2 — Peterson's) |
| Application fee | ~4,200 schools (Layer 2) |
| CDS C7 admissions factor ratings | ~4,200 schools (Layer 2); top 100 directly from PDFs |
| Housing deposit deadline/amount | ~4,200 schools (Layer 2) |
| Supplemental essay prompts | Top 500 schools (Layer 5 — manual) |
| Transcript submission method | Top 500 schools (Layer 5 — manual) |
| Housing application dates | Top 500 schools (Layer 5 — manual) |
| Orientation dates | Top 500 schools (Layer 5 — manual) |
| Immunization requirements | Top 500 schools (Layer 5 — manual) |
| Placement test requirements | Top 500 schools (Layer 5 — manual) |
| Student portal setup | Top 500 schools (Layer 5 — manual) |

---

*This Data Architecture section synthesizes findings from Area 1 & 2 research (College Data Sources & APIs) and maps them to a concrete technical build plan for the Ladder college guidance app.*

