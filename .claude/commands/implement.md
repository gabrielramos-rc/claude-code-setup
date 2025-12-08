# Implement: $ARGUMENTS

## Instructions

Implement the feature or task: **$ARGUMENTS**

Follow the context injection pattern in `.claude/patterns/context-injection.md`, state-based session management pattern in `.claude/patterns/state-based-session-management.md`, and model selection guide in `.claude/patterns/model-selection.md`.

---

## Initialize Task Tracking

Write initial state to `.claude/plans/current-task.md`:

```markdown
## Current Task
**Command:** /project:implement $ARGUMENTS
**Status:** IN_PROGRESS
**Started:** {current_timestamp}
**Progress:** Step 0/5 - Starting
**Next:** Context Loading

## Workflow Steps
1. [ ] Load context (specs, file tree)
2. [ ] Engineer: Implement code
3. [ ] Validation: Test + Security + Review
4. [ ] Documentation: Update docs
5. [ ] Human gate: Approval

## Context
**Feature:** $ARGUMENTS
**Goal:** Implement feature following specifications and quality gates

## Resume Instructions
If interrupted, run: `/project:resume`
```

---

## Step 0: Load Project Context

Before invoking any agents, gather all shared context to avoid redundant reads.

**⚠️ MANUAL INJECTION:** When you see `{{PLACEHOLDER}}` in agent prompts below, YOU must:
1. Read the corresponding file using the Read tool
2. Replace the placeholder with the actual file contents when invoking the agent
3. The placeholder notation is a convention - there is NO automatic substitution

### 1. Read Core Specifications

Read the following files if they exist (skip if not found):

```bash
# Check and read specifications
for spec in requirements architecture tech-stack; do
  if [ -f ".claude/specs/$spec.md" ]; then
    echo "Found: .claude/specs/$spec.md"
  fi
done
```

Store content for injection:
- `.claude/specs/requirements.md`
- `.claude/specs/architecture.md`
- `.claude/specs/tech-stack.md`

**For UI features, also read:**
- `.claude/specs/ui-ux-specs.md`
- `.claude/specs/design-system.md`
- `.claude/specs/frontend-architecture.md`

### 2. Generate Project File Tree

Generate project structure overview (choose first available command):

```bash
# Preferred: tree command
tree -L 3 -I 'node_modules|.git|dist|build|coverage|.next|__pycache__|*.pyc' > /tmp/project-tree.txt

# Fallback: find command
find . -type d \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o -print | head -100 > /tmp/project-tree.txt
```

### 3. Read Current Task State

If resuming a workflow, read:
- `.claude/plans/current-task.md`

**Update task progress after context loading:**

```markdown
## Current Task
**Progress:** Step 1/5 - Context Loaded
**Next:** Engineer Implementation

## Workflow Steps
1. [x] Load context (specs, file tree) ✓ (completed {timestamp})
2. [ ] Engineer: Implement code ← CURRENT
3. [ ] Validation: Test + Security + Review
4. [ ] Documentation: Update docs
5. [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Loaded specifications and project file tree
**Next Step:** Invoke Engineer agent to implement code following architecture specs
**Files Modified:** None (context loading only)
```

---

## Step 1: Invoke Engineer Agent

Use the Task tool with context injection at TOP of prompt:

### Prompt Structure:

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
    <source>.claude/specs/tech-stack.md</source>
    <document_content>
    {{TECH_STACK_CONTENT}}
    </document_content>
  </document>

  <document index="4">
    <source>Project File Tree</source>
    <document_content>
    {{PROJECT_TREE}}
    </document_content>
  </document>
</documents>

You are the Engineer agent.

**IMPORTANT: Context already loaded above - DO NOT re-read these files.**

The project file tree shows you the complete structure - DO NOT run ls/find/tree commands.

Your task: Implement the following feature: $ARGUMENTS

Follow these steps:

1. **Understand Requirements**
   - Review specifications provided above
   - Identify what needs to be implemented
   - Clarify any ambiguities with user if needed

