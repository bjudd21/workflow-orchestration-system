# Phase 4 Council Review — Compliance Audit

**Audit Date**: 2026-03-02
**Audited By**: Claude Sonnet 4.5
**Purpose**: Verify Phase 4 implementation against PRD v3.5, task list, and council review feedback

---

## Executive Summary

Phase 4 Council Review workflow is **functionally working** but has **specification gaps** that need addressing before claiming "True MVP complete" status.

### Status Legend
- ✅ **Implemented & Tested** - Working as specified
- ⚠️ **Partially Implemented** - Core functionality works, but missing requirements
- ❌ **Not Implemented** - Required for True MVP but missing
- 🔮 **Full MVP Only** - Deferred to Full MVP per PRD

### Quick Status
| Category | Status | Notes |
|----------|--------|-------|
| Core Council (4 reviewers + chair) | ✅ | All working, producing quality output |
| FR-4.5 Chair Synthesis | ✅ | Consensus/Conflicts/Verdict/Revisions all present |
| FR-8.4 LLM Resilience | ⚠️ | 4/5 items implemented, missing retry logic |
| FR-10.11B Model Batching | ✅ | Speed model → Quality model sequencing working |
| Specialist Selection | ❌ | Manual only, no auto-scan or UI |
| User Decision Flow | ⚠️ | UI exists, PRD revision not implemented |
| State Management | ⚠️ | Working but uses pattern inconsistent with Phases 2-3 |

---

## 1. FR-4 Requirements Compliance

### FR-4.1: Core Reviewers ✅
**Requirement**: 4 core reviewers always present

**Status**: ✅ COMPLIANT

**Evidence**:
- Technical Reviewer: `prompts/prd-council/core/technical-reviewer.md`
- Security Reviewer: `prompts/prd-council/core/security-reviewer.md`
- Executive Reviewer: `prompts/prd-council/core/executive-reviewer.md`
- User Advocate: `prompts/prd-council/core/user-advocate.md`
- All prompts have stated biases, output format, severity/confidence ratings
- All executed successfully in test run (test-project)

### FR-4.2: Specialized Agent Recommendation ❌
**Requirement**: System analyzes PRD and recommends specialists based on content signals

**Status**: ❌ NOT IMPLEMENTED

**What's Missing**:
- No PRD content scanning (e.g., detecting "FISMA" → recommend Compliance Reviewer)
- No automatic recommendation logic
- Current implementation: Manual checkbox selection (exists in UI but not connected)

**Task Reference**: Task 6.2 says "specialist selection form: checkboxes" but 6.1 says "scan PRD for council triggers"

**Decision Needed**:
- Is auto-scan required for True MVP? PRD says "shall recommend" (not optional)
- Task 6.1: "Node: Scan PRD for council triggers (Code node — match against agents.json council_triggers)"

**Recommendation**: Implement as task 6.1 specifies, or document as Full MVP deferral with PRD amendment

### FR-4.3: User Modifies Composition ❌
**Requirement**: User can accept/add/remove specialists

**Status**: ❌ NOT IMPLEMENTED

**What's Missing**:
- No UI for specialist selection in True MVP
- Checkbox form exists in workflow but not exposed in GET webhook UI
- Users cannot currently select which specialists to include

**Decision Needed**: Is this True MVP or Full MVP?
- PRD places it in FR-4 (no MVP qualifier)
- Task 6.2 explicitly includes it: "Add specialist selection form: checkboxes"

**Recommendation**: Implement specialist selection UI or defer to Full MVP with explicit PRD amendment

### FR-4.4: Reviewer Output Format ✅
**Requirement**: 3-5 concerns/endorsements with severity/confidence

**Status**: ✅ COMPLIANT

**Evidence**:
- All 4 reviewer prompts specify exact format
- Test run output shows proper structure (Finding 1-4 with Type/Severity/Confidence/Description/Recommendation)
- Chair synthesis preserves reviewer structure

### FR-4.5: Chair Synthesis ✅
**Requirement**: Consensus points, conflicts, recommended revisions, decisions for stakeholder

**Status**: ✅ COMPLIANT

**Evidence**:
- Chair prompt explicitly requires all 4 sections
- Test run output includes:
  - ✅ Consensus Points (areas where all reviewers agree)
  - ✅ Conflicts (Executive vs Technical on FR-8 removal)
  - ✅ Overall Verdict (REVISE AND RESUBMIT, properly escalated from Security CRITICAL)
  - ✅ Required Revisions (6 numbered, prioritized revisions)
- Format matches PRD spec exactly

### FR-4.6: User Decision Flow ⚠️
**Requirement**: User reviews output, accepts/rejects recommendations, produces new PRD version

