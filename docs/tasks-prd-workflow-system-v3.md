# Task List: Workflow Orchestration System (n8n Architecture)

> **PRD**: `prd-workflow-system-v3.md` (v3.5)  
> **Generated**: February 27, 2026  
> **Architecture**: n8n (Docker/WSL2) + Ollama local (True MVP) + Multi-provider LLM (Full MVP)  
> **Milestones**: True MVP (Weeks 1-2) validates core pipeline with local Ollama. Full MVP (Weeks 3-5) adds API providers + infrastructure.

---

## Relevant Files

### Infrastructure
- `docker-compose.yml` - n8n + persistent volumes
- `setup.sh` - First-time setup script: prerequisite checker + model puller + Docker Compose launcher
- `.env.example` - Template for API keys and n8n config
- `.gitignore` - Ignore .env, n8n-data, workspace project artifacts
- `LICENSE` - MIT license

### n8n Workflows (exported JSON, version controlled)
- `workflows/master-orchestration.json` - Phase sequencing and status dashboard (Full MVP)
- `workflows/model-router.json` - Shared sub-workflow: multi-provider routing and normalization (Full MVP)
- `workflows/phase-1-analysis.json` - Codebase analysis, multi-repo capable (Full MVP)
- `workflows/phase-2-interview.json` - PRD interview via webhook-based chat
- `workflows/phase-3-prd-synthesis.json` - PRD writing and revision
- `workflows/phase-4-council-review.json` - Core reviewers + manual specialist selection + chair synthesis
- `workflows/phase-4.5-pm-destination.json` - PM destination selection (Full MVP)
- `workflows/phase-5-task-generation.json` - Tasks + GitHub Issues push (Full MVP)
- `workflows/phase-5.5-feasibility-review.json` - Critics council implementation feasibility review (Full MVP)
- `workflows/phase-6-execution-tracking.json` - Progress tracking, Code Review Agent, GitHub sync (Full MVP)

### Agent Prompts (26 agents, each paired with skills per FR-11.4)
- `prompts/analysis/codebase-analyst.md` - Analysis agent
- `prompts/prd-development/prd-interviewer.md` - Interview agent
- `prompts/prd-development/prd-writer.md` - PRD synthesis agent
- `prompts/prd-council/core/technical-reviewer.md` - Technical feasibility reviewer
- `prompts/prd-council/core/security-reviewer.md` - Security and compliance reviewer
- `prompts/prd-council/core/executive-reviewer.md` - Business alignment reviewer
- `prompts/prd-council/core/user-advocate.md` - User value reviewer
- `prompts/prd-council/core/council-chair.md` - Council synthesizer (quality model default)
- `prompts/prd-council/specialized/compliance-reviewer.md` - Deep FISMA/FedRAMP/NIST
- `prompts/prd-council/specialized/performance-reviewer.md` - Scalability and performance
- `prompts/prd-council/specialized/accessibility-reviewer.md` - WCAG, 508, inclusive design
- `prompts/prd-council/specialized/data-privacy-reviewer.md` - PII, GDPR, privacy by design
- `prompts/prd-council/specialized/api-design-reviewer.md` - API contracts, versioning
- `prompts/prd-council/specialized/migration-reviewer.md` - Legacy modernization, rollback
- `prompts/critics-council/skeptical-implementer.md` - Timeline/task feasibility critic
- `prompts/critics-council/scope-killer.md` - Scope creep and MVP purity critic
- `prompts/critics-council/integration-pessimist.md` - Integration seam and failure mode critic
- `prompts/critics-council/requirements-lawyer.md` - PRD-to-task consistency critic
- `prompts/critics-council/outsider-user.md` - Secondary persona and UX critic
- `prompts/critics-council/critics-chair.md` - Critics council synthesizer (tiered findings)
- `prompts/pm-framework/pm-architect.md` - Task decomposition agent
- `prompts/pm-framework/issue-generator.md` - Dual-purpose issue creation agent
- `prompts/pm-framework/destination-advisor.md` - PM destination recommendation agent
- `prompts/task-execution/implementation-agent.md` - Dual-purpose execution agent
- `prompts/task-execution/code-review-agent.md` - Dedicated PR review agent

### Skills (35 files — 18 existing + 17 new ★)
**Analysis skills** (Codebase Analyst):
- `skills/analysis/dotnet-patterns.md` - .NET Framework / .NET 8 patterns
- `skills/analysis/python-patterns.md` - Python codebase patterns
- `skills/analysis/typescript-patterns.md` - TypeScript / Node.js patterns
- `skills/analysis/aws-cdk-patterns.md` - AWS CDK infrastructure patterns
- `skills/analysis/gov-compliance-discovery.md` - Government compliance discovery
- `skills/analysis/tech-debt-assessment.md` - Tech debt identification and scoring
- `skills/analysis/multi-repo-analysis.md` - Cross-repository analysis methodology

