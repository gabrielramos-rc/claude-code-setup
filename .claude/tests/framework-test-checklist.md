# Framework Test Checklist

**Purpose:** Manual QA checklist for validating framework behavior after changes.

**How to use:**
1. Run each test scenario manually
2. Record result (PASS/FAIL) and date
3. Add notes for failures
4. All tests must pass before release

---

## Test Run Record

| Run Date | Version | Tester | Result |
|----------|---------|--------|--------|
| YYYY-MM-DD | v0.X | Name | X/13 |

---

## Category 1: Task Routing

### Test 1.1: Cosmetic Task Routing

| Field | Value |
|-------|-------|
| **Command** | `/project:route Fix the typo in the header component` |
| **Expected** | Complexity 1, recommends `/project:implement` |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

### Test 1.2: Feature Task Routing

| Field | Value |
|-------|-------|
| **Command** | `/project:route Add dark mode toggle to settings` |
| **Expected** | Complexity 2, recommends `/project:plan` |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

### Test 1.3: System Task Routing

| Field | Value |
|-------|-------|
| **Command** | `/project:route Refactor auth to use JWT` |
| **Expected** | Complexity 3, recommends `/project:start` |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

## Category 2: Reflexion Loop

### Test 2.1: Successful Auto-Retry

| Field | Value |
|-------|-------|
| **Setup** | Create code with easily fixable type error |
| **Command** | `/project:implement` |
| **Expected** | Fixes error in ≤2 attempts, completes without user help |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Uses ≤2 attempts
- [ ] Fixes error automatically
- [ ] Completes successfully
- [ ] Does NOT ask user for help

---

### Test 2.2: Exhausted Retries (3 max)

| Field | Value |
|-------|-------|
| **Setup** | Create unfixable test failure (e.g., race condition) |
| **Command** | `/project:implement` |
| **Expected** | Stops at 3 attempts, outputs failure message |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Stops at exactly 3 attempts
- [ ] Does NOT try attempt 4
- [ ] Outputs clear failure message
- [ ] Provides diagnostic info

---

### Test 2.3: Global Retry Limit (5 max)

| Field | Value |
|-------|-------|
| **Setup** | Trigger multiple command retries across workflow |
| **Command** | Multiple commands totaling >5 retries |
| **Expected** | Stops at 5 cumulative retries, asks user |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Cumulative counter increments correctly
- [ ] Stops at 5 total retries
- [ ] Asks user for direction

---

## Category 3: Human Gatekeeping

### Test 3.1: Review Waits for User

| Field | Value |
|-------|-------|
| **Setup** | Write code with intentional security issue |
| **Command** | `/project:review` |
| **Expected** | Outputs REJECTED, suggests fix, WAITS for user |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Outputs [STATUS: REJECTED]
- [ ] Lists specific file and issue
- [ ] Suggests fix command
- [ ] Does NOT execute fix automatically

---

## Category 4: Artifact Priority

### Test 4.1: Artifact Wins Over Conversation

| Field | Value |
|-------|-------|
| **Setup** | specs/tech-stack.md says "React Context", conversation says "use Redux" |
| **Command** | `/project:implement add user state management` |
| **Expected** | Uses React Context (artifact), notes discrepancy |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Reads artifact first
- [ ] Uses artifact choice, not conversation
- [ ] Notes the discrepancy
- [ ] Explains decision

---

### Test 4.2: Missing Artifact Fallback

| Field | Value |
|-------|-------|
| **Setup** | Delete tech-stack.md, mention "use PostgreSQL" in conversation |
| **Command** | `/project:implement add database layer` |
| **Expected** | Uses PostgreSQL, creates tech-stack.md |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Handles missing artifact gracefully
- [ ] Uses conversation as fallback
- [ ] Creates artifact for future
- [ ] Explains decision

---

### Test 4.3: Internal Artifact Conflict

| Field | Value |
|-------|-------|
| **Setup** | requirements.md: "10k users", architecture.md: "single-server" |
| **Command** | `/project:implement user service` |
| **Expected** | Detects conflict, stops, asks for clarification |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

**Criteria:**
- [ ] Detects artifact conflict
- [ ] Does NOT proceed with implementation
- [ ] Flags to user
- [ ] Suggests resolution

---

## Category 5: Regression Tests

### Test 5.1: Basic Implement

| Field | Value |
|-------|-------|
| **Command** | `/project:implement add console.log to main.ts` |
| **Expected** | Works without routing, no reflexion if tests pass |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

### Test 5.2: Basic Review

| Field | Value |
|-------|-------|
| **Command** | `/project:review` |
| **Expected** | Works, approves if code is good |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

### Test 5.3: Proactive Agent Invocation

| Field | Value |
|-------|-------|
| **Input** | "Can you write a user authentication function?" |
| **Expected** | Engineer agent triggers automatically, reads artifacts |
| **Result** | [ ] PASS  [ ] FAIL |
| **Date** | |
| **Notes** | |

---

## Summary

### Results Table

| # | Test | Result | Date |
|---|------|--------|------|
| 1.1 | Cosmetic Routing | | |
| 1.2 | Feature Routing | | |
| 1.3 | System Routing | | |
| 2.1 | Successful Retry | | |
| 2.2 | Exhausted Retries | | |
| 2.3 | Global Retry Limit | | |
| 3.1 | Review Waits | | |
| 4.1 | Artifact Priority | | |
| 4.2 | Missing Artifact | | |
| 4.3 | Artifact Conflict | | |
| 5.1 | Basic Implement | | |
| 5.2 | Basic Review | | |
| 5.3 | Proactive Agent | | |

**Total: ___/13**

---

## Release Criteria

- **Pass:** 13/13 tests pass
- **Conditional:** 12/13 with documented workaround
- **Fail:** <12/13 - do not release

---

## Failure Log

Record any failures for debugging:

| Date | Test | Failure Description | Resolution |
|------|------|---------------------|------------|
| | | | |
