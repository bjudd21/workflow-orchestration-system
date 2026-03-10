# PRDWorkflowSystem

## Purpose

Multi-agent workflow orchestration system that automates: project analysis → PRD development → council review → task generation → GitHub Issues creation → execution tracking.

## Status

True MVP in implementation. PRD v3.5 is finalized. Scaffold structure exists; core n8n workflows, agent prompts, and skill documents still need to be built.

## Stack

n8n (Docker) + Ollama (local GPU inference) + file-based artifact storage. No Python, no traditional compilation — this is workflow automation.

## Commands

```bash
# First-time setup (checks prerequisites, pulls ~39GB of models, starts n8n)
./setup.sh

# Subsequent starts
docker compose up -d

# Access n8n UI
http://localhost:5678   # creds in .env

# Validate environment
nvidia-smi                # Check GPU memory
ollama list               # Should show qwen3.5:35b and qwen3.5:35b-a3b
```

Ollama runs as a **host service** (not in Docker), accessed via `host.docker.internal:11434`. Never add Ollama to docker-compose.

## Architecture

```
PRDWorkflowSystem/
├── docs/
│   ├── prd-workflow-system-v3.md      # Full PRD (source of truth)
│   ├── tasks-prd-workflow-system-v3.md # Implementation task list
│   └── council-review-prd-v3.4.md     # Council feedback log
├── docker-compose.yml                 # Single n8n service
├── setup.sh                           # First-time setup
├── .env.example                       # All config vars documented here
├── prompts/                           # Agent system prompts (by phase)
├── skills/                            # Skill/knowledge docs for agents
├── workflows/                         # n8n exported workflow JSON
├── contracts/                         # Handoff validation schemas
└── workspace/                         # Runtime artifacts (gitignored)
```

Runtime workspace per project:

```
workspace/{project-name}/
├── handoffs/              # Phase outputs (001-analysis.md, 002-prd-interview.md, etc.)
├── tasks/                 # Generated task lists + completion records
├── diagrams/              # Mermaid diagrams (architecture, dataflow, auth-flow)
├── config/                # project.json, decisions.json
└── interview-state.json
```

## The 6-Phase Pipeline

Each phase is an n8n workflow. Phases hand off via structured markdown validated against JSON schemas in `contracts/`.

| Phase | Name                                     | Model                     |
| ----- | ---------------------------------------- | ------------------------- |
| 1     | Codebase Analysis                        | Speed                     |
| 2     | PRD Interview (webhook chat)             | Speed                     |
| 3     | PRD Synthesis                            | Quality                   |
| 4     | Council Review (4-9 reviewers + chair)   | Speed → Quality (chair)   |
| 4.5   | PM Destination Selection                 | —                         |
| 5     | Task Generation → GitHub Issues          | Speed                     |
| 5.5   | Feasibility / Critics Council (optional) | Speed → Quality           |
| 6     | Execution Tracking                       | Hybrid: n8n + Claude Code |

## Model Strategy (GPU Memory Critical)

Two models, **cannot run simultaneously** on RTX 4090 (24GB VRAM):

| Model   | ID                | VRAM  | Speed        | Use                            |
| ------- | ----------------- | ----- | ------------ | ------------------------------ |
| Speed   | `qwen3.5:35b-a3b` | ~18GB | ~40-60 tok/s | Conversational, parallel steps |
| Quality | `qwen3.5:35b`     | ~23GB | ~24-32 tok/s | Synthesis, judgment            |

**Swap takes 15-30 seconds.** Workflows batch all speed-model calls before swapping to quality once (e.g., all 4 reviewers, then chair).

LLM calls use 300s timeout, 3 retries with exponential backoff, pre-flight connectivity check.

## Agent Architecture

26+ specialized agents, each consisting of:

1. A **system prompt** in `prompts/{phase}/agent-name.md`
2. One or more **skill documents** in `skills/{phase}/skill-name.md`

Both assembled by n8n into LLM call context at runtime.

**Core agents for True MVP** (build first):

- `prompts/prd-development/interviewer.md`
- `prompts/prd-development/writer.md`
- `prompts/prd-council/core/` — 4 reviewers + chair

