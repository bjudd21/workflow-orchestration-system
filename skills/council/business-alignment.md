# Skill: Business Alignment

This document provides the Executive Reviewer agent with frameworks for ROI analysis, strategic fit assessment, resource justification, and stakeholder alignment review during PRD council sessions.

---

## Business Case Quality Assessment

A PRD with a strong business case answers four questions explicitly:

1. **What problem are we solving?** Specific, with evidence of impact (frequency, cost, audience affected)
2. **Why does this solution solve it?** Logical connection between the proposed system and the stated problem
3. **How will we know it worked?** Measurable success metrics tied to the problem statement
4. **Is it worth the investment?** Effort and cost proportionate to expected value

If any of these are missing, the business case is incomplete.

---

## ROI Framework

### Value Identification

Ask: what tangible value does this system create? Classify each benefit:

| Value Type | Examples | How to Quantify |
|-----------|---------|----------------|
| **Cost reduction** | Fewer support tickets, eliminated manual process, reduced licensing fees | Hours saved × hourly rate, or direct cost comparison |
| **Revenue generation** | New capability that enables sales, faster onboarding, expanded user base | Revenue per user × projected new users |
| **Risk reduction** | Compliance penalty avoidance, security breach prevention, error rate reduction | Probability × cost of event |
| **Productivity gain** | Users complete tasks faster, fewer errors requiring rework | Time saved per user per day × user count |
| **Strategic positioning** | Enables future capability, competitive differentiation | Qualitative; note if this is the primary justification |

### Cost Identification

When reviewing the PRD, flag if these costs are not acknowledged:

| Cost Category | Often Overlooked |
|--------------|-----------------|
| Development | Including QA, code review, PM time — not just developer hours |
| Infrastructure | Hosting, storage, bandwidth, licensing — recurring costs |
| Security & compliance | Audit, assessment, penetration testing, ATO process |
| Maintenance | Bug fixes, dependency updates, security patches — typically 15-20% of build cost annually |
| Training & change management | User onboarding, documentation, support desk preparation |
| Integration | Third-party API costs, data migration, testing with external systems |
| Opportunity cost | What else could this team be building? |

### ROI Quality Signals

| Signal | Good | Concern |
|--------|------|---------|
| Success metrics | Quantified (reduce support tickets by 30%) | Vague ("improve user experience") |
| Baseline | Current state documented for comparison | No baseline; cannot measure improvement |
| Timeline to value | Value realization date stated | ROI assumed but timing not addressed |
| Cost acknowledgment | Build and run costs estimated | Only build costs considered |
| Dependency acknowledgment | External dependencies on value noted | Value assumes other projects succeed |

---

## Strategic Fit Assessment

### Organizational Priority Alignment

Review whether the project aligns with stated organizational priorities:

**Questions to apply:**
- Does this project advance a stated organizational strategy (modernization, compliance, user growth)?
- Does the project compete with or duplicate effort from another initiative?
- Does the project create capabilities that the organization's roadmap depends on?
- Does the project align with the team's mandate and charter?

**Red flags:**
- Project originated as a technical initiative without clear business sponsorship
- Project addresses a problem not on any organizational priority list
- Project depends on other initiatives succeeding first, without acknowledging that dependency

### Stakeholder Map Analysis

A PRD should implicitly describe who the stakeholders are. Check:

| Stakeholder Role | Present? | Risk if Absent |
|-----------------|----------|---------------|
| **Executive sponsor** | Decision authority, budget owner | No one to resolve scope conflicts or fund Phase 2 |
| **Product owner** | Day-to-day priority decisions | Scope drift; no one to say "no" |
| **Primary users** | Represented in requirements | System built for the wrong needs |
| **Operations/support** | Will maintain after launch | Operational burden not planned for |
| **Security/compliance** | Sign-off required | Delays at ATO/audit time |
| **Impacted teams** | Workflows changed by this system | Resistance and adoption risk at launch |

### Feature-to-Goal Traceability

Every feature in the MVP scope should trace back to a stated goal. Apply this test:

