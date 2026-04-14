# CLAUDE CODE PROMPT — Ladder Business Economics Helper

> **How to use this file:** Paste this entire document into Claude Code as context.
> Then ask it questions like:
> - "Walk me through how much it costs to run one user"
> - "Help me figure out what to charge"
> - "What's the best business model for Ladder?"
> - "Explain unit economics to me like I'm an engineer"
> - "How much money can Ladder realistically make in Year 1?"

---

## YOUR ROLE

You are helping **Kathan (17, high school senior, software engineer)** understand the business economics of his iOS app **Ladder**. He is NOT from a business/economics background — he's an engineer. 

**Rules for how you explain things:**
1. Use engineering analogies. If you're explaining margin, compare it to efficiency. If you're explaining CAC, compare it to the cost of a function call. Make it click for an engineer's brain.
2. Never use business jargon without immediately explaining it in plain English.
3. Show the MATH. Kathan trusts numbers, not hand-wavy statements. Always show: `input × rate = output`.
4. Use tables and code-style formatting — he reads those faster than paragraphs.
5. Be honest about uncertainty. Say "this is a guess" vs "this is a fact from research."
6. When he asks "what should I charge?" — don't just give a number. Walk him through HOW you'd figure it out, so he can reason about it himself.

---

## WHAT LADDER IS

Ladder is an iOS college guidance app (SwiftUI, iOS 17+). Think: AI college counselor in your pocket.

**What it does:**
- Career discovery quiz → personalized activity suggestions
- College search with Match/Reach/Safety sorting (based on GPA + SAT)
- Application tracker with auto-generated checklists
- AI advisor (Gemini API) that knows the student's full profile
- Essay hub, scholarship search, financial aid comparison
- Grade-gated features (9th graders see different stuff than 12th graders)
- 4-year journey from 9th grade through acceptance

**Tech stack:**
- iOS native (SwiftUI + SwiftData)
- AWS backend (Cognito auth, Lambda, DynamoDB, S3)
- Google Gemini API for AI features
- College Scorecard API (free, government data)

**Current state:** 209 files, ~48K lines, 145+ features built, 4 core engines working. Not yet on the App Store.

---

## THE MARKET (Who Would Pay For This)

**The problem Ladder solves:**
- Private college counselors cost $3,000–$10,000+ per student
- Public school counselors have 400:1 student ratios (basically useless for personalized advice)
- First-gen and low-income students get almost no guidance
- Existing apps (CollegeVine, Niche) are either just search tools or monetize through expensive human tutors

**How many potential customers exist:**
- ~16.5 million US high school students (grades 9–12) at any time
- ~3.7 million graduate each year
- ~61% of graduates go to college (~2.3 million/year)
- College-bound students across all 4 grades: ~9.5 million

**Competitors and what they charge:**

```
CollegeVine    → Free chancing tool, then $40-100/hr for human tutors
Going Merry    → Free (scholarship-only platform)
Niche          → Free (ad-supported college reviews)
Scoir          → Sold to schools at ~$5-15/student (B2B)
Private counselors → $3,000-$10,000+ per student
Common App     → Free (just the application portal, no guidance)
```

**Key gap in the market:** Nobody offers an AI-native, personalized, 4-year guidance subscription. That's Ladder's lane.

---

## WHAT IT COSTS TO RUN LADDER (The Server Bill)

These are real numbers from published pricing as of April 2026.

### AWS Costs (per month, at different scales)

```
Service          | 10K users  | 50K users  | 200K users
-----------------|------------|------------|------------
Cognito (auth)   | $0 (free)  | $198       | $950
Lambda (APIs)    | ~$5        | ~$30       | ~$150
DynamoDB (DB)    | ~$15       | ~$80       | ~$400
S3 (file storage)| ~$5        | ~$25       | ~$100
CloudFront (CDN) | ~$0        | ~$10       | ~$50
-----------------|------------|------------|------------
TOTAL AWS        | ~$25/mo    | ~$343/mo   | ~$1,650/mo
```

**Per user:** At 10K users, AWS costs about $0.0025/user/month (basically nothing).

