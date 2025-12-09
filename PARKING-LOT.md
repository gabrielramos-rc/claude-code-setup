# Parking Lot

Ideas captured during development sessions for future consideration.

---

## Priority Ranking

| Priority | Idea | Rationale |
|----------|------|-----------|
| **P0** | #4 + #5: Agent Refactoring + Protocol System | Foundation for all other optimizations. Reduces token cost, enables cross-cutting concerns. |
| **P1** | #1 + #9: Hierarchical Specs + Index Pattern | Second major token optimization. Builds on protocol system patterns. |
| **P2** | #14: Progress Streaming | Highest UX impact for minimal effort. Leverages existing checkpoint system. |
| **P3** | #12: Agent Communication Protocol | Prevents bugs from inconsistent state files. Small effort, high reliability gain. |
| **P4** | #15: Dry Run Mode | User confidence builder. Enables cost estimation (#13). |
| **P5** | #13: Cost Tracking | Validates all token optimizations. Needs #15 for estimation. |
| **P6** | #2: Git Workflow Improvements | Quality-of-life. Already have `.claude/patterns/git-workflow.md`. |
| **P7** | #16 + #17: Snapshots + Interactive Mode | Nice-to-have UX improvements. |
| **P8** | #6, #7, #8: Cross-Cutting Protocols | Content, not architecture. Add after #5 is implemented. |
| **P9** | #11: Conversation Memory | Complex, unclear ROI. Research needed. |
| **P10** | #18: Natural Language Commands | Advanced UX. Depends on stable command set. |
| **P11** | #3: Opinionated Framework Variant | Scope creep risk. Consider stack snippets instead. |
| **P12** | #10: Semantic Protocol Routing | Enhancement to #5. Implement after basic protocol system works. |

---

## Ideas

### 1. Hierarchical Specification System

**Date:** 2025-12-07
**Source:** Audit session discussion
**Status:** Parked

**Problem:**
State files accumulate too much information. Agents read entire files when they only need specific sections. Token waste and cognitive overload.

**Proposed Solution:**
Create a two-tier specification system:

```
.claude/specs/
├── OVERVIEW.md              ← Concise summary with links
├── features/
│   ├── auth.md              ← Full auth specification
│   ├── payments.md          ← Full payments specification
│   └── notifications.md     ← Full notifications specification
└── services/
    ├── api-gateway.md       ← Full API gateway spec
    └── database.md          ← Full database spec
```

**OVERVIEW.md example:**
```markdown
## Features

### Authentication
OAuth2 + JWT implementation for user auth.
**Full spec:** [features/auth.md](features/auth.md)

### Payments
Stripe integration for subscriptions.
**Full spec:** [features/payments.md](features/payments.md)
```

**Benefits:**
- Agents read overview first (small token cost)
- Only fetch full specs when needed
- Reduces context window usage
- Better organization as project grows

**Considerations:**
- Requires updates to context injection pattern
- Agents need guidance on when to "drill down"
- Overview must stay in sync with detailed specs

---

### 2. Git and GitHub Workflow Improvements

**Date:** 2025-12-07
**Source:** Audit session observation
**Status:** Parked

**Problem:**
Current git workflow is not producing clean branches and commits. Issues observed:
- Branch naming inconsistent
- Commits not following conventional commit format consistently
- No clear PR workflow guidance
- Agents may commit at wrong times or with poor messages

**Areas to Revisit:**
- Branch naming conventions (feature/, fix/, chore/, etc.)
- Commit message format enforcement
- When agents should commit vs. batch changes
- PR creation workflow
- Git hooks integration
- DevOps agent git coordination role

**Considerations:**
- May need updates to multiple agents' git sections
- Could benefit from a `.claude/patterns/git-workflow.md` pattern
- Should align with common team practices

---

### 3. Opinionated Framework Variant

**Date:** 2025-12-07
**Source:** Audit Session 5 discussion
**Status:** Parked

**Problem:**
Current framework is tooling-agnostic - it detects and adapts to whatever the project uses. This is flexible but means every project must make all tooling decisions from scratch.

**Proposed Solution:**
Create an opinionated variant of the framework with pre-selected stack:
- **Language:** TypeScript
- **Runtime:** Node.js / Bun
- **Testing:** Vitest (unit/integration), Playwright (E2E)
- **Linting:** ESLint + Prettier
- **Database:** PostgreSQL + Prisma
- **Deployment:** Docker + fly.io or Railway
- **CI/CD:** GitHub Actions

**Benefits:**
- Zero decision fatigue for new projects
- Agents optimized for specific tooling
- Consistent patterns across all projects
- Better documentation and examples
- Faster onboarding

