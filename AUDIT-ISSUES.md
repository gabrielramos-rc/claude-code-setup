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
| 4 | BUG-01 | Bug | Context injection template variables (`{{REQUIREMENTS_CONTENT}}`) never actually substituted - pattern is manual | HIGH | [x] |
| 5 | SEC-03 | Security | No input validation/sanitization on `$ARGUMENTS` variable | MEDIUM | [x] |
| 6 | SEC-04 | Security | Bash commands use unsanitized user-provided paths/patterns | MEDIUM | [x] |
| 7 | WST-01 | Waste | Duplicate functionality between Security Auditor and Code Reviewer (both check security) | MEDIUM | [x] |
| 8 | WST-02 | Waste | Redundant commands: `plan.md` and `spec.md` serve nearly identical purposes | MEDIUM | [x] |
| 9 | OPT-01 | Optimization | Opus model overused - Haiku sufficient for docs/simple tasks | MEDIUM | [x] |
| 10 | OPT-02 | Optimization | Parallel agent execution underutilized (only `implement.md` and `fix.md`) | MEDIUM | [x] Won't Fix |
| 11 | GAP-02 | Gap | No integration/E2E testing command | MEDIUM | [x] |
| 12 | GAP-03 | Gap | No rollback/recovery workflow (`/project:rollback` or `/project:undo`) | MEDIUM | [x] |
| 13 | GAP-04 | Gap | No API Designer agent for OpenAPI specs, versioning, rate limiting | MEDIUM | [x] |
| 14 | GAP-05 | Gap | No Database/Migration agent for schema design and migrations | MEDIUM | [x] |
| 15 | GAP-06 | Gap | No Performance agent for profiling, bundle analysis, load testing | MEDIUM | [x] |
| 16 | PRD-01 | Production | Benchmark system exists but has no automated regression tracking | MEDIUM | [x] |
| 17 | PRD-02 | Production | Test scenarios in `beta-v0.2-scenarios.md` are not executable | MEDIUM | [x] |
| 18 | SEC-05 | Security | No rate limiting/cooldown on reflexion loops | LOW | [x] Won't Fix |
| 19 | BUG-02 | Bug | Broken emoji characters in `resume.md` (lines 15-16 show `�`) | LOW | [x] |
| 20 | WST-03 | Waste | Over-engineered checkpointing with arbitrary percentages (0%→15%→40%→70%→90%→100%) | LOW | [x] |
| 21 | WST-04 | Waste | Unused state files created but rarely read: `diagnosis.md`, `fix-notes.md`, `test-quality-review.md`, `git-strategy.md` | LOW | [x] |
| 22 | OPT-03 | Optimization | File tree regenerated every command even when unchanged | LOW | [x] |
| 23 | OPT-04 | Optimization | No agent caching - specs re-read even when unchanged | LOW | [x] |
| 24 | UNN-01 | Unnecessary | Consider merging Tester + Code Reviewer into Quality Agent | LOW | [x] Won't Fix |
| 25 | UNN-02 | Unnecessary | DevOps and Engineer have overlapping deployment responsibilities | LOW | [x] Won't Fix |
| 26 | UNN-03 | Unnecessary | Product Manager agent overlaps with `/project:spec` command | LOW | [x] |
| 27 | GAP-07 | Gap | No monorepo/multi-project support | LOW | [x] Documented |

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

**Resolution (2025-12-07):**
Updated documentation to clarify manual process (Option 1):
- Added "IMPORTANT: Manual Process" section to `.claude/patterns/context-injection.md`
- Explains placeholders are conventions, NOT auto-substitution
- Added example workflow showing read → store → replace steps
- Added anti-patterns: "Don't assume placeholders auto-substitute"
- Updated `implement.md` with explicit manual injection note in Step 0

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

**Resolution (2025-12-07):**
Created `.claude/patterns/input-safety.md` with comprehensive guidance:
- Documented risks: shell injection, markdown injection, git message corruption
- Safe usage patterns by context (display, Bash, git, file paths)
- Summary table for quick reference
- HEREDOC pattern for safe git commits
- Checklist for command authors

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

