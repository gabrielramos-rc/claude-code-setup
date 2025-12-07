# Context Injection Pattern

**Version:** v0.3
**Purpose:** Load specifications once per command, inject into all agent prompts to eliminate redundant reads
**Expected Impact:** 40-50% token reduction, 30% performance boost from document ordering

---

## Problem Statement

In v0.2, each agent reads specifications independently:
- 10 agents × 3 spec files = 28+ redundant file reads
- Each agent runs 60% of Bash commands for file discovery (ls, find, tree)
- **Result:** Massive token waste and slower execution

## Solution

**Commands load context ONCE, inject into ALL agent prompts.**

---

## Implementation Pattern

### Step 0: Load Context (Once Per Command)

Commands should load context at the START, before invoking any agents:

```markdown
## Step 0: Load Project Context

Before invoking any agents, gather all shared context:

### 1. Read Core Specifications

Read the following files if they exist (skip if not found):

- `.claude/specs/requirements.md`
- `.claude/specs/architecture.md`
- `.claude/specs/tech-stack.md`
- `.claude/specs/phase-*.md` (any phase-specific specs)

### 2. Generate Project File Tree

Generate a project structure overview:

```bash
tree -L 3 -I 'node_modules|.git|dist|build|coverage|.next|__pycache__|*.pyc' > /tmp/project-tree.txt
```

If `tree` is not available, use:

```bash
find . -type d \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o -print | head -100
```

### 3. Read Current Task State

Read `.claude/plans/current-task.md` if resuming a workflow.
```

### Step 1-N: Invoke Agents with Context

When invoking agents using the Task tool, inject context at the TOP of prompts using this XML structure:

```markdown
<documents>
  <document index="1">
    <source>.claude/specs/requirements.md</source>
    <document_content>
{{REQUIREMENTS_CONTENT}}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/specs/architecture.md</source>
    <document_content>
{{ARCHITECTURE_CONTENT}}
    </document_content>
  </document>

  <document index="3">
    <source>.claude/specs/tech-stack.md</source>
    <document_content>
{{TECH_STACK_CONTENT}}
    </document_content>
  </document>

  <document index="4">
    <source>Project File Tree</source>
    <document_content>
{{PROJECT_TREE}}
    </document_content>
  </document>
</documents>

You are the {AGENT_NAME} agent.

**IMPORTANT: Context already loaded above - DO NOT re-read these files.**

The project file tree shows you the complete structure - DO NOT run ls/find/tree commands.

Your task: {SPECIFIC_TASK_DESCRIPTION}

{ADDITIONAL_AGENT_SPECIFIC_INSTRUCTIONS}
```

---

## Research-Backed Design Decisions

### 1. XML Structure (Not Plain Text)

**Source:** [Long Context Tips - Anthropic Docs](https://docs.anthropic.com/claude/docs/long-context-tips)

Using structured XML with `<document>` tags and metadata helps Claude:
- Identify document boundaries
- Reference specific documents
- Maintain context across long prompts

### 2. Place Documents at TOP

**Source:** [Long Context Tips - Document Placement](https://docs.anthropic.com/claude/docs/long-context-tips)

> "Place long documents (20K+ tokens) **near the top** of prompts... This significantly improves performance across all models."

**Impact:** 30% performance boost measured in official research

### 3. Explicit "DO NOT Re-Read" Instructions

Agents have ingrained habits from training. Explicit instructions prevent:
- Re-reading specs despite having them in context
- Running unnecessary Bash commands for file discovery
- Token waste from redundant operations

---

## Example: Implement Command Pattern

```markdown
# Implement: $ARGUMENTS

## Step 0: Load Project Context

Before invoking any agents, gather shared context:

1. Read specifications:
   - `.claude/specs/requirements.md`
   - `.claude/specs/architecture.md`
   - `.claude/specs/tech-stack.md`

2. Generate project file tree:
   ```bash
   tree -L 3 -I 'node_modules|.git|dist' > /tmp/project-tree.txt
   ```

3. Read current task state:
   - `.claude/plans/current-task.md`

## Step 1: Invoke Engineer Agent

Use Task tool with context injection:

```
<documents>
  <document index="1">
    <source>.claude/specs/architecture.md</source>
    <document_content>
    {ARCHITECTURE_CONTENT}
    </document_content>
  </document>

  <document index="2">
    <source>.claude/specs/tech-stack.md</source>
    <document_content>
    {TECH_STACK_CONTENT}
    </document_content>
  </document>

  <document index="3">
    <source>Project File Tree</source>
    <document_content>
    {PROJECT_TREE}
    </document_content>
  </document>
</documents>

You are the Engineer agent.

**Context already loaded above - DO NOT re-read these files.**
**File tree shows project structure - DO NOT run ls/find commands.**

Your task: Implement {FEATURE_NAME}

Follow the architecture patterns and tech stack specified above.
```
```

---

## Migration Guide: Updating Existing Commands

### Old Pattern (v0.2)

```markdown
## Step 1: Invoke Architect

Use the **architect agent** to design the system.

The agent will read specifications from `.claude/specs/`.
```

**Problem:** Agent reads specs independently, every time

### New Pattern (v0.3)

```markdown
## Step 0: Load Project Context

Read specifications:
- `.claude/specs/requirements.md`
- `.claude/specs/architecture.md`
- `.claude/specs/tech-stack.md`

Generate file tree:
```bash
tree -L 3 -I 'node_modules|.git' > /tmp/project-tree.txt
```

## Step 1: Invoke Architect

Use Task tool with context injection:

```
<documents>
  <document index="1">
    <source>.claude/specs/requirements.md</source>
    <document_content>
    {REQUIREMENTS_CONTENT}
    </document_content>
  </document>
  ...
</documents>

You are the Architect agent.

**Context already loaded above - DO NOT re-read these files.**

Your task: Design architecture for {FEATURE}
```
```

---

## Benefits

### Token Efficiency
- **Before:** 28+ spec reads across 10 agents
- **After:** 1-3 spec reads per command
- **Savings:** 20-30% token reduction

### Bash Command Reduction
- **Before:** 122 Bash commands (60% for file discovery)
- **After:** ~50 Bash commands (file tree generated once)
- **Savings:** 10-15% token reduction

### Performance
- **Document ordering:** 30% performance boost (research-backed)
- **Combined impact:** 40-50% efficiency gain

### Developer Experience
- Faster command execution
- More predictable behavior
- Easier to debug (context visible in prompt)

---

## Anti-Patterns to Avoid

❌ **Don't:** Tell agents to "read specs from .claude/specs/"
✅ **Do:** Inject specs directly into agent prompts

❌ **Don't:** Let agents run `tree` or `ls` commands
✅ **Do:** Generate file tree once, inject into all agents

❌ **Don't:** Place documents at bottom of prompt
✅ **Do:** Place documents at TOP per research findings

❌ **Don't:** Use plain text for multiple documents
✅ **Do:** Use XML structure with `<document>` tags

---

## Testing Checklist

When updating a command to use context injection:

- [ ] Step 0 reads specs before agent invocation
- [ ] Step 0 generates project file tree
- [ ] Agent prompts use XML `<documents>` structure
- [ ] Documents placed at TOP of prompts
- [ ] Clear "DO NOT re-read" instructions
- [ ] Agent prompts reference context, not files
- [ ] File tree eliminates need for ls/find/tree
- [ ] Command tested end-to-end

---

## Version History

- **v0.3 (2025-12-06):** Initial pattern based on research findings
- Research sources: Anthropic Long Context Tips, Claude Agent SDK Subagents documentation
