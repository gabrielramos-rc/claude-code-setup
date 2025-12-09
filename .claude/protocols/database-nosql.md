---
name: database-nosql
description: >
  NoSQL database patterns for MongoDB, Redis, and DynamoDB including
  document modeling, querying, and data access patterns.
applies_to: [engineer]
load_when: >
  Implementing NoSQL databases like MongoDB, Redis data structures, or
  DynamoDB for document storage, caching, or key-value operations.
---

# NoSQL Database Protocol

## When to Use This Protocol

Load this protocol when:

- Implementing MongoDB with Mongoose
- Using Redis for data storage (not just caching)
- Working with DynamoDB
- Designing document schemas
- Implementing NoSQL access patterns

**Do NOT load this protocol for:**
- Redis caching (use `caching-strategies.md`)
- Relational databases (use `database-implementation.md`)
- Database architecture decisions (Architect domain)

---

## MongoDB with Mongoose

### Connection Setup

```typescript
// src/db/mongodb.ts
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI!;

export async function connectMongoDB(): Promise<void> {
  try {
    await mongoose.connect(MONGODB_URI, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
}

mongoose.connection.on('disconnected', () => {
  console.warn('MongoDB disconnected');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error:', err);
});

export { mongoose };
```

### Schema Definition

```typescript
// src/models/user.model.ts
import { Schema, model, Document, Types } from 'mongoose';

interface IAddress {
  street: string;
  city: string;
  country: string;
  zipCode: string;
}

interface IUser extends Document {
  email: string;
  name: string;
  passwordHash: string;
  role: 'user' | 'admin';
  addresses: IAddress[];
  preferences: Map<string, unknown>;
  createdAt: Date;
  updatedAt: Date;
}

const addressSchema = new Schema<IAddress>({
  street: { type: String, required: true },
  city: { type: String, required: true },
  country: { type: String, required: true },
  zipCode: { type: String, required: true },
});

const userSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    name: { type: String, required: true },
    passwordHash: { type: String, required: true, select: false },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    addresses: [addressSchema],
    preferences: { type: Map, of: Schema.Types.Mixed },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_, ret) => {
        delete ret.passwordHash;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Indexes
userSchema.index({ email: 1 });
userSchema.index({ 'addresses.city': 1 });
userSchema.index({ createdAt: -1 });

// Text index for search
userSchema.index({ name: 'text', email: 'text' });

export const User = model<IUser>('User', userSchema);
```

### CRUD Operations

```typescript
// src/repositories/user.repository.ts
import { User } from '../models/user.model';
import { FilterQuery, UpdateQuery } from 'mongoose';

export const userRepository = {
  async create(data: CreateUserInput): Promise<IUser> {
    const user = new User(data);
    return user.save();
  },

  async findById(id: string): Promise<IUser | null> {
    return User.findById(id);
  },

  async findByEmail(email: string): Promise<IUser | null> {
    return User.findOne({ email }).select('+passwordHash');
  },

  async findAll(
    filter: FilterQuery<IUser> = {},
    options: { skip?: number; limit?: number; sort?: Record<string, 1 | -1> } = {}
  ): Promise<IUser[]> {
    return User.find(filter)
      .skip(options.skip ?? 0)
      .limit(options.limit ?? 20)
      .sort(options.sort ?? { createdAt: -1 });
  },

  async update(id: string, data: UpdateQuery<IUser>): Promise<IUser | null> {
    return User.findByIdAndUpdate(id, data, { new: true, runValidators: true });
  },

  async delete(id: string): Promise<boolean> {
    const result = await User.findByIdAndDelete(id);
    return !!result;
  },

  async search(query: string): Promise<IUser[]> {
    return User.find({ $text: { $search: query } })
      .select({ score: { $meta: 'textScore' } })
      .sort({ score: { $meta: 'textScore' } })
      .limit(20);
  },
};
```

### Aggregation

```typescript
// Complex queries with aggregation pipeline
async function getUserStats(): Promise<UserStats[]> {
  return User.aggregate([
    {
      $group: {
        _id: '$role',
        count: { $sum: 1 },
        avgAddresses: { $avg: { $size: '$addresses' } },
      },
    },
    {
      $project: {
        role: '$_id',
        count: 1,
        avgAddresses: { $round: ['$avgAddresses', 2] },
        _id: 0,
      },
    },
  ]);
}

async function getRecentOrdersByUser(userId: string) {
  return Order.aggregate([
    { $match: { userId: new Types.ObjectId(userId) } },
    { $sort: { createdAt: -1 } },
    { $limit: 10 },
    {
      $lookup: {
        from: 'products',
        localField: 'items.productId',
        foreignField: '_id',
        as: 'productDetails',
      },
    },
  ]);
}
```

---

## Redis Data Structures

### Strings (Key-Value)

```typescript
// Simple key-value
await redis.set('user:123:name', 'John Doe');
await redis.get('user:123:name');  // "John Doe"

// With expiration
await redis.setex('session:abc', 3600, JSON.stringify(sessionData));

// Atomic operations
await redis.incr('page:views');
await redis.incrby('user:123:points', 10);
```

### Hashes

```typescript
// Store object fields
await redis.hset('user:123', {
  name: 'John Doe',
  email: 'john@example.com',
  role: 'admin',
});

await redis.hget('user:123', 'name');  // "John Doe"
await redis.hgetall('user:123');  // { name: "John Doe", email: "...", ... }

// Increment hash field
await redis.hincrby('user:123', 'loginCount', 1);
```

