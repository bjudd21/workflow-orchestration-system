# Issue #76: Auto-Chaining Phase 2→3→4

**Goal**: Automatically trigger Phase 3 after Phase 2 completes, and Phase 4 after Phase 3 completes.

**Method**: Manual UI setup (programmatic JSON modification breaks n8n import)

**Estimated Time**: 15-20 minutes

---

## Part 1: Phase 2 → Auto-Trigger Phase 3

### Step 1: Open Phase 2 Workflow
1. Navigate to http://localhost:5678
2. Open: **"Phase 2 — PRD Interview"**

### Step 2: Find the Final Node
Look for the node named: **"Respond to Webhook - Interview Complete"**
- This is the last node in the workflow
- It sends the completion response to the user

### Step 3: Add HTTP Request Node

**Add the node:**
1. Click the **+** button after "Respond to Webhook - Interview Complete"
2. Search for: **HTTP Request**
3. Select it

**Configure the node:**

**Basic Settings:**
- **Name**: `Auto-Trigger Phase 3`
- **Method**: `POST`
- **URL**: `http://localhost:5678/webhook/prd-synthesis-action`

**Body Settings:**
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`

**Add these parameters (click "Add Parameter" for each):**
1. **Name**: `project` | **Value**: `={{ $json.project }}`
2. **Name**: `action` | **Value**: `synthesize` (plain text, no expression)

**Options (click "Add Option"):**
- **Add Option** → **Timeout**: `10000` (10 seconds)
- **Add Option** → **Ignore SSL Issues**: Toggle ON (for local dev)

### Step 4: Important Connection Pattern

The auto-trigger should run **in parallel** with the response, not block it.

**DO NOT** connect it in series. The workflow should look like:

```
[Write Binary File - Handoff]
    ├─→ [Respond to Webhook - Interview Complete]
    └─→ [Auto-Trigger Phase 3]
```

Both nodes should connect directly from "Write Binary File - Handoff".

### Step 5: Save & Activate
1. Click **Save** (Ctrl+S)
2. Ensure workflow is **Active**

---

## Part 2: Phase 3 → Auto-Trigger Phase 4

### Step 1: Open Phase 3 Workflow
1. Open: **"Phase 3 — PRD Synthesis"**

### Step 2: Find the PRD Write Node
Look for: **"Code - Write Versioned PRD"**
- This node already writes both:
  - `tasks/prd-{project}-v{version}.md`
  - `handoffs/003-prd-refined.md` (Issue #72 fix)

### Step 3: Add HTTP Request Node

**Add the node:**
1. Click the **+** button after "Code - Write Versioned PRD"
2. Before the "Respond to Webhook" node
3. Search for: **HTTP Request**
4. Select it

**Configure the node:**

**Basic Settings:**
- **Name**: `Auto-Trigger Phase 4`
- **Method**: `POST`
- **URL**: `http://localhost:5678/webhook/council-review-action`

**Body Settings:**
- **Send Body**: Toggle ON
- **Body Content Type**: `JSON`
- **Specify Body**: `Using Fields Below`

**Add these parameters:**
1. **Name**: `project` | **Value**: `={{ $json.project }}`
2. **Name**: `action` | **Value**: `review` (plain text, no expression)

**Options:**
- **Add Option** → **Timeout**: `10000`
- **Add Option** → **Ignore SSL Issues**: Toggle ON

### Step 4: Connect in Series

This time, the auto-trigger should run **in series** (one after another):

```
[Code - Write Versioned PRD]
    → [Auto-Trigger Phase 4]
    → [Respond to Webhook - Synthesis Complete]
```

This ensures Phase 4 starts immediately after the PRD is written.

### Step 5: Save & Activate
1. Click **Save** (Ctrl+S)
2. Ensure workflow is **Active**

---

## Testing the Auto-Chain

### Test 1: Check n8n is Running
```bash
docker compose ps
curl -s http://localhost:5678/healthz
```

