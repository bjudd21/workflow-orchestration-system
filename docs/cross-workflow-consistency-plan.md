# Cross-Workflow Consistency Analysis & Fix Plan

**Date**: 2026-03-02
**Purpose**: Identify inconsistencies between Phases 2, 3, and 4, and plan retrofit strategy

---

## Pattern Analysis

### Phase 2 (Interview)
**State Management**: `workspace/{project}/interview-state.json`
- Persistent conversation state
- Survives n8n restarts
- JSON file with conversation history

**Data Flow**: Mixed
- State file for conversation persistence
- n8n node-to-node for LLM request/response

**HTTP Nodes**: Simple, direct Ollama calls
```json
{
  "model": "qwen3.5:35b-a3b",
  "messages": [...],
  "stream": false
}
```

**Error Handling**:
- Ollama health check (5s timeout)
- `continueOnFail: true` on health check
- No retry logic

---

### Phase 3 (Synthesis)
**State Management**: None (pure n8n data flow)
- No state files
- All data flows through nodes
- Version tracking in PRD file naming only

**Data Flow**: Native n8n
- `$input.first().json.field` references
- Clean node-to-node passing
- IF nodes route based on inline conditions

**HTTP Nodes**: Simple, direct Ollama calls
```json
{
  "model": "qwen3.5:35b-a3b",
  "prompt": "...",
  "stream": false,
  "options": { "num_predict": 8000 }
}
```

**Error Handling**:
- Ollama health check (10s timeout)
- `continueOnFail: true` on health check
- No retry logic

---

