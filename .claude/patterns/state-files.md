# State Files Pattern

> Documentation for `.claude/state/` files: schemas, ownership, and conventions

---

## Overview

State files enable asynchronous communication between agents. Each agent writes to designated state files; other agents read these files to understand context and make decisions.

**Location:** `.claude/state/`

**Principle:** Write-once ownership. Only the designated owner writes to a state file.

---

## State File Registry

| File | Owner | Purpose | Readers |
|------|-------|---------|---------|
| `current-task.md` | Commands | Track workflow progress and checkpoints | All agents, `/project:resume` |
| `implementation-notes.md` | Engineer | Document what was built and how | Tester, Security, Reviewer, Documenter |
| `test-results.md` | Tester | Test execution outcomes and failures | Engineer, DevOps |
| `security-findings.md` | Security Auditor | Vulnerability reports by severity | Engineer |
| `code-review-findings.md` | Code Reviewer | Review feedback and recommendations | Engineer |
| `retry-counter.md` | Commands | Bounded reflexion tracking | Commands |
| `workflow-log.md` | All agents | Protocol loading decisions (append-only) | Debugging |

---

## File Schemas

### current-task.md

Tracks workflow progress for resume capability.

```markdown
## Current Task

**Command:** /project:{command} {arguments}
**Status:** IDLE | IN_PROGRESS | COMPLETED | FAILED
**Progress:** Step X/Y - {checkpoint name}
**Started:** {ISO timestamp}
**Updated:** {ISO timestamp}

## Workflow Steps

1. [x] Load context ✓ (completed 14:00)
2. [x] Engineer: Implement ✓ (completed 14:30)
3. [ ] Validation ← CURRENT
4. [ ] Documentation
5. [ ] Human gate

## Last Checkpoint

**Completed:** {description of what was done}
**Next Step:** {description of what to do next}
**Files Modified:** {comma-separated list}

## Context References

- `specs/architecture.md` - Architecture decisions
- `specs/requirements.md` - Feature requirements
```

**Status values:**
- `IDLE` - No active task
- `IN_PROGRESS` - Task running
- `COMPLETED` - Task finished successfully
- `FAILED` - Task failed (see Last Checkpoint for details)

---

### implementation-notes.md

Documents what Engineer built for downstream agents.

```markdown
## Implementation: {Feature Name}

**Date:** {YYYY-MM-DD}
**Engineer:** Claude
**Phase:** {phase number if applicable}

### Summary

{2-3 sentence summary of what was implemented}

### Files Created

| File | Purpose |
|------|---------|
| `src/path/file.ts` | {description} |
| `src/path/file.ts` | {description} |

### Files Modified

| File | Changes |
|------|---------|
| `src/path/file.ts` | {what changed} |

### Dependencies Added

| Package | Version | Purpose |
|---------|---------|---------|
| `package-name` | `^1.0.0` | {why needed} |

### Architecture Decisions

- {decision 1 and rationale}
- {decision 2 and rationale}

### Test Focus Areas

Areas requiring testing attention:
- {area 1}
- {area 2}

### Known Limitations

- {limitation 1}
- {limitation 2}

### Security Considerations

- {consideration 1}
- {consideration 2}
```

---

### test-results.md

Reports test execution outcomes.

```markdown
## Test Results: {Feature/Date}

**Status:** PASS | FAIL | PARTIAL
**Run Date:** {ISO timestamp}
**Coverage:** {percentage}%

### Summary

| Type | Passed | Failed | Skipped | Total |
|------|--------|--------|---------|-------|
| Unit | X | Y | Z | N |
| Integration | X | Y | Z | N |
| E2E | X | Y | Z | N |
| **Total** | X | Y | Z | N |

### Failures

#### {Test Name}

- **File:** `tests/path/file.test.ts:42`
- **Type:** Unit | Integration | E2E
- **Error:**
  ```
  {error message}
  ```
- **Expected:** {expected behavior}
- **Actual:** {actual behavior}
- **Fix Suggestion:** {how to fix}

### Coverage Gaps

| Area | Current | Target | Gap |
|------|---------|--------|-----|
| `src/path/` | 45% | 80% | -35% |

### Recommendations

- {recommendation 1}
- {recommendation 2}
```

**Status values:**
- `PASS` - All tests passed, coverage meets threshold
- `FAIL` - One or more tests failed
- `PARTIAL` - Tests passed but coverage below threshold

---

### security-findings.md

Reports security vulnerabilities by severity.

```markdown
## Security Audit: {Feature/Date}

**Status:** PASS | FAIL
**Auditor:** Security Auditor Agent
**Date:** {ISO timestamp}

### Summary

| Severity | Count | Blocking |
|----------|-------|----------|
| CRITICAL | 0 | Yes |
| HIGH | 0 | Yes |
| MEDIUM | 0 | No |
| LOW | 0 | No |

### Findings

#### [CRITICAL] {Title}

- **ID:** SEC-001
- **Location:** `src/path/file.ts:42`
- **Category:** {OWASP category, e.g., A01:2021-Broken Access Control}
- **Issue:** {description of vulnerability}
- **Risk:** {impact if exploited}
- **Remediation:** {specific steps to fix}
- **References:** {CVE, CWE, or documentation links}

#### [HIGH] {Title}

- **ID:** SEC-002
- **Location:** `src/path/file.ts:87`
- **Category:** {OWASP category}
- **Issue:** {description}
- **Risk:** {impact}
- **Remediation:** {fix steps}

#### [MEDIUM] {Title}
...

#### [LOW] {Title}
...

### Dependency Audit

| Package | Current | Severity | Advisory |
|---------|---------|----------|----------|
| `pkg` | `1.0.0` | HIGH | {link} |

### Positive Notes

- {what was done well}
- {good security practices observed}
```

