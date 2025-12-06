# Implement: $ARGUMENTS

## Instructions

Implement the feature or task: **$ARGUMENTS**

### Pre-Implementation
1. Check for existing plans in `.claude/plans/`
2. Check for specs in `.claude/specs/`
3. Review existing codebase patterns

### Implementation Process

Use the **engineer agent** to:

1. **Understand Requirements**
   - Review any existing plan or spec
   - Clarify ambiguities with the user

2. **Plan Approach**
   - Outline what files will be created/modified
   - Identify potential challenges

3. **Implement Incrementally**
   - Work in small, testable chunks
   - Verify each chunk works before proceeding
   - Follow existing code patterns

4. **Verify & Loop (Max 3 Attempts)**

Use the **tester agent** to run tests.

**Reflexion Protocol:**

**Attempt 1:** If tests fail, read errors, identify root cause, fix code, retry.
**Attempt 2:** If tests fail again, read errors, identify root cause, fix code, retry.
**Attempt 3:** If tests fail again, **STOP**.

**Failure Termination:**

If tests fail after Attempt 3, output:

```
🔴 **Automated fixes failed after 3 attempts**

**Last Error:**
[error details]

**Manual Intervention Required:**
- Review error log above
- Recommended action: [specific suggestion]
- Run `/project:debug` OR manually fix [specific file:line]
```

Do NOT attempt a 4th fix.

### Output
After implementation:
- List all files changed
- Explain what was done
- Provide instructions to test
- Note any follow-up needed
