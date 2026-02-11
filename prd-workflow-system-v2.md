# Product Requirements Document: Workflow Orchestration System

---

**Document Version**: 2.0  
**Author**: Brian (IT Manager) / Claude (AI-assisted)  
**Date**: February 10, 2026  
**Status**: Final Draft — All open questions resolved, ready for implementation  
**Changes from v1**: Expanded MVP to include council review pattern and PM framework phase. Integrated existing PRD/task workflow rules as foundational patterns. Added Phase 5 (task generation) and Phase 6 (task execution protocol).

---

## 1. Executive Summary

The Workflow Orchestration System is a phase-based, multi-agent framework that systematizes the full lifecycle from project analysis through PRD development, review, and project execution planning. It replaces the current ad-hoc approach where an IT manager manually drives AI tools through analysis, requirements gathering, and documentation — losing context to compaction and starting over repeatedly.

The system supports two entry points: analyzing an existing codebase or starting from a greenfield idea. It guides users through a conversational interview, synthesizes a structured PRD, convenes a council of specialized reviewers for quality assurance, generates a phased task list, automatically pushes GitHub Issues with milestones and a project board (kanban + roadmap), and produces dual-purpose issues that either a junior human developer or an AI agent (Claude Code) can pick up and execute.

The MVP delivers the full pipeline via Claude Code and VS Code. A future phase will deliver a web UI to make the system accessible to product owners and non-technical stakeholders.

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

### 2.3 Impact of Not Solving

Projects continue to start with incomplete or inconsistent requirements documentation. Modernization efforts lack the structured analysis needed to surface compliance gaps, tech debt, and architectural risks before development begins. PRDs ship with blind spots that a 30-minute council review would have caught. Developers receive task lists without sufficient context or structure.

---

## 3. Vision & Goals

### 3.1 Vision

A reusable, phase-based system where any user — from a seasoned IT manager to a product owner with an idea on a napkin — can produce a comprehensive, compliance-aware, council-reviewed PRD with an actionable task list through guided conversation with specialized AI agents. Context is never lost. Quality is enforced at every boundary. Outputs are ready for execution.

### 3.2 Goals

| Goal | Success Metric | Target |
|------|---------------|--------|
| Eliminate context loss | Zero manual context reconstruction across phases | MVP |
| Standardize PRD quality | Every PRD contains all required sections (7 core + compliance when applicable) | MVP |
| Support dual entry points | System handles both repo analysis and greenfield ideas | MVP |
| Multi-perspective review | Every PRD reviewed by technical, security, executive, and user advocate perspectives before finalization | MVP |
| Actionable task output | PRD produces a developer-ready task list with sub-tasks, relevant files, and GitHub Issues | MVP |
| Reduce PRD-to-tasks time | Analysis → PRD → reviewed → task list complete in < 3 hours | MVP |
| Enable non-technical users | Product owners can produce a PRD via web UI without CLI knowledge | Phase 2 |

### 3.3 Non-Goals (Explicitly Out of Scope for MVP)

- Web UI for non-technical users (Phase 2)
- MCP server integration
- Multi-user collaboration on a single PRD
- Integration with external PM tools beyond GitHub (Linear, Jira)
- Model tiering optimization (Opus vs. Sonnet vs. Haiku routing)
- Task execution automation for non-Claude Code environments (MVP requires Claude Code CLI)

---

## 4. Users & Personas

### 4.1 Primary User — IT Manager (Brian)

**Context**: 20 years leading Infrastructure Engineering teams on state and local government contracts. Deeply comfortable with CLI tools, Claude Code, VS Code, and AWS infrastructure. Runs this workflow across multiple projects per quarter.

**Needs**: Speed, consistency, compliance awareness, context persistence across sessions. Wants to invoke the system from the terminal and get structured, reviewable output.

**Entry point (MVP)**: Claude Code CLI and/or VS Code terminal.

### 4.2 Secondary User — Developer Manager / Developer Lead

**Context**: Member of Brian's team. Comfortable with code and git but may not have deep experience driving AI for requirements work. Might use the system to analyze a repo before proposing a refactor, or receive a generated task list to implement.

**Needs**: Clear instructions, sensible industry-standard defaults, structured task lists written for their skill level. The task list should be explicit enough for a junior developer to follow.

**Entry point (MVP)**: Claude Code CLI with guided prompts. Receives task lists as markdown files.

### 4.3 Future User — Product Owner / Stakeholder (Phase 2)

**Context**: Non-technical or semi-technical. Has ideas for new features or applications but no familiarity with AI prompting, CLI tools, or codebase analysis.

**Needs**: A simple, guided interface. Conversational interview that doesn't assume technical knowledge. Output they can review and approve without understanding the underlying system.

**Entry point (Phase 2)**: Web UI with conversational chat interface.

---

## 5. System Architecture

### 5.1 Entry Points & Phase Flow

