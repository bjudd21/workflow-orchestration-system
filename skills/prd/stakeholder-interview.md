# Skill: Stakeholder Interview

This document provides the PRD Interviewer agent with a structured question bank, coverage methodology, and probing techniques for requirements gathering conversations.

---

## Coverage Areas & Question Bank

### Area 1: Problem Statement & Success Criteria

The goal is to understand what is broken or missing, who is affected, and what measurable improvement would constitute success.

**Opening questions:**
- "What is the specific problem this project solves — and who experiences it today?"
- "What happens right now when this problem occurs? What's the workaround?"
- "If this project succeeds completely, what changes for the user in measurable terms?"

**Probing for specificity:**
- "How often does this problem occur? Daily, weekly, per transaction?"
- "How many people are affected — 5 internal users, 500 customers, or 50,000 citizens?"
- "What does failure look like after launch? How would you know the project didn't work?"

**Success criteria framing:**
- "If I showed you a dashboard 6 months after launch, what metric would tell you this worked?"
- "Is there an existing baseline we're trying to improve? E.g., 'support tickets drop by 30%'?"

---

### Area 2: Target Users

The goal is to understand who will use the system, what they need to accomplish, and what constraints they operate under.

**Primary user questions:**
- "Who is the primary user — the person who interacts with the system most often?"
- "What is their technical skill level? Are they developers, business users, or members of the public?"
- "What device do they use? Desktop, mobile, or both? Any constrained environments (low bandwidth, shared terminals)?"
- "What is their biggest frustration with the current approach?"

**Secondary user questions:**
- "Is there anyone else who interacts with this system — approvers, auditors, administrators, support staff?"
- "What do secondary users need to do, and how often?"

**Persona constraints:**
- "Are there users with accessibility needs we must accommodate?"
- "Are there users for whom English is not a first language, or who operate in multilingual environments?"
- "Do users have specific compliance training requirements before they can access the system?"

---

### Area 3: Core Functionality

The goal is to identify the must-have capabilities — not a wishlist, but the features without which the system fails to solve the problem.

**Scope anchoring:**
- "If you had to list the 3-5 things this system absolutely must do to be useful, what would they be?"
- "Is there an existing requirements document, user story backlog, or rule file I should be aware of?"

**Feature clarification:**
- "When you say [feature], what does that mean from the user's perspective — what action do they take, and what does the system do in response?"
- "Does [feature] need to work in real time, or is a 5-minute delay acceptable?"
- "Who triggers [feature] — the user, a scheduler, an external event?"

**Workflow mapping:**
- "Walk me through the most common scenario, step by step, from the user's perspective."
- "What does the user do first? Then what? What happens at the end?"
- "Are there any approval steps, review stages, or handoffs between users?"

---

### Area 4: Scope & Boundaries

The goal is to create explicit scope boundaries so the council and task generator can validate that features are in or out.

**MVP definition:**
- "What is the minimum version of this system that you'd put in front of real users?"
- "Is there anything on your wishlist that you could live without for the first release?"
- "What would you be embarrassed to ship — what's the minimum bar for quality?"

**Explicit out-of-scope:**
- "Is there anything this system should explicitly NOT do, even if technically possible?"
- "Are there adjacent features that people will request but should be deferred? Let's name them now."

**Phase 2+ features:**
- "What features would make this significantly more valuable but are too complex for the first version?"

---

### Area 5: Non-Functional Requirements

The goal is to turn qualitative expectations ("it should be fast") into measurable targets.

**Performance:**
- "When you say 'fast,' what does that mean — how long is acceptable for the slowest operation a user would wait for?"
- Options: "A) Under 1 second B) Under 3 seconds C) Under 10 seconds D) [specific target you have]"
- "How many concurrent users do you expect at peak? Launch day vs. steady state?"
- "Is there a specific SLA or uptime requirement — 99%, 99.9%, 24/7 availability?"

**Data volume:**
- "How much data will this system store or process? Orders of magnitude: kilobytes, megabytes, gigabytes, terabytes?"
- "Is data volume expected to grow significantly year over year?"

**Availability & resilience:**
- "What happens if this system is down for 1 hour? For 24 hours? Is this mission-critical?"
- "Are there scheduled maintenance windows acceptable, or does it need to run continuously?"

**Integrations:**
- "What external systems does this need to connect to? Which are inside your control, and which are third-party?"
- "What happens if an external integration is unavailable? Can users keep working, or does the system stop?"

---

### Area 6: Compliance & Regulatory Requirements

The goal is to determine whether compliance frameworks apply and, if so, which ones and at what level.

**Direct inquiry:**
> "Does this project need to meet any government or regulatory compliance frameworks? For example:
> - **FISMA** — federal information systems
> - **FedRAMP** — cloud services used by federal agencies
> - **SOC 2** — commercial trust and security
> - **HIPAA** — healthcare data
> - **GDPR** — EU personal data
> - **CCPA** — California personal data
> - **Section 508 / WCAG** — accessibility for federal agencies or public-facing systems
> - **NIST 800-171** — controlled unclassified information (CUI)
> - **PCI DSS** — payment card data"

