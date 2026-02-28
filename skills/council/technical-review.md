# Skill: Technical Review

This document provides the Technical Reviewer agent with an architecture evaluation framework, feasibility assessment checklist, scope realism benchmarks, and technology risk indicators for PRD review.

---

## Architecture Evaluation Framework

### 1. Component Coupling Assessment

**What to look for**: Systems fail at their boundaries. Tightly coupled components amplify risk.

| Coupling Type | Green Signal | Red Flag |
|--------------|-------------|----------|
| **Sync dependencies** | Service calls have defined timeouts and fallback behavior | "Service A calls Service B" with no mention of what happens when B is slow or down |
| **Shared database** | Each service owns its data; cross-service reads are through APIs | Multiple services writing to the same tables |
| **Deployment coupling** | Components can be deployed independently | PRD implies all components must deploy together |
| **Circular dependencies** | None visible in the architecture | Service A depends on B which depends on A |

**Questions to ask**:
- What happens to the user-facing experience if Component X fails?
- Can the system degrade gracefully, or is every component a single point of failure?
- Are there fan-out calls (one request triggers N downstream calls)? What's N?

### 2. Data Flow Validation

Trace the data flow through the system as described. For each major user action:

1. Where does the request enter? (API gateway, direct service, webhook)
2. What services or functions does it touch?
3. Where is state created or modified?
4. What is the response path back to the user?
5. What could fail at each step, and what does the user experience?

**Red flags in data flow:**
- Data transformations described but not the format (JSON? XML? CSV?)
- "The system stores this information" without specifying where or who owns it
- State changes that touch multiple data stores with no mention of transaction management or compensation
- External API calls inline with user-facing operations (latency + availability risk)

### 3. Integration Point Analysis

For each integration with an external system:

| Factor | Questions |
|--------|-----------|
| **Protocol** | REST? SOAP? Message queue? File-based? Is it specified? |
| **Authentication** | How does our system authenticate to the external system? API key, OAuth, client cert? |
| **Availability** | What's the SLA of the external system? What happens if it's down? |
| **Rate limits** | Are there rate limits? Can our load exceed them? |
| **Schema ownership** | Who owns the contract? Can the external system change it without warning? |
| **Test environment** | Is there a sandbox/test endpoint? Are we forced to test against production? |

**Unspecified integrations are hidden risk.** "The system integrates with [external system]" without protocol, auth, and failure mode is a MEDIUM or HIGH finding.

### 4. State Management Review

| Question | Green | Red Flag |
|----------|-------|----------|
| Is session/user state managed? | Yes, explicitly (JWT, server-side session, etc.) | Authentication mentioned, session management not |
| Is distributed state consistent? | Consistency model described | Multiple nodes with no consistency discussion |
| Is cache invalidation addressed? | Strategy described | Caching mentioned without invalidation strategy |
| Is background processing tracked? | Job state visible (queued, running, done, failed) | Async operations with no status visibility |

---

## Feasibility Assessment Checklist

### Technical Complexity vs. Stated Timeline

Use this heuristic to assess whether the stated scope is achievable:

| Feature Type | Baseline Complexity | Often Underestimated Because |
|-------------|--------------------|-----------------------------|
| CRUD with basic auth | Low | Straightforward |
| File upload/processing | Medium | Validation, virus scanning, storage, size limits |
| Real-time (WebSocket, SSE) | Medium-High | Infrastructure, connection management, reconnect logic |
| Search | Medium-High | Indexing strategy, relevance, performance at scale |
| Notifications (email/SMS/push) | Medium | Template system, delivery guarantees, unsubscribe, bounce handling |
| OAuth / SSO integration | Medium-High | Token refresh, edge cases, multiple providers |
| Payments | High | PCI scope, refunds, disputes, reconciliation |
| Multi-tenancy | High | Data isolation, per-tenant config, billing |
| Import/export (large files) | Medium | Background processing, progress reporting, error recovery |
| Reporting / analytics | Medium-High | Query complexity, performance at scale, data accuracy |
| Multi-region / HA | High | Replication, failover, consistency |
| Migration from legacy system | High | Data quality, cutover strategy, parallel run |

**Benchmarks for solo or small team:**
- A motivated junior developer implements ~1 medium-complexity feature per week (including tests, code review, and integration work)
- A mid-level developer: ~1.5-2 features per week
- These estimates assume clean requirements. Poor requirements multiply time by 2-3x.

### Hidden Complexity Indicators

Flag these as MEDIUM or HIGH when found in a PRD:

