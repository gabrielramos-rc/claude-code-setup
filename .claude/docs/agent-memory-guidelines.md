# Agent Memory Guidelines

**Version:** v0.3
**Purpose:** Prevent ad-hoc memory file proliferation, maintain clean organization
**Created:** 2025-12-06

---

## Rule: Use Existing Artifacts, Don't Create New Files

Agents should NOT create separate memory/summary files outside designated locations.

**Instead:**
- Use `.claude/specs/*` for persistent context (architecture, requirements)
- Use `.claude/plans/current-task.md` for session state
- Use `.claude/state/*` for agent-to-agent communication
- Update existing artifacts, don't create new summaries

---

## File Organization

| Directory | Purpose | Owned By |
|-----------|---------|----------|
| `.claude/specs/` | Specifications, persistent architectural decisions | Architect, PM |
| `.claude/plans/` | Planning, backlog, current task tracking | PM, Commands |
| `.claude/state/` | Session state, agent-to-agent communication | All agents |
| `.claude/commands/` | Workflow orchestration | Framework |
| `.claude/agents/` | Agent definitions | Framework |
| `.claude/docs/` | Framework documentation | Framework |
| `.claude/patterns/` | Reusable patterns (context-injection, reflexion) | Framework |
| `.claude/tests/` | Framework test scenarios | Framework |

---

## Artifact Ownership

| File | Owner | Purpose |
|------|-------|---------|
| `specs/requirements.md` | Product Manager | User requirements, user stories, acceptance criteria |
| `specs/architecture.md` | Architect | System design, component interactions, patterns |
| `specs/tech-stack.md` | Architect | Technology choices, versions, rationale |
| `specs/api-contracts.md` | Architect | Interface definitions, API specifications |
| `specs/phase-X-*.md` | Architect | Phase-specific architectural designs |
| `plans/current-task.md` | Commands (auto) | Session progress tracking, resume capability |
| `plans/backlog.md` | Product Manager | Feature backlog, open questions, rejected ideas |
| `state/implementation-notes.md` | Engineer | What was implemented, technical decisions |
| `state/test-results.md` | Tester | Test outcomes, coverage, failures |
| `state/security-findings.md` | Security Auditor | Security audit results, vulnerability reports |
| `state/code-review-findings.md` | Code Reviewer | Quality findings, recommendations |
| `state/diagnosis.md` | Engineer | Bug investigation, root cause analysis |
| `state/fix-notes.md` | Engineer | Bug fix documentation |
| `state/retry-counter.md` | Commands (auto) | Bounded reflexion retry tracking |
| `state/workflow-metrics.json` | Commands (auto) | Automated metrics logging |

---

## Examples

### ❌ DON'T: Create Ad-Hoc Memory Files

```
# Bad - Architect creates unauthorized files
PROJECT_INITIALIZATION_SUMMARY.md         # Root directory clutter
.claude/agent-memory-2025-12-06.md       # Ad-hoc memory file
.claude/architect-notes.md                # Redundant with specs
.claude/context-summary.md                # Should use specs
```

**Problems:**
- File sprawl and disorganization
- Redundant information
- Unclear where truth lives
- No standardized format

### ✅ DO: Update Existing Artifacts

```
# Good - Architect updates standard locations
.claude/specs/architecture.md             # Design decisions
.claude/specs/tech-stack.md               # Technology choices
.claude/specs/phase-2-architecture.md     # Phase-specific design
```

**Benefits:**
- Clean organization
- Single source of truth
- Standardized format
- Easy to find information

---

## Agent-Specific Guidelines

### Architect
**Use:**
- `specs/architecture.md` for design decisions
- `specs/tech-stack.md` for technology choices
- `specs/api-contracts.md` for interface definitions

**Don't create:**
- Custom summary files
- Architecture notes outside specs/

### Engineer
**Use:**
- `state/implementation-notes.md` for what you built
- `state/diagnosis.md` for bug investigation
- `state/fix-notes.md` for bug fixes

**Don't create:**
- Custom progress files
- Implementation summaries outside state/

