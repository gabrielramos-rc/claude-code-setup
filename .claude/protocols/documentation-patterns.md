---
name: documentation-patterns
description: >
  Technical documentation patterns for APIs, READMEs, architecture docs,
  and user guides with consistent structure and quality.
applies_to: [documenter]
load_when: >
  Writing technical documentation including API docs, README files,
  architecture documentation, user guides, or contribution guidelines.
---

# Documentation Protocol

## When to Use This Protocol

Load this protocol when:

- Writing API documentation
- Creating README files
- Documenting architecture
- Writing user guides
- Creating contribution guidelines
- Documenting deployment procedures

**Do NOT load this protocol for:**
- Code comments (inline documentation)
- Specification files (Architect's domain)
- Test documentation (Tester's domain)

---

## Documentation Types

| Type | Audience | Purpose |
|------|----------|---------|
| **README** | Developers | Project overview, quick start |
| **API Docs** | API consumers | Endpoint reference |
| **Architecture** | Developers | System design decisions |
| **User Guide** | End users | How to use the product |
| **Contributing** | Contributors | How to contribute |
| **Deployment** | DevOps | How to deploy |

---

## README Structure

### Essential Sections

```markdown
# Project Name

Brief description (1-2 sentences).

## Features

- Feature 1
- Feature 2
- Feature 3

## Quick Start

### Prerequisites

- Node.js 20+
- PostgreSQL 15+

### Installation

```bash
git clone https://github.com/org/project
cd project
npm install
cp .env.example .env
npm run dev
```

## Usage

Basic usage example here.

## Documentation

- [API Reference](./docs/api.md)
- [Architecture](./docs/architecture.md)
- [Contributing](./CONTRIBUTING.md)

## License

MIT
```

### Extended README

```markdown
# Project Name

[![CI](https://github.com/org/project/actions/workflows/ci.yml/badge.svg)](...)
[![Coverage](https://codecov.io/gh/org/project/badge.svg)](...)

Brief description.

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Development](#development)
- [Deployment](#deployment)
- [Contributing](#contributing)

## Features

### Core Features
- **Feature 1:** Description
- **Feature 2:** Description

### Technical Highlights
- TypeScript with strict mode
- 90%+ test coverage
- OpenAPI documentation

## Quick Start

[Installation steps]

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `DATABASE_URL` | PostgreSQL connection | Required |
| `JWT_SECRET` | Auth secret (32+ chars) | Required |

## API Reference

See [API Documentation](./docs/api.md) for complete reference.

### Quick Examples

```bash
# Get all users
curl http://localhost:3000/api/users

# Create user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "name": "User"}'
```

## Development

### Running Tests

```bash
npm test              # Unit tests
npm run test:e2e      # E2E tests
npm run test:coverage # With coverage
```

### Code Style

```bash
npm run lint          # Check linting
npm run lint:fix      # Auto-fix
npm run format        # Format code
```

## Deployment

See [Deployment Guide](./docs/deployment.md).

## Contributing

See [Contributing Guide](./CONTRIBUTING.md).

## License

MIT License - see [LICENSE](./LICENSE)
```

---

## API Documentation

### OpenAPI/Swagger

```yaml
# docs/openapi.yaml
openapi: 3.0.3
info:
  title: My API
  version: 1.0.0
  description: |
    API for managing users and resources.

    ## Authentication
    All endpoints require Bearer token authentication.

    ## Rate Limiting
    - 100 requests per minute per IP
    - 429 response when exceeded

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: http://localhost:3000/v1
    description: Development

paths:
  /users:
    get:
      summary: List users
      tags: [Users]
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
        - name: offset
          in: query
          schema:
            type: integer
            default: 0
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
```

### Markdown API Docs

```markdown
# API Reference

## Authentication

All API requests require authentication via Bearer token:

```
Authorization: Bearer <token>
```

## Endpoints

### Users

#### List Users

```
GET /api/users
```

**Parameters:**

| Name | Type | Description |
|------|------|-------------|
| `limit` | integer | Max results (default: 20) |
| `offset` | integer | Skip results (default: 0) |

**Response:**

```json
{
  "data": [
    {
      "id": "123",
      "email": "user@example.com",
      "name": "User Name"
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 20,
    "offset": 0
  }
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 500 | Server error |
```

---

## Architecture Documentation

### Structure

```markdown
# Architecture Overview

## System Context

[High-level diagram or description]

## Key Decisions

### Decision 1: Database Choice

**Context:** Need persistent storage for user data.

**Decision:** PostgreSQL with Prisma ORM.

**Rationale:**
- Strong consistency requirements
- Complex relational queries needed
- Team familiarity

**Consequences:**
- ✅ ACID transactions
- ✅ Strong typing with Prisma
- ⚠️ Vertical scaling limits

### Decision 2: [Title]

[Same structure]

## Component Overview

### API Layer
- Express.js REST API
- JWT authentication
- Rate limiting

### Data Layer
- PostgreSQL database
- Redis cache
- Prisma ORM

### External Services
- Stripe for payments
- SendGrid for email
- S3 for file storage

## Data Flow

```
[Request] → [API Gateway] → [Auth Middleware] → [Controller]
    ↓
[Service Layer] → [Repository] → [Database]
    ↓
[Response]
```

## Security

See [Security Documentation](./security.md).

## Scalability

Current capacity: ~1000 req/min

Scaling strategy:
1. Horizontal API scaling (Kubernetes)
2. Read replicas for database
3. CDN for static assets
```

---

## User Guide Structure

```markdown
# User Guide

## Getting Started

### Creating an Account

1. Navigate to [signup page]
2. Enter your email and password
3. Verify your email
4. Complete your profile

### First Steps

After signing up:
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Features

### Feature 1

[Description with screenshots]

**How to use:**
1. Step 1
2. Step 2
3. Step 3

**Tips:**
- Tip 1
- Tip 2

### Feature 2

[Same structure]

## FAQ

### How do I reset my password?

[Answer]

### How do I delete my account?

[Answer]

## Troubleshooting

### Issue: Can't log in

**Possible causes:**
- Incorrect password
- Account not verified
- Account locked

**Solutions:**
1. [Solution 1]
2. [Solution 2]

## Support

- Email: support@example.com
- Chat: [link]
- Documentation: [link]
```

---

## Contributing Guide

```markdown
# Contributing

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Install dependencies: `npm install`
4. Create a branch: `git checkout -b feature/my-feature`

## Development

### Running Locally

```bash
npm run dev
```

### Running Tests

```bash
npm test
```

### Code Style

We use ESLint and Prettier. Run before committing:

```bash
npm run lint
npm run format
```

## Pull Request Process

1. Ensure tests pass
2. Update documentation if needed
3. Add entry to CHANGELOG.md
4. Request review

### PR Title Format

```
type(scope): description

Examples:
feat(auth): add OAuth support
fix(api): handle null user response
docs(readme): update installation steps
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code refactoring
- `test` - Tests
- `chore` - Maintenance

## Code of Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## Questions?

Open an issue or reach out to maintainers.
```

---

## Writing Guidelines

### Clarity
- Use simple language
- Avoid jargon without explanation
- One idea per sentence
- Active voice preferred

### Structure
- Lead with the most important information
- Use headings and subheadings
- Include examples for complex concepts
- Keep paragraphs short (3-4 sentences)

### Code Examples
- Always tested and working
- Include expected output
- Show common use cases first
- Explain non-obvious parts

### Formatting
- Consistent heading hierarchy
- Code blocks with language tags
- Tables for structured data
- Lists for steps or options

---

## Checklist

Before completing documentation:

- [ ] Target audience identified
- [ ] Purpose is clear
- [ ] Structure follows conventions
- [ ] Code examples are tested
- [ ] Links are valid
- [ ] Spelling/grammar checked
- [ ] Screenshots are current (if used)
- [ ] Version information included

---

## Related

- `api-rest.md` - API design for documentation
- `code-review-checklist.md` - Documentation review

---

*Protocol created: 2025-12-08*
*Version: 1.0*
