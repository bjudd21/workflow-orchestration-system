# Workflow Orchestration System

A phase-based, multi-agent workflow that transforms a project idea into a council-reviewed PRD, structured task list, and GitHub Issues — using local Ollama inference with no API keys required.

**Status**: True MVP in progress — Phase 2 (Interview), Phase 3 (Synthesis), and Phase 4 (Council Review) complete and tested.

---

## How It Works

```
Phase 2: PRD Interview      → Conversational requirements gathering (webhook chat UI)
         ↓ (auto-chains)
Phase 3: PRD Synthesis      → Quality model synthesizes a full PRD from the interview
         ↓ (auto-chains)
Phase 4: Council Review     → 4 specialist agents review; chair synthesizes findings
         ↓
Phase 5: Task Generation    → PRD → structured task list + GitHub Issues
         ↓
Phase 6: Execution Tracking → Claude Code picks up tasks; PR review automation
```

**Auto-chaining**: Phase 2 automatically triggers Phase 3, which automatically triggers Phase 4. Real-time progress updates stream via Server-Sent Events (SSE) to connected clients.

Phases hand off via validated markdown artifacts stored in `workspace/{project}/handoffs/`.

---

## Quick Start

```bash
# First-time setup: checks prerequisites, pulls models, starts n8n
./setup.sh

# Subsequent runs
docker compose up -d

# Access n8n at http://localhost:5678
# SSE service (real-time updates) at http://localhost:3001
```

### Prerequisites

- WSL2 (Ubuntu) or Linux
- NVIDIA GPU with ≥18GB VRAM (RTX 4090, RTX 4080, or equivalent)
- Docker Desktop or Docker Engine + Compose
- Ollama with CUDA support (`ollama serve` running on host)
- ~40GB free disk space for model weights

---

## Phase 2: PRD Interview

Phase 2 is the first working phase. Open the chat UI in a browser:

```
http://localhost:5678/webhook/prd-interview
```

Enter a project name, then start typing. The interviewer asks one question at a time across 8 coverage areas (problem, users, features, scope, NFRs, compliance, tech constraints, timeline). When all areas are covered, it signals completion, extracts structured requirements, and writes the handoff file.

**Handoff output**: `workspace/{project-name}/handoffs/002-prd-interview.md`

To restart or reset an interview, delete `workspace/{project-name}/interview-state.json`.

---

## Phase 3: PRD Synthesis

Phase 3 takes the interview handoff and synthesizes a complete PRD. **It automatically triggers when Phase 2 completes** (or can be triggered manually via webhook).

**Input**: `workspace/{project}/handoffs/002-prd-interview.md`
**Output**: `workspace/{project}/handoffs/003-prd-refined.md`

The synthesis uses the quality model to produce a structured PRD with:
- Executive Summary
- Functional Requirements (FR-1, FR-2, etc.)
- Non-Functional Requirements (NFR-1, NFR-2, etc.)
- User Stories
- Architecture overview
- Risk Assessment
- MVP Definition

**Real-time updates**: Progress events (0%, 50%, 100%) stream via SSE to `http://localhost:3001/events/{project-id}/phase3/progress`

---

## Phase 4: Council Review

Phase 4 runs a 5-agent council review of the synthesized PRD. **It automatically triggers when Phase 3 completes** (or can be triggered manually via webhook).

**4 Core Reviewers** (run in parallel):
1. **Technical Reviewer** — Challenges technical feasibility and architecture
2. **Security Reviewer** — Identifies security risks and compliance gaps
3. **Executive Reviewer** — Ensures business value and ROI alignment
4. **User Advocate** — Champions end-user experience and usability

**Council Chair** — Synthesizes all reviewer feedback into consensus points, conflicts, and a unified verdict.

**Trigger via webhook** (manual):
```bash
curl -X POST http://localhost:5678/webhook/council-review-action \
  -H "Content-Type: application/json" \
  -d '{"project":"your-project-name","action":"review"}'
```

