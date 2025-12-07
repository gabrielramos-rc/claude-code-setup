# Framework Audit - Prioritized Issue List

**Audit Date:** 2025-12-07
**Auditor:** Claude Code (Opus 4.5)
**Framework Version:** v0.3 (Token Optimization)

---

## Summary

| Severity | Count |
|----------|-------|
| HIGH | 5 |
| MEDIUM | 14 |
| LOW | 8 |
| **Total** | **27** |

---

## Prioritized Issues

| Priority | ID | Category | Issue | Severity | Status |
|----------|-----|----------|-------|----------|--------|
| 1 | SEC-01 | Security | State files (`.claude/state/`) committed to git - risk of leaking secrets | HIGH | [x] |
| 2 | SEC-02 | Security | Security Auditor has Write/Edit access - should be scoped | HIGH | [x] |
| 3 | GAP-01 | Gap | UI/UX Designer lacks Bash access for accessibility tools (`axe-core`, `pa11y`) | HIGH | [x] |
| 4 | BUG-01 | Bug | Context injection template variables (`{{REQUIREMENTS_CONTENT}}`) never actually substituted - pattern is manual | HIGH | [ ] |
| 5 | SEC-03 | Security | No input validation/sanitization on `$ARGUMENTS` variable | MEDIUM | [ ] |
| 6 | SEC-04 | Security | Bash commands use unsanitized user-provided paths/patterns | MEDIUM | [ ] |
| 7 | WST-01 | Waste | Duplicate functionality between Security Auditor and Code Reviewer (both check security) | MEDIUM | [ ] |
| 8 | WST-02 | Waste | Redundant commands: `plan.md` and `spec.md` serve nearly identical purposes | MEDIUM | [ ] |
| 9 | OPT-01 | Optimization | Opus model overused - Haiku sufficient for docs/simple tasks | MEDIUM | [ ] |
| 10 | OPT-02 | Optimization | Parallel agent execution underutilized (only `implement.md` and `fix.md`) | MEDIUM | [ ] |
| 11 | GAP-02 | Gap | No integration/E2E testing command | MEDIUM | [ ] |
| 12 | GAP-03 | Gap | No rollback/recovery workflow (`/project:rollback` or `/project:undo`) | MEDIUM | [ ] |
| 13 | GAP-04 | Gap | No API Designer agent for OpenAPI specs, versioning, rate limiting | MEDIUM | [ ] |
| 14 | GAP-05 | Gap | No Database/Migration agent for schema design and migrations | MEDIUM | [ ] |
| 15 | GAP-06 | Gap | No Performance agent for profiling, bundle analysis, load testing | MEDIUM | [ ] |
| 16 | PRD-01 | Production | Benchmark system exists but has no automated regression tracking | MEDIUM | [ ] |
| 17 | PRD-02 | Production | Test scenarios in `beta-v0.2-scenarios.md` are not executable | MEDIUM | [ ] |
| 18 | SEC-05 | Security | No rate limiting/cooldown on reflexion loops | LOW | [ ] |
| 19 | BUG-02 | Bug | Broken emoji characters in `resume.md` (lines 15-16 show `�`) | LOW | [x] |
| 20 | WST-03 | Waste | Over-engineered checkpointing with arbitrary percentages (0%→15%→40%→70%→90%→100%) | LOW | [ ] |
| 21 | WST-04 | Waste | Unused state files created but rarely read: `diagnosis.md`, `fix-notes.md`, `test-quality-review.md`, `git-strategy.md` | LOW | [ ] |
| 22 | OPT-03 | Optimization | File tree regenerated every command even when unchanged | LOW | [ ] |
| 23 | OPT-04 | Optimization | No agent caching - specs re-read even when unchanged | LOW | [ ] |
| 24 | UNN-01 | Unnecessary | Consider merging Tester + Code Reviewer into Quality Agent | LOW | [ ] |
| 25 | UNN-02 | Unnecessary | DevOps and Engineer have overlapping deployment responsibilities | LOW | [ ] |
| 26 | UNN-03 | Unnecessary | Product Manager agent overlaps with `/project:spec` command | LOW | [ ] |
| 27 | GAP-07 | Gap | No monorepo/multi-project support | LOW | [ ] |

