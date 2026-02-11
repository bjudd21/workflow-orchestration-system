# Task List: Workflow Orchestration System

> **PRD**: `prd-workflow-system-v2.md`  
> **Generated**: February 10, 2026  
> **Target**: Template repo MVP — 2 week timeline

---

## Relevant Files

### Root Configuration
- `package.json` - Node.js config for stop hooks and TypeScript dependencies
- `tsconfig.json` - TypeScript configuration for hooks
- `.gitignore` - Git ignore rules for node_modules, temp files
- `CLAUDE.md` - Root coordinator prompt for Claude Code
- `README.md` - Professional onboarding documentation (FR-9)
- `CHANGELOG.md` - Auto-maintained changelog template (Keep a Changelog format)
- `aliases.sh` - Bash/Zsh shell aliases for macOS/Linux
- `aliases.ps1` - PowerShell aliases for Windows
- `LICENSE` - License file

### Workflow Orchestration (Meta Plugin)
- `plugins/workflow-orchestration/agents/workflow-coordinator.md` - Orchestrates phase transitions and state management
- `plugins/workflow-orchestration/agents/reviewer-agent.md` - "Second eyes" drift detection agent
- `plugins/workflow-orchestration/commands/status.md` - Report current phase and progress
- `plugins/workflow-orchestration/commands/next.md` - Advance to next phase with validation
- `plugins/workflow-orchestration/commands/resume.md` - Resume interrupted session with context reload
- `plugins/workflow-orchestration/skills/handoff-validation/SKILL.md` - Validate handoffs against contracts
- `contracts/analysis-output.schema.md` - Phase 1 handoff contract
- `contracts/prd-interview-output.schema.md` - Phase 2 handoff contract
- `contracts/prd-output.schema.md` - Phase 3 handoff contract
- `contracts/council-output.schema.md` - Phase 4 handoff contract
- `contracts/pm-output.schema.md` - Phase 5 handoff contract
- `state/workflow-state.md` - Template for current phase tracking
- `state/decisions.md` - Template for cross-phase decision log
- `state/todo.md` - Template for anti-drift checklist

### Analysis Plugin (Phase 1)
- `plugins/analysis/agents/codebase-analyst.md` - Codebase analysis agent definition
- `plugins/analysis/commands/analyze.md` - Analysis phase command
- `plugins/analysis/skills/dotnet-patterns/SKILL.md` - .NET Framework / .NET 8 patterns skill
- `plugins/analysis/skills/python-patterns/SKILL.md` - Python codebase patterns skill
- `plugins/analysis/skills/typescript-patterns/SKILL.md` - TypeScript / Node.js patterns skill
- `plugins/analysis/skills/aws-cdk-patterns/SKILL.md` - AWS CDK infrastructure patterns skill
- `plugins/analysis/skills/gov-compliance-discovery/SKILL.md` - Government compliance discovery skill
- `plugins/analysis/skills/tech-debt-assessment/SKILL.md` - Tech debt identification and scoring skill

### PRD Development Plugin (Phases 2–3)
- `plugins/prd-development/agents/prd-interviewer.md` - Conversational PRD interviewer agent
- `plugins/prd-development/agents/prd-writer.md` - PRD synthesis and refinement agent
- `plugins/prd-development/commands/interview.md` - Interview phase command
- `plugins/prd-development/commands/synthesize.md` - PRD synthesis command
- `plugins/prd-development/skills/stakeholder-interview/SKILL.md` - Interview techniques and probing skill
- `plugins/prd-development/skills/requirements-engineering/SKILL.md` - Requirements engineering best practices
- `plugins/prd-development/skills/gov-prd-requirements/SKILL.md` - Government-specific PRD requirements

### PRD Council Plugin (Phase 4)
- `plugins/prd-council/agents/technical-reviewer.md` - Technical feasibility reviewer
- `plugins/prd-council/agents/security-reviewer.md` - Security and compliance reviewer
- `plugins/prd-council/agents/executive-reviewer.md` - Business alignment reviewer
- `plugins/prd-council/agents/user-advocate.md` - User value and usability reviewer
- `plugins/prd-council/agents/council-chair.md` - Council synthesizer agent
- `plugins/prd-council/commands/council-review.md` - Full council review command
- `plugins/prd-council/commands/council-debate.md` - Focused debate on specific PRD sections
- `plugins/prd-council/skills/fisma-compliance-check/SKILL.md` - FISMA compliance review skill
- `plugins/prd-council/skills/fedramp-review/SKILL.md` - FedRAMP review skill

