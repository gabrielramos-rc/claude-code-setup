---
name: testing-e2e
description: >
  End-to-end testing patterns for browser-based user flow testing with
  Playwright or Cypress, simulating real user interactions through the
  complete application stack.
applies_to: [tester]
load_when: >
  Writing end-to-end tests that simulate real user workflows through the
  complete application stack, typically using browser automation tools
  like Playwright or Cypress.
---

# End-to-End Testing Protocol

## When to Use This Protocol

Load this protocol when:

- Testing complete user flows (login → action → logout)
- Testing browser interactions (clicks, forms, navigation)
- Testing visual elements and page content
- Testing across multiple pages/routes
- Verifying production-like behavior

**Do NOT load this protocol for:**
- Isolated function testing (use `testing-unit.md`)
- API endpoint testing without browser (use `testing-integration.md`)
- Component-level testing without full app

---

## E2E Test Characteristics

| Aspect | Requirement |
|--------|-------------|
| **Speed** | < 30s per test (acceptable: < 60s) |
| **Environment** | Full application stack running |
| **Browser** | Real browser (headless or headed) |
| **Database** | Test database with seed data |
| **Isolation** | Clean state per test suite |

---

## Framework Detection

Check `package.json` for E2E framework:

| Framework | Detection | Config File |
|-----------|-----------|-------------|
| **Playwright** | `@playwright/test` | `playwright.config.ts` |
| **Cypress** | `cypress` | `cypress.config.ts` |

---

## Playwright Setup

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 13'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

### Basic Test Structure

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should allow user to log in', async ({ page }) => {
    // Navigate to login
    await page.click('text=Sign In');

    // Fill form
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');

    // Submit
    await page.click('button[type="submit"]');

    // Assert redirect and welcome
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.click('text=Sign In');
    await page.fill('input[name="email"]', 'wrong@example.com');
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error')).toContainText('Invalid credentials');
    await expect(page).toHaveURL('/login');
  });
});
```

---

## Cypress Setup

### Configuration

```typescript
// cypress.config.ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.ts',
    specPattern: 'cypress/e2e/**/*.cy.{js,ts}',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
    retries: {
      runMode: 2,
      openMode: 0,
    },
    setupNodeEvents(on, config) {
      // Load tasks
      return config;
    },
  },
});
```

### Basic Test Structure

```typescript
// cypress/e2e/auth.cy.ts
describe('Authentication', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('should allow user to log in', () => {
    cy.contains('Sign In').click();

    cy.get('input[name="email"]').type('test@example.com');
    cy.get('input[name="password"]').type('password123');
    cy.get('button[type="submit"]').click();

    cy.url().should('include', '/dashboard');
    cy.get('h1').should('contain', 'Welcome');
  });

  it('should show error for invalid credentials', () => {
    cy.contains('Sign In').click();
    cy.get('input[name="email"]').type('wrong@example.com');
    cy.get('input[name="password"]').type('wrongpassword');
    cy.get('button[type="submit"]').click();

    cy.get('.error').should('contain', 'Invalid credentials');
    cy.url().should('include', '/login');
  });
});
```

---

## Page Object Pattern

### Playwright Page Objects

```typescript
// tests/e2e/pages/login.page.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.locator('input[name="email"]');
    this.passwordInput = page.locator('input[name="password"]');
    this.submitButton = page.locator('button[type="submit"]');
    this.errorMessage = page.locator('.error');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// Usage in test
import { LoginPage } from './pages/login.page';

test('should login successfully', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password123');

  await expect(page).toHaveURL('/dashboard');
});
```

### Cypress Page Objects

```typescript
// cypress/support/pages/login.page.ts
export class LoginPage {
  visit() {
    cy.visit('/login');
    return this;
  }

  fillEmail(email: string) {
    cy.get('input[name="email"]').type(email);
    return this;
  }

  fillPassword(password: string) {
    cy.get('input[name="password"]').type(password);
    return this;
  }

  submit() {
    cy.get('button[type="submit"]').click();
    return this;
  }

  login(email: string, password: string) {
    return this.fillEmail(email).fillPassword(password).submit();
  }

  assertError(message: string) {
    cy.get('.error').should('contain', message);
    return this;
  }
}

