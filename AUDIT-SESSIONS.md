# Audit Fix Sessions

Organized approach to resolving framework audit issues.

---

## Session Plan

| Session | Issues | Type | Time Est. | Status |
|---------|--------|------|-----------|--------|
| **Session 1** | SEC-01, SEC-02, GAP-01, BUG-02 | Quick fixes | 15 min | COMPLETE |
| **Session 2** | BUG-01, SEC-03, SEC-04 | Documentation | 30 min | COMPLETE |
| **Session 3** | WST-01, WST-02 | Merge/refactor | 45 min | PENDING |
| **Session 4** | OPT-01, OPT-02 | Optimization | 30 min | PENDING |
| **Session 5** | GAP-02, GAP-03 | New commands | 1 hr | PENDING |
| **Session 6** | GAP-04, GAP-05, GAP-06 | New agents | 1.5 hr | PENDING |
| **Session 7** | Remaining LOW items | Cleanup | 1 hr | PENDING |

---

## Session 1: Quick Fixes (CURRENT)

**Status:** COMPLETE
**Completed:** 2025-12-07
**Commit:** bd87a6e

| Issue | Description | Status |
|-------|-------------|--------|
| SEC-01 | Add .gitignore for state files | [x] DONE |
| SEC-02 | Scope Security Auditor Write/Edit access | [x] DONE |
| GAP-01 | Add Bash to UI/UX Designer | [x] DONE |
| BUG-02 | Fix broken emojis in resume.md | [x] DONE |

**Commit message for this session:**
```
fix(audit): quick security and functionality fixes

- SEC-01: Add .gitignore for sensitive state files
- SEC-02: Remove Write/Edit from Security Auditor (read-only)
- GAP-01: Add Bash tool to UI/UX Designer for a11y tools
- BUG-02: Fix broken emoji characters in resume.md
```

---

## Session 2: Documentation Updates

**Status:** COMPLETE
**Completed:** 2025-12-07

| Issue | Description | Status |
|-------|-------------|--------|
| BUG-01 | Clarify context injection is manual process | [x] DONE |
| SEC-03 | Document $ARGUMENTS validation guidance | [x] DONE |
| SEC-04 | Document Bash path sanitization | [x] DONE |

**Changes Made:**
- Updated `.claude/patterns/context-injection.md` with "IMPORTANT: Manual Process" section
- Created `.claude/patterns/input-safety.md` (comprehensive input validation guidance)
- Updated `.claude/commands/implement.md` with manual injection note
- Updated `CLAUDE.md` Key Files section with security additions
- Documented resolutions in `AUDIT-ISSUES.md`

---

## Session 3: Merge/Refactor

**Status:** COMPLETE
**Completed:** 2025-12-07

| Issue | Description | Status |
|-------|-------------|--------|
| WST-01 | Clarify Security Auditor vs Code Reviewer responsibilities | [x] DONE |
| WST-02 | Merge plan.md and spec.md commands | [x] DONE |

**Changes Made:**
- WST-01: Removed ALL security from Code Reviewer. Security Auditor owns all security checks.
- WST-02: Deleted `spec.md`. `plan.md` is single entry point for feature planning.
- UNN-03: Marked obsolete (no `/project:spec` to overlap with PM agent)

---

## Session 4: Optimization

**Status:** PENDING

| Issue | Description |
|-------|-------------|
| OPT-01 | Add model hints (opus/sonnet/haiku) per task type |
| OPT-02 | Extend parallel execution to more commands |

---

## Session 5: New Commands

**Status:** PENDING

| Issue | Description |
|-------|-------------|
| GAP-02 | Create integration/E2E testing command |
| GAP-03 | Create rollback/recovery workflow |

---

## Session 6: New Agents

**Status:** PENDING

| Issue | Description |
|-------|-------------|
| GAP-04 | Create API Designer agent |
| GAP-05 | Create Database/Migration agent |
| GAP-06 | Create Performance agent |

---

## Session 7: Cleanup

**Status:** PENDING

| Issue | Description |
|-------|-------------|
| SEC-05 | Add reflexion loop cooldown |
| WST-03 | Simplify checkpointing system |
| WST-04 | Clean up unused state files |
| OPT-03 | Cache file tree generation |
| OPT-04 | Implement agent caching |
| UNN-01 | Evaluate Tester + Code Reviewer merge |
| UNN-02 | Clarify DevOps/Engineer boundaries |
| UNN-03 | Clarify Product Manager vs spec command |
| GAP-07 | Document monorepo limitations |
| PRD-01 | Add benchmark regression tracking |
| PRD-02 | Make test scenarios executable |

---

## Resume Prompts

Copy the appropriate prompt when starting a new session.

### Session 2 Resume Prompt

```
I'm continuing the framework audit. We completed Session 1 (quick fixes).

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)
- PARKING-LOT.md (parked ideas)

Session 2 focuses on documentation updates:
- BUG-01: Clarify context injection is manual (not auto-templated)
- SEC-03: Document $ARGUMENTS validation guidance
- SEC-04: Document Bash path sanitization

Let's start with BUG-01.
```

### Session 3 Resume Prompt

```
I'm continuing the framework audit. We completed Sessions 1-2.

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)

Session 3 focuses on merge/refactor work:
- WST-01: Clarify Security Auditor vs Code Reviewer responsibilities
- WST-02: Merge plan.md and spec.md commands

Let's start with WST-01.
```

### Session 4 Resume Prompt

```
I'm continuing the framework audit. We completed Sessions 1-3.

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)

Session 4 focuses on optimization:
- OPT-01: Add model hints (opus/sonnet/haiku per task)
- OPT-02: Extend parallel execution to more commands

Let's start with OPT-01.
```

### Session 5 Resume Prompt

```
I'm continuing the framework audit. We completed Sessions 1-4.

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)

Session 5 focuses on new commands:
- GAP-02: Create integration/E2E testing command
- GAP-03: Create rollback/recovery workflow

Let's start with GAP-02.
```

### Session 6 Resume Prompt

```
I'm continuing the framework audit. We completed Sessions 1-5.

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)

Session 6 focuses on new agents:
- GAP-04: Create API Designer agent
- GAP-05: Create Database/Migration agent
- GAP-06: Create Performance agent

Let's start with GAP-04.
```

### Session 7 Resume Prompt

```
I'm continuing the framework audit. We completed Sessions 1-6.

Please read these files for context:
- AUDIT-ISSUES.md (full issue list)
- AUDIT-SESSIONS.md (session plan)

Session 7 is cleanup of remaining LOW priority items.
Review the Session 7 section in AUDIT-SESSIONS.md for the full list.

Let's start with the first item.
```

---

## Completion Log

| Session | Completed | Duration | Commit |
|---------|-----------|----------|--------|
| Session 1 | 2025-12-07 | ~30 min | bd87a6e |
| Session 2 | 2025-12-07 | ~15 min | a9a8c39 |
| Session 3 | 2025-12-07 | ~15 min | pending |
| Session 4 | - | - | - |
| Session 5 | - | - | - |
| Session 6 | - | - | - |
| Session 7 | - | - | - |
