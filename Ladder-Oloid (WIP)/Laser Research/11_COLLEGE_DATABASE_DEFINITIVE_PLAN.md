# College Database — Definitive Plan
_Based on actual internet research. Every source verified. No Wikipedia._

---

## The Goal

Every accredited US college and university in the app — approximately **6,900 institutions** — with:
- Core stats (name, location, acceptance rate, tuition, SAT/ACT, enrollment)
- A real campus photo
- Application deadlines and requirements
- School colors and logo
- Admissions philosophy label (test-driven, EC-driven, holistic, open-enrollment)

---

## Source 1: College Scorecard API — Core Data (FREE)

**What it is:** The US Department of Education's official college data API. Authoritative. Free.

**URL:** https://collegescorecard.ed.gov/data/api/  
**API key:** Register free at https://api.data.gov/signup/ — key emailed immediately.

**Coverage:** ~6,900 Title IV participating institutions (every college that accepts federal financial aid — this is effectively every real college in America).

**Key data fields available per school:**
- School name, city, state, zip code
- School URL (official website)
- Ownership: public (1), private nonprofit (2), private for-profit (3)
- Acceptance rate (`admissions.admission_rate.overall`)
- Tuition in-state and out-of-state
- SAT scores: 25th/75th percentile, reading/writing/math sections
- ACT composite 25th/75th percentile
- Enrollment size
- Programs offered (CIP codes → can map to major categories)
- Graduation rate, transfer-out rate
- Average debt at graduation
- Percentage of Pell Grant recipients (good first-gen indicator)
- Percentage of first-generation students

**How to pull all schools:**
```
GET https://api.data.gov/ed/collegescorecard/v1/schools?api_key=YOUR_KEY&per_page=100&page=0&fields=school.name,school.city,school.state,admissions.admission_rate.overall,...
```
Paginate through all pages (6,900 / 100 per page = 69 API calls). Takes ~5 minutes total.

**Supabase Edge Function:** Write a one-time seeder that paginates through all pages and inserts/upserts to the `colleges` table.

---

## Source 2: Urban Institute Education Data Portal — Supplement (FREE)

**URL:** https://educationdata.urban.org/documentation/colleges.html

Combines IPEDS + College Scorecard into one clean REST API. No API key required. Best for:
- Historical trend data
- Institutional characteristics not in Scorecard
- CSV bulk download if you want a full offline dataset

---

## Source 3: Campus Photos — Google Places API (New)

**This is the answer to the image problem. No Wikipedia. Accurate, real campus photos.**

**URL:** https://developers.google.com/maps/documentation/places/web-service/place-photos

**How the workflow works:**
1. For each college, call Text Search: `POST https://places.googleapis.com/v1/places:searchText` with body `{"textQuery": "University of Florida campus Gainesville FL"}`
2. Get back a `places[0].photos[]` array with photo resource names
3. Call the Place Photos endpoint for each photo resource name to get the actual image
4. Store the image permanently in **Supabase Storage** (photos are cached — Google's photo names expire)

**Photo quality:** Real Google Maps photos. High resolution. Every major campus has 10–100+ photos. Even small community colleges usually have 3–5.

**Pricing:**
- Text Search: $17 per 1,000 requests
- Place Photos: $7 per 1,000 requests
- For 6,000 schools @ 1 Text Search + 3 photos = $17 + $21 = **$38 per 1,000 schools** → **~$228 total** one-time cost

**Attribution requirement:** Some photos require displaying photographer attribution. Store the `authorAttributions` array with each photo.

**Implementation plan:**
1. Write a Node.js/Python script (runs once) that iterates through all 6,900 colleges
2. For each: Text Search → grab top 3 photo resource names
3. Download each photo → upload to Supabase Storage at `college-images/{collegeId}/hero.jpg`, `thumb.jpg`
4. Store the Supabase Storage URL in the `colleges` table `heroImageURL` field
5. Run this script once. Photos are now stored permanently. Zero ongoing cost.

---

## Source 4: Application Deadlines — Three-Part Strategy

**The problem:** No single free API has all deadlines for all 6,900 schools. Here's how to get them:

### Part A: Common App Schools (~1,000 schools) — FREE PDF Parse
Common App publishes an annual PDF called the "Requirements Grid" with every member school's:
- EA deadline
- ED/ED2 deadline  
- RD deadline
- Application fee
- Testing policy
- Supplemental essays (yes/no)

**URL:** https://content.commonapp.org/files/ReqGrid.pdf (updates each August)

**Action:** Parse this PDF with Firecrawl or Python's pdfplumber library → extract all 1,000 schools' data into JSON → import to Supabase.

This covers the most-applied-to schools: essentially all selective colleges in America use Common App.

### Part B: Non-Common-App Schools — Firecrawl Scraping
**URL:** https://www.firecrawl.dev  
**Pricing:** Standard plan = $83/month for 100,000 credits (1 credit = 1 page)

For Florida public schools and top 500 non-Common-App schools:
- Use Firecrawl's `/extract` endpoint (LLM-powered)
- Input: the college's admissions URL
- Input: a schema: `{ea_deadline, ed_deadline, rd_deadline, application_fee, testing_policy, transcript_requirement}`
- Output: structured JSON
- 500 schools = 500 credits = ~$0.42 (trivial cost on Standard plan)

### Part C: Peterson's Data — Licensed Database
**URL:** https://petersonsdata.com  
**Contact:** data-info@petersons.com

Peterson's has the most complete college data available including deadlines, financial aid deadlines, and enrollment requirements for 4,200+ US schools.

When Ladder has traction or funding: license Peterson's data. Until then, Part A + B covers the schools students actually apply to.

### Part D: Rolling Admissions / Open Enrollment (~4,000 schools)
Most community colleges and vocational schools have no strict deadlines (rolling admissions). For these schools, the app shows: "This school uses rolling admissions — apply as early as possible." No scraping needed.

---

## Source 5: School Colors — Free JSON Data

### NCAA Schools (~1,100):
**URL:** https://github.com/glidej/ncaa-team-colors  
Free JSON. Hex + RGB codes for all NCAA division schools. Import directly.

### Non-NCAA Schools:
Extract primary color automatically from the school's logo using a color extraction algorithm (dominant color from the top of the logo = primary brand color).

---

## Source 6: School Logos

### Apistemic Logos API (Free, Clearbit replacement)
**URL:** https://logos.apistemic.com/  
Works by `.edu` domain lookup:
```
GET https://logos.apistemic.com/logo?domain=ufl.edu
```
Returns the official institutional logo. Works for any school with a `.edu` domain.

### Sports Logos (for schools with athletic programs):
**URL:** https://github.com/abrelsfo/sportsJSON  
Links to ESPN CDN logo files for hundreds of college athletic programs. Good for prototyping — for production, license directly from schools.

---

## Source 7: Admissions Philosophy Labels

This one is Ladder's own AI-generated enrichment (no external API exists for this).

**The 4 labels:**
1. **Test-Driven** — SAT/ACT weighted Very Important (from Common Data Set Section C7)
2. **Extracurricular-Driven** — Extracurricular activities weighted Important/Very Important, test optional
3. **Holistic** — All factors weighted equally
4. **Open Enrollment** — No selective criteria (community colleges, vocational schools)

**How to generate:**
- Pull each school's Common Data Set Section C7 (a PDF published annually by each school's institutional research office)
- Section C7 lists ~20 admissions factors with ratings: Very Important, Important, Considered, Not Considered
- A Gemini Edge Function reads Section C7 → assigns a philosophy label + personality name
- Store as `admissionsPhilosophy` and `personalityArchetype` in the `colleges` table

