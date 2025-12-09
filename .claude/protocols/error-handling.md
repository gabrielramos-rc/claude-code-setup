---
name: error-handling
description: >
  Error handling patterns including error classification, retry strategies,
  circuit breakers, and graceful degradation for resilient applications.
applies_to: [engineer, architect]
load_when: >
  Designing how the application handles, reports, and recovers from failures
  across the stack, including error classification, retry strategies, circuit
  breakers, and graceful degradation.
---

# Error Handling Protocol

## When to Use This Protocol

Load this protocol when:

- Designing error handling strategy
- Implementing retry logic
- Adding circuit breakers
- Building graceful degradation
- Standardizing error responses
- Handling external service failures

**Do NOT load this protocol for:**
- Logging setup (use `observability.md`)
- Security error handling (use `security-hardening.md`)
- Test assertions (use `testing-unit.md`)

---

## Error Classification

### Error Types

| Type | Retryable | Example |
|------|-----------|---------|
| **Transient** | Yes | Network timeout, rate limit, DB connection |
| **Client** | No | Validation error, not found, unauthorized |
| **Server** | Maybe | Internal error, dependency failure |
| **Fatal** | No | Out of memory, config missing |

### Custom Error Classes

```typescript
// src/errors/base.ts
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly code: string;
  abstract readonly isOperational: boolean;

  constructor(message: string, public readonly cause?: Error) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        ...(process.env.NODE_ENV !== 'production' && { stack: this.stack }),
      },
    };
  }
}
```

### Specific Error Types

```typescript
// src/errors/index.ts
import { AppError } from './base';

// Client errors (4xx)
export class ValidationError extends AppError {
  readonly statusCode = 400;
  readonly code = 'VALIDATION_ERROR';
  readonly isOperational = true;

  constructor(
    message: string,
    public readonly fields: Array<{ field: string; message: string }>
  ) {
    super(message);
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        fields: this.fields,
      },
    };
  }
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly code = 'NOT_FOUND';
  readonly isOperational = true;

  constructor(resource: string, id: string) {
    super(`${resource} with ID ${id} not found`);
  }
}

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
  readonly code = 'UNAUTHORIZED';
  readonly isOperational = true;

  constructor(message = 'Authentication required') {
    super(message);
  }
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;
  readonly code = 'FORBIDDEN';
  readonly isOperational = true;

  constructor(message = 'Access denied') {
    super(message);
  }
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
  readonly code = 'CONFLICT';
  readonly isOperational = true;

  constructor(message: string) {
    super(message);
  }
}

// Server errors (5xx)
export class InternalError extends AppError {
  readonly statusCode = 500;
  readonly code = 'INTERNAL_ERROR';
  readonly isOperational = false;

  constructor(message: string, cause?: Error) {
    super(message, cause);
  }
}

export class ServiceUnavailableError extends AppError {
  readonly statusCode = 503;
  readonly code = 'SERVICE_UNAVAILABLE';
  readonly isOperational = true;

  constructor(service: string, cause?: Error) {
    super(`${service} is temporarily unavailable`, cause);
  }
}

// Transient errors (retryable)
export class TransientError extends AppError {
  readonly statusCode = 503;
  readonly code = 'TRANSIENT_ERROR';
  readonly isOperational = true;

  constructor(
    message: string,
    public readonly retryAfter?: number,
    cause?: Error
  ) {
    super(message, cause);
  }
}
```

---

## Error Handler Middleware

### Express Error Handler

```typescript
// src/middleware/error-handler.ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../errors/base';
import { logger } from '../logger';

export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  // Log error
  if (error instanceof AppError && error.isOperational) {
    req.log?.warn({ err: error }, error.message);
  } else {
    req.log?.error({ err: error }, 'Unhandled error');
  }

  // Send response
  if (error instanceof AppError) {
    res.status(error.statusCode).json(error.toJSON());
    return;
  }

  // Unknown error - don't leak details in production
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : error.message,
    },
  });
}

// Async wrapper to catch promise rejections
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
```

### Usage

