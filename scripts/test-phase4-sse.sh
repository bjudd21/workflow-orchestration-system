#!/bin/bash

# Test Phase 4 SSE Emissions
# This script validates that the SSE server receives proper payloads from Phase 4

set -e

PROJECT="test-sse-$(date +%s)"

echo "======================================"
echo "Phase 4 SSE Emission Test"
echo "======================================"
echo ""

# Check SSE server health
echo "[1/4] Checking SSE server..."
HEALTH=$(curl -s http://localhost:3001/health)
if echo "$HEALTH" | grep -q '"status":"healthy"'; then
  echo "✓ SSE server is healthy"
else
  echo "✗ SSE server not responding"
  exit 1
fi
echo ""

# Start SSE listener in background
echo "[2/4] Starting SSE listener..."
echo "Listening for events on project: $PROJECT"
echo ""

# Create a named pipe for SSE events
PIPE="/tmp/sse-test-$$"
mkfifo "$PIPE"

# Start SSE connection in background
curl -sN "http://localhost:3001/events/$PROJECT" > "$PIPE" &
SSE_PID=$!

# Give it a moment to connect
sleep 2

echo "[3/4] Triggering Phase 4 council review..."
echo "Project: $PROJECT"
echo ""

# Trigger the review (will fail if no PRD exists, but SSE should still emit events)
RESPONSE=$(curl -s -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d "{\"project\":\"$PROJECT\",\"action\":\"review\"}" \
  2>&1 || echo "Expected failure")

echo "Workflow triggered (may fail due to missing PRD, that's OK for this test)"
echo ""

echo "[4/4] Waiting 10 seconds for SSE events..."
echo "Press Ctrl+C to stop early"
echo ""

# Read events for 10 seconds
timeout 10 cat "$PIPE" | while IFS= read -r line; do
  if [[ "$line" =~ ^data:.*reviewer ]]; then
    echo "✓ Received reviewer event:"
    echo "  $line"
  elif [[ "$line" =~ ^data:.*verdict ]]; then
    echo "✓ Received complete event:"
    echo "  $line"
  fi
done || true

# Cleanup
kill $SSE_PID 2>/dev/null || true
rm -f "$PIPE"

echo ""
echo "======================================"
echo "Test Complete"
echo "======================================"
echo ""
echo "If you saw '✓ Received reviewer event' messages above,"
echo "the SSE emissions are working correctly!"
echo ""
echo "If no events appeared, check:"
echo "  1. Phase 4 workflow has been updated with fixed emission nodes"
echo "  2. docker logs workflow-orchestration-sse"
echo "  3. n8n execution logs for the review workflow"