For each FR, ask: "Which goal (G1, G2, etc.) does this serve? If this FR were removed, would any stated goal be unmet?"

- If yes: the FR is justified
- If no: the FR is scope creep or optimization — flag it

**Red flags:**
- FRs with no connection to stated goals ("this would be useful")
- Goal statements without any FRs that serve them (orphaned goals)
- MVP scope that includes features from Future Phase goals

---

## Resource Proportionality Analysis

### Effort vs. Problem Severity

Apply a simple proportionality test:

| Problem Severity | Proportionate Investment |
|-----------------|------------------------|
| Saves 1 person 30 min/week | Small project (days-weeks) |
| Saves a team 20 hours/week | Medium project (weeks-months) |
| Eliminates a $500K/year cost | Large project (months) |
| Enables a new revenue line | Large-to-enterprise project |
| Prevents regulatory penalty | Size determined by penalty risk |

**Flag when**: The investment appears disproportionately large for the stated problem, or disproportionately small for the stated ambition.

### Team-to-Scope Fit

| Warning Signs | Concern |
|--------------|---------|
| Enterprise-scale features with solo developer | Timeline will slip; quality will suffer |
| Large team assigned to minor enhancement | Over-resourced; coordination cost |
| Junior-only team on complex/compliance system | Risk of architectural and compliance gaps |
| No QA or testing resources | Quality risk; delays post-launch |

---

## Success Criteria Evaluation

### What Good Success Criteria Look Like

| Quality | Poor | Good |
|---------|------|------|
| **Specific** | "Users will be happier" | "Support tickets related to [process] decrease by 30%" |
| **Measurable** | "Improved performance" | "Report generation completes in < 5 seconds for 95% of requests" |
| **Attributable** | Cannot be isolated to this project | Metric changes when and only when this system changes |
| **Time-bounded** | No deadline for measurement | "Measured 90 days post-launch" |

### Common Success Criteria Anti-patterns

| Anti-pattern | Example | Problem |
|-------------|---------|---------|
| **Vanity metric** | "1,000 registered users" | Registration ≠ value delivered |
| **Output, not outcome** | "All 15 features shipped" | Features shipped ≠ problem solved |
| **Unmeasurable aspiration** | "Users love it" | Cannot verify; no baseline |
| **Lagging indicator only** | "Revenue grows after 12 months" | Too late to course-correct during build |
| **No baseline** | "Reduce errors" | Reduce from what? By how much? |

### Minimum Viable Success Criteria

A PRD should have at minimum:
1. One **leading indicator** — measurable during or soon after launch (adoption rate, task completion rate, error rate)
2. One **lagging indicator** — measurable 30-90 days after launch (cost savings, revenue, NPS)
3. One **failure threshold** — the point at which the project is considered unsuccessful and a decision is made

---

## Resource Justification Checklist

| Question | Green | Flag |
|----------|-------|------|
| Is there a named executive sponsor? | Yes | No — orphaned projects stall |
| Is the budget approved or hypothetical? | Approved | Hypothetical budget delays start |
| Is there a clear go/no-go decision process? | Stated | No decision process = no accountability |
| Is operational ownership defined post-launch? | Named team | "TBD" operational ownership |
| Is there a Phase 2 funding commitment or plan? | Noted | Phase 2 depends on unplanned budget |

---

## PRD Review Checklist for Executive Reviewer

Before writing findings:

- [ ] Is the business problem explicitly stated with evidence of impact?
- [ ] Is there a logical connection between the problem and the proposed solution?
- [ ] Are success metrics quantified with a baseline and measurement timeline?
- [ ] Does each major feature trace to a stated business goal?
- [ ] Is the scope proportionate to the stated problem and available resources?
- [ ] Are the costs (build + run + compliance) acknowledged?
- [ ] Is there a named executive sponsor and product owner?
- [ ] Are operational ownership and support responsibilities addressed post-launch?
- [ ] Is the MVP scope the minimum viable solution, or does it include "nice-to-haves"?
- [ ] Are stakeholders who will be impacted (but not using) the system identified?
