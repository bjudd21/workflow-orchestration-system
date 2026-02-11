# Workflow System Design Memory File

> **Purpose**: This document captures the complete context of a conversation about designing a multi-agent workflow system for software project analysis, PRD development, and project management. Feed this to an AI instance to continue the work.

---

## User Context

**Name**: Brian  
**Role**: IT Manager with 20 years of experience leading .NET development teams  
**Domain**: Government contracts (HUD PBRA systems, federal workloads)  
**Compliance**: SOC 2, FISMA, FedRAMP  
**Tech Stack**: .NET Framework → .NET 8 modernization, AWS infrastructure  
**AI Tools**: Claude Code, VS Code, exploring AWS Bedrock integration  

---

## Problem Statement

Brian has a recurring workflow he performs across many projects:

1. **Analyze** a git repository to understand architecture, dependencies, tech debt
2. **Document** the current state of the project
3. **PRD Interview** - AI interviews Brian to extract requirements for modernization or greenfield projects
4. **PRD Refinement** - Tighten the PRD until it's production-ready
5. **PM Framework** - Generate roadmap, milestones, issues, resource planning

### Key Challenges
- **Context window compaction**: Claude Code frequently compacts, losing accumulated context
- **No formalized system**: Currently ad-hoc, wants to systematize
- **Quality consistency**: Needs reliable outputs across phases
- **Handoff integrity**: Context must survive phase transitions

---

## Design Decision: Phase-Based Specialized Agents

### Why Specialized Agents Over Role-Switching

Once frequent compaction is accepted, the "single session with accumulated context" advantage disappears. Treating each phase as a separate agent with explicit handoffs:

- Forces good documentation at phase boundaries
- Allows agent optimization per phase
- Makes handoffs the primary interface (not conversation history)
- Enables parallel council reviews
- Supports model tiering (Opus for complex, Haiku for execution)

### Core Principles Adopted

1. **Memory files are first-class artifacts** - as important as code
2. **Contracts define handoffs** - each phase has input/output schemas
3. **Diagrams > Prose** for context (Mermaid format, token-efficient)
4. **Skills load on-demand** - progressive disclosure for domain expertise
5. **Councils for complex decisions** - multiple perspectives, synthesized
6. **Stop hooks enforce quality** - validate before phase completion
7. **Todo.md for anti-drift** - running checklist prevents context loss

---

## Architecture Overview

```
project/
├── .claude-plugin/
│   └── workflow-marketplace.json      <- Plugin registry
│
├── plugins/
│   ├── analysis/                       <- PHASE 1
│   │   ├── agents/
│   │   │   └── codebase-analyst.md
│   │   ├── commands/
│   │   │   └── analyze.md
│   │   └── skills/
│   │       ├── dotnet-patterns/SKILL.md
│   │       ├── gov-compliance-discovery/SKILL.md
│   │       └── tech-debt-assessment/SKILL.md
│   │
│   ├── prd-development/                <- PHASE 2-3
│   │   ├── agents/
│   │   │   ├── prd-interviewer.md
│   │   │   └── prd-writer.md
│   │   ├── commands/
│   │   │   ├── interview.md
│   │   │   └── synthesize.md
│   │   └── skills/
│   │       ├── stakeholder-interview/SKILL.md
│   │       ├── requirements-engineering/SKILL.md
│   │       └── gov-prd-requirements/SKILL.md
│   │
│   ├── prd-council/                    <- PHASE 4 (COUNCIL PATTERN)
│   │   ├── agents/
│   │   │   ├── technical-reviewer.md
│   │   │   ├── security-reviewer.md
│   │   │   ├── executive-reviewer.md
│   │   │   ├── user-advocate.md
│   │   │   └── council-chair.md
│   │   ├── commands/
│   │   │   ├── council-review.md
│   │   │   └── council-debate.md
│   │   └── skills/
│   │       ├── fisma-compliance-check/SKILL.md
│   │       └── fedramp-review/SKILL.md
│   │
│   ├── pm-framework/                   <- PHASE 5
│   │   ├── agents/
│   │   │   ├── pm-architect.md
│   │   │   ├── issue-generator.md
│   │   │   └── resource-planner.md
│   │   ├── commands/
│   │   │   ├── generate-roadmap.md
│   │   │   ├── generate-issues.md
│   │   │   └── estimate.md
│   │   └── skills/
│   │       ├── gov-contract-planning/SKILL.md
│   │       └── agile-estimation/SKILL.md
│   │
│   └── workflow-orchestration/         <- META PLUGIN
│       ├── agents/
│       │   ├── workflow-coordinator.md
│       │   └── reviewer-agent.md       <- "Second eyes" for drift
│       ├── commands/
│       │   ├── status.md
│       │   ├── next.md
│       │   └── resume.md
│       └── skills/
│           └── handoff-validation/SKILL.md
│
├── diagrams/                           <- Mermaid diagrams (compressed context)
│   ├── architecture.mermaid.md
│   ├── data-flow.mermaid.md
│   └── auth-flow.mermaid.md
│
├── handoffs/                           <- Phase output artifacts
│   ├── 001-analysis-complete.md
│   ├── 002-prd-interview.md
│   ├── 003-prd-refined.md
│   └── 004-pm-framework.md
│
├── contracts/                          <- Handoff validation schemas
│   ├── analysis-output.schema.md
│   ├── prd-output.schema.md
│   └── pm-output.schema.md
│
├── state/                              <- Workflow state
│   ├── workflow-state.md               <- Current phase + metadata
│   ├── decisions.md                    <- Cross-phase decisions log
│   └── todo.md                         <- Anti-drift checklist
│
├── hooks/                              <- Claude Code hooks
│   ├── stop-hook.ts                    <- Quality gates
│   └── phase-validator.ts              <- Contract validation
│
└── CLAUDE.md                           <- Root coordinator
```

