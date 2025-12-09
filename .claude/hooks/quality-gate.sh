#!/bin/bash
# Hook: Check quality gates before stopping
# Triggered by: Stop (used with prompt-type hook for intelligent checking)

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Check for quality state files
ISSUES_FOUND=false
ISSUES=""

# Check test results
if [ -f ".claude/state/test-results.md" ]; then
    if grep -qiE "(FAIL|ERROR|failed)" ".claude/state/test-results.md" 2>/dev/null; then
        ISSUES_FOUND=true
        ISSUES="$ISSUES\n- Tests have failures (see .claude/state/test-results.md)"
    fi
fi

# Check security findings
if [ -f ".claude/state/security-findings.md" ]; then
    if grep -qiE "(CRITICAL|HIGH)" ".claude/state/security-findings.md" 2>/dev/null; then
        ISSUES_FOUND=true
        ISSUES="$ISSUES\n- Critical/High security issues found (see .claude/state/security-findings.md)"
    fi
fi

# Check code review findings
if [ -f ".claude/state/code-review-findings.md" ]; then
    if grep -qiE "CRITICAL" ".claude/state/code-review-findings.md" 2>/dev/null; then
        ISSUES_FOUND=true
        ISSUES="$ISSUES\n- Critical code review issues (see .claude/state/code-review-findings.md)"
    fi
fi

# Output quality gate status
if [ "$ISSUES_FOUND" = true ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop"
  },
  "continue": true,
  "systemMessage": "Quality gate warning: Issues detected that may need attention:$ISSUES"
}
EOF
else
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop"
  },
  "continue": true
}
EOF
fi

exit 0
