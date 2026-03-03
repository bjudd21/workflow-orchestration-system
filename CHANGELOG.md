# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

---

## [0.4.0] — 2026-03-03

### Added
- **Auto-chaining feature**: Phase 2 → 3 → 4 pipeline now executes automatically without manual intervention
  - Phase 2 (Interview) completion auto-triggers Phase 3 (PRD Synthesis)
  - Phase 3 completion auto-triggers Phase 4 (Council Review)
  - New HTTP Request nodes for inter-workflow triggering
  - Phase 4 response now includes artifact paths for all handoff files
  - Full pipeline completes in ~9-10 minutes from interview start
- New documentation: `docs/auto-chaining.md` with implementation details, troubleshooting, and testing guide
- New script: `scripts/add-auto-chaining.py` to programmatically modify workflow JSON files
- New test script: `scripts/test-auto-chaining.sh` for end-to-end validation

### Fixed
- **Issue #72**: Phase 3 now writes PRD to both `tasks/prd-{project}-v{N}.md` AND `handoffs/003-prd-refined.md`
  - Added `Code - Write Handoff Copy` node in Phase 3 workflow
  - Ensures Phase 4 can always find the PRD handoff file
  - Maintains backward compatibility with existing `tasks/` directory structure

### Changed
- Phase 2 workflow: Added `HTTP Request - Trigger Phase 3` node after handoff write
- Phase 3 workflow: Added handoff copy step before triggering Phase 4
- Phase 4 workflow: Enhanced final response to include artifact information
  - Response now contains `artifacts` object with paths to interview, PRD, and council review handoffs
  - Added `note` field explaining where to find artifacts

### In Progress
- Phase 4: Council Review workflow (core functionality complete, auto-chaining integrated)

### Previous Fixes (from 0.3.x development)
- Switched Council Chair quality model from `qwen3.5:35b` (~23GB VRAM) to `qwen3:30b-a3b` (~18GB VRAM) — prevents Ollama crash during Chair synthesis step. Both models now fit in 24GB GPU with room for context. Chair prompt updated to honor FR-4.5 spec (Consensus Points, Conflicts, Overall Verdict, Required Revisions)

---

## [0.3.0] — 2026-03-01

### Added
- Phase 3 PRD Synthesis workflow (`workflows/phase-3-prd-synthesis.json`) — fully working end-to-end
  - GET webhook review UI at `/webhook/prd-synthesis`
  - POST webhook for synthesize and approve actions at `/webhook/prd-synthesis-action`
  - Ollama connectivity pre-check before LLM call
  - PRD synthesized from interview handoff + (optional) analysis handoff
  - Versioned PRD written to `workspace/{project}/tasks/prd-{project}-v{N}.md`
  - Schema validation on approve: frontmatter, 7 required sections, FR count, NFR numeric targets, user story count, risk table rows
  - On approve: handoff written to `workspace/{project}/handoffs/003-prd-refined.md`

### Fixed
- Switched PRD synthesis model from `qwen3.5:35b` (dense 23GB) to `qwen3.5:35b-a3b` (MoE 18GB) — dense model OOMs during long generation on RTX 4090 24GB (only ~1.9GB left for KV cache after model load)
- Stripped thinking-mode preamble and markdown code fences from model output in `Code - Process Synthesis`
- Fixed `IF - Action Is Approve` condition referencing `$json.action` (Ollama health response, no `action` field) — now uses `$('Code - Validate Inputs').first().json.action`
- Updated section heading regex in validator to accept `#`, `##`, or `###` headings

---

## [0.2.1] — 2026-03-01

### Fixed
- Corrected quality model from `qwen3.5:27b` to `qwen3.5:35b` (dense 23GB) — confirmed working on RTX 4090 24GB
- Updated VRAM and throughput figures: speed model `qwen3.5:35b-a3b` is ~18GB MoE at ~40-60 tok/s; quality model `qwen3.5:35b` is ~23GB at ~24-32 tok/s
- Updated all references across `.env.example`, `docker-compose.yml`, `setup.sh`, `README.md`, and agent prompt front-matter (`council-chair.md`, `prd-writer.md`)

---

## [0.2.0] — 2026-03-01

### Added
- Phase 2 PRD Interview workflow (`workflows/phase-2-interview.json`) — fully working end-to-end
  - Webhook chat UI at `/webhook/prd-interview`
  - Ollama connectivity pre-check before each LLM call
  - Conversation state persisted to `workspace/{project}/interview-state.json`
  - Completion detection via `INTERVIEW_COMPLETE` signal
  - Requirements extraction call (quality model) on completion
  - Handoff validation against `contracts/prd-interview-output.schema.md`
  - Output written to `workspace/{project}/handoffs/002-prd-interview.md`

### Fixed
- Corrected speed model name from `qwen3.5:35b` to `qwen3.5:35b-a3b` (MoE variant, 18GB vs 23GB)
- Fixed invalid n8n expression syntax in HTTP Request body (`.field` → `$json.field`)
- Added `onError: continueRegularOutput` to webhook nodes (required for responseNode mode)
- Replaced n8n expression shorthand with full `$json` references throughout

---

## [0.1.0] — 2026-02-27

### Added
- Initial project scaffold: Docker Compose (n8n), directory structure, `.env.example`, `setup.sh`
- 7 core agent prompts for True MVP:
  - `prompts/prd-development/prd-interviewer.md`
  - `prompts/prd-development/prd-writer.md`
  - `prompts/prd-council/core/technical-reviewer.md`
  - `prompts/prd-council/core/security-reviewer.md`
  - `prompts/prd-council/core/executive-reviewer.md`
  - `prompts/prd-council/core/user-advocate.md`
  - `prompts/prd-council/core/council-chair.md`
- 10 core skill documents (PRD, council, compliance)
- 3 handoff contract schemas (interview, PRD, council output)
