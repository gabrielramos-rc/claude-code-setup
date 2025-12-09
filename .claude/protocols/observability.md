---
name: observability
description: >
  Observability patterns including structured logging, metrics collection,
  distributed tracing, and alerting to understand and monitor system behavior.
applies_to: [engineer, devops]
load_when: >
  Implementing logging infrastructure, metrics collection, distributed tracing,
  or alerting to understand and monitor system behavior in production.
---

# Observability Protocol

## When to Use This Protocol

Load this protocol when:

- Setting up structured logging
- Implementing metrics collection
- Adding distributed tracing
- Configuring alerting and monitoring
- Debugging production issues
- Adding observability to new services

**Do NOT load this protocol for:**
- Security audit logging (use `security-hardening.md`)
- Test result reporting (Tester's domain)
- Error handling logic (use `error-handling.md`)

---

## The Three Pillars

| Pillar | Purpose | Tools |
|--------|---------|-------|
| **Logs** | Discrete events with context | Pino, Winston, Bunyan |
| **Metrics** | Aggregated measurements | Prometheus, StatsD, OpenTelemetry |
| **Traces** | Request flow across services | Jaeger, Zipkin, OpenTelemetry |

---

## Structured Logging

### Pino (Recommended for Node.js)

```typescript
// src/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: {
    service: process.env.SERVICE_NAME || 'api',
    env: process.env.NODE_ENV,
  },
  timestamp: pino.stdTimeFunctions.isoTime,
});

// Child logger with request context
export function createRequestLogger(requestId: string, userId?: string) {
  return logger.child({
    requestId,
    userId,
  });
}
```

### Request Logging Middleware

```typescript
// src/middleware/request-logger.ts
import { Request, Response, NextFunction } from 'express';
import { v4 as uuid } from 'uuid';
import { createRequestLogger, logger } from '../logger';

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const requestId = req.headers['x-request-id'] as string || uuid();
  const startTime = Date.now();

  // Attach logger to request
  req.log = createRequestLogger(requestId, req.user?.id);

  // Set request ID header for tracing
  res.setHeader('x-request-id', requestId);

  // Log request
  req.log.info({
    type: 'request',
    method: req.method,
    path: req.path,
    query: req.query,
    userAgent: req.headers['user-agent'],
  });

  // Log response on finish
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const level = res.statusCode >= 500 ? 'error' :
                  res.statusCode >= 400 ? 'warn' : 'info';

    req.log[level]({
      type: 'response',
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration,
    });
  });

  next();
}
```

### Log Levels Usage

```typescript
// ERROR: Application errors requiring attention
logger.error({ err, userId }, 'Failed to process payment');

// WARN: Unexpected but handled situations
logger.warn({ attemptCount }, 'Rate limit approaching');

// INFO: Important business events
logger.info({ orderId, total }, 'Order completed');

// DEBUG: Detailed debugging information
logger.debug({ query, params }, 'Database query executed');

// TRACE: Very detailed tracing (rarely used in production)
logger.trace({ payload }, 'Incoming webhook payload');
```

### Error Logging

```typescript
// Always log errors with context
try {
  await processOrder(order);
} catch (error) {
  logger.error({
    err: error,
    orderId: order.id,
    userId: order.userId,
    action: 'processOrder',
  }, 'Order processing failed');
  throw error;
}
```

---

## Metrics Collection

### Prometheus with prom-client

```typescript
// src/metrics.ts
import { Registry, Counter, Histogram, Gauge, collectDefaultMetrics } from 'prom-client';

export const register = new Registry();

// Collect default Node.js metrics
collectDefaultMetrics({ register });

// HTTP request metrics
export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [register],
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register],
});

// Business metrics
export const ordersTotal = new Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status'],
  registers: [register],
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active WebSocket connections',
  registers: [register],
});
```

### Metrics Middleware

```typescript
// src/middleware/metrics.ts
import { Request, Response, NextFunction } from 'express';
import { httpRequestsTotal, httpRequestDuration } from '../metrics';

export function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      path: req.route?.path || req.path,
      status: res.statusCode.toString(),
    };

    httpRequestsTotal.inc(labels);
    httpRequestDuration.observe(labels, duration);
  });

  next();
}
```

### Metrics Endpoint

```typescript
// src/routes/metrics.ts
import { Router } from 'express';
import { register } from '../metrics';

const router = Router();

router.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

export default router;
```

### Key Metrics to Track

```typescript
// Request metrics
http_requests_total{method, path, status}
http_request_duration_seconds{method, path, status}

// Business metrics
orders_total{status}
users_registered_total
payments_processed_total{provider, status}

// System metrics (auto-collected)
nodejs_heap_size_total_bytes
nodejs_active_handles_total
nodejs_eventloop_lag_seconds
```

---

## Distributed Tracing

### OpenTelemetry Setup

```typescript
// src/tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: process.env.SERVICE_NAME || 'api',
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.VERSION || '1.0.0',
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-fs': { enabled: false },
    }),
  ],
});

export function startTracing(): void {
  sdk.start();
  console.log('Tracing initialized');

  process.on('SIGTERM', () => {
    sdk.shutdown().then(() => console.log('Tracing terminated'));
  });
}
```

### Manual Spans

```typescript
// src/services/order.ts
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('order-service');

export async function processOrder(order: Order): Promise<void> {
  return tracer.startActiveSpan('processOrder', async (span) => {
    try {
      span.setAttribute('order.id', order.id);
      span.setAttribute('order.total', order.total);

      // Child span for payment
      await tracer.startActiveSpan('processPayment', async (paymentSpan) => {
        try {
          await chargeCard(order.paymentMethod, order.total);
          paymentSpan.setStatus({ code: SpanStatusCode.OK });
        } catch (error) {
          paymentSpan.setStatus({
            code: SpanStatusCode.ERROR,
            message: error.message,
          });
          throw error;
        } finally {
          paymentSpan.end();
        }
      });

      // Child span for fulfillment
      await tracer.startActiveSpan('createFulfillment', async (fulfillmentSpan) => {
        await createShipment(order);
        fulfillmentSpan.end();
      });

      span.setStatus({ code: SpanStatusCode.OK });
    } catch (error) {
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  });
}
```

### Trace Context Propagation

```typescript
// HTTP client with context propagation
import { context, propagation } from '@opentelemetry/api';

async function callExternalService(url: string, data: unknown): Promise<Response> {
  const headers: Record<string, string> = {};

  // Inject trace context into headers
  propagation.inject(context.active(), headers);

  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...headers,
    },
    body: JSON.stringify(data),
  });
}
```

---

## Health Checks

### Comprehensive Health Endpoint

```typescript
// src/health.ts
import { Router } from 'express';
import { db } from './db';
import { redis } from './redis';

const router = Router();

interface HealthCheck {
  status: 'healthy' | 'unhealthy';
  latency?: number;
  error?: string;
}

async function checkDatabase(): Promise<HealthCheck> {
  const start = Date.now();
  try {
    await db.$queryRaw`SELECT 1`;
    return { status: 'healthy', latency: Date.now() - start };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
}

async function checkRedis(): Promise<HealthCheck> {
  const start = Date.now();
  try {
    await redis.ping();
    return { status: 'healthy', latency: Date.now() - start };
  } catch (error) {
    return { status: 'unhealthy', error: error.message };
  }
}

// Liveness: Is the process running?
router.get('/health/live', (req, res) => {
  res.json({ status: 'ok' });
});

// Readiness: Can we serve traffic?
router.get('/health/ready', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
  };

  const isHealthy = Object.values(checks).every(c => c.status === 'healthy');

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? 'healthy' : 'unhealthy',
    checks,
    timestamp: new Date().toISOString(),
  });
});

export default router;
```

---

## Alerting

### Alert Rules (Prometheus)

```yaml
# prometheus/alerts.yml
groups:
  - name: application
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) /
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate (> 5%)
          description: "Error rate is {{ $value | humanizePercentage }}"

      # High latency
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High p95 latency (> 1s)
          description: "p95 latency is {{ $value | humanizeDuration }}"

      # Service down
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Service is down
          description: "{{ $labels.instance }} is not responding"
```

---

## Docker Compose for Local Observability

```yaml
# docker-compose.observability.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.45.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/alerts.yml:/etc/prometheus/alerts.yml

  grafana:
    image: grafana/grafana:10.0.0
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana

  jaeger:
    image: jaegertracing/all-in-one:1.47
    ports:
      - "16686:16686"  # UI
      - "4318:4318"    # OTLP HTTP

  loki:
    image: grafana/loki:2.8.0
    ports:
      - "3100:3100"

volumes:
  grafana-data:
```

---

## Checklist

Before completing observability setup:

- [ ] Structured logging configured (Pino/Winston)
- [ ] Request logging middleware added
- [ ] Error context included in logs
- [ ] Metrics endpoint exposed (/metrics)
- [ ] Key business metrics defined
- [ ] Health check endpoints (live/ready)
- [ ] Tracing configured (if microservices)
- [ ] Log aggregation set up (Loki/ELK)
- [ ] Dashboards created (Grafana)
- [ ] Alerting rules defined

---

## Related

- `error-handling.md` - Error classification and recovery
- `ci-cd.md` - Metrics in CI pipelines
- `containerization.md` - Container monitoring

---

*Protocol created: 2025-12-08*
*Version: 1.0*
