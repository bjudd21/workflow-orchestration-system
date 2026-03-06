# Implementation Guide: Phase A - State Persistence & Resume

**Goal:** Make the UI resilient to page refresh and allow users to resume projects.

**Status:** Components created, workflows need updating

---

## What We've Built

### 1. State Management Library
**File:** `scripts/pipeline-state.js`

Node.js module that workflows can require to manage state:
```javascript
const stateLib = require('/home/node/scripts/pipeline-state.js');

// Initialize state
stateLib.initState('project-name');

// Update progress
stateLib.updateProgress('project-name', 'synthesis', 50, 'Generating section 4...');

// Complete phase
stateLib.completePhase('project-name', 'synthesis', 'council');

// Read state
const state = stateLib.readState('project-name');
```

**State File Location:** `workspace/{project}/pipeline-state.json`

### 2. n8n Code Snippets
**File:** `docs/n8n-state-management-snippets.md`

Copy-paste snippets for updating each workflow to track state.

### 3. Resume Functionality Patch
**File:** `frontend/resume-functionality-patch.js`

JavaScript methods to add to the enhanced UI for:
- Loading project state from API
- Resuming from current phase
- localStorage backup
- Better status messages

### 4. API Endpoints

**Get Pipeline State:**
```
GET /webhook/api/pipeline-state/:project
Returns: {exists: true, state: {...}}
```

**Workflow:** `workflows/api-get-pipeline-state.json`

### 5. Project Dashboard
**File:** `frontend/dashboard.html`

Shows all projects with status, allows resuming or viewing PRDs.

**Workflow:** `workflows/dashboard-ui.json`

---

## Implementation Steps

### Step 1: Install State Management Module

The `scripts/pipeline-state.js` module is already created. Ensure it's accessible to n8n:

```bash
# Verify the file exists and is readable
ls -la scripts/pipeline-state.js

# Test it works
node -e "const s = require('./scripts/pipeline-state.js'); console.log(typeof s.initState)"
```

### Step 2: Import API Workflows

**A. Import State API:**
1. Open n8n: http://localhost:5678
2. Import `workflows/api-get-pipeline-state.json`
3. Activate the workflow
4. Test: `curl http://localhost:5678/webhook/api/pipeline-state/test-project`

**B. Import Dashboard:**
1. Import `workflows/dashboard-ui.json`
2. **IMPORTANT:** Replace `FILE_CONTENT_PLACEHOLDER` in the "Respond - Dashboard HTML" node with the actual contents of `frontend/dashboard.html`
3. Activate the workflow
4. Test: Open `http://localhost:5678/webhook/dashboard`

### Step 3: Update Phase 2 (Interview) Workflow

**Location:** Phase 2 — PRD Interview

**Add state tracking on interview completion:**

1. Find the "Code - Format Handoff" node (the one that writes the interview handoff file)
2. **Add this code AFTER the handoff is written:**

```javascript
// ... existing handoff write code ...

// Update pipeline state
const stateLib = require('/home/node/scripts/pipeline-state.js');
stateLib.completePhase(project, 'interview', 'synthesis');

return [{
  json: {
    project,
    handoff_path,
    // ... rest of existing return data
  }
}];
```

3. Save and activate

### Step 4: Update Phase 3 (Synthesis) Workflow

**Location:** Phase 3 — PRD Synthesis

**Add 3 state update nodes:**

**A. At Workflow Start (0%):**

1. Create new Code node: "Code - Update State 0%"
2. Place it BEFORE the first SSE event (0% progress)
3. Add this code:

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updateProgress(project, 'synthesis', 0, 'Starting PRD synthesis...');

return [{ json: { project } }];
```

4. Connect it in the workflow execution path

**B. Before Ollama Call (50%):**

1. Create new Code node: "Code - Update State 50%"
2. Place it BEFORE the 50% SSE event
3. Add this code:

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updateProgress(project, 'synthesis', 50, 'PRD synthesis in progress...');

return [{ json: { project } }];
```

**C. On Approval (100% + Complete):**

1. Find the "Code - Write Handoff" node (approve action)
2. Add this code AFTER writing the handoff:

```javascript
// ... existing handoff write code ...

// Update pipeline state
const stateLib = require('/home/node/scripts/pipeline-state.js');
stateLib.updateProgress(project, 'synthesis', 100, 'PRD synthesis complete');
stateLib.completePhase(project, 'synthesis', 'council');

return [{
  json: {
    valid: true,
    handoff_path,
    // ... rest of existing return data
  }
}];
```

### Step 5: Update Phase 4 (Council) Workflow

**Location:** Phase 4 — Council Review

**A. At Workflow Start:**

1. Create new Code node: "Code - Init Council State"
2. Place at the start, after input validation
3. Add this code:

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updatePhase(project, 'council', {
  status: 'in_progress',
  reviewersComplete: 0,
  totalReviewers: 5,
  startedAt: new Date().toISOString()
});

return [{ json: { project } }];
```

**B. On Completion:**

1. Find the council chair synthesis code (final step)
2. Add this AFTER generating the final verdict:

```javascript
// ... after chair synthesis ...

const stateLib = require('/home/node/scripts/pipeline-state.js');
stateLib.completePhase(project, 'council', 'findings');

