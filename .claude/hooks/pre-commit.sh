#!/bin/bash
# Hook: Validate commit message format before git commit
# Can be used as a git pre-commit hook or Claude Code hook

set -e

# Read commit message from argument or stdin
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
    COMMIT_MSG=$(cat)
fi

# Allowed commit prefixes based on agent conventions
ALLOWED_PREFIXES="feat|fix|refactor|test|docs|arch|design|security|review|devops|ci|chore|perf|build|revert"

# Extract first line
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n 1)

# Validate prefix format
if ! echo "$FIRST_LINE" | grep -qE "^($ALLOWED_PREFIXES)(\(.+\))?:"; then
    cat << EOF >&2
Invalid commit message format.

Expected format: <type>(<scope>): <description>

Allowed types:
  feat:     New feature (Engineer)
  fix:      Bug fix (Engineer)
  refactor: Code restructuring (Engineer)
  test:     Test changes (Tester)
  docs:     Documentation (Documenter)
  arch:     Architecture (Architect)
  design:   UI/UX design (Designer)
  security: Security changes (Security Auditor)
  review:   Code review (Code Reviewer)
  devops:   DevOps/CI changes (DevOps)
  ci:       CI/CD only (DevOps)
  chore:    Maintenance tasks
  perf:     Performance improvements
  build:    Build system changes
  revert:   Revert changes

Example: feat(auth): add JWT token refresh endpoint
EOF
    exit 2
fi

# Check commit message length
if [ ${#FIRST_LINE} -gt 72 ]; then
    echo "Warning: Commit message first line exceeds 72 characters" >&2
fi

exit 0