### PM Framework Plugin (Phase 5)
- `plugins/pm-framework/agents/pm-architect.md` - Task decomposition and roadmap agent
- `plugins/pm-framework/agents/issue-generator.md` - GitHub Issues creation agent
- `plugins/pm-framework/agents/resource-planner.md` - Resource estimation and allocation agent
- `plugins/pm-framework/commands/generate-tasks.md` - Two-phase task generation command
- `plugins/pm-framework/commands/generate-issues.md` - GitHub Issues push command
- `plugins/pm-framework/commands/estimate.md` - Effort estimation command
- `plugins/pm-framework/skills/task-decomposition/SKILL.md` - Task breakdown best practices
- `plugins/pm-framework/skills/github-issues-format/SKILL.md` - GitHub Issues + AI Agent Notes formatting
- `plugins/pm-framework/skills/gov-contract-planning/SKILL.md` - Government contract planning skill
- `plugins/pm-framework/skills/agile-estimation/SKILL.md` - T-shirt sizing estimation skill

### Task Execution Plugin (Phase 6)
- `plugins/task-execution/agents/implementation-agent.md` - Dual-purpose task execution agent
- `plugins/task-execution/commands/next-task.md` - Pick up next task command
- `plugins/task-execution/commands/update-github.md` - Update GitHub Issues/PRs/board command
- `plugins/task-execution/skills/coding-standards/SKILL.md` - Coding preferences and standards
- `plugins/task-execution/skills/commit-protocol/SKILL.md` - Branch, PR, review, merge, changelog protocol

### Stop Hooks
- `hooks/stop-hook.ts` - Quality gate hook for phase completion
- `hooks/phase-validator.ts` - Contract validation hook

### Per-Project Workspace (Initialized Empty)
- `handoffs/.gitkeep` - Handoff artifacts directory
- `state/.gitkeep` - Workflow state directory
- `tasks/.gitkeep` - PRDs, task lists, summaries directory
- `tasks/summary/.gitkeep` - Task step summary directory
- `diagrams/.gitkeep` - Mermaid diagrams directory

### Notes

- All agent, skill, and command files are Markdown (`.md`) — no build step required.
- Stop hooks are TypeScript, compiled and run via Node.js for cross-platform compatibility.
- Shell aliases reference plugin paths relative to repo root.
- Test the full pipeline end-to-end after all tasks are complete using a real or sample project.

---

## Tasks

- [ ] 1.0 Scaffold the Template Repo Structure
  - [ ] 1.1 Initialize the repo with `git init`, create `package.json` with project metadata, TypeScript and Node.js dependencies for hooks (`typescript`, `ts-node`, `@types/node`)
  - [ ] 1.2 Create `tsconfig.json` configured for the hooks directory (target ES2020, module commonjs, strict mode)
  - [ ] 1.3 Create `.gitignore` covering `node_modules/`, `dist/`, `.env`, OS files (`.DS_Store`, `Thumbs.db`), and editor files (`.vscode/settings.json`)
  - [ ] 1.4 Create the complete directory tree with all plugin subdirectories (`plugins/analysis/agents/`, `plugins/analysis/commands/`, `plugins/analysis/skills/`, etc. for all 6 plugins) and `.gitkeep` files in empty per-project workspace directories (`handoffs/`, `state/`, `tasks/`, `tasks/summary/`, `diagrams/`)
  - [ ] 1.5 Create `CLAUDE.md` root coordinator — this file instructs Claude Code on the project structure, how to load the current phase's agents/skills, how to read workflow state, and how to invoke commands. Include instructions for both repo-analysis and greenfield entry points.
  - [ ] 1.6 Create `CHANGELOG.md` template with Keep a Changelog header, `[Unreleased]` section, and category placeholders (Added, Changed, Deprecated, Removed, Fixed, Security)
  - [ ] 1.7 Create `LICENSE` file (confirm license type with Brian — default to MIT if not specified)
  - [ ] 1.8 Run `npm install` to generate `package-lock.json`, verify directory structure is complete, and make initial commit

