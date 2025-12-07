# Benchmark Quick Start Guide

Step-by-step instructions to run the Claude Code framework benchmark.

---

## Prerequisites

Before starting, ensure you have:
- [ ] Docker Desktop installed and running
- [ ] Git installed
- [ ] Claude Code CLI installed
- [ ] At least 4GB free disk space
- [ ] Ports 3000 and 5432 available (not in use)

---

## Step 1: Create Benchmark Project Directory

```bash
# Navigate to your projects folder
cd ~/rcconsultech

# Create a new directory for the benchmark
mkdir task-api-benchmark-v0.2
cd task-api-benchmark-v0.2

# Initialize git repository
git init

# Create initial commit (required for Claude Code)
git commit --allow-empty -m "Initial commit for benchmark"
```

---

## Step 2: Copy Framework Files

```bash
# Copy the .claude directory from the framework repo
cp -r ~/rcconsultech/claude-code-setup/.claude .

# Copy the template CLAUDE.md as the project's CLAUDE.md
cp ~/rcconsultech/claude-code-setup/TEMPLATE-CLAUDE.md ./CLAUDE.md

# Verify files were copied
ls -la .claude/
# Should see: agents/, commands/, docs/, patterns/, plans/, specs/, state/, tests/

# Verify CLAUDE.md exists
ls -la CLAUDE.md
```

---

## Step 3: Open Claude Code

```bash
# Start Claude Code in the benchmark directory
claude-code

# OR if you're using VS Code extension, open the folder:
code .
# Then launch Claude Code from VS Code
```

---

## Step 4: Paste the Benchmark Prompt

Copy the prompt from `.claude/docs/benchmark-prompt.md` or use this:

```
I want to build a production-ready Task Management REST API to benchmark the Claude Code framework.

Requirements:

PHASE 1: Core API
- Set up Express.js with TypeScript
- Create task model with fields: id, title, description, status, createdAt
- Implement CRUD endpoints:
  * POST /tasks - Create task
  * GET /tasks - List all tasks
  * GET /tasks/:id - Get single task
  * PUT /tasks/:id - Update task
  * DELETE /tasks/:id - Delete task
- Add input validation (title required, status must be: pending/in-progress/completed)
- Implement filtering: GET /tasks?status=pending
- Add pagination: GET /tasks?limit=10&offset=0
- Use PostgreSQL for data storage

PHASE 2: Authentication
- Implement JWT authentication
- Add user model: id, email, password (hashed), createdAt
- Create endpoints:
  * POST /auth/register - User registration
  * POST /auth/login - User login (returns JWT)
- Protect task endpoints - users can only access their own tasks
- Add userId foreign key to tasks table

PHASE 3: Advanced Features
- Add priority field to tasks (low, medium, high)
- Implement search: GET /tasks/search?q=keyword (searches title + description)
- Add dueDate field to tasks
- Create computed property: isOverdue (true if dueDate < now and status != completed)
- Add task assignment: assignedTo field, GET /tasks/assigned-to-me endpoint

PHASE 4: Production Readiness
- Write comprehensive tests:
  * Unit tests for models and services
  * Integration tests for all API endpoints
  * Achieve minimum 80% test coverage
- Run security audit:
  * Prevent SQL injection
  * Prevent XSS attacks
  * Validate JWT properly
  * Hash passwords with bcrypt
- Implement rate limiting (100 requests per 15 minutes per IP)
- Add API documentation with Swagger/OpenAPI
- Create environment variable configuration (.env file)
- Implement global error handling middleware
- Add request logging
- Prepare for deployment:
  * Create Dockerfile
  * Add docker-compose.yml with PostgreSQL
  * Create README with setup instructions
  * Deploy and run the application in Docker on this machine
  * Verify the API is accessible at http://localhost:3000
  * Include docker commands to start/stop the application

Technical Requirements:
- Use TypeScript with strict mode
- Use environment variables for all configuration
- Follow REST best practices
- No hardcoded secrets or credentials
- Proper HTTP status codes for all responses
- Consistent error response format

Deliverables:
1. Fully functional API running on localhost via Docker
2. All tests passing
3. Security audit passed
4. API documentation accessible at http://localhost:3000/api-docs
5. Application deployed and running in Docker containers
6. Complete README with setup and deployment instructions
7. Verify deployment by testing at least one endpoint
```