### Phase 4 (Council Review)
**State Management**: `/tmp/workflow-state-${$execution.id}.json`
- Ephemeral temp file (doesn't survive reboot)
- Read/write in every Code node
- Centralized state object with all data

**Data Flow**: File-based (anti-pattern for n8n)
- Every node reads state file
- Every node writes state file
- n8n data flow bypassed

**HTTP Nodes**: Simple, direct Ollama calls
```json
{
  "model": "qwen3:30b-a3b",
  "prompt": "...",
  "stream": false,
  "temperature": 0.7,
  "num_predict": 6000
}
```

**Error Handling**:
- Ollama health check (default timeout)
- `alwaysOutputData: true` on health check
- **300-second timeout on LLM calls** (only Phase 4 has this)
- No retry logic

---

## Inconsistencies Identified

### 1. State Management ⚠️
| Phase | Pattern | Durability | Survives Restart? | n8n Native? |
|-------|---------|------------|-------------------|-------------|
| 2 | Workspace JSON file | High | ✅ Yes | ❌ No (hybrid) |
| 3 | None (pure n8n flow) | High | ✅ Yes (in handoffs) | ✅ Yes |
| 4 | Temp JSON file | Low | ❌ No (ephemeral) | ❌ No |

**Issue**: Three different approaches, no consistency

**Best Practice**: Phase 3 (pure n8n) for simple workflows, Phase 2 (workspace state) for conversation persistence

### 2. Timeout Configuration ⚠️
| Phase | Health Check Timeout | LLM Call Timeout |
|-------|---------------------|------------------|
| 2 | 5s | Default (~60s) |
| 3 | 10s | Default (~60s) |
| 4 | Default (~60s) | 300s |

**Issue**: Only Phase 4 implements FR-8.4.1 (300s timeout for LLM calls)

**Best Practice**: FR-8.4 applies to **ALL phases**, not just Phase 4

### 3. Retry Logic ❌
| Phase | Retries on LLM Calls |
|-------|---------------------|
| 2 | ❌ None |
| 3 | ❌ None |
| 4 | ❌ None |

**Issue**: FR-8.4.2 requires 3 retries with backoff, **NOT IMPLEMENTED** in any phase

**Best Practice**: Add to all phases

### 4. Error Handling Patterns ⚠️
| Phase | `continueOnFail` | `alwaysOutputData` | Clear Error Messages |
|-------|------------------|--------------------|--------------------|
| 2 | ✅ Health check | ❌ | ⚠️ Generic |
| 3 | ✅ Health check | ❌ | ⚠️ Generic |
| 4 | ✅ Health check | ✅ Health check | ✅ Specific models listed |

**Issue**: Phase 4 has better error handling pattern

**Best Practice**: Adopt Phase 4's `alwaysOutputData` + specific error messages

---

## Architecture Assessment

### Phase 2 Pattern (Workspace State File)
**Pros**:
- ✅ Durable (survives restarts)
- ✅ Useful for conversation state
- ✅ Easy to debug (can inspect file)
- ✅ Enables resume from where you left off

**Cons**:
- ❌ Not pure n8n (adds external dependency)
- ❌ Requires file I/O in Code nodes
- ❌ State management logic in every node

**When to Use**: Long-running conversational workflows where state must persist between sessions

### Phase 3 Pattern (Pure n8n Data Flow)
**Pros**:
- ✅ True n8n pattern (idiomatic)
- ✅ Simple, no file I/O
- ✅ Easy to understand data flow
- ✅ All data visible in execution history

**Cons**:
- ❌ Doesn't preserve partial progress on failure
- ❌ Can't resume from mid-workflow

**When to Use**: Single-execution workflows with clear start and end

### Phase 4 Pattern (Temp State File)
**Pros**:
- ✅ Enables partial result preservation (FR-8.4.3)
- ✅ Easy to debug (can inspect state)
- ✅ Avoids complex node reference syntax

**Cons**:
- ❌ **Not durable** (ephemeral `/tmp`, lost on reboot)
- ❌ Not pure n8n (anti-pattern)
- ❌ State management logic in every node
- ❌ Doesn't survive Docker container restarts

**When to Use**: Multi-step LLM workflows where partial preservation matters

---

## Recommended Patterns

### Pattern A: Pure n8n (Simple Workflows)
**Use For**: Phase 3, any single-execution workflow
```javascript
// Code node
const data = $input.first().json;
return [{ json: { ...data, newField: "value" } }];
```

**Characteristics**:
- No state files
- All data via `$input` and `return [{ json: {...} }]`
- IF nodes use inline expressions

### Pattern B: Workspace State (Conversational Workflows)
**Use For**: Phase 2, any workflow needing session persistence
```javascript
// Code node
const stateFile = `/home/node/workspace/${project}/session-state.json`;
const fs = require('fs');
let state = fs.existsSync(stateFile) ? JSON.parse(fs.readFileSync(stateFile, 'utf8')) : {};
state.newField = "value";
fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
return [{ json: { ...state } }];
```

**Characteristics**:
- Durable workspace state file
- Survives restarts
- Good for interviews, iterative processes

### Pattern C: Workspace State with Resilience (Multi-LLM Workflows)
**Use For**: Phase 4, Phase 5, any multi-step LLM workflow
```javascript
// Code node
const stateFile = `/home/node/workspace/${project}/workflow-state-${workflowName}.json`;
const fs = require('fs');
let state = fs.existsSync(stateFile) ? JSON.parse(fs.readFileSync(stateFile, 'utf8')) : {};
state.reviewers = state.reviewers || [];
state.reviewers.push({ name: "Technical", output: "..." });
fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
return [{ json: { ...state } }];
```

**Characteristics**:
- Durable workspace state (not `/tmp`)
- Enables FR-8.4.3 (partial result preservation)
- Can resume from last successful step
- Survives restarts

---

## Retrofit Strategy

### Option 1: Standardize on Pure n8n (Simplest)
**Target Pattern**: Phase 3

**Changes Required**:
- **Phase 2**: No changes (conversation state is valid use case)
- **Phase 4**: **Refactor** - Remove state files, use n8n data flow

**Pros**: Most idiomatic, simplest to understand
**Cons**: Loses FR-8.4.3 compliance (partial result preservation)

**Verdict**: ❌ **Not Recommended** - Violates FR-8.4.3

### Option 2: Standardize on Workspace State (Most Durable)
**Target Pattern**: Pattern C (Workspace State with Resilience)

**Changes Required**:
- **Phase 2**: Minor - Already uses workspace state
- **Phase 3**: **Add** - Workspace state file for version tracking
- **Phase 4**: **Fix** - Move from `/tmp` to `workspace/{project}/council-state.json`

**Pros**:
- ✅ FR-8.4.3 compliant (partial result preservation)
- ✅ Durable (survives restarts)
- ✅ Consistent across all phases
- ✅ Easy to debug

**Cons**:
- Requires state management in all workflows
- Not pure n8n pattern

**Verdict**: ✅ **RECOMMENDED** - Best balance of resilience and consistency

### Option 3: Hybrid (Context-Dependent)
**Target Patterns**:
- Phase 2-3: Keep as-is
- Phase 4: Fix to workspace state

**Changes Required**:
- **Phase 2**: No changes
- **Phase 3**: No changes
- **Phase 4**: Move from `/tmp` to workspace

**Pros**: Minimal changes, respects existing patterns
**Cons**: Inconsistent, harder to document

**Verdict**: ⚠️ **Acceptable** - Pragmatic but not ideal

---

## Recommended Fix Plan

### Adopt Option 2: Standardize on Workspace State

### Phase-by-Phase Changes

#### Phase 2 (Interview) - No Changes ✅
- Already uses workspace state for conversation
- Pattern: Keep as-is

#### Phase 3 (Synthesis) - Minor Addition
**Current**: Pure n8n data flow

**Proposed**: Add workspace state for version tracking only
```javascript
// Add to "Code - Process Synthesis"
const stateFile = `/home/node/workspace/${project}/synthesis-state.json`;
const fs = require('fs');
let state = { versions: [], currentVersion: version };
fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
```

**Purpose**: Enable resume if synthesis fails mid-process

**Impact**: Low (optional, FR-8.4.3 compliance)

#### Phase 4 (Council Review) - Critical Fix
**Current**: `/tmp/workflow-state-${$execution.id}.json` (ephemeral)

**Proposed**: `/home/node/workspace/${project}/council-state-r${reviewNum}.json` (durable)

**Changes**:
```diff
- const stateFile = `/tmp/workflow-state-${$execution.id}.json`;
+ const stateFile = `/home/node/workspace/${$json.project}/council-state-r${reviewNum}.json`;
```

**Purpose**:
- Survives Docker restarts
- Enables re-review loop (r1, r2, r3 states preserved)
- True FR-8.4.3 compliance

**Impact**: High (fixes durability issue)

### FR-8.4 Standardization

Apply to **ALL phases**:

#### FR-8.4.1: 300-Second Timeout
Add to all LLM HTTP nodes:
```json
{
  "options": {
    "timeout": 300000
  }
}
```

#### FR-8.4.2: Retry Logic
Add to all LLM HTTP nodes:
```json
{
  "options": {
    "timeout": 300000,
    "retry": {
      "maxRetries": 3,
      "retryWaitTime": 30000
    }
  }
}
```

#### FR-8.4.4: Enhanced Health Check
Standardize across all phases:
```json
{
  "alwaysOutputData": true,
  "options": {
    "response": {
      "response": {
        "fullResponse": false,
        "neverError": true,
        "responseFormat": "json"
      }
    }
  }
}
```

---

## Implementation Order

### Priority 1: Critical Fixes (Do First)
1. ✅ **Phase 4: Move state from `/tmp` to workspace** (fixes durability)
2. ✅ **All Phases: Add 300s timeout to LLM calls** (FR-8.4.1)
3. ✅ **All Phases: Add retry logic** (FR-8.4.2)

### Priority 2: Phase 4 Functional Completion
4. ❌ **Implement PRD revision logic** (FR-4.6)
5. ❌ **Implement reconvene loop** (FR-4.9)

### Priority 3: Consistency (After Phase 4 works)
6. ⚠️ **Phase 3: Add optional state file** (for consistency)
7. ⚠️ **All Phases: Standardize health check pattern**

---

## Testing Strategy

### After Each Change
1. Run end-to-end test for affected phase
2. Verify state file location and content
3. Test Docker restart resilience:
   ```bash
   # Mid-workflow:
   docker compose down
   docker compose up -d
   # Resume workflow, verify state preserved
   ```

### Full System Test
After all changes, run complete True MVP pipeline:
- Phase 2: Interview
- Phase 3: Synthesis
- Phase 4: Council (with reconvene)
- Verify all handoff files created
- Verify state files in correct locations

---

## Summary

**Current State**: Inconsistent patterns, missing FR-8.4 compliance

**Recommended Approach**: Standardize on workspace state files for resilience

**Critical Changes**:
1. Move Phase 4 state to workspace (not `/tmp`)
2. Add 300s timeout to all phases
3. Add retry logic to all phases
4. Complete Phase 4 functional requirements

**Estimated Time**:
- Priority 1 (Critical): 2-3 hours
- Priority 2 (Phase 4 complete): 4-6 hours
- Priority 3 (Consistency): 2-3 hours
- **Total**: 8-12 hours

**Recommendation**: Fix Priority 1 and 2 before proceeding to Phase 5