- [ ] 2.0 Build the Workflow Orchestration Engine (Meta Plugin)
  - [ ] 2.1 Write `plugins/workflow-orchestration/agents/workflow-coordinator.md` — agent definition that manages phase transitions, reads `state/workflow-state.md`, validates handoffs before advancing, and provides status reporting. Include YAML frontmatter (name, description, model).
  - [ ] 2.2 Write `plugins/workflow-orchestration/agents/reviewer-agent.md` — "second eyes" agent that can be invoked to diagnose drift, critique conversation direction, and suggest corrections. Include stated biases and output format.
  - [ ] 2.3 Write `state/workflow-state.md` template — include fields for current phase, completed phases with handoff references, current objective, key context for current phase, next actions, and resume instructions.
  - [ ] 2.4 Write `state/decisions.md` template — structured decision log format with decision ID, date, phase, decision description, rationale, alternatives considered, and impact.
  - [ ] 2.5 Write `state/todo.md` template — anti-drift checklist format with sections for current phase objectives, completed items, in-progress items, and blocked items. Include timestamp for last update.
  - [ ] 2.6 Write `contracts/analysis-output.schema.md` — define required sections for Phase 1 handoff: architecture overview, technology inventory, tech debt inventory, compliance discovery, diagrams produced, and "Do NOT Lose" section.
  - [ ] 2.7 Write `contracts/prd-interview-output.schema.md` — define required sections for Phase 2 handoff: interview transcript summary, extracted requirements by category, compliance applicability determination, identified gaps, and stakeholder decisions.
  - [ ] 2.8 Write `contracts/prd-output.schema.md` — define required sections for Phase 3 handoff: all 7-8 PRD sections per FR-3.2, version metadata, and revision history.
  - [ ] 2.9 Write `contracts/council-output.schema.md` — define required sections for Phase 4 handoff: per-reviewer findings, consensus points, conflicts, recommended revisions, decisions for stakeholder, and overall ratings.
  - [ ] 2.10 Write `contracts/pm-output.schema.md` — define required sections for Phase 5 handoff: parent tasks with sub-tasks, dependency map, T-shirt estimates, relevant files, GitHub Issues metadata (milestones, labels), and AI Agent Notes per issue.
  - [ ] 2.11 Write `plugins/workflow-orchestration/skills/handoff-validation/SKILL.md` — skill that defines how to validate a handoff artifact against its contract schema: check required sections exist, verify YAML frontmatter fields, flag missing content.
  - [ ] 2.12 Write `plugins/workflow-orchestration/commands/status.md` — command definition: read `state/workflow-state.md` and `state/todo.md`, report current phase, percentage complete, and next actions.
  - [ ] 2.13 Write `plugins/workflow-orchestration/commands/next.md` — command definition: validate current phase handoff against contract, update workflow state, identify next phase and required context loading.
  - [ ] 2.14 Write `plugins/workflow-orchestration/commands/resume.md` — command definition: read workflow state, load last handoff + current phase agents/skills + diagrams + decisions, reconstruct context for continuation.

- [ ] 3.0 Build the Analysis Plugin (Phase 1)
  - [ ] 3.1 Write `plugins/analysis/agents/codebase-analyst.md` — agent definition for repository analysis. Include: role description, analysis methodology (clone → scan structure → identify tech stack → analyze patterns → discover compliance → generate diagrams), output format matching the analysis contract, and instructions for language-agnostic core analysis with on-demand skill loading.
  - [ ] 3.2 Write `plugins/analysis/commands/analyze.md` — command definition: accepts repo URL or local path, triggers local clone, invokes codebase-analyst agent with appropriate skills based on detected tech stack, validates output against contract, writes to `handoffs/001-analysis-complete.md`.
  - [ ] 3.3 Write `plugins/analysis/skills/dotnet-patterns/SKILL.md` — .NET Framework and .NET 8 analysis skill: solution/project structure, NuGet dependencies, Framework-to-.NET 8 migration indicators, common anti-patterns (embedded credentials, sync-over-async), configuration patterns (web.config vs appsettings.json).
  - [ ] 3.4 Write `plugins/analysis/skills/python-patterns/SKILL.md` — Python codebase analysis skill: project structure (setuptools, poetry, pip), dependency management (requirements.txt, pyproject.toml), common patterns (Django, Flask, FastAPI), testing frameworks, virtual environment usage.
  - [ ] 3.5 Write `plugins/analysis/skills/typescript-patterns/SKILL.md` — TypeScript/Node.js analysis skill: project structure (monorepo, single package), package management (npm, yarn, pnpm), framework detection (React, Next.js, Express, NestJS), tsconfig analysis, build tooling.
  - [ ] 3.6 Write `plugins/analysis/skills/aws-cdk-patterns/SKILL.md` — AWS CDK infrastructure analysis skill: stack structure, construct levels (L1/L2/L3), cross-stack references, environment configuration, common patterns (VPC, Lambda, API Gateway, DynamoDB), security group analysis.
  - [ ] 3.7 Write `plugins/analysis/skills/gov-compliance-discovery/SKILL.md` — government compliance discovery skill: authentication patterns (PIV/CAC, MFA), data classification, audit logging, encryption at rest/in transit, access control, PII handling, NIST 800-53 control family mapping, FedRAMP baseline indicators, SOC 2 trust principle alignment.
  - [ ] 3.8 Write `plugins/analysis/skills/tech-debt-assessment/SKILL.md` — tech debt identification skill: deprecated dependency detection, outdated framework versions, code duplication indicators, missing test coverage, hardcoded configuration, security vulnerabilities, maintainability scoring.

