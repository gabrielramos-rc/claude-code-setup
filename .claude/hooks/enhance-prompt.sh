#!/bin/bash
# Hook: Enhance user prompts with context
# Triggered by: UserPromptSubmit

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract the prompt
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Exit early if no prompt
if [ -z "$PROMPT" ]; then
    exit 0
fi

# Check if prompt mentions specific patterns that need context
NEEDS_CONTEXT=false
CONTEXT_FILES=""

# Check for architecture-related keywords
if echo "$PROMPT" | grep -qiE "(architect|design|structure|pattern|api|database|schema)"; then
    if [ -f ".claude/specs/architecture.md" ]; then
        CONTEXT_FILES="$CONTEXT_FILES .claude/specs/architecture.md"
        NEEDS_CONTEXT=true
    fi
fi

# Check for requirements-related keywords
if echo "$PROMPT" | grep -qiE "(requirement|feature|user story|acceptance|criteria)"; then
    if [ -f ".claude/specs/requirements.md" ]; then
        CONTEXT_FILES="$CONTEXT_FILES .claude/specs/requirements.md"
        NEEDS_CONTEXT=true
    fi
fi

# Check for test-related keywords
if echo "$PROMPT" | grep -qiE "(test|testing|coverage|spec|jest|vitest)"; then
    if [ -f ".claude/state/test-results.md" ]; then
        CONTEXT_FILES="$CONTEXT_FILES .claude/state/test-results.md"
        NEEDS_CONTEXT=true
    fi
fi

# Output suggestion if context would help
if [ "$NEEDS_CONTEXT" = true ]; then
    echo "Suggested context files:$CONTEXT_FILES" >&2
fi

exit 0
