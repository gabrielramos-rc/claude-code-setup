# Input Safety Pattern

**Version:** v0.3
**Purpose:** Prevent injection attacks and malformed input when handling user-provided arguments and paths
**Scope:** All commands using `$ARGUMENTS`, Bash commands with user-provided values

---

## Problem Statement

Commands accept user input via `$ARGUMENTS` which is directly interpolated into:
- Markdown content
- Bash commands
- Git commit messages
- File paths

Without validation, malicious or malformed input can cause:
- Shell command injection
- Markdown formatting breaks
- Path traversal attacks
- Git message corruption

---

## $ARGUMENTS Validation (SEC-03)

### What is $ARGUMENTS?

The `$ARGUMENTS` variable contains raw user input passed to slash commands:

```
/project:implement Add user authentication with OAuth2
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                   This becomes $ARGUMENTS
```

### Risks

1. **Shell Injection:**
   ```markdown
   Debug the issue: **$ARGUMENTS**
   ```
   If `$ARGUMENTS` = `"; rm -rf /; echo "`, the output becomes malformed.

2. **Markdown Injection:**
   ```markdown
   Feature: $ARGUMENTS
   ```
   If `$ARGUMENTS` = `**bold** and [link](evil.com)`, formatting is hijacked.

3. **Git Message Injection:**
   ```bash
   git commit -m "feat: $ARGUMENTS"
   ```
   If `$ARGUMENTS` contains newlines or quotes, commit breaks.

### Safe Usage Guidelines

#### For Display/Markdown

**DO:** Treat `$ARGUMENTS` as plain text description
```markdown
**Task:** $ARGUMENTS
```
This is generally safe as Markdown rendering doesn't execute code.

**DON'T:** Use `$ARGUMENTS` in code blocks or command examples without escaping
```markdown
Run: `my-command $ARGUMENTS`  ← User sees literal input, but copy-paste could be dangerous
```

#### For Bash Commands

**NEVER** interpolate `$ARGUMENTS` directly into shell commands:

```bash
# DANGEROUS - Never do this
grep "$ARGUMENTS" src/
find . -name "$ARGUMENTS"
```

**INSTEAD**, use safe patterns:

```bash
# Option 1: Quote and escape (Claude should do this mentally before executing)
# When executing, ensure the value is properly quoted

# Option 2: Use arguments for what they are - descriptions, not commands
# $ARGUMENTS = "user authentication" → Use as search term with proper quoting
grep -r "authentication" src/  # Use extracted keywords, not raw input
```

#### For Git Commits

**DO:** Use HEREDOC for safe multi-line handling:

```bash
git commit -m "$(cat <<'EOF'
feat: implement feature

Description based on: $ARGUMENTS

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**DON'T:** Direct interpolation:

```bash
git commit -m "feat: $ARGUMENTS"  # Breaks on quotes, newlines
```

#### For File Paths

**NEVER** use `$ARGUMENTS` as a file path without validation:

```bash
# DANGEROUS
cat "$ARGUMENTS"
rm "$ARGUMENTS"
```

**INSTEAD**, validate paths:

```bash
# Check the path is within expected directories
# Don't allow ../ traversal
# Confirm file exists before operations
```

### Summary Table

| Context | Risk | Safe Pattern |
|---------|------|--------------|
| Markdown display | Low | Use directly (formatting only) |
| Bash commands | HIGH | Extract keywords, quote properly, never raw interpolation |
| Git messages | MEDIUM | Use HEREDOC, escape quotes |
| File paths | HIGH | Validate within expected dirs, no `../` |

---

## Bash Path Sanitization (SEC-04)

### Problem

Commands run Bash with paths/patterns that may contain:
- Spaces
- Special characters (`*`, `?`, `[`, `]`)
- Parent directory references (`../`)
- User-controlled values

### Unsafe Patterns

```bash
# Unquoted path with spaces
cat src/my file.txt          # Fails - interpreted as two arguments

# Glob injection
rm $USER_PATTERN             # If pattern is "*", deletes everything

# Path traversal
cat $USER_PATH               # If path is "../../../etc/passwd", reads system files
```

### Safe Patterns

#### Always Quote Paths

```bash
# SAFE - double quotes preserve spaces, expand variables safely
cat "src/my file.txt"
ls "$PROJECT_DIR"

# SAFE - single quotes for literal strings
find . -name '*.test.ts'
```

#### Validate Paths Before Use

When a path comes from user context or is constructed dynamically:

```bash
# Check path is within allowed directory
if [[ "$TARGET_PATH" != ./* && "$TARGET_PATH" != /* ]]; then
  # Relative path - prefix with ./
  TARGET_PATH="./$TARGET_PATH"
fi

# Check for traversal attempts
if [[ "$TARGET_PATH" == *".."* ]]; then
  echo "Error: Path traversal not allowed"
  exit 1
fi
```

#### Use `--` to End Options

Prevent filenames starting with `-` from being interpreted as flags:

```bash
# SAFE - -- ends option parsing
rm -- "$FILENAME"
cat -- "$FILEPATH"
grep -r "pattern" -- "$DIRECTORY"
```

#### Escape Glob Characters When Needed

```bash
# If you want literal *, not glob expansion
pattern='\*'
grep "$pattern" file.txt
```

### Recommended Patterns by Command Type

| Command | Safe Pattern | Why |
|---------|--------------|-----|
| `tree` | `tree -L 3 -I 'node_modules\|.git'` | Quoted patterns, escaped pipe |
| `find` | `find . -type f -name '*.md'` | Quoted glob pattern |
| `grep` | `grep -r "pattern" -- src/` | Quoted pattern, `--` for safety |
| `cat` | `cat -- "$filepath"` | Quoted variable, `--` for safety |
| `rm` | `rm -- "$file"` | NEVER with user input; always `--` |

### Special Case: tree Ignore Patterns

The `tree` command is used frequently for project structure:

```bash
# SAFE - pattern properly quoted
tree -L 3 -I 'node_modules|.git|dist|build|coverage'

# SAFE - multiple -I flags for clarity
tree -L 3 -I 'node_modules' -I '.git' -I 'dist'
```

---

## Checklist for Command Authors

When creating or updating commands that use user input:

- [ ] `$ARGUMENTS` is NOT directly interpolated into Bash commands
- [ ] All file paths are quoted with double quotes
- [ ] Glob patterns in commands use single quotes
- [ ] Git commit messages use HEREDOC format
- [ ] No raw `$ARGUMENTS` in constructed paths
- [ ] Path traversal (`../`) is either blocked or intentionally allowed
- [ ] `--` separator used before paths in commands that support it

---

## Version History

- **v0.3 (2025-12-07):** Initial pattern addressing SEC-03 and SEC-04
