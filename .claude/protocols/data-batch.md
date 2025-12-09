---
name: data-batch
description: >
  Batch data processing including ETL pipelines, scheduled jobs, bulk
  import/export operations, and data transformations on a fixed cadence.
applies_to: [engineer]
load_when: >
  Implementing scheduled data processing jobs, ETL pipelines, bulk
  import/export operations, or any data transformation that runs on
  a fixed cadence rather than in response to real-time events.
---

# Batch Data Processing Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- ETL/ELT pipelines
- Scheduled/cron jobs
- Bulk data imports from files (CSV, JSON, XML)
- Bulk data exports
- Data aggregation jobs
- Nightly/hourly batch processing
- Data warehouse loading
- Report generation

**Do NOT load this protocol for:**
- Real-time event processing (use `data-streaming.md`)
- Database schema changes (use `database-implementation.md`)
- Single-record CRUD operations
- API request handling

---

## Pipeline Architecture

### Simple ETL Pattern

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Extract   │────▶│  Transform  │────▶│    Load     │
│  (Source)   │     │ (Validate)  │     │  (Target)   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      ▼                   ▼                   ▼
  File/API           Clean data          Database
  Database           Enrich              File/API
  S3 bucket          Aggregate           Data warehouse
```

### Pipeline Result Interface

```typescript
// src/pipelines/types.ts
export interface PipelineResult {
  status: 'success' | 'partial' | 'failed';
  processed: number;
  failed: number;
  skipped: number;
  errors: Array<{
    row?: number;
    id?: string;
    error: string;
    data?: unknown;
  }>;
  startedAt: Date;
  completedAt: Date;
  durationMs: number;
}
```

---

## File Import Pipeline

### CSV Import

```typescript
// src/pipelines/import-users.ts
import { createReadStream } from 'fs';
import { parse } from 'csv-parse';
import { z } from 'zod';
import { db } from '../db/client';
import { users } from '../db/schema';
import type { PipelineResult } from './types';

// Validation schema
const userRowSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100).optional(),
  role: z.enum(['user', 'admin', 'moderator']).default('user'),
});

