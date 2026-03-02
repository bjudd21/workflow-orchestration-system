# Development Standards for Workflow Orchestration System

**Last Updated**: 2026-03-02
**Purpose**: Apply the system's own documented standards to its own development

This document synthesizes standards from:
- `skills/execution/coding-standards.md` (3 principles, 10 categories)
- `skills/execution/commit-protocol.md` (branch, commit, PR practices)
- PRD FR-8.4 (LLM call resilience)
- n8n workflow best practices (emerging from implementation)

---

## Core Principles

### 1. **Clarity Over Cleverness**
*From coding-standards.md Principle 1*

- **n8n workflows**: Node names must be descriptive and follow a pattern
  - ✅ `Code - Validate Inputs` (verb + object)
  - ✅ `HTTP - Ollama Health` (protocol + purpose)
  - ❌ `Process` (too vague)
  - ❌ `node1` (meaningless)

- **File operations**: Always validate paths before read/write
  ```javascript
  // ✅ Good - validates existence
  if (!d.prdHandoff) throw new Error('prdHandoff path required');

  // ❌ Bad - assumes path exists
  const prd = fs.readFileSync(d.prdHandoff);
  ```

### 2. **Fail Fast, Fail Clear**
*From coding-standards.md Principle 2*

- **Error messages must include context**:
  ```javascript
  // ✅ Good
  throw new Error(`PRD not found at ${d.prdHandoff}. Run Phase 3 first.`);

  // ❌ Bad
  throw new Error('File not found');
  ```

- **Pre-flight checks before expensive operations** (FR-8.4):
  ```
  [User Input] → [Validate Inputs] → [Ollama Health Check] → [Expensive LLM Call]
                                             ↓
                                    [Clear Error + Guidance]
  ```

### 3. **Data Flow Integrity**
*From coding-standards.md Principle 3*

**Every node must preserve context unless explicitly discarding it.**

- **n8n HTTP Request nodes**: Use "Put Output in Field" to preserve input data
  ```json
  "options": {
    "destinationDataField": "healthCheck"  // Response goes here, rest preserved
  }
  ```

- **n8n IF nodes**: Pass-through — don't modify data, just route it

- **Code nodes**: Merge previous context with new data
  ```javascript
  // ✅ Good - preserves context
  const d = $('Code - Validate Inputs').first().json;
  return [{ json: { ...d, newField: value } }];

  // ❌ Bad - loses context
  return [{ json: { newField: value } }];
  ```

---

## n8n Workflow Standards

### Node Naming Convention

| Pattern | Example | When to Use |
|---------|---------|-------------|
| `Code - {Action}` | `Code - Validate Inputs` | JavaScript logic nodes |
| `HTTP - {Purpose}` | `HTTP - Run R1 (Tech)` | API calls with descriptive purpose |
| `Read - {What}` | `Read - PRD File` | Read Binary File nodes |
| `IF - {Condition}` | `IF - Ollama Reachable` | Conditional branching |
| `Webhook - {Action}` | `Webhook - Council Action` | Webhook entry points |
| `Respond - {What}` | `Respond - Review UI` | Webhook responses |

### Data Flow Patterns

#### Pattern 1: Health Check (Non-Invasive)
```
[Generate Data] → [HTTP Health Check] → [IF Check Passed] → [Continue]
                         ↓                      ↓
                   (preserves data)      (data still intact)
```

**Implementation**:
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://host.docker.internal:11434/api/tags",
    "options": {
      "destinationDataField": "healthCheck"
    }
  }
}
```

#### Pattern 2: File Read + Process
```
[Path Data] → [Read Binary File] → [Code - Process] → [Continue]
                    ↓                      ↓
             (reads file)         (converts to text + merges context)
```

**Implementation**:
```javascript
// Code - Process node
const d = $('Code - Validate Inputs').first().json;
const item = $input.first();
const content = Buffer.from(item.binary.data.data).toString('utf8');
return [{ json: { ...d, fileContent: content } }];
```

#### Pattern 3: LLM Call (FR-8.4 Resilience)
```
[Build Request] → [HTTP - LLM Call] → [Parse Response] → [Continue]
                        ↓
                  300s timeout
                  3 retries
                  30s backoff
```

**Implementation**:
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://host.docker.internal:11434/api/generate",
    "timeout": 300000,
    "options": {
      "retry": {
        "maxRetries": 3,
        "retryIntervalMs": 30000
      }
    }
  }
}
```

---

## Git Commit Standards

*From skills/execution/commit-protocol.md*

### Branch Naming
```
feature/phase-{N}-{description}
fix/{issue-description}
refactor/{component}
docs/{what}
```

**Examples**:
- ✅ `feature/phase-4-council-review`
- ✅ `fix/data-flow-preservation`
- ✅ `docs/development-standards`

### Conventional Commits

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature (workflow, agent, skill)
- `fix`: Bug fix
- `refactor`: Code restructuring (no behavior change)
- `docs`: Documentation only
- `test`: Test additions/fixes
- `chore`: Build, deps, tooling

**Examples**:
```bash
# Good
git commit -m "fix: preserve data through HTTP health check

- HTTP - Ollama Health now uses destinationDataField
- IF condition updated to check healthCheck.models
- Follows data flow integrity principle

Fixes data flow breakage causing Read nodes to fail"

# Bad
git commit -m "fixed it"
```