```
Entry Point A: Existing Codebase          Entry Point B: Greenfield Idea
┌─────────────────────────┐               ┌─────────────────────────┐
│   User provides repo    │               │  User provides idea /   │
│   URL or local path     │               │  problem description    │
└───────────┬─────────────┘               └───────────┬─────────────┘
            │                                         │
            ▼                                         │
┌─────────────────────────┐                           │
│  Phase 1: Analysis      │                           │
│  (Codebase Analyst)     │                           │
│  → Architecture map     │                           │
│  → Tech debt inventory  │                           │
│  → Compliance discovery │                           │
│  → Mermaid diagrams     │                           │
└───────────┬─────────────┘                           │
            │                                         │
            ▼                                         ▼
┌──────────────────────────────────────────────────────┐
│  Phase 2: PRD Interview                              │
│  (PRD Interviewer Agent)                             │
│  Conversational, one question at a time.             │
│  Provides lettered/numbered options where possible   │
│  for quick user response.                            │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  Phase 3: PRD Synthesis & Refinement                 │
│  (PRD Writer Agent)                                  │
│  Produces structured PRD. User reviews, requests     │
│  revisions. Versions tracked (v1, v2, v3).           │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  Phase 4: Council Review                             │
│  (Council of Agents)                                 │
│                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │Technical │ │Security  │ │Executive │ │ User   │  │
│  │Reviewer  │ │Reviewer  │ │Reviewer  │ │Advocate│  │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───┬────┘  │
│       └─────────────┴────────────┴───────────┘       │
│                      │                               │
│              ┌───────▼───────┐                       │
│              │ Council Chair │                       │
│              │ (Synthesizer) │                       │
│              └───────────────┘                       │
│  → Consensus points, conflicts, recommended          │
│    revisions, decisions for stakeholder               │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  Phase 5: Task Generation & GitHub Setup             │
│  (PM Architect + Issue Generator)                    │
│                                                      │
│  Two-phase generation:                               │
│  1. Generate parent tasks → present → wait for "Go"  │
│  2. Generate sub-tasks, relevant files, estimates     │
│                                                      │
│  Then automatically via gh CLI:                       │
│  → Create GitHub Project board (if needed)            │
│  → Create milestones with due dates from PRD timeline │
│  → Push issues to repo with labels + milestones       │
│  → Add issues to project board kanban + roadmap       │
│                                                      │
│  Output: Task list markdown + live GitHub Issues      │
└──────────────────────┬───────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────┐
│  Phase 6: Task Execution (Dual-Purpose)              │
│  Issues assignable to human dev OR AI agent           │
│                                                      │
│  Human dev: follows main issue body + sub-tasks      │
│  AI agent (Claude Code): reads main body +            │
│    AI Agent Notes for full autonomous context         │
│                                                      │
│  Either executor: one sub-task at a time →            │
│  mark complete → run tests → commit to feature        │
│  branch → create PR when parent done.                 │
│                                                      │
│  PR Review Gate (user chooses per PR):                │
│  • Human review → merge when satisfied                │
│  • AI-assisted review → AI reviews, user approves     │
│  • AI review + auto-merge → AI reviews + merges       │
│                                                      │
│  On merge: append to CHANGELOG.md → close Issue →     │
│  move card to Done. Task step summaries per sub-task. │
│                                                      │
│  When all tasks done: compile release notes.          │
└──────────────────────────────────────────────────────┘
```

### 5.2 Plugin Architecture

```
plugins/
├── analysis/                       ← PHASE 1 (optional)
│   ├── agents/
│   │   └── codebase-analyst.md
│   ├── commands/
│   │   └── analyze.md
│   └── skills/
│       ├── dotnet-patterns/SKILL.md
│       ├── python-patterns/SKILL.md
│       ├── typescript-patterns/SKILL.md
│       ├── aws-cdk-patterns/SKILL.md
│       ├── gov-compliance-discovery/SKILL.md
│       └── tech-debt-assessment/SKILL.md
│
├── prd-development/                ← PHASE 2-3
│   ├── agents/
│   │   ├── prd-interviewer.md
│   │   └── prd-writer.md
│   ├── commands/
│   │   ├── interview.md
│   │   └── synthesize.md
│   └── skills/
│       ├── stakeholder-interview/SKILL.md
│       ├── requirements-engineering/SKILL.md
│       └── gov-prd-requirements/SKILL.md
│
├── prd-council/                    ← PHASE 4
│   ├── agents/
│   │   ├── technical-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── executive-reviewer.md
│   │   ├── user-advocate.md
│   │   └── council-chair.md
│   ├── commands/
│   │   ├── council-review.md
│   │   └── council-debate.md
│   └── skills/
│       ├── fisma-compliance-check/SKILL.md
│       └── fedramp-review/SKILL.md
│
├── pm-framework/                   ← PHASE 5
│   ├── agents/
│   │   ├── pm-architect.md
│   │   ├── issue-generator.md
│   │   └── resource-planner.md
│   ├── commands/
│   │   ├── generate-tasks.md
│   │   ├── generate-issues.md
│   │   └── estimate.md
│   └── skills/
│       ├── task-decomposition/SKILL.md
│       ├── github-issues-format/SKILL.md
│       ├── gov-contract-planning/SKILL.md
│       └── agile-estimation/SKILL.md
│
├── task-execution/                 ← PHASE 6 (dual-purpose: human or AI agent)
│   ├── agents/
│   │   └── implementation-agent.md
│   ├── commands/
│   │   ├── next-task.md
│   │   └── update-github.md
│   └── skills/
│       ├── coding-standards/SKILL.md
│       └── commit-protocol/SKILL.md
│
└── workflow-orchestration/         ← META PLUGIN
    ├── agents/
    │   ├── workflow-coordinator.md
    │   └── reviewer-agent.md
    ├── commands/
    │   ├── status.md
    │   ├── next.md
    │   └── resume.md
    └── skills/
        └── handoff-validation/SKILL.md
```

### 5.3 Integration of Existing Workflow Rules

Brian's existing rule files are integrated into the system as follows, with improvements noted:

