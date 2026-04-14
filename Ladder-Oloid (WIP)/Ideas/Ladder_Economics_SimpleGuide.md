# Ladder Economics — The Simple Version

> This is for YOU, Kathan. No MBA jargon. Just the numbers and what they mean.

---

## The One-Sentence Version

It costs you about **6 cents** to serve a paid user each month, and you charge them **$8**. That's like buying something for $0.06 and selling it for $8. The margins are insane.

---

## How Money Works in This Business

Think of it like a pipeline (you're an engineer, so this should click):

```
[Users download app for FREE]
        ↓
[Some of them hit a feature wall — "upgrade to unlock"]
        ↓
[~15% of them pay $7.99/month]
        ↓
[Apple takes 15% of that → you keep $6.79]
        ↓
[It costs you $0.06 to serve them → you pocket $6.73]
        ↓
[They stay for ~18 months → you make $121 total from that one person]
```

That's the whole business. Everything else is just optimizing each step of this pipeline.

---

## The 5 Numbers That Matter

### 1. Cost to serve one user: ~$0.06/month
This is your AWS bill + Gemini AI bill, divided by users. It's tiny because:
- AWS gives you 10K users free on Cognito
- Gemini Flash costs half a cent per conversation
- College data is cached locally from a free government API

### 2. What you charge: $7.99/month (Standard) or $14.99/month (Premium)
Why $7.99?
- Cheaper than Netflix ($15.49) — easy parent sell
- 10-25x cheaper than a private counselor ($3,000+)
- In the "I won't even think twice" price range for families

### 3. What Apple takes: 15%
Apple takes a cut of every App Store subscription. Under $1M revenue/year, they only take 15% (Small Business Program). So from $7.99, you actually get $6.79.

### 4. How many free users become paid: ~15% (your target)
This is called "conversion rate." Out of every 100 users who download:
- 85 stay on free forever
- 12 pay $7.99 (Standard)
- 3 pay $14.99 (Premium)

### 5. How long paid users stick around: ~18 months
A typical student uses this their junior + senior year. That means one paying user = ~$122 in your pocket over their lifetime.

---

## What You'd Actually Make

### With 10,000 users (doable in Year 1):
- 1,200 paying Standard + 300 paying Premium
- **~$11,200/month profit** after Apple's cut and server costs
- **~$134K/year**

### With 50,000 users (Year 2 goal):
- 7,500 Standard + 2,500 Premium
- **~$78,000/month profit**
- **~$940K/year**

### The minimum viable milestone:
- **150 paid users** = ~$1,000/month (solid side income in college)
- **500 paid users** = ~$3,400/month (more than most part-time jobs)
- **1,500 paid users** = ~$10,000/month (real business territory)

---

## The Three Tiers Explained

### FREE — The Hook
Give away enough to get students addicted: college search, basic career quiz, 10 AI messages/month, scholarship browsing. This costs you almost nothing (~1 cent/user/month). The goal is to get 9th and 10th graders using it early so they convert when they hit 11th grade and need the real features.

### STANDARD ($7.99/mo) — The Money Maker
This is where 80% of your revenue comes from. Unlimited AI advisor, personalized activity suggestions, application tracker, essay help, deadline calendar. Everything a student actively applying to college needs.

### PREMIUM ($14.99/mo) — The Upsell
For serious applicants and families who would've considered hiring a counselor. Deep essay review, mock interviews, transcript parsing, parent access. Higher margin, smaller audience.

---

## Why This Business Model Works

**The comparison that sells it:**

```
Private college counselor:    $3,000 - $10,000
Ladder Premium for 4 years:   $400
Ladder Standard for 4 years:  $288

You're offering a $5,000 service for $300.
```

**The margins are software margins:**
Your "product" is code running on AWS + AI API calls. There's no inventory, no shipping, no manufacturing. Once you build it, serving the 10,000th user costs almost the same as serving the 1st.

**Natural retention:**
Students don't cancel during application season. They NEED this. And the 4-year journey (starting in 9th grade) means users who start early are locked in for years.

**Built-in virality:**
Students talk to friends about college. "What app are you using?" is a natural conversation. Each user brings more users.

---

## What Could Go Wrong (Being Real)

1. **Maybe only 5% convert instead of 15%.** You'd make ~$44K/year instead of $134K at 10K users. Still profitable, but slower growth. Fix by improving the free→paid value gap.

2. **Apple's 30% cut at scale.** If you pass $1M revenue, Apple takes 30% instead of 15%. Mitigation: offer sign-up through a website to bypass the App Store.

3. **AI costs could rise.** If Gemini doubles prices, your cost per user goes from $0.06 to $0.12. Still tiny compared to revenue. Build in message limits as a safety valve.

4. **Someone bigger copies you.** CollegeVine could add AI subscriptions tomorrow. Your moat: you built for 9th graders, not just 12th. The 4-year data advantage compounds.

---

## Next Steps

1. **Read the Claude Code prompt file** (`Ladder_Economics_ClaudeCode_Prompt.md`) — it has ALL the detailed numbers and research
2. **Paste it into Claude Code** and ask questions until everything clicks
3. **Come back to me** with what you learned and any decisions you've made
4. **I'll refine it** into whatever format you need (pitch deck, one-pager, etc.)

---

*You built a 48,000-line app with 145 features. The economics are the easy part. The numbers are on your side.*
