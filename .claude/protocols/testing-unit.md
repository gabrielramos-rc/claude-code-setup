---
name: testing-unit
description: >
  Unit testing patterns for isolated function and class testing with
  mocking, assertions, and test organization best practices.
applies_to: [tester]
load_when: >
  Writing isolated tests for individual functions, classes, or modules
  that verify behavior without external dependencies like databases,
  APIs, or file systems.
---

# Unit Testing Protocol

## When to Use This Protocol

Load this protocol when:

- Testing individual functions or methods
- Testing class behavior in isolation
- Mocking external dependencies
- Testing pure business logic
- Creating fast, isolated test suites

**Do NOT load this protocol for:**
- API endpoint testing (use `testing-integration.md`)
- Database interaction testing (use `testing-integration.md`)
- Browser-based testing (use `testing-e2e.md`)

---

## Unit Test Characteristics

| Aspect | Requirement |
|--------|-------------|
| **Speed** | < 10ms per test |
| **Dependencies** | All mocked |
| **Isolation** | No shared state between tests |
| **Determinism** | Same result every run |
| **Side effects** | None (no DB, network, filesystem) |

---

## Test Framework Detection

Check `package.json` for test framework:

| Framework | Detection | Run Command |
|-----------|-----------|-------------|
| **Vitest** | `vitest` in dependencies | `npx vitest run` |
| **Jest** | `jest` in dependencies | `npx jest` |
| **Mocha** | `mocha` in dependencies | `npx mocha` |

---

## Test Structure (AAA Pattern)

Use Arrange-Act-Assert for clear test structure:

```typescript
// tests/unit/calculator.test.ts
import { describe, it, expect } from 'vitest';
import { Calculator } from '../../src/calculator';

describe('Calculator', () => {
  describe('add', () => {
    it('should add two positive numbers', () => {
      // Arrange
      const calculator = new Calculator();

      // Act
      const result = calculator.add(2, 3);

      // Assert
      expect(result).toBe(5);
    });

    it('should handle negative numbers', () => {
      // Arrange
      const calculator = new Calculator();

      // Act
      const result = calculator.add(-1, 5);

      // Assert
      expect(result).toBe(4);
    });
  });
});
```

---

## Mocking Patterns

### Function Mocks

```typescript
import { vi, describe, it, expect, beforeEach } from 'vitest';
import { processOrder } from '../../src/order';
import * as emailService from '../../src/services/email';

// Mock entire module
vi.mock('../../src/services/email');

describe('processOrder', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should send confirmation email after order', async () => {
    // Arrange
    const mockSendEmail = vi.mocked(emailService.sendEmail);
    mockSendEmail.mockResolvedValue({ success: true });

    const order = { id: '123', email: 'test@example.com' };

    // Act
    await processOrder(order);

    // Assert
    expect(mockSendEmail).toHaveBeenCalledWith({
      to: 'test@example.com',
      template: 'order-confirmation',
      data: expect.objectContaining({ orderId: '123' }),
    });
  });
});
```

### Spy on Methods

```typescript
import { vi, describe, it, expect } from 'vitest';

describe('UserService', () => {
  it('should call validator before saving', async () => {
    // Arrange
    const service = new UserService();
    const validateSpy = vi.spyOn(service, 'validate');

    // Act
    await service.save({ email: 'test@example.com' });

    // Assert
    expect(validateSpy).toHaveBeenCalledOnce();
  });
});
```

### Mock Return Values

```typescript
import { vi } from 'vitest';

// Return specific value
mockFn.mockReturnValue(42);

// Return different values on each call
mockFn.mockReturnValueOnce(1).mockReturnValueOnce(2);

// Async returns
mockFn.mockResolvedValue({ data: 'result' });
mockFn.mockRejectedValue(new Error('Failed'));

// Custom implementation
mockFn.mockImplementation((x) => x * 2);
```

### Partial Mocks

```typescript
import { vi } from 'vitest';
import * as utils from '../../src/utils';

// Mock only specific exports
vi.mock('../../src/utils', async () => {
  const actual = await vi.importActual('../../src/utils');
  return {
    ...actual,
    fetchData: vi.fn().mockResolvedValue({ data: 'mocked' }),
  };
});
```

---

## Testing Async Code

### Promises

```typescript
describe('async functions', () => {
  it('should resolve with user data', async () => {
    const result = await fetchUser('123');
    expect(result).toEqual({ id: '123', name: 'John' });
  });

  it('should reject with error for invalid id', async () => {
    await expect(fetchUser('')).rejects.toThrow('Invalid user ID');
  });
});
```

