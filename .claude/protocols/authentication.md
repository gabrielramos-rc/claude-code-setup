---
name: authentication
description: >
  Authentication implementation patterns including password hashing, JWT tokens,
  OAuth/OIDC integration, session management, and multi-factor authentication.
applies_to: [security-auditor, engineer]
load_when: >
  Implementing or auditing user identity verification including login flows,
  JWT or session token management, OAuth/OIDC integration, password policies,
  or multi-factor authentication.
---

# Authentication Protocol

## When to Use This Protocol

Load this protocol when:

- Implementing login/logout flows
- Setting up JWT token authentication
- Integrating OAuth providers (Google, GitHub, etc.)
- Implementing password hashing
- Adding multi-factor authentication
- Managing user sessions

**Do NOT load this protocol for:**
- API authorization logic (use role checks in implementation)
- General security hardening (use `security-hardening.md`)
- Input validation patterns (use `security-hardening.md`)

---

## Password Handling

### Hashing (bcrypt - Recommended)

```typescript
// src/auth/password.ts
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12; // 10-12 for production

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### Alternative: Argon2 (Higher Security)

```typescript
// src/auth/password.ts
import argon2 from 'argon2';

export async function hashPassword(password: string): Promise<string> {
  return argon2.hash(password, {
    type: argon2.argon2id,
    memoryCost: 65536,  // 64MB
    timeCost: 3,
    parallelism: 4,
  });
}

export async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  return argon2.verify(hash, password);
}
```

### Password Policy

```typescript
// src/auth/password-policy.ts
export interface PasswordPolicy {
  minLength: number;
  requireUppercase: boolean;
  requireLowercase: boolean;
  requireNumbers: boolean;
  requireSpecial: boolean;
}

const defaultPolicy: PasswordPolicy = {
  minLength: 12,
  requireUppercase: true,
  requireLowercase: true,
  requireNumbers: true,
  requireSpecial: true,
};

export function validatePassword(
  password: string,
  policy: PasswordPolicy = defaultPolicy
): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (password.length < policy.minLength) {
    errors.push(`Password must be at least ${policy.minLength} characters`);
  }
  if (policy.requireUppercase && !/[A-Z]/.test(password)) {
    errors.push('Password must contain uppercase letter');
  }
  if (policy.requireLowercase && !/[a-z]/.test(password)) {
    errors.push('Password must contain lowercase letter');
  }
  if (policy.requireNumbers && !/\d/.test(password)) {
    errors.push('Password must contain number');
  }
  if (policy.requireSpecial && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('Password must contain special character');
  }

  return { valid: errors.length === 0, errors };
}
```

---

## JWT Authentication

### Token Generation

```typescript
// src/auth/jwt.ts
import jwt from 'jsonwebtoken';

interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}

interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

// IMPORTANT: JWT_SECRET must be at least 32 characters (256 bits)
const JWT_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be at least 32 characters');
}

export function generateTokens(payload: TokenPayload): TokenPair {
  const accessToken = jwt.sign(payload, JWT_SECRET, {
    expiresIn: '15m',  // Short-lived access token
    algorithm: 'HS256',
  });

  const refreshToken = jwt.sign(
    { userId: payload.userId },
    REFRESH_SECRET!,
    {
      expiresIn: '7d',  // Longer-lived refresh token
      algorithm: 'HS256',
    }
  );

  return { accessToken, refreshToken };
}

export function verifyAccessToken(token: string): TokenPayload {
  return jwt.verify(token, JWT_SECRET) as TokenPayload;
}

export function verifyRefreshToken(token: string): { userId: string } {
  return jwt.verify(token, REFRESH_SECRET!) as { userId: string };
}
```

### Auth Middleware

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../auth/jwt';

export interface AuthRequest extends Request {
  user?: {
    userId: string;
    email: string;
    role: string;
  };
}

export function authMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Missing authorization token' });
    return;
  }

  const token = authHeader.substring(7);

  try {
    const payload = verifyAccessToken(token);
    req.user = payload;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({ error: 'Token expired' });
    } else {
      res.status(401).json({ error: 'Invalid token' });
    }
  }
}
```

### Token Refresh Flow

```typescript
// src/routes/auth.ts
router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token required' });
  }

  try {
    const { userId } = verifyRefreshToken(refreshToken);

    // Verify token not revoked (check database/cache)
    const isRevoked = await tokenStore.isRevoked(refreshToken);
    if (isRevoked) {
      return res.status(401).json({ error: 'Token revoked' });
    }

    // Get fresh user data
    const user = await userRepository.findById(userId);
    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    // Generate new tokens
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Optionally rotate refresh token
    await tokenStore.revoke(refreshToken);

    return res.json(tokens);
  } catch (error) {
    return res.status(401).json({ error: 'Invalid refresh token' });
  }
});
```

---

## OAuth 2.0 / OIDC

### Google OAuth (Passport.js)

```typescript
// src/auth/strategies/google.ts
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { userRepository } from '../../repositories/user';

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      callbackURL: '/auth/google/callback',
      scope: ['profile', 'email'],
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        // Find or create user
        let user = await userRepository.findByGoogleId(profile.id);

        if (!user) {
          user = await userRepository.create({
            googleId: profile.id,
            email: profile.emails?.[0]?.value,
            name: profile.displayName,
            avatar: profile.photos?.[0]?.value,
          });
        }

        return done(null, user);
      } catch (error) {
        return done(error);
      }
    }
  )
);

// Routes
router.get('/auth/google', passport.authenticate('google'));

router.get(
  '/auth/google/callback',
  passport.authenticate('google', { session: false }),
  (req, res) => {
    const user = req.user as User;
    const tokens = generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Redirect with token or set cookie
    res.redirect(`/auth/success?token=${tokens.accessToken}`);
  }
);
```

