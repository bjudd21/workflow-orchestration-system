# Issue #75: n8n Workflows Emit SSE Events

**Goal**: Make Phase 3 and Phase 4 workflows send real-time progress updates to the SSE service.

**What we'll add:**
- Phase 3: Emit progress events (0%, 50%, 100%)
- Phase 4: Emit events when each council reviewer completes
- Phase 4: Emit final completion event

**Estimated Time**: 30-45 minutes

---

## Part 1: Phase 3 → Emit Progress Events

Phase 3 (PRD Synthesis) takes ~10-15 minutes. We'll emit progress updates so the UI can show a progress bar.

### Step 1: Open Phase 3 Workflow

1. Go to http://localhost:5678
2. Open: **"Phase 3 — PRD Synthesis"**

### Step 2: Add Progress Event Nodes

We'll add 3 HTTP Request nodes to emit progress at key points:
- **0%**: When synthesis starts
- **50%**: After Ollama synthesis completes
- **100%**: After PRD is written

---

#### A. Add "Emit Progress 0%" Node

**Where**: After the first node that validates inputs (usually "Code - Validate Inputs" or similar)

1. **Find the node** after webhook trigger (probably "Code - Validate Inputs" or "IF - Action is Approve")
2. **Click the + button** after it
3. **Search for**: `HTTP Request`
4. **Select**: HTTP Request

**Configure:**
- **Name**: `Emit Progress 0%`
- **Method**: `POST`
- **URL**: `http://sse-broadcast:3001/events/{{ $json.project }}/phase3/progress`
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`
- **Body Parameters**:
  - **Name**: `percent` | **Value**: `0` (plain text)
  - **Name**: `message` | **Value**: `Starting PRD synthesis...` (plain text)
- **Options** → **Ignore SSL Issues**: Toggle ON
- **Options** → **Timeout**: `5000`

**Connection**: Insert this node in the main flow (not parallel).

---

#### B. Add "Emit Progress 50%" Node

**Where**: After "HTTP Request - Ollama Synthesis" completes

1. **Find the node**: "HTTP Request - Ollama Synthesis" (or similar - the node that calls Ollama)
2. **Find the node that comes AFTER it** (usually "Code - Process Synthesis")
3. **Click + between** Ollama node and Process node
4. **Add HTTP Request**

**Configure:**
- **Name**: `Emit Progress 50%`
- **Method**: `POST`
- **URL**: `http://sse-broadcast:3001/events/{{ $json.project }}/phase3/progress`
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`
- **Body Parameters**:
  - **Name**: `percent` | **Value**: `50` (plain text)
  - **Name**: `message` | **Value**: `PRD synthesis complete, writing file...` (plain text)
- **Options** → **Ignore SSL Issues**: Toggle ON
- **Options** → **Timeout**: `5000`

**Connection**: Insert in series between Ollama and Process nodes.

---

#### C. Add "Emit Progress 100%" Node

**Where**: After "Code - Write Versioned PRD" completes

1. **Find the node**: "Code - Write Versioned PRD"
2. **Click + after it**
3. **Add HTTP Request** (should be BEFORE "Auto-Trigger Phase 4")

**Configure:**
- **Name**: `Emit Progress 100%`
- **Method**: `POST`
- **URL**: `http://sse-broadcast:3001/events/{{ $json.project }}/phase3/progress`
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`
- **Body Parameters**:
  - **Name**: `percent` | **Value**: `100` (plain text)
  - **Name**: `message` | **Value**: `PRD complete!` (plain text)
- **Options** → **Ignore SSL Issues**: Toggle ON
- **Options** → **Timeout**: `5000`

**Connection**:
```
Code - Write Versioned PRD → Emit Progress 100% → Auto-Trigger Phase 4 → Respond
```

---

### Step 3: Save Phase 3

1. Click **Save** (Ctrl+S)
2. Ensure workflow is **Active**

---

## Part 2: Phase 4 → Emit Reviewer Events

Phase 4 runs 4 core reviewers in parallel, then a council chair. We'll emit an event after each reviewer completes.

### Step 1: Open Phase 4 Workflow

1. Open: **"Phase 4 — Council Review"**

### Step 2: Find the Council Reviewer Nodes

Phase 4 should have 4 parallel HTTP Request nodes that call Ollama for each reviewer:
- Tech Reviewer
- UX Reviewer
- Business Reviewer
- Security Reviewer

Each of these feeds into a "Code" node that processes the review.

---

### Step 3: Add "Emit Reviewer Event" After Each Reviewer

We need to add an HTTP Request node **after each reviewer's processing node**.

**Repeat this for EACH of the 4 reviewers:**

#### Find the Pattern:
```
HTTP Request - Ollama (Reviewer) → Code - Process (Reviewer) → [Next Node]
```

We'll insert a new node after "Code - Process (Reviewer)":

```
Code - Process (Reviewer) → Emit Reviewer Event → [Next Node]
```

---

#### Example: Tech Reviewer

1. **Find**: "Code - Process Tech Review" (or similar)
2. **Disconnect** the output from this node
3. **Click +** on "Code - Process Tech Review"
4. **Add HTTP Request**

**Configure:**
- **Name**: `Emit Tech Reviewer Event`
- **Method**: `POST`
- **URL**: `http://sse-broadcast:3001/events/{{ $json.project }}/phase4/reviewer`
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`
- **Body Parameters**:
  - **Name**: `reviewer` | **Value**: `Tech Reviewer` (plain text)
  - **Name**: `review` | **Value**: `={{ $json.techReview }}` (expression - adjust field name to match your workflow)
  - **Name**: `verdict` | **Value**: `={{ $json.techVerdict }}` (expression)
  - **Name**: `concerns_count` | **Value**: `={{ $json.techConcernsCount || 0 }}` (expression)
- **Options** → **Ignore SSL Issues**: Toggle ON
- **Options** → **Timeout**: `5000`

5. **Reconnect**: The node that was originally after "Code - Process Tech Review"

---

#### Repeat for Other Reviewers:

**UX Reviewer:**
- Name: `Emit UX Reviewer Event`
- reviewer: `UX Reviewer`
- Adjust field names: `$json.uxReview`, `$json.uxVerdict`, etc.

**Business Reviewer:**
- Name: `Emit Business Reviewer Event`
- reviewer: `Business Reviewer`
- Adjust field names: `$json.businessReview`, `$json.businessVerdict`, etc.

**Security Reviewer:**
- Name: `Emit Security Reviewer Event`
- reviewer: `Security Reviewer`
- Adjust field names: `$json.securityReview`, `$json.securityVerdict`, etc.

---

### Step 4: Add "Emit Complete" Event

After the Council Chair node completes, we'll emit a final "complete" event.

1. **Find**: The node that processes the Council Chair's final verdict (usually "Code - Council Chair Decision" or similar)
2. **Find the node after it** (probably writes the handoff file or responds)
3. **Insert a new HTTP Request node**

**Configure:**
- **Name**: `Emit Council Complete Event`
- **Method**: `POST`
- **URL**: `http://sse-broadcast:3001/events/{{ $json.project }}/phase4/complete`
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`
- **Body Parameters**:
  - **Name**: `verdict` | **Value**: `={{ $json.verdict }}` (expression)
  - **Name**: `summary` | **Value**: `={{ $json.chairSummary || 'Council review complete' }}` (expression)
  - **Name**: `concerns` | **Value**: `={{ $json.totalConcerns || 0 }}` (expression)
  - **Name**: `endorsements` | **Value**: `={{ $json.totalEndorsements || 0 }}` (expression)
- **Options** → **Ignore SSL Issues**: Toggle ON
- **Options** → **Timeout**: `5000`

---

### Step 5: Save Phase 4

1. Click **Save** (Ctrl+S)
2. Ensure workflow is **Active**

---

## Part 3: Test SSE Events

### Step 1: Connect to SSE Stream

**Open a new terminal** and run:

```bash
curl -N http://localhost:3001/events/sse-test
```

This will keep a connection open and show events as they arrive.

### Step 2: Start a Test Interview

**In another terminal or browser:**

```bash
# Start interview
http://localhost:5678/webhook/prd-interview?project=sse-test
```

Complete the interview (answer a few questions, then say "done").

### Step 3: Watch Events Appear

In the curl terminal, you should see events appear in real-time:

```
event: connected
data: {"message":"Connected to SSE stream","project":"sse-test"}