### Tester
**Use:**
- `state/test-results.md` for all test outcomes

**Don't create:**
- Separate coverage reports (include in test-results.md)
- Custom test summaries

### Security Auditor
**Use:**
- `state/security-findings.md` for all audit results

**Don't create:**
- Separate vulnerability reports
- Custom security summaries

### Code Reviewer
**Use:**
- `state/code-review-findings.md` for all review feedback

**Don't create:**
- Separate quality reports
- Custom review notes

### Product Manager
**Use:**
- `specs/requirements.md` for user requirements
- `plans/backlog.md` for feature tracking, open questions

**Don't create:**
- Custom backlog files
- Separate question tracking

### Documenter
**Use:**
- `docs/*` for end-user documentation
- Update README.md for project overview

**Don't create:**
- Documentation outside docs/
- Custom doc summaries

---

## State File Format Standards

### implementation-notes.md
```markdown
# Implementation: {Feature Name}

**Date:** {date}
**Phase:** {phase}

## What Was Implemented
### Files Created
### Files Modified

## Technical Decisions
## Test Focus Areas
## Known Limitations
## Next Steps
```

### test-results.md
```markdown
# Test Results: {Feature Name}

**Test Date:** {date}
**Phase:** {phase}

## Summary
- Total Tests, Passing, Failing, Coverage

## Coverage Details (table)
## Test Suites
## Coverage Gaps
## Recommendation
```

### security-findings.md
```markdown
# Security Audit: {Feature Name}

**Audit Date:** {date}
**Phase:** {phase}

## Summary (severity counts)
## CRITICAL Findings
## HIGH Findings
## MEDIUM Findings
## LOW Findings
## Bash Commands Run
## Recommendations
## Next Steps
```

### code-review-findings.md
```markdown
# Code Review: {Feature Name}

**Review Date:** {date}
**Phase:** {phase}

## Summary
## Positive Findings ✅
## Issues Found (categorized by severity)
## Architecture Compliance
## Performance
## Verdict
```

---

## Migration from Ad-Hoc Files

If you discover ad-hoc memory files:

1. **Identify content**
2. **Move to appropriate artifact:**
   - Design decisions → `specs/architecture.md`
   - Requirements → `specs/requirements.md`
   - Implementation notes → `state/implementation-notes.md`
   - Questions → `plans/backlog.md`
3. **Delete ad-hoc file**
4. **Commit cleanup:**
   ```bash
   git rm {ad-hoc-file}
   git commit -m "chore: migrate {ad-hoc-file} to standard artifacts"
   ```

---

## Benefits of This System

### Clean Organization
- Predictable file locations
- Easy navigation
- Clear ownership

### Single Source of Truth
- No duplicate information
- Clear which file is authoritative
- Consistent formats

### Scalability
- Works for small and large projects
- Handles multiple phases
- Supports team collaboration

### Maintainability
- Easy onboarding (clear structure)
- Simple to understand where information lives
- Reduces cognitive load

---

## Enforcement

This is enforced through:
1. **Agent prompts** - Clear file boundary rules
2. **Command patterns** - Explicit state file usage
3. **Code review** - Check for unauthorized files
4. **Documentation** - This guide as reference

**Not enforced through:**
- File system restrictions (agents have access to all files)
- Technical barriers (we rely on clear instructions)

---

## Questions?

**Q: What if I need to store information not covered by existing artifacts?**
**A:** First, check if it fits in existing locations:
- Design → `specs/architecture.md`
- Requirements → `specs/requirements.md`
- Session state → `state/{agent}-notes.md`
- Backlog → `plans/backlog.md`

If truly needed, propose new standard artifact to framework maintainers.

**Q: Can I create temporary files during processing?**
**A:** Yes, in `/tmp/` directory. Clean up after or let system clean up. Don't commit temporary files.

**Q: What about project-specific files outside `.claude/`?**
**A:** This guide covers `.claude/` organization only. Project files (`src/`, `docs/`, `tests/`) follow their own organization.

---

**Document Version:** 1.0
**Status:** ACTIVE
**Owner:** Framework Development Team