### Test 2: Start an Interview
```bash
# Open in browser:
http://localhost:5678/webhook/prd-interview?project=auto-chain-test

# Or use curl:
curl http://localhost:5678/webhook/prd-interview?project=auto-chain-test
```

### Test 3: Monitor Executions

**Watch n8n executions:**
1. Go to: http://localhost:5678/executions
2. You should see three executions appear within ~15-20 minutes:
   - **Phase 2**: Completes immediately after interview
   - **Phase 3**: Starts within 5-10 seconds of Phase 2 completion
   - **Phase 4**: Starts immediately after Phase 3 completion

### Test 4: Verify Artifacts

```bash
# Wait for all phases to complete, then check:
ls -lh workspace/auto-chain-test/handoffs/

# Expected files:
# 002-prd-interview.md    (Phase 2 output)
# 003-prd-refined.md      (Phase 3 output)
# 004-council-review.md   (Phase 4 output)
```

---

## Troubleshooting

### Phase 3 Doesn't Auto-Start

**Check Phase 2 execution:**
1. Go to n8n → Executions → Click Phase 2 execution
2. Find "Auto-Trigger Phase 3" node
3. Check if it executed successfully

**Manual test:**
```bash
curl -X POST http://localhost:5678/webhook/prd-synthesis-action \
  -H "Content-Type: application/json" \
  -d '{"project": "auto-chain-test", "action": "synthesize"}'
```

If manual test works, the issue is in the HTTP Request node configuration.

### Phase 4 Doesn't Auto-Start

**Check Phase 3 execution:**
1. Go to n8n → Executions → Click Phase 3 execution
2. Verify "Code - Write Versioned PRD" completed successfully
3. Check if "Auto-Trigger Phase 4" node executed

**Verify handoff file exists:**
```bash
cat workspace/auto-chain-test/handoffs/003-prd-refined.md
```

**Manual test:**
```bash
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d '{"project": "auto-chain-test", "action": "review"}'
```

### Auto-Chain Node Shows Error

**Common issues:**
- ❌ **Connection refused**: n8n workflow not activated
- ❌ **Timeout**: Increase timeout to 30000ms (30 seconds)
- ❌ **Invalid JSON**: Check that parameter values use `={{ $json.field }}` syntax correctly

---

## Why Manual Setup?

**Previous attempt (commit 873ad6e) failed because:**
- Programmatic JSON modification broke workflow connections
- n8n's import couldn't handle the modified structure
- Nodes appeared disconnected in the UI

**Manual setup advantages:**
- ✅ n8n handles all internal IDs and connections correctly
- ✅ Visual feedback (you see if nodes are connected properly)
- ✅ Can test each step incrementally
- ✅ Easier to debug if something goes wrong
- ✅ Takes only 15-20 minutes

---

## Success Criteria

When auto-chaining is working correctly:

- [ ] Phase 2 completes and returns interview response to user
- [ ] Phase 3 starts automatically within 5-10 seconds
- [ ] Phase 3 writes `003-prd-refined.md` and triggers Phase 4
- [ ] Phase 4 starts automatically and runs council review
- [ ] All three executions appear in n8n execution history
- [ ] All handoff files are created in correct locations
- [ ] User only interacts at start (interview) and end (review findings)

---

## Next Steps After #76

Once auto-chaining is working:

1. **Test end-to-end flow** with a real project
2. **Move to #74**: Enhanced Frontend UI (HTMX + Alpine.js)
   - Add progress bars for Phase 3
   - Add streaming council conversation for Phase 4
   - Add action buttons (Approve/Request Changes)
3. **Move to #75**: n8n workflows emit SSE events
   - Phase 3 emits progress updates
   - Phase 4 emits reviewer completion events

Timeline: #76 (today) → #75 (1-2 days) → #74 (3-4 days) = Full real-time UI complete!
