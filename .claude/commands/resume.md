# Resume: Continue From Checkpoint

## Instructions

Resume a previously interrupted workflow from its last checkpoint.

Follow the state-based session management pattern in `.claude/patterns/state-based-session-management.md`.

---

## Step 1: Read Task State

Read `.claude/plans/current-task.md` to understand current workflow state.

**Check status:**
- `IDLE` í No task in progress
- `IN_PROGRESS` í Task was interrupted
- `COMPLETED` í Task finished successfully
- `FAILED` í Task encountered errors

---

## Step 2: Present Status to User

### If Status is IDLE

```
=À No task in progress

.claude/plans/current-task.md shows no active workflow.

Options:
1. Start new implementation: /project:implement {feature}
2. Create specification: /project:spec {feature}
3. Fix bug: /project:fix {bug description}
4. Run tests: /project:test {test scope}

What would you like to do?
```

Stop here. Ask user what they want to do.

---

### If Status is IN_PROGRESS

Present detailed progress:

```
 **Resumable Session Found**

**Last session:** {command from current-task.md}
**Started:** {started timestamp}
**Progress:** {progress}%
**Duration so far:** {calculate from started timestamp}

**Completed steps:**
{list all completed steps with  and timestamps}

**Last checkpoint:**
{completed from current-task.md}

**Next step:**
{next_step from current-task.md}

**Files modified:**
{list files from current-task.md}

---

Resume from checkpoint? (y/n)
```

**Wait for user response.**

---

### If Status is COMPLETED

```
 **Task Completed**

**Command:** {command from current-task.md}
**Completed:** {completed timestamp}
**Duration:** {duration}

**Results:**
{results from current-task.md}

**Files Modified:**
{list files}

---

Options:
1. Review changes: git diff
2. Start new task: /project:implement {feature}
3. Run tests: /project:test
4. Create PR: gh pr create

What would you like to do?
```

Stop here. Ask user what they want to do.

---

### If Status is FAILED

```
=4 **Task Failed**

**Command:** {command from current-task.md}
**Failed at:** {failed timestamp}

**Error:**
{error message from current-task.md}

**Last successful checkpoint:**
{last completed step}

**Files modified:**
{list files}

---

Options:
1. Retry from last checkpoint: resume (y)
2. Debug the issue: /project:debug
3. Abandon task: abort
4. Review error details: read state files

What would you like to do?
```

Stop here. Ask user what they want to do.

---

## Step 3: Resume Execution (If User Says Yes)

**Only execute this step if:**
- Status is IN_PROGRESS
- User answered "yes" to resume

### 3.1: Load Context

Follow the context injection pattern in `.claude/patterns/context-injection.md`.

Read specifications (if they exist):
- `.claude/specs/requirements.md`
- `.claude/specs/architecture.md`
- `.claude/specs/tech-stack.md`

Generate project file tree:
```bash
tree -L 3 -I 'node_modules|.git|dist|build|coverage' > /tmp/project-tree.txt
```

### 3.2: Read Current State

From current-task.md "Files Modified" section, read relevant files to understand current state:

**Implementation files:**
- Read any `src/*` files that were modified
- Read `.claude/state/implementation-notes.md` if it exists

**Test files:**
- Read any `tests/*` files that were modified
- Read `.claude/state/test-results.md` if it exists

**Quality results:**
- Read `.claude/state/security-findings.md` if validation was in progress
- Read `.claude/state/code-review-findings.md` if validation was in progress

**Specs:**
- Read any `.claude/specs/*` files that were created during this workflow

### 3.3: Determine Next Step

From current-task.md, the "Next Step" field tells you exactly what to do.

**Example next steps:**
- "Invoke Architect agent to design feature architecture"
- "Invoke Engineer agent to implement code following architecture specs"
- "Invoke quality validation agents in parallel (Tester + Security + Reviewer)"
- "Invoke Documenter agent to update end-user documentation"
- "Present summary to user for approval"

### 3.4: Execute Next Step

Follow the original command workflow for the next step.

**For Architect step:**
- Use context injection (specs loaded in Step 3.1)
- Invoke Architect agent with task
- Update current-task.md after completion

**For Engineer step:**
- Use context injection (specs + architecture loaded)
- Invoke Engineer agent with task
- Update current-task.md after completion

**For Validation step:**
- Use parallel quality validation pattern
- Invoke Tester + Security + Code Reviewer in parallel
- Wait for all three to complete
- Check results, reflexion loop if needed
- Update current-task.md after completion

**For Documentation step:**
- Invoke Documenter agent with implementation notes
- Update current-task.md after completion

**For Human gate:**
- Present summary to user
- Ask for approval
- Update current-task.md to COMPLETED if approved

### 3.5: Update Progress

After completing the next step, update `.claude/plans/current-task.md`:

```markdown
**Progress:** {new_percentage}%

## Workflow Steps
- [x] {previous steps} 
- [x] {just_completed_step}  (completed {timestamp})
- [ ] {next_step} ê CURRENT

## Last Checkpoint
**Completed:** {what was just finished}
**Next Step:** {what to do next}
**Files Modified:**
{updated list including new files}
```

### 3.6: Continue Until Complete

Repeat steps 3.3-3.5 until all workflow steps are completed.

When complete, update current-task.md:
```markdown
**Status:** COMPLETED
**Completed:** {timestamp}
**Progress:** 100%

## Results
{final results}
```

---

## Error Handling

### If current-task.md doesn't exist

```
=À No task state file found

.claude/plans/current-task.md does not exist.

This could mean:
1. No task has been started yet
2. The file was deleted
3. You're in a different project directory

What would you like to do?
- Start new task: /project:implement {feature}
- Check directory: pwd
- Abort
```

### If current-task.md is corrupted

```
† Task state file corrupted

Unable to parse .claude/plans/current-task.md.

Options:
1. View raw file: cat .claude/plans/current-task.md
2. Start fresh (WARNING: will overwrite current-task.md)
3. Abort and investigate manually

What would you like to do?
```

### If "Next Step" is unclear

```
† Unable to determine next step

current-task.md does not have a clear "Next Step" instruction.

Last checkpoint: {last_completed}
Workflow status: {show workflow steps}

Manual intervention needed. What would you like to do?
- Manually specify next step
- Review workflow steps
- Abort and review state files
```

---

## Output

After successfully resuming and continuing the workflow, provide:

1. **Resumed from:** What checkpoint we resumed from
2. **Completed:** What steps were executed after resume
3. **Status:** Current status (IN_PROGRESS or COMPLETED)
4. **Files Modified:** All files changed during resumed execution
5. **Next:** What to do next (if workflow still in progress)

**Example:**

```
 **Workflow Resumed and Continued**

Resumed from: Validation checkpoint (60% complete)
Completed after resume:
-  Documentation updated
-  Human gate approval received

Status: COMPLETED

Files Modified (this resume session):
- docs/api/authentication.md
- docs/guides/getting-started.md
- README.md
- .claude/plans/current-task.md

Final Results:
- Implementation: JWT authentication with bcrypt
- Tests: 85% coverage, all passing
- Security: 0 CRITICAL, 1 HIGH (addressed)
- Code Review: PASS
- Documentation: Complete

Ready for next command.
```

---

## Notes

- This command is designed to work seamlessly with context injection and parallel quality validation patterns
- Task state is updated automatically by other commands (implement, fix, test)
- Resume is idempotent - can be run multiple times safely
- If interrupted again during resume, just run `/project:resume` again
- Use `/project:debug` if you need to investigate errors instead of resuming

---

**Pattern Reference:** See `.claude/patterns/state-based-session-management.md` for complete implementation guide.