### Timers

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('debounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should call function after delay', () => {
    const fn = vi.fn();
    const debounced = debounce(fn, 1000);

    debounced();
    expect(fn).not.toHaveBeenCalled();

    vi.advanceTimersByTime(1000);
    expect(fn).toHaveBeenCalledOnce();
  });
});
```

---

## Testing Error Handling

```typescript
describe('error handling', () => {
  it('should throw for invalid input', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
  });

  it('should throw specific error type', () => {
    expect(() => validateEmail('invalid')).toThrow(ValidationError);
  });

  it('should reject promise with error', async () => {
    await expect(fetchUser('invalid')).rejects.toThrow('User not found');
  });

  it('should include error details', () => {
    try {
      validateUser({ email: 'bad' });
    } catch (error) {
      expect(error).toBeInstanceOf(ValidationError);
      expect(error.field).toBe('email');
      expect(error.message).toContain('Invalid email');
    }
  });
});
```

---

## Testing Classes

```typescript
describe('UserService', () => {
  let service: UserService;
  let mockRepository: MockedObject<UserRepository>;

  beforeEach(() => {
    mockRepository = {
      findById: vi.fn(),
      save: vi.fn(),
      delete: vi.fn(),
    };
    service = new UserService(mockRepository);
  });

  describe('getUser', () => {
    it('should return user when found', async () => {
      mockRepository.findById.mockResolvedValue({ id: '1', name: 'John' });

      const user = await service.getUser('1');

      expect(user).toEqual({ id: '1', name: 'John' });
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(service.getUser('999')).rejects.toThrow('User not found');
    });
  });
});
```

---

## Test Data Patterns

### Factories

```typescript
// tests/factories/user.factory.ts
import { faker } from '@faker-js/faker';

export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    createdAt: new Date(),
    ...overrides,
  };
}

// Usage in tests
it('should process user', () => {
  const user = createUser({ name: 'Specific Name' });
  // ...
});
```

### Builders

```typescript
// tests/builders/order.builder.ts
export class OrderBuilder {
  private order: Partial<Order> = {};

  withId(id: string): this {
    this.order.id = id;
    return this;
  }

  withItems(items: OrderItem[]): this {
    this.order.items = items;
    return this;
  }

  withTotal(total: number): this {
    this.order.total = total;
    return this;
  }

  build(): Order {
    return {
      id: this.order.id ?? 'order-1',
      items: this.order.items ?? [],
      total: this.order.total ?? 0,
      createdAt: new Date(),
    };
  }
}

// Usage
const order = new OrderBuilder()
  .withId('order-123')
  .withTotal(99.99)
  .build();
```

---

## File Organization

```
tests/
├── unit/
│   ├── services/
│   │   ├── user.service.test.ts
│   │   └── order.service.test.ts
│   ├── utils/
│   │   ├── validation.test.ts
│   │   └── formatting.test.ts
│   └── models/
│       └── user.test.ts
├── factories/
│   ├── user.factory.ts
│   └── order.factory.ts
├── builders/
│   └── order.builder.ts
└── helpers/
    └── test-utils.ts
```

---

## Common Assertions

```typescript
// Equality
expect(value).toBe(5);              // Strict equality
expect(value).toEqual({ a: 1 });    // Deep equality
expect(value).toStrictEqual(obj);   // Deep + type checking

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeLessThanOrEqual(5);
expect(value).toBeCloseTo(0.3, 5);

// Strings
expect(value).toMatch(/pattern/);
expect(value).toContain('substring');

// Arrays
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(array).toEqual(expect.arrayContaining([1, 2]));

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toHaveProperty('nested.key', 'value');
expect(obj).toMatchObject({ key: 'value' });

// Functions
expect(fn).toHaveBeenCalled();
expect(fn).toHaveBeenCalledWith(arg1, arg2);
expect(fn).toHaveBeenCalledTimes(2);
```

---

## Running Unit Tests

```bash
# Run all unit tests
npx vitest run tests/unit/
npm test -- --testPathPattern=unit

# Run specific file
npx vitest run tests/unit/services/user.service.test.ts

# Run with coverage
npx vitest run tests/unit/ --coverage

# Watch mode (development)
npx vitest tests/unit/
```

---

## Checklist

Before completing unit tests:

- [ ] All public functions have tests
- [ ] Happy path covered
- [ ] Edge cases covered (empty, null, boundary values)
- [ ] Error conditions tested
- [ ] All mocks properly reset between tests
- [ ] No external dependencies (DB, network, filesystem)
- [ ] Tests run in < 1 second total
- [ ] Test names describe behavior (not implementation)
- [ ] Coverage > 80% for tested module

---

## Related

- `testing-integration.md` - Component interaction testing
- `testing-e2e.md` - Full user flow testing

---

*Protocol created: 2025-12-08*
*Version: 1.0*
