---
name: caching-strategies
description: >
  Caching patterns at all layers including in-memory, distributed (Redis),
  HTTP caching, and database query caching.
applies_to: [engineer, architect]
load_when: >
  Implementing caching at any layer of the application stack to improve
  performance, reduce load, or handle high traffic scenarios.
---

# Caching Strategies Protocol

## When to Use This Protocol

Load this protocol when:

- Implementing Redis or in-memory caching
- Adding HTTP caching headers
- Caching database query results
- Optimizing API response times
- Handling high-traffic scenarios

**Do NOT load this protocol for:**
- Database indexing (use `database-implementation.md`)
- CDN configuration (DevOps domain)
- Session storage (use `authentication.md`)

---

## Cache Types

| Type | Latency | Capacity | Use Case |
|------|---------|----------|----------|
| **In-Memory** | ~1μs | Limited | Hot data, single instance |
| **Redis** | ~1ms | Large | Shared cache, distributed |
| **HTTP** | 0ms (browser) | Varies | Static assets, API responses |
| **Database** | ~10ms | Large | Query results |

---

## In-Memory Caching

### Simple LRU Cache

```typescript
// src/cache/memory-cache.ts
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, unknown>({
  max: 500,                    // Max items
  maxSize: 50 * 1024 * 1024,  // 50MB
  sizeCalculation: (value) => JSON.stringify(value).length,
  ttl: 1000 * 60 * 5,         // 5 minutes
});

export function get<T>(key: string): T | undefined {
  return cache.get(key) as T | undefined;
}

export function set<T>(key: string, value: T, ttlMs?: number): void {
  cache.set(key, value, { ttl: ttlMs });
}

export function del(key: string): void {
  cache.delete(key);
}

export function clear(): void {
  cache.clear();
}
```

### Memoization

```typescript
// src/utils/memoize.ts
export function memoize<T extends (...args: any[]) => any>(
  fn: T,
  options: { maxAge?: number; maxSize?: number } = {}
): T {
  const cache = new LRUCache<string, ReturnType<T>>({
    max: options.maxSize ?? 100,
    ttl: options.maxAge ?? 60000,
  });

  return ((...args: Parameters<T>): ReturnType<T> => {
    const key = JSON.stringify(args);
    const cached = cache.get(key);

    if (cached !== undefined) {
      return cached;
    }

    const result = fn(...args);
    cache.set(key, result);
    return result;
  }) as T;
}

// Usage
const expensiveCalculation = memoize(
  (userId: string) => computeUserStats(userId),
  { maxAge: 60000 }
);
```

---

## Redis Caching

### Redis Client Setup

```typescript
// src/cache/redis.ts
import Redis from 'ioredis';

export const redis = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: 3,
  retryDelayOnFailover: 100,
  enableReadyCheck: true,
});

redis.on('error', (err) => console.error('Redis error:', err));
redis.on('connect', () => console.log('Redis connected'));
```

### Cache-Aside Pattern

```typescript
// src/cache/cache-aside.ts
import { redis } from './redis';

interface CacheOptions {
  ttl?: number;  // seconds
  prefix?: string;
}

export async function cacheAside<T>(
  key: string,
  fetcher: () => Promise<T>,
  options: CacheOptions = {}
): Promise<T> {
  const { ttl = 300, prefix = 'cache' } = options;
  const cacheKey = `${prefix}:${key}`;

  // Try cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached) as T;
  }

  // Fetch from source
  const data = await fetcher();

  // Store in cache
  await redis.setex(cacheKey, ttl, JSON.stringify(data));

  return data;
}

// Usage
const user = await cacheAside(
  `user:${userId}`,
  () => db.user.findUnique({ where: { id: userId } }),
  { ttl: 600 }
);
```

### Write-Through Pattern

```typescript
// src/cache/write-through.ts
export async function writeThrough<T>(
  key: string,
  data: T,
  writer: (data: T) => Promise<void>,
  options: CacheOptions = {}
): Promise<void> {
  const { ttl = 300, prefix = 'cache' } = options;
  const cacheKey = `${prefix}:${key}`;

  // Write to database
  await writer(data);

  // Update cache
  await redis.setex(cacheKey, ttl, JSON.stringify(data));
}

// Usage
await writeThrough(
  `user:${userId}`,
  updatedUser,
  (user) => db.user.update({ where: { id: userId }, data: user })
);
```

### Cache Invalidation

```typescript
// src/cache/invalidation.ts
export async function invalidate(pattern: string): Promise<void> {
  const keys = await redis.keys(`cache:${pattern}`);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
}

// Invalidate specific key
await invalidate(`user:${userId}`);

// Invalidate pattern (use sparingly)
await invalidate('user:*');  // All users

// Invalidate related caches
async function updateUser(userId: string, data: UserUpdate): Promise<void> {
  await db.user.update({ where: { id: userId }, data });

  // Invalidate all related caches
  await Promise.all([
    invalidate(`user:${userId}`),
    invalidate(`user-posts:${userId}`),
    invalidate(`user-profile:${userId}`),
  ]);
}
```

---

## HTTP Caching

### Cache-Control Headers

