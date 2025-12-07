# Model Selection Guide

When invoking agents via the Task tool, choose the appropriate model based on task complexity.

## Default Model by Agent

| Agent | Default Model | Rationale |
|-------|---------------|-----------|
| Architect | opus | Complex reasoning, architectural decisions |
| Product Manager | sonnet | Structured output, requirements gathering |
| UI/UX Designer | sonnet | Pattern-based design specifications |
| Engineer | sonnet | Code generation, implementation |
| Tester | sonnet | Test creation and execution |
| Code Reviewer | sonnet | Quality analysis, pattern matching |
| Security Auditor | sonnet | Vulnerability scanning, analysis |
| DevOps | sonnet | CI/CD configuration, deployment |
| Documenter | haiku | Simple formatting, documentation |

## When to Override Defaults

### Use opus when:
- Novel architectural decisions with multiple valid approaches
- Complex trade-off analysis (performance vs maintainability vs cost)
- System design spanning multiple services or domains
- Security architecture requiring threat modeling
- Debugging complex, non-obvious issues

### Use sonnet when:
- Implementing well-defined features
- Following established patterns
- Creating structured output (specs, tests, configs)
- Code review with clear criteria
- Standard security scanning

### Use haiku when:
- Simple formatting tasks
- Documentation updates
- Repetitive, template-based output
- Status updates and summaries
- Straightforward file transformations

## Cost-Benefit Summary

| Model | Relative Cost | Best For |
|-------|---------------|----------|
| opus | $$$ | Complex reasoning, novel problems |
| sonnet | $$ | Implementation, structured tasks |
| haiku | $ | Simple formatting, documentation |

## Example Overrides

```markdown
# Override to opus for complex debugging
Task tool with model: opus for Engineer debugging race condition

# Override to haiku for simple README update
Task tool with model: haiku for Documenter updating version number

# Keep default sonnet for standard implementation
Task tool (no model override) for Engineer implementing CRUD endpoints
```

## Decision Flowchart

```
Is this novel problem-solving or architectural design?
├─ Yes → opus
└─ No → Is this code generation or structured analysis?
         ├─ Yes → sonnet
         └─ No → Is this simple formatting or documentation?
                  ├─ Yes → haiku
                  └─ No → sonnet (safe default)
```
