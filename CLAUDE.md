# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **Claude Code framework repository** - a meta-development system for creating structured AI agent workflows. You are working on the framework itself, not using it for a client project. Your goal is to enhance, extend, and improve this framework to help it deliver high-value production-ready software in other projects.

## Framework Architecture

### Core Concept: Multi-Agent Workflow Orchestration

This framework implements a pattern where:
1. **Slash commands** (`.claude/commands/*.md`) define high-level workflows
2. **Specialized agents** (`.claude/agents/*.md`) handle specific development roles
3. **State directories** (`.claude/plans/`, `.claude/specs/`, `.claude/state/`) persist decisions and context
4. Commands orchestrate multiple agents in sequence to accomplish complex tasks

### Beta v0.2 Enhancements (Safety-First Agentic Patterns)

**New in v0.2:**
- **Task Routing** - Analyze complexity before choosing workflow (cosmetic/feature/system)
- **Bounded Reflexion** - Commands auto-retry up to 3 times, max 5 total across workflow
- **Human-in-the-Loop Gatekeeping** - Code review requires manual approval for fixes
- **Artifact Priority System** - Agents read `.claude/specs/` to maintain architectural decisions
- **Global Retry Coordination** - Prevents infinite loops with cumulative retry tracking
- **Comprehensive Testing** - 13 behavioral test scenarios validate framework behavior

### v0.3 Phase 1: Command-Level Context Injection (Token Optimization)

**Status:** ✅ Implemented (2025-12-06)

**New in v0.3 Phase 1:**
- **Context Injection Pattern** - Commands load specs ONCE, inject into all agent prompts (`.claude/patterns/context-injection.md`)
- **XML-Structured Documents** - Research-backed format with documents at TOP of prompts (30% performance boost)
- **File Tree Generation** - Generate project structure once per command, eliminate ls/find/tree redundancy
- **Updated Command Workflows** - implement.md, fix.md, test.md now use Step 0 for context loading
- **Parallel Quality Validation** - Tester + Security + Code Reviewer run concurrently
- **Agent Protocol v0.3** - Simplified CONTEXT PROTOCOL with clear "DO NOT re-read" instructions

**Expected Impact:**
- 20-30% token reduction from eliminating 28+ redundant spec reads
- 10-15% token reduction from eliminating 60+ redundant Bash file discovery commands
- 30% performance improvement from document ordering (Anthropic research)
- **Combined: 40-50% efficiency gain**

**Pattern Reference:** See `.claude/patterns/context-injection.md` for complete implementation guide

**Phase 1 Week 2: Role Enforcement** - ✅ Implemented (2025-12-06)

All 8 agents updated with comprehensive role enforcement guidelines to prevent boundary violations:

**File Boundary Enforcement:**
- **Architect** - ONLY `.claude/specs/*`, NEVER `src/*` or `tests/*`
- **Engineer** - ONLY `src/*` and `tests/*`, NEVER `.claude/specs/*`
- **Tester** - ONLY `tests/*` and `.claude/state/test-results.md`
- **Security Auditor** - Bash for scans, `.claude/state/security-findings.md` for reports
- **Code Reviewer** - Read-only analysis (Read/Grep/Glob ONLY, NO Bash)
- **Documenter** - ONLY `docs/*` and `README.md`, NEVER `src/*` or `.claude/specs/*`
- **DevOps** - CI/CD configs, deployment files, **coordinates git but NEVER centralizes commits**
- **Product Manager** - ONLY `.claude/specs/requirements.md` and `.claude/plans/backlog.md`

**Distributed Git Workflow:**
- Each agent commits their own work (no centralization to DevOps)
- Clear commit message conventions: `feat:`, `fix:`, `test:`, `docs:`, `arch:`, `devops:`, `security:`, `review:`
- DevOps coordinates strategy in `.claude/state/git-strategy.md` but doesn't make commits for other agents

**Agent Protocol Pattern:**
All agents now follow standardized structure:
1. **What You Write** - Clear file boundaries with ✅ DO write locations
2. **What You DON'T Write** - Explicit ❌ NEVER write locations
3. **Tool Usage Guidelines** - Intent-based usage (not restrictions)
4. **Process/Workflow** - Step-by-step agent process
5. **State Communication** - How agents coordinate via `.claude/state/*`
6. **Git Commits** - Distributed approach with agent-specific prefixes
7. **When to Invoke Other Agents** - Escalation paths
8. **Examples (Good vs Bad)** - Concrete examples of proper boundaries

**Supporting Documentation:**
- `.claude/docs/agent-memory-guidelines.md` - Prevent ad-hoc memory file proliferation
- Artifact ownership table (16 standard artifacts)
- File organization table (7 directories with clear purposes)

**Problems Solved:**
- CON-11: Architect creating code → Engineer deleting → recreating (boundary violations)
- CON-04/CON-08: Ad-hoc memory file proliferation (PROJECT_INITIALIZATION_SUMMARY.md, etc.)
- Unclear agent responsibilities and file ownership
- Distributed git workflow prevents centralization confusion

