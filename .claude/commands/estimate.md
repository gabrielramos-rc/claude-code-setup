---
description: Estimate complexity and effort for a feature or task
allowed-tools: Read, Grep, Glob, Task
argument-hint: <feature-description>
---

# Estimate: $ARGUMENTS

## Instructions

Analyze and estimate complexity for: **$ARGUMENTS**

---

## Process

### Step 1: Understand the Request

Parse the feature/task description and identify:
- Core functionality required
- Integration points
- Dependencies
- User-facing vs backend work

### Step 2: Codebase Analysis

Explore the codebase to understand:

```
1. Existing patterns - How similar features are implemented
2. Affected files - Which files would need changes
3. Dependencies - External libraries needed
4. Test coverage - Existing test patterns
```

### Step 3: Complexity Assessment

Rate each dimension (1-5):

| Dimension | Score | Reasoning |
|-----------|-------|-----------|
| **Scope** | ? | Number of files/components affected |
| **Technical** | ? | Algorithmic complexity, new patterns |
| **Integration** | ? | External APIs, services, databases |
| **Risk** | ? | Security, data integrity, breaking changes |
| **Unknown** | ? | Unclear requirements, new territory |

**Complexity Score:** Sum / 25 = X%

### Step 4: Breakdown

Provide task breakdown:

```markdown
## Feature: {name}

### Components
1. **{Component 1}** - {description}
   - Files: {affected files}
   - Complexity: {Low/Medium/High}

2. **{Component 2}** - {description}
   - Files: {affected files}
   - Complexity: {Low/Medium/High}

### Dependencies
- [ ] {Dependency 1} - {status: exists/needs installation}
- [ ] {Dependency 2}

### Risks
- {Risk 1} - Mitigation: {approach}
- {Risk 2} - Mitigation: {approach}
```

### Step 5: Effort Classification

Classify the overall effort:

| Level | Description | Typical Scope |
|-------|-------------|---------------|
| **XS** | Trivial | Single file, < 50 lines |
| **S** | Small | 2-3 files, < 200 lines |
| **M** | Medium | 4-10 files, new component |
| **L** | Large | 10+ files, new feature area |
| **XL** | Extra Large | Architectural change, multi-phase |

### Step 6: Recommendations

Provide:
1. **Recommended approach** - How to implement
2. **Suggested workflow** - Which command to use
3. **Prerequisites** - What to do first
4. **Risks to watch** - Key concerns

---

## Output Format

```markdown
# Estimate: {Feature Name}

## Summary
**Complexity:** {XS/S/M/L/XL}
**Risk Level:** {Low/Medium/High}
**Recommended Workflow:** /project:{implement|fix|plan}

## Complexity Breakdown
| Dimension | Score (1-5) | Notes |
|-----------|-------------|-------|
| Scope | X | {notes} |
| Technical | X | {notes} |
| Integration | X | {notes} |
| Risk | X | {notes} |
| Unknown | X | {notes} |

## Task Breakdown
{numbered list of subtasks}

## Files Affected
- `{file1}` - {change type}
- `{file2}` - {change type}

## Prerequisites
1. {prerequisite}

## Risks & Mitigations
- **{Risk}:** {mitigation}

## Recommendation
{Summary recommendation and next steps}
```

---

## Examples

```
/project:estimate Add user authentication with OAuth
/project:estimate Refactor database layer to use Prisma
/project:estimate Add real-time notifications
```
