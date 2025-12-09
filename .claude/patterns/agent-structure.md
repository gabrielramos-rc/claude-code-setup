# Agent Structure Pattern

> Standard structure for all agent definition files in `.claude/agents/`

---

## Overview

All agents follow a consistent structure with mandatory sections, optional sections, and agent-specific sections. This ensures predictable behavior and simplifies maintenance.

---

## File Structure Template

```markdown
---
name: {agent-name}
description: >
  {One-line description of role}
  Use PROACTIVELY when {trigger condition}.

  See `.claude/patterns/context-injection.md` for context handling.
model: {opus|sonnet|haiku}
tools: {tool list}
---

{Agent persona - one line establishing identity}

## MANDATORY SECTIONS

### Your Responsibilities
### What You Write
### What You DON'T Write
### Tool Usage Guidelines
### Process

## OPTIONAL SECTIONS

### Protocol Loading
### State Communication

## REFERENCE SECTIONS

### Git Commits
### Related Patterns

## AGENT-SPECIFIC SECTIONS

### {Custom domain sections}

## CLOSING SECTIONS

### When to Invoke Other Agents
### Example: Good vs Bad
### Output Format
```

---

## Mandatory Sections

Every agent MUST have these sections in this order:

### 1. Your Responsibilities

Brief overview of what the agent does (3-5 bullet points max).

```markdown
## Your Responsibilities

- {Primary responsibility}
- {Secondary responsibility}
- {Tertiary responsibility}
```

### 2. What You Write

Files/locations this agent creates or modifies. Be explicit.

```markdown
## What You Write

**✅ DO write to these locations:**
- `path/pattern` - {purpose}
- `path/pattern` - {purpose}
```

### 3. What You DON'T Write

Files/locations this agent must NEVER touch. Critical for preventing boundary violations.

```markdown
## What You DON'T Write

**❌ NEVER write to these locations:**
- `path/pattern` - {why not, who owns it}
- `path/pattern` - {why not, who owns it}

**Critical Rule:** {One-line enforcement statement}
```

### 4. Tool Usage Guidelines

How each tool should be used by this agent. Intent-based, not restrictive.

```markdown
## Tool Usage Guidelines

### Read/Grep/Glob
**✅ Use for:** {appropriate uses}

### Write/Edit
**✅ Use for:** {appropriate uses}
**❌ Never use for:** {inappropriate uses}

### Bash
**✅ Use for:** {appropriate uses}
**❌ Never use for:** {inappropriate uses}
```

### 5. Process

Step-by-step workflow the agent follows. Numbered for clarity.

```markdown
## Process

1. **{Step Name}:** {Action description}
2. **{Step Name}:** {Action description}
3. **{Step Name}:** {Action description}
```

---

## Optional Sections

Include only if applicable to this agent:

### Protocol Loading

Only for agents that load protocols from `.claude/protocols/`.

```markdown
## Protocol Loading

Before starting work:
1. Read `.claude/protocols/INDEX.md`
2. Analyze task for protocol relevance
3. Select 1-3 relevant protocols (max)
4. State: "Loading protocols: [X, Y] because [reason]"
5. Log selection to `.claude/state/workflow-log.md`
```

### State Communication

Only for agents that write to `.claude/state/` files.

```markdown
## State Communication

After completing work, update `.claude/state/{file}.md`.
See `.claude/patterns/state-files.md` for schema.
```

---

## Reference Sections

These sections reference patterns instead of duplicating content. Keep them brief.

### Git Commits

```markdown
## Git Commits

Follow `.claude/patterns/git-workflow.md`. Use prefix: `{type}:`
```

Common prefixes by agent:
| Agent | Prefix |
|-------|--------|
| Architect | `arch:` |
| Engineer | `feat:`, `fix:` |
| Tester | `test:` |
| Security Auditor | `security:` |
| Code Reviewer | `review:` |
| Documenter | `docs:` |
| DevOps | `devops:`, `ci:` |
| UI/UX Designer | `design:` |
| Product Manager | `pm:` |

### Related Patterns

```markdown
## Related Patterns

- `.claude/patterns/{pattern}.md` - {when relevant}
```

---

## Agent-Specific Sections

Agents may add custom sections for domain-specific guidance. Place these between Reference and Closing sections.

**Examples:**
- Architect: "API Design Principles", "Technology Selection Criteria"
- Engineer: "Error Handling", "Performance Considerations"
- Tester: "Coverage Requirements", "Test Organization"
- Security Auditor: "OWASP Checklist", "Vulnerability Severity"

**Note:** When agent-specific sections grow large (>100 lines), they become candidates for protocol extraction.

---

## Closing Sections

Every agent ends with these sections:

### When to Invoke Other Agents

Reference the collaboration pattern, then list agent-specific triggers.

```markdown
## When to Invoke Other Agents

See `.claude/patterns/agent-collaboration.md` for full handoff matrix.

**Specific triggers for this agent:**
- {condition} → Invoke {Agent}
- {condition} → Invoke {Agent}
```

### Example: Good vs Bad

One good example, one bad example. Concrete and specific to the agent's domain.

```markdown
## Example: Good vs Bad

### ❌ BAD
{Bad example showing boundary violation or anti-pattern}
**Why:** {Explanation}

### ✅ GOOD
{Good example showing correct behavior}
**Why:** {Explanation}
```

### Output Format

What the agent should output when work is complete.

```markdown
## Output Format

{Description of expected output format}
```

---

## Section Order Summary

```
1. YAML Frontmatter (name, description, model, tools)
2. Persona (one line)
3. Your Responsibilities (MANDATORY)
4. What You Write (MANDATORY)
5. What You DON'T Write (MANDATORY)
6. Tool Usage Guidelines (MANDATORY)
7. Process (MANDATORY)
8. Protocol Loading (OPTIONAL)
9. State Communication (OPTIONAL)
10. Git Commits (REFERENCE)
11. Related Patterns (REFERENCE)
12. {Agent-Specific Sections}
13. When to Invoke Other Agents (CLOSING)
14. Example: Good vs Bad (CLOSING)
15. Output Format (CLOSING)
```

---

## Validation Checklist

When reviewing or creating an agent, verify:

- [ ] YAML frontmatter includes name, description, model, tools
- [ ] Description includes "Use PROACTIVELY when..." trigger
- [ ] Description references context-injection pattern
- [ ] All 5 mandatory sections present in order
- [ ] What You Write uses ✅ format
- [ ] What You DON'T Write uses ❌ format with Critical Rule
- [ ] Git Commits references git-workflow pattern
- [ ] When to Invoke references agent-collaboration pattern
- [ ] Example section has both good and bad examples
- [ ] Agent-specific sections are under 100 lines each

---

*Pattern created: 2025-12-08*
*Version: 1.0*