**PRD skills** (Interviewer + Writer):
- `skills/prd/stakeholder-interview.md` - Interview techniques and probing
- `skills/prd/requirements-engineering.md` - Requirements engineering best practices
- `skills/prd/gov-prd-requirements.md` - Government-specific PRD requirements

**Council skills** (Core + Specialized reviewers — 12 files):
- ★ `skills/council/technical-review.md` - Architecture evaluation, feasibility checklists
- ★ `skills/council/security-review.md` - Threat modeling, security requirements checklist
- ★ `skills/council/business-alignment.md` - ROI analysis, strategic fit assessment
- ★ `skills/council/ux-review.md` - User journey validation, usability heuristics
- ★ `skills/council/council-synthesis.md` - Multi-perspective synthesis framework
- `skills/council/fisma-compliance-check.md` - FISMA compliance review
- `skills/council/fedramp-review.md` - FedRAMP review
- ★ `skills/council/compliance-deep-dive.md` - Deep compliance framework analysis
- ★ `skills/council/performance-review.md` - Scalability, SLAs, bottleneck identification
- ★ `skills/council/accessibility-review.md` - WCAG 2.1 checklist, Section 508
- ★ `skills/council/data-privacy-review.md` - PII handling, privacy by design
- ★ `skills/council/api-design-review.md` - API contracts, versioning, compatibility
- ★ `skills/council/migration-review.md` - Migration risk assessment, rollback planning

**Critics council skills** (Implementation Feasibility Review — 5 files):
- ★ `skills/critics/implementation-feasibility.md` - Task counting, time estimation, hidden complexity
- ★ `skills/critics/scope-analysis.md` - MVP validation, hypothesis-to-feature tracing
- ★ `skills/critics/integration-risk.md` - System boundary analysis, failure mode enumeration
- ★ `skills/critics/requirements-audit.md` - FR-to-task cross-referencing, contradiction detection
- ★ `skills/critics/ux-accessibility-audit.md` - Persona journey mapping, assumed knowledge detection

**PM skills** (PM Architect + Issue Generator):
- `skills/pm/task-decomposition.md` - Task breakdown best practices
- `skills/pm/github-issues-format.md` - Dual-purpose issue template + AI Agent Notes
- `skills/pm/gov-contract-planning.md` - Government contract planning
- `skills/pm/agile-estimation.md` - T-shirt sizing estimation

**Execution skills** (Implementation Agent + Code Review Agent):
- `skills/execution/coding-standards.md` - Comprehensive coding standards (3 principles, 10 categories)
- `skills/execution/commit-protocol.md` - Branch, PR, review, merge, changelog protocol
- ★ `skills/execution/code-review.md` - Diff analysis methodology, review format, auto-merge criteria

### Handoff Contracts
- `contracts/prd-interview-output.schema.md` - Phase 2 validation schema
- `contracts/prd-output.schema.md` - Phase 3 validation schema
- `contracts/council-output.schema.md` - Phase 4 validation schema
- `contracts/analysis-output.schema.md` - Phase 1 validation schema (Full MVP)
- `contracts/feasibility-review-output.schema.md` - Phase 5.5 validation schema (Full MVP)
- `contracts/pm-output.schema.md` - Phase 5 validation schema (Full MVP)

### Documentation & Config
- `README.md` - Professional onboarding documentation
- `CLAUDE.md` - Instructions for Claude Code during Phase 6 execution (Full MVP)
- `CHANGELOG.md` - Auto-maintained changelog template
- `workspace/config/models.json.example` - Model registry template with Ollama defaults + API provider examples (Full MVP)

---

## Milestone 1: True MVP (Weeks 1-2) — Validate Core Pipeline

> **Goal**: Prove the pipeline works — interview → PRD → council review produces artifacts Brian would use on a real project. Local Ollama inference with two-model strategy (speed model for throughput steps, quality model for reasoning steps), no API keys required, no GitHub integration, no full model router.