return [{
  json: {
    verdict,
    summary,
    // ... rest of data
  }
}];
```

### Step 6: Update Enhanced UI with Resume Functionality

**File:** `frontend/interview-ui-enhanced.html`

**Changes needed:**

1. **Add new state variables** (in Alpine.js `pipelineState()` function):
```javascript
isResuming: false,
resumeError: null,
stateLoaded: false,
```

2. **Add new methods** (copy from `frontend/resume-functionality-patch.js`):
- `loadProjectState(projectName)`
- `resumeProject(state)`
- `saveToLocalStorage()`
- `loadFromLocalStorage()`

3. **Replace init() method** with the enhanced version from the patch file

4. **Add loading UI** (after `<body x-data...>`):
```html
<div x-show="isResuming" class="phase-container" style="text-align: center;">
  <h3>🔄 Resuming Project</h3>
  <p>Loading state for <strong x-text="projectName"></strong>...</p>
  <div class="progress-bar-bg" style="width: 200px; margin: 20px auto;">
    <div class="progress-bar-fill" style="width: 100%; animation: pulse 1.5s infinite;"></div>
  </div>
</div>
```

5. **Add CSS animation:**
```css
@keyframes pulse {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1; }
}
```

6. **Update the workflow** with the new HTML using `scripts/update-interview-ui.js`

### Step 7: Re-import Updated Workflows

After making all code changes:

1. Export updated workflows from n8n
2. Save them to `workflows/` directory
3. Re-import all 3 workflows:
   - Phase 2 — PRD Interview
   - Phase 3 — PRD Synthesis
   - Phase 4 — Council Review
4. Ensure all are activated

---

## Testing

### Test 1: Fresh Project Start
1. Open `http://localhost:5678/webhook/prd-interview`
2. Start an interview
3. Check `workspace/{project}/pipeline-state.json` exists
4. Should show:
```json
{
  "project": "project-2026-03-06-XXXX",
  "currentPhase": "interview",
  "phases": {
    "interview": {"status": "in_progress", ...}
  }
}
```

### Test 2: Page Refresh During Interview
1. Start interview, answer 2 questions
2. Refresh browser (F5)
3. Should see "Resuming..." message
4. Should return to interview phase
5. ❌ **Known limitation:** Interview conversation history not saved yet (future enhancement)

### Test 3: Resume During Synthesis
1. Start interview, complete it
2. Wait for Phase 3 to reach 50%
3. **Refresh browser**
4. Should see "Resuming..." then jump to synthesis phase at 50%
5. Progress bar should continue from 50% → 100%

### Test 4: Resume from Council Review
1. Complete interview + synthesis
2. Wait for Phase 4 council review to start
3. **Refresh browser**
4. Should resume at council phase
5. Reviewer boxes should show correctly

### Test 5: localStorage Resume
1. Complete an interview
2. **Close browser completely**
3. Open new browser window
4. Go to `http://localhost:5678/webhook/prd-interview` (no ?project= param)
5. Should see popup: "Resume project-2026-03-06-XXXX?"
6. Click OK → should jump to last phase

### Test 6: Dashboard
1. Create 2-3 projects (start interviews)
2. Open `http://localhost:5678/webhook/dashboard`
3. Should see table with all projects
4. Click project name → should resume that project
5. Status dots should reflect actual phase completion

### Test 7: Direct URL Resume
1. Note a project name (e.g., `project-2026-03-06-1535`)
2. Open `http://localhost:5678/webhook/prd-interview?project=project-2026-03-06-1535`
3. Should automatically resume from current phase

---

## Verification Checklist

- [ ] `scripts/pipeline-state.js` accessible to n8n
- [ ] API workflow imported and returns state for test project
- [ ] Dashboard workflow imported and shows HTML
- [ ] Dashboard lists all projects correctly
- [ ] Phase 2 writes state on interview completion
- [ ] Phase 3 updates progress at 0%, 50%, 100%
- [ ] Phase 4 marks council as in_progress
- [ ] Enhanced UI has resume functionality
- [ ] Page refresh preserves state
- [ ] URL with ?project= param resumes correctly
- [ ] localStorage offers to resume recent project
- [ ] Dashboard allows clicking to resume

---

## Known Limitations (Future Work)

1. **Interview conversation history not saved** - Refreshing during interview loses chat messages (Phase B or C)
2. **No error state UI** - Failed phases just show "failed" badge (Phase C)
3. **No manual retry buttons** - Can't retry a failed phase from UI (Phase B)
4. **Council reviewer progress not granular** - Shows "in_progress" but not which reviewer is working (Phase C)
5. **No execution log** - Can't see what happened in the workflow (Phase C)

---

## Next Steps (Phase B & C)

After Phase A is complete and tested:

**Phase B: Core Features**
- Navigation menu (always visible)
- Manual phase triggers
- View PRD button
- Delete project functionality

**Phase C: Polish**
- Error recovery UI
- Execution log panel
- Ollama status indicator
- Better progress messages (section-level)

---

## Rollback Plan

If issues arise:

1. Deactivate updated workflows
2. Re-import old workflows from `workflows/backups/`
3. Remove state management code
4. Revert to original enhanced UI

State files in `workspace/` are non-destructive - they won't break existing projects.

---

## Support Files

- `scripts/pipeline-state.js` - State management library
- `docs/n8n-state-management-snippets.md` - Copy-paste code snippets
- `frontend/resume-functionality-patch.js` - UI resume logic
- `frontend/dashboard.html` - Project dashboard UI
- `workflows/api-get-pipeline-state.json` - State API workflow
- `workflows/dashboard-ui.json` - Dashboard workflow

All files created and ready to use!
