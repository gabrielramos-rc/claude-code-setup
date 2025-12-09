# Project Context

## Overview
[Brief description of your project - fill this in]

## Technology Stack
[Technologies used - fill this in after planning]

## Key Commands

### Routing (Beta v0.2+)
- `/project:route [task]` - Analyze task complexity and recommend workflow
  - Level 1 (Cosmetic): Simple fixes, direct implementation
  - Level 2 (Feature): Multi-file changes, requires planning
  - Level 3 (System): Architecture changes, full workflow

### Planning
- `/project:start [name]` - Start a new project
- `/project:plan [feature]` - Plan a feature (requirements + technical design)

### Development
- `/project:implement [task]` - Implement a feature/task (auto-retries up to 3x)
- `/project:fix [issue]` - Debug and fix an issue (auto-retries up to 3x)

### Quality
- `/project:review` - Code review (outputs [APPROVED] or [REJECTED])
- `/project:test [target]` - Create/run tests (auto-retries up to 3x)
- `/project:security` - Security audit

### Documentation & Deployment
- `/project:docs` - Generate documentation
- `/project:deploy-prep [env]` - Prepare for deployment

## Available Agents

All agents use **Artifact Priority** (Beta v0.2+): They read project artifacts in `.claude/specs/` before acting, ensuring architectural decisions persist across conversations.

- **product-manager** - Requirements and user stories
- **architect** - System design and tech decisions (updates artifacts)
- **engineer** - Code implementation (reads artifacts for context)
- **code-reviewer** - Code quality review
- **tester** - Test creation and execution
- **security-auditor** - Security vulnerability scanning
- **documenter** - Documentation creation
- **devops** - Deployment and CI/CD

## Project Structure
```
[Fill in your project structure as it develops]
```

## Development Guidelines

### Beta v0.2 Workflow
1. **Route first** - Run `/project:route [task]` to get recommended workflow
2. **Update artifacts** - Keep `.claude/specs/` files current with decisions
3. **Trust auto-retry** - Commands retry up to 3x automatically (max 5 total across workflow)
4. **Review gates** - `/project:review` requires manual approval before fixes

### Best Practices
1. Always plan before implementing complex features (`/project:plan`)
2. Review code after implementation (`/project:review`)
3. Run security checks before deployment (`/project:security`)
4. Keep documentation updated (`/project:docs`)

### Artifact System (Beta v0.2+)
The framework uses persistent artifacts to maintain context:
- `.claude/specs/requirements.md` - What we're building
- `.claude/specs/architecture.md` - How we're building it
- `.claude/specs/tech-stack.md` - Technologies in use
- `.claude/plans/current-task.md` - Active work

**When conflicts arise**, agents prioritize artifacts over conversation to ensure consistency.
