---
description: Review a GitHub pull request
allowed-tools: Task, Read, Grep, Glob, Bash(git:*), Bash(gh:*)
argument-hint: <pr-number-or-url>
---

# PR Review: $ARGUMENTS

## Instructions

Review a GitHub pull request: **$ARGUMENTS**

---

## Process

### Step 1: Fetch PR Information

```bash
# Get PR details
gh pr view $ARGUMENTS --json title,body,files,additions,deletions,author

# Get the diff
gh pr diff $ARGUMENTS
```

### Step 2: Analyze Changes

Review the PR for:

#### Code Quality
- [ ] Code is readable and maintainable
- [ ] No duplicated code
- [ ] Functions are focused and small
- [ ] Proper error handling
- [ ] No magic numbers/strings

#### Architecture
- [ ] Follows project patterns
- [ ] Layer separation maintained
- [ ] No circular dependencies
- [ ] Appropriate abstractions

#### Security
- [ ] No exposed secrets
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities

#### Testing
- [ ] Tests added for new code
- [ ] Edge cases covered
- [ ] Tests are meaningful

#### Performance
- [ ] No N+1 queries
- [ ] No memory leaks
- [ ] Efficient algorithms

### Step 3: Review Files

For each changed file:
1. Read the full file for context (not just the diff)
2. Check if changes align with project conventions
3. Look for potential issues

### Step 4: Generate Review

Provide structured feedback:

```markdown
## PR Review: #{pr_number} - {title}

### Summary
{Overall assessment: APPROVE / REQUEST_CHANGES / COMMENT}

### Strengths
- {What was done well}

### Issues Found

#### Critical (Must Fix)
- **{file}:{line}** - {issue description}
  ```suggestion
  {suggested fix}
  ```

#### Minor (Should Fix)
- **{file}:{line}** - {issue description}

#### Suggestions (Nice to Have)
- {suggestion}

### Checklist
- [ ] Code quality: {PASS/FAIL}
- [ ] Architecture: {PASS/FAIL}
- [ ] Security: {PASS/FAIL}
- [ ] Tests: {PASS/FAIL}

### Recommendation
{Final recommendation with reasoning}
```

### Step 5: (Optional) Post Review

If requested, post the review:
```bash
gh pr review $ARGUMENTS --comment --body "$(cat review.md)"
# or
gh pr review $ARGUMENTS --approve
# or
gh pr review $ARGUMENTS --request-changes --body "$(cat review.md)"
```

---

## Examples

```
/project:pr-review 123
/project:pr-review https://github.com/org/repo/pull/456
```

---

## Notes

- This command uses the GitHub CLI (`gh`)
- Ensure you're authenticated: `gh auth status`
- For private repos, ensure proper access
