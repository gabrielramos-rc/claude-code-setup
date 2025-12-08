# Rollback: $ARGUMENTS

## Instructions

Undo recent commits safely using git revert (default) or git reset (with --hard flag).

---

## Usage

```
/project:rollback                 # Revert last commit
/project:rollback 3               # Revert last 3 commits
/project:rollback abc123          # Revert specific commit by hash
/project:rollback --hard          # Reset last commit (destructive)
/project:rollback --hard 3        # Reset last 3 commits (destructive)
```

**Modes:**
- **revert** (default) - Creates new commits that undo changes. Safe, preserves history.
- **reset** (--hard flag) - Removes commits from history. Destructive, use with caution.

---

## Step 1: Parse Arguments

From `$ARGUMENTS`, extract:
- **Mode:** `revert` (default) or `reset` (if `--hard` present)
- **Target:** Number of commits (default: 1) OR specific commit hash

**Examples:**
| Arguments | Mode | Target |
|-----------|------|--------|
| (empty) | revert | 1 commit |
| `3` | revert | 3 commits |
| `abc123` | revert | specific commit |
| `--hard` | reset | 1 commit |
| `--hard 3` | reset | 3 commits |

---

## Step 2: Safety Checks

Run these checks BEFORE proceeding:

### Check 1: Verify Git Repository

```bash
git rev-parse --is-inside-work-tree
```

If not a git repo, abort:
```
🔴 Not a git repository

This command requires a git repository.
Initialize with: git init
```

### Check 2: Check for Uncommitted Changes

```bash
git status --porcelain
```

If there are uncommitted changes, abort:
```
🔴 Uncommitted changes detected

Please commit or stash your changes before rollback:
  git stash        # Temporarily store changes
  git commit -am "message"  # Commit changes

Then re-run: /project:rollback $ARGUMENTS
```

### Check 3: Verify Commits Exist

```bash
git log --oneline -n {count}
```

If not enough commits exist, abort:
```
🔴 Not enough commits

Requested: 5 commits
Available: 3 commits

Adjust your rollback target.
```

### Check 4: Reset Mode - Check if Pushed (CRITICAL)

For `--hard` mode only:

```bash
git log --oneline origin/$(git branch --show-current)..HEAD
```

If commits are already pushed, show strong warning:
```
⚠️  WARNING: Destructive Operation on Pushed Commits

These commits have been pushed to the remote repository.
Using --hard will:
- Remove commits from your local history
- Cause conflicts for anyone who has pulled these commits
- Require force push to sync (git push --force)

This is generally NOT recommended for shared branches.

Consider using revert instead (without --hard flag).

Type 'CONFIRM RESET' to proceed anyway, or 'cancel' to abort:
```

Wait for explicit confirmation before proceeding.

### Check 5: Merge Commits Warning

```bash
git log --oneline --merges -n {count}
```

If reverting merge commits, warn:
```
⚠️  Merge commit detected

Reverting merge commits is complex and may have unexpected results.
Consider manual intervention or consult git documentation.

Proceed anyway? [y/N]
```

### Check 6: Large Rollback Warning

If rolling back more than 5 commits:
```
⚠️  Large rollback requested: {count} commits

This will undo significant work. Please confirm this is intentional.

Proceed? [y/N]
```

---

## Step 3: Preview Changes

Show what will be undone:

```bash
# Get commits to be affected
git log --oneline -n {count}

# Show files affected
git diff --stat HEAD~{count}..HEAD
```

**Output format:**

For **revert** mode:
```
🔄 Rollback Preview

Mode: revert (safe - creates undo commits)
Commits to undo: {count}

1. {hash} - {message}
   Files: {file1}, {file2}

2. {hash} - {message}
   Files: {file1}, {file2}

This will create {count} new commit(s) that undo these changes.
History will be preserved.

Proceed? [y/N]
```

