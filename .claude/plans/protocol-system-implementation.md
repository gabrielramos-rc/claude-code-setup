# Protocol System Implementation Plan

> Plan for implementing the Agent Refactoring + Protocol System (Parking Lot P0)
> Date: 2025-12-08
> Status: PLANNING

---

## Executive Summary

Split large agent files (Architect: 1222 lines, Engineer: 822 lines) into:
- **Core agent files** (~250 lines) - Identity, responsibilities, tool usage, process
- **On-demand protocols** (~150-350 lines each) - Specialized procedures loaded when needed

Implement a **Layered Hybrid** activation mechanism:
1. Agent reads protocol index and selects based on task
2. Security Auditor serves as gatekeeper for security protocol
3. Downstream agents (Reviewer/Tester) catch missing protocols

---

## Protocols vs Patterns: Key Distinction

Understanding the difference is critical for proper framework organization:

| Aspect | Protocols | Patterns |
|--------|-----------|----------|
| **Purpose** | Task-specific procedures for specialized work | Cross-cutting concerns that apply broadly |
| **Scope** | Loaded on-demand for specific task types | Referenced by many agents, always relevant |
| **Location** | `.claude/protocols/` | `.claude/patterns/` |
| **Loading** | Agent selects based on task analysis | Always available, referenced when needed |
| **Examples** | api-rest, testing-unit, database-implementation | performance, git-workflow, context-injection |

### Existing Patterns (keep as patterns)

| Pattern | Why It's a Pattern (not protocol) |
|---------|-----------------------------------|
| `performance.md` | Cross-cutting: Architect designs, Engineer implements, Tester validates, Reviewer checks |
| `git-workflow.md` | Cross-cutting: All agents commit using these conventions |
| `context-injection.md` | Cross-cutting: All commands use this loading pattern |
| `input-safety.md` | Cross-cutting: All agents validate inputs |
| `model-selection.md` | Cross-cutting: Applies to agent/task selection |
| `reflexion.md` | Cross-cutting: Retry pattern for all workflows |
| `state-based-session-management.md` | Cross-cutting: All commands track state |
| `parallel-quality-validation.md` | Cross-cutting: Orchestration pattern |

### Protocols Can Reference Patterns

Protocols may include references like:
```markdown
## Performance Considerations

For performance optimization patterns, see `.claude/patterns/performance.md`.
Apply the caching strategy defined there when implementing API endpoints.
```

This avoids duplication while keeping protocols focused on task-specific procedures.

---

## Current State Analysis

### Agent File Sizes

| Agent | Current Lines | Target Lines | Action |
|-------|---------------|--------------|--------|
| architect.md | 1222 | ~250 | **Refactor (extract 4 protocols)** |
| engineer.md | 822 | ~250 | **Refactor (extract 3 protocols)** |
| devops.md | 654 | ~300 | **Refactor (extract 2 protocols)** |
| tester.md | 561 | ~400 | Minor trim (acceptable) |
| ui-ux-designer.md | 551 | ~400 | Minor trim (acceptable) |
| code-reviewer.md | 486 | ~400 | No change (acceptable) |
| security-auditor.md | 437 | ~350 | Minor update (add gatekeeper role) |
| documenter.md | 434 | ~350 | No change (acceptable) |
| product-manager.md | 36 | ~200 | Expand (currently too thin) |

### Existing Patterns (Not Protocols)

These are **cross-cutting patterns** that agents reference (different from task-specific protocols):

| Pattern | Lines | Purpose |
|---------|-------|---------|
| performance.md | 448 | Cross-cutting performance guidance |
| context-injection.md | ~200 | How commands inject context |
| git-workflow.md | ~150 | Git conventions |
| parallel-quality-validation.md | ~935 | Parallel agent orchestration |
| state-based-session-management.md | ~300 | Task tracking and resume |
| input-safety.md | ~100 | Input validation |
| model-selection.md | ~100 | Opus/Sonnet/Haiku selection |
| reflexion.md | ~100 | Retry patterns |

