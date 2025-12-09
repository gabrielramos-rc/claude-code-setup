# Claude Code Framework Plugin

A comprehensive multi-agent orchestration framework for Claude Code that delivers production-ready software through coordinated AI agent workflows.

## Features

- **9 Specialized Agents** - Architect, Engineer, Tester, Security Auditor, Code Reviewer, Product Manager, UI/UX Designer, Documenter, DevOps
- **18 Slash Commands** - Complete workflow coverage from planning to deployment
- **24 Domain Protocols** - On-demand loading of specialized procedures
- **Automated Hooks** - Code formatting, validation, quality gates
- **Token Optimization** - Context injection pattern for 40-50% token reduction
- **Parallel Validation** - 50% faster quality checks

## Installation

```bash
# Add the marketplace (if not already added)
/plugin marketplace add rcconsultech/claude-plugins

# Install the framework
/plugin install claude-code-framework@rcconsultech
```

## Quick Start

After installation, use these commands:

```bash
# Start a new project
/project:start my-app

# Implement a feature
/project:implement Add user authentication

# Fix an issue
/project:fix Login not working

# Run tests
/project:test

# Review code
/project:review

# Resume interrupted work
/project:resume
```

## Commands

### Core Workflows
| Command | Description |
|---------|-------------|
| `/project:start` | Initialize new project with specs |
| `/project:implement` | Full feature implementation workflow |
| `/project:fix` | Debug and fix with validation |
| `/project:test` | Run tests (unit/integration/e2e) |

### Quick Actions
| Command | Description |
|---------|-------------|
| `/project:quick-fix` | Single-file fixes without full validation |
| `/project:refactor` | Safe refactoring with checks |
| `/project:pr-review` | Review GitHub pull requests |
| `/project:estimate` | Complexity estimation |

### Planning & Analysis
| Command | Description |
|---------|-------------|
| `/project:plan` | Feature planning session |
| `/project:route` | Analyze task complexity |
| `/project:review` | Code quality review |
| `/project:security` | Security audit |

### Operations
| Command | Description |
|---------|-------------|
| `/project:docs` | Generate documentation |
| `/project:deploy-prep` | Deployment preparation |
| `/project:rollback` | Safe git rollback |
| `/project:resume` | Continue interrupted work |
| `/project:benchmark` | Performance profiling |
| `/project:debug` | Deep diagnostics |

## Agents

| Agent | Model | Role |
|-------|-------|------|
| Architect | Opus | System design, technology decisions |
| Engineer | Sonnet | Code implementation |
| Tester | Sonnet | Test design and execution |
| Security Auditor | Sonnet | Vulnerability scanning |
| Code Reviewer | Sonnet | Quality review |
| Product Manager | Sonnet | Requirements gathering |
| UI/UX Designer | Sonnet | User experience design |
| Documenter | Haiku | Documentation |
| DevOps | Sonnet | CI/CD and deployment |

## Protocols

Domain-specific procedures loaded on-demand:

- **Architecture:** api-rest, api-realtime, data-modeling, frontend-architecture
- **Implementation:** database-implementation, data-batch, data-streaming
- **Testing:** testing-unit, testing-integration, testing-e2e
- **Security:** authentication, security-hardening
- **DevOps:** ci-cd, containerization
- **Cross-cutting:** observability, error-handling, caching, accessibility, i18n, api-versioning

## Hooks

Automated workflow enhancements:

- **format.sh** - Auto-format files after edits
- **validate-specs.sh** - Check specs before implementation
- **load-context.sh** - Session setup
- **pre-commit.sh** - Commit message validation
- **enhance-prompt.sh** - Context suggestions
- **log-progress.sh** - Progress tracking
- **quality-gate.sh** - Quality checks

## Configuration

The framework uses `.claude/settings.json` for configuration:

```json
{
  "permissions": {
    "allow": ["Bash(npm:*)", "Bash(git:*)"],
    "deny": ["Read(./.env)"]
  },
  "hooks": {
    "PostToolUse": [...]
  }
}
```

## Version History

- **v0.3.0** - Context injection, parallel validation, session management, hooks
- **v0.2.0** - Bounded reflexion, task routing, artifact priority
- **v0.1.0** - Initial multi-agent framework

## License

MIT

## Support

- Issues: https://github.com/rcconsultech/claude-code-setup/issues
- Documentation: https://github.com/rcconsultech/claude-code-setup
