# Testing: $ARGUMENTS

## Instructions

Create or run tests for: **$ARGUMENTS**

### Use the **tester agent** to:

1. **Analyze Target**
   - Understand what needs testing
   - Review existing tests
   - Identify coverage gaps

2. **Create Tests**
   For each function/component:
   - Happy path tests
   - Edge case tests
   - Error handling tests

3. **Run Tests & Loop (Max 3 Attempts)**

Follow the reflexion loop pattern in `.claude/patterns/reflexion.md`.

**Reflexion Protocol (for test command):**

**Attempt 1:** Run tests, identify failures. If tests fail, investigate code or test issues.
**Attempt 2:** If new failures appear, investigate environment or test infrastructure.
**Attempt 3:** If failures persist, check for deeper test infrastructure issues.

After 3 attempts with persistent failures, output:

```
🔴 **Test failures persist after 3 attempts**

**Last Failure:**
[failure details]

**Manual Intervention Required:**
- Review failure log above
- Recommended action: [specific suggestion]
- Check test infrastructure OR review test expectations
```

Do NOT attempt a 4th run without changes.

### Test Types

- **Unit Tests** - Test individual functions
- **Integration Tests** - Test component interactions
- **E2E Tests** - Test user workflows

### Output

Provide:
1. Test files created/modified
2. Test results summary
3. Coverage information
4. Recommendations for additional testing