**Key Distinction:**
- **Patterns** = Cross-cutting concerns (apply to all/many agents)
- **Protocols** = Task-specific procedures (loaded on-demand for specific work)

---

## Complete Protocol List

### Tier 1: Extract from Existing Agents (Implementation Phase 1)

#### From Architect (1222 → ~250 lines)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `api-rest.md` | ~200 | Load when designing traditional request-response APIs where clients call specific URL endpoints with HTTP methods to perform CRUD operations on resources. Covers endpoint structure, versioning, pagination, error formats, and OpenAPI specifications. |
| `api-realtime.md` | ~150 | Load when designing APIs that require flexible client-driven queries (GraphQL), persistent bidirectional connections (WebSocket), or server-initiated updates (SSE). Covers schema design, subscriptions, and AsyncAPI specifications. |
| `data-modeling.md` | ~150 | Load when designing how data will be structured and stored in databases, including entity identification, relationship mapping, indexing strategy, constraints, and migration planning. |
| `frontend-architecture.md` | ~200 | Load when deciding how the user interface will be technically structured, including component hierarchy patterns, state management approach, styling methodology, and code splitting strategy. References `patterns/performance.md` for frontend performance. |

**What Remains in architect.md (~250 lines):**
- YAML frontmatter, core responsibilities, tool usage
- System design process (high-level)
- Protocol loading section
- Git commits, agent invocation, examples

#### From Engineer (822 → ~250 lines)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `database-implementation.md` | ~200 | Load when implementing database operations using an ORM like Prisma or Drizzle, creating or modifying schema migrations, setting up database connectivity, or implementing repository patterns. |
| `data-batch.md` | ~150 | Load when implementing scheduled data processing jobs, ETL pipelines, bulk import/export operations, or any data transformation that runs on a fixed cadence rather than in response to events. |
| `data-streaming.md` | ~120 | Load when implementing real-time data processing, event-driven pipelines, message queue consumers, or any continuous data flow that reacts immediately to incoming data. |

**What Remains in engineer.md (~250 lines):**
- YAML frontmatter, core responsibilities, tool usage
- Implementation process (high-level)
- Protocol loading section
- State communication, git commits, agent invocation

#### From DevOps (654 → ~300 lines)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `ci-cd.md` | ~200 | Load when setting up or modifying automated pipelines that build, test, and deploy code in response to repository events. Covers GitHub Actions, GitLab CI, and general CI/CD patterns. |
| `containerization.md` | ~150 | Load when packaging applications into Docker containers, writing docker-compose configurations for local development, or setting up Kubernetes manifests and Helm charts for orchestrated deployments. |

**What Remains in devops.md (~300 lines):**
- Core responsibilities, tool usage, git coordination
- Environment management, protocol loading section

#### From Security Auditor (437 → ~300 lines)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `authentication.md` | ~180 | Load when implementing user identity verification including login flows, JWT or session token management, OAuth/OIDC integration, password policies, or multi-factor authentication. |
| `security-hardening.md` | ~150 | Load when reviewing code for OWASP Top 10 vulnerabilities, implementing input validation and output encoding, managing secrets, scanning dependencies, or hardening application configuration. |

**What Remains in security-auditor.md (~300 lines):**
- Core responsibilities, tool usage, gatekeeper role
- Security audit checklist, protocol loading section

#### From Tester (561 → ~300 lines)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `testing-unit.md` | ~120 | Load when writing isolated tests for individual functions, classes, or modules that verify behavior without external dependencies like databases, APIs, or file systems. Covers mocking, assertions, and test organization. |
| `testing-integration.md` | ~120 | Load when writing tests that verify multiple components work together correctly, including database operations, API endpoint testing, and service-to-service communication. |
| `testing-e2e.md` | ~150 | Load when writing end-to-end tests that simulate real user workflows through the complete application stack, typically using browser automation tools like Playwright or Cypress. |