```typescript
// src/routes/users.ts
import { asyncHandler } from '../middleware/error-handler';
import { NotFoundError, ValidationError } from '../errors';

router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userRepository.findById(req.params.id);

  if (!user) {
    throw new NotFoundError('User', req.params.id);
  }

  res.json(user);
}));

router.post('/users', asyncHandler(async (req, res) => {
  const validation = validateUser(req.body);

  if (!validation.success) {
    throw new ValidationError('Invalid user data', validation.errors);
  }

  const user = await userRepository.create(req.body);
  res.status(201).json(user);
}));
```

---

## Retry Strategies

### Exponential Backoff

```typescript
// src/utils/retry.ts
interface RetryOptions {
  maxAttempts?: number;
  initialDelayMs?: number;
  maxDelayMs?: number;
  backoffMultiplier?: number;
  retryOn?: (error: Error) => boolean;
}

const defaultOptions: Required<RetryOptions> = {
  maxAttempts: 3,
  initialDelayMs: 100,
  maxDelayMs: 10000,
  backoffMultiplier: 2,
  retryOn: () => true,
};

export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const opts = { ...defaultOptions, ...options };
  let lastError: Error;
  let delay = opts.initialDelayMs;

  for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;

      if (attempt === opts.maxAttempts || !opts.retryOn(lastError)) {
        throw lastError;
      }

      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
      await sleep(delay);

      delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelayMs);
    }
  }

  throw lastError!;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

### Usage with Retryable Errors

```typescript
// Only retry on transient errors
const result = await withRetry(
  () => externalApi.fetchData(id),
  {
    maxAttempts: 3,
    initialDelayMs: 500,
    retryOn: (error) => {
      return error instanceof TransientError ||
             error.message.includes('ECONNRESET') ||
             error.message.includes('ETIMEDOUT');
    },
  }
);
```

### Jitter for Distributed Systems

```typescript
// Add jitter to prevent thundering herd
function calculateDelay(
  attempt: number,
  baseDelay: number,
  maxDelay: number
): number {
  const exponentialDelay = baseDelay * Math.pow(2, attempt - 1);
  const cappedDelay = Math.min(exponentialDelay, maxDelay);
  // Add random jitter (0-100% of delay)
  const jitter = Math.random() * cappedDelay;
  return Math.floor(cappedDelay + jitter);
}
```

---

## Circuit Breaker

### Implementation

```typescript
// src/utils/circuit-breaker.ts
enum CircuitState {
  CLOSED = 'CLOSED',
  OPEN = 'OPEN',
  HALF_OPEN = 'HALF_OPEN',
}

interface CircuitBreakerOptions {
  failureThreshold: number;
  successThreshold: number;
  timeout: number;
}

export class CircuitBreaker {
  private state: CircuitState = CircuitState.CLOSED;
  private failureCount = 0;
  private successCount = 0;
  private lastFailureTime?: number;
  private readonly options: CircuitBreakerOptions;

  constructor(options: Partial<CircuitBreakerOptions> = {}) {
    this.options = {
      failureThreshold: 5,
      successThreshold: 2,
      timeout: 30000,
      ...options,
    };
  }

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === CircuitState.OPEN) {
      if (Date.now() - this.lastFailureTime! > this.options.timeout) {
        this.state = CircuitState.HALF_OPEN;
      } else {
        throw new ServiceUnavailableError('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess(): void {
    if (this.state === CircuitState.HALF_OPEN) {
      this.successCount++;
      if (this.successCount >= this.options.successThreshold) {
        this.reset();
      }
    } else {
      this.failureCount = 0;
    }
  }

  private onFailure(): void {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.options.failureThreshold) {
      this.state = CircuitState.OPEN;
    }
  }

  private reset(): void {
    this.state = CircuitState.CLOSED;
    this.failureCount = 0;
    this.successCount = 0;
  }

  getState(): CircuitState {
    return this.state;
  }
}
```

### Usage

```typescript
// src/services/payment.ts
const paymentCircuit = new CircuitBreaker({
  failureThreshold: 5,
  successThreshold: 2,
  timeout: 60000,
});

