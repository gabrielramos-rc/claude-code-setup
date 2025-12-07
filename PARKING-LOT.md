# Parking Lot

Ideas captured during development sessions for future consideration.

---

## Ideas

### 1. Hierarchical Specification System

**Date:** 2025-12-07
**Source:** Audit session discussion
**Status:** Parked

**Problem:**
State files accumulate too much information. Agents read entire files when they only need specific sections. Token waste and cognitive overload.

**Proposed Solution:**
Create a two-tier specification system:

```
.claude/specs/
├── OVERVIEW.md              ← Concise summary with links
├── features/
│   ├── auth.md              ← Full auth specification
│   ├── payments.md          ← Full payments specification
│   └── notifications.md     ← Full notifications specification
└── services/
    ├── api-gateway.md       ← Full API gateway spec
    └── database.md          ← Full database spec
```

**OVERVIEW.md example:**
```markdown
## Features

### Authentication
OAuth2 + JWT implementation for user auth.
**Full spec:** [features/auth.md](features/auth.md)

### Payments
Stripe integration for subscriptions.
**Full spec:** [features/payments.md](features/payments.md)
```

**Benefits:**
- Agents read overview first (small token cost)
- Only fetch full specs when needed
- Reduces context window usage
- Better organization as project grows

**Considerations:**
- Requires updates to context injection pattern
- Agents need guidance on when to "drill down"
- Overview must stay in sync with detailed specs

---

*Add new ideas below*

---
