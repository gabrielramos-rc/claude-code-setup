# Benchmark Learnings & Considerations

**Date:** 2025-12-06
**Source:** First benchmark run feedback
**Framework Version:** Beta v0.2

This document tracks observations, issues, and improvement opportunities discovered during benchmark testing.

---

## Issues & Considerations

### CON-01: CLAUDE.md File Initialization ⚠️ HIGH PRIORITY

**Problem:**
When starting a new project, `CLAUDE.md` sections (Overview, Technology Stack, Project Structure) are empty from the template. Unclear when/how these should be filled.

**Observation:**
- OBS-01: Engineer Agent updated CLAUDE.md during "Step 4: Initializing Project Structure" (self-initiated)

**Questions:**
- Should this happen at project start?
- Should `/project:start` command explicitly update CLAUDE.md?
- Should we ask user for input or let agents fill automatically?
- Should Architect agent own this responsibility?

**Proposed Solutions:**

**Option A: Architect-Driven (Recommended)**
```markdown
# In .claude/commands/start.md
After architect creates specifications:
1. Architect reads specs/architecture.md, specs/tech-stack.md
2. Architect updates CLAUDE.md sections:
   - Overview: From requirements.md
   - Technology Stack: From tech-stack.md
   - Project Structure: From architecture.md
3. Commit CLAUDE.md update
```

**Option B: Dedicated Command**
```bash
/project:init-docs
# Updates CLAUDE.md from .claude/specs/* artifacts
```

**Option C: Human-Filled Template**
- Keep as manual step in quickstart guide
- User fills after `/project:start` completes

**Status:** 🟡 Needs Decision
**Priority:** HIGH (affects every project start)
**Assigned To:** Framework Enhancement v0.3

---

### CON-02: Slash Commands Not Auto-Loaded ⚠️ CRITICAL

**Problem:**
Error: "Unknown slash command: project:route"
Claude had to search `.claude/commands/**/*` manually to discover commands.

**Root Cause:**
Slash commands from `.claude/commands/*.md` are not automatically registered when using the framework in a new project.