---

## Step 5: Start Tracking Metrics

Create a benchmark results file:

```bash
# Create results tracking file
touch benchmark-results-v0.2-$(date +%Y%m%d).md
```

Copy this template into the file:

```markdown
# Benchmark Results: Framework v0.2

**Date:** [YYYY-MM-DD]
**Tester:** [Your Name]
**Start Time:** [HH:MM]

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
- **Commands Used:** [list all /project:* commands used]

## Deployment Verification

- **Docker Build Success:** ✅/❌
- **Containers Running:** __ / 2 (API + PostgreSQL)
- **API Accessible:** ✅/❌ (http://localhost:3000)
- **Database Connected:** ✅/❌
- **Test Endpoint Verified:** ✅/❌
- **Swagger UI Accessible:** ✅/❌ (http://localhost:3000/api-docs)

## Detailed Observations

### Routing Decisions
[Track each routing decision and whether it was correct]

### Auto-Retry Events
[Track each time the framework auto-retried and the outcome]

### User Interventions
[Log each time you had to manually intervene and why]

### Issues Encountered
[Document any problems, errors, or unexpected behavior]

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

## Recommendations
[What should be improved in the next framework version?]
```

---

## Step 6: Let Claude Code Work

After pasting the prompt:

1. **Observe routing**: Claude should recognize this as a Level 3 (System) task and suggest `/project:start`

2. **Track interventions**: Note every time you need to:
   - Answer a question
   - Manually fix something
   - Approve/reject a review
   - Resolve a conflict

3. **Monitor retries**: Watch for automatic retry attempts on failed tests/builds

4. **Check artifacts**: Periodically verify that `.claude/specs/` files are being created and updated

---

## Step 7: Verify Deployment

Once the framework completes, verify the deployment:

```bash
# Check if containers are running
docker ps

# Expected output: 2 containers (API + PostgreSQL)
# CONTAINER ID   IMAGE                    STATUS
# abc123...      task-api-benchmark:latest  Up X minutes
# def456...      postgres:15                Up X minutes

# Test the health endpoint
curl http://localhost:3000/health

# Expected: {"status":"ok"} or similar

# Test the API documentation
curl http://localhost:3000/api-docs

# Or open in browser:
open http://localhost:3000/api-docs

# Test a CRUD endpoint (create task)
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Benchmark test","status":"pending"}'

# Test list tasks
curl http://localhost:3000/tasks

# Check logs if needed
docker-compose logs api
docker-compose logs db
```

---

## Step 8: Calculate Metrics

### Routing Accuracy
- Did Claude suggest `/project:start`? ✅ Correct (Level 3 task)
- Score: 100% (1 task, correctly routed)

### Auto-Fix Success Rate
- Count how many test failures were auto-fixed within 3 retries
- Count how many required manual intervention
- Score: (Auto-fixed / Total failures) × 100

### Loop Prevention
- Did any command retry more than 3 times? ❌ = FAIL
- Did total retries across workflow exceed 5? ❌ = FAIL
- Score: 100% if no violations, 0% if any violation

### Context Retention
- Check if `.claude/specs/architecture.md` mentions TypeScript + Express + PostgreSQL
- Verify later agents used these decisions (not different tech)
- Score: (Correct artifact usage / Total decisions) × 100

### Code Quality
Use the checklist from `benchmark-specification.md`:
- [ ] TypeScript strict mode (10 pts)
- [ ] No security vulnerabilities (20 pts)
- [ ] Test coverage ≥80% (15 pts)
- [ ] REST conventions (10 pts)
- [ ] Error handling (10 pts)
- [ ] Input validation (10 pts)
- [ ] Documentation (10 pts)
- [ ] Docker deployment (10 pts)
- [ ] No hardcoded secrets (5 pts)

### Deployment Success
- [ ] Dockerfile created (20 pts)
- [ ] docker-compose.yml (20 pts)
- [ ] Build successful (15 pts)
- [ ] Containers running (15 pts)
- [ ] API accessible (15 pts)
- [ ] Migrations auto-run (10 pts)
- [ ] Endpoint verified (5 pts)