// Usage in test
import { LoginPage } from '../support/pages/login.page';

describe('Login', () => {
  const loginPage = new LoginPage();

  it('should login successfully', () => {
    loginPage.visit().login('test@example.com', 'password123');
    cy.url().should('include', '/dashboard');
  });
});
```

---

## Authentication Helpers

### Playwright Auth State

```typescript
// tests/e2e/auth.setup.ts
import { test as setup } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '../.auth/user.json');

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: authFile });
});

// playwright.config.ts - add authenticated project
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'authenticated',
      testMatch: /.*\.spec\.ts/,
      dependencies: ['setup'],
      use: {
        storageState: '.auth/user.json',
      },
    },
  ],
});
```

### Cypress Auth Commands

```typescript
// cypress/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      login(email?: string, password?: string): Chainable<void>;
      loginByApi(email: string, password: string): Chainable<void>;
    }
  }
}

// UI login
Cypress.Commands.add('login', (email = 'test@example.com', password = 'password123') => {
  cy.visit('/login');
  cy.get('input[name="email"]').type(email);
  cy.get('input[name="password"]').type(password);
  cy.get('button[type="submit"]').click();
  cy.url().should('include', '/dashboard');
});

// API login (faster)
Cypress.Commands.add('loginByApi', (email, password) => {
  cy.request('POST', '/api/auth/login', { email, password }).then((response) => {
    window.localStorage.setItem('token', response.body.token);
  });
});
```

---

## Test Data Management

### Database Seeding (Playwright)

```typescript
// tests/e2e/global-setup.ts
import { chromium, FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
  // Reset and seed database
  const { execSync } = require('child_process');
  execSync('npm run db:reset && npm run db:seed', {
    env: { ...process.env, DATABASE_URL: process.env.TEST_DATABASE_URL },
  });
}

export default globalSetup;

// playwright.config.ts
export default defineConfig({
  globalSetup: require.resolve('./global-setup'),
});
```

### Fixtures (Cypress)

```typescript
// cypress/fixtures/users.json
{
  "validUser": {
    "email": "test@example.com",
    "password": "password123"
  },
  "adminUser": {
    "email": "admin@example.com",
    "password": "adminpass"
  }
}

// cypress/e2e/login.cy.ts
describe('Login', () => {
  beforeEach(() => {
    cy.fixture('users').as('users');
  });

  it('should login with valid user', function() {
    cy.visit('/login');
    cy.get('input[name="email"]').type(this.users.validUser.email);
    cy.get('input[name="password"]').type(this.users.validUser.password);
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});
```

---

## Common User Flows

### Form Submission

```typescript
// Playwright
test('should submit contact form', async ({ page }) => {
  await page.goto('/contact');

  await page.fill('input[name="name"]', 'John Doe');
  await page.fill('input[name="email"]', 'john@example.com');
  await page.fill('textarea[name="message"]', 'Hello, this is a test message');

  // Handle file upload
  await page.setInputFiles('input[type="file"]', 'tests/fixtures/document.pdf');

  await page.click('button[type="submit"]');

  await expect(page.locator('.success')).toBeVisible();
  await expect(page.locator('.success')).toContainText('Message sent');
});
```

### Navigation and Routing

```typescript
// Playwright
test('should navigate through main sections', async ({ page }) => {
  await page.goto('/');

  // Navigate to products
  await page.click('nav >> text=Products');
  await expect(page).toHaveURL('/products');
  await expect(page.locator('h1')).toContainText('Products');

  // Navigate to specific product
  await page.click('.product-card >> nth=0');
  await expect(page).toHaveURL(/\/products\/\d+/);

  // Use browser back
  await page.goBack();
  await expect(page).toHaveURL('/products');
});
```

### CRUD Operations

```typescript
// Playwright
test.describe('Todo CRUD', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/todos');
  });

  test('should create a todo', async ({ page }) => {
    await page.fill('input[placeholder="Add todo"]', 'New task');
    await page.press('input[placeholder="Add todo"]', 'Enter');

    await expect(page.locator('.todo-item')).toContainText('New task');
  });

  test('should edit a todo', async ({ page }) => {
    await page.dblclick('.todo-item >> nth=0');
    await page.fill('.todo-item input', 'Updated task');
    await page.press('.todo-item input', 'Enter');

    await expect(page.locator('.todo-item >> nth=0')).toContainText('Updated task');
  });

  test('should delete a todo', async ({ page }) => {
    const initialCount = await page.locator('.todo-item').count();

    await page.hover('.todo-item >> nth=0');
    await page.click('.todo-item >> nth=0 >> .delete-btn');

    await expect(page.locator('.todo-item')).toHaveCount(initialCount - 1);
  });
});
```

---

## API Mocking

### Playwright API Mocking

```typescript
// tests/e2e/mocked-api.spec.ts
import { test, expect } from '@playwright/test';

