---
name: api-versioning
description: >
  API versioning strategies for managing breaking changes including URL path
  versioning, header versioning, and migration patterns.
applies_to: [architect, engineer]
load_when: >
  Managing breaking API changes, implementing version negotiation, or
  migrating clients between API versions.
---

# API Versioning Protocol

## When to Use This Protocol

Load this protocol when:

- Introducing breaking API changes
- Setting up versioning strategy
- Migrating clients between versions
- Deprecating old API versions
- Documenting version differences

**Do NOT load this protocol for:**
- Non-breaking additive changes
- Internal API changes
- Database schema versioning

---

## Versioning Strategies

| Strategy | Format | Pros | Cons |
|----------|--------|------|------|
| **URL Path** | `/v1/users` | Clear, cacheable | URL pollution |
| **Query Param** | `/users?version=1` | Easy to change | Not RESTful |
| **Header** | `Accept-Version: 1` | Clean URLs | Hidden |
| **Content-Type** | `Accept: application/vnd.api.v1+json` | Formal | Complex |

**Recommendation:** URL Path versioning for most APIs.

---

## URL Path Versioning

### Route Structure

```typescript
// src/routes/index.ts
import { Router } from 'express';
import v1Routes from './v1';
import v2Routes from './v2';

const router = Router();

router.use('/v1', v1Routes);
router.use('/v2', v2Routes);

// Redirect latest to current version
router.use('/latest', v2Routes);

export default router;
```

### Version-Specific Routes

```typescript
// src/routes/v1/users.ts
import { Router } from 'express';

const router = Router();

router.get('/users', async (req, res) => {
  const users = await userService.findAll();

  // V1 response format
  res.json({
    users: users.map(user => ({
      id: user.id,
      name: user.name,
      email: user.email,
    })),
  });
});

export default router;

// src/routes/v2/users.ts
import { Router } from 'express';

const router = Router();

router.get('/users', async (req, res) => {
  const users = await userService.findAll();

  // V2 response format (different structure)
  res.json({
    data: users.map(user => ({
      id: user.id,
      attributes: {
        fullName: user.name,
        emailAddress: user.email,
        createdAt: user.createdAt,
      },
    })),
    meta: {
      total: users.length,
    },
  });
});

export default router;
```

---

## Header Versioning

### Middleware

```typescript
// src/middleware/api-version.ts
import { Request, Response, NextFunction } from 'express';

const SUPPORTED_VERSIONS = ['1', '2'];
const DEFAULT_VERSION = '2';

export function apiVersion(req: Request, res: Response, next: NextFunction) {
  const version = req.headers['accept-version'] as string ||
                  req.headers['x-api-version'] as string ||
                  DEFAULT_VERSION;

  if (!SUPPORTED_VERSIONS.includes(version)) {
    return res.status(400).json({
      error: {
        code: 'UNSUPPORTED_VERSION',
        message: `API version ${version} is not supported`,
        supportedVersions: SUPPORTED_VERSIONS,
      },
    });
  }

  req.apiVersion = version;
  res.setHeader('X-API-Version', version);
  next();
}
```

### Version-Aware Handler

```typescript
// src/controllers/users.controller.ts
export async function getUsers(req: Request, res: Response) {
  const users = await userService.findAll();

  if (req.apiVersion === '1') {
    return res.json(formatV1Response(users));
  }

  return res.json(formatV2Response(users));
}

function formatV1Response(users: User[]) {
  return {
    users: users.map(u => ({ id: u.id, name: u.name })),
  };
}

function formatV2Response(users: User[]) {
  return {
    data: users.map(u => ({
      id: u.id,
      type: 'user',
      attributes: { name: u.name, email: u.email },
    })),
  };
}
```

---

## Breaking vs Non-Breaking Changes

### Non-Breaking (No Version Bump)
- Adding new optional fields
- Adding new endpoints
- Adding new optional query parameters
- Expanding enum values (if clients ignore unknown)
- Performance improvements

### Breaking (Requires Version Bump)
- Removing or renaming fields
- Changing field types
- Changing response structure
- Removing endpoints
- Changing authentication method
- Changing error format

---

## Version Migration

### Deprecation Headers

