# Pattern Consolidation Plan

> Plan for consolidating cross-cutting patterns and reducing agent duplication
> Date: 2025-12-08
> Status: PLANNING

---

## Executive Summary

Create 3 new patterns to consolidate duplicated content across agents:
- `agent-collaboration.md` - Visual handoff diagram and escalation paths
- `state-files.md` - State file documentation and schemas
- `agent-structure.md` - Mandatory/optional section template for agents

Remove ~342 lines of duplicated content from agents, replaced with pattern references.

---

## Patterns vs Protocols: Reminder

| Aspect | Patterns | Protocols |
|--------|----------|-----------|
| **Purpose** | Cross-cutting concerns for ALL/MANY agents | Task-specific procedures for ONE agent type |
| **Loading** | Always available, referenced when needed | On-demand based on task analysis |
| **Location** | `.claude/patterns/` | `.claude/protocols/` |
| **Dependency** | Protocols may reference patterns | Patterns don't reference protocols |

---

## Current Patterns (Keep As-Is)

| Pattern | Lines | Purpose | Changes Needed |
|---------|-------|---------|----------------|
| `git-workflow.md` | 252 | Git conventions | None - already comprehensive |
| `context-injection.md` | 340 | Context loading | None - already comprehensive |
| `performance.md` | 448 | Cross-cutting perf | None |
| `state-based-session-management.md` | 700 | Task tracking | None |
| `parallel-quality-validation.md` | 354 | Agent parallelization | None |
| `multi-repo.md` | 572 | Multi-repo architecture | None |
| `input-safety.md` | 256 | Input validation | None |
| `model-selection.md` | 73 | Model selection | None |
| `reflexion.md` | 64 | Retry patterns | None |

---

## New Patterns to Create

### 1. `agent-collaboration.md` (~150 lines)

**Purpose:** Define how agents hand off work to each other, with visual diagrams.

**Content:**

```markdown
# Agent Collaboration Pattern

## Agent Ecosystem Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PLANNING LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │   Product    │───▶│   UI/UX      │───▶│  Architect   │          │
│  │   Manager    │    │   Designer   │    │  (Frontend   │          │
│  │              │    │              │    │  + Backend)  │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│        │                    │                    │                  │
│        │ requirements       │ design specs       │ architecture    │
│        ▼                    ▼                    ▼                  │
│  specs/requirements.md  specs/ui-ux-*.md    specs/architecture.md  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      IMPLEMENTATION LAYER                            │
├─────────────────────────────────────────────────────────────────────┤
│        ┌──────────────────────────────────────────┐                 │
│        │              Engineer                     │                 │
│        │  (reads specs, writes src/ and tests/)   │                 │
│        └──────────────────────────────────────────┘                 │
│                          │                                          │
│                          │ implementation                           │
│                          ▼                                          │
│                    src/*, tests/*                                   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       VALIDATION LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │    Tester    │    │   Security   │    │    Code      │          │
│  │              │    │   Auditor    │    │   Reviewer   │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│        │                    │                    │                  │
│        │ test results       │ findings          │ review           │
│        ▼                    ▼                    ▼                  │
│  state/test-results.md  state/security-*.md  state/code-review-*.md│
│                                                                     │
│  ════════════════════════════════════════════════════════════════  │
│                    Runs in PARALLEL                                 │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        DELIVERY LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│        ┌──────────────┐              ┌──────────────┐              │
│        │  Documenter  │              │    DevOps    │              │
│        │              │              │              │              │
│        └──────────────┘              └──────────────┘              │
│              │                              │                       │
│              │ docs                         │ deployment            │
│              ▼                              ▼                       │
│         docs/*, README.md           .github/workflows/, Dockerfile  │
└─────────────────────────────────────────────────────────────────────┘
```

## Handoff Matrix

| From | To | Trigger | Information Passed |
|------|----|---------|--------------------|
| Product Manager | Architect | Requirements complete | `specs/requirements.md` |
| Product Manager | UI/UX Designer | UX needed | `specs/requirements.md` |
| UI/UX Designer | Architect | Design specs ready | `specs/ui-ux-specs.md`, `specs/design-system.md` |
| Architect | Engineer | Architecture defined | `specs/architecture.md`, `specs/tech-stack.md` |
| Engineer | Tester | Implementation complete | `state/implementation-notes.md` |
| Engineer | Security Auditor | Security-sensitive code | `state/implementation-notes.md` |
| Engineer | Code Reviewer | Ready for review | `state/implementation-notes.md` |
| Tester | Engineer | Tests fail | `state/test-results.md` (issues to fix) |
| Security Auditor | Engineer | Vulnerabilities found | `state/security-findings.md` |
| Code Reviewer | Engineer | Changes requested | `state/code-review-findings.md` |
| Engineer | Documenter | Feature complete | `state/implementation-notes.md` |
| Engineer | DevOps | Ready for deployment | Implementation complete |

