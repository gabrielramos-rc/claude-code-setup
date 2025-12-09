---
description: Refactor code with safety checks and validation
allowed-tools: Task, Read, Write, Edit, Bash(npm:*), Bash(git:*), Grep, Glob
argument-hint: <target> <refactoring-type>
---

# Refactor: $ARGUMENTS

## Instructions

Safely refactor: **$ARGUMENTS**

---

## Refactoring Types

| Type | Description | Example |
|------|-------------|---------|
| **rename** | Rename symbol across codebase | `rename getUserById to findUserById` |
| **extract** | Extract function/component | `extract validation logic from UserForm` |
| **inline** | Inline unnecessary abstraction | `inline unused helper function` |
| **move** | Move code to different location | `move utils to shared module` |
| **simplify** | Reduce complexity | `simplify nested conditionals in auth` |
| **modernize** | Update to modern patterns | `modernize callbacks to async/await` |

---

## Process

### Step 1: Understand the Refactoring

Parse arguments to identify:
- **Target:** What code to refactor
- **Type:** What kind of refactoring
- **Scope:** How many files affected

### Step 2: Pre-flight Checks

Before making changes:

```bash
# Ensure clean working state
git status

# Run existing tests
npm test

# Check for type errors
npm run typecheck 2>/dev/null || true
```

**STOP if tests fail** - Fix existing issues before refactoring.

### Step 3: Impact Analysis

Identify all affected locations:

```
1. Use Grep to find all usages of the target
2. Map dependencies and dependents
3. List all files that will change
4. Check for dynamic references (strings, reflection)
```

Report:
```markdown
## Impact Analysis

**Files affected:** {count}
**References found:** {count}

### Files to Modify
- `{file1}` - {X references}
- `{file2}` - {Y references}

### Potential Risks
- {risk 1}
- {risk 2}
```

### Step 4: Execute Refactoring

Apply changes systematically:

1. **Make the core change** (rename, extract, etc.)
2. **Update all references** in order:
   - Same file
   - Same directory
   - Other directories
   - Tests
   - Documentation
3. **Preserve behavior** - No functional changes

### Step 5: Validation

Run comprehensive checks:

```bash
# Type check
npm run typecheck

# Run all tests
npm test

# Run linter
npm run lint 2>/dev/null || true
```

### Step 6: Invoke Validation Agents

Use parallel validation for larger refactors:

```
Invoke in parallel:
- Tester Agent: Verify tests still pass
- Code Reviewer Agent: Verify refactoring quality
```

### Step 7: Report Results

```markdown
## Refactoring Complete: {description}

### Changes Made
- {change 1}
- {change 2}

### Files Modified ({count})
- `{file1}`
- `{file2}`

### Validation Results
- Type Check: {PASS/FAIL}
- Tests: {PASS/FAIL} ({count} tests)
- Lint: {PASS/FAIL}

### Behavioral Changes
{None / List any unavoidable changes}

### Rollback
If needed: `git checkout -- .` or `/project:rollback`
```

---

## Safety Rules

1. **Never refactor and add features** in the same operation
2. **Always run tests** before and after
3. **Commit incrementally** for large refactors
4. **Preserve all behavior** - refactoring changes structure, not function
5. **Check dynamic references** - strings, config, reflection
6. **Update documentation** if public APIs change

---

## Examples

```
/project:refactor rename getUserById to findUserById
/project:refactor extract validation logic from UserForm component
/project:refactor move src/utils/auth.ts to src/auth/utils.ts
/project:refactor simplify src/services/payment.ts
/project:refactor modernize callbacks to async/await in api/
```

---

## When to Use Other Commands

- **Adding functionality:** Use `/project:implement`
- **Fixing bugs:** Use `/project:fix`
- **Small single-file changes:** Use `/project:quick-fix`
- **Architecture changes:** Use `/project:plan` first
