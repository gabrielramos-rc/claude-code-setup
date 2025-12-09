# Workflow Retry Counter

**Purpose:** Track cumulative retries across command chain to prevent infinite loops

## Current Workflow

**Status:** Inactive
**Task:** None
**Started:** N/A
**Command Chain:** []
**Total Retries:** 0/5

## Retry Log

| Command | Attempt | Result | Notes |
|---------|---------|--------|-------|
| - | - | - | No retries yet |

## Usage Instructions

When a command needs to retry:
1. Read this file
2. Check if `Total Retries < 5`
3. If yes: Increment counter, add log entry, proceed
4. If no: Stop and output "Global retry limit reached. Manual review required."

## Termination Protocol

When total retries reach 5 across all commands:
1. Stop all automated fixes
2. Output cumulative error report
3. Ask user for direction

## Reset

To reset the counter for a new workflow, set:
- Status: Inactive
- Task: None
- Total Retries: 0/5
- Clear retry log (set to "No retries yet")
