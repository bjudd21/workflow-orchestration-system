# PRD Workflow System Documentation

**Status**: ✅ True MVP Complete (Phase 2→3→4 operational)
**Last Updated**: 2026-03-03

---

## 🚀 Quick Start

### Running the System
```bash
# First-time setup
./setup.sh

# Subsequent starts
docker compose up -d

# Access n8n UI
http://localhost:5678  # admin/changeme
```

### Running Tests
```bash
# Pre-flight checks
./verify-workflows.sh

# Run full Phase 2→3→4 test
./test-phase2-interview-simple.sh

# Validate results
./check-test-results.sh
```

---

## 📚 Core Documentation

### Getting Started
- **[TESTING-GUIDE.md](./TESTING-GUIDE.md)** - Complete testing guide with troubleshooting
- **[IMPORT-WORKFLOW-GUIDE.md](./IMPORT-WORKFLOW-GUIDE.md)** - How to import and deploy workflows

### Architecture & Standards
- **[architectural-decisions.md](./architectural-decisions.md)** - Key architectural decisions and rationale
- **[development-standards.md](./development-standards.md)** - Development patterns and conventions
- **[true-mvp-compliance-audit.md](./true-mvp-compliance-audit.md)** - Compliance requirements audit

### Status & Results
- **[TRUE-MVP-COMPLETE.md](./TRUE-MVP-COMPLETE.md)** - True MVP completion summary
- **[issue-48-retest-results.md](./issue-48-retest-results.md)** - Full integration test results (Issues #69, #70, #71 verified)

---

## 🏗️ System Architecture

### The 6-Phase Pipeline

| Phase | Name | Status | Models | Duration |
|-------|------|--------|--------|----------|
| 1 | Codebase Analysis | 🔜 Future | Speed | TBD |
| 2 | PRD Interview | ✅ Operational | Speed | ~5 min |
| 3 | PRD Synthesis | ✅ Operational | Quality | ~2 min |
| 4 | Council Review | ✅ Operational | Speed→Quality | ~2 min |
| 4.5 | PM Destination | 🔜 Future | — | TBD |
| 5 | Task Generation | 🔜 Future | Speed | TBD |
| 6 | Execution Tracking | 🔜 Future | Hybrid | TBD |

### Key Components

**Workflows** (n8n):
- `phase-2-interview-refactored.json` - PRD interview chat interface
- `phase-3-prd-synthesis.json` - PRD document generation
- `phase-4-council-review-fixed.json` - Multi-agent review council

**Agent Prompts** (`prompts/`):
- Organized by phase (e.g., `prompts/prd-development/interviewer.md`)
- Loaded at runtime by n8n workflows

**Skill Documents** (`skills/`):
- Domain knowledge for agents
- Referenced by agent prompts

**Handoff Files** (`workspace/{project}/handoffs/`):
- `002-prd-interview.md` - Interview transcript
- `003-prd-refined.md` - Synthesized PRD
- `004-council-review.md` - Council review output

---

## 🔧 Technical Details

### Model Strategy

Two models on RTX 4090 (24GB VRAM) - **cannot run simultaneously**:

- **Speed Model**: `qwen3.5:35b-a3b` (~18GB VRAM, 40-60 tok/s)
  - Used for: Interviews, parallel reviews, task generation

- **Quality Model**: `qwen3.5:35b` (~23GB VRAM, 24-32 tok/s)
  - Used for: PRD synthesis, council chair judgment

**Model swap**: 15-30 seconds between phases

### Handoff Contract

All handoff files follow strict schemas (see `contracts/`) with:
- YAML frontmatter (phase, version, metadata)
- Required sections validated before LLM calls
- Fail-fast validation (< 1 second rejection)

### Environment Variables

All config in `.env` (see `.env.example` for template):
```bash
OLLAMA_BASE_URL=http://host.docker.internal:11434
OLLAMA_SPEED_MODEL=qwen3.5:35b-a3b
OLLAMA_QUALITY_MODEL=qwen3.5:35b
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
```

---

## ✅ Verified Capabilities

**Phase 2: PRD Interview**
- ✅ Multi-turn conversational interview (7+ turns)
- ✅ Coverage tracking (8 areas)
- ✅ Automatic handoff creation
- ✅ No require() errors (Issue #69 fixed)

**Phase 3: PRD Synthesis**
- ✅ Quality model PRD generation
- ✅ 7 required sections (Overview, FRs, NFRs, USs, Tech, Compliance, Risks)
- ✅ Schema validation (3 FRs, 2 NFRs, 3 USs minimum)
- ✅ Version tracking (v1, v2, etc.)

**Phase 4: Council Review**
- ✅ 4 specialist reviewers + council chair
- ✅ Speed model → quality model handoff
- ✅ Automatic handoff creation (Issue #70 fixed)
- ✅ PRD version tracking (Issue #71 fixed)
- ✅ < 20-minute completion (NFR-1 compliance)

---

## 🐛 Known Issues

### Active Issues

**Issue #72: Phase 3 Version Numbering Mismatch**
- Severity: LOW
- Description: Synthesis creates v1, approval looks for v0
- Workaround: Manual handoff copy (does not block True MVP)

### Resolved Issues

- ✅ Issue #69: Phase 2 require() errors - FIXED (refactored workflow)
- ✅ Issue #70: Phase 4 handoff file not written - FIXED (auto-write added)
- ✅ Issue #71: PRD version undefined - FIXED (version tracking added)

---

## 📊 Performance Benchmarks

From Issue #48 integration test (2026-03-03):

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Council Review Time | < 20 min | ~2 min | ✅ 10x faster |
| Phase 2→3→4 Total | N/A | ~9 min | ✅ Excellent |
| Handoff Creation | Automatic | ✅ All 3 | ✅ Verified |

---

## 🔗 Quick References

### n8n API

**Generate API key**: http://localhost:5678 → Settings → API

```bash
# List workflows
curl -H "X-N8N-API-KEY: YOUR_KEY" \
  http://localhost:5678/api/v1/workflows

# Execute workflow
curl -H "X-N8N-API-KEY: YOUR_KEY" -X POST \
  http://localhost:5678/api/v1/workflows/{id}/execute

# Check execution status
curl -H "X-N8N-API-KEY: YOUR_KEY" \
  http://localhost:5678/api/v1/executions/{id}
```

### Webhook Endpoints

```bash
# Phase 2: Interview (GET for UI, POST for messages)
GET  http://localhost:5678/webhook/prd-interview
POST http://localhost:5678/webhook/prd-interview-send

# Phase 3: PRD Synthesis (GET for UI, POST for actions)
GET  http://localhost:5678/webhook/prd-synthesis
POST http://localhost:5678/webhook/prd-synthesis-action

# Phase 4: Council Review (GET for UI, POST for actions)
GET  http://localhost:5678/webhook/council-review
POST http://localhost:5678/webhook/council-review-action
```

### Directory Structure

```
workflow-orchestration-system-scaffold/
├── docker-compose.yml          # n8n service definition
├── setup.sh                    # First-time setup script
├── .env                        # Environment config (not committed)
├── prompts/                    # Agent system prompts
├── skills/                     # Agent knowledge documents
├── workflows/                  # n8n workflow JSON files
├── contracts/                  # Handoff validation schemas
├── docs/                       # Documentation (you are here)
└── workspace/                  # Runtime artifacts (gitignored)
    └── {project-name}/
        ├── handoffs/           # Phase output artifacts
        ├── tasks/              # Generated tasks
        ├── diagrams/           # Mermaid diagrams
        └── config/             # Project metadata
```

---

## 🤝 Contributing

See **[development-standards.md](./development-standards.md)** for:
- Commit conventions
- Testing practices
- Common pitfalls to avoid
- Development patterns

---

## 📝 License

See parent repository for license information.
