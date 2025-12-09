---
name: database-implementation
description: >
  Database operations using ORMs like Prisma or Drizzle, schema migrations,
  database connectivity setup, and repository patterns.
applies_to: [engineer]
load_when: >
  Implementing database operations using an ORM like Prisma or Drizzle,
  creating or modifying schema migrations, setting up database connectivity,
  or implementing repository patterns.
---

# Database Implementation Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Setting up database connectivity
- Implementing schema from Architect's data model
- Creating or modifying migrations
- Writing repository/data access layer
- Database seeding for development

**Do NOT load this protocol for:**
- Database schema design (Architect uses `data-modeling.md`)
- Batch data processing (use `data-batch.md`)
- Real-time data streaming (use `data-streaming.md`)
- Query optimization only (see `.claude/patterns/performance.md`)

**Prerequisites:**
- Read Architect's data model from `.claude/specs/data-model.md`
- Schema design decisions already made

---

## ORM/Database Tool Detection

First, identify the project's database tooling:

| Tool | Detection | Schema Location |
|------|-----------|-----------------|
| **Prisma** | `prisma/schema.prisma` exists | `prisma/schema.prisma` |
| **Drizzle** | `drizzle.config.ts` exists | `src/db/schema.ts` |
| **TypeORM** | `ormconfig.json` or `data-source.ts` | `src/entities/*.ts` |
| **Knex** | `knexfile.js/ts` exists | `migrations/*.js` |
| **Sequelize** | `.sequelizerc` or `config/config.json` | `models/*.js` |
| **Django** | `manage.py` + `models.py` | `app/models.py` |
| **SQLAlchemy** | `alembic.ini` exists | `models/*.py` |
| **Raw SQL** | `migrations/*.sql` only | `migrations/*.sql` |

---

## Prisma Implementation

### Setup

```bash
# Initialize Prisma (if not exists)
npx prisma init

# After writing schema
npx prisma validate
npx prisma generate
```

### Schema Pattern

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  name          String?
  passwordHash  String    @map("password_hash")
  role          Role      @default(USER)
  posts         Post[]
  comments      Comment[]
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")
  deletedAt     DateTime? @map("deleted_at")

  @@index([email])
  @@index([createdAt])
  @@map("users")
}

model Post {
  id          String    @id @default(uuid())
  title       String    @db.VarChar(200)
  slug        String
  content     String
  published   Boolean   @default(false)
  publishedAt DateTime? @map("published_at")
  author      User      @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId    String    @map("author_id")
  comments    Comment[]
  tags        Tag[]     @relation("PostTags")
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")

  @@unique([authorId, slug])
  @@index([authorId])
  @@index([publishedAt])
  @@map("posts")
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

### Migrations

```bash
# Create migration (development)
npx prisma migrate dev --name add_user_role

# Apply migrations (production)
npx prisma migrate deploy

# Reset database (development only!)
npx prisma migrate reset

# View database
npx prisma studio
```

### Client Usage Pattern

```typescript
// src/db/client.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

### Repository Pattern

```typescript
// src/repositories/user.repository.ts
import { prisma } from '../db/client';
import type { User, Prisma } from '@prisma/client';

export const userRepository = {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id, deletedAt: null },
    });
  },

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email, deletedAt: null },
    });
  },

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  },

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: { ...data, updatedAt: new Date() },
    });
  },

  async softDelete(id: string): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  },

  async list(params: {
    skip?: number;
    take?: number;
    cursor?: string;
    orderBy?: Prisma.UserOrderByWithRelationInput;
  }): Promise<User[]> {
    const { skip, take = 20, cursor, orderBy = { createdAt: 'desc' } } = params;

    return prisma.user.findMany({
      where: { deletedAt: null },
      skip,
      take,
      cursor: cursor ? { id: cursor } : undefined,
      orderBy,
    });
  },
};
```

---

## Drizzle Implementation

### Setup

```bash
# Initialize (if not exists)
npm install drizzle-orm postgres
npm install -D drizzle-kit
```

### Schema Pattern

```typescript
// src/db/schema.ts
import {
  pgTable,
  uuid,
  varchar,
  text,
  timestamp,
  boolean,
  index,
  uniqueIndex,
  pgEnum,
} from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const roleEnum = pgEnum('role', ['user', 'admin', 'moderator']);

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 100 }),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  role: roleEnum('role').default('user').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  deletedAt: timestamp('deleted_at'),
}, (table) => ({
  emailIdx: uniqueIndex('users_email_idx').on(table.email),
  createdAtIdx: index('users_created_at_idx').on(table.createdAt),
}));

export const posts = pgTable('posts', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: varchar('title', { length: 200 }).notNull(),
  slug: varchar('slug', { length: 200 }).notNull(),
  content: text('content').notNull(),
  published: boolean('published').default(false).notNull(),
  publishedAt: timestamp('published_at'),
  authorId: uuid('author_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  authorSlugIdx: uniqueIndex('posts_author_slug_idx').on(table.authorId, table.slug),
  authorIdx: index('posts_author_idx').on(table.authorId),
  publishedAtIdx: index('posts_published_at_idx').on(table.publishedAt),
}));

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));
```

### Migrations

```bash
# Generate migration
npx drizzle-kit generate