---

## Key Patterns Integrated

### 1. Councils of Agents (James Stanier)

**Source**: https://theengineeringmanager.substack.com/p/councils-of-agents

Instead of single reviewers, spawn multiple perspective agents:
- Technical Reviewer (feasibility, architecture)
- Security Reviewer (compliance, risks)
- Executive Reviewer (business alignment)
- User Advocate (user value)
- Council Chair (synthesizes all perspectives)

Each agent has stated biases. Chair identifies consensus, surfaces conflicts, recommends revisions.

### 2. Plugin Architecture (wshobson/agents)

**Source**: https://github.com/wshobson/agents

Structure: `plugins/{name}/agents/ + commands/ + skills/`

Key insights:
- Each plugin does one thing well (Unix philosophy)
- Average plugin size: 3.4 components
- Skills use progressive disclosure (metadata always loaded, instructions on activation, resources on demand)
- Model tiering: Sonnet for complex tasks, Haiku for execution

### 3. Mermaid Diagrams for Context (John Lindquist)

**Source**: How I AI podcast with John Lindquist

- Diagrams compress application structure into token-efficient format
- AI consumes mermaid easily; humans struggle
- Preload via `claude --append-system-prompt "$(cat diagrams/*.md)"`
- Generate diagrams after each working feature, not upfront

### 4. Stop Hooks for Quality Gates (John Lindquist)

Check for errors before Claude thinks it's done:
```typescript
// On stop: check for errors → if errors, feed back to Claude → else commit
```

Extended for handoff validation:
- Validate handoff against contract schema
- Block phase completion if contract not satisfied
- Update workflow state on success

### 5. Anti-Drift with Todo.md (Manus/Context Engineering)

Maintain a running checklist that persists across compaction:
- Updated step-by-step as work progresses
- Fights context degradation in long sessions
- Injected into prompts to maintain focus

### 6. "Second Eyes" Reset Pattern (John Lindquist)

When things go off the rails:
1. Export conversation
2. Feed to different model (GPT-5, Gemini)
3. Have it critique and diagnose drift
4. Provide corrected starting prompt
5. Restart phase

Built into architecture as `reviewer-agent.md`.

### 7. System Prompt Preloading (John Lindquist)

Rather than relying on Claude to read files:
```bash
claude --append-system-prompt "$(cat plugins/analysis/agents/*.md plugins/analysis/skills/*/SKILL.md)"
```

Context is already there at session start.

---

## Agent File Formats

### Agent Definition (`agents/*.md`)

```markdown
---
name: agent-name
description: Brief description of role
model: sonnet | haiku | opus
skills:
  - skill-name-1
  - skill-name-2
---

# Agent Name

You are a [role description].

## Your Perspective
- [What you focus on]
- [Your expertise]

## Your Biases (Stated Openly)
- [Acknowledged biases that affect your judgment]

## Process
1. [Step 1]
2. [Step 2]

## Output Format
[Specified output structure]
```

