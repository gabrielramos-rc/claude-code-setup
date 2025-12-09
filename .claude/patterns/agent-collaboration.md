# Agent Collaboration Pattern

> How agents hand off work, communicate, and escalate issues

---

## Agent Ecosystem Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PLANNING LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │   Product    │───▶│   UI/UX      │───▶│  Architect   │          │
│  │   Manager    │    │   Designer   │    │  (Frontend   │          │
│  │              │    │              │    │  + Backend)  │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│        │                    │                    │                  │
│        │ requirements       │ design specs       │ architecture    │
│        ▼                    ▼                    ▼                  │
│  specs/requirements.md  specs/ui-ux-*.md    specs/architecture.md  │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      IMPLEMENTATION LAYER                           │
├─────────────────────────────────────────────────────────────────────┤
│        ┌──────────────────────────────────────────┐                 │
│        │              Engineer                     │                 │
│        │  (reads specs, writes src/ and tests/)   │                 │
│        └──────────────────────────────────────────┘                 │
│                          │                                          │
│                          │ implementation                           │
│                          ▼                                          │
│                    src/*, tests/*                                   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       VALIDATION LAYER                              │
│                     (runs in PARALLEL)                              │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │    Tester    │    │   Security   │    │    Code      │          │
│  │              │    │   Auditor    │    │   Reviewer   │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│        │                    │                    │                  │
│        │ test results       │ findings          │ review           │
│        ▼                    ▼                    ▼                  │
│  state/test-results.md  state/security-*.md  state/code-review-*.md│
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        DELIVERY LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│        ┌──────────────┐              ┌──────────────┐              │
│        │  Documenter  │              │    DevOps    │              │
│        │              │              │              │              │
│        └──────────────┘              └──────────────┘              │
│              │                              │                       │
│              │ docs                         │ deployment            │
│              ▼                              ▼                       │
│         docs/*, README.md           .github/workflows/, Dockerfile  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Handoff Matrix

| From | To | Trigger | Artifact Passed |
|------|----|---------|-----------------|
| Product Manager | Architect | Requirements complete | `specs/requirements.md` |
| Product Manager | UI/UX Designer | UX work needed | `specs/requirements.md` |
| UI/UX Designer | Architect | Design specs ready | `specs/ui-ux-specs.md`, `specs/design-system.md` |
| Architect | Engineer | Architecture defined | `specs/architecture.md`, `specs/tech-stack.md` |
| Engineer | Tester | Implementation complete | `state/implementation-notes.md` |
| Engineer | Security Auditor | Security-sensitive code | `state/implementation-notes.md` |
| Engineer | Code Reviewer | Ready for review | `state/implementation-notes.md` |
| Tester | Engineer | Tests fail | `state/test-results.md` |
| Security Auditor | Engineer | Vulnerabilities found | `state/security-findings.md` |
| Code Reviewer | Engineer | Changes requested | `state/code-review-findings.md` |
| Engineer | Documenter | Feature complete | `state/implementation-notes.md` |
| Engineer | DevOps | Ready for deployment | Implementation complete |

---

## Agent Capabilities Matrix

| Agent | Creates | Reads | Never Touches |
|-------|---------|-------|---------------|
| Product Manager | `specs/requirements.md`, `plans/backlog.md` | - | `src/`, `tests/` |
| UI/UX Designer | `specs/ui-ux-*.md`, `specs/design-system.md` | requirements | `src/`, `tests/` |
| Architect | `specs/architecture.md`, `specs/tech-stack.md` | requirements, ui-ux | `src/`, `tests/` |
| Engineer | `src/*`, `tests/*` | all specs | `specs/*` |
| Tester | `tests/*`, `state/test-results.md` | src, specs | `src/*` (only tests) |
| Security Auditor | `state/security-findings.md` | src, tests | `src/*`, `tests/*` |
| Code Reviewer | `state/code-review-findings.md` | src, tests, specs | `src/*`, `tests/*` |
| Documenter | `docs/*`, `README.md` | src, specs | `src/*`, `specs/*` |
| DevOps | `.github/*`, `Dockerfile`, CI configs | all | `src/*` |

---

## Parallel Validation

Tester, Security Auditor, and Code Reviewer run **concurrently** after implementation:

```
                    ┌─────────────┐
                    │  Engineer   │
                    │  completes  │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Tester  │    │ Security │    │ Reviewer │
    │          │    │ Auditor  │    │          │
    └────┬─────┘    └────┬─────┘    └────┬─────┘
         │               │               │
         └───────────────┼───────────────┘
                         ▼
                  Aggregate Results
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
    All Pass?                      Issues Found?
         │                               │
         ▼                               ▼
  Documenter/DevOps              Engineer (fix)
                                 (bounded reflexion)
```

**Time savings:** 50% reduction vs sequential validation

See `.claude/patterns/parallel-quality-validation.md` for implementation details.

---

## Escalation Paths

### Architecture Clarification

When Engineer encounters unclear or missing architectural guidance:

```
Engineer ──(unclear specs)──▶ Architect
         ◀──(updated specs)──
```

**Trigger:** Spec ambiguity, missing technology decision, conflicting requirements

### Architectural Violations

When Code Reviewer detects architecture violations:

```
Code Reviewer ──(violation)──▶ Architect ──(decision)──▶ Engineer
```

**Trigger:** Pattern deviation, unauthorized technology, structural issues

### Security Issues

Based on severity:

```
Security Auditor ──(CRITICAL)──▶ Engineer (immediate fix, blocks deployment)
                 ──(HIGH)──▶ Engineer (priority fix before merge)
                 ──(MEDIUM)──▶ Backlog (fix in next sprint)
                 ──(LOW)──▶ Backlog (fix when convenient)
```

### Test Failures

When tests fail after implementation:

```
Tester ──(failures)──▶ Engineer ──(fix)──▶ Tester (re-run)
```

**Bounded reflexion:** Max 3 fix attempts before escalation

### Requirements Clarification

When requirements are ambiguous:

```
Any Agent ──(unclear requirement)──▶ Product Manager
          ◀──(clarification)──
```

---

## Communication via State Files

Agents communicate asynchronously through state files:

```
┌─────────────┐     writes      ┌──────────────────────────┐
│   Agent A   │ ───────────────▶│ .claude/state/{file}.md  │
└─────────────┘                 └──────────────────────────┘
                                           │
                                           │ reads
                                           ▼
                                ┌─────────────┐
                                │   Agent B   │
                                └─────────────┘
```

**Key state files:**
| File | Writer | Readers |
|------|--------|---------|
| `implementation-notes.md` | Engineer | Tester, Security, Reviewer, Documenter |
| `test-results.md` | Tester | Engineer, DevOps |
| `security-findings.md` | Security Auditor | Engineer |
| `code-review-findings.md` | Code Reviewer | Engineer |
| `current-task.md` | Commands | All agents |

See `.claude/patterns/state-files.md` for schemas.

---

## Workflow Integration

### Standard Feature Workflow

```
1. Product Manager → requirements
2. UI/UX Designer → design specs (if UX-heavy)
3. Architect → architecture decisions
4. Engineer → implementation
5. [Parallel] Tester + Security + Reviewer → validation
6. Engineer → fixes (if needed, max 3 iterations)
7. Documenter → documentation
8. DevOps → deployment prep
```

### Bug Fix Workflow

```
1. Engineer → fix implementation
2. [Parallel] Tester + Reviewer → validation
3. Engineer → fixes (if needed)
```

### Architecture-Only Workflow

```
1. Product Manager → requirements
2. Architect → architecture + specs
3. (No implementation)
```

---

## Anti-Patterns

### ❌ Boundary Violations

```
Architect creates src/components/Button.tsx  ← WRONG
Engineer modifies specs/architecture.md      ← WRONG
Tester fixes src/utils/helper.ts             ← WRONG
```

**Rule:** Each agent owns specific files. Never cross boundaries.

### ❌ Skipping Validation

```
Engineer → Documenter (skipping Tester/Security/Reviewer)  ← WRONG
```

**Rule:** Validation layer is mandatory for all implementations.

### ❌ Circular Escalation

```
Engineer → Architect → Engineer → Architect → ...  ← WRONG
```

**Rule:** Use bounded reflexion (max 3 iterations). Escalate to human if unresolved.

### ❌ Direct Communication

```
Engineer writes notes in code comments for Tester  ← WRONG
```

**Rule:** Use state files for inter-agent communication.

---

## Quick Reference

### "Who do I invoke?"

| If you need... | Invoke... |
|----------------|-----------|
| Requirements clarification | Product Manager |
| UX/design decisions | UI/UX Designer |
| Architecture guidance | Architect |
| Code implementation | Engineer |
| Test design/execution | Tester |
| Security review | Security Auditor |
| Code quality review | Code Reviewer |
| Documentation | Documenter |
| CI/CD, deployment | DevOps |

### "Who invokes me?"

| Agent | Typically invoked by |
|-------|---------------------|
| Product Manager | Commands, human |
| UI/UX Designer | Product Manager, Commands |
| Architect | Product Manager, Commands |
| Engineer | Architect, Tester, Security, Reviewer |
| Tester | Engineer (impl complete), Commands |
| Security Auditor | Engineer (impl complete), Commands |
| Code Reviewer | Engineer (impl complete), Commands |
| Documenter | Engineer (feature complete), Commands |
| DevOps | Engineer (ready to deploy), Commands |

---

*Pattern created: 2025-12-08*
*Version: 1.0*