| Source File | Integrated Into | Improvements |
|-------------|----------------|-------------|
| `create-prd.md` | `prd-interviewer.md` agent + `stakeholder-interview` skill | Expanded PRD structure (7-8 sections vs. 9 original). Added compliance-conditional section. Conversational one-at-a-time style preserved. Clarifying questions now offer lettered/numbered options for quick response (preserved from original). Added probing techniques for specificity. |
| `generate-tasks.md` | `pm-architect.md` + `issue-generator.md` agents + `task-decomposition` skill | Two-phase generation preserved (parent tasks → confirm → sub-tasks). Added: dependency tracking, T-shirt estimates, automatic GitHub push with project board and milestones, relevant files with test file pairing. Issues are dual-purpose: main body at junior developer level (preserved from original), AI Agent Notes section appended for autonomous AI execution. |
| `process-task-list.md` | `implementation-agent.md` agent + `commit-protocol` skill | One-at-a-time execution preserved. Agent now actively implements code. Each completed parent task results in a PR (not a direct merge). Human review gate with option for AI-assisted review or AI auto-merge. Merged PRs auto-append to CHANGELOG.md in Keep a Changelog format for release notes. Stop hooks validate tests before allowing commit. Task step summary files preserved. Enhanced commit protocol with conventional commit format. GitHub Issues closed upon PR merge. |
| `coding-prefs.md` | `coding-standards/SKILL.md` | All original preferences preserved and expanded into a comprehensive standard built on three core principles: clarity over cleverness, simplicity first, readability is non-negotiable. Best practices extended across 10 categories: naming, function design, file structure, comments, error handling, testing, duplication, environment/config, dependencies, and change scope. Loaded as a skill during task execution phase. Environment-specific validation in stop hooks (no mocked data outside test env). |

### 5.4 Handoff System

Each phase produces a structured handoff artifact in `handoffs/`. Handoffs are validated against contract schemas before a phase is considered complete.

**Handoff format:**

