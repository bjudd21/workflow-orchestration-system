# Phase 4 SSE Fix & Enhanced UI - Implementation Summary

**Date**: 2026-03-13
**Status**: Ready for Testing

---

## What Was Fixed

### Problem
Phase 4 workflow had SSE emission nodes configured to POST to the SSE server, but they were sending **empty request bodies**. This meant:
- SSE server received events but with no payload data
- Real-time UI couldn't display reviewer progress
- Users saw only the final result after 2+ minutes with no feedback

### Solution
1. **Fixed SSE Emission Nodes**: Added proper JSON payloads to all 5 emission HTTP Request nodes
2. **Built Enhanced Streaming UI**: Created real-time UI that displays each reviewer's output as it streams in

---

## Files Changed

### 1. Workflow Export (Fixed)
**Location**: `workflows/Phase-4-Council-Review-FIXED.json`

**Changes**:
- **5 emission nodes** now send structured JSON payloads:
  - `Emit Tech Reviewer Event` → sends `{ reviewer, review, timestamp }`
  - `Emit Security Reviewer Event` → sends `{ reviewer, review, timestamp }`
  - `Emit Executive Reviewer Event` → sends `{ reviewer, review, timestamp }`
  - `Emit User Reviewer Event` → sends `{ reviewer, review, timestamp }`
  - `Emit Council Complete Event` → sends `{ verdict, review, chair_synthesis, timestamp }`

- Removed conflicting `bodyParameters` (form-style body)
- Set `specifyBody: "json"` with proper `jsonBody` configuration

### 2. Enhanced Streaming UI
**Location**: `frontend/council-review-streaming.html`

**Features**:
- **Real-time progress cards** for each of the 5 reviewers
- **Status indicators**: Waiting (⏳), Active (▶), Complete (✓)
- **Streaming cursor** animation while reviewer is active
- **Connection status** indicator (shows SSE connection health)
- **Auto-expanding cards** as reviewers complete
- **Verdict summary** displayed after council chair synthesis
- **Action buttons**: Accept / Reject / Request Revision

**Technology Stack**:
- Alpine.js for reactive state management
- EventSource API for SSE connection
- Marked.js for markdown rendering
- Tailwind-inspired minimal CSS

---

## How to Deploy

### Step 1: Update Phase 4 Workflow in n8n

**Option A: Import via n8n UI** (Recommended)
1. Open n8n at `http://localhost:5678`
2. Go to Workflows
3. Find "Phase 4 — Council Review" (ID: `Aj51idq5bxiC7Uhi`)
4. Click the "..." menu → "Duplicate" (to keep a backup)
5. Click the "..." menu on original → "Delete"
6. Click "Add workflow" → "Import from file"
7. Select `workflows/Phase-4-Council-Review-FIXED.json`
8. Activate the workflow

**Option B: Database Direct Update** (Advanced)
```bash
# Stop n8n
docker stop workflow-orchestration-n8n

# Backup database
docker cp workflow-orchestration-n8n:/home/node/.n8n/database.sqlite /tmp/n8n-backup.sqlite

# Use SQLite to update (requires manual SQL editing - not recommended)

# Restart n8n
docker start workflow-orchestration-n8n
```

### Step 2: Update Phase 4 Webhook Response to Serve New UI

**Option 1: Via n8n UI**
1. Open the Phase 4 workflow
2. Find node: "Respond - Review UI"
3. Replace the HTML in `responseBody` with contents of `frontend/council-review-streaming.html`
4. Save and activate

**Option 2: Separate Static File Server** (Better for development)
```bash
cd frontend
python3 -m http.server 8080

# Access UI at: http://localhost:8080/council-review-streaming.html
```

Then modify the workflow to redirect or use the static file.

### Step 3: Verify SSE Server is Running

```bash
# Check SSE service health
curl http://localhost:3001/health

# Expected response:
# {"status":"healthy","uptime":12345,"projects":0,"connectedClients":0}
```

---

## Testing the Fix

### Test 1: Verify SSE Emissions (Backend)

Run a council review and watch SSE server logs:

```bash
# Terminal 1: Watch SSE logs
docker logs -f workflow-orchestration-sse

# Terminal 2: Trigger review
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d '{"project":"test-sse-fix","action":"review"}'
```

**Expected logs**:
```
[SSE] Broadcasting phase4.reviewer to X client(s) (project: test-sse-fix)
  ↳ Payload: {"reviewer":"Technical Reviewer","review":"## Technical Review...","timestamp":"..."}
[SSE] Broadcasting phase4.reviewer to X client(s) (project: test-sse-fix)
  ↳ Payload: {"reviewer":"Security Reviewer","review":"## Security Review...","timestamp":"..."}
...
[SSE] Broadcasting phase4.complete to X client(s) (project: test-sse-fix)
  ↳ Payload: {"verdict":"REVISE AND RESUBMIT","review":"...","chair_synthesis":"...","timestamp":"..."}
```

