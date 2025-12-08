# Parallel Quality Validation Pattern

**Version:** v0.3 Phase 2
**Purpose:** Run multiple quality agents concurrently for faster feedback
**Created:** 2025-12-06

---

## Pattern Overview

**Problem:** Running quality agents (Tester, Security Auditor, Code Reviewer) sequentially takes 10+ minutes.

**Solution:** Use the Task tool to launch multiple agents in parallel, reducing total time by ~50%.

**Research Backing:**
> "Running style-checker, security-scanner, and test-coverage subagents simultaneously reduces multi-minute reviews to seconds." - Anthropic Subagents Documentation

---

## Time Comparison

### Sequential Execution (OLD)
```
Tester (5 min) → Security Auditor (3 min) → Code Reviewer (2 min)
Total: 10 minutes
```

### Parallel Execution (NEW)
```
[Tester, Security Auditor, Code Reviewer] run concurrently
Total: 5 minutes (longest agent duration)

Time savings: 50%
```

---

## How to Use This Pattern

### Step 1: Prepare Context

Before launching parallel agents, ensure you have:
- Implementation notes in `.claude/state/implementation-notes.md`
- Specifications loaded (architecture.md, requirements.md, tech-stack.md)
- Project file tree generated

### Step 2: Launch Agents in Parallel

**CRITICAL:** Use a SINGLE message with MULTIPLE Task tool invocations.

#### Correct Implementation (Parallel)

In your command workflow, say:

```markdown
Now I'll launch three quality agents in parallel to validate the implementation.
```

Then invoke THREE Task tools in ONE message:

**Task #1: Tester Agent**
- subagent_type: "tester"
- Prompt includes: requirements.md, implementation-notes.md, file tree
- Task: Design tests, implement tests, run tests, report results

**Task #2: Security Auditor Agent**
- subagent_type: "security-auditor"
- Prompt includes: architecture.md, implementation-notes.md, file tree
- Task: Run scans (npm audit), manual review, report findings

**Task #3: Code Reviewer Agent**
- subagent_type: "code-reviewer"
- Prompt includes: architecture.md, implementation-notes.md, file tree
- Task: Review code quality, check patterns, report findings

**All three agents run simultaneously.**

#### Incorrect Implementation (Sequential)

```markdown
❌ DON'T DO THIS:

First, I'll invoke the Tester agent...
[wait for completion]

Next, I'll invoke the Security Auditor...
[wait for completion]

Finally, I'll invoke the Code Reviewer...
[wait for completion]

This runs sequentially and takes 2x longer!
```

### Step 3: Wait for All Agents to Complete

After launching all three agents in parallel, wait for ALL to complete before proceeding.

**Do NOT read results until all agents finish.**

### Step 4: Read All Results

Once all agents complete, read their output files:
- `.claude/state/test-results.md` - Test coverage, pass/fail
- `.claude/state/security-findings.md` - CRITICAL/HIGH/MEDIUM/LOW findings
- `.claude/state/code-review-findings.md` - Quality issues and recommendations

### Step 5: Decision Logic

**If ANY critical issues found:**
1. Follow reflexion loop pattern (`.claude/patterns/reflexion.md`)
2. Invoke Engineer with findings as context
3. Re-run quality validation (return to Step 2)
4. Max 3 retries per command, max 5 total across workflow

**If all pass:**
- Proceed to next step (documentation, deployment, etc.)

---

## Agent Prompt Template

Each parallel agent should receive context via XML-structured documents:

```markdown
<documents>
  <document index="1">
    <source>{RELEVANT_SPEC_FILE}</source>
    <document_content>
    {{SPEC_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/state/implementation-notes.md</source>
    <document_content>
    {{IMPLEMENTATION_NOTES}}
    </document_content>
  </document>

  <document index="3">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>
</documents>

You are the {AGENT_NAME} agent.

**Context already loaded above - DO NOT re-read files.**

Your task: {SPECIFIC_TASK}

Follow your agent protocol in .claude/agents/{agent}.md
```

---

## When to Use Parallel Quality Validation

### ✅ Use for:
- **Feature implementation** (`/project:implement`) - All three agents
- **Bug fixes** (`/project:fix`) - Tester + Code Reviewer (Security optional)
- **Major refactoring** - All three agents
- **Security-sensitive code** (auth, payment, PII) - All three agents (Security REQUIRED)

### ❌ Don't use for:
- **Trivial changes** (typo fixes, comments) - Skip quality validation
- **Documentation-only changes** - Skip quality validation
- **Test-only changes** (`/project:test`) - Already in test workflow, Code Reviewer optional

---

## Quality Agent Roles

### Tester Agent
**Focus:** Test design, implementation, execution
- Designs test cases (unit, integration, e2e)
- Implements tests in `tests/`
- Runs tests and measures coverage
- Reports results in `.claude/state/test-results.md`
- Commits tests to git

