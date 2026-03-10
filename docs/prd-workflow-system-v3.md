# Product Requirements Document: Workflow Orchestration System

---

**Document Version**: 3.5  
**Author**: Brian (IT Manager) / Claude (AI-assisted)  
**Date**: February 27, 2026  
**Status**: Final Draft — Post-second-council review  
**Changes from v3.4**: Second council review (Ollama-first focus, 5 reviewers). Incorporated all 18 revisions: (16) Fixed stale references from v3.3 (NFR-3, A3, R1, R4). (17) Abstracted model names in architectural sections to "speed model" / "quality model". (18) Added model swap batching recommendation for council workflow. (19) Updated deployment quickstart with realistic prerequisites and download sizes. (20) Split Success Criterion 13 for honest onboarding metrics. (21) Added context window sizes to FR-10.11A. (22) Added deployment variants section. (23) Added model version logging to project config. (24) Added single-GPU and MoE persona risks to register. (25) Added setup.sh script to True MVP scope. (26) Added Electron desktop shell concept to Phase 2 scope — lightweight wrapper over n8n API for native app experience, evaluated during product viability council review. (27) Added FR-4.9 council re-review gate — after revisions are applied, user can proceed or reconvene council for delta review. System recommends re-review when changes are substantial. (28) Added Ollama Lifecycle Independence note to deployment section — clarifies Ollama is a persistent host service, not bundled with Docker Compose, models never re-downloaded. (29) Red team council review: extended True MVP timeline from Week 1 to Weeks 1-2, Full MVP from Weeks 2-3 to Weeks 3-5. (30) Split success criteria into True MVP (11 criteria) and Full MVP (22 criteria) — True MVP criteria only reference phases that exist in True MVP. (31) Added Task 7.0: True MVP end-to-end integration test (pipeline validation, handoff verification, session resilience, connectivity recovery). (32) Added FR-8.4 LLM Call Resilience — 300-second timeouts, 3 retries with backoff, partial result preservation, connectivity pre-check, model warm-up before council chair. Updated all LLM call tasks with FR-8.4 references. (33) Deferred prompt tiers to Full MVP — True MVP uses single-tier prompts targeting quality model. (34) Added Phase 5.5: Implementation Feasibility Review (Critics Council) — adversarial reviewers assess buildability after task generation. 5 critics + chair, optional gate between Phase 5 and Phase 6. Added 6 agent prompts, 5 skills, workflow, handoff contract. Automated workflow in Full MVP; documented practice for True MVP.  
**Changes from v3.3**: (11) Switched True MVP from Anthropic API to local Ollama inference with two-model strategy: Qwen3.5-35B-A3B (speed, 60-100 tok/s) for conversational steps + Qwen3.5-27B (quality, 15-25 tok/s, Intelligence Index 42) for reasoning-critical steps. Zero API keys required for MVP. (12) Added per-step model assignment table (FR-10.11A). (13) Updated prompt tiers to target Qwen3.5 models. (14) Updated progressive configuration: Ollama zero-config default, API providers as optional additions. (15) Updated risk register for local-first approach.  
**Changes from v3.2**: Council review produced 15 recommendations. Incorporated accepted revisions: (1) Two-milestone MVP — True MVP validates core pipeline in Week 1, Full MVP adds infrastructure Weeks 2-3. (2) Replaced n8n Chat Trigger with webhook-based chat loop for interview. (3) Project-namespaced workspace directories. (4) Progressive configuration — zero-config start, form-driven provider setup, JSON escape hatch. (5) Prompt tiers for multi-model compatibility. (6) Context budget system in model router. (7) Phase 6 task injection to target repo. (8) Simplified agent roster for MVP (manual selection, full registry Phase 2). (9) Every agent paired with relevant skills. (10) Polling default for Phase 6 GitHub monitoring.

---

## 1. Executive Summary

The Workflow Orchestration System is a phase-based, multi-agent framework that systematizes the full lifecycle from project analysis through PRD development, review, and project execution planning. It replaces the current ad-hoc approach where an IT manager manually drives AI tools through analysis, requirements gathering, and documentation — losing context to compaction and starting over repeatedly.

The system supports two entry points: analyzing one or more existing codebases or starting from a greenfield idea. It guides users through a conversational interview, synthesizes a structured PRD, convenes a council of specialized reviewers for quality assurance, generates a phased task list, automatically pushes GitHub Issues with milestones and a project board (kanban + roadmap), and produces dual-purpose issues that either a junior human developer or an AI agent (Claude Code or Continue.Dev) can pick up and execute.

The system maintains a roster of specialized agents — each with defined capabilities, biases, and assigned workflow steps. The council draws from a core set of reviewers with the ability to add specialized agents (e.g., accessibility, performance, data privacy) based on what the PRD contains. A dedicated code review agent handles PR review, and all agent assignments are visible and configurable.

Every agent in the system is built with both a specialized prompt and a curated set of skill documents that give it domain expertise. Skills are injected alongside the agent prompt into every LLM call, ensuring agents have the knowledge they need regardless of which model backs them.

The MVP is delivered in two milestones. **True MVP (Weeks 1-2)** validates the core pipeline: interview → PRD synthesis → council review, using local Ollama inference with a two-model strategy (a fast MoE model for speed-sensitive steps, a dense reasoning model for quality-critical steps) and file-based handoffs. **Full MVP (Weeks 3-5)** adds infrastructure: multi-provider model router with Anthropic/Bedrock/OpenAI-compatible API fallback, codebase analysis, task generation, GitHub integration, execution tracking, and multi-repo support. Both milestones run as n8n workflows in Docker on WSL2, accessible via browser from Windows. Code execution in Phase 6 is hybrid — n8n tracks progress while Claude Code, Continue.Dev, or a human developer implements in the terminal.

---

## 2. Problem Statement

### 2.1 Current State

Brian performs a recurring multi-step workflow across projects: analyze a codebase, document its state, interview stakeholders for requirements, refine a PRD, review it from multiple perspectives, and generate an actionable task list for developers. Today this process is ad-hoc — driven through raw Claude Code sessions with no formalized structure, no reusable templates, and no mechanism for preserving context across phases.

Brian has existing rule files (`create-prd.md`, `generate-tasks.md`, `process-task-list.md`, `coding-prefs.md`) that encode good workflow discipline — conversational PRD interviews, two-phase task generation, one-at-a-time execution with commit protocols. But these are loose files loaded manually, not an integrated system.

### 2.2 Core Pain Points

**Context loss through compaction.** Claude Code compacts conversation history during long sessions, destroying accumulated analysis, decisions, and requirements context. Work must be repeated or reconstructed from memory.

**No formalized handoffs.** When moving from analysis to PRD writing to project planning, there is no structured artifact that carries forward what was learned. Context transfer depends on conversation history — which is fragile.

**Inconsistent quality.** Without standardized prompts, skills, or validation gates, output quality varies between sessions. A PRD produced on Monday may be structurally different from one produced on Friday.

**No structured review.** PRDs go from draft to implementation without systematic review from multiple perspectives (technical feasibility, security/compliance, business alignment, user value). Gaps surface during development, not before.

**Single-user bottleneck.** Only Brian can operate the current workflow. Product owners, team leads, and other stakeholders who need PRDs cannot self-serve because the process requires deep familiarity with AI prompting, Claude Code, and the underlying technical domain.

**No multi-repo awareness.** Many enterprise projects span multiple repositories. The current approach analyzes one repo at a time with no mechanism for understanding cross-repo dependencies, shared libraries, or system-level architecture.

### 2.3 Impact of Not Solving

Projects continue to start with incomplete or inconsistent requirements documentation. Modernization efforts lack the structured analysis needed to surface compliance gaps, tech debt, and architectural risks before development begins. PRDs ship with blind spots that a 30-minute council review would have caught. Developers receive task lists without sufficient context or structure.

---

## 3. Vision & Goals

### 3.1 Vision

A standardized, repeatable workflow that transforms any project — from a legacy .NET monolith to a greenfield microservice — into a production-ready PRD with council-reviewed requirements, an actionable task list, and live GitHub Issues, with minimal manual intervention. Accessible through a browser-based interface that non-technical users can operate alongside the technical team.

### 3.2 Goals

| # | Goal | Metric |
|---|------|--------|
| G1 | Eliminate context loss between workflow phases | Zero rework due to lost context; n8n preserves state between executions |
| G2 | Standardize PRD quality | Every PRD includes all required sections with measurable requirements |
| G3 | Surface blind spots before development starts | Council review identifies ≥1 concern per PRD not found in interview |
| G4 | Reduce time from idea to actionable task list | < 3 hours for moderately complex project |
| G5 | Enable self-service for non-technical stakeholders | Dev Manager / Lead can run pipeline via browser-based n8n UI |
| G6 | Support multi-repo analysis | Projects spanning multiple repos produce unified analysis |

---

## 4. Users & Personas

### 4.1 Primary: IT Manager (Brian)

- **Role**: IT Manager, Infrastructure Engineering, state and local government contracts
- **Experience**: 20 years in technology leadership
- **Needs**: Run the full pipeline on existing repos and greenfield ideas. Review and refine PRDs. Approve task lists. Configure system for specific project types (compliance, modernization, greenfield).
- **Environment**: Windows PC (RTX 4090, 64GB RAM) with WSL2, Docker, n8n, Claude Code

### 4.2 Secondary: Developer Manager / Developer Lead

- **Role**: Technical team leads who receive PRDs and task lists
- **Needs**: Pick up dual-purpose GitHub Issues. Understand task context without separate onboarding. Execute tasks with or without AI agent assistance. Follow industry standard defaults.
- **Interaction**: Consumes output; may trigger specific phases (e.g., re-analyze a repo after changes)
- **Environment**: Browser access to n8n UI; terminal access for Phase 6 execution

### 4.3 Future: Product Owner / Non-Technical Stakeholder

- **Role**: Defines business requirements, lacks technical implementation knowledge
- **Needs**: Participate in PRD interview without understanding AI tooling, prompt engineering, or codebase details. Review PRD in plain language.
- **Interaction**: Browser-based interview chat via webhook-based chat UI
- **Timeline**: Supported at MVP with n8n's built-in chat interface

---

## 5. Scope & Boundaries

### 5.1 In Scope

- 6-phase pipeline: Analysis → Interview → PRD → Council Review → Task Generation → Execution
- n8n workflow orchestration with configurable LLM providers
- Multi-provider model support: Ollama (local default), Anthropic Claude (API fallback), AWS Bedrock, OpenAI-compatible endpoints
- Per-step model selection with defaults and runtime override
- **Agent roster** — centralized registry of all agents with specialties, capabilities, assigned steps, and configurable model assignments
- **Dynamic council composition** — core reviewer agents plus specialized agents auto-selected or manually added based on PRD content
- **Dedicated code review agent** — specialized agent that reviews PRs before merge
- Multi-repo analysis support
- PM destination selection (target repo for GitHub Issues)
- Dual entry points: existing repo(s) or greenfield idea
- Agents as system prompts for LLM API calls (provider-agnostic)
- Skills as context documents injected into prompts
- Handoff contracts with validation between phases
- GitHub integration via n8n nodes (issues, milestones, project boards, PRs)
- Docker Compose deployment on WSL2
- Browser-based UI for all phases except code execution
- Phase 6 hybrid: n8n tracks, Claude Code or Continue.Dev or human executes

### 5.2 Out of Scope