### Lists

```typescript
// Queue (FIFO)
await redis.rpush('queue:jobs', JSON.stringify(job));
const job = await redis.lpop('queue:jobs');

// Recent items (capped list)
await redis.lpush('user:123:recent', productId);
await redis.ltrim('user:123:recent', 0, 9);  // Keep last 10
const recent = await redis.lrange('user:123:recent', 0, -1);
```

### Sets

```typescript
// Unique items
await redis.sadd('product:123:tags', 'electronics', 'sale', 'featured');
await redis.smembers('product:123:tags');  // ["electronics", "sale", "featured"]

// Set operations
await redis.sinter('user:123:interests', 'user:456:interests');  // Common interests
await redis.sunion('tag:electronics', 'tag:computers');  // All products in either tag
```

### Sorted Sets

```typescript
// Leaderboard
await redis.zadd('leaderboard', { score: 1000, member: 'user:123' });
await redis.zadd('leaderboard', { score: 1500, member: 'user:456' });

// Top 10
const top10 = await redis.zrevrange('leaderboard', 0, 9, 'WITHSCORES');

// User rank
const rank = await redis.zrevrank('leaderboard', 'user:123');

// Time-based feed
await redis.zadd('feed:123', { score: Date.now(), member: postId });
const recentPosts = await redis.zrevrangebyscore(
  'feed:123',
  '+inf',
  Date.now() - 86400000  // Last 24 hours
);
```

---

## DynamoDB

### Table Design

```typescript
// Single-table design pattern
interface DynamoItem {
  PK: string;  // Partition key
  SK: string;  // Sort key
  GSI1PK?: string;
  GSI1SK?: string;
  // Entity-specific attributes
  [key: string]: unknown;
}

// User: PK=USER#123, SK=USER#123
// Order: PK=USER#123, SK=ORDER#2024-01-15#abc
// Product: PK=PRODUCT#456, SK=PRODUCT#456
```

### Client Setup

```typescript
// src/db/dynamodb.ts
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({
  region: process.env.AWS_REGION,
});

export const docClient = DynamoDBDocumentClient.from(client, {
  marshallOptions: {
    removeUndefinedValues: true,
  },
});
```

### CRUD Operations

```typescript
// src/repositories/dynamo-user.repository.ts
import { PutCommand, GetCommand, QueryCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { docClient } from '../db/dynamodb';

const TABLE_NAME = process.env.DYNAMODB_TABLE!;

export const userRepository = {
  async create(user: User): Promise<void> {
    await docClient.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: {
        PK: `USER#${user.id}`,
        SK: `USER#${user.id}`,
        GSI1PK: `EMAIL#${user.email}`,
        GSI1SK: `USER#${user.id}`,
        ...user,
        entityType: 'USER',
      },
      ConditionExpression: 'attribute_not_exists(PK)',
    }));
  },

  async findById(id: string): Promise<User | null> {
    const result = await docClient.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: {
        PK: `USER#${id}`,
        SK: `USER#${id}`,
      },
    }));
    return result.Item as User | null;
  },

  async findByEmail(email: string): Promise<User | null> {
    const result = await docClient.send(new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :email',
      ExpressionAttributeValues: {
        ':email': `EMAIL#${email}`,
      },
    }));
    return result.Items?.[0] as User | null;
  },

  async getUserOrders(userId: string): Promise<Order[]> {
    const result = await docClient.send(new QueryCommand({
      TableName: TABLE_NAME,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `USER#${userId}`,
        ':sk': 'ORDER#',
      },
      ScanIndexForward: false,  // Most recent first
    }));
    return result.Items as Order[];
  },
};
```

---

## Data Modeling Patterns

### Embedding vs Referencing (MongoDB)

```typescript
// Embed: Small, bounded, queried together
const orderSchema = new Schema({
  userId: ObjectId,
  items: [{
    productId: ObjectId,
    name: String,  // Denormalized
    price: Number,
    quantity: Number,
  }],
  shippingAddress: addressSchema,  // Embedded
});

// Reference: Large, unbounded, queried separately
const userSchema = new Schema({
  email: String,
  // Don't embed orders - reference instead
});
```

### Single Table Design (DynamoDB)

```
| PK           | SK                    | Data          |
|--------------|----------------------|---------------|
| USER#123     | USER#123             | User data     |
| USER#123     | ORDER#2024-01#abc    | Order data    |
| USER#123     | ORDER#2024-01#def    | Order data    |
| PRODUCT#456  | PRODUCT#456          | Product data  |
| PRODUCT#456  | REVIEW#123           | Review data   |
```

---

## Checklist

Before completing NoSQL implementation:

- [ ] Connection handling with retries
- [ ] Schema/model defined with validation
- [ ] Indexes created for query patterns
- [ ] CRUD operations implemented
- [ ] Error handling for DB operations
- [ ] Connection pooling configured
- [ ] Data modeling appropriate for use case
- [ ] Aggregation/complex queries tested

---

## Related

- `database-implementation.md` - Relational databases
- `caching-strategies.md` - Redis caching
- `data-modeling.md` - Data architecture

---

*Protocol created: 2025-12-08*
*Version: 1.0*