**Resolution (2025-12-07):**
Added Bash path sanitization section to `.claude/patterns/input-safety.md`:
- Documented unsafe patterns (unquoted paths, glob injection, path traversal)
- Safe patterns: always quote paths, validate before use, use `--` separator
- Recommended patterns table by command type (tree, find, grep, cat, rm)
- Special case guidance for tree ignore patterns
- Checklist item for command authors

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

**Resolution (2025-12-07):**
Removed ALL security responsibilities from Code Reviewer:
- Removed "Security (Basic Check)" checklist section
- Removed security from description and intro
- Removed "invoke Security Auditor" escalation path
- Removed "Security vulnerabilities" from CRITICAL severity items
- Removed security check from output format

Code Reviewer now focuses ONLY on: quality, architecture compliance, performance, maintainability.
Security Auditor owns ALL security checks - zero overlap.

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

**Resolution (2025-12-07):**
Deleted `spec.md` command. `plan.md` is the single entry point for feature planning:
- Invokes Product Manager (requirements, user stories)
- Invokes Architect (technical design)
- Creates task breakdown with estimates
- Outputs to `.claude/plans/[feature].md`

Updated references in: TEMPLATE-CLAUDE.md, route.md, resume.md, current-task.md, state-based-session-management.md
UNN-03 is now obsolete (no `/project:spec` to overlap with).

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

**Resolution (2025-12-07):**
Updated agent default models:
- Product Manager: opus → sonnet (structured output, not complex reasoning)
- UI/UX Designer: opus → sonnet (pattern-based design specs)
- Documenter: sonnet → haiku (simple formatting tasks)
- Architect: kept opus (needs complex reasoning)

Created `.claude/patterns/model-selection.md` with:
- Default model table by agent
- Override criteria (when to use opus/sonnet/haiku)
- Decision flowchart
- Cost-benefit summary

Updated commands to reference model selection guide:
- `implement.md`, `fix.md`, `test.md`, `start.md`, `plan.md`

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

**Resolution (2025-12-07): Won't Fix**

Analysis revealed that suggested parallelization violates data dependencies:

- `start.md`: Documenter needs Engineer's output (project structure, dependencies) before writing docs. Running in parallel would document a non-existent project.
- `plan.md`: Architect needs Product Manager's requirements before designing. Sequential by nature.

The existing parallel validation in `implement.md` and `fix.md` works because Tester, Security, and Code Reviewer are independent consumers of the same completed implementation.

**Conclusion:** Current parallelization is appropriate. No changes needed.

---

### Priority 11: GAP-02 - No Integration Testing Command

**Severity:** MEDIUM
**Category:** Gap
**Location:** `.claude/commands/`

**Problem:**
`test.md` focuses on unit tests. Missing E2E test orchestration, API integration tests, visual regression testing.

**Recommendation:**
Create `/project:test-e2e` or extend `test.md` with scope parameter.

**Resolution (2025-12-07):**
Extended `test.md` with parameterized scope (cleaner than separate command):

**Usage:**
```
/project:test                     # Run all tests
/project:test unit auth           # Unit tests for auth module
/project:test integration api     # Integration tests for API
/project:test e2e checkout        # E2E tests for checkout flow
/project:test coverage            # Full suite with coverage report
```

**Changes:**
- Updated `test.md` with usage examples and scope parameter documentation
- Added "Scope-Aware Testing Protocol" to Tester agent (120+ lines):
  - Scope parsing logic (unit/integration/e2e/coverage/all)
  - Project tooling detection (Vitest, Jest, Playwright, Cypress, pytest)
  - Scope-specific commands and behavior
  - E2E pre-flight checks (fail immediately if server not running)
  - E2E artifact handling (screenshots, traces, videos)
  - Flaky test handling (max 2 retries)

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

**Resolution (2025-12-07):**
Created `/project:rollback` command with comprehensive safety features:

