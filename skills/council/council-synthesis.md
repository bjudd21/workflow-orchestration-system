# Skill: Council Synthesis

This document provides the Council Chair agent with frameworks for multi-perspective synthesis, consensus detection, conflict resolution, recommendation prioritization, and stakeholder decision framing.

---

## Synthesis Process Overview

The Council Chair receives multiple independent review outputs and must produce a single coherent document that:
1. Is more useful than reading all reviews separately
2. Does not lose any critical finding in the summarization process
3. Gives the stakeholder a clear path forward

The process has four steps: Cluster → Assess → Prioritize → Frame.

---

## Step 1: Cluster Findings

Before writing, map all findings across reviewers into clusters. A cluster is a group of findings that address the same underlying issue, even if surfaced by different reviewers from different angles.

### Clustering Method

Create a mental or draft matrix:

| Finding Theme | Technical | Security | Executive | User Advocate | Specialists |
|--------------|-----------|----------|-----------|---------------|-------------|
| Authentication gaps | HIGH | CRITICAL | — | — | — |
| Timeline realism | CRITICAL | — | HIGH | — | — |
| User story gaps | — | — | — | HIGH | — |
| Compliance coverage | MEDIUM | HIGH | — | — | Compliance: CRITICAL |

Clusters with findings from multiple reviewers are **stronger signals** — weight them accordingly in the synthesis. A concern raised independently by two reviewers with different perspectives is more credible than a concern raised by one.

### Endorsement Clusters

Also cluster endorsements (positive findings). Where multiple reviewers agree the PRD does something well, say so clearly. Positive consensus is useful signal too.

---

## Step 2: Assess Severity and Consensus

### Consensus vs. Disagreement Classification

| Type | Definition | Synthesis Action |
|------|-----------|-----------------|
| **Strong consensus** | Three or more reviewers raise the same concern (from different angles) | Lead the synthesis with this; weight it CRITICAL regardless of individual ratings |
| **Moderate consensus** | Two reviewers align on a concern | Present as a significant finding with both perspectives |
| **Single reviewer concern** | Only one reviewer flagged it | Present faithfully with appropriate weight; don't amplify or discount |
| **Conflict** | Two reviewers contradict each other | Present both positions; recommend resolution path without picking a winner |
| **Endorsement consensus** | Two or more reviewers praise the same element | Acknowledge with specifics in the summary |

### Severity Elevation Rules

- A MEDIUM finding becomes HIGH in the synthesis if it appears in 3+ reviewer outputs
- A HIGH finding becomes CRITICAL in the synthesis if it is cluster-consistent and no reviewer contradicted it
- A single reviewer's CRITICAL finding remains CRITICAL in the synthesis — do not downgrade findings from individual reviewers

---

## Step 3: Prioritize Revisions

Translate clustered findings into an ordered revision list. The ordering is what matters most — the stakeholder reads the top of the list first.

### Priority Tiers

**Tier 1 — Must Address Before Proceeding**
Conditions:
- Any CRITICAL-severity finding from any reviewer
- Any finding where multiple reviewers independently identified the same CRITICAL or HIGH concern
- REVISE AND RESUBMIT rating from any reviewer

These are not negotiable. If they are not addressed, the PRD cannot advance to task generation.

**Tier 2 — Should Address Before Proceeding**
Conditions:
- HIGH-severity findings from one reviewer where the concern is specific and addressable
- Medium-severity findings that appear in 2+ reviewers' outputs

These can technically proceed, but proceeding without addressing them carries documented risk.

**Tier 3 — Address in Next Pass**
Conditions:
- MEDIUM-severity findings from one reviewer
- Concerns that are valid but require more information to resolve
- Findings where the PRD may address the concern implicitly, but should make it explicit

**Tier 4 — Optional Improvements**
Conditions:
- LOW-severity findings
- Style or clarity suggestions that don't affect requirements quality
- Recommendations that are genuinely optional based on project context

---

## Step 4: Frame Conflicts for Stakeholders

### Conflict Presentation Format

Present each conflict fairly and without picking a side. The stakeholder makes the call.

**Structure:**
```
**Conflict: [Topic]**

[Reviewer A] argues: [position, with their reasoning]

[Reviewer B] argues: [position, with their reasoning]

**Resolution path**: [Framing that helps the stakeholder decide — what additional information would resolve this? What are the consequences of each choice? Who should make this decision?]
```

### Common Conflict Patterns and Resolution Frames

