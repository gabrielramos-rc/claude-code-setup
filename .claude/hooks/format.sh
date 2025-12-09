#!/bin/bash
# Hook: Auto-format files after Write/Edit operations
# Triggered by: PostToolUse (Write|Edit)

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on file type
case "$EXT" in
    ts|tsx|js|jsx|json)
        # Check if prettier is available
        if command -v npx &> /dev/null && [ -f "package.json" ]; then
            # Only format if prettier config exists or is in dependencies
            if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ] || grep -q "prettier" package.json 2>/dev/null; then
                npx prettier --write "$FILE_PATH" 2>/dev/null || true
            fi
        fi
        ;;
    py)
        # Check if black is available
        if command -v black &> /dev/null; then
            black "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    go)
        # Check if gofmt is available
        if command -v gofmt &> /dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    md)
        # Markdown files - no auto-formatting (preserve intentional formatting)
        ;;
esac

exit 0