- [ ] 1.0 Set Up Docker Infrastructure and Project Scaffold
  - [ ] 1.1 Create the project directory structure: `workflows/`, `prompts/` (with subdirs: `analysis/`, `prd-development/`, `prd-council/core/`, `prd-council/specialized/`, `pm-framework/`, `task-execution/`), `skills/` (with subdirs: `analysis/`, `prd/`, `council/`, `pm/`, `execution/`), `contracts/`, `workspace/config/`
  - [ ] 1.2 Create `docker-compose.yml` with n8n service: persistent volume for n8n data, workspace directory mounted from host, port 5678 exposed, environment variables for n8n config (basic auth, encryption key)
  - [ ] 1.3 Create `.env.example` with minimal True MVP config:
    - n8n config: `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `N8N_ENCRYPTION_KEY`
    - Ollama: `OLLAMA_BASE_URL=http://host.docker.internal:11434` (default, no key needed)
    - Per-step model config: `OLLAMA_SPEED_MODEL=qwen3.5:35b-a3b`, `OLLAMA_QUALITY_MODEL=qwen3.5:35b`
    - Placeholder comments for Full MVP API providers (Anthropic, Bedrock, OpenAI-compatible)
  - [ ] 1.4 Create `.gitignore` covering: `.env`, `n8n-data/`, `workspace/*/handoffs/`, `workspace/*/tasks/`, `workspace/*/diagrams/`, `workspace/*/interview-state.json`, `node_modules/`
  - [ ] 1.5 Create `CHANGELOG.md` template, `LICENSE` (MIT)
  - [ ] 1.6 Create `setup.sh` — first-time setup script: check for Ollama installation, check for NVIDIA GPU access, verify CUDA availability, check Docker/Docker Compose, prompt to pull required models (with size estimates: ~18GB + ~21GB), run `docker compose up -d`, print success message with URL. Make executable (`chmod +x`).
  - [ ] 1.7 Verify Docker Compose starts n8n successfully: `docker compose up -d`, access `http://localhost:5678`, confirm n8n UI loads

- [ ] 2.0 Create Core Agent Prompts (True MVP)
  - [ ] 2.1 Write `prompts/prd-development/prd-interviewer.md` — system prompt for conversational interview: one-question-at-a-time model, lettered/numbered options, probing techniques for specificity, conditional compliance inquiry, coverage checklist, batch input mode support (detect uploaded requirements, ask only about gaps). Header references skills: `skills/prd/stakeholder-interview.md`, `skills/prd/requirements-engineering.md`
  - [ ] 2.2 Write `prompts/prd-development/prd-writer.md` — system prompt for PRD synthesis: input sources (interview + analysis if present), output structure (all 7-8 sections per FR-3.2), version tracking, revision model, junior-developer-level clarity, "what/why not how" principle. Header references skills: `skills/prd/requirements-engineering.md`, `skills/prd/gov-prd-requirements.md` (conditional)
  - [ ] 2.3 Write `prompts/prd-council/core/technical-reviewer.md` — stated biases (prefers proven tech, values maintainability, skeptical of timelines). Focus: architecture, feasibility, scope realism. Output: 3-5 concerns/endorsements with severity/confidence + overall rating. Header references skills: `skills/council/technical-review.md`
  - [ ] 2.4 Write `prompts/prd-council/core/security-reviewer.md` — stated biases (worst-case threat model, demands explicit security requirements). Focus: security posture, data handling, attack surface. Output: 3-5 concerns + security risk rating. Header references skills: `skills/council/security-review.md`, `skills/council/fisma-compliance-check.md` (conditional), `skills/council/fedramp-review.md` (conditional)
  - [ ] 2.5 Write `prompts/prd-council/core/executive-reviewer.md` — stated biases (organizational value focus, questions scope without business goals). Focus: ROI, strategic fit, resource justification. Output: 3-5 concerns/endorsements + business alignment rating. Header references skills: `skills/council/business-alignment.md`
  - [ ] 2.6 Write `prompts/prd-council/core/user-advocate.md` — stated biases (champions end-user experience). Focus: user stories, accessibility, usability. Output: 3-5 concerns/endorsements + user value rating. Header references skills: `skills/council/ux-review.md`
  - [ ] 2.7 Write `prompts/prd-council/core/council-chair.md` — synthesis prompt (default model: `qwen3.5:35b` quality model). Takes all reviewer outputs (variable count: core + any specialists), identifies consensus, surfaces conflicts, recommends revisions, flags decisions for stakeholder. Must handle variable number of reviewer inputs. Header references skills: `skills/council/council-synthesis.md`