## Escalation Paths

### When Engineer Needs Architecture Clarification
```
Engineer ──(unclear specs)──▶ Architect
          ◀──(updated specs)──
```

### When Reviewer Finds Architectural Issues
```
Code Reviewer ──(arch violation)──▶ Architect ──(decision)──▶ Engineer
```

### When Security Finds Critical Issues
```
Security Auditor ──(CRITICAL)──▶ Engineer (immediate fix)
                 ──(HIGH)──▶ Engineer (priority fix)
                 ──(MEDIUM/LOW)──▶ Backlog
```

## Parallel Validation

Tester, Security Auditor, and Code Reviewer run in parallel after implementation:

```
                    ┌─────────────┐
                    │  Engineer   │
                    │  (done)     │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Tester  │    │ Security │    │ Reviewer │
    │          │    │ Auditor  │    │          │
    └────┬─────┘    └────┬─────┘    └────┬─────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
                  Aggregate Results
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
    All Pass?                      Issues Found?
         │                               │
         ▼                               ▼
    Documenter/DevOps              Engineer (fix)
```

## Agent Capabilities Summary

| Agent | Creates | Reads | Never Touches |
|-------|---------|-------|---------------|
| Product Manager | `specs/requirements.md` | - | `src/`, `tests/` |
| UI/UX Designer | `specs/ui-ux-*.md` | requirements | `src/`, `tests/` |
| Architect | `specs/architecture.md`, `specs/tech-stack.md` | requirements, ui-ux | `src/`, `tests/` |
| Engineer | `src/*`, `tests/*` | all specs | `specs/*` |
| Tester | `tests/*`, `state/test-results.md` | src, specs | `src/*` |
| Security Auditor | `state/security-findings.md` | src, tests | `src/*`, `tests/*` |
| Code Reviewer | `state/code-review-findings.md` | src, tests, specs | `src/*`, `tests/*` |
| Documenter | `docs/*`, `README.md` | src, specs | `src/*`, `specs/*` |
| DevOps | `.github/*`, `Dockerfile` | all | `src/*` |
```

**Replaces in agents:** "When to Invoke Other Agents" sections (~180 lines total)

---

### 2. `state-files.md` (~120 lines)

**Purpose:** Document all state files, their schemas, and ownership.

**Content:**

```markdown
# State Files Pattern

## Overview

State files enable agents to communicate asynchronously. Each agent writes to their designated state file; other agents read these files to understand context.

**Location:** `.claude/state/`

## State File Registry

| File | Owner | Purpose | Readers |
|------|-------|---------|---------|
| `current-task.md` | Commands | Track workflow progress | All agents, `/project:resume` |
| `implementation-notes.md` | Engineer | Document what was built | Tester, Security, Reviewer, Documenter |
| `test-results.md` | Tester | Test execution outcomes | Engineer (for fixes), DevOps |
| `security-findings.md` | Security Auditor | Vulnerability reports | Engineer (for fixes) |
| `code-review-findings.md` | Code Reviewer | Review feedback | Engineer (for fixes) |
| `retry-counter.md` | Commands | Reflexion tracking | Commands |
| `workflow-log.md` | All agents | Protocol loading decisions | Debugging |

## File Schemas

### current-task.md

```markdown
## Current Task
**Command:** /project:{command} {arguments}
**Status:** IDLE | IN_PROGRESS | COMPLETED | FAILED
**Progress:** Step X/Y - {checkpoint name}
**Started:** {timestamp}

## Workflow Steps
1. [x] Step 1 ✓ (completed {time})
2. [ ] Step 2 ← CURRENT
3. [ ] Step 3

## Last Checkpoint
**Completed:** {what was done}
**Next Step:** {what to do next}
**Files Modified:** {list}
```

### implementation-notes.md

