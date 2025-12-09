# Protocol Index

> Registry of task-specific protocols for on-demand loading by agents

---

## How to Use This Index

### For Agents

1. **Receive your task** from the command or workflow
2. **Consult this index** to identify relevant protocols
3. **Analyze the "Load When"** descriptions to determine relevance
4. **Select 1-3 protocols** maximum (be selective, not exhaustive)
5. **State your selection:** "Loading protocols: [X, Y] because [reason]"
6. **Read the protocol** files and follow their guidance
7. **Log your decision** to `.claude/state/workflow-log.md`

### Selection Principles

- **Be selective** - Load only what the task clearly needs
- **When uncertain** - Err toward loading (downstream agents catch over-loading)
- **Max 2-3 protocols** - More creates cognitive overload
- **Explain your choice** - Creates audit trail for debugging

### If Protocols Were Injected

If the command already injected protocols via context, use those.
Only load additional protocols if you identify a critical gap.

---

## Architecture Protocols

*Primary user: Architect*

| Protocol | File | Load When |
|----------|------|-----------|
| REST API Design | `api-rest.md` | Designing traditional request-response APIs where clients call specific URL endpoints with HTTP methods to perform CRUD operations on resources. Covers endpoint structure, versioning, pagination, error formats, and OpenAPI specifications. |
| Real-time API Design | `api-realtime.md` | Designing APIs that require flexible client-driven queries (GraphQL), persistent bidirectional connections (WebSocket), or server-initiated updates (SSE). Covers schema design, subscriptions, and AsyncAPI specifications. |
| Data Modeling | `data-modeling.md` | Designing how data will be structured and stored in databases, including entity identification, relationship mapping, indexing strategy, constraints, and migration planning. |
| Frontend Architecture | `frontend-architecture.md` | Deciding how the user interface will be technically structured, including component hierarchy patterns, state management approach, styling methodology, and code splitting strategy. |

---

## Implementation Protocols

*Primary user: Engineer*

| Protocol | File | Load When |
|----------|------|-----------|
| Database Implementation | `database-implementation.md` | Implementing database operations using an ORM like Prisma or Drizzle, creating or modifying schema migrations, setting up database connectivity, or implementing repository patterns. |
| Batch Data Processing | `data-batch.md` | Implementing scheduled data processing jobs, ETL pipelines, bulk import/export operations, or any data transformation that runs on a fixed cadence rather than in response to events. |
| Stream Data Processing | `data-streaming.md` | Implementing real-time data processing, event-driven pipelines, message queue consumers, or any continuous data flow that reacts immediately to incoming data. |

---

## Testing Protocols

*Primary user: Tester*

| Protocol | File | Load When |
|----------|------|-----------|
| Unit Testing | `testing-unit.md` | Writing isolated tests for individual functions, classes, or modules that verify behavior without external dependencies like databases, APIs, or file systems. Covers mocking, assertions, and test organization. |
| Integration Testing | `testing-integration.md` | Writing tests that verify multiple components work together correctly, including database operations, API endpoint testing, and service-to-service communication. |
| End-to-End Testing | `testing-e2e.md` | Writing end-to-end tests that simulate real user workflows through the complete application stack, typically using browser automation tools like Playwright or Cypress. |

---

## Security Protocols

*Primary user: Security Auditor*

| Protocol | File | Load When |
|----------|------|-----------|
| Authentication | `authentication.md` | Implementing user identity verification including login flows, JWT or session token management, OAuth/OIDC integration, password policies, or multi-factor authentication. |
| Security Hardening | `security-hardening.md` | Reviewing code for OWASP Top 10 vulnerabilities, implementing input validation and output encoding, managing secrets, scanning dependencies, or hardening application configuration. |

---

## DevOps Protocols

*Primary user: DevOps*

| Protocol | File | Load When |
|----------|------|-----------|
| CI/CD Pipelines | `ci-cd.md` | Setting up or modifying automated pipelines that build, test, and deploy code in response to repository events. Covers GitHub Actions, GitLab CI, and general CI/CD patterns. |
| Containerization | `containerization.md` | Packaging applications into Docker containers, writing docker-compose configurations for local development, or setting up Kubernetes manifests and Helm charts for orchestrated deployments. |

---

## Cross-Cutting Protocols

*Primary user: Multiple agents*

