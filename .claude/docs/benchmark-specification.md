# Framework Benchmark Specification

## Benchmark Application: Task Management API

### Purpose
Standardized benchmark to measure framework effectiveness across versions and validate improvements.

---

## Application Requirements

### Phase 1: Core API (Complexity Level 1-2)
- [ ] Express.js REST API setup
- [ ] Task CRUD endpoints (GET, POST, PUT, DELETE /tasks)
- [ ] Input validation (title required, status enum)
- [ ] Filter by status endpoint (GET /tasks?status=pending)
- [ ] Pagination support (GET /tasks?limit=10&offset=0)

### Phase 2: Authentication (Complexity Level 3)
- [ ] JWT authentication middleware
- [ ] User registration endpoint (POST /auth/register)
- [ ] User login endpoint (POST /auth/login)
- [ ] Protected routes (tasks belong to authenticated user)

### Phase 3: Advanced Features (Complexity Level 2)
- [ ] Task priority field (low/medium/high)
- [ ] Search endpoint (GET /tasks/search?q=keyword)
- [ ] Due date tracking (dueDate field, isOverdue computed)
- [ ] Task assignment (assignedTo field, GET /tasks/assigned-to-me)

### Phase 4: Production Readiness
- [ ] Unit tests (≥80% coverage)
- [ ] Integration tests (all endpoints)
- [ ] Security audit (SQL injection, XSS, authentication)
- [ ] Rate limiting (max 100 requests/15min per IP)
- [ ] OpenAPI/Swagger documentation
- [ ] Environment configuration (.env support)
- [ ] Error handling (global error middleware)
- [ ] Docker deployment (Dockerfile + docker-compose.yml)
- [ ] Application deployed and running in Docker on local machine
- [ ] API accessible at http://localhost:3000
- [ ] Database running in separate Docker container
- [ ] Deployment verification (test at least one endpoint)

### Technology Stack
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** PostgreSQL
- **Testing:** Jest + Supertest
- **Validation:** Zod or Joi
- **Documentation:** Swagger/OpenAPI
- **Deployment:** Docker + Docker Compose
- **Containerization:** Multi-stage Dockerfile, separate containers for API and DB

---

## Benchmark Metrics

### 1. Routing Accuracy (Target: ≥80%)

**Test Scenarios:**
- Cosmetic (L1): "Fix typo in error message" → Should suggest `/project:implement`
- Feature (L2): "Add task priority levels" → Should suggest `/project:plan`
- System (L3): "Add JWT authentication" → Should suggest `/project:start`

**Scoring:**
- Correct routing = 1 point
- Over-routing (L1→L2, L2→L3) = 0.5 points (acceptable)
- Under-routing (L3→L2, L2→L1) = 0 points (failure)

**Score:** (Points / Total Tasks) × 100

---

### 2. Automated Fix Success Rate (Target: ≥70%)

**Test Scenarios:**
- Type error in task model
- Missing import in controller
- Failing unit test (simple logic bug)
- Database connection error (missing env var)
- Validation error (incorrect schema)

**Scoring:**
- Fixed within 3 retries = 1 point
- Exhausted retries with diagnostic = 0.5 points
- Attempted 4th retry = 0 points (failure)

**Score:** (Points / Total Fixable Errors) × 100

---

### 3. Infinite Loop Prevention (Target: 100%)

**Test Scenarios:**
- Implement → Test → Fix → Review → Fix (chain retry)
- Circular dependency error
- Persistent test failure (unfixable in 3 attempts)

**Scoring:**
- Stops at ≤5 total retries = 1 point
- Exceeds 5 retries = 0 points (critical failure)

**Score:** (Points / Total Scenarios) × 100

---

### 4. Context Retention (Target: ≥90%)

**Test Scenarios:**
- Artifact says "PostgreSQL" → Conversation says "MongoDB" → Should use PostgreSQL
- Missing artifact → Should create from conversation
- Conflicting artifacts → Should flag conflict and ask user

**Scoring:**
- Follows artifact correctly = 1 point
- Follows conversation when should follow artifact = 0 points
- Handles missing artifact gracefully = 1 point
- Detects and flags conflicts = 1 point

**Score:** (Points / Total Scenarios) × 100

---

### 5. Code Quality Score (Target: ≥85%)

**Evaluation Criteria:**
- [ ] TypeScript strict mode compliance (10 points)
- [ ] No security vulnerabilities (20 points)
- [ ] Test coverage ≥80% (15 points)
- [ ] API follows REST conventions (10 points)
- [ ] Error handling complete (10 points)
- [ ] Input validation on all endpoints (10 points)
- [ ] Documentation complete (10 points)
- [ ] Docker deployment successful (10 points)
- [ ] No hardcoded secrets (5 points)

**Score:** (Points Earned / 100) × 100

---

### 6. Deployment Success Score (Target: 100%)

**Evaluation Criteria:**
- [ ] Dockerfile created and optimized (multi-stage build) (20 points)
- [ ] docker-compose.yml with API + PostgreSQL services (20 points)
- [ ] `docker-compose up` builds successfully (15 points)
- [ ] Containers start without errors (15 points)
- [ ] API accessible at http://localhost:3000 (15 points)
- [ ] Database migrations run automatically (10 points)
- [ ] At least one endpoint tested and working (5 points)

