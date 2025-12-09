---
name: testing-integration
description: >
  Integration testing patterns for verifying component interactions,
  API endpoints, database operations, and service-to-service communication.
applies_to: [tester]
load_when: >
  Writing tests that verify multiple components work together correctly,
  including database operations, API endpoint testing, and service-to-service
  communication.
---

# Integration Testing Protocol

## When to Use This Protocol

Load this protocol when:

- Testing API endpoints (HTTP request/response)
- Testing database operations with real database
- Testing service interactions
- Testing middleware and request pipelines
- Testing with real (or containerized) dependencies

**Do NOT load this protocol for:**
- Isolated function testing (use `testing-unit.md`)
- Browser-based user flow testing (use `testing-e2e.md`)

---

## Integration Test Characteristics

| Aspect | Requirement |
|--------|-------------|
| **Speed** | < 1s per test (acceptable: < 5s) |
| **Dependencies** | Real or containerized |
| **Database** | Test database (reset between suites) |
| **Network** | Allowed (localhost) |
| **Isolation** | Per-test cleanup |

---

## Test Database Setup

### Prisma

```typescript
// tests/helpers/db.ts
import { PrismaClient } from '@prisma/client';
import { execSync } from 'child_process';

const prisma = new PrismaClient();

export async function setupTestDb() {
  // Reset database to clean state
  execSync('npx prisma migrate reset --force --skip-seed', {
    env: { ...process.env, DATABASE_URL: process.env.TEST_DATABASE_URL },
  });
}

export async function cleanupTestDb() {
  // Delete all data (order matters for FK constraints)
  await prisma.comment.deleteMany();
  await prisma.post.deleteMany();
  await prisma.user.deleteMany();
}

export async function disconnectDb() {
  await prisma.$disconnect();
}

export { prisma };
```

### Drizzle

```typescript
// tests/helpers/db.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';
import * as schema from '../../src/db/schema';

const connectionString = process.env.TEST_DATABASE_URL!;
const client = postgres(connectionString);
export const db = drizzle(client, { schema });

export async function setupTestDb() {
  await migrate(db, { migrationsFolder: './drizzle' });
}

export async function cleanupTestDb() {
  await db.delete(schema.comments);
  await db.delete(schema.posts);
  await db.delete(schema.users);
}
```

### Test Lifecycle

```typescript
// tests/integration/setup.ts
import { beforeAll, afterAll, beforeEach } from 'vitest';
import { setupTestDb, cleanupTestDb, disconnectDb } from '../helpers/db';

beforeAll(async () => {
  await setupTestDb();
});

afterAll(async () => {
  await disconnectDb();
});

beforeEach(async () => {
  await cleanupTestDb();
});
```

---

## API Endpoint Testing

### Supertest (Express/Fastify)

```typescript
// tests/integration/api/users.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { app } from '../../../src/app';
import { prisma } from '../../helpers/db';
import { createUser } from '../../factories/user.factory';

describe('GET /api/users', () => {
  beforeEach(async () => {
    // Seed test data
    await prisma.user.createMany({
      data: [
        createUser({ email: 'user1@test.com' }),
        createUser({ email: 'user2@test.com' }),
      ],
    });
  });

  it('should return list of users', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body.data).toHaveLength(2);
    expect(response.body.data[0]).toHaveProperty('email');
  });

  it('should support pagination', async () => {
    const response = await request(app)
      .get('/api/users?limit=1')
      .expect(200);

    expect(response.body.data).toHaveLength(1);
    expect(response.body.pagination).toHaveProperty('hasMore', true);
  });
});

describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'new@test.com',
        name: 'New User',
        password: 'securePassword123',
      })
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('new@test.com');

    // Verify in database
    const user = await prisma.user.findUnique({
      where: { email: 'new@test.com' },
    });
    expect(user).not.toBeNull();
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'invalid-email',
        name: 'Test',
        password: 'password123',
      })
      .expect(400);

    expect(response.body.errors).toContainEqual(
      expect.objectContaining({ field: 'email' })
    );
  });

  it('should return 409 for duplicate email', async () => {
    await prisma.user.create({
      data: createUser({ email: 'existing@test.com' }),
    });

    await request(app)
      .post('/api/users')
      .send({
        email: 'existing@test.com',
        name: 'Duplicate',
        password: 'password123',
      })
      .expect(409);
  });
});
```

