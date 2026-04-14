# LADDER — Business Economics & Subscription Strategy

> **Purpose:** This document is both a business reference for Kathan AND a Claude Code prompt.
> When fed to Claude Code, it provides full context to help make pricing, architecture,
> and business model decisions for Ladder.
>
> **Last updated:** April 13, 2026

---

## 1. WHAT LADDER IS (Elevator Pitch)

Ladder is an iOS college guidance platform that gives every high schooler a personal AI college counselor in their pocket — from 9th grade through acceptance. Career discovery, activity tracking, college research, application management, AI advising, scholarships, and financial aid — all in one app.

**The problem it solves:** Private college counselors cost $3,000–$10,000+ per student. Public school counselors have 400:1 student ratios. First-gen and low-income students get almost no guidance. Ladder democratizes what rich families pay thousands for.

**Key differentiator:** Ladder starts in **9th grade**, not 11th. The ConnectionEngine personalizes everything — career path drives activity suggestions, GPA drives match/reach/safety calculations, grade level gates features appropriately. It's not a static college search tool — it's a 4-year guidance system.

---

## 2. MARKET SIZE (TAM / SAM / SOM)

### Total Addressable Market (TAM)
- **~16.5 million** US high school students (grades 9–12) at any given time
- **~3.7 million** graduate per year
- **61%** of graduates enroll in college immediately (~2.3M/year)
- If you include the 4-year journey: **16.5M students × $10/mo avg = ~$2B/year** theoretical max

### Serviceable Addressable Market (SAM)
- College-bound students with smartphones who would pay for guidance
- **~9.5 million** students across grades 9–12 are college-bound
- Realistic pricing: **9.5M × $8/mo avg = ~$912M/year**

### Serviceable Obtainable Market (SOM) — Year 1–3 targets
| Year | Users (free + paid) | Paid users | Revenue |
|------|-------------------|------------|---------|
| Year 1 | 10,000 | 1,500 (15% conversion) | ~$144K |
| Year 2 | 50,000 | 10,000 (20% conversion) | ~$960K |
| Year 3 | 200,000 | 50,000 (25% conversion) | ~$4.8M |

**Why these are realistic:** CollegeVine has millions of users but monetizes through tutoring ($40–$100/hr). Ladder's subscription model at $8/mo is far cheaper than any alternative, making conversion achievable.

---

## 3. COMPETITIVE LANDSCAPE

| Competitor | Model | Pricing | What They Do | Ladder's Edge |
|-----------|-------|---------|--------------|---------------|
| **CollegeVine** | Freemium + tutoring | Free chancing tool; tutoring $40–$100/hr | Chancing calculator, essay review, peer advising | Ladder starts 9th grade, full 4-yr journey, AI-native |
| **Going Merry** | Free (scholarship-funded) | Free | Scholarship search + applications | Ladder is comprehensive — not just scholarships |
| **Niche** | Free + ads | Free | College rankings, reviews, search | Ladder is personalized + actionable, not just browsing |
| **Private Counselors** | Fee-for-service | $3,000–$10,000+ per student | Full-service human counseling | Ladder is 100x cheaper, available 24/7, scales |
| **Common App** | Free | Free | Application portal only | Ladder guides the ENTIRE journey, not just submission |
| **Scoir** | B2B (school-sold) | School pays ~$5–$15/student | College/career planning for schools | Ladder is B2C (direct to student), AI-first |

**Key insight:** No one owns the "personal AI counselor" space for high schoolers. CollegeVine is closest but monetizes through human tutors, not AI. The market is wide open for a subscription AI product.

---

## 4. INFRASTRUCTURE COSTS (Per User, Per Month)

### AWS Stack Costs

| Service | Free Tier | Cost at 10K MAU | Cost at 50K MAU | Cost at 200K MAU |
|---------|-----------|-----------------|-----------------|------------------|
| **Cognito** (auth) | 10K MAU free | $0 | $198/mo ($0.004/user) | $950/mo |
| **Lambda** (API logic) | 1M requests free | ~$5/mo | ~$30/mo | ~$150/mo |
| **DynamoDB** (database) | 25 GB + 25 WCU/RCU free | ~$15/mo | ~$80/mo | ~$400/mo |
| **S3** (storage, transcripts) | 5 GB free | ~$5/mo | ~$25/mo | ~$100/mo |
| **CloudFront** (CDN) | 1 TB free | ~$0 | ~$10/mo | ~$50/mo |
| **Total AWS** | | **~$25/mo** | **~$343/mo** | **~$1,650/mo** |