export async function processPayment(order: Order): Promise<PaymentResult> {
  return paymentCircuit.execute(async () => {
    return await stripeClient.charges.create({
      amount: order.total,
      currency: 'usd',
      source: order.paymentToken,
    });
  });
}
```

---

## Graceful Degradation

### Fallback Strategies

```typescript
// src/services/recommendations.ts
import { withFallback } from '../utils/fallback';

export async function getRecommendations(userId: string): Promise<Product[]> {
  return withFallback(
    // Primary: ML-based recommendations
    () => mlService.getPersonalizedRecommendations(userId),
    [
      // Fallback 1: Simple recommendations based on history
      () => getHistoryBasedRecommendations(userId),
      // Fallback 2: Popular products (cached)
      () => getCachedPopularProducts(),
      // Fallback 3: Empty array (graceful empty state)
      () => Promise.resolve([]),
    ]
  );
}

async function withFallback<T>(
  primary: () => Promise<T>,
  fallbacks: Array<() => Promise<T>>
): Promise<T> {
  try {
    return await primary();
  } catch (primaryError) {
    console.warn('Primary failed, trying fallbacks:', primaryError);

    for (const fallback of fallbacks) {
      try {
        return await fallback();
      } catch {
        continue;
      }
    }

    throw primaryError;
  }
}
```

### Feature Flags for Degradation

```typescript
// src/features.ts
interface FeatureFlags {
  enableMLRecommendations: boolean;
  enableRealTimeInventory: boolean;
  enableVideoStreaming: boolean;
}

const flags: FeatureFlags = {
  enableMLRecommendations: true,
  enableRealTimeInventory: true,
  enableVideoStreaming: true,
};

export function isFeatureEnabled(feature: keyof FeatureFlags): boolean {
  return flags[feature];
}

// Disable feature when service is unhealthy
export function disableFeature(feature: keyof FeatureFlags): void {
  flags[feature] = false;
  console.warn(`Feature disabled: ${feature}`);
}

// Usage
if (isFeatureEnabled('enableMLRecommendations')) {
  recommendations = await mlService.getRecommendations(userId);
} else {
  recommendations = await getSimpleRecommendations(userId);
}
```

---

## Timeout Handling

### Request Timeouts

```typescript
// src/utils/timeout.ts
export function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  message = 'Operation timed out'
): Promise<T> {
  return Promise.race([
    promise,
    new Promise<never>((_, reject) =>
      setTimeout(() => reject(new TransientError(message)), timeoutMs)
    ),
  ]);
}

// Usage
const result = await withTimeout(
  externalApi.slowOperation(),
  5000,
  'External API timed out'
);
```

### AbortController for Cancellation

```typescript
// src/utils/fetch-with-timeout.ts
export async function fetchWithTimeout(
  url: string,
  options: RequestInit = {},
  timeoutMs = 5000
): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
    });
    return response;
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new TransientError(`Request to ${url} timed out`);
    }
    throw error;
  } finally {
    clearTimeout(timeoutId);
  }
}
```

---

## Error Response Format

### Standardized API Errors

```typescript
// Success response
{
  "data": { ... }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "fields": [
      { "field": "email", "message": "Invalid email format" },
      { "field": "password", "message": "Password too short" }
    ],
    "requestId": "abc-123"
  }
}

// Server error (production)
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred",
    "requestId": "abc-123"
  }
}
```

---

## Checklist

Before completing error handling:

- [ ] Custom error classes defined
- [ ] Error handler middleware configured
- [ ] Async errors caught properly
- [ ] Retry logic for transient failures
- [ ] Circuit breakers for external services
- [ ] Graceful degradation with fallbacks
- [ ] Timeouts on all external calls
- [ ] Standardized error response format
- [ ] Errors logged with context
- [ ] Sensitive data not leaked in errors

---

## Related

- `observability.md` - Error logging and monitoring
- `api-rest.md` - API error responses
- `testing-unit.md` - Testing error scenarios

---

*Protocol created: 2025-12-08*
*Version: 1.0*
