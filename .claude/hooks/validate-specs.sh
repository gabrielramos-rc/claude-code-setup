#!/bin/bash
# Hook: Validate specifications exist before invoking Task tool
# Triggered by: PreToolUse (Task)

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Get the tool name and task description
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TASK_PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // empty')

# Only validate for implementation tasks
if echo "$TASK_PROMPT" | grep -qi "engineer\|implement\|code\|build"; then
    # Check if architecture spec exists
    if [ ! -f ".claude/specs/architecture.md" ]; then
        echo "Warning: No architecture.md found in .claude/specs/" >&2
        echo "Consider running /project:start first to create specifications." >&2
        # Don't block - just warn (exit 0 allows continuation)
    fi

    # Check if requirements spec exists
    if [ ! -f ".claude/specs/requirements.md" ]; then
        echo "Warning: No requirements.md found in .claude/specs/" >&2
        echo "Consider defining requirements before implementation." >&2
    fi
fi

# Output JSON response (optional - allows modification of input)
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse"
  },
  "continue": true
}
EOF

exit 0
