# AI Adaptive Career Discovery Quiz: Complete Design Specification

## Executive Summary

This document presents a complete design specification for a sectional adaptive career assessment quiz targeting 9th-12th graders (ages 14-18). The system adapts in real-time using a multistage adaptive testing (MST) model inspired by the [digital SAT's sectional adaptation approach](https://highered.collegeboard.org/media/pdf/digital-sat-faculty-guide-ada.pdf), routing students through branching follow-up questions based on initial responses. The design synthesizes three established frameworks — Holland's RIASEC model, the Strong Interest Inventory, and Advance CTE's Career Clusters — into a custom 5-bucket scoring system with 25 sub-specializations. The quiz completes in 5-8 minutes (30 questions total), includes annual retake logic for growth tracking across grades 9-12, and feeds into a Gemini AI personalization layer that generates career narratives, major recommendations, college suggestions, AP course alignments, and extracurricular guidance.

---

## Part 1: Theoretical Foundations

### Holland's RIASEC Model

The RIASEC model, developed by psychologist John L. Holland, categorizes vocational interests into six personality types arranged in a hexagonal structure: Realistic (R), Investigative (I), Artistic (A), Social (S), Enterprising (E), and Conventional (C). Adjacent types on the hexagon share more similarity than opposite types — for example, Realistic and Investigative are more related than Realistic and Social ([Assessment Systems Corporation](https://assess.com/what-is-riasec-assessment/)).

The model's core principle is person-environment fit: individuals experience greater satisfaction and persistence when their work environments match their personality type ([HIGH5 Test](https://high5test.com/what-are-holland-codes/)). Results are expressed as a three-letter Holland Code (e.g., "IRE") representing primary, secondary, and tertiary interest types, creating 720 possible combinations that map to specific career clusters ([RIASECtest.com](https://riasectest.com/blog/understanding-your-riasec-test-results-career-paths-for-3-letter-combinations)).

The U.S. Department of Labor's [O\*NET system](https://www.onetcenter.org/dl_files/IP_Manual.pdf) integrates the RIASEC framework to categorize over 900 occupations, making it the most widely used vocational interest framework worldwide. The O\*NET Interest Profiler uses 30 items per RIASEC scale (180 total) in its long form, 10 items per scale (60 total) in its short form, and 5 items per scale (30 total) in its Mini-IP version ([O\*NET Center](https://www.onetcenter.org/dl_files/Mini-IP_Linking.pdf)).

### Strong Interest Inventory (SII)

The SII is one of the most empirically validated interest assessments, consisting of 291 questions completed in 30-50 minutes. It profiles results across Holland's six General Occupational Themes (GOTs), 30 Basic Interest Scales (BIS), 244 Occupational Scales, and 5 Personal Style Scales. Raw scores are normed against a General Representative Sample (GRS) of 2,250 people, converted to standard scores with a mean of 50 and standard deviation of 10 ([Career Assessment Site](https://careerassessmentsite.com/validity-reliability-strong-interest-inventory/)).

The SII is validated for individuals aged 14 and above, requiring at least a sixth-grade reading level ([EBSCO](https://www.ebsco.com/research-starters/health-and-medicine/strong-interest-inventory-sii)). Its reliability metrics are strong: GOT internal consistency alphas exceed .91, and test-retest reliabilities for Occupational Scales reach a median of .86 across 2-7 month intervals ([Myers-Briggs Company](https://ap.themyersbriggs.com/content/Research%20and%20White%20Papers/Strong/Strong_Content_Validity.pdf)).

### Advance CTE Career Clusters Framework

Modernized in 2024 after two years of industry input, the [National Career Clusters Framework](https://careertech.org/career-clusters/) now consists of 14 Career Clusters and 72 Sub-Clusters organized into 6 Cluster Groupings, replacing the previous 16-cluster model. Three Cross-Cutting Clusters — Digital Technology, Management & Entrepreneurship, and Marketing & Sales — intersect with all other clusters ([Advance CTE FAQ](https://careertech.org/career-clusters/frequently-asked-questions/)). The framework shifted from educational groupings to industry-oriented, sector-specific clusters defined by labor market data, making it more aligned with current workforce realities.

---

## Part 2: Adaptive Testing Architecture

### Multistage Adaptive Testing (MST) Model

The quiz uses a sectional MST approach modeled after the digital SAT, rather than question-by-question Item Response Theory (IRT) adaptation. In the [digital SAT's design](https://www.edisonos.com/digital-sat/adaptive-testing), each section has two modules: a Base Module of uniform difficulty, followed by an Adaptive Module whose difficulty adjusts based on Base Module performance. This approach preserves content control while enabling personalization — students can review and revise answers within a module, which pure IRT-based CAT does not allow ([College Board](https://highered.collegeboard.org/media/pdf/digital-sat-faculty-guide-ada.pdf)).

Our adaptation translates this to interest assessment:

| Component | Digital SAT Analog | Career Quiz Implementation |
|---|---|---|
| Base Module | Standard difficulty questions | Stage 1: 5 general interest questions |
| Scoring Gate | Performance threshold | Bucket score calculation + top-2 identification |
| Adaptive Module | Harder/easier question set | Stage 2: 5 branch-specific deep-dive questions |
| Score Ceiling/Floor | Module-dependent max score | Branch determines which sub-specializations are assessed |

### Three-Stage Flow

**Stage 1 — General Interest Discovery (5 questions, ~2 min):** Every student answers the same 5 questions spanning all five question types. These map across all RIASEC dimensions to produce initial bucket scores.

**Scoring Gate:** The system calculates scores across 5 career buckets (STEM, Medical, Business, Humanities, Sports/Kinesiology), identifies the top 2 buckets, and routes to the appropriate Stage 2 branch.

**Stage 2 — Deep-Dive Branch (5 questions, ~3 min):** Students receive questions specific to their top-scoring bucket(s). If STEM + Medical are top 2, questions distinguish between sub-specializations within both. The system uses the [branching assessment pattern](https://www.taotesting.com/blog/how-to-use-types-of-computer-adaptive-testing/) where initial responses determine the adaptive pathway.

**Stage 3 — AI Personalization (automated):** Gemini AI processes raw scores plus student profile data to generate personalized output.

<!-- Branching Logic Architecture diagram (image removed — contained expired AWS credentials) -->

---

## Part 3: Scoring Algorithm

### RIASEC-to-Bucket Mapping

Each question response generates weighted RIASEC dimension scores. These are then mapped to 5 career buckets using the following matrix:

| Career Bucket | Primary RIASEC | Secondary RIASEC | Tertiary RIASEC |
|---|---|---|---|
| STEM | Investigative (I) | Realistic (R) | Conventional (C) |
| Medical | Investigative (I) | Social (S) | Realistic (R) |
| Business | Enterprising (E) | Conventional (C) | Social (S) |
| Humanities | Artistic (A) | Social (S) | Enterprising (E) |
| Sports/Kinesiology | Realistic (R) | Social (S) | Enterprising (E) |

### Scoring Formula

For each question response, the system assigns RIASEC dimension points. The bucket score formula uses weighted contribution from the [C-index congruence method](https://pmc.ncbi.nlm.nih.gov/articles/PMC9819525/):

\[
\text{BucketScore}_b = 3 \times \text{RIASEC}_{\text{primary}(b)} + 2 \times \text{RIASEC}_{\text{secondary}(b)} + 1 \times \text{RIASEC}_{\text{tertiary}(b)}
\]

Where \(\text{RIASEC}_{\text{primary}(b)}\) is the accumulated score for bucket \(b\)'s primary RIASEC dimension. This produces a congruence score from 0 to a theoretical maximum based on question count.

### Normalization to Percentages

After summing across all Stage 1 questions:

\[
\text{NormalizedScore}_b = \frac{\text{BucketScore}_b}{\sum_{i=1}^{5} \text{BucketScore}_i} \times 100
\]

This yields percentage distribution across buckets (e.g., STEM 35%, Medical 25%, Business 20%, Humanities 12%, Sports 8%).

### Response Scoring by Question Type

| Question Type | Scoring Method | Max Points per RIASEC Dimension |
|---|---|---|
| Scenario-Based | Each option maps to specific RIASEC dimensions; selected option gets full weight | 5 points per relevant dimension |
| Forced-Choice Pair | Selected option contributes +3 to its dimension; rejected option contributes +1 to its dimension (ipsative scoring) | 3 points selected, 1 point rejected |
| Likert Scale (1-5) | Response value directly applied to the relevant RIASEC dimension | 5 points max |
| Activity Ranking (rank 1-5) | Rank inverted to weight: Rank 1 = 5pts, Rank 2 = 4pts, ... Rank 5 = 1pt | 5 points for top-ranked |
| Time Allocation (10 hrs split) | Hours allocated proportionally converted to dimension scores | Proportional to hours assigned |

### Sub-Specialization Scoring (Stage 2)

Within each bucket, Stage 2 questions differentiate sub-specializations. Each bucket contains 5 sub-specializations:

**STEM:** Computer Science, Engineering, Data Science, Environmental Science, Mathematics

**Medical:** Clinical Practice, Biomedical Engineering, Public Health, Health Tech, Research/Pharmaceutical

**Business:** Entrepreneurship, Finance/Accounting, Consulting/Management, Marketing/Media, Real Estate

**Humanities:** Law & Policy, Education, Psychology, Media/Journalism, Social Work

**Sports/Kinesiology:** Sports Medicine, Coaching/Management, Exercise Science, Physical Therapy, Sports Analytics

Stage 2 scoring uses the same weighted approach but maps to sub-specialization dimensions rather than RIASEC buckets. The top 3 sub-specializations are reported.

### Consistency Detection

The system flags inconsistent responses using the [Strong Interest Inventory's Typicality Index approach](https://careerassessmentsite.com/validity-reliability-strong-interest-inventory/), which detects random or contradictory response patterns. If a student's Stage 1 forced-choice selection contradicts their Likert rating on the same dimension (e.g., choosing "solve puzzles" in Q2 but rating "science activities" as 1/5 in Q3), the system:

1. Flags the response pair internally
2. Computes a consistency score (0-1)
3. If consistency < 0.5, adds a tiebreaker question before Stage 2
4. Reports confidence level alongside results (High/Medium/Low)

---

## Part 4: 30 Sample Questions

### Stage 1 — General Section (All Students)

#### Q1: Scenario-Based
**"You just won a $100 gift card. What do you do with it?"**

| Option | RIASEC Mapping |
|---|---|
| A) Invest it in stocks or crypto | E+C (Business) |
| B) Buy supplies to build a project | R+I (STEM) |
| C) Donate it to a health charity | S+I (Medical) |
| D) Buy books or art supplies | A+S (Humanities) |
| E) Get new athletic gear or gym membership | R+S (Sports) |

#### Q2: Forced-Choice Pair
**"Would you rather..."**

| Pair | Maps To |
|---|---|
| A) Lead a team on a group project | E+S (Business/Humanities) |
| B) Solve a complex math or science problem alone | I+R (STEM/Medical) |

#### Q3: Likert Scale (1-5)
**"Rate how much you would enjoy each activity:"**

| Activity | RIASEC Target |
|---|---|
| a) Giving a presentation to your class | E + S |
| b) Dissecting a frog in biology lab | I + R |
| c) Writing a short story or poem | A + S |
| d) Organizing a fundraiser | E + S |
| e) Training for a sports competition | R + S |