test('should display products from mocked API', async ({ page }) => {
  // Mock API response
  await page.route('**/api/products', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'Mock Product', price: 99.99 },
        { id: 2, name: 'Another Product', price: 49.99 },
      ]),
    });
  });

  await page.goto('/products');

  await expect(page.locator('.product-card')).toHaveCount(2);
  await expect(page.locator('.product-card >> nth=0')).toContainText('Mock Product');
});

test('should handle API error gracefully', async ({ page }) => {
  await page.route('**/api/products', async (route) => {
    await route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });

  await page.goto('/products');

  await expect(page.locator('.error-message')).toContainText('Failed to load products');
});
```

### Cypress API Interception

```typescript
// cypress/e2e/products.cy.ts
describe('Products', () => {
  it('should display products from mocked API', () => {
    cy.intercept('GET', '/api/products', {
      statusCode: 200,
      body: [
        { id: 1, name: 'Mock Product', price: 99.99 },
        { id: 2, name: 'Another Product', price: 49.99 },
      ],
    }).as('getProducts');

    cy.visit('/products');
    cy.wait('@getProducts');

    cy.get('.product-card').should('have.length', 2);
    cy.get('.product-card').first().should('contain', 'Mock Product');
  });
});
```

---

## Visual Testing

### Playwright Screenshots

```typescript
// tests/e2e/visual.spec.ts
import { test, expect } from '@playwright/test';

test('should match homepage screenshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixels: 100,
  });
});

test('should match component screenshot', async ({ page }) => {
  await page.goto('/components');

  const button = page.locator('.primary-button');
  await expect(button).toHaveScreenshot('primary-button.png');
});
```

---

## File Organization

```
tests/
├── e2e/
│   ├── pages/                # Page objects
│   │   ├── login.page.ts
│   │   ├── dashboard.page.ts
│   │   └── products.page.ts
│   ├── fixtures/             # Test data
│   │   └── users.json
│   ├── auth.setup.ts         # Auth setup
│   ├── auth.spec.ts          # Auth tests
│   ├── dashboard.spec.ts     # Dashboard tests
│   └── products.spec.ts      # Products tests
├── .auth/                    # Auth state storage
│   └── user.json
└── playwright.config.ts
```

---

## Running E2E Tests

```bash
# Playwright
npx playwright test                    # Run all tests
npx playwright test --headed           # Run with browser visible
npx playwright test --project=chromium # Run specific browser
npx playwright test auth.spec.ts       # Run specific file
npx playwright show-report             # View HTML report

# Cypress
npx cypress run                        # Run headless
npx cypress open                       # Open interactive mode
npx cypress run --spec "cypress/e2e/auth.cy.ts"  # Run specific file
```

---

## Checklist

Before completing E2E tests:

- [ ] Critical user flows covered (login, main actions, checkout)
- [ ] Page objects created for reusability
- [ ] Authentication state reused (not logging in every test)
- [ ] Test data isolated (not affecting other tests)
- [ ] API mocks used where appropriate
- [ ] Error scenarios tested (network failures, invalid data)
- [ ] Tests run in CI pipeline
- [ ] Screenshots/videos captured on failure
- [ ] Mobile viewport tested (if applicable)
- [ ] Tests complete in reasonable time (< 5 min total)

---

## Related

- `testing-unit.md` - Isolated function testing
- `testing-integration.md` - API and database testing
- `frontend-architecture.md` (Architect) - Frontend structure

---

*Protocol created: 2025-12-08*
*Version: 1.0*
