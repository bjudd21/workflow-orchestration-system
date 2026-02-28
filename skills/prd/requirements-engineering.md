# Skill: Requirements Engineering

This document provides the PRD Interviewer and PRD Writer agents with structured techniques for eliciting, organizing, and validating requirements to produce a complete, measurable PRD.

---

## Requirements Quality Standards

A requirement is only valid if it passes all four tests:

| Test | Question | Fail Condition |
|------|----------|---------------|
| **Specific** | Does it describe one distinct behavior or property? | "The system shall be user-friendly" — too broad |
| **Measurable** | Can we verify it passed or failed? | "The system shall be fast" — no metric |
| **Achievable** | Is it technically feasible given constraints? | "Zero downtime during deployment" without blue-green infra |
| **Traceable** | Can it be linked to a user need or business goal? | Requirements without a "because" are scope creep waiting to happen |

If a requirement fails any test, it must be revised before the PRD can be approved.

---

## Functional vs. Non-Functional Requirements

### Functional Requirements (FRs)

Describe **what the system does** — capabilities, behaviors, and user interactions.

Pattern: `The system shall [behavior] when [trigger/condition] for [actor].`

Good FR examples:
- `FR-3: The system shall send an email notification to the submitting user within 60 seconds of a form submission being approved or rejected.`
- `FR-7: The system shall prevent any user from accessing records outside their assigned organizational unit, enforcing this restriction at the API layer regardless of UI state.`

Bad FR examples:
- `The system shall be easy to use.` → Not a FR — this is a UX aspiration. Translate to specific behaviors.
- `The system shall use PostgreSQL.` → Implementation detail. Remove from FR; note in architecture recommendations.
- `The system shall handle errors gracefully.` → Vague. Translate to: "The system shall display actionable error messages for all user-facing failures, including what failed, why, and what the user can do next."

### Non-Functional Requirements (NFRs)

Describe **how well the system performs** — quality attributes. Every NFR must have a measurable target.

| Category | Pattern | Example |
|----------|---------|---------|
| **Performance** | [operation] completes in [time] at [load] | Search returns results in < 500ms at 200 concurrent users |
| **Availability** | [system] achieves [uptime %] measured [period] | API gateway achieves 99.9% uptime measured monthly |
| **Scalability** | [system] supports [volume] without [degradation] | System supports 10,000 concurrent sessions without response time degradation beyond NFR-1 |
| **Security** | [asset/operation] requires [control] | All user sessions require MFA authentication |
| **Data** | [data] retained for [period] per [requirement] | Audit logs retained 7 years, encrypted at rest, per NIST 800-53 AU-11 |
| **Recovery** | [system] recovers in [time] after [failure type] | System recovers to full operation within 15 minutes after a single node failure |

---

## Acceptance Criteria Methodology

Every functional requirement must have acceptance criteria — the conditions that prove the requirement is met.

### Format: Given/When/Then

```
Given [a specific initial state],
When [a specific action occurs],
Then [a specific, observable outcome results].
```

Examples:

```
FR-4: User Authentication

Given a user with a valid account,
When they submit their username and valid password,
Then they are authenticated and redirected to their dashboard.

Given a user with a valid account,
When they submit an invalid password three times consecutively,
Then their account is locked for 15 minutes and they receive a notification email.

Given a locked account,
When 15 minutes have elapsed,
Then the account is automatically unlocked and login attempts are permitted.
```

### Acceptance Criteria Completeness Check

For each FR, verify criteria cover:

- [ ] **Happy path**: The normal successful case
- [ ] **Edge cases**: Boundary conditions (empty, max, minimum values)
- [ ] **Failure cases**: What happens when input is invalid or the operation fails
- [ ] **Authorization**: What a user without permission receives
- [ ] **Concurrent operations**: If relevant, what happens when two users act simultaneously

---

## Requirements Organization Patterns

### Grouping by Feature Area

Group related FRs under headings. A well-organized PRD is scannable:

