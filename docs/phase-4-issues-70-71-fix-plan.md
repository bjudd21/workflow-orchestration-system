# Phase 4 Issues #70 and #71 Fix Plan

**Date**: 2026-03-03
**Status**: Investigation complete, fix strategy defined
**Complexity**: Medium - requires careful data flow tracing through 8+ nodes

---

## Issue #70: Phase 4 Doesn't Write Handoff File Automatically

### Current Behavior
- Phase 4 workflow completes successfully
- Returns `review_text` field in JSON response (14KB of formatted markdown)
- Does **NOT** write `workspace/{project}/handoffs/004-council-review.md` to disk
- Contract expects this file to exist for Phase 5 handoff validation

### Root Cause
Phase 4 workflow is missing the Write Binary File node in the main review completion path. The workflow has Write Binary File nodes, but they're only in the re-review/revision branches (decision and gate handling), not in the initial review completion flow.

### Attempted Fix (2026-03-03)
Added 3 nodes to workflow:
1. **Code - Prepare Handoff Data** (ID: generated)
   - Takes `$input.first().json` from "Code - Assemble Output"
   - Prepares binary data structure for file write
   - Returns: `{ json: assembleData, binary: { data: { data: review_text, mimeType: 'text/markdown' } } }`

2. **Write Binary File - Council Review** (ID: generated)
   - Writes to: `/home/node/workspace/${project}/handoffs/004-council-review.md`
   - Uses `dataPropertyName: "data"`

3. Updated connections:
   - `Code - Assemble Output` → `Code - Prepare Handoff Data` → `Write Binary File - Council Review` → `Respond - Review Done`

**Result**: Workflow executes without errors, but file is NOT created.

### Why Fix Didn't Work

**Hypothesis 1**: Write Binary File node may need binary data in specific format
- n8n Read/Write Binary File expects `input.binary.data.data` (nested structure)
- Current prep code may not match expected format

**Hypothesis 2**: File path expression may not evaluate correctly
- Expression: `{{ $input.first().json.project ? ... }}`
- If project field is missing from input, fallback path `/tmp/council-review.md` may be used (or error silently)

**Hypothesis 3**: Write Binary File node not actually executing
- Connection chain looks correct in JSON
- But n8n may not have activated the updated workflow properly
- Need to verify via n8n UI execution logs

### Recommended Fix Strategy

**Step 1**: Verify Write Binary File node execution
```bash
# Check n8n workflow execution history
docker logs n8n 2>&1 | grep "Write Binary File - Council Review"

# Or check via n8n UI: Executions → Phase 4 → View execution graph
# Verify "Write Binary File - Council Review" node shows as executed
```

**Step 2**: Simplify file path expression
Instead of conditional expression, use simple path:
```json
{
  "fileName": "={{ '/home/node/workspace/' + $input.first().json.project + '/handoffs/004-council-review.md' }}"
}
```

**Step 3**: Fix binary data preparation
The Write Binary File node expects data in this exact format:
```javascript
return [{
  json: { ...metadata },
  binary: {
    data: {
      data: reviewTextContent,  // String or Buffer
      mimeType: 'text/markdown',
      fileName: 'optional-name.md'  // Optional, path specified in node config
    }
  }
}];
```

Current prep code may have wrong nesting. Should be:
```javascript
const assembleData = $input.first().json;

return [{
  json: assembleData,
  binary: {
    data: {
      data: assembleData.review_text,  // This should be a string
      mimeType: 'text/markdown'
    }
  }
}];
```

**Step 4**: Alternative approach - use Code node with fs (if binary fails)
Since Phase 4 already uses `require('fs')` in some nodes (not sandboxed like Phase 2), could add simple fs write:
```javascript
const fs = require('fs');
const assembleData = $input.first().json;

const handoffPath = `/home/node/workspace/${assembleData.project}/handoffs/004-council-review.md`;

// Create directory if needed
const dir = require('path').dirname(handoffPath);
fs.mkdirSync(dir, { recursive: true });

// Write file
fs.writeFileSync(handoffPath, assembleData.review_text, 'utf8');

return [{ json: { ...assembleData, handoff_written: handoffPath } }];
```

**Step 5**: Test with verification
```bash
# Before test
rm -f workspace/test-project/handoffs/004-council-review.md

# Run test
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d '{"project": "test-project", "action": "review"}' \
  --max-time 180

# Verify file created
ls -lh workspace/test-project/handoffs/004-council-review.md
head -20 workspace/test-project/handoffs/004-council-review.md
```

---

## Issue #71: PRD Version Shows "undefined" in Council Review

### Current Behavior
- Council review handoff file frontmatter shows: `prd_version_reviewed: undefined`
- Should show actual PRD version (e.g., `v1`)

### Root Cause
The PRD version extraction was added to "Read - PRD File" node but doesn't flow through the data path to "Code - Build Chair Request" → "Code - Assemble Output".

### Data Flow Analysis

**Current flow**:
```
Read - PRD File (extracts prdVersion)
  → Code - Validate PRD Contract
  → Code - Load Reviewers
  → [4x HTTP - Run R1/R2/R3/R4 in parallel]
  → Code - Save R4
  → Code - Build Chair Request  ← reads from "Code - Save R4"
  → HTTP - Run Chair
  → Code - Assemble Output  ← reads from "Code - Build Chair Request"
```

**Problem**: `prdVersion` is extracted in "Read - PRD File" but:
- "Code - Build Chair Request" reads from `$('Code - Save R4').first().json`
- "Code - Save R4" doesn't pass prdVersion through
- Therefore "Code - Build Chair Request" never sees prdVersion