#### Q4: Activity Ranking (Rank 1-5)
**"Rank these after-school activities from most to least appealing:"**

| Activity | Bucket Mapping |
|---|---|
| A) Robotics or coding club | STEM |
| B) Volunteering at a hospital or clinic | Medical |
| C) Running a small business or side hustle | Business |
| D) School newspaper or debate team | Humanities |
| E) Varsity sports or personal training | Sports/Kinesiology |

#### Q5: Time Allocation (Split 10 hours)
**"You have 10 free hours this weekend. How would you split them?"**

| Activity | Bucket Mapping |
|---|---|
| Building/tinkering with technology | STEM |
| Learning about health, nutrition, or medicine | Medical |
| Working on a money-making project | Business |
| Reading, writing, or creative work | Humanities |

---

### Stage 2 — STEM Branch (5 Questions)

#### Q6: Forced-Choice Pair
**"Would you rather..."**
- A) Write code for an app → Computer Science
- B) Design a bridge or machine → Engineering

#### Q7: Scenario-Based
**"Your school needs help with a problem. Which do you volunteer for?"**
- A) Analyzing the school's energy usage data → Data Science
- B) Designing a water filtration system for the garden → Environmental Science
- C) Building a website to track school events → Computer Science
- D) Fixing the 3D printer in the makerspace → Engineering
- E) Tutoring classmates in calculus → Mathematics

