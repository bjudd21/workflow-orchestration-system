#!/bin/bash
# Simplified Phase 2 Interview Test Script
# Uses project name for conversation continuity (no session IDs needed)

set -e

PROJECT_NAME="federal-grant-portal-test"
N8N_BASE="http://localhost:5678"
WEBHOOK_URL="${N8N_BASE}/webhook/prd-interview-send"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=================================================="
echo "Phase 2: PRD Interview Test"
echo "Project: ${PROJECT_NAME}"
echo "=================================================="
echo ""

# Function to send message
send_message() {
    local message="$1"
    local step_name="$2"

    echo -e "${YELLOW}Step: ${step_name}${NC}"
    echo "Message: ${message:0:100}..."
    echo ""

    response=$(curl -s -X POST "${WEBHOOK_URL}" \
        -H "Content-Type: application/json" \
        -d "{\"project\": \"${PROJECT_NAME}\", \"message\": $(echo "$message" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read()))")}")

    echo -e "${GREEN}Response:${NC}"
    echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('response', d.get('error', str(d)))[:300])" 2>/dev/null

    complete=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('complete', False))" 2>/dev/null)
    turn=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('turn', '?'))" 2>/dev/null)

    echo ""
    echo -e "Turn: ${turn}, Complete: ${complete}"
    echo ""
    sleep 2
}

# Step 1: Initial project description
send_message "I need a Federal Grant Management Portal for a mid-sized federal agency. The system should help program managers track grant applications from submission through award and closeout. It needs to integrate with our existing financial systems and comply with federal regulations including FISMA, FedRAMP, and Section 508 accessibility standards." "1 - Project Overview"

# Step 2: User information
send_message "Primary users are federal grant program managers (20-30 users), applicant organizations submitting proposals (500+ external users), and compliance officers who audit grant usage. Program managers need dashboard views of all active grants, applicants need form submission and document upload, compliance officers need audit trail access." "2 - Users and Personas"

# Step 3: Technical requirements
send_message "Must integrate with our Oracle Financials system via REST API for budget tracking. Need SSO integration with Login.gov for external users and our internal Active Directory for staff. All data must be encrypted at rest and in transit. System should support 1000 concurrent users and handle uploads up to 100MB. We're hosting on AWS GovCloud." "3 - Technical Requirements"

# Step 4: Compliance and timeline
send_message "This is a greenfield project, no legacy system to migrate from. Must achieve FedRAMP Moderate authorization within 12 months of launch. Need FISMA controls documented in our SSP. Section 508 compliance is mandatory - we get audited annually. Launch target is 9 months from now. Budget is approved, no constraints there." "4 - Compliance and Timeline"

# Step 5: Complete interview
send_message "That covers all the key requirements. Please proceed with synthesizing this into a PRD." "5 - Complete Interview"

echo "=================================================="
echo "Interview Complete"
echo "=================================================="
echo ""
echo -e "${GREEN}✓ All messages sent${NC}"
echo ""
echo "Next steps:"
echo "1. Check: workspace/${PROJECT_NAME}/interview-state.json"
echo "2. Check: workspace/${PROJECT_NAME}/handoffs/002-prd-interview.md"
echo "3. Phase 3 should trigger automatically once interview is marked complete"
echo "4. Monitor: ${N8N_BASE} (Executions tab)"
echo ""
echo "Run ./check-test-results.sh to validate all handoffs"
echo ""
