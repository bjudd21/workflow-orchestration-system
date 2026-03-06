# Issue #74: Enhanced Frontend UI with HTMX + Alpine.js

**Status**: ✅ Complete
**Date**: March 6, 2026

## Overview

Enhanced the Phase 2 interview UI to become a single-page application that transitions through the entire Phase 2→3→4 pipeline with real-time updates.

## Features

### 1. Phase Transitions

The UI automatically transitions through 4 phases:

1. **Interview** — Conversational requirements gathering
2. **Synthesis** — Progress bar (0-100%) during PRD synthesis
3. **Council** — Live stream of council reviewers as they complete
4. **Findings** — Final verdict display with 4 action buttons

### 2. Real-Time Updates (SSE)

The UI connects to the SSE service (`http://localhost:3001/events/{project-id}`) when the interview completes and listens for:

- `phase3.progress` — Updates progress bar (0%, 50%, 100%)
- `phase4.reviewer` — Displays each reviewer's assessment as it completes
- `phase4.complete` — Shows final council verdict and summary

### 3. Connection Status Indicator

A fixed status indicator in the top-right shows the SSE connection state:
- 🟢 **Live** — Connected and receiving events
- 🟡 **Reconnecting...** — Attempting to reconnect
- 🔴 **Disconnected** — No active connection

### 4. Action Buttons (Findings Phase)

Four action buttons allow the user to respond to council findings:

| Button | Action | Status |
|--------|--------|--------|
| **Approve & Proceed** | Trigger Phase 5 (Task Generation) | ⚠️ Placeholder (Phase 5 not yet built) |
| **Reject PRD** | Stop pipeline | ⚠️ Placeholder (logs rejection) |
| **Request Revision** | Send feedback to Phase 3 | ⚠️ Placeholder (Phase 3 revision flow incomplete) |
| **Generate Tasks Anyway** | Override concerns and proceed | ⚠️ Placeholder (Phase 5 not yet built) |

**Note**: All buttons are currently placeholders with alert messages. They will be wired up when Phase 5 is implemented.

## Technical Implementation

### Stack

- **Alpine.js 3.13.5** — Reactive state management
- **HTMX 1.9.10** — Included but not actively used (vanilla fetch preferred for this use case)
- **Server-Sent Events (EventSource API)** — Real-time updates from SSE broadcast service

### State Management (Alpine.js)

```javascript
pipelineState() {
  return {
    currentPhase: 'interview',  // Controls which phase is visible
    projectName: '',             // Project identifier
    interviewComplete: false,    // Disables input after completion
    progressPercent: 0,          // Phase 3 progress (0-100)
    progressMessage: '',         // Phase 3 status message
    councilReviews: [],          // Array of reviewer objects
    findings: {},                // Final verdict and summary
    connectionStatus: '',        // SSE connection state
    eventSource: null,           // EventSource instance
    // ... methods
  }
}
```

### Key Methods

**`init()`** — Sets default project name, starts interview

**`sendMessage()`** — Sends user message to interview API, handles completion transition

**`connectSSE()`** — Establishes SSE connection, registers event listeners

**`initializeCouncilReviews()`** — Creates 5 placeholder review objects (4 reviewers + chair)

**Action Methods** — `approveAndProceed()`, `rejectPRD()`, `revisePRD()`, `generateTasksAnyway()`

### Phase Transition Logic

```
Interview completes
  → Wait 2 seconds
  → Switch to 'synthesis' phase
  → Connect to SSE
  → Listen for phase3.progress events

Progress reaches 100%
  → Wait 1.5 seconds
  → Switch to 'council' phase
  → Initialize reviewer placeholders
  → Listen for phase4.reviewer events

All reviewers + chair complete
  → Wait 2 seconds
  → Switch to 'findings' phase
  → Close SSE connection
  → Display action buttons
```

## File Structure

```
frontend/
└── interview-ui-enhanced.html    # Complete enhanced UI (19KB)

scripts/
└── update-interview-ui.js        # Script to inject HTML into workflow JSON

workflows/
└── Phase 2 — PRD Interview.json  # Updated with new HTML in "Respond - Chat UI" node
```

## How to Test

### 1. Import Updated Workflow

The workflow has been automatically updated with the new HTML. Re-import it in n8n:

1. Open n8n: `http://localhost:5678`
2. Go to **Workflows** → **Phase 2 — PRD Interview**
3. Delete existing workflow
4. Import `workflows/Phase 2 — PRD Interview.json`
5. Activate the workflow

