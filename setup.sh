#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Workflow Orchestration System — First-Time Setup
# ============================================================
# Checks prerequisites, pulls Ollama models, starts services.
# Run once after cloning. Subsequent runs: docker compose up -d

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Workflow Orchestration System — Setup           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0

# ---- Check prerequisites ----

echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

# Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
    echo -e "  ${GREEN}✓${NC} Docker ${DOCKER_VERSION}"
else
    echo -e "  ${RED}✗${NC} Docker not found. Install Docker Desktop or Docker Engine."
    ERRORS=$((ERRORS + 1))
fi

# Docker Compose
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
    echo -e "  ${GREEN}✓${NC} Docker Compose ${COMPOSE_VERSION}"
elif command -v docker-compose &> /dev/null; then
    echo -e "  ${YELLOW}!${NC} Found docker-compose (v1). docker compose (v2) is recommended."
else
    echo -e "  ${RED}✗${NC} Docker Compose not found."
    ERRORS=$((ERRORS + 1))
fi

# Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | grep -oP '\d+\.\d+\.\d+')
    echo -e "  ${GREEN}✓${NC} Git ${GIT_VERSION}"
else
    echo -e "  ${RED}✗${NC} Git not found."
    ERRORS=$((ERRORS + 1))
fi

# gh CLI (needed for Phase 6, optional for True MVP)
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1 | grep -oP '\d+\.\d+\.\d+')
    echo -e "  ${GREEN}✓${NC} GitHub CLI ${GH_VERSION}"
else
    echo -e "  ${YELLOW}!${NC} GitHub CLI not found. Optional for True MVP, required for Full MVP (Phase 5-6)."
fi

# Ollama
if command -v ollama &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Ollama installed"
else
    echo -e "  ${RED}✗${NC} Ollama not found. Install: curl -fsSL https://ollama.com/install.sh | sh"
    ERRORS=$((ERRORS + 1))
fi

# NVIDIA GPU
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    echo -e "  ${GREEN}✓${NC} GPU: ${GPU_NAME} (${GPU_VRAM})"
else
    echo -e "  ${YELLOW}!${NC} nvidia-smi not found. GPU acceleration may not work."
fi

echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Found ${ERRORS} missing prerequisite(s). Please install them and re-run setup.${NC}"
    exit 1
fi

# ---- Check Ollama service ----

echo -e "${BLUE}Checking Ollama service...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Ollama is running"
else
    echo -e "  ${YELLOW}!${NC} Ollama is not running. Starting..."
    ollama serve &> /dev/null &
    sleep 3
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Ollama started"
    else
        echo -e "  ${RED}✗${NC} Failed to start Ollama. Start it manually: ollama serve"
        exit 1
    fi
fi
echo ""

# ---- Pull models ----

SPEED_MODEL="qwen3.5:35b-a3b"
QUALITY_MODEL="qwen3.5:35b"

echo -e "${BLUE}Checking required models...${NC}"
echo -e "  Speed model:   ${SPEED_MODEL} (~18GB MoE)"
echo -e "  Quality model: ${QUALITY_MODEL} (~23GB)"
echo ""

EXISTING_MODELS=$(ollama list 2>/dev/null | awk '{print $1}' || echo "")

pull_if_needed() {
    local model=$1
    local desc=$2
    if echo "$EXISTING_MODELS" | grep -q "^${model}"; then
        echo -e "  ${GREEN}✓${NC} ${desc} (${model}) already pulled"
    else
        echo -e "  ${YELLOW}↓${NC} Pulling ${desc} (${model})... this may take a while."
        ollama pull "$model"
        echo -e "  ${GREEN}✓${NC} ${desc} pulled"
    fi
}

pull_if_needed "$SPEED_MODEL" "Speed model"
pull_if_needed "$QUALITY_MODEL" "Quality model"
echo ""

# ---- Create .env if needed ----

if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env from .env.example...${NC}"
    cp .env.example .env
    # Generate a random encryption key
    RANDOM_KEY=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | xxd -p | tr -d '\n' | head -c 64)
    sed -i "s/generate-a-random-string-here/${RANDOM_KEY}/" .env
    echo -e "  ${GREEN}✓${NC} .env created with random encryption key"
    echo -e "  ${YELLOW}!${NC} Update N8N_BASIC_AUTH_PASSWORD in .env before production use"
else
    echo -e "  ${GREEN}✓${NC} .env already exists"
fi
echo ""

# ---- Start services ----

echo -e "${BLUE}Starting services...${NC}"
docker compose up -d
echo ""

# ---- Wait for n8n ----

echo -e "${BLUE}Waiting for n8n to be ready...${NC}"
for i in $(seq 1 30); do
    if curl -s http://localhost:5678 > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} n8n is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "  ${RED}✗${NC} n8n failed to start. Check: docker compose logs n8n"
        exit 1
    fi
    sleep 2
done
echo ""

# ---- Done ----

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup complete!                                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Open n8n:  ${BLUE}http://localhost:5678${NC}"
echo -e "  Username:  admin"
echo -e "  Password:  (see .env)"
echo ""
echo -e "  Next steps:"
echo -e "  1. Open n8n in your browser"
echo -e "  2. Import the interview workflow (workflows/phase-2-interview.json)"
echo -e "  3. Start your first interview"
echo ""
echo -e "  To stop:   ${YELLOW}docker compose down${NC}"
echo -e "  To restart: ${YELLOW}docker compose up -d${NC}"
echo ""
