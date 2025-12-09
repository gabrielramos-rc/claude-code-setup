---
name: data-streaming
description: >
  Real-time data processing including event-driven pipelines, message queue
  consumers, WebSocket handlers, and continuous data flows.
applies_to: [engineer]
load_when: >
  Implementing real-time data processing, event-driven pipelines, message
  queue consumers, or any continuous data flow that reacts immediately
  to incoming data rather than running on a fixed schedule.
---

# Data Streaming Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Message queue consumers (Redis, RabbitMQ, SQS, Kafka)
- Event-driven data pipelines
- Real-time data transformations
- WebSocket message handlers
- Server-Sent Events (SSE) data sources
- Pub/Sub patterns
- Change Data Capture (CDC)

**Do NOT load this protocol for:**
- Scheduled batch jobs (use `data-batch.md`)
- One-time data imports (use `data-batch.md`)
- Database schema changes (use `database-implementation.md`)
- API endpoint design (Architect uses `api-realtime.md`)

---

## Event-Driven Architecture

### Event Flow Pattern

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Producer  │────▶│    Queue    │────▶│  Consumer   │
│  (Source)   │     │  (Buffer)   │     │ (Handler)   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      ▼                   ▼                   ▼
  API request        Redis/SQS/         Process event
  DB change          RabbitMQ           Update DB
  Webhook            Kafka              Send notification
```

### Event Interface

```typescript
// src/events/types.ts
export interface Event<T = unknown> {
  id: string;
  type: string;
  payload: T;
  timestamp: Date;
  metadata: {
    source: string;
    correlationId?: string;
    userId?: string;
  };
}

export interface EventHandler<T = unknown> {
  type: string;
  handle: (event: Event<T>) => Promise<void>;
}
```

---

## Redis Pub/Sub

### Publisher

```typescript
// src/events/publisher.ts
import Redis from 'ioredis';
import { v4 as uuid } from 'uuid';
import type { Event } from './types';

const redis = new Redis(process.env.REDIS_URL);

export async function publish<T>(
  type: string,
  payload: T,
  metadata?: Partial<Event['metadata']>
): Promise<string> {
  const event: Event<T> = {
    id: uuid(),
    type,
    payload,
    timestamp: new Date(),
    metadata: {
      source: process.env.SERVICE_NAME || 'api',
      ...metadata,
    },
  };

  await redis.publish(type, JSON.stringify(event));
  return event.id;
}

// Usage
await publish('user.created', { userId: '123', email: 'user@example.com' });
await publish('order.completed', { orderId: '456', total: 99.99 });
```

### Subscriber

```typescript
// src/events/subscriber.ts
import Redis from 'ioredis';
import type { Event, EventHandler } from './types';

export class EventSubscriber {
  private redis: Redis;
  private handlers: Map<string, EventHandler[]> = new Map();

  constructor() {
    this.redis = new Redis(process.env.REDIS_URL);
  }

  register<T>(handler: EventHandler<T>): void {
    const existing = this.handlers.get(handler.type) || [];
    this.handlers.set(handler.type, [...existing, handler as EventHandler]);
  }

  async start(): Promise<void> {
    const channels = Array.from(this.handlers.keys());

    if (channels.length === 0) {
      console.warn('[Subscriber] No handlers registered');
      return;
    }

    await this.redis.subscribe(...channels);
    console.log(`[Subscriber] Listening to: ${channels.join(', ')}`);

    this.redis.on('message', async (channel, message) => {
      const event = JSON.parse(message) as Event;
      const handlers = this.handlers.get(channel) || [];

      for (const handler of handlers) {
        try {
          await handler.handle(event);
        } catch (error) {
          console.error(`[Subscriber] Handler failed for ${channel}:`, error);
          // Add to dead letter queue or retry
        }
      }
    });
  }

  async stop(): Promise<void> {
    await this.redis.unsubscribe();
    await this.redis.quit();
  }
}
```

### Handler Registration

```typescript
// src/events/handlers/index.ts
import { EventSubscriber } from '../subscriber';
import { userCreatedHandler } from './user-created';
import { orderCompletedHandler } from './order-completed';

export function setupEventHandlers(): EventSubscriber {
  const subscriber = new EventSubscriber();

  subscriber.register(userCreatedHandler);
  subscriber.register(orderCompletedHandler);

  return subscriber;
}

// src/events/handlers/user-created.ts
import type { EventHandler } from '../types';
import { sendWelcomeEmail } from '../../services/email';

interface UserCreatedPayload {
  userId: string;
  email: string;
}

