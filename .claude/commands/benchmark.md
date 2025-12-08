# Benchmark: Profile Framework Performance

## Instructions

Run a benchmark to profile framework performance and measure efficiency improvements.

**Purpose:** Validate v0.3's claimed 70%+ efficiency improvement and identify optimization opportunities.

---

## What Gets Measured

### Token Efficiency
- Spec reads (should be 1 per spec with context injection)
- File discovery commands (should be 1 tree command per workflow)
- Total tokens used vs baseline

### Time Efficiency
- Quality validation time (parallel vs sequential)
- Total workflow duration
- Agent execution times

### Quality Coverage
- Percentage of workflows with testing
- Percentage with security audits
- Percentage with code review

### Session Resilience
- Number of interruptions handled
- Resume success rate
- Rework percentage after interruptions

---

## How to Run a Benchmark

### Option 1: Automatic Benchmark (Recommended)

Run a standardized test workflow and compare against baseline:

```bash
# 1. Run benchmark workflow
/project:implement "Simple authentication feature"

# 2. Export session data
./.claude/benchmark/tools/export-full-session.sh

# 3. Analyze results
# Results saved to .claude/benchmark/results/{timestamp}/
```

### Option 2: Manual Comparison

Compare your workflow against pre-v0.3 baseline:

**Step 1: Run your workflow normally**
- `/project:implement {your feature}`
- Or `/project:fix {your bug}`

**Step 2: Export session**
```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

**Step 3: Analyze**
Check generated report in `.claude/benchmark/results/{timestamp}/`

Look for:
- FRAMEWORK-IMPROVEMENT-ANALYSIS.md (detailed analysis)
- EXECUTIVE-SUMMARY.md (high-level metrics)
- QUICK-ANALYSIS.md (quick wins identified)

---

## Interpreting Results

### Token Efficiency Metrics

**Context Injection (Phase 1 impact):**
```
✅ GOOD: 1-3 reads per spec file
❌ BAD: 10+ reads per spec file (redundant reads)

Expected improvement: 40-50% token reduction
```

**File Discovery (Phase 1 impact):**
```
✅ GOOD: 1 tree/ls command per workflow
❌ BAD: 50+ ls/find/tree commands (redundant discovery)

Expected improvement: 10-15% token reduction
```

### Time Efficiency Metrics

**Parallel Quality Validation (Phase 2 impact):**
```
✅ GOOD: ~5 minutes for validation
❌ BAD: 10+ minutes for validation (sequential execution)

Expected improvement: 50% time reduction
```

### Resume Capability Metrics

**State-Based Session Management (Phase 3 impact):**
```
✅ GOOD: Resume from checkpoint, 0% rework
❌ BAD: Start from scratch, 100% rework

Expected improvement: 100% resume capability
```

---

## Benchmark Templates

Use these templates to create reproducible benchmarks:

### Template 1: Simple Feature Implementation
```
Task: Implement JWT authentication
Baseline (pre-v0.3): ~45 minutes, 50K tokens
Target (v0.3): ~25 minutes, 25K tokens
```

### Template 2: Bug Fix Workflow
```
Task: Fix login validation bug
Baseline (pre-v0.3): ~15 minutes, 15K tokens
Target (v0.3): ~10 minutes, 8K tokens
```

### Template 3: Interrupted Workflow
```
Task: Implement feature, interrupt at 60%, resume
Baseline (pre-v0.3): Restart from 0%, 100% rework
Target (v0.3): Resume from 60%, 0% rework
```

---

## Export Tools Reference

### export-full-session.sh

Exports complete session including all sub-agents.

**Usage:**
```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

**Output:**
- Main conversation (JSONL + Markdown)
- All sub-agent conversations
- Analysis summaries
- Statistics

**Location:** `.claude/benchmark/results/{timestamp}/`

### convert-jsonl-to-markdown.sh

Converts JSONL session exports to readable Markdown.

**Usage:**
```bash
cd .claude/benchmark/tools
./convert-jsonl-to-markdown.sh input.jsonl output.md
```

---

## Baseline Metrics (Pre-v0.3)

