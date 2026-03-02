# Phase 4 Council Review - Module Disallowed Fix

**Date**: 2026-03-02
**Issue**: `Module 'http' is disallowed` / `Module 'fs' is disallowed`
**Status**: ✅ FIXED

## Problem

n8n's Code nodes run in a security sandbox that blocks Node.js built-in modules like:
- `require('fs')` - File system operations
- `require('http')` - HTTP requests
- `require('child_process')` - Process execution
- All other core Node modules

The Phase 4 workflow was using these forbidden modules in multiple Code nodes, causing execution failures.

## Root Cause

Recent refactors (commits after 6ad217b) attempted to merge workflow steps into "self-contained" Code nodes using `require('http')` and `require('fs')`. This violated n8n's security model.

## Solution Applied

### 1. Restored HTTP Request Nodes (from commit 6ad217b)
Replaced Code nodes with `require('http')` with proper n8n HTTP Request nodes:
- ✅ HTTP - Run R1 (Tech)
- ✅ HTTP - Run R2 (Sec)
- ✅ HTTP - Run R3 (Exec)
- ✅ HTTP - Run R4 (User)
- ✅ HTTP - Warm Quality Model
- ✅ HTTP - Run Chair

### 2. Removed All `require('fs')` Calls
Replaced file system operations with n8n native nodes:

| Old Code Node | Fix Applied |
|---------------|-------------|
| Code - Validate Inputs | Simplified (removed review counting) |
| Code - Load PRD | → Read - PRD File + Code - Process PRD |
| Code - Load Reviewers | Structured data only (no file reads) |
| Code - Build Chair Request | Inline prompt placeholder (MVP) |
| Code - Handle User Decision | + Read - Council for Decision nodes |
| Code - Handle Gate Decision | + Read - Council for Gate nodes |

### 3. Architecture Pattern

```
┌─────────────────┐
│  Code - Prepare │  ← Build request data
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Read Binary File│  ← Read files via n8n native node
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Code - Process  │  ← Parse file content (no require)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  HTTP Request   │  ← Call APIs via n8n native node
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Code - Parse    │  ← Process response
└─────────────────┘
```

## Verification

```bash
$ grep -c "require(" workflows/phase-4-council-review.json
0
```

✅ No `require()` calls remain in the workflow!

## Next Steps

1. **Re-import the workflow to n8n**:
   ```
   - Open n8n UI: http://localhost:5678
   - Workflows → Delete existing "Phase 4 — Council Review"
   - Import from File → Select workflows/phase-4-council-review.json
   - Activate the workflow
   - Save (Ctrl+S)
   ```

2. **Test the workflow**:
   ```
   http://localhost:5678/webhook/council-review
   ```
   - Enter a project name (e.g., "test-project")
   - Click "Start Council Review"
   - Should run without "Module disallowed" errors

3. **Expected behavior**:
   - PRD contract validation
   - 4 reviewers run sequentially (speed model)
   - Model warm-up
   - Council chair runs (quality model)
   - Review displayed in UI
   - Accept/Reject decision handling
   - Re-review gate (PROCEED/RECONVENE)

## Known Limitations (MVP)

- **Code - Build Chair Request** uses inline prompt placeholder
  - Production version should use Read Binary File nodes for:
    - `prompts/prd-council/core/council-chair.md`
    - `skills/council/council-synthesis.md`
  - Current inline placeholder is sufficient for MVP testing

- **Code - Validate Inputs** always starts at reviewNum=1
  - No automatic detection of existing reviews
  - Re-review numbering (r2, r3, etc.) not implemented yet
  - User must manually track review iterations

## Lessons Learned

1. **Never use `require()` in n8n Code nodes** - always blocked by security sandbox
2. **Use n8n native nodes** for file I/O and HTTP:
   - File operations: `Read Binary File` / `Write Binary File`
   - HTTP operations: `HTTP Request`
   - Process operations: `Execute Command`
3. **Test workflow imports immediately** - disconnected nodes = wrong JSON structure
4. **Follow Phase 3 patterns** - it works correctly with HTTP Request nodes

## Commit History

- `1715cc5` - fix: remove all require() calls from Phase 4 workflow
- `6ad217b` - fix: correct HTTP Request body format for Ollama API calls (working base)
- `a820221` - refactor: final merged solution (introduced require('http') bug)

## Status

✅ Fixed and ready for testing
📍 Commit: `1715cc5`
🔀 Branch: `feature/phase-3-prd-synthesis`
🎯 Next: Test in n8n, then merge PR #64
