# Auto-Chaining Feature: Phase 2 → 3 → 4

## Overview

The PRD workflow system now automatically chains from interview completion through PRD synthesis to council review, creating a seamless end-to-end pipeline with no manual intervention required.

**Status**: ✅ Implemented (2026-03-03)

## What Changed

### Before
- **Phase 2 (Interview)**: Completed and stopped
- **Phase 3 (PRD Synthesis)**: Manually triggered, wrote PRD only to `tasks/` directory
- **Phase 4 (Council Review)**: Manually triggered, no artifact information in response

### After
- **Phase 2 (Interview)**: Completes → **auto-triggers Phase 3**
- **Phase 3 (PRD Synthesis)**:
  - Writes PRD to both `tasks/` AND `handoffs/003-prd-refined.md` (fixes Issue #72)
  - Completes → **auto-triggers Phase 4**
- **Phase 4 (Council Review)**:
  - Completes → returns response with **artifact paths**

## Pipeline Flow

```
┌─────────────────────┐
│  Phase 2: Interview │
│  (Interactive chat) │
└──────────┬──────────┘
           │ Auto-triggers
           ▼
┌─────────────────────┐
│ Phase 3: PRD        │
│ Synthesis           │
│ - Quality model     │
│ - Writes handoff    │
└──────────┬──────────┘
           │ Auto-triggers
           ▼
┌─────────────────────┐
│ Phase 4: Council    │
│ Review              │
│ - 4 reviewers       │
│ - 1 chair           │
│ - Returns artifacts │
└─────────────────────┘
```

## Implementation Details

### Phase 2: Auto-Trigger Phase 3

**Node Added**: `HTTP Request - Trigger Phase 3`

- **Type**: HTTP Request node
- **Method**: POST
- **URL**: `http://localhost:5678/webhook/prd-synthesis-action`
- **Body**:
  ```json
  {
    "project": "{{ $json.project }}",
    "action": "synthesize"
  }
  ```
- **Timeout**: 180000ms (3 minutes)
- **Connection**: Triggered after "Write Binary File - Handoff" completes

**When it fires**: Immediately after the interview transcript is written to `002-prd-interview.md`

### Phase 3: Handoff Write + Auto-Trigger Phase 4

**Nodes Added**:

1. **`Code - Write Handoff Copy`**
   - **Type**: Code node
   - **Purpose**: Writes PRD to `handoffs/003-prd-refined.md` (fixes Issue #72)
   - **Code**:
     ```javascript
     const fs = require('fs');
     const path = require('path');
     const data = $input.first().json;

     const workspacePath = process.env.WORKSPACE_PATH || '/data/workspace';
     const handoffDir = path.join(workspacePath, data.project, 'handoffs');
     const handoffPath = path.join(handoffDir, '003-prd-refined.md');

     fs.mkdirSync(handoffDir, { recursive: true });
     fs.writeFileSync(handoffPath, data.prd_text, 'utf8');

     return [{ json: { ...data, handoff_path: handoffPath } }];
     ```

2. **`HTTP Request - Trigger Phase 4`**
   - **Type**: HTTP Request node
   - **Method**: POST
   - **URL**: `http://localhost:5678/webhook/council-review-action`
   - **Body**:
     ```json
     {
       "project": "{{ $json.project }}",
       "action": "review"
     }
     ```
   - **Timeout**: 180000ms (3 minutes)

**Connection Flow**:
```
Code - Write Versioned PRD
  ├─> Respond - Synthesis Complete (original)
  └─> Code - Write Handoff Copy (new)
        └─> HTTP Request - Trigger Phase 4 (new)
```

### Phase 4: Artifact Information in Response

**Node Modified**: `Respond - Review Done`

**New Response Body**:
```json
{
  "success": true,
  "status": "complete",
  "verdict": "{{ $json.verdict }}",
  "review_number": "{{ $json.reviewNum }}",
  "project": "{{ $json.project }}",
  "review_text": "{{ $json.reviewText }}",
  "artifacts": {
    "interview": "workspace/{project}/handoffs/002-prd-interview.md",
    "prd": "workspace/{project}/handoffs/003-prd-refined.md",
    "council_review": "workspace/{project}/handoffs/004-council-review.md"
  },
  "note": "Artifacts are available in the workspace directory"
}
```

**What this provides**:
- All handoff file paths for easy access
- Clear indication that artifacts are ready
- Project name for reference

## Timeline Expectations

| Phase | Duration | Notes |
|-------|----------|-------|
| Phase 2: Interview | 3-5 minutes | User interaction required |
| Auto-trigger delay | <1 second | HTTP request |
| Phase 3: PRD Synthesis | 1-2 minutes | Quality model (slow) |
| Auto-trigger delay | <1 second | HTTP request |
| Phase 4: Council Review | 1-2 minutes | Speed model reviewers + quality chair |
| **Total** | **~9-10 minutes** | From interview start to artifacts |

## Testing

### Manual Test

1. Start interview:
   ```bash
   curl -X POST "http://localhost:5678/webhook/prd-interview" \
     -H "Content-Type: application/json" \
     -d '{"project": "test-auto-chain", "initial_message": "Test project"}'
   ```

2. Complete interview conversation in UI

3. Wait ~9-10 minutes

4. Verify all handoff files exist:
   ```bash
   ls -lh workspace/test-auto-chain/handoffs/
   # Should show:
   # 002-prd-interview.md
   # 003-prd-refined.md
   # 004-council-review.md
   ```

### Automated Test

```bash
./scripts/test-auto-chaining.sh
```

This script:
- Creates a test project
- Starts the interview
- Waits for all phases to complete
- Validates all handoff files exist
- Checks file content structure

## Troubleshooting

### Phase 3 Doesn't Auto-Trigger

**Symptom**: Interview completes but Phase 3 never starts

**Check**:
1. n8n workflow `phase-3-prd-synthesis` is activated
2. Webhook endpoint `/webhook/prd-synthesis-action` is accessible
3. Phase 2 execution log shows HTTP Request node succeeded
4. n8n error log: `docker logs n8n -f`

**Solution**: Verify all workflows are activated and n8n is running

### Phase 4 Doesn't Auto-Trigger

**Symptom**: PRD synthesis completes but council review never starts

**Check**:
1. Handoff file `003-prd-refined.md` was created successfully
2. n8n workflow `phase-4-council-review-fixed` is activated
3. Webhook endpoint `/webhook/council-review-action` is accessible
4. Phase 3 execution log shows both "Write Handoff Copy" and "Trigger Phase 4" nodes succeeded

**Solution**: Verify Phase 3 handoff write completed before trigger fires

### Handoff File Not Found (Issue #72)

**Symptom**: Phase 4 fails with "PRD file not found"

**Check**:
1. Verify `003-prd-refined.md` exists in `workspace/{project}/handoffs/`
2. Check Phase 3 execution log for "Write Handoff Copy" node errors

**Solution**: This should be fixed by the new "Write Handoff Copy" node. If still failing, check file permissions on `workspace/` directory.

### Timeout Errors

**Symptom**: HTTP Request nodes fail with timeout

**Possible causes**:
- Quality model is slow (expected: 1-2 minutes)
- GPU memory issues (qwen3.5:35b requires ~23GB VRAM)
- Ollama not responding

**Solution**:
1. Check GPU memory: `nvidia-smi`
2. Check Ollama status: `curl http://localhost:11434/api/tags`
3. Increase timeout if needed (currently 180 seconds)

## Files Modified

1. **workflows/phase-2-interview-refactored.json**
   - Added `HTTP Request - Trigger Phase 3` node
   - Updated connections from `Write Binary File - Handoff`

2. **workflows/phase-3-prd-synthesis.json**
   - Added `Code - Write Handoff Copy` node (fixes Issue #72)
   - Added `HTTP Request - Trigger Phase 4` node
   - Updated connections from `Code - Write Versioned PRD`

3. **workflows/phase-4-council-review-fixed.json**
   - Modified `Respond - Review Done` node response body
   - Added `artifacts` object with handoff file paths

## Rollback Instructions

If auto-chaining causes issues and you need to revert to manual triggering:

### Option 1: Disable Trigger Nodes

In n8n UI:
1. Open `phase-2-interview-refactored`
2. Disable node: `HTTP Request - Trigger Phase 3`
3. Open `phase-3-prd-synthesis`
4. Disable node: `HTTP Request - Trigger Phase 4`

This preserves the handoff file fix (Issue #72) while reverting to manual triggers.

### Option 2: Restore from Git

```bash
git checkout HEAD~1 -- workflows/phase-2-interview-refactored.json
git checkout HEAD~1 -- workflows/phase-3-prd-synthesis.json
git checkout HEAD~1 -- workflows/phase-4-council-review-fixed.json
```

Then re-import workflows to n8n.

## Future Enhancements

### Potential Improvements

1. **Download Endpoint**
   - Create dedicated `/webhook/download-artifact` endpoint
   - Support direct file downloads via browser
   - Add Content-Disposition headers

2. **Web UI for Results**
   - Create `/webhook/view-results?project=X` endpoint
   - Display all artifacts in formatted HTML
   - Include council verdict and key highlights

3. **Status Polling Endpoint**
   - Create `/webhook/pipeline-status?project=X` endpoint
   - Return current phase and progress
   - Enable UI to show real-time progress

4. **Error Handling**
   - Add rollback logic if Phase 3 or 4 fails
   - Preserve partial results on failure
   - Send notifications on pipeline completion/failure

5. **Parallel Execution**
   - Support multiple projects running simultaneously
   - Requires model queue management (GPU limitation)
   - Add project status tracking database

## Related Issues

- **Issue #72**: Phase 3 PRD not written to handoffs/ directory → ✅ Fixed by `Code - Write Handoff Copy` node
- **Issue #48**: Council review verification → Validated with auto-chaining

## Verification Checklist

After importing updated workflows:

- [ ] Phase 2 workflow activated
- [ ] Phase 3 workflow activated
- [ ] Phase 4 workflow activated
- [ ] Test interview completes successfully
- [ ] Phase 3 auto-triggers (check n8n execution log)
- [ ] Phase 4 auto-triggers (check n8n execution log)
- [ ] All three handoff files created
- [ ] Phase 4 response includes artifacts object
- [ ] Total pipeline time ~9-10 minutes
- [ ] No manual intervention required

## References

- **Plan**: `/home/bjudd/.claude/projects/.../10506a7d-0324-459e-9699-be2321c76ce7.jsonl`
- **Implementation Script**: `scripts/add-auto-chaining.py`
- **Test Script**: `scripts/test-auto-chaining.sh`
- **Original PRD**: `prd-workflow-system-v3.md`