**Impact:**
- Poor user experience (commands don't work out of the box)
- Breaks framework workflow
- Requires manual discovery every session

**Investigation Needed:**
1. How does Claude Code discover custom slash commands?
2. Is there a manifest/index file needed?
3. Do commands need specific naming convention?
4. Is `.claude/commands/` the correct location?

**Proposed Solutions:**

**Option A: Command Manifest**
Create `.claude/commands.json`:
```json
{
  "commands": [
    {
      "name": "project:route",
      "file": ".claude/commands/route.md",
      "description": "Analyze task complexity and recommend workflow"
    },
    {
      "name": "project:start",
      "file": ".claude/commands/start.md",
      "description": "Initialize new project with full workflow"
    }
  ]
}
```

**Option B: Index File**
Create `.claude/commands/index.md` that lists all commands.

**Option C: Framework Initialization Command**
Add to quickstart:
```bash
# After copying .claude directory
claude-code --load-commands .claude/commands/
```

**Status:** 🔴 CRITICAL - Blocks framework usage
**Priority:** CRITICAL
**Assigned To:** Immediate investigation required

---

### CON-03: Benchmark Metric Tracking Automation 🤖

**Problem:**
Manual tracking of benchmark metrics is error-prone and tedious.

**Current State:**
- Human manually counts retries
- Human manually tracks interventions
- Human manually calculates scores
- Easy to miss or miscount events

**Proposed Solutions:**

**Option A: Metrics Logging Agent**
Create `.claude/agents/metrics-logger.md`:
- Triggered automatically during benchmark runs
- Logs events to `.claude/state/benchmark-metrics.json`
- Tracks: routing decisions, retries, interventions, time

**Option B: Benchmark Command with Auto-Tracking**
Create `/project:benchmark` command:
```bash
/project:benchmark [prompt]
# Automatically tracks all metrics
# Outputs results at end
```

**Option C: Post-Run Analysis Tool**
Create script that parses conversation history:
```bash
python analyze-benchmark.py --conversation conversation.json
# Outputs: benchmark-results-auto-generated.md
```

**Option D: State File Updates**
Update commands to log to `.claude/state/`:
```
.claude/state/routing-log.md
.claude/state/retry-log.md
.claude/state/intervention-log.md
.claude/state/time-log.md
```

**Recommended Approach:**
Combination of Option D + Option C
- Commands log events to state files
- Post-run script aggregates and calculates scores

**Status:** 🟡 Enhancement
**Priority:** MEDIUM
**Assigned To:** Framework v0.3

---

### CON-04: Parking Lot Requirements (Open Questions) 📋

**Problem:**
PM agent created "Open Questions" during `/project:start` - perfect features for later versions. No tracking mechanism for these.

**Example:**
```markdown
## Open Questions (from PM)
- Should we support task templates?
- Multi-tenancy support?
- Real-time notifications?
- Audit logging?
```

**Current State:**
- Questions live in planning documents
- No systematic tracking
- Easy to forget or lose

**Proposed Solutions:**

**Option A: Backlog File**
Create `.claude/plans/backlog.md`:
```markdown
# Feature Backlog

## Future Enhancements (Phase 5+)
- [ ] Task templates
- [ ] Multi-tenancy
- [ ] Real-time notifications
- [ ] Audit logging

## Open Questions
- How to handle time zones for due dates?
- Should we support recurring tasks?
```

**Option B: PM Agent Responsibility**
Update `.claude/agents/product-manager.md`:
- PM automatically creates/updates `.claude/plans/backlog.md`
- Categorizes: Must-Have, Nice-to-Have, Future

**Option C: Versioned Requirements**
```
.claude/specs/requirements-v1.md  (current)
.claude/specs/requirements-v2.md  (future)
.claude/plans/parking-lot.md      (ideas/questions)
```

**Recommended Approach:**
Option B (PM owns backlog management)

**Status:** 🟢 Enhancement
**Priority:** LOW
**Assigned To:** Framework v0.3

---

### CON-05: Agent Time Awareness (2024 vs 2025) 📅

**Problem:**
Agents sometimes think they're in 2024, potentially causing outdated recommendations.

**Observation:**
- OBS-01: Engineer agent correctly knew it was 2025 (see PROJECT_INITIALIZATION_SUMMARY.md)
- Inconsistent behavior across agents

**Impact:**
- May recommend deprecated packages
- May miss recent best practices
- May use outdated syntax

**Investigation:**
- Is this a Claude Code system prompt issue?
- Do agents inherit correct date from system?
- Is this specific to certain agents?

**Proposed Solutions:**

**Option A: Explicit Date in Agent Prompts**
Add to all agent `.md` files:
```yaml
---
name: engineer
current_date: 2025-12-06  # Auto-updated by system
---
```

**Option B: System Prompt Enhancement**
Ensure all agents receive:
```
IMPORTANT: Current date is {CURRENT_DATE}
Use latest versions and best practices as of this date.
```

**Option C: No Action**
- If Engineer (most critical agent) is correct, may be acceptable
- Monitor for actual issues caused by date confusion

**Recommended Approach:**
Option C + monitoring
- Document expected behavior
- Log instances where wrong date caused issues

**Status:** 🟢 Monitor
**Priority:** LOW (unless causes actual problems)
**Assigned To:** Observation

---

### CON-06: Task Tracking - Plans Directory Unused ⚠️ HIGH PRIORITY

**Problem:**
Agents never used `.claude/plans/*` files during workflow. If session is lost, no way to resume from where they stopped.

**Current State:**
- `.claude/plans/current-task.md` exists but unused
- No persistence of progress
- Session loss = start from scratch

**Impact:**
- Cannot resume after quota limit
- Cannot resume after errors
- Cannot hand off to another developer
- Violates framework's "context persistence" principle

**Proposed Solutions:**

**Option A: Mandatory Task Updates**
Update all commands to:
1. Read `.claude/plans/current-task.md` at start
2. Update progress after each step
3. Mark complete when done

Example in `/project:implement`:
```markdown
1. Read current-task.md
2. If task exists and in-progress:
   - Resume from last checkpoint
3. If no task:
   - Create new task entry
4. After each major step:
   - Update current-task.md with progress
5. On completion:
   - Mark task complete
   - Archive to .claude/plans/completed/
```

**Option B: Task State Machine**
Create `.claude/state/workflow-state.json`:
```json
{
  "current_phase": "Phase 2: Authentication",
  "last_step": "Implemented JWT middleware",
  "next_step": "Write authentication tests",
  "retry_count": 2,
  "timestamp": "2025-12-06T14:30:00Z"
}
```

**Option C: Engineer Agent Checkpoints**
Engineer agent automatically creates checkpoints:
```markdown
# .claude/plans/checkpoint-2025-12-06-1430.md
## Progress
- ✅ Phase 1 complete
- 🔄 Phase 2 in progress (60%)
- ⏸️ Next: Complete auth tests

## Files Changed
- src/auth/jwt.ts
- src/middleware/auth.ts
- tests/auth.test.ts (in progress)
```

**Recommended Approach:**
Combination of Option A + Option C
- Commands update current-task.md
- Engineer creates detailed checkpoints

**Status:** 🔴 HIGH PRIORITY
**Priority:** HIGH (critical for resume capability)
**Assigned To:** Framework v0.3

---

### CON-07: Version Control & Git Conventions 🔀

**Problem:**
Agents used git locally but:
- Never committed to remote repo
- No commit message conventions
- No branch strategy
- Cannot recover from problems or discard changes

**Current State:**
- Framework instructions mention git but don't enforce it
- No systematic commit strategy
- No push to remote

**Impact:**
- Cannot rollback bad changes
- Cannot share progress
- Cannot use CI/CD
- No collaboration support

**Proposed Solutions:**

**Option A: Git Workflow in Commands**
Update commands to include git operations:
```markdown
# In /project:implement
After implementation:
1. Run tests
2. If tests pass:
   - git add .
   - git commit -m "feat: implement [feature]"
3. Ask user: "Push to remote? (y/n)"
```

**Option B: Dedicated Git Agent**
Create `.claude/agents/git-manager.md`:
- Manages all git operations
- Follows conventional commits
- Creates feature branches
- Handles merge conflicts

**Option C: DevOps Agent Extension**
Extend `.claude/agents/devops.md`:
- Include git workflow responsibility
- Create branches per phase
- Commit after each phase
- Tag releases

**Git Conventions to Enforce:**
```
feat: New feature
fix: Bug fix
refactor: Code refactor
test: Add tests
docs: Documentation
chore: Maintenance

Branch naming:
- feature/[feature-name]
- fix/[issue-name]
- phase/[phase-number]
```

**Recommended Approach:**
Option C + automatic commits per phase

**Status:** 🟡 Enhancement
**Priority:** MEDIUM
**Assigned To:** Framework v0.3

---

### CON-08: Agent Memory Organization 💾

**Problem:**
Engineer agent created `PROJECT_INITIALIZATION_SUMMARY.md` in root folder. Unclear if:
- This is agent memory
- Root is the right location
- Other agents should do this
- Standard pattern or one-off

**Questions:**
1. Should agents create memory/summary files?
2. If yes, where should they live?
3. Should there be naming conventions?
4. How do these relate to `.claude/specs/*` artifacts?

**Proposed Solutions:**

**Option A: Standardized Memory Location**
```
.claude/memory/
├── engineer-session-2025-12-06.md
├── architect-decisions.md
├── pm-requirements-notes.md
└── tester-coverage-tracking.md
```

**Option B: Integrate with Existing Artifacts**
- Don't create separate memory files
- Update existing `.claude/specs/*` files
- Use `.claude/plans/current-task.md` for session state

**Option C: Agent-Specific Summaries in Specs**
```
.claude/specs/
├── requirements.md          (PM owned)
├── architecture.md          (Architect owned)
├── implementation-notes.md  (Engineer owned)
├── test-strategy.md         (Tester owned)
└── security-findings.md     (Security owned)
```

**Recommended Approach:**
Option B (use existing artifacts, don't proliferate files)
- Update agent prompts to use specs/ for memory
- Move PROJECT_INITIALIZATION_SUMMARY.md to `.claude/specs/implementation-notes.md`

**Status:** 🟢 Enhancement
**Priority:** LOW
**Assigned To:** Framework v0.3 (documentation)

---

### CON-09: Agent Quota Limit Recovery 🚫

**Problem:**
When hitting "Limit reached · resets 2pm", unclear how to resume work from where it stopped.

**Current State:**
- No clear resume mechanism
- Related to CON-06 (task tracking)
- Framework doesn't handle quota limits gracefully

**User Experience:**
```
Agent: Working on Phase 2...
System: Limit reached · resets 2pm (America/Sao_Paulo)
[Session ends]

[After 2pm]
User: How do I continue?
Agent: Starting from scratch?
```

**Proposed Solutions:**

**Option A: Resume Command**
Create `/project:resume`:
```markdown
1. Read .claude/plans/current-task.md
2. Read .claude/state/workflow-state.json
3. Show user: "Last step: X, Next step: Y"
4. Ask: "Resume from here? (y/n)"
5. Continue workflow
```

**Option B: Automatic State Persistence**
Every command saves state:
```json
{
  "session_id": "abc-123",
  "interrupted_at": "2025-12-06T14:00:00Z",
  "current_command": "/project:implement",
  "current_phase": "Phase 2",
  "resume_point": "Writing authentication tests",
  "context": {
    "files_modified": [...],
    "tests_passing": true,
    "retry_count": 1
  }
}
```

**Option C: Checkpoint System**
Before each major operation:
```markdown
Engineer: Creating checkpoint...
[Saves current state]
Engineer: Safe to interrupt. Run /project:resume to continue.
```

**Option D: User Documentation**
Add to quickstart guide:
```markdown
## If You Hit Quota Limit

1. Note what phase/step you're on
2. Commit current work: git commit -m "WIP: [step]"
3. After quota resets:
   - Read .claude/specs/ to understand state
   - Read latest commit message
   - Tell Claude: "Continue from [step]"
```

**Recommended Approach:**
Combination of Option A + Option B + Option D
- Implement automatic state saving
- Create resume command
- Document manual process as backup

**Status:** 🔴 HIGH PRIORITY
**Priority:** HIGH (critical for usability)
**Assigned To:** Framework v0.3

**Dependencies:** Requires CON-06 (task tracking) to be fixed first

---

### CON-10: Token Utilization Optimization 🎯 CRITICAL

**Problem:**
Reaching token limits too quickly during benchmark runs.

**Symptoms:**
- Long conversation history
- Large file reads
- Repeated context in agent calls
- Inefficient tool usage

**Impact:**
- Cannot complete full benchmark in one session
- Expensive API costs
- Poor user experience

**Analysis Needed:**
1. Which operations consume most tokens?
2. Are agents reading files multiple times?
3. Is context being duplicated in agent handoffs?
4. Are large files being read unnecessarily?

**Proposed Solutions:**

**Option A: Agent Context Optimization**
- Use `model: haiku` for simple agents (tester, documenter)
- Reserve `opus` only for critical decisions (architect, PM)
- Use `sonnet` as default (engineer, reviewer)

Update agent frontmatter:
```yaml
---
name: tester
model: haiku  # Fast, cheap for test generation
---
```

**Option B: Artifact-First Strategy**
Reduce conversation context by:
1. Writing key decisions to `.claude/specs/` immediately
2. Agents read artifacts instead of asking in conversation
3. Minimize back-and-forth questions

**Option C: Lazy File Reading**
- Don't read entire codebase upfront
- Only read files when necessary
- Use Grep/Glob first to locate, then Read specific files
- Limit file reads with `limit` parameter

**Option D: Conversation Summarization**
After each phase:
1. Summarize key decisions
2. Write to artifact
3. Clear conversation context
4. Next phase starts fresh with artifact context

**Option E: Command Optimization**
Update commands to:
- Minimize agent invocations
- Combine related tasks
- Use parallel agent execution where possible
- Avoid redundant context passing

**Recommended Approach:**
ALL of the above (comprehensive optimization)

**Immediate Actions:**
1. Audit token usage in benchmark run
2. Profile which agents use most tokens
3. Identify redundant reads/operations
4. Implement quick wins first

**Status:** 🔴 CRITICAL
**Priority:** CRITICAL
**Assigned To:** Immediate investigation + Framework v0.3

---

### CON-11: Rework and Code Deletion Pattern 🔄

**Problem:**
PM and Architect create draft code in planning phase. Engineer later deletes and rebuilds instead of preserving/commenting code.

**Example:**
```
Planning Phase: Architect creates draft authentication code
Phase 1 (Foundation): Engineer deletes auth code (not needed yet)
Phase 2 (Authentication): Engineer recreates auth code from scratch
```

**Impact:**
- Wasted tokens recreating code
- Loss of initial design insights
- Inefficient workflow
- Unnecessary churn

**Root Cause Analysis:**
1. PM/Architect creating code too early?
2. Engineer not recognizing existing code?
3. No convention for "future code" preservation?
4. Phased implementation not well coordinated?

**Proposed Solutions:**

**Option A: Strict Phase Boundaries**
- PM/Architect create only specifications, NO code
- Engineer creates all code, following specs
- Clear separation: planning vs implementation

Update architect prompt:
```markdown
IMPORTANT: Create architecture DOCUMENTS only.
Do NOT create code files.
Your output: architecture.md with design decisions.
```

**Option B: Future Code Convention**
If early code is created, use clear markers:
```typescript
// PHASE 2: Authentication (not implemented yet)
// TODO: Implement JWT authentication
export function authenticateUser() {
  throw new Error('Not implemented - planned for Phase 2');
}
```

Engineer recognizes and preserves until phase 2.

**Option C: Incremental Code Strategy**
- Create minimal stubs in planning
- Engineer extends (not replaces) in each phase
- Use feature flags for future code

```typescript
// Phase 1: Stub
export function authenticate() { return true; }

// Phase 2: Engineer updates
export function authenticate(token: string) {
  return validateJWT(token);
}
```

**Option D: Artifact-Based Planning**
- Architect creates detailed pseudocode in architecture.md
- Engineer translates pseudocode to actual code (no deletion needed)
- Pseudocode stays in artifact as reference

**Recommended Approach:**
Combination of Option A + Option D

**Changes Needed:**
1. Update Architect agent: No code creation, only specs
2. Update Engineer agent: Implement from specs, not from example code
3. Update commands: Clear phase boundaries

**Status:** 🟡 Enhancement
**Priority:** MEDIUM
**Assigned To:** Framework v0.3

---

## Session Analysis Considerations (From Agent Transcript Analysis)

**Source:** Full 18-agent transcript analysis (2025-12-06)
**Analysis Location:** `session-exports/20251206-194845/FRAMEWORK-IMPROVEMENT-ANALYSIS.md`
**Quantified Evidence:** 4.3x file redundancy, 122 Bash commands, 60-85% token reduction possible

### CON-12: Agent File Content Caching 🔴 CRITICAL

**Problem:** Agents re-read the same files multiple times, causing massive token waste.

**Evidence:**
- 78 unique files, 333 file operations = **4.3x redundancy factor**
- Core specs read 28 times: architecture.md (10x), tech-stack.md (9x), requirements.md (9x)
- agent-4a328c96 read same files twice in single session

**Impact:** **Estimated 30-40% token reduction**

**Recommendation:** Per-agent file content cache, "recently read" metadata

**Status:** 🔴 CRITICAL | **Priority:** P0 | **Assigned To:** v0.3 Phase 1

---

### CON-13: Explicit Agent Role Metadata 🔴 CRITICAL

**Problem:** Cannot identify agent roles from transcripts - debugging impossible.

**Evidence:**
- agent-2cd490d2: 42 ops, 0 reads, 19 writes - role unknown
- agent-00a0149e, agent-c42525e1: 1 operation each - purpose unknown

**Recommendation:** Add `role`, `phase`, `subtask` fields to agent YAML and exports

**Status:** 🔴 CRITICAL | **Priority:** P0 | **Assigned To:** v0.3 Phase 3

---

### CON-14: Duplicate Agent Invocations 🟡 HIGH

**Problem:** Two agents worked on Phase 2 Auth - unclear if retry or parallel.

**Evidence:**
- agent-4ed9b522: 59 ops on "Phase 2 Auth"
- agent-4a328c96: 238 ops on "Phase 2 Auth"
- Potentially 59 wasted operations

**Recommendation:** Export retry metadata, parent-child relationships, retry reason

**Status:** 🟡 HIGH | **Priority:** P1 | **Assigned To:** v0.3 Phase 3

---

### CON-15: Minimal Agent Invocation Waste 🟢 MEDIUM

**Problem:** 2 agents performed only 1 operation each.

**Evidence:** agent-00a0149e (1.4KB), agent-c42525e1 (1.8KB)

**Recommendation:** Pre-flight complexity check, log termination reason

**Status:** 🟢 MEDIUM | **Priority:** P2 | **Assigned To:** v0.4

---

### CON-16: Bash-Heavy File Discovery Anti-Pattern 🔴 HIGH

**Problem:** Agents use expensive Bash commands for file discovery.

**Evidence:**
- 122 Bash commands total, 60% for `ls`, `find`, `grep`
- agent-4a328c96: 42 Bash commands for file location

**Impact:** **Estimated 10-15% token reduction**

**Recommendation:** Provide project file tree in context, FilesystemQuery tool

**Status:** 🔴 HIGH | **Priority:** P1 | **Assigned To:** v0.3 Phase 1

---

### CON-17: Command-Level Artifact Cache Not Working 🔴 CRITICAL

**Problem:** v0.2 artifact priority not preventing redundant reads.

**Evidence:** Core specs read 28 times total across agents

**Impact:** **Estimated 15-20% token reduction**

**Recommendation:** Load artifacts once per command, inject into all agent contexts

**Status:** 🔴 CRITICAL | **Priority:** P0 | **Assigned To:** v0.3 Phase 1

---

### CON-18: Engineer-Heavy Workflow Imbalance 🟡 MEDIUM

**Problem:** 8+ Engineer agents, minimal testing/validation agents.

**Evidence:** Top 10 agents: 8 Engineers, 1 Architect, 1 Unknown

**Recommendation:** Dedicated Tester and Code Reviewer agents for each phase

**Status:** 🟡 MEDIUM | **Priority:** P2 | **Assigned To:** v0.3 Phase 2

---

### CON-19: No Testing Agents in Workflow 🔴 CRITICAL

**Problem:** No testing specialists despite production-ready goal.

**Evidence:**
- 0 dedicated Tester agents in top 10
- Framework has tester agent but not invoked

**Recommendation:** Make Tester agent mandatory, test-first workflow variant

**Status:** 🔴 CRITICAL | **Priority:** P0 | **Assigned To:** v0.3 Phase 2

---

### CON-20: Missing Security Auditor Agent 🔴 CRITICAL

**Problem:** Authentication implemented with no security review.

**Evidence:**
- Phase 2 (JWT, passwords) with no security-auditor agent
- Framework has security-auditor but not used

**Recommendation:** Mandatory security-auditor for auth/data/API phases

**Status:** 🔴 CRITICAL | **Priority:** P0 | **Assigned To:** v0.3 Phase 2

---

### CON-21: Write vs Edit Imbalance 🟢 MEDIUM

**Problem:** High Write/Edit ratios suggest "write once, ship" pattern.

**Evidence:** agent-58e69205: 37 Writes, 3 Edits (12:1 ratio)

**Recommendation:** Track ratios, flag >5:1 for quality review

**Status:** 🟢 MEDIUM | **Priority:** P3 | **Assigned To:** v0.4

---

### CON-22: Error Handling Opaque 🟡 HIGH

**Problem:** Unclear if error references are encountered errors or code being written.

**Evidence:** agent-2cd490d2: 12 error references in transcript

**Recommendation:** Structured error logging: agent_errors, tool_errors, retry_triggers

**Status:** 🟡 HIGH | **Priority:** P1 | **Assigned To:** v0.3 Phase 3

---

### CON-23: Parallel Agent Coordination Unknown 🟢 LOW

**Problem:** Agents with identical ops suggest parallel work, no metadata confirms.

**Evidence:** agent-af41e798 and agent-8495e060: both 33 ops, identical usage

**Recommendation:** Add execution mode, timestamps, dependency graph

**Status:** 🟢 LOW | **Priority:** P4 | **Assigned To:** v0.4+

---

### CON-24: No Documentation Agent Evidence 🟡 MEDIUM

**Problem:** Phase 4 production readiness with no dedicated documenter.

**Evidence:** Framework has documenter agent but not invoked

**Recommendation:** Mandatory documenter agent after each phase

**Status:** 🟡 MEDIUM | **Priority:** P2 | **Assigned To:** v0.3

---

### CON-25: Workflow Missing Enforced Quality Gates 🟡 MEDIUM

**Problem:** Workflow allows sequential execution without enforcing quality gates.

**Recommendation:** Phase-gating, mandatory agents based on phase type

**Status:** 🟡 MEDIUM | **Priority:** P2 | **Assigned To:** v0.3

---

## Summary & Prioritization

**Total Considerations:** 25 (CON-01 through CON-25)
**Analysis Source:** First benchmark run + Full agent transcript analysis
**Quantified Impact:** 60-85% token reduction possible

### 🔴 CRITICAL (Must Fix for v0.3) - 7 Issues

**Token Optimization (60-85% reduction):**
1. **CON-12**: Agent file content caching (30-40% reduction)
2. **CON-17**: Command-level artifact cache (15-20% reduction)
3. **CON-16**: Bash-heavy file discovery (10-15% reduction)
4. **CON-10**: Token utilization optimization (now quantified)

**Quality Gates:**
5. **CON-19**: No testing agents in workflow
6. **CON-20**: Missing security auditor

**Framework Issues:**
7. **CON-02**: Slash commands not auto-loading
8. **CON-13**: Explicit agent role metadata

### ⚠️ HIGH PRIORITY (Should Fix for v0.3) - 6 Issues

**Analysis & Debugging:**
9. **CON-14**: Duplicate agent invocations
10. **CON-22**: Error handling opaque

**User Experience:**
11. **CON-01**: CLAUDE.md initialization strategy
12. **CON-06**: Task tracking and resume capability
13. **CON-09**: Quota limit recovery mechanism

### 🟡 MEDIUM PRIORITY (Nice to Have in v0.3) - 8 Issues

**Quality Improvements:**
14. **CON-18**: Engineer-heavy workflow imbalance
15. **CON-24**: No documentation agent evidence
16. **CON-25**: Workflow missing enforced quality gates
17. **CON-21**: Write/Edit imbalance

**Process Improvements:**
18. **CON-07**: Git workflow enforcement
19. **CON-11**: Rework and code deletion pattern
20. **CON-03**: Benchmark metric automation
21. **CON-15**: Minimal agent invocation waste

### 🟢 LOW PRIORITY (Future Versions) - 4 Issues

22. **CON-23**: Parallel agent coordination
23. **CON-04**: Parking lot requirements tracking
24. **CON-05**: Agent time awareness consistency
25. **CON-08**: Agent memory organization

---

## Next Steps

1. **Immediate Investigation** (Week 1)
   - CON-02: Test slash command loading mechanisms
   - CON-10: Profile token usage in benchmark
   - CON-06: Design state persistence system

2. **Framework v0.3 Planning** (Week 2)
   - Prioritize fixes based on impact
   - Design solutions for critical issues
   - Update agent prompts and commands

3. **Implementation** (Week 3-4)
   - Fix critical issues
   - Test with benchmark
   - Measure improvement

4. **Documentation** (Week 4)
   - Update CLAUDE.md with learnings
   - Update benchmark guide
   - Document new patterns

---

## Open Questions for Discussion

1. **CON-02**: What is the official way to register slash commands in Claude Code?
2. **CON-10**: What is acceptable token budget for a full benchmark? (current vs target)
3. **CON-06**: Should we use JSON or Markdown for state persistence?
4. **CON-01**: Should CLAUDE.md be auto-updated or user-edited?
5. **CON-11**: Should PM/Architect agents be prohibited from creating code files?

---

## Metrics to Track in Next Benchmark

After v0.3 improvements, re-run benchmark and measure:

- [ ] Slash commands work out of the box (CON-02)
- [ ] Token usage reduced by __% (CON-10)
- [ ] Can resume after interruption (CON-06, CON-09)
- [ ] CLAUDE.md filled automatically (CON-01)
- [ ] Less code rework observed (CON-11)
- [ ] Git commits created systematically (CON-07)

---

**Document Owner:** Framework Development Team
**Last Updated:** 2025-12-06
**Next Review:** After v0.3 implementation
