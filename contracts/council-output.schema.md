# Contract: Council Output Schema

**Phase**: 4 → 4.5 or 5 (Council Review → PM Destination Selection or Task Generation)
**File**: `workspace/{project-name}/handoffs/004-council-review.md`
         (re-reviews: `004-council-review-r2.md`, `004-council-review-r3.md`, etc.)
**Validated by**: Phase 5 workflow before task generation; re-review gate before reconvening council

---

## Purpose

This contract defines the required structure of the council review output. The Phase 5 workflow and re-review gate node use this to verify the council completed a valid review, all required outputs are present, and the acceptance/rejection status is recorded.

---

## Required Frontmatter

```yaml
---
phase: council-review
project: [project name — kebab-case]
review_number: 1          # Increments with each re-review (r1=1, r2=2, etc.)
date: [ISO 8601 date]
prd_version_reviewed: v[N]
reviewers:
  - technical-reviewer
  - security-reviewer
  - executive-reviewer
  - user-advocate
  - council-chair
  # + any specialized reviewers included
overall_verdict: APPROVED | APPROVED_WITH_CONCERNS | REVISE_AND_RESUBMIT
status: ACCEPTED | REJECTED | PENDING
# status = ACCEPTED: user accepted the council's verdict and agreed revisions are applied
# status = REJECTED: user rejected recommendations; PRD proceeds unchanged
# status = PENDING: review complete but user has not yet acted on it
---
```

**Validation rules:**
- `phase` must equal `council-review`
- `overall_verdict` must be one of the three values
- `status` must be one of the three values
- `reviewers` list must contain at minimum: `technical-reviewer`, `security-reviewer`, `executive-reviewer`, `user-advocate`, `council-chair`
- `prd_version_reviewed` must reference a valid PRD version

---

## Required Sections

---

### Section 1: Individual Reviewer Outputs

**Heading**: `## Reviewer Outputs`

**Contents**: The complete output from each reviewer, in order. Each reviewer's output is a subsection with their name as the heading.

```markdown
## Reviewer Outputs

### Technical Reviewer

[Full Technical Reviewer output, verbatim from the LLM — including stated biases, all findings with severity/confidence, and summary]

---

### Security Reviewer

[Full Security Reviewer output]

---

### Executive Reviewer

[Full Executive Reviewer output]

---

### User Advocate

[Full User Advocate output]

---

### [Specialized Reviewer Name] *(if included)*

[Full Specialized Reviewer output]

---
```

**Validation rules:**
- At least 4 reviewer subsections (core reviewers) must be present
- Each reviewer subsection must contain at minimum:
  - "Stated Biases" (or equivalent label)
  - "Overall Rating" with a value of APPROVED, APPROVED WITH CONCERNS, or REVISE AND RESUBMIT
  - At least 3 findings
  - At least 1 finding with severity label (CRITICAL, HIGH, MEDIUM, or LOW)
- A `council-chair` subsection is NOT in this section — chair output is in Section 2

---

### Section 2: Council Chair Synthesis

**Heading**: `## Council Chair Synthesis`

**Contents**: The complete council chair output, verbatim from the LLM.

```markdown
## Council Chair Synthesis

[Full Council Chair output — must include:]
[- Reviewers list]
[- Overall Verdict]
[- Consensus Points]
[- Conflicts Requiring Resolution (or statement that none exist)]
[- Recommended PRD Revisions with priority tiers]
[- Stakeholder Decisions Required (or statement that none exist)]
[- Individual Reviewer Ratings table]
[- Overall Assessment]
```

**Validation rules:**
- Section must be present and non-empty
- Must contain `Overall Verdict:` with a valid verdict value
- Must contain `Recommended PRD Revisions` section (may state "no revisions required" only if verdict is APPROVED)
- Must contain `Individual Reviewer Ratings` table with all reviewers listed
- If verdict is REVISE_AND_RESUBMIT, a "Must Address Before Proceeding" subsection with at least one item must be present

---

### Section 3: User Decisions

**Heading**: `## User Decisions`

**Contents**: Record of which recommendations the user accepted or rejected. This section is populated after the user reviews the council output — it may be empty (PENDING) if the council just completed.

```markdown
## User Decisions

**Review Date**: [ISO date when user reviewed]
**Decision**: ACCEPTED | REJECTED | PARTIAL

### Accepted Recommendations
[List of recommendations from the council that the user agreed to implement]
1. [Recommendation text — copied from council synthesis]
2. [...]

[Or:]
No recommendations accepted. User proceeding without council revisions.

### Rejected Recommendations
[List of recommendations the user explicitly declined, with rationale]
1. [Recommendation] — Rationale: [why rejected or deferred]

[Or:]
No recommendations rejected.

### Notes
[Any additional context from the user's review session]
```