**Considerations:**
- How to maintain both versions? Fork vs feature flags vs profiles?
- Naming: "claude-code-setup-ts" or "claude-code-setup --profile=typescript"?
- How to handle projects that outgrow the opinionated choices?
- Which stacks deserve opinionated variants? (TypeScript, Python, Go?)

---

### 4. Refactor Large Agent Files to Summary + Reference Architecture

**Date:** 2025-12-07
**Source:** Audit Session 6 discussion
**Status:** PLANNING - See `.claude/plans/protocol-system-implementation.md`

**Problem:**
Agent files are growing large (Architect ~1100 lines, Engineer ~550 lines). This creates:
- High token cost when loading agents
- Cognitive overload for Claude processing full files
- Harder to maintain and update

**Proposed Solution:**
Split large agent files into:

```
.claude/agents/
├── architect.md           ← Core responsibilities + summary (~200 lines)
├── engineer.md            ← Core responsibilities + summary (~200 lines)
└── protocols/
    ├── api-design.md      ← Full API Design Protocol
    ├── data-model.md      ← Full Data Model Design
    ├── database-impl.md   ← Full Database Implementation Protocol
    ├── data-engineering.md ← Full Data Engineering Protocol
    └── frontend-arch.md   ← Full Frontend Architecture
```

**Agent file structure:**
```markdown
## Core Responsibilities
(What agent does, 50 lines)

## Protocols Available
- **API Design** - See protocols/api-design.md
- **Data Model** - See protocols/data-model.md
(Agent loads protocol only when task requires it)

## Quick Reference
(Checklists, common commands, 100 lines)
```

**Benefits:**
- Smaller base agent files
- Protocols loaded on-demand
- Easier to update individual protocols
- Could enable protocol sharing between agents

**Considerations:**
- How does agent know which protocol to load?
- Context injection pattern needs updating
- May need protocol index/registry

---

### 5. Protocol System for Agent Specialization

**Date:** 2025-12-07
**Source:** Audit Session 6 discussion
**Status:** PLANNING - See `.claude/plans/protocol-system-implementation.md`

**Problem:**
Currently, specialization is done by adding sections to agent files. This doesn't scale and creates monolithic agents.

**Proposed Solution:**
Formalize a "Protocol" system:

```markdown
# Protocol: Performance Optimization

## Applies To
- Engineer (code-level optimization)
- Tester (load testing)
- DevOps (CI performance budgets)

## When Activated
- Task mentions "performance", "slow", "optimize", "load test"
- User explicitly requests performance focus

## Protocol Content
(Specialized guidance for this concern)
```

**Protocol Registry:**
```yaml
# .claude/protocols/registry.yaml
protocols:
  - name: performance
    file: protocols/performance.md
    agents: [engineer, tester, devops]
    triggers: ["performance", "optimize", "slow", "load test"]

  - name: security-hardening
    file: protocols/security-hardening.md
    agents: [engineer, security-auditor]
    triggers: ["security", "harden", "vulnerability"]
```

**Benefits:**
- Cross-cutting concerns handled cleanly
- Agents stay focused on core responsibilities
- Protocols can be shared, versioned, updated independently
- Easy to add new specializations without bloating agents

**Considerations:**
- How are protocols activated? Command-level? Auto-detection?
- Token cost of loading protocols
- Interaction between multiple active protocols
- This is a significant architectural change

---

### 6. Cross-Cutting FinOps/Cost Protocols

**Date:** 2025-12-07
**Source:** Audit Session 6 discussion
**Status:** Parked

**Problem:**
Cost optimization is a cross-cutting concern that spans multiple agents:
- Architect: Infrastructure cost modeling, right-sizing decisions
- Engineer: Efficient code, avoiding expensive operations
- DevOps: Cloud cost monitoring, auto-scaling policies, spot instances
- Code Reviewer: Spotting costly patterns (N+1 queries, unnecessary API calls)

**Proposed Solution:**
Similar to performance, create distributed cost awareness:
- `.claude/patterns/finops.md` - Central reference for cost optimization
- Each agent gets a focused "Cost Awareness" section

**Topics to cover:**
- Cloud cost estimation
- Database query cost (RCU/WCU for DynamoDB, compute time for serverless)
- API call optimization (batching, caching)
- Right-sizing recommendations
- Cost monitoring and alerts
- Serverless vs container cost tradeoffs

---

### 7. Cross-Cutting Logging/Monitoring Protocols

**Date:** 2025-12-07
**Source:** Audit Session 6 discussion
**Status:** Parked