**Status**: ⚠️ PARTIALLY IMPLEMENTED

**What Works**:
- ✅ UI presents council findings (GET /webhook/council-review)
- ✅ Accept/Reject buttons functional
- ✅ Textarea for revision selection

**What's Missing**:
- ❌ No PRD revision logic (accepting changes doesn't update PRD file)
- ❌ No version increment (v1 → v2 after accepting changes)
- ❌ "Apply & Continue" button doesn't actually apply changes

**Evidence**:
- UI JavaScript calls `/webhook/council-review-action` with `action: "decide"`
- Workflow has routing for "decide" action but no implementation nodes after routing

**Task Reference**: Task 6.7 says "Add PRD revision node: if recommendations accepted, call Ollama API (model: qwen3.5:35b) with prd-writer prompt + PRD + accepted changes → new PRD version"

**Impact**: High - users cannot act on council feedback within the system

**Recommendation**: Implement PRD revision logic as specified in task 6.7

### FR-4.7: Council Mandatory ✅
**Requirement**: Every PRD passes through council

**Status**: ✅ COMPLIANT (by design)

**Evidence**: Phase 4 is a separate workflow; Phase 5 would depend on Phase 4 handoff

### FR-4.8: Handoff File ✅
**Requirement**: Write to workspace/{project}/handoffs/004-council-review.md

**Status**: ✅ COMPLIANT

**Evidence**:
- Handoff file created in test run
- Path: `/home/bjudd/projects/PRDWorkflowSystem/workflow-orchestration-system-scaffold/workspace/test-project/handoffs/004-council-review.md`
- Size: 19KB
- Contains all reviewer outputs + chair synthesis

### FR-4.9: Re-Review Gate ⚠️
**Requirement**: After revisions, user chooses "Proceed" or "Reconvene Council"

**Status**: ⚠️ PARTIALLY IMPLEMENTED

**What Works**:
- ✅ UI has gate buttons (Proceed / Reconvene)
- ✅ Gate only appears after accept/reject decision
- ✅ JavaScript calls `/webhook/council-review-action` with `action: "gate"`

**What's Missing**:
- ❌ Reconvene logic not implemented (no loop back to reviewers)
- ❌ Recommendation logic for when to reconvene (Full MVP feature, correctly deferred)
- ❌ Review counter increment (r2, r3, etc.)

**Task Reference**: Task 6.8 says "Add re-review gate node (FR-4.9): present form with two options... If reconvene selected, loop back to step 6.1"

**Recommendation**: Implement reconvene loop for True MVP completion

---

## 2. FR-8.4 LLM Resilience Compliance

### FR-8.4.1: 300-Second Timeout ✅
**Requirement**: All LLM HTTP nodes have 300-second timeout

**Status**: ✅ COMPLIANT

**Evidence**: Grep workflow JSON shows `"timeout": 300000` on all HTTP Request nodes

### FR-8.4.2: 3 Retries with Backoff ❌
**Requirement**: 3 attempts with 30-second exponential backoff on failure

**Status**: ❌ NOT IMPLEMENTED

**What's Missing**:
- No retry logic in HTTP nodes
- n8n HTTP Request node has `retry` options but not configured

**Impact**: If Ollama has transient failure, workflow fails immediately instead of retrying

**Task Reference**: Task 6.3 says "300-second timeout, 3 retries per FR-8.4"

**Recommendation**: Add retry configuration to all HTTP Request nodes

### FR-8.4.3: Partial Result Preservation ✅
**Requirement**: If workflow fails mid-sequence, preserve completed outputs

**Status**: ✅ COMPLIANT

**Evidence**:
- State management using `/tmp/workflow-state-${$execution.id}.json`
- Each reviewer saves output to state file after completion
- If Chair fails, R1-R4 outputs are preserved in state
- User can retry from last successful point

**Implementation Method**: Temp file state management (see Section 4 for architecture assessment)

### FR-8.4.4: Connectivity Pre-Check ✅
**Requirement**: First node verifies Ollama connectivity

**Status**: ✅ COMPLIANT

**Evidence**:
- "HTTP - Ollama Health" node calls `GET host.docker.internal:11434/api/tags`
- Configured with `alwaysOutputData: true` and `neverError: true`
- IF node checks `Array.isArray($json.models)`
- Error path returns clear message: "Ollama unreachable. Ensure qwen3.5:35b-a3b and qwen3:30b-a3b are loaded."

### FR-8.4.5: Model Warm-Up ✅
**Requirement**: Warm-up request before Chair synthesis

**Status**: ✅ COMPLIANT

**Evidence**:
- "HTTP - Warmup Quality Model" node sends trivial request to `qwen3:30b-a3b`
- Prompt: "Respond with: ready"
- `num_predict: 10` (minimal tokens)
- Positioned after all speed-model reviewers, before Chair

---

## 3. FR-10.11B Model Batching Compliance ✅

**Requirement**: Batch LLM calls by model to minimize GPU swaps

**Status**: ✅ COMPLIANT

**Evidence**:
- All 4 core reviewers use `qwen3.5:35b-a3b` (speed model)
- Reviewers execute sequentially: R1 → R2 → R3 → R4
- After R4 completes, warm-up request loads `qwen3:30b-a3b` (quality model)
- Chair runs once on quality model
- **No intermediate model swaps**

**Council Review Feedback**: This directly implements Reviewer 1, Concern 1 recommendation from `council-review-prd-v3.4.md`

---

## 4. Architecture Violation Assessment

### State Management Pattern ⚠️

**Issue**: Phase 4 uses temp file state management (`/tmp/workflow-state-*.json`), inconsistent with Phases 2 and 3

**What We Built**:
```javascript
const stateFile = `/tmp/workflow-state-${$execution.id}.json`;
function readState() { return JSON.parse(fs.readFileSync(stateFile, 'utf8')); }
function writeState(state) { fs.writeFileSync(stateFile, JSON.stringify(state, null, 2)); }
```

Every Code node reads/writes this state file. Data flows through state, not n8n's native data flow.

**How Phases 2 & 3 Work**:
- Phase 2 (Interview): Uses `workspace/{project}/interview-state.json` for conversation state
- Phase 3 (Synthesis): No persistent state file; uses n8n's node-to-node data passing

**Why We Did This**:
- During troubleshooting, we had issues with:
  - Data loss through HTTP health check node
  - Complex node references (`$('Node Name').first().json.field`)
  - "Cannot read property 'json' of undefined" errors

**Is This a Violation?**

⚠️ **Mixed Assessment**:

**Arguments FOR (acceptable)**:
1. **FR-8.4.3 compliance**: Temp files enable partial result preservation
2. **Resilience**: If n8n execution history is cleared, state survives (though ephemeral `/tmp` doesn't survive reboot)
3. **Debugging**: State files make troubleshooting easier (can inspect state between steps)
4. **Works reliably**: No data loss, no "undefined" errors

**Arguments AGAINST (violation)**:
1. **Inconsistent with Phase 2-3**: Different pattern makes system harder to understand
2. **Not in PRD/tasks**: No specification for this pattern
3. **Ephemeral storage**: `/tmp` files don't survive Docker container restart
4. **n8n anti-pattern**: n8n is designed for node-to-node data flow, not file-based state

**Council Review Feedback**: Not addressed in council review (predates this implementation)

**Recommendation**:
- **Option A (Keep)**: Document this as the standard pattern and retrofit Phases 2-3 for consistency
- **Option B (Fix)**: Refactor Phase 4 to use n8n's native data flow like Phase 3
- **Option C (Hybrid)**: Use state files only for resilience (FR-8.4.3), primary flow via n8n data

### Missing Retry Logic ❌

**Issue**: FR-8.4.2 specifies 3 retries with exponential backoff, not implemented

**Impact**: Single transient failure (Ollama busy, network hiccup) causes full workflow failure

**Why We Missed This**:
- Focused on timeout (implemented)
- Focused on partial result preservation (implemented)
- Didn't configure n8n HTTP node's built-in retry mechanism

**Is This a Violation?**: Yes, FR-8.4 explicitly requires it

**Recommendation**: Add to all HTTP Request nodes:
```json
"options": {
  "timeout": 300000,
  "retry": {
    "maxRetries": 3,
    "retryWaitTime": 30000
  }
}
```

---

## 5. Task List Compliance

Checking against tasks-prd-workflow-system-v3.md, Task 6.0 (Build Phase 4: Council Review Workflow):

| Subtask | Requirement | Status | Notes |
|---------|-------------|--------|-------|
| 6.1 | Load PRD from handoffs/003 | ✅ | Implemented |
| 6.2 | Specialist selection form | ❌ | Form exists but not exposed in UI |
| 6.3 | Core reviewers (4 sequential Ollama calls, speed model, 300s timeout, 3 retries) | ⚠️ | Implemented except retries |
| 6.4 | Specialist loop | ❌ | Not implemented (no specialists in True MVP) |
| 6.5 | Warm-up + Chair synthesis (quality model) | ✅ | Implemented |
| 6.6 | User review node | ✅ | UI presents findings |
| 6.7 | PRD revision node | ❌ | UI exists but no revision logic |
| 6.8 | Re-review gate | ⚠️ | UI exists but no loop-back logic |
| 6.9 | Contract validation + file write | ✅ | Handoff file created |
| 6.10 | Export and test | ✅ | Workflow exported, tested successfully |

**Overall Task Compliance**: 5/10 fully implemented, 3/10 partially, 2/10 not implemented

---

## 6. Council Review Feedback Compliance

Checking against council-review-prd-v3.4.md recommendations:

### Reviewer 1 (Local LLM Infrastructure Engineer)

| Concern | Recommendation | Status | Notes |
|---------|----------------|--------|-------|
| Concern 1: Model swap overhead | Batch by model OR single-model mode | ✅ | Implemented batching |
| Concern 2: Context window limits | Add context window column to FR-10.11A | ❌ | Not implemented |
| Concern 3: GPU health check | Pre-flight VRAM check | ⚠️ | Ollama connectivity check only, not VRAM |

**Verdict**: Primary concern (model batching) fully addressed. Secondary concerns deferred.

### Reviewer 2 (AI Model Strategy Analyst)

| Concern | Recommendation | Status | Notes |
|---------|----------------|--------|-------|
| Concern 1: Model tag hardcoding | Abstract to config, not architecture | ✅ | Updated to env vars |
| Concern 2: Intelligence Index 42 claim | Qualify benchmark claims | N/A | Documentation issue, not implementation |
| Concern 3: MoE persona consistency | (Observational, no specific action) | N/A | Testing will reveal |

**Verdict**: Addressing through model configuration updates (completed in latest commits).

---

## 7. Cross-Workflow Consistency Issues

### State Management
- **Phase 2**: Uses `workspace/{project}/interview-state.json`
- **Phase 3**: Uses n8n native data flow (no state file)
- **Phase 4**: Uses `/tmp/workflow-state-${$execution.id}.json`

**Issue**: Three different patterns for three workflows

**Options**:
1. Standardize on temp files (requires Phase 2-3 refactor)
2. Standardize on n8n data flow (requires Phase 4 refactor)
3. Standardize on workspace state files (requires Phase 3-4 changes)

**Recommendation**: Option 2 (n8n native) for True MVP, Option 3 (workspace state) for Full MVP with model router

### HTTP Node Configuration
- **Phase 2**: Direct Ollama calls, simple jsonBody
- **Phase 3**: Direct Ollama calls, simple jsonBody
- **Phase 4**: Direct Ollama calls, complex state management, require() usage (later removed)

**Status**: Now consistent after removing require() calls

### Error Handling
- **Phase 2**: Connectivity pre-check, clear error messages
- **Phase 3**: Connectivity pre-check, clear error messages
- **Phase 4**: Connectivity pre-check, clear error messages, **but missing retry logic**

**Issue**: Phase 4 missing retry logic that should be in all phases

**Recommendation**: Add retry to all phases, not just Phase 4

---

## 8. Recommendations

### Critical (Must Fix for True MVP)
1. **Implement PRD revision logic (Task 6.7)** - Users can't act on council feedback
2. **Add retry logic to all LLM HTTP nodes** - FR-8.4.2 compliance
3. **Implement reconvene loop (Task 6.8)** - Re-review gate doesn't work

### High Priority (Should Fix for True MVP)
4. **Specialist selection decision** - Clarify if True MVP or Full MVP, implement or defer
5. **Standardize state management** - Choose one pattern, retrofit all workflows

### Medium Priority (Full MVP or Phase 2)
6. **Context window documentation** - Add to FR-10.11A per council feedback
7. **GPU VRAM pre-check** - Enhance Ollama health check

### Low Priority (Quality of Life)
8. **State file location** - Move from `/tmp` to `workspace` for durability
9. **Specialist auto-scan** - Implement PRD content triggers (if not deferred to Full MVP)

---

## 9. Verdict

**Phase 4 Status**: ⚠️ **Functionally Working, Specification Incomplete**

**What Works**:
- ✅ Core council review (4 reviewers + chair) produces high-quality output
- ✅ Model batching prevents GPU thrashing
- ✅ Partial result preservation works
- ✅ Chair synthesis matches PRD spec exactly
- ✅ Handoff file created correctly

**What's Missing**:
- ❌ User decision flow incomplete (no PRD revision)
- ❌ Re-review gate non-functional (no loop-back)
- ❌ Retry logic missing (FR-8.4.2 violation)
- ❌ Specialist selection not exposed
- ⚠️ State management pattern inconsistent

**Recommendation**:
**Do NOT proceed to Phase 5** until Critical items (1-3) are fixed. Phase 4 must be complete before building on top of it.

**Estimated Fix Time**: 4-6 hours to address Critical items
