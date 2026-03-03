#!/bin/bash
# Phase 2 Interview Test Script
# Project: Federal Grant Management Portal (retest for Issue #48)

set -e

PROJECT_NAME="federal-grant-portal-test"
N8N_BASE="http://localhost:5678"
WEBHOOK_PATH="/webhook/prd-interview-send"

echo "=================================================="
echo "Phase 2: PRD Interview Test"
echo "Project: ${PROJECT_NAME}"
echo "=================================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to send message to interview webhook
send_message() {
    local message="$1"
    local session_id="$2"

    echo -e "${YELLOW}Sending message...${NC}"
    echo "Message: ${message:0:80}..."
    echo ""

    local payload
    if [ -z "$session_id" ]; then
        # Initial message (no session ID)
        payload=$(cat <<EOF
{
  "project": "${PROJECT_NAME}",
  "message": "${message}"
}
EOF
)
    else
        # Follow-up message (with session ID)
        payload=$(cat <<EOF
{
  "project": "${PROJECT_NAME}",
  "session_id": "${session_id}",
  "message": "${message}"
}
EOF
)
    fi

    response=$(curl -s -X POST "${N8N_BASE}${WEBHOOK_PATH}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    echo -e "${GREEN}Response received:${NC}"
    echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('response', d.get('message', d.get('error', str(d)))))" 2>/dev/null | head -20
    echo ""

    # Extract session_id from response if present
    session_id=$(echo "$response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('session_id', ''))" 2>/dev/null)
    echo "$session_id"
}

# Step 1: Start interview with initial project description
echo "=================================================="
echo "Step 1: Starting Interview"
echo "=================================================="
echo ""

initial_message="I need a Federal Grant Management Portal for a mid-sized federal agency. The system should help program managers track grant applications from submission through award and closeout. It needs to integrate with our existing financial systems and comply with federal regulations including FISMA, FedRAMP, and Section 508 accessibility standards."

SESSION_ID=$(send_message "$initial_message" "")

if [ -z "$SESSION_ID" ]; then
    echo -e "${RED}ERROR: No session ID returned. Check if Phase 2 workflow is active in n8n.${NC}"
    exit 1
fi

echo -e "${GREEN}Session started: ${SESSION_ID}${NC}"
echo ""
sleep 2

# Step 2: Answer follow-up questions about users
echo "=================================================="
echo "Step 2: Providing User Information"
echo "=================================================="
echo ""

user_info="Primary users are federal grant program managers (20-30 users), applicant organizations submitting proposals (500+ external users), and compliance officers who audit grant usage. Program managers need dashboard views of all active grants, applicants need form submission and document upload, compliance officers need audit trail access."

SESSION_ID=$(send_message "$user_info" "$SESSION_ID")
sleep 2

# Step 3: Technical requirements
echo "=================================================="
echo "Step 3: Technical Requirements"
echo "=================================================="
echo ""

tech_requirements="Must integrate with our Oracle Financials system via REST API for budget tracking. Need SSO integration with Login.gov for external users and our internal Active Directory for staff. All data must be encrypted at rest and in transit. System should support 1000 concurrent users and handle uploads up to 100MB. We're hosting on AWS GovCloud."

SESSION_ID=$(send_message "$tech_requirements" "$SESSION_ID")
sleep 2

# Step 4: Compliance and timeline
echo "=================================================="
echo "Step 4: Compliance and Timeline"
echo "=================================================="
echo ""

compliance_timeline="This is a greenfield project, no legacy system to migrate from. Must achieve FedRAMP Moderate authorization within 12 months of launch. Need FISMA controls documented in our SSP. Section 508 compliance is mandatory - we get audited annually. Launch target is 9 months from now. Budget is approved, no constraints there."

SESSION_ID=$(send_message "$compliance_timeline" "$SESSION_ID")
sleep 2

# Step 5: Complete interview and trigger synthesis
echo "=================================================="
echo "Step 5: Completing Interview"
echo "=================================================="
echo ""

completion_message="That covers all the key requirements. Please proceed with writing the PRD."

SESSION_ID=$(send_message "$completion_message" "$SESSION_ID")

echo ""
echo "=================================================="
echo "Interview Complete"
echo "=================================================="
echo ""
echo -e "${GREEN}✓ Interview conversation completed${NC}"
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Check workspace/${PROJECT_NAME}/handoffs/002-prd-interview.md"
echo "2. Phase 3 (PRD Synthesis) should trigger automatically"
echo "3. Monitor n8n execution history: ${N8N_BASE}"
echo ""
echo "Run this to check handoff files:"
echo "  ls -lh workspace/${PROJECT_NAME}/handoffs/"
echo ""
