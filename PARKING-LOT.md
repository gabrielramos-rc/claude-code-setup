# Parking Lot

Ideas captured during development sessions for future consideration.

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
**Status:** Parked

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
**Status:** Parked

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

*Add new ideas below*

---
