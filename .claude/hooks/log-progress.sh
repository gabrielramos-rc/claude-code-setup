#!/bin/bash
# Hook: Log workflow progress for tracking
# Triggered by: Notification

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract notification details
NOTIFICATION=$(echo "$INPUT" | jq -r '.notification // empty')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log file location
LOG_FILE=".claude/state/progress-log.md"

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    cat > "$LOG_FILE" << 'EOF'
# Progress Log

Automatic log of workflow progress.

---

EOF
fi

# Append notification to log
if [ -n "$NOTIFICATION" ]; then
    echo "### $TIMESTAMP" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "$NOTIFICATION" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

exit 0
