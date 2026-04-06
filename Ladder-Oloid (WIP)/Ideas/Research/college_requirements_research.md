# College Application & Post-Admissions Checklists Research

## The Goal
The goal of this research module is to map out exactly what every college in the US requires for:
1. **Pre-Admissions:** The application checklist (Common App vs. Institution Portal, SAT/ACT requirements, Letters of Recommendation, Transcripts).
2. **Post-Admissions:** The enrolled-student checklist (Deposit, Housing, Immunization, Final Transcripts).

### Why Scraping Post-Admissions Data is Difficult
To address the comment: *"why cant it do it, i need it to go and explore everything"*
1. **Login Walls & 2FA:** After a student applies, the university sends them a unique portal link with a temporary username and password. The post-acceptance checklists are hidden behind these personalized accounts. AI web scrapers (like Firecrawl) cannot easily log in to thousands of unique student portals without the student's credentials.
2. **Personalized Checklists:** Some items only appear depending on the student's major, financial aid status, or housing preference (e.g., an "Audition Portfolio" only appears for Music majors).

### The Solution: How We Will Build the Database
Since we cannot easily scrape the post-admissions secure portals *before* a student gets access, we will:
1. **Scrape Pre-Admissions Data Automatically:** We can scrape public university admissions sites (using Firecrawl) for application deadlines, standardized testing policies, and transcript types.
2. **Crowdsource/Email Parse Post-Admissions Data:** Once the student gets accepted, they forward their "Welcome to X University" email or upload the PDF/screenshot of their portal. The AI (using an LLM vision/text parser) pulls the checklist from *their* specific portal and creates the tracker in our app. Over time, as hundreds of students upload FIU or RIT checklists, our app "learns" the default FIU/RIT checklists.

## Step 1: Firecrawl Strategy for US Colleges
We are preparing to use **Firecrawl** to scrape the public data for US colleges. 

**Data Schema to Extract:**
*   College Name
*   Location
*   Acceptance Rate (Approximate)
*   Application Platforms (Common App, Coalition, Direct)
*   Testing Policy (Test-Optional vs. Blind vs. Required)
*   Transcript Requirement (Self-Reported SSAR vs. Official)
*   Key Deadlines (Early Action, Early Decision, Regular Decision)

### Next Actions:
*   We need the **Firecrawl API Key** from the user.
*   Once provided, we will write a Python script to iterate through a seed list of the top 300 US universities (and specifically Florida state schools) to build the initial JSON database.
