# State-Based Session Management Pattern

**Version:** v0.3 Phase 3
**Purpose:** Enable seamless resumption after interruptions (quota limits, network issues, context exhaustion)
**Created:** 2025-12-06

---

## Pattern Overview

**Problem:** Sessions get interrupted (quota limits, network issues, context exhaustion) and there's no way to resume from where you left off.

**Solution:** Commands track progress in `.claude/plans/current-task.md`, resume command reads state and continues from checkpoint.

**Benefits:**
- Seamless continuation after interruptions
- Zero rework (don't start from scratch)
- Progress visibility (users see exactly where workflow is)
- Automated documentation (CLAUDE.md stays in sync with specs)

---

## Core Components

### 1. Task Tracking File

**Location:** `.claude/plans/current-task.md`

**Purpose:** Single source of truth for current workflow state

**Updated by:** Every command at key checkpoints

**Structure:**
```markdown
## Current Task
**Command:** /project:implement Phase 2 - Authentication
**Status:** IN_PROGRESS | COMPLETED | FAILED
**Started:** 2025-12-06 14:00:00
**Progress:** 60%

## Workflow Steps
- [x] Step 1 ✓ (completed HH:MM)
- [x] Step 2 ✓ (completed HH:MM)
- [ ] Step 3 ← CURRENT
- [ ] Step 4
- [ ] Step 5

## Last Checkpoint
**Completed:** {what was just finished}
**Next Step:** {what to do next}
**Files Modified:** {list of modified files}

## Context
**Phase:** {current phase}
**Goal:** {what we're trying to achieve}

## Resume Instructions
If interrupted, run: `/project:resume`
```

### 2. Resume Command

**Location:** `.claude/commands/resume.md`

**Purpose:** Read state and continue from checkpoint

**Workflow:**
1. Read `.claude/plans/current-task.md`
2. Present progress to user
3. Ask to resume
4. Continue from "Next Step" if yes

### 3. CLAUDE.md Auto-Population

**When:** After `/project:start` creates specifications

**How:** Architect agent reads specs and populates CLAUDE.md sections

**Keeps in sync:** CLAUDE.md always reflects actual architecture

---

## How to Implement Task Tracking

### When to Update current-task.md

**At Command Start:**
- Initialize with command name, status IN_PROGRESS, progress 0%
- List workflow steps
- Set initial context

**After Each Major Step:**
- Mark step as completed with timestamp
- Update progress percentage
- Record "Last Checkpoint" with what was done and what's next
- List files modified in this step

**On Command Completion:**
- Set status to COMPLETED
- Add completion timestamp
- Record final results (test coverage, security findings, etc.)

**On Command Failure:**
- Set status to FAILED
- Record error message
- Provide troubleshooting guidance

### Progress Calculation

```
Progress % = (completed_steps / total_steps) * 100

Example:
Workflow has 5 steps
3 steps completed
Progress = (3 / 5) * 100 = 60%
```

### Checkpoint Format

```markdown
## Last Checkpoint
**Completed:** Validation passed (tests: 85%, security: 0 critical, review: PASS)
**Next Step:** Invoke Documenter agent to update end-user documentation
**Files Modified:**
- src/auth/jwt.ts
- src/middleware/auth.ts
- tests/auth/jwt.test.ts
- .claude/state/test-results.md
- .claude/state/security-findings.md
- .claude/state/code-review-findings.md
```

---

## Example: implement.md with Task Tracking

### At Command Start

```markdown
# Implementation: $ARGUMENTS

Write initial state to `.claude/plans/current-task.md`:

```markdown
## Current Task
**Command:** /project:implement $ARGUMENTS
**Status:** IN_PROGRESS
**Started:** {current_timestamp}
**Progress:** 0%

## Workflow Steps
- [ ] Load context (specs, file tree)
- [ ] Architect: Design architecture
- [ ] Engineer: Implement code
- [ ] Validation: Test + Security + Review
- [ ] Documentation: Update docs
- [ ] Human gate: Approval

## Context
**Feature:** $ARGUMENTS
**Goal:** Implement feature following specifications and quality gates

## Resume Instructions
If interrupted, run: `/project:resume`
```
```

### After Step 0 (Context Loading)

```markdown
Update `.claude/plans/current-task.md`:

```markdown
## Current Task
**Command:** /project:implement $ARGUMENTS
**Status:** IN_PROGRESS
**Started:** {timestamp}
**Progress:** 15%

## Workflow Steps
- [x] Load context (specs, file tree) ✓ (completed {time})
- [ ] Architect: Design architecture ← CURRENT
- [ ] Engineer: Implement code
- [ ] Validation: Test + Security + Review
- [ ] Documentation: Update docs
- [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Loaded requirements.md, architecture.md, tech-stack.md, project file tree
**Next Step:** Invoke Architect agent to design feature architecture
**Files Modified:** None (context loading only)
```
```

### After Step 1 (Architect)

```markdown
Update `.claude/plans/current-task.md`:

```markdown
## Workflow Steps
- [x] Load context ✓
- [x] Architect: Design architecture ✓ (completed {time})
- [ ] Engineer: Implement code ← CURRENT
- [ ] Validation: Test + Security + Review
- [ ] Documentation: Update docs
- [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Architect designed feature architecture
**Next Step:** Invoke Engineer agent to implement code following architecture specs
**Files Modified:**
- .claude/specs/phase-2-architecture.md
```
```

### After Step 2 (Engineer)

```markdown
Update `.claude/plans/current-task.md`:

```markdown
**Progress:** 50%

## Workflow Steps
- [x] Load context ✓
- [x] Architect: Design architecture ✓
- [x] Engineer: Implement code ✓ (completed {time})
- [ ] Validation: Test + Security + Review ← CURRENT
- [ ] Documentation: Update docs
- [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Engineer implemented authentication with JWT and bcrypt
**Next Step:** Invoke quality validation agents in parallel (Tester + Security + Reviewer)
**Files Modified:**
- src/auth/jwt.ts
- src/middleware/auth.ts
- .claude/state/implementation-notes.md
```
```

### After Step 3 (Validation)

```markdown
Update `.claude/plans/current-task.md`:

```markdown
**Progress:** 75%

## Workflow Steps
- [x] Load context ✓
- [x] Architect: Design architecture ✓
- [x] Engineer: Implement code ✓
- [x] Validation: Test + Security + Review ✓ (completed {time})
- [ ] Documentation: Update docs ← CURRENT
- [ ] Human gate: Approval

## Last Checkpoint
**Completed:** Validation passed (tests: 85%, security: 0 CRITICAL, review: PASS)
**Next Step:** Invoke Documenter agent to update end-user documentation
**Files Modified:**
- tests/auth/jwt.test.ts
- tests/middleware/auth.test.ts
- .claude/state/test-results.md
- .claude/state/security-findings.md
- .claude/state/code-review-findings.md
```
```

### On Completion

```markdown
Update `.claude/plans/current-task.md`:

```markdown
## Current Task
**Command:** /project:implement Phase 2 - Authentication
**Status:** COMPLETED
**Started:** 2025-12-06 14:00:00
**Completed:** 2025-12-06 15:30:00
**Duration:** 1h 30min
**Progress:** 100%

## Results
- **Implementation:** JWT authentication with bcrypt password hashing
- **Tests:** 85% coverage, all passing ✅
- **Security:** 0 CRITICAL, 1 HIGH (addressed), 2 MEDIUM
- **Code Review:** PASS ✅
- **Documentation:** API docs and user guide updated

## Files Modified
- src/auth/jwt.ts
- src/middleware/auth.ts
- tests/auth/jwt.test.ts
- tests/middleware/auth.test.ts
- docs/api/authentication.md
- docs/guides/getting-started.md
- README.md

## Resume Instructions
Task completed. Run new command or `/project:resume` to review results.
```
```

---

## Resume Command Implementation

### Step 1: Read State

```markdown
Read `.claude/plans/current-task.md`

Check status:
- If COMPLETED → Present results, ask what to do next
- If IN_PROGRESS → Present progress, ask to resume
- If FAILED → Present error, ask to retry or abort
- If file doesn't exist → No task in progress, ask what to start
```

### Step 2: Present to User

```markdown
✅ **Resumable Session Found**

Last session was working on: /project:implement Phase 2 - Authentication
Started: 2025-12-06 14:00:00
Progress: 60%

Completed steps:
✓ Load context
✓ Architect: Design architecture
✓ Engineer: Implement code

Last checkpoint: Validation passed (tests: 85%, security: 0 critical, review: PASS)
Next step: Invoke Documenter agent to update end-user documentation

Files modified:
- src/auth/jwt.ts
- src/middleware/auth.ts
- tests/auth/jwt.test.ts
- .claude/state/implementation-notes.md
- .claude/state/test-results.md
- .claude/state/security-findings.md
- .claude/state/code-review-findings.md

Resume from here? (y/n)
```

### Step 3: Resume Execution

**If yes:**
1. Load context from `.claude/specs/*` (use context injection pattern)
2. Read files listed in "Files Modified" to understand current state
3. Continue from "Next Step"
4. Update current-task.md as you progress

**If no:**
- Ask what they'd like to do instead
- Options: start fresh, modify task, abort, review results

**Implementation:**

```markdown
## Step 3: Resume Execution

User chose to resume.

### 3.1: Load Context

Follow context injection pattern:
- Read `.claude/specs/requirements.md`
- Read `.claude/specs/architecture.md`
- Read `.claude/specs/tech-stack.md`
- Generate project file tree

### 3.2: Read Current State

Read files from "Files Modified" section:
- {list files from current-task.md}

### 3.3: Continue from Next Step

From current-task.md, the next step is: {next_step}

{Execute next step...}

### 3.4: Update Progress

After completing next step, update `.claude/plans/current-task.md` with new checkpoint.
```

---

## CLAUDE.md Auto-Population

### When to Populate

**Trigger:** After `/project:start` creates specifications

**Who:** Architect agent (already has context from creating specs)

### What to Populate

```markdown
## Overview
{1-2 paragraph summary from requirements.md - what the project does}

## Technology Stack

**Frontend:** {from tech-stack.md}
**Backend:** {from tech-stack.md}
**Database:** {from tech-stack.md}
**Infrastructure:** {from tech-stack.md}

## Project Structure

{Directory structure from architecture.md}

```
src/
├── components/    # React components
├── services/      # Business logic
├── utils/         # Helper functions
└── types/         # TypeScript types
```

## Architecture

{High-level architecture overview from architecture.md}

## Development Guidelines

**Code Style:**
{Key conventions from architecture.md}

**Patterns:**
{Architectural patterns being used}

**Testing:**
{Testing approach from architecture.md}
```

### How to Implement

**In `.claude/commands/start.md`:**

```markdown
## Step 4: Populate Project Documentation

After Architect creates specifications, invoke Architect again to populate CLAUDE.md:

**Architect Task:**
1. Read all specifications you just created:
   - `.claude/specs/requirements.md`
   - `.claude/specs/architecture.md`
   - `.claude/specs/tech-stack.md`

2. Update `CLAUDE.md` sections:
   - Overview (from requirements.md)
   - Technology Stack (from tech-stack.md)
   - Project Structure (from architecture.md)
   - Architecture (from architecture.md)
   - Development Guidelines (from architecture.md)

3. Commit update:
   ```bash
   git add CLAUDE.md
   git commit -m "docs: auto-populate CLAUDE.md from specifications"
   ```
```

---

## State Files Directory Structure

```
.claude/
├── plans/
│   └── current-task.md          # Current workflow state (this pattern)
├── specs/
│   ├── requirements.md          # User requirements (source for CLAUDE.md Overview)
│   ├── architecture.md          # Architecture design (source for CLAUDE.md Architecture)
│   └── tech-stack.md            # Technology choices (source for CLAUDE.md Tech Stack)
└── state/
    ├── implementation-notes.md  # What was implemented (read during resume)
    ├── test-results.md          # Test outcomes (read during resume)
    ├── security-findings.md     # Security audit results (read during resume)
    └── code-review-findings.md  # Code review feedback (read during resume)
```

---

## Common Use Cases

### Use Case 1: Quota Limit Hit

**Scenario:**
- User runs `/project:implement Phase 2`
- After 45 minutes, quota limit reached mid-implementation
- Engineer finished, validation in progress

**Recovery:**
1. Wait for quota to reset
2. Run `/project:resume`
3. See progress: "60% complete, validation in progress"
4. Continue from validation step
5. No rework needed

### Use Case 2: Network Interruption

**Scenario:**
- User runs `/project:fix bug in login`
- Network drops during test execution
- Tests were running when disconnected

**Recovery:**
1. Reconnect
2. Run `/project:resume`
3. See progress: "50% complete, testing in progress"
4. Re-run tests (idempotent operation)
5. Continue to code review

### Use Case 3: Context Exhaustion

**Scenario:**
- User runs `/project:implement complex feature`
- Context fills up during documentation step
- All validation passed, just needs docs

**Recovery:**
1. Start new session
2. Run `/project:resume`
3. See progress: "75% complete, documentation next"
4. Load minimal context (implementation-notes.md only)
5. Finish documentation step

### Use Case 4: Review Results

**Scenario:**
- User runs `/project:implement feature`
- Feature completes successfully
- Later, user wants to review what was done

**Recovery:**
1. Run `/project:resume`
2. See status: COMPLETED
3. Review results: files modified, test coverage, security findings
4. Choose: start new task or review files

---

## Integration with Existing Patterns

### With Context Injection (Phase 1)

**Resume command loads context ONCE:**
- Read specs from `.claude/specs/*`
- Pass to next step via XML document structure
- Agents don't re-read (context already loaded)

**Benefits:**
- Fast resume (minimal reads)
- Consistent context (specs don't change mid-workflow)

### With Parallel Quality Validation (Phase 2)

**Track validation as single checkpoint:**
- Start validation → Update to "Validation in progress"
- Wait for all three agents
- Validation complete → Update to "Validation passed/failed"

**Resume behavior:**
- If interrupted during validation → Re-run validation (parallel agents are fast)
- If interrupted after validation → Skip to next step

### With Bounded Reflexion (v0.2)

**Track retry attempts:**
```markdown
## Reflexion State
**Retry Attempts:** 2 / 3
**Last Failure:** Tests failed with 3 errors
**Next Action:** Invoke Engineer with test failure context
```

**Resume behavior:**
- If interrupted during reflexion loop → Resume from same attempt
- Retry counter persists across interruptions

---

## Best Practices

### DO:
- ✅ Update current-task.md after EVERY major step
- ✅ Include specific "Next Step" instructions
- ✅ List ALL files modified (helps with resume)
- ✅ Track progress percentage (users love visibility)
- ✅ Write clear, actionable "Resume Instructions"

### DON'T:
- ❌ Skip checkpoints (can't resume accurately)
- ❌ Use vague "Next Step" ("continue" → what does that mean?)
- ❌ Forget to update status to COMPLETED
- ❌ Leave current-task.md in inconsistent state

---

## Error Handling

### Scenario: current-task.md Doesn't Exist

**Resume command behavior:**
```
📋 No task in progress

.claude/plans/current-task.md not found.

Options:
1. Start new task: /project:implement {feature}
2. Create specification: /project:spec {feature}
3. Fix bug: /project:fix {bug description}
4. Run tests: /project:test {test scope}

What would you like to do?
```

### Scenario: current-task.md is Corrupted

**Resume command behavior:**
```
⚠️ Task state file corrupted

Unable to parse .claude/plans/current-task.md.

Options:
1. View raw file to recover manually
2. Start fresh (WARNING: will overwrite current-task.md)
3. Abort and investigate

What would you like to do?
```

### Scenario: Multiple Incomplete Tasks

**Solution:** Only ONE current-task.md (latest task)

**Archive completed tasks:**
```
.claude/plans/
├── current-task.md           # Current workflow
└── archive/
    ├── 2025-12-05-implement-auth.md
    └── 2025-12-04-fix-login-bug.md
```

---

## Success Metrics

### Resume Capability
- **Before:** 0% of interrupted sessions can resume
- **After:** 100% of interrupted sessions can resume from checkpoint

### Rework Reduction
- **Before:** Start from scratch after quota limit (100% rework)
- **After:** Continue from checkpoint (0% rework)

### Progress Visibility
- **Before:** No visibility into workflow progress
- **After:** Real-time progress tracking with % completion

### Documentation Sync
- **Before:** CLAUDE.md manually updated, often out of sync
- **After:** CLAUDE.md auto-populated from specs (always in sync)

---

## References

- Context Injection Pattern: `.claude/patterns/context-injection.md`
- Parallel Quality Validation Pattern: `.claude/patterns/parallel-quality-validation.md`
- Reflexion Loop Pattern: `.claude/patterns/reflexion.md`
- Resume Command: `.claude/commands/resume.md`

---

**Document Version:** 1.0
**Status:** ACTIVE
**Owner:** Claude Code Framework Development Team