**Usage:**
```
/project:rollback                 # Revert last commit (safe)
/project:rollback 3               # Revert last 3 commits
/project:rollback abc123          # Revert specific commit
/project:rollback --hard          # Reset last commit (destructive)
/project:rollback --hard 3        # Reset last 3 commits
```

**Features:**
- **Default: revert** - Safe mode, creates undo commits, preserves history
- **Optional: reset** - Destructive mode with `--hard` flag, removes commits
- **Safety checks:** Uncommitted changes, pushed commits, merge commits, large rollbacks
- **Backup branch:** Always created before any rollback operation
- **Preview:** Shows exactly what will be undone before confirmation
- **Strong warnings:** Extra confirmation required for destructive operations

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

**Resolution (2025-12-07):**
Extended Architect agent with comprehensive "API Design Protocol" section (~400 lines):

**Decision:** Enhance Architect rather than create new agent because:
- API design IS architecture (system boundaries)
- Avoids agent proliferation and coordination overhead
- Keeps related concerns together

**Changes to Architect agent:**
1. **New file outputs:**
   - `openapi.yaml` (project root) - REST API specs
   - `schema.graphql` (project root) - GraphQL schemas
   - `asyncapi.yaml` (project root) - WebSocket/event specs

2. **API Design Protocol section covering:**
   - REST API design (versioning, resources, pagination, errors, rate limiting)
   - GraphQL design (schema-first, Relay pagination, error handling)
   - Real-time APIs (WebSocket vs SSE vs polling, event patterns)
   - OpenAPI 3.x template with full example
   - GraphQL schema template with Relay patterns
   - AsyncAPI template for event-driven APIs

3. **Validation tooling added to Bash:**
   - `npx @redocly/cli lint openapi.yaml`
   - `npx spectral lint openapi.yaml`
   - `npx graphql-inspector validate schema.graphql`
   - `npx @asyncapi/cli validate asyncapi.yaml`

4. **Output format updated** with API-specific deliverables

**Key clarification made:**
- `.claude/specs/` = Agent memory (design decisions)
- Project root = Machine-readable deliverables (openapi.yaml, schema.graphql)

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

**Resolution (2025-12-07):**
Implemented hybrid approach: Architect designs, Engineer implements.

**Decision:** No new agent. Database work follows existing Architect→Engineer flow:
- Data model design is an architectural decision
- Schema/migration implementation is engineering work
- Keeps agent count stable, reduces coordination overhead

**Changes to Architect agent (~160 lines):**
- Added "Data Model Design" section
- Database technology selection guide (SQL, Document, Key-Value, Graph, Time-Series, Vector)
- Entity-Relationship design patterns
- Index and constraint design
- Output: `.claude/specs/data-model.md`
- Checklist for handoff to Engineer

**Changes to Engineer agent (~220 lines):**

1. **Database Implementation Protocol:**
   - ORM/tool detection table (Prisma, Drizzle, TypeORM, Knex, Sequelize, Django, SQLAlchemy, raw SQL)
   - Prisma implementation patterns with schema examples
   - Drizzle implementation patterns with schema examples
   - Raw SQL migration patterns
   - Migration best practices (naming, safe migrations, data migrations)
   - Validation commands
   - Implementation checklist

2. **Data Engineering Protocol (for complex cases):**
   - ETL/ELT pipeline patterns
   - Scheduled job patterns (cron)
   - Query optimization (cursor pagination, keyset pagination)
   - Bulk operations (batch updates, upserts)
   - Data validation with Zod
   - Data engineering commands (backup, restore, analyze)
   - Data engineering checklist

**Workflow:**
1. Architect designs data model → `.claude/specs/data-model.md`
2. Engineer implements schema using appropriate ORM
3. Engineer creates migrations
4. Engineer implements data pipelines (if needed)

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

**Resolution (2025-12-07):**
Implemented distributed approach: performance as cross-cutting concern across multiple agents.

**Decision:** No new Performance agent. Instead:
- Performance is everyone's responsibility
- Each agent gets role-specific performance guidance
- Central pattern file as single source of truth