```typescript
// src/middleware/deprecation.ts
export function deprecationWarning(version: string, sunsetDate: Date) {
  return (req: Request, res: Response, next: NextFunction) => {
    res.setHeader('Deprecation', 'true');
    res.setHeader('Sunset', sunsetDate.toUTCString());
    res.setHeader('Link', `</v2${req.path}>; rel="successor-version"`);

    // Also add to response body
    res.on('finish', () => {
      if (res.statusCode < 400) {
        console.warn(`Deprecated API v${version} called: ${req.method} ${req.path}`);
      }
    });

    next();
  };
}

// Usage
router.use('/v1', deprecationWarning('1', new Date('2025-06-01')), v1Routes);
```

### Migration Guide Template

```markdown
# API v1 to v2 Migration Guide

## Timeline

- **v2 Release:** 2024-01-15
- **v1 Deprecation:** 2024-06-15
- **v1 Sunset:** 2025-01-15

## Breaking Changes

### 1. Response Format

**v1:**
```json
{
  "users": [{ "id": "1", "name": "John" }]
}
```

**v2:**
```json
{
  "data": [{ "id": "1", "type": "user", "attributes": { "name": "John" } }]
}
```

### 2. Endpoint Changes

| v1 | v2 | Notes |
|----|----| ------|
| `GET /users/{id}` | `GET /users/{id}` | Response format changed |
| `POST /users/create` | `POST /users` | Path simplified |
| `DELETE /users/delete/{id}` | `DELETE /users/{id}` | Path simplified |

## Migration Steps

1. Update API base URL to `/v2`
2. Update response parsing for new format
3. Update request paths as shown above
4. Test all endpoints
```

---

## Version Negotiation

### Content Negotiation

```typescript
// src/middleware/content-negotiation.ts
export function contentNegotiation(req: Request, res: Response, next: NextFunction) {
  const accept = req.headers.accept || '';

  // Parse version from Accept header
  // Accept: application/vnd.myapi.v2+json
  const match = accept.match(/application\/vnd\.myapi\.v(\d+)\+json/);

  if (match) {
    req.apiVersion = match[1];
  } else {
    req.apiVersion = '2'; // Default
  }

  next();
}
```

### Version Response Wrapper

```typescript
// src/utils/response.ts
interface ApiResponse<T> {
  version: string;
  data: T;
  meta?: Record<string, unknown>;
}

export function formatResponse<T>(
  version: string,
  data: T,
  meta?: Record<string, unknown>
): ApiResponse<T> {
  return {
    version,
    data,
    ...(meta && { meta }),
  };
}
```

---

## Versioning in OpenAPI

```yaml
# openapi/v1.yaml
openapi: 3.0.3
info:
  title: My API
  version: "1.0.0"
  x-api-id: my-api
  x-lifecycle-status: deprecated
  x-sunset-date: "2025-01-15"

servers:
  - url: https://api.example.com/v1

# openapi/v2.yaml
openapi: 3.0.3
info:
  title: My API
  version: "2.0.0"

servers:
  - url: https://api.example.com/v2
```

---

## Sunset Policy

```typescript
// src/config/api-versions.ts
export const API_VERSIONS = {
  v1: {
    status: 'deprecated',
    deprecatedAt: new Date('2024-06-15'),
    sunsetAt: new Date('2025-01-15'),
    documentation: '/docs/migration-v1-to-v2',
  },
  v2: {
    status: 'current',
    releasedAt: new Date('2024-01-15'),
  },
  v3: {
    status: 'beta',
    releasedAt: new Date('2024-12-01'),
  },
};
```

---

## Client SDK Versioning

```typescript
// sdk/index.ts
import { ApiClientV1 } from './v1';
import { ApiClientV2 } from './v2';

export { ApiClientV1, ApiClientV2 };

// Default export is latest stable
export { ApiClientV2 as ApiClient };

// Usage
import { ApiClient } from '@mycompany/api-sdk';
// or
import { ApiClientV1 } from '@mycompany/api-sdk';
```

---

## Checklist

Before releasing new API version:

- [ ] Breaking changes documented
- [ ] Migration guide written
- [ ] Deprecation headers added to old version
- [ ] Sunset date announced
- [ ] OpenAPI spec updated for both versions
- [ ] SDK updated with new version support
- [ ] Changelog updated
- [ ] Client communication sent
- [ ] Monitoring for old version usage

---

## Related

- `api-rest.md` - REST API design
- `documentation-patterns.md` - API documentation
- `error-handling.md` - Error response versioning

---

*Protocol created: 2025-12-08*
*Version: 1.0*