**Response includes**:
- All reviewer outputs (5 detailed assessments)
- Council Chair synthesis (consensus + conflicts)
- Overall verdict: APPROVED / APPROVED WITH CONCERNS / REVISE AND RESUBMIT
- Required revisions (if any)

**Execution time**: ~2 minutes (5 LLM calls with single model)

**Real-time updates**: Each reviewer completion streams via SSE to `http://localhost:3001/events/{project-id}/phase4/reviewer` and `phase4/complete`

---

## Model Configuration

**MVP uses a single model** to avoid GPU memory swapping on 24GB cards:

| Model | VRAM | Used for |
|-------|------|----------|
| `qwen3.5:35b-a3b` | ~18GB | All phases (interview, synthesis, council reviewers + chair) |

Pull the model before running:
```bash
ollama pull qwen3.5:35b-a3b
```

The setup script handles this automatically. Future Full MVP will use two models (speed + quality) with proper model swapping.

---

## Project Structure

```
workflows/          ← Exported n8n workflow JSON (version-controlled)
prompts/            ← Agent system prompts, organized by phase
  prd-development/  ← prd-interviewer.md, prd-writer.md
  prd-council/      ← core/ (5 agents) + specialized/ (6 agents)
  critics-council/  ← adversarial feasibility reviewers (Phase 5.5)
  pm-framework/     ← task decomposition and issue generation
  task-execution/   ← implementation and code review agents
skills/             ← Skill context documents paired with agents
contracts/          ← Handoff validation schemas (markdown)
services/           ← Supporting services
  sse-broadcast/    ← Server-Sent Events broadcast service (Express.js)
workspace/          ← Runtime project workspaces (gitignored)
  {project-name}/
    handoffs/       ← Phase output artifacts (002-prd-interview.md, etc.)
    tasks/          ← Generated task lists
    diagrams/       ← Mermaid architecture/flow diagrams
    config/         ← project.json, decisions.json
    interview-state.json
```

---

## Build Status

| Task | Status |
|------|--------|
| 1.0 Docker infrastructure + scaffold | ✅ Complete |
| 2.0 Core agent prompts (7 agents) | ✅ Complete |
| 3.0 Core skills + handoff contracts | ✅ Complete |
| 4.0 Phase 2: PRD Interview workflow | ✅ Complete — live and tested |
| 5.0 Phase 3: PRD Synthesis workflow | ✅ Complete — live and tested |
| 6.0 Phase 4: Council Review workflow | ✅ Complete — live and tested (5 reviewers) |
| 7.0 SSE real-time event broadcasting | ✅ Complete — Phase 3 & 4 events |
| 8.0 Auto-chaining (Phase 2→3→4) | ✅ Complete — tested end-to-end |
| 9.0 Enhanced Frontend UI (HTMX + Alpine) | 🔨 Next |

---

## Architecture Notes

- **Ollama runs on the host**, not in Docker. Accessed from n8n container via `host.docker.internal:11434`.
- **File I/O** in Code nodes uses `require('fs')` — works in self-hosted n8n despite validator warnings.
- **Single model for MVP**: Using qwen3.5:35b-a3b for all LLM calls to avoid GPU memory issues. Model swapping deferred to Full MVP.
- **State persistence**: Conversation state is stored as JSON in `workspace/{project}/interview-state.json`. Restarting n8n or Docker does not lose state.
- **Handoff validation**: Each phase validates its output against schemas in `contracts/` before writing the handoff file.
- **Auto-chaining**: Phase 2 automatically POSTs to Phase 3 webhook on completion; Phase 3 automatically POSTs to Phase 4 webhook after writing the handoff file. No manual triggering required.
- **Real-time updates**: SSE broadcast service (Express.js on port 3001) receives events from n8n workflows via HTTP POST and streams them to connected browsers. Supports reconnection with `Last-Event-ID` for missed events.

---

## License

MIT