Use these as comparison baselines:

### Token Usage (Pre-v0.3)
- Typical implementation: 40-60K tokens
- Spec reads: 28+ redundant reads
- File discovery: 60+ redundant commands
- Quality validation: Not automated (0% coverage)

### Time (Pre-v0.3)
- Typical implementation: 45-60 minutes
- Quality validation: 10-15 minutes (if done manually)
- Resume after interruption: Not possible (100% rework)

### Quality Coverage (Pre-v0.3)
- Testing: 0% (engineers test own code)
- Security audits: 0%
- Code review: 0%

---

## Expected v0.3 Improvements

### Token Efficiency
- **40-50% reduction** from context injection
- **Spec reads:** 28+ → 3 (85% reduction)
- **File discovery:** 60+ → 3 (95% reduction)

### Time Efficiency
- **50% reduction** in quality validation (parallel execution)
- **Overall:** 30-40% faster workflows

### Quality Coverage
- **100% coverage** - Every implementation gets testing, security, and review

### Resume Capability
- **100% resume rate** - All interrupted sessions can continue
- **0% rework** - Continue from checkpoint, not from scratch

---

## Creating Custom Benchmarks

### Step 1: Define Test Scenario

Create benchmark template in `.claude/benchmark/templates/`:

```markdown
# Benchmark: {Scenario Name}

## Task Description
{What feature/fix to implement}

## Baseline Metrics (Pre-v0.3)
- Tokens: {expected}
- Time: {expected}
- Quality: {coverage %}

## Target Metrics (v0.3)
- Tokens: {expected}
- Time: {expected}
- Quality: 100%

## Steps
1. {step 1}
2. {step 2}
...
```

### Step 2: Run Benchmark

Execute the workflow:
```bash
/project:implement "{task from template}"
```

### Step 3: Export and Analyze

```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

### Step 4: Compare Results

Compare exported metrics against baseline and target.

---

## Continuous Benchmarking

### Track Over Time

Create benchmark history:
```bash
# Run monthly benchmarks
# Compare: .claude/benchmark/results/{month}/

# Track trends:
# - Token usage trending down?
# - Time trending down?
# - Quality coverage stable at 100%?
```

### Regression Detection

If metrics regress:
1. Check which pattern isn't being followed
2. Review agent prompts for boundary violations
3. Verify context injection is working
4. Confirm parallel validation is running

---

## Output

After benchmarking, you'll have:

1. **Quantitative Metrics**
   - Token usage breakdown
   - Time measurements
   - Quality coverage percentages

2. **Analysis Reports**
   - EXECUTIVE-SUMMARY.md (high-level metrics)
   - FRAMEWORK-IMPROVEMENT-ANALYSIS.md (detailed)
   - QUICK-ANALYSIS.md (quick wins)

3. **Session Archives**
   - Full conversation history
   - Sub-agent transcripts
   - Statistics and metrics

4. **Comparison Data**
   - Baseline vs actual
   - Target vs actual
   - Improvement percentages

---

## Troubleshooting

### "Export script not found"
```bash
# Make sure you're in the right directory
cd .claude/benchmark/tools
ls -la export-full-session.sh

# Make executable if needed
chmod +x export-full-session.sh
```

### "No session data available"
- Session data is stored in Claude Code's data directory
- Export immediately after running workflows
- Check Claude Code documentation for session storage location

### "Results don't match expected improvements"
- Verify all v0.3 patterns are being used:
  - Context injection (Step 0 in commands)
  - Parallel validation (Task tool with multiple agents)
  - Task tracking (current-task.md updates)
- Check agent prompts for proper file boundaries
- Review command workflows for proper orchestration

---

## Next Steps

After benchmarking:

1. **Document Results** - Save metrics for future comparison
2. **Identify Gaps** - Find where improvements aren't being realized
3. **Iterate** - Refine agent prompts and commands
4. **Share** - Contribute benchmarks back to framework repository

---

**Pattern Reference:** See `.claude/benchmark/SESSION-EXPORT-GUIDE.md` for detailed export tool usage.