### GitHub OAuth

```typescript
// src/auth/strategies/github.ts
import { Strategy as GitHubStrategy } from 'passport-github2';

passport.use(
  new GitHubStrategy(
    {
      clientID: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
      callbackURL: '/auth/github/callback',
      scope: ['user:email'],
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        let user = await userRepository.findByGithubId(profile.id);

        if (!user) {
          user = await userRepository.create({
            githubId: profile.id,
            email: profile.emails?.[0]?.value,
            name: profile.displayName || profile.username,
            avatar: profile.photos?.[0]?.value,
          });
        }

        return done(null, user);
      } catch (error) {
        return done(error);
      }
    }
  )
);
```

---

## Session Management

### Cookie-Based Sessions

```typescript
// src/auth/session.ts
import session from 'express-session';
import RedisStore from 'connect-redis';
import { createClient } from 'redis';

const redisClient = createClient({ url: process.env.REDIS_URL });
redisClient.connect();

export const sessionMiddleware = session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  name: 'sessionId',  // Don't use default 'connect.sid'
  cookie: {
    httpOnly: true,   // Prevent XSS access
    secure: process.env.NODE_ENV === 'production',  // HTTPS only in prod
    sameSite: 'lax',  // CSRF protection
    maxAge: 24 * 60 * 60 * 1000,  // 24 hours
  },
});
```

### Session Security Best Practices

```typescript
// Regenerate session ID after login (prevent session fixation)
router.post('/login', async (req, res) => {
  // ... validate credentials ...

  req.session.regenerate((err) => {
    if (err) {
      return res.status(500).json({ error: 'Session error' });
    }

    req.session.userId = user.id;
    req.session.save((err) => {
      if (err) {
        return res.status(500).json({ error: 'Session save error' });
      }
      res.json({ success: true });
    });
  });
});

// Destroy session on logout
router.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: 'Logout error' });
    }
    res.clearCookie('sessionId');
    res.json({ success: true });
  });
});
```

---

## Multi-Factor Authentication (MFA)

### TOTP Setup (Time-based One-Time Password)

```typescript
// src/auth/mfa.ts
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';

export async function generateMfaSecret(
  email: string
): Promise<{ secret: string; qrCode: string }> {
  const secret = speakeasy.generateSecret({
    name: `MyApp (${email})`,
    length: 32,
  });

  const qrCode = await QRCode.toDataURL(secret.otpauth_url!);

  return {
    secret: secret.base32,
    qrCode,
  };
}

export function verifyMfaToken(secret: string, token: string): boolean {
  return speakeasy.totp.verify({
    secret,
    encoding: 'base32',
    token,
    window: 1,  // Allow 1 step tolerance (30 seconds)
  });
}
```

### MFA Login Flow

```typescript
// src/routes/auth.ts
router.post('/login', async (req, res) => {
  const { email, password, mfaToken } = req.body;

  const user = await userRepository.findByEmail(email);
  if (!user || !await verifyPassword(password, user.passwordHash)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Check if MFA enabled
  if (user.mfaEnabled) {
    if (!mfaToken) {
      return res.status(200).json({
        requiresMfa: true,
        tempToken: generateTempToken(user.id),
      });
    }

    if (!verifyMfaToken(user.mfaSecret, mfaToken)) {
      return res.status(401).json({ error: 'Invalid MFA code' });
    }
  }

  const tokens = generateTokens({
    userId: user.id,
    email: user.email,
    role: user.role,
  });

  return res.json(tokens);
});
```

---

## Rate Limiting

### Login Endpoint Protection

```typescript
// src/middleware/rate-limit.ts
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';

// Strict rate limit for authentication endpoints
export const authRateLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redisClient.sendCommand(args),
  }),
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 5,                     // 5 attempts per window
  message: { error: 'Too many login attempts. Try again in 15 minutes.' },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.ip + ':' + req.body.email,  // Per IP+email
});

// Apply to auth routes
router.post('/login', authRateLimiter, loginHandler);
router.post('/register', authRateLimiter, registerHandler);
router.post('/forgot-password', authRateLimiter, forgotPasswordHandler);
```

---

## Security Audit Checklist

When auditing authentication:

- [ ] Passwords hashed with bcrypt (cost 10+) or argon2
- [ ] No plaintext passwords in logs or responses
- [ ] JWT secret at least 32 characters (256 bits)
- [ ] Access tokens short-lived (15-60 minutes)
- [ ] Refresh tokens stored securely and revocable
- [ ] Rate limiting on login (5 attempts per 15 min)
- [ ] Session IDs regenerated after login
- [ ] Cookies: httpOnly, secure (prod), sameSite
- [ ] MFA available for sensitive accounts
- [ ] OAuth callback URLs validated
- [ ] Password reset tokens single-use and time-limited

---

## Related

- `security-hardening.md` - Input validation, OWASP patterns
- `api-rest.md` (Architect) - API endpoint design
- `database-implementation.md` - User storage

---

*Protocol created: 2025-12-08*
*Version: 1.0*