**Verification Commands:**
```bash
docker-compose up -d
docker ps  # Should show 2 running containers
curl http://localhost:3000/health  # Should return 200 OK
curl http://localhost:3000/api-docs  # Should return Swagger UI
```

**Scoring:**
- All criteria met = 100%
- Partial deployment (builds but doesn't run) = 50%
- Build fails = 0%

**Score:** (Points Earned / 100) × 100

---

### 7. Time to Completion

**Measurement:**
- Track total time from `/project:start` to fully deployed in Docker
- Count number of user interventions required
- Measure retry cycles needed

**Comparison:**
- Compare v0.2 vs v0.1 (or future versions)
- Shorter time + fewer interventions = better framework

---

### 8. User Intervention Count (Target: 30% reduction)

**Categories:**
- Clarification questions (acceptable)
- Manual fixes (failure - should auto-retry)
- Approval gates (expected - review, security)
- Conflict resolution (expected - artifact conflicts)

**Scoring:**
- Count only "Manual fixes" interventions
- Compare to baseline version
- Calculate reduction percentage

---

## Benchmark Execution Protocol

### Step 1: Baseline Measurement (First Run)
1. Start fresh project: `/project:start Task Management API`
2. Provide full requirements (phases 1-4)
3. Track all metrics during development
4. Document issues encountered
5. Record final scores

### Step 2: Framework Improvement
1. Identify bottlenecks from baseline
2. Improve framework (new agents, better prompts, etc.)
3. Version the framework (e.g., v0.3)

### Step 3: Comparison Run
1. Start identical project with new framework version
2. Use EXACT same requirements
3. Track all metrics
4. Compare scores side-by-side

### Step 4: Analysis
1. Calculate improvement percentages
2. Identify what improved vs regressed
3. Document lessons learned
4. Update framework based on findings

---

## Scoring Template

```markdown
# Benchmark Results: [Framework Version]

**Date:** [YYYY-MM-DD]
**Tester:** [Name]

## Application Completeness
- [ ] Phase 1 Complete (Core API)
- [ ] Phase 2 Complete (Authentication)
- [ ] Phase 3 Complete (Advanced Features)
- [ ] Phase 4 Complete (Production Ready)

## Metric Scores

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Routing Accuracy | ≥80% | __% | ✅/❌ |
| Auto-Fix Success | ≥70% | __% | ✅/❌ |
| Loop Prevention | 100% | __% | ✅/❌ |
| Context Retention | ≥90% | __% | ✅/❌ |
| Code Quality | ≥85% | __% | ✅/❌ |
| Deployment Success | 100% | __% | ✅/❌ |

## Time & Efficiency

- **Total Time:** __ hours
- **User Interventions (Manual Fixes):** __ count
- **Retry Cycles:** __ count
- **Commands Used:** [list]

## Deployment Verification

- **Docker Build Success:** ✅/❌
- **Containers Running:** __ / 2 (API + PostgreSQL)
- **API Accessible:** ✅/❌ (http://localhost:3000)
- **Database Connected:** ✅/❌
- **Test Endpoint Verified:** ✅/❌
- **Swagger UI Accessible:** ✅/❌ (http://localhost:3000/api-docs)

## Qualitative Assessment

**What Worked Well:**
- [observation]

**What Failed:**
- [observation]

**Improvement Opportunities:**
- [recommendation]

## Overall Score

**Framework Effectiveness:** (Average of 6 metrics) ___%

**Grade:**
- A (≥90%): Production-ready framework
- B (80-89%): Good, needs minor improvements
- C (70-79%): Functional, needs significant improvements
- D (60-69%): Requires major redesign
- F (<60%): Framework not viable

**Deployment Grade:**
- ✅ **PASS**: Application deployed and accessible in Docker
- ❌ **FAIL**: Deployment incomplete or not working
```

---

## Benchmark Variations (Future Testing)

### Variation 1: Simple CRUD API (Fast Baseline)
- Remove authentication (Phase 2)
- Remove advanced features (Phase 3)
- Focus on routing and auto-retry

### Variation 2: Frontend Application
- React Task Manager UI
- Tests framework on different tech stack
- Validates framework flexibility

### Variation 3: Microservices
- Split into Auth Service + Task Service
- Tests system-level orchestration
- Validates multi-repo coordination

---

## Quick Start Command

To run the benchmark:

```bash
# 1. Start new project
/project:start Task Management API

# 2. Provide requirements
[Paste Phase 1-4 requirements]

# 3. Let framework orchestrate
[Follow routing suggestions]

# 4. Track metrics in real-time
[Use scoring template]

# 5. Complete benchmark
[Fill in results template]
```

---

## Success Criteria for Framework Version Release

A framework version is ready for release when:

- [ ] Benchmark achieves all metric targets
- [ ] No critical failures (infinite loops, security issues)
- [ ] Application deploys successfully to Docker
- [ ] Application is accessible and functional at http://localhost:3000
- [ ] All Docker verification tests pass
- [ ] Documentation is complete
- [ ] Improvement over previous version (if applicable)

---

## Notes

- Run benchmark at least 3 times per framework version for consistency
- Use same hardware/environment for fair comparison
- Document any manual overrides or deviations
- Share results with framework development team
- Update benchmark as framework capabilities evolve