**What Remains in tester.md (~300 lines):**
- Core responsibilities, tool usage
- Test detection and execution
- Protocol loading section, results reporting

### Tier 2: New Protocols (Implementation Phase 2)

| Protocol | Lines | Load When |
|----------|-------|-----------|
| `observability.md` | ~200 | Load when implementing logging infrastructure, metrics collection, distributed tracing, or alerting to understand and monitor system behavior in production. References `patterns/performance.md` for performance metrics. |
| `error-handling.md` | ~150 | Load when designing how the application handles, reports, and recovers from failures across the stack, including error classification, retry strategies, circuit breakers, and graceful degradation. |

### Tier 3: Future Protocols (Implementation Phase 3+)

| Protocol | Lines | Load When | Add When |
|----------|-------|-----------|----------|
| `code-review-checklist.md` | ~150 | Load when performing code review to ensure consistent quality checks across architecture compliance, code style, security, and performance. | After Code Reviewer patterns stabilize |
| `documentation-patterns.md` | ~120 | Load when writing technical documentation including API docs, architecture docs, README files, and inline code documentation standards. | After Documenter patterns stabilize |
| `caching-strategies.md` | ~150 | Load when implementing caching at any layer including browser caching, CDN configuration, application-level caches (Redis), or database query caching. | If caching content in `patterns/performance.md` grows too large |
| `accessibility.md` | ~150 | Load when implementing WCAG compliance, screen reader support, keyboard navigation, or other accessibility requirements beyond what UI/UX Designer specifies. | If a11y patterns grow beyond UI/UX Designer scope |
| `internationalization.md` | ~120 | Load when implementing multi-language support, locale-aware formatting, right-to-left layouts, or other internationalization requirements. | When i18n becomes common requirement |
| `api-versioning.md` | ~100 | Load when planning breaking changes to existing APIs, managing multiple API versions simultaneously, or implementing deprecation strategies. | If versioning section in api-rest.md grows |
| `database-nosql.md` | ~150 | Load when implementing document databases (MongoDB), key-value stores (Redis/DynamoDB), or other non-relational data patterns. | When NoSQL projects become common |
| `mobile-patterns.md` | ~180 | Load when implementing React Native, Flutter, or native mobile applications with specific patterns for offline support, push notifications, and app lifecycle. | When mobile development added to framework |

### Protocol Count Summary

| Tier | Count | Total Lines | Implementation Phase |
|------|-------|-------------|---------------------|
| **Tier 1** (from agents) | 14 | ~2,140 | Phase 1-2 |
| **Tier 2** (new essential) | 2 | ~350 | Phase 3 |
| **Tier 3** (future) | 8 | ~1,120 | As needed |
| **Total Planned** | **24** | **~3,610** | - |

**Initial implementation (Tiers 1+2):** 16 protocols, ~2,490 lines

---

## Protocol-Pattern References

Protocols should reference patterns where appropriate to avoid duplication:

| Protocol | References Pattern |
|----------|-------------------|
| `api-rest.md` | `patterns/performance.md` (caching, rate limiting) |
| `frontend-architecture.md` | `patterns/performance.md` (frontend performance budgets) |
| `database-implementation.md` | `patterns/performance.md` (query optimization) |
| `testing-e2e.md` | `patterns/performance.md` (performance testing) |
| `observability.md` | `patterns/performance.md` (metrics, SLOs) |
| `ci-cd.md` | `patterns/git-workflow.md` (branch strategy) |
| All protocols | `patterns/input-safety.md` (input validation) |

---

## Protocol Structure and Format

### File Location

