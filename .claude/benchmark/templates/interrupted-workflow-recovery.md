# Benchmark: Interrupted Workflow Recovery

**Version:** v0.3+
**Created:** 2025-12-06
**Benchmark ID:** BENCH-003

---

## Task Description

Implement user profile management feature, simulate interruption at 60% progress, then resume from checkpoint.

**Feature Requirements:**
- User profile CRUD operations (Create, Read, Update, Delete)
- Profile fields: name, email, bio, avatar URL
- Basic validation
- REST API endpoints

**Interruption Simulation:**
- Start implementation workflow
- Wait for Engineer to complete implementation (~40% progress)
- Simulate quota limit or network interruption (manually stop)
- Resume workflow using `/project:resume`

**Success Criteria:**
- Resume from checkpoint without redoing work
- Context preserved (no re-reads of specs)
- Continue seamlessly from "Next Step" in current-task.md
- Total time < restarting from scratch

---

## Baseline Metrics (Pre-v0.3)

### Resume Capability
- **Resume capability:** 0% (no resume feature)
- **Rework percentage:** 100% (must restart from scratch)
- **Time lost to interruption:** 30+ minutes (all work lost)

### Interruption Scenario
1. Start implementation (30 minutes of work)
2. Hit quota limit at 60% progress
3. **Cannot resume** - no checkpoint state saved
4. Restart workflow from beginning
5. Repeat all previous work (30 minutes wasted)
6. Total time: 60+ minutes

### Context Preservation
- **Specifications:** Re-read all specs from scratch
- **File discovery:** Re-run all file discovery commands
- **Implementation:** Re-implement what was already done
- **State:** No memory of previous work

---

## Target Metrics (v0.3)

### Resume Capability
- **Resume capability:** 100% (can resume from any checkpoint)
- **Rework percentage:** 0% (continue from checkpoint)
- **Time to resume:** <2 minutes (read state + minimal context)
- **Time saved:** 30+ minutes (no rework needed)

### Interruption Scenario
1. Start implementation (30 minutes of work)
2. Hit quota limit at 60% progress (Engineer completed, validation pending)
3. **Resume from checkpoint:** Read `.claude/plans/current-task.md`
4. Load minimal context (validation results only)
5. Continue from "Next Step" (invoke quality validation agents)
6. Total time: 30 minutes (original) + 2 minutes (resume) + 15 minutes (remaining work) = 47 minutes
7. **Time saved:** 30 minutes (60% of original work not redone)

### Context Preservation
- **Current task state:** Preserved in `.claude/plans/current-task.md`
- **Progress:** Preserved (60% checkpoint recorded)
- **Next step:** Clearly defined ("Invoke quality validation agents")
- **Files modified:** List preserved in checkpoint
- **Minimal re-reading:** Only read what's needed for next step (no full spec re-reads)

---

## Steps to Run

### Part 1: Start Implementation

```bash
/project:implement "User profile management with CRUD operations"
```

**Monitor progress:**
- Watch for "Progress: 40%" update in current-task.md
- Wait for Engineer agent to complete implementation
- **Do not wait for quality validation to start**

### Part 2: Simulate Interruption

When you see Engineer complete (Progress: 40%), manually interrupt:

```bash
# Simulate quota limit / network interruption
# (In real usage, this happens automatically)
# For benchmark: Just stop Claude Code session
```

**Verify state was saved:**

```bash
cat .claude/plans/current-task.md
# Should show:
# Status: IN_PROGRESS
# Progress: 40%
# Last Checkpoint: Engineer implemented feature
# Next Step: Invoke quality validation agents in parallel
```

### Part 3: Resume Workflow

Start new session and resume:

```bash
/project:resume
```