For **reset** mode:
```
🔄 Rollback Preview

Mode: reset --hard (DESTRUCTIVE - removes commits)
Commits to remove: {count}

1. {hash} - {message}
   Files: {file1}, {file2}

2. {hash} - {message}
   Files: {file1}, {file2}

⚠️  These commits will be PERMANENTLY REMOVED from history.
This cannot be easily undone.

Type 'yes' to proceed, or 'cancel' to abort:
```

---

## Step 4: Execute Rollback

### Revert Mode (Default)

```bash
# Create backup branch first
git branch backup/pre-rollback-$(date +%Y%m%d-%H%M%S)

# Revert commits (newest first, no-edit for automated message)
git revert --no-edit HEAD~{count-1}..HEAD
```

For single commit:
```bash
git revert --no-edit HEAD
```

For specific commit hash:
```bash
git revert --no-edit {hash}
```

### Reset Mode (--hard)

```bash
# Create backup branch first (CRITICAL for reset)
git branch backup/pre-reset-$(date +%Y%m%d-%H%M%S)

# Reset to target
git reset --hard HEAD~{count}
```

---

## Step 5: Update Task State

If `.claude/plans/current-task.md` exists and has an active task:

```bash
# Read current task state
cat .claude/plans/current-task.md
```

Update the status to reflect rollback:

```markdown
## Rollback Performed

**Date:** {timestamp}
**Mode:** {revert|reset}
**Commits Affected:** {count}
**Backup Branch:** backup/pre-{mode}-{timestamp}

Previous task progress has been rolled back.
```

---

## Step 6: Report Result

### Success - Revert Mode

```
✅ Rollback Complete (revert)

Commits reverted: {count}
New undo commits created: {count}

Backup branch: backup/pre-rollback-{timestamp}

Your changes have been undone. History is preserved.
The original commits are still visible in git log.

To push these changes:
  git push origin {branch}

To undo this rollback:
  git revert HEAD~{count}..HEAD
```

### Success - Reset Mode

```
✅ Rollback Complete (reset --hard)

Commits removed: {count}

Backup branch: backup/pre-reset-{timestamp}
(Use this to recover if needed)

Your local history has been rewritten.

⚠️  If these commits were pushed, you need to force push:
  git push --force origin {branch}

To recover the removed commits:
  git checkout backup/pre-reset-{timestamp}
```

### Failure

```
🔴 Rollback Failed

Error: {git error message}

Your repository state has not been changed.
Backup branch (if created): {branch name}

Recommended actions:
- Check git status: git status
- View recent commits: git log --oneline -10
- Manual recovery: git reflog
```

---

## Safety Summary

| Feature | Purpose |
|---------|---------|
| Backup branch | Always created before any rollback |
| Uncommitted check | Prevents losing work in progress |
| Pushed check (reset) | Warns about shared branch conflicts |
| Preview | Shows exactly what will change |
| Confirmation | Requires explicit approval |
| Merge warning | Alerts to complex scenarios |
| Large rollback warning | Prevents accidental mass undo |

---

## Examples

### Example 1: Undo last commit (safe)

```
User: /project:rollback

Output:
🔄 Rollback Preview

Mode: revert (safe - creates undo commits)
Commits to undo: 1

1. abc1234 - feat: add broken feature
   Files: src/feature.ts (+45), tests/feature.test.ts (+30)

This will create 1 new commit that undoes these changes.
History will be preserved.

Proceed? [y/N]
```

### Example 2: Undo last 3 commits (destructive)

```
User: /project:rollback --hard 3

Output:
🔄 Rollback Preview

Mode: reset --hard (DESTRUCTIVE - removes commits)
Commits to remove: 3

1. abc1234 - feat: broken feature 3
2. def5678 - feat: broken feature 2
3. ghi9012 - feat: broken feature 1

⚠️  These commits will be PERMANENTLY REMOVED from history.

Type 'yes' to proceed, or 'cancel' to abort:
```

---

## Output

After rollback, provide:
1. **Mode used:** revert or reset
2. **Commits affected:** List with hashes and messages
3. **Backup branch:** Name for recovery
4. **Next steps:** Push instructions or recovery options