#### Q8: Likert Scale (1-5)
**"Rate your interest in each:"**
- a) Writing Python scripts or algorithms → Computer Science
- b) Working with circuits, CAD, or physical prototypes → Engineering
- c) Finding patterns in large datasets → Data Science
- d) Studying climate change or ecosystems → Environmental Science
- e) Proving mathematical theorems → Mathematics

#### Q9: Activity Ranking (Rank 1-5)
**"Rank these projects from most to least exciting:"**
- A) Build an AI chatbot → Computer Science
- B) Design a prosthetic hand → Engineering
- C) Create a dashboard from survey data → Data Science
- D) Map local pollution sources → Environmental Science
- E) Develop a new encryption method → Mathematics

#### Q10: Time Allocation (Split 10 hours)
**"You have 10 hours for a passion project. How do you split them?"**
- Coding / programming → Computer Science
- Building / prototyping physical devices → Engineering
- Analyzing data or creating visualizations → Data Science
- Environmental research or fieldwork → Environmental Science

---

### Stage 2 — Medical Branch (5 Questions)

#### Q11: Forced-Choice Pair
**"Would you rather..."**
- A) Diagnose patients in a clinic → Clinical Practice
- B) Design a new medical device → Biomedical Engineering

#### Q12: Scenario-Based
**"A new disease outbreak is reported. What role appeals most?"**
- A) Treating patients on the front line → Clinical Practice
- B) Engineering better ventilators → Biomedical Engineering
- C) Tracking the spread using population data → Public Health
- D) Developing an app to coordinate care → Health Tech
- E) Running lab experiments to find a cure → Research/Pharma

#### Q13: Likert Scale (1-5)
**"Rate your interest:"**
- a) Shadowing a doctor or surgeon → Clinical Practice
- b) Designing prosthetics or implants → Biomedical Engineering
- c) Studying disease prevention in communities → Public Health
- d) Building health monitoring wearables → Health Tech
- e) Conducting lab research on drug compounds → Research/Pharma

#### Q14: Activity Ranking (Rank 1-5)
**"Rank these from most to least appealing:"**
- A) Performing a simulated surgery → Clinical Practice
- B) 3D-printing an organ model → Biomedical Engineering
- C) Designing a vaccination campaign → Public Health
- D) Coding a telemedicine platform → Health Tech
- E) Analyzing clinical trial data → Research/Pharma

#### Q15: Time Allocation (Split 10 hours)
**"10 hours for a health project — how do you split?"**
- Patient care simulation → Clinical Practice
- Device prototyping → Biomedical Engineering
- Community health data analysis → Public Health
- Health app development → Health Tech

---

### Stage 2 — Business Branch (5 Questions)

#### Q16: Forced-Choice Pair
**"Would you rather..."**
- A) Start your own company → Entrepreneurship
- B) Manage investments and portfolios → Finance/Accounting

#### Q17: Scenario-Based
**"Your school wants to raise $5,000. Which role do you take?"**
- A) Come up with the business idea and pitch it → Entrepreneurship
- B) Manage the budget and track expenses → Finance/Accounting
- C) Plan the strategy and organize the team → Consulting/Management
- D) Design the marketing campaign and social media → Marketing/Media
- E) Research real estate for a pop-up event space → Real Estate

#### Q18: Likert Scale (1-5)
**"Rate your interest:"**
- a) Pitching a startup idea to investors → Entrepreneurship
- b) Reading financial statements and stock reports → Finance/Accounting
- c) Advising a company on how to improve → Consulting/Management
- d) Creating ad campaigns or brand strategies → Marketing/Media
- e) Analyzing property values and market trends → Real Estate

#### Q19: Activity Ranking (Rank 1-5)
**"Rank these from most to least appealing:"**
- A) Running a lemonade stand or e-commerce shop → Entrepreneurship
- B) Competing in a stock market simulation → Finance
- C) Leading a team through a business case competition → Consulting
- D) Designing an Instagram marketing campaign → Marketing/Media
- E) Touring commercial properties → Real Estate

