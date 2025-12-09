---
name: api-realtime
description: >
  GraphQL schema design and real-time API patterns including WebSocket,
  Server-Sent Events (SSE), and AsyncAPI specification writing.
applies_to: [architect]
load_when: >
  Designing APIs that require flexible client-driven queries (GraphQL),
  persistent bidirectional connections (WebSocket), or server-initiated
  updates (SSE). Also for event-driven architectures.
---

# Real-Time & GraphQL API Protocol

## When to Use This Protocol

Load this protocol when your task involves:

- Designing GraphQL schemas
- Real-time features (chat, notifications, live updates)
- WebSocket connection design
- Server-Sent Events (SSE) implementation
- Event-driven API patterns
- Writing AsyncAPI specifications

**Do NOT load this protocol for:**
- Traditional REST APIs (use `api-rest.md`)
- Simple request-response patterns
- Polling-based updates (simple timer + REST)

---

## Technology Selection

| Technology | Use When | Avoid When |
|------------|----------|------------|
| **GraphQL** | Flexible queries, multiple clients, complex relationships | Simple CRUD, caching critical |
| **WebSocket** | Bidirectional, high-frequency (chat, gaming, collaboration) | Server-to-client only, simple updates |
| **SSE** | Server-to-client only, simple (notifications, feeds) | Client needs to send data |
| **Polling** | Simplest, low-frequency, wide compatibility | Real-time feel needed |

### Decision Matrix

```
Need bidirectional? ──Yes──▶ WebSocket
        │
        No
        │
        ▼
Need flexible queries? ──Yes──▶ GraphQL (+ subscriptions for real-time)
        │
        No
        │
        ▼
Need real-time updates? ──Yes──▶ SSE
        │
        No
        │
        ▼
REST API (see api-rest.md)
```

---

## GraphQL Schema Design

### When to Choose GraphQL

- Clients need flexible data fetching (mobile apps, varied UIs)
- Complex relationships between entities
- Avoiding over-fetching/under-fetching is critical
- Multiple client types with different data needs
- Real-time subscriptions needed

### Schema-First Design

Write to `schema.graphql` at project root:

```graphql
# ===================
# Types
# ===================

type User {
  id: ID!
  email: String!
  name: String
  posts(first: Int, after: String): PostConnection!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments(first: Int, after: String): CommentConnection!
  publishedAt: DateTime
  createdAt: DateTime!
}

# ===================
# Relay-Style Pagination
# ===================

type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type PostEdge {
  node: Post!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# ===================
# Queries
# ===================

type Query {
  # Single resource
  user(id: ID!): User
  post(id: ID!): Post

  # Collections (always paginated)
  users(first: Int, after: String, filter: UserFilter): UserConnection!
  posts(first: Int, after: String, filter: PostFilter): PostConnection!

  # Current user (authenticated)
  me: User
}

# ===================
# Mutations
# ===================

type Mutation {
  # Create
  createUser(input: CreateUserInput!): CreateUserPayload!
  createPost(input: CreatePostInput!): CreatePostPayload!

  # Update
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
  updatePost(id: ID!, input: UpdatePostInput!): UpdatePostPayload!

  # Delete
  deleteUser(id: ID!): DeleteUserPayload!
  deletePost(id: ID!): DeletePostPayload!
}

# ===================
# Input Types
# ===================

input CreateUserInput {
  email: String!
  name: String
  password: String!
}

input UpdateUserInput {
  name: String
  email: String
}

input UserFilter {
  email: String
  createdAfter: DateTime
}

# ===================
# Payload Types (for mutations)
# ===================

type CreateUserPayload {
  user: User
  errors: [UserError!]
}

type UserError {
  field: String
  message: String!
  code: ErrorCode!
}

enum ErrorCode {
  VALIDATION_ERROR
  NOT_FOUND
  UNAUTHORIZED
  CONFLICT
}

# ===================
# Subscriptions
# ===================

type Subscription {
  # Resource-level subscriptions
  postCreated: Post!
  postUpdated(id: ID!): Post!

  # User-scoped subscriptions
  notificationReceived: Notification!

  # Channel-based (chat, collaboration)
  messageReceived(channelId: ID!): Message!
}

# ===================
# Custom Scalars
# ===================

scalar DateTime
scalar JSON
```

