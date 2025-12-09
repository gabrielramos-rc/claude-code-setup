---
description: Quick single-file fix without full validation cycle
allowed-tools: Read, Write, Edit, Bash(npm test:*), Grep, Glob
argument-hint: <file-path> <issue-description>
---

# Quick Fix: $ARGUMENTS

## Instructions

Apply a quick fix without the full validation workflow.

**Use this for:**
- Single-file bug fixes
- Typo corrections
- Small refactors
- Config adjustments

**DO NOT use for:**
- Multi-file changes (use `/project:fix` instead)
- Security-related code (use `/project:fix` instead)
- New features (use `/project:implement` instead)

---

## Process

### Step 1: Understand the Issue

Parse arguments: `$ARGUMENTS`
- Extract file path (if provided)
- Understand the issue description

### Step 2: Locate and Analyze

1. If file path provided, read it directly
2. If not, search for relevant file:
   ```
   Use Grep/Glob to find the file containing the issue
   ```

3. Understand the context around the issue

### Step 3: Apply Fix

Make the minimal change needed:
- Fix only the specific issue
- Don't refactor surrounding code
- Don't add new features
- Preserve existing style

### Step 4: Quick Validation

Run a quick sanity check:
```bash
# If TypeScript/JavaScript
npm run typecheck 2>/dev/null || true

# Run tests for the specific file if they exist
npm test -- --testPathPattern="$(basename $FILE .ts)" 2>/dev/null || true
```

### Step 5: Report

Provide a brief summary:
```
Quick Fix Applied: {file}

Issue: {description}
Change: {what was changed}
Lines: {line numbers}

Note: This was a quick fix. For complex issues, use /project:fix
```

---

## Examples

```
/project:quick-fix src/utils/format.ts fix date formatting bug
/project:quick-fix typo in error message
/project:quick-fix config.json update API endpoint
```

---

## Escalation

If you discover the fix requires:
- Multiple files → Recommend `/project:fix`
- Security implications → Recommend `/project:fix`
- Architectural changes → Recommend `/project:implement`

State: "This fix is more complex than expected. Recommend using `/project:fix` for proper validation."