---

## Issue Details

### Priority 1: SEC-01 - State Files Git Security Risk

**Severity:** HIGH
**Category:** Security
**Location:** `.claude/state/`

**Problem:**
State files are committed to git by default. If agents accidentally log API keys, database URLs, or tokens in implementation-notes.md, diagnosis.md, or test-results.md, these secrets would be committed to version control.

**Recommendation:**
Add to `.gitignore`:
```
.claude/state/*.log
.claude/state/implementation-notes.md
.claude/state/diagnosis.md
```
Or create `.claude/state/.sensitive/` directory with its own gitignore.

**Resolution (2025-12-07):**
Created `.gitignore` with selective state file exclusions (Option A).
Files ignored: `implementation-notes.md`, `diagnosis.md`, `fix-notes.md`, `test-results.md`, `security-findings.md`, `code-review-findings.md`
Files tracked: `retry-counter.md`, `git-strategy.md`

---

### Priority 2: SEC-02 - Security Auditor Write Access

**Severity:** HIGH
**Category:** Security
**Location:** `.claude/agents/security-auditor.md`

**Problem:**
Security Auditor has `Write` and `Edit` tools. A security auditor with write access to source code violates the principle of least privilege and creates a contradiction in responsibilities.

**Recommendation:**
~~Remove Write/Edit from tools, keep only: `Bash, Read, Grep, Glob`~~

**Resolution (2025-12-07):**
Revised approach - Keep Write+Edit but enforce strict scope.
- Added `Edit` to tools (was missing, needed for efficient updates)
- Added "Write/Edit Tool (SCOPED)" section with explicit restrictions
- Only allowed location: `.claude/state/security-findings.md`
- Clear rationale: auditor reports, engineer fixes

---

### Priority 3: GAP-01 - UI/UX Designer No Bash Access

**Severity:** HIGH
**Category:** Gap
**Location:** `.claude/agents/ui-ux-designer.md`

**Problem:**
UI/UX Designer tools: `Read, Write, Edit, Grep, Glob` - no Bash.
Agent cannot run accessibility audits (`axe-core`, `pa11y`), generate design tokens (`style-dictionary`), or check color contrast tools.

**Recommendation:**
Add `Bash` to tools list.

**Resolution (2025-12-07):**
- Added `Bash` to tools list
- Added "Bash Tool (For Design Validation)" section with scoped usage
- Allowed: accessibility audits, color contrast, design tokens, Lighthouse
- Prohibited: builds, tests, installs, code modification

---

### Priority 4: BUG-01 - Context Injection Is Manual

**Severity:** HIGH
**Category:** Bug
**Location:** `.claude/patterns/context-injection.md`, all commands

**Problem:**
Commands show template variables like `{{REQUIREMENTS_CONTENT}}` but Claude Code has no built-in templating. The pattern documentation implies automatic injection, but execution requires manual read-and-paste steps.

**Recommendation:**
Either:
1. Update documentation to clarify manual process
2. Create a shell script/pre-processor that generates injection blocks
3. Document exact steps Claude must follow

---

### Priority 5: SEC-03 - No $ARGUMENTS Validation

**Severity:** MEDIUM
**Category:** Security
**Location:** All command files

**Problem:**
Commands use `$ARGUMENTS` directly without validation:
```markdown
Debug the issue: **$ARGUMENTS**
git commit -m "fix: resolve {issue from $ARGUMENTS}"
```
Malicious input could inject shell commands or break markdown parsing.

**Recommendation:**
Document safe usage patterns and add input sanitization guidance.

---

### Priority 6: SEC-04 - Unsanitized Bash Paths

**Severity:** MEDIUM
**Category:** Security
**Location:** Various commands

**Problem:**
Commands run Bash with user-provided context without escaping:
```bash
tree -L 3 -I '$USER_PROVIDED_PATTERN'
```

**Recommendation:**
Add guidance on escaping user input in Bash commands.

---

### Priority 7: WST-01 - Security Auditor vs Code Reviewer Overlap

**Severity:** MEDIUM
**Category:** Waste
**Location:** `.claude/agents/security-auditor.md`, `.claude/agents/code-reviewer.md`