**Availability:** All accredited schools publish the CDS. Most schools have it linked from their institutional research / Common Data Set page. Firecrawl can find and scrape these PDFs.

---

## Complete Data Schema (Updated CollegeModel)

```swift
@Model
final class CollegeModel {
    // Identity
    var id: String           // College Scorecard UNITID
    var name: String
    var city: String
    var state: String
    var zipCode: String
    var website: String
    
    // Type
    var ownership: Int       // 1=public, 2=private nonprofit, 3=for-profit
    var carnegieCategory: String?  // R1=Research, BAC=Liberal Arts, etc.
    
    // Admissions
    var acceptanceRate: Double?
    var satComposite25: Int?
    var satComposite75: Int?
    var actComposite25: Int?
    var actComposite75: Int?
    var testingPolicy: String?      // "required" | "optional" | "blind"
    var applicationPlatforms: [String]  // ["Common App", "Coalition", "Direct"]
    var eaDeadline: String?
    var edDeadline: String?
    var rdDeadline: String?
    var applicationFee: Int?
    var hasSupplement: Bool
    
    // Costs
    var tuitionInState: Int?
    var tuitionOutOfState: Int?
    var roomAndBoard: Int?
    var averageNetCost: Int?
    
    // Profile
    var enrollmentSize: Int?
    var graduationRate: Double?
    var percentFirstGen: Double?
    var percentPellGrant: Double?
    
    // Visual identity
    var heroImageURL: String?       // Supabase Storage URL (from Google Places)
    var logoURL: String?            // Apistemic Logos
    var primaryColor: String?       // Hex (from ncaa-team-colors or extracted)
    var mascot: String?
    
    // Personality (AI-generated)
    var admissionsPhilosophy: String?  // "test-driven" | "ec-driven" | "holistic" | "open"
    var personalityArchetype: String?  // "The Builder" | "The Achiever" etc.
    var personalityDescription: String?
    var personalityTraits: [String]
    
    // Post-acceptance
    var depositDeadline: String?
    var housingApplicationOpens: String?
    var housingApplicationDeadline: String?
    
    // Meta
    var lastSyncedAt: Date
    var dataQualityTier: Int  // 1=full, 2=partial, 3=basic (College Scorecard only)
}
```

---

## Implementation Timeline

### Week 1: Bootstrap College Data
1. Run College Scorecard seeder Edge Function → 6,900 schools in Supabase
2. Parse Common App Requirements Grid PDF → 1,000 schools get full deadline data
3. Pull Apistemic logos for all schools with .edu domains
4. Import ncaa-team-colors JSON for ~1,100 schools

### Week 2: Photos
1. Run Google Places photo pipeline → 3 photos per school, store in Supabase Storage
2. Manual curation for top 100 most-applied schools (ensure best photo is hero)

### Week 3: Enrichment
1. Firecrawl the top 500 non-Common-App schools for deadlines
2. Run Gemini pipeline on Common Data Set PDFs for top 500 schools → generate personality labels

### Ongoing (Automated):
- Annual: Re-run College Scorecard seeder (new tuition rates, acceptance rates)
- Annual (August): Re-parse Common App Requirements Grid PDF (new deadlines)
- On-demand: AI page generation for colleges added by students that aren't in DB

---

## Cost Summary (One-Time Bootstrap)

| Item | Cost |
|------|------|
| College Scorecard API | Free |
| Google Places photos (6,900 schools × 3 photos) | ~$228 |
| Firecrawl (500 schools enrichment) | ~$0.42 (trivial) |
| Supabase Storage (photos, ~100MB estimated) | Free tier or ~$1/month |
| Apistemic Logos | Free |
| ncaa-team-colors | Free (open source) |
| Common App PDF parse | Free |
| **Total** | **~$230** |

After this one-time run: all 6,900 colleges are in the database with photos, colors, deadlines (for selective schools), and admissions philosophy labels.
