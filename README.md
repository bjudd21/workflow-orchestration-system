# ⚠️ This project has been archived

**Active development has moved to [Project Forge](https://github.com/bjudd21/project-forge)** — a SaaS web application that evolved from this reference implementation.

The agent prompts, skill documents, handoff contracts, and pipeline patterns from this repo have been ported to the new project. This repo is preserved as a reference implementation of the original n8n + Ollama architecture.

---

# Workflow Orchestration System (Archived)

A phase-based, multi-agent workflow that transforms a project idea into a council-reviewed PRD, structured task list, and GitHub Issues — using local Ollama inference with no API keys required.

**Final status**: True MVP complete — Phase 2 (Interview), Phase 3 (Synthesis), and Phase 4 (Council Review) working end-to-end with auto-chaining.

## What was built

```
Phase 2: PRD Interview      → Conversational requirements gathering (webhook chat UI)
         ↓ (auto-chains)
Phase 3: PRD Synthesis      → Quality model synthesizes a full PRD from the interview
         ↓ (auto-chains)
Phase 4: Council Review     → 4 specialist agents review; chair synthesizes findings
```

- 7 agent system prompts (interviewer, PRD writer, 4 reviewers, council chair)
- 10 skill documents (requirements engineering, security review, compliance, etc.)
- 3 handoff contract schemas with validation
- n8n workflow orchestration with Ollama (qwen3.5:35b-a3b on RTX 4090)
- SSE real-time event broadcasting
- Auto-chaining across phases (~9-10 minutes end-to-end)

## What moved to Project Forge

| Asset | WOS Location | Project Forge Location |
|-------|-------------|----------------------|
| Agent prompts | `prompts/` | `content/prompts/` |
| Skill documents | `skills/` | `content/skills/` |
| Handoff contracts | `contracts/` | `content/contracts/` |
| Pipeline pattern | n8n workflows | TypeScript state machine |
| LLM inference | Ollama (local) | Anthropic API (cloud) |
| Frontend | HTMX/Alpine | React/TypeScript |

## Why it was archived

WOS proved the multi-agent PRD pipeline concept on local hardware. Project Forge takes the same agent architecture and ships it as a SaaS product:

- **Distribution**: Web app (sign up and use) vs. Docker + Ollama + GPU setup
- **Target user**: IT managers and non-developer business users
- **Revenue model**: $29/mo Pro tier with cloud inference
- **New capabilities**: Revision loop (council feedback → PRD revision → re-review)

The agent prompts and pipeline design are the real IP — the n8n execution layer was always an implementation detail.

## Running locally (if needed)

This still works if you have the prerequisites:

```bash
# Prerequisites: WSL2/Linux, NVIDIA GPU ≥18GB VRAM, Docker, Ollama
./setup.sh
docker compose up -d
# Access n8n at http://localhost:5678
```

See the original README sections below for full documentation.

---

## Original Documentation

<details>
<summary>Click to expand full original README</summary>

### Quick Start

```
./setup.sh
docker compose up -d
```

### Prerequisites

* WSL2 (Ubuntu) or Linux
* NVIDIA GPU with ≥18GB VRAM (RTX 4090, RTX 4080, or equivalent)
* Docker Desktop or Docker Engine + Compose
* Ollama with CUDA support
* ~40GB free disk space for model weights

### Model Configuration

| Model | VRAM | Used for |
| --- | --- | --- |
| `qwen3.5:35b-a3b` | ~18GB | All phases (interview, synthesis, council reviewers + chair) |

### Project Structure

```
workflows/          ← Exported n8n workflow JSON
prompts/            ← Agent system prompts, organized by phase
skills/             ← Skill context documents paired with agents
contracts/          ← Handoff validation schemas
services/           ← SSE broadcast service
workspace/          ← Runtime project workspaces (gitignored)
```

### Architecture Notes

* Ollama runs on the host, not in Docker
* File I/O in Code nodes uses `require('fs')` — works in self-hosted n8n
* Single model for MVP to avoid GPU memory swapping
* Handoff validation against schemas in `contracts/`
* Auto-chaining: Phase 2 → 3 → 4 without manual triggering

</details>

## License

MIT