**Problem:**
Both agents check security, input validation, and hardcoded secrets. Unclear who is responsible for what.

**Recommendation:**
Clearly delineate:
- Code Reviewer = code quality only (patterns, readability, DRY)
- Security Auditor = security only (OWASP, CVE, dependency audit)

---

### Priority 8: WST-02 - Redundant plan.md and spec.md

**Severity:** MEDIUM
**Category:** Waste
**Location:** `.claude/commands/plan.md`, `.claude/commands/spec.md`

**Problem:**
Both commands gather requirements and create specifications:
- `plan.md` → Creates `.claude/plans/[feature].md`
- `spec.md` → Creates `.claude/specs/[feature]-spec.md`

**Recommendation:**
Merge into single `spec.md` command outputting to `.claude/specs/`.

---

### Priority 9: OPT-01 - Opus Model Overused

**Severity:** MEDIUM
**Category:** Optimization
**Location:** Multiple agents

**Problem:**
Product Manager, Architect, UI/UX Designer all use `model: opus`. Opus is expensive for simpler tasks.

**Recommendation:**
Add model hints per task type:
- Complex reasoning → opus
- Code generation → sonnet
- Simple formatting → haiku

---

### Priority 10: OPT-02 - Parallel Execution Underutilized

**Severity:** MEDIUM
**Category:** Optimization
**Location:** Various commands

**Problem:**
Only `implement.md` and `fix.md` use parallel validation.

**Recommendation:**
Also parallelize in:
- `start.md`: Product Manager + Architect partially parallel
- `plan.md`: Requirements + initial design exploration

---

### Priority 11: GAP-02 - No Integration Testing Command

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/commands/`

**Problem:**
`test.md` focuses on unit tests. Missing E2E test orchestration, API integration tests, visual regression testing.

**Recommendation:**
Create `/project:test-e2e` or extend `test.md` with scope parameter.

---

### Priority 12: GAP-03 - No Rollback Workflow

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/commands/`

**Problem:**
Commands handle forward progress but no recovery:
- No `/project:rollback`
- No `/project:undo`
- Git-based recovery is manual

**Recommendation:**
Create rollback command using git revert/reset.

---

### Priority 13: GAP-04 - No API Designer Agent

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/agents/`

**Problem:**
For API-first development, no dedicated tooling for:
- OpenAPI/Swagger spec generation
- API versioning strategy
- Rate limiting design
- GraphQL schema design

Currently buried in Architect's responsibilities.

**Recommendation:**
Create dedicated API Designer agent or extend Architect.

---

### Priority 14: GAP-05 - No Database/Migration Agent

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/agents/`

**Problem:**
Complex projects need:
- Database schema design
- Migration file generation
- Schema validation

Architect mentions "data model" but no dedicated tooling.

**Recommendation:**
Create Database Architect agent or extend Architect with database section.

---