**Blocking rules:**
- CRITICAL or HIGH → Blocks merge/deployment
- MEDIUM or LOW → Logged for backlog

---

### code-review-findings.md

Reports code quality review feedback.

```markdown
## Code Review: {Feature/Date}

**Status:** APPROVED | CHANGES_REQUESTED | BLOCKED
**Reviewer:** Code Reviewer Agent
**Date:** {ISO timestamp}

### Summary

| Severity | Count |
|----------|-------|
| BLOCKING | 0 |
| MAJOR | 0 |
| MINOR | 0 |
| NIT | 0 |

### Findings

#### [BLOCKING] {Title}

- **ID:** REV-001
- **Location:** `src/path/file.ts:42-50`
- **Category:** Architecture | Performance | Correctness | Style
- **Issue:** {description}
- **Suggestion:** {recommended change}
- **Rationale:** {why this matters}

#### [MAJOR] {Title}

- **ID:** REV-002
- **Location:** `src/path/file.ts:87`
- **Category:** {category}
- **Issue:** {description}
- **Suggestion:** {recommendation}

#### [MINOR] {Title}
...

#### [NIT] {Title}
...

### Architecture Compliance

- [x] Follows established patterns
- [x] Respects module boundaries
- [ ] {issue if any}

### Positive Notes

- {what was done well}
- {good patterns observed}

### Overall Assessment

{1-2 sentence summary of code quality}
```

**Status values:**
- `APPROVED` - No blocking issues, ready to merge
- `CHANGES_REQUESTED` - Has MAJOR issues requiring fixes
- `BLOCKED` - Has BLOCKING issues, cannot proceed

---

### retry-counter.md

Tracks bounded reflexion attempts.

```markdown
## Retry Counter

**Workflow:** /project:{command} {arguments}
**Started:** {ISO timestamp}

### Retry Log

| Attempt | Agent | Reason | Timestamp |
|---------|-------|--------|-----------|
| 1 | Engineer | Test failures | 14:30 |
| 2 | Engineer | Security findings | 14:45 |
| 3 | Engineer | Review feedback | 15:00 |

### Limits

- **Per-step max:** 3
- **Workflow max:** 5
- **Current total:** 3

### Status

WITHIN_LIMITS | LIMIT_REACHED

### If Limit Reached

Escalate to human with:
- Summary of all attempts
- Remaining issues
- Recommendation
```

---

### workflow-log.md

Append-only log for debugging protocol selection.

```markdown
## Workflow Log: {Date}

### {Timestamp} - {Agent}

**Task:** {task description}
**Protocols Loaded:**
- `{protocol}.md` - {reason for loading}
- `{protocol}.md` - {reason for loading}

**Protocols Skipped:**
- `{protocol}.md` - {reason for skipping}

---

### {Timestamp} - {Agent}

**Task:** {task description}
**Protocols Loaded:**
- `{protocol}.md` - {reason}

---
```

**Usage:** Append new entries, never overwrite previous entries.

---

## Read/Write Rules

### 1. Single Owner

Only the designated owner writes to their state file. Other agents read only.

```
✅ Engineer writes implementation-notes.md
✅ Tester reads implementation-notes.md
❌ Tester writes implementation-notes.md
```

### 2. Replace on New Workflow

Most state files are replaced when a new workflow starts:
- `current-task.md` - Replaced
- `implementation-notes.md` - Replaced
- `test-results.md` - Replaced
- `security-findings.md` - Replaced
- `code-review-findings.md` - Replaced
- `retry-counter.md` - Replaced

**Exception:** `workflow-log.md` is append-only (preserves history).

### 3. Status First

Put status/summary at the top of every state file for quick scanning.

### 4. Timestamps

Include ISO timestamps for traceability.

### 5. Structured Format

Use consistent markdown structure with headers, tables, and code blocks.

---

## State File Lifecycle

```
Workflow Start
     │
     ├──▶ current-task.md created (IN_PROGRESS)
     │
     ▼
Planning Phase
     │
     ├──▶ workflow-log.md appended (protocol decisions)
     │
     ▼
Implementation Phase
     │
     ├──▶ implementation-notes.md created
     │
     ▼
Validation Phase (parallel)
     │
     ├──▶ test-results.md created
     ├──▶ security-findings.md created
     ├──▶ code-review-findings.md created
     │
     ▼
Fix Iterations (if needed)
     │
     ├──▶ retry-counter.md updated
     ├──▶ State files updated with new results
     │
     ▼
Workflow Complete
     │
     └──▶ current-task.md updated (COMPLETED)
```

---

*Pattern created: 2025-12-08*
*Version: 1.0*
