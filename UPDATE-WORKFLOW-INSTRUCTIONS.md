# How to Update Phase 3 Workflow with Issue #72 Fix

## What Was Fixed

Modified `workflows/phase-3-prd-synthesis.json` to write **both**:
- `workspace/{project}/tasks/prd-{project}-v{version}.md` (versioned PRD)
- `workspace/{project}/handoffs/003-prd-refined.md` (handoff file for Phase 4)

## Why Manual Import is Needed

n8n stores workflows in an internal SQLite database. Editing the JSON file only updates the export, not the active workflow. You must reimport to apply changes.

## Quick Import Steps

1. **Open n8n UI**
   ```bash
   open http://localhost:5678  # or visit in browser
   # Login: admin / changeme
   ```

2. **Delete Old Workflow**
   - Click "Workflows" in left sidebar
   - Find "Phase 3 — PRD Synthesis"
   - Click three-dots menu → "Delete"
   - Confirm deletion

3. **Import Updated Workflow**
   - Click "Import workflow" (top right)
   - Select: `workflows/phase-3-prd-synthesis.json`
   - Click "Import"

4. **Activate Workflow**
   - Open the imported workflow
   - Toggle "Active" switch (top right)
   - Verify the switch shows "Active"

5. **Verify the Fix**
   ```bash
   cd /home/bjudd/projects/PRDWorkflowSystem/workflow-orchestration-system-scaffold

   # Clean test project
   rm -f workspace/federal-grant-portal-test/handoffs/003-prd-refined.md
   rm -f workspace/federal-grant-portal-test/tasks/prd-federal-grant-portal-test-v1.md

   # Trigger Phase 3
   curl -X POST http://localhost:5678/webhook/prd-synthesis-action \
     -H "Content-Type: application/json" \
     -d '{"project": "federal-grant-portal-test", "action": "synthesize", "current_version": 0}'

   # Check both files were created
   ls -lh workspace/federal-grant-portal-test/tasks/
   ls -lh workspace/federal-grant-portal-test/handoffs/

   # Expected: BOTH directories should have the PRD file
   # - tasks/prd-federal-grant-portal-test-v1.md
   # - handoffs/003-prd-refined.md
   ```

## What Changed in the Workflow

**Before** (Code - Write Versioned PRD node):
```javascript
const fs = require('fs');
const data = $input.first().json;

fs.mkdirSync(data.prdDir, { recursive: true });
fs.writeFileSync(data.prdPath, data.prdText, 'utf8');

return [{
  json: {
    prd_text: data.prdText,
    version: data.version,
    project: data.project,
    prd_path: data.prdPath
  }
}];
```

**After** (with handoff file creation):
```javascript
const fs = require('fs');
const path = require('path');
const data = $input.first().json;

// Write versioned PRD to tasks/
fs.mkdirSync(data.prdDir, { recursive: true });
fs.writeFileSync(data.prdPath, data.prdText, 'utf8');

// Also write to handoffs/003-prd-refined.md
const handoffDir = path.dirname(data.handoffPath);
fs.mkdirSync(handoffDir, { recursive: true });
fs.writeFileSync(data.handoffPath, data.prdText, 'utf8');

return [{
  json: {
    prd_text: data.prdText,
    version: data.version,
    project: data.project,
    prd_path: data.prdPath,
    handoff_path: data.handoffPath  // NEW: added to response
  }
}];
```

## Troubleshooting

**If workflow import fails:**
- Check that the JSON file exists: `ls -l workflows/phase-3-prd-synthesis.json`
- Check file size: should be ~30KB
- Verify JSON is valid: `python3 -m json.tool workflows/phase-3-prd-synthesis.json > /dev/null`

**If workflow doesn't activate:**
- Check n8n logs: `docker compose logs n8n --tail 50`
- Verify Ollama is running: `ollama list`
- Restart n8n: `docker compose restart n8n`

**If test still doesn't create handoff file:**
- Open workflow in n8n UI
- Click on "Code - Write Versioned PRD" node
- Verify the code matches the "After" version above
- If not, manually paste the updated code into the node

## Alternative: Direct Node Edit (Faster)

If you don't want to delete/reimport the entire workflow:

1. Open workflow in n8n UI
2. Click "Code - Write Versioned PRD" node
3. Replace the code with the "After" version above
4. Click "Save" (Ctrl+S)
5. Test with the verify command

This preserves execution history and is faster for single-node changes.