```markdown
## Implementation: {Feature Name}

**Date:** {date}
**Phase:** {phase if applicable}

### Files Created
- `path/to/file.ts` - {description}

### Files Modified
- `path/to/file.ts` - {what changed}

### Dependencies Added
- `package@version` - {purpose}

### Test Focus Areas
- {areas needing testing}

### Known Limitations
- {what's not implemented yet}
```

### test-results.md

```markdown
## Test Results: {Feature/Date}

**Status:** PASS | FAIL | PARTIAL
**Coverage:** {percentage}

### Summary
| Type | Passed | Failed | Skipped |
|------|--------|--------|---------|
| Unit | X | Y | Z |
| Integration | X | Y | Z |
| E2E | X | Y | Z |

### Failures
#### {Test Name}
- **File:** `tests/path/file.test.ts`
- **Error:** {error message}
- **Fix Needed:** {description}

### Coverage Gaps
- {areas lacking coverage}
```

### security-findings.md

```markdown
## Security Audit: {Feature/Date}

**Status:** PASS | FAIL
**Critical:** {count} | **High:** {count} | **Medium:** {count} | **Low:** {count}

### Findings

#### [CRITICAL] {Title}
- **Location:** `src/path/file.ts:42`
- **Issue:** {description}
- **Risk:** {impact}
- **Remediation:** {how to fix}

#### [HIGH] {Title}
...
```

### code-review-findings.md

```markdown
## Code Review: {Feature/Date}

**Status:** APPROVED | CHANGES_REQUESTED | BLOCKED
**Issues:** {critical} CRITICAL, {major} MAJOR, {minor} MINOR

### Findings

#### [MAJOR] {Title}
- **Location:** `src/path/file.ts:42`
- **Issue:** {description}
- **Suggestion:** {recommended change}

### Positive Notes
- {what was done well}
```

### workflow-log.md

```markdown
## Workflow: {Date}

### Protocol Loading

**Agent:** Architect
**Task:** Design payment API
**Protocols Loaded:**
- `api-rest.md` - Task involves REST endpoints
- Skipped: `api-realtime.md` - No real-time requirements

**Agent:** Engineer
**Task:** Implement payment processing
**Protocols Loaded:**
- `database-implementation.md` - New tables needed
- `authentication.md` - Payment requires auth
```

## Read/Write Rules

1. **Ownership:** Only the owner agent writes to their state file
2. **Append-only:** When adding to existing file, append new sections
3. **Clear on new workflow:** State files may be cleared at workflow start
4. **Timestamp:** Include timestamps for traceability
5. **Status first:** Put status/summary at top for quick reading

## State File Lifecycle

```
Workflow Start
     │
     ▼
current-task.md created (IN_PROGRESS)
     │
     ▼
Agents write their state files as they work
     │
     ▼
Workflow Complete
     │
     ▼
current-task.md updated (COMPLETED)
```
```

**Creates new documentation for:** State file schemas and conventions

---

### 3. `agent-structure.md` (~100 lines)

**Purpose:** Define the standard structure for all agent files.

**Content:**

```markdown
# Agent Structure Pattern

## Overview

All agents follow a consistent structure with mandatory sections, optional sections, and agent-specific sections.

## File Structure

```markdown
---
name: {agent-name}
description: >
  {One-line description}
  {When to use PROACTIVELY}

  See `.claude/patterns/context-injection.md` for context handling.
model: {opus|sonnet|haiku}
tools: {tool list}
---

{Agent persona - one line}

## MANDATORY SECTIONS (in order)

### Your Responsibilities
### What You Write
### What You DON'T Write
### Tool Usage Guidelines
### Process/Workflow

## OPTIONAL SECTIONS

### Protocol Loading (if agent uses protocols)
### State Communication (if agent writes state files)

## REFERENCE SECTIONS (one-liners)

### Git Commits
### Related Patterns

## AGENT-SPECIFIC SECTIONS

### {Custom sections for this agent's domain}

## STANDARD CLOSING

### When to Invoke Other Agents
### Example: Good vs Bad
### Output Format
```

## Mandatory Sections

Every agent MUST have these sections:

### 1. Your Responsibilities
Brief overview of what the agent does (3-5 bullet points).

### 2. What You Write
Files/locations this agent creates or modifies.
Format:
```markdown
**✅ DO write to these locations:**
- `path/pattern` - {purpose}
```

### 3. What You DON'T Write
Files/locations this agent must never touch.
Format:
```markdown
**❌ NEVER write to these locations:**
- `path/pattern` - {why not}

**Critical Rule:** {one-line enforcement}
```

