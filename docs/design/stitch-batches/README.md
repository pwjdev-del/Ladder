# Ladder Stitch batches

Stitch cannot process the full v2 prompt in one paste. This folder splits the brief into 6 self-contained batches. Paste each batch file into a fresh Stitch session.

| # | File | Content | Count |
|---|---|---|---|
| 1 | `batch-1-landing-and-auth.md` | Landing (new) · 30s trigger animation · School picker · School login (themed) · Invite redemption · InviteCodeDisplay · B2C signup (COPPA gate) · Parental co-sign · B2B inquiry · Founder login | 10 screens |
| 2 | `batch-2-consent-and-student-start.md` | 5 consent sheets (Terms · Privacy · Parental · AI Addendum · DPA summary) · Quiz grade-band picker · K-2 quiz · Quiz locked state · Grades self-entry · Add-grade sheet | 10 screens |
| 3 | `batch-3-student-end-and-counselor.md` | Class suggester · Extracurriculars AI session · Schedule builder (3 states) · Parent invite · Counselor home · Queue list · Schedule review · Class list upload · Scheduling window · Counselor invite codes | 10 screens |
| 4 | `batch-4-admin-and-founder-start.md` | Admin home · Teacher profiles (list + detail) · Teacher schedules upload · Teacher reviews · Success metrics popup · Founder dashboard · Schools grid · School detail · Add new school | 10 screens |
| 5 | `batch-5-founder-end-and-components.md` | Solo people · Feature flags (with Varun-blocked state) · Varun panel · Impersonation banner · Founder-blocked view · Component: InviteCodeDisplay states · Component: ScheduleGrid (3 variants) · Component: DataDenseTable · Component: FeatureFlagToggle · Component: ImpersonationBanner placements | 10 screens/components |
| 6 | `batch-6-remaining-components.md` | Component: SiblingSwitcher · KidFriendlyButton · ConsentRow · Bottom nav per role (counselor / admin / parent variants) | 4 components |

**Total: 54 new artifacts.**

Each batch starts with the same brand tokens + hard-stop rules + reference file list so the Stitch session has full context without needing the other batches.

## How to use

1. Open `batch-1-landing-and-auth.md` in TextEdit. Copy the whole file.
2. Paste into a new Stitch session.
3. Wait for Stitch to deliver `screen.png` + `code.html` + `notes.md` for the 10 screens in that batch.
4. Move the deliverables into `~/Downloads/ladder-stitch-v2/batch-1/` (or wherever you like).
5. Ping me — I'll rework the matching SwiftUI views to consume the mocks 1:1.
6. Repeat for batches 2–6.

If Stitch still chokes on a 10-screen batch, split that batch further by grabbing 3–4 screens at a time from the same file. The brand-token block at the top of each batch is enough context on its own.

## Priority order (which batch to design first)

- **Batch 1 first** — unblocks the first impression of the app.
- **Batch 3 second** — unblocks student + counselor pilot value (those are the ones LWRPA will actually use).
- **Batch 4 third** — admin completeness.
- **Batch 5 fourth** — founder backdoor (infra-gated, can come last).
- **Batch 2 fifth** — consents + quiz variants.
- **Batch 6 last** — components shipped alongside whichever cluster first consumes them.

(The earlier `stitch-prompt.md` at the parent level is the master brief; these batches are the paste-sized slices of the same content.)