**If yes to any:**
- "For [framework], what impact level or tier applies? (For FISMA/FedRAMP: Low/Moderate/High)"
- "Is an ATO (Authority to Operate) required? Is there an existing ATO we're operating under?"
- "Are there inherited controls from a cloud platform (e.g., FedRAMP-authorized infrastructure) we can rely on?"
- "Who is the ISSO or compliance lead for this project?"

**If no compliance applies:**
- Note it explicitly: "User confirmed no compliance frameworks apply. Security requirements driven by organizational policy, not regulatory mandate."

---

### Area 7: Technical Constraints

The goal is to surface existing technology decisions, mandates, and constraints that will shape the architecture.

**Existing stack:**
- "Is this a new system or a modification to something that already exists?"
- "If existing: what language, framework, and database is it built on? Are we staying on that stack?"
- "Are there architectural patterns or conventions already in use that we should follow?"

**Technology mandates:**
- "Are there organizational standards for technology choices — approved languages, frameworks, cloud providers, or databases?"
- "Are there technologies explicitly prohibited or unsupported by your ops team?"

**Deployment environment:**
- "Where will this be deployed — on-premises, cloud (which provider?), or hybrid?"
- "Is there a specific cloud region or data residency requirement?"
- "Who owns and manages the deployment infrastructure — internal team, cloud ops, or a vendor?"

**Integration constraints:**
- "For each integration: what protocol and format does it use? REST, SOAP, GraphQL, file-based?"
- "Are there rate limits, throttling, or SLAs on external APIs you depend on?"
- "Is there a dev/test environment available for each integration, or are we testing against production?"

---

### Area 8: Timeline & Resources

The goal is to identify real constraints that will affect what's achievable in scope.

**Timeline:**
- "What is the target delivery date, and is it fixed or flexible?"
- Options: "A) Fixed — tied to contract, launch event, or regulatory deadline B) Target — preferred but negotiable C) Approximate — best estimate"
- "Why that date? What happens if you miss it?"

**Team:**
- "Who is building this? How many developers, and what are their skill levels?"
- "Is this team dedicated to this project, or are they splitting time with other work?"
- "Will you be using AI coding tools for implementation (e.g., Claude Code, Continue.Dev)?"

**Budget:**
- "Are there budget constraints that affect technology choices — e.g., open source only, no new SaaS subscriptions, existing cloud credits only?"
- "Is there a separate budget for compliance work (security audits, penetration testing, ATO fees)?"

---

## Probing Techniques

### Converting Vague to Specific

| Vague Answer | Probing Response |
|-------------|-----------------|
| "It needs to be fast" | "What's the slowest operation a user would wait for — page load, search, report generation? What's the maximum acceptable time for that?" |
| "It needs to be secure" | "Which aspects of security concern you most — who can log in, what data is exposed, how it's stored, or audit trails?" |
| "It needs to scale" | "What's the expected load at launch? What does 10x growth look like in 2 years?" |
| "It needs to be simple" | "Simple for the end user to use, or simple for the engineering team to build and maintain?" |
| "As many users as possible" | "Let's put a number on it — is this 10 internal users, 1,000 registered users, or potentially millions?" |
| "Standard security" | "By 'standard,' do you mean password authentication, or something more specific like MFA, SSO, or FIPS 140-2 validated encryption?" |
| "We'll figure that out later" | "What would need to be true for us to make that decision? Is there a specific milestone or piece of information we're waiting on?" |

### Handling "I Don't Know"

When users don't know an answer:
1. **Offer bounded options**: "If you had to guess, would it be closer to A, B, or C?"
2. **Ask who would know**: "Who in your organization would have the answer to this?"
3. **Ask what would be unacceptable**: "Even if you don't know the target, what would be unacceptably slow / too many users / too expensive?"
4. **Accept and note the gap**: "That's okay — I'll note this as an open question for the PRD. It should be resolved before development starts."

### Recognizing Scope Creep During Interview

When the user mentions features that exceed stated MVP scope:
- "That sounds useful — is that part of the initial release, or a future phase?"
- "If we added that, what would you be willing to cut from the MVP to keep scope realistic?"

---

## Interview Completion Checklist

Before emitting `INTERVIEW_COMPLETE`, verify:

- [ ] Problem is stated specifically (not just "we need X")
- [ ] Success is measurable (at least one quantified metric)
- [ ] Primary user is described with skill level and environment
- [ ] Core functionality covers the user's primary workflow end to end
- [ ] MVP scope is explicitly bounded (in AND out of scope)
- [ ] At least one NFR has a measurable target
- [ ] Compliance question was asked and answered (yes/no/which frameworks)
- [ ] Technical stack constraints are identified or noted as unconstrained
- [ ] Timeline and team composition are captured

If any item is incomplete, ask the remaining question before emitting the completion signal.
