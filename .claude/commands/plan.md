---
description: Plan a feature with requirements, architecture, and design
allowed-tools: Task, Read, Write, Grep, Glob
argument-hint: <feature-description>
---

# Plan Feature: $ARGUMENTS

## Process

You are coordinating a planning session for: **$ARGUMENTS**

Follow the model selection guide in `.claude/patterns/model-selection.md` when invoking agents.

### Step 1: Requirements Gathering
Use the **product-manager agent** to:
- Understand the feature request
- Ask clarifying questions
- Create user stories with acceptance criteria

### Step 2: Technical Design
Use the **architect agent** to:
- Design the solution architecture
- Choose appropriate technologies
- Identify components and their interactions
- Create a data model if needed

### Step 3: Task Breakdown
Break down the implementation into:
- Numbered tasks in logical order
- Estimated complexity (Small/Medium/Large)
- Dependencies between tasks
- Suggested implementation order

### Output
Save the plan to `.claude/plans/[feature-name].md` with:
1. Requirements summary
2. Technical design
3. Task list with estimates
4. Risks and considerations
5. Success criteria