### Gemini AI API Costs

Assuming average user sends **~30 AI messages/month**, each ~500 tokens in + ~800 tokens out:

| Model | Input cost/1M tokens | Output cost/1M tokens | Cost per user/mo | 10K users | 50K users |
|-------|---------------------|----------------------|-----------------|-----------|-----------|
| **Gemini 2.5 Flash** (recommended) | $0.50 | $3.00 | **~$0.05** | $500/mo | $2,500/mo |
| **Gemini 2.5 Pro** (premium tier) | $1.25 | $10.00 | **~$0.26** | $2,600/mo | $13,000/mo |
| **Gemini 2.5 Flash-Lite** (free tier) | $0.10 | $0.40 | **~$0.01** | $100/mo | $500/mo |

**Strategy:** Use Flash-Lite for free tier, Flash for paid tier, Pro only for premium essay review / deep advising sessions.

### College Scorecard API
- **Free** — government API, no cost
- Rate limit: 1,000 requests/IP/hour (can request increase)
- Cache college data locally — only refresh weekly/monthly

### Total Cost Per User Per Month

| Tier | AWS share | AI cost | Total COGS/user |
|------|-----------|---------|-----------------|
| **Free user** | ~$0.003 | ~$0.01 (Flash-Lite, 10 msgs) | **~$0.013** |
| **Paid user (Standard)** | ~$0.007 | ~$0.05 (Flash, 30 msgs) | **~$0.057** |
| **Paid user (Premium)** | ~$0.010 | ~$0.15 (Flash + some Pro) | **~$0.16** |

**This is insanely good margin.** Even the premium tier costs ~$0.16/user/month to serve.

---

## 5. SUBSCRIPTION TIERS & PRICING

### Recommended 3-Tier Model

#### FREE — "Explorer"
**Price: $0/month**
- College search & discovery (full database)
- Basic career quiz (one-time)
- Dashboard with grade-appropriate milestones
- 10 AI advisor messages/month (Flash-Lite model)
- Browse scholarships
- Basic graduation requirement tracker
- **Purpose:** Get users hooked. Build habit from 9th grade. Convert later.

#### STANDARD — "Climber"
**Price: $7.99/month or $59.99/year ($5/mo effective)**
- Everything in Free, plus:
- **Unlimited AI advisor** (Flash model, context-aware with full profile)
- ConnectionEngine: personalized activity suggestions based on career path
- Match/Reach/Safety college sorting with chances calculator
- Application tracker with auto-generated checklists
- Essay Hub with AI writing feedback
- Deadline calendar synced to saved colleges
- Financial aid comparison tool
- Post-acceptance checklist automation
- **Target:** 11th–12th graders actively applying

#### PREMIUM — "Summit"
**Price: $14.99/month or $99.99/year ($8.33/mo effective)**
- Everything in Standard, plus:
- **AI essay review** powered by Gemini Pro (deep, detailed feedback)
- **Mock interview** with AI (voice recording + analysis)
- **Transcript upload + AI parse** → auto-update profile
- Priority AI responses (Pro model for complex questions)
- PDF portfolio export
- Parent view access
- **Target:** Serious applicants, families who would've considered a private counselor

### Why This Pricing Works

| Comparison | Cost | Ladder equivalent |
|-----------|------|-------------------|
| Private counselor (basic) | $3,000–$5,000 total | Ladder Premium for 4 years = **$400** |
| CollegeVine tutoring | $40–$100/hour | Ladder Standard for a year = **$60** (unlimited AI) |
| College app boot camp | $500–$2,000 | Ladder Premium for 1 year = **$100** |

Ladder is **10–50x cheaper** than every alternative. This is the pitch.

---

