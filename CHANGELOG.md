# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### In Progress
- Phase 3: PRD Synthesis workflow
- Phase 4: Council Review workflow

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