### GraphQL Error Handling

Return errors in payload, not as GraphQL errors:

```graphql
# ✅ GOOD - Payload errors
type CreateUserPayload {
  user: User           # null if failed
  errors: [UserError!] # populated if failed
}

# Client checks:
# if (data.createUser.errors) { handle errors }
# else { use data.createUser.user }
```

Reserve GraphQL errors for:
- Authentication failures
- Authorization failures
- Server errors
- Malformed queries

### GraphQL Best Practices

| Practice | Description |
|----------|-------------|
| Nullable by default | Only use `!` when truly required |
| Connections for lists | Use Relay pagination for all lists |
| Input types for mutations | Never use scalar arguments |
| Payload types for mutations | Return errors in payload |
| Specific field names | `publishedAt` not `date` |

---

## WebSocket Design

### Connection Lifecycle

```
1. Client connects with auth token (query param or first message)
2. Server validates, sends: connection.established
3. Client subscribes to channels/topics
4. Heartbeat every 30s (ping/pong)
5. Reconnect with exponential backoff on disconnect
6. Resume from last event ID if supported
```

### Event Envelope Pattern

All messages use consistent structure:

```json
{
  "type": "event_name",
  "payload": { },
  "timestamp": "2024-01-15T10:30:00Z",
  "id": "evt_abc123"
}
```

### Standard Events

**Server → Client:**
```json
{ "type": "connection.established", "payload": { "session_id": "sess_123" } }
{ "type": "message.created", "payload": { "message": {...} } }
{ "type": "user.typing", "payload": { "user_id": "u_1", "channel_id": "ch_1" } }
{ "type": "presence.updated", "payload": { "user_id": "u_1", "status": "online" } }
{ "type": "error", "payload": { "code": "rate_limited", "message": "..." } }
```

**Client → Server:**
```json
{ "type": "message.send", "payload": { "channel_id": "ch_1", "content": "Hello" } }
{ "type": "channel.subscribe", "payload": { "channel_id": "ch_1" } }
{ "type": "channel.unsubscribe", "payload": { "channel_id": "ch_1" } }
{ "type": "presence.update", "payload": { "status": "away" } }
{ "type": "ping" }
```

### Reconnection Strategy

```javascript
// Exponential backoff pattern
const backoff = {
  initial: 1000,      // 1 second
  max: 30000,         // 30 seconds
  multiplier: 2,
  jitter: 0.1         // ±10% randomization
};

// Reconnect attempts: 1s, 2s, 4s, 8s, 16s, 30s, 30s...
```

### WebSocket Authentication

**Option 1: Query Parameter (simpler)**
```
wss://api.example.com/ws?token=jwt_token_here
```

**Option 2: First Message (more secure)**
```json
// Client sends immediately after connect:
{ "type": "auth", "payload": { "token": "jwt_token_here" } }

// Server responds:
{ "type": "auth.success", "payload": { "user_id": "u_123" } }
// or
{ "type": "auth.failed", "payload": { "code": "invalid_token" } }
```

---

## Server-Sent Events (SSE)

### When to Use SSE

- Server-to-client only (no client messages)
- Simple real-time updates (notifications, feeds)
- Need automatic reconnection (built into EventSource)
- HTTP/2 compatible infrastructure

### SSE Endpoint Design

```
GET /api/v1/events/stream
Accept: text/event-stream

# Response headers
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

### SSE Message Format

```
event: notification
id: evt_123
data: {"type": "new_message", "payload": {...}}

