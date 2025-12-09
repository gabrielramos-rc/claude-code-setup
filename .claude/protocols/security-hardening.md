---
name: security-hardening
description: >
  Security hardening patterns including OWASP Top 10 mitigations, input validation,
  output encoding, dependency scanning, secret management, and security headers.
applies_to: [security-auditor, engineer]
load_when: >
  Reviewing code for OWASP Top 10 vulnerabilities, implementing input validation
  and output encoding, managing secrets, scanning dependencies, or hardening
  application configuration.
---

# Security Hardening Protocol

## When to Use This Protocol

Load this protocol when:

- Reviewing code for OWASP vulnerabilities
- Implementing input validation
- Adding output encoding (XSS prevention)
- Scanning dependencies for vulnerabilities
- Setting up secret management
- Configuring security headers
- Hardening application configuration

**Do NOT load this protocol for:**
- Authentication flows (use `authentication.md`)
- API design decisions (use `api-rest.md`)

---

## OWASP Top 10 Mitigations

### A01: Broken Access Control

```typescript
// BAD: No authorization check
router.get('/admin/users', async (req, res) => {
  const users = await db.user.findMany();
  res.json(users);
});

// GOOD: Role-based access control
router.get('/admin/users', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const users = await db.user.findMany();
  res.json(users);
});

// GOOD: Resource-level authorization
router.get('/orders/:id', authMiddleware, async (req, res) => {
  const order = await db.order.findUnique({
    where: { id: req.params.id },
  });

  // Check ownership
  if (order.userId !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  res.json(order);
});
```

### A02: Cryptographic Failures

```typescript
// BAD: Weak hashing
import crypto from 'crypto';
const hash = crypto.createHash('md5').update(password).digest('hex');

// GOOD: Strong hashing
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);

// BAD: Hardcoded secrets
const JWT_SECRET = 'my-secret-key';

// GOOD: Environment-based secrets with validation
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}

// GOOD: Encrypt sensitive data at rest
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

function encrypt(data: string): { encrypted: string; iv: string } {
  const iv = randomBytes(16);
  const cipher = createCipheriv('aes-256-gcm', Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
  const encrypted = Buffer.concat([cipher.update(data), cipher.final()]);
  const tag = cipher.getAuthTag();
  return {
    encrypted: Buffer.concat([encrypted, tag]).toString('base64'),
    iv: iv.toString('base64'),
  };
}
```

### A03: Injection

#### SQL Injection Prevention

```typescript
// BAD: String concatenation
const query = `SELECT * FROM users WHERE email = '${email}'`;

// GOOD: Parameterized queries (Prisma)
const user = await prisma.user.findUnique({
  where: { email },
});

// GOOD: Parameterized queries (raw SQL)
const user = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${email}
`;

// GOOD: Drizzle ORM
const user = await db.select().from(users).where(eq(users.email, email));
```

#### Command Injection Prevention

```typescript
// BAD: Direct command execution
import { exec } from 'child_process';
exec(`convert ${filename} output.png`);

// GOOD: Use array arguments (no shell)
import { execFile } from 'child_process';
execFile('convert', [filename, 'output.png']);

// GOOD: Validate input
const ALLOWED_EXTENSIONS = ['.jpg', '.png', '.gif'];
if (!ALLOWED_EXTENSIONS.some(ext => filename.endsWith(ext))) {
  throw new Error('Invalid file type');
}
```

### A04: Insecure Design

```typescript
// BAD: Security question for password reset
router.post('/reset-password', (req, res) => {
  if (req.body.answer === user.securityAnswer) {
    // Reset password
  }
});

// GOOD: Time-limited token via email
router.post('/forgot-password', async (req, res) => {
  const token = crypto.randomBytes(32).toString('hex');
  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

  await db.passwordReset.create({
    data: {
      userId: user.id,
      token: hashedToken,
      expiresAt: new Date(Date.now() + 3600000), // 1 hour
    },
  });

  await sendEmail(user.email, `Reset: /reset?token=${token}`);
  res.json({ message: 'Check your email' });
});
```

### A05: Security Misconfiguration

```typescript
// Security headers middleware
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],  // Adjust as needed
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

// CORS configuration
import cors from 'cors';

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Error handling (don't expose stack traces)
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err);  // Log for debugging

  // Don't expose details in production
  if (process.env.NODE_ENV === 'production') {
    res.status(500).json({ error: 'Internal server error' });
  } else {
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});
```

### A06: Vulnerable Components

```bash
# Check for vulnerabilities
npm audit