**Created: `.claude/patterns/performance.md` (~350 lines)**
Comprehensive reference covering:
- Performance requirements (Architect focus)
- Code optimization (Engineer focus)
- Load testing (Tester focus)
- Frontend performance / Core Web Vitals (UI/UX focus)
- CI performance budgets (DevOps focus)
- Performance code review (Code Reviewer focus)
- Commands reference

**Distributed sections added to agents:**

| Agent | Section Added | Lines |
|-------|---------------|-------|
| Architect | Performance Design | ~60 |
| Engineer | Performance Implementation | ~70 |
| Tester | Performance Testing | ~90 |
| DevOps | Performance CI/CD | ~80 |
| Code Reviewer | Performance Review | ~60 |

**UI/UX Designer:** Already had Lighthouse via GAP-01 Bash addition.

**Pattern:** Distributed + Central Reference
- Each agent has focused, role-specific section
- All reference `.claude/patterns/performance.md` for deep dives
- Single source of truth prevents fragmentation

**Benefits:**
- Performance "baked in" to every role
- No coordination overhead
- Context-appropriate guidance
- Mirrors real-world teams

---

### Priority 16: PRD-01 - No Benchmark Regression Tracking

**Severity:** MEDIUM
**Category:** Production
**Location:** `.claude/benchmark/`

**Problem:**
Benchmark templates exist but no automated comparison against actual runs. Measurement capability exists but no regression tracking.

**Recommendation:**
Add benchmark result storage and comparison tooling.

**Resolution (2025-12-07): Simple Results Storage**

Added manual benchmark tracking system:

**New files:**
- `.claude/benchmark/results/TEMPLATE.md` - Results report template
- `.claude/benchmark/baseline-v0.3.md` - Baseline metrics for v0.3
- `.claude/benchmark/results/` - Directory for storing run results

**Workflow:**
1. Copy TEMPLATE.md to `results/YYYY-MM-DD.md`
2. Run scenarios manually, record metrics
3. Compare against baseline
4. Note regressions

**Metrics tracked:**
- Time per scenario
- Success rate
- Agent invocations
- Retries

**Regression thresholds:**
- Warning: >25% time increase or <90% success
- Failure: >50% time increase or <80% success

Automated collection deferred - Claude Code doesn't expose usage metrics yet.

---

### Priority 17: PRD-02 - Test Scenarios Not Executable

**Severity:** MEDIUM
**Category:** Production
**Location:** `.claude/tests/beta-v0.2-scenarios.md`

**Problem:**
13 behavioral test scenarios exist as documentation, not executable tests. Framework itself is untested.

**Recommendation:**
Create test runner or convert to executable format.

**Resolution (2025-12-07): Converted to Manual QA Checklist**

Created `.claude/tests/framework-test-checklist.md` - structured checklist for manual testing.

**Why manual (not automated):**
- Tests validate LLM behavior, not code
- Outputs are non-deterministic
- Human judgment required (e.g., "did it explain correctly?")

**Checklist features:**
- 13 tests organized by category (Routing, Reflexion, Gatekeeping, Artifact Priority, Regression)
- Pass/Fail checkboxes with date recording
- Detailed criteria per test
- Summary results table
- Failure log for debugging
- Release criteria (13/13 to pass)

**Categories:**
1. Task Routing (3 tests)
2. Reflexion Loop (3 tests)
3. Human Gatekeeping (1 test)
4. Artifact Priority (3 tests)
5. Regression Tests (3 tests)

Original `beta-v0.2-scenarios.md` preserved for reference.

---

### Priority 18: SEC-05 - No Reflexion Loop Cooldown

**Severity:** LOW
**Category:** Security
**Location:** `.claude/patterns/reflexion.md`

**Problem:**
Global retry limit is 5, but no cooldown between attempts. Could exhaust tokens rapidly.

**Recommendation:**
Consider adding delay or token budget check between retries.

**Resolution (2025-12-07): Won't Fix**

