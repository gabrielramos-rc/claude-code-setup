# Claude Code Hooks

This directory contains hook scripts for automating Claude Code workflows.

## Available Hooks

### `format.sh` (PostToolUse)
**Trigger:** After Write or Edit operations
**Purpose:** Auto-format files based on their type

Supported formatters:
- **TypeScript/JavaScript:** Prettier (if configured in project)
- **Python:** Black (if installed)
- **Go:** gofmt (if installed)

### `validate-specs.sh` (PreToolUse)
**Trigger:** Before Task tool invocation
**Purpose:** Warn if specifications are missing before implementation

Checks for:
- `.claude/specs/architecture.md`
- `.claude/specs/requirements.md`

### `load-context.sh` (SessionStart)
**Trigger:** When a Claude Code session starts
**Purpose:** Set up environment variables and context

Sets:
- `CLAUDE_FRAMEWORK_VERSION` - Current framework version
- `CLAUDE_PROJECT_ROOT` - Project root directory
- `CLAUDE_PROJECT_TYPE` - Detected project type (nodejs, python, go)

### `pre-commit.sh` (Git Integration)
**Purpose:** Validate commit message format

Expected format: `<type>(<scope>): <description>`

Allowed types:
- `feat`, `fix`, `refactor` - Engineer
- `test` - Tester
- `docs` - Documenter
- `arch` - Architect
- `design` - UI/UX Designer
- `security` - Security Auditor
- `review` - Code Reviewer
- `devops`, `ci` - DevOps
- `chore`, `perf`, `build`, `revert` - General

## Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": ".claude/hooks/format.sh",
          "timeout": 30
        }]
      }
    ]
  }
}
```

## Hook Input/Output

### Input (JSON via stdin)
```json
{
  "session_id": "abc123",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "src/index.ts",
    "content": "..."
  }
}
```

### Exit Codes
- `0` - Success (continue)
- `2` - Blocking error (stop with message)
- Other - Non-blocking error (warn and continue)

## Creating Custom Hooks

1. Create a script in `.claude/hooks/`
2. Make it executable: `chmod +x .claude/hooks/my-hook.sh`
3. Add configuration to `.claude/settings.json`

### Available Events
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `SessionStart` - Session begins
- `SessionEnd` - Session ends
- `UserPromptSubmit` - User submits prompt
- `Stop` - Claude finishes working
- `Notification` - Notifications sent

## Security Notes

- All scripts run with project directory permissions
- Validate input before processing
- Quote shell variables to prevent injection
- Don't process secrets or sensitive files

---

*Part of Claude Code Framework v0.3*