# Check for outdated packages
npm outdated

# Auto-fix where possible
npm audit fix

# Force update (may break things)
npm audit fix --force
```

```typescript
// package.json - Lock versions
{
  "dependencies": {
    "express": "4.18.2",  // Exact version
    "lodash": "^4.17.21"  // Caret for minor updates
  },
  "overrides": {
    // Force specific version for transitive dependency
    "nth-check": "2.1.1"
  }
}
```

### A07: Identification and Authentication Failures

See `authentication.md` protocol for comprehensive patterns.

### A08: Software and Data Integrity Failures

```typescript
// Verify webhook signatures
router.post('/webhook/stripe', express.raw({ type: 'application/json' }), (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  try {
    const event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    // Handle event
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
});

// Subresource Integrity for CDN scripts
// <script src="https://cdn.example.com/lib.js"
//         integrity="sha384-abc123..."
//         crossorigin="anonymous"></script>
```

### A09: Security Logging and Monitoring Failures

```typescript
// src/middleware/audit-log.ts
interface AuditEvent {
  timestamp: Date;
  userId?: string;
  action: string;
  resource: string;
  ip: string;
  userAgent: string;
  success: boolean;
  details?: Record<string, unknown>;
}

export function auditLog(event: AuditEvent): void {
  // Log to structured logging system
  logger.info('audit', {
    ...event,
    timestamp: event.timestamp.toISOString(),
  });
}

// Usage
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await authenticate(email, password);

  auditLog({
    timestamp: new Date(),
    userId: user?.id,
    action: 'LOGIN',
    resource: '/auth/login',
    ip: req.ip,
    userAgent: req.headers['user-agent'] || '',
    success: !!user,
    details: { email },
  });
});
```

### A10: Server-Side Request Forgery (SSRF)

```typescript
// BAD: User-controlled URL
router.get('/fetch', async (req, res) => {
  const response = await fetch(req.query.url);  // SSRF vulnerable!
  res.json(await response.json());
});

// GOOD: Allowlist domains
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com'];

router.get('/fetch', async (req, res) => {
  const url = new URL(req.query.url);

  if (!ALLOWED_DOMAINS.includes(url.hostname)) {
    return res.status(400).json({ error: 'Domain not allowed' });
  }

  // Also block internal IPs
  const ip = await dns.lookup(url.hostname);
  if (isPrivateIP(ip)) {
    return res.status(400).json({ error: 'Internal addresses not allowed' });
  }

  const response = await fetch(url.toString());
  res.json(await response.json());
});
```

---

## Input Validation

### Schema Validation (Zod)

```typescript
// src/validators/user.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string()
    .min(12, 'Password must be at least 12 characters')
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[a-z]/, 'Must contain lowercase')
    .regex(/\d/, 'Must contain number')
    .regex(/[!@#$%^&*]/, 'Must contain special character'),
  name: z.string()
    .min(1, 'Name required')
    .max(100, 'Name too long')
    .regex(/^[\p{L}\s'-]+$/u, 'Invalid characters'),  // Unicode letters only
});

export const updateUserSchema = createUserSchema.partial();

// Validation middleware
export function validate<T>(schema: z.ZodType<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        error: 'Validation failed',
        details: result.error.errors.map(e => ({
          field: e.path.join('.'),
          message: e.message,
        })),
      });
    }

    req.body = result.data;
    next();
  };
}

// Usage
router.post('/users', validate(createUserSchema), createUser);
```

### Sanitization

```typescript
// src/utils/sanitize.ts
import DOMPurify from 'isomorphic-dompurify';

// HTML sanitization (for rich text)
export function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'a'],
    ALLOWED_ATTR: ['href'],
  });
}

// Strip all HTML (for plain text fields)
export function stripHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, { ALLOWED_TAGS: [] });
}

// Filename sanitization
export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[^a-zA-Z0-9._-]/g, '_')  // Replace invalid chars
    .replace(/\.{2,}/g, '.')            // No path traversal
    .slice(0, 255);                     // Limit length
}
```

---

## Output Encoding

### XSS Prevention

```typescript
// React (JSX) - Auto-escaped by default
function UserProfile({ user }) {
  return <div>{user.name}</div>;  // Safe - auto-escaped
}

// DANGEROUS: dangerouslySetInnerHTML
function RichContent({ html }) {
  // Only use with sanitized content
  return <div dangerouslySetInnerHTML={{ __html: sanitizeHtml(html) }} />;
}

// API responses - JSON encoding is safe
res.json({ message: userInput });  // Safe - JSON encoded