- [ ] 4.0 Build the PRD Development Plugin (Phases 2–3)
  - [ ] 4.1 Write `plugins/prd-development/agents/prd-interviewer.md` — conversational interviewer agent. Define: one-question-at-a-time interaction model, lettered/numbered options for quick response where possible, probing techniques for specificity (vague → measurable), conditional compliance inquiry (FR-2.5), coverage checklist (all areas in FR-2.6), and instructions for referencing analysis handoff when available vs. greenfield flow.
  - [ ] 4.2 Write `plugins/prd-development/agents/prd-writer.md` — PRD synthesis agent. Define: input sources (interview handoff + analysis handoff if present), output structure (all 7-8 sections per FR-3.2 with conditional compliance section), version tracking convention (`prd-[name]-v1.md`, `-v2.md`), revision interaction model, junior-developer-level clarity requirement, and "what/why not how" principle (FR-3.5).
  - [ ] 4.3 Write `plugins/prd-development/commands/interview.md` — command definition: check for analysis handoff (load if exists, skip if greenfield), invoke interviewer agent, write transcript and extracted requirements to `handoffs/002-prd-interview.md`, validate against interview output contract.
  - [ ] 4.4 Write `plugins/prd-development/commands/synthesize.md` — command definition: load interview handoff + analysis handoff (if exists), invoke PRD writer agent, write PRD to `tasks/prd-[project-name]-v1.md`, allow iterative revision, validate final version against PRD output contract, write to `handoffs/003-prd-refined.md`.
  - [ ] 4.5 Write `plugins/prd-development/skills/stakeholder-interview/SKILL.md` — interview techniques skill: question categories (vision/goals, scope/constraints, technical direction, resources, compliance, edge cases), probing techniques, anti-patterns to avoid (leading questions, assuming requirements, skipping the "why"), quantification rules.
  - [ ] 4.6 Write `plugins/prd-development/skills/requirements-engineering/SKILL.md` — requirements engineering skill: functional vs. non-functional requirements, SMART criteria for requirements, acceptance criteria writing, user story format, requirement traceability, prioritization techniques (MoSCoW).
  - [ ] 4.7 Write `plugins/prd-development/skills/gov-prd-requirements/SKILL.md` — government-specific PRD requirements skill: compliance section structure, ATO implications, FISMA control mapping, FedRAMP inheritance, data sensitivity levels, security control requirements, 508 accessibility requirements.

