# Testing: $ARGUMENTS

## Instructions

Create or run tests for: **$ARGUMENTS**

Follow the context injection pattern in `.claude/patterns/context-injection.md` and model selection guide in `.claude/patterns/model-selection.md`.

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

### 3. Read Implementation Context

If testing recently implemented code, read:
- `.claude/state/implementation-notes.md`

---

## Step 1: Invoke Tester Agent

Use the **tester agent** with context injection:

```
<documents>
  <document index="1">
    <source>.claude/specs/requirements.md</source>
    <document_content>
    {{REQUIREMENTS_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {{ARCHITECTURE_CONTENT}}
    </document_content>
  </document>

  <document index="3">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>

  <document index="4">
    <source>.claude/state/implementation-notes.md</source>
    <document_content>
    {{IMPLEMENTATION_NOTES}}
    </document_content>
  </document>
</documents>

You are the Tester agent.

**Context already loaded above - DO NOT re-read these files.**
**File tree shows project structure - DO NOT run ls/find commands.**

Your task: Create and run comprehensive tests for: $ARGUMENTS

Follow these steps:

1. **Analyze Target**
   - Understand what needs testing (from requirements and implementation notes)
   - Review existing tests in the file tree
   - Identify coverage gaps

2. **Design Test Strategy**
   - Plan test cases covering:
     - Happy path scenarios
     - Edge cases
     - Error conditions
     - Performance (if applicable)

3. **Create Tests**
   For each function/component:
   - Unit tests for individual functions
   - Integration tests for component interactions
   - E2E tests for user workflows (if applicable)

   Follow testing patterns from architecture specs.

4. **Run Tests**
   Execute test suite:
   ```bash
   npm test
   # or
   npm run test:coverage
   ```

5. **Analyze Results**
   - Identify passing vs failing tests
   - Calculate coverage percentage
   - Document gaps

6. **Document Results**
   Write to `.claude/state/test-results.md`:
   ```markdown
   # Test Results: {Feature Name}

   **Test Date:** {date}
   **Target:** $ARGUMENTS

   ## Summary
   - Total Tests: X
   - Passing: Y
   - Failing: Z
   - Coverage: N%

   ## Coverage Details
   | File | Lines | Branches | Functions |
   |------|-------|----------|-----------|
   | {file} | X% | Y% | Z% |

   ## Test Suites
   - ✅ {suite name} (X tests)
   - ❌ {suite name} (Y tests, Z failures)

   ## Coverage Gaps
   - {file:line} - {description}

   ## Recommendation
   {PASS/FAIL with reasoning}
   ```

7. **Commit Tests**
   ```bash
   git add tests/
   git commit -m "test: add comprehensive tests for {feature}

   - Coverage: X%
   - All tests passing
   - Edge cases covered

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

Output: Path to `.claude/state/test-results.md`
```

---

## Step 2: Reflexion Loop (If Tests Fail)

Follow the reflexion loop pattern in `.claude/patterns/reflexion.md`.

**Reflexion Protocol (Max 3 Attempts):**

**Attempt 1:** Run tests, identify failures. If tests fail, investigate code or test issues.
**Attempt 2:** If new failures appear, investigate environment or test infrastructure.
**Attempt 3:** If failures persist, check for deeper test infrastructure issues.

After 3 attempts with persistent failures, output:

```
🔴 **Test failures persist after 3 attempts**

**Last Failure:**
[failure details]

**Manual Intervention Required:**
- Review failure log above
- Review test results in .claude/state/test-results.md
- Recommended action: [specific suggestion]
- Check test infrastructure OR review test expectations
- Run `/project:debug` to investigate
```

Do NOT attempt a 4th run without changes.

---

## Step 3: Quality Check

If tests are passing, optionally invoke **code-reviewer agent** to review test quality:

```
<documents>
  <document index="1">
    <source>.claude/state/test-results.md</source>
    <document_content>
    {{TEST_RESULTS}}
    </document_content>
  </document>

  <document index="2">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>
</documents>

You are the Code Reviewer agent.

**Context already loaded above - DO NOT re-read files.**

Your task: Review test quality:
- Are tests comprehensive?
- Do they cover edge cases?
- Are tests maintainable?
- Any redundant tests?

Output brief review to: `.claude/state/test-quality-review.md`
```

---

## Output

Provide:
1. **Test Files Created/Modified:** List of test files
2. **Test Results Summary:** Pass/fail counts, coverage
3. **Coverage Information:** Percentage and gaps
4. **Recommendations:** Additional testing needed or improvements
5. **Git Commit:** Tests committed with coverage info

**Ready for next command.**
