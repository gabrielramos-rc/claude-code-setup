# Debug: $ARGUMENTS

## Instructions

Debug the issue: **$ARGUMENTS**

### Debugging Process

1. **Understand the Problem**
   - Read any error messages or stack traces
   - Review recent changes that might have caused the issue
   - Check `.claude/state/retry-counter.md` to see what's been attempted

2. **Investigate**
   - Read the failing test output
   - Examine the code where the error occurred
   - Check for common issues:
     - Syntax errors
     - Missing dependencies
     - Incorrect imports
     - Type mismatches
     - Logic errors

3. **Diagnose Root Cause**
   - Trace the error back to its source
   - Identify what condition is causing the failure
   - Determine if it's a code issue, configuration issue, or environment issue

4. **Present Findings**
   - Clearly explain what's wrong
   - Show the specific file and line number
   - Explain why it's failing
   - Suggest 2-3 possible solutions with trade-offs

### Output

Provide:
- **Problem Summary:** What's failing and why
- **Root Cause:** The underlying issue
- **Location:** Specific file:line references
- **Recommended Fix:** Step-by-step solution
- **Alternative Approaches:** Other ways to solve it (if applicable)

**Important:** This command investigates and explains - it does NOT automatically fix. After understanding the issue, use `/project:fix` or manually implement the solution.
