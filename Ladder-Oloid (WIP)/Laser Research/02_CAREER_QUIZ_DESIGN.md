# Career Quiz — Full Design Specification
_Sourced from: subtitles (4).txt, subtitles (5).txt, IMG_8192.txt, IMG_8200.txt_

---

## Purpose

The Career Quiz is the **entry point for the entire Ladder experience**. It determines which "path bucket" the student belongs to, which drives:
- Class recommendations
- Extracurricular suggestions and ratings
- College filtering (STEM-heavy vs. Liberal Arts vs. Athletic programs)
- AI advisor tone and focus areas

It is NOT a test. It is NOT final. It is a **suggestion engine** that students revisit every year.

---

## Core Design Principles

1. **Short and entertaining.** Target audience is 9th graders (14 years old). If it feels like homework, they won't finish it.
2. **Suggestions, not mandates.** Every output screen says "These are just suggestions based on what you told us."
3. **Override always available.** If AI says STEM but student insists Medical, the app adapts. No fights.
4. **Annual retake.** The quiz is taken once per year. Each retake recalibrates ALL downstream recommendations.
5. **Holistic inputs.** Not just "what do you like?" — also covers lifestyle, money expectations, and values.

---

## Quiz Structure

### Section 1: Hobbies (5–7 questions)
Questions about what the student naturally gravitates toward.
- "When you have free time, what do you most enjoy doing?"
  - Building/making things
  - Taking care of people
  - Solving problems/puzzles
  - Performing/creating art or music
  - Leading/organizing groups
  - Playing/coaching sports
  - Reading/researching/learning
- "If you could spend a Saturday doing anything, what would it be?"
- "Which school subject do you enjoy most, even if you're not the best at it?"

### Section 2: College / Career Interests (3–5 questions)
Light, non-intimidating way to surface career leaning.
- "Which type of work sounds most appealing?"
  - Working in a lab or with technology
  - Helping people with health or mental wellness
  - Running a business or managing projects
  - Creating things — writing, art, design, film
  - Training, coaching, or competing athletically
- "Which of these sounds most like a dream job?" (pick 2)
  - Engineer / Developer / Scientist
  - Doctor / Nurse / Therapist
  - Entrepreneur / Marketer / Finance
  - Journalist / Artist / Teacher / Lawyer
  - Professional Athlete / Coach / Physical Trainer

### Section 3: Lifestyle & Values (3–4 questions)
Calibrates for financial reality and work style preference.
- "When you picture your life at 30, what matters most?" (pick 2)
  - High income / financial freedom
  - Making a difference / helping others
  - Creative freedom / self-expression
  - Stability and a good work-life balance
  - Recognition / fame / influence
- "How do you prefer to work?"
  - Alone, focused on deep problems
  - With a team on big projects
  - With people directly (clients, patients, students)
  - Physically active and outdoors
  - Flexible / remote / entrepreneurially

---

## Output: The 5 Career Path Buckets

Based on quiz scoring, the student is placed in the bucket with the highest match:

| Bucket | Covers |
|--------|--------|
| **STEM** | Engineering, Computer Science, Math, Physics, Environmental Science, Architecture, Data Science |
| **Medical** | Pre-Med, Nursing, Dentistry, Pharmacy, Physical Therapy, Psychology, Biology |
| **Business** | Business Administration, Finance, Marketing, Accounting, Entrepreneurship, Law, Real Estate |
| **Humanities** | English, History, Education, Political Science, Journalism, Sociology, Film, Art, Music, Theater |
| **Sports** | Athletic Training, Kinesiology, Sports Management, Physical Education, Nutrition, NCAA path |

### Output Screen UX
- Show the top bucket with a bold archetype name (e.g., "The Builder" for STEM)
- Show a dropdown of 6–10 specific majors within that bucket
- "These are suggestions. You can explore other paths below ↓"
- Show the other 4 buckets below as alternate options
- "Not sure? You can take this again next year — you don't need to decide today."

---

## Annual Retake Flow

Every year when the student opens the app, they see a prompt:
> "It's been a year! A lot can change. Want to update your career quiz? Takes 3 minutes."

On retake:
- Pre-fill with last year's answers
- Only show the questions where the student might want to change their answer
- After completing, show delta: "Last year you were leaning Medical. Based on your new answers, you're now leaning STEM/Medical equally. Here's what that means for your classes this year…"

---

## Integration Points

| Data produced | Used by |
|---------------|---------|
| Career bucket | Class recommendation engine |
| Career bucket | Activities system (which of the 6 specific activities to suggest) |
| Career bucket | College filtering (filter by strong programs in that major) |
| Career bucket | AI advisor system prompt (tailors advice to career path) |
| Career bucket + lifestyle answers | Scholarship search filters |
| Career bucket | Roadmap milestone focus areas |

---

## Note: College Board Integration

One transcript mentions directing students to College Board's own college quiz, having them take screenshots, and importing those results. This is a possible shortcut to avoid building the full quiz logic from scratch:
- Link to: bigfuture.collegeboard.org/majors-careers quiz
- After student completes it there, they upload a screenshot to Ladder
- AI vision parsing extracts the college/major suggestions
- Ladder uses those suggestions as inputs for filtering

This is a valid MVP approach for the quiz feature — faster to build, leverages College Board's validated methodology.
