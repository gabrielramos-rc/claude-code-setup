# Route Task: $ARGUMENTS

## Instructions

Analyze the request: **$ARGUMENTS**

### Complexity Analysis (Objective Criteria)

**Level 1: Cosmetic/One-off**
- File count: 1-2 files
- No new dependencies
- No tests required
- Examples: typo, color change, single function fix, log statement
- **Recommendation:** Run `/project:implement` directly.

**Level 2: Feature/Component**
- File count: 3-10 files
- May add dependencies
- Tests required
- Examples: new endpoint, new page, logic change, refactor component
- **Recommendation:** Run `/project:plan` first.

**Level 3: System/Architecture**
- File count: 10+ files OR new architecture
- New dependencies/frameworks
- Integration tests required
- Examples: new stack, refactor system, init project, auth system
- **Recommendation:** Run `/project:start` or `/project:spec`.

### Ambiguous Cases

If task description is unclear, default to higher complexity level (safer to over-plan than under-plan).

### Output Format

**Complexity Level:** [1/2/3]
**Reasoning:** [File count estimate, dependency changes, testing needs]
**Recommended Command:** `/project:[command]`
**Confidence:** [High/Medium/Low]