```typescript
// src/middleware/cache-control.ts
import { Request, Response, NextFunction } from 'express';

interface CacheConfig {
  maxAge?: number;
  sMaxAge?: number;
  staleWhileRevalidate?: number;
  private?: boolean;
  noStore?: boolean;
}

export function cacheControl(config: CacheConfig) {
  return (req: Request, res: Response, next: NextFunction) => {
    const directives: string[] = [];

    if (config.noStore) {
      directives.push('no-store');
    } else {
      directives.push(config.private ? 'private' : 'public');

      if (config.maxAge !== undefined) {
        directives.push(`max-age=${config.maxAge}`);
      }
      if (config.sMaxAge !== undefined) {
        directives.push(`s-maxage=${config.sMaxAge}`);
      }
      if (config.staleWhileRevalidate !== undefined) {
        directives.push(`stale-while-revalidate=${config.staleWhileRevalidate}`);
      }
    }

    res.setHeader('Cache-Control', directives.join(', '));
    next();
  };
}

// Usage
router.get('/products',
  cacheControl({ maxAge: 60, sMaxAge: 300, staleWhileRevalidate: 86400 }),
  getProducts
);

router.get('/user/profile',
  cacheControl({ private: true, maxAge: 0, noStore: true }),
  getUserProfile
);
```

### ETag Support

```typescript
// src/middleware/etag.ts
import { createHash } from 'crypto';

export function generateETag(data: unknown): string {
  const content = JSON.stringify(data);
  return createHash('md5').update(content).digest('hex');
}

export function handleETag(req: Request, res: Response, data: unknown): boolean {
  const etag = `"${generateETag(data)}"`;
  res.setHeader('ETag', etag);

  const clientETag = req.headers['if-none-match'];
  if (clientETag === etag) {
    res.status(304).end();
    return true;
  }

  return false;
}

// Usage
router.get('/products/:id', async (req, res) => {
  const product = await getProduct(req.params.id);

  if (handleETag(req, res, product)) {
    return;  // 304 Not Modified sent
  }

  res.json(product);
});
```

---

## Query Result Caching

### Prisma Caching Extension

```typescript
// src/db/cache-extension.ts
import { Prisma } from '@prisma/client';
import { redis } from '../cache/redis';

export const cacheExtension = Prisma.defineExtension({
  name: 'cache',
  query: {
    $allModels: {
      async findUnique({ model, args, query }) {
        const cacheKey = `db:${model}:${JSON.stringify(args)}`;

        const cached = await redis.get(cacheKey);
        if (cached) {
          return JSON.parse(cached);
        }

        const result = await query(args);

        if (result) {
          await redis.setex(cacheKey, 300, JSON.stringify(result));
        }

        return result;
      },
    },
  },
});

// Usage
const prisma = new PrismaClient().$extends(cacheExtension);
```

### Manual Query Caching

```typescript
// src/repositories/product.repository.ts
export async function findPopularProducts(): Promise<Product[]> {
  return cacheAside(
    'products:popular',
    async () => {
      return db.product.findMany({
        where: { isActive: true },
        orderBy: { salesCount: 'desc' },
        take: 20,
      });
    },
    { ttl: 3600 }  // 1 hour
  );
}
```

---

## Caching Strategies by Use Case

### Read-Heavy Data
```typescript
// Long TTL, aggressive caching
const config = await cacheAside('app:config', fetchConfig, { ttl: 3600 });
```

### User-Specific Data
```typescript
// Shorter TTL, invalidate on changes
const profile = await cacheAside(`user:${userId}:profile`, fetchProfile, { ttl: 300 });
```

### Frequently Updated Data
```typescript
// Short TTL or no cache
const prices = await cacheAside('stock:prices', fetchPrices, { ttl: 10 });
```

### Computed/Aggregated Data
```typescript
// Background refresh, stale-while-revalidate
const stats = await cacheAside('analytics:daily', computeStats, { ttl: 900 });
```

---

## Cache Warming

```typescript
// src/cache/warmer.ts
export async function warmCache(): Promise<void> {
  console.log('Warming cache...');

  // Warm popular products
  const products = await db.product.findMany({
    where: { isActive: true },
    orderBy: { views: 'desc' },
    take: 100,
  });

  await Promise.all(
    products.map(product =>
      redis.setex(`product:${product.id}`, 3600, JSON.stringify(product))
    )
  );

  // Warm configuration
  const config = await fetchAppConfig();
  await redis.setex('app:config', 3600, JSON.stringify(config));

  console.log('Cache warmed');
}

// Run on startup
warmCache().catch(console.error);
```

---

## Monitoring

### Cache Hit Rate

```typescript
// src/cache/metrics.ts
import { Counter } from 'prom-client';

const cacheHits = new Counter({
  name: 'cache_hits_total',
  help: 'Total cache hits',
  labelNames: ['cache', 'key_prefix'],
});

const cacheMisses = new Counter({
  name: 'cache_misses_total',
  help: 'Total cache misses',
  labelNames: ['cache', 'key_prefix'],
});

export function recordCacheHit(cache: string, prefix: string): void {
  cacheHits.inc({ cache, key_prefix: prefix });
}

export function recordCacheMiss(cache: string, prefix: string): void {
  cacheMisses.inc({ cache, key_prefix: prefix });
}
```

---

## Checklist

Before completing caching implementation:

- [ ] Cache layer selected (memory/Redis/both)
- [ ] TTL values appropriate for data type
- [ ] Invalidation strategy defined
- [ ] Cache keys are unique and descriptive
- [ ] Serialization/deserialization tested
- [ ] Cache miss handling is graceful
- [ ] Monitoring/metrics added
- [ ] Cache warming for critical data
- [ ] Memory limits configured

---

## Related

- `database-implementation.md` - Query optimization
- `observability.md` - Cache metrics
- `error-handling.md` - Cache failure handling

---

*Protocol created: 2025-12-08*
*Version: 1.0*