### 4. Tool Usage Guidelines
How each tool should be used by this agent.
Format:
```markdown
### {Tool Name}
**✅ Use for:** {list}
**❌ Never use for:** {list}
```

### 5. Process/Workflow
Step-by-step process the agent follows.
Format: Numbered steps with clear actions.

## Optional Sections

Include if applicable:

### Protocol Loading
Only if the agent loads protocols from `.claude/protocols/`.
```markdown
## Protocol Loading

Before starting work, consult `.claude/protocols/INDEX.md`.
Select relevant protocols based on task analysis.
```

### State Communication
Only if the agent writes to `.claude/state/` files.
```markdown
## State Communication

After completing work, update `.claude/state/{file}.md`.
See `.claude/patterns/state-files.md` for schema.
```

## Reference Sections (One-Liners)

These sections reference patterns instead of duplicating content:

### Git Commits
```markdown
## Git Commits
Follow `.claude/patterns/git-workflow.md`. Use prefix: `{type}:`
```

### Related Patterns
```markdown
## Related Patterns
- `.claude/patterns/performance.md` - {when relevant}
- `.claude/patterns/input-safety.md` - {when relevant}
```

## Agent-Specific Sections

Agents may add custom sections for domain-specific guidance.
Examples:
- Architect: "API Design Process", "Data Model Design"
- Engineer: "Database Implementation", "Performance Optimization"
- Tester: "Test Strategy", "Coverage Requirements"

These become candidates for protocol extraction when they grow large.

## Standard Closing Sections

Every agent ends with:

### When to Invoke Other Agents
Reference `.claude/patterns/agent-collaboration.md` then list agent-specific triggers:
```markdown
## When to Invoke Other Agents
See `.claude/patterns/agent-collaboration.md` for full handoff matrix.

### Specific triggers for this agent:
- {condition} → Invoke {agent}
```

### Example: Good vs Bad
One good example, one bad example specific to this agent's domain.

### Output Format
What the agent should output when finished.

## Template

```markdown
---
name: example-agent
description: >
  Brief description of agent role.
  Use PROACTIVELY when {trigger condition}.

  See `.claude/patterns/context-injection.md` for context handling.
model: sonnet
tools: Read, Write, Edit, Grep, Glob, Bash
---

You are a {role} who {responsibility}.

## Your Responsibilities

- {responsibility 1}
- {responsibility 2}
- {responsibility 3}

## What You Write

**✅ DO write to these locations:**
- `path/pattern` - {purpose}

## What You DON'T Write

**❌ NEVER write to these locations:**
- `path/pattern` - {reason}

**Critical Rule:** {enforcement statement}

## Tool Usage Guidelines

### Read/Grep/Glob
**✅ Use for:** {appropriate uses}

### Write/Edit
**✅ Use for:** {appropriate uses}
**❌ Never use for:** {inappropriate uses}

### Bash
**✅ Use for:** {appropriate uses}
**❌ Never use for:** {inappropriate uses}

## Process

1. **Step 1:** {action}
2. **Step 2:** {action}
3. **Step 3:** {action}

## Git Commits

Follow `.claude/patterns/git-workflow.md`. Use prefix: `{type}:`

## When to Invoke Other Agents

See `.claude/patterns/agent-collaboration.md` for full handoff matrix.

### Specific triggers:
- {condition} → Invoke {Agent}

## Example: Good vs Bad

### ❌ BAD
{bad example with explanation}

### ✅ GOOD
{good example with explanation}

## Output Format

{what agent outputs when finished}
```
```

**Establishes:** Consistent agent structure with mandatory/optional/custom sections

---

## Agent Refactoring: Duplication Removal

After creating new patterns, update agents to reference them:

### Git Commits Section (All 8 Agents)

**Before (~20 lines each):**
```markdown
## Git Commits

Follow the git workflow pattern in `.claude/patterns/git-workflow.md`.

Commit your implementation after completing a logical chunk:

```bash
git add src/ tests/
git commit -m "feat(phase-X): implement {feature}
...
```

**After (~2 lines each):**
```markdown
## Git Commits

Follow `.claude/patterns/git-workflow.md`. Use prefix: `feat:` or `fix:`
```

**Savings:** ~18 lines × 8 agents = ~144 lines

### When to Invoke Other Agents (All 8 Agents)

