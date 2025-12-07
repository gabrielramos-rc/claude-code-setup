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

*Add new ideas below*

---
