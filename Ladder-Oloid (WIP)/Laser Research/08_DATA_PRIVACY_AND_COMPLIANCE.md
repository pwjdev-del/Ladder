# Data Privacy & Compliance Notes
_Sourced from: subtitles (3).txt, (8).txt, IMG_8202.txt, IMG 8238.txt, college_requirements_research.md_

---

## The Core Challenge

Ladder's most powerful features (class recommendations, transcript parsing, school API integration) all depend on accessing sensitive student data. This is the hardest technical and legal problem the app faces.

---

## FERPA (Federal Law — US)

**Family Educational Rights and Privacy Act**
- Governs all student education records at institutions receiving federal funding (nearly all public schools)
- Students 18+ own their own records. Under 18, parents have the rights.
- **Schools CANNOT share student records with Ladder without written consent from the student (or parent if under 18)**
- **Ladder's approach:**
  - All data is voluntarily uploaded by the student themselves (not pulled by the school)
  - Student consent is obtained at onboarding (clear, explicit, checkbox — not buried in ToS)
  - Schools can optionally connect their data systems, but only with district-level agreement AND individual student consent

---

## Transcript Types (Critical to Understand)

### Unofficial Transcripts
- Can be downloaded by the student from Focus (Manatee County) or PowerSchool
- PDF with student grades, course history, GPA
- **Acceptable for:** Initial Ladder profile setup, college application screening, AI class recommendations
- **Not acceptable for:** Official college submissions (most colleges require official transcripts from the school)

### Official Transcripts
- Sent directly from the high school (with official seal and signature) to the college
- Student cannot handle this — must request through their school counselor
- **UF example:** Submitted through STARS (Florida-specific system)
- **RIT example:** Must be sent directly via email to admissions from the school
- **Ladder's role:** Coach the student to request official transcripts early. Provide step-by-step instructions. Track "Official transcript requested" as a checklist item.

---

## School Portal Systems in Florida

| School System | Portal Name | Notes |
|---------------|-------------|-------|
| Manatee County (public) | Focus (by PowerSchool) | Students can download unofficial transcripts |
| Charter Schools USA (CSUSA) | PowerSchool | Same system, different instance |
| University of Florida | STARS / Gator Portal | Florida-specific transcript submission |
| Florida State University | MyFSU | Application through Common App |
| University of South Florida | USF Application Portal | Direct application |

---

## Transcript Upload Flow

**What students can actually do themselves:**
1. Log in to Focus / PowerSchool at their school
2. Navigate to transcripts section
3. Download unofficial transcript as PDF
4. Upload that PDF to Ladder
5. Ladder's AI parses it using a vision/text model (Gemini Vision)
6. Extracted data: subjects, grades per year, GPA, course difficulty level

**What Ladder CANNOT do (legally or technically):**
- Log in to school portals on behalf of students
- Access student records from school systems without explicit partnership
- Request official transcripts from the school (only the student or parent can do this)

---

## Data Storage & Security

- All student data stored in Supabase (PostgreSQL with RLS)
- Row Level Security: every table has policies that prevent any user from accessing another user's data
- Transcripts stored as encrypted files in Supabase Storage
- Payment data: never stored (handled by Apple's StoreKit / Apple Pay)
- API keys never in app bundle (always proxied through Supabase Edge Functions)

---

## Age / COPPA Considerations

- **COPPA** (Children's Online Privacy Protection Act) applies to users under 13
- Ladder's minimum age is 13 (entering 8th grade) — technically one year below the typical high school entry
- At 13, parental consent is required for data collection
- **Implementation:**
  - Date of birth collected during onboarding
  - If user is under 13: block registration with message "Ask a parent or guardian to create your account"
  - If user is 13–17: require parent email for consent (email sent to parent with consent link)
  - If 18+: standard consent flow

---

## What to Ask the District (When Pitching)

When approaching Manatee County or any school district for partnership:

1. "We want to accept PDF transcript uploads from students — students download these from Focus themselves. We're not asking for API access to Focus."
2. "We want schools to optionally create a profile listing their class catalog, clubs, and athletics. This is completely voluntary data that you choose to share."
3. "We want to create counselor accounts that let counselors see the class preferences submitted by students at their school."
4. "We will sign a Data Privacy Agreement (DPA) / Student Data Privacy Consortium (SDPC) agreement if required."
5. "All student data is encrypted, access-controlled, and never sold to third parties."

---

## Reference: Student Data Privacy Consortium (SDPC)

Many US school districts require ed-tech vendors to sign an SDPC agreement before any data sharing is permitted. Ladder should:
1. Review SDPC requirements: studentdataprivacy.org
2. Draft a compliant Privacy Policy and Data Security Agreement before pitching to any district
3. Consider pursuing FERPA-compliant data processing certification
