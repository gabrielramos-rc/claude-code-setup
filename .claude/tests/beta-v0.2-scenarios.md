# Beta v0.2 Test Scenarios

## Test 1: Routing - Cosmetic Task

**Input:**
```
User: Fix the typo in the header component where "Welcme" should be "Welcome"
```

**Command:** `/project:route Fix the typo in the header component`

**Expected Output:**
```
**Complexity Level:** 1
**Reasoning:** Single file change, no logic, no tests needed
**Recommended Command:** `/project:implement`
**Confidence:** High
```

**Success Criteria:** Suggests implement, not plan

---

## Test 2: Routing - Feature Task

**Input:**
```
User: Add a dark mode toggle to the settings page with local storage persistence
```

**Command:** `/project:route Add dark mode toggle to settings`

**Expected Output:**
```
**Complexity Level:** 2
**Reasoning:** Multiple files (Settings component, theme context, storage utility),
requires tests for persistence logic
**Recommended Command:** `/project:plan`
**Confidence:** High
```

**Success Criteria:** Suggests plan first, not direct implement

---

## Test 3: Routing - System Task

**Input:**
```
User: Refactor the authentication system to use JWT instead of sessions
```

**Command:** `/project:route Refactor auth to use JWT`

**Expected Output:**
```
**Complexity Level:** 3
**Reasoning:** System-wide change, affects middleware, API routes, client storage,
requires integration tests, security review
**Recommended Command:** `/project:start`
**Confidence:** High
```

**Success Criteria:** Suggests start (full workflow), not plan

---

## Test 4: Reflexion Loop - Successful Retry

**Setup:**
```
1. Modify code to have easily fixable type error
2. Run /project:implement
```

**Expected Behavior:**
```
Attempt 1: Implement feature → tests fail (type error)
Reflexion: Read error, identify missing type annotation
Attempt 2: Add type annotation → tests pass
Output: Implementation complete
```

**Success Criteria:**
- Uses ≤ 2 attempts
- Fixes error automatically
- Proceeds to completion
- Does NOT ask user for help

---

## Test 5: Reflexion Loop - Exhausted Retries

**Setup:**
```
1. Create test with complex/ambiguous failure (e.g., race condition)
2. Run /project:implement
```

**Expected Behavior:**
```
Attempt 1: Implement → tests fail (race condition)
Reflexion: Try to fix with setTimeout
Attempt 2: Implement → tests still fail
Reflexion: Try to fix with Promise.all
Attempt 3: Implement → tests still fail
Output: 🔴 Automated fixes failed after 3 attempts
        Manual Intervention Required: [details]
```

**Success Criteria:**
- Stops at exactly 3 attempts
- Does NOT try attempt 4
- Outputs clear failure message
- Provides diagnostic info

---

## Test 6: Global Retry Limit

**Setup:**
```
1. Create scenario requiring implement (3 attempts) → review (reject) → fix (2 attempts)
2. Track cumulative retries
```

**Expected Behavior:**
```
implement: attempt 1, 2, 3 → pass (3 total)
review: reject
fix: attempt 1, 2 → pass (5 total)
review: check retry counter → at limit → ask user
```

**Success Criteria:**
- Cumulative counter increments correctly
- Stops at 5 total retries
- Does not continue to review loop
- Asks user for direction

---

## Test 7: Gatekeeping - User Confirmation

**Setup:**
```
1. Write code with intentional security issue
2. Run /project:review
```

**Expected Behavior:**
```
Review output:
[STATUS: REJECTED]

**Critical Issues:**
* src/api/user.ts (SQL injection vulnerability)

**Recommended Action:** User, please run /project:fix SQL injection in user.ts

[WAITS - does NOT auto-run fix command]
```

**Success Criteria:**
- Outputs [STATUS: REJECTED]
- Lists specific file and issue
- Suggests fix command
- Does NOT execute fix automatically
- User must explicitly run `/project:fix`

---

## Test 8: Artifact Priority - Conversation Conflict

**Setup:**
```
1. Create .claude/specs/tech-stack.md with "React Context for state"
2. In conversation, mention "use Redux"
3. Run /project:implement add user state management
```

**Expected Behavior:**
```
Engineer agent:
1. Reads tech-stack.md
2. Sees "React Context"
3. Notes conversation mentioned Redux
4. Implements React Context (artifact wins)
5. Outputs: "Using React Context per tech-stack.md.
            Note: Earlier conversation mentioned Redux - following artifact."
```

**Success Criteria:**
- Agent reads artifact first
- Uses artifact choice, not conversation
- Notes the discrepancy
- Explains decision

---

## Test 9: Artifact Priority - Missing Artifact

**Setup:**
```
1. Ensure .claude/specs/tech-stack.md does NOT exist
2. In conversation, say "use PostgreSQL"
3. Run /project:implement add database layer
```

**Expected Behavior:**
```
Engineer agent:
1. Tries to read tech-stack.md → file not found
2. Falls back to conversation
3. Uses PostgreSQL
4. Creates tech-stack.md with PostgreSQL
5. Outputs: "Using PostgreSQL per conversation. Created tech-stack.md."
```

**Success Criteria:**
- Handles missing artifact gracefully
- Uses conversation as fallback
- Creates artifact for future reference
- Explains decision

---

## Test 10: Artifact Priority - Internal Conflict

**Setup:**
```
1. requirements.md: "Support 10,000 concurrent users"
2. architecture.md: "Single-server deployment"
3. Run /project:implement user service
```

**Expected Behavior:**
```
Engineer agent:
1. Reads both artifacts
2. Detects conflict (10k users needs distributed, but arch is single-server)
3. Stops before implementing
4. Outputs: "🚨 Artifact Conflict Detected:
            - requirements.md: 10k concurrent users
            - architecture.md: single-server deployment
            Recommendation: Update architecture to distributed system
            Please clarify before proceeding."
```

**Success Criteria:**
- Detects internal artifact conflicts
- Does not proceed with contradictory implementation
- Flags to user
- Suggests resolution

---

## Regression Tests

### Ensure Existing Functionality Still Works

**Test R1: Basic implement command**
```
/project:implement add console.log to main.ts
→ Should work without routing
→ Should not trigger reflexion if tests pass
```

**Test R2: Basic review command**
```
/project:review
→ Should work without global retry counter
→ Should approve if code is good
```

**Test R3: Agent proactive invocation**
```
User: Can you write a user authentication function?
→ Engineer agent should trigger automatically
→ Should read artifacts if they exist
```

---

## Verification Checklist

After implementing Beta v0.2:

- [ ] Test 1 passed (routing cosmetic)
- [ ] Test 2 passed (routing feature)
- [ ] Test 3 passed (routing system)
- [ ] Test 4 passed (reflexion success)
- [ ] Test 5 passed (reflexion exhausted)
- [ ] Test 6 passed (global retry limit)
- [ ] Test 7 passed (gatekeeping confirmation)
- [ ] Test 8 passed (artifact priority - conflict)
- [ ] Test 9 passed (artifact priority - missing)
- [ ] Test 10 passed (artifact priority - internal conflict)
- [ ] Test R1 passed (basic implement)
- [ ] Test R2 passed (basic review)
- [ ] Test R3 passed (proactive agent)

**Pass Criteria:** 13/13 tests pass
**Failure Protocol:** If any test fails, halt deployment and debug