**Expected Impact:**
- Prevent boundary violations between agents
- Clear agent responsibilities and file ownership
- Smooth agent-to-agent coordination via state files
- No duplicate work or conflicting changes

---

### v0.3 Phase 2: Quality Agent Orchestration with Parallelization

**Status:** ✅ Implemented (2025-12-06)

**New in v0.3 Phase 2:**
- **Parallel Quality Validation** - Run Tester + Security + Code Reviewer concurrently (`.claude/patterns/parallel-quality-validation.md`)
- **Task Tool Parallelization** - Invoke multiple agents in single message for concurrent execution
- **50% Time Reduction** - 10 minutes sequential → 5 minutes parallel validation
- **100% Quality Coverage** - Independent validation on every implementation (not engineers testing own code)
- **Updated Command Workflows** - implement.md and fix.md now use parallel quality validation

**Time Comparison:**
```
Sequential (OLD): Tester (5 min) → Security (3 min) → Reviewer (2 min) = 10 minutes
Parallel (NEW):    [Tester, Security, Reviewer] concurrently = 5 minutes
Time savings: 50%
```

**Quality Coverage:**
- Before: 0% dedicated testing/security/review (engineers test own code)
- After: 100% independent validation with specialized agents
- **Tester Agent** - Designs tests, implements in tests/, executes, reports results
- **Security Auditor Agent** - Runs scans (npm audit, eslint security), manual review, reports findings
- **Code Reviewer Agent** - Reviews quality, patterns, architecture compliance

**Command Integration:**
- **implement.md** - Step 2.5: Parallel validation (Tester + Security + Code Reviewer)
- **fix.md** - Step 2: Parallel validation (Tester + Code Reviewer)
- **test.md** - No changes (already testing-focused workflow)

**Decision Logic:**
After parallel validation completes:
- If ANY critical issues → Bounded reflexion (invoke Engineer with findings, max 3 retries)
- If all pass → Proceed to documentation/deployment

**Problems Solved:**
- CON-19: 0 Testing agents in workflow → 100% test coverage on every implementation
- CON-20: 0 Security auditor for critical phases → Security validation automatic
- CON-24: 0 Documentation agents → Documenter invoked in workflows
- CON-18: 8 Engineer agents, minimal validation → Independent quality gates

**Expected Impact:**
- 100% quality coverage for all implementations
- 50% time reduction through parallelization
- Independent validation (specialized agents, not self-review)
- Bounded reflexion prevents infinite loops while enabling auto-fixes

**Research Backing:**
> "Running style-checker, security-scanner, and test-coverage subagents simultaneously reduces multi-minute reviews to seconds." - Anthropic Subagents Documentation

**Combined v0.3 Impact:**
- Phase 1: 40-50% token reduction (context injection)
- Phase 2: 50% time reduction (parallelization)
- **Total efficiency improvement: 70%+**

**Pattern Reference:** See `.claude/patterns/parallel-quality-validation.md` for complete implementation guide

---

### Agent System Design

Agents are defined with YAML frontmatter containing:
- `name` - Agent identifier
- `description` - Role and when to use (includes PROACTIVE usage triggers)
- `model` - Preferred model (opus for complex reasoning, sonnet for implementation)
- `tools` - Tool access (Bash, Read, Write, Edit)

**Key Insight**: The `description` field contains "Use PROACTIVELY" directives that tell Claude when to invoke this agent automatically. This enables Claude to self-orchestrate workflows.

### Current Agent Ecosystem

**Strategic Agents (opus)**:
- `product-manager` - Requirements gathering, user stories, acceptance criteria
- `architect` - System design, technology selection, architectural decisions

**Implementation Agents (sonnet)**:
- `engineer` - Code implementation following established patterns
- `tester` - Test creation and execution
- `code-reviewer` - Code quality, security, performance review

**Supporting Agents**:
- `security-auditor` - Vulnerability scanning and security verification
- `documenter` - Documentation generation and maintenance
- `devops` - Deployment preparation and CI/CD

### Command Pattern Structure

Commands use `$ARGUMENTS` variable and follow this structure:
1. **Context setting** - What task is being performed
2. **Multi-step process** - Which agents to use and in what order
3. **Output specification** - What to deliver and where to save it

Commands implement **staged workflows**: plan → design → implement → verify → document

**Beta v0.2 Additions:**
- **Reflexion loops** - Commands auto-retry failed operations (max 3 attempts)
- **Global retry counter** - `.claude/state/retry-counter.md` tracks cumulative retries
- **Failure escalation** - Clear diagnostic messages when automation fails
- **Routing command** - `/project:route` recommends appropriate workflow based on complexity

## Framework Extension Guidelines

### When Enhancing This Framework