```
.claude/
├── agents/                    # Core agent files (~250 lines each)
│   ├── architect.md
│   ├── engineer.md
│   └── ...
├── protocols/                 # Task-specific protocols (NEW)
│   ├── INDEX.md               # Protocol index with "Load When" guidance
│   ├── api-design.md          # ~350 lines
│   ├── data-modeling.md       # ~150 lines
│   ├── frontend-architecture.md # ~200 lines
│   ├── database-implementation.md # ~200 lines
│   ├── data-engineering.md    # ~220 lines
│   ├── ci-cd.md               # ~200 lines
│   ├── containerization.md    # ~150 lines
│   └── security-hardening.md  # ~200 lines
└── patterns/                  # Cross-cutting patterns (existing)
    └── performance.md, etc.
```

### Protocol File Format

Each protocol has a self-describing header:

```markdown
---
name: api-design
description: >
  REST, GraphQL, and Real-Time API design patterns.
  Includes OpenAPI and AsyncAPI specification writing.
applies_to: [architect]
load_when: >
  Load this protocol when the task requires designing how clients will
  communicate with the server, including endpoint structure, request/response
  formats, versioning strategy, or writing API specifications like OpenAPI
  or AsyncAPI documents.
---

# API Design Protocol

## When to Use This Protocol

Load this protocol when your task involves designing the communication layer
between clients and server. This includes:

- Defining endpoint structure and URL patterns for a new service
- Choosing between REST, GraphQL, or real-time approaches based on requirements
- Specifying request/response formats and status codes
- Establishing API versioning and deprecation strategy
- Writing machine-readable API specifications (OpenAPI, AsyncAPI)

**Do NOT load this protocol for:**
- Simple CRUD operations following existing API patterns
- Internal function interfaces (not exposed to clients)
- Database schema design (use data-modeling.md instead)

## REST API Design

[... detailed content extracted from architect.md ...]
```

### Protocol Index File

```markdown
# .claude/protocols/INDEX.md

## Available Protocols

### Architecture Protocols (Architect)

| Protocol | File | Load When |
|----------|------|-----------|
| REST API Design | `api-rest.md` | Load when designing traditional request-response APIs where clients call specific URL endpoints with HTTP methods to perform CRUD operations on resources. |
| Real-time API Design | `api-realtime.md` | Load when designing APIs that require flexible client-driven queries (GraphQL), persistent bidirectional connections (WebSocket), or server-initiated updates (SSE). |
| Data Modeling | `data-modeling.md` | Load when designing how data will be structured and stored in databases, including entity identification, relationship mapping, and indexing strategy. |
| Frontend Architecture | `frontend-architecture.md` | Load when deciding how the user interface will be technically structured, including component hierarchy, state management, and styling methodology. |

### Implementation Protocols (Engineer)

| Protocol | File | Load When |
|----------|------|-----------|
| Database Implementation | `database-implementation.md` | Load when implementing database operations using an ORM like Prisma or Drizzle, creating schema migrations, or setting up database connectivity. |
| Batch Data Processing | `data-batch.md` | Load when implementing scheduled data processing jobs, ETL pipelines, bulk import/export operations, or transformations that run on a fixed cadence. |
| Stream Data Processing | `data-streaming.md` | Load when implementing real-time data processing, event-driven pipelines, message queue consumers, or continuous data flows. |

### Testing Protocols (Tester)

| Protocol | File | Load When |
|----------|------|-----------|
| Unit Testing | `testing-unit.md` | Load when writing isolated tests for individual functions, classes, or modules that verify behavior without external dependencies. |
| Integration Testing | `testing-integration.md` | Load when writing tests that verify multiple components work together correctly, including database operations and API endpoints. |
| End-to-End Testing | `testing-e2e.md` | Load when writing tests that simulate real user workflows through the complete application stack using browser automation. |

### Security Protocols (Security Auditor)

| Protocol | File | Load When |
|----------|------|-----------|
| Authentication | `authentication.md` | Load when implementing user identity verification including login flows, JWT/session tokens, OAuth/OIDC, or multi-factor authentication. |
| Security Hardening | `security-hardening.md` | Load when reviewing code for OWASP Top 10 vulnerabilities, implementing input validation, managing secrets, or scanning dependencies. |

### DevOps Protocols (DevOps)

| Protocol | File | Load When |
|----------|------|-----------|
| CI/CD Pipelines | `ci-cd.md` | Load when setting up or modifying automated pipelines that build, test, and deploy code in response to repository events. |
| Containerization | `containerization.md` | Load when packaging applications into Docker containers, writing docker-compose configurations, or setting up Kubernetes deployments. |

### Cross-Cutting Protocols (Multiple Agents)

| Protocol | File | Load When |
|----------|------|-----------|
| Observability | `observability.md` | Load when implementing logging infrastructure, metrics collection, distributed tracing, or alerting for production monitoring. |
| Error Handling | `error-handling.md` | Load when designing how the application handles, reports, and recovers from failures, including retry strategies and circuit breakers. |

## Related Patterns (Not Protocols)

These are cross-cutting concerns in `.claude/patterns/` - reference them, don't duplicate:

| Pattern | When to Reference |
|---------|-------------------|
| `performance.md` | For caching, optimization, and performance budgets across any protocol |
| `git-workflow.md` | For branch strategy and commit conventions |
| `input-safety.md` | For input validation patterns |

## Loading Guidelines

### For Agents

1. **Read your task description**
2. **Consult this index** to identify relevant protocols
3. **Load 1-3 protocols** maximum (be selective)
4. **State your selection:** "Loading protocols: [X, Y] because [reason]"
5. **Read the protocol** and follow its guidance

### Selection Principles

- **Be selective** - Load only what the task clearly needs
- **When uncertain** - Err toward loading (downstream catches over-loading)
- **Max 2-3 protocols** - More creates cognitive overload
- **Explain your choice** - Creates audit trail for debugging

### If Protocols Were Injected

If the command already injected protocols, use those.
Only load additional protocols if you identify a critical gap.

## Protocol Logging

After selecting protocols, update `.claude/state/workflow-log.md`:

```markdown
## Protocol Loading