### 2. Start SSE Service

```bash
cd services/sse-broadcast
npm install
node server.js
```

Verify it's running: `http://localhost:3001/health`

### 3. Open Interview UI

```
http://localhost:5678/webhook/prd-interview
```

### 4. Complete Interview

Answer the interviewer's questions until it says "Interview complete!" and the UI transitions to the progress bar.

### 5. Observe Real-Time Updates

- **Phase 3 (Synthesis)**: Progress bar should update: 0% → 50% → 100%
- **Phase 4 (Council)**: Reviewer boxes should update from "⏳ Reviewing..." to showing actual reviews
- **Findings**: Final verdict should appear with 4 action buttons

### 6. Check SSE Connection

- Open browser DevTools → Network tab
- Filter by "events" or "localhost:3001"
- Should see an active EventSource connection
- Events should appear in real-time as the pipeline progresses

## Known Limitations

1. **Action buttons are placeholders** — They show alert messages instead of triggering real workflows because Phase 5 (Task Generation) doesn't exist yet.

2. **Phase 3 progress is coarse-grained** — Only 3 events (0%, 50%, 100%). For finer-grained progress, Phase 3 workflow would need to emit more events.

3. **Council reviews don't stream character-by-character** — Each reviewer's full output appears at once when they complete. True streaming would require Phase 4 to use Ollama's streaming API and emit incremental SSE events.

4. **No error handling for failed phases** — If Phase 3 or 4 fails, the UI will hang. Should add timeout detection and error messages.

5. **SSE reconnection is automatic but silent** — If SSE disconnects mid-pipeline, EventSource will attempt to reconnect, but the UI doesn't provide clear feedback during the reconnection window.

## Future Enhancements

### Phase 5 Integration (Next)

When Phase 5 (Task Generation) is implemented, wire up the action buttons:

```javascript
async approveAndProceed() {
  const response = await fetch('/webhook/task-generation-action', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ project: this.projectName, action: 'generate' })
  });
  // Transition to task generation phase
}
```

### Finer-Grained Progress

Add more SSE events to Phase 3:

- `phase3.progress` at 10%, 20%, 30%, etc.
- Section-level progress: "Synthesizing Executive Summary...", "Synthesizing Functional Requirements...", etc.

### Character-by-Character Streaming

Modify Phase 4 to use Ollama's streaming API and emit SSE events for each chunk:

```javascript
eventSource.addEventListener('phase4.reviewer.stream', (e) => {
  const data = JSON.parse(e.data);
  const review = councilReviews.find(r => r.name === data.reviewer);
  review.content += data.chunk; // Append incremental text
});
```

### Error Handling

Add timeout detection and error states:

```javascript
setTimeout(() => {
  if (this.currentPhase === 'synthesis' && this.progressPercent === 0) {
    this.showError('Phase 3 timed out. Check n8n workflow execution.');
  }
}, 60000); // 1 minute timeout
```

## Dependencies

- **Issue #73** (SSE Infrastructure) — Must be running on port 3001
- **Issue #75** (SSE Events in workflows) — Phase 3 & 4 must emit events
- **Issue #76** (Auto-chaining) — Phase 2→3→4 must auto-trigger

## Commit

```bash
git add frontend/ scripts/ workflows/
git commit -m "feat: enhanced frontend UI with real-time updates (Issue #74)

Created single-page app with Alpine.js + SSE for live pipeline visualization.

Features:
- Auto-transitions: interview → synthesis → council → findings
- Progress bar: 0-100% during Phase 3 PRD synthesis
- Council stream: Live reviewer outputs appearing as they complete
- Findings display: Verdict + 4 action buttons (placeholders for Phase 5)
- SSE connection status indicator
- Responsive design for mobile

Action buttons are placeholders pending Phase 5 implementation.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Testing Checklist

- [ ] SSE connection established when interview completes
- [ ] Progress bar updates at 0%, 50%, 100%
- [ ] Council reviews appear within 5 seconds of completion
- [ ] All 5 reviewers display (4 + chair)
- [ ] Verdict displays correctly (APPROVED / APPROVED WITH CONCERNS / REVISE)
- [ ] All 4 action buttons respond (show alert messages)
- [ ] Connection status indicator shows correct state
- [ ] Page transitions are smooth (no jarring jumps)
- [ ] Works on mobile viewport (responsive)
- [ ] SSE reconnection works if connection drops mid-pipeline
