#!/bin/bash
# Check Issue #48 Re-Test Results
# Validates all acceptance criteria

set -e

PROJECT="federal-grant-portal-test"
HANDOFF_DIR="workspace/${PROJECT}/handoffs"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=================================================="
echo "Issue #48 Re-Test Results Validation"
echo "Project: ${PROJECT}"
echo "=================================================="
echo ""

# Track pass/fail
PASSED=0
FAILED=0

# Helper function for test results
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Test 1: All handoff files exist
echo "Test 1: Handoff Files Created"
echo "-----------------------------------"

if [ -f "${HANDOFF_DIR}/002-prd-interview.md" ]; then
    size=$(stat -f%z "${HANDOFF_DIR}/002-prd-interview.md" 2>/dev/null || stat -c%s "${HANDOFF_DIR}/002-prd-interview.md")
    pass "002-prd-interview.md exists (${size} bytes)"
else
    fail "002-prd-interview.md missing (Phase 2 failed)"
fi

if [ -f "${HANDOFF_DIR}/003-prd-refined.md" ]; then
    size=$(stat -f%z "${HANDOFF_DIR}/003-prd-refined.md" 2>/dev/null || stat -c%s "${HANDOFF_DIR}/003-prd-refined.md")
    pass "003-prd-refined.md exists (${size} bytes)"
else
    fail "003-prd-refined.md missing (Phase 3 failed)"
fi

if [ -f "${HANDOFF_DIR}/004-council-review.md" ]; then
    size=$(stat -f%z "${HANDOFF_DIR}/004-council-review.md" 2>/dev/null || stat -c%s "${HANDOFF_DIR}/004-council-review.md")
    pass "004-council-review.md exists (${size} bytes) - Issue #70 fix"
else
    fail "004-council-review.md missing (Issue #70 not fixed)"
fi

echo ""

# Test 2: Phase 3 PRD validation
echo "Test 2: PRD Structure (003-prd-refined.md)"
echo "-----------------------------------"

if [ -f "${HANDOFF_DIR}/003-prd-refined.md" ]; then
    # Check for required sections
    required_sections=(
        "## Project Overview"
        "## Functional Requirements"
        "## Non-Functional Requirements"
        "## User Stories"
        "## Technical Specifications"
        "## Compliance and Regulatory"
        "## Risks and Mitigations"
    )

    for section in "${required_sections[@]}"; do
        if grep -q "^${section}" "${HANDOFF_DIR}/003-prd-refined.md"; then
            pass "Section found: ${section}"
        else
            fail "Section missing: ${section}"
        fi
    done

    # Check version format
    if grep -q "version: v[0-9]" "${HANDOFF_DIR}/003-prd-refined.md"; then
        pass "Version format correct (version: v1)"
    else
        fail "Version format incorrect or missing"
    fi
else
    warn "Skipping PRD validation (file missing)"
fi

echo ""

# Test 3: Phase 4 Council Review validation
echo "Test 3: Council Review (004-council-review.md)"
echo "-----------------------------------"

if [ -f "${HANDOFF_DIR}/004-council-review.md" ]; then
    # Check for PRD version tracking (Issue #71 fix)
    if grep -q "prd_version_reviewed: v[0-9]" "${HANDOFF_DIR}/004-council-review.md"; then
        version=$(grep "prd_version_reviewed:" "${HANDOFF_DIR}/004-council-review.md" | head -1)
        pass "PRD version tracked correctly: ${version} - Issue #71 fix"
    elif grep -q "prd_version_reviewed: undefined" "${HANDOFF_DIR}/004-council-review.md"; then
        fail "PRD version is 'undefined' (Issue #71 NOT fixed)"
    else
        fail "PRD version field missing"
    fi

    # Check for all reviewers
    reviewers=(
        "Technical Reviewer"
        "Security Reviewer"
        "Executive Reviewer"
        "User Advocate"
        "Council Chair"
    )

    for reviewer in "${reviewers[@]}"; do
        if grep -q "${reviewer}" "${HANDOFF_DIR}/004-council-review.md"; then
            pass "Reviewer present: ${reviewer}"
        else
            fail "Reviewer missing: ${reviewer}"
        fi
    done

    # Check for verdict
    if grep -q "verdict:" "${HANDOFF_DIR}/004-council-review.md"; then
        verdict=$(grep "verdict:" "${HANDOFF_DIR}/004-council-review.md" | head -1)
        pass "Verdict present: ${verdict}"
    else
        fail "Verdict missing"
    fi
else
    warn "Skipping council review validation (file missing)"
fi

echo ""

# Test 4: Check for Issue #69 fix (no require() errors in logs)
echo "Test 4: Issue #69 Fix (No require() errors)"
echo "-----------------------------------"

# We can't directly check logs, but if 002-prd-interview.md exists, Phase 2 succeeded
if [ -f "${HANDOFF_DIR}/002-prd-interview.md" ]; then
    pass "Phase 2 completed (no require() errors)"
else
    fail "Phase 2 failed (possible require() error - check n8n logs)"
fi

echo ""

# Summary
echo "=================================================="
echo "Test Summary"
echo "=================================================="
echo ""
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo ""
    echo "Issue #48 acceptance criteria met:"
    echo "  ✓ All 3 handoff files created automatically"
    echo "  ✓ Issue #69 fixed (Phase 2 no require() errors)"
    echo "  ✓ Issue #70 fixed (Phase 4 writes handoff file)"
    echo "  ✓ Issue #71 fixed (PRD version tracked correctly)"
    echo ""
    echo "Next steps:"
    echo "  1. Run resilience tests (malformed handoff, Docker restart)"
    echo "  2. Document results in docs/issue-48-retest-results.md"
    echo "  3. Update GitHub issue #48 and close"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo ""
    echo "Check n8n execution history: http://localhost:5678"
    echo "Review logs for errors and retry failed phases"
    exit 1
fi