**Agent:** Architect
**Task:** Design payment processing API
**Protocols Loaded:**
- api-design.md - Task involves REST endpoints
- security-hardening.md - Payment processing is sensitive

**Protocols Not Loaded:**
- frontend-architecture.md - No frontend in this task
- data-modeling.md - Schema already designed
```
```

---

## Agent Refactoring Plan

### Phase 1: Infrastructure Setup

**Step 1.1: Create protocols directory structure**
```bash
mkdir -p .claude/protocols
```

**Step 1.2: Create INDEX.md**
- Protocol index with Load When guidance
- Loading guidelines for agents
- Logging instructions

**Step 1.3: Create workflow-log.md template**
```bash
touch .claude/state/workflow-log.md
```

### Phase 2: Architect Refactoring

**Step 2.1: Extract api-design.md (~350 lines)**
- Extract lines 397-820 from architect.md
- Add protocol header with metadata
- Update references

**Step 2.2: Extract data-modeling.md (~150 lines)**
- Extract lines 823-985 from architect.md
- Add protocol header with metadata

**Step 2.3: Extract frontend-architecture.md (~200 lines)**
- Extract lines 198-395 from architect.md
- Add protocol header with metadata

**Step 2.4: Refactor architect.md core**
- Remove extracted content
- Add protocol loading section
- Update to reference protocols
- Target: ~250 lines

### Phase 3: Engineer Refactoring

**Step 3.1: Extract database-implementation.md (~200 lines)**
- Extract lines 124-321 from engineer.md
- Add protocol header with metadata

**Step 3.2: Extract data-engineering.md (~220 lines)**
- Extract lines 324-548 from engineer.md
- Add protocol header with metadata

**Step 3.3: Merge performance content into patterns/performance.md**
- Lines 550-624 contain implementation-specific performance
- Add to existing patterns/performance.md under "## Engineer Implementation" section