### Attempted Fix (2026-03-03)
1. Added version extraction to "Read - PRD File":
   ```javascript
   const versionMatch = prd.match(/^version:\s*(v\d+)$/m);
   const prdVersion = versionMatch ? versionMatch[1] : 'v1';
   return [{ json: { ...d, prd, prdVersion } }];
   ```

2. Updated "Code - Assemble Output" to use `buildData.prdVersion` instead of `buildData.prdV`

**Result**: Still shows `undefined` because prdVersion doesn't reach "Code - Build Chair Request".

### Recommended Fix Strategy

**Option A**: Add prdVersion to "Code - Save R4" output
```javascript
// In "Code - Save R4" node
const validateData = $('Code - Validate PRD Contract').first().json;
const r4Data = $input.first().json;

return [{
  json: {
    ...r4Data,
    prdVersion: validateData.prdVersion,  // Pass through from validation
    project: validateData.project,
    reviewNum: validateData.reviewNum
    // ... other fields
  }
}];
```

**Option B**: Have "Code - Build Chair Request" read prdVersion directly from earlier node
```javascript
// In "Code - Build Chair Request" node
const d = $('Code - Save R4').first().json;
const validateData = $('Code - Validate PRD Contract').first().json;

// Get prdVersion from validation node
const prdVersion = validateData.prdVersion || 'v1';

return [{
  json: {
    ...d,
    prdVersion,  // Add to output
    // ... rest of chair request data
  }
}];
```

**Option C**: Extract version in "Code - Assemble Output" directly from PRD text
```javascript
// In "Code - Assemble Output" node
const buildData = $('Code - Build Chair Request').first().json;

// Extract version from PRD if not in buildData
let prdVersion = buildData.prdVersion;
if (!prdVersion) {
  // Read PRD from earlier node
  const validateData = $('Code - Validate PRD Contract').first().json;
  const prd = validateData.prd;
  const versionMatch = prd.match(/^version:\s*(v\d+)$/m);
  prdVersion = versionMatch ? versionMatch[1] : 'v1';
}

// Use prdVersion in frontmatter
const reviewText = `---
phase: council-review
project: ${buildData.project}
review_number: ${buildData.reviewNum}
date: ${new Date().toISOString().split('T')[0]}
prd_version_reviewed: ${prdVersion}
...
`;
```

**Recommended**: Option C (extract in Assemble Output)
- Most reliable - doesn't depend on data flowing through 5+ nodes
- Self-contained - reads PRD directly from earlier node
- Easier to debug - all logic in one place

### Test Plan

After implementing fix:
```bash
# Test with known PRD version
echo "version: v2" >> workspace/test-project/handoffs/003-prd-refined.md

# Run council review
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d '{"project": "test-project", "action": "review"}' \
  --max-time 180 > /tmp/council-test.json

# Check version in response
python3 -c "import json; d=json.load(open('/tmp/council-test.json')); print('PRD version:', d['review_text'].split('prd_version_reviewed:')[1].split('\n')[0].strip())"

# Should output: "PRD version: v2"
```

---

## Implementation Checklist

### Issue #70 (Handoff File Write)
- [ ] Check n8n execution logs to verify Write Binary File node executed
- [ ] Verify binary data format in "Code - Prepare Handoff Data"
- [ ] Simplify file path expression (remove conditional)
- [ ] Test with manual file deletion + council review
- [ ] Alternative: Use fs.writeFileSync in Code node if Write Binary File fails
- [ ] Verify file created with correct content and permissions
- [ ] Update contracts/council-output.schema.md if needed

### Issue #71 (PRD Version Extraction)
- [ ] Implement Option C: Extract version in "Code - Assemble Output"
- [ ] Test with multiple PRD versions (v1, v2, v10)
- [ ] Test with missing version (should default to v1)
- [ ] Verify version appears in all 3 places:
  - Response JSON `prd_version_reviewed` field
  - Handoff file frontmatter
  - PRD Revision Log section
- [ ] Update n8n-Development-Notes.md wiki with solution

### Integration Test
- [ ] Run full Phase 3 → Phase 4 flow
- [ ] Verify both handoff file AND version are correct
- [ ] Commit Phase 4 changes
- [ ] Close issues #70 and #71
- [ ] Update Issue #48 integration test results

---

## Node IDs Reference

Key Phase 4 nodes for debugging:

| Node Name | Node ID | Purpose |
|-----------|---------|---------|
| Read - PRD File | (find via name) | Extracts PRD content + version |
| Code - Validate PRD Contract | (find via name) | Validates PRD structure |
| Code - Save R4 | (find via name) | Aggregates reviewer outputs |
| Code - Build Chair Request | (find via name) | Prepares chair synthesis prompt |
| Code - Assemble Output | `869ea519-ca49-4da8-9d4b-f43c721668fa` | Formats final council review |
| Code - Prepare Handoff Data | (generated in fix) | Prepares binary for file write |
| Write Binary File - Council Review | (generated in fix) | Writes 004-council-review.md |

---

## Alternative: Defer to Full MVP

If these fixes prove too complex for True MVP deadline:
- Document as known limitations in Issue #48 results
- Phase 4 works correctly (review executes, response returned)
- Handoff file can be extracted manually: `curl ... | jq -r '.review_text' > 004-council-review.md`
- PRD version shows "undefined" but doesn't break workflow
- Both issues are cosmetic/DX improvements, not functional blockers
- Prioritize Full MVP features over polish

---

## Time Estimate

- **Issue #70 fix + test**: 15-30 minutes
- **Issue #71 fix + test**: 15-20 minutes
- **Integration test**: 10 minutes (120s council review + verification)
- **Total**: 40-60 minutes

**Recommendation**: Tackle in next session with fresh focus. Issue #69 (Phase 2 refactor) was the highest priority and is now complete and committed.
