# Fix Issue: $ARGUMENTS

## Instructions

Debug and fix: **$ARGUMENTS**

Follow the context injection pattern in `.claude/patterns/context-injection.md`.

---

## Step 0: Load Project Context

Before invoking any agents, gather all shared context.

### 1. Read Core Specifications

Read specifications if they exist:
- `.claude/specs/requirements.md`
- `.claude/specs/architecture.md`
- `.claude/specs/tech-stack.md`

### 2. Generate Project File Tree

```bash
tree -L 3 -I 'node_modules|.git|dist|build|coverage' > /tmp/project-tree.txt
```

### 3. Read Error Context

If error logs or test failures are available, capture them.

---

## Step 1: Investigate Issue

Use the **engineer agent** with context injection:

```
<documents>
  <document index="1">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {{ARCHITECTURE_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>

  <document index="3">
    <source>Error Context</source>
    <document_content>
    {{ERROR_LOGS_OR_DESCRIPTION}}
    </document_content>
  </document>
</documents>

You are the Engineer agent.

**Context already loaded above - DO NOT re-read these files.**
**File tree shows project structure - DO NOT run ls/find commands.**

Your task: Investigate and diagnose this issue: $ARGUMENTS

Follow these steps:

1. **Reproduce the Issue**
   - Understand expected vs actual behavior
   - Identify steps to reproduce
   - Run tests if applicable

2. **Analyze**
   - Search codebase for relevant code using Grep tool
   - Identify potential root causes
   - Check error messages and stack traces

3. **Diagnose**
   - Narrow down to specific cause
   - Understand why the bug exists
   - Document root cause in `.claude/state/diagnosis.md`

4. **Plan the Fix**
   - Describe fix approach
   - Identify files to modify
   - Consider side effects

5. **Implement Fix**
   - Make minimal, targeted changes
   - Preserve existing functionality
   - Add error handling if missing
   - Follow architecture patterns from specs above

6. **Document Fix**
   - Write to `.claude/state/fix-notes.md`:
     - Root cause explanation
     - Changes made
     - Files modified
     - How to verify the fix

7. **Commit Your Work**
   ```bash
   git add src/ tests/
   git commit -m "fix: resolve {issue}

   - Root cause: {explanation}
   - Solution: {what was done}

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

Output: Path to `.claude/state/fix-notes.md`
```

---

## Step 2: Quality Validation (PARALLEL EXECUTION)

Follow the reflexion loop pattern in `.claude/patterns/reflexion.md` and parallel quality validation pattern in `.claude/patterns/parallel-quality-validation.md`.

Read `.claude/state/fix-notes.md` to understand what was fixed.

**PARALLEL EXECUTION:** Invoke Tester + Code Reviewer concurrently (use Task tool in single message).

### 2.1: Tester Agent

Use **tester agent** with context:

```
<documents>
  <document index="1">
    <source>.claude/state/fix-notes.md</source>
    <document_content>
    {{FIX_NOTES}}
    </document_content>
  </document>

  <document index="2">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>
</documents>

You are the Tester agent.

**Context already loaded above - DO NOT re-read files.**

Your task: Run tests to verify the fix works.

Focus on:
- Tests related to the bug that was fixed
- Regression tests to ensure no new issues
- Edge cases related to the fix

Output test results to: `.claude/state/test-results.md`
```

### Reflexion Protocol (Max 3 Attempts)

**Attempt 1:** If tests fail, read errors, analyze why fix didn't work, adjust.
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
- Review detailed diagnosis in .claude/state/diagnosis.md
- Recommended action: [specific suggestion]
- Run `/project:debug` OR manually fix [specific file:line]
```

Do NOT attempt a 4th fix.

---

### 2.2: Code Reviewer Agent

Invoke **code-reviewer agent** IN PARALLEL with Tester (same message):

```
<documents>
  <document index="1">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {{ARCHITECTURE_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/state/fix-notes.md</source>
    <document_content>
    {{FIX_NOTES}}
    </document_content>
  </document>
</documents>

You are the Code Reviewer agent.

**Context already loaded above - DO NOT re-read files.**

Your task: Review the bug fix for:
- Correctness
- Code quality
- Potential side effects
- Adherence to architecture patterns

Output review to: `.claude/state/code-review-findings.md`
```

**Wait for BOTH agents to complete before proceeding.**

---

## Step 3: Check Quality Results

Read both result files:
- `.claude/state/test-results.md`
- `.claude/state/code-review-findings.md`

### Decision Logic

**If tests fail:**
- Follow reflexion protocol (max 3 attempts) from Step 2.1
- Invoke Engineer with test failure context
- Return to Step 2

**If tests pass but review identifies issues:**
- Invoke Engineer with review findings as context
- Return to Step 2

**If both pass:**
- Proceed to Output

---

## Output

Provide:
- **Root Cause:** What caused the bug (from `.claude/state/diagnosis.md`)
- **Changes Made:** Files modified and what was done
- **Verification:** Test results showing fix works
- **Prevention:** Suggestions to prevent similar issues
- **Git Commit:** Changes committed with descriptive message

**Ready for next command.**
