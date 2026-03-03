# Issue #48 Re-Test Plan
**Date**: 2026-03-03
**Project**: federal-grant-portal-test (reusing existing project)
**Objective**: Validate full Phase 2→3→4 pipeline with all fixes applied

---

## Fixes Applied Since Previous Test

✅ **Issue #69**: Phase 2 refactored (removed require() calls)
✅ **Issue #70**: Phase 4 writes handoff file automatically
✅ **Issue #71**: Phase 4 captures PRD version correctly

---

## Test Sequence

### Pre-flight Checks
- [x] n8n container running
- [x] Ollama models available (qwen3.5:35b, qwen3.5:35b-a3b)
- [x] Workspace directory exists: `workspace/federal-grant-portal-test/`
- [ ] Old artifacts archived

### Phase 2: PRD Interview
**Workflow**: `phase-2-interview-refactored.json`
**Webhook**: `http://localhost:5678/webhook/prd-interview`

**Actions**:
1. Start interview via webhook POST
2. Complete interview conversation (provide Federal Grant Portal requirements)
3. Trigger PRD synthesis from interview
4. Verify `002-prd-interview.md` created automatically

**Expected Handoff**: `workspace/federal-grant-portal-test/handoffs/002-prd-interview.md`

### Phase 3: PRD Synthesis
**Workflow**: `phase-3-prd-synthesis.json`
**Input**: `002-prd-interview.md`

**Actions**:
1. Triggered automatically by Phase 2 (or manually via webhook)
2. Quality model synthesizes PRD
3. Verify `003-prd-refined.md` created automatically

**Expected Handoff**: `workspace/federal-grant-portal-test/handoffs/003-prd-refined.md`

**Validation**:
- 7 required sections present
- ≥3 FRs, ≥2 NFRs, ≥3 User Stories
- Risk table with Likelihood/Impact/Mitigation
- YAML frontmatter with version: v1

### Phase 4: Council Review
**Workflow**: `phase-4-council-review-fixed.json`
**Input**: `003-prd-refined.md`

**Actions**:
1. Triggered automatically by Phase 3 (or manually via webhook)
2. 4 reviewers + council chair execute
3. Verify `004-council-review.md` created automatically (Issue #70 fix)
4. Verify `prd_version_reviewed: v1` in frontmatter (Issue #71 fix)

**Expected Handoff**: `workspace/federal-grant-portal-test/handoffs/004-council-review.md`

**Validation**:
- All 5 reviewers produced output
- Council Chair synthesized consensus
- Verdict present (APPROVED / APPROVED WITH CONCERNS / REVISE AND RESUBMIT)
- Execution time < 20 minutes

---

## Resilience Tests (Sub-tasks 7.3-7.5)

### 7.3: Handoff Contract Validation
**Test**: Trigger Phase 3 with malformed `002-prd-interview.md`

**Steps**:
1. Backup valid `002-prd-interview.md`
2. Remove required section (e.g., "## Functional Requirements")
3. Trigger Phase 3 via webhook
4. Verify Phase 3 returns error with specific section name
5. Restore valid handoff

**Expected**: Error response within 1 second, before LLM call

### 7.4: Docker Restart Recovery
**Test**: Restart n8n mid-pipeline, resume from handoff files

**Steps**:
1. Complete Phase 2 and Phase 3 (handoffs 002 and 003 exist)
2. Run `docker compose restart`
3. Wait for startup (~15 seconds)
4. Trigger Phase 4 via webhook (should consume existing 003-prd-refined.md)
5. Verify Phase 4 completes successfully

**Expected**: Zero data loss, workflows re-activate, Phase 4 executes normally

### 7.5: Ollama Connectivity Failure
**Test**: Validate error handling when Ollama is unreachable

**Options**:
- **Option A (Design Review)**: Verify workflow has health check + error response nodes
- **Option B (Live Test)**: Stop Ollama, trigger workflow, verify error message

**Expected**: Error message "Ollama is not reachable at host.docker.internal:11434" within 300 seconds

---

## Success Criteria

- [ ] All 3 handoff files created automatically (002, 003, 004)
- [ ] Zero require() errors in Phase 2
- [ ] Phase 4 writes handoff file without manual intervention
- [ ] PRD version appears correctly in council review frontmatter
- [ ] Contract validation rejects malformed handoff
- [ ] Docker restart recovery works (15s, no data loss)
- [ ] Ollama failure returns actionable error
- [ ] Council review completes in < 20 minutes
- [ ] No manual file manipulation required

---

## Test Artifacts

All artifacts saved to:
- `workspace/federal-grant-portal-test/handoffs/` (handoff files)
- `workspace/federal-grant-portal-test/archive/` (previous test artifacts)
- `docs/issue-48-retest-results.md` (test results)

---

## Notes

**Project Reused**: Federal Grant Management Portal (same project from previous test)
**Interview Approach**: Provide same requirements as previous test for comparison
**Baseline**: Previous test artifacts archived in `workspace/federal-grant-portal-test/archive/`