#### Q20: Time Allocation (Split 10 hours)
**"10 hours for business learning — how do you split?"**
- Building a business plan → Entrepreneurship
- Studying markets and financial models → Finance
- Strategy workshops and case studies → Consulting
- Creating content and brand identity → Marketing/Media

---

### Stage 2 — Humanities Branch (5 Questions)

#### Q21: Forced-Choice Pair
**"Would you rather..."**
- A) Argue a case in court → Law & Policy
- B) Teach a class of students → Education

#### Q22: Scenario-Based
**"Your community has a social issue to address. What's your approach?"**
- A) Draft new policy or legal protections → Law & Policy
- B) Create an educational program about it → Education
- C) Research the psychological impact on people → Psychology
- D) Write an investigative article exposing the issue → Media/Journalism
- E) Organize support services for affected families → Social Work

#### Q23: Likert Scale (1-5)
**"Rate your interest:"**
- a) Studying constitutional law or government policy → Law & Policy
- b) Mentoring younger students → Education
- c) Understanding why people think and behave the way they do → Psychology
- d) Producing a podcast or documentary → Media/Journalism
- e) Volunteering at a community shelter → Social Work

#### Q24: Activity Ranking (Rank 1-5)
**"Rank these from most to least appealing:"**
- A) Mock trial or Model UN → Law & Policy
- B) Tutoring or running a study group → Education
- C) Analyzing a psychology case study → Psychology
- D) Writing for the school newspaper → Media/Journalism
- E) Organizing a community service project → Social Work

#### Q25: Time Allocation (Split 10 hours)
**"10 hours for personal growth — how do you split?"**
- Reading about law, politics, or current events → Law & Policy
- Developing lesson plans or teaching → Education
- Studying human behavior or counseling techniques → Psychology
- Creating media content → Media/Journalism

---

### Stage 2 — Sports/Kinesiology Branch (5 Questions)

#### Q26: Forced-Choice Pair
**"Would you rather..."**
- A) Treat a player's injury on the sideline → Sports Medicine
- B) Coach and strategize game plans → Coaching/Management

#### Q27: Scenario-Based
**"A local sports team asks for your help. What do you do?"**
- A) Assess and rehabilitate injured players → Sports Medicine
- B) Develop game strategy and manage the team → Coaching/Management
- C) Design a custom workout and nutrition program → Exercise Science
- D) Help an injured athlete recover through rehab exercises → Physical Therapy
- E) Analyze player stats to optimize performance → Sports Analytics

#### Q28: Likert Scale (1-5)
**"Rate your interest:"**
- a) Learning sports injury prevention and treatment → Sports Medicine
- b) Leading a team as captain or coach → Coaching/Management
- c) Studying exercise physiology and nutrition science → Exercise Science
- d) Helping people recover from physical injuries → Physical Therapy
- e) Using data and statistics to analyze athletic performance → Sports Analytics

#### Q29: Activity Ranking (Rank 1-5)
**"Rank these from most to least appealing:"**
- A) Shadowing an athletic trainer → Sports Medicine
- B) Running a practice session for a youth team → Coaching
- C) Designing a fitness testing protocol → Exercise Science
- D) Working in a physical therapy clinic → Physical Therapy
- E) Building a player performance dashboard → Sports Analytics

#### Q30: Time Allocation (Split 10 hours)
**"10 hours in the sports world — how do you split?"**
- Athletic training and injury prevention → Sports Medicine
- Team strategy and leadership → Coaching/Management
- Fitness research and workout design → Exercise Science
- Data analysis and performance metrics → Sports Analytics

---

## Part 5: AI Personalization Prompt Template

### Gemini API Prompt Template

```
SYSTEM PROMPT:
You are a college and career counselor AI for high school students (grades 9-12).
You specialize in translating career assessment data into actionable, personalized
guidance. Be encouraging but realistic. Use age-appropriate language.
Avoid gender or socioeconomic stereotyping.

USER PROMPT:
Generate a personalized career discovery report for the following student.

=== STUDENT PROFILE ===
Name: {{student_name}}
Grade: {{grade}} ({{grade_year}} of high school)
GPA: {{gpa}} ({{gpa_scale}} scale)
School: {{school_name}}, {{state}}

AP/Honors Courses Taken or Planned:
{{ap_courses_list}}

Extracurriculars:
{{extracurriculars_list}}

=== QUIZ RESULTS ===
Date Taken: {{quiz_date}}
Completion Time: {{completion_minutes}} minutes
Consistency Score: {{consistency_score}}/1.0

Bucket Scores (normalized percentages):
- STEM: {{stem_pct}}%
- Medical: {{medical_pct}}%
- Business: {{business_pct}}%
- Humanities: {{humanities_pct}}%
- Sports/Kinesiology: {{sports_pct}}%

Top Bucket: {{top_bucket}}
Second Bucket: {{second_bucket}}

Sub-Specialization Rankings (within top bucket):
1. {{sub_spec_1}} ({{sub_spec_1_score}})
2. {{sub_spec_2}} ({{sub_spec_2_score}})
3. {{sub_spec_3}} ({{sub_spec_3_score}})

RIASEC Code: {{holland_code}} (e.g., "IRE")

{{#if has_previous_results}}
=== YEAR-OVER-YEAR COMPARISON ===
{{#each previous_results}}
- {{year}} (Grade {{grade}}): STEM {{stem}}%, Medical {{medical}}%,
  Business {{business}}%, Humanities {{humanities}}%, Sports {{sports}}%
{{/each}}
Interest Trend: {{trend_summary}}
{{/if}}

=== GENERATE THE FOLLOWING 5 SECTIONS ===

**Section 1: Personalized Career Path Narrative (200-300 words)**
Write a compelling narrative connecting the student's assessment results to
real-world career paths. Reference their specific quiz responses where relevant.
Acknowledge their unique combination of interests (e.g., "Your blend of Medical
and STEM interests positions you for biomedical engineering"). If year-over-year
data exists, comment on their interest evolution.

**Section 2: Major Recommendations (Top 5)**
For each recommended major:
- Major name and brief description
- Why it matches their profile (cite specific scores and interests)
- Typical starting salary range
- Growth outlook (Bureau of Labor Statistics data)
- Related minors that complement it

**Section 3: College Suggestions (Top 8)**
Sorted by program strength in the student's top field. For each:
- College name
- Relevant program/department and national ranking
- Why it's a good fit for this student
- Approximate annual cost (in-state vs out-of-state if relevant)
- Admission competitiveness relative to student's GPA

**Section 4: AP Course Recommendations**
Based on their career path and current course load:
- Must-take APs (directly relevant to career path)
- Recommended APs (strengthens profile)
- Optional APs (broadens perspective)
- For each, explain WHY it matters for their specific path

**Section 5: Extracurricular Suggestions**
Based on their career path and what they're already doing:
- Activities to continue (with rationale)
- New activities to start (specific clubs, competitions, volunteer ops)
- Summer programs or internships to pursue
- Portfolio/project ideas that demonstrate interest

FORMATTING: Use markdown headers. Be specific — name real colleges, real AP
courses, real competitions. Do not use generic advice. Every recommendation
should feel tailored to THIS student.
```