| Conflict Type | Framing Template |
|--------------|-----------------|
| **Speed vs. Security** | "If the timeline holds, the security requirement must be explicitly descoped and documented as a known risk. If the security requirement is non-negotiable, the timeline needs adjustment. This is a resource allocation decision." |
| **Scope vs. Timeline** | "The technical reviewer believes this scope is too large for the stated timeline. The executive reviewer sees the scope as necessary for business value. A phased approach may resolve both — what can move to Phase 2 without breaking the core user value?" |
| **Build vs. Buy** | "The technical reviewer recommends a proven third-party solution. The stakeholder specified building custom. This is a strategic choice with cost and timeline implications either way. [Describe each option's trade-offs]." |
| **Compliance rigor** | "The compliance reviewer recommends [stricter control]. The executive reviewer questions the cost. The resolution depends on whether [framework] is a hard regulatory requirement or an aspirational target for this system." |
| **User simplicity vs. feature richness** | "The User Advocate and Executive Reviewer disagree on whether [feature] serves the primary user or adds complexity. The answer depends on whether primary users have been consulted directly. Consider user testing or a pilot to resolve." |

---

## Stakeholder Decision Framework

### What Qualifies as a Stakeholder Decision

Escalate to stakeholder (not PRD writer) when:
- The resolution requires organizational authority (budget, timeline change, strategic choice)
- The resolution requires information only the stakeholder has (regulatory intent, contract requirements, team capacity)
- Two valid positions exist and neither is clearly "correct" from the PRD alone
- The decision has irreversible consequences (architectural commitments, technology lock-in)

### How to Frame Stakeholder Decisions

Each stakeholder decision should include:

1. **The question**: One clear sentence stating what needs to be decided
2. **The options**: Typically 2-3, with consequences for each
3. **The recommendation** (if any): Note which option the council leans toward and why, without mandating it
4. **Who should decide**: Name the role (executive sponsor, product owner, ISSO, legal counsel)
5. **When it must be decided**: Before development starts, before Phase 2, before ATO — frame the urgency

---

## Recommendation Writing Standards

Each recommended revision must be:

**Specific**: "Add a requirement that all audit log entries include user ID, timestamp (UTC), IP address, action performed, and outcome" — not "improve audit logging"

**Actionable**: The PRD writer can act on it without a follow-up conversation

**Scoped**: Identify which section or FR the change affects

**Justified**: One sentence explaining why this change matters

### Good vs. Poor Recommendation Examples

| Poor | Good |
|------|------|
| "Add more security requirements" | "FR-4 (Authentication) lacks an account lockout requirement. Add: 'The system shall lock an account for 15 minutes after 5 consecutive failed login attempts, and notify the account owner via email.'" |
| "Be more specific about timelines" | "The PRD states '2-week MVP' but lists 8 FRs. Based on typical development velocity (1 FR/week for a small team), adjust the timeline to 8-10 weeks or reduce MVP scope to 2-3 FRs." |
| "Think about accessibility" | "FR-6 describes a drag-and-drop file upload interface with no keyboard-accessible alternative. Add: 'A keyboard-accessible upload mechanism shall be provided alongside drag-and-drop.'" |

---

## Overall Verdict Decision Logic

Apply this logic to determine the council's overall verdict:

```
IF any reviewer rated REVISE AND RESUBMIT:
  → Overall verdict: REVISE AND RESUBMIT
  → Reason: "One or more reviewers identified fundamental gaps that must be resolved."

ELSE IF any CRITICAL finding exists (even if that reviewer rated APPROVED WITH CONCERNS):
  → Overall verdict: REVISE AND RESUBMIT
  → Reason: "A CRITICAL finding was surfaced that constitutes a fundamental gap."

ELSE IF 2+ reviewers rated APPROVED WITH CONCERNS and HIGH findings exist:
  → Overall verdict: APPROVED WITH CONCERNS
  → Reason: "Significant concerns exist but are addressable with targeted revisions."

ELSE IF 1 reviewer rated APPROVED WITH CONCERNS and findings are MEDIUM/LOW:
  → Overall verdict: APPROVED WITH CONCERNS
  → Reason: "Minor addressable concerns noted."

ELSE (all reviewers APPROVED, no HIGH+ findings):
  → Overall verdict: APPROVED
  → Reason: "Council found no significant gaps. PRD is ready for task generation."
```

---

## Synthesis Quality Checklist

Before finalizing the council synthesis:

- [ ] Every reviewer's output is reflected — no findings silently omitted
- [ ] Consensus points identified where 2+ reviewers agree
- [ ] Conflicts clearly presented with both sides and a resolution path
- [ ] Revision list is ordered by priority (Must → Should → Next Pass → Optional)
- [ ] Revisions are specific and actionable — no vague instructions
- [ ] Stakeholder decisions are clearly framed with options and consequences
- [ ] Overall verdict is justified by the findings
- [ ] Individual reviewer ratings are included in the output table
- [ ] The summary is honest — if the PRD has fundamental problems, that is stated clearly
