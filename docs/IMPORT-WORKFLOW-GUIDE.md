# n8n Workflow Import Guide - Phase 4 Fixed Version

**Task**: Import the fixed Phase 4 workflow to deploy Issues #70 and #71 fixes
**Time Required**: 5 minutes
**File to Import**: `workflows/phase-4-council-review.json`

---

## Step-by-Step Instructions

### Step 1: Open n8n in Browser

1. Open your browser
2. Navigate to: **http://localhost:5678**
3. Login with:
   - Username: **admin**
   - Password: **changeme**

---

### Step 2: Backup Current Workflow (Safety First)

Before making changes, let's backup the current workflow:

1. In n8n, look at the left sidebar
2. Click **"Workflows"** (should show a list of workflows)
3. Find **"Phase 4 — Council Review"** in the list
4. Click on it to open the workflow
5. Once the workflow is open, look for the **"⋮" (three dots)** menu in the top-right
   - OR look for **"Workflow"** menu in the top menu bar
6. Click **"Download"** or **"Export"**
7. Choose **"Download as JSON"**
8. Save the file as `phase-4-council-review-backup-$(date +%Y%m%d).json`

✅ **Backup complete!** Now we can safely proceed.

---

### Step 3: Delete the Old Workflow

We need to remove the old workflow before importing the new one:

1. Go back to the **Workflows** list (click "Workflows" in left sidebar)
2. Find **"Phase 4 — Council Review"**
3. Hover over it - you'll see a **"⋮" (three dots)** menu appear on the right
4. Click the three dots
5. Select **"Delete"**
6. Confirm the deletion when prompted

**Note**: This is safe because:
- We just backed it up
- The fixed version is in git
- n8n execution history is preserved

---

### Step 4: Import the Fixed Workflow

Now let's import the fixed version:

1. Still in the **Workflows** list view
2. Look for the **"+ Add workflow"** button or **"Import"** button in the top-right
   - If you see "+ Add workflow", click it → then click "Import from file"
   - If you see "Import" button directly, click it
3. A file picker will open
4. Navigate to: `/home/bjudd/projects/PRDWorkflowSystem/workflow-orchestration-system-scaffold/workflows/`
5. Select: **phase-4-council-review.json**
6. Click **"Open"**

n8n will import the workflow and open it in the editor.

---

### Step 5: Verify the Import

Let's make sure the fixes are present:

1. The workflow should now be open in the editor
2. You'll see a canvas with many nodes and connections
3. Find the node called **"Code - Write Handoff File"** (use search if needed)
   - Shortcut: Press **Ctrl+F** (or **Cmd+F** on Mac) and search for "Write Handoff"
4. Click on that node
5. Look at the code in the right panel
6. You should see: `fs.writeFileSync(handoffPath, assembleData.reviewText, 'utf8');`
   - If you see this, Issue #70 fix is present ✅

7. Now find **"Code - Assemble Output"** node
8. Click on it
9. Scroll to the top of the code
10. You should see: `// Extract PRD version` followed by version extraction logic
    - If you see this, Issue #71 fix is present ✅

---

### Step 6: Activate the Workflow

The imported workflow is inactive by default:

1. Look at the **top-right corner** of the n8n editor
2. Find the toggle switch labeled **"Active"** or **"Inactive"**
3. Click the toggle to turn it **ON** (should turn green/blue)
4. You should see **"Active"** displayed

✅ **Workflow is now live!**

---

### Step 7: Test the Fixes (Optional Quick Test)

If you want to immediately verify the fixes work, run this command in your terminal:

```bash
# Create a test project
PROJECT="verify-import-$(date +%s)"
mkdir -p "workspace/$PROJECT/handoffs"

# Copy an existing PRD (we know this one has version: v1)
cp workspace/federal-grant-portal-test/handoffs/003-prd-refined.md \
   "workspace/$PROJECT/handoffs/003-prd-refined.md"

# Verify the PRD has version: v1
grep "^version:" "workspace/$PROJECT/handoffs/003-prd-refined.md"

# Start Phase 4 council review
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d "{\"project\": \"$PROJECT\", \"action\": \"review\"}" \
  --max-time 1200 > /tmp/verify-import.json 2>&1 &

echo "Phase 4 started for project: $PROJECT"
echo "This will take 15-20 minutes..."
echo ""
echo "Monitor progress:"
echo "  watch -n 5 'ls -lh workspace/$PROJECT/handoffs/'"
```

**Wait 15-20 minutes**, then verify:

```bash
PROJECT="verify-import-XXXXX"  # Use the actual project name from above

# Check Issue #70: Handoff file created
ls -lh "workspace/$PROJECT/handoffs/004-council-review.md"
# Expected: File exists (~15KB)

# Check Issue #71: PRD version shows v1 (not undefined)
grep "^prd_version_reviewed:" "workspace/$PROJECT/handoffs/004-council-review.md"
# Expected: prd_version_reviewed: v1
```

If both checks pass, **Issues #70 and #71 are fixed!** 🎉

---

## Troubleshooting

### "Import failed" or "Invalid JSON"

- Make sure you selected the correct file: `phase-4-council-review.json`
- Check the file is valid: `python3 -c "import json; json.load(open('workflows/phase-4-council-review.json')); print('✅ Valid')"`

### Workflow appears but nodes look wrong

- The old workflow might still be in browser cache
- Solution: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)

### Can't find "Import" button

- Look for "+ Add workflow" button instead
- Click it, then select "Import from file"

### Workflow imported but not active

- Don't forget Step 6! Toggle must be ON
- Look for the toggle in the top-right corner

---

## Success Criteria

After import and activation, you should have:

✅ Phase 4 workflow in n8n with name "Phase 4 — Council Review"
✅ Node "Code - Write Handoff File" contains `fs.writeFileSync`
✅ Node "Code - Assemble Output" contains `// Extract PRD version`
✅ Workflow toggle shows "Active"
✅ Webhook available at: http://localhost:5678/webhook/council-review-action

---

## What's Next

After successful import:

1. ✅ Issues #70 and #71 are deployed
2. ✅ True MVP is 100% complete (after verification test)
3. 🎉 Ready to move to Full MVP features (Phase 5, Phase 6)

---

## Quick Reference

- **n8n URL**: http://localhost:5678
- **Login**: admin / changeme
- **File to import**: `workflows/phase-4-council-review.json`
- **Workflow name**: Phase 4 — Council Review
- **Test endpoint**: POST http://localhost:5678/webhook/council-review-action