---

## Part 6: Validation and Psychometric Design

### Minimum Question Count for Reliability

Research across established instruments reveals a clear relationship between item count and reliability:

| Instrument | Items per Scale | Total Items | Cronbach's Alpha | Test-Retest r |
|---|---|---|---|---|
| O\*NET Interest Profiler (Long) | 30 | 180 | .93-.95 | .81-.92 |
| O\*NET IP Short Form | 10 | 60 | .80-.85 | .76-.89 |
| O\*NET Mini-IP | 5 | 30 | .72-.78 | .68-.82 |
| Strong Interest Inventory | ~48 per GOT | 291 | .91+ | .84-.92 |
| COPS Interest Inventory | ~12 | ~168 | .85-.90 | .75-.85 |

Sources: [O\*NET Center](https://www.onetcenter.org/dl_files/IP_RVS.pdf), [Myers-Briggs Company](https://ap.themyersbriggs.com/content/Research%20and%20White%20Papers/Strong/Strong_Content_Validity.pdf), [EBSCO](https://www.ebsco.com/research-starters/health-and-medicine/strong-interest-inventory-sii)

The O\*NET Mini-IP demonstrates that 5 items per RIASEC scale (30 total) can achieve acceptable reliability for exploratory career assessments, though not for high-stakes decisions ([O\*NET Mini-IP Linkage Paper](https://www.onetcenter.org/dl_files/Mini-IP_Linking.pdf)). Our 30-question design — with 5 general + 5 branch-specific questions — provides comparable item density to the Mini-IP while adding depth through branching.

### Reliability Targets for This Assessment

| Metric | Target | Rationale |
|---|---|---|
| Cronbach's Alpha (per bucket) | ≥ 0.75 | Acceptable for low-stakes exploratory assessment ([UVA Library](http://library.virginia.edu/data/articles/using-and-interpreting-cronbachs-alpha)) |
| Test-Retest (2-week interval) | ≥ 0.70 | Appropriate given adolescent interest volatility |
| Consistency Score | ≥ 0.50 | Minimum for valid interpretation |
| Minimum sample for norming | 50+ per demographic group | Standard for psychometric norming ([Assessmentq](https://assessmentq.com/psychometric-values-what-are-they-and-how-do-you-use-them/?lang=en)) |

### Validation Strategy

The Spearman-Brown prophecy formula can estimate how reliability improves with added items ([Questionmark](https://www.questionmark.com/resources/blog/how-many-questions-do-i-need-on-my-assessment/)):

\[
r_{new} = \frac{k \cdot r_{old}}{1 + (k-1) \cdot r_{old}}
\]

Where \(k\) is the factor by which the test is lengthened and \(r_{old}\) is the current reliability. If the initial 30-item quiz achieves \(\alpha = 0.72\), doubling to 60 items would yield an estimated \(\alpha = 0.84\).

### Handling Inconsistent Responses

1. **Cross-response validation:** Compare answers across question types targeting the same dimension. If a student ranks "robotics club" as #1 (Q4) but rates "coding and algorithms" as 1/5 (Q8), flag the inconsistency.
2. **Infrequent response detection:** Adapted from the [Strong Interest Inventory's Typicality Index](https://careerassessmentsite.com/validity-reliability-strong-interest-inventory/), flag profiles where more than 15 of 291 items are skipped or patterns match random response simulation.
3. **Response time analysis:** Flag completion times below 2 minutes (surface-level clicking) or above 15 minutes (likely distracted).
4. **Confidence bands:** Report results with High (consistency ≥ 0.8), Medium (0.5-0.79), or Low (< 0.5) confidence indicators.

---

## Part 7: Age-Appropriate Design Considerations

### Attention Span and Quiz Length

Research on youth survey design establishes clear guidelines for the 14-18 age range:

- Children aged 12-15 can sustain survey attention for 45-60 minutes; ages 16+ match adult attention spans of 60+ minutes ([Research Evaluation Consulting](https://researchevaluationconsulting.com/youth-surveys-tips-for-effective-data-collection/))
- For secondary students, [Hanover Research](https://www.hanoverresearch.com/insights-blog/k-12-education/strategies-for-successful-k-12-survey-design-and-analysis/) recommends a 7-minute time limit
- Average survey response time is 7.5-10 seconds per question ([Drag'n Survey](https://www.dragnsurvey.com/blog/en/how-many-questions-do-people-answer-before-getting-bored/))
- Gamified quiz formats maintain teen engagement through timed rounds, instant feedback, and social competition ([Learning For Youth](https://learningforyouth.com/gamified-quiz-apps/))

Our 30-question design at ~10 seconds per standard question and ~20 seconds per ranking/allocation question targets **5-8 minutes total** — well within the optimal range.

### Design Principles for 14-18 Year Olds

| Principle | Implementation |
|---|---|
| **Short rounds** | Stage 1 (2 min) → Scoring Gate → Stage 2 (3 min) → Results. Never more than 5 questions without visual feedback |
| **Progress indicator** | Visual progress bar showing Stage 1/Stage 2 completion percentage |
| **Mixed question types** | Alternating between scenario, forced-choice, Likert, ranking, and allocation prevents autopilot responses |
| **Mobile-first** | 90%+ of Gen Z own smartphones; design for thumb-friendly interaction ([Learning For Youth](https://learningforyouth.com/gamified-quiz-apps/)) |
| **Instant micro-feedback** | After Stage 1, show a preview of top bucket before Stage 2 ("Looks like you're trending toward STEM...") |
| **Gamification elements** | Achievement badges for completing retakes, streak tracking across years |
| **6th-grade reading level** | Consistent with SII requirements; avoid jargon, use scenario-based language |

### Bias Reduction Strategies

Career assessments face documented risks of gender, socioeconomic, and cultural bias ([CareerWise / CERIC](https://careerwise.ceric.ca/2024/09/19/breaking-down-bias-in-career-assessments/)). [Stanford research](https://sociology.stanford.edu/publications/gender-and-career-choice-process-role-biased-self-assessments) demonstrates that cultural beliefs about gender bias self-competence perceptions, affecting career decisions independent of actual ability.

| Bias Type | Mitigation |
|---|---|
| **Gender stereotyping** | Avoid gendered language in question stems. Do not use occupational titles with implicit gender (e.g., "fireman"). Present all career options as equally accessible. Norm scores by gender as the SII does to ensure cross-gender validity |
| **Socioeconomic bias** | Include activities accessible at all income levels. Avoid questions assuming access to expensive equipment, travel, or paid programs. Include free/low-cost extracurricular suggestions in AI output |
| **Cultural bias** | Use scenarios relevant across cultures. Avoid culture-specific references. Pilot test with diverse demographic groups. Career professionals should be "knowledgeable about a client's culture" ([NCDA](https://www.ncda.org/aws/NCDA/page_template/show_detail/278313?model_name=news_article)) |
| **Confirmation bias** | Present results as explorative, not definitive. Include disclaimer: "This quiz measures interests, not abilities. Your results are a starting point for exploration, not a final answer" |

---

## Part 8: Annual Retake and Growth Tracking

### Longitudinal Interest Development in Adolescence

Research on vocational interest stability during adolescence provides the scientific basis for annual retake:

- Vocational interests are least stable during adolescence (ages 12-18), then increase substantially during college years ([Illinois meta-analysis](https://education.illinois.edu/docs/default-source/edpsy-documents/epsy-publications/rounds---normative-changes-in-interests-from-adolescence-to-adulthood-a-meta-analysis-of-longitudinal-studies.pdf?sfvrsn=e7e32a9c_2))
- A longitudinal study of adolescents ages 16-18 found interests "remain relatively stable throughout middle adolescence, with minimal changes" but with enough variation to warrant tracking ([InPACT Conference](https://inpact-psychologyconference.org/wp-content/uploads/2024/07/202401OP038.pdf))
- A six-wave longitudinal study tracking 3,023 young adults over 10 years found "substantial changes in mean levels occurred primarily in the context of the transition from high school to university" ([PubMed](https://pubmed.ncbi.nlm.nih.gov/32730064/))

### Growth Tracking Dashboard Design

Each September retake generates a comparison report:

```
╔══════════════════════════════════════════╗
║     INTEREST EVOLUTION: KATHAN P.        ║
╠══════════════════════════════════════════╣
║                                          ║
║  9th Grade (Sept 2024)                   ║
║  ████████████████░░░░ STEM     45%       ║
║  ██████████░░░░░░░░░░ Medical  25%       ║
║  ████████░░░░░░░░░░░░ Business 18%       ║
║  ██░░░░░░░░░░░░░░░░░░ Human.   7%       ║
║  ██░░░░░░░░░░░░░░░░░░ Sports   5%       ║
║                                          ║
║  10th Grade (Sept 2025)                  ║
║  ██████████████░░░░░░ STEM     38%       ║
║  ████████████░░░░░░░░ Medical  30%  ↑    ║
║  ██████░░░░░░░░░░░░░░ Business 15%       ║
║  ████░░░░░░░░░░░░░░░░ Human.  12%  ↑    ║
║  ██░░░░░░░░░░░░░░░░░░ Sports   5%       ║
║                                          ║
║  TREND: Medical interest increasing      ║
║  (+5% YoY). Consider AP Biology and      ║
║  hospital volunteering.                  ║
║                                          ║
╚══════════════════════════════════════════╝
```

### What Year-Over-Year Changes Mean for Planning

| Shift Pattern | Interpretation | Action Item |
|---|---|---|
| Stable top bucket (±5%) across 2+ years | Strong, crystallized interest | Focus college search on this field |
| Gradual shift (5-15% over 2 years) | Evolving but normal for adolescence | Explore intersection of old and new interests |
| Sharp shift (>20% in one year) | May indicate new experience, class, or mentor influence | Investigate what triggered the change; don't abandon prior track |
| Flat profile (all buckets within 5%) | Undifferentiated interests | Broaden exposure; take diverse electives; not unusual for 9th-10th grade |
| Increasing differentiation over time | Healthy career identity crystallization | Expected pattern; student is "finding their lane" |

---

## Part 9: Data Model

### Entity-Relationship Schema

```sql
-- Core student identity
CREATE TABLE students (
    student_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email             VARCHAR(255) UNIQUE NOT NULL,
    first_name        VARCHAR(100) NOT NULL,
    last_name         VARCHAR(100) NOT NULL,
    date_of_birth     DATE,
    grade_level        INTEGER CHECK (grade_level BETWEEN 9 AND 12),
    school_name       VARCHAR(255),
    state             VARCHAR(2),
    created_at        TIMESTAMP DEFAULT NOW(),
    updated_at        TIMESTAMP DEFAULT NOW()
);

-- Student academic profile (updated annually)
CREATE TABLE student_profiles (
    profile_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id        UUID REFERENCES students(student_id),
    academic_year     VARCHAR(9) NOT NULL,  -- e.g., "2025-2026"
    grade_level       INTEGER NOT NULL,
    gpa               DECIMAL(3,2),
    gpa_scale         DECIMAL(3,1) DEFAULT 4.0,
    ap_courses        JSONB,      -- ["AP Biology", "AP Calculus BC"]
    honors_courses    JSONB,
    extracurriculars  JSONB,      -- [{"name": "Robotics Club", "role": "Captain", "years": 2}]
    created_at        TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, academic_year)
);

-- Quiz session metadata
CREATE TABLE quiz_sessions (
    session_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id        UUID REFERENCES students(student_id),
    quiz_version      VARCHAR(20) NOT NULL,    -- "v1.0", "v1.1"
    started_at        TIMESTAMP NOT NULL,
    completed_at      TIMESTAMP,
    completion_seconds INTEGER,
    consistency_score DECIMAL(3,2),            -- 0.00 to 1.00
    stage1_completed  BOOLEAN DEFAULT FALSE,
    stage2_branch     VARCHAR(50),             -- "STEM", "Medical", etc.
    is_valid          BOOLEAN DEFAULT TRUE,
    academic_year     VARCHAR(9) NOT NULL,
    UNIQUE(student_id, academic_year)          -- One valid quiz per year
);

-- Individual question responses
CREATE TABLE question_responses (
    response_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id        UUID REFERENCES quiz_sessions(session_id),
    question_id       VARCHAR(10) NOT NULL,    -- "Q1", "Q2", ..., "Q30"
    question_type     VARCHAR(20) NOT NULL,    -- "scenario", "forced_choice", "likert", "ranking", "time_allocation"
    stage             INTEGER NOT NULL,        -- 1 or 2
    response_value    JSONB NOT NULL,          -- Flexible: "A", [3,1,5,2,4], {"stem":4,"medical":3,...}
    response_seconds  INTEGER,                 -- Time spent on this question
    riasec_scores     JSONB NOT NULL,          -- {"R":2,"I":5,"A":0,"S":1,"E":0,"C":3}
    created_at        TIMESTAMP DEFAULT NOW()
);

-- Computed bucket scores per session
CREATE TABLE bucket_scores (
    score_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id        UUID REFERENCES quiz_sessions(session_id),
    student_id        UUID REFERENCES students(student_id),
    -- Stage 1 bucket percentages
    stem_pct          DECIMAL(5,2) NOT NULL,
    medical_pct       DECIMAL(5,2) NOT NULL,
    business_pct      DECIMAL(5,2) NOT NULL,
    humanities_pct    DECIMAL(5,2) NOT NULL,
    sports_pct        DECIMAL(5,2) NOT NULL,
    -- Raw RIASEC scores
    r_score           INTEGER NOT NULL,
    i_score           INTEGER NOT NULL,
    a_score           INTEGER NOT NULL,
    s_score           INTEGER NOT NULL,
    e_score           INTEGER NOT NULL,
    c_score           INTEGER NOT NULL,
    -- Holland code
    holland_code      VARCHAR(3) NOT NULL,     -- e.g., "IRE"
    -- Top bucket and branch
    top_bucket        VARCHAR(50) NOT NULL,
    second_bucket     VARCHAR(50) NOT NULL,
    -- Sub-specialization scores (Stage 2)
    sub_spec_scores   JSONB,                   -- {"computer_science": 85, "engineering": 72, ...}
    top_sub_specs     JSONB,                   -- ["Computer Science", "Engineering", "Data Science"]
    -- Confidence
    confidence_level  VARCHAR(10) NOT NULL,    -- "High", "Medium", "Low"
    created_at        TIMESTAMP DEFAULT NOW()
);

-- AI-generated personalized results
CREATE TABLE ai_results (
    result_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id        UUID REFERENCES quiz_sessions(session_id),
    student_id        UUID REFERENCES students(student_id),
    ai_model          VARCHAR(50) NOT NULL,    -- "gemini-2.0-flash", etc.
    prompt_version    VARCHAR(20) NOT NULL,
    career_narrative  TEXT NOT NULL,
    major_recommendations JSONB NOT NULL,      -- [{name, description, match_reason, salary, growth}]
    college_suggestions   JSONB NOT NULL,      -- [{name, program, ranking, cost, fit_reason}]
    ap_recommendations    JSONB NOT NULL,      -- [{course, priority, reason}]
    extracurricular_suggestions JSONB NOT NULL, -- [{activity, type, reason}]
    raw_ai_response   TEXT,                    -- Full unstructured AI output
    generated_at      TIMESTAMP DEFAULT NOW()
);

-- Year-over-year growth tracking (materialized view)
CREATE TABLE growth_tracking (
    tracking_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id        UUID REFERENCES students(student_id),
    comparison_year_1 VARCHAR(9) NOT NULL,
    comparison_year_2 VARCHAR(9) NOT NULL,
    stem_delta        DECIMAL(5,2),            -- Percentage point change
    medical_delta     DECIMAL(5,2),
    business_delta    DECIMAL(5,2),
    humanities_delta  DECIMAL(5,2),
    sports_delta      DECIMAL(5,2),
    holland_code_1    VARCHAR(3),
    holland_code_2    VARCHAR(3),
    holland_code_changed BOOLEAN,
    trend_summary     TEXT,                    -- AI-generated trend interpretation
    shift_magnitude   VARCHAR(10),             -- "Stable", "Gradual", "Sharp"
    computed_at       TIMESTAMP DEFAULT NOW()
);

-- Question bank for versioning
CREATE TABLE question_bank (
    question_id       VARCHAR(10) PRIMARY KEY,
    question_text     TEXT NOT NULL,
    question_type     VARCHAR(20) NOT NULL,
    stage             INTEGER NOT NULL,
    branch            VARCHAR(50),             -- NULL for Stage 1, branch name for Stage 2
    options           JSONB NOT NULL,          -- Answer options with RIASEC mappings
    riasec_mapping    JSONB NOT NULL,          -- How each option maps to RIASEC scores
    bucket_mapping    JSONB,                   -- How each option maps to career buckets
    sub_spec_mapping  JSONB,                   -- How each option maps to sub-specializations
    version           VARCHAR(20) NOT NULL,
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_quiz_sessions_student ON quiz_sessions(student_id);
CREATE INDEX idx_quiz_sessions_year ON quiz_sessions(academic_year);
CREATE INDEX idx_bucket_scores_student ON bucket_scores(student_id);
CREATE INDEX idx_question_responses_session ON question_responses(session_id);
CREATE INDEX idx_growth_tracking_student ON growth_tracking(student_id);
```

### Key Query Patterns

```sql
-- Get student's latest results
SELECT bs.*, qs.academic_year, qs.consistency_score
FROM bucket_scores bs
JOIN quiz_sessions qs ON bs.session_id = qs.session_id
WHERE bs.student_id = $1
ORDER BY qs.completed_at DESC
LIMIT 1;

-- Year-over-year comparison
SELECT
    qs.academic_year,
    bs.stem_pct, bs.medical_pct, bs.business_pct,
    bs.humanities_pct, bs.sports_pct,
    bs.holland_code, bs.top_bucket
FROM bucket_scores bs
JOIN quiz_sessions qs ON bs.session_id = qs.session_id
WHERE bs.student_id = $1
ORDER BY qs.academic_year;

-- Aggregate trends across student population
SELECT
    bs.top_bucket,
    COUNT(*) as student_count,
    AVG(bs.stem_pct) as avg_stem,
    AVG(bs.medical_pct) as avg_medical,
    AVG(bs.business_pct) as avg_business
FROM bucket_scores bs
JOIN quiz_sessions qs ON bs.session_id = qs.session_id
WHERE qs.academic_year = '2025-2026'
GROUP BY bs.top_bucket;
```

---

## Part 10: Implementation Roadmap

### Phase 1: MVP (Months 1-3)
- Implement 30-question bank with all 5 question types
- Build Stage 1 → Scoring Gate → Stage 2 branching logic
- Integrate Gemini API for personalization
- Mobile-responsive frontend with progress tracking
- Basic result storage and display

### Phase 2: Validation (Months 3-6)
- Pilot with 200+ students across diverse demographics
- Calculate Cronbach's alpha per bucket and per sub-specialization
- Conduct 2-week test-retest study with 50+ students
- Analyze bias across gender, race, and socioeconomic groups
- Refine question wording based on item analysis

### Phase 3: Growth Tracking (Months 6-9)
- Build annual retake flow with year-over-year comparison
- Implement growth tracking dashboard
- Add AI-generated trend narratives
- Deploy counselor dashboard for school administrators

### Phase 4: Refinement (Ongoing)
- Expand question bank for future versions (reduce memorization on retake)
- A/B test question variants for improved discrimination
- Integrate with college application platforms
- Add parent/counselor co-viewing features

---

## Appendix: Framework Comparison Summary

| Feature | Holland RIASEC | Strong Interest Inventory | Advance CTE Clusters | Our System |
|---|---|---|---|---|
| Dimensions | 6 types | 6 GOTs + 30 BIS + 244 OS | 14 clusters + 72 sub-clusters | 5 buckets + 25 sub-specs |
| Items | 30-180 | 291 | Varies | 30 (adaptive) |
| Time | 5-30 min | 30-50 min | Varies | 5-8 min |
| Age Range | 14+ | 14+ | Grades 4-12 | Grades 9-12 |
| Adaptive | No | No | No | Yes (MST-style) |
| AI Layer | No | No | No | Yes (Gemini) |
| Growth Tracking | No | No | No | Yes (annual) |
| Reading Level | 6th grade | 6th grade | 4th-8th grade | 6th grade |

This design achieves the dual goal of psychometric rigor and practical engagement — a quiz that's short enough for a teenager's attention span, deep enough to produce meaningful differentiation, and smart enough to improve its guidance over four years of high school.
