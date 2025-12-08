# Multi-Repo Architecture Pattern

**Status:** Documentation only (v0.3). Implementation planned for v0.4.

This pattern documents how to evolve from a single project to multi-repo architecture while maintaining AI agent effectiveness.

---

## Overview

Modern applications often evolve through these stages:

```
Stage 1: Modular Monolith  →  Single repo, module boundaries
Stage 2: Multi-Repo        →  Separate repos, shared types
Stage 3: Event-Driven      →  Async communication, event schemas
```

Each stage has different tradeoffs for AI agentic coding.

---

## AI Agent Considerations

| Factor | Single Repo | Multi-Repo |
|--------|-------------|------------|
| Context focus | Diluted (all code) | Focused (one service) |
| File discovery | More files to search | Fewer, relevant files |
| Cross-cutting changes | One commit | Coordination needed |
| Token cost | Higher (larger tree) | Lower per session |

**Key insight:** AI agents work best with focused context. Multi-repo enables this but requires coordination for cross-cutting changes.

---

## Stage 1: Modular Monolith

**When:** Starting a new project or small team.

### Structure

```
my-app/
├── src/
│   ├── modules/
│   │   ├── users/
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   ├── users.repository.ts
│   │   │   └── index.ts          ← Public API
│   │   ├── orders/
│   │   │   ├── orders.controller.ts
│   │   │   ├── orders.service.ts
│   │   │   └── index.ts
│   │   └── shared/
│   │       ├── types.ts
│   │       └── utils.ts
│   └── index.ts
├── tests/
├── CLAUDE.md
└── .claude/
    └── specs/
        └── architecture.md
```

### Architecture Spec

Add to `.claude/specs/architecture.md`:

```markdown
## Module Boundaries

### Rules
1. Modules communicate via exported interfaces only
2. No direct imports between module internals
3. Shared code goes in `src/modules/shared/`
4. Each module has a single `index.ts` that exports public API

### Module Structure
Each module follows this structure:
- `*.controller.ts` - HTTP/API handlers
- `*.service.ts` - Business logic
- `*.repository.ts` - Data access
- `index.ts` - Public exports only

### Import Rules
```typescript
// ✅ GOOD - Import from module's public API
import { createUser } from '../users';

// ❌ BAD - Import from module internals
import { UserService } from '../users/users.service';
```

### Preparing for Split
When a module becomes a candidate for extraction:
1. Ensure all imports go through `index.ts`
2. Define clear interface types
3. Document async boundaries (what could be an event?)
4. Measure: if module changes independently >80% of time, consider split
```

### Framework Impact

**None.** Current framework handles modular monolith perfectly.

---

## Stage 2: Multi-Repo Services

**When:**
- Teams need independent deployment cycles
- Module changes independently >80% of time
- Different scaling requirements
- Technology divergence needed

### When to Split

| Signal | Threshold | Action |
|--------|-----------|--------|
| Independent changes | >80% of commits | Consider split |
| Team ownership | Dedicated team | Split |
| Scale requirements | 10x difference | Split |
| Tech stack | Different runtime | Split |

### Structure

```
# Organization/Company level
mycompany/
├── ecommerce-types/     ← Shared contracts
├── ecommerce-api/       ← Backend service
├── ecommerce-web/       ← Frontend app
└── ecommerce-platform/  ← Orchestration (optional)
```

### Shared Types Repo

```
ecommerce-types/
├── src/
│   ├── user.ts
│   ├── order.ts
│   ├── product.ts
│   └── index.ts
├── package.json
├── tsconfig.json
└── CLAUDE.md
```

**package.json:**
```json
{
  "name": "@mycompany/ecommerce-types",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  }
}
```

**Example type:**
```typescript
// src/order.ts
export type OrderStatus = 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled';

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  status: OrderStatus;
  total: number;
  createdAt: Date;
}

export interface CreateOrderInput {
  userId: string;
  items: Array<{
    productId: string;
    quantity: number;
  }>;
}
```

### Service Repo

```
ecommerce-api/
├── src/
│   ├── routes/
│   ├── services/
│   └── index.ts
├── package.json
├── CLAUDE.md
└── .claude/
    └── specs/
        └── architecture.md
```