event: heartbeat
data: ping

event: notification
id: evt_124
data: {"type": "user_online", "payload": {...}}
```

### SSE with Last-Event-ID

Client reconnects automatically with `Last-Event-ID` header:
```
GET /api/v1/events/stream
Last-Event-ID: evt_123
```

Server resumes from that point.

---

## AsyncAPI Specification

For WebSocket/event-driven APIs, write to `asyncapi.yaml`:

```yaml
asyncapi: 2.6.0
info:
  title: {Project} Real-Time API
  version: 1.0.0
  description: WebSocket API for real-time features

servers:
  production:
    url: wss://api.example.com/ws
    protocol: wss
  development:
    url: ws://localhost:3000/ws
    protocol: ws

channels:
  /:
    publish:
      summary: Messages client can send
      message:
        oneOf:
          - $ref: '#/components/messages/SendMessage'
          - $ref: '#/components/messages/Subscribe'
          - $ref: '#/components/messages/Ping'
    subscribe:
      summary: Messages client receives
      message:
        oneOf:
          - $ref: '#/components/messages/MessageCreated'
          - $ref: '#/components/messages/ConnectionEstablished'
          - $ref: '#/components/messages/Error'

components:
  messages:
    SendMessage:
      name: message.send
      payload:
        type: object
        required: [type, payload]
        properties:
          type:
            const: message.send
          payload:
            type: object
            required: [channel_id, content]
            properties:
              channel_id:
                type: string
              content:
                type: string

    MessageCreated:
      name: message.created
      payload:
        type: object
        properties:
          type:
            const: message.created
          payload:
            $ref: '#/components/schemas/Message'
          timestamp:
            type: string
            format: date-time
          id:
            type: string

  schemas:
    Message:
      type: object
      properties:
        id:
          type: string
        channel_id:
          type: string
        user_id:
          type: string
        content:
          type: string
        created_at:
          type: string
          format: date-time
```

---

## Validation Commands

```bash
# GraphQL validation
npx graphql-inspector validate schema.graphql

# Check for breaking changes
npx graphql-inspector diff old-schema.graphql schema.graphql

# AsyncAPI validation
npx @asyncapi/cli validate asyncapi.yaml

# Generate docs
npx @asyncapi/cli generate fromTemplate asyncapi.yaml @asyncapi/html-template -o docs/
```

---

## Design Checklist

### GraphQL
- [ ] Schema uses Relay-style pagination
- [ ] Mutations use input/payload types
- [ ] Errors returned in payload (not GraphQL errors)
- [ ] Custom scalars defined (DateTime, JSON)
- [ ] Subscriptions use appropriate granularity
- [ ] N+1 query prevention planned (DataLoader)

### WebSocket
- [ ] Event envelope pattern consistent
- [ ] Authentication flow documented
- [ ] Heartbeat/ping-pong defined
- [ ] Reconnection strategy specified
- [ ] Event deduplication (via event ID)

### SSE
- [ ] Last-Event-ID support for resume
- [ ] Heartbeat to prevent timeout
- [ ] Event types documented

---

## Output

Document decisions in `.claude/specs/api-contracts.md`:

```markdown
# Real-Time API Design

## Technology
**Choice:** GraphQL + WebSocket subscriptions
**Rationale:** {why}

## GraphQL
**Schema:** schema.graphql
**Pagination:** Relay cursor-based
**Error handling:** Payload errors

## Real-Time
**Technology:** WebSocket
**Events:** See asyncapi.yaml
**Reconnection:** Exponential backoff (1s-30s)
```

Write machine-readable specs to project root:
- `schema.graphql` - GraphQL schema
- `asyncapi.yaml` - WebSocket/event specification

---

## Related

- `api-rest.md` - REST API design
- `.claude/patterns/performance.md` - Connection pooling, caching

---

*Protocol created: 2025-12-08*
*Version: 1.0*