2. **Plan Approach**
   - Use file tree to identify where code should go
   - Outline files to create/modify
   - Follow architecture patterns from specs above

3. **Implement Incrementally**
   - Work in small, testable chunks
   - Verify each chunk works before proceeding
   - Follow existing code patterns from the codebase

4. **Document Implementation**
   - Write implementation notes to `.claude/state/implementation-notes.md`:
     - What was implemented
     - Which files were created/modified
     - Technical decisions made
     - Areas that need testing focus

5. **Commit Your Work**
   ```bash
   git add src/ tests/
   git commit -m "feat: implement {feature}

   - Implementation details
   - Files modified

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

Output: Path to `.claude/state/implementation-notes.md`
```

**Update task progress after implementation:**

```markdown
## Current Task
**Progress:** Step 2/5 - Engineer Complete
**Next:** Validation (Test + Security + Review)

## Workflow Steps
1. [x] Load context ✓
2. [x] Engineer: Implement code ✓ (completed {timestamp})
3. [ ] Validation: Test + Security + Review ← CURRENT
4. [ ] Documentation: Update docs
5. [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Engineer implemented feature following architecture specs
**Next Step:** Invoke quality validation agents in parallel (Tester + Security + Reviewer)
**Files Modified:**
- {list files from implementation-notes.md}
- .claude/state/implementation-notes.md
```

---

## Step 2: Quality Validation (PARALLEL EXECUTION)

After Engineer completes implementation, read `.claude/state/implementation-notes.md` to understand what was built.

**PARALLEL EXECUTION (50% time savings):**

Follow the parallel quality validation pattern in `.claude/patterns/parallel-quality-validation.md`.

**CRITICAL:** Invoke all three Task tools in a SINGLE message to run agents concurrently:
- Tester Agent (tests/)
- Security Auditor Agent (security scans)
- Code Reviewer Agent (quality review)

**Expected time:** ~5 minutes (vs 10 minutes sequential)

**Invoke these three agents IN PARALLEL using Task tool:**

### 2.1: Tester Agent

Inject same context plus implementation notes:

```
<documents>
  <document index="1">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {{ARCHITECTURE_CONTENT}}
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

You are the Tester agent.

**Context already loaded above - DO NOT re-read files.**

Your task: Design and run comprehensive tests for the implementation.

Output test results to: `.claude/state/test-results.md`
```

### 2.2: Security Auditor Agent

```
<documents>
  <document index="1">
    <source>.claude/state/implementation-notes.md</source>
    <document_content>
    {{IMPLEMENTATION_NOTES}}
    </document_content>
  </document>
</documents>

You are the Security Auditor agent.

**Context already loaded above - DO NOT re-read files.**
The implementation-notes.md lists all files that were modified - focus your audit on those.

Your task: Run security scans and audit the implementation.

Output findings to: `.claude/state/security-findings.md`
```

### 2.3: Code Reviewer Agent

```
<documents>
  <document index="1">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {{ARCHITECTURE_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/state/implementation-notes.md</source>
    <document_content>
    {{IMPLEMENTATION_NOTES}}
    </document_content>
  </document>
</documents>

You are the Code Reviewer agent.

**Context already loaded above - DO NOT re-read files.**
The implementation-notes.md lists all files that were modified - focus your review on those.

Your task: Review code quality, patterns, and maintainability.

Output review to: `.claude/state/code-review-findings.md`
```

**Wait for ALL three agents to complete before proceeding.**

---

## Step 3: Check Quality Results

Read all three result files:
- `.claude/state/test-results.md`
- `.claude/state/security-findings.md`
- `.claude/state/code-review-findings.md`

### Decision Logic

**If ANY critical issues found:**

Follow the reflexion loop pattern in `.claude/patterns/reflexion.md`.

1. Read `.claude/state/retry-counter.md` to check current retry count
2. If under limits (max 3 per command, max 5 total):
   - Invoke Engineer again with findings as context
   - Update retry counter
   - Return to Step 2
