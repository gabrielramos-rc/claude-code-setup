# Artifact System - Single Source of Truth

## Purpose

The artifact system provides a persistent, file-based context management system that prevents agents from losing critical project decisions and architectural choices across conversation boundaries.

## Artifact Hierarchy (Priority Order)

When conflicts arise between different sources of information, consult in this order:

1. **`.claude/specs/requirements.md`** - What we're building
2. **`.claude/specs/architecture.md`** - How we're building it
3. **`.claude/specs/tech-stack.md`** - Technologies in use
4. **`.claude/plans/current-task.md`** - Active work description
5. **Conversation history** - Context and clarifications

## Artifact Structure

### Required Artifacts (Must Exist)

#### `.claude/specs/requirements.md`
```markdown
# Project Requirements

## User Stories
[List of user stories]

## Acceptance Criteria
[What "done" looks like]

## Out of Scope
[What we're NOT building]
```

#### `.claude/specs/architecture.md`
```markdown
# System Architecture

## Component Design
[High-level component structure]

## Data Flow
[How data moves through system]

## Integration Points
[External systems, APIs]
```

#### `.claude/specs/tech-stack.md`
```markdown
# Technology Stack

## Languages
- [Primary language + version]

## Frameworks
- [Framework + version]

## Dependencies
- [Key libraries]

## Development Tools
- [Testing, linting, build tools]
```

#### `.claude/plans/current-task.md`
```markdown
# Current Task: [Task Name]

## Objective
[What we're implementing right now]

## Files to Modify
[List of files]

## Success Criteria
[How to verify completion]

## Status
- [ ] Planning
- [ ] Implementation
- [ ] Testing
- [ ] Review
```

### Optional Artifacts

- `.claude/plans/completed-tasks.md` - History log
- `.claude/specs/api-design.md` - API contracts
- `.claude/specs/database-schema.md` - Data models
- `.claude/specs/security-requirements.md` - Security constraints

## Usage Protocol for Agents

### On Agent Invocation

1. **Read artifact directory:**
   ```bash
   ls .claude/specs/
   ls .claude/plans/
   ```

2. **Load relevant artifacts:**
   - Always read: `requirements.md`, `architecture.md`, `tech-stack.md`
   - If exists: `current-task.md`
   - If relevant: domain-specific specs

3. **Verify artifact freshness:**
   - Check last modified date
   - If > 7 days old, note potential staleness in output

### Conflict Resolution

**Scenario 1: Conversation contradicts artifact**
```
Conversation: "Use Redux for state management"
Artifact tech-stack.md: "React Context for state"

Action: Follow artifact, note discrepancy
Output: "Using React Context per tech-stack.md. Note: Earlier conversation mentioned Redux."
```

**Scenario 2: Artifact missing or unclear**
```
Artifact: Silent on database choice
Conversation: "Use PostgreSQL"

Action: Follow conversation, update artifact
Output: "Using PostgreSQL per conversation. Updating tech-stack.md."
```

**Scenario 3: Artifacts conflict with each other**
```
requirements.md: "Support 10,000 concurrent users"
architecture.md: "Single-server deployment"

Action: Flag conflict, ask for clarification
Output: "🚨 Artifact Conflict Detected:
        - requirements.md: 10k concurrent users
        - architecture.md: single-server deployment
        Recommendation: Update architecture to distributed system
        Please clarify before proceeding."
```

**Scenario 4: Artifact exists but is clearly outdated**
```
Artifact tech-stack.md: Last modified 30 days ago, says "React 17"
Conversation: "We upgraded to React 19 last week"

Action: Trust recent conversation, update artifact
Output: "Updating tech-stack.md to React 19 per recent conversation. Previous version was outdated."
```

### Artifact Updates

Agents should update artifacts when:
- **Making architectural decisions** → Update `architecture.md`
- **Completing tasks** → Move from `current-task.md` to `completed-tasks.md`
- **Adding dependencies** → Update `tech-stack.md`
- **Discovering new requirements** → Update `requirements.md` with `[DISCOVERED]` tag
- **Choosing technologies** → Update `tech-stack.md` with rationale

### Update Format

When updating an artifact, add a changelog entry:

```markdown
## Changelog

### 2025-12-05 - Added PostgreSQL
- Decision: Use PostgreSQL for persistence
- Rationale: Need ACID compliance, complex queries
- Decided by: architect agent
```

## Benefits of Artifact Priority

1. **Persistent Context** - Decisions survive conversation resets
2. **Consistency** - All agents use same source of truth
3. **Transparency** - User can inspect/modify artifacts directly
4. **Conflict Detection** - Explicit handling of contradictions
5. **Audit Trail** - Changelog tracks decision history

## Common Pitfalls to Avoid

❌ **Don't blindly follow old artifacts** - Check freshness, update when outdated
❌ **Don't ignore conversation** - Conversation can override artifacts when user is correcting
❌ **Don't update artifacts silently** - Always note what changed and why
❌ **Don't skip conflict detection** - Flag contradictions, don't guess

✅ **Do check artifacts first** - Read before implementing
✅ **Do note discrepancies** - Tell user when sources conflict
✅ **Do update proactively** - Keep artifacts current with decisions
✅ **Do ask when unclear** - Better to clarify than guess wrong