- [ ] 3.0 Create Core Skills and Handoff Contracts (True MVP)
  - [ ] 3.1 Write `skills/prd/stakeholder-interview.md` — interview question bank organized by coverage area, probing techniques for vague answers, specificity conversion examples ("fast" → "< 200ms p95"), conditional compliance inquiry flow
  - [ ] 3.2 Write `skills/prd/requirements-engineering.md` — requirements structuring patterns, measurability standards, acceptance criteria methodology, functional vs. non-functional organization
  - [ ] 3.3 Write `skills/prd/gov-prd-requirements.md` — gov-specific PRD sections (compliance, ATO pathway, impact levels), FISMA/FedRAMP/SOC 2 language, conditional inclusion rules
  - [ ] 3.4 ★ Write `skills/council/technical-review.md` — architecture evaluation framework (component coupling, scalability, maintainability), feasibility assessment checklist, scope realism benchmarks (effort vs. timeline), technology risk indicators
  - [ ] 3.5 ★ Write `skills/council/security-review.md` — threat modeling methodology (STRIDE or equivalent), security requirements checklist (AuthN, AuthZ, encryption, logging, input validation), attack surface analysis approach, security-specific acceptance criteria patterns
  - [ ] 3.6 ★ Write `skills/council/business-alignment.md` — ROI analysis framework, strategic fit assessment criteria, resource justification methodology (cost vs. value), stakeholder alignment checklist, business risk identification
  - [ ] 3.7 ★ Write `skills/council/ux-review.md` — user journey validation methodology, usability heuristics (Nielsen's 10 adapted for PRD review), accessibility baseline checks, user value proposition scoring, persona coverage assessment
  - [ ] 3.8 ★ Write `skills/council/council-synthesis.md` — multi-perspective synthesis framework (how to detect consensus vs. conflict), conflict resolution patterns (present both sides, recommend resolution), recommendation prioritization (critical/important/nice-to-have), stakeholder decision framing
  - [ ] 3.9 Write `skills/council/fisma-compliance-check.md` — FISMA control family checklist, impact level assessment, inherited vs. implemented controls identification
  - [ ] 3.10 Write `skills/council/fedramp-review.md` — FedRAMP baseline requirements, shared responsibility model, continuous monitoring requirements
  - [ ] 3.11 Write `contracts/prd-interview-output.schema.md` — required sections for interview handoff: coverage summary, raw transcript, extracted requirements by category, compliance applicability flag, identified gaps
  - [ ] 3.12 Write `contracts/prd-output.schema.md` — required sections for PRD handoff: all FR-3.2 sections present, measurable requirements check, version number, approval status
  - [ ] 3.13 Write `contracts/council-output.schema.md` — required sections for council handoff: reviewer list, per-reviewer findings, chair synthesis (consensus, conflicts, recommendations, decisions), accepted/rejected status per recommendation

- [ ] 4.0 Build Phase 2: Interview Workflow (Webhook-Based Chat)
  - [ ] 4.1 Create a lightweight chat HTML page served by n8n (static file or Respond to Webhook node) — simple chat UI with message input, send button, conversation display. Sends each user message as POST to an n8n webhook endpoint.
  - [ ] 4.2 Create the interview webhook workflow: receives user message, loads conversation state from `workspace/{project-name}/interview-state.json` (creates if first message), loads analysis handoff if exists. **First node**: Ollama connectivity pre-check (`GET host.docker.internal:11434/api/tags`) — return clear error if unreachable (per FR-8.4).
  - [ ] 4.3 Add LLM call node: Ollama API HTTP Request (`POST /api/chat`) with interviewer system prompt + skills (stakeholder-interview + requirements-engineering) + full conversation history + new user message. Model: `qwen3.5:35b-a3b` (speed model — interactive chat needs fast response). Configure per FR-8.4: 300-second timeout, 3 retries with 30-second backoff. For True MVP, this is a direct Ollama API call (no model router).
  - [ ] 4.4 Add state management: append user message + agent response to conversation state file, save to disk
  - [ ] 4.5 Add completion detection node (Code node): check if the interviewer's response contains a completion signal (e.g., "INTERVIEW_COMPLETE" marker or all coverage checklist items addressed)
  - [ ] 4.6 Add requirements extraction node: on completion, call Ollama API (model: `qwen3.5:35b` — quality model for structured extraction, 300-second timeout per FR-8.4) with extraction prompt + full transcript → structured requirements document
  - [ ] 4.7 Add handoff validation node: check output against `contracts/prd-interview-output.schema.md`
  - [ ] 4.8 Add file write node: save to `workspace/{project-name}/handoffs/002-prd-interview.md`
  - [ ] 4.9 Add project initialization: first message to the webhook creates the project directory (`workspace/{project-name}/`) with all subdirectories if it doesn't exist. Project name from URL parameter or form input.
  - [ ] 4.10 Export as `workflows/phase-2-interview.json` and test with a simulated interview (greenfield scenario)

- [ ] 5.0 Build Phase 3: PRD Synthesis Workflow
  - [ ] 5.1 Create the PRD synthesis sub-workflow: triggered manually from n8n UI. Load interview handoff + analysis handoff (if exists) from `workspace/{project-name}/handoffs/`
  - [ ] 5.2 Add synthesis node: Ollama API call (model: `qwen3.5:35b` — quality model for complex PRD synthesis, 300-second timeout, 3 retries per FR-8.4) with prd-writer prompt + skills (requirements-engineering + gov-prd-requirements conditional) + all loaded context → produce PRD v1
  - [ ] 5.3 Add user review node: present PRD to user in n8n UI, accept feedback text or "approved"
  - [ ] 5.4 Add revision loop: if user provides feedback, re-call Ollama API (model: `qwen3.5:35b`) with PRD + feedback → produce next version (v2, v3, etc.)
  - [ ] 5.5 Add contract validation node: check final PRD against `contracts/prd-output.schema.md`
  - [ ] 5.6 Add file write nodes: save versioned PRD to `workspace/{project-name}/tasks/prd-[name]-v[n].md` and handoff to `workspace/{project-name}/handoffs/003-prd-refined.md`
  - [ ] 5.7 Export as `workflows/phase-3-prd-synthesis.json` and test

- [ ] 6.0 Build Phase 4: Council Review Workflow
  - [ ] 6.1 Create the council review sub-workflow: load latest PRD from `workspace/{project-name}/handoffs/003-prd-refined.md`
  - [ ] 6.2 Add specialist selection form: checkboxes for optional specialized reviewers (☐ Compliance ☐ Performance ☐ Accessibility ☐ Data Privacy ☐ API Design ☐ Migration). User checks which to include.
  - [ ] 6.3 Add core reviewer nodes — **batch all speed-model calls first** to minimize GPU model swaps (per FR-10.11B). Four sequential Ollama API calls (model: `qwen3.5:35b-a3b` — speed model for reviewer throughput, 300-second timeout, 3 retries per FR-8.4) with the respective prompt + paired skills + PRD context:
    - Technical Reviewer (prompt + technical-review skill)
    - Security Reviewer (prompt + security-review skill + fisma/fedramp skills conditional)
    - Executive Reviewer (prompt + business-alignment skill)
    - User Advocate (prompt + ux-review skill)
  - [ ] 6.4 Add specialist reviewer loop (still speed model, runs before chair): for each checked specialist, load prompt + skills, call Ollama API (model: `qwen3.5:35b-a3b`, 300-second timeout, 3 retries) → review output. On failure after retries, preserve completed reviewer outputs and present error to user with option to retry the failed reviewer only (per FR-8.4).
  - [ ] 6.5 **After all speed-model calls complete**, add quality model warm-up node: send trivial request to `qwen3.5:35b` (e.g., "respond with OK") to force model load before synthesis (per FR-8.4). Then add Council Chair synthesis node: Ollama API call (model: `qwen3.5:35b` — quality model for hardest reasoning task, 300-second timeout) with council-chair prompt + council-synthesis skill + ALL reviewer outputs (core + specialists) → synthesized findings per FR-4.5
  - [ ] 6.6 Add user review node: present council findings, user accepts/rejects each recommendation
  - [ ] 6.7 Add PRD revision node: if recommendations accepted, call Ollama API (model: `qwen3.5:35b`) with prd-writer prompt + PRD + accepted changes → new PRD version
  - [ ] 6.8 Add re-review gate node (FR-4.9): present form with two options — "Proceed to next phase" or "Reconvene council for re-review". If reconvene selected, loop back to step 6.1 (load revised PRD) for delta review of changed sections only. Increment review counter in output filename (e.g., `004-council-review-r2.md`). Full MVP adds recommendation logic (auto-suggest re-review when >3 recommendations accepted, CRITICAL findings addressed, or user made manual PRD changes).
  - [ ] 6.9 Add contract validation and file write nodes
  - [ ] 6.10 Export as `workflows/phase-4-council-review.json` and test with a sample PRD — including at least one re-review cycle to verify the loop

- [ ] 7.0 True MVP Integration Test — End-to-End Pipeline Validation
  - [ ] 7.1 Run the full True MVP pipeline end-to-end with a real project idea (not a toy example): start interview → complete full conversation → trigger synthesis → review PRD → trigger council review → accept/reject recommendations → exercise re-review gate (reconvene at least once) → verify final PRD reflects all revisions
  - [ ] 7.2 Verify all handoff files are created in `workspace/{project-name}/handoffs/` with correct naming and valid content: `002-prd-interview.md`, `003-prd-refined.md`, `004-council-review.md`
  - [ ] 7.3 Verify handoff contract validation catches a deliberately malformed handoff (e.g., remove a required section from the interview transcript and confirm Phase 3 rejects it)
  - [ ] 7.4 Verify session resilience: mid-pipeline, run `docker compose down && docker compose up -d`, then resume the pipeline from the last completed phase using existing handoff files
  - [ ] 7.5 Verify Ollama connectivity recovery: stop Ollama mid-workflow, confirm the workflow returns a clear error (not a hang), restart Ollama, re-trigger the failed step successfully
  - [ ] 7.6 Document any issues found, adjust timeouts/prompts/workflows as needed, re-run until clean

---

## Milestone 2: Full MVP (Weeks 3-5) — Add Infrastructure

> **Goal**: Multi-provider model routing, codebase analysis, task generation, GitHub automation, execution tracking, and all remaining skills.

- [ ] 8.0 Build the Model Router Sub-workflow
  - [ ] 8.1 Create the model router n8n sub-workflow (`workflows/model-router.json`): accepts inputs — `step_name`, `system_prompt`, `user_content`, `skills_content`, `model_override` (optional)
  - [ ] 8.2 Add model resolution logic (Code node): priority chain — (1) runtime override, (2) project config override, (3) models.json default, (4) fallback to Ollama `qwen3.5:35b`
  - [ ] 8.3 Add prompt tier selection (Code node): based on resolved model's `tier` field, select appropriate prompt tier markers from the system prompt (frontier/strong/capable)
  - [ ] 8.4 Add context budget check (Code node): calculate approximate token count. If >80% of model's context window, log warning. If >95%, apply summarization or suggest larger model.
  - [ ] 8.5 Add provider request formatting (Code node): format HTTP request per provider type (Anthropic Messages API / OpenAI chat completions / Ollama chat / Bedrock invoke-model)
  - [ ] 8.6 Add HTTP Request node with retry logic (3 retries, exponential backoff for 429/500)
  - [ ] 8.7 Add response normalization (Code node): extract text response into `{ response_text, model_used, provider, tokens_input, tokens_output, latency_ms }`
  - [ ] 8.8 Add usage logging: append to `workspace/config/usage-log.jsonl` — include model digest (SHA256 from Ollama `/api/show` or API model version) for reproducibility audit per FR-11.10
  - [ ] 8.9 Export as `workflows/model-router.json` and test with Ollama (both models) + at least one API provider (Anthropic or OpenAI-compatible)

- [ ] 9.0 Progressive Configuration & Model Registry
  - [ ] 9.1 Create auto-generation logic: on first run (no models.json exists), detect configured providers from env vars (check Ollama connectivity first, then API keys) and auto-generate `workspace/config/models.json` with provider entries + model definitions + per-step defaults matching FR-11.11A assignments
  - [ ] 9.2 Create `workspace/config/models.json.example` — full reference template with all providers, models (including tier field: frontier/strong/capable/lightweight), context windows, cost tiers, and all step defaults per FR-11.4
  - [ ] 9.3 Create "Configure Providers" n8n workflow: form-driven setup for adding API providers (Anthropic, Bedrock, OpenAI-compatible) alongside existing Ollama. Tests connectivity, lists available models, updates models.json.
  - [ ] 9.4 Create "Model Assignments" n8n workflow: shows each workflow step with current model assignment. User selects from dropdown of available models per step. Updates models.json.

- [ ] 10.0 Create Remaining Agent Prompts (Full MVP)
  - [ ] 10.1 Write `prompts/analysis/codebase-analyst.md` — analysis methodology, output format matching analysis contract, language-agnostic core with skill-based specialization, multi-repo awareness. References skills: analysis/ skills (conditional by detected tech stack)
  - [ ] 10.2 Write `prompts/prd-council/specialized/compliance-reviewer.md` — deep FISMA/FedRAMP expertise. References skills: `fisma-compliance-check.md`, `fedramp-review.md`, `compliance-deep-dive.md`
  - [ ] 10.3 Write `prompts/prd-council/specialized/performance-reviewer.md` — scalability and performance architecture. References skills: `performance-review.md`
  - [ ] 10.4 Write `prompts/prd-council/specialized/accessibility-reviewer.md` — WCAG and inclusive design. References skills: `accessibility-review.md`
  - [ ] 10.5 Write `prompts/prd-council/specialized/data-privacy-reviewer.md` — data handling and privacy. References skills: `data-privacy-review.md`
  - [ ] 10.6 Write `prompts/prd-council/specialized/api-design-reviewer.md` — API contract design. References skills: `api-design-review.md`
  - [ ] 10.7 Write `prompts/prd-council/specialized/migration-reviewer.md` — legacy modernization. References skills: `migration-review.md`
  - [ ] 10.8 Write `prompts/pm-framework/pm-architect.md` — task decomposition, dependency identification, milestone derivation. References skills: `task-decomposition.md`, `agile-estimation.md`, `gov-contract-planning.md` (conditional)
  - [ ] 10.9 Write `prompts/pm-framework/issue-generator.md` — dual-purpose issue creation. References skills: `github-issues-format.md`, `coding-standards.md`
  - [ ] 10.10 Write `prompts/pm-framework/destination-advisor.md` — PM destination recommendation. References skills: `gov-contract-planning.md`
  - [ ] 10.11 Write `prompts/task-execution/implementation-agent.md` — dual-purpose execution, works with Claude Code and Continue.Dev. References skills: `coding-standards.md`, `commit-protocol.md`
  - [ ] 10.12 Write `prompts/task-execution/code-review-agent.md` — dedicated PR review, diff analysis, structured review output, auto-merge decision criteria. References skills: `coding-standards.md`, `commit-protocol.md`, `code-review.md`

- [ ] 11.0 Create Remaining Skills (Full MVP)
  - [ ] 11.1 Write all 7 analysis skills: `dotnet-patterns.md`, `python-patterns.md`, `typescript-patterns.md`, `aws-cdk-patterns.md`, `gov-compliance-discovery.md`, `tech-debt-assessment.md`, `multi-repo-analysis.md`
  - [ ] 11.2 ★ Write 6 specialized council skills: `compliance-deep-dive.md` (deep framework analysis), `performance-review.md` (scalability, SLAs, bottlenecks), `accessibility-review.md` (WCAG 2.1, Section 508), `data-privacy-review.md` (PII, GDPR, privacy by design), `api-design-review.md` (contracts, versioning, compatibility), `migration-review.md` (migration risk, rollback planning)
  - [ ] 11.3 Write 4 PM skills: `task-decomposition.md`, `github-issues-format.md`, `gov-contract-planning.md`, `agile-estimation.md`
  - [ ] 11.4 Write 3 execution skills: `coding-standards.md` (comprehensive — 3 principles, 10 categories per FR-6.8), `commit-protocol.md` (branch naming, conventional commits, PR creation), ★ `code-review.md` (diff analysis methodology, review comment format, auto-merge criteria)
  - [ ] 11.5 Write remaining handoff contracts: `contracts/analysis-output.schema.md`, `contracts/pm-output.schema.md`

- [ ] 12.0 Build Master Orchestration Workflow
  - [ ] 12.1 Create the master n8n workflow: manual trigger with project configuration form (project name, entry point type, repo URLs, optional model override dropdown populated from models.json)
  - [ ] 12.2 Add workspace initialization node: create `workspace/{project-name}/` with subdirectories (handoffs/, tasks/, tasks/summary/, diagrams/, config/)
  - [ ] 12.3 Add phase router logic: read project config to determine current state and next phase
  - [ ] 12.4 Add sub-workflow trigger nodes for each phase (Phases 1-6 + 4.5 + 5.5)
  - [ ] 12.5 Add status dashboard node: read project state, return completed phases, current phase, next actions, model assignments
  - [ ] 12.6 Add handoff validation between phase transitions
  - [ ] 12.7 Export as `workflows/master-orchestration.json` and test

- [ ] 13.0 Build Phase 1: Analysis Workflow
  - [ ] 13.1 Create the analysis sub-workflow: input form accepting single repo URL or multiple URLs with descriptions
  - [ ] 13.2 Add repo cloning node: Execute Command → `git clone` each URL into temp directory
  - [ ] 13.3 Add tech stack detection: call Model Router (step: "analysis.detect"), analyst prompt + conditional tech skills
  - [ ] 13.4 Add per-repo analysis loop: Model Router (step: "analysis.deep"), analyst prompt + detected tech skills + compliance discovery + tech-debt skills
  - [ ] 13.5 Add cross-repo analysis (conditional, multi-repo): Model Router (step: "analysis.cross_repo") + multi-repo skill
  - [ ] 13.6 Add handoff validation + file write to `workspace/{project-name}/handoffs/001-analysis-complete.md`
  - [ ] 13.7 Export as `workflows/phase-1-analysis.json` and test

- [ ] 14.0 Retrofit True MVP Workflows with Model Router
  - [ ] 14.1 Update Phase 2 interview workflow: replace direct Ollama API calls with Model Router sub-workflow calls
  - [ ] 14.2 Update Phase 3 synthesis workflow: replace direct Ollama API calls with Model Router calls
  - [ ] 14.3 Update Phase 4 council workflow: replace direct Ollama API calls with Model Router calls (each reviewer uses its step_name for model resolution)
  - [ ] 14.4 Test all three workflows end-to-end with Model Router using Ollama + at least one API provider (Anthropic or OpenAI-compatible)

- [ ] 15.0 Build Phase 4.5: PM Destination Selection Workflow
  - [ ] 15.1 Create destination selection sub-workflow: options form (target repo, separate repo, custom repo, local only)
  - [ ] 15.2 Add destination advisor: Model Router (step: "pm.destination_advisor"), advisor prompt + gov-contract-planning skill
  - [ ] 15.3 Add user selection + config update to `workspace/{project-name}/config/project.json`
  - [ ] 15.4 Export and test

- [ ] 16.0 Build Phase 5: Task Generation + GitHub Push Workflow
  - [ ] 16.1 Create task generation sub-workflow: load PRD + council review + analysis + coding standards skill
  - [ ] 16.2 Add parent task generation: Model Router (step: "pm.parent_tasks"), pm-architect prompt + task-decomposition + agile-estimation skills
  - [ ] 16.3 Add user confirmation gate: present parent tasks, wait for "Go"
  - [ ] 16.4 Add sub-task generation: Model Router (step: "pm.sub_tasks")
  - [ ] 16.5 Add issue body generation: Model Router (step: "pm.issue_bodies"), issue-generator prompt + github-issues-format + coding-standards skills
  - [ ] 16.6 Add local file write: `workspace/{project-name}/tasks/tasks-prd-[name].md`
  - [ ] 16.7 Add GitHub milestone creation (n8n GitHub node, reads PM destination from config)
  - [ ] 16.8 Add GitHub issue creation loop with labels + milestone
  - [ ] 16.9 Add GitHub project board creation (kanban + roadmap views)
  - [ ] 16.10 Add error handling: retry logic, duplicate detection
  - [ ] 16.11 Export and test

- [ ] 17.0 Build Phase 5.5: Implementation Feasibility Review Workflow (Critics Council)
  - [ ] 17.1 Create the feasibility review sub-workflow: load PRD + task list + council review from `workspace/{project-name}/handoffs/`
  - [ ] 17.2 Write 6 critics council prompts: `prompts/critics-council/skeptical-implementer.md`, `scope-killer.md`, `integration-pessimist.md`, `requirements-lawyer.md`, `outsider-user.md`, `critics-chair.md`. Each prompt defines the adversarial mandate, stated biases, and output format (findings with severity ratings, no endorsements).
  - [ ] 17.3 Write 5 critics council skills: `skills/critics/implementation-feasibility.md`, `scope-analysis.md`, `integration-risk.md`, `requirements-audit.md`, `ux-accessibility-audit.md`
  - [ ] 17.4 Add critic reviewer nodes — batch all speed-model calls: 5 sequential Model Router calls (step: "critics.{reviewer}"), each critic prompt + paired skill + PRD + task list as context. 300-second timeout, 3 retries per FR-8.4.
  - [ ] 17.5 Add Critics Chair synthesis node: Model Router (step: "critics.chair"), chair prompt + council-synthesis skill + ALL critic outputs → tiered findings report (Tier 1: fix before building, Tier 2: fix during build, Tier 3: acknowledge and move on)
  - [ ] 17.6 Add user review node: present findings, user selects which to act on
  - [ ] 17.7 Add decision routing: if user revises PRD → trigger Phase 3/4 revision loop; if user revises task list → update tasks; if user proceeds → advance to Phase 6
  - [ ] 17.8 Add file write: `workspace/{project-name}/handoffs/005.5-feasibility-review.md`
  - [ ] 17.9 Export as `workflows/phase-5.5-feasibility-review.json` and test

- [ ] 18.0 Build Phase 6: Execution Tracking Workflow
  - [ ] 18.1 Create execution tracking sub-workflow: read task list, identify next uncompleted task (dependency-aware)
  - [ ] 18.2 Add task injection node: write task context (issue body + AI Agent Notes) to `.claude/current-task.md` in target repo for Claude Code pickup
  - [ ] 18.3 Add task presentation node: display in n8n UI with copy-to-clipboard + terminal command instruction
  - [ ] 18.4 Add GitHub polling node (Schedule Trigger): check for new PRs matching `task/[issue-number]-*` branch pattern every 2 minutes
  - [ ] 18.5 Add Code Review Agent node: on new PR detected, call Model Router (step: "execution.code_review"), code-review-agent prompt + coding-standards skill + code-review skill + PR diff context
  - [ ] 18.6 Add review routing: if clean + auto-merge authorized → merge via `gh pr merge`; if issues found → present review to user
  - [ ] 18.7 Add PR merge handler: update CHANGELOG.md, close linked issue, move board card to Done
  - [ ] 18.8 Add completion check: when all tasks done, compile release notes
  - [ ] 18.9 Export and test

- [ ] 19.0 Write CLAUDE.md and Documentation
  - [ ] 19.1 Write `CLAUDE.md` — instructions for Claude Code / Continue.Dev during Phase 6 execution: how to read `.claude/current-task.md`, issue reading protocol, one-sub-task-at-a-time model, feature branch workflow, conventional commit format, PR creation, coding standards reference, approval gate
  - [ ] 19.2 Write `README.md` — all sections per FR-10.3: header/badges, what this is, how it works (Mermaid diagram), prerequisites (Ollama + GPU drivers + Docker + ~40GB disk), quick start (setup.sh OR manual Ollama + Docker Compose on WSL2), **deployment variants** (local workstation, team GPU server, API-only no-GPU, hybrid), architecture diagram (showing n8n → model router → Ollama local + optional API providers), phase guide, multi-repo analysis, PM destination selection, model configuration guide (Ollama zero-config start + adding API providers + JSON reference), agent roster and skills overview, council composition (core + specialist selection + critics council), dual-purpose issues (with visual example), PR review & Code Review Agent, changelog automation, configuration reference, FAQ/troubleshooting, contributing, license
  - [ ] 19.3 Final review pass: verify all workflow JSONs are exportable and importable, all prompts reference correct skill files, model router works with Ollama + at least one API provider, council specialist selection works via checkboxes, model swap batching runs all speed-model calls before quality-model calls, project namespace creates correctly, README matches actual project structure, `setup.sh` OR (`ollama pull` + `docker compose up`) → first interview within 15 minutes (assuming models pulled)
