# PASTE THIS INTO CLAUDE CODE ↓

---

## Pricing Reconciliation — CANON ANSWER

The **3-tier B2C model from the economics doc is canon.** The earlier Pro+School model was a brainstorm — discard it. Here's what's final:

```
FREE  ("Explorer")  → $0/month
STANDARD ("Climber") → $7.99/month  |  $59.99/year ($5.00/mo effective)
PREMIUM  ("Summit")  → $14.99/month |  $99.99/year ($8.33/mo effective)
```

The school/B2B channel ($4–6/student/yr) is a **Year 2 initiative**, not a launch tier. Don't build IAP product IDs or paywall flows for it yet. When we get there, it'll be a separate licensing model outside the App Store (no Apple cut).

**Update any in-app references, StoreKit product IDs, and paywall copy to match the 3-tier model above. The $9.99 Pro tier no longer exists.**

---

## NOW — Walk Me Through These Things (In This Order)

I'm an engineer, not a business person. I need you to teach me these concepts by **showing the math and using engineering analogies**. Don't just tell me the answer — walk me through HOW you get there so I can reason about it myself.

### 1. UNIT ECONOMICS WALKTHROUGH

Break down the full lifecycle of ONE paid Standard user, dollar by dollar:

```
What they pay you:           $7.99
What Apple takes (15%):      -$___
What AWS costs you:          -$___
What Gemini AI costs you:    -$___
What you actually pocket:    $___
```

Then do the same for Premium. Then show me the **lifetime version** (assuming 18 months).

After that, answer these specific questions:
- How many paid users do I need to cover $100/month in fixed AWS costs?
- At what point does the AI bill become my biggest cost? (How many users?)
- What's my break-even point if I spend $0 on marketing vs. $500/month on marketing?

### 2. SENSITIVITY ANALYSIS

I want to see what happens when my assumptions are WRONG. Build me a table like this:

```
Scenario                          | Monthly Revenue | Monthly Cost | Monthly Profit
----------------------------------|-----------------|--------------|---------------
Base case (15% conversion)        | $___            | $___         | $___
Pessimistic (5% conversion)       | $___            | $___         | $___
Optimistic (25% conversion)       | $___            | $___         | $___
AI costs double                   | $___            | $___         | $___
Apple takes 30% (over $1M)        | $___            | $___         | $___
Only 5K users instead of 10K      | $___            | $___         | $___
```

Do this at 10K users AND at 50K users. I need to see the range of outcomes, not just the best case.

### 3. PRICING PRESSURE TEST

Help me stress-test whether $7.99 is actually the right number. Walk me through:

- **Price elasticity:** If I drop to $4.99, how much would conversion need to increase to make the same revenue? Show the crossover math.
- **Price anchoring:** What does $7.99 "feel like" compared to things my target audience (16-18 year olds + their parents) already pay for? List 5-6 comparable monthly subscriptions.
- **Willingness to pay by grade:** A 9th grader's parent probably won't pay. A 12th grader's parent during app season is desperate. Should I have different pricing strategies by grade, or is that too complex?
- **Annual vs monthly mix:** What % of users typically choose annual vs monthly in education apps? How does that affect my cash flow?

### 4. THE "WHEN DOES THIS GET REAL" TIMELINE

I'm going to RIT in Fall 2026. I need to understand:

- If I launch on the App Store this summer (June 2026), what's a **realistic** user count by December 2026? Not optimistic — realistic, for a solo developer with no marketing budget.
- How long does it take freemium apps to hit 1,000 paid users? What are benchmark timelines from comparable apps?
- At what user count does this generate enough money that I should treat it as a real business vs. a side project? Give me a specific number.
- What's the minimum monthly revenue where I should consider hiring help (a part-time marketer, a designer, etc.)?

### 5. B2B SCHOOL CHANNEL — WHEN AND HOW

Don't build it yet, but help me understand:
- What does a school district actually pay for software per student? What's the range?
- Who makes the purchasing decision? (Principal? Counselor? District IT? Superintendent?)
- What's the typical sales cycle for edtech to schools? (Months? A year?)
- What would Ladder need to have built (features, certifications, compliance) before a school would consider buying it?
- Is FERPA compliance a blocker? What does that actually require?

### 6. APP STORE ECONOMICS DEEP DIVE

Walk me through exactly how Apple's cut works:
- Small Business Program: how do I qualify, when does it expire, what's the exact revenue threshold?
- If a user subscribes in-app at $7.99, what literally happens to the money? Walk me through the flow from "user taps Subscribe" to "money in my bank."
- Can I avoid Apple's cut by selling subscriptions through a website? What are the rules around that? (I know Apple vs Epic changed things — what's the current state?)
- What about promotional offers, free trials, and introductory pricing? How do those affect revenue timing?

### 7. COMPETITIVE MOAT ANALYSIS

I need to think about what stops someone from copying Ladder:
- CollegeVine has millions of users. If they add an AI subscription tomorrow, am I dead?
- What's my actual defensible advantage? Be brutally honest.
- Is the "start in 9th grade" positioning real, or is that just marketing? Why would a 9th grader actually open this app weekly?
- What data would Ladder accumulate over time that makes it harder to leave? (Network effects? Switching costs?)

---

## OUTPUT FORMAT

For each section above:
1. **Teach me the concept** — explain it like I'm an engineer who's never taken a business class
2. **Show the math** — every number should have a formula I can follow
3. **Give me the answer** — after teaching, give me the concrete recommendation
4. **Flag what's uncertain** — tell me which numbers are researched facts vs. educated guesses

When you're done with all 7 sections, give me a **ONE-PAGE CHEAT SHEET** at the end that summarizes:
- The 5 most important numbers I need to know
- The 3 biggest risks
- The 1 decision I need to make before launching
- The timeline from "launch" to "$10K/month"

---

*Take this section by section. Don't dump everything at once. Start with #1 (Unit Economics Walkthrough) and wait for me to say "next" before moving on.*