### Testing with Authentication

```typescript
// tests/helpers/auth.ts
import { generateToken } from '../../src/auth/jwt';
import { prisma } from './db';
import { createUser } from '../factories/user.factory';

export async function createAuthenticatedUser() {
  const user = await prisma.user.create({
    data: createUser(),
  });
  const token = generateToken(user.id);
  return { user, token };
}

// Usage in tests
describe('GET /api/profile', () => {
  it('should return user profile when authenticated', async () => {
    const { user, token } = await createAuthenticatedUser();

    const response = await request(app)
      .get('/api/profile')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body.id).toBe(user.id);
  });

  it('should return 401 without token', async () => {
    await request(app)
      .get('/api/profile')
      .expect(401);
  });

  it('should return 401 with invalid token', async () => {
    await request(app)
      .get('/api/profile')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);
  });
});
```

---

## Database Integration Tests

### Repository Testing

```typescript
// tests/integration/repositories/user.repository.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { userRepository } from '../../../src/repositories/user.repository';
import { prisma, cleanupTestDb } from '../../helpers/db';
import { createUser } from '../../factories/user.factory';

describe('UserRepository', () => {
  beforeEach(async () => {
    await cleanupTestDb();
  });

  describe('findById', () => {
    it('should return user when exists', async () => {
      const created = await prisma.user.create({
        data: createUser({ email: 'test@example.com' }),
      });

      const user = await userRepository.findById(created.id);

      expect(user).not.toBeNull();
      expect(user?.email).toBe('test@example.com');
    });

    it('should return null when not exists', async () => {
      const user = await userRepository.findById('non-existent-id');
      expect(user).toBeNull();
    });
  });

  describe('create', () => {
    it('should create and return user', async () => {
      const user = await userRepository.create({
        email: 'new@example.com',
        name: 'New User',
        passwordHash: 'hashed',
      });

      expect(user.id).toBeDefined();
      expect(user.email).toBe('new@example.com');

      // Verify persistence
      const found = await prisma.user.findUnique({
        where: { id: user.id },
      });
      expect(found).not.toBeNull();
    });

    it('should throw on duplicate email', async () => {
      await prisma.user.create({
        data: createUser({ email: 'existing@example.com' }),
      });

      await expect(
        userRepository.create({
          email: 'existing@example.com',
          name: 'Duplicate',
          passwordHash: 'hashed',
        })
      ).rejects.toThrow();
    });
  });
});
```

### Transaction Testing

```typescript
describe('transferFunds', () => {
  it('should transfer between accounts atomically', async () => {
    const from = await createAccount({ balance: 100 });
    const to = await createAccount({ balance: 50 });

    await transferFunds(from.id, to.id, 30);

    const updatedFrom = await prisma.account.findUnique({ where: { id: from.id } });
    const updatedTo = await prisma.account.findUnique({ where: { id: to.id } });

    expect(updatedFrom?.balance).toBe(70);
    expect(updatedTo?.balance).toBe(80);
  });

  it('should rollback on insufficient funds', async () => {
    const from = await createAccount({ balance: 10 });
    const to = await createAccount({ balance: 50 });

    await expect(transferFunds(from.id, to.id, 100)).rejects.toThrow('Insufficient funds');

    // Verify no changes
    const updatedFrom = await prisma.account.findUnique({ where: { id: from.id } });
    const updatedTo = await prisma.account.findUnique({ where: { id: to.id } });

    expect(updatedFrom?.balance).toBe(10);  // Unchanged
    expect(updatedTo?.balance).toBe(50);    // Unchanged
  });
});
```

---

## Service Integration Tests

### External Service Mocking

