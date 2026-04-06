# College Database Strategy
_Sourced from: college_requirements_research.md, college_requirements_db.json, florida_colleges_admissions.json, Export text - IMG8189.MOV, Export text - IMG8203.MOV_

---

## Current State (The Problem)

The `florida_colleges_admissions.json` database has **6 colleges** with mostly blank fields:
- University of Florida (UF) — has EA deadline + testing notes
- Florida State University (FSU) — completely blank
- University of South Florida (USF) — only RD deadline
- Rochester Institute of Technology (RIT) — test optional, no deadlines
- University of Tampa (UT) — completely blank
- Florida International University (FIU) — completely blank

The app needs **6,500+ institutions** with rich data and images. This is the #1 gap between the current build and a usable product.

---

## Data Tiers

### Tier 1: All US Colleges (6,500+)
**Source:** US Department of Education College Scorecard API (free, no auth required)
**Endpoint:** `https://api.data.gov/ed/collegescorecard/v1/schools`
**Key fields available:**
- School name, city, state, zip
- School URL, school type (public/private)
- Acceptance rate (`admissions.admission_rate.overall`)
- Enrollment size
- In-state / out-of-state tuition
- Average SAT (total + by section)
- Average ACT
- Completion rates
- Financial aid data (average debt, Pell grant %first-gen %)
- Programs/CIP codes (what majors are offered)

**What to do:** Seed the Supabase `colleges` table with all 6,500+ records via a one-time Edge Function that paginates through the API (100 records per call).

### Tier 2: Top 500 Enrichment
**Source:** Firecrawl scraping of public admissions pages
**Fields to add:**
- Application platforms (Common App, Coalition, Direct)
- Early Action / Early Decision deadlines
- Regular Decision deadline
- Testing policy (test-required / test-optional / test-blind)
- Transcript submission method (STARS for UF, self-reported, official)
- Supplemental essay requirements (yes/no + count)
- Application fee
- College-specific portal name (e.g., "Gator Portal" for UF)

### Tier 3: Florida Focus (Priority)
Start with Florida public universities + popular out-of-state choices for Florida students:
- UF, FSU, USF, FIU, UCF, FAU, FGCU, UNF, FIU, New College, UM, UT
- Popular national targets: RIT, Penn State, Georgia Tech, Ohio State, NYU, Boston University, Michigan

---

## College Images

**The problem:** College Scorecard has no images. The Stitch designs show beautiful campus hero photos.

**Solution stack:**
1. **Unsplash:** Each college name mapped to a search query. Unsplash API is free for development. Licensing for production requires Unsplash Pro or alternative.
2. **Wikipedia/Wikimedia Commons:** Most schools have a main image on their Wikipedia page. Wikipedia API can fetch the main image URL for any school. License: Creative Commons (usually free to use).
3. **Manual curation:** For the top 100 schools, manually save curated hero images to Supabase Storage. Use consistent aspect ratio (16:9 hero + 1:1 thumbnail).
4. **Fallback:** Generated gradient using primary school color + initials (e.g., "UF" on a blue gradient). School colors can be sourced from schoolcolors.com or similar.

**CollegeModel update needed:**
```swift
var heroImageURL: String?      // Supabase Storage URL or Wikipedia image URL
var thumbnailImageURL: String?  // Smaller square crop
var primaryColor: String?       // Hex color for fallback gradient (e.g., "#003087" for UF)
var secondaryColor: String?     // Accent color
```

---

## AI-Generated College Pages

**The vision (from IMG8189 transcript):** If a student adds a college not in the database, AI auto-creates a page.

**Implementation:**

1. Student types in college name not in DB
2. App shows: "We don't have [College Name] yet. Want us to build a page for it? (takes ~30 seconds)"
3. Supabase Edge Function is called with the college name
4. Edge Function uses Firecrawl to scrape the college's admissions site
5. Gemini parses the scraped content → extracts: deadlines, portal name, testing policy, checklist
6. Creates a `CollegeModel` record in the database
7. This new page is now shared globally — the next student who adds that college gets the pre-built page

**Key insight from transcript:**
> "If the RIT page was already created, the next student just uses that page. It doesn't create a whole new thing."

This is a crowdsourced enrichment loop. Every student who adds a new college improves the database for all future students.

---

## Post-Acceptance Checklist System

**Two-phase checklists per college:**

### Phase 1: Pre-Admission Application Checklist
Generic to all colleges, customized by:
- Testing policy (add "Submit SAT scores" if required)
- Specific platform (STARS link for UF, specific portal for others)
- Supplemental essay count

**Standard items:**
- [ ] Create Common App account (or college-specific portal)
- [ ] Request official transcripts from school counselor
- [ ] Submit SAT/ACT scores to college (if required)
- [ ] Complete and submit application before deadline
- [ ] Write and submit supplemental essays (if applicable)
- [ ] Request letters of recommendation (2+ weeks in advance)
- [ ] Apply for financial aid / FAFSA
- [ ] Pay application fee (or submit fee waiver)

### Phase 2: Post-Acceptance Enrollment Checklist
Triggered when student marks application status as "Accepted."

**Standard items (customized per school):**
- [ ] Pay enrollment deposit (commit to attending) — DEADLINE: varies, check portal
- [ ] Submit official final transcript (school sends with seal, after graduation)
- [ ] Submit immunization records
- [ ] Apply for housing (separate deadline, often earlier than general enrollment)
- [ ] Accept/decline financial aid award letter
- [ ] Set up student email and login credentials
- [ ] Register for orientation
- [ ] Take placement tests (math, foreign language)
- [ ] Confirm your major / intended program
- [ ] Sign up for meal plan

**Key insight from transcript:**
> "The post-acceptance checklists have no deadlines listed. Students have no clue what order to do it in. We generalize where we can't automate: 'Pay deposit' even if we don't know the exact amount."

**Crowdsourcing enrichment:** When students forward their acceptance emails or upload screenshots of their admitted student portal, AI parses the specific deadlines and items, enriching the template for that college.

---

## Data Update Strategy

| Cadence | What updates |
|---------|-------------|
| Daily | Cached college pages in SwiftData (delta sync via `lastSyncedAt`) |
| Weekly | Firecrawl re-scrape of top 500 admissions pages (deadline changes) |
| Annually | Full College Scorecard re-seed (new tuition rates, acceptance rates) |
| On-demand | AI generates page when student adds unlisted college |

---

## College Personality Profiles (The Key Feature)

Each college gets an AI-generated "personality" based on:
1. **Common Data Set Section C7** — each school rates 20+ admission factors (Very Important / Important / Considered / Not Considered)
2. **Admissions page language** — tone, values, emphasis
3. **Student body demographics** — first-gen %, diversity, geographic spread

**Output:** A named archetype + traits (like Myers-Briggs for colleges):
- UF = "The Achiever" — test-score driven, high GPA bar, large campus energy
- RIT = "The Builder" — extracurricular-driven, portfolio/project emphasis, co-op culture
- NYU = "The City Dweller" — global perspective, arts & culture, urban immersion
- MIT = "The Pioneer" — pure intellectual rigor, research-first, innovation

This transforms how students choose colleges — not just stats, but fit.