**Step 3.4: Refactor engineer.md core**
- Remove extracted content
- Add protocol loading section
- Target: ~250 lines

### Phase 4: DevOps Refactoring

**Step 4.1: Extract ci-cd.md (~200 lines)**
- Extract CI/CD content from devops.md
- Add protocol header

**Step 4.2: Extract containerization.md (~150 lines)**
- Extract Docker/K8s content from devops.md
- Add protocol header

**Step 4.3: Refactor devops.md core**
- Remove extracted content
- Add protocol loading section
- Target: ~300 lines

### Phase 5: Security Gatekeeper Setup

**Step 5.1: Create security-hardening.md (~200 lines)**
- Compile security patterns from security-auditor.md
- Add OWASP Top 10 checklist
- Add secure coding patterns

**Step 5.2: Update security-auditor.md**
- Add gatekeeper role description
- Auto-load security-hardening.md
- Flag in reviews when protocol wasn't loaded upstream

### Phase 6: Command Updates

**Step 6.1: Update implement.md**
- Add protocol awareness to agent invocations
- Enable agents to load protocols on-demand

**Step 6.2: Update fix.md**
- Same updates as implement.md

**Step 6.3: Update test.md**
- Same updates as implement.md

### Phase 7: Testing and Validation

**Step 7.1: Token count validation**
- Measure token reduction per agent
- Target: 50%+ reduction in context size

**Step 7.2: Functionality testing**
- Run test scenarios with refactored agents
- Verify protocols load correctly
- Verify downstream catch works

**Step 7.3: Logging validation**
- Verify workflow-log.md captures protocol decisions
- Useful for debugging

---

## Activation Mechanism: Layered Hybrid

### Layer 1: Agent Selection (Primary)

```
┌─────────────────────────────────────────────────────────┐
│ Agent receives task                                      │
│                                                          │
│ 1. Read .claude/protocols/INDEX.md                       │
│ 2. Analyze task for protocol relevance                   │
│ 3. Select 1-3 relevant protocols                         │
│ 4. State: "Loading protocols: X, Y because Z"            │
│ 5. Read and apply protocol guidance                      │
│ 6. Log decision to .claude/state/workflow-log.md        │
└─────────────────────────────────────────────────────────┘
```

### Layer 2: Security Gatekeeper

```
┌─────────────────────────────────────────────────────────┐
│ Security Auditor (always in validation chain)           │
│                                                          │
│ 1. Always loads security-hardening.md                    │
│ 2. Reviews implementation for security concerns          │
│ 3. Checks if upstream agents loaded security protocol    │
│    when they should have                                 │
│ 4. Flags: "Security protocol not loaded for auth work"   │
└─────────────────────────────────────────────────────────┘
```

### Layer 3: Downstream Catch (Safety Net)

```
┌─────────────────────────────────────────────────────────┐
│ Code Reviewer / Tester (validation phase)                │
│                                                          │
│ During review, check:                                    │
│ - Code handles user input → security protocol loaded?    │
│ - Code has performance implications → perf pattern used? │
│ - Code defines APIs → api-design protocol loaded?        │
│                                                          │
│ If gap identified:                                       │
│ "PROTOCOL GAP: API design patterns not followed.         │
│  Recommend re-running with api-design protocol."         │
└─────────────────────────────────────────────────────────┘
```

---

## Token Impact Estimates

### Before Refactoring

| Agent | Lines | Est. Tokens |
|-------|-------|-------------|
| Architect | 1222 | ~3,050 |
| Engineer | 822 | ~2,055 |
| DevOps | 654 | ~1,635 |
| **Total (3 agents)** | **2698** | **~6,740** |

### After Refactoring (Agent Only)

| Agent | Lines | Est. Tokens |
|-------|-------|-------------|
| Architect (core) | ~250 | ~625 |
| Engineer (core) | ~250 | ~625 |
| DevOps (core) | ~300 | ~750 |
| **Total (3 agents)** | **~800** | **~2,000** |