**Before (~25 lines each):**
```markdown
## When to Invoke Other Agents

### Architecture decision needed?
→ **STOP, invoke Architect**
- Don't make architectural decisions yourself
...
```

**After (~8 lines each):**
```markdown
## When to Invoke Other Agents

See `.claude/patterns/agent-collaboration.md` for full handoff matrix.

### Specific triggers for this agent:
- Architecture unclear → Invoke Architect
- Tests needed → Let Tester design, you implement
```

**Savings:** ~17 lines × 8 agents = ~136 lines

### CONTEXT PROTOCOL (Add to 5 agents missing it)

Currently only 3 agents have CONTEXT PROTOCOL. Add to all agents in description:

```markdown
description: >
  {existing description}

  See `.claude/patterns/context-injection.md` for context handling.
```

---

## Implementation Phases

### Phase 1: Create New Patterns

1. Create `.claude/patterns/agent-collaboration.md` (~150 lines)
2. Create `.claude/patterns/state-files.md` (~120 lines)
3. Create `.claude/patterns/agent-structure.md` (~100 lines)

### Phase 2: Update Agent Files

For each agent:
1. Add context-injection reference to description (if missing)
2. Replace Git Commits section with pattern reference
3. Replace When to Invoke section with pattern reference + specific triggers
4. Add State Communication section (if agent writes state files)
5. Verify structure matches `agent-structure.md`

### Phase 3: Validate

1. Check all agents follow `agent-structure.md`
2. Verify pattern references are correct
3. Test agent behavior unchanged

---

## Pattern Summary

### Existing Patterns (No Changes)

| Pattern | Lines | Status |
|---------|-------|--------|
| `git-workflow.md` | 252 | Keep |
| `context-injection.md` | 340 | Keep |
| `performance.md` | 448 | Keep |
| `state-based-session-management.md` | 700 | Keep |
| `parallel-quality-validation.md` | 354 | Keep |
| `multi-repo.md` | 572 | Keep |
| `input-safety.md` | 256 | Keep |
| `model-selection.md` | 73 | Keep |
| `reflexion.md` | 64 | Keep |
| **Total** | **3,059** | - |

### New Patterns

| Pattern | Est. Lines | Purpose |
|---------|------------|---------|
| `agent-collaboration.md` | ~150 | Visual handoffs, escalation |
| `state-files.md` | ~120 | State file documentation |
| `agent-structure.md` | ~100 | Agent template |
| **Total New** | **~370** | - |

### Agent Line Reduction

| Change | Lines Saved |
|--------|-------------|
| Git Commits simplification | ~144 |
| When to Invoke simplification | ~136 |
| CONTEXT PROTOCOL consolidation | ~22 |
| **Total Saved** | **~302** |

### Net Effect

- **New patterns:** +370 lines
- **Agent reduction:** -302 lines
- **Net:** +68 lines BUT centralized and maintainable

---

## Dependency Order

When implementing protocols and patterns together:

```
1. Create patterns first (protocols may reference them)
   └── agent-structure.md
   └── agent-collaboration.md
   └── state-files.md

2. Create protocol infrastructure
   └── protocols/INDEX.md

3. Extract protocols from agents
   └── (uses agent-structure.md as guide for what remains)

4. Update agents
   └── Reference new patterns
   └── Remove extracted protocols
   └── Follow agent-structure.md template
```

---

## Checklist

### New Patterns
- [ ] Create `agent-collaboration.md` with visual diagrams
- [ ] Create `state-files.md` with schemas
- [ ] Create `agent-structure.md` with mandatory/optional sections

### Agent Updates
- [ ] Architect: Add context-injection ref, simplify Git/Invoke sections
- [ ] Engineer: Simplify Git/Invoke sections
- [ ] Tester: Add context-injection ref, simplify Git/Invoke sections
- [ ] Security Auditor: Add context-injection ref, simplify Git/Invoke sections
- [ ] Code Reviewer: Add context-injection ref, simplify Git/Invoke sections
- [ ] DevOps: Add context-injection ref, simplify Git/Invoke sections
- [ ] Documenter: Add context-injection ref, simplify Git/Invoke sections
- [ ] UI/UX Designer: Simplify Git/Invoke sections
- [ ] Product Manager: Expand to match agent-structure.md

### Validation
- [ ] All agents follow agent-structure.md
- [ ] All pattern references work
- [ ] Agent behavior unchanged

---

*Plan created: 2025-12-08*
*Ready for review and approval*
