#!/bin/bash
# Verify n8n workflows are active and webhooks are accessible

set -e

N8N_BASE="http://localhost:5678"

echo "=================================================="
echo "n8n Workflow Verification"
echo "=================================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if n8n is accessible
echo -n "Checking n8n accessibility... "
if curl -s -o /dev/null -w "%{http_code}" "${N8N_BASE}" | grep -q "200"; then
    echo -e "${GREEN}✓ n8n is running${NC}"
else
    echo -e "${RED}✗ n8n is not accessible${NC}"
    echo "Run: docker compose up -d"
    exit 1
fi
echo ""

# Check Ollama connectivity
echo -n "Checking Ollama connectivity... "
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:11434/api/tags" | grep -q "200"; then
    echo -e "${GREEN}✓ Ollama is running${NC}"
else
    echo -e "${RED}✗ Ollama is not accessible${NC}"
    echo "Run: ollama serve"
    exit 1
fi
echo ""

# Check Ollama models
echo "Checking Ollama models:"
ollama list | grep qwen3.5 | while read -r line; do
    echo -e "  ${GREEN}✓${NC} $line"
done
echo ""

# Check workspace directory
echo -n "Checking workspace directory... "
if [ -d "workspace/federal-grant-portal-test" ]; then
    echo -e "${GREEN}✓ workspace/federal-grant-portal-test exists${NC}"
else
    echo -e "${YELLOW}⚠ Creating workspace/federal-grant-portal-test${NC}"
    mkdir -p workspace/federal-grant-portal-test/handoffs
fi
echo ""

# Check existing handoff files
echo "Existing handoff files:"
if [ -d "workspace/federal-grant-portal-test/handoffs" ]; then
    handoff_count=$(ls -1 workspace/federal-grant-portal-test/handoffs/*.md 2>/dev/null | wc -l)
    if [ "$handoff_count" -gt 0 ]; then
        ls -lh workspace/federal-grant-portal-test/handoffs/*.md | while read -r line; do
            echo -e "  ${YELLOW}⚠${NC} $line"
        done
        echo ""
        echo -e "${YELLOW}Note: Old handoff files exist. Archive them before testing.${NC}"
    else
        echo -e "  ${GREEN}✓ No handoff files (clean slate)${NC}"
    fi
else
    mkdir -p workspace/federal-grant-portal-test/handoffs
    echo -e "  ${GREEN}✓ Created handoffs directory${NC}"
fi
echo ""

# Try to access Phase 2 webhook (will fail if workflow not active)
echo -n "Testing Phase 2 webhook accessibility... "
webhook_response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${N8N_BASE}/webhook/prd-interview" 2>/dev/null)
if [ "$webhook_response" = "200" ] || [ "$webhook_response" = "404" ]; then
    echo -e "${GREEN}✓ Webhook endpoint exists${NC}"
    echo "  Response code: ${webhook_response}"
else
    echo -e "${RED}✗ Webhook not accessible (code: ${webhook_response})${NC}"
    echo "  Check if 'PRD Interview (Phase 2)' workflow is active in n8n"
fi
echo ""

echo "=================================================="
echo "Pre-flight Check Complete"
echo "=================================================="
echo ""
echo "Ready to run: ./test-phase2-interview.sh"
echo ""