**Problem:**
Observability (logging, metrics, tracing) spans multiple agents:
- Architect: Observability architecture, tool selection
- Engineer: Structured logging, metrics instrumentation, trace propagation
- DevOps: Log aggregation, alerting, dashboards
- Security Auditor: Audit logging, security event monitoring

**Proposed Solution:**
Create distributed observability guidance:
- `.claude/patterns/observability.md` - Central reference
- Each agent gets focused logging/monitoring section

**Topics to cover:**
- Structured logging patterns (JSON, log levels)
- Metrics instrumentation (counters, gauges, histograms)
- Distributed tracing (OpenTelemetry, trace context propagation)
- Log aggregation setup (ELK, Loki, CloudWatch)
- Alerting strategies (error rates, latency percentiles)
- Dashboard design principles

---

### 8. SRE Protocols

**Date:** 2025-12-07
**Source:** Audit Session 6 discussion
**Status:** Parked

**Problem:**
Site Reliability Engineering practices span multiple concerns:
- Service Level Objectives (SLOs) and error budgets
- Incident response and postmortems
- Capacity planning
- Chaos engineering
- On-call practices

**Proposed Solution:**
Create SRE-focused protocols that integrate with existing agents:
- `.claude/patterns/sre.md` - Central SRE reference
- Architect: SLO definition, reliability requirements
- DevOps: SLI implementation, error budget tracking, runbooks
- Tester: Chaos testing, failure injection
- Engineer: Circuit breakers, graceful degradation, retry patterns

**Topics to cover:**
- SLO/SLI/SLA definitions
- Error budget policies
- Incident severity levels
- Postmortem templates
- Capacity planning methodology
- Chaos engineering principles
- Runbook structure

---

---

### 9. Spec Index + On-Demand Pattern

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked
**Related:** Refinement of #1

