# Phase 4 Deep Audit - Executive Summary

**Date**: 2026-03-02
**Auditor**: Claude Sonnet 4.5
**Scope**: Complete compliance check against PRD v3.5, task list, and council review feedback

---

## TL;DR

**Verdict**: ⚠️ **Phase 4 is functionally working BUT has specification gaps that must be fixed before proceeding to Phase 5**

### What Works ✅
- Core council review (4 reviewers + chair) produces excellent, actionable output
- Model batching prevents GPU thrashing (council review feedback implemented)
- Chair synthesis perfectly matches FR-4.5 spec (consensus/conflicts/verdict/revisions)
- Partial result preservation via state files
- Test run succeeded end-to-end

### What's Broken ❌
- **User decision flow incomplete** - UI exists but doesn't apply PRD revisions
- **Re-review gate non-functional** - Can't actually reconvene council
- **Missing retry logic** - Violates FR-8.4.2 (required for True MVP)
- **Ephemeral state files** - Using `/tmp` instead of workspace (lost on restart)
- **Inconsistent patterns** - Phase 4 uses different approach than Phases 2-3

---

## Detailed Reports

Created three comprehensive audit documents:

1. **phase-4-compliance-audit.md** (13,000 words)
   - FR-4.x requirements compliance (FR-4.1 through FR-4.9)
   - FR-8.4 LLM resilience compliance (5 sub-requirements)
   - FR-10.11B model batching compliance
   - Task list compliance (10 subtasks assessed)
   - Council review feedback implementation status
   - Architecture violation assessment

2. **cross-workflow-consistency-plan.md** (5,000 words)
   - Pattern analysis: Phases 2, 3, 4
   - Inconsistency identification (4 major issues)
   - Architecture assessment (3 patterns evaluated)
   - Retrofit strategy (3 options, 1 recommended)
   - Implementation order with time estimates

3. **This document** (executive summary)

---

## Critical Issues (Must Fix Before Phase 5)

### 1. PRD Revision Logic Missing ❌
**FR Violated**: FR-4.6
**Impact**: Users can't act on council recommendations within the system
**What's Missing**:
- Accept button doesn't update PRD file
- No version increment (v1 → v2)
- "Apply & Continue" is non-functional

**Fix Required**: Implement task 6.7
- Add Ollama call to prd-writer with accepted recommendations
- Increment version number
- Write revised PRD to workspace

**Time**: 2-3 hours

### 2. Re-Review Loop Missing ❌
**FR Violated**: FR-4.9
**Impact**: Can't reconvene council after revisions
**What's Missing**:
- "Reconvene Council" button doesn't loop back
- No review counter increment (r1 → r2 → r3)
- No delta review logic

**Fix Required**: Implement task 6.8
- Add workflow loop from gate back to "Load PRD"
- Increment review counter in filename
- Preserve previous review states

**Time**: 2-3 hours

### 3. Retry Logic Missing ❌
**FR Violated**: FR-8.4.2
**Impact**: Transient failures cause full workflow failure
**What's Missing**: All LLM HTTP nodes lack retry configuration

**Fix Required**: Add to ALL phases (not just Phase 4)
```json
"options": {
  "timeout": 300000,
  "retry": {
    "maxRetries": 3,
    "retryWaitTime": 30000
  }
}
```

**Time**: 1 hour (all phases)

### 4. State Files Not Durable ⚠️
**FR Violated**: FR-8.4.3 (partial implementation)
**Impact**: State lost on Docker restart
**What's Wrong**: Using `/tmp/workflow-state-*.json` (ephemeral)

**Fix Required**: Move to workspace
```diff
- const stateFile = `/tmp/workflow-state-${$execution.id}.json`;
+ const stateFile = `/home/node/workspace/${project}/council-state-r${reviewNum}.json`;
```

**Time**: 30 minutes

---

## High Priority Issues (Should Fix)

### 5. Specialist Selection Not Implemented ❌
**FR Violated**: FR-4.2, FR-4.3
**Impact**: Can't add specialized reviewers (Compliance, Performance, etc.)
**Decision Needed**: Is this True MVP or Full MVP?

PRD says "shall recommend" (not optional), but we built manual-only checkboxes that aren't exposed in UI.

**Options**:
A. Implement auto-scan + UI (task 6.1-6.2, ~6 hours)
B. Defer to Full MVP with explicit PRD amendment

**Recommendation**: Clarify with user, likely defer to Full MVP

### 6. Timeout Inconsistency ⚠️
**FR Violated**: FR-8.4.1 (in Phases 2-3)
**Impact**: Phase 2-3 use default 60s timeout, only Phase 4 has 300s

**Fix Required**: Add 300s timeout to Phase 2 and 3 LLM calls

**Time**: 30 minutes

### 7. State Management Inconsistency ⚠️
**Pattern Violation**: Three different approaches across three phases

- Phase 2: Workspace state file
- Phase 3: Pure n8n data flow
- Phase 4: Temp state file

**Fix Required**: Standardize on workspace state files (see cross-workflow-consistency-plan.md, Option 2)

**Time**: 2-3 hours

---

## What We Did Right ✅