**Critics council** (`prompts/critics-council/`): Optional Phase 5.5. Adversarial mandate — find reasons the plan will fail, not endorse it.

## Project-Specific Conventions

- Agent prompts written in markdown; n8n reads them from mounted volume at runtime.
- PRD written at junior developer level — "what/why" not "how."
- Council reviewers produce 3-5 concerns/endorsements with severity + confidence ratings.
- GitHub Issues include an "AI Agent Notes" section for Claude Code execution context (objective, relevant files, existing patterns, acceptance criteria, commit format).
- Handoffs numbered sequentially: `001-analysis-complete.md`, `002-prd-interview.md`, etc.

## Key Files

@docs/prd-workflow-system-v3.md
@docs/tasks-prd-workflow-system-v3.md
@.env.example

## Success Criteria

End-to-end pipeline (interview → PRD → council → handoff artifacts):

- Council review < 20 minutes
- Zero context loss between phases
- All handoffs validate against schemas in `contracts/`
- n8n execution history captures full audit trail
- LLM timeouts handled gracefully (partial result preservation)

---

## n8n Workflow Development Notes

### File Operations: The Correct Pattern

**TL;DR**: For writing text files in n8n workflows, use Code nodes with `fs.writeFileSync`, NOT the readWriteFile node.

#### Problem Context

During Phase 4 (Council Review) workflow development, handoff files were not being created despite successful workflow executions. The workflow showed 29 nodes executed in ~2 minutes, but no file appeared on disk.

#### What Was Tried First (Wrong Approach)

Initial implementation used the `n8n-nodes-base.readWriteFile` node with `dataPropertyName` or `binaryPropertyName` parameters. This pattern did not work reliably for text content.

#### How the Solution Was Found

1. Used n8n MCP to look up readWriteFile node documentation
2. Examined other working file write operations in the same workflow
3. Discovered that ALL successful write operations used Code nodes with `fs.writeFileSync`
4. Examples found: "Write Binary File - Save Revised PRD" and "Write Binary File - Update Handoff"

#### The Correct Pattern (Proven)

```javascript
const fs = require('fs');
const d = $input.first().json;

// Create directory if needed
fs.mkdirSync(`/home/node/workspace/${d.project}/handoffs`, { recursive: true });

// Write the file
const handoffPath = `/home/node/workspace/${d.project}/handoffs/004-council-review.md`;
fs.writeFileSync(handoffPath, d.reviewText, 'utf8');

return [{ json: d }];
```

**Key elements:**
- Use `require('fs')` (works at runtime despite validator warnings)
- Use `mkdirSync` with `{ recursive: true }` to ensure directory exists
- Use `writeFileSync` with explicit `'utf8'` encoding
- Return the input data so the workflow can continue

#### When to Use This Pattern

Use Code nodes with `fs.writeFileSync` for:
- Markdown handoff files
- JSON config files
- Any text-based output that needs to persist between phases
- Files that must be guaranteed to exist on disk for subsequent operations

#### Workflow Connections Matter

Even with the correct write pattern, files won't be created if the write node is not connected in the execution flow. Verify that:
1. The write node receives input from the previous node
2. The write node's output connects to the next node in the flow
3. The node is not orphaned in the workflow graph

Example of incorrect (orphaned) connection:
```
"Code - Assemble Output" → "Emit Event" → "Respond"
// Write node exists but not in this path = never executes
```

Example of correct connection:
```
"Code - Assemble Output" → "Write File" → "Emit Event" → "Respond"
```

#### Environment Notes

- n8n version: 2.9.4
- Container environment: `NODE_FUNCTION_ALLOW_BUILTIN=fs,path`
- `require('fs')` works at runtime despite Code node validator warnings
- `process.env` does NOT work in Code nodes (sandbox restriction)
- All file paths must be absolute (e.g., `/home/node/workspace/...`)

**Validated in production:**
- Phase 2: Interview handoff (002-prd-interview.md)
- Phase 3: PRD synthesis handoff (003-prd-refined.md)
- Phase 4: Council review handoff (004-council-review.md)