**Problem:**
Hierarchical specs (#1) require agents to navigate multiple files. Need a simpler mechanism for selective loading.

**Proposed Solution:**
Create an index file that commands inject, with agents loading full specs on-demand:

```markdown
# .claude/specs/SPEC-INDEX.md

## Available Specifications
| Topic | Summary | Full Spec |
|-------|---------|-----------|
| Auth | OAuth2 + JWT for user authentication | specs/auth.md |
| Payments | Stripe subscriptions and billing | specs/payments.md |
| Notifications | Email, SMS, push notification system | specs/notifications.md |

## How to Use
1. Commands inject this index (not full specs)
2. Read full spec ONLY when task directly involves that topic
3. Never read specs "just in case"
```

**Benefits:**
- Explicit, self-documenting pattern
- No complex command-level filtering logic
- Agents make informed decisions about what to read
- Single index file to maintain

**Considerations:**
- Agents must be disciplined about not over-reading
- Index must stay in sync with actual spec files
- Works best with Protocol System (#5) for consistent patterns

---

### 10. Semantic Protocol Routing

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked
**Related:** Enhancement to #5

**Problem:**
Protocol System (#5) proposes keyword triggers ("performance", "optimize"). This is fragile - users might say "make the app faster" without trigger words.

**Proposed Solution:**
Instead of keyword matching, use semantic routing at command level:

```markdown
## /project:route Output (enhanced)

**Task:** "Make the app load faster on mobile"
**Analysis:**
- Workflow: implement
- Complexity: feature-level
- **Protocols detected:** performance, mobile-optimization
- Agents: Architect → Engineer → Tester

**Protocol injection:**
The implement command will load:
- protocols/performance.md (load time concern)
- protocols/mobile.md (mobile-specific)
```

**Benefits:**
- Deliberate protocol selection (not magic keywords)
- Route command already does task analysis
- Human can override/confirm protocol selection
- Works with any phrasing

**Considerations:**
- Adds complexity to route command
- May need LLM call for semantic analysis
- Should be opt-in enhancement, not replacement

---

### 11. Conversation Memory & Learning

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
Each session starts fresh. The framework doesn't learn from past sessions. If an agent makes a mistake, there's no mechanism to prevent it next time.

**Proposed Solution:**
Create a learning directory that persists across sessions:

```
.claude/learning/
├── anti-patterns.md      # "Don't do X because Y happened"
├── project-decisions.md  # "We chose X over Y because Z"
└── user-preferences.md   # "User prefers verbose responses"
```

**Example anti-patterns.md:**
```markdown
## Anti-Patterns Learned

### Don't use moment.js
**Date:** 2025-12-01
**Context:** Engineer suggested moment.js for date formatting
**Problem:** Package is deprecated, 67KB gzipped
**Solution:** Use date-fns or native Intl.DateTimeFormat
**Applies to:** Engineer, Code Reviewer

### Don't create separate test files for utilities
**Date:** 2025-12-05
**Context:** Tester created utils.test.ts with 3 tests
**Problem:** User prefers co-located tests
**Solution:** Add tests to existing feature test files
**Applies to:** Tester
```

**Benefits:**
- Framework improves over time
- Project-specific knowledge persists
- User preferences respected automatically

**Considerations:**
- How are learnings captured? Manual or automatic?
- Risk of learnings becoming stale
- Token cost of injecting learnings
- Privacy concerns with user preferences

---

### 12. Agent Communication Protocol (State Schema)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
Agents communicate through state files (`.claude/state/*`). But there's no formal schema. One agent might write `status: complete` while another expects `status: COMPLETED`.

**Proposed Solution:**
Define formal schemas for state files:

```yaml
# .claude/schemas/task-state.yaml
task_state:
  status:
    type: enum
    values: [PENDING, IN_PROGRESS, COMPLETED, FAILED, BLOCKED]
    required: true
  progress:
    type: object
    properties:
      current_step: integer
      total_steps: integer
      checkpoint: string
  outputs:
    type: object
    properties:
      files_created: string[]
      files_modified: string[]
  errors:
    type: array
    items: string
```

```yaml
# .claude/schemas/security-findings.yaml
security_finding:
  severity:
    type: enum
    values: [CRITICAL, HIGH, MEDIUM, LOW, INFO]
  category:
    type: enum
    values: [VULNERABILITY, DEPENDENCY, CONFIGURATION, CODE_QUALITY]
  description: string
  location: string
  remediation: string
```

**Benefits:**
- Consistent state file structure
- Agents can validate before writing
- Easier to parse and process state
- Catches integration bugs early

**Considerations:**
- Schema enforcement mechanism needed
- Versioning for schema changes
- Balance between strictness and flexibility

---

### 13. Cost Tracking & Token Budget

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
Framework optimizes for token efficiency (v0.3 focus) but has no visibility into actual costs. Can't measure if optimizations work.

**Proposed Solution:**
Track token usage per workflow:

```markdown
# .claude/state/token-usage.md

## Session: 2025-12-07

| Command | Tokens In | Tokens Out | Cost Est. |
|---------|-----------|------------|-----------|
| /project:implement "auth" | 45,000 | 12,000 | $0.28 |
| /project:fix "login bug" | 22,000 | 8,000 | $0.14 |
| /project:test | 18,000 | 5,000 | $0.10 |

**Session Total:** 85,000 in / 25,000 out = $0.52

## Trends
- Average implement cost: $0.30
- Average fix cost: $0.15
- Most expensive workflow: implement (expected)
```

**Benefits:**
- Measure optimization effectiveness
- Budget planning for projects
- Identify expensive patterns
- Compare before/after changes

**Considerations:**
- How to capture token counts? (API response metadata)
- Cost calculation varies by model
- Storage and aggregation over time
- Privacy of usage data

---

### 14. Progress Streaming (UX)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
User runs `/project:implement` and waits 10+ minutes with no visibility. Current checkpoint system writes to state files but doesn't surface progress during execution.

**Proposed Solution:**
Stream progress updates to user during workflow:

```
[14:00:00] Starting /project:implement "Add user authentication"
[14:00:05] ✓ Context loaded (3 specs, 1 pattern)
[14:00:10] → Architect analyzing requirements...
[14:03:45] ✓ Architecture complete
           Created: .claude/specs/auth-architecture.md
[14:03:50] → Engineer implementing feature...
[14:12:30] ✓ Implementation complete
           Created: src/auth/*, tests/auth/*
[14:12:35] → Validation (parallel): Tester, Security, Reviewer
[14:15:20] ✓ Tester: 12 tests passed
[14:15:45] ✓ Security: No vulnerabilities found
[14:16:00] ✓ Reviewer: Approved with 2 suggestions
[14:16:05] Complete!
           Files: 8 created, 2 modified
           Duration: 16m 5s
```

**Benefits:**
- User knows workflow is progressing
- Can estimate remaining time
- Easier to identify stuck steps
- Better debugging when issues occur

**Considerations:**
- Leverages existing checkpoint system (Phase 3)
- Output format for CLI vs IDE integration
- Verbosity levels (quiet, normal, verbose)

---

### 15. Dry Run Mode (UX)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
User unsure what a command will do. Fear of unintended changes prevents experimentation.

**Proposed Solution:**
Add `--dry-run` flag to commands:

```bash
/project:implement "Add user authentication" --dry-run

# Output:
═══════════════════════════════════════════════
DRY RUN: /project:implement
═══════════════════════════════════════════════

This command will:

1. LOAD CONTEXT
   - .claude/specs/requirements.md
   - .claude/specs/architecture.md
   - .claude/specs/tech-stack.md

2. INVOKE AGENTS (sequence)
   - Architect (opus) → Design authentication system
   - Engineer (sonnet) → Implement auth module
   - Tester (sonnet) → Write and run tests
   - Security Auditor (sonnet) → Scan for vulnerabilities
   - Code Reviewer (sonnet) → Review implementation

3. EXPECTED OUTPUT
   - New files: ~5-8 files in src/auth/
   - Test files: ~2-3 files in tests/auth/
   - Spec updates: .claude/specs/auth-architecture.md

4. ESTIMATED COST
   - Tokens: ~80,000 input, ~25,000 output
   - Cost: ~$0.45 (opus) + ~$0.15 (sonnet) = ~$0.60

═══════════════════════════════════════════════
Proceed with actual execution? [y/n]
```

**Benefits:**
- User confidence in command behavior
- Cost visibility before execution
- Educational - shows how framework works
- Prevents accidental expensive operations

**Considerations:**
- Estimation accuracy (especially file counts)
- Maintaining dry-run logic as commands evolve
- Integration with cost tracking (#13)

---

### 16. Workflow-Level Snapshots (UX)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
User doesn't like result but changes span multiple commits. Git archaeology is tedious. `/project:rollback` exists but works at commit level.

**Proposed Solution:**
Create workflow-level snapshots:

```bash
/project:implement "Add feature"
# Automatically creates: .claude/snapshots/2025-12-07-14-00-implement.tar.gz

# Later...
/project:undo
# Shows:
Available snapshots:
1. [2025-12-07 14:00] implement "Add feature" (45 files changed)
2. [2025-12-07 11:30] fix "Login bug" (3 files changed)
3. [2025-12-06 16:00] implement "Dashboard" (22 files changed)

Restore which snapshot? [1-3, or 'cancel']
```

**Benefits:**
- Clean undo regardless of commit history
- Workflow-level granularity
- Preserves git history (snapshot is separate)
- Quick recovery from bad outcomes

**Considerations:**
- Storage size for snapshots
- Retention policy (keep last N?)
- Conflict with uncommitted changes
- Relationship to git stash

---

### 17. Interactive vs Autonomous Mode (UX)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
Sometimes users want full automation, sometimes they want approval at each step. Current framework is fully autonomous.

**Proposed Solution:**
Add mode flag to commands:

```bash
# Current behavior (default)
/project:implement "Feature" --mode=autonomous

# New: Pause after each agent
/project:implement "Feature" --mode=interactive
```

**Interactive mode flow:**
```
[Architect complete]
══════════════════════════════════════════════
CHECKPOINT: Architecture Design
══════════════════════════════════════════════

Proposed architecture:
- REST API with JWT authentication
- PostgreSQL with Prisma ORM
- Rate limiting middleware

Files to create:
- .claude/specs/auth-architecture.md

Options:
[a] Approve and continue
[e] Edit the output before continuing
[r] Reject and provide feedback
[s] Skip this agent
[q] Quit workflow

Choice: _
```

**Benefits:**
- User control over workflow
- Learning opportunity (see each step)
- Catch issues before they compound
- Build trust in framework

**Considerations:**
- Increases workflow duration significantly
- State management between pauses
- Timeout handling
- Hybrid mode? (pause only on certain agents)

---

### 18. Natural Language Commands (UX)

**Date:** 2025-12-07
**Source:** Discussion session (Claude suggestion)
**Status:** Parked

**Problem:**
Users must remember exact command names and syntax. Barrier to adoption.

**Proposed Solution:**
Create a catch-all `/project:do` command:

```bash
/project:do "I need user authentication with Google OAuth"

# Internal processing:
# 1. Analyze intent → "implement new feature"
# 2. Extract constraints → "Google OAuth"
# 3. Route to appropriate command → /project:implement
# 4. Inject constraints into workflow

# Equivalent to:
/project:implement "User authentication with Google OAuth"
```

**More examples:**
```bash
/project:do "The login page is broken"
# → Routes to /project:fix

/project:do "Is our code secure?"
# → Routes to security audit workflow

/project:do "What's the status of the current task?"
# → Routes to /project:resume --status-only

/project:do "Make it faster"
# → Routes to /project:implement with performance protocol
```

**Benefits:**
- Zero learning curve
- Natural interaction
- Handles ambiguous requests
- Single entry point

**Considerations:**
- Accuracy of intent detection
- Handling truly ambiguous requests
- Cost of classification LLM call
- Edge cases and fallbacks
- Should still support explicit commands

---

*Add new ideas below*

---
