# Fix Issue: $ARGUMENTS

## Instructions

Debug and fix: **$ARGUMENTS**

Follow the context injection pattern in `.claude/patterns/context-injection.md`, state-based session management pattern in `.claude/patterns/state-based-session-management.md`, and model selection guide in `.claude/patterns/model-selection.md`.

---

## Initialize Task Tracking

Write initial state to `.claude/plans/current-task.md`:

```markdown
## Current Task
**Command:** /project:fix $ARGUMENTS
**Status:** IN_PROGRESS
**Started:** {current_timestamp}
**Progress:** Step 0/4 - Starting
**Next:** Context Loading

## Workflow Steps
1. [ ] Load context (specs, file tree, error logs)
2. [ ] Engineer: Diagnose and fix issue
3. [ ] Validation: Test + Code Review
4. [ ] Approval

## Context
**Issue:** $ARGUMENTS
**Goal:** Identify root cause and implement fix with verification

## Resume Instructions
If interrupted, run: `/project:resume`
```

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

**Update task progress after context loading:**

```markdown
## Current Task
**Progress:** Step 1/4 - Context Loaded
**Next:** Engineer Diagnosis

## Workflow Steps
1. [x] Load context (specs, file tree, error logs) ✓ (completed {timestamp})
2. [ ] Engineer: Diagnose and fix issue ← CURRENT
3. [ ] Validation: Test + Code Review
4. [ ] Approval

## Last Checkpoint
**Completed:** Loaded specifications, project file tree, and error context
**Next Step:** Invoke Engineer agent to investigate and fix the issue
**Files Modified:** None (context loading only)
```

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

**Update task progress after fix implementation:**

```markdown
## Current Task
**Progress:** Step 2/4 - Fix Implemented
**Next:** Validation (Test + Code Review)

## Workflow Steps
1. [x] Load context ✓
2. [x] Engineer: Diagnose and fix issue ✓ (completed {timestamp})
3. [ ] Validation: Test + Code Review ← CURRENT
4. [ ] Approval

## Last Checkpoint
**Completed:** Engineer diagnosed root cause and implemented fix
**Next Step:** Invoke quality validation agents in parallel (Tester + Code Reviewer)
**Files Modified:**
- {list files from fix-notes.md}
- .claude/state/diagnosis.md
- .claude/state/fix-notes.md
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

**Update task progress after validation passes:**

```markdown
## Current Task
**Progress:** Step 3/4 - Validation Complete
**Next:** Approval

## Workflow Steps
1. [x] Load context ✓
2. [x] Engineer: Diagnose and fix issue ✓
3. [x] Validation: Test + Code Review ✓ (completed {timestamp})
4. [ ] Approval ← CURRENT

## Last Checkpoint
**Completed:** Validation passed (tests: passing, review: PASS)
**Next Step:** Present summary to user for approval
**Files Modified:**
- {implementation files from Step 1}
- tests/* (from Tester)
- .claude/state/test-results.md
- .claude/state/code-review-findings.md
```

---

## Output

Provide:
- **Root Cause:** What caused the bug (from `.claude/state/diagnosis.md`)
- **Changes Made:** Files modified and what was done
- **Verification:** Test results showing fix works
- **Prevention:** Suggestions to prevent similar issues
- **Git Commit:** Changes committed with descriptive message

**Update task status to COMPLETED:**

```markdown
## Current Task
**Command:** /project:fix $ARGUMENTS
**Status:** COMPLETED
**Started:** {started_timestamp}
**Completed:** {current_timestamp}
**Duration:** {calculate duration}
**Progress:** Step 4/4 - Complete

## Results
- **Root Cause:** {from diagnosis.md}
- **Fix Applied:** {summary from fix-notes.md}
- **Tests:** All passing ✅
- **Code Review:** PASS ✅

## Files Modified
- {list all files from all steps}

## Resume Instructions
Task completed. Run new command or `/project:resume` to review results.
```

**Ready for next command.**