**CLAUDE.md:**
```markdown
# E-commerce API

## Overview
Backend API service for e-commerce platform.

## Tech Stack
- Runtime: Node.js 20
- Framework: Express
- Database: PostgreSQL + Prisma

## Shared Types
Types imported from `@mycompany/ecommerce-types`.

**IMPORTANT:** Do NOT duplicate type definitions. Always import from shared package.

## Related Repositories
- Types: github.com/mycompany/ecommerce-types
- Frontend: github.com/mycompany/ecommerce-web
```

### Publishing Types

```bash
# NPM (public)
npm publish --access public

# NPM (private/scoped)
npm publish --access restricted

# GitHub Packages
npm publish --registry=https://npm.pkg.github.com

# Verdaccio (self-hosted)
npm publish --registry=http://localhost:4873
```

### Consuming Types

```bash
# Install in service repos
npm install @mycompany/ecommerce-types

# Use in code
import { Order, CreateOrderInput } from '@mycompany/ecommerce-types';
```

### Coordination Patterns

#### Pattern A: Sequential (Simple)

```
1. Update types → publish
2. Update backend → deploy
3. Update frontend → deploy
```

Best for: Rare cross-cutting changes, different teams.

#### Pattern B: Beta Channel (Parallel Development)

```bash
# Types repo - publish beta
npm version prerelease --preid=beta  # 1.1.0-beta.1
npm publish --tag beta

# Service repos - use beta during development
npm install @mycompany/ecommerce-types@beta

# When ready - promote to stable
npm version minor  # 1.1.0
npm publish
```

Best for: Coordinated features, same team.

#### Pattern C: Local Linking (Development)

```bash
# Link during development
cd ecommerce-types && npm link
cd ../ecommerce-api && npm link @mycompany/ecommerce-types

# Changes reflect immediately (no publish needed)
```

Best for: Active development, fast iteration.

### Orchestration Repo (Optional)

For coordinated releases across repos:

```
ecommerce-platform/
├── .claude/
│   ├── commands/
│   │   └── release.md
│   └── specs/
│       ├── repos.md
│       └── dependencies.md
├── repos/                  ← Git submodules
│   ├── types/
│   ├── api/
│   └── web/
└── CLAUDE.md
```

**repos.md:**
```markdown
# Repository Registry

| Repo | Purpose | Depends On | Deploy Order |
|------|---------|------------|--------------|
| ecommerce-types | Shared types | None | 1 |
| ecommerce-api | Backend API | types | 2 |
| ecommerce-web | Frontend | types | 3 |
```

### AI Agent Workflow

Each repo gets its own Claude Code session:

```bash
# Work on backend
cd ecommerce-api
claude
> /project:implement add shipping endpoint

# Work on frontend (separate session)
cd ecommerce-web
claude
> /project:implement shipping address form
```

**Benefits:**
- Focused context per session
- Lower token costs
- Clear boundaries
- Independent work

---

## Stage 3: Event-Driven Architecture

**When:**
- Services need async communication
- Eventual consistency is acceptable
- High throughput requirements
- Decoupled service lifecycles

### Additional Repo: Events

```
ecommerce-events/
├── src/
│   ├── order-placed.ts
│   ├── payment-completed.ts
│   ├── order-shipped.ts
│   └── index.ts
├── package.json
└── CLAUDE.md
```

**Event schema:**
```typescript
// src/order-placed.ts
export interface OrderPlacedEvent {
  type: 'ORDER_PLACED';
  version: '1.0';
  payload: {
    orderId: string;
    userId: string;
    total: number;
    items: Array<{
      productId: string;
      quantity: number;
    }>;
  };
  metadata: {
    timestamp: string;
    correlationId: string;
    causationId?: string;
  };
}
```

### Event Catalog Spec

Add to orchestration repo `.claude/specs/events.md`:

```markdown
# Event Catalog

## Events

| Event | Producer | Consumers | Schema Version |
|-------|----------|-----------|----------------|
| OrderPlaced | api | payment, notification | 1.0 |
| PaymentCompleted | payment | api, notification | 1.0 |
| OrderShipped | api | notification | 1.0 |

## Compatibility Rules

### Non-Breaking Changes (Minor Version)
- Add optional field
- Add new event type
- Deprecate field (keep in schema)

### Breaking Changes (Major Version)
- Remove field
- Change field type
- Rename field
- Change field semantics

## Event Versioning Strategy

Option A: Version in type name
```typescript
interface OrderPlacedV1 { ... }
interface OrderPlacedV2 { ... }
```

Option B: Version field
```typescript
interface OrderPlaced {
  version: '1.0' | '2.0';
  payload: OrderPlacedPayloadV1 | OrderPlacedPayloadV2;
}
```

Recommended: Option B (cleaner, single type to import)
```

### Service Structure with Events

```
payment-service/
├── src/
│   ├── handlers/
│   │   └── order-placed.handler.ts  ← Event consumer
│   ├── publishers/
│   │   └── payment-completed.ts     ← Event producer
│   └── index.ts
├── package.json
└── CLAUDE.md
```

**Consumer:**
```typescript
import { OrderPlacedEvent } from '@mycompany/ecommerce-events';

export async function handleOrderPlaced(event: OrderPlacedEvent) {
  // Process payment
  const result = await processPayment(event.payload);

  // Publish completion event
  await publishPaymentCompleted({
    orderId: event.payload.orderId,
    status: result.status,
    correlationId: event.metadata.correlationId,
  });
}
```

---

## Migration Checklist

### Monolith → Multi-Repo

- [ ] Identify module with >80% independent changes
- [ ] Ensure all imports go through module's `index.ts`
- [ ] Extract shared types to separate package
- [ ] Create service repo with own CLAUDE.md
- [ ] Update CI/CD for independent deployment
- [ ] Document in orchestration repo (if exists)

### Multi-Repo → Event-Driven

- [ ] Identify sync calls that could be async
- [ ] Define event schemas in events package
- [ ] Choose message broker (Kafka, RabbitMQ, SQS, etc.)
- [ ] Implement event producers in source services
- [ ] Implement event consumers in target services
- [ ] Add event catalog documentation
- [ ] Update architecture specs with async boundaries

---

## Framework Integration (v0.4 Planned)

### Planned Commands

| Command | Purpose |
|---------|---------|
| `/project:init-platform` | Create orchestration repo |
| `/project:add-service` | Add new service repo |
| `/project:sync-types` | Update shared types across repos |
| `/project:release` | Coordinated release train |

### Planned Specs

| Spec | Purpose |
|------|---------|
| `repos.md` | Repository registry |
| `dependencies.md` | Cross-repo dependency graph |
| `events.md` | Event catalog |

### Planned Agent Updates

| Agent | Addition |
|-------|----------|
| Architect | Multi-repo design section |
| Architect | Event-driven design section |
| DevOps | Cross-repo CI/CD patterns |

---

## Current Workarounds (v0.3)

Until v0.4 implementation:

1. **Work from service directory:**
   ```bash
   cd ecommerce-api
   claude  # Scoped to this service
   ```

2. **Manual type updates:**
   ```bash
   npm update @mycompany/ecommerce-types
   ```

3. **Sequential releases:**
   - Publish types first
   - Update and deploy services in dependency order

4. **Document in each repo's CLAUDE.md:**
   - List related repositories
   - Document shared type package
   - Note deployment order

---

## Decision Framework

```
How often do cross-cutting changes happen?

Monthly or less  → Multi-repo ✅
   • AI agents work great (focused context)
   • Occasional coordination is acceptable

Weekly          → Evaluate tradeoffs
   • Multi-repo: More coordination overhead
   • Monorepo: More context for AI to handle

Daily           → Consider monorepo
   • Coordination cost exceeds AI benefits
   • Atomic commits more valuable
```

---

## References

- [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [Monorepo vs Multi-repo](https://github.com/joelparkerhenderson/monorepo-vs-polyrepo)
- [Event-Driven Architecture Patterns](https://martinfowler.com/articles/201701-event-driven.html)