### AI Costs (Gemini API)

Assumption: average user sends ~30 AI messages/month. Each message is ~500 tokens in, ~800 tokens out.

```
Model               | Cost per 1M input tokens | Cost per 1M output tokens | Cost per user/month
---------------------|--------------------------|---------------------------|--------------------
Gemini 2.5 Flash-Lite| $0.10                    | $0.40                     | ~$0.01
Gemini 2.5 Flash     | $0.50                    | $3.00                     | ~$0.05
Gemini 2.5 Pro       | $1.25                    | $10.00                    | ~$0.26
```

**Strategy:** Use the cheap model (Flash-Lite) for free users, the mid model (Flash) for paid users, and the expensive model (Pro) only for premium features like essay review.

### College Scorecard API
- **Completely free** — it's a government API
- Cache the data locally so you barely hit it

### Total cost to serve ONE user per month

```
User type          | AWS share | AI cost | TOTAL cost to serve
-------------------|-----------|---------|--------------------
Free user          | $0.003    | $0.01   | ~$0.013/month
Paid (Standard)    | $0.007    | $0.05   | ~$0.057/month  
Paid (Premium)     | $0.010    | $0.15   | ~$0.16/month
```

**Translation:** It costs you about 1-2 CENTS to serve a free user and about 6-16 CENTS to serve a paid user. This is extremely cheap.

---

## PRICING OPTIONS TO EXPLORE WITH KATHAN

When Kathan asks "what should I charge?" — walk him through this decision tree:

### Step 1: What are people ALREADY paying for this kind of help?
```
Private counselor (budget)     = $3,000-$5,000 total (~$125-$210/month over 2 years)
CollegeVine tutoring           = $40-$100/hour
SAT prep courses               = $500-$2,000
College app boot camps         = $500-$2,000
Netflix (the "would I pay this monthly?" anchor) = $15.49/month
Spotify                        = $11.99/month
```

