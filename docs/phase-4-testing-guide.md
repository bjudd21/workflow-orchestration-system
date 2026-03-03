# Phase 4 Council Review - Testing Guide

**Last Updated**: 2026-03-02
**Status**: Data flow fixed, ready for re-test

---

## What Was Fixed

### Issue
**Error**: `Cannot read properties of undefined (reading 'toString')`

**Root Cause**: HTTP - Ollama Health node was overwriting input data with API response, breaking the data flow to downstream Read Binary File nodes.

### Fix Applied
1. **HTTP node configured to preserve data**:
   - Used `destinationDataField: "healthCheck"`
   - Input data now preserved, API response in `$json.healthCheck`

2. **IF condition updated**:
   - Changed from `$json.models` to `$json.healthCheck.models`
   - Uses optional chaining for safe access

3. **Follows system standards**:
   - Data Flow Integrity principle (docs/development-standards.md)
   - Every node preserves context unless explicitly discarding

**Commit**: `54966f0` - fix: preserve data through HTTP health check

---

## Prerequisites

Before testing Phase 4, you need a PRD file from Phase 3.

### Option 1: Use Existing Test Data
```bash
ls -la workspace/test-project/handoffs/003-prd-refined.md
```

If this file exists, use project name: `test-project`

### Option 2: Create Minimal Test PRD
```bash
mkdir -p workspace/phase4-test/handoffs

cat > workspace/phase4-test/handoffs/003-prd-refined.md << 'EOF'
---
phase: prd-synthesis
version: v1
status: Draft
compliance: none
---

# E-Commerce Modernization Platform

## 1. Executive Summary
Migrate legacy .NET Framework 4.8 e-commerce system to .NET 8 microservices architecture with cloud-native patterns.

## 2. Functional Requirements

**FR-1**: Product catalog service must expose RESTful API with OpenAPI 3.0 spec
**FR-2**: User authentication via OAuth 2.0 with JWT tokens
**FR-3**: Order processing must support async workflows via message queue
**FR-4**: Payment integration with Stripe and PayPal gateways
**FR-5**: Admin dashboard with RBAC for inventory management
**FR-6**: Search functionality via Elasticsearch with sub-100ms response
**FR-7**: Real-time inventory updates via WebSocket connections
**FR-8**: Automated tax calculation integration with Avalara

## 3. Non-Functional Requirements

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-1 | API response time (p95) | < 200ms | APM monitoring |
| NFR-2 | System availability | 99.9% uptime | StatusPage |
| NFR-3 | Concurrent users | 10,000 active | Load testing |
| NFR-4 | Database query time (p99) | < 50ms | Query logs |
| NFR-5 | Container startup | < 30s | K8s metrics |

## 4. User Stories

**US-1**: As a customer, I want to browse products by category so I can find items quickly
**US-2**: As a customer, I want to add items to cart and checkout securely
**US-3**: As an admin, I want to manage product inventory in real-time
**US-4**: As an admin, I want to view sales analytics and reports
**US-5**: As a developer, I want API documentation so I can integrate

## 5. Architecture Overview

Microservices architecture:
- Product Service (ASP.NET Core 8, PostgreSQL)
- Order Service (ASP.NET Core 8, SQL Server)
- User Service (Identity Server, PostgreSQL)
- Gateway (YARP reverse proxy)
- Message Bus (RabbitMQ)
- Cache Layer (Redis)
- Search (Elasticsearch)

Deployment: AWS EKS, Terraform IaC

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| R1: Data migration complexity | High | High | Phased migration, dual-write pattern |
| R2: Third-party API downtime | Medium | High | Circuit breaker pattern, fallback logic |
| R3: Performance degradation | Medium | High | Load testing before cutover |
| R4: Team skill gap (K8s) | High | Medium | Training + managed EKS |

## 7. MVP vs. Future Phases

**MVP (Phase 1 - 8 weeks)**:
- Product catalog + search
- User auth + basic checkout
- Admin inventory management
- Deploy to staging EKS

**Future (Phase 2+)**:
- Advanced analytics
- Mobile app
- International expansion
- AI-powered recommendations
EOF

echo "✅ Test PRD created at workspace/phase4-test/handoffs/003-prd-refined.md"
```

---

## Testing Steps

### Step 1: Re-import Fixed Workflow

