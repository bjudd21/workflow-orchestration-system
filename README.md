# Workflow Orchestration System

A phase-based, multi-agent framework that transforms project ideas into production-ready PRDs with council review, actionable task lists, and GitHub Issues.

**Status**: True MVP in development (Weeks 1-2)

## Quick Start

```bash
# First-time setup (checks prerequisites, pulls models, starts services)
./setup.sh

# Subsequent runs
docker compose up -d
# Open http://localhost:5678
```

## Prerequisites

- Windows with WSL2 (Ubuntu)
- NVIDIA GPU with ≥24GB VRAM (RTX 4090 or equivalent)
- Docker Desktop or Docker Engine + Compose
- Ollama with GPU support
- ~40GB free disk space for model weights

## Project Structure

```
workflows/          ← Exported n8n workflow JSON
prompts/            ← Agent system prompts (markdown)
skills/             ← Skill context documents (markdown)
contracts/          ← Handoff validation schemas
workspace/          ← Project workspaces (runtime, gitignored)
```

See `prd-workflow-system-v3.md` for full documentation.

## License

MIT