**What happens:**
- Step 1: Read `.claude/plans/current-task.md`
- Step 2: Present progress to user ("60% complete, ready to continue?")
- Step 3: Load minimal context (only what's needed for next step)
- Step 4: Continue from "Next Step" (invoke quality validation)
- Step 5: Complete remaining workflow steps

### Part 4: Export and Analyze

```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

**Important:** You may need to export both sessions:
- Original session (interrupted)
- Resume session (completion)

### Part 5: Compare Metrics

Calculate time savings:

| Metric                    | Baseline (Restart) | v0.3 (Resume) | Savings |
|---------------------------|-------------------|---------------|---------|
| Time before interruption  | 30 min            | 30 min        | 0 min   |
| Time lost to rework       | 30 min (100%)     | 0 min (0%)    | 30 min  |
| Time to resume            | N/A               | 2 min         | N/A     |
| Time to complete          | 30 min (redo all) | 15 min (rest) | 15 min  |
| **Total time**            | **60 min**        | **47 min**    | **13 min** |

---

## Success Criteria

### Must Meet (Required)

- ✅ **Resume capability:** Can resume from checkpoint
- ✅ **State preserved:** current-task.md shows accurate progress
- ✅ **No rework:** Don't re-implement what Engineer already did
- ✅ **Context loading:** Don't re-read all specs (only needed context)
- ✅ **Workflow continuation:** Start from "Next Step" correctly
- ✅ **Completion:** Successfully finish remaining workflow steps

### Should Meet (Goals)

- ⚡ **Resume time:** <2 minutes to analyze state and continue
- ⚡ **Time savings:** Save 30+ minutes compared to restart
- ⚡ **Rework percentage:** 0% (no redundant work)
- ⚡ **Checkpoint accuracy:** "Next Step" is exactly right

### May Vary (Acceptable)

- 📊 **Interruption point:** May interrupt at different percentages (40%, 60%, 70%)
- 📊 **Resume context loading:** May load slightly more context if needed for next step
- 📊 **Total time:** May vary based on feature complexity

---

## Expected File Structure After Resume

```
.claude/plans/
└── current-task.md          # COMPLETED status, 100% progress

.claude/state/
├── implementation-notes.md  # From original session (Engineer)
├── test-results.md          # From resume session (Tester)
├── security-findings.md     # From resume session (Security)
└── code-review-findings.md  # From resume session (Reviewer)

src/
└── profile/
    ├── profile.controller.ts  # Created in original session
    ├── profile.service.ts     # Created in original session
    └── profile.model.ts       # Created in original session

tests/
└── profile/
    └── profile.test.ts        # Created in resume session (Tester)
```

---

## Checkpoint Scenarios to Test

### Scenario A: Interrupt After Context Loading (15% progress)

**Checkpoint:**
```markdown
## Last Checkpoint
**Completed:** Loaded specifications and project file tree
**Next Step:** Invoke Engineer agent to implement code
**Files Modified:** None
```

**Expected resume behavior:**
- Skip context loading (already done)
- Directly invoke Engineer agent
- Time saved: 2 minutes (context loading)

### Scenario B: Interrupt After Engineer (40% progress)

**Checkpoint:**
```markdown
## Last Checkpoint
**Completed:** Engineer implemented feature following architecture specs
**Next Step:** Invoke quality validation agents in parallel (Tester + Security + Reviewer)
**Files Modified:**
- src/profile/profile.controller.ts
- src/profile/profile.service.ts
- .claude/state/implementation-notes.md
```

**Expected resume behavior:**
- Skip context loading and implementation
- Read implementation-notes.md only
- Invoke quality validation agents
- Time saved: 30+ minutes (context + implementation)

### Scenario C: Interrupt After Validation (70% progress)

**Checkpoint:**
```markdown
## Last Checkpoint
**Completed:** Validation passed (tests: 85%, security: 0 CRITICAL, review: PASS)
**Next Step:** Invoke Documenter agent to update end-user documentation
**Files Modified:**
- {implementation files}
- tests/profile/profile.test.ts
- .claude/state/test-results.md
- .claude/state/security-findings.md
- .claude/state/code-review-findings.md
```

**Expected resume behavior:**
- Skip context loading, implementation, and validation
- Read test/security/review results only
- Invoke Documenter agent
- Time saved: 40+ minutes (all previous steps)

---

## Common Variance Explanations

### Resume Reads Full Context (Not Minimal)

**Possible causes:**
- Resume command not following minimal context pattern
- "Next Step" unclear, so loaded everything to be safe
- Bug in resume.md implementation

**Investigation:**
```bash
# Check what was read during resume
grep "Read.*architecture.md" .claude/benchmark/results/{timestamp}/readable/main-conversation.md

# Should only see minimal reads (e.g., just implementation-notes.md)
```

### Resume Redoes Work

**Possible causes:**
- current-task.md not updated correctly in original session
- "Last Checkpoint" missing or incomplete
- "Files Modified" list missing
- Resume command didn't trust checkpoint state

**Investigation:**
```bash
# Check checkpoint was written correctly
cat .claude/plans/current-task.md
# Should show clear "Last Checkpoint" with files modified
```

### Resume Fails to Continue

**Possible causes:**
- Status is FAILED (not IN_PROGRESS)
- Critical errors in original session
- Resume command doesn't handle edge case

**Investigation:**
```bash
cat .claude/plans/current-task.md
# Check Status field (should be IN_PROGRESS, not FAILED)
```

---

## Actual Results (Run {date})

Fill in after running benchmark:

### Part 1: Original Session (Interrupted)
- **Time before interruption:** {actual} minutes
- **Progress at interruption:** {actual}%
- **Checkpoint saved:** {yes/no}
- **Files created:** {count}

### Part 2: Resume Session
- **Time to resume:** {actual} minutes
- **Context loaded:** {list files read}
- **Rework performed:** {percentage}%
- **Time to complete:** {actual} minutes

### Part 3: Comparison
- **Total time (with resume):** {actual} minutes
- **Total time (if restarted):** {estimated} minutes
- **Time saved:** {actual} minutes ({percentage}%)

### Variance Analysis

**Resume efficiency:**
{Was context loading minimal? Did it continue from right step?}

**Checkpoint quality:**
{Was "Next Step" accurate? Was state preserved correctly?}

**Time savings:**
{How much time saved vs restarting from scratch?}

### Key Findings

1. {finding 1}
2. {finding 2}
3. {finding 3}

### Recommendations

Based on results:
- {recommendation 1}
- {recommendation 2}
- {recommendation 3}

---

## Notes

- This benchmark validates **v0.3 Phase 3** (state-based session management)
- Tests resume capability from multiple checkpoint percentages
- Critical for real-world usage (quota limits, network issues)
- Re-run with different interruption points to test robustness
- Expected duration: 60+ minutes total (includes interruption simulation)

---

**Benchmark Status:** READY FOR USE
**Last Updated:** 2025-12-06
**Owner:** Claude Code Framework Development Team
