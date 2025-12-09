---
name: code-review-checklist
description: >
  Structured code review patterns covering correctness, performance, security,
  maintainability, and architecture compliance.
applies_to: [code-reviewer]
load_when: >
  Performing structured code review of pull requests or implementation changes,
  evaluating code quality, architecture compliance, and identifying issues.
---

# Code Review Protocol

## When to Use This Protocol

Load this protocol when:

- Reviewing pull requests
- Evaluating implementation quality
- Checking architecture compliance
- Assessing code maintainability
- Identifying potential issues

**Do NOT load this protocol for:**
- Security vulnerability scanning (use `security-hardening.md`)
- Test coverage analysis (Tester's domain)
- Writing implementation code (Engineer's domain)

---

## Review Priority Order

1. **Correctness** - Does it work as intended?
2. **Security** - Any obvious vulnerabilities? (flag for Security Auditor)
3. **Performance** - Any obvious inefficiencies?
4. **Maintainability** - Is it readable and maintainable?
5. **Architecture** - Does it follow established patterns?

---

## Correctness Checklist

### Logic
- [ ] Code handles all expected inputs correctly
- [ ] Edge cases are handled (null, empty, boundary values)
- [ ] Error conditions are properly managed
- [ ] Business logic matches requirements
- [ ] No off-by-one errors in loops/slices

### Data Flow
- [ ] Variables are initialized before use
- [ ] Data transformations are correct
- [ ] State mutations are intentional
- [ ] Async operations complete before dependent code

### Types (TypeScript)
- [ ] No `any` types without justification
- [ ] Nullable types handled with null checks
- [ ] Type assertions are safe
- [ ] Generic types are correctly constrained

```typescript
// BAD: Unhandled nullable
const name = user.profile.name; // Could be undefined

// GOOD: Null check
const name = user.profile?.name ?? 'Unknown';

// BAD: Unsafe assertion
const user = data as User;

// GOOD: Validated assertion
if (isUser(data)) {
  const user = data;
}
```

---

## Performance Checklist

### Algorithmic
- [ ] No unnecessary O(n²) where O(n) is possible
- [ ] No repeated expensive computations
- [ ] Collections sized appropriately
- [ ] Early returns for short-circuit optimization

```typescript
// BAD: O(n²) nested loops
const common = arr1.filter(x => arr2.includes(x));

// GOOD: O(n) with Set
const set2 = new Set(arr2);
const common = arr1.filter(x => set2.has(x));
```

### Database
- [ ] No N+1 query patterns
- [ ] Queries use appropriate indexes
- [ ] Large result sets are paginated
- [ ] Connections are properly pooled

```typescript
// BAD: N+1 queries
for (const user of users) {
  const posts = await db.post.findMany({ where: { userId: user.id } });
}

// GOOD: Single query with include
const users = await db.user.findMany({
  include: { posts: true },
});
```

### Memory
- [ ] Large objects are not held unnecessarily
- [ ] Streams used for large data
- [ ] Event listeners are cleaned up
- [ ] No memory leaks in closures

### Network
- [ ] Requests are batched where possible
- [ ] Responses are cached appropriately
- [ ] Payloads are reasonably sized
- [ ] Timeouts are configured

---

## Maintainability Checklist

### Readability
- [ ] Code is self-documenting (clear names)
- [ ] Complex logic has explanatory comments
- [ ] Functions are single-purpose
- [ ] Nesting is minimal (< 3 levels)

```typescript
// BAD: Unclear
const x = arr.filter(i => i.s === 'a' && i.d > Date.now());

// GOOD: Clear
const activeItems = items.filter(item =>
  item.status === 'active' && item.expiresAt > Date.now()
);
```

### Structure
- [ ] Functions are appropriately sized (< 50 lines ideal)
- [ ] No code duplication (DRY)
- [ ] Related code is colocated
- [ ] Abstractions are at the right level

### Naming
- [ ] Variables describe their content
- [ ] Functions describe their action
- [ ] Boolean names are questions (`isActive`, `hasPermission`)
- [ ] Consistent naming conventions

```typescript
// BAD: Unclear names
const d = getData();
const f = (x) => x.filter(i => i.a);

// GOOD: Clear names
const users = fetchActiveUsers();
const filterByActive = (items) => items.filter(item => item.isActive);
```

---

## Architecture Checklist

### Patterns
- [ ] Follows existing codebase patterns
- [ ] Matches architecture in `.claude/specs/architecture.md`
- [ ] Dependency injection used appropriately
- [ ] Separation of concerns maintained

### Dependencies
- [ ] New dependencies are justified
- [ ] No duplicate functionality with existing deps
- [ ] Dependencies are appropriately scoped (dev vs prod)
- [ ] License compatibility checked

### API Design
- [ ] Consistent with existing API patterns
- [ ] Backward compatible (or breaking change documented)
- [ ] Error responses follow standard format
- [ ] Request/response types are defined

---

## Common Issues to Flag

### Immediate Blockers
- Obvious bugs or broken logic
- Security vulnerabilities (flag for Security Auditor)
- Missing error handling for critical paths
- Breaking changes without migration path

### Should Fix
- Performance issues with measurable impact
- Code duplication
- Missing types or type safety holes
- Inconsistent patterns

### Suggestions
- Minor naming improvements
- Optional refactoring opportunities
- Documentation additions
- Test coverage improvements

---

## Review Comment Format

### Blocking Issue
```
🔴 **BLOCKER:** [Issue description]

This will cause [impact].

**Suggested fix:**
```code
// Fix here
```
```

### Should Fix
```
🟡 **SHOULD FIX:** [Issue description]

This could cause [impact] because [reason].

Consider:
```code
// Alternative approach
```
```

### Suggestion
```
💡 **SUGGESTION:** [Improvement idea]

This would improve [aspect] by [benefit].
```

### Positive Feedback
```
✅ Nice handling of [specific thing]!
```

---

## Review Output Format

```markdown
# Code Review: {PR/Feature Name}

**Reviewer:** Code Reviewer Agent
**Date:** {date}

## Summary
- **Status:** APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION
- **Blockers:** {count}
- **Should Fix:** {count}
- **Suggestions:** {count}

## Blockers

### 1. {Issue title}
**File:** `src/path/file.ts:42`
**Issue:** {description}
**Impact:** {what could go wrong}
**Fix:** {suggested solution}

## Should Fix

### 1. {Issue title}
**File:** `src/path/file.ts:87`
**Issue:** {description}
**Suggestion:** {improvement}

## Suggestions

- Consider extracting `processData` into a separate utility
- Add JSDoc for public API functions

## Positive Notes

- Good error handling in `handlePayment`
- Clean separation of concerns in service layer

## Next Steps
- Engineer: Address blockers
- Re-review after fixes
```

---

## Checklist Summary

Quick reference for reviewers:

- [ ] **Correctness:** Logic works, edge cases handled
- [ ] **Security:** No obvious vulnerabilities (flag for audit)
- [ ] **Performance:** No N+1, O(n²), or memory issues
- [ ] **Maintainability:** Readable, well-named, not duplicated
- [ ] **Architecture:** Follows patterns, deps justified
- [ ] **Types:** No `any`, nulls handled
- [ ] **Tests:** Adequate coverage (flag for Tester if not)

---

## Related

- `security-hardening.md` - Security review
- `testing-unit.md` - Test coverage
- `observability.md` - Logging review

---

*Protocol created: 2025-12-08*
*Version: 1.0*
