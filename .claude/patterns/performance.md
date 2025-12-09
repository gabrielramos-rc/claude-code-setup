# Performance Pattern

Central reference for performance optimization across all agents.

**Pattern Type:** Cross-cutting concern
**Applies To:** Architect, Engineer, Tester, UI/UX Designer, DevOps, Code Reviewer

---

## Overview

Performance is everyone's responsibility. Each agent handles performance within their domain:

| Agent | Performance Focus |
|-------|-------------------|
| Architect | Performance requirements, scalability design, caching strategy |
| Engineer | Code optimization, profiling, efficient algorithms, bundle size |
| Tester | Load testing, performance regression tests, benchmarks |
| UI/UX Designer | Core Web Vitals, perceived performance, Lighthouse |
| DevOps | CI performance budgets, CDN, deployment optimization |
| Code Reviewer | Spotting performance anti-patterns |

---

## Performance Requirements (Architect)

### Defining Performance Budgets

```markdown
## Performance Requirements

### Response Time Targets
| Endpoint Type | P50 | P95 | P99 |
|---------------|-----|-----|-----|
| API reads | 50ms | 200ms | 500ms |
| API writes | 100ms | 300ms | 1s |
| Page load | 1s | 2s | 3s |

### Throughput Targets
- API: 1000 req/s per instance
- Background jobs: 100 jobs/min

### Resource Constraints
- Memory per instance: 512MB
- CPU per instance: 0.5 vCPU
- Database connections: 20 per instance
```

### Scalability Patterns

| Pattern | Use When |
|---------|----------|
| **Horizontal scaling** | Stateless services, load-balanced |
| **Vertical scaling** | Database, cache, simple start |
| **Caching** | Read-heavy, expensive computations |
| **Queue-based** | Async processing, spiky loads |
| **CDN** | Static assets, global distribution |
| **Read replicas** | Read-heavy database workloads |

### Caching Strategy

```markdown
## Caching Architecture

### Cache Layers
1. **Browser cache** - Static assets (1 year), API responses (varies)
2. **CDN cache** - Static assets, public API responses
3. **Application cache** - Redis for sessions, computed data
4. **Database cache** - Query result cache, connection pooling

### Cache Invalidation
- **Time-based:** TTL for simple cases
- **Event-based:** Invalidate on write operations
- **Version-based:** Cache keys include version/hash
```

---

## Code Optimization (Engineer)

### Profiling First

**Rule:** Never optimize without profiling. Measure, don't guess.

```bash
# Node.js profiling
node --inspect src/index.js
# Open chrome://inspect

# CPU profiling
node --prof src/index.js
node --prof-process isolate-*.log > profile.txt

# Memory profiling
node --inspect --expose-gc src/index.js

# Flame graphs
npx clinic flame -- node src/index.js
```

### Common Optimizations

**Algorithm complexity:**
```typescript
// Bad: O(n²)
const found = arr1.filter(x => arr2.includes(x));

// Good: O(n)
const set2 = new Set(arr2);
const found = arr1.filter(x => set2.has(x));
```

**Avoid unnecessary work:**
```typescript
// Bad: Recalculates on every render
function Component({ items }) {
  const sorted = items.sort((a, b) => a.date - b.date);
  return <List items={sorted} />;
}

// Good: Memoized
function Component({ items }) {
  const sorted = useMemo(
    () => [...items].sort((a, b) => a.date - b.date),
    [items]
  );
  return <List items={sorted} />;
}
```

**Batch operations:**
```typescript
// Bad: N database calls
for (const id of ids) {
  await db.query('SELECT * FROM users WHERE id = ?', [id]);
}

// Good: 1 database call
await db.query('SELECT * FROM users WHERE id IN (?)', [ids]);
```

### Bundle Size Management

```bash
# Analyze bundle
npm run build -- --analyze
npx vite-bundle-visualizer
npx webpack-bundle-analyzer stats.json

# Check package size before adding
npx bundlephobia <package-name>

# Find duplicates
npx duplicate-package-checker-webpack-plugin
```

**Bundle size targets:**
- Initial JS: < 200KB gzipped
- Initial CSS: < 50KB gzipped
- Largest chunk: < 100KB gzipped

### Memory Management

```typescript
// Avoid memory leaks
class Service {
  private intervalId: NodeJS.Timeout;

  start() {
    this.intervalId = setInterval(() => this.poll(), 1000);
  }

  // Always clean up!
  stop() {
    clearInterval(this.intervalId);
  }
}

// Avoid holding references
const cache = new Map();
// Use WeakMap for object keys that should be GC'd
const weakCache = new WeakMap();
```

---

## Load Testing (Tester)

### Load Testing Tools

| Tool | Use Case |
|------|----------|
| **k6** | Scriptable, developer-friendly, CI integration |
| **Artillery** | YAML config, easy setup, good for APIs |
| **Locust** | Python-based, distributed testing |
| **Gatling** | Scala-based, detailed reports |
| **Apache JMeter** | GUI-based, comprehensive |

### k6 Example

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up
    { duration: '3m', target: 50 },   // Sustain
    { duration: '1m', target: 100 },  // Spike
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% under 200ms
    http_req_failed: ['rate<0.01'],   // <1% errors
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });
  sleep(1);
}
```

```bash
# Run load test
k6 run load-test.js