// Template literals in HTML (server-side rendering)
import { escape } from 'html-escaper';

const html = `<p>Hello, ${escape(userName)}</p>`;
```

### Content-Type Headers

```typescript
// Always set correct content type
res.setHeader('Content-Type', 'application/json');
res.json(data);

// Prevent MIME sniffing
app.use(helmet.noSniff());  // X-Content-Type-Options: nosniff
```

---

## Dependency Scanning

### npm audit

```bash
# Check for vulnerabilities
npm audit

# JSON output for CI
npm audit --json > audit-report.json

# Check severity
npm audit --audit-level=high  # Fail on high+ only
```

### CI Integration

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci
      - run: npm audit --audit-level=high
```

### Automated Dependency Updates

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    groups:
      development-dependencies:
        dependency-type: "development"
      production-dependencies:
        dependency-type: "production"
```

---

## Secret Management

### Environment Variables

```bash
# .env.example (commit this)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
JWT_SECRET=generate-a-32-character-secret-here
STRIPE_SECRET_KEY=sk_test_...

# .env (NEVER commit)
DATABASE_URL=postgresql://...actual-credentials...
JWT_SECRET=actual-secret-value-at-least-32-chars
```

### Validation at Startup

```typescript
// src/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  PORT: z.string().transform(Number).default('3000'),
});

function validateEnv() {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    console.error('Environment validation failed:');
    result.error.errors.forEach(err => {
      console.error(`  ${err.path}: ${err.message}`);
    });
    process.exit(1);
  }

  return result.data;
}

export const env = validateEnv();
```

### Secret Managers (Production)

```typescript
// AWS Secrets Manager
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: 'us-east-1' });

async function getSecret(secretId: string): Promise<string> {
  const response = await client.send(
    new GetSecretValueCommand({ SecretId: secretId })
  );
  return response.SecretString!;
}

// Load secrets at startup
const dbCredentials = JSON.parse(await getSecret('prod/db-credentials'));
```

---

## Security Headers

### Complete Helmet Configuration

```typescript
import helmet from 'helmet';

app.use(helmet({
  // Content Security Policy
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.stripe.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },

  // Cross-Origin policies
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: "same-origin" },
  crossOriginResourcePolicy: { policy: "same-origin" },

  // DNS prefetch control
  dnsPrefetchControl: { allow: false },

  // Frameguard (clickjacking prevention)
  frameguard: { action: "deny" },

  // HSTS
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },

  // IE no open
  ieNoOpen: true,

  // No sniff
  noSniff: true,

  // Origin agent cluster
  originAgentCluster: true,

  // Permitted cross-domain policies
  permittedCrossDomainPolicies: { permittedPolicies: "none" },

  // Referrer policy
  referrerPolicy: { policy: "strict-origin-when-cross-origin" },

  // XSS filter (legacy)
  xssFilter: true,
}));
```

---

## Scanning Commands

### Security Auditor Bash Commands

```bash
# Dependency vulnerabilities
npm audit --json

# Outdated packages
npm outdated --json

# Secret scanning (grep patterns)
grep -r "password.*=.*['\"]" src/
grep -r "api[_-]key.*=.*['\"]" src/
grep -r "secret.*=.*['\"]" src/
grep -r "-----BEGIN" src/  # Private keys

# Code patterns
grep -r "eval(" src/           # Code injection
grep -r "innerHTML" src/       # XSS
grep -r "dangerouslySetInnerHTML" src/
grep -r "\$queryRaw" src/      # Raw SQL
grep -r "exec(" src/           # Command injection
grep -r "createHash\('md5'\)" src/  # Weak hashing

# ESLint security plugin
npx eslint --plugin security src/
```

---

## Checklist

When hardening application:

- [ ] All user input validated (Zod/Joi schemas)
- [ ] Output properly encoded (XSS prevention)
- [ ] No SQL injection (ORM/parameterized queries)
- [ ] No command injection (execFile, not exec)
- [ ] Secrets in environment variables (not code)
- [ ] npm audit clean (no high/critical vulns)
- [ ] Security headers configured (Helmet)
- [ ] CORS properly restricted
- [ ] Error messages don't leak info (prod)
- [ ] Audit logging for sensitive operations
- [ ] SSRF protection (URL allowlisting)
- [ ] File uploads validated and sanitized

---

## Related

- `authentication.md` - Auth patterns, JWT, sessions
- `api-rest.md` (Architect) - API design
- `observability.md` - Logging and monitoring

---

*Protocol created: 2025-12-08*
*Version: 1.0*