3. If retries exhausted:
   - Output failure message (see below)
   - Escalate to human

**If all pass:**
- Proceed to Step 4

**Failure Termination Message:**

```
🔴 **Automated fixes failed after 3 attempts**

**Last Issues:**
- Test coverage: X%
- Security findings: Y CRITICAL, Z HIGH
- Code review: FAIL

**Manual Intervention Required:**
- Review detailed findings in .claude/state/
- Recommended action: [specific suggestion based on findings]
- Run `/project:debug` to investigate OR manually fix [specific file:line]
```

**Update task progress after validation passes:**

```markdown
## Current Task
**Progress:** Step 3/5 - Validation Complete
**Next:** Documentation

## Workflow Steps
1. [x] Load context ✓
2. [x] Engineer: Implement code ✓
3. [x] Validation: Test + Security + Review ✓ (completed {timestamp})
4. [ ] Documentation: Update docs ← CURRENT
5. [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Validation passed (tests: X%, security: Y findings, review: PASS)
**Next Step:** Invoke Documenter agent to update end-user documentation
**Files Modified:**
- {implementation files from Step 1}
- tests/* (from Tester)
- .claude/state/test-results.md
- .claude/state/security-findings.md
- .claude/state/code-review-findings.md
```

---

## Step 4: Documentation

Invoke Documenter agent with context:

```
<documents>
  <document index="1">
    <source>.claude/state/implementation-notes.md</source>
    <document_content>
    {{IMPLEMENTATION_NOTES}}
    </document_content>
  </document>
</documents>

You are the Documenter agent.

**Context already loaded above - DO NOT re-read files.**
The implementation-notes.md describes what was implemented - document those features.

Your task: Update documentation for this implementation.

Output:
- Update `docs/` directory with API docs, user guides
- Update `README.md` if needed
- Commit documentation updates
```

**Update task progress after documentation:**

```markdown
## Current Task
**Progress:** Step 4/5 - Documentation Complete
**Next:** Human Approval

## Workflow Steps
1. [x] Load context ✓
2. [x] Engineer: Implement code ✓
3. [x] Validation: Test + Security + Review ✓
4. [x] Documentation: Update docs ✓ (completed {timestamp})
5. [ ] Human gate: Approval ← CURRENT

## Last Checkpoint
**Completed:** Documenter updated end-user documentation
**Next Step:** Present summary to user for approval
**Files Modified:**
- {all previous files}
- docs/* (from Documenter)
```

---

## Step 5: Human Gate

Present summary to user:

```
✅ **Implementation Complete: $ARGUMENTS**

**What was implemented:**
{summary from implementation-notes.md}

**Quality Validation:**
- Tests: X% coverage, all passing ✅
- Security: 0 CRITICAL, Y HIGH, Z MEDIUM
- Code Review: PASS ✅

**Files Modified:**
{list from implementation-notes.md}

**Next Steps:**
- Review changes: `git diff`
- Test manually if desired
- Approve and continue? (y/n)
```

**If user approves, update task status to COMPLETED:**

```markdown
## Current Task
**Command:** /project:implement $ARGUMENTS
**Status:** COMPLETED
**Started:** {started_timestamp}
**Completed:** {current_timestamp}
**Duration:** {calculate duration}
**Progress:** Step 5/5 - Complete

## Results
- **Implementation:** {summary from implementation-notes.md}
- **Tests:** {coverage}% coverage, all passing ✅
- **Security:** {findings count by severity}
- **Code Review:** PASS ✅
- **Documentation:** Updated

## Files Modified
- {list all files from all steps}

## Resume Instructions
Task completed. Run new command or `/project:resume` to review results.
```

---

## Output

After implementation:
- Implementation completed in `src/`
- Tests passing (see `.claude/state/test-results.md`)
- Security validated (see `.claude/state/security-findings.md`)
- Code reviewed (see `.claude/state/code-review-findings.md`)
- Documentation updated in `docs/`
- Git commits created for each phase
- All state files updated

**Ready for next command.**