**Output:** Pass/fail, coverage percentage, gap analysis

### Security Auditor Agent
**Focus:** Vulnerability detection and security compliance
- Runs automated scans (npm audit, eslint security, secret scanning)
- Manual code review for security anti-patterns
- Checks authentication/authorization logic
- Reports findings in `.claude/state/security-findings.md`
- Commits findings to git

**Output:** CRITICAL/HIGH/MEDIUM/LOW findings with remediation steps

### Code Reviewer Agent
**Focus:** Code quality, patterns, maintainability
- Reviews code structure and organization
- Checks architecture compliance
- Analyzes quality (DRY, SOLID, naming, complexity)
- Reports findings in `.claude/state/code-review-findings.md`
- Commits review to git

**Output:** PASS/FAIL verdict with recommendations

---

## Integration with Context Injection Pattern

Parallel quality validation works seamlessly with context injection (`.claude/patterns/context-injection.md`):

1. **Command loads specs ONCE** in Step 0
2. **Command launches parallel agents** with specs pre-loaded
3. **Agents receive context at TOP** of their prompts (30% performance boost)
4. **Agents DO NOT re-read** - context already provided

**Combined benefit:**
- 40-50% token reduction (context injection)
- 50% time reduction (parallelization)
- **Total: 70%+ efficiency improvement**

---

## Common Mistakes

### Mistake #1: Sequential Invocation

```markdown
❌ BAD:
I'll now invoke the Tester agent.
[invoke Task for tester]
[wait for completion]
Now I'll invoke Security Auditor.
[invoke Task for security-auditor]
[wait for completion]
Now I'll invoke Code Reviewer.
[invoke Task for code-reviewer]
```

**Problem:** Agents run one after another, taking 10 minutes total.

**Fix:** Invoke all three Task tools in a SINGLE message.

### Mistake #2: Reading Results Too Early

```markdown
❌ BAD:
[invoke all three agents in parallel]
Let me check the test results first...
[read test-results.md before other agents finish]
```

**Problem:** Partial results, other agents still running.

**Fix:** Wait for ALL agents to complete, THEN read all results.

### Mistake #3: Not Providing Context

```markdown
❌ BAD:
Task prompt: "Run tests for the authentication feature."
[no specs provided, no implementation-notes.md]
```

**Problem:** Agent has to read files itself, defeating context injection.

**Fix:** Always provide specs, implementation-notes.md, and file tree in agent prompt.

---

## Example: Correct Parallel Execution

```markdown
## Step 2.5: Parallel Quality Validation

Now I'll launch three quality agents in parallel to validate the authentication implementation.

[Invoke three Task tools in this single message:]

1. Tester Agent:
   - Context: requirements.md, implementation-notes.md, file tree
   - Task: Design and run comprehensive authentication tests
   - Output: .claude/state/test-results.md

2. Security Auditor Agent:
   - Context: architecture.md, implementation-notes.md, file tree
   - Task: Audit authentication security (JWT, password hashing, rate limiting)
   - Output: .claude/state/security-findings.md

3. Code Reviewer Agent:
   - Context: architecture.md, implementation-notes.md, file tree
   - Task: Review authentication code quality and patterns
   - Output: .claude/state/code-review-findings.md

[All three agents are now running concurrently...]
```

After all agents complete:

```markdown
## Step 3: Check Quality Results

All three quality agents have completed. Let me read their results.

[Read test-results.md]
[Read security-findings.md]
[Read code-review-findings.md]

Analysis:
- Tests: 85% coverage, all passing ✅
- Security: 0 CRITICAL, 1 HIGH (weak JWT secret), 2 MEDIUM
- Code Review: PASS with 3 MINOR recommendations

Decision: HIGH security finding requires fix. Invoking Engineer with remediation context...
```

---

## Success Metrics

### Quality Coverage
- **Before parallelization:** 0% dedicated quality validation (engineers test own code)
- **After parallelization:** 100% independent validation for every implementation

### Time Efficiency
- **Before:** 10 minutes sequential execution
- **After:** 5 minutes parallel execution
- **Savings:** 50% time reduction

### Issue Detection
- **Tests:** Catch regressions and edge cases
- **Security:** Identify vulnerabilities before deployment
- **Code Review:** Ensure maintainability and architecture compliance

---

## References

- Context Injection Pattern: `.claude/patterns/context-injection.md`
- Reflexion Loop Pattern: `.claude/patterns/reflexion.md`
- Tester Agent: `.claude/agents/tester.md`
- Security Auditor Agent: `.claude/agents/security-auditor.md`
- Code Reviewer Agent: `.claude/agents/code-reviewer.md`

**Research:**
- Anthropic Subagents Documentation: "Running multiple subagents concurrently reduces review time"
- Anthropic Long Context Tips: "Documents at TOP = 30% performance boost"

---

**Document Version:** 1.0
**Status:** ACTIVE
**Owner:** Claude Code Framework Development Team