### Protocol Loading (On-Demand)

| Scenario | Protocols Loaded | Added Tokens |
|----------|------------------|--------------|
| API feature | api-design | ~875 |
| Full-stack feature | api-design + frontend-arch | ~1,375 |
| Database work | data-modeling + db-implementation | ~875 |
| DevOps task | ci-cd + containerization | ~875 |

### Net Impact

| Scenario | Before | After | Reduction |
|----------|--------|-------|-----------|
| **Always loaded** | 6,740 | 2,000 | **70%** |
| **API feature** | 6,740 | 2,875 | **57%** |
| **Full-stack** | 6,740 | 3,375 | **50%** |
| **Database work** | 6,740 | 2,875 | **57%** |

**Conservative estimate: 50-70% token reduction** depending on task complexity.

---

## Implementation Checklist

### Pre-Implementation
- [ ] Review and approve this plan
- [ ] Decide on implementation order (phases)
- [ ] Set up branch: `feature/protocol-system`

### Phase 1: Infrastructure
- [ ] Create `.claude/protocols/` directory
- [ ] Create `INDEX.md` with protocol registry
- [ ] Create `.claude/state/workflow-log.md` template
- [ ] Update CLAUDE.md with protocol system documentation

### Phase 2: Architect Refactoring
- [ ] Extract `api-design.md` protocol
- [ ] Extract `data-modeling.md` protocol
- [ ] Extract `frontend-architecture.md` protocol
- [ ] Refactor `architect.md` core (~250 lines)
- [ ] Test architect with protocol loading

### Phase 3: Engineer Refactoring
- [ ] Extract `database-implementation.md` protocol
- [ ] Extract `data-engineering.md` protocol
- [ ] Merge performance content to `patterns/performance.md`
- [ ] Refactor `engineer.md` core (~250 lines)
- [ ] Test engineer with protocol loading

### Phase 4: DevOps Refactoring
- [ ] Extract `ci-cd.md` protocol
- [ ] Extract `containerization.md` protocol
- [ ] Refactor `devops.md` core (~300 lines)
- [ ] Test devops with protocol loading

### Phase 5: Security Gatekeeper
- [ ] Create `security-hardening.md` protocol
- [ ] Update `security-auditor.md` with gatekeeper role
- [ ] Test security catch mechanism

### Phase 6: Command Updates
- [ ] Update `implement.md` for protocol awareness
- [ ] Update `fix.md` for protocol awareness
- [ ] Update `test.md` for protocol awareness

### Phase 7: Validation
- [ ] Measure token reduction (target: 50%+)
- [ ] Run test scenarios
- [ ] Validate logging works
- [ ] Update documentation

### Post-Implementation
- [ ] Update CLAUDE.md with protocol system docs
- [ ] Update PARKING-LOT.md (mark #4 and #5 as implemented)
- [ ] Create PR for review

---

## Open Questions

1. **Should protocol loading be logged to workflow-log.md or a separate file?**
   - Recommendation: workflow-log.md keeps everything in one place

2. **What happens if agent loads wrong protocol?**
   - Downstream catch handles this
   - Not critical if caught in review

3. **Should protocols be versioned?**
   - Start with no versioning (Option A from earlier discussion)
   - Add versioning only if stability becomes an issue

4. **Should commands be able to force-load protocols?**
   - Optional enhancement for Phase 2
   - Start with agent autonomy

---

## Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Activation mechanism | Layered Hybrid | User preferred agent autonomy + safety net |
| Protocol location | `.claude/protocols/` | Separate from patterns (different purpose) |
| Index format | Markdown table + YAML headers | Self-describing, easy to parse |
| Security handling | Gatekeeper pattern | Security Auditor always loads protocol |
| Logging | workflow-log.md | Debug visibility, single location |
| Versioning | None (initially) | Premature optimization |

---

*Plan created: 2025-12-08*
*Ready for review and approval*