- [ ] 5.0 Build the PRD Council Plugin (Phase 4)
  - [ ] 5.1 Write `plugins/prd-council/agents/technical-reviewer.md` — technical feasibility reviewer with stated biases (prefers proven tech, values maintainability, skeptical of timelines without buffer). Define: focus areas (architecture soundness, technical risks, scope realism, missing dependencies), output format (3-5 concerns/endorsements, overall feasibility rating LOW/MEDIUM/HIGH).
  - [ ] 5.2 Write `plugins/prd-council/agents/security-reviewer.md` — security and compliance reviewer with stated biases (worst-case threat model, demands explicit security requirements). Define: focus areas (FISMA/FedRAMP compliance, data handling, implicit security requirements, ATO implications), skills to load (fisma-compliance-check, fedramp-review), output format (3-5 concerns, missing requirements, compliance risk rating).
  - [ ] 5.3 Write `plugins/prd-council/agents/executive-reviewer.md` — business alignment reviewer with stated biases (organizational value focus, questions scope that doesn't serve business goals). Define: focus areas (ROI, strategic fit, resource justification, stakeholder alignment, opportunity cost), output format (3-5 concerns/endorsements, business alignment rating).
  - [ ] 5.4 Write `plugins/prd-council/agents/user-advocate.md` — user value and usability reviewer with stated biases (champions end-user experience, pushes back on tech decisions that hurt UX). Define: focus areas (user story completeness, accessibility, usability, user value proposition, missing personas), output format (3-5 concerns/endorsements, user value rating).
  - [ ] 5.5 Write `plugins/prd-council/agents/council-chair.md` — council synthesizer agent (model: opus). Define: input format (all four reviewer outputs), synthesis process (identify consensus → surface conflicts → prioritize by severity → recommend revisions → flag human decisions), output format per FR-4.3.
  - [ ] 5.6 Write `plugins/prd-council/commands/council-review.md` — command definition: load PRD from latest version, invoke all four reviewers sequentially, feed all outputs to council chair for synthesis, write results to `handoffs/004-council-review.md`, present recommendations to user for accept/reject, trigger PRD revision if changes accepted.
  - [ ] 5.7 Write `plugins/prd-council/commands/council-debate.md` — command definition: accepts a specific PRD section or concern, invokes relevant reviewers for focused debate on that topic, chair synthesizes narrower scope output.
  - [ ] 5.8 Write `plugins/prd-council/skills/fisma-compliance-check/SKILL.md` — FISMA compliance check skill: NIST 800-53 control families, FISMA impact levels (Low/Moderate/High), required controls per level, common gaps in PRDs, ATO boundary considerations.
  - [ ] 5.9 Write `plugins/prd-council/skills/fedramp-review/SKILL.md` — FedRAMP review skill: FedRAMP authorization levels, baseline control sets, cloud service provider inheritance, continuous monitoring requirements, POA&M considerations.

- [ ] 6.0 Build the PM Framework Plugin (Phase 5)
  - [ ] 6.1 Write `plugins/pm-framework/agents/pm-architect.md` — task decomposition and roadmap agent. Define: two-phase generation process (parent tasks first → confirm → sub-tasks), codebase assessment integration (check existing patterns if analysis exists), dependency identification between tasks, T-shirt sizing estimation methodology, milestone derivation from PRD timeline.
  - [ ] 6.2 Write `plugins/pm-framework/agents/issue-generator.md` — GitHub Issues creation agent. Define: dual-purpose issue format (junior-developer-readable body + AI Agent Notes section per FR-5.8), label taxonomy (feature area, T-shirt size, `agent-ready`), milestone assignment logic, project board configuration (kanban + roadmap), `gh` CLI command sequences for creating milestones, issues, project board.
  - [ ] 6.3 Write `plugins/pm-framework/agents/resource-planner.md` — resource estimation agent. Define: T-shirt sizing criteria (S = <2hrs, M = 2-4hrs, L = 4-8hrs, XL = 8+hrs or needs decomposition), team capacity assessment, timeline feasibility check against PRD, risk-adjusted estimates.
  - [ ] 6.4 Write `plugins/pm-framework/commands/generate-tasks.md` — command definition: two-phase process — Phase A generates parent tasks and presents with "Go" confirmation, Phase B generates sub-tasks with dependencies, estimates, and relevant files. Output to `tasks/tasks-prd-[project-name].md`.
  - [ ] 6.5 Write `plugins/pm-framework/commands/generate-issues.md` — command definition: reads task list, creates milestones via `gh api`, creates issues via `gh issue create` with dual-purpose body + AI Agent Notes, creates GitHub Project board if needed via `gh project create`, adds issues to board, configures kanban and roadmap views. Include error handling for auth failures and existing milestones/projects.
  - [ ] 6.6 Write `plugins/pm-framework/commands/estimate.md` — command definition: reads task list, invokes resource planner for T-shirt sizing, updates task list with estimates, produces summary with total effort and timeline feasibility.
  - [ ] 6.7 Write `plugins/pm-framework/skills/task-decomposition/SKILL.md` — task breakdown skill: decomposition heuristics (parent = deliverable, sub-task = one session of work), dependency identification, file-to-task mapping, test file pairing convention.
  - [ ] 6.8 Write `plugins/pm-framework/skills/github-issues-format/SKILL.md` — GitHub Issues formatting skill: dual-purpose issue template with human-readable body structure (description, sub-task checklist, acceptance criteria) and AI Agent Notes section (all 9 subsections per FR-5.8), label conventions, milestone format, `gh` CLI syntax reference for both macOS and Windows.
  - [ ] 6.9 Write `plugins/pm-framework/skills/gov-contract-planning/SKILL.md` — government contract planning skill: contract deliverable alignment, compliance milestone requirements, security review checkpoints, ATO timeline integration, documentation deliverables.
  - [ ] 6.10 Write `plugins/pm-framework/skills/agile-estimation/SKILL.md` — T-shirt sizing estimation skill: sizing criteria, complexity factors, uncertainty buffers, velocity assumptions, common estimation pitfalls.

- [ ] 7.0 Build the Task Execution Plugin (Phase 6)
  - [ ] 7.1 Write `plugins/task-execution/agents/implementation-agent.md` — dual-purpose execution agent. Define: issue reading protocol (main body for human context + AI Agent Notes for autonomous context per FR-6.2), one-sub-task-at-a-time execution model, approval gate between sub-tasks, codebase check before writing new code, test writing requirements, feature branch workflow (branch naming convention: `task/[issue-number]-[short-description]`).
  - [ ] 7.2 Write `plugins/task-execution/commands/next-task.md` — command definition: read local task list, identify next uncompleted sub-task, load parent issue's AI Agent Notes, check dependency issues are closed, present sub-task to user and begin on approval.
  - [ ] 7.3 Write `plugins/task-execution/commands/update-github.md` — command definition: sync local task list completion status with GitHub Issues (close completed issues, add comments with implementation notes, move project board cards), create/update PRs, update CHANGELOG.md on merge.
  - [ ] 7.4 Write `plugins/task-execution/skills/coding-standards/SKILL.md` — comprehensive coding standards skill built on three core principles (clarity over cleverness, simplicity first, readability is non-negotiable). Includes best practices for: naming and readability (intent-revealing names, boolean naming, no abbreviations), function design (single responsibility, ~25 lines, max 3-4 params, early returns, guard clauses, max 3 indent levels), file and code structure (200-300 line limit, separation of concerns, delete dead code), comments and documentation (explain "why" not "what", self-documenting code, document public APIs), error handling (explicit handling, fail fast, actionable messages, log with context), testing (test alongside implementation, test behavior not implementation, one assertion per test, Arrange-Act-Assert), duplication and abstraction (check codebase first, prefer duplication over wrong abstraction, extract at 3+ occurrences), environment and configuration (environment-aware, no hardcoded config, no `.env` overwrites, secrets never in code), dependencies (prefer stdlib, evaluate health before adding, pin versions), and changes and scope (scoped changes, exhaust existing patterns, remove old patterns when replacing, one PR one concern).
  - [ ] 7.5 Write `plugins/task-execution/skills/commit-protocol/SKILL.md` — commit and PR protocol skill: feature branch creation, conventional commit format with `-m` flags, PR creation via `gh pr create` (title, body with changes/sub-tasks/test results/issue link), three review gate options (human review, AI-assisted review, AI review + auto-merge), merge protocol, CHANGELOG.md entry format (Keep a Changelog categories mapped from conventional commit prefixes), issue closure on merge, project board update.

- [ ] 8.0 Build Cross-Platform Shell Aliases & Stop Hooks
  - [ ] 8.1 Write `aliases.sh` — Bash/Zsh aliases for all phase launchers: `wf-analyze`, `wf-interview`, `wf-synthesize`, `wf-council`, `wf-tasks`, `wf-issues`, `wf-status`, `wf-resume`, `wf-next`. Each alias uses `claude --append-system-prompt` to inject the relevant agents, skills, prior handoffs, and diagrams. Include setup instructions as comments.
  - [ ] 8.2 Write `aliases.ps1` — PowerShell equivalents of all aliases in `aliases.sh`. Use PowerShell functions instead of Unix aliases. Handle path separators and command differences. Include setup instructions as comments.
  - [ ] 8.3 Write `hooks/stop-hook.ts` — quality gate stop hook: check for changed files, validate handoff files against contracts if present, update `state/todo.md` with last action timestamp and changed files, suggest git commit. Cross-platform file path handling via Node.js `path` module.
  - [ ] 8.4 Write `hooks/phase-validator.ts` — contract validation hook: read the appropriate contract schema for the current phase, parse the handoff artifact, verify all required sections exist, check YAML frontmatter fields, report missing/incomplete sections with actionable error messages. Cross-platform compatible.
  - [ ] 8.5 Test aliases on macOS (Bash/Zsh) — verify all aliases resolve correctly, system prompt injection loads the right files, and phase launchers start Claude Code with proper context.
  - [ ] 8.6 Test aliases on Windows (PowerShell) — verify all PowerShell functions work equivalently, paths resolve correctly, and `gh` CLI commands execute properly.
  - [ ] 8.7 Test stop hooks — verify hooks execute on phase completion, validate a sample handoff against its contract, and correctly update todo.md. Test on both platforms.

- [ ] 9.0 Write the Professional README
  - [ ] 9.1 Write the header section: project name, one-line description ("A phase-based workflow system that turns codebases and ideas into production-ready PRDs, reviewed task lists, and GitHub Issues — powered by AI agents"), badges for license, macOS, Windows, and GitHub Issues.
  - [ ] 9.2 Write the "What This Is" section — 2-3 sentence plain-language explanation. No jargon. Target: a reader understands the value proposition in 30 seconds.
  - [ ] 9.3 Write the "How It Works" section — create a Mermaid diagram showing the 6-phase pipeline (Analysis → Interview → PRD → Council → Tasks/Issues → Execution) with dual entry points. Add one-sentence descriptions per phase below the diagram.
  - [ ] 9.4 Write the "Prerequisites" section — table of required tools (Git, `gh` CLI, Claude Code, Node.js) with minimum versions and install links/commands for both macOS (Homebrew) and Windows (winget/choco).
  - [ ] 9.5 Write the "Quick Start" section — numbered step-by-step for both macOS and Windows in side-by-side or tabbed format: clone repo, install dependencies (`npm install`), source aliases, authenticate `gh` CLI, run first phase. Every command copy-pasteable. Target: clone to first phase in 10 minutes.
  - [ ] 9.6 Write the "Usage" section — reference table of all commands (`wf-analyze`, `wf-interview`, etc.) with one-line description, expected inputs, and expected outputs per command.
  - [ ] 9.7 Write the "Phase Descriptions" section — collapsible `<details>` block per phase with: what it does, when to use it, what agents/skills are involved, what artifacts it produces, input requirements, and how to resume if interrupted.
  - [ ] 9.8 Write the "Project Structure" section — full directory tree with one-line descriptions per directory and key files. Match the distribution model layout from the PRD.
  - [ ] 9.9 Write the "Dual-Purpose Issues" section — explain the GitHub Issue structure: main body written for junior developers, AI Agent Notes section appended for AI agents. Include a visual example of what an issue looks like with both sections.
  - [ ] 9.10 Write the "PR Review & Changelog" section — explain the three PR review options (human, AI-assisted, AI auto-merge), how to choose per PR, how CHANGELOG.md is auto-maintained, and how to cut a release with `gh release create`.
  - [ ] 9.11 Write the "Configuration & Customization" section — how to add a new skill (create `SKILL.md` in the right directory), override an agent per-project, adjust coding standards, and add new tech stack skill packs.
  - [ ] 9.12 Write the "FAQ / Troubleshooting" section — cover: compaction recovery (`wf-resume`), re-running a phase, skipping analysis for greenfield, Windows-specific issues (PowerShell execution policy, path separators), `gh` CLI auth problems, Claude Code version requirements.
  - [ ] 9.13 Write the "Contributing" section — how to improve agents, add skills, fix issues, and submit PRs back to the template repo. Include branch naming and commit conventions.
  - [ ] 9.14 Write the "License" section — license declaration matching the `LICENSE` file.
  - [ ] 9.15 Add table of contents at the top of the README with anchor links to all sections. Final review pass for consistency, tone, and completeness.