Analysis revealed:
- Time-based delays don't apply to LLM workflows (if tests fail, waiting doesn't help)
- The 3 per-command + 5 global retry limits ARE the rate limiting mechanism
- Claude Code doesn't expose token counts to commands (can't implement budget checks)
- This is a cost concern, not a security vulnerability (mislabeled)

The bounded retry limits are sufficient protection.

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

**Resolution (2025-12-07):**

Replaced arbitrary percentages with step-based progress format:

**New format:**
```markdown
**Progress:** Step 2/5 - Engineer Complete
**Next:** Validation
```

This provides:
- Clear position (2/5)
- Meaningful checkpoint name (what completed)
- Explicit next step (no ambiguity on resume)

**Files updated:**
- `implement.md` - 5 steps (Step 0/5 → Step 5/5)
- `fix.md` - 4 steps (Step 0/4 → Step 4/4)
- `current-task.md` - Template updated with **Next:** field
- `state-based-session-management.md` - Key sections updated
- `resume.md` - Progress display updated

**Rationale:** Full simplification to 3 states would break resume accuracy. Step-based format keeps all checkpoints but removes arbitrary percentages.

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

**Resolution (2025-12-07):**

Analysis revealed `diagnosis.md` and `fix-notes.md` ARE actually used (read by fix.md output and other agents). Only 2 files were truly unused:

**git-strategy.md → Pattern file:**
- Created `.claude/patterns/git-workflow.md` - centralized git conventions
- Updated DevOps agent to reference pattern instead of creating state file
- All agents can now reference the pattern when committing
- Covers: branching strategy, commit conventions, PR requirements, safety rules

**test-quality-review.md → Merged into test-results.md:**
- Added "Quality Assessment" section to test-results.md template
- Updated test.md Code Reviewer step to update test-results.md instead
- Single file for all test output (results + quality review)

**Files updated:**
- Created: `.claude/patterns/git-workflow.md` (new pattern file)
- Modified: `.claude/agents/devops.md` (reference pattern, not create state file)
- Modified: `.claude/commands/test.md` (merge quality review into results)

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

**Resolution (2025-12-07):**

Analysis revealed caching isn't the right optimization. The real issue is **token waste from injecting tree into agents that don't need it**.

**Token cost analysis:**
- Tree output: ~2000 tokens per injection
- Injected into 5 agents in implement.md: ~10,000 tokens total
- But only 2 agents (Engineer, Tester) actually use the tree

**Solution: Selective injection (not caching)**

Removed tree from agents that don't need it:

| Agent | Before | After | Rationale |
|-------|--------|-------|-----------|
| Engineer | Tree | Tree | Needs file locations |
| Tester | Tree | Tree | Needs test locations |
| Security Auditor | Tree | **Removed** | Uses implementation-notes.md |
| Code Reviewer | Tree | **Removed** | Uses implementation-notes.md |
| Documenter | Tree | **Removed** | Uses implementation-notes.md |

**Files updated:**
- `implement.md` - Removed tree from Security Auditor, Code Reviewer, Documenter
- `test.md` - Removed tree from Code Reviewer
- `fix.md` - Already optimized (Code Reviewer had no tree)

**Token savings:**
- implement.md: ~6000 tokens per workflow (3 agents × 2000 tokens)
- test.md: ~2000 tokens per workflow (1 agent)
- **Total: ~8000 tokens saved per workflow**

Added clarifying instruction to each agent: "The implementation-notes.md lists all files that were modified - focus on those."

---

### Priority 23: OPT-04 - No Agent Caching

**Severity:** LOW
**Category:** Optimization
**Location:** All agents

**Problem:**
Each agent invocation is stateless. If Architect runs twice, it re-reads everything.

**Recommendation:**
Implement spec fingerprinting - skip re-analysis if specs unchanged.

**Resolution (2025-12-07): Already Resolved**

The context injection pattern (v0.3 Phase 1) already addresses this at the command level:

1. Command starts → Step 0 reads all specs ONCE
2. Specs content injected into all agent prompts
3. Agents instructed: "Context already loaded above - DO NOT re-read these files"