### Step 2: Where should Ladder sit?
Ladder needs to be:
- WAY cheaper than a private counselor (that's the whole point)
- Cheap enough that a high schooler can convince their parents
- Expensive enough to actually make money
- In the "yeah I'd pay that" zone ($5-$15/month range)

### Step 3: Recommended tiers to discuss

```
FREE ("Explorer")     — $0/month
  - College search (full database)
  - Basic career quiz
  - Dashboard + milestones
  - 10 AI messages/month (cheap model)
  - Scholarship browsing
  → PURPOSE: Get users hooked. Build the habit. Convert them later.

STANDARD ("Climber")  — $7.99/month  OR  $59.99/year ($5/mo)
  - Everything free, plus:
  - Unlimited AI advisor (good model)
  - Personalized activity suggestions
  - Match/Reach/Safety sorting
  - Application tracker + checklists
  - Essay hub with AI feedback
  - Deadline calendar
  - Financial aid comparison
  → PURPOSE: The main money-maker. Targets 11th-12th graders.

PREMIUM ("Summit")    — $14.99/month  OR  $99.99/year ($8.33/mo)
  - Everything standard, plus:
  - Deep AI essay review (best model)
  - Mock interview with AI
  - Transcript upload + AI parse
  - PDF portfolio export
  - Parent view
  → PURPOSE: For families who would've considered a private counselor.
```

### The pitch comparison:
```
4 years of Ladder Premium = ~$400
vs.
1 engagement with a private counselor = $3,000-$10,000

Ladder is 10-25x cheaper.
```

---

## UNIT ECONOMICS (Explained for Engineers)

Think of unit economics like profiling your code — you're measuring the cost and value of each "unit" (one user, one transaction, one month).

### The key numbers:

**COGS (Cost of Goods Sold)** = what it costs you to serve one paid user
- Think of it like: the compute cost of running one instance of your app for one user
- For Ladder: ~$0.06-$0.16/user/month

**Revenue per user** = what one paid user pays you
- Standard: $7.99/month
- Premium: $14.99/month

**Gross margin** = (revenue - COGS) / revenue × 100
- Standard: ($7.99 - $0.06) / $7.99 = **99.2% margin**
- Premium: ($14.99 - $0.16) / $14.99 = **98.9% margin**
- This is insanely high. Most SaaS companies dream of 80%.

**BUT WAIT — Apple takes a cut:**
- Year 1: Apple takes **30%** of every in-app subscription
- Year 2+: Apple drops to **15%** for subscriptions that renew past 12 months
- If you make <$1M/year: Apple's Small Business Program = only **15%** from day 1

**Margin AFTER Apple (Small Business Program):**
- Standard: $7.99 × 0.85 = $6.79 to you. Minus $0.06 COGS = **$6.73 profit/user/month**
- Premium: $14.99 × 0.85 = $12.74 to you. Minus $0.16 COGS = **$12.58 profit/user/month**

**LTV (Lifetime Value)** = how much money one user gives you over their entire time using the app
- Average college-bound student uses an app like this for ~18 months (junior + senior year)
- Standard LTV: $7.99 × 18 = $143.82
- Premium LTV: $14.99 × 18 = $269.82
- After Apple's 15% cut: Standard = $122.25, Premium = $229.35

**CAC (Customer Acquisition Cost)** = how much you spend to get one new user
- If you're doing organic growth (TikTok, word of mouth, school partnerships): ~$0-$3
- If you're running paid ads: ~$5-$15
- Target: keep CAC under $5

**LTV:CAC ratio** = the "is this business worth running?" number
- Rule of thumb: >3:1 is good, >5:1 is great
- Ladder at organic CAC of $3: $122 / $3 = **40:1** — this is exceptional

**Conversion rate** = what % of free users become paid users
- Industry average for freemium apps: 2-5%
- Good freemium with strong value gate: 10-15%
- Ladder target: 15-25% (because the free→paid value jump is huge)

**Churn rate** = what % of paid users cancel each month
- Good SaaS: <5% monthly churn
- Ladder advantage: students NEED this during application season, natural retention

---

## REVENUE PROJECTIONS AT DIFFERENT SCALES

### Scenario: 10,000 total users (realistic Year 1)

```
Free users (85%):      8,500  → cost to serve: 8,500 × $0.013 = $110/mo
Paid Standard (12%):   1,200  → revenue: 1,200 × $7.99 = $9,588/mo
Paid Premium (3%):       300  → revenue: 300 × $14.99 = $4,497/mo

TOTAL monthly revenue: $14,085
Apple's 15% cut:       -$2,113
AWS + AI costs:        -$760
────────────────────────────────
NET monthly profit:    $11,212/mo
ANNUAL profit:         ~$134,500/year
```

### Scenario: 50,000 total users (Year 2)

```
Free users (80%):      40,000 → cost: $520/mo
Paid Standard (15%):    7,500 → revenue: $59,925/mo
Paid Premium (5%):      2,500 → revenue: $37,475/mo

TOTAL monthly revenue: $97,400
Apple's 15% cut:       -$14,610
AWS + AI costs:        -$4,443
────────────────────────────────
NET monthly profit:    $78,347/mo
ANNUAL profit:         ~$940,000/year
```

### Scenario: 200,000 total users (Year 3)

```
Free users (75%):     150,000 → cost: $1,950/mo
Paid Standard (18%):   36,000 → revenue: $287,640/mo
Paid Premium (7%):     14,000 → revenue: $209,860/mo

TOTAL monthly revenue:  $497,500
Apple's cut (~20% blended): -$99,500
AWS + AI costs:         -$21,650
────────────────────────────────
NET monthly profit:     $376,350/mo
ANNUAL profit:          ~$4,516,000/year
```

---

## BUSINESS MODEL OPTIONS (Help Kathan Decide)

When Kathan asks "what's the best business model?" — walk through these options:

### Option A: Pure B2C Subscription (RECOMMENDED TO START)
```
How:    Students/parents pay monthly/yearly via App Store
Pros:   Simple, direct, you control everything
Cons:   Apple takes 15-30%, have to market to individual students
Best for: Year 1-2
```

### Option B: B2B2C (Schools Buy, Students Use)
```
How:    Sell to school districts at $2-5/student/year
        Students get Standard tier free, can upgrade to Premium themselves
Pros:   Massive scale (one sale = 500+ students), recurring revenue
Cons:   Long sales cycles, need counselor portal feature built
Best for: Year 2-3
```

### Option C: Freemium + Premium Content
```
How:    Free app + one-time purchases (essay template packs, interview prep)
Pros:   Lower friction than subscription, no Apple recurring cut
Cons:   Less predictable revenue, harder to forecast
Best for: Supplementary revenue stream alongside subscriptions
```

### Option D: Hybrid (RECOMMENDED LONG-TERM)
```
How:    B2C subscriptions + B2B school licenses + premium content
Pros:   Multiple revenue streams, diversified risk
Cons:   More complex to manage
Best for: Year 2+
```

**Kathan's recommended path:**
1. Launch with Option A (B2C subscription, 3 tiers)
2. Add Option C (premium content packs) in Year 1
3. Build counselor portal and add Option B (B2B) in Year 2
4. Evolve into Option D (hybrid) by Year 3

---

## ADDITIONAL REVENUE STREAMS TO EXPLORE

```
Stream                    | How it works                           | When
--------------------------|----------------------------------------|-------
School/district licenses  | Schools pay $2-5/student/year          | Year 2
College advertising       | Colleges pay to be featured            | Year 2-3
Scholarship referrals     | Scholarship providers pay per lead     | Year 2
Premium content packs     | One-time: essay templates, etc.        | Year 1
Anonymized data insights  | Aggregate trends for researchers       | Year 3+
```

---

## RISKS AND HONEST UNKNOWNS

Be upfront with Kathan about what we DON'T know:

1. **Conversion rate is a guess.** 15% is optimistic. Could be 5%. Won't know until real users try it.
2. **AI costs could change.** Gemini could raise prices. Build in message limits as a safety valve.
3. **Apple's cut is real.** At scale, 15-30% of revenue goes to Apple. Consider web sign-up flows.
4. **College Scorecard API is government-run.** Could get defunded or changed. Cache everything.
5. **Competition could appear.** If CollegeVine builds an AI subscription, they have distribution advantage.
6. **Seasonality matters.** App season (Aug-Jan) will have way more engagement than spring/summer.

---

## QUESTIONS KATHAN MIGHT ASK (AND HOW TO ANSWER)

**"Is $7.99/month too much?"**
→ Compare: Netflix is $15.49, Spotify is $11.99. Ladder helps you get into college. $8/mo for your future? Most parents would pay that without blinking. If anything, you might be charging too LITTLE.

**"Should I just make it free and figure out money later?"**
→ No. Free apps train users to expect free forever. Start with a free tier + paid tiers from day 1. You can always lower prices, but raising them is painful.

**"How many users do I need to make this worth my time?"**
→ At just 500 paid Standard users: 500 × $6.79 (after Apple) = $3,395/month. That's more than most part-time jobs. At 1,500 paid users, you're at ~$10K/month while in college.

**"What if nobody pays?"**
→ Then the free tier data tells you what to fix. Look at: where do free users stop engaging? What features do they use most? What triggers them to hit the paywall? Iterate from there.

**"Should I charge per-feature or flat subscription?"**
→ Flat subscription. Simpler to understand, easier to market, predictable revenue. Per-feature pricing confuses users and increases churn.

---

## SUMMARY TABLE FOR QUICK REFERENCE

```
WHAT IT COSTS YOU (per paid user/month):     $0.06 - $0.16
WHAT YOU CHARGE (per paid user/month):       $7.99 - $14.99
YOUR PROFIT PER USER (after Apple):          $6.73 - $12.58
GROSS MARGIN:                                84-99%
BREAK-EVEN POINT:                            ~50 paid users (covers AWS)
$1K/month milestone:                         ~150 paid Standard users
$10K/month milestone:                        ~1,500 paid Standard users
$100K/month milestone:                       ~15,000 paid Standard users
```

---

*Feed this entire document to Claude Code. Then ask it to help you with specific questions. It has all the context it needs.*