**DO:**
- Add new agents for emerging development needs (e.g., API designer, database optimizer, performance analyst)
- Create new command workflows that combine agents in novel ways
- Improve agent prompts to produce more actionable, specific outputs
- Add state management patterns (new directories under `.claude/`)
- Enhance coordination between agents (passing context, building on previous agent output)
- Design for real-world production usage - prioritize quality, security, and maintainability

**DON'T:**
- Follow the existing structure rigidly - you're building/improving it, not using it
- Add agents that duplicate existing functionality without clear differentiation
- Create overly complex workflows that obscure simple tasks
- Add generic advice that doesn't leverage agent specialization

### Design Principles for Production-Ready Software

When enhancing this framework, optimize for:

1. **Clear separation of concerns** - Each agent has distinct, non-overlapping responsibilities
2. **Proactive agent invocation** - Agents should trigger automatically based on context
3. **Context persistence** - Important decisions saved to `.claude/plans/` and `.claude/specs/`
4. **Incremental verification** - Each step validated before proceeding
5. **Production quality gates** - Security, testing, and review as mandatory steps
6. **Minimal coordination overhead** - Commands should orchestrate smoothly without user intervention
7. **Safety bounds** (v0.2+) - Prevent infinite loops with retry limits and user gates
8. **Artifact priority** (v0.2+) - Persistent context trumps conversation when conflicts arise

## Common Development Tasks

### Adding a New Agent

1. Create `.claude/agents/[name].md` with YAML frontmatter
2. Define clear `description` with "Use PROACTIVELY" triggers
3. Specify `model` choice (opus for reasoning, sonnet for execution)
4. List required `tools` access
5. Write detailed prompt explaining responsibilities and output format
6. Update relevant commands to orchestrate the new agent

### Adding a New Command

1. Create `.claude/commands/[name].md`
2. Use `$ARGUMENTS` for parameterization
3. Define agent orchestration sequence
4. Specify where outputs should be saved (`.claude/plans/`, `.claude/specs/`, etc.)
5. Include verification steps

### Improving Agent Prompts

Focus on:
- **Specificity** - Exact output format, not general guidance
- **Actionability** - What to produce, not just what to think about
- **Quality criteria** - What "good" looks like for this agent's output
- **Integration points** - How this agent's output feeds other agents

## Framework Evolution Strategy

This framework should evolve toward:
1. **Self-orchestrating workflows** - Claude determines which agents to invoke based on context
2. **Adaptive complexity** - Simple tasks stay simple, complex tasks get appropriate structure
3. **Production-ready defaults** - Security, testing, and quality built into every workflow
4. **Cross-project learning** - Patterns that work across different tech stacks and domains
5. **Minimal user intervention** - Smart defaults with targeted questions only when necessary

## Key Files

### Core Framework
- `CLAUDE.md` - This file (framework documentation for meta-development)
- `TEMPLATE-CLAUDE.md` - Template for projects using this framework (to be customized per project)
- `.claude/commands/start.md` - Project initialization workflow (creates project-specific CLAUDE.md)
- `.claude/agents/*.md` - Agent definitions (the core reusable components)

### State & Persistence
- `.claude/plans/` - Persistent planning outputs
- `.claude/specs/` - Detailed specifications (requirements, architecture, tech-stack)
- `.claude/state/` - Runtime state (retry counter, workflow tracking)

### Beta v0.2 Additions
- `.claude/commands/route.md` - Task complexity analyzer and workflow router
- `.claude/patterns/reflexion.md` - Shared retry pattern documentation
- `.claude/docs/artifact-system.md` - Complete artifact priority protocol
- `.claude/docs/beta-v0.2-metrics.md` - Success metrics and acceptance criteria
- `.claude/tests/beta-v0.2-scenarios.md` - 13 behavioral test scenarios

### v0.3 Phase 1 Additions
- `.claude/patterns/context-injection.md` - Command-level context injection pattern (1040 lines)
- `.claude/docs/agent-memory-guidelines.md` - Prevent ad-hoc memory file proliferation (306 lines)
- Updated commands: `implement.md`, `fix.md`, `test.md` with Step 0 context loading
- Updated all 8 agents with role enforcement guidelines (2500+ total lines)
- Agent protocol v0.3 with file boundaries and distributed git workflow

### v0.3 Phase 2 Additions
- `.claude/patterns/parallel-quality-validation.md` - Parallel agent orchestration pattern (935 lines)
- Updated commands: `implement.md`, `fix.md` with parallel quality validation
- Task tool parallelization for 50% time reduction
- 100% quality coverage with independent validation

## Notes on Framework Usage

When this framework is used in actual projects:
- Projects will have their own CLAUDE.md (generated from TEMPLATE-CLAUDE.md)
- Project CLAUDE.md should document project-specific architecture, commands, and tech stack
- This repository's `.claude/` directory gets copied to new projects as a starting point
- Commands are invoked as `/project:[command]` in client projects