export async function importUsers(filePath: string): Promise<PipelineResult> {
  const startedAt = new Date();
  const result: PipelineResult = {
    status: 'success',
    processed: 0,
    failed: 0,
    skipped: 0,
    errors: [],
    startedAt,
    completedAt: startedAt,
    durationMs: 0,
  };

  const parser = createReadStream(filePath).pipe(
    parse({
      columns: true,
      skip_empty_lines: true,
      trim: true,
    })
  );

  const BATCH_SIZE = 1000;
  let batch: (typeof users.$inferInsert)[] = [];
  let rowNumber = 0;

  for await (const record of parser) {
    rowNumber++;

    try {
      // Validate
      const validated = userRowSchema.parse(record);

      // Transform
      batch.push({
        email: validated.email.toLowerCase(),
        name: validated.name || null,
        role: validated.role,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // Load in batches
      if (batch.length >= BATCH_SIZE) {
        await db.insert(users).values(batch).onConflictDoNothing();
        result.processed += batch.length;
        batch = [];

        // Progress logging
        console.log(`[Import] Processed ${result.processed} rows...`);
      }
    } catch (error) {
      result.failed++;
      result.errors.push({
        row: rowNumber,
        error: error instanceof Error ? error.message : String(error),
        data: record,
      });

      // Stop on too many errors
      if (result.failed > 100) {
        result.status = 'failed';
        break;
      }
    }
  }

  // Insert remaining batch
  if (batch.length > 0) {
    await db.insert(users).values(batch).onConflictDoNothing();
    result.processed += batch.length;
  }

  result.completedAt = new Date();
  result.durationMs = result.completedAt.getTime() - startedAt.getTime();
  result.status = result.failed > 0 ? 'partial' : 'success';

  console.log(`[Import] Complete: ${result.processed} processed, ${result.failed} failed`);
  return result;
}
```

### JSON Import

```typescript
// src/pipelines/import-products.ts
import { readFile } from 'fs/promises';

export async function importProducts(filePath: string): Promise<PipelineResult> {
  const startedAt = new Date();
  const content = await readFile(filePath, 'utf-8');
  const records = JSON.parse(content) as unknown[];

  const result: PipelineResult = { /* ... */ };

  // Process in batches
  for (let i = 0; i < records.length; i += BATCH_SIZE) {
    const batch = records.slice(i, i + BATCH_SIZE);
    const validated = batch.map((record, idx) => {
      try {
        return productSchema.parse(record);
      } catch (error) {
        result.errors.push({ row: i + idx, error: String(error) });
        return null;
      }
    }).filter(Boolean);

    if (validated.length > 0) {
      await db.insert(products).values(validated).onConflictDoUpdate({
        target: products.sku,
        set: { name: sql`EXCLUDED.name`, price: sql`EXCLUDED.price`, updatedAt: new Date() },
      });
      result.processed += validated.length;
    }
  }

  return result;
}
```

---

## Scheduled Jobs

### Cron Job Pattern

```typescript
// src/jobs/index.ts
import { CronJob } from 'cron';
import { dailyAggregation } from './daily-aggregation';
import { cleanupExpired } from './cleanup-expired';
import { generateReports } from './generate-reports';

export const jobs = {
  // Daily at 2 AM UTC
  dailyAggregation: new CronJob('0 2 * * *', dailyAggregation, null, false, 'UTC'),

  // Every hour
  cleanupExpired: new CronJob('0 * * * *', cleanupExpired, null, false, 'UTC'),

  // Weekly on Sunday at 3 AM
  weeklyReports: new CronJob('0 3 * * 0', generateReports, null, false, 'UTC'),
};

// Start all jobs
export function startJobs() {
  Object.entries(jobs).forEach(([name, job]) => {
    job.start();
    console.log(`[Jobs] Started: ${name}`);
  });
}

// Stop all jobs (for graceful shutdown)
export function stopJobs() {
  Object.entries(jobs).forEach(([name, job]) => {
    job.stop();
    console.log(`[Jobs] Stopped: ${name}`);
  });
}
```

### Aggregation Job

```typescript
// src/jobs/daily-aggregation.ts
import { db } from '../db/client';
import { sql } from 'drizzle-orm';

export async function dailyAggregation(): Promise<void> {
  const jobName = 'daily-aggregation';
  const startTime = Date.now();

  console.log(`[${jobName}] Starting...`);

  try {
    // Calculate yesterday's date
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    yesterday.setHours(0, 0, 0, 0);

    // Aggregate daily stats
    await db.execute(sql`
      INSERT INTO daily_stats (date, total_users, total_posts, active_users, new_signups)
      SELECT
        ${yesterday}::date,
        (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL),
        (SELECT COUNT(*) FROM posts WHERE created_at >= ${yesterday} AND created_at < ${yesterday} + INTERVAL '1 day'),
        (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE created_at >= ${yesterday} AND created_at < ${yesterday} + INTERVAL '1 day'),
        (SELECT COUNT(*) FROM users WHERE created_at >= ${yesterday} AND created_at < ${yesterday} + INTERVAL '1 day')
      ON CONFLICT (date) DO UPDATE SET
        total_users = EXCLUDED.total_users,
        total_posts = EXCLUDED.total_posts,
        active_users = EXCLUDED.active_users,
        new_signups = EXCLUDED.new_signups,
        updated_at = NOW()
    `);

    const duration = Date.now() - startTime;
    console.log(`[${jobName}] Completed in ${duration}ms`);

  } catch (error) {
    console.error(`[${jobName}] Failed:`, error);
    // Send alert (integrate with monitoring)
    throw error;
  }
}
```

### Cleanup Job

```typescript
// src/jobs/cleanup-expired.ts
import { db } from '../db/client';
import { lt, and, isNotNull } from 'drizzle-orm';
import { sessions, passwordResetTokens, verificationTokens } from '../db/schema';

export async function cleanupExpired(): Promise<void> {
  const jobName = 'cleanup-expired';
  console.log(`[${jobName}] Starting...`);

  const now = new Date();
  let totalDeleted = 0;

  // Cleanup expired sessions
  const sessionsDeleted = await db
    .delete(sessions)
    .where(lt(sessions.expiresAt, now))
    .returning({ id: sessions.id });
  totalDeleted += sessionsDeleted.length;

  // Cleanup expired password reset tokens
  const resetTokensDeleted = await db
    .delete(passwordResetTokens)
    .where(lt(passwordResetTokens.expiresAt, now))
    .returning({ id: passwordResetTokens.id });
  totalDeleted += resetTokensDeleted.length;

  // Cleanup expired verification tokens
  const verifyTokensDeleted = await db
    .delete(verificationTokens)
    .where(lt(verificationTokens.expiresAt, now))
    .returning({ id: verificationTokens.id });
  totalDeleted += verifyTokensDeleted.length;

  // Hard delete soft-deleted records older than 30 days
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  const usersHardDeleted = await db
    .delete(users)
    .where(and(isNotNull(users.deletedAt), lt(users.deletedAt, thirtyDaysAgo)))
    .returning({ id: users.id });
  totalDeleted += usersHardDeleted.length;

  console.log(`[${jobName}] Deleted ${totalDeleted} expired records`);
}
```

---

## Bulk Operations

### Bulk Update

```typescript
// src/pipelines/bulk-update.ts

export async function bulkUpdateStatus(
  userIds: string[],
  status: string
): Promise<{ updated: number }> {
  const BATCH_SIZE = 500;
  let updated = 0;

  for (let i = 0; i < userIds.length; i += BATCH_SIZE) {
    const batch = userIds.slice(i, i + BATCH_SIZE);

    const result = await db
      .update(users)
      .set({ status, updatedAt: new Date() })
      .where(inArray(users.id, batch))
      .returning({ id: users.id });

    updated += result.length;
    console.log(`[BulkUpdate] Progress: ${updated}/${userIds.length}`);
  }

  return { updated };
}
```

### Bulk Upsert

```typescript
// src/pipelines/sync-products.ts

export async function syncProducts(products: Product[]): Promise<PipelineResult> {
  const BATCH_SIZE = 500;
  const result: PipelineResult = { /* ... */ };

  for (let i = 0; i < products.length; i += BATCH_SIZE) {
    const batch = products.slice(i, i + BATCH_SIZE);

    await db
      .insert(productsTable)
      .values(batch)
      .onConflictDoUpdate({
        target: productsTable.sku,
        set: {
          name: sql`EXCLUDED.name`,
          price: sql`EXCLUDED.price`,
          stock: sql`EXCLUDED.stock`,
          updatedAt: new Date(),
        },
      });

    result.processed += batch.length;
  }

  return result;
}
```

---

## Export Pipeline

### CSV Export

```typescript
// src/pipelines/export-users.ts
import { createWriteStream } from 'fs';
import { stringify } from 'csv-stringify';
import { db } from '../db/client';
import { users } from '../db/schema';

export async function exportUsers(outputPath: string): Promise<{ exported: number }> {
  const BATCH_SIZE = 1000;
  let exported = 0;
  let cursor: string | undefined;

  const output = createWriteStream(outputPath);
  const stringifier = stringify({
    header: true,
    columns: ['id', 'email', 'name', 'role', 'created_at'],
  });
  stringifier.pipe(output);

  while (true) {
    const batch = await db
      .select({
        id: users.id,
        email: users.email,
        name: users.name,
        role: users.role,
        created_at: users.createdAt,
      })
      .from(users)
      .where(cursor ? gt(users.id, cursor) : undefined)
      .orderBy(users.id)
      .limit(BATCH_SIZE);

    if (batch.length === 0) break;

    for (const row of batch) {
      stringifier.write(row);
    }

    exported += batch.length;
    cursor = batch[batch.length - 1].id;

    console.log(`[Export] Exported ${exported} rows...`);
  }

  stringifier.end();

  return new Promise((resolve) => {
    output.on('finish', () => {
      console.log(`[Export] Complete: ${exported} rows to ${outputPath}`);
      resolve({ exported });
    });
  });
}
```

---

## Job Monitoring

### Job Wrapper with Monitoring

```typescript
// src/jobs/utils/job-wrapper.ts
import { metrics } from '../monitoring';

export function wrapJob(
  name: string,
  fn: () => Promise<void>
): () => Promise<void> {
  return async () => {
    const startTime = Date.now();
    const labels = { job: name };

    try {
      metrics.jobStarted.inc(labels);
      await fn();
      metrics.jobCompleted.inc({ ...labels, status: 'success' });
    } catch (error) {
      metrics.jobCompleted.inc({ ...labels, status: 'failed' });
      metrics.jobErrors.inc(labels);

      // Log and alert
      console.error(`[${name}] Failed:`, error);
      await alerting.send({
        severity: 'error',
        title: `Job Failed: ${name}`,
        message: error instanceof Error ? error.message : String(error),
      });

      throw error;
    } finally {
      const duration = Date.now() - startTime;
      metrics.jobDuration.observe(labels, duration);
    }
  };
}

// Usage
export const dailyAggregation = new CronJob(
  '0 2 * * *',
  wrapJob('daily-aggregation', runDailyAggregation),
  null,
  false,
  'UTC'
);
```

---

## CLI Runner

```typescript
// src/cli/run-pipeline.ts
import { program } from 'commander';
import { importUsers } from '../pipelines/import-users';
import { exportUsers } from '../pipelines/export-users';
import { dailyAggregation } from '../jobs/daily-aggregation';

program
  .command('import-users <file>')
  .description('Import users from CSV file')
  .action(async (file) => {
    const result = await importUsers(file);
    console.log(JSON.stringify(result, null, 2));
    process.exit(result.status === 'failed' ? 1 : 0);
  });

program
  .command('export-users <output>')
  .description('Export users to CSV file')
  .action(async (output) => {
    const result = await exportUsers(output);
    console.log(`Exported ${result.exported} users`);
  });

program
  .command('run-job <name>')
  .description('Run a job manually')
  .action(async (name) => {
    const jobs: Record<string, () => Promise<void>> = {
      'daily-aggregation': dailyAggregation,
    };

    if (!jobs[name]) {
      console.error(`Unknown job: ${name}`);
      process.exit(1);
    }

    await jobs[name]();
  });

program.parse();
```

```bash
# Run from command line
npx ts-node src/cli/run-pipeline.ts import-users ./data/users.csv
npx ts-node src/cli/run-pipeline.ts export-users ./exports/users.csv
npx ts-node src/cli/run-pipeline.ts run-job daily-aggregation
```

---

## Checklist

Before completing batch processing implementation:

- [ ] Pipeline handles errors gracefully (doesn't stop on single failure)
- [ ] Batch sizes appropriate for memory (100-1000 typical)
- [ ] Progress logging for long-running operations
- [ ] Idempotent operations (safe to re-run)
- [ ] Validation before database writes (Zod schemas)
- [ ] Result tracking (processed, failed, errors)
- [ ] Monitoring/alerting for job failures
- [ ] CLI runner for manual execution
- [ ] Documentation for cron schedules

---

## Related

- `data-streaming.md` - Real-time event processing
- `database-implementation.md` - Database setup
- `.claude/patterns/performance.md` - Query optimization

---

*Protocol created: 2025-12-08*
*Version: 1.0*
