# Architectural Decisions Log

**Project**: PRDWorkflowSystem
**Date**: 2026-03-02
**Context**: Phase 4 compliance audit revealed specification gaps and cross-workflow inconsistencies

---

## Decision 1: State Management Pattern (ACCEPTED)

**Date**: 2026-03-02
**Status**: ✅ APPROVED
**Decision Maker**: Brian Judd + Claude Sonnet 4.5

### Context
Phase 4 audit revealed three different state management patterns across three phases:
- Phase 2: Workspace state file (`workspace/{project}/interview-state.json`)
- Phase 3: Pure n8n data flow (no state file)
- Phase 4: Ephemeral temp file (`/tmp/workflow-state-*.json`)

### Decision
**Standardize on workspace state files for multi-step LLM workflows**

### Rationale
1. **FR-8.4.3 Compliance**: "Partial result preservation" requires durable state
2. **Durability**: Workspace files survive Docker restarts, `/tmp` does not
3. **Debuggability**: State files make troubleshooting easier (can inspect between steps)
4. **Consistency**: One pattern for all multi-step workflows

### Pattern Definition

**For Conversational Workflows** (Phase 2):
```javascript
const stateFile = `/home/node/workspace/${project}/interview-state.json`;
```

**For Multi-LLM Workflows** (Phase 4, 5):
```javascript
const stateFile = `/home/node/workspace/${project}/${workflow}-state-r${reviewNum}.json`;
```

**For Simple Single-Execution Workflows** (Phase 3):
- Option A: Add minimal state for version tracking (preferred for consistency)
- Option B: Keep pure n8n data flow (acceptable exception)

### Implementation
- Phase 2: No changes (already compliant)
- Phase 3: Optional - add minimal state file for consistency
- Phase 4: **CRITICAL** - Move from `/tmp` to workspace (Session 2)
- Phase 5-6: Follow workspace state pattern from start

### Alternatives Considered
1. **Pure n8n data flow everywhere** - Rejected (violates FR-8.4.3)
2. **Temp files everywhere** - Rejected (not durable)

---

## Decision 2: Specialist Selection Scope (DEFERRED)

**Date**: 2026-03-02
**Status**: ✅ APPROVED (Defer to Full MVP)
**Decision Maker**: Brian Judd + Claude Sonnet 4.5

### Context
FR-4.2 and FR-4.3 require:
- System analyzes PRD and recommends specialized reviewers
- User can accept/add/remove specialists
- Task 6.1-6.2 specify auto-scan + checkbox UI

Current implementation: Manual checkboxes exist but not exposed in UI, no auto-scan

### Decision
**Defer specialist selection to Full MVP (Milestone 2)**

### Rationale
1. **Core 4 reviewers provide sufficient value** - Test run produced excellent output
2. **Significant scope addition** - Auto-scan + UI = 6 hours
3. **True MVP focus** - Validate core pipeline first
4. **Low risk** - Can add specialists manually in Full MVP if needed

### Impact
- True MVP has 4 core reviewers only (Technical, Security, Executive, User Advocate)
- Full MVP adds 6 specialized reviewers + auto-scan + selection UI
- PRD FR-4.2/FR-4.3 moved from True MVP to Full MVP scope

### Implementation
- Mark FR-4.2, FR-4.3 as Full MVP in PRD
- Document "Core 4 only" limitation in README
- Task 6.2 (specialist selection) moves to Milestone 2
- Phase 4 workflow keeps specialist loop structure for future use

### Alternatives Considered
1. **Implement now for True MVP** - Rejected (extends timeline, validates same value)
2. **Remove from Full MVP** - Rejected (specialist reviewers add real value for complex projects)

---

## Decision 3: Timeline Investment (APPROVED)

**Date**: 2026-03-02
**Status**: ✅ APPROVED
**Decision Maker**: Brian Judd + Claude Sonnet 4.5

### Context
Phase 4 compliance audit identified critical specification gaps:
- FR-4.6 (PRD revision logic) - not implemented
- FR-4.9 (reconvene loop) - not implemented
- FR-8.4.2 (retry logic) - missing in all phases
- FR-8.4.3 (state durability) - ephemeral `/tmp` not durable

### Decision
**Invest 8-12 hours to bring Phase 4 to full spec compliance before Phase 5**

### Rationale
1. **Foundational issues** - Phase 5 depends on Phase 4 handoff working correctly
2. **No shortcuts** - User decision flow is core to system value proposition
3. **FR-8.4 non-negotiable** - LLM resilience required for production use
4. **Prevents rework** - Fixing now cheaper than refactoring later

### Breakdown
- Session 1: Architectural decisions (30 min) - ✅ THIS SESSION
- Session 2: Foundational fixes (2-3 hours) - FR-8.4 + state durability
- Session 3: Phase 4 completion (4-6 hours) - FR-4.6 + FR-4.9
- Session 4: Testing (1-2 hours) - End-to-end validation

**Total**: 8-12 hours

### Alternatives Considered
1. **Proceed to Phase 5 now** - Rejected (builds on incomplete foundation)
2. **Fix Critical only (4 hours)** - Rejected (leaves user flow broken)
3. **Defer to "Phase 2"** - Rejected (creates technical debt)

---

## Decision 4: Implementation Sequence (APPROVED)

**Date**: 2026-03-02
**Status**: ✅ APPROVED
**Decision Maker**: Brian Judd + Claude Sonnet 4.5

### Decision
**Follow "Smart Order" - Architectural → Foundational → Phase 4 Completion → Testing**

### Sequence

#### Session 2: Foundational Fixes (2-3 hours)
1. Add 300s timeout to Phase 2, 3 LLM nodes (FR-8.4.1)
2. Add retry logic to all phases (FR-8.4.2)
3. Move Phase 4 state from `/tmp` to workspace (FR-8.4.3)

#### Session 3: Phase 4 Functional Completion (4-6 hours)
4. Implement PRD revision logic (FR-4.6)
5. Implement reconvene loop (FR-4.9)

#### Session 4: Testing (1-2 hours)
6. End-to-end test with reconvene
7. Docker restart resilience test

### Rationale
- **No rework** - State pattern locked in before implementing FR-4.6/4.9
- **Establishes patterns** - FR-8.4 fixes apply to future phases
- **Clear deliverables** - Each session has testable outcomes

---

## Summary

| Decision | Status | Impact |
|----------|--------|--------|
| Workspace state pattern | ✅ APPROVED | Standard for all multi-step workflows |
| Specialist selection | ✅ DEFERRED | Full MVP only (Core 4 in True MVP) |
| Timeline investment | ✅ APPROVED | 8-12 hours to spec compliance |
| Implementation sequence | ✅ APPROVED | Smart order prevents rework |

**Next Action**: Create GitHub issues and begin Session 2 (Foundational Fixes)