```markdown
## Functional Requirements

### Authentication & Access Control
**FR-1**: [login]
**FR-2**: [MFA]
**FR-3**: [session management]
**FR-4**: [role assignment]

### Data Management
**FR-5**: [record creation]
**FR-6**: [record editing]
**FR-7**: [record deletion with soft-delete]

### Notifications
**FR-8**: [email notifications]
**FR-9**: [in-app alerts]
```

### Dependency Notation

When one FR depends on another being implemented first:
```
FR-8: [Notification System]
Depends on: FR-3 (User accounts must exist before notifications can be sent)
```

This helps the task generator create the right dependency ordering in GitHub Issues.

---

## User Stories Structure

### Format

```
**US-N: [Story Name]**
As a [specific persona],
I want to [specific action],
So that [specific outcome that matters to them].

Acceptance Criteria:
- Given [state], when [action], then [result]
```

### Common Mistakes to Avoid

| Mistake | Wrong | Right |
|---------|-------|-------|
| **Generic persona** | "As a user..." | "As an agency procurement officer..." |
| **Vague action** | "I want to manage my data" | "I want to export my transaction history as CSV" |
| **Missing outcome** | "So that it works" | "So that I can provide it to the auditor without reformatting" |
| **Solution in story** | "I want a dashboard widget that..." | Keep it goal-oriented, not implementation-oriented |

### Story Sizing Signal

If a user story's acceptance criteria exceeds 6 items, it likely needs to be split. Complex stories map to complex tasks — break them before they reach the task generator.

---

## Scope Management

### The MVP Boundary Test

For every feature, ask: "If we removed this from the first release, would the system fail to solve the stated problem for the primary user?"

- If yes → MVP scope
- If no → candidate for future phase

Document the future phases explicitly. Features without a documented rationale for deferral will creep back in during development.

### "Won't Do" List

Every PRD should include a brief list of explicit non-starters — things that stakeholders might expect but the project will not deliver. These prevent scope creep during development:

```markdown
### Explicitly Out of Scope
- Real-time collaboration (multiple users editing simultaneously) — deferred to Phase 2
- Mobile native app — web-responsive only for MVP; native app in Phase 3
- Integration with [legacy system X] — data will be imported manually; API integration in Phase 2
```

---

## Requirements Traceability

Each requirement should be traceable forward (to acceptance criteria and tasks) and backward (to a user need or business goal).

Traceability format in the PRD:
```
FR-5: Record Export
Source: US-4 (procurement officer exports for audit), NFR-3 (data portability)
Validates: G2 (self-service compliance reporting)
```

The PRD writer does not need to produce a formal traceability matrix — but every functional requirement should clearly derive from at least one user story or business goal. Orphaned requirements (FRs with no user story or business goal) are scope creep.

---

## Completeness Checklist

Before marking a PRD ready for council review, verify:

### Functional Requirements
- [ ] All primary user stories have corresponding FRs
- [ ] All FRs have at least 2 acceptance criteria
- [ ] All acceptance criteria are testable (Given/When/Then or equivalent)
- [ ] FRs cover: creation, reading, updating, deletion (as applicable to the domain)
- [ ] Error handling is specified (what happens when an operation fails)
- [ ] Authorization is specified (who can do what, and what unauthorized users receive)
- [ ] Notifications and feedback loops are covered

### Non-Functional Requirements
- [ ] At least one performance target with a number
- [ ] Availability or uptime requirement (even if it's just "99% during business hours")
- [ ] Security requirements explicitly stated (not "standard security")
- [ ] Data retention or storage requirement if the system persists data

### User Stories
- [ ] All primary personas covered with ≥3 stories each
- [ ] All secondary personas covered with ≥1 story
- [ ] No stories with generic personas ("as a user")

### Structure
- [ ] No implementation details in FRs (no library names, no endpoint paths)
- [ ] MVP scope explicitly bounded
- [ ] Future phases documented with rationale
- [ ] Compliance section present if applicable, absent if not
