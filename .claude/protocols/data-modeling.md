---
name: data-modeling
description: >
  Database schema design including entity identification, relationship mapping,
  indexing strategy, constraints, and migration planning.
applies_to: [architect]
load_when: >
  Designing how data will be structured and stored in databases, including
  entity identification, relationship mapping, indexing strategy, constraints,
  and migration planning.
---

# Data Modeling Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Designing a new database schema
- Adding entities to existing schema
- Planning complex relationships between data
- Designing indexes for query patterns
- Migration strategy planning
- Data warehouse or analytics schema

**Do NOT load this protocol for:**
- Simple field additions to existing tables
- ORM implementation details (see Engineer's `database-implementation.md`)
- Query optimization (see `.claude/patterns/performance.md`)

---

## Database Technology Selection

| Type | Use When | Examples |
|------|----------|----------|
| **Relational (SQL)** | Structured data, ACID needed, complex queries | PostgreSQL, MySQL, SQLite |
| **Document** | Flexible schema, nested data, rapid iteration | MongoDB, CouchDB |
| **Key-Value** | Simple lookups, caching, sessions | Redis, DynamoDB |
| **Graph** | Relationship-heavy data, social networks | Neo4j, Amazon Neptune |
| **Time-Series** | Metrics, logs, IoT data | InfluxDB, TimescaleDB |
| **Vector** | AI embeddings, semantic search | Pinecone, pgvector, Weaviate |

### Selection Criteria

| Criterion | Relational | Document | Key-Value |
|-----------|------------|----------|-----------|
| Data structure | Fixed schema | Flexible | Simple |
| Relationships | Complex (joins) | Embedded/refs | None |
| Transactions | Full ACID | Limited | None/basic |
| Query flexibility | High (SQL) | Medium | Low |
| Horizontal scale | Moderate | Easy | Easy |

Document selection in `.claude/specs/tech-stack.md`.

---

## Entity-Relationship Design

### Step 1: Identify Entities

List all entities with their attributes and types:

```markdown
## User
- id: UUID (PK)
- email: string (unique, indexed)
- password_hash: string
- name: string (nullable)
- role: enum (user, admin)
- email_verified_at: timestamp (nullable)
- created_at: timestamp
- updated_at: timestamp

## Post
- id: UUID (PK)
- user_id: UUID (FK → User)
- title: string (max 200)
- slug: string (unique per user)
- content: text
- status: enum (draft, published, archived)
- published_at: timestamp (nullable, indexed)
- created_at: timestamp
- updated_at: timestamp
```

### Step 2: Define Relationships

| Relationship | Type | Implementation |
|--------------|------|----------------|
| User → Posts | One-to-Many | FK `user_id` on Post |
| Post → Tags | Many-to-Many | Junction table `post_tags` |
| User → Profile | One-to-One | FK on Profile or embed |
| Comment → Comment | Self-referential | `parent_id` FK (nullable) |
| User → User (follow) | Many-to-Many | Junction table `follows` |

### Relationship Patterns

**One-to-Many:**
```
┌─────────────┐       ┌─────────────┐
│    User     │       │    Post     │
├─────────────┤       ├─────────────┤
│ id (PK)     │──┐    │ id (PK)     │
│ email       │  └───<│ user_id(FK) │
│ name        │       │ title       │
└─────────────┘       └─────────────┘
```

**Many-to-Many:**
```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    Post     │       │  post_tags  │       │    Tag      │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │──┐    │ post_id(FK) │    ┌──│ id (PK)     │
│ title       │  └───<│ tag_id (FK) │>───┘  │ name        │
└─────────────┘       │ (PK: both)  │       └─────────────┘
                      └─────────────┘
```

**Self-Referential:**
```
┌─────────────────┐
│    Comment      │
├─────────────────┤
│ id (PK)         │
│ parent_id (FK)  │───┐
│ content         │   │
└────────┬────────┘   │
         └────────────┘
```

---

## Primary Key Strategy

| Strategy | Pros | Cons | Use When |
|----------|------|------|----------|
| **UUID v4** | Globally unique, no coordination | Larger, random (index fragmentation) | Distributed systems, public IDs |
| **UUID v7** | Time-sortable, globally unique | Larger than int | Distributed + time ordering |
| **Auto-increment** | Small, fast, sequential | Coordination needed, predictable | Single database, internal IDs |
| **ULID** | Sortable, URL-safe | Less common | Need sortable + URL-safe |

**Recommendation:** UUID v7 for new projects (sortable + distributed-friendly).

---

## Indexing Strategy

### Index Types

| Index Type | Use For | PostgreSQL |
|------------|---------|------------|
| B-tree (default) | Equality, range, sorting | `CREATE INDEX` |
| Hash | Equality only | `USING hash` |
| GIN | Arrays, JSONB, full-text | `USING gin` |
| GiST | Geometric, full-text | `USING gist` |
| BRIN | Large sequential data | `USING brin` |

### Index Design Rules

1. **Index foreign keys** - Always index FK columns
2. **Index WHERE clauses** - Columns frequently filtered
3. **Index ORDER BY** - Columns used for sorting
4. **Composite indexes** - Order matters (leftmost prefix)
5. **Covering indexes** - Include columns to avoid table lookup

### Example Index Design

```markdown
## Indexes

### Users
- PRIMARY: id
- UNIQUE: email
- INDEX: created_at DESC (for admin listings)

### Posts
- PRIMARY: id
- INDEX: user_id (FK lookups)
- INDEX: status, published_at DESC (for feeds)
- INDEX: user_id, slug (unique constraint)
- UNIQUE: user_id, slug

### Full-Text Search
- GIN INDEX: posts(title, content) using tsvector
```

### Composite Index Ordering

```sql
-- For query: WHERE user_id = ? AND status = ? ORDER BY created_at DESC
CREATE INDEX idx_posts_user_status_created
ON posts(user_id, status, created_at DESC);

-- Index can serve:
-- ✅ WHERE user_id = ?
-- ✅ WHERE user_id = ? AND status = ?
-- ✅ WHERE user_id = ? AND status = ? ORDER BY created_at DESC
-- ❌ WHERE status = ? (doesn't use leftmost column)
```

---

## Constraints

### Referential Integrity

| Action | Use When |
|--------|----------|
| `CASCADE` | Child meaningless without parent (post comments) |
| `SET NULL` | Child can exist independently (post author) |
| `RESTRICT` | Prevent accidental deletion |
| `NO ACTION` | Check at transaction end (for cycles) |

```markdown
## Foreign Key Behavior

- Post.user_id → User.id (ON DELETE SET NULL, ON UPDATE CASCADE)
- Comment.post_id → Post.id (ON DELETE CASCADE)
- Comment.user_id → User.id (ON DELETE SET NULL)
- PostTag.post_id → Post.id (ON DELETE CASCADE)
- PostTag.tag_id → Tag.id (ON DELETE CASCADE)
```

### Check Constraints

```sql
-- Value constraints
ALTER TABLE users ADD CONSTRAINT chk_email_format
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Length constraints
ALTER TABLE posts ADD CONSTRAINT chk_title_length
CHECK (char_length(title) BETWEEN 1 AND 200);

-- Enum constraints (if not using enum type)
ALTER TABLE posts ADD CONSTRAINT chk_status
CHECK (status IN ('draft', 'published', 'archived'));
```

### Unique Constraints

```sql
-- Simple unique
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);

-- Composite unique
ALTER TABLE posts ADD CONSTRAINT uq_posts_user_slug UNIQUE (user_id, slug);

-- Partial unique (only published posts need unique slug)
CREATE UNIQUE INDEX uq_posts_slug_published
ON posts(slug) WHERE status = 'published';
```

---

## Soft Delete vs Hard Delete

| Approach | Pros | Cons |
|----------|------|------|
| **Hard delete** | Simple, no bloat | Data loss, cascade issues |
| **Soft delete** | Audit trail, recovery | Query complexity, bloat |
| **Archive table** | Clean main table | More complex, two-phase |

### Soft Delete Pattern

```markdown
## Soft Delete

Add to applicable entities:
- deleted_at: timestamp (nullable, indexed)

Query pattern:
- Default: WHERE deleted_at IS NULL
- Include deleted: no filter
- Only deleted: WHERE deleted_at IS NOT NULL

Cascade behavior:
- Soft delete parent → soft delete children
- Hard delete after retention period (30 days)
```

---

## Timestamp Conventions

```markdown
## Standard Timestamp Fields

All entities include:
- created_at: timestamp NOT NULL DEFAULT now()
- updated_at: timestamp NOT NULL DEFAULT now()

Optional fields:
- deleted_at: timestamp (soft delete)
- published_at: timestamp (content publishing)
- expires_at: timestamp (time-limited records)
- last_login_at: timestamp (user activity)

Timezone:
- Store as UTC (timestamp with time zone)
- Convert to user timezone in application
```

---

## ER Diagram Output

Create ASCII diagram in `.claude/specs/data-model.md`:

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │       │    Post     │       │   Comment   │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │──┐    │ id (PK)     │──┐    │ id (PK)     │
│ email       │  │    │ user_id(FK) │  │    │ post_id(FK) │>──┐
│ name        │  └───<│ title       │  └───<│ user_id(FK) │   │
│ role        │       │ content     │       │ parent_id   │───┤
│ created_at  │       │ status      │       │ content     │   │
│ updated_at  │       │ published_at│       │ created_at  │<──┘
└─────────────┘       │ created_at  │       └─────────────┘
       │              └─────────────┘
       │                    │
       │              ┌─────────────┐       ┌─────────────┐
       │              │  post_tags  │       │    Tag      │
       │              ├─────────────┤       ├─────────────┤
       │              │ post_id(FK) │>──────│ id (PK)     │
       │              │ tag_id (FK) │       │ name        │
       │              └─────────────┘       │ slug        │
       │                                    └─────────────┘
       │
       │              ┌─────────────┐
       │              │   follows   │
       │              ├─────────────┤
       └─────────────<│ follower_id │
       └─────────────<│ following_id│
                      │ created_at  │
                      └─────────────┘
```

---

## Design Checklist

Before handing off to Engineer:

- [ ] All entities identified with attributes and types
- [ ] Primary key strategy decided (UUID v7 recommended)
- [ ] Relationships mapped with cardinality
- [ ] Foreign key behavior specified (CASCADE, SET NULL, RESTRICT)
- [ ] Indexes designed for expected query patterns
- [ ] Constraints defined (unique, check, not null)
- [ ] Soft delete vs hard delete decided
- [ ] Timestamp fields standardized
- [ ] Migration strategy documented
- [ ] ER diagram created

---

## Output

Write to `.claude/specs/data-model.md`:

```markdown
# Data Model

## Database Technology
**Choice:** PostgreSQL 15
**Rationale:** ACID compliance, complex queries, JSON support

## Primary Key Strategy
**Choice:** UUID v7
**Rationale:** Sortable, distributed-friendly

## Entity-Relationship Diagram
{ASCII diagram}

## Entities
{Detailed entity definitions}

## Relationships
{Relationship table with FK behavior}

## Indexes
{Index strategy by table}

## Constraints
{Unique, check, referential constraints}

## Soft Delete
**Approach:** deleted_at timestamp
**Retention:** 30 days before hard delete

## Migration Strategy
**Tool:** Prisma migrations / raw SQL
**Approach:** Forward-only, tested in staging
```

---

## Related

- `database-implementation.md` (Engineer) - ORM implementation
- `.claude/patterns/performance.md` - Query optimization

---

*Protocol created: 2025-12-08*
*Version: 1.0*