```markdown
---
phase: [phase-name]
completed: [ISO timestamp]
agent: [agent-name]
project: [project-name]
entry_point: repo | greenfield
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

```
state/
├── workflow-state.md    ← Current phase, completed phases, resume instructions
├── decisions.md         ← Cross-phase decision log
└── todo.md              ← Anti-drift checklist, updated as work progresses
```

### 5.6 Output Structure

```
workflow-system/                        ← Template repo root
├── aliases.sh                          ← Bash/Zsh aliases (macOS/Linux)
├── aliases.ps1                         ← PowerShell aliases (Windows)
├── CHANGELOG.md                        ← Auto-maintained from merged PRs
│
├── tasks/
│   ├── prd-[project-name].md           ← Final PRD (latest version)
│   ├── prd-[project-name]-v1.md        ← PRD version history
│   ├── prd-[project-name]-v2.md
│   ├── tasks-prd-[project-name].md     ← Task list (local working copy)
│   └── summary/
│       ├── task-1.1-summary.md         ← Per-subtask completion summaries
│       ├── task-1.2-summary.md
│       └── ...
│
GitHub (created automatically by agent via gh CLI):
├── Project Board                       ← Kanban (To Do / In Progress / Done) + Roadmap view
├── Milestones                          ← With due dates from PRD timeline
├── Issues                              ← One per parent task, sub-tasks as checklists
└── Pull Requests                       ← One per completed parent task, linked to issue
```

### 5.7 Context Preservation Strategy

1. **Handoff artifacts** — structured markdown files that carry forward findings, decisions, and context between phases.
2. **Mermaid diagrams** — architecture, data flow, and auth flow diagrams. Token-efficient format stored in `diagrams/`.
3. **System prompt preloading** — each phase launcher injects relevant agent definitions, skill files, and prior handoffs via `--append-system-prompt`.
4. **Todo.md anti-drift** — running checklist that persists across compaction. Updated step-by-step.
5. **Stop hooks** — TypeScript hooks that validate handoffs against contracts, run tests, and update state before phase completion.
6. **Task step summaries** — per-subtask completion records that document what was done, providing a breadcrumb trail if context is lost.
7. **GitHub Issues as external state** — issue status, comments, and project board position serve as a persistent record of implementation progress that survives any local context loss.
8. **Pull Requests as review history** — each PR captures the diff, review comments, and merge decision for a parent task, providing a complete audit trail.
9. **CHANGELOG.md as cumulative record** — auto-maintained from merged PRs, provides a running narrative of what was built and why.

---

## 6. Functional Requirements

### FR-1: Codebase Analysis (Phase 1 — Optional)

**Trigger**: User provides a repository URL or local path.

**FR-1.1** The system shall clone the repository locally and perform automated analysis. Remote repos are always cloned — no GitHub API access for analysis.

**FR-1.2** The analysis agent shall produce:
- Architecture overview (component map, layer identification)
- Technology inventory (languages, frameworks, versions, dependencies)
- Tech debt inventory (deprecated patterns, outdated dependencies, code smells)
- Compliance discovery (authentication patterns, data handling, audit logging, encryption)
- Mermaid diagrams (architecture, data flow, key workflows)

**FR-1.3** Analysis shall be language-agnostic at the core, with domain-specific skills loaded on demand. MVP skill packs: .NET Framework/.NET 8, Python, TypeScript/Node.js, AWS CDK.

**FR-1.4** The analysis agent shall identify existing components, utilities, and patterns that are relevant to any subsequent PRD work — following the principle of checking for existing code before proposing new implementations.

**FR-1.5** Analysis output shall be written to `handoffs/001-analysis-complete.md`.

### FR-2: PRD Interview (Phase 2)

**Trigger**: User initiates interview (after analysis, or directly for greenfield).

**FR-2.1** The PRD interviewer agent shall conduct a conversational interview, one question at a time.

**FR-2.2** Where possible, questions shall include lettered or numbered options for quick response (e.g., "What's your target timeline? A) 2 weeks B) 1 month C) 3 months D) Other").

**FR-2.3** If analysis artifacts exist, the interviewer shall reference them to ask informed, specific questions.

**FR-2.4** If no analysis exists (greenfield), the interviewer shall start with vision and scope, progressively exploring technical, compliance, and resource dimensions.

**FR-2.5** The interviewer shall ask whether compliance frameworks (FISMA, FedRAMP, SOC 2) apply to this project. This determines whether the compliance section appears in the PRD.

**FR-2.6** The interview shall cover, at minimum:
- Problem statement and success criteria
- Target users and their goals
- Core functionality and user stories
- Functional scope (MVP vs. future phases)
- Technical constraints and preferences
- Integration points with existing systems
- Compliance requirements (if applicable)
- Team composition and timeline constraints
- Known risks, dependencies, and edge cases
- Design/UI considerations (if applicable)

**FR-2.7** The interviewer shall use probing techniques to convert vague requirements into measurable ones (e.g., "fast" → "< 200ms p95 response time").

**FR-2.8** Interview transcript and extracted requirements shall be written to `handoffs/002-prd-interview.md`.

### FR-3: PRD Synthesis & Refinement (Phase 3)

**Trigger**: Interview phase completes.

**FR-3.1** The PRD writer agent shall synthesize interview transcript + analysis artifacts (if present) into a structured PRD.

**FR-3.2** Every PRD shall contain the following sections:

| # | Section | Description | Required |
|---|---------|-------------|----------|
| 1 | Executive Summary | Problem, solution, key outcomes in 3-5 sentences | Always |
| 2 | Functional Requirements | Numbered, testable requirements grouped by feature area. Explicit and unambiguous — written so a junior developer can understand. | Always |
| 3 | Non-Functional Requirements | Performance, scalability, availability, security requirements with measurable targets | Always |
| 4 | Compliance Requirements | Applicable frameworks, specific controls, ATO implications | Conditional — only if interview identifies applicable frameworks |
| 5 | User Stories & Acceptance Criteria | "As a [role], I want [goal], so that [benefit]" with testable acceptance criteria | Always |
| 6 | Architecture Recommendations | Proposed tech stack, system boundaries, integration patterns, deployment model | Always |
| 7 | Risk Assessment | Technical, compliance, schedule, resource risks with likelihood, impact, mitigation | Always |
| 8 | MVP vs. Future Phase Scoping | What ships now vs. what is deferred, with rationale | Always |

**FR-3.3** The PRD writer shall present the draft for review. The user can request revisions interactively.

**FR-3.4** Each PRD revision shall be tracked as a versioned file: `prd-[name]-v1.md`, `prd-[name]-v2.md`, etc. The latest version is authoritative.

**FR-3.5** The PRD shall not include implementation details — it defines "what" and "why," not "how." Implementation is the developer's domain.

**FR-3.6** PRDs shall be saved to `tasks/prd-[project-name].md` (maintaining compatibility with the existing `/tasks/` directory convention).

### FR-4: Council Review (Phase 4)

**Trigger**: PRD synthesis completes (latest version).

**FR-4.1** The council review shall convene four specialized reviewer agents, each with stated biases:

| Reviewer | Focus | Stated Bias |
|----------|-------|-------------|
| Technical Reviewer | Architecture, feasibility, timeline realism, dependencies | Prefers proven tech, values maintainability, skeptical of timelines without buffer |
| Security Reviewer | Compliance, data handling, threat model, ATO implications | Assumes worst-case threat model, demands explicit security requirements |
| Executive Reviewer | Business alignment, ROI, strategic fit, resource justification | Focuses on organizational value, questions scope that doesn't serve business goals |
| User Advocate | User value, usability, accessibility, user story completeness | Champions end-user experience, pushes back on technical decisions that hurt UX |

**FR-4.2** Each reviewer shall independently analyze the PRD and produce 3-5 concerns or endorsements with a severity/confidence rating.

**FR-4.3** The Council Chair agent shall synthesize all reviewer feedback into:
- Consensus points (where all reviewers agree)
- Conflicts requiring resolution (where perspectives differ — both sides presented)
- Recommended PRD revisions (specific, actionable changes)
- Decisions for stakeholder (items only a human can resolve)

**FR-4.4** The user shall review council output and decide which recommendations to accept. Accepted changes produce a new PRD version.

**FR-4.5** Council review is not optional for the MVP pipeline. Every PRD passes through council before task generation.

### FR-5: Task Generation (Phase 5)

**Trigger**: Council-reviewed PRD is finalized.

**FR-5.1** Task generation shall follow a two-phase process:
1. **Phase A**: Generate parent tasks (high-level, ~5-8 tasks). Present to user with the message: "I have generated the high-level tasks based on the PRD. Ready to generate the sub-tasks? Respond with 'Go' to proceed."
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

**FR-5.4** The output shall include a "Relevant Files" section listing every file expected to be created or modified, with a one-line description and corresponding test files.

**FR-5.5** Task list shall be saved to `tasks/tasks-prd-[project-name].md`.

**FR-5.6** After task generation, the agent shall automatically push to GitHub using the `gh` CLI:

1. **Milestones**: Create milestones with due dates derived from the PRD timeline. Each milestone corresponds to a phase boundary (e.g., "MVP," "Phase 2") or a major deliverable.
2. **Issues**: Create GitHub Issues for each parent task. Each issue is dual-purpose — written so either a junior human developer or an AI agent can pick it up and execute. The issue structure:
   - **Title**: Clear, action-oriented task title
   - **Body** (human-readable, junior developer level):
     - Description of what needs to be built and why, written in plain language
     - Sub-tasks as a checklist
     - Acceptance criteria in testable language
   - **AI Agent Notes section** (appended at the bottom of the body): A dedicated section containing additional context that an AI agent needs for autonomous execution. Human developers can ignore this section. (See FR-5.8 for contents.)
   - **Labels**: Feature area, T-shirt size estimate, `agent-ready` label
   - **Milestone**: Assignment to the appropriate milestone
3. **Project Board**: If a GitHub Project board does not exist for the repo, create one. Configure it with kanban view (To Do / In Progress / Done) and roadmap view with milestone-based timelines.
4. **Board Population**: Add all created issues to the project board, assigned to the appropriate milestones and initial "To Do" status.

**FR-5.7** The markdown task list in `tasks/` remains the local working copy. GitHub Issues are the source of truth for project tracking once pushed.

**FR-5.8** Every GitHub Issue shall include an **AI Agent Notes** section appended below the human-readable body, separated by a horizontal rule and clearly labeled `## AI Agent Notes`. This section is supplemental — a junior developer can ignore it entirely and still complete the task from the main body alone. An AI agent reads both the main body and this section for maximum context.