### Co-Authoring with AI
```
feat: build phase 4 council review workflow

All 8 sub-tasks complete. Sequential reviewer execution with
speed model batching per FR-10.11B.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Testing Standards

### Pre-Commit Checks
Before committing workflow changes:

1. **Export from n8n**: Don't edit JSON by hand
2. **Validate JSON**: `python3 -m json.tool workflows/*.json > /dev/null`
3. **Check node count**: Ensure nodes weren't lost
4. **Verify connections**: No orphaned nodes
5. **Test import**: Re-import to n8n, verify connections visible

### Test Data Requirements

**Phase 4 Council Review requires**:
```
workspace/
  {project-name}/
    handoffs/
      003-prd-refined.md    ← Must exist (from Phase 3)
```

**Create test data**:
```bash
# Create minimal PRD for testing
mkdir -p workspace/test-council/handoffs
cat > workspace/test-council/handoffs/003-prd-refined.md << 'EOF'
---
phase: prd-synthesis
version: v1
status: Draft
compliance: none
---

# Test PRD

## 1. Executive Summary
Test project for council review.

## 2. Functional Requirements
**FR-1**: System must do something

## 3. Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | Response time | < 2s |

## 4. User Stories
**US-1**: As a user, I want to test the council

## 5. Architecture Overview
Simple test architecture.

## 6. Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| R1 | Low | Low | Accept |

## 7. MVP vs. Future Phases
MVP: Basic functionality
EOF
```

---

## Documentation Standards

### Inline Comments (When to Use)
*From coding-standards.md Category 1*

**n8n Code nodes**: Comment complex logic only
```javascript
// ✅ Good - explains non-obvious behavior
// Model swap takes 15-30s, batch to avoid repeated swaps
const allReviewers = [...coreReviewers, ...specialists];

// ❌ Bad - obvious from code
// Set the project name
const project = body.project;
```

### Error Messages (User-Facing)
```javascript
// ✅ Good - actionable
throw new Error(`Ollama not reachable at ${OLLAMA_URL}. ` +
                `Verify Ollama is running: ollama list`);

// ❌ Bad - vague
throw new Error('Connection failed');
```

### File Headers (Python Scripts)
```python
#!/usr/bin/env python3
"""
{Purpose} - {Brief Description}

PRINCIPLE: {Which standard this follows}
ISSUE: {What problem this solves}
FIX: {How it's solved}
"""
```

---

## Common Pitfalls & Fixes

### ❌ Pitfall 1: Using `require()` in n8n Code Nodes
**Why**: n8n security sandbox blocks all Node.js built-in modules

**Fix**: Use n8n native nodes
```
require('fs').readFileSync() → Read Binary File node
require('http').request()    → HTTP Request node
require('child_process')     → Execute Command node
```

### ❌ Pitfall 2: HTTP Nodes Overwriting Data
**Why**: By default, HTTP nodes replace input with response

**Fix**: Use `destinationDataField`
```json
"options": {
  "destinationDataField": "apiResponse"
}
```

### ❌ Pitfall 3: Hardcoded Values in Workflows
**Why**: Makes workflows inflexible and hard to maintain

**Fix**: Use expressions and environment variables
```javascript
// ❌ Bad
const model = "qwen3.5:35b";

// ✅ Good
const model = $('Code - Validate Inputs').first().json.qualityModel ||
              process.env.OLLAMA_QUALITY_MODEL ||
              "qwen3.5:35b";
```

### ❌ Pitfall 4: Silent Failures
**Why**: Debugging is impossible without context

**Fix**: Always log + throw with context
```javascript
// ❌ Bad
if (!prd) return [];

// ✅ Good
if (!prd) {
  console.error(`PRD load failed. Path: ${d.prdHandoff}, Project: ${d.project}`);
  throw new Error(`PRD not found at ${d.prdHandoff}. Run Phase 3 first.`);
}
```

---

## Workflow Versioning

### When to Increment Version
- **Major (1.0 → 2.0)**: Breaking changes (different input/output format)
- **Minor (1.0 → 1.1)**: New features (added nodes, new paths)
- **Patch (1.0.0 → 1.0.1)**: Bug fixes (no behavior change)

### Workflow Metadata
```json
{
  "name": "Phase 4 — Council Review",
  "version": 1,
  "description": "Runs PRD Council: 4 core reviewers (speed model) + chair (quality model)",
  "meta": {
    "templateCredsSetupCompleted": false
  }
}
```

---

## Checklist: Before Merging a Workflow PR

- [ ] **Functionality**: Workflow executes end-to-end without errors
- [ ] **Data Flow**: All nodes preserve context correctly
- [ ] **Error Handling**: FR-8.4 resilience patterns applied (timeout, retries)
- [ ] **Naming**: All nodes follow naming convention
- [ ] **Testing**: Test data created, test passes with real data
- [ ] **Documentation**: Changes documented in PR description
- [ ] **Export**: Workflow exported from n8n (not hand-edited JSON)
- [ ] **Validation**: JSON validates, nodes have UUIDs not simple strings
- [ ] **Commit**: Conventional commit format with Co-Authored-By
- [ ] **Review**: Self-review: Would I understand this in 6 months?

---

## References

- **Coding Standards**: `skills/execution/coding-standards.md`
- **Commit Protocol**: `skills/execution/commit-protocol.md`
- **PRD FR-8.4**: LLM call resilience requirements
- **n8n Docs**: https://docs.n8n.io/ (workflow best practices)
- **This Doc**: Living document, update as patterns emerge

---

**Last Updated**: 2026-03-02 by Claude Sonnet 4.5
**Next Review**: After Phase 4 complete, capture lessons learned