---

## Step 9: Fill Out Results Template

Update your `benchmark-results-v0.2-[date].md` file with:
- All metric scores
- Total time elapsed
- Number of interventions
- Deployment verification results
- Observations and recommendations

---

## Step 10: Cleanup (Optional)

After completing the benchmark:

```bash
# Stop Docker containers
docker-compose down

# Remove volumes (clean database)
docker-compose down -v

# Remove images (full cleanup)
docker-compose down --rmi all -v
```

---

## Troubleshooting

### Issue: Docker not running
```bash
# Start Docker Desktop
open -a Docker

# Wait for Docker to start, then verify
docker ps
```

### Issue: Port 3000 already in use
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process or change the port in docker-compose.yml
```

### Issue: PostgreSQL port 5432 in use
```bash
# Find what's using port 5432
lsof -i :5432

# Stop PostgreSQL if running locally
brew services stop postgresql
# or
sudo systemctl stop postgresql
```

### Issue: Framework doesn't create artifacts
- Verify `.claude/` directory exists
- Check `CLAUDE.md` is in project root
- Ensure you're using framework v0.2

### Issue: Infinite loop detected
- Check `.claude/state/retry-counter.md`
- This is actually a test of the framework's limits
- Document when/why it happened
- Framework should stop at 5 total retries

---

## Quick Reference: Expected Timeline

| Phase | Expected Duration | Key Milestones |
|-------|------------------|----------------|
| Setup | 5-10 min | Project created, framework copied |
| Routing | 1-2 min | Claude suggests `/project:start` |
| Planning | 10-20 min | Requirements, architecture, tech-stack created |
| Phase 1 (Core) | 30-60 min | CRUD endpoints + tests |
| Phase 2 (Auth) | 30-60 min | JWT implementation + tests |
| Phase 3 (Features) | 20-40 min | Search, priority, assignments |
| Phase 4 (Quality) | 30-60 min | Security, docs, deployment |
| Deployment | 10-20 min | Docker build + verify |
| **Total** | **2.5-5 hours** | Fully deployed API |

---

## Success Checklist

Before considering the benchmark complete:

- [ ] All 4 phases implemented
- [ ] Tests passing (run `npm test` or framework equivalent)
- [ ] Security audit completed (no critical vulnerabilities)
- [ ] Docker containers running (`docker ps` shows 2 containers)
- [ ] API accessible (`curl http://localhost:3000/health` works)
- [ ] Swagger UI accessible (http://localhost:3000/api-docs)
- [ ] At least one CRUD operation verified
- [ ] All metrics calculated and recorded
- [ ] Results template filled out
- [ ] Recommendations documented

---

## Next Steps

1. **Compare with baseline** - If you run this again with v0.3, compare scores
2. **Identify improvements** - What worked well? What needs work?
3. **Update framework** - Make changes to agents/commands based on learnings
4. **Re-benchmark** - Test the improved framework
5. **Document learnings** - Share insights with team

---

## Support

If you encounter issues:
1. Check `.claude/state/retry-counter.md` for retry status
2. Review `.claude/specs/` for artifact state
3. Check framework documentation in `CLAUDE.md`
4. Document the issue for framework improvement

---

## Appendix: File Locations Reference

```
task-api-benchmark-v0.2/
├── .claude/
│   ├── agents/          # Framework agents (don't modify)
│   ├── commands/        # Framework commands (don't modify)
│   ├── docs/            # Framework documentation
│   ├── specs/           # PROJECT ARTIFACTS (created by agents)
│   │   ├── requirements.md
│   │   ├── architecture.md
│   │   └── tech-stack.md
│   ├── plans/           # Current task tracking
│   ├── state/           # Retry counter
│   └── tests/           # Framework test scenarios
├── CLAUDE.md            # Project-specific instructions
├── benchmark-results-v0.2-[date].md  # Your metrics tracking
└── [application files created by framework]
    ├── src/
    ├── tests/
    ├── Dockerfile
    ├── docker-compose.yml
    └── README.md
```

---

**Ready to start?** Follow Step 1 and begin your benchmark! 🚀