The AI Agent Notes section shall contain:

| Subsection | Description |
|------------|-------------|
| **Objective** | One-sentence statement of what this task accomplishes and why it matters in the context of the PRD |
| **Relevant Files** | Files to create, modify, or reference — with paths relative to repo root and a one-line description of each file's role |
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

### FR-6: Task Execution — Dual-Purpose (Phase 6)

**Trigger**: Task list is generated and GitHub Issues are pushed.

**FR-6.0** Phase 6 issues are designed for dual-purpose execution — either a human developer or an AI agent (Claude Code) can pick up any issue and complete it. When an AI agent executes, it reads both the main issue body and the AI Agent Notes section. When a human developer executes, the main body alone is sufficient. The user decides at execution time whether a given issue is assigned to a human or an AI agent.

**FR-6.1** The implementation agent (Claude Code) shall execute task implementation one sub-task at a time. The agent shall not proceed to the next sub-task until the user explicitly approves ("yes" or "y").

**FR-6.2** When an AI agent executes a task, it shall read the corresponding GitHub Issue — both the main body and the AI Agent Notes section — to load full implementation context:
- The objective and how it fits the broader PRD
- Relevant files to create or modify
- Existing codebase patterns to follow
- Dependencies (confirming prerequisite issues are closed)
- Technical constraints and compliance requirements
- Machine-readable acceptance criteria and expected test coverage
- Coding standards applicable to this task
- Out of scope boundaries to prevent drift

When a human developer executes a task, the main issue body (description, sub-task checklist, acceptance criteria) provides everything needed. The AI Agent Notes section can be ignored.

**FR-6.3** For each sub-task, the executor (human or AI agent) shall:
1. Read the sub-task description and, if AI agent, the AI Agent Notes from the parent issue
2. Check the existing codebase for related code, patterns, and utilities before writing new code
3. Implement the sub-task following the coding standards and existing patterns
4. Write or update tests as specified by the acceptance criteria
5. Mark the sub-task as `[x]` in the local task list

**FR-6.4** When all sub-tasks under a parent task are complete, the agent shall:
1. Run the full test suite
2. Only if tests pass: stage changes (`git add`)
3. Remove any temporary files and temporary code
4. Commit to a feature branch using conventional commit format (e.g., `git commit -m "feat: add payment validation" -m "- Validates card type" -m "Closes #42"`)
5. Push the feature branch and create a Pull Request via `gh pr create` with:
   - Title matching the parent task title
   - Body containing: summary of changes, list of sub-tasks completed, link to the GitHub Issue, and test results
   - Linked to the corresponding GitHub Issue
6. Mark the parent task as `[x]` in the local task list

**FR-6.5** The Pull Request is a human review gate. After the PR is created, the system shall present the user with a choice:

| Option | Behavior |
|--------|----------|
| **Human review** | The user (or a team member) reviews the PR in GitHub, leaves comments, requests changes, and merges when satisfied. The agent waits. |
| **AI-assisted review** | The agent performs a code review of its own PR — checking for adherence to coding standards, test coverage, potential issues, and consistency with the PRD. The agent posts its review as PR comments, then asks the user for final merge approval. |
| **AI review + auto-merge** | The agent reviews the PR, posts comments, and if no issues are found, merges automatically. The user is notified but does not need to act unless they want to intervene. |

The user selects their preferred option per PR. The default is human review.

