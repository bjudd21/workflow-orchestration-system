#!/bin/bash
# Verify that auto-chaining modifications are present in workflow files

set -e

echo "🔍 Verifying auto-chaining modifications..."
echo ""

WORKFLOWS_DIR="workflows"
PASS=0
FAIL=0

check_pattern() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "${pattern}" "${WORKFLOWS_DIR}/${file}"; then
        echo "✅ ${description}"
        ((PASS++))
    else
        echo "❌ ${description}"
        ((FAIL++))
    fi
}

# Phase 2 checks
echo "📋 Phase 2: Interview Workflow"
check_pattern "phase-2-interview-refactored.json" "HTTP Request - Trigger Phase 3" "Phase 3 trigger node exists"
check_pattern "phase-2-interview-refactored.json" "prd-synthesis-action" "Phase 3 webhook URL present"
check_pattern "phase-2-interview-refactored.json" '"action": "synthesize"' "Synthesize action parameter present"
echo ""

# Phase 3 checks
echo "📋 Phase 3: PRD Synthesis Workflow"
check_pattern "phase-3-prd-synthesis.json" "Code - Write Handoff Copy" "Handoff copy node exists"
check_pattern "phase-3-prd-synthesis.json" "003-prd-refined.md" "Handoff file path present"
check_pattern "phase-3-prd-synthesis.json" "HTTP Request - Trigger Phase 4" "Phase 4 trigger node exists"
check_pattern "phase-3-prd-synthesis.json" "council-review-action" "Phase 4 webhook URL present"
check_pattern "phase-3-prd-synthesis.json" '"action": "review"' "Review action parameter present"
echo ""

# Phase 4 checks
echo "📋 Phase 4: Council Review Workflow"
check_pattern "phase-4-council-review-fixed.json" '"artifacts"' "Artifacts object in response"
check_pattern "phase-4-council-review-fixed.json" "002-prd-interview.md" "Interview artifact path present"
check_pattern "phase-4-council-review-fixed.json" "003-prd-refined.md" "PRD artifact path present"
check_pattern "phase-4-council-review-fixed.json" "004-council-review.md" "Council review artifact path present"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ All auto-chaining modifications verified!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Import updated workflows to n8n:"
    echo "   - Workflows → Import from File"
    echo "   - Select each workflow JSON file"
    echo "   - Click 'Save' to activate"
    echo ""
    echo "2. Verify all workflows are activated:"
    echo "   - phase-2-interview-refactored"
    echo "   - phase-3-prd-synthesis"
    echo "   - phase-4-council-review-fixed"
    echo ""
    echo "3. Test end-to-end:"
    echo "   ./scripts/test-auto-chaining.sh"
    echo ""
    exit 0
else
    echo "❌ Some modifications are missing!"
    echo ""
    echo "🔧 To re-apply modifications:"
    echo "   python3 scripts/add-auto-chaining.py"
    echo ""
    exit 1
fi
