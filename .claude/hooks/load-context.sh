#!/bin/bash
# Hook: Load context and set environment variables at session start
# Triggered by: SessionStart

set -e

# Check if CLAUDE_ENV_FILE is available for environment injection
if [ -n "$CLAUDE_ENV_FILE" ]; then
    # Set framework version
    echo 'export CLAUDE_FRAMEWORK_VERSION="0.3"' >> "$CLAUDE_ENV_FILE"

    # Set project root
    echo "export CLAUDE_PROJECT_ROOT=\"$(pwd)\"" >> "$CLAUDE_ENV_FILE"

    # Check for Node.js project
    if [ -f "package.json" ]; then
        echo 'export CLAUDE_PROJECT_TYPE="nodejs"' >> "$CLAUDE_ENV_FILE"
    fi

    # Check for Python project
    if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        echo 'export CLAUDE_PROJECT_TYPE="python"' >> "$CLAUDE_ENV_FILE"
    fi

    # Check for Go project
    if [ -f "go.mod" ]; then
        echo 'export CLAUDE_PROJECT_TYPE="go"' >> "$CLAUDE_ENV_FILE"
    fi

    # Load any project-specific environment
    if [ -f ".claude/env.sh" ]; then
        cat ".claude/env.sh" >> "$CLAUDE_ENV_FILE"
    fi
fi

# Output status
echo "Session context loaded for project: $(basename "$(pwd)")"

exit 0
