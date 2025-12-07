# Benchmark Application Prompt

Use this prompt to test the Claude Code framework. Copy and paste this entire prompt when starting a new benchmark test.

---

## Prompt for Claude Code

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

## How to Use This Prompt

### Step 1: Prepare Environment
```bash
# Create a new directory for benchmark
mkdir task-api-benchmark-v0.2
cd task-api-benchmark-v0.2

# Initialize git
git init

# Copy .claude directory from framework
cp -r /path/to/claude-code-setup/.claude .
```

### Step 2: Start Benchmark
1. Open Claude Code in the benchmark directory
2. Paste the prompt above
3. Let Claude route the task: `/project:route [task]`
4. Follow the framework's recommendations

### Step 3: Track Metrics
Use the scoring template from `benchmark-specification.md` to track:
- Routing decisions
- Retry attempts
- User interventions
- Time to completion
- Code quality
- Deployment success

### Step 4: Verify Deployment
After framework completes:
```bash
# Check containers are running
docker ps

# Test API endpoint
curl http://localhost:3000/tasks

# Check API documentation
open http://localhost:3000/api-docs
```

### Step 5: Compare Results
Run the same benchmark with different framework versions and compare scores.

---

## Expected Framework Behavior (v0.2)

1. **Routing Phase:**
   - Should recognize this as Level 3 (System) complexity
   - Should recommend `/project:start`

2. **Planning Phase:**
   - Product Manager: Create requirements.md
   - Architect: Design system architecture
   - Output tech-stack decision (Express, TypeScript, PostgreSQL)

3. **Implementation Phase:**
   - Engineer: Implement features incrementally
   - Tester: Write tests after each feature
   - Auto-retry on test failures (max 3 attempts)

4. **Quality Phase:**
   - Code Reviewer: Review code (may reject with specific issues)
   - Security Auditor: Check for vulnerabilities
   - User approves fixes before proceeding

5. **Deployment Phase:**
   - DevOps: Create Docker setup, docker-compose.yml
   - Deploy application to Docker on local machine
   - Verify deployment with test requests
   - Documenter: Generate README and API docs

---

## Benchmark Variations

### Quick Benchmark (30-60 minutes)
Use only Phase 1 + Phase 4 (Core API + Tests + Docker Deployment)

### Standard Benchmark (2-4 hours)
Use Phases 1, 2, 4 (Core + Auth + Quality + Docker Deployment)

### Full Benchmark (4-8 hours)
Use all phases 1-4 with full Docker deployment

---

## Success Indicators

✅ **Framework Working Well:**
- Routes to `/project:start` for full workflow
- Creates artifacts in `.claude/specs/`
- Auto-retries failing tests successfully
- Security review catches vulnerabilities
- No infinite loops
- Docker containers build successfully
- Application runs and is accessible at http://localhost:3000
- API endpoints respond correctly

❌ **Framework Issues:**
- Under-routes (suggests `/project:implement` for system-level task)
- Doesn't create/read artifacts
- Fails tests without retry
- Infinite retry loops
- Security issues missed
- Manual intervention required for fixable errors
- Docker build/deployment fails
- Application not accessible after deployment

---

## Deployment Verification Checklist

After deployment, verify:
- [ ] `docker ps` shows running containers (API + PostgreSQL)
- [ ] `curl http://localhost:3000/health` returns 200 OK
- [ ] `curl http://localhost:3000/tasks` works (may require auth)
- [ ] `http://localhost:3000/api-docs` shows Swagger UI
- [ ] Database migrations ran successfully
- [ ] Environment variables loaded correctly
- [ ] Logs are accessible via `docker logs [container-name]`

---

## Troubleshooting

If framework behaves unexpectedly:
1. Check if `.claude/` directory is present
2. Verify CLAUDE.md exists in project root
3. Check retry counter: `.claude/state/retry-counter.md`
4. Review artifacts: `.claude/specs/*.md`
5. Document issue for framework improvement

If deployment fails:
1. Check Docker is installed and running
2. Review Dockerfile and docker-compose.yml
3. Check port 3000 is not already in use
4. Review docker logs for errors
5. Verify PostgreSQL connection string

---

## Results Reporting

After completing benchmark, create a file:
```
benchmark-results-v[version]-[date].md
```

Include:
- Framework version tested
- All metric scores
- Time breakdown by phase
- Issues encountered
- Code quality assessment
- Deployment success status
- Docker verification results
- Overall grade (A-F)

---

## Next Steps After Benchmark

1. **Analyze bottlenecks** - Where did framework struggle?
2. **Improve framework** - Update agents, commands, or patterns
3. **Re-run benchmark** - Validate improvements
4. **Compare versions** - Document progress
5. **Share learnings** - Update framework documentation