| Indicator | Hidden Complexity |
|-----------|------------------|
| "Users can upload files" | File validation, storage, virus scanning, size limits, access control, version management |
| "Real-time updates" | WebSocket infrastructure, connection lifecycle, reconnect, missed events during disconnect |
| "Support multiple languages" | i18n throughout UI, date/number/currency formatting, RTL support, content translation workflow |
| "Users can share with others" | Invitation flow, permission levels, revocation, activity feeds |
| "Audit trail" | Every entity change logged with who/when/what, immutable log storage, audit report UI |
| "Bulk operations" | Background processing, progress UI, partial failure handling, retry |
| "Export to PDF" | Layout engine, pagination, fonts, accessibility of generated PDFs |
| "Single sign-on" | IdP integration, claim mapping, session federation, token refresh |
| "Offline support" | Local state management, sync conflict resolution, queue management |

---

## Scope Realism Benchmarks

### Timeline Red Flags

| Claim in PRD | Concern |
|-------------|---------|
| "2-week MVP" with 5+ FRs | Each FR typically requires 1+ week including design, dev, and testing |
| "1 developer, 3 months" for enterprise features | Enterprise-grade auth, multi-tenancy, audit trails are 6+ month efforts for a team |
| Timeline not stated | Missing timeline = no accountability; flag as MEDIUM |
| Timeline tied to external event (regulatory deadline, contract date) | Fixed timeline + scope creep = overtime or cuts; flag to document the constraint |

### Scope Warning Signs

| Pattern | Risk |
|---------|------|
| More than 8-10 FRs in MVP | High probability of timeline slip |
| Every feature listed as "must-have" | No prioritization; nothing can be cut if timeline is threatened |
| FR says "and" more than twice | The FR should be split |
| "The system shall support [complex feature] in a simple interface" | Tension between complexity and simplicity is unresolved |
| Compliance requirements with no timeline for ATO or assessment | Compliance adds 3-12+ months to timelines |

---

## Technology Risk Indicators

### "Build vs. Buy" Risk

Flag when the PRD proposes building something that commodity solutions handle:

| Built Proposal | Commodity Alternative | Flag Level |
|---------------|----------------------|-----------|
| Custom authentication system | Auth0, Okta, Cognito, Keycloak | HIGH — auth is hard to get right |
| Custom email delivery | SendGrid, SES, Postmark | MEDIUM — deliverability is nuanced |
| Custom queue/background jobs | Redis + Bull, SQS, Celery | MEDIUM — depends on scale needs |
| Custom search | Elasticsearch, Typesense, Postgres full-text | MEDIUM — depends on complexity |
| Custom CMS | Strapi, Contentful, Ghost | LOW — may be intentional |
| Custom analytics | Posthog, Mixpanel, GA4 | LOW — may be a privacy requirement |

### Technology Maturity

| Risk | Indicators |
|------|-----------|
| **Immature dependency** | Framework or library in pre-1.0, released < 12 months ago, <500 GitHub stars, or with known breaking changes in progress |
| **End-of-life technology** | Runtime or framework past official support date (e.g., .NET Framework 4.5, Node 14) |
| **Lock-in risk** | Proprietary cloud service for a core function with no migration path |
| **Skill availability** | Proposed technology has a small talent pool relative to the team's hiring market |

### Missing Infrastructure Requirements

Common omissions that create implementation gaps:

- [ ] CI/CD pipeline (how does code get to production?)
- [ ] Environment strategy (dev, test, staging, prod?)
- [ ] Secrets management (where do API keys live?)
- [ ] Logging and monitoring (how are errors surfaced in production?)
- [ ] Backup and disaster recovery (what's the RPO/RTO?)
- [ ] Database migrations strategy (how is schema changed in production?)
- [ ] Feature flags or rollout strategy (how is new functionality released safely?)

---

## Common Architectural Anti-patterns to Flag

| Anti-pattern | Description | Risk |
|-------------|-------------|------|
| **God object** | One service or module that does everything | Single point of failure; hard to test; hard to scale |
| **Chatty interface** | Many small calls where one would do | Latency amplification; network saturation |
| **Synchronous fan-out** | One request triggers N synchronous downstream calls | Cascading failures; timeout amplification |
| **Shared mutable state** | Multiple components write to the same resource without coordination | Data corruption; race conditions |
| **Callback hell / deep nesting** | Error handling buried in nested conditions | Silent failures; unmaintainable code |
| **Magic numbers** | Hard-coded timeouts, limits, and thresholds | Cannot tune without code changes; breaks at scale |
| **Missing idempotency** | Non-idempotent operations on retryable paths | Duplicate records, double charges, data corruption |

---

## PRD Review Checklist for Technical Reviewer

Before writing findings:

- [ ] Is the system's architecture described at a component level?
- [ ] Are all integration points identified with protocol and auth?
- [ ] Are failure modes described for critical paths?
- [ ] Does the timeline match the scope (use complexity benchmarks)?
- [ ] Are there hidden complexity items in the FRs?
- [ ] Is there infrastructure-as-code or deployment strategy mentioned?
- [ ] Are there "build your own" proposals for commodity problems?
- [ ] Are NFRs achievable with the implied architecture?
- [ ] Are test strategy and environment parity addressed?