export const userCreatedHandler: EventHandler<UserCreatedPayload> = {
  type: 'user.created',
  async handle(event) {
    console.log(`[Handler] Processing user.created: ${event.id}`);

    await sendWelcomeEmail(event.payload.email);

    console.log(`[Handler] Completed user.created: ${event.id}`);
  },
};
```

---

## Redis Queue (BullMQ)

### Queue Setup

```typescript
// src/queues/email.queue.ts
import { Queue, Worker, Job } from 'bullmq';

const connection = {
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT || '6379'),
};

// Queue (for adding jobs)
export const emailQueue = new Queue('email', { connection });

// Worker (for processing jobs)
export const emailWorker = new Worker(
  'email',
  async (job: Job) => {
    const { to, subject, template, data } = job.data;

    console.log(`[Email] Processing job ${job.id}: ${subject}`);

    await sendEmail({ to, subject, template, data });

    return { sent: true, to };
  },
  {
    connection,
    concurrency: 5,  // Process 5 emails concurrently
  }
);

// Event handlers
emailWorker.on('completed', (job, result) => {
  console.log(`[Email] Completed ${job.id}:`, result);
});

emailWorker.on('failed', (job, error) => {
  console.error(`[Email] Failed ${job?.id}:`, error);
});
```

### Adding Jobs

```typescript
// src/services/notification.ts
import { emailQueue } from '../queues/email.queue';

export async function sendWelcomeEmail(email: string): Promise<void> {
  await emailQueue.add(
    'welcome',
    {
      to: email,
      subject: 'Welcome!',
      template: 'welcome',
      data: { email },
    },
    {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 1000,
      },
      removeOnComplete: 100,  // Keep last 100 completed
      removeOnFail: 1000,     // Keep last 1000 failed
    }
  );
}

// Delayed job
export async function sendReminderEmail(email: string, delayMs: number): Promise<void> {
  await emailQueue.add(
    'reminder',
    { to: email, subject: 'Reminder', template: 'reminder', data: {} },
    { delay: delayMs }
  );
}

// Scheduled/recurring job
export async function scheduleDigestEmail(email: string): Promise<void> {
  await emailQueue.add(
    'digest',
    { to: email, subject: 'Weekly Digest', template: 'digest', data: {} },
    {
      repeat: {
        pattern: '0 9 * * 1',  // Every Monday at 9 AM
      },
    }
  );
}
```

---

## WebSocket Message Handler

### Message Router

```typescript
// src/websocket/router.ts
import type { WebSocket } from 'ws';
import type { Event } from '../events/types';

type MessageHandler = (ws: WebSocket, payload: unknown) => Promise<void>;

export class WebSocketRouter {
  private handlers: Map<string, MessageHandler> = new Map();

  register(type: string, handler: MessageHandler): void {
    this.handlers.set(type, handler);
  }

  async route(ws: WebSocket, message: string): Promise<void> {
    let event: Event;

    try {
      event = JSON.parse(message);
    } catch {
      this.sendError(ws, 'invalid_json', 'Message must be valid JSON');
      return;
    }

    const handler = this.handlers.get(event.type);

    if (!handler) {
      this.sendError(ws, 'unknown_type', `Unknown message type: ${event.type}`);
      return;
    }

    try {
      await handler(ws, event.payload);
    } catch (error) {
      console.error(`[WS] Handler error for ${event.type}:`, error);
      this.sendError(ws, 'handler_error', 'Internal error processing message');
    }
  }

  private sendError(ws: WebSocket, code: string, message: string): void {
    ws.send(JSON.stringify({
      type: 'error',
      payload: { code, message },
      timestamp: new Date().toISOString(),
    }));
  }
}
```

### WebSocket Handlers

```typescript
// src/websocket/handlers/chat.ts
import type { WebSocket } from 'ws';
import { db } from '../../db/client';
import { messages } from '../../db/schema';
import { broadcast } from '../broadcast';

export async function handleSendMessage(
  ws: WebSocket,
  payload: { channelId: string; content: string }
): Promise<void> {
  const userId = (ws as any).userId;  // Set during auth

  // Save to database
  const [message] = await db
    .insert(messages)
    .values({
      channelId: payload.channelId,
      userId,
      content: payload.content,
    })
    .returning();

  // Broadcast to channel
  await broadcast(payload.channelId, {
    type: 'message.created',
    payload: message,
    timestamp: new Date().toISOString(),
  });
}

export async function handleTyping(
  ws: WebSocket,
  payload: { channelId: string }
): Promise<void> {
  const userId = (ws as any).userId;

  await broadcast(payload.channelId, {
    type: 'user.typing',
    payload: { userId, channelId: payload.channelId },
    timestamp: new Date().toISOString(),
  }, userId);  // Exclude sender
}
```

---

## Server-Sent Events (SSE)

### SSE Endpoint

```typescript
// src/routes/events.ts
import { Router } from 'express';
import { subscribeToUserEvents } from '../events/user-events';