### Skill Definition (`skills/*/SKILL.md`)

```markdown
---
name: skill-name
description: What the skill does. Use when [trigger conditions].
---

# Skill Title

## When to Use
[Activation criteria]

## Core Knowledge
[Domain expertise, patterns, best practices]

## Output Requirements
[What outputs should include]

## Anti-Patterns
[What to avoid]
```

### Command Definition (`commands/*.md`)

```markdown
---
name: command-name
description: What this command does
---

# Command Title

## Process
1. [Step 1]
2. [Step 2]

## Invocation
```
/plugin-name:command-name [arguments]
```

## Output
[What gets produced]
```

### Contract Schema (`contracts/*.schema.md`)

```markdown
# Phase Output Contract

## Required Sections

### 1. Section Name (required)
- field_name: type
- field_name: type

### 2. Section Name (required)
[etc.]

## Output Location
Write to: handoffs/XXX-phase-name.md

## Format
Markdown with YAML frontmatter for structured data.
```

---

## Handoff Format

```markdown
---
phase: analysis
completed: 2025-02-10T14:30:00Z
agent: codebase-analyst
project: project-name
---

# Phase Handoff: Analysis → PRD Development

## Summary
[2-3 sentence summary of what was done]

## Key Findings
1. [Finding 1]
2. [Finding 2]

## Artifacts Produced
- [List of files created]

## Context for Next Phase
[What the next agent needs to know]

## Decisions Made
- D001: [Decision + rationale]

## Do NOT Lose
- [Critical facts that might seem minor but matter]
```

---

## Workflow State Format

```markdown
# Current Workflow State

## Phase
PM_FRAMEWORK (Phase 5 of 5)

## Completed
- [x] Analysis - see handoffs/001-analysis-complete.md
- [x] PRD Interview - see handoffs/002-prd-interview.md
- [x] PRD Council Review - see handoffs/003-prd-refined.md
- [ ] PM Framework

## Current Objective
Generate milestones and issues from PRD

## Key Context for This Phase
- PRD has 4 epics
- Timeline constraint: 6 months
- Team size: 3 devs + 1 DevOps
- Compliance: FISMA moderate

## Next Actions
1. Create milestone breakdown
2. Generate issue templates for each epic
3. Estimate resource allocation

## Resume Instructions
If starting a new session, read:
1. This file
2. handoffs/003-prd-refined.md
3. state/decisions.md (last 5 entries)
```

---

## Shell Aliases

```bash
# ============================================
# Plugin-Based Workflow Aliases
# ============================================

# Phase launchers
alias cc-analyze='claude --append-system-prompt "$(cat plugins/analysis/agents/*.md plugins/analysis/skills/*/SKILL.md diagrams/*.md 2>/dev/null)"'

alias cc-prd='claude --append-system-prompt "$(cat plugins/prd-development/agents/*.md plugins/prd-development/skills/*/SKILL.md handoffs/001-*.md 2>/dev/null)"'

alias cc-council='claude --append-system-prompt "$(cat plugins/prd-council/agents/*.md plugins/prd-council/skills/*/SKILL.md handoffs/002-*.md 2>/dev/null)"'

alias cc-pm='claude --append-system-prompt "$(cat plugins/pm-framework/agents/*.md plugins/pm-framework/skills/*/SKILL.md handoffs/003-*.md 2>/dev/null)"'

# Workflow management
alias cc-status='claude -p "Read state/workflow-state.md and state/todo.md. Report current phase, completed work, and next steps."'

alias cc-resume='claude --append-system-prompt "$(cat plugins/workflow-orchestration/agents/*.md state/*.md diagrams/*.md 2>/dev/null)"'

# Quick modes
alias ccx='claude --dangerously-skip-permissions'
alias cch='claude --model haiku'

# Council review
alias cc-council-review='claude --append-system-prompt "$(cat plugins/prd-council/agents/*.md)" -p "Convene the PRD council. Each reviewer analyzes handoffs/002-prd.md from their perspective. Council chair synthesizes."'
```

---

## Example Agent Definitions

### Technical Reviewer (Council Member)

