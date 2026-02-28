# Contract: PRD Output Schema

**Phase**: 3 → 4 (PRD Synthesis → Council Review)
**Files**:
- Versioned PRD: `workspace/{project-name}/tasks/prd-{project-name}-v{N}.md`
- Handoff: `workspace/{project-name}/handoffs/003-prd-refined.md`
**Validated by**: Phase 4 workflow before starting council review

---

## Purpose

This contract defines the required structure and content quality for a PRD handoff. Phase 4 (Council Review) will reject a PRD that is missing required sections, contains unmeasurable NFRs, or lacks measurable acceptance criteria, returning it to Phase 3 for revision.

---

## Required Frontmatter

```yaml
---
phase: prd-synthesis
project: [project name — kebab-case]
version: v[N]       # e.g., v1, v2, v3
date: [ISO 8601 date — e.g., 2026-02-28]
status: Draft | Under Review | Approved
entry_point: greenfield | repo-analysis | multi-repo-analysis
compliance: [list of frameworks] | none
source_interview: workspace/{project-name}/handoffs/002-prd-interview.md
source_analysis: workspace/{project-name}/handoffs/001-analysis-complete.md | none
---
```

**Validation rules:**
- `phase` must equal `prd-synthesis`
- `version` must be present and match `v[integer]` format
- `status` must be one of the three allowed values
- `compliance` must either list framework names or the literal string `none`

---

## Required Sections

The following 7 sections are always required. Section 8 (Compliance) is required when `compliance` in frontmatter is not `none`.

---

### Section 1: Executive Summary

**Heading**: `## 1. Executive Summary` (or `## Executive Summary`)

**Minimum content**:
- 2 paragraphs minimum
- Must describe: what the system does, why it's being built, who it serves
- Must include at least one measurable success criterion

**Validation rule**: Section must be present with ≥150 words. Must contain at least one numeric metric or measurable target.

---

### Section 2: Functional Requirements

**Heading**: `## 2. Functional Requirements` (or `## Functional Requirements`)

**Minimum content**:
- At least 3 numbered functional requirements (FR-1, FR-2, FR-3...)
- Each FR must have at least 2 acceptance criteria
- Acceptance criteria must be testable

**FR format check**:
```markdown
**FR-N: [Name]**
[Description]

Acceptance Criteria:
- [ ] [Testable condition]
- [ ] [Testable condition]
```

**Validation rules**:
- At least 3 FRs present
- Each FR has at least 2 acceptance criteria
- No FR acceptance criteria that are purely qualitative ("users should find it easy")
- At least one FR covers authentication or access control (if the system has users)

---

### Section 3: Non-Functional Requirements

**Heading**: `## 3. Non-Functional Requirements` (or `## Non-Functional Requirements`)

**Minimum content**:
- At least 2 NFRs with measurable targets
- NFRs presented as a table or list with explicit targets

**Validation rules**:
- At least 2 NFRs present
- At least one NFR contains a numeric target (e.g., "< 200ms", "99.9%", "10,000 users")
- No NFR that is purely qualitative ("the system shall be responsive")

**Automatic failure patterns** (reject PRD if any present):
- `NFR: The system shall be fast` — no measurement
- `NFR: The system shall be secure` — no specification
- `NFR: The system shall scale` — no target
- `NFR: The system shall be user-friendly` — not a valid NFR

---

### Section 4: User Stories & Acceptance Criteria

**Heading**: `## 4. User Stories` (or `## User Stories & Acceptance Criteria`)

**Minimum content**:
- At least 3 user stories
- Each story must have: persona (not "user"), action, outcome
- Each story must have at least 1 acceptance criterion

**User story format check**:
```markdown
**US-N: [Name]**
As a [specific persona], I want to [action], so that [outcome].

Acceptance Criteria:
- Given [...], when [...], then [...]
```

**Validation rules**:
- At least 3 user stories present
- No story with generic persona "user" or "the system" — must name a specific role
- Each story has at least 1 acceptance criterion with Given/When/Then or equivalent testable format