- CI/CD pipeline generation
- Full web application with custom frontend (n8n's UI is sufficient for MVP)
- PM tool integration beyond GitHub (Linear, Jira)
- Multi-user concurrent editing of the same PRD

### 5.3 Pipeline Overview

```
   ┌──────────────────────────────────────────┐
   │     n8n (Docker on WSL2)                  │
   │     Browser UI: http://localhost:5678     │
   ├──────────────────────────────────────────┤
   │                                          │
   │  ┌─────────┐   ┌──────────┐             │
   │  │ Repo(s) │   │Greenfield│             │
   │  │  URL(s) │   │  Idea    │             │
   │  └────┬────┘   └────┬─────┘             │
   │       │              │                   │
   │       ▼              │                   │
   │  Phase 1: Analysis ──┤                   │
   │  (optional, multi-   │                   │
   │   repo capable)      │                   │
   │       │              │                   │
   │       ▼              ▼                   │
   │  Phase 2: PRD Interview ──────────────── │
   │  (webhook chat — browser-based)           │
   │       │                                  │
   │       ▼                                  │
   │  Phase 3: PRD Synthesis ──────────────── │
   │       │                                  │
   │       ▼                                  │
   │  Phase 4: Council Review (mandatory) ─── │
   │       │                                  │
   │       ▼                                  │
   │  Phase 4.5: PM Destination Selection ─── │
   │       │                                  │
   │       ▼                                  │
   │  Phase 5: Tasks + GitHub Issues ──────── │
   │       │                                  │
   │       ▼                                  │
   │  Phase 6: Execution ─────────────────── │
   │  (n8n tracks; Claude Code or human       │
   │   implements in terminal)                │
   │                                          │
   └──────────────────────────────────────────┘
```

### 5.4 Handoff Model

Each phase produces a structured handoff artifact that the next phase consumes. Handoffs are validated against contracts before phase transition.

**Handoff format:**

```markdown
---
phase: [phase-name]
completed: [ISO timestamp]
agent: [agent-name]
project: [project-name]
entry_point: repo | multi-repo | greenfield
target_repos:
  - url: [repo-url]
    role: [primary | dependency | shared-lib]
---

# Phase Handoff: [Source] → [Destination]

## Summary
[2-3 sentence summary]

## Key Findings
[Numbered list of findings]

## Artifacts Produced
[List of files created]

## Context for Next Phase
[What the next agent needs to know]

## Decisions Made
[Decision ID: decision + rationale]

## Do NOT Lose
[Critical facts that might seem minor but matter]
```

### 5.5 State Management

n8n manages workflow state through its execution history and workflow variables. File-based artifacts provide persistence and portability:

```
workspace/
├── handoffs/           ← Phase handoff artifacts (markdown)
├── tasks/              ← PRDs, task lists, summaries
│   └── summary/        ← Per-subtask completion summaries
├── diagrams/           ← Mermaid diagrams generated during analysis
└── config/
    ├── project.json    ← Target repo(s), PM destination, project metadata
    └── decisions.json  ← Cross-phase decision log
```

### 5.6 Output Structure

```
GitHub (target repo — user selects destination):
├── Project Board          ← Kanban (To Do / In Progress / Done) + Roadmap view
├── Milestones             ← With due dates from PRD timeline
├── Issues                 ← One per parent task, dual-purpose format
└── Pull Requests          ← One per completed parent task, linked to issue

Local workspace (on n8n host):
├── workspace/handoffs/    ← Phase handoff artifacts
├── workspace/tasks/       ← PRDs, task lists, summaries
├── workspace/diagrams/    ← Architecture and flow diagrams
└── workspace/config/      ← Project configuration
```

### 5.7 Context Preservation Strategy

1. **n8n execution state** — workflow variables persist between manual triggers and sub-workflow calls. Phase outputs stored as both n8n data and file artifacts.
2. **Handoff artifacts** — structured markdown files that carry forward findings, decisions, and context between phases.
3. **Mermaid diagrams** — architecture, data flow, and auth flow diagrams. Token-efficient format stored in `workspace/{project-name}/diagrams/`.
4. **System prompt injection** — each LLM API call includes relevant agent prompt + skill context + prior handoff content, assembled by the n8n workflow node. The same prompt structure works across all supported providers.
5. **n8n execution history** — full audit trail of every workflow run, inputs, outputs, and errors. Browsable in n8n UI.
6. **Task step summaries** — per-subtask completion records that document what was done.
7. **GitHub Issues as external state** — issue status, comments, and project board position serve as a persistent record of progress.
8. **Pull Requests as review history** — each PR captures the diff, review comments, and merge decision.
9. **CHANGELOG.md as cumulative record** — auto-maintained from merged PRs.

---

## 6. Functional Requirements

### FR-1: Codebase Analysis (Phase 1 — Optional)

**Trigger**: User provides one or more repository URLs or local paths via n8n workflow input form.

**FR-1.1** The system shall clone each repository locally and perform automated analysis. Remote repos are always cloned — no GitHub API access for analysis.

**FR-1.2** The analysis agent shall produce:
- Architecture overview (component map, layer identification)
- Technology inventory (languages, frameworks, versions, dependencies)
- Tech debt inventory (deprecated patterns, outdated dependencies, code smells)
- Compliance discovery (authentication patterns, data handling, audit logging, encryption)
- Mermaid diagrams (architecture, data flow, key workflows)

**FR-1.3** Analysis shall be language-agnostic at the core, with domain-specific skills loaded on demand. MVP skill packs: .NET Framework/.NET 8, Python, TypeScript/Node.js, AWS CDK.

**FR-1.4** The analysis agent shall identify existing components, utilities, and patterns that are relevant to any subsequent PRD work — following the principle of checking for existing code before proposing new implementations.

**FR-1.5** Analysis output shall be written to `workspace/{project-name}/handoffs/001-analysis-complete.md`.

**FR-1.6 (Multi-Repo)** The system shall support analyzing projects that span multiple repositories. When multiple repos are provided:
- Each repo is cloned and analyzed individually
- A cross-repo analysis identifies: shared dependencies, API contracts between services, data flow across repo boundaries, and shared library usage
- The handoff artifact includes a repository relationship map and a unified architecture diagram
- File references in subsequent phases use the format `repo-name:path/to/file` to disambiguate cross-repo paths

**FR-1.7 (Multi-Repo)** The analysis workflow input form shall accept:
- A single repo URL (standard mode)
- Multiple repo URLs with optional descriptions and relationship hints
- A JSON configuration file for complex multi-repo setups

### FR-2: PRD Interview (Phase 2)

**Trigger**: User initiates interview via n8n — either clicks "Start Interview" in the n8n UI or the workflow auto-advances after analysis.

**FR-2.1** The PRD interviewer agent shall conduct a conversational interview, one question at a time, via the webhook-based chat interface accessible in the browser.

**FR-2.2** Where possible, questions shall include lettered or numbered options for quick response (e.g., "What's your target timeline? A) 2 weeks B) 1 month C) 3 months D) Other").

**FR-2.3** If analysis artifacts exist, the interviewer shall reference them to ask informed, specific questions.

**FR-2.4** If no analysis exists (greenfield), the interviewer shall start with vision and scope, progressively exploring technical, compliance, and resource dimensions.

**FR-2.5** The interviewer shall ask whether compliance frameworks (FISMA, FedRAMP, SOC 2) apply to this project. This determines whether the compliance section appears in the PRD.

**FR-2.6** The interview shall cover, at minimum:
- Problem statement and success criteria
- Target users and their goals
- Core functionality and user stories
- Functional scope (MVP vs. future phases)
- Non-functional requirements (performance, security, scalability)
- Compliance requirements (conditional)
- Technical constraints and preferences
- Timeline and resource constraints

**FR-2.7** The interviewer shall probe vague answers for specificity. "Fast" becomes "< 200ms p95 response time." "Secure" becomes specific authentication, authorization, and data handling requirements.

**FR-2.8** Interview transcript and extracted requirements shall be written to `workspace/{project-name}/handoffs/002-prd-interview.md`.

**FR-2.9** The webhook-based chat workflow shall preserve the full conversation history in `workspace/{project-name}/interview-state.json`, enabling the synthesis phase to access the complete interview without relying on LLM conversation context.

### FR-3: PRD Synthesis (Phase 3)

**Trigger**: Interview phase completes.

**FR-3.1** The PRD writer agent shall synthesize interview results (and analysis handoff if present) into a structured PRD.

**FR-3.2** The PRD shall include these sections:
1. Executive Summary
2. Functional Requirements (numbered: FR-1, FR-2, etc.)
3. Non-Functional Requirements (measurable targets)
4. User Stories & Acceptance Criteria
5. Architecture Recommendations
6. Risk Assessment
7. MVP vs. Future Phase Scoping
8. Compliance Requirements (conditional — only if applicable frameworks identified in interview)

**FR-3.3** PRD files shall be versioned: `prd-[project-name]-v1.md`, `prd-[project-name]-v2.md`.

**FR-3.4** The user shall be presented with the PRD for review and can request iterative revisions. Each revision produces a new version.

**FR-3.5** PRDs describe "what" and "why," not "how." Implementation details belong in task execution.

**FR-3.6** PRDs shall be written at a level a junior developer can understand — explicit, unambiguous, no jargon without definition.

**FR-3.7** Final PRD version shall be written to `workspace/{project-name}/handoffs/003-prd-refined.md`.

### FR-4: Council Review (Phase 4 — Mandatory)

**Trigger**: PRD synthesis is finalized by the user.

**FR-4.1** The council shall consist of **core reviewers** (always present) and **specialized reviewers** (added based on PRD content). Core reviewers:

| Reviewer | Focus | Stated Biases |
|----------|-------|---------------|
| Technical Reviewer | Architecture soundness, technical risks, scope realism, missing dependencies | Prefers proven tech, values maintainability, skeptical of optimistic timelines |
| Security Reviewer | Security posture, data handling, implicit security requirements, attack surface | Worst-case threat model, demands explicit security requirements for anything touching user data |
| Executive Reviewer | ROI, strategic fit, resource justification, stakeholder alignment | Organizational value focus, questions scope that doesn't serve business goals |
| User Advocate | User story completeness, accessibility, usability, user value proposition | Champions end-user experience, pushes back on technical decisions that hurt UX |

**FR-4.2** The system shall analyze the PRD content and recommend specialized agents from the roster to join the council. Selection criteria:

| PRD Content Signal | Specialized Agent Added |
|--------------------|----------------------|
| FISMA, FedRAMP, ATO, NIST references | Compliance Reviewer — deep compliance framework expertise |
| Performance targets, SLAs, latency requirements | Performance Reviewer — scalability and performance architecture |
| Accessibility requirements, 508 compliance | Accessibility Reviewer — WCAG, assistive technology, inclusive design |
| Data privacy, PII, GDPR, data classification | Data Privacy Reviewer — data handling, retention, consent, privacy by design |
| API design, multi-service, microservices | API Design Reviewer — contract design, versioning, backward compatibility |
| Migration, legacy modernization | Migration Reviewer — risk assessment, incremental migration strategy, rollback planning |

**FR-4.3** The user shall be presented with the recommended council composition and can:
- Accept the recommended composition
- Add additional specialized agents from the roster
- Remove a recommended specialized agent (with a confirmation noting why it was recommended)

**FR-4.4** Each reviewer (core and specialized) shall independently analyze the PRD and produce 3-5 concerns or endorsements with a severity/confidence rating.

**FR-4.5** The Council Chair agent shall synthesize all reviewer feedback into:
- Consensus points (where all reviewers agree)
- Conflicts requiring resolution (where perspectives differ — both sides presented)
- Recommended PRD revisions (specific, actionable changes)
- Decisions for stakeholder (items only a human can resolve)

**FR-4.6** The user shall review council output and decide which recommendations to accept. Accepted changes produce a new PRD version.

**FR-4.7** Council review is not optional for the MVP pipeline. Every PRD passes through council before task generation.

**FR-4.8** Council output shall be written to `workspace/{project-name}/handoffs/004-council-review.md`.

**FR-4.9 Council Re-Review Gate.** After council revisions are applied to the PRD, the system shall present the user with a decision gate:

| Option | When to Use |
|--------|-------------|
| **Proceed to next phase** | Revisions were minor or mechanical (typo fixes, clarifications, scoping adjustments) |
| **Reconvene council for re-review** | Revisions were substantial — new sections added, architecture changed, or user made additional changes beyond what the council recommended |

The system shall **recommend re-review** when any of the following conditions are met:
- More than 3 council recommendations were accepted and applied in a single pass
- Any CRITICAL-severity finding was addressed (the fix itself may introduce new issues)
- The user made manual changes to the PRD beyond the council's recommendations
- The PRD revision delta exceeds 15% of the document (measured by section count or line count)

When reconvened, the council reviews only the changed sections (delta review), not the full PRD. The council review counter increments (e.g., `004-council-review-r2.md`) and the revision history is preserved. There is no limit on re-review cycles — the user controls when the PRD is "good enough" to proceed.

For True MVP, the re-review gate is a simple n8n form with the two options above. The recommendation logic (threshold detection) is added in Full MVP.

### FR-4.5A: PM Destination Selection (Phase 4.5)

**Trigger**: Council review is accepted and PRD is finalized.

**FR-4.5A.1** Before task generation, the system shall present the user with a destination selection form in the n8n UI:

| Option | Description | When to Use |
|--------|-------------|-------------|
| **Target Repository** | Push issues/milestones/board to the analyzed repo(s) | Single-repo projects where PM artifacts belong alongside code |
| **Separate Management Repo** | Create or select a dedicated PM repository | Multi-repo projects or when you want clean separation |
| **Custom Repository** | Specify any GitHub repo URL | Use an existing organizational PM repo |
| **Local Only** | Generate task list and issue files locally, skip GitHub push | Offline planning, preparing before committing |

**FR-4.5A.2** For multi-repo projects, the default recommendation shall be "Separate Management Repo" with cross-repo file references using the `repo-name:path/to/file` format.

**FR-4.5A.3** The selected destination shall be stored in `workspace/{project-name}/config/project.json` and used by all subsequent GitHub operations.

**FR-4.5A.4** A destination advisor prompt shall analyze project context (single vs. multi-repo, compliance requirements, team structure) and recommend the optimal destination with rationale.

### FR-5: Task Generation (Phase 5)

**Trigger**: PM destination is selected.

**FR-5.1** Task generation shall follow a two-phase process:
1. **Phase A**: Generate parent tasks (high-level, ~5-8 tasks). Present to user in n8n UI with the message: "I have generated the high-level tasks based on the PRD. Ready to generate the sub-tasks? Respond with 'Go' to proceed."
2. **Phase B**: After user confirms "Go," generate sub-tasks for each parent task.

**FR-5.2** The task generation agent shall assess the current codebase state (if a repo exists) to:
- Identify existing components that can be leveraged
- Detect architectural patterns and conventions to follow
- Find related files that need modification vs. creation
- Avoid proposing code that duplicates existing functionality

**FR-5.3** Each task shall include:
- Clear description written at a junior developer level — explicit, unambiguous, no assumed domain knowledge
- Sub-tasks with sufficient step-by-step detail that a junior developer or an AI agent can implement without additional context
- Dependency indicators (which tasks/issues must complete first)
- Estimated effort (T-shirt sizing: S/M/L/XL — no hour-based estimates)

**FR-5.4** The output shall include a "Relevant Files" section listing every file expected to be created or modified, with a one-line description and corresponding test files. For multi-repo projects, file paths use the `repo-name:path/to/file` format.

**FR-5.5** Task list shall be saved to `workspace/{project-name}/tasks/tasks-prd-[project-name].md`.

**FR-5.6** After task generation, the n8n workflow shall push to the selected GitHub destination using n8n's GitHub nodes:

1. **Milestones**: Create milestones with due dates derived from the PRD timeline.
2. **Issues**: Create GitHub Issues for each parent task. Each issue is dual-purpose — written so either a junior human developer or an AI agent can pick it up and execute. The issue structure:
   - **Title**: Clear, action-oriented task title
   - **Body** (human-readable, junior developer level):
     - Description of what needs to be built and why, written in plain language
     - Sub-tasks as a checklist
     - Acceptance criteria in testable language
   - **AI Agent Notes section** (appended at the bottom of the body): A dedicated section containing additional context that an AI agent needs for autonomous execution. Human developers can ignore this section. (See FR-5.8 for contents.)
   - **Labels**: Feature area, T-shirt size estimate, `agent-ready` label
   - **Milestone**: Assignment to the appropriate milestone
3. **Project Board**: If a GitHub Project board does not exist for the target repo, create one. Configure it with kanban view (To Do / In Progress / Done) and roadmap view with milestone-based timelines.
4. **Board Population**: Add all created issues to the project board.

**FR-5.7** The markdown task list in `workspace/{project-name}/tasks/` remains the local working copy. GitHub Issues are the source of truth for project tracking once pushed.

**FR-5.8** Every GitHub Issue shall include an **AI Agent Notes** section appended below the human-readable body, separated by a horizontal rule and clearly labeled `## AI Agent Notes`. This section is supplemental — a junior developer can ignore it entirely and still complete the task from the main body alone. An AI agent reads both the main body and this section for maximum context.

The AI Agent Notes section shall contain:

| Subsection | Description |
|------------|-------------|
| **Objective** | One-sentence statement of what this task accomplishes and why it matters in the context of the PRD |
| **Relevant Files** | Files to create, modify, or reference — with paths relative to repo root (or `repo-name:path` for multi-repo) and a one-line description of each file's role |
| **Existing Patterns** | Codebase conventions the agent must follow (naming, directory structure, architectural patterns discovered during analysis). Reference specific files as examples where possible. |
| **Dependencies** | Other issues/tasks that must be completed before this one. List by issue number. |
| **Technical Constraints** | Framework versions, library preferences, environment considerations (dev/test/prod), and any compliance requirements that apply |
| **Acceptance Criteria (Machine-Readable)** | Restates acceptance criteria from the main body in precise, testable form — expected inputs/outputs, test commands to run, coverage expectations |
| **Coding Standards** | Relevant subset of coding preferences: max file length, duplication avoidance, environment-awareness rules, and any task-specific constraints |
| **Out of Scope** | What the agent should explicitly NOT do while implementing this task — prevents scope creep and drift |
| **Commit Format** | Expected conventional commit prefix (feat/fix/refactor/etc.) and reference to this issue number |

**FR-5.9** The AI Agent Notes section shall be populated from:
- Analysis handoff (Phase 1) — for existing patterns, relevant files, and technical constraints
- PRD (Phase 3) — for requirements, acceptance criteria, and compliance requirements
- Council review (Phase 4) — for any concerns or constraints surfaced during review
- Coding standards skill — for coding preferences

If no analysis phase was run (greenfield), the Existing Patterns and Relevant Files subsections shall note "Greenfield — no existing codebase" and focus on the architecture recommendations from the PRD.

### FR-5.5A: Implementation Feasibility Review (Phase 5.5 — Optional)

**Trigger**: Task list is generated. User chooses to run the feasibility review before execution.

**FR-5.5A.1** Phase 5.5 is an optional gate between task generation (Phase 5) and execution (Phase 6). It convenes a **critics council** — adversarial reviewers whose mandate is to find reasons the implementation plan will fail, not to endorse it.

**FR-5.5A.2** The critics council is distinct from the Phase 4 PRD council. The PRD council reviews requirements quality (is the PRD technically sound, secure, business-aligned). The critics council reviews **buildability** — it takes the PRD *and* the task list as input and asks: can this actually be built in the stated timeline, what integration seams will break, and does the task list cover the requirements?

**FR-5.5A.3** The critics council shall consist of the following adversarial reviewers:

| Reviewer | Mandate |
|----------|---------|
| **Skeptical Implementer** | "I have to build this. What's actually impossible in the time budget?" — Counts tasks vs. available time, identifies underspecified tasks, flags hidden complexity. |
| **Scope Killer** | "This says MVP but reads like a platform. What should be cut?" — Identifies features that don't directly validate the core hypothesis, finds scope creep disguised as infrastructure. |
| **Integration Pessimist** | "Every seam between components is a failure point. Which ones will break first?" — Traces data flows across system boundaries, identifies timeout/retry gaps, flags missing error handling. |
| **Requirements Lawyer** | "The FRs contradict each other, the success criteria are unmeasurable, and the task list doesn't match the PRD." — Cross-references PRD requirements against task list, finds gaps and contradictions, verifies success criteria are testable. |
| **Outsider User** | "I'm the secondary persona. Can I actually use this?" — Evaluates the system from a non-primary-user perspective, identifies assumed knowledge, flags UX gaps. |

**FR-5.5A.4** Each critic shall independently analyze the PRD + task list and produce findings with severity ratings (CRITICAL, HIGH, MEDIUM, LOW). Unlike the Phase 4 council, critics shall not produce endorsements — only concerns, contradictions, and risks.

**FR-5.5A.5** A chair shall synthesize all critic findings into a prioritized report:
- **Tier 1 — Fix Before Building**: Flaws that will cause implementation failure if not addressed
- **Tier 2 — Fix During Build**: Issues that won't block starting but should be resolved during implementation
- **Tier 3 — Acknowledge and Move On**: Valid concerns that are acceptable risks or deferred to a later phase

**FR-5.5A.6** The user reviews the critics council report, decides which findings to act on, and either:
- Revises the PRD and/or task list (which may trigger the FR-4.9 re-review gate if PRD changes are substantial)
- Proceeds to execution with acknowledged risks

**FR-5.5A.7** Critics council output shall be written to `workspace/{project-name}/handoffs/005.5-feasibility-review.md`.

**FR-5.5A.8** For True MVP, the critics council is not implemented as an automated workflow — it exists as a documented practice that can be performed manually (e.g., by prompting an LLM with the critics council format). The automated Phase 5.5 workflow is added in Full MVP.

### FR-6: Task Execution — Dual-Purpose (Phase 6)

**Trigger**: Task list is generated and GitHub Issues are pushed.

**FR-6.0** Phase 6 issues are designed for dual-purpose execution — either a human developer or an AI agent (Claude Code or Continue.Dev) can pick up any issue and complete it. When an AI agent executes, it reads both the main issue body and the AI Agent Notes section. When a human developer executes, the main body alone is sufficient. The user decides at execution time whether a given issue is assigned to a human or an AI agent, and which AI coding tool to use.

**FR-6.1** Phase 6 is hybrid. n8n orchestrates task assignment and progress tracking. The actual code implementation happens outside n8n — in a terminal via Claude Code, in an IDE via Continue.Dev, or by a human developer with their preferred editor. n8n's role is:
- Present the next available task (respecting dependencies)
- Provide the full issue context (body + AI Agent Notes)
- Track sub-task completion status
- Sync progress to GitHub (close issues, move board cards, update PRs)
- Maintain CHANGELOG.md entries

**FR-6.2** When an AI agent executes a task, it shall read the corresponding GitHub Issue — both the main body and the AI Agent Notes section — to load full implementation context.

When a human developer executes a task, the main issue body (description, sub-task checklist, acceptance criteria) provides everything needed.

**FR-6.3** For each sub-task, the executor (human or AI agent) shall:
1. Read the sub-task description and, if AI agent, the AI Agent Notes from the parent issue
2. Check the existing codebase for related code, patterns, and utilities before writing new code
3. Implement the sub-task following the coding standards and existing patterns
4. Write or update tests as specified by the acceptance criteria
5. Mark the sub-task as complete

**FR-6.4** When all sub-tasks under a parent task are complete, the executor shall:
1. Run the full test suite
2. Only if tests pass: stage changes (`git add`)
3. Remove any temporary files and temporary code
4. Commit to a feature branch using conventional commit format (e.g., `git commit -m "feat: add payment validation" -m "- Validates card type" -m "Closes #42"`)
5. Push the feature branch and create a Pull Request via `gh pr create` with:
   - Title matching the conventional commit message
   - Body containing: one-paragraph summary, sub-task completion list, linked issue reference, test results summary
   - Base branch: `main` (or configured default)

**FR-6.5** PRs serve as the review gate. A dedicated **Code Review Agent** from the roster handles automated PR review. The user selects one of three review modes per PR:

| Mode | Workflow | When to Use |
|------|----------|-------------|
| **Human Review** | PR stays open; user (or team) reviews on GitHub, merges when satisfied | Default. For critical changes, complex logic, security-sensitive code. |
| **Agent Review → Human Merge** | Code Review Agent analyzes the diff, posts structured review comments (issues found, suggestions, approval/request-changes), then waits for user to merge | Mid-confidence. Agent catches issues but human makes the final call. |
| **Agent Review → Auto-Merge** | Code Review Agent reviews, and if the review passes with no blocking issues, merges via `gh pr merge --merge` and notifies user. If blocking issues found, escalates to human. | High-confidence. Routine changes, style fixes, documentation. |

The Code Review Agent shall review against:
- The coding standards skill (three core principles, 10 categories)
- The acceptance criteria from the GitHub Issue
- The existing codebase patterns identified during analysis
- Test coverage expectations from the AI Agent Notes

Default mode is Human Review.

**FR-6.6** Upon PR merge:
1. Append an entry to `CHANGELOG.md` in the repo root, using the PR title, description, and linked issue as source material
2. The entry shall follow Keep a Changelog format (https://keepachangelog.com) with the conventional commit prefix mapped to the appropriate category:
   - `feat:` → Added
   - `fix:` → Fixed
   - `refactor:` → Changed
   - `docs:` → Changed
   - `perf:` → Changed
   - `security:` → Security
   - `chore:` / `build:` / `ci:` → omit from changelog unless significant
3. Close the linked GitHub Issue
4. Move the project board card from "In Progress" to "Done"

**FR-6.7** The implementation agent shall write a task step summary to `workspace/{project-name}/tasks/summary/task-[num]-summary.md` after each sub-task completion.

**FR-6.8** The implementation agent shall enforce coding standards as defined in the coding standards skill. The standards are organized around three core principles, with best practices flowing from each:

**Core Principles:**
1. **Clarity over cleverness** — Code is read far more than it is written. Every line should be immediately understandable by someone who has never seen the codebase.
2. **Simplicity first** — The simplest solution that meets the requirement is the correct solution. Complexity is a cost, not a feature.
3. **Readability is non-negotiable** — If code needs a comment to explain what it does (not why), it needs to be rewritten.

**Best Practices (derived from core principles):**

*Naming & Readability:*
- Names reveal intent — no abbreviations unless universally understood in the domain
- Functions named for what they do; variables named for what they contain
- Booleans read as questions: `isValid`, `hasPermission`, `canExecute`
- No single-letter variables outside loop counters
- Consistent naming conventions per language (camelCase, PascalCase, snake_case as appropriate)

*Function Design:*
- Functions do one thing — if you need "and" to describe it, split it
- Functions fit on one screen (~25 lines); extract when larger
- Maximum 3-4 parameters; use an options/config object beyond that
- Early returns and guard clauses over nested conditionals
- Pure functions preferred — minimize side effects
- Flat is better than nested — maximum 3 levels of indentation

*File & Code Structure:*
- Files under 200-300 lines; refactor at that threshold
- Group related code together; separate concerns (business logic, data access, presentation)
- Consistent file organization per language conventions
- Delete dead code — git has history; no commented-out code blocks

*Comments & Documentation:*
- Code is self-documenting through naming; comments explain "why," never "what"
- Document public APIs, interfaces, and non-obvious architectural decisions
- TODO comments include context and issue/ticket reference

*Error Handling:*
- Handle errors explicitly — never swallow exceptions silently
- Fail fast and fail loudly in development; fail gracefully in production
- Error messages are actionable: what happened, what was expected, what to do next
- Log errors with context (what operation, what inputs, what state)

*Testing:*
- Write tests alongside implementation, not after
- Test behavior, not implementation details
- Each test tests one thing; test names describe the scenario (`should_reject_expired_tokens`)
- No mocked or stubbed data outside test environments
- Arrange-Act-Assert pattern

*Duplication & Abstraction:*
- Check existing codebase for related code before writing anything new
- No code duplication — but prefer duplication over the wrong abstraction
- Extract shared code only when a pattern appears 3+ times
- Shared utilities belong in clearly named, discoverable modules

*Environment & Configuration:*
- Environment-aware code (dev, test, prod) — behavior adapts to environment
- No hardcoded configuration values; externalize to config files or environment variables
- No `.env` overwrites without explicit user confirmation
- Secrets never in code — always from environment variables or a secrets manager

*Dependencies:*
- Prefer standard library over third-party when the functionality is comparable
- Evaluate dependency health before adding (maintenance activity, bundle size, known vulnerabilities)
- Pin dependency versions in lock files
- Avoid adding dependencies for trivial functionality

*Changes & Scope:*
- Changes scoped to what was requested — no drive-by refactors without approval
- When fixing bugs, understand root cause before applying a fix; exhaust existing implementation options before introducing new patterns
- If a new pattern is needed, remove the old one — don't leave two ways to do the same thing
- One PR, one concern — don't bundle unrelated changes

**FR-6.9** The "Relevant Files" section in the task list shall be maintained as implementation progresses — new files added, descriptions updated.

**FR-6.10** n8n shall update GitHub Issues as work progresses: close completed issues upon PR merge with a summary comment, and move cards on the project board from "In Progress" to "Done."

**FR-6.11** If the agent encounters ambiguity not resolved by the AI Agent Notes, it shall pause and ask the user rather than making assumptions. The resolution shall be added as a comment on the GitHub Issue for future reference.

**FR-6.12** When all tasks are complete and all PRs are merged, the system shall compile `CHANGELOG.md` entries into release notes and present them to the user for review. The user can then tag a release and publish release notes to GitHub Releases.

### FR-7: Workflow Orchestration (n8n)

**FR-7.1** n8n shall be the primary orchestration layer. Each phase is implemented as an n8n workflow or sub-workflow.

**FR-7.2** The master workflow shall manage phase sequencing:
- Track which phases are complete via workflow variables
- Validate handoff artifacts between phases (check required sections exist)
- Allow users to trigger any phase independently (for re-runs or partial pipelines)
- Present status dashboard showing current phase, completed phases, and next actions

**FR-7.3** Handoff artifacts shall be validated against contract schemas before phase advancement. Validation is an n8n workflow node that reads the contract schema and checks the handoff artifact.

**FR-7.4** Cross-phase decisions shall be recorded in `workspace/{project-name}/config/decisions.json`.

**FR-7.5** The n8n UI shall provide:
- Manual trigger buttons for each phase
- A status dashboard (via n8n workflow that reads state and returns formatted output)
- Chat interface for the interview phase (webhook-based chat UI)
- Form inputs for configuration (repo URLs, PM destination, project metadata)

### FR-8: Session Resilience

**FR-8.1** Each phase is independently resumable. n8n workflow executions persist inputs and outputs. If a phase fails mid-execution, it can be re-triggered with the same inputs.

**FR-8.2** All LLM calls include full context (agent prompt + skill content + prior handoff) assembled by the n8n workflow and routed through the model router. There is no reliance on any model's conversation memory between workflow executions.

**FR-8.3** Handoff artifacts on disk serve as the source of truth. If n8n's execution history is cleared, the pipeline can be resumed from the last handoff file.

**FR-8.4 LLM Call Resilience.** Every n8n HTTP Request node that calls an LLM provider (Ollama, Anthropic, Bedrock, OpenAI-compatible) shall be configured with:
1. **Timeout**: 300 seconds (5 minutes). Local Ollama inference with the quality model can take 60-90 seconds for complex outputs; model swaps (unloading one model, loading another from disk to VRAM) add 15-30 seconds. The 300-second timeout accommodates worst-case scenarios including cold starts.
2. **Retry**: 3 attempts with 30-second exponential backoff on failure (timeout, 5xx, connection refused).
3. **Partial result preservation**: If a multi-step workflow (e.g., council review with 6+ sequential LLM calls) fails mid-sequence, completed reviewer outputs shall be preserved. The user can retry the failed step without re-running earlier steps.
4. **Connectivity pre-check**: The first node in any workflow that uses Ollama shall verify connectivity (`GET http://host.docker.internal:11434/api/tags`). If unreachable, return a clear error message to the user immediately rather than hanging on the first LLM call.
5. **Model warm-up**: Before the council chair synthesis call (which requires swapping from speed model to quality model), send a trivial warm-up request to the quality model endpoint to force the model load. This prevents the synthesis call from including both model load time and inference time.

### FR-9: Professional Documentation

**FR-9.1** The project shall include a professionally written `README.md` as the primary onboarding document. It is not optional — it is a required deliverable of the MVP.

**FR-9.2** The README shall be structured for three audiences in order of priority:
1. **First-time user** — understands what this system does and whether it's relevant to them within 30 seconds of reading
2. **Getting started user** — can go from Docker Compose up to running their first phase within 15 minutes by following the README alone
3. **Returning user** — can quickly reference phase workflows, configuration options, and troubleshooting

**FR-9.3** The README shall include the following sections:

| Section | Content |
|---------|---------|
| **Header / Badge bar** | Project name, one-line description, badges (license, Docker, n8n) |
| **What This Is** | 2-3 sentence plain-language explanation. No jargon. |
| **How It Works** | Visual overview of the 6-phase pipeline (Mermaid diagram). Brief description per phase. |
| **Quick Start** | Docker Compose setup on WSL2: clone, `docker compose up`, access n8n UI, run first phase. |
| **Prerequisites** | Table: Docker, Docker Compose, Git, `gh` CLI, Ollama (local inference), Claude Code (for Phase 6). For True MVP, Ollama with `qwen3.5:27b` and `qwen3.5:35b-a3b` pulled. For Full MVP, optionally add API providers: Anthropic API key, AWS Bedrock credentials, or OpenAI-compatible endpoint. |
| **Architecture** | Diagram showing n8n, model router, LLM providers (Ollama local/Anthropic/Bedrock/OpenAI-compatible), GitHub, and file system interaction. |
| **Phase Guide** | Each phase: what it does, how to trigger it, what it produces, what to review. |
| **Multi-Repo Analysis** | How to configure and run analysis across multiple repositories. |
| **PM Destination Selection** | How to choose where GitHub Issues are created. |
| **Dual-Purpose Issues** | Explanation of human body + AI Agent Notes format with visual example. |
| **PR Review & Changelog** | Three review options, CHANGELOG.md maintenance, release creation. |
| **Configuration** | Environment variables, LLM provider setup (Ollama local default, Anthropic/Bedrock/OpenAI-compatible as optional API fallbacks), model registry and per-step model assignment, n8n settings, agent prompt customization. |
| **FAQ / Troubleshooting** | Common issues, n8n restart recovery, API errors, GitHub auth. |
| **Contributing** | How to improve agents, add skills, export/import workflows. |
| **License** | License declaration. |

### FR-10: Model Configuration & Flexibility

**FR-10.1** Every n8n workflow node that makes an LLM call shall be independently configurable to use any supported model provider and model. There shall be no hardcoded model or provider at any step — the user selects which model handles each task.

**FR-10.2** The system shall support the following LLM providers:

| Provider | Connection | Use Case |
|----------|-----------|----------|
| **Ollama** (local, default) | HTTP endpoint (`host.docker.internal:11434`) | Qwen3.5-27B, Qwen3.5-35B-A3B, or any Ollama-hosted model — local inference on GPU, zero cost, no API keys |
| **Anthropic API** (direct) | API key, model ID | Claude Opus, Sonnet, Haiku — API fallback for frontier quality |
| **AWS Bedrock** | AWS credentials + region | Claude models in gov/compliance environments |
| **OpenAI-compatible** | Base URL + API key | LM Studio, vLLM, text-generation-webui, or any endpoint that implements the OpenAI chat completions format |

**FR-10.3** The system shall maintain a **model registry** (`workspace/config/models.json`) that defines:
- All available providers and their connection settings (endpoints, credentials references)
- All available models per provider (model ID, display name, context window size, cost tier)
- **Default model assignments per workflow step** — a named mapping from every LLM call point to its recommended model

**FR-10.4** Default model assignments shall be provided as a starting configuration. The recommended defaults use a two-model Ollama strategy for local inference, with API models as documented upgrade options:

| Workflow Step | Local Default (Ollama) | API Upgrade Option | Rationale |
|--------------|----------------------|-------------------|-----------|
| Analysis — tech stack detection | `qwen3.5:35b-a3b` (speed) | Sonnet | Fast classification task |
| Analysis — per-repo deep analysis | `qwen3.5:27b` (quality) | Sonnet | Handles large context, complex analysis |
| Analysis — cross-repo synthesis | `qwen3.5:27b` (quality) | Opus | Complex multi-source reasoning |
| Interview — conversation | `qwen3.5:35b-a3b` (speed) | Sonnet | Interactive chat needs fast response |
| Requirements extraction | `qwen3.5:27b` (quality) | Sonnet | Structured extraction, precision matters |
| PRD synthesis | `qwen3.5:27b` (quality) | Opus | Complex document generation requiring nuance |
| Council — Core Reviewers (4) | `qwen3.5:35b-a3b` (speed) | Sonnet | Focused analysis, single perspective; speed for sequential calls |
| Council — Specialized Reviewers | `qwen3.5:35b-a3b` (speed) | Sonnet | Focused analysis, domain-specific perspective |
| Council — Chair synthesis | `qwen3.5:27b` (quality) | Opus | Multi-perspective reasoning, conflict resolution |
| PM destination advisor | `qwen3.5:35b-a3b` (speed) | Haiku | Lightweight recommendation |
| Task generation — parent tasks | `qwen3.5:27b` (quality) | Sonnet | Structured decomposition |
| Task generation — sub-tasks | `qwen3.5:27b` (quality) | Sonnet | Structured decomposition |
| Issue body generation | `qwen3.5:35b-a3b` (speed) | Sonnet | Template-following with context integration |
| Code Review Agent | `qwen3.5:27b` (quality) | Opus or Sonnet | Requires strong reasoning to evaluate code quality |
| Handoff validation | `qwen3.5:35b-a3b` (speed) | Haiku | Schema checking, lightweight |

These defaults can be overridden globally (change the default for all projects) or per-project (change for a specific workflow run).

**FR-10.5** Each LLM workflow node shall resolve its model at execution time by checking, in priority order:
1. **Runtime override** — if the user selects a specific model when triggering the workflow or step
2. **Project-level override** — if `workspace/{project-name}/config/project.json` specifies a model for this step
3. **Model registry default** — the default assignment from `workspace/config/models.json`
4. **System fallback** — if no configuration exists, use the Ollama Qwen3.5-27B model as the default (or fail with a clear error if Ollama is not running and no providers are configured)

**FR-10.6** The n8n workflow shall implement model routing through a shared utility sub-workflow (or Code node) that:
- Accepts: the step name, system prompt, user content, and any optional model override
- Resolves: which provider and model to use (per FR-10.5 priority chain)
- Formats: the API request according to the selected provider's format (Anthropic Messages API, OpenAI chat completions, or Ollama API)
- Returns: the model's response in a normalized format regardless of provider

This ensures all LLM nodes use a single, consistent integration layer rather than each node having its own provider-specific configuration.

**FR-10.7** The model registry shall include context window sizes for each configured model. The system shall use this for the context budget system (FR-10.13).

**FR-10.8** The n8n UI shall provide:
- A configuration form for adding/editing providers and models in the registry (Full MVP)
- A model assignment view showing which model is assigned to each workflow step (Full MVP)
- Runtime model selection when manually triggering a workflow or step (dropdown of available models)

**FR-10.9** When using Ollama local models, the system shall:
- Verify the Ollama service is reachable before starting a workflow
- List available models from the Ollama API (`/api/tags`)
- Support pulling new models on demand (`/api/pull`)
- Handle longer response times gracefully (local models may be slower than cloud APIs)

**FR-10.10** The system shall log the model used for each workflow step in the execution record, enabling:
- Cost tracking (cloud API calls)
- Quality comparison (same workflow run with different models)
- Performance benchmarking (response time per model per step)
- **Reproducibility audit**: For each pipeline run, record the Ollama model digest (SHA256 from `/api/show`) or API model version in `workspace/{project-name}/config/decisions.json`. This enables tracing which exact model version produced which artifacts — critical for gov contract reproducibility.

**FR-10.11 Progressive Configuration.** The system shall support a zero-friction onboarding path with local-first defaults:

| Level | What the User Does | What the System Does |
|-------|-------------------|---------------------|
| **Zero-config start** | Installs Ollama, pulls `qwen3.5:27b` and `qwen3.5:35b-a3b`, runs `docker compose up` | Detects Ollama at `host.docker.internal:11434`. Auto-generates `models.json` with Ollama provider, both Qwen3.5 models, and per-step assignments (35B-A3B for speed steps, 27B for quality steps). No API keys required. |
| **Add an API provider** | Runs a "Configure Providers" workflow in n8n UI | Walks through: select provider type (Anthropic/Bedrock/OpenAI-compatible) → enter endpoint/credentials → test connection → list available models → update models.json. No JSON editing required. |
| **Customize model assignments** | Runs a "Model Assignments" workflow in n8n UI | Shows each workflow step with its current model assignment. User selects from dropdown of available models per step. Updates models.json. |
| **Power-user escape hatch** | Edits models.json and agents.json directly | Full control over all configuration. JSON schema documented in README. |

The True MVP (Weeks 1-2) uses Ollama as the sole provider with a two-model strategy: Qwen3.5-35B-A3B (fast, 60-100 tok/s, 3B active) for conversational and throughput-sensitive steps, and Qwen3.5-27B (precise, 15-25 tok/s, 27B dense) for quality-critical reasoning steps. No API keys or cloud accounts required. The model router is introduced in Full MVP (Weeks 3-5) with progressive configuration and API provider support.

**FR-10.11A Per-Step Model Assignments (True MVP Defaults).** This table defines the True MVP model assignments using direct Ollama API calls. For the full model registry including API upgrade options (Full MVP), see FR-10.4.

| Pipeline Step | Default Model | Context Window | Rationale |
|--------------|--------------|----------------|-----------|
| Interview Agent | `qwen3.5:35b-a3b` | 128K | Interactive chat needs speed for responsive UX |
| Requirements Extraction | `qwen3.5:27b` | 128K | Structured extraction benefits from dense reasoning |
| PRD Writer (synthesis) | `qwen3.5:27b` | 128K | Quality-critical: synthesizing interview into structured PRD sections |
| Council Reviewers (core 4) | `qwen3.5:35b-a3b` | 128K | Produces 500-1000 token reviews; format adherence is simpler; speed matters for 4-6 sequential calls |
| Council Chair (synthesis) | `qwen3.5:27b` | 128K | Hardest reasoning task: synthesize 4-6 reviews + full PRD into coherent recommendation |
| Handoff Validation | `qwen3.5:35b-a3b` | 128K | Contract checking is lightweight; speed model or small model works |

These defaults are overridable per-step via models.json once the model router is introduced in Full MVP.

**FR-10.11B Model Loading Strategy.** To minimize GPU model swap overhead during sequential LLM calls (especially council review with 4-6 calls), the workflow shall batch calls by model:
- All speed-model calls execute first (e.g., all 4 core reviewers), then
- Swap to quality model once for remaining calls (e.g., council chair synthesis)

This eliminates intermediate model swaps that each incur 15-30 seconds of GPU I/O on a single-GPU setup. For True MVP, this means the council workflow orders its nodes: reviewers (all speed model) → chair (quality model), not interleaved. If a user configures all steps to use the same model (single-model mode), no swaps occur at all.

**FR-10.12 Prompt Tiers.** Each agent prompt shall support multiple tiers to handle model capability differences:

| Tier | Target Models | Prompt Style |
|------|--------------|-------------|
| **frontier** | Claude Opus, GPT-4o, Qwen3.5-397B, GLM-5 | Full prompt with nuanced instructions, complex output schemas, multi-step reasoning |
| **strong** | Claude Sonnet, Qwen3.5-27B, Qwen3-Coder-Next | Standard prompt with explicit formatting instructions and structured output |
| **capable** | Claude Haiku, Qwen3.5-35B-A3B, Qwen3-8B, Phi-4 | Simplified prompt with very explicit output format, shorter instructions, single-step reasoning |

Each agent's prompt file shall include tier markers (e.g., `<!-- tier:frontier -->`, `<!-- tier:strong -->`, `<!-- tier:capable -->`) that delimit the prompt content for each tier. The model router selects the appropriate tier based on the resolved model's `tier` field in models.json.

For True MVP, all prompts are written at a single tier targeting the quality model (`qwen3.5:27b`). The same prompt is sent to both quality and speed models — the speed model either handles it or contract validation catches the failure. Tier differentiation (separate prompt variants per model capability level) is added in Full MVP alongside the model router and multi-provider support.

**FR-10.13 Context Budget System.** The model router shall manage context consumption per step:

1. Each workflow step declares a **context budget allocation** in the model registry:
   - `system_prompt_budget`: percentage reserved for agent prompt + skills (default: 25%)
   - `prior_context_budget`: percentage for handoff content and prior phase outputs (default: 50%)
   - `response_budget`: percentage reserved for model response (default: 25%)

2. Before executing an LLM call, the router calculates approximate token count of the assembled input. If it exceeds 80% of the model's context window:
   - **Warning**: Log that context is approaching limits
   - **Summarization**: For prior context, call a lightweight model to produce a condensed summary before passing to the primary model
   - **Suggestion**: Recommend a model with a larger context window

3. The **council chair** specifically receives: reviewer executive summaries (not full reviews) + PRD executive summary and requirements (not full PRD). Full documents are available if the chair's model has sufficient context.

4. Token usage per step is logged for cost monitoring and optimization.

### FR-11: Agent Roster & Skills

**FR-11.1 MVP Roster (Simplified).** For MVP, the agent roster is the **directory of prompt files** under `prompts/`. Each agent is defined by its prompt file and its paired skill files. There is no JSON registry for MVP — the roster is the filesystem structure itself.

Adding a new agent means: (1) create a prompt file, (2) reference the relevant skill files in the prompt's header, (3) add the agent's LLM call node in the appropriate n8n workflow. Removing an agent means disabling its node in the workflow.

The full JSON-based agent registry (`agents.json`) with trigger-based auto-selection, dashboard view, and programmatic management is deferred to **Phase 2** of the product roadmap.

**FR-11.2 Council Composition (MVP).** For MVP, the council review workflow presents a **manual selection form**:
- Core reviewers (Technical, Security, Executive, User Advocate, Chair) are always included
- Specialized reviewers are listed as checkboxes: ☐ Compliance ☐ Performance ☐ Accessibility ☐ Data Privacy ☐ API Design ☐ Migration
- The user checks which specialists to include based on their knowledge of the project
- Each checked specialist's prompt file is loaded and its LLM call node is executed

Trigger-based auto-selection (scanning PRD content for keywords and recommending specialists) is deferred to **Phase 2**.

**FR-11.3 Agents Are Built with Skills.** Every agent in the system shall be paired with one or more **skill documents** that give it domain expertise. The agent's prompt defines its role, personality, and methodology. The skills provide the domain knowledge it applies. Both are injected into every LLM call for that agent.

**FR-11.4 Complete Agent-to-Skills Mapping.** The following table defines every agent and the skills it uses. Skill files marked with ★ are new (added to support this mapping). All other skills existed previously.

| Agent | Prompt File | Skills Injected | What the Skills Provide |
|-------|-------------|----------------|------------------------|
| **Codebase Analyst** | `prompts/analysis/codebase-analyst.md` | `skills/analysis/dotnet-patterns.md` (conditional), `skills/analysis/python-patterns.md` (conditional), `skills/analysis/typescript-patterns.md` (conditional), `skills/analysis/aws-cdk-patterns.md` (conditional), `skills/analysis/gov-compliance-discovery.md`, `skills/analysis/tech-debt-assessment.md`, `skills/analysis/multi-repo-analysis.md` (if multi-repo) | Language-specific patterns to look for, compliance framework detection rules, tech debt scoring methodology, cross-repo dependency analysis |
| **PRD Interviewer** | `prompts/prd-development/prd-interviewer.md` | `skills/prd/stakeholder-interview.md`, `skills/prd/requirements-engineering.md` | Interview question bank, coverage checklist, probing techniques, requirements elicitation methodology |
| **PRD Writer** | `prompts/prd-development/prd-writer.md` | `skills/prd/requirements-engineering.md`, `skills/prd/gov-prd-requirements.md` (conditional) | Requirements structuring patterns, measurability standards, gov-specific PRD sections and language |
| **Technical Reviewer** | `prompts/prd-council/core/technical-reviewer.md` | ★ `skills/council/technical-review.md` | Architecture evaluation framework, feasibility assessment checklist, scope realism benchmarks, technology risk indicators |
| **Security Reviewer** | `prompts/prd-council/core/security-reviewer.md` | ★ `skills/council/security-review.md`, `skills/council/fisma-compliance-check.md` (conditional), `skills/council/fedramp-review.md` (conditional) | Threat modeling methodology, security requirements checklist, compliance control mapping (FISMA/FedRAMP when applicable) |
| **Executive Reviewer** | `prompts/prd-council/core/executive-reviewer.md` | ★ `skills/council/business-alignment.md` | ROI analysis framework, strategic fit assessment, resource justification methodology, stakeholder alignment checklist |
| **User Advocate** | `prompts/prd-council/core/user-advocate.md` | ★ `skills/council/ux-review.md` | User journey validation methodology, accessibility baseline, usability heuristics, user value scoring |
| **Council Chair** | `prompts/prd-council/core/council-chair.md` | ★ `skills/council/council-synthesis.md` | Multi-perspective synthesis framework, conflict resolution patterns, recommendation prioritization methodology, consensus detection |
| **Compliance Reviewer** | `prompts/prd-council/specialized/compliance-reviewer.md` | `skills/council/fisma-compliance-check.md`, `skills/council/fedramp-review.md`, ★ `skills/council/compliance-deep-dive.md` | Deep FISMA/FedRAMP control family analysis, impact level assessment, inherited vs. implemented controls, ATO pathway gap analysis |
| **Performance Reviewer** | `prompts/prd-council/specialized/performance-reviewer.md` | ★ `skills/council/performance-review.md` | Performance architecture patterns, scalability assessment, SLA validation, bottleneck identification, load testing requirements |
| **Accessibility Reviewer** | `prompts/prd-council/specialized/accessibility-reviewer.md` | ★ `skills/council/accessibility-review.md` | WCAG 2.1 conformance checklist, Section 508 requirements, assistive technology compatibility, inclusive design patterns |
| **Data Privacy Reviewer** | `prompts/prd-council/specialized/data-privacy-reviewer.md` | ★ `skills/council/data-privacy-review.md` | Data classification framework, PII handling requirements, GDPR/CCPA compliance, privacy by design patterns, consent and retention policies |
| **API Design Reviewer** | `prompts/prd-council/specialized/api-design-reviewer.md` | ★ `skills/council/api-design-review.md` | API contract design principles, versioning strategies, backward compatibility checklist, error handling conventions, rate limiting patterns |
| **Migration Reviewer** | `prompts/prd-council/specialized/migration-reviewer.md` | ★ `skills/council/migration-review.md` | Migration risk assessment framework, incremental migration patterns (strangler fig, branch by abstraction), rollback planning, data migration validation, parallel run methodology |
| **Destination Advisor** | `prompts/pm-framework/destination-advisor.md` | `skills/pm/gov-contract-planning.md` | Gov contract PM patterns, multi-repo management practices, organizational repo conventions |
| **PM Architect** | `prompts/pm-framework/pm-architect.md` | `skills/pm/task-decomposition.md`, `skills/pm/agile-estimation.md`, `skills/pm/gov-contract-planning.md` (conditional) | Task decomposition methodology, dependency mapping, T-shirt estimation framework, milestone derivation, gov-specific planning constraints |
| **Issue Generator** | `prompts/pm-framework/issue-generator.md` | `skills/pm/github-issues-format.md`, `skills/execution/coding-standards.md` | Dual-purpose issue template, AI Agent Notes schema, label taxonomy, coding standards reference for issue context |
| **Implementation Agent** | `prompts/task-execution/implementation-agent.md` | `skills/execution/coding-standards.md`, `skills/execution/commit-protocol.md` | Three core principles + 10 best practice categories, conventional commit format, PR creation protocol, feature branch workflow |
| **Code Review Agent** | `prompts/task-execution/code-review-agent.md` | `skills/execution/coding-standards.md`, `skills/execution/commit-protocol.md`, ★ `skills/execution/code-review.md` | Coding standards to review against, commit protocol validation, diff analysis methodology, review comment format, auto-merge decision criteria |
| **Skeptical Implementer** | `prompts/critics-council/skeptical-implementer.md` | ★ `skills/critics/implementation-feasibility.md` | Task counting methodology, time estimation heuristics, hidden complexity detection, underspecified task identification |
| **Scope Killer** | `prompts/critics-council/scope-killer.md` | ★ `skills/critics/scope-analysis.md` | MVP scope validation, feature-to-hypothesis tracing, scope creep detection patterns |
| **Integration Pessimist** | `prompts/critics-council/integration-pessimist.md` | ★ `skills/critics/integration-risk.md` | Data flow tracing across system boundaries, timeout/retry gap detection, error handling audit, failure mode analysis |
| **Requirements Lawyer** | `prompts/critics-council/requirements-lawyer.md` | ★ `skills/critics/requirements-audit.md` | Cross-referencing PRD FRs against task list, success criteria testability, contradiction detection, coverage gap analysis |
| **Outsider User** | `prompts/critics-council/outsider-user.md` | ★ `skills/critics/ux-accessibility-audit.md` | Secondary persona journey validation, assumed knowledge detection, onboarding friction assessment |
| **Critics Chair** | `prompts/critics-council/critics-chair.md` | `skills/council/council-synthesis.md` | Multi-perspective synthesis (reuses existing council synthesis skill), tiered prioritization framework |

**FR-11.5 New Skill Documents.** The following skill documents are new (marked with ★ above) and must be created:

| Skill File | Purpose |
|-----------|---------|
| `skills/council/technical-review.md` | Architecture evaluation framework, feasibility checklists, scope realism benchmarks |
| `skills/council/security-review.md` | Threat modeling methodology, security requirements checklist, attack surface analysis |
| `skills/council/business-alignment.md` | ROI analysis framework, strategic fit assessment, resource justification |
| `skills/council/ux-review.md` | User journey validation, usability heuristics, accessibility baseline |
| `skills/council/council-synthesis.md` | Multi-perspective synthesis, conflict resolution, recommendation prioritization |
| `skills/council/compliance-deep-dive.md` | Deep compliance framework analysis beyond basic discovery |
| `skills/council/performance-review.md` | Performance architecture patterns, SLA validation, bottleneck identification |
| `skills/council/accessibility-review.md` | WCAG 2.1 checklist, Section 508 requirements, inclusive design patterns |
| `skills/council/data-privacy-review.md` | Data classification, PII handling, privacy by design, consent/retention |
| `skills/council/api-design-review.md` | API contracts, versioning, backward compatibility, error conventions |
| `skills/council/migration-review.md` | Migration risk assessment, strangler fig, rollback planning, data migration |
| `skills/execution/code-review.md` | Diff analysis methodology, review comment format, auto-merge criteria |
| `skills/critics/implementation-feasibility.md` | Task counting, time estimation, hidden complexity patterns, underspecification detection |
| `skills/critics/scope-analysis.md` | MVP validation methodology, hypothesis-to-feature tracing, scope creep indicators |
| `skills/critics/integration-risk.md` | System boundary analysis, timeout/retry auditing, failure mode enumeration |
| `skills/critics/requirements-audit.md` | FR-to-task cross-referencing, contradiction detection, success criteria validation |
| `skills/critics/ux-accessibility-audit.md` | Persona journey mapping, assumed knowledge detection, onboarding friction scoring |

**FR-11.6 Skill Injection.** When the model router executes an LLM call for an agent, it shall:
1. Read the agent's prompt file
2. Read all skill files associated with that agent (per FR-11.4)
3. Conditionally include/exclude skills based on project context (e.g., gov-compliance skills only when compliance frameworks apply, language-specific skills only when that language is detected)
4. Assemble the full context: system prompt (from prompt file) + skill content + prior handoff content + user input
5. Apply the context budget system (FR-10.13) if the assembled context exceeds limits

**FR-11.7 Adding New Agents.** To add a new agent:
1. Create a prompt file in the appropriate `prompts/` subdirectory
2. Create or identify the skill files the agent needs
3. Add an LLM call node in the relevant n8n workflow, configured with the prompt file path and skill file paths
4. (Full MVP) Add a model assignment for the agent's workflow step in models.json

**FR-11.8 The Code Review Agent** shall be a dedicated agent with:
- A specialized prompt focused on code review best practices, diff analysis, and the project's coding standards
- Skills: coding-standards.md, commit-protocol.md, code-review.md
- Assignment to workflow step "execution.code_review"
- Configurable model (defaults to `qwen3.5:27b` quality model locally; API upgrade: Opus or Sonnet)

---

## 7. Non-Functional Requirements

### NFR-1: Performance

| Metric | Target |
|--------|--------|
| Analysis phase | < 30 minutes for repos up to 100k LOC |
| Interview phase | 15-45 minutes depending on complexity |
| PRD synthesis | < 15 minutes from interview completion |
| Council review | < 20 minutes (all reviewers + synthesis) |
| Task generation | < 15 minutes for a moderately complex PRD |
| Full pipeline (analysis → task list) | < 3 hours end-to-end |

### NFR-2: Reliability

- Handoff artifacts survive n8n restarts (file-based, not memory-dependent).
- Any phase restartable from handoff inputs without data loss.
- n8n workflow validation nodes prevent incomplete handoffs from advancing.
- Task step summaries provide recovery breadcrumbs if context is lost during execution.

### NFR-3: Usability

- Getting started requires only: Ollama installed with two models pulled (`qwen3.5:27b` and `qwen3.5:35b-a3b`), then `docker compose up` and open browser to `localhost:5678`. No API keys, no cloud accounts, no configuration files to edit. System auto-detects Ollama and generates all configuration.
- Browser-based UI for all phases except code execution.
- Non-technical users can participate in the interview phase via the chat interface.
- Phase status visible in n8n dashboard.

### NFR-4: Extensibility

- New analysis skills addable by creating a skill markdown file and referencing it in the analysis workflow.
- New council reviewers addable by creating a prompt file + skill files and adding an LLM call node in the council workflow.
- Custom coding standards loadable as markdown files.
- New phases addable as n8n sub-workflows without modifying existing workflows.
- New LLM providers addable by extending the model router sub-workflow. New models addable by updating the model registry JSON — no workflow changes required.

### NFR-5: Security & Compliance Awareness

- System never commits sensitive data to handoff artifacts without explicit user approval.
- Compliance skills reference NIST 800-53, FedRAMP baselines, SOC 2 trust principles.
- Security findings flagged with severity ratings.
- Council security reviewer specifically validates compliance coverage.
- API keys stored in n8n credentials (encrypted), never in workflow JSON or files.

### NFR-6: Platform & Deployment

- Primary deployment: Docker Compose on WSL2 (Ubuntu).
- n8n, persistent storage, and workspace files all containerized or mounted.
- Accessible via browser from Windows host at `localhost:5678`.
- Claude Code for Phase 6 execution runs natively in WSL2 terminal.
- Git and `gh` CLI required in WSL2 for Phase 6 execution.
- No dependency on macOS — WSL2 is the primary and only platform for MVP.

---

## 8. Architecture

### 8.1 MVP Tech Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Orchestration | n8n (self-hosted, Docker) | Visual workflows, built-in AI agent node, GitHub integration, chat trigger, execution history, browser UI |
| AI Runtime | Two-model local strategy + optional API providers | True MVP: Ollama with speed model (MoE, fast) + quality model (dense, strong reasoning) — local GPU, zero cost. Full MVP adds: Anthropic API (Claude Opus/Sonnet/Haiku), AWS Bedrock (Claude for gov), OpenAI-compatible endpoints (LM Studio, vLLM). Recommended models as of Feb 2026: see FR-10.11A. |
| Model Routing | Shared n8n utility sub-workflow | Single integration layer normalizes requests/responses across all providers. Each step resolves model from registry → project config → runtime override. |
| Agent Definitions | Markdown files (system prompts) | Human-readable, version-controllable, provider-agnostic — same prompt works with any model |
| Skill Context | Markdown files | Domain knowledge documents injected alongside agent prompts |
| Handoff Artifacts | Markdown with YAML frontmatter | Structured but human-reviewable |
| Handoff Validation | n8n workflow nodes | Check required sections against contract schemas |
| State Management | n8n execution state + file artifacts + JSON config | Durable, inspectable, portable |
| GitHub Integration | n8n GitHub nodes + `gh` CLI (Phase 6) | Native n8n nodes for issues/milestones/boards; `gh` CLI for PR creation in terminal |
| Code Execution (Phase 6) | Claude Code CLI in WSL2 terminal | Native file editing, test running, git operations |
| Diagrams | Mermaid format | Token-efficient; renderable in GitHub/n8n/browser |
| Changelog | CHANGELOG.md (Keep a Changelog) | Auto-maintained from merged PRs |
| Deployment | Docker Compose on WSL2 | Single command startup, persistent volumes, browser access from Windows |

### 8.2 n8n Workflow Architecture

```
Master Orchestration Workflow
├── Input: Project configuration (repos, name, entry point)
├── Node: Initialize workspace directories
├── Node: Phase router (check current state, determine next phase)
│
├── Shared: Model Router Sub-workflow
│   ├── Input: step_name, system_prompt, user_content, model_override (optional)
│   ├── Node: Resolve model (runtime override → project config → registry default → fallback)
│   ├── Node: Format request (Anthropic / OpenAI / Ollama API format)
│   ├── Node: Execute LLM call (HTTP Request to resolved endpoint)
│   ├── Node: Normalize response (extract text content regardless of provider)
│   ├── Node: Log usage (model, tokens, latency, cost estimate)
│   └── Output: normalized response + metadata
│
├── Sub-workflow: Phase 1 — Analysis
│   ├── Input form: repo URL(s), descriptions
│   ├── Node: Clone repos (Execute Command)
│   ├── Node: Detect tech stacks (Model Router — step: "analysis.detect", analyst prompt + detection skill)
│   ├── Node: Analyze each repo (Loop → Model Router — step: "analysis.deep", analyst prompt + tech skills)
│   ├── Node: Cross-repo analysis (Model Router — step: "analysis.cross_repo", if multi-repo)
│   ├── Node: Validate against contract
│   └── Output: {project-name}/handoffs/001-analysis-complete.md
│
├── Sub-workflow: Phase 2 — Interview
│   ├── Trigger: n8n Webhook (receives POST from browser chat UI)
│   ├── Node: Load conversation state from file (interview-state.json)
│   ├── Node: Load analysis handoff (if exists) + interviewer skills
│   ├── Node: Model Router — step: "interview.conversation", full conversation history + interviewer prompt + skills
│   ├── Node: Save updated conversation state to file
│   ├── Node: Completion detection (check if coverage checklist satisfied)
│   ├── Node: On completion → Extract requirements from transcript
│   └── Output: {project-name}/handoffs/002-prd-interview.md
│
├── Sub-workflow: Phase 3 — PRD Synthesis
│   ├── Node: Load interview handoff + analysis handoff
│   ├── Node: Model Router — step: "prd.synthesis", writer prompt + requirements skill + all context
│   ├── Node: Present PRD to user for review
│   ├── Node: Revision loop (if user requests changes)
│   ├── Node: Validate against contract
│   └── Output: {project-name}/handoffs/003-prd-refined.md
│
├── Sub-workflow: Phase 4 — Council Review
│   ├── Node: Load PRD
│   ├── Node: Scan PRD for council triggers (Code node — match against agents.json council_triggers)
│   ├── Node: Present recommended council composition to user (core + triggered specialists)
│   ├── Node: User confirms/modifies composition
│   ├── Node: Core — Technical Reviewer (Model Router — step: "council.technical")
│   ├── Node: Core — Security Reviewer (Model Router — step: "council.security")
│   ├── Node: Core — Executive Reviewer (Model Router — step: "council.executive")
│   ├── Node: Core — User Advocate (Model Router — step: "council.user_advocate")
│   ├── Node: Loop — Specialized Reviewers (for each selected specialist: Model Router — step: "council.{agent_id}")
│   ├── Node: Council Chair (Model Router — step: "council.chair", synthesize ALL reviews)
│   ├── Node: Present findings to user
│   ├── Node: Apply accepted revisions → new PRD version
│   ├── Node: Re-review gate (form: proceed to next phase OR reconvene council)
│   ├── Node: If reconvene → loop back to "Load PRD" (delta review of changed sections only, review counter increments)
│   ├── Node: Validate against contract
│   └── Output: {project-name}/handoffs/004-council-review.md (or 004-council-review-r{N}.md for re-reviews)
│
├── Sub-workflow: Phase 4.5 — PM Destination Selection
│   ├── Node: Present destination options form
│   ├── Node: Destination advisor (Model Router — step: "pm.destination_advisor")
│   ├── Node: User selects destination
│   └── Output: config/project.json (updated with destination)
│
├── Sub-workflow: Phase 5 — Task Generation + GitHub Push
│   ├── Node: Load PRD + council review + analysis + coding standards
│   ├── Node: Generate parent tasks (Model Router — step: "pm.parent_tasks", PM architect prompt)
│   ├── Node: Present parents, wait for "Go"
│   ├── Node: Generate sub-tasks (Model Router — step: "pm.sub_tasks", PM architect prompt)
│   ├── Node: Generate dual-purpose issue bodies (Model Router — step: "pm.issue_bodies", issue generator prompt)
│   ├── Node: Create milestones (GitHub API node)
│   ├── Node: Create issues with labels (GitHub API node, loop)
│   ├── Node: Create/configure project board (GitHub API node)
│   └── Output: {project-name}/tasks/tasks-prd-[name].md, GitHub Issues live
│
├── Sub-workflow: Phase 5.5 — Implementation Feasibility Review (Optional)
│   ├── Node: Load PRD + task list + council review
│   ├── Node: Skeptical Implementer (Model Router — step: "critics.implementer")
│   ├── Node: Scope Killer (Model Router — step: "critics.scope")
│   ├── Node: Integration Pessimist (Model Router — step: "critics.integration")
│   ├── Node: Requirements Lawyer (Model Router — step: "critics.requirements")
│   ├── Node: Outsider User (Model Router — step: "critics.outsider")
│   ├── Node: Chair synthesis → prioritized Tier 1/2/3 findings
│   ├── Node: Present findings to user
│   ├── Node: User decides: revise PRD/tasks, or proceed with acknowledged risks
│   └── Output: {project-name}/handoffs/005.5-feasibility-review.md
│
└── Sub-workflow: Phase 6 — Execution Tracking
    ├── Node: Read task list, identify next task (dependency-aware)
    ├── Node: Write task context to target repo (.claude/current-task.md) for Claude Code pickup
    ├── Node: Present task to user in n8n UI (with copy-to-clipboard and terminal command)
    ├── Node: Monitor GitHub for PR creation (polling via Schedule Trigger — webhook optional)
    ├── Node: Code Review Agent (Model Router — step: "execution.code_review" + coding standards + code review skills)
    ├── Node: Review routing (auto-merge if clean + user authorized, else present review to user)
    ├── Node: On PR merge: update CHANGELOG.md, close issue, move board card
    └── Output: Ongoing tracking until all tasks complete
```

### 8.3 Project Structure

```
workflow-orchestration-system/
├── docker-compose.yml              ← n8n + supporting services
├── .env                            ← API keys, n8n config (gitignored)
├── .env.example                    ← Template for .env
│
├── workflows/                      ← Exported n8n workflow JSON (version controlled)
│   ├── master-orchestration.json
│   ├── model-router.json           ← Shared sub-workflow: resolves provider/model per step
│   ├── phase-1-analysis.json
│   ├── phase-2-interview.json
│   ├── phase-3-prd-synthesis.json
│   ├── phase-4-council-review.json
│   ├── phase-4.5-pm-destination.json
│   ├── phase-5-task-generation.json
│   ├── phase-5.5-feasibility-review.json  ← Critics council (optional)
│   └── phase-6-execution-tracking.json
│
├── prompts/                        ← Agent system prompts (markdown)
│   ├── analysis/
│   │   └── codebase-analyst.md
│   ├── prd-development/
│   │   ├── prd-interviewer.md
│   │   └── prd-writer.md
│   ├── prd-council/
│   │   ├── core/                   ← Always-present council members
│   │   │   ├── technical-reviewer.md
│   │   │   ├── security-reviewer.md
│   │   │   ├── executive-reviewer.md
│   │   │   ├── user-advocate.md
│   │   │   └── council-chair.md
│   │   └── specialized/            ← Added based on PRD content
│   │       ├── compliance-reviewer.md
│   │       ├── performance-reviewer.md
│   │       ├── accessibility-reviewer.md
│   │       ├── data-privacy-reviewer.md
│   │       ├── api-design-reviewer.md
│   │       └── migration-reviewer.md
│   ├── pm-framework/
│   │   ├── pm-architect.md
│   │   ├── issue-generator.md
│   │   └── destination-advisor.md
│   ├── critics-council/              ← Implementation feasibility reviewers
│   │   ├── skeptical-implementer.md
│   │   ├── scope-killer.md
│   │   ├── integration-pessimist.md
│   │   ├── requirements-lawyer.md
│   │   ├── outsider-user.md
│   │   └── critics-chair.md
│   └── task-execution/
│       ├── implementation-agent.md
│       └── code-review-agent.md    ← Dedicated PR review agent
│
├── skills/                         ← Skill context documents (markdown, 35 files)
│   ├── analysis/                   ← Codebase Analyst skills
│   │   ├── dotnet-patterns.md       (conditional: .NET detected)
│   │   ├── python-patterns.md       (conditional: Python detected)
│   │   ├── typescript-patterns.md   (conditional: TypeScript detected)
│   │   ├── aws-cdk-patterns.md      (conditional: CDK detected)
│   │   ├── gov-compliance-discovery.md
│   │   ├── tech-debt-assessment.md
│   │   └── multi-repo-analysis.md   (conditional: multi-repo)
│   ├── prd/                        ← Interviewer + Writer skills
│   │   ├── stakeholder-interview.md
│   │   ├── requirements-engineering.md
│   │   └── gov-prd-requirements.md  (conditional: compliance applies)
│   ├── council/                    ← Council reviewer skills (12 files)
│   │   ├── technical-review.md      ★ NEW — architecture evaluation, feasibility
│   │   ├── security-review.md       ★ NEW — threat modeling, security reqs
│   │   ├── business-alignment.md    ★ NEW — ROI, strategic fit
│   │   ├── ux-review.md             ★ NEW — user journey, usability heuristics
│   │   ├── council-synthesis.md     ★ NEW — multi-perspective synthesis
│   │   ├── fisma-compliance-check.md
│   │   ├── fedramp-review.md
│   │   ├── compliance-deep-dive.md  ★ NEW — deep framework analysis
│   │   ├── performance-review.md    ★ NEW — scalability, SLAs, bottlenecks
│   │   ├── accessibility-review.md  ★ NEW — WCAG 2.1, Section 508
│   │   ├── data-privacy-review.md   ★ NEW — PII, GDPR, privacy by design
│   │   ├── api-design-review.md     ★ NEW — contracts, versioning, compat
│   │   └── migration-review.md      ★ NEW — migration risk, rollback
│   ├── critics/                   ← Critics council skills (5 files)
│   │   ├── implementation-feasibility.md  ★ NEW — task counting, time estimation
│   │   ├── scope-analysis.md              ★ NEW — MVP validation, scope creep
│   │   ├── integration-risk.md            ★ NEW — system boundary analysis
│   │   ├── requirements-audit.md          ★ NEW — FR-to-task cross-referencing
│   │   └── ux-accessibility-audit.md      ★ NEW — persona journey mapping
│   ├── pm/                         ← PM Architect + Issue Generator skills
│   │   ├── task-decomposition.md
│   │   ├── github-issues-format.md
│   │   ├── gov-contract-planning.md (conditional: gov context)
│   │   └── agile-estimation.md
│   └── execution/                  ← Implementation + Code Review Agent skills
│       ├── coding-standards.md
│       ├── commit-protocol.md
│       └── code-review.md           ★ NEW — diff analysis, review format, auto-merge
│
├── contracts/                      ← Handoff validation schemas
│   ├── analysis-output.schema.md
│   ├── prd-interview-output.schema.md
│   ├── prd-output.schema.md
│   ├── council-output.schema.md
│   ├── feasibility-review-output.schema.md
│   └── pm-output.schema.md
│
├── workspace/                      ← Project workspaces (gitignored except templates)
│   ├── config/                     ← Global system config (auto-generated on first run)
│   │   ├── models.json             ← Model registry: providers, models, per-step defaults
│   │   └── agents.json             ← Agent roster (Phase 2 — auto-generated from prompts/ for now)
│   └── {project-name}/             ← Per-project directory (created by master workflow)
│       ├── handoffs/               ← Phase handoff artifacts
│       ├── tasks/
│       │   └── summary/
│       ├── diagrams/
│       ├── interview-state.json    ← Webhook chat conversation history
│       └── config/
│           ├── project.json        ← Project settings + model overrides
│           └── decisions.json      ← Cross-phase decision log
│
├── CLAUDE.md                       ← Instructions for Claude Code (Phase 6 execution)
├── CHANGELOG.md                    ← Auto-maintained from merged PRs
├── README.md                       ← Professional onboarding documentation
└── LICENSE
```

### 8.4 Deployment Model

MVP is Docker Compose on WSL2. 

**Prerequisites:**
- Windows with WSL2 (Ubuntu)
- NVIDIA GPU drivers configured for WSL2 CUDA passthrough (RTX 4090 or equivalent with ≥24GB VRAM)
- Ollama installed in WSL2 with GPU support (`curl -fsSL https://ollama.com/install.sh | sh`)
- Docker Desktop (or Docker Engine + Compose in WSL2)
- ~40GB free disk space for model weights
- Git and `gh` CLI (for Phase 6 execution)

**First-time setup** (~45-60 minutes on broadband, one-time):

```bash
git clone https://github.com/bjudd21/workflow-orchestration-system.git
cd workflow-orchestration-system

# Option A: Automated setup (checks prerequisites, pulls models, starts services)
./setup.sh

# Option B: Manual setup
# 1. Pull required Ollama models (~35-40GB total download):
ollama pull qwen3.5:27b        # Quality model — dense, 15-25 tok/s (~18GB)
ollama pull qwen3.5:35b-a3b    # Speed model — MoE, 60-100 tok/s (~21GB)

# 2. Start the system (no API keys required for True MVP):
cp .env.example .env
# .env defaults: OLLAMA_BASE_URL=http://host.docker.internal:11434
# Optional API providers (Full MVP):
#   ANTHROPIC_API_KEY (for Claude API fallback)
#   AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY + AWS_REGION (for Bedrock)
#   OPENAI_COMPATIBLE_BASE_URL + OPENAI_COMPATIBLE_API_KEY (for LM Studio, vLLM, etc.)
docker compose up -d
# Open browser: http://localhost:5678
```

**Subsequent runs** (~2 minutes): `docker compose up -d` → open browser. Models stay cached in Ollama.

**Deployment Variants:**

| Variant | Target | Configuration | When to Use |
|---------|--------|--------------|-------------|
| **Local workstation** (default) | Brian's machine: RTX 4090, WSL2 | Ollama at `host.docker.internal:11434`, both models local | Personal use, development, True MVP |
| **Team GPU server** | Shared server with GPU | Set `OLLAMA_BASE_URL` to server IP (e.g., `http://192.168.1.100:11434`). n8n Docker container on any machine. | Team deployment, multiple concurrent users |
| **API-only (no GPU)** | Machines without NVIDIA GPU | Skip Ollama entirely. Configure Anthropic/Bedrock/OpenAI-compatible in `.env`. All steps use cloud API. | Gov-managed workstations, CI/CD pipelines, restricted environments |
| **Hybrid** | Local GPU + API overflow | Ollama for most steps, API for frontier quality on hardest steps (council chair, PRD synthesis) | Best quality, some cloud cost |

All variants use the same Docker Compose stack and n8n workflows — only the provider configuration in `.env` and `models.json` differs.

n8n data persists via Docker volumes. Workspace files are mounted from the host filesystem for easy access and git operations. Ollama running on the WSL2 host (or Windows) is accessible from the n8n container via host networking.

**Ollama Lifecycle Independence.** Ollama is a host-level service with its own lifecycle, not a container managed by Docker Compose. Models are downloaded once via `ollama pull` and persist on disk (~40GB for both recommended models) across system restarts — they are never re-downloaded unless explicitly removed. Ollama runs as a background service that starts with WSL2 and remains available regardless of whether the workflow system is running. The workflow system simply connects to Ollama's HTTP endpoint (`host.docker.internal:11434`) the same way it would connect to any external API. `docker compose up` starts n8n; `docker compose down` stops n8n — neither command affects Ollama or its loaded models. This separation means the LLM inference layer is always warm and ready when the workflow system needs it.

### 8.5 Integration with Existing Rule Files

All four original rule files are integrated into the new structure:

| Original File | New Location(s) | How It's Used |
|---------------|-----------------|---------------|
| `create-prd.md` | `prompts/prd-development/prd-interviewer.md` + `skills/prd/stakeholder-interview.md` | Interview methodology and PRD structure preserved as agent prompt and skill context. Injected into LLM calls during Phases 2-3. |
| `generate-tasks.md` | `prompts/pm-framework/pm-architect.md` + `prompts/pm-framework/issue-generator.md` + `skills/pm/task-decomposition.md` | Two-phase generation preserved. Added: dual-purpose issues with AI Agent Notes, GitHub automation via n8n nodes, multi-repo file references. |
| `process-task-list.md` | `prompts/task-execution/implementation-agent.md` + `prompts/task-execution/code-review-agent.md` + `skills/execution/commit-protocol.md` + `CLAUDE.md` | One-at-a-time execution preserved. Dedicated Code Review Agent handles PR review with structured feedback. CHANGELOG.md automation. Task step summaries. Loaded by Claude Code or Continue.Dev during Phase 6. |
| `coding-prefs.md` | `skills/execution/coding-standards.md` | All original preferences preserved and expanded into comprehensive standard with three core principles and 10 best practice categories. Referenced in Phase 5 (issue generation) and Phase 6 (execution). |

---

## 9. Risk Assessment

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| R1 | API rate limits slow down council review when using cloud providers (Full MVP) | Medium | Medium | Not applicable to True MVP (local inference has no rate limits). For Full MVP: use appropriate model tiers per step, implement retry with backoff in n8n. |
| R2 | Agent prompts produce inconsistent output across different models | Medium | High | Standardized prompt format with explicit output schemas; contract validation between phases. Test prompts against each model during setup. |
| R3 | Analysis phase overwhelmed by large monorepo | Medium | Medium | Scope to specified directories; chunking strategy |
| R4 | Webhook-based chat UI lacks polish compared to dedicated chat frameworks (no typing indicators, limited formatting) | Medium | Low | Simple HTML form is functional for MVP; custom chat UI with richer UX is a Product Phase 2 enhancement |
| R5 | Multi-repo analysis produces overwhelming output | Low | Medium | Prioritize cross-repo findings; summarize per-repo details with expandable sections |
| R6 | Local Ollama models may not meet quality bar for complex reasoning steps | Medium | Medium | Two-model strategy: dense quality model for reasoning-critical steps, fast MoE model for throughput steps. Contract validation catches poor output. API fallback available per-step. |
| R7 | Docker/n8n adds infrastructure complexity vs. simple CLI | Low | Medium | Docker Compose is single-command. n8n provides more value than it costs in complexity. |
| R8 | Phase 6 hybrid model (n8n + Claude Code) creates friction | Medium | Medium | Clear handoff: n8n presents task context, user copies to Claude Code terminal. CLAUDE.md contains all Phase 6 instructions. |
| R9 | Compliance skills become outdated | Low | High | Skills reference control frameworks by ID; periodic review cadence |
| R10 | Local Ollama models produce lower quality output than frontier API models on complex tasks | Medium | Medium | Current recommended quality model benchmarks comparably to models 5-10x its size on reasoning tasks. Contract validation catches failures. Retry with different model or fall back to API. Quality gap is real for hardest tasks but acceptable for MVP validation. |
| R11 | Prompt format differences across providers cause failures | Low | Medium | Model router normalizes requests and responses. Provider-specific formatting isolated to a single integration layer. |
| R12 | Single-GPU dependency creates bottleneck for concurrent or sustained use | Medium | Medium | Not a concern for single-user True MVP. For team deployment: API providers available as overflow, dedicated GPU server recommended. See deployment variants. |
| R13 | MoE speed model may be less consistent on format-following and persona adherence than dense models | Medium | Low | MoE models (3B active parameters) may produce less coherent "reviewer personality" across long outputs. Fallback: configure all council steps to use quality model (slower but more consistent). Contract validation catches format failures. |

---

## 10. MVP vs. Future Phase Scoping

### True MVP (Target: Weeks 1-2) — Validate Core Pipeline

The True MVP proves the core value proposition: can the pipeline produce a good PRD from an interview and can the council catch real issues?

**Included:**
- Docker Compose deployment on WSL2 (n8n + workspace)
- `setup.sh` script: prerequisite checker + model puller + Docker Compose launcher for first-time setup
- Local Ollama inference with two-model strategy (no API keys required):
  - Qwen3.5-35B-A3B (speed model, 60-100 tok/s) for: interview, council reviewers, handoff validation
  - Qwen3.5-27B (quality model, 15-25 tok/s) for: PRD synthesis, council chair, requirements extraction
- Per-step model assignment via simple config (step name → Ollama model tag)
- Project-namespaced workspace directories
- Phase 2: PRD Interview workflow (webhook-based chat, browser-accessible)
- Phase 3: PRD Synthesis workflow (version tracking, revision loop)
- Phase 4: Council Review workflow (4 core reviewers + chair, manual specialist selection via checkboxes)
- Agent prompts for interview, synthesis, and council agents (all with paired skills)
- Core skill documents: prd/ skills, council/ core skills (5 new + 2 existing)
- Handoff contracts with validation between phases
- File-based handoffs on disk
- Greenfield entry point (no analysis phase yet)
- Single-tier prompts targeting the quality model (tier differentiation added in Full MVP)

**Not included in True MVP:**
- Phase 1 (Analysis), Phase 5 (Tasks/GitHub), Phase 5.5 (Critics Council — automated workflow), Phase 6 (Execution Tracking)
- Full model router sub-workflow (True MVP uses direct Ollama API calls with per-step model config)
- Multi-provider support (Anthropic, Bedrock, OpenAI-compatible APIs)
- Prompt tier differentiation (True MVP uses single-tier prompts; tier markers added in Full MVP)
- GitHub integration (issues, milestones, boards)
- Multi-repo analysis
- PM destination selection
- Code Review Agent
- Context budget system
- Full agent roster JSON registry

### Full MVP (Target: Weeks 3-5) — Add Infrastructure

The Full MVP adds the infrastructure that makes the system powerful: multi-model routing, codebase analysis, task generation, GitHub automation, and execution tracking.

**Adds to True MVP:**
- Model router sub-workflow with multi-provider support (Ollama + Anthropic + Bedrock + OpenAI-compatible)
- Model registry with default assignments, progressive configuration workflows (add API providers, customize per-step)
- Prompt tiers: add tier markers to all prompts (`strong`, `capable`, `frontier`) and tier selection in model router
- Context budget system in model router
- Phase 1: Codebase Analysis workflow (single repo, then multi-repo)
- Phase 4.5: PM Destination Selection workflow
- Phase 5: Task Generation + GitHub Push workflow (dual-purpose issues, milestones, project board)
- Phase 5.5: Implementation Feasibility Review workflow (critics council — adversarial reviewers assess buildability, timeline realism, integration risks)
- Phase 6: Execution Tracking workflow (task injection to target repo, polling, Code Review Agent)
- Specialized council reviewer prompts + skills (6 specialized agents)
- All remaining skill documents (analysis/, pm/, execution/)
- CLAUDE.md for Phase 6 Claude Code / Continue.Dev execution
- Comprehensive coding standards skill
- Professional README with Docker setup, phase guide, and full configuration documentation
- Batch input mode for interview (upload existing requirements)

### Product Phase 2: Agent Registry & Enhanced Integrations

- Full JSON agent roster (`agents.json`) with programmatic management
- Trigger-based council composition (auto-scan PRD content, recommend specialists)
- Agent roster dashboard in n8n UI
- Audit log as core feature (every user decision logged to `audit-log.jsonl`)
- **Product viability council review** — convene a specialized council (competitor analyst, developer tools product strategist, pricing/GTM specialist, open-source community builder) to evaluate the system as a product after the Full MVP is validated with real projects. Assess: competitive landscape, target market beyond internal use, monetization paths (open-source vs. commercial vs. hybrid), developer tooling market fit, distribution strategy, and **desktop app viability** (Electron shell vs. browser-only, install experience, system tray integration). Output: product viability report with go/no-go recommendation for productization investment.
- Slack/Teams notifications on phase completion
- Webhook triggers for CI/CD integration
- **Electron desktop shell** — lightweight Electron app that wraps n8n's API without replacing the orchestration engine. n8n continues to run all workflows, state management, and LLM calls. The Electron shell provides: dedicated chat window for the interview phase, pipeline status dashboard, system tray with progress notifications, single-click launch (starts Docker + n8n in background), and a native app feel. n8n's browser UI remains available for workflow editing and advanced configuration. Evaluate feasibility during the product viability council review.
- Interview save/resume for long sessions
- Model performance benchmarking dashboard
- Secondary user journey (Dev Manager as viewer + task executor)
- Prompt quality logging (contract pass/fail rates, user satisfaction per agent)

### Product Phase 3: Scale & Optimization

- Multi-user collaboration (team members trigger phases independently)
- Cross-project analytics (patterns across multiple PRDs)
- Advanced project board automation (auto-assign, sprint planning)
- Integration with additional PM tools (Linear, Jira)
- n8n workflow marketplace for sharing custom phases and skills
- Dogfooding: run the system against its own repo as validation

---

## 11. Open Questions & Assumptions

### Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|-----------|-----------------|
| A1 | LLM token limits accommodate full prompt injection (agent + skill + handoff context) for configured models | High | Chunk handoffs, use summarization step, or switch to a model with larger context |
| A2 | Markdown handoffs provide sufficient structure for context transfer | High | Move to JSON/YAML |
| A3 | Webhook-based chat UI provides adequate conversational interview experience | Medium | Build custom chat UI with richer features (typing indicators, message history, file upload) |
| A4 | n8n's GitHub nodes cover all required operations (issues, milestones, project boards) | Medium | Supplement with `gh` CLI calls via Execute Command node |
| A5 | Four tech stack skill packs are sufficient for initial projects | High | Easy to add more |
| A6 | Council review completes in under 20 minutes with 4-10 sequential LLM calls (core + specialists) | Medium | Optimize prompts, consider parallel execution, or use faster local models for reviewers |
| A7 | Docker Compose on WSL2 is stable for long-running n8n processes | High | Minimal risk; n8n is production-grade |
| A8 | Phase 6 hybrid model (n8n tracking + terminal execution) is not overly friction-heavy | Medium | If friction is high, explore tighter n8n-to-terminal integration |
| A9 | Agent prompts designed for Claude produce acceptable output with other models (Qwen, Llama, etc.) | Medium | May need model-specific prompt variants for critical steps. Contract validation catches quality issues. |
| A10 | Ollama on WSL2 host is network-accessible from n8n Docker container | High | Configure Docker networking or run Ollama in a container |

### Resolved Questions

1. ~~**Interview save/resume**~~: Deferred — nice to have but not MVP.
2. ~~**PRD versioning**~~: Track versions explicitly (v1, v2, v3).
3. ~~**Compliance applicability**~~: Interview asks whether frameworks apply; section conditionally included.
4. ~~**PM output target**~~: User selects destination via PM Destination Selection (Phase 4.5).
5. ~~**Target repo separation**~~: Workflow system is a Docker stack. Target repo(s) are configured as project settings. GitHub Issues go wherever the user specifies.
6. ~~**Multi-repo support**~~: Integrated into MVP. Analysis workflow loops over multiple repos and produces unified findings.
7. ~~**Orchestration architecture**~~: n8n replaces shell aliases and Claude Code CLI orchestration.
8. ~~**Cross-platform**~~: Docker + browser. WSL2 is the only required platform for MVP.
9. ~~**Distribution model**~~: Docker Compose (clone repo, docker compose up). No template-per-project.

---

## 12. Success Criteria

### True MVP Success (Weeks 1-2)

The True MVP is successful when:

1. Brian can start from a greenfield idea and produce a council-reviewed PRD through the interview → PRD synthesis → council review pipeline.
2. The interview agent conducts a structured conversation via the browser-based webhook chat UI, covering all required topic areas (FR-2.6).
3. The PRD synthesis agent produces a PRD containing all required sections (FR-3.2) with measurable, testable requirements.
4. The council is made up of 4 core reviewers + chair, with the option to add specialized reviewers via checkboxes.
5. The council review surfaces at least one concern or gap that was not identified during the interview/synthesis phases.
6. The re-review gate allows the user to reconvene the council after substantial revisions.
7. A session interruption does not require rework — restarting the n8n workflow resumes from the last completed phase using file-based handoffs.
8. Handoff contracts are validated between phases; invalid handoffs do not advance the pipeline.
9. The system runs on WSL2 via Docker Compose with local Ollama inference and is accessible via browser from Windows.
10. First-time setup including Ollama installation and model pulls completes in under 1 hour on broadband.
11. After setup, `docker compose up` → running the first interview within 15 minutes.

### Full MVP Success (Weeks 3-5)

The Full MVP is successful when all True MVP criteria remain satisfied, plus:

12. Brian can run any GitHub repo or repos (multi-repo capable) through the full pipeline (analysis → interview → PRD → council review → task list → GitHub Issues) and produce artifacts he would use for a real project.
13. There is a roster of agents of various specialties, viewable and configurable through the system.
14. GitHub Issues are automatically created at the user-selected destination with milestones, labels, and a project board (kanban + roadmap) without manual intervention.
15. GitHub Issues are dual-purpose: a junior developer can follow the main body without reading AI Agent Notes, and an AI agent can execute autonomously using both sections.
16. The implementation agent (Claude Code or Continue.Dev) successfully codes, tests, commits to a feature branch, creates a PR, then a specialized Code Review Agent reviews the PR and closes a GitHub Issue for at least one complete parent task.
17. CHANGELOG.md is automatically updated upon PR merge with properly categorized entries in Keep a Changelog format.
18. The README enables a new user to go from `docker compose up` to running their first phase within 15 minutes (assuming Ollama is installed and models are pulled).
19. Total time from start to finished task list with GitHub Issues is under 3 hours for a moderately complex project.
20. Multi-repo analysis produces unified findings with cross-repo dependency mapping.
21. PM destination selection allows the user to choose where GitHub Issues are pushed without code changes.
22. The model router supports Ollama + at least one API provider (Anthropic or OpenAI-compatible) with per-step model assignment.

---

*End of PRD — Version 3.5*