## 6. UNIT ECONOMICS

### At 10,000 users (Year 1 target)

| Metric | Value |
|--------|-------|
| Total users | 10,000 |
| Free users (85%) | 8,500 |
| Paid Standard (12%) | 1,200 |
| Paid Premium (3%) | 300 |
| **Monthly revenue** | (1,200 × $7.99) + (300 × $14.99) = **$14,085/mo** |
| **Annual revenue** | **~$169K** (assumes some annual plans at discount) |
| Monthly AWS cost | ~$25–50 |
| Monthly AI cost | ~$600 |
| **Monthly COGS** | **~$650** |
| **Gross margin** | **95.4%** |

### At 50,000 users (Year 2 target)

| Metric | Value |
|--------|-------|
| Free users (80%) | 40,000 |
| Paid Standard (15%) | 7,500 |
| Paid Premium (5%) | 2,500 |
| **Monthly revenue** | (7,500 × $7.99) + (2,500 × $14.99) = **$97,400/mo** |
| **Annual revenue** | **~$1.17M** |
| Monthly AWS cost | ~$343 |
| Monthly AI cost | ~$4,100 |
| **Monthly COGS** | **~$4,443** |
| **Gross margin** | **95.4%** |

### At 200,000 users (Year 3 target)

| Metric | Value |
|--------|-------|
| Free users (75%) | 150,000 |
| Paid Standard (18%) | 36,000 |
| Paid Premium (7%) | 14,000 |
| **Monthly revenue** | (36,000 × $7.99) + (14,000 × $14.99) = **$497,500/mo** |
| **Annual revenue** | **~$5.97M** |
| Monthly AWS cost | ~$1,650 |
| Monthly AI cost | ~$20,000 |
| Apple's 30% cut (App Store) | ~$149,250/mo |
| **Monthly COGS (incl Apple)** | **~$170,900** |
| **Gross margin** | **65.6%** (after Apple cut) |

> **Note on Apple's 30% cut:** This is the single biggest cost. Strategies to mitigate:
> - Offer web-based sign-up (bypasses Apple for subscriptions initiated on web)
> - After Year 1, Apple drops to 15% for subscriptions renewed past 12 months
> - Year 3 effective Apple rate is likely ~20% blended, pushing margin back to ~75%

---

## 7. KEY METRICS TO TRACK

| Metric | What it measures | Target |
|--------|-----------------|--------|
| **MAU** | Monthly active users | Growth rate >15% MoM early |
| **Free → Paid conversion** | % of free users who subscribe | 15–25% |
| **Churn rate** | % of paid users who cancel monthly | <5% monthly |
| **LTV (Lifetime Value)** | Revenue per user over their lifetime | $80–$200 |
| **CAC (Customer Acquisition Cost)** | Cost to acquire one user | <$5 (organic/viral target) |
| **LTV:CAC ratio** | Sustainability metric | >5:1 |
| **AI messages/user/month** | Engagement depth | 15–40 |
| **DAU/MAU ratio** | Stickiness | >30% |
| **NPS** | Would you recommend Ladder? | >50 |

### LTV Calculation

Average paid user stays **18 months** (covers junior + senior year):
- Standard: $7.99 × 18 = **$143.82 LTV**
- Premium: $14.99 × 18 = **$269.82 LTV**
- Blended (75/25 split): **$175.32 LTV**

If CAC is $3–5 (organic/word-of-mouth/TikTok): **LTV:CAC = 35:1 to 58:1** — exceptional.

---

## 8. GO-TO-MARKET STRATEGY

### Phase 1: Organic + Community (Year 1)
- **TikTok/Instagram Reels:** "Things your counselor won't tell you" content series
- **High school partnerships:** Free tier for entire schools (counselors share it)
- **Reddit/Discord:** r/ApplyingToCollege, college prep Discord servers
- **Word of mouth:** Students tell friends — inherently viral in friend groups
- **Cost:** Near zero. Your time + content creation.

### Phase 2: B2B2C Channel (Year 2)
- Sell to school districts: "Give every student a counselor for $2/student/year"
- Counselor portal (Sprint 4 feature) enables this
- School buys → students get Standard tier free → upgrades to Premium are B2C
- **This is where real scale comes from**