```markdown
---
name: technical-reviewer
description: Senior engineer perspective on PRD feasibility
model: sonnet
---

# Technical Reviewer

You are a Principal Engineer reviewing a PRD for technical feasibility.

## Your Perspective
- Is this architecturally sound?
- What are the technical risks?
- Is the scope realistic for the proposed timeline?
- What dependencies are missing?
- Are there better technical approaches?

## Your Biases (Stated Openly)
- You prefer proven technologies over bleeding edge
- You value maintainability over cleverness
- You're skeptical of timelines that don't include buffer

## Output Format
Provide 3-5 bullet points of concerns or endorsements.
Rate overall technical feasibility: LOW / MEDIUM / HIGH
```

### Security Reviewer (Council Member)

```markdown
---
name: security-reviewer
description: Security and compliance perspective for government contracts
model: sonnet
skills:
  - fisma-compliance-check
  - fedramp-review
---

# Security & Compliance Reviewer

You are a Security Engineer reviewing a PRD for government contract work.

## Your Perspective
- Does this meet FISMA/FedRAMP requirements?
- Are there data handling concerns?
- What security controls are implied but not stated?
- Are there ATO implications?

## Your Biases (Stated Openly)
- You assume the worst-case threat model
- You prefer explicit security requirements over implied
- You question any "we'll handle security later" statements

## Output Format
Provide 3-5 security/compliance concerns.
List any missing security requirements.
Rate compliance risk: LOW / MEDIUM / HIGH
```

### Council Chair (Synthesizer)

```markdown
---
name: council-chair
description: Synthesizes council feedback into actionable refinements
model: opus
---

# Council Chair

You synthesize feedback from the PRD review council into actionable guidance.

## Input
You receive perspectives from:
- Technical Reviewer (feasibility)
- Security Reviewer (compliance)
- Executive Reviewer (strategy)
- User Advocate (user value)

## Your Role
1. Identify consensus (where all agree)
2. Surface conflicts (where perspectives differ)
3. Prioritize concerns by severity
4. Recommend specific PRD revisions
5. Flag items needing human decision

## Output Format
### Consensus Points
[What everyone agrees on]

### Conflicts Requiring Resolution
[Where perspectives differ - present both sides]

### Recommended Revisions
[Specific changes to make to the PRD]

### Decisions for Stakeholder
[Items only a human can resolve]
```

---

## Example Skill Definition

### Government Compliance Discovery

```markdown
---
name: gov-compliance-discovery
description: Identify compliance requirements in government contract codebases. Use when analyzing repos for FISMA, FedRAMP, SOC 2, or HUD systems.
---

# Government Compliance Discovery

When analyzing a codebase for a government contract, identify:

## Compliance Indicators to Look For
- Authentication patterns (PIV/CAC requirements)
- Data classification markers
- Audit logging implementations
- Encryption at rest/in transit
- Access control patterns
- PII handling

## Questions to Surface
- What data sensitivity level is this system?
- What ATO boundary does this fall under?
- Are there FISMA control implementations?
- Is there FedRAMP inheritance from cloud providers?

## Output Requirements
- List discovered compliance patterns
- Flag gaps against expected controls
- Note ATO-impacting changes if modernizing

## Reference Controls
- NIST 800-53 control families
- FedRAMP baseline mappings
- SOC 2 trust principles
```

### Stakeholder Interview Techniques

```markdown
---
name: stakeholder-interview
description: Conduct effective stakeholder interviews for requirements gathering. Use when interviewing for PRD development.
---

# Stakeholder Interview Techniques

## Core Questions by Area

**Vision & Goals**
- "What does success look like 6 months after launch?"
- "Who are the primary users and what are they trying to accomplish?"
- "What happens if we don't build this?"

**Scope & Constraints**
- "What's explicitly out of scope?"
- "What's the MVP vs. future phases?"
- "Are there hard deadlines? What's driving them?"

**Technical Direction**
- "Are there technology preferences or constraints?"
- "What systems does this integrate with?"
- "Are there compliance requirements?"

**Resources**
- "What's the team composition?"
- "Are there budget constraints?"
- "What dependencies exist on other teams?"

## Probing Techniques
- "Tell me more about that..."
- "What would happen if...?"
- "How would you prioritize between X and Y?"
- "What's the biggest risk you see?"

## Anti-Patterns to Avoid
- Leading questions
- Assuming requirements
- Skipping the "why"
- Not quantifying ("fast" → "under 200ms")
```

---

## Stop Hook Implementation