```typescript
// tests/integration/services/payment.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import nock from 'nock';
import { PaymentService } from '../../../src/services/payment';

describe('PaymentService', () => {
  beforeEach(() => {
    nock.cleanAll();
  });

  it('should process payment successfully', async () => {
    // Mock Stripe API
    nock('https://api.stripe.com')
      .post('/v1/charges')
      .reply(200, {
        id: 'ch_123',
        status: 'succeeded',
        amount: 1000,
      });

    const service = new PaymentService();
    const result = await service.charge({
      amount: 1000,
      currency: 'usd',
      source: 'tok_visa',
    });

    expect(result.status).toBe('succeeded');
    expect(result.id).toBe('ch_123');
  });

  it('should handle payment failure', async () => {
    nock('https://api.stripe.com')
      .post('/v1/charges')
      .reply(402, {
        error: {
          type: 'card_error',
          message: 'Your card was declined.',
        },
      });

    const service = new PaymentService();

    await expect(
      service.charge({ amount: 1000, currency: 'usd', source: 'tok_declined' })
    ).rejects.toThrow('Your card was declined.');
  });
});
```

### Message Queue Testing

```typescript
// tests/integration/queues/email.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { emailQueue, emailWorker } from '../../../src/queues/email';

describe('Email Queue', () => {
  beforeEach(async () => {
    await emailQueue.drain();  // Clear queue
  });

  afterEach(async () => {
    await emailWorker.close();
  });

  it('should process email job', async () => {
    const jobData = {
      to: 'test@example.com',
      subject: 'Test',
      template: 'welcome',
    };

    const job = await emailQueue.add('send', jobData);

    // Wait for processing
    const result = await job.waitUntilFinished(emailWorker);

    expect(result.sent).toBe(true);
  });
});
```

---

## Test Containers (Docker)

For consistent test environments:

```typescript
// tests/helpers/containers.ts
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { RedisContainer } from '@testcontainers/redis';

let postgresContainer: PostgreSqlContainer;
let redisContainer: RedisContainer;

export async function startContainers() {
  postgresContainer = await new PostgreSqlContainer()
    .withDatabase('test')
    .start();

  redisContainer = await new RedisContainer().start();

  process.env.TEST_DATABASE_URL = postgresContainer.getConnectionUri();
  process.env.TEST_REDIS_URL = redisContainer.getConnectionUrl();
}

export async function stopContainers() {
  await postgresContainer?.stop();
  await redisContainer?.stop();
}
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globalSetup: './tests/helpers/global-setup.ts',
    setupFiles: ['./tests/integration/setup.ts'],
  },
});
```

---

## File Organization

```
tests/
├── integration/
│   ├── setup.ts              # Lifecycle hooks
│   ├── api/
│   │   ├── users.test.ts
│   │   ├── posts.test.ts
│   │   └── auth.test.ts
│   ├── repositories/
│   │   ├── user.repository.test.ts
│   │   └── post.repository.test.ts
│   └── services/
│       ├── payment.test.ts
│       └── email.test.ts
├── helpers/
│   ├── db.ts                 # Database utilities
│   ├── auth.ts               # Auth helpers
│   └── containers.ts         # Test containers
└── factories/
    └── user.factory.ts
```

---

## Running Integration Tests

```bash
# Run all integration tests
npx vitest run tests/integration/

# Run specific suite
npx vitest run tests/integration/api/

# Run with coverage
npx vitest run tests/integration/ --coverage

# Run with verbose output
npx vitest run tests/integration/ --reporter=verbose
```

---

## Checklist

Before completing integration tests:

- [ ] Test database properly isolated (TEST_DATABASE_URL)
- [ ] Database reset between test suites
- [ ] All CRUD operations tested
- [ ] Authentication flows tested
- [ ] Error responses validated (400, 401, 404, 409)
- [ ] External services mocked (nock)
- [ ] Transactions and rollbacks tested
- [ ] No test pollution (tests pass in any order)
- [ ] Tests complete in reasonable time (< 30s total)

---

## Related

- `testing-unit.md` - Isolated function testing
- `testing-e2e.md` - Full user flow testing
- `database-implementation.md` - Database setup

---

*Protocol created: 2025-12-08*
*Version: 1.0*