**Validation rules:**
- Section must be present (may have placeholder text if status is PENDING)
- If `status == ACCEPTED` or `REJECTED`, the section must contain substantive content
- If `status == PENDING`, section may contain: `"User review in progress. Decisions not yet recorded."`

---

### Section 4: PRD Revision Log

**Heading**: `## PRD Revision Log`

**Contents**: Summary of what changed in the PRD as a result of accepted recommendations.

```markdown
## PRD Revision Log

**PRD version before council**: v[N]
**PRD version after revisions**: v[N+1] | No revision (accepted without changes)

### Changes Made
[Bulleted list of specific changes applied to the PRD]
- Added MFA requirement to FR-4 (Authentication) — per Security Reviewer finding
- Updated NFR-1 performance target from "sub-second" to "< 500ms p95 at 200 concurrent users"
- Removed [feature X] from MVP scope — per Executive Reviewer finding
- [...]

[Or if no changes:]
No PRD changes made. Council findings acknowledged; user proceeding with PRD as-is.
```

**Validation rules:**
- Section must be present
- If `status == ACCEPTED` and accepted recommendations list is non-empty: changes list must be non-empty
- If `status == REJECTED` or no recommendations accepted: "No PRD changes made" statement is valid

---

### Section 5: Re-Review Status

**Heading**: `## Re-Review Status`

**Contents**: Records the re-review gate decision — whether the user chose to proceed or reconvene the council.

```markdown
## Re-Review Status

**Gate Decision**: PROCEED | RECONVENE
**Decision Date**: [ISO date]
**Rationale**: [Brief note on why the user chose to proceed or reconvene]

[If RECONVENE:]
**Next review scope**: Delta review of [specific sections changed]
**Next review file**: workspace/{project-name}/handoffs/004-council-review-r[N+1].md
```

**Validation rules:**
- Section must be present
- If `status != PENDING`: `Gate Decision` must be PROCEED or RECONVENE
- If Gate Decision is RECONVENE: "Next review file" must be specified with the correct filename pattern

---

## Re-Review File Naming

| Review | Filename |
|--------|---------|
| First review | `004-council-review.md` (same as `004-council-review-r1.md`) |
| Second review | `004-council-review-r2.md` |
| Third review | `004-council-review-r3.md` |
| N-th review | `004-council-review-r{N}.md` |

All review files are preserved. Phase 5 uses the most recent completed review file (highest `r{N}` value with `status != PENDING`).

---

## Validation Logic for Phase 5 Workflow Node

Phase 5 loads the most recent council review file and validates:

```
HARD FAIL (blocks task generation):
1. Frontmatter missing or malformed
2. phase != "council-review"
3. overall_verdict missing or invalid value
4. status == PENDING (council review not yet acted on by user)
5. Fewer than 4 reviewer subsections in Section 1
6. Council Chair Synthesis section missing
7. Overall Verdict in chair synthesis missing
8. Re-review status section missing
9. Gate Decision is not PROCEED (or file is not the latest in a series)

PASS conditions:
- All required sections present
- status is ACCEPTED or REJECTED (not PENDING)
- Gate Decision is PROCEED
- overall_verdict is valid
```

**Special case**: If `overall_verdict == REVISE_AND_RESUBMIT` and `status == ACCEPTED`, Phase 5 proceeds only if the PRD Revision Log shows substantive changes were made. If the PRD Revision Log is empty despite a REVISE_AND_RESUBMIT verdict, Phase 5 warns the user: "The council issued a REVISE AND RESUBMIT verdict but no PRD changes are recorded. Confirm you wish to proceed without addressing the council's mandatory findings."

---

## Validation Logic for Re-Review Gate Node

The re-review gate node checks the current council review file and prompts the user:

```
Input: current 004-council-review.md (or latest r{N})
Check: status == ACCEPTED | REJECTED
If status == PENDING: gate blocks; prompt user to review and act on council findings
If status == ACCEPTED | REJECTED:
  → Present form: "Proceed to next phase" | "Reconvene council for re-review"
  → If user selects RECONVENE:
    - Set Gate Decision = RECONVENE in current file
    - Create new council review handoff shell: 004-council-review-r{N+1}.md
    - Load revised PRD and run council review workflow (delta mode)
  → If user selects PROCEED:
    - Set Gate Decision = PROCEED in current file
    - Advance to Phase 4.5 (PM Destination) or Phase 5 (Task Generation)
```