const router = Router();

router.get('/events/stream', async (req, res) => {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  // SSE headers
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  // Send initial connection event
  res.write(`event: connected\ndata: ${JSON.stringify({ userId })}\n\n`);

  // Heartbeat every 30s
  const heartbeat = setInterval(() => {
    res.write(`event: heartbeat\ndata: ${Date.now()}\n\n`);
  }, 30000);

  // Subscribe to user events
  const unsubscribe = subscribeToUserEvents(userId, (event) => {
    res.write(`event: ${event.type}\nid: ${event.id}\ndata: ${JSON.stringify(event.payload)}\n\n`);
  });

  // Cleanup on disconnect
  req.on('close', () => {
    clearInterval(heartbeat);
    unsubscribe();
    console.log(`[SSE] Client disconnected: ${userId}`);
  });
});

export default router;
```

---

## Change Data Capture (CDC)

### PostgreSQL LISTEN/NOTIFY

```typescript
// src/cdc/postgres-listener.ts
import { Client } from 'pg';

export class PostgresChangeListener {
  private client: Client;
  private handlers: Map<string, (payload: unknown) => Promise<void>> = new Map();

  constructor() {
    this.client = new Client(process.env.DATABASE_URL);
  }

  onTableChange(table: string, handler: (payload: unknown) => Promise<void>): void {
    this.handlers.set(table, handler);
  }

  async start(): Promise<void> {
    await this.client.connect();

    // Listen to notification channel
    await this.client.query('LISTEN table_changes');

    this.client.on('notification', async (msg) => {
      if (msg.channel === 'table_changes' && msg.payload) {
        const { table, operation, data } = JSON.parse(msg.payload);
        const handler = this.handlers.get(table);

        if (handler) {
          await handler({ operation, data });
        }
      }
    });

    console.log('[CDC] Listening for database changes');
  }

  async stop(): Promise<void> {
    await this.client.query('UNLISTEN table_changes');
    await this.client.end();
  }
}

// PostgreSQL trigger (run as migration)
/*
CREATE OR REPLACE FUNCTION notify_table_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('table_changes', json_build_object(
    'table', TG_TABLE_NAME,
    'operation', TG_OP,
    'data', CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE row_to_json(NEW) END
  )::text);
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_change_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION notify_table_change();
*/
```

---

## Error Handling & Retries

### Dead Letter Queue

```typescript
// src/queues/dead-letter.ts
import { Queue } from 'bullmq';

export const deadLetterQueue = new Queue('dead-letter', { connection });

export async function moveToDeadLetter(
  originalQueue: string,
  job: { id: string; data: unknown; error: Error }
): Promise<void> {
  await deadLetterQueue.add('failed', {
    originalQueue,
    jobId: job.id,
    data: job.data,
    error: job.error.message,
    failedAt: new Date().toISOString(),
  });
}
```

### Retry with Backoff

```typescript
// src/events/retry.ts
export async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxAttempts?: number; backoffMs?: number } = {}
): Promise<T> {
  const { maxAttempts = 3, backoffMs = 1000 } = options;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) throw error;

      const delay = backoffMs * Math.pow(2, attempt - 1);
      console.log(`[Retry] Attempt ${attempt} failed, retrying in ${delay}ms`);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }

  throw new Error('Unreachable');
}
```

---

## Graceful Shutdown

```typescript
// src/index.ts
import { emailWorker } from './queues/email.queue';
import { subscriber } from './events/subscriber';
import { cdcListener } from './cdc/postgres-listener';

async function shutdown(): Promise<void> {
  console.log('[Shutdown] Starting graceful shutdown...');

  // Stop accepting new work
  await emailWorker.close();
  await subscriber.stop();
  await cdcListener.stop();

  // Close database connections
  await db.$disconnect();

  console.log('[Shutdown] Complete');
  process.exit(0);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
```

---

## Checklist

Before completing streaming implementation:

- [ ] Event schema defined (type, payload, metadata)
- [ ] Publisher and subscriber implemented
- [ ] Error handling with dead letter queue
- [ ] Retry logic with exponential backoff
- [ ] Graceful shutdown handling
- [ ] Idempotent handlers (safe to reprocess)
- [ ] Monitoring/logging for event flow
- [ ] Connection pooling configured
- [ ] Backpressure handling (if high volume)

---

## Related

- `data-batch.md` - Scheduled batch processing
- `api-realtime.md` (Architect) - WebSocket/SSE design
- `database-implementation.md` - Database setup

---

*Protocol created: 2025-12-08*
*Version: 1.0*