# Run with output to dashboard
k6 run --out influxdb=http://localhost:8086/k6 load-test.js
```

### Performance Regression Tests

```typescript
// performance.test.ts
import { describe, it, expect } from 'vitest';

describe('Performance', () => {
  it('processes 1000 items under 100ms', async () => {
    const items = generateItems(1000);

    const start = performance.now();
    await processItems(items);
    const duration = performance.now() - start;

    expect(duration).toBeLessThan(100);
  });

  it('API response under 200ms', async () => {
    const start = performance.now();
    await fetch('/api/users');
    const duration = performance.now() - start;

    expect(duration).toBeLessThan(200);
  });
});
```

---

## Frontend Performance (UI/UX Designer)

### Core Web Vitals

| Metric | Target | Measures |
|--------|--------|----------|
| **LCP** (Largest Contentful Paint) | < 2.5s | Loading performance |
| **INP** (Interaction to Next Paint) | < 200ms | Interactivity |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Visual stability |

### Lighthouse Audits

```bash
# CLI audit
npx lighthouse https://example.com --output=html --output-path=./report.html

# CI integration
npx lhci autorun

# Performance budget
npx lighthouse https://example.com --budget-path=budget.json
```

**budget.json:**
```json
[
  {
    "resourceSizes": [
      { "resourceType": "script", "budget": 200 },
      { "resourceType": "stylesheet", "budget": 50 },
      { "resourceType": "image", "budget": 500 }
    ],
    "resourceCounts": [
      { "resourceType": "third-party", "budget": 5 }
    ]
  }
]
```

### Perceived Performance

- **Skeleton screens** - Show layout immediately
- **Optimistic updates** - Update UI before server confirms
- **Progressive loading** - Load critical content first
- **Lazy loading** - Defer non-critical resources

---

## CI Performance Budgets (DevOps)

### GitHub Actions Example

```yaml
# .github/workflows/performance.yml
name: Performance Checks

on: [pull_request]

jobs:
  bundle-size:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build

      - name: Check bundle size
        uses: preactjs/compressed-size-action@v2
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          pattern: './dist/**/*.js'

  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci && npm run build

      - name: Lighthouse CI
        uses: treosh/lighthouse-ci-action@v10
        with:
          budgetPath: ./budget.json
          uploadArtifacts: true

  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: grafana/k6-action@v0.3.0
        with:
          filename: tests/load/api.js
          flags: --out json=results.json
```

### Performance Monitoring

```yaml
# Alert on performance regression
- name: Check performance thresholds
  run: |
    P95=$(jq '.metrics.http_req_duration.values["p(95)"]' results.json)
    if (( $(echo "$P95 > 200" | bc -l) )); then
      echo "P95 latency exceeded threshold: ${P95}ms"
      exit 1
    fi
```

---

## Performance Code Review (Code Reviewer)

### Performance Checklist

- [ ] **Algorithm complexity** - No O(n²) where O(n) is possible
- [ ] **Database queries** - No N+1 queries, proper indexes used
- [ ] **Caching** - Expensive operations cached appropriately
- [ ] **Bundle impact** - New dependencies justified, tree-shakeable
- [ ] **Memory** - No leaks, proper cleanup, reasonable allocations
- [ ] **Async operations** - Parallel where possible, no unnecessary awaits
- [ ] **Rendering** - No unnecessary re-renders, proper memoization
- [ ] **Network** - Batched requests, appropriate payload sizes

### Anti-Patterns to Flag

```typescript
// Flag: Synchronous file operations
import { readFileSync } from 'fs'; // Use async version

// Flag: Blocking the event loop
while (condition) { /* ... */ } // Use async/setImmediate

// Flag: Unbounded growth
const cache = {}; // Use LRU cache with size limit

// Flag: Missing pagination
const allUsers = await db.users.findMany(); // Add limit

// Flag: Inefficient serialization in hot path
JSON.parse(JSON.stringify(obj)); // Use structuredClone or avoid
```

---

## Performance Commands Reference

```bash
# Profiling
node --inspect src/index.js          # Chrome DevTools profiling
npx clinic flame -- node src/index.js # Flame graphs
npx 0x src/index.js                   # Flame graphs alternative

# Bundle analysis
npx vite-bundle-visualizer            # Vite projects
npx webpack-bundle-analyzer stats.json # Webpack projects
npx source-map-explorer dist/*.js     # Source map analysis

# Load testing
k6 run load-test.js                   # k6 load test
npx artillery run load-test.yml       # Artillery load test

# Lighthouse
npx lighthouse https://example.com    # Lighthouse audit
npx lhci autorun                      # Lighthouse CI

# Database
EXPLAIN ANALYZE SELECT ...            # PostgreSQL query analysis
npx prisma db execute --stdin <<< "EXPLAIN ..." # Via Prisma
```

---

## Quick Reference by Role

| Role | Key Actions |
|------|-------------|
| **Architect** | Define budgets, choose caching strategy, design for scale |
| **Engineer** | Profile first, optimize algorithms, manage bundle size |
| **Tester** | Load test critical paths, track regressions, set thresholds |
| **UI/UX** | Optimize Core Web Vitals, perceived performance, Lighthouse |
| **DevOps** | CI budgets, monitoring, alerting on degradation |
| **Reviewer** | Check complexity, N+1, memory leaks, bundle impact |