| Protocol | File | Load When |
|----------|------|-----------|
| Observability | `observability.md` | Implementing logging infrastructure, metrics collection, distributed tracing, or alerting to understand and monitor system behavior in production. |
| Error Handling | `error-handling.md` | Designing how the application handles, reports, and recovers from failures across the stack, including error classification, retry strategies, circuit breakers, and graceful degradation. |
| Caching Strategies | `caching-strategies.md` | Implementing caching at any layer including in-memory caches, Redis, HTTP caching headers, or database query caching to improve performance. |
| Accessibility | `accessibility.md` | Implementing WCAG compliance, ensuring keyboard accessibility, adding screen reader support, or auditing accessibility of web applications. |
| Internationalization | `internationalization.md` | Implementing multi-language support, handling locale-specific formatting for dates, numbers, and currencies, or supporting RTL layouts. |
| API Versioning | `api-versioning.md` | Managing breaking API changes, implementing version negotiation, or migrating clients between API versions. |

---

## Specialized Protocols

*Primary user: Varies by protocol*

| Protocol | File | Load When |
|----------|------|-----------|
| Code Review Checklist | `code-review-checklist.md` | Performing structured code reviews covering correctness, performance, maintainability, security, and architecture compliance. |
| Documentation Patterns | `documentation-patterns.md` | Writing technical documentation including READMEs, API docs, architecture documentation, user guides, or contributing guides. |
| NoSQL Databases | `database-nosql.md` | Implementing NoSQL databases like MongoDB, Redis data structures, or DynamoDB for document storage, caching, or key-value operations. |
| Mobile Patterns | `mobile-patterns.md` | Implementing mobile applications with React Native, handling navigation, platform-specific code, or integrating native modules. |

---

## Protocol Status

| Protocol | Status | Lines |
|----------|--------|-------|
| `api-rest.md` | ✅ Complete | ~290 |
| `api-realtime.md` | ✅ Complete | ~320 |
| `data-modeling.md` | ✅ Complete | ~310 |
| `frontend-architecture.md` | ✅ Complete | ~380 |
| `database-implementation.md` | ✅ Complete | ~340 |
| `data-batch.md` | ✅ Complete | ~380 |
| `data-streaming.md` | ✅ Complete | ~350 |
| `testing-unit.md` | ✅ Complete | ~480 |
| `testing-integration.md` | ✅ Complete | ~570 |
| `testing-e2e.md` | ✅ Complete | ~510 |
| `authentication.md` | ✅ Complete | ~500 |
| `security-hardening.md` | ✅ Complete | ~550 |
| `ci-cd.md` | ✅ Complete | ~550 |
| `containerization.md` | ✅ Complete | ~480 |
| `observability.md` | ✅ Complete | ~500 |
| `error-handling.md` | ✅ Complete | ~500 |
| `caching-strategies.md` | ✅ Complete | ~450 |
| `accessibility.md` | ✅ Complete | ~570 |
| `internationalization.md` | ✅ Complete | ~485 |
| `api-versioning.md` | ✅ Complete | ~420 |
| `code-review-checklist.md` | ✅ Complete | ~400 |
| `documentation-patterns.md` | ✅ Complete | ~450 |
| `database-nosql.md` | ✅ Complete | ~475 |
| `mobile-patterns.md` | ✅ Complete | ~650 |

**Legend:** 🔲 Planned | 🚧 In Progress | ✅ Complete

**Total:** 24 protocols (~11,365 lines)

---

## Related Patterns (Not Protocols)

These are cross-cutting concerns in `.claude/patterns/`. Reference them, don't duplicate.

| Pattern | When to Reference |
|---------|-------------------|
| `performance.md` | Caching, optimization, and performance budgets across any protocol |
| `git-workflow.md` | Branch strategy and commit conventions |
| `input-safety.md` | Input validation patterns |
| `agent-collaboration.md` | Agent handoffs and escalation |
| `state-files.md` | State file schemas |

**Key distinction:**
- **Protocols** = Task-specific procedures (loaded on-demand)
- **Patterns** = Cross-cutting concerns (always available)

---

## Protocol Logging

After selecting protocols, append to `.claude/state/workflow-log.md`:

```markdown
### {Timestamp} - {Agent}

**Task:** {task description}
**Protocols Loaded:**
- `{protocol}.md` - {reason for loading}

**Protocols Considered but Skipped:**
- `{protocol}.md` - {reason for skipping}
```

See `.claude/patterns/state-files.md` for complete workflow-log schema.

---

*Index created: 2025-12-08*
*Version: 1.1 - All 26 protocols complete*
