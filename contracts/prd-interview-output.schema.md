# Contract: PRD Interview Output Schema

**Phase**: 2 → 3 (Interview → PRD Synthesis)
**File**: `workspace/{project-name}/handoffs/002-prd-interview.md`
**Validated by**: Phase 3 workflow before starting PRD synthesis

---

## Purpose

This contract defines the required structure and content of the interview handoff artifact produced by Phase 2. Phase 3 (PRD Writer) will reject an incomplete handoff and require re-running or manually completing Phase 2.

---

## Required Frontmatter

The handoff file must begin with a valid YAML frontmatter block:

```yaml
---
phase: prd-interview
completed: [ISO 8601 timestamp — e.g., 2026-02-28T14:32:00Z]
agent: prd-interviewer
project: [project name — no spaces, kebab-case]
entry_point: greenfield | repo-analysis | multi-repo-analysis
compliance_applicable: true | false
compliance_frameworks: [list of frameworks, or empty list]
coverage_complete: true
---
```

**Validation rules:**
- `phase` must equal `prd-interview`
- `completed` must be a valid ISO 8601 timestamp
- `project` must be present and non-empty
- `entry_point` must be one of the three allowed values
- `coverage_complete` must be `true` — a `false` value indicates an incomplete interview and blocks Phase 3

---

## Required Sections

All six sections below must be present. A section is present if it contains at least one non-empty line below its heading.

### Section 1: Coverage Summary

**Heading**: `## Coverage Summary`

**Contents**: A table or checklist showing which of the 8 coverage areas were completed. Each area must be marked as covered (✓), not applicable (N/A), or open (incomplete — blocks Phase 3).

```markdown
## Coverage Summary

| # | Area | Status | Notes |
|---|------|--------|-------|
| 1 | Problem Statement & Success Criteria | ✓ | |
| 2 | Target Users | ✓ | |
| 3 | Core Functionality | ✓ | |
| 4 | Scope & Boundaries | ✓ | |
| 5 | Non-Functional Requirements | ✓ | Uptime target TBD |
| 6 | Compliance | ✓ | FISMA Moderate applies |
| 7 | Technical Constraints | ✓ | |
| 8 | Timeline & Resources | ✓ | |
```

**Validation rule**: No area may have status `incomplete` or be missing from the table. If a coverage area was explicitly declined by the user, mark it N/A and note the reason.

---

### Section 2: Extracted Requirements

**Heading**: `## Extracted Requirements`

**Contents**: Structured summary of requirements organized by category. This is the pre-processed input for the PRD Writer — not raw transcript, but interpreted and organized findings.

Required subsections:

```markdown
## Extracted Requirements

### Problem Statement
[1-3 sentences describing the specific problem being solved and who is affected]

### Success Criteria
[Bulleted list of measurable outcomes that indicate project success]
- [Metric 1: specific and quantified]
- [Metric 2: specific and quantified]

### Primary Users
[Description of primary persona: role, technical level, environment, goals, pain points]

### Secondary Users
[Description of secondary personas, or "None identified"]

### Core Functional Requirements
[Numbered list of must-have capabilities derived from the interview]
1. [Capability with enough specificity to write an FR]
2. ...

### MVP Scope Boundary
In scope:
- [Feature/capability confirmed as MVP]

Out of scope:
- [Feature/capability explicitly deferred]

### Non-Functional Requirements
[Bulleted list of NFRs with measurable targets where specified]
- Performance: [target or "not specified — default to [recommendation]"]
- Availability: [target or "not specified"]
- [Additional NFRs as identified]

### Technical Constraints
[Bulleted list of confirmed technical constraints]
- Existing stack: [or "greenfield — no constraints stated"]
- Deployment target: [or "not specified"]
- Integration points: [list or "none identified"]

### Timeline & Resources
- Target delivery: [date or range]
- Team: [size and skill level]
- Budget constraints: [or "not stated"]

### Compliance
[Either:]
No compliance frameworks identified. Security requirements driven by organizational policy.
[Or:]
Applicable frameworks: [list]
- [Framework 1]: [impact level, ATO status, specific requirements identified]
```

**Validation rule**: All subsections must be present. A subsection may note "not specified" or "not applicable" but may not be absent.

---

### Section 3: Raw Interview Transcript

**Heading**: `## Interview Transcript`

**Contents**: The complete conversation in chronological order, preserving both user messages and agent questions. Each message labeled with speaker.

```markdown
## Interview Transcript

**Interviewer**: [question]

**User**: [response]

**Interviewer**: [follow-up question]

**User**: [response]

[...full conversation...]

**Interviewer**: I have everything I need. [closing summary]

INTERVIEW_COMPLETE
```

**Validation rules:**
- Transcript must be present and non-empty
- Transcript must contain at least 6 exchanges (user question + response pairs)
- Transcript must end with `INTERVIEW_COMPLETE` or equivalent completion signal

---

### Section 4: Open Questions

**Heading**: `## Open Questions`

**Contents**: Any questions that arose during the interview that were not fully resolved. These should be explicitly addressed before or during PRD review.

```markdown
## Open Questions

1. [Question text] — [why it matters, when it must be resolved]
2. [Question text] — [context]

[Or if no open questions:]
No open questions. All coverage areas resolved with sufficient specificity.
```

**Validation rule**: Section must be present. May state no open questions if true.

---

### Section 5: Compliance Summary

**Heading**: `## Compliance Summary`

**Contents**: Summary of applicable compliance frameworks (or explicit statement that none apply). Controls the PRD Writer's inclusion of Section 8.

```markdown
## Compliance Summary

Compliance applicable: [Yes / No]

[If Yes:]
Frameworks identified:
- [Framework]: [impact level or tier] — [brief rationale for applicability]
- [Framework]: [additional detail]

[If No:]
No regulatory or government compliance frameworks apply to this project.
Security requirements are driven by organizational policy and industry best practices.
```

**Validation rule**: Section must be present. `compliance_applicable` in frontmatter must match this section's content.

---

### Section 6: Handoff Notes

**Heading**: `## Handoff Notes`

**Contents**: Any context the PRD Writer needs that doesn't fit the structured sections above — interviewer observations, tone of requirements, user uncertainty, areas needing special attention.

```markdown
## Handoff Notes

[Free-form notes for the PRD Writer — what to watch for, any ambiguity in the extracted requirements, user preferences expressed during the interview, or recommendations for PRD structure]

[May be brief or detailed as appropriate]
```

**Validation rule**: Section must be present. May be brief (one sentence) if no special notes apply.

---

## Validation Logic for Phase 3 Workflow Node

The Phase 3 workflow validation node shall check:

```
PASS conditions (all must be true):
1. Frontmatter parses without error
2. phase == "prd-interview"
3. coverage_complete == true
4. compliance_applicable is boolean (true or false)
5. All 6 sections are present (by heading)
6. Section 2 contains all required subsections
7. Section 3 (Transcript) contains at least 6 exchanges
8. No coverage area in Section 1 has status "incomplete"

FAIL conditions (any triggers rejection):
- Missing or malformed frontmatter
- coverage_complete == false
- Any required section missing
- Transcript contains fewer than 6 exchanges
- Any coverage area marked incomplete
```

On failure, Phase 3 returns an error to the user: "[Section name] is missing or incomplete in the interview handoff. Re-run Phase 2 or manually complete the missing section."

---

## File Naming Convention

Primary handoff: `workspace/{project-name}/handoffs/002-prd-interview.md`

If the interview is re-run (e.g., requirements changed after the first interview), the revised handoff overwrites the primary file. A backup of the original is saved as: `002-prd-interview-v1-[timestamp].md`