**FR-6.6** Upon PR merge (regardless of review method), the agent shall:
1. Append an entry to `CHANGELOG.md` in the repo root, using the PR title, description, and linked issue as source material
2. Follow Keep a Changelog format (https://keepachangelog.com):
   ```
   ## [Unreleased]
   ### Added
   - Payment validation logic (#42) — Validates card type and expiry, adds unit tests for edge cases
   ```
3. Categorize entries under: Added, Changed, Deprecated, Removed, Fixed, Security — derived from the conventional commit prefix (feat → Added, fix → Fixed, refactor → Changed, etc.)
4. Close the corresponding GitHub Issue and move it to Done on the project board

**FR-6.7** Each completed sub-task shall produce a task step summary at `tasks/summary/task-[num]-summary.md` documenting what was done, decisions made during implementation, and any deviations from the original plan.

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

**FR-6.10** The agent shall update GitHub Issues as work progresses: close completed issues upon PR merge with a summary comment, and move cards on the project board from "In Progress" to "Done."

**FR-6.11** If the agent encounters ambiguity not resolved by the AI Agent Notes, it shall pause and ask the user rather than making assumptions. The resolution shall be added as a comment on the GitHub Issue for future reference.

**FR-6.12** When all tasks are complete and all PRs are merged, the agent shall compile `CHANGELOG.md` entries into release notes and present them to the user for review. The user can then tag a release (`git tag`) and publish release notes to GitHub Releases via `gh release create`.

### FR-7: Workflow Orchestration

**FR-7.1** The system shall maintain workflow state in `state/workflow-state.md`.

**FR-7.2** Commands:
- `status` — report current phase and progress
- `next` — advance to next phase (validates current phase complete)
- `resume` — restart session with full context from state + handoffs

**FR-7.3** Handoff artifacts shall be validated against contract schemas before phase advancement.

**FR-7.4** Cross-phase decisions recorded in `state/decisions.md`.

**FR-7.5** Anti-drift checklist maintained in `state/todo.md`.

### FR-8: Session Resilience

**FR-8.1** Each phase independently resumable via `resume` command.

**FR-8.2** Phase launchers preload context via `--append-system-prompt`.

**FR-8.3** Stop hooks validate output, run tests (where applicable), update state, and suggest git commits before phase completion.

### FR-9: Professional README

**FR-9.1** The template repo shall include a professionally written `README.md` as the primary onboarding document. It is not optional — it is a required deliverable of the MVP.

**FR-9.2** The README shall be structured for three audiences in order of priority:
1. **First-time user** — understands what this system does and whether it's relevant to them within 30 seconds of reading
2. **Getting started user** — can go from clone to running their first phase within 10 minutes by following the README alone
3. **Returning user** — can quickly reference commands, phase descriptions, and configuration options

**FR-9.3** The README shall include the following sections:

| Section | Content |
|---------|---------|
| **Header / Badge bar** | Project name, one-line description, badges (license, platform support, GitHub Issues link) |
| **What This Is** | 2-3 sentence plain-language explanation of the system — what it does, who it's for, and what you get out of it. No jargon. |
| **How It Works** | Visual overview of the 6-phase pipeline (Mermaid diagram rendered in GitHub). Brief one-sentence description of each phase. |
| **Quick Start** | Step-by-step setup for both macOS and Windows: clone, install prerequisites (Git, `gh` CLI, Claude Code, Node.js), source aliases, run first phase. Numbered steps, copy-pasteable commands. |
| **Prerequisites** | Table of required tools with version requirements and install links for both macOS (Homebrew) and Windows (winget/choco/manual). |
| **Usage** | Each phase command with a one-line description, expected inputs, and expected outputs. Organized as a reference table or command list. |
| **Phase Descriptions** | Expandable or linked sections for each phase with: what it does, when to use it, what it produces, and how to resume if interrupted. |
| **Project Structure** | Directory tree with one-line descriptions of each directory and key file. |
| **Dual-Purpose Issues** | Brief explanation of how GitHub Issues are structured for both human developers and AI agents, including the AI Agent Notes section. |
| **PR Review & Changelog** | How the PR gate works (three review options), how CHANGELOG.md is maintained, how to create a release. |
| **Configuration & Customization** | How to add new skills, override agent behavior per-project, and adjust coding standards. |
| **FAQ / Troubleshooting** | Common issues: compaction recovery, resuming interrupted phases, re-running a phase, Windows-specific gotchas. |
| **Contributing** | How to improve the system (add skills, improve agents, submit PRs to the template repo). |
| **License** | License declaration. |

**FR-9.4** The README shall use GitHub-compatible markdown features: Mermaid diagrams for the pipeline overview, collapsible `<details>` sections for phase descriptions to keep the page scannable, and a table of contents linking to each section.

**FR-9.5** The README shall not assume the reader is familiar with Claude Code, AI agents, or prompt engineering. It should read like professional open-source project documentation — comparable in quality to well-maintained tools like Husky, Commitlint, or similar developer tooling.

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

- Handoff artifacts survive compaction (file-based, not conversation-dependent).
- Any phase restartable from handoff inputs without data loss.
- Stop hooks prevent incomplete handoffs from being marked complete.
- Task step summaries provide recovery breadcrumbs if context is lost during execution.

### NFR-3: Usability

- Getting started requires only: clone the template repo, source `aliases.sh` (macOS/Linux) or `aliases.ps1` (Windows), and run the first phase command.
- Single `claude` CLI command per phase (via shell aliases).
- Agent prompts are self-documenting.
- Interview questions offer lettered/numbered options where possible for quick response.
- GitHub Issues are dual-purpose: main body written at junior developer level (explicit, unambiguous, no jargon), AI Agent Notes section appended for autonomous AI execution.
- A junior developer can complete any issue without reading the AI Agent Notes. An AI agent reads both for maximum context.
- Error messages from validation failures are actionable.

### NFR-4: Extensibility

- New tech stack skill packs addable by creating `skills/{name}/SKILL.md` — no code changes.
- New phases addable by creating a plugin directory — no changes to existing plugins.
- New council reviewers addable by creating an agent file in `prd-council/agents/`.
- Custom coding standards loadable as skill files.

### NFR-6: Cross-Platform Support

- The system shall work on both macOS and Windows operating systems.
- Shell aliases shall be provided in both Bash/Zsh (macOS/Linux) and PowerShell (Windows) formats.
- All file paths shall use platform-agnostic conventions (forward slashes or path resolution via Node.js/shell built-ins).
- Stop hooks and any scripts shall avoid Unix-only commands; where platform differences exist, provide both implementations or use cross-platform tooling (Node.js, `npx`).
- Git, `gh` CLI, and Claude Code are required dependencies on both platforms. Setup instructions shall cover both OS install paths.

### NFR-5: Security & Compliance Awareness

- System never commits sensitive data to handoff artifacts without explicit user approval.
- Compliance skills reference NIST 800-53, FedRAMP baselines, SOC 2 trust principles.
- Security findings flagged with severity ratings.
- Council security reviewer specifically validates compliance coverage.

---

## 8. Architecture Recommendations

### 8.1 MVP Tech Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| AI Runtime | Claude Code (CLI) | Primary tool; supports system prompt injection, hooks |
| Editor Integration | VS Code terminal | Familiar environment |
| Agent/Skill Definitions | Markdown files | Human-readable, version-controllable, no build step |
| Handoff Artifacts | Markdown with YAML frontmatter | Structured but human-reviewable |
| Task Lists | Markdown with checkbox format | Compatible with GitHub rendering, existing workflow |
| Diagrams | Mermaid format | Token-efficient; renderable in GitHub/VS Code |
| Quality Gates | TypeScript stop hooks | Native Claude Code hook system; cross-platform via Node.js |
| Platform Support | macOS + Windows | Bash/Zsh aliases + PowerShell aliases |
| Version Control | Git | Feature branches per task; PRs as review gates; all artifacts committed |
| Changelog | CHANGELOG.md (Keep a Changelog) | Auto-maintained from merged PRs; feeds GitHub Releases |
| Distribution | Template repo (clone per project) | Self-contained; no install step; npm package extraction post-MVP |
| PM Output | GitHub Issues + Projects + PRs | Via `gh` CLI — issues, milestones, project board, roadmap, pull requests |

### 8.2 Phase 2 Tech Stack (Web UI — Future)

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Frontend | TypeScript / React or Next.js | Team familiarity; SSR |
| Backend | AWS Lambda + API Gateway or Next.js API routes | Serverless; fits AWS infra |
| AI Integration | AWS Bedrock (Claude) or Anthropic API | Bedrock for gov compliance |
| Storage | S3 for artifacts, DynamoDB for state | Serverless, scalable |
| Auth | AWS Cognito or existing auth | Gov-compatible |
| Infrastructure | AWS CDK | Brian's preferred IaC |

### 8.3 Distribution Model

**MVP**: Template repo. The entire system (plugins, agents, skills, contracts, hooks, shell aliases) lives in a single GitHub repo that is cloned or forked to start a new project. The engine and per-project workspace coexist in the same repo.

```
workflow-system/                     ← Clone this to start any project
├── plugins/                         ← Engine (agents, skills, commands)
├── contracts/                       ← Handoff validation schemas
├── hooks/                           ← Stop hooks (TypeScript, cross-platform via Node.js)
├── aliases.sh                       ← Bash/Zsh aliases (macOS/Linux)
├── aliases.ps1                      ← PowerShell aliases (Windows)
│
├── handoffs/                        ← Per-project (initially empty)
├── state/                           ← Per-project (initialized by first run)
├── tasks/                           ← Per-project (PRDs, task lists, summaries)
├── diagrams/                        ← Per-project (generated during analysis)
│
├── CHANGELOG.md                     ← Auto-maintained from merged PRs
├── CLAUDE.md                        ← Root coordinator
└── README.md                        ← Professional onboarding doc (setup, usage, reference)
```

**Tradeoff acknowledged**: Cloning the engine into every project means improvements must be manually propagated to existing projects. This is acceptable for the MVP validation period where agent prompts and skills are expected to change frequently.

**Future (post-MVP)**: Once the agents and skills stabilize through real-project validation, the engine can be extracted into an npm package (`npx workflow-system init`) that scaffolds only the per-project directories (handoffs, state, tasks, diagrams) and references shared plugins at runtime. The agent/skill/contract files transfer directly — no rewrite needed. The CLI wrapper is the only new code.

### 8.4 Deployment Model

MVP is local — clone the template repo, source the aliases, and run phases from the terminal. No server, no deployment. Git is the persistence layer.

---

## 9. Risk Assessment

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| R1 | Context compaction loses mid-phase work | High | High | Anti-drift todo.md, frequent handoff checkpoints, stop hooks, task step summaries |
| R2 | Agent prompts produce inconsistent output | Medium | Medium | Standardized agent definitions with explicit output formats; contract validation |
| R3 | Analysis phase overwhelmed by large monorepo | Medium | Medium | Scope to specified directories; chunking strategy |
| R4 | Council review adds overhead without proportional value | Low | Medium | Council output is structured and actionable; user can accept/reject recommendations quickly |
| R5 | Two-phase task generation feels slow for simple features | Low | Low | Lightweight mode for small features: skip parent-task confirmation, generate directly |
| R6 | Compliance skills become outdated | Low | High | Skills reference control frameworks by ID; periodic review cadence |
| R7 | Task lists too granular or not granular enough | Medium | Medium | User confirms parent tasks before sub-task generation; adjustable decomposition depth |
| R8 | Full pipeline (6 phases) takes too long for small projects | Medium | Medium | Phases are independently invocable; user can skip analysis for greenfield. Council is always mandatory. |
| R9 | System prompt size exceeds token limits with all context loaded | Medium | High | Selective loading: only load prior handoff + current phase agents/skills, not entire history |

---

## 10. MVP vs. Future Phase Scoping

### MVP (Target: 2 weeks)

**Included:**
- Template repo (clone per project, engine + workspace self-contained)
- Shell aliases for phase launching (Bash/Zsh for macOS/Linux, PowerShell for Windows)
- Cross-platform support (macOS + Windows)
- Phase 1: Codebase Analysis plugin (optional, agents + skills for .NET, Python, TypeScript, AWS CDK)
- Phase 2: PRD Interview plugin (conversational, one-at-a-time, with quick-response options)
- Phase 3: PRD Synthesis plugin (7-8 section PRD, version tracking)
- Phase 4: Council Review plugin (4 reviewers + chair, synthesized output)
- Phase 5: PM Framework plugin (two-phase task generation, automatic GitHub Issues push, project board with kanban + roadmap, milestones with due dates)
- Phase 6: Task Execution — dual-purpose issues (human dev or AI agent), PR-based review gate with human/AI/auto-merge options, auto-maintained CHANGELOG.md, release notes compilation
- Workflow orchestration plugin (status, next, resume)
- Handoff contracts and validation
- Stop hooks for quality gates
- Professional README with setup guides for macOS and Windows, phase reference, directory structure, and FAQ
- Dual entry point support (repo or greenfield)

**Not included:**
- npm package distribution (post-MVP, once agents/skills stabilize)
- Web UI for non-technical users
- MCP server integration
- Model tiering optimization
- Multi-user collaboration
- Interview save/resume mid-conversation (nice-to-have, deferred)
- PM tool integration beyond GitHub (Linear, Jira)

### Phase 2: Web UI, npm Package & Broader Access

- Extract engine into npm package (`npx workflow-system init`) for clean per-project scaffolding
- Web-based conversational interface for non-technical users
- User authentication and session management
- Hosted PRD storage and retrieval
- Simplified interview flow for non-technical personas
- AWS Bedrock integration
- Deployed as serverless in AWS, potentially within an existing ATO boundary

### Phase 3: Optimization & Extended Integration

- Model tiering (Opus for synthesis/council, Sonnet for analysis, Haiku for validation)
- Interview save/resume for long sessions
- Integration with additional PM tools if needed (Linear, Jira)
- Advanced project board automation (auto-assign issues, sprint planning)
- Cross-project analytics (patterns across multiple PRDs and task lists)

---

## 11. Open Questions & Assumptions

### Assumptions

| # | Assumption | Confidence | Impact if Wrong |
|---|-----------|-----------|-----------------|
| A1 | `--append-system-prompt` handles combined agent + skill + handoff size without hitting token limits | High | Need chunking or selective loading |
| A2 | Markdown handoffs provide sufficient structure for context transfer | High | Move to JSON/YAML |
| A3 | Conversational one-at-a-time interview won't frustrate users who want to dump requirements | Medium | Add batch mode for pasting existing docs |
| A4 | Git is acceptable persistence for MVP | High | Trivial to add DB for Phase 2 |
| A5 | Four tech stack skill packs are sufficient for initial projects | High | Easy to add more |
| A6 | Council review completes in under 20 minutes | Medium | Council is mandatory — if slow, optimize agent prompts rather than skip |
| A7 | Two-week timeline accommodates 6 phases of agent/skill/contract development | Medium | Prioritize phases 2-5 if time is tight; phase 1 and 6 are most deferrable |
| A8 | Template repo duplication across projects is acceptable during MVP validation period | High | Extract to npm package once agents/skills stabilize |

### Resolved Questions

1. ~~**Interview save/resume**~~: Deferred — nice to have but not MVP.
2. ~~**PRD versioning**~~: Track versions explicitly (v1, v2, v3).
3. ~~**Compliance applicability**~~: Interview asks whether frameworks apply; section conditionally included.
4. ~~**PM output target**~~: GitHub Issues via `gh` CLI.
5. ~~**MCP server**~~: Not needed for MVP; file-based handoffs solve the same problem.

### Open Questions

All resolved.

6. ~~**Repo access**~~: Always clone locally. No GitHub API for analysis.
7. ~~**Council skip option**~~: Council is always mandatory. Every PRD goes through council review — no skip option.
8. ~~**Task estimation**~~: T-shirt sizing (S/M/L/XL). No hour-based estimates.
9. ~~**Definition of done**~~: Accepted as stated — real project produces a usable PRD, council surfaces at least one unconsidered issue, task list is actionable for a developer.
10. ~~**Distribution model**~~: Template repo for MVP (clone per project, self-contained). Extract to npm package post-MVP once agents/skills stabilize.

---

## 12. Success Criteria

The MVP is successful when:

1. Brian can run a legacy .NET Framework repo through the full pipeline (analysis → interview → PRD → council review → task list → GitHub Issues) and produce artifacts he would use for a real modernization project.
2. Brian can start from a greenfield idea and produce equivalent-quality output through the interview → PRD → council → task list → GitHub Issues pipeline.
3. The council review surfaces at least one concern or gap that was not identified during the interview/synthesis phases.
4. GitHub Issues are automatically created with milestones, labels, and a project board (kanban + roadmap) without manual intervention.
5. A session interruption at any phase boundary does not require rework — `resume` restores full context.
6. The PRD contains all required sections with measurable, testable requirements.
7. GitHub Issues are dual-purpose: a junior developer can follow the main body without reading AI Agent Notes, and an AI agent can execute autonomously using both sections.
8. The implementation agent (Claude Code) successfully codes, tests, commits to a feature branch, creates a PR, and closes a GitHub Issue for at least one complete parent task.
9. CHANGELOG.md is automatically updated upon PR merge with properly categorized entries in Keep a Changelog format.
10. The system works on both macOS and Windows.
11. The README enables a new user (Developer Manager / Developer Lead) to go from clone to running their first phase within 10 minutes without external help.
12. Total time from start to finished task list with GitHub Issues is under 3 hours for a moderately complex project.

---

*End of PRD — Version 2.0 Draft*
