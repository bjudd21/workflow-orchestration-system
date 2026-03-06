# n8n State Management Code Snippets

These snippets should be added to n8n workflows to enable state persistence.

## Setup

All snippets require loading the state management module:

```javascript
const stateLib = require('/home/node/scripts/pipeline-state.js');
```

---

## Phase 2: Interview Completion

**Add this to the "Code - Format Handoff" node AFTER writing the handoff file:**

```javascript
// ... existing handoff code ...

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

---

## Phase 3: Progress Updates

### At 0% (Start of Synthesis)

**Add new Code node: "Code - Update State 0%" BEFORE the first SSE event:**

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updateProgress(project, 'synthesis', 0, 'Starting PRD synthesis...');

return [{ json: { project } }];
```

### At 50% (Middle of Synthesis)

**Add new Code node: "Code - Update State 50%" BEFORE the 50% SSE event:**

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updateProgress(project, 'synthesis', 50, 'PRD synthesis in progress...');

return [{ json: { project } }];
```

### At 100% (Completion - Approve Action)

**Add to "Code - Write Handoff" node AFTER writing the handoff file:**

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

---

## Phase 4: Council Review

### At Start

**Add new Code node: "Code - Init Council State" at the start:**

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const stateLib = require('/home/node/scripts/pipeline-state.js');

stateLib.updatePhase(project, 'council', {
  status: 'in_progress',
  reviewersComplete: 0,
  totalReviewers: 5
});

return [{ json: { project } }];
```

### After Each Reviewer

**Add to each "SSE Event - Reviewer X" node:**

```javascript
const project = $('Code - Validate Inputs').first().json.project;
const reviewerName = 'Tech Reviewer'; // Change per reviewer
const stateLib = require('/home/node/scripts/pipeline-state.js');

const state = stateLib.readState(project);
const reviewersComplete = (state.phases.council.reviewersComplete || 0) + 1;

stateLib.updatePhase(project, 'council', {
  reviewersComplete,
  lastReviewer: reviewerName
});

// ... existing SSE event code ...
```

### At Completion

**Add to council chair completion code:**

```javascript
// ... after chair synthesis ...

const stateLib = require('/home/node/scripts/pipeline-state.js');
stateLib.completePhase(project, 'council', 'findings');

return [{
  json: {
    verdict,
    // ... rest of data
  }
}];
```

---

## Error Handling

**Add to any node's error handling:**

```javascript
try {
  // ... existing code ...
} catch (error) {
  const stateLib = require('/home/node/scripts/pipeline-state.js');
  stateLib.failPhase(project, 'synthesis', error.message);
  throw error;
}
```

---

## Dashboard: List All Projects

**New workflow: "Dashboard UI" - Code node:**

```javascript
const stateLib = require('/home/node/scripts/pipeline-state.js');
const projects = stateLib.listProjects();

return [{
  json: {
    projects,
    count: projects.length
  }
}];
```

---

## Testing State Management

**Test from command line:**

```javascript
const stateLib = require('./scripts/pipeline-state.js');

// Init new project
stateLib.initState('test-project-123');

// Update progress
stateLib.updateProgress('test-project-123', 'synthesis', 50, 'Generating section 4...');

// Complete phase
stateLib.completePhase('test-project-123', 'synthesis', 'council');

// Read state
console.log(JSON.stringify(stateLib.readState('test-project-123'), null, 2));
```

---

## State File Location

All state files are stored at:
```
workspace/{project-name}/pipeline-state.json
```

Example:
```
workspace/project-2026-03-06-1535/pipeline-state.json
```

---

## State File Format

```json
{
  "project": "project-2026-03-06-1535",
  "currentPhase": "council",
  "phases": {
    "interview": {
      "status": "completed",
      "startedAt": "2026-03-06T20:38:00Z",
      "completedAt": "2026-03-06T20:45:00Z"
    },
    "synthesis": {
      "status": "completed",
      "progress": 100,
      "progressMessage": "PRD synthesis complete",
      "startedAt": "2026-03-06T20:45:05Z",
      "completedAt": "2026-03-06T20:48:30Z"
    },
    "council": {
      "status": "in_progress",
      "reviewersComplete": 2,
      "totalReviewers": 5,
      "lastReviewer": "Security Reviewer",
      "startedAt": "2026-03-06T20:48:35Z"
    },
    "findings": {
      "status": "pending"
    }
  },
  "createdAt": "2026-03-06T20:38:00Z",
  "lastUpdated": "2026-03-06T20:50:15Z"
}
```