```typescript
// hooks/stop-hook.ts

import { execSync } from 'child_process';
import { readFileSync, existsSync, writeFileSync } from 'fs';

interface HookInput {
  session_id: string;
  cwd: string;
}

async function main() {
  const input: HookInput = JSON.parse(readFileSync('/dev/stdin', 'utf-8'));
  
  // Check for changed files
  let filesChanged: string[] = [];
  try {
    const diff = execSync('git diff --name-only', { encoding: 'utf-8' });
    filesChanged = diff.split('\n').filter(Boolean);
  } catch { }

  if (filesChanged.length === 0) {
    process.exit(0);
  }

  // Check for handoff files - validate against contracts
  const handoffFiles = filesChanged.filter(f => f.includes('handoffs/'));
  if (handoffFiles.length > 0) {
    for (const handoff of handoffFiles) {
      const phase = handoff.match(/\d+-(\w+)/)?.[1];
      const contractPath = `contracts/${phase}-output.schema.md`;
      
      if (existsSync(contractPath)) {
        console.log(JSON.stringify({
          block: false,
          message: `Handoff created for ${phase}. Please validate against ${contractPath} and fix any issues.`
        }));
        process.exit(0);
      }
    }
  }

  // Update todo.md
  const todoPath = 'state/todo.md';
  if (existsSync(todoPath)) {
    const todo = readFileSync(todoPath, 'utf-8');
    const update = `\n\n## Last Action (${new Date().toISOString()})\nFiles: ${filesChanged.join(', ')}`;
    writeFileSync(todoPath, todo + update);
  }

  // Suggest commit
  console.log(JSON.stringify({
    block: false,
    message: `All checks passed. Please commit: ${filesChanged.join(', ')}`
  }));
}

main().catch(console.error);
```

---

## Sources Referenced

1. **ChatPRD** (https://www.chatprd.ai)
   - PRD + CLAUDE.md pattern for Claude Code
   - MCP integration for live PRD access
   - Lenny's Podcast transcripts as knowledge base example

2. **John Lindquist - How I AI Podcast**
   - Mermaid diagrams for compressed context
   - System prompt preloading with `--append-system-prompt`
   - Stop hooks for quality gates
   - CLI aliases for workflow efficiency
   - "Second eyes" reset pattern

3. **James Stanier - Councils of Agents**
   - Multi-agent review councils
   - Technical council + Executive council patterns
   - Stated biases for each agent perspective

4. **wshobson/agents** (https://github.com/wshobson/agents)
   - Plugin architecture (agents/ + commands/ + skills/)
   - Progressive disclosure for skills
   - Model tiering (Sonnet + Haiku orchestration)
   - Multi-agent orchestration patterns (sequential, parallel, review)

5. **Agent Skills Specification** (https://agentskills.io/specification)
   - SKILL.md format with YAML frontmatter
   - Three-tier loading (metadata → instructions → resources)
   - Token efficiency through on-demand loading

---

## Current State

**Phase**: Design complete, ready for implementation

**Completed in Conversation**:
- [x] Identified the problem (compaction, lack of formalization)
- [x] Decided on phase-based specialized agents
- [x] Designed plugin architecture
- [x] Integrated council pattern for PRD review
- [x] Defined handoff contracts
- [x] Created example agent and skill definitions
- [x] Designed shell aliases for workflow
- [x] Designed stop hooks for quality gates

**Next Steps to Implement**:
1. Create the directory structure in a template repo
2. Write full agent definitions for each phase
3. Write skill files for Brian's domains (gov compliance, .NET modernization)
4. Write contract schemas for each handoff
5. Implement stop hooks
6. Create initial mermaid diagram generation prompts
7. Test with a real project

---

## Questions for Continuation

When continuing this work, the AI should:

1. **Ask Brian** which phase he wants to start implementing first
2. **Clarify** any domain-specific requirements for skills (specific FISMA controls, .NET patterns)
3. **Offer** to create the complete directory structure as a starter kit
4. **Consider** whether to integrate with ChatPRD's MCP server or build custom
5. **Determine** if Brian wants GitHub Issues, Linear, or another PM tool for the output

---

## How to Use This Memory File

```bash
# Start a new Claude Code session with this context
claude --append-system-prompt "$(cat workflow-system-memory.md)"

# Or in Claude.ai, upload this file and say:
# "I'm continuing work on this workflow system design. 
#  Please review the memory file and help me implement [specific phase]."
```

---

*Last updated: 2025-02-10*
*Conversation with: Claude (Anthropic)*
*User: Brian (IT Manager, Government Contracts)*
