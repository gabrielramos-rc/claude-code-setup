# Git Workflow Pattern

**Version:** v0.3
**Purpose:** Standardized git practices for all agents
**Created:** 2025-12-07

---

## Core Principle: Distributed Commits

Each agent commits their own work. No centralized committer.

**Why:**
- Clear ownership and accountability
- Atomic commits by concern
- Easier rollback of specific changes
- Better git history

---

## Commit Message Conventions

### Format

```
{type}: {description}

{optional body}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: {model} <noreply@anthropic.com>
```

### Types by Agent

| Agent | Prefix | Example |
|-------|--------|---------|
| Architect | `arch:` | `arch: define authentication system boundaries` |
| Engineer | `feat:`, `fix:`, `refactor:` | `feat: implement JWT authentication` |
| Tester | `test:` | `test: add auth middleware unit tests` |
| Security Auditor | `security:` | `security: fix SQL injection vulnerability` |
| Documenter | `docs:` | `docs: add API authentication guide` |
| DevOps | `devops:`, `ci:` | `devops: add GitHub Actions workflow` |
| Code Reviewer | `review:` | `review: address code review findings` |

### Good Commit Messages

```bash
# Clear, specific, explains WHY
feat: add rate limiting to API endpoints

Prevents abuse and ensures fair usage across clients.
Implements token bucket algorithm with 100 req/min limit.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4 <noreply@anthropic.com>
```

### Bad Commit Messages

```bash
# Too vague
fix: bug fix

# No context
update code

# Bundled unrelated changes
feat: add auth, fix tests, update docs
```

---

## Branching Strategy

### Recommended: Trunk-Based Development

For most projects using this framework:

```
main (production)
  └── feature/feature-name (short-lived)
  └── fix/bug-description (short-lived)
```

**Rules:**
- `main` is always deployable
- Feature branches are short-lived (< 1 week)
- Merge via PR with review
- Delete branch after merge

### Alternative: GitFlow

For projects with formal release cycles:

```
main (production)
  └── develop (integration)
       └── feature/* (features)
       └── release/* (release prep)
  └── hotfix/* (urgent fixes)
```

---

## When to Commit

### Do Commit

- After completing a logical unit of work
- After tests pass for new code
- After fixing a bug (with test)
- After documentation updates

### Don't Commit

- Mid-implementation (incomplete features)
- With failing tests
- With secrets or credentials
- With debug code (console.log, print statements)

---

## Agent-Specific Guidelines

### Architect
```bash
git add .claude/specs/
git commit -m "arch: {description}"
```

### Engineer
```bash
git add src/
git commit -m "feat: {description}"
# or
git commit -m "fix: {description}"
```

### Tester
```bash
git add tests/
git commit -m "test: {description}"
```

### DevOps
```bash
git add .github/ Dockerfile docker-compose.yml
git commit -m "devops: {description}"
```

### Documenter
```bash
git add docs/ README.md
git commit -m "docs: {description}"
```

---

## PR Requirements

### Before Creating PR

1. All tests pass locally
2. Code follows project conventions
3. Documentation updated if needed
4. No debug code or secrets
5. Commit history is clean

### PR Description Template

```markdown
## Summary
{1-3 bullet points describing changes}

## Test Plan
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Safety Rules

### Never

- Force push to main/master
- Commit secrets (API keys, passwords, tokens)
- Skip pre-commit hooks without explicit user request
- Amend commits that are already pushed
- Rebase shared branches

### Always

- Pull before pushing
- Create backup branch before destructive operations
- Use `--no-verify` only when explicitly requested
- Check `git status` before committing

---

## Integration with Framework

Commands reference this pattern for git operations:

```markdown
Follow the git workflow pattern in `.claude/patterns/git-workflow.md`.
```

Agents should read this pattern when:
- Making their first commit in a workflow
- Unsure about commit conventions
- Setting up branching strategy

---

## Troubleshooting

### Merge Conflicts

1. Pull latest changes: `git pull origin main`
2. Resolve conflicts in affected files
3. Stage resolved files: `git add {files}`
4. Continue: `git commit` (for merge) or `git rebase --continue`

### Accidental Commit of Secrets

1. **Immediately:** Remove from working directory
2. Use `git filter-branch` or BFG Repo Cleaner
3. Force push (with team coordination)
4. Rotate compromised credentials
5. Add to `.gitignore`

### Wrong Branch

```bash
# If not committed yet
git stash
git checkout correct-branch
git stash pop

# If already committed
git checkout correct-branch
git cherry-pick {commit-hash}
git checkout wrong-branch
git reset --hard HEAD~1
```
