# Fix Issue: $ARGUMENTS

## Instructions

Debug and fix: **$ARGUMENTS**

### Investigation Phase

1. **Reproduce the Issue**
   - Understand the expected vs actual behavior
   - Identify steps to reproduce

2. **Analyze**
   - Search codebase for relevant code
   - Identify potential root causes
   - Check logs and error messages

3. **Diagnose**
   - Narrow down to the specific cause
   - Understand why the bug exists

### Fix Phase

Use the **engineer agent** to:

1. **Plan the Fix**
   - Describe the fix approach
   - Identify files to modify
   - Consider side effects

2. **Implement**
   - Make minimal, targeted changes
   - Preserve existing functionality
   - Add error handling if missing

3. **Verify & Loop (Max 3 Attempts)**

Follow the reflexion loop pattern in `.claude/patterns/reflexion.md`.

Use the **tester agent** to run tests.

**Reflexion Protocol (for fix command):**

**Attempt 1:** Apply fix, run tests. If tests fail, analyze why fix didn't work, adjust.
**Attempt 2:** If tests fail again, analyze deeper issue, adjust fix.
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
- Manually fix [specific file:line]
```

Do NOT attempt a 4th fix.

### Output
Provide:
- Root cause explanation
- Changes made
- How to verify the fix
- Suggestions to prevent similar issues