### Test 2: Verify Enhanced UI (Frontend)

1. Open the streaming UI:
   ```
   http://localhost:8080/council-review-streaming.html
   ```
   (Or whatever URL serves the new HTML)

2. Enter project name: `test-streaming-ui`

3. Click "Start Council Review"

4. **Watch for**:
   - Connection status shows "● Connected to event stream"
   - Each reviewer card appears and expands as they complete
   - Status changes: Waiting → Active → Complete
   - Streaming cursor appears on active reviewer
   - Verdict summary appears after all reviewers complete
   - Action buttons appear at the end

### Test 3: End-to-End with Phase 2→3→4

1. Start a fresh interview at `http://localhost:5678/webhook/prd-interview`
2. Complete the interview
3. Phase 3 auto-triggers (PRD synthesis)
4. Phase 4 auto-triggers (council review)
5. Open the streaming UI with the same project name
6. Watch the real-time updates

---

## Troubleshooting

### SSE Events Not Appearing in UI

**Check 1: SSE Server Receiving Events**
```bash
docker logs workflow-orchestration-sse --tail 50
```
Look for "Broadcasting phase4.reviewer" messages. If missing:
- Workflow emission nodes not sending data (check n8n execution logs)
- Verify URL in emission nodes: `http://host.docker.internal:3001/events/{project}/phase4/reviewer`

**Check 2: Browser Console**
Open DevTools → Console. Look for:
- `[SSE] Connected` (confirms EventSource connection)
- `[Reviewer Update] {...}` (confirms events received)
- `[Review Complete] {...}` (confirms final event)

If missing:
- Check CORS (SSE server allows all origins by default)
- Verify SSE URL: `http://localhost:3001/events/{project-name}`
- Check Network tab for `events/{project}` request (should be "pending" during review)

### Emission Nodes Fail in n8n

**Error**: "Missing or invalid required parameters"

**Fix**:
1. Open emission node in n8n UI
2. Verify `Send Body` is checked
3. Verify `Specify Body` is set to `JSON`
4. Verify `JSON` field contains:
   ```json
   {
     "reviewer": "{{ $json.r1name }}",
     "review": "{{ $json.r1 }}",
     "timestamp": "{{ new Date().toISOString() }}"
   }
   ```
5. Save node

### UI Shows "Disconnected"

**Causes**:
- SSE server not running (`docker ps | grep sse`)
- Wrong SSE URL in UI (check `connectSSE()` function)
- CORS blocking (check browser console for errors)

**Fix**:
```bash
# Restart SSE server
docker restart workflow-orchestration-sse

# Verify health
curl http://localhost:3001/health
```

---

## Next Steps

### Phase 5: Task Generation
With Phase 4 complete and streaming, the next phase is:
- Input: Council review + refined PRD
- Output: Structured task list + GitHub Issues
- Uses: PM Framework agents to decompose PRD into tasks

### Future Enhancements (Optional)
1. **Token-by-token streaming**: Modify Ollama calls to use `stream: true` and emit text chunks in real-time (Issue #80)
2. **Reconnection with replay**: If user refreshes page mid-review, replay missed events from SSE buffer
3. **Progress percentage**: Show "3 of 5 reviewers complete"
4. **Estimated time remaining**: Based on average reviewer duration

---

## Related Issues

- **#80**: "Configure Phase 4 workflow for Ollama streaming mode" - ✅ **RESOLVED** (emission payloads fixed)
- **#79**: "Enhanced Phase 4 UI with real-time LLM streaming" - ✅ **RESOLVED** (streaming UI built)
- **#78**: "Build SSE real-time event broadcasting server" - ✅ Already complete

---

## Scripts Used

1. `scripts/fix-phase4-sse-emissions-v2.js` - Added JSON payloads to emission nodes
2. `scripts/fix-phase4-sse-emissions-v3.js` - Cleaned conflicting bodyParameters
3. Final workflow: `workflows/Phase-4-Council-Review-FIXED.json`

---

## Validation Checklist

- [ ] SSE server running and healthy (`curl http://localhost:3001/health`)
- [ ] Phase 4 workflow updated with fixed emission nodes
- [ ] Enhanced UI accessible via browser
- [ ] Test review shows real-time updates in UI
- [ ] SSE logs show proper JSON payloads being broadcast
- [ ] Browser console shows `[SSE] Connected` and `[Reviewer Update]` messages
- [ ] All 5 reviewers + chair display correctly
- [ ] Verdict summary appears after completion
- [ ] Action buttons work (Accept/Reject/Revise)

---

**Questions or Issues?**
Open a GitHub issue with:
- SSE server logs (`docker logs workflow-orchestration-sse`)
- n8n execution ID of failed run
- Browser console output
- Network tab screenshot showing SSE connection
