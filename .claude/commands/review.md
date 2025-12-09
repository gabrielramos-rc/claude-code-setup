---
description: Review code for quality, architecture compliance, and maintainability
allowed-tools: Task, Read, Grep, Glob
argument-hint: <files-or-feature-to-review>
---

# Code Review: $ARGUMENTS

## Instructions

Review the code for: **$ARGUMENTS**

If no argument provided, review recent changes (git diff).

### Review Process

Use the **code-reviewer agent** to examine:

1. **Code Quality**
   - Readability and clarity
   - Naming conventions
   - Code organization
   - DRY principles

2. **Functionality**
   - Does it meet requirements?
   - Edge cases handled?
   - Error handling present?

3. **Security**
   - Input validation
   - No hardcoded secrets
   - Safe data handling

4. **Performance**
   - Obvious inefficiencies
   - Resource usage

5. **Testing**
   - Test coverage
   - Test quality

### Output Format

Organize findings as:
- 🔴 **Critical** - Must fix
- 🟡 **Warning** - Should fix
- 🟢 **Suggestion** - Consider
- ✅ **Good** - Well done

Include specific line references and fix suggestions.

### Review Decision

The **code-reviewer agent** must end the review with one of these binary outcomes:

**Option A: Approval**

```
[STATUS: APPROVED]

All checks passed. Code is ready to merge.
```

**Option B: Rejection**

```
[STATUS: REJECTED]

**Critical Issues:**
- [File path]: [Specific issue description]
- [File path]: [Specific issue description]

**Recommended Action:** User, please run `/project:fix [specific issue description]`
```

*Note: Do not automatically invoke commands. Wait for user confirmation.*

### Human-in-the-Loop Protocol

When code is rejected:
1. The reviewer outputs [STATUS: REJECTED] with specific issues
2. The reviewer suggests the appropriate fix command
3. **WAIT for user to decide** whether to run the suggested command
4. Do NOT automatically execute `/project:fix` or any other command
5. User maintains control over next steps