### Phase 3: Partnerships (Year 3)
- College Board, ACT, FAFSA integration partnerships
- Content partnerships with scholarship providers
- White-label for college prep companies

---

## 9. REVENUE STREAMS BEYOND SUBSCRIPTIONS

| Stream | How it works | When to add |
|--------|-------------|-------------|
| **B2B School Licenses** | Schools pay $2–5/student/year for Standard access | Year 2 |
| **College Advertising** | Colleges pay to be featured/promoted in discovery | Year 2–3 |
| **Scholarship Matching Fees** | Scholarship providers pay per qualified applicant referred | Year 2 |
| **Premium Content** | One-time purchases: essay templates, interview prep packs | Year 1 |
| **Data Insights (Anonymized)** | Aggregate trends sold to colleges/researchers | Year 3+ |

---

## 10. FINANCIAL PROJECTIONS SUMMARY

| | Year 1 | Year 2 | Year 3 |
|---|--------|--------|--------|
| **Total Users** | 10,000 | 50,000 | 200,000 |
| **Paid Users** | 1,500 | 10,000 | 50,000 |
| **ARR** | $169K | $1.17M | $5.97M |
| **COGS** | $7.8K | $53K | $2.05M |
| **Gross Profit** | $161K | $1.12M | $3.92M |
| **Gross Margin** | 95% | 95% | 66% (Apple cut) |
| **Operating Costs*** | ~$20K | ~$100K | ~$500K |
| **Net Profit** | ~$141K | ~$1.02M | ~$3.42M |

*Operating costs = marketing, App Store fees (Year 1–2 under Small Business Program at 15%), potential contractor/part-time help

---

## 11. RISKS & MITIGATIONS

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Apple's 30% cut** | Eats margin at scale | Web sign-up flow, 15% rate after Year 1 renewal |
| **AI cost spikes** | Gemini pricing could increase | Cache common responses, use Flash-Lite aggressively, set message limits |
| **Low conversion** | Free users don't upgrade | Gate high-value features (essay review, unlimited AI) behind paywall |
| **Competition** | CollegeVine or a big player copies this | First-mover on AI-native + 9th grade start. Ship fast. |
| **College Scorecard shutdown** | DOE defunds the API | Cache full database locally, scrape alternatives |
| **Churn after acceptance** | Users leave after getting into college | Add post-acceptance features (housing, roommate, orientation) |
| **Regulatory (COPPA/FERPA)** | Under-13 data, student privacy | Age gate already built, parental consent flow in roadmap |

---

## 12. THE PITCH (One-Liner Options)

Pick your favorite:

1. **"Ladder gives every high schooler a $5,000 college counselor for $8/month."**
2. **"We're building the Duolingo of college guidance — start in 9th grade, get accepted in 12th."**
3. **"Private counselors charge $10K. School counselors are overwhelmed. Ladder is the AI counselor that's always available, always personalized, and costs less than Netflix."**

---

## 13. CLAUDE CODE INSTRUCTIONS

When working on Ladder business decisions, use these rules:

1. **Always optimize for the free → paid conversion funnel.** Every feature should either hook free users or justify the paid upgrade.
2. **Cost per AI message matters.** Default to Flash-Lite for free tier, Flash for Standard, Pro only for Premium essay/interview features.
3. **Cache everything possible.** College data, common AI responses, state requirements — don't re-fetch what doesn't change.
4. **The 9th-grade hook is the moat.** Features that make 9th/10th graders open the app weekly (activity suggestions, streak, career exploration) are MORE important than 12th-grade features for long-term business value.
5. **B2B is the real growth lever.** Design the counselor portal and school admin features with eventual B2B licensing in mind.
6. **Apple's cut is the #1 margin threat.** Always consider web-based payment flows.
7. **Track these numbers in the app:** MAU, messages sent, features used per tier, conversion triggers (what action preceded an upgrade).

---

*This document should be treated as a living reference. Update pricing and costs as actual usage data comes in. The numbers above are estimates based on published API pricing and market research as of April 2026.*
