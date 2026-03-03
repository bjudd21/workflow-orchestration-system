# Testing Guide: Issue #48 Re-Test

Quick reference for running the full Phase 2→3→4 integration test.

---

## Prerequisites

Before running tests, ensure:
- ✅ n8n container is running (`docker compose ps`)
- ✅ Ollama is running (`ollama list`)
- ✅ Both models available: `qwen3.5:35b` and `qwen3.5:35b-a3b`
- ✅ Fixed workflows imported in n8n:
  - `phase-2-interview-refactored.json` (Issue #69 fix)
  - `phase-3-prd-synthesis.json`
  - `phase-4-council-review-fixed.json` (Issues #70 & #71 fixes)

---

## Test Execution

### Step 1: Pre-Flight Check

```bash
./verify-workflows.sh
```

**What it checks:**
- n8n accessibility (http://localhost:5678)
- Ollama connectivity and models
- Workspace directory structure
- Existing handoff files
- Webhook endpoint accessibility

**Expected output:**
```
✓ n8n is running
✓ Ollama is running
✓ qwen3.5:35b and qwen3.5:35b-a3b available
✓ workspace/federal-grant-portal-test exists
✓ Webhook endpoint exists
```

---

### Step 2: Run Interview Script

```bash
./test-phase2-interview.sh
```

**What it does:**
1. Sends initial project description to Phase 2 webhook
2. Continues conversation with 4-5 follow-up messages
3. Completes interview and triggers PRD synthesis
4. Displays session ID and response excerpts

**Expected outputs:**
- Session ID returned from first message
- Interviewer responses after each message
- Final confirmation that interview is complete

**Duration:** ~2-3 minutes (depending on Ollama response time)

---

### Step 3: Verify Handoff Files

```bash
ls -lh workspace/federal-grant-portal-test/handoffs/
```

**Expected files:**
- `002-prd-interview.md` (~10-20KB) - Created by Phase 2
- `003-prd-refined.md` (~20-30KB) - Created by Phase 3 (may take 1-2 minutes)
- `004-council-review.md` (~10-20KB) - Created by Phase 4 (may take 2-3 minutes)

**Timing:**
- Phase 2 completes immediately after script finishes
- Phase 3 triggers automatically (1-2 min for quality model)
- Phase 4 triggers automatically (2-3 min for 4 reviewers + chair)

---

### Step 4: Monitor Execution

**Option A: Check files periodically**
```bash
watch -n 5 'ls -lh workspace/federal-grant-portal-test/handoffs/'
```

**Option B: Monitor n8n UI**
- Open: http://localhost:5678
- Login: admin / changeme
- Click "Executions" to see real-time progress

---

## Troubleshooting

### Webhook Returns 404
**Problem:** Phase 2 workflow not active in n8n

**Solution:**
1. Open n8n UI: http://localhost:5678
2. Check if "PRD Interview (Phase 2)" workflow exists
3. If not, import: `workflows/phase-2-interview-refactored.json`
4. Activate the workflow (toggle in top-right)

### Session ID Not Returned
**Problem:** Webhook payload format mismatch

**Solution:**
1. Check n8n execution history for errors
2. Look for "Webhook" node output in execution details
3. Verify payload structure matches webhook expectations

### No Handoff Files Created
**Problem:** Workflows not chaining correctly

**Solution:**
1. Check n8n execution history for each phase
2. Verify each workflow completed successfully
3. Check for errors in "Write Binary File" nodes
4. Confirm workspace directory has write permissions

### Ollama Timeout
**Problem:** Model swap or GPU memory issue

**Solution:**
1. Check GPU memory: `nvidia-smi`
2. Unload current model: `ollama stop`
3. Reload model: `ollama run qwen3.5:35b-a3b` (or `:35b`)
4. Re-trigger failed phase via n8n

---

## Expected Results

### Full Success
- ✅ All 3 handoff files exist
- ✅ Phase 2 completes without require() errors
- ✅ Phase 4 writes handoff file automatically (Issue #70 fix)
- ✅ Council review shows `prd_version_reviewed: v1` (Issue #71 fix)
- ✅ Total pipeline time: ~5-8 minutes

### Validation Commands

```bash
# Check all handoffs exist
ls workspace/federal-grant-portal-test/handoffs/*.md

# Verify Phase 2 handoff structure
head -20 workspace/federal-grant-portal-test/handoffs/002-prd-interview.md

# Verify Phase 3 PRD sections
grep "^## " workspace/federal-grant-portal-test/handoffs/003-prd-refined.md

# Verify Phase 4 PRD version tracking (Issue #71 fix)
grep "prd_version_reviewed:" workspace/federal-grant-portal-test/handoffs/004-council-review.md
```

---

## Resilience Tests (After Basic Test Succeeds)

### Test 1: Malformed Handoff Validation
```bash
# Backup valid handoff
cp workspace/federal-grant-portal-test/handoffs/003-prd-refined.md \
   workspace/federal-grant-portal-test/archive/003-backup.md

# Remove required section
sed -i '/## Functional Requirements/,/^## /d' \
   workspace/federal-grant-portal-test/handoffs/003-prd-refined.md

# Trigger Phase 4 (should reject)
curl -X POST http://localhost:5678/webhook/council-review \
  -H "Content-Type: application/json" \
  -d '{"project": "federal-grant-portal-test"}'

# Restore valid handoff
cp workspace/federal-grant-portal-test/archive/003-backup.md \
   workspace/federal-grant-portal-test/handoffs/003-prd-refined.md
```

### Test 2: Docker Restart Recovery
```bash
# Restart n8n
docker compose restart

# Wait for startup
sleep 15

# Re-trigger Phase 4 (should work with existing handoff)
curl -X POST http://localhost:5678/webhook/council-review \
  -H "Content-Type: application/json" \
  -d '{"project": "federal-grant-portal-test"}'
```

---

## Next Steps After Test

1. **Document results** in `docs/issue-48-retest-results.md`
2. **Compare artifacts** with previous test (archived in `workspace/federal-grant-portal-test/archive/`)
3. **Update GitHub issue** #48 with test results
4. **Close issue** if all acceptance criteria met

---

## Quick Reference

| Script | Purpose |
|--------|---------|
| `verify-workflows.sh` | Pre-flight checks (n8n, Ollama, workspace) |
| `test-phase2-interview.sh` | Run full Phase 2 interview conversation |

| Workflow File | Fixes Applied |
|---------------|---------------|
| `phase-2-interview-refactored.json` | ✅ Issue #69 (no require()) |
| `phase-3-prd-synthesis.json` | (no changes needed) |
| `phase-4-council-review-fixed.json` | ✅ Issue #70 (handoff write), #71 (PRD version) |

| Handoff File | Created By | Size |
|--------------|------------|------|
| `002-prd-interview.md` | Phase 2 | ~10-20KB |
| `003-prd-refined.md` | Phase 3 | ~20-30KB |
| `004-council-review.md` | Phase 4 | ~10-20KB |
