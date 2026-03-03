#!/bin/bash
set -e

PROJECT="test-council-review"
WORKSPACE_DIR="/home/bjudd/projects/PRDWorkflowSystem/workflow-orchestration-system-scaffold/workspace"

echo "=== Phase 4 Review Flow Test ==="
echo

# Create test workspace structure
echo "1. Setting up test project workspace..."
mkdir -p "$WORKSPACE_DIR/$PROJECT/handoffs"
mkdir -p "$WORKSPACE_DIR/$PROJECT/tasks"

# Create minimal PRD handoff file (required by Read - PRD File node)
PRD_FILE="$WORKSPACE_DIR/$PROJECT/handoffs/003-prd-refined.md"
cat > "$PRD_FILE" << 'EOF'
---
project: test-council-review
version: v1
date: 2026-03-02
status: refined
---

# Product Requirements Document: Test Council Review

## Overview
This is a test PRD for validating the Phase 4 council review workflow.

## Features
- Test Feature 1: Basic functionality
- Test Feature 2: Core validation

## Technical Requirements
- Must validate node reference fixes
- Must complete council review without errors

## Success Criteria
- Council review completes in < 20 minutes
- No node reference errors
- All 4 reviewers + chair execute successfully
EOF

echo "   ✓ Created $PRD_FILE"

# Test webhook accessibility first
echo
echo "2. Testing webhook accessibility..."
WEBHOOK_URL="http://localhost:5678/webhook/council-review-action"

if curl -s -f -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"project":"'$PROJECT'","action":"review"}' > /tmp/phase4-test-response.json 2>&1; then

    echo "   ✓ Webhook responded"
    echo
    echo "3. Response:"
    cat /tmp/phase4-test-response.json | jq '.' 2>/dev/null || cat /tmp/phase4-test-response.json
else
    echo "   ✗ Webhook call failed"
    echo
    echo "Error output:"
    cat /tmp/phase4-test-response.json
    exit 1
fi
