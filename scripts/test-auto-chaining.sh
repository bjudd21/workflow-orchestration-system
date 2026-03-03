#!/bin/bash
# Test script for auto-chaining Phase 2 → 3 → 4
# This validates that the interview automatically triggers PRD synthesis,
# which then triggers council review, with all artifacts properly created.

set -e

PROJECT_NAME="auto-chain-test-$(date +%s)"
WORKSPACE_DIR="/home/bjudd/projects/PRDWorkflowSystem/workflow-orchestration-system-scaffold/workspace"
PROJECT_DIR="${WORKSPACE_DIR}/${PROJECT_NAME}"

echo "🧪 Testing auto-chaining with project: ${PROJECT_NAME}"
echo ""

# Step 1: Start interview
echo "📋 Step 1: Starting interview..."
INTERVIEW_RESPONSE=$(curl -s -X POST "http://localhost:5678/webhook/prd-interview" \
  -H "Content-Type: application/json" \
  -d "{\"project\": \"${PROJECT_NAME}\", \"initial_message\": \"Test project for validating auto-chaining\"}")

echo "Interview started: ${INTERVIEW_RESPONSE}"
echo ""

# Step 2: Complete interview with minimal responses
echo "📋 Step 2: Completing interview conversation..."
# In a real test, you'd simulate the full interview conversation
# For now, we'll just verify the workflow is set up correctly

# Give a moment for workflows to process
sleep 2

# Step 3: Verify handoff files are created
echo "📋 Step 3: Checking for handoff files..."
echo ""

HANDOFFS_DIR="${PROJECT_DIR}/handoffs"

check_file() {
    local file=$1
    local description=$2

    if [ -f "${HANDOFFS_DIR}/${file}" ]; then
        echo "✅ ${description} exists"
        ls -lh "${HANDOFFS_DIR}/${file}"
    else
        echo "❌ ${description} NOT FOUND"
        return 1
    fi
}

# Wait for Phase 2 to complete (interview)
echo "⏳ Waiting for Phase 2 (Interview) to complete..."
sleep 5

check_file "002-prd-interview.md" "Interview handoff"
echo ""

# Wait for Phase 3 to auto-trigger and complete (PRD synthesis)
echo "⏳ Waiting for Phase 3 (PRD Synthesis) to auto-complete..."
echo "   (This may take 1-2 minutes for quality model)"
sleep 120

check_file "003-prd-refined.md" "PRD handoff"
echo ""

# Wait for Phase 4 to auto-trigger and complete (Council review)
echo "⏳ Waiting for Phase 4 (Council Review) to auto-complete..."
echo "   (This may take 1-2 minutes for council reviewers)"
sleep 120

check_file "004-council-review.md" "Council review handoff"
echo ""

# Step 4: Validate file contents
echo "📋 Step 4: Validating handoff file contents..."
echo ""

validate_content() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "${pattern}" "${HANDOFFS_DIR}/${file}"; then
        echo "✅ ${description}"
    else
        echo "❌ ${description} - pattern not found"
        return 1
    fi
}

# Validate interview handoff
validate_content "002-prd-interview.md" "# Interview Transcript" "Interview has header"
validate_content "002-prd-interview.md" "${PROJECT_NAME}" "Interview mentions project name"

# Validate PRD handoff
validate_content "003-prd-refined.md" "# Product Requirements Document" "PRD has header"
validate_content "003-prd-refined.md" "## Overview" "PRD has overview section"

# Validate council review
validate_content "004-council-review.md" "# Council Review" "Council review has header"
validate_content "004-council-review.md" "## Verdict" "Council review has verdict"

echo ""
echo "✅ Auto-chaining test complete!"
echo ""
echo "📁 All artifacts created in: ${PROJECT_DIR}/handoffs/"
echo ""
echo "🔍 To inspect the results:"
echo "   ls -lh ${HANDOFFS_DIR}"
echo "   cat ${HANDOFFS_DIR}/002-prd-interview.md"
echo "   cat ${HANDOFFS_DIR}/003-prd-refined.md"
echo "   cat ${HANDOFFS_DIR}/004-council-review.md"