This eliminates redundant reads within a single command execution. Cross-session caching is not needed since specs may change between runs.

The original concern was about per-agent redundancy, which is now solved.

---

### Priority 24: UNN-01 - Consider Merging Tester + Code Reviewer

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/`

**Problem:**
Both validate implementation quality. Could be combined into "Quality Agent".

**Recommendation:**
Evaluate if consolidation reduces coordination overhead.

**Resolution (2025-12-07): Won't Fix - Keep Separate**

Analysis showed merging would cause more problems than it solves:

1. **Different responsibilities:** Tester writes tests (modifies `tests/`), Code Reviewer only analyzes (read-only)
2. **Different tool access:** Tester needs Bash to run tests; Code Reviewer is intentionally read-only
3. **Parallel execution depends on separation:** v0.3 parallel validation runs them concurrently for 50% time savings
4. **Clear ownership:** Tester owns `tests/`, Code Reviewer never modifies code
5. **Independent verdicts:** "Tests pass but code quality bad" is a valuable distinct signal

Naming considered:
- "Quality Agent" too ambiguous - overlaps with Code Reviewer's "code quality" domain
- "Tester" is specific and accurate - owns tests, not general quality

Current design follows principle: *agents that write* vs *agents that only read*.

---

### Priority 25: UNN-02 - DevOps/Engineer Overlap

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/devops.md`, `.claude/agents/engineer.md`

**Problem:**
DevOps creates Dockerfile, CI/CD configs. Engineer often updates build configs, fixes deployment. Boundary violations happen.

**Recommendation:**
Clarify boundaries or merge deployment responsibilities.

**Resolution (2025-12-07): Won't Fix - Boundaries Already Clear**

Analysis showed boundaries are already well-defined:

| Owner | Files |
|-------|-------|
| DevOps | `.github/workflows/*`, `Dockerfile`, `docker-compose.yml`, `k8s/*`, `helm/*` |
| Engineer | `src/*`, `tests/*`, `package.json`, `*.config.*` (vite, webpack, etc.) |

Explicit restrictions already in place:
- DevOps: "Running application builds (Engineer does this)"
- Engineer: "Deployments (DevOps handles this)"

The v0.3 Phase 1 role enforcement (file boundaries) prevents violations:
- DevOps can only write to deployment/CI files
- Engineer can only write to src/ and tests/

Edge cases follow file location naturally - no additional clarification needed.

---

### Priority 26: UNN-03 - Product Manager vs Spec Command Overlap

**Severity:** LOW
**Category:** Unnecessary
**Location:** `.claude/agents/product-manager.md`, `.claude/commands/spec.md`

**Problem:**
Both create requirements and specifications.

**Recommendation:**
Clarify when to use agent vs command.

**Resolution (2025-12-07):**
OBSOLETE - `/project:spec` was deleted as part of WST-02 resolution.
`/project:plan` now invokes Product Manager agent, so there's no overlap.

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

**Resolution (2025-12-07): Documented - Implementation Deferred to v0.4**

Created comprehensive pattern documentation: `.claude/patterns/multi-repo.md`

**Documentation covers:**
1. **Stage 1: Modular Monolith** - Single repo with module boundaries (current framework works)
2. **Stage 2: Multi-Repo Services** - Separate repos with shared types package
3. **Stage 3: Event-Driven** - Async communication with event schemas

**Key guidance:**
- AI agents work best with focused context (favors multi-repo over monorepo)
- Shared types via npm package (`@company/types`)
- Coordination patterns: Sequential, Beta channel, Local linking
- Decision framework based on cross-cutting change frequency
- Migration checklists for each evolution stage

**v0.4 Planned Implementation:**
- `/project:init-platform` - Create orchestration repo
- `/project:add-service` - Add new service repo
- `/project:sync-types` - Update shared types across repos
- `/project:release` - Coordinated release train
- New specs: `repos.md`, `dependencies.md`, `events.md`

**Current workaround:** Work from service directory (`cd service && claude`)

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