### 1. Model Change (qwen3:30b-a3b)
**Council Feedback**: Reviewer 1, Concern 1 - Model swap batching
**Implementation**: ✅ Fully addressed
- Both models now ~18GB (can coexist on 24GB GPU)
- Speed model (4 reviewers) → Quality model (chair) sequencing
- Warm-up request before chair
- No intermediate swaps

**Verdict**: Excellent implementation of council recommendation

### 2. Chair Synthesis Format
**PRD Requirement**: FR-4.5 (4 specific sections)
**Implementation**: ✅ Perfect compliance
- Consensus Points (where reviewers agree)
- Conflicts (both sides presented)
- Overall Verdict (APPROVED/CONDITIONAL/REVISE)
- Required Revisions (numbered, specific)

**Test Evidence**: Real PRD test produced all sections correctly

### 3. Partial Result Preservation
**PRD Requirement**: FR-8.4.3
**Implementation**: ✅ Working (but needs durability fix)
- State files preserve R1-R4 if Chair fails
- Can retry from last successful point
- **Issue**: Using `/tmp` instead of workspace

### 4. Connectivity Pre-Check
**PRD Requirement**: FR-8.4.4
**Implementation**: ✅ Fully compliant
- HTTP - Ollama Health node
- Clear error message with model names
- `alwaysOutputData: true` pattern

---

## Compliance Scorecard

### FR-4 (Council Review)
| Requirement | Status | Notes |
|-------------|--------|-------|
| FR-4.1: Core reviewers | ✅ | All 4 implemented |
| FR-4.2: Auto-recommend specialists | ❌ | Not implemented |
| FR-4.3: User modifies composition | ❌ | Not implemented |
| FR-4.4: Reviewer output format | ✅ | Perfect compliance |
| FR-4.5: Chair synthesis | ✅ | All 4 sections present |
| FR-4.6: User decision flow | ❌ | UI only, no logic |
| FR-4.7: Council mandatory | ✅ | By design |
| FR-4.8: Handoff file | ✅ | Working |
| FR-4.9: Re-review gate | ❌ | UI only, no loop |

**FR-4 Compliance**: 5/9 ✅, 0/9 ⚠️, 4/9 ❌

### FR-8.4 (LLM Resilience)
| Requirement | Phase 2 | Phase 3 | Phase 4 |
|-------------|---------|---------|---------|
| FR-8.4.1: 300s timeout | ❌ | ❌ | ✅ |
| FR-8.4.2: 3 retries | ❌ | ❌ | ❌ |
| FR-8.4.3: Partial preservation | N/A | N/A | ✅* |
| FR-8.4.4: Pre-check | ✅ | ✅ | ✅ |
| FR-8.4.5: Warm-up | N/A | N/A | ✅ |

*Asterisk = Works but uses ephemeral `/tmp`

**FR-8.4 Compliance**: Phase 4 = 4/5, Phases 2-3 = 1/2

---

## Recommendations

### Do NOT Proceed to Phase 5 Until:
1. ✅ Critical issues 1-4 are fixed (8-10 hours)
2. ✅ Phase 4 end-to-end test passes with:
   - User accepts recommendations → PRD revised
   - Reconvene council → second review completes
   - Docker restart mid-workflow → state preserved

### Decision Points for User:
1. **Specialist selection** - True MVP or Full MVP?
2. **State management pattern** - Accept workspace state files as standard?
3. **Timeline adjustment** - Add 8-12 hours to True MVP estimate

### Proposed Next Steps:
1. Review this audit with user
2. Get decisions on specialist selection + state pattern
3. Fix Critical issues 1-4 (Priority 1)
4. Fix High Priority issues 5-7 (Priority 2)
5. Complete Phase 4 testing
6. **Then** proceed to Phase 5

---

## Estimated Fix Time

| Priority | Issues | Time Estimate |
|----------|--------|---------------|
| **Critical** (Must Fix) | PRD revision, Reconvene loop, Retry logic, State durability | 8-10 hours |
| **High** (Should Fix) | Specialist UI, Timeout consistency, State pattern | 4-6 hours |
| **Medium** (Nice to Have) | Context window docs, GPU VRAM check | 2-3 hours |

**Total to True MVP Complete**: 12-16 hours

---

## Files Created

1. `/docs/phase-4-compliance-audit.md` - Full compliance report
2. `/docs/cross-workflow-consistency-plan.md` - Retrofit strategy
3. `/docs/phase-4-audit-summary.md` - This file

**Commits Made**:
- `9e61cd3`: fix: switch quality model to qwen3:30b-a3b for Chair synthesis
- `4d16275`: docs: update model configuration to qwen3:30b-a3b

**Next Commit Should Include**:
- These audit documents
- Decision on specialist selection
- Plan approval before implementation

---

## Verdict

**Phase 4 Status**: ⚠️ **60% Complete**

**Core functionality works**, but **specification gaps** prevent claiming "True MVP Phase 4 complete."

**Recommendation**: **PAUSE** - Fix critical issues before building Phase 5 on incomplete foundation.

**Rationale**:
- Investing 8-10 hours now prevents compounding technical debt
- Phase 5 depends on Phase 4 handoff working correctly
- User decision flow is core to the system's value proposition
- FR-8.4 compliance is non-negotiable for production use

**User Action Required**:
1. Review audit documents
2. Approve fix plan or propose alternatives
3. Make decisions on specialist selection + state pattern
4. Approve time investment (8-10 hours critical fixes)
