# Reflexion Loop Pattern

This pattern should be used in any command that executes code and may fail.

## Protocol

**Max Attempts:** 3 per command
**Applicable Commands:** implement, fix, test

### Loop Structure

1. **Attempt 1:**
   - Execute action (implement/fix/test)
   - Verify with tester agent
   - If fail: read errors, identify root cause, fix

2. **Attempt 2:**
   - Re-execute action
   - Verify with tester agent
   - If fail: read errors, identify root cause, fix

3. **Attempt 3:**
   - Re-execute action
   - Verify with tester agent
   - If fail: STOP

### Failure Termination

After attempt 3 failure, output:

```
🔴 **Automated fixes failed after 3 attempts**

**Last Error:**
[error details]

**Manual Intervention Required:**
1. Review error log above
2. Recommended action: [specific suggestion]
3. Manually fix [specific file:line]
```

Do NOT attempt a 4th fix.

## Global Retry Coordination

In addition to per-command limits, there is a **global workflow limit** of 5 total retries across all commands in a workflow chain.

Before executing any retry:
1. Read `.claude/state/retry-counter.md`
2. Check if `total_retries < 5`
3. If at global limit: Stop and output "Global retry limit reached (5/5). Manual review required."
4. If under limit: Proceed with local reflexion loop
5. After each retry attempt: Update the counter

### Counter Update Protocol

When a command makes a retry attempt, it must:
1. Read current retry-counter.md
2. Increment total_retries
3. Add entry to retry log table
4. Write updated counter back to file

See `.claude/state/retry-counter.md` for the counter format.