# Apply migration
npx drizzle-kit migrate

# View database
npx drizzle-kit studio
```

### Client Setup

```typescript
// src/db/client.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const connectionString = process.env.DATABASE_URL!;
const client = postgres(connectionString);

export const db = drizzle(client, { schema });
```

### Repository Pattern

```typescript
// src/repositories/user.repository.ts
import { eq, isNull, desc } from 'drizzle-orm';
import { db } from '../db/client';
import { users } from '../db/schema';

export const userRepository = {
  async findById(id: string) {
    const result = await db
      .select()
      .from(users)
      .where(eq(users.id, id))
      .where(isNull(users.deletedAt))
      .limit(1);
    return result[0] ?? null;
  },

  async create(data: typeof users.$inferInsert) {
    const result = await db.insert(users).values(data).returning();
    return result[0];
  },

  async update(id: string, data: Partial<typeof users.$inferInsert>) {
    const result = await db
      .update(users)
      .set({ ...data, updatedAt: new Date() })
      .where(eq(users.id, id))
      .returning();
    return result[0];
  },

  async list(params: { limit?: number; cursor?: string }) {
    const { limit = 20, cursor } = params;

    return db
      .select()
      .from(users)
      .where(isNull(users.deletedAt))
      .orderBy(desc(users.createdAt))
      .limit(limit + 1);  // +1 to check hasMore
  },
};
```

---

## Raw SQL Migrations

For projects without ORM:

### Migration File Pattern

```sql
-- migrations/20240115120000_create_users.sql

-- Up
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(100),
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Down
DROP TABLE IF EXISTS users;
```

### Naming Convention

```
YYYYMMDDHHMMSS_descriptive_action.sql

Examples:
20240115120000_create_users.sql
20240116090000_add_posts_table.sql
20240117140000_add_users_role_column.sql
20240118100000_create_posts_published_at_index.sql
```

---

## Safe Migration Practices

### Adding Columns

```sql
-- Safe: Has default value
ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';

-- Safe: Nullable
ALTER TABLE users ADD COLUMN bio TEXT;
```

### Adding Indexes

```sql
-- Safe: Concurrent (PostgreSQL, doesn't lock table)
CREATE INDEX CONCURRENTLY idx_users_role ON users(role);

-- Less safe: Locks table during creation
CREATE INDEX idx_users_role ON users(role);
```

### Removing Columns (Multi-step)

```sql
-- Step 1: Stop writing to column (code change)
-- Step 2: Deploy code that doesn't read column
-- Step 3: Drop column
ALTER TABLE users DROP COLUMN legacy_field;
```

### Renaming (Multi-step)

```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN display_name VARCHAR(100);

-- Step 2: Migrate data
UPDATE users SET display_name = name;

-- Step 3: Code change to use new column
-- Step 4: Drop old column
ALTER TABLE users DROP COLUMN name;
```

---

## Database Seeding

```typescript
// prisma/seed.ts (Prisma)
import { prisma } from '../src/db/client';

async function main() {
  // Clear existing data (development only)
  if (process.env.NODE_ENV === 'development') {
    await prisma.user.deleteMany();
  }

  // Create seed data
  const admin = await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin User',
      passwordHash: await hash('password123'),
      role: 'ADMIN',
    },
  });

  // Create related data
  await prisma.post.createMany({
    data: [
      { title: 'First Post', slug: 'first-post', content: '...', authorId: admin.id },
      { title: 'Second Post', slug: 'second-post', content: '...', authorId: admin.id },
    ],
  });

  console.log('Seeded database');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
```

```bash
# Run seed
npx prisma db seed
```

---

## Validation Commands

```bash
# Prisma
npx prisma validate           # Validate schema
npx prisma db push --dry-run  # Preview changes
npx prisma migrate status     # Check migration status

# Drizzle
npx drizzle-kit check         # Validate schema

# Connection test
npx prisma db execute --stdin <<< "SELECT 1"
```

---

## Environment Setup

Update `.env.example`:

```bash
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/dbname?schema=public"

# For connection pooling (production)
DATABASE_URL="postgresql://user:password@pooler.example.com:5432/dbname?pgbouncer=true"
DIRECT_URL="postgresql://user:password@direct.example.com:5432/dbname"
```

---

## Checklist

Before completing database implementation:

- [ ] Schema matches Architect's data model exactly
- [ ] All indexes from data model implemented
- [ ] Foreign key constraints match spec (CASCADE, SET NULL, etc.)
- [ ] Migration file created and tested locally
- [ ] Rollback tested (if applicable)
- [ ] Seed data created for development
- [ ] Environment variables documented (.env.example)
- [ ] Repository/data access layer implemented
- [ ] Client singleton pattern used (avoid connection leaks)

---

## Related

- `data-modeling.md` (Architect) - Schema design
- `data-batch.md` - Bulk operations, ETL
- `.claude/patterns/performance.md` - Query optimization

---

*Protocol created: 2025-12-08*
*Version: 1.0*
