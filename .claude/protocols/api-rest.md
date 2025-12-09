---
name: api-rest
description: >
  REST API design patterns including endpoint structure, versioning,
  pagination, error handling, and OpenAPI specification writing.
applies_to: [architect]
load_when: >
  Designing traditional request-response APIs where clients call specific
  URL endpoints with HTTP methods to perform CRUD operations on resources.
---

# REST API Design Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Designing new REST API endpoints
- Adding endpoints to existing REST API
- Defining versioning strategy for APIs
- Specifying pagination patterns
- Designing error response formats
- Writing OpenAPI specifications

**Do NOT load this protocol for:**
- GraphQL schema design (use `api-realtime.md`)
- WebSocket/SSE real-time APIs (use `api-realtime.md`)
- Simple CRUD following existing patterns in codebase
- Internal function interfaces

---

## Versioning Strategy

| Strategy | URL Example | Use When |
|----------|-------------|----------|
| URL Path | `/api/v1/users` | Public APIs, clear breaking changes |
| Header | `Accept: application/vnd.api+json;version=1` | Internal APIs, flexible clients |
| Query Param | `/api/users?version=1` | Simple cases, less common |

**Recommendation:** URL path versioning for most projects (clearest, best tooling support).

---

## Resource Structure

Follow RESTful conventions:

```yaml
# Standard CRUD operations
GET    /api/v1/users          # List users
POST   /api/v1/users          # Create user
GET    /api/v1/users/{id}     # Get user
PUT    /api/v1/users/{id}     # Replace user
PATCH  /api/v1/users/{id}     # Update user fields
DELETE /api/v1/users/{id}     # Delete user

# Nested resources for relationships
GET    /api/v1/users/{id}/posts    # User's posts
POST   /api/v1/users/{id}/posts    # Create post for user

# Actions that don't fit CRUD
POST   /api/v1/users/{id}/activate    # Custom action
POST   /api/v1/auth/login             # Auth endpoints
```

### Naming Conventions

- Use plural nouns: `/users`, `/posts`, `/comments`
- Use kebab-case for multi-word: `/user-profiles`, `/order-items`
- Avoid verbs in URLs (use HTTP methods instead)
- Keep URLs lowercase

---

## Pagination Patterns

### Cursor-Based (Recommended)

Best for large datasets, real-time data, consistent performance.

```yaml
# Request
GET /api/v1/users?cursor=abc123&limit=20

# Response
{
  "data": [...],
  "pagination": {
    "next_cursor": "def456",
    "prev_cursor": "xyz789",
    "has_more": true
  }
}
```

### Offset-Based

Simpler implementation, suitable for smaller datasets.

```yaml
# Request
GET /api/v1/users?page=2&per_page=20

# Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### When to Use Which

| Pattern | Pros | Cons | Use When |
|---------|------|------|----------|
| Cursor | Consistent, handles real-time | Complex, no jump-to-page | Large/dynamic datasets |
| Offset | Simple, jump-to-page | Slow on large data, inconsistent | Small/static datasets |

---

## Error Response Format

Follow RFC 7807 Problem Details:

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "The request body contains invalid fields",
  "instance": "/api/v1/users",
  "errors": [
    { "field": "email", "message": "Invalid email format" },
    { "field": "password", "message": "Must be at least 8 characters" }
  ]
}
```

### Standard Error Types

| Status | Type | When |
|--------|------|------|
| 400 | `/errors/validation` | Invalid request body |
| 401 | `/errors/unauthorized` | Missing/invalid auth |
| 403 | `/errors/forbidden` | Valid auth, no permission |
| 404 | `/errors/not-found` | Resource doesn't exist |
| 409 | `/errors/conflict` | Resource conflict (duplicate) |
| 422 | `/errors/unprocessable` | Valid syntax, invalid semantics |
| 429 | `/errors/rate-limit` | Too many requests |
| 500 | `/errors/internal` | Server error |

---

## Rate Limiting

### Response Headers

Include in all responses:

```yaml
X-RateLimit-Limit: 100        # Requests per window
X-RateLimit-Remaining: 95     # Remaining requests
X-RateLimit-Reset: 1640995200 # Window reset (Unix timestamp)
```

### 429 Response

```json
{
  "type": "https://api.example.com/errors/rate-limit",
  "title": "Rate Limit Exceeded",
  "status": 429,
  "detail": "You have exceeded 100 requests per minute",
  "retry_after": 45
}
```

### Recommended Limits

| Client Type | Limit | Window |
|-------------|-------|--------|
| Authenticated | 100-1000 | per minute |
| Anonymous | 10-60 | per minute |
| Batch/Bulk | 10-100 | per minute |

---

## OpenAPI Specification

Write to `openapi.yaml` at project root:

```yaml
openapi: 3.0.3
info:
  title: {Project Name} API
  version: 1.0.0
  description: |
    {Brief description}

    ## Authentication
    All endpoints require Bearer token unless marked public.

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: http://localhost:3000/v1
    description: Development

paths:
  /users:
    get:
      summary: List users
      operationId: listUsers
      tags: [Users]
      parameters:
        - name: cursor
          in: query
          description: Pagination cursor
          schema:
            type: string
        - name: limit
          in: query
          description: Number of results (max 100)
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/RateLimited'

    post:
      summary: Create user
      operationId: createUser
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'

components:
  schemas:
    User:
      type: object
      required: [id, email, created_at]
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
        created_at:
          type: string
          format: date-time

    UserList:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/User'
        pagination:
          $ref: '#/components/schemas/CursorPagination'

    CursorPagination:
      type: object
      properties:
        next_cursor:
          type: string
        has_more:
          type: boolean

    Error:
      type: object
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string

  responses:
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    ValidationError:
      description: Validation failed
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    RateLimited:
      description: Rate limit exceeded
      headers:
        Retry-After:
          schema:
            type: integer
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

---

## Validation Commands

Use Bash to validate OpenAPI specifications:

```bash
# Lint OpenAPI spec
npx @redocly/cli lint openapi.yaml

# Style enforcement
npx spectral lint openapi.yaml

# Generate documentation
npx @redocly/cli build-docs openapi.yaml -o docs/api.html

# Generate TypeScript types
npx openapi-typescript openapi.yaml -o src/types/api.d.ts
```

---

## Design Checklist

Before finalizing REST API design:

- [ ] Versioning strategy documented (recommend URL path)
- [ ] All endpoints follow RESTful conventions
- [ ] Pagination pattern consistent (cursor or offset)
- [ ] Error format follows RFC 7807
- [ ] Rate limiting strategy defined with headers
- [ ] Authentication documented (Bearer/API key)
- [ ] OpenAPI spec validates without errors
- [ ] Response examples included for each endpoint

---

## Output

Document decisions in `.claude/specs/api-contracts.md`:

```markdown
# REST API Design

## Versioning
**Strategy:** URL path (/api/v1/)
**Breaking change policy:** {policy}

## Authentication
**Method:** JWT Bearer tokens
**Token lifetime:** 1h access, 7d refresh

## Rate Limiting
**Authenticated:** 100 req/min
**Anonymous:** 20 req/min

## Pagination
**Pattern:** Cursor-based
**Default limit:** 20
**Max limit:** 100
```

Write machine-readable spec to project root:
- `openapi.yaml` - OpenAPI 3.0+ specification

---

## Related

- `api-realtime.md` - GraphQL and real-time APIs
- `.claude/patterns/performance.md` - Caching and rate limiting patterns
- `.claude/patterns/input-safety.md` - Input validation

---

*Protocol created: 2025-12-08*
*Version: 1.0*
