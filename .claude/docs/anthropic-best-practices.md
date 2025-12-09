# Anthropic Best Practices Reference Guide

> Framework-relevant insights from official Anthropic documentation.
> Last updated: 2025-12-08

---

## Sources

| Document | URL | Key Topics |
|----------|-----|------------|
| Claude Code Best Practices | [anthropic.com/engineering/claude-code-best-practices](https://www.anthropic.com/engineering/claude-code-best-practices) | CLAUDE.md, subagents, context management |
| Context Engineering for AI Agents | [anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | Token efficiency, right altitude, signal-to-noise |
| Multi-Agent Research System | [anthropic.com/engineering/multi-agent-research-system](https://www.anthropic.com/engineering/multi-agent-research-system) | Orchestrator-worker pattern, task delegation |
| Building Agents with Claude Agent SDK | [anthropic.com/engineering/building-agents-with-the-claude-agent-sdk](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk) | Agent harness, tools, verification |
| Subagents Documentation | [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents) | Configuration, delegation patterns |
| Claude 4 Prompt Engineering | [platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices) | Claude 4.x specific techniques |

---

## Core Principles

### 1. The Fundamental Token Principle

> "Find the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

**Implications for our framework:**
- Every token in agent files and specs should earn its place
- Prefer concise, high-signal instructions over comprehensive documentation
- Context injection should be selective, not exhaustive

### 2. The Right Altitude Principle

Context and instructions should be neither too specific nor too vague:

| Extreme | Problem | Example |
|---------|---------|---------|
| **Too Specific (Brittle)** | Breaks with small changes, requires constant updates | "If user says 'optimize', load performance.md, if user says 'make faster', load speed.md..." |
| **Too Vague** | Assumes shared understanding, fails to guide | "Use appropriate protocols for the task" |
| **Goldilocks Zone** | Specific enough to guide, flexible enough for heuristics | "Load performance protocols when task involves speed, caching, or optimization concerns" |

### 3. Context Rot

Accuracy decreases as context window grows due to:
- **n² pairwise relationships** - Transformer attention scales quadratically
- **Training distribution** - Less training data for very long sequences
- **Attention dilution** - Important information competes with noise

**Mitigation strategies:**
- Clear context with `/clear` between unrelated tasks
- Use subagents for isolated context windows
- Inject only relevant context per task
- Place critical information at start or end of context (avoid middle)

---

## Context Engineering

### Structuring Effective Context

**Use clear section markers:**
```xml
<background_information>
Project uses TypeScript with Prisma ORM.
</background_information>

<instructions>
Implement the feature following existing patterns.
</instructions>

<constraints>
Do not modify the database schema.
</constraints>
```

**Organization techniques:**
- XML tags for clear boundaries
- Markdown headers for hierarchy
- Start minimal, add based on observed failures

### Token Efficiency Strategies

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| **Chunked delivery** | Mention specific files, let agent retrieve | Large codebases |
| **Selective injection** | Load only task-relevant specs | Multi-spec projects |
| **Context clearing** | Reset between unrelated tasks | Long sessions |
| **Subagent isolation** | Delegate to fresh context windows | Complex multi-step tasks |

### Document Ordering

Research shows **30% performance improvement** when documents are placed at the TOP of prompts:

```markdown
<!-- CORRECT: Documents first -->
<specifications>
{injected specs here}
</specifications>

Now implement the feature described above.

<!-- INCORRECT: Documents buried -->
Implement a new feature.

Here are the specifications:
{specs here}

Please follow these carefully.
```

---

## Subagent Patterns

### When to Use Subagents

From Anthropic's documentation:

> "Subagents are useful for two main reasons. First, they enable parallelization. Second, they help manage context: subagents use their own isolated context windows, and only send relevant information back to the orchestrator."

**Use subagents when:**
- Task can be parallelized (independent subtasks)
- Need to preserve main context for later steps
- Task requires sifting through large information sets
- Early in conversation to preserve context availability
- Need specialized expertise (code review, security audit)

**Avoid subagents when:**
- Task is simple and linear
- Context sharing is critical between steps
- Overhead of spawning outweighs benefits

### Task Delegation Requirements

From Anthropic's Multi-Agent Research System:

> "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries. Without detailed task descriptions, agents duplicate work, leave gaps, or fail to find necessary information."

**Required elements for delegation:**

| Element | Description | Example |
|---------|-------------|---------|
| **Objective** | Clear goal statement | "Review code for security vulnerabilities" |
| **Output format** | What to return | "Return findings as markdown with severity levels" |
| **Tool guidance** | Which tools to use | "Use Grep for pattern matching, Read for file contents" |
| **Task boundaries** | What NOT to do | "Do not modify files, only analyze" |

### Subagent Configuration Best Practices

```yaml
---
name: code-reviewer
description: >
  Expert code reviewer. Use PROACTIVELY after any code changes.
  Analyzes quality, security, and maintainability.
tools: Read, Grep, Glob  # Minimal necessary tools
model: sonnet            # Match task complexity
---

You are a senior code reviewer...
```

**Key insights:**
- `description` field controls automatic invocation
- Include "PROACTIVELY" for automatic triggering
- Limit tools to minimum necessary
- Project-level agents take precedence over user-level

### Parallel Execution

> "Running style-checker, security-scanner, and test-coverage subagents simultaneously reduces multi-minute reviews to seconds."

**Performance impact:**
- Sequential: 10+ minutes for full validation
- Parallel: ~5 minutes (50% reduction)
- Anthropic's research system: 90% time reduction with parallelization

**Implementation pattern:**
```markdown
## Parallel Validation
Invoke simultaneously:
1. Tester agent - Run tests, report results
2. Security agent - Scan for vulnerabilities
3. Reviewer agent - Check code quality

Wait for all to complete, then synthesize results.
```

---

## Claude 4.x Prompt Engineering

### General Principles

#### Be Explicit

Claude 4.x models are trained for precise instruction following:

```markdown
<!-- Less effective -->
Create an analytics dashboard

<!-- More effective -->
Create an analytics dashboard. Include relevant features
and interactions. Go beyond the basics to create a
fully-featured implementation.
```

#### Provide Context/Motivation

Explaining WHY improves results:

```markdown
<!-- Less effective -->
NEVER use ellipses

<!-- More effective -->
Your response will be read aloud by text-to-speech,
so never use ellipses since TTS won't pronounce them correctly.
```

Claude generalizes from explanations better than from bare rules.

#### Be Vigilant with Examples

> "Claude 4.x models pay very close attention to details in examples. Ensure your examples align with the behaviors you want to encourage."

Examples are "pictures worth a thousand words" - curate diverse, canonical examples rather than exhaustive edge cases.

### Native Subagent Orchestration

> "Claude 4.5 models can recognize when tasks would benefit from delegating work to specialized subagents and do so proactively without requiring explicit instruction."

**Controlling delegation behavior:**

```markdown
<!-- More conservative -->
Only delegate to subagents when the task clearly benefits
from a separate agent with a new context window.

<!-- More aggressive (default for Claude 4.5) -->
Proactively delegate specialized tasks to appropriate subagents.
```

### Tool Usage Patterns

Claude 4.x models benefit from explicit direction:

```markdown
<!-- Less effective (Claude may only suggest) -->
Can you suggest some changes to improve this function?

<!-- More effective (Claude will act) -->
Change this function to improve its performance.
```

**For proactive action by default:**
```xml
<default_to_action>
By default, implement changes rather than only suggesting them.
If the user's intent is unclear, infer the most useful action
and proceed, using tools to discover missing details.
</default_to_action>
```

### Parallel Tool Calling

Claude 4.x models excel at parallel execution:

```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies
between the tool calls, make all independent calls in parallel.
Maximize parallel tool calls for speed and efficiency.
However, if some calls depend on previous results,
call them sequentially. Never guess missing parameters.
</use_parallel_tool_calls>
```

### Avoiding Over-Engineering

Claude Opus 4.5 tends to create extra files and abstractions:

```xml
<avoid_over_engineering>
Avoid over-engineering. Only make changes that are directly
requested or clearly necessary. Keep solutions simple and focused.

Don't add features, refactor code, or make "improvements"
beyond what was asked. Don't create helpers or abstractions
for one-time operations. Don't design for hypothetical
future requirements.

The right amount of complexity is the minimum needed
for the current task.
</avoid_over_engineering>
```

### Long-Horizon State Tracking

Claude 4.5 excels at multi-context-window workflows:

**Best practices:**
1. Use structured formats (JSON) for state data
2. Use unstructured text for progress notes
3. Use git for checkpoints and state tracking
4. Emphasize incremental progress

```json
// Structured state (tests.json)
{
  "tests": [
    {"id": 1, "name": "auth_flow", "status": "passing"},
    {"id": 2, "name": "user_mgmt", "status": "failing"}
  ],
  "passing": 150,
  "failing": 25
}
```

```text
// Progress notes (progress.txt)
Session 3:
- Fixed authentication token validation
- Next: investigate user_management failures
- Note: Do not remove tests
```

---

## Quick Reference Checklists

### Agent File Checklist

- [ ] Name is lowercase with hyphens
- [ ] Description includes WHEN to invoke
- [ ] Description includes "PROACTIVELY" if should auto-trigger
- [ ] Tools limited to minimum necessary
- [ ] Model matches task complexity (opus/sonnet/haiku)
- [ ] System prompt defines clear objective
- [ ] Output format specified
- [ ] Task boundaries explicit (what NOT to do)
- [ ] File size < 500 lines (split if larger)

### Command File Checklist

- [ ] Step 0 loads context (specs, patterns)
- [ ] Protocols specified for each agent
- [ ] Clear agent sequence defined
- [ ] Output locations specified
- [ ] Checkpoint updates for resume capability
- [ ] Human gates where appropriate
- [ ] Bounded reflexion (max 3 retries)

### Context Injection Checklist

- [ ] Documents at TOP of prompt
- [ ] XML tags for clear sections
- [ ] Only task-relevant specs loaded
- [ ] File tree generated once (not per-agent)
- [ ] Critical info at start or end (not middle)
- [ ] Total context < 50% of window (leave room for generation)

### Subagent Delegation Checklist

- [ ] Clear objective stated
- [ ] Output format specified
- [ ] Tools/sources guidance provided
- [ ] Task boundaries explicit
- [ ] Return only relevant information
- [ ] Consider parallel execution for independent tasks

---

## Anti-Patterns to Avoid

### 1. Keyword-Based Triggering

**Don't:**
```yaml
triggers: ["performance", "optimize", "slow"]
```

**Do:**
```markdown
description: >
  Load when task involves speed optimization, caching strategies,
  or performance concerns. Use judgment based on task semantics.
```

### 2. Exhaustive Context Loading

**Don't:**
```markdown
Read all files in .claude/specs/
```

**Do:**
```markdown
Read specs/requirements.md and specs/architecture.md.
Only read specs/payments.md if task involves billing.
```

### 3. Vague Task Delegation

**Don't:**
```markdown
Research the topic and report back.
```

**Do:**
```markdown
Research OAuth2 implementation patterns for Node.js.
Return:
- 3 recommended libraries with pros/cons
- Security considerations
- Example integration code
```

### 4. Bloated Tool Sets

**Don't:**
```yaml
tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, WebSearch
```

**Do:**
```yaml
tools: Read, Grep, Glob  # Read-only for reviewers
```

### 5. Middle-Buried Instructions

**Don't:**
```markdown
Here's some context...
[500 lines of specs]
IMPORTANT: Always validate input!
[more content]
```

**Do:**
```markdown
CRITICAL REQUIREMENTS:
- Always validate input
- Never expose secrets

<specifications>
[specs here]
</specifications>
```

---

## Framework-Specific Applications

### Protocol System Design

Based on research, protocols should:
1. Be loaded explicitly by commands (not keyword-triggered)
2. Have clear "When to Load" descriptions
3. Be coarse-grained (~200-400 lines, not micro-protocols)
4. Support agent override for edge cases
5. Live in `.claude/protocols/` (separate from agents)

### Agent Refactoring Strategy

Split large agents (>500 lines) into:
1. **Core file** (~200 lines) - Identity, responsibilities, quick reference
2. **Protocols** (loaded on-demand) - Detailed procedures for specific tasks

### State Communication

Use structured schemas for agent communication:
```yaml
status: PENDING | IN_PROGRESS | COMPLETED | FAILED | BLOCKED
progress:
  current_step: 3
  total_steps: 5
  checkpoint: "Validation"
outputs:
  files_created: [...]
  files_modified: [...]
```

---

## Version History

| Date | Changes |
|------|---------|
| 2025-12-08 | Initial compilation from Anthropic docs research |