```bash
# 1. Open n8n UI
http://localhost:5678

# 2. Navigate to Workflows

# 3. Find "Phase 4 — Council Review"

# 4. Delete the old version
#    (Click workflow → Settings → Delete)

# 5. Import the fixed version
#    - Click "Import from File"
#    - Select: workflow-orchestration-system-scaffold/workflows/phase-4-council-review.json
#    - Click "Import"

# 6. Activate the workflow
#    (Toggle switch in top-right corner)

# 7. Save (Ctrl+S)
```

### Step 2: Access Council Review UI

Open in browser:
```
http://localhost:5678/webhook/council-review
```

You should see:
```
Council Review (Phase 4)
Run PRD Council: 4 core reviewers + Council Chair. Review takes 15-20 minutes.

Project: [                    ] [Start Council Review]
```

### Step 3: Start Review

1. **Enter project name**: `test-project` (or `phase4-test` if you created new data)
2. **Click**: "Start Council Review"
3. **Wait**: Status should change to "Running council — 4 reviewers + chair. Takes 15-20 min…"

---

## Expected Behavior

### Data Flow (Should NOT Error)
```
User submits "test-project"
  ↓
Code - Validate Inputs (creates prdHandoff, councilHandoff)
  ↓
HTTP - Ollama Health (checks Ollama, preserves data) ✅
  ↓
IF - Ollama Reachable (checks healthCheck.models) ✅
  ↓
IF - Route Action (action = 'review')
  ↓
Read - PRD File (reads $json.prdHandoff) ✅
  ↓
Code - Process PRD (converts binary to text)
  ↓
Code - Validate PRD Contract (checks sections)
  ↓
Code - Load Reviewers (structures reviewer data)
  ↓
HTTP - Run R1 (Tech) → HTTP - Run R2 (Sec) → HTTP - Run R3 (Exec) → HTTP - Run R4 (User)
  ↓
HTTP - Warm Quality Model (loads qwen3.5:35b)
  ↓
HTTP - Run Chair (synthesizes all reviews)
  ↓
Assemble council output → Return to UI
```

### Success Criteria
- ✅ No "Cannot read properties of undefined" error
- ✅ All 4 reviewers execute (see console output)
- ✅ Chair synthesis runs
- ✅ Review displayed in UI with markdown formatting

### Timeline
- **Reviewers (4 × ~3-4 min)**: 12-16 minutes (speed model)
- **Chair (1 × ~4-6 min)**: 4-6 minutes (quality model)
- **Total**: 16-22 minutes

---

## If It Still Errors

### Check 1: Ollama Running
```bash
ollama list
# Should show qwen3.5:35b-a3b and qwen3.5:35b
```

### Check 2: PRD File Exists
```bash
cat workspace/test-project/handoffs/003-prd-refined.md
# Should show PRD content
```

### Check 3: n8n Execution Log
In n8n UI:
1. Click "Executions" in left sidebar
2. Find the failed execution
3. Click to see detailed error
4. Check which node failed
5. Share the error log

### Check 4: Workflow Import Success
```bash
# Verify node connections
# In n8n UI: Open workflow, check that nodes have visible connection lines
# No orphaned nodes
```

---

## After Successful Test

Once the council review completes:

1. **Verify output**: Review text displayed in UI with markdown formatting
2. **Check handoff file**:
   ```bash
   cat workspace/test-project/handoffs/004-council-review.md
   ```
3. **Test decisions**:
   - Click "✓ Accept Recommendations"
   - Click "✗ Reject Recommendations"
4. **Test re-review gate**:
   - After decision, choose "→ Proceed to Phase 5" or "↻ Reconvene Council"

---

## Success Indicators

✅ **Phase 4 works correctly if:**
1. Review completes without errors
2. All 4 reviewers produce output
3. Chair synthesis runs
4. Review displayed in UI
5. User decisions recorded
6. Re-review gate presents options

📊 **Performance check:**
- Total time < 25 minutes (NFR-1 target: < 20 min)
- Speed model calls: ~40-60 tok/s
- Quality model call: ~24-32 tok/s

---

## Next Steps After Success

1. ✅ Mark Issue #47 as complete
2. ✅ Update PR #64 with test results
3. ✅ Merge to main
4. ➡️ Begin Task 7.0: True MVP Integration Test (end-to-end pipeline validation)

---

**Questions?** Check `docs/development-standards.md` for troubleshooting patterns.