---

### Section 5: Architecture Recommendations

**Heading**: `## 5. Architecture Recommendations` (or `## Architecture`)

**Minimum content**:
- Description of major system components (not implementation details)
- At least one architectural risk or trade-off mentioned

**Validation rules**:
- Section present with ≥100 words
- Must not contain implementation-specific choices (specific library names, database products, cloud services) unless the PRD explicitly states they are user-constrained

**Failure pattern**: "The system will use PostgreSQL with a FastAPI backend deployed on AWS Lambda" — implementation detail, not architecture recommendation

---

### Section 6: Risk Assessment

**Heading**: `## 6. Risk Assessment` (or `## Risks`)

**Minimum content**:
- At least 2 identified risks
- Each risk has likelihood and impact classification

**Risk format check**:
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Risk] | High/Med/Low | High/Med/Low | [Mitigation] |

**Validation rules**:
- At least 2 risks present
- Each risk has a likelihood AND impact (both required)
- At least one technical risk and one timeline/resource risk

---

### Section 7: MVP vs. Future Phases

**Heading**: `## 7. MVP vs. Future Phases` (or `## Scope`)

**Minimum content**:
- Explicit list of what is in MVP scope
- Explicit list of at least 1 deferred item

**Validation rules**:
- Both MVP scope and deferred/future items present
- MVP scope list is not empty
- Future phases list is not empty (if the PRD has no deferred items, it likely lacks scope discipline)

---

### Section 8: Compliance Requirements *(Conditional)*

**Heading**: `## 8. Compliance Requirements` (or `## Compliance`)

**Required when**: `compliance` in frontmatter is not `none`

**Minimum content**:
- List of applicable frameworks
- At least one compliance-driven requirement per framework

**Validation rules** (when compliance applies):
- Section must be present when `compliance != none`
- Each listed framework has at least one specific requirement
- Must not be generic ("the system shall comply with FISMA") — must state specific required controls or behaviors

---

## PRD Quality Checks (Non-Blocking Warnings)

These checks produce warnings that are reported to the user but do not block council review:

| Check | Warning Condition |
|-------|-----------------|
| FR count | Fewer than 5 FRs may indicate incomplete requirements; more than 12 FRs in MVP scope may indicate over-scoping |
| Acceptance criteria | Any FR with exactly 1 acceptance criterion (minimum passed but quality concern) |
| Personas | Only 1 user persona described (secondary personas often overlooked) |
| Timeline | No timeline mentioned in Executive Summary or Section 7 |
| "How" language | FRs using specific framework/library names (implementation detail leak) |

---

## Handoff File vs. Versioned PRD

| File | Purpose | Contents |
|------|---------|---------|
| `003-prd-refined.md` | Phase handoff artifact | Final approved PRD version + frontmatter with phase metadata |
| `prd-{name}-v{N}.md` | Version-controlled PRD | The PRD document itself; each version preserved |

The handoff file (`003-prd-refined.md`) is a copy of the latest PRD version with the handoff frontmatter prepended. It is this file that Phase 4 loads — not the versioned PRD directly.

---

## Validation Logic for Phase 4 Workflow Node

```
HARD FAIL (blocks council review):
1. Frontmatter missing or malformed
2. phase != "prd-synthesis"
3. version missing or malformed
4. Any required section (1-7) missing
5. Section 8 missing when compliance != none
6. Fewer than 3 FRs
7. Any FR missing acceptance criteria
8. Fewer than 2 NFRs
9. Any NFR with no measurable target
10. Fewer than 3 user stories
11. Any user story with generic "user" persona
12. Risk section has fewer than 2 risks
13. Future phases section is absent or empty

SOFT WARN (reported but not blocking):
- Fewer than 5 FRs
- Only 1 user persona
- No timeline mentioned
- FR contains framework/library names
```

On hard fail, Phase 4 returns: "PRD failed validation: [specific check(s) that failed]. Return to Phase 3 to address these gaps before council review."