### Priority 15: GAP-06 - No Performance Agent

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/agents/`

**Problem:**
No agent handles:
- Performance profiling
- Bundle size analysis
- Load testing
- Lighthouse audits
- Database query optimization

**Recommendation:**
Create Performance Engineer agent.

---

### Priority 16: PRD-01 - No Benchmark Regression Tracking

**Severity:** MEDIUM
**Category:** Production
**Location:** `.claude/benchmark/`

**Problem:**
Benchmark templates exist but no automated comparison against actual runs. Measurement capability exists but no regression tracking.

**Recommendation:**
Add benchmark result storage and comparison tooling.

---

### Priority 17: PRD-02 - Test Scenarios Not Executable

**Severity:** MEDIUM
**Category:** Production
**Location:** `.claude/tests/beta-v0.2-scenarios.md`

**Problem:**
13 behavioral test scenarios exist as documentation, not executable tests. Framework itself is untested.

**Recommendation:**
Create test runner or convert to executable format.

---

### Priority 18: SEC-05 - No Reflexion Loop Cooldown

**Severity:** LOW
**Category:** Security
**Location:** `.claude/patterns/reflexion.md`

**Problem:**
Global retry limit is 5, but no cooldown between attempts. Could exhaust tokens rapidly.

**Recommendation:**
Consider adding delay or token budget check between retries.

---

### Priority 19: BUG-02 - Broken Emojis in resume.md

**Severity:** LOW
**Category:** Bug
**Location:** `.claude/commands/resume.md` (lines 15-16)

**Problem:**
```markdown
- `IDLE` � No task in progress
- `IN_PROGRESS` � Task was interrupted
```
Characters render as `�` instead of proper emojis.

**Recommendation:**
Replace with proper UTF-8 emojis or ASCII alternatives.

---

### Priority 20: WST-03 - Over-Engineered Checkpointing

**Severity:** LOW
**Category:** Waste
**Location:** `implement.md`, `fix.md`

**Problem:**
6 checkpoint updates with arbitrary percentages:
```
0% → 15% → 40% → 70% → 90% → 100%
```
Creates overhead and percentages don't reflect actual work.

**Recommendation:**
Simplify to 3 states: STARTED → IN_PROGRESS → COMPLETED

---

### Priority 21: WST-04 - Unused State Files

**Severity:** LOW
**Category:** Waste
**Location:** Various commands

**Problem:**
State files created but rarely read by other commands:
- `diagnosis.md` - Only used by `fix.md`
- `fix-notes.md` - Only used by `fix.md`
- `test-quality-review.md` - Created but never read
- `git-strategy.md` - DevOps creates but no command reads it

**Recommendation:**
Either integrate into workflows or remove.

---

### Priority 22: OPT-03 - File Tree Regenerated Every Command

**Severity:** LOW
**Category:** Optimization
**Location:** Context injection pattern

**Problem:**
Every command runs:
```bash
tree -L 3 -I 'node_modules|...'
```
Even when structure hasn't changed.

**Recommendation:**
Cache file tree with timestamp, regenerate only if files changed.

---

### Priority 23: OPT-04 - No Agent Caching

**Severity:** LOW
**Category:** Optimization
**Location:** All agents

**Problem:**
Each agent invocation is stateless. If Architect runs twice, it re-reads everything.

**Recommendation:**
Implement spec fingerprinting - skip re-analysis if specs unchanged.

---

### Priority 24: UNN-01 - Consider Merging Tester + Code Reviewer

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/`

**Problem:**
Both validate implementation quality. Could be combined into "Quality Agent".

**Recommendation:**
Evaluate if consolidation reduces coordination overhead.

---

### Priority 25: UNN-02 - DevOps/Engineer Overlap

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/devops.md`, `.claude/agents/engineer.md`

**Problem:**
DevOps creates Dockerfile, CI/CD configs. Engineer often updates build configs, fixes deployment. Boundary violations happen.

**Recommendation:**
Clarify boundaries or merge deployment responsibilities.

---

### Priority 26: UNN-03 - Product Manager vs Spec Command Overlap

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/product-manager.md`, `.claude/commands/spec.md`

**Problem:**
Both create requirements and specifications.

**Recommendation:**
Clarify when to use agent vs command.

---

### Priority 27: GAP-07 - No Monorepo Support

**Severity:** LOW
**Category:** Gap
**Location:** Framework-wide

**Problem:**
Framework assumes single-project structure. No support for:
- Shared components across packages
- Workspace coordination
- Cross-package dependencies

**Recommendation:**
Add monorepo patterns in future version.

---

## Prioritization Logic

1. **Security first** - Anything that could leak secrets or allow injection
2. **Broken functionality** - Agents that can't do their job
3. **Misleading documentation** - Promises that aren't delivered
4. **Cost/efficiency** - Direct savings (money, time)
5. **Missing capabilities** - Gaps that block use cases
6. **Polish/cleanup** - Nice to have improvements

---

## Quick Wins (< 30 minutes each)

| Priority | ID | Time Estimate |
|----------|-----|---------------|
| 1 | SEC-01 | 2 min |
| 2 | SEC-02 | 5 min |
| 3 | GAP-01 | 2 min |
| 19 | BUG-02 | 5 min |

---

## Notes

- Mark issues as `[x]` when resolved
- Add resolution notes below each issue
- Update this file as new issues are discovered