event: phase3.progress
data: {"percent":0,"message":"Starting PRD synthesis..."}

event: phase3.progress
data: {"percent":50,"message":"PRD synthesis complete, writing file..."}

event: phase3.progress
data: {"percent":100,"message":"PRD complete!"}

event: phase4.reviewer
data: {"reviewer":"Tech Reviewer","review":"...","verdict":"APPROVE","concerns_count":0}

event: phase4.reviewer
data: {"reviewer":"UX Reviewer","review":"...","verdict":"APPROVE","concerns_count":1}

...

event: phase4.complete
data: {"verdict":"APPROVED","summary":"Council review complete","concerns":2,"endorsements":15}
```

---

## Troubleshooting

### SSE Service Not Running

```bash
# Check if service is up
curl http://localhost:3001/health

# If not, start it:
docker compose up -d sse-broadcast
```

### Events Not Appearing

1. **Check n8n execution logs**:
   - Go to http://localhost:5678/executions
   - Click on the Phase 3 or Phase 4 execution
   - Look for the "Emit Progress" or "Emit Reviewer Event" nodes
   - Check if they executed successfully

2. **Check SSE service logs**:
   ```bash
   docker compose logs sse-broadcast --tail 50 -f
   ```

3. **Manual test the endpoint**:
   ```bash
   curl -X POST http://localhost:3001/events/test/phase3/progress \
     -H "Content-Type: application/json" \
     -d '{"percent": 50, "message": "Test event"}'
   ```

### Field Name Mismatches

If you see errors like "Cannot read property 'techReview' of undefined":
- The field names in your workflow may be different
- Click on the node before the "Emit" node
- Click "Execute Node" to see what data is available
- Update the field names in the emit node to match

---

## Success Criteria

When SSE events are working correctly:

- [ ] Phase 3 emits 3 progress events (0%, 50%, 100%)
- [ ] Phase 4 emits 4 reviewer events (one per core reviewer)
- [ ] Phase 4 emits 1 complete event (after council chair)
- [ ] curl terminal shows events arriving in real-time
- [ ] SSE service logs show "Broadcasting" messages
- [ ] No errors in n8n execution logs for emit nodes

---

## Next Steps

After Issue #75 is complete:
- **#74**: Enhanced Frontend UI (HTMX + Alpine.js)
  - Connect to SSE stream in browser
  - Show progress bar that updates from events
  - Show council conversation that updates in real-time
  - Add action buttons (Approve/Request Changes)

Timeline: #75 (today) → #74 (3-4 days) = Full real-time UI complete!
