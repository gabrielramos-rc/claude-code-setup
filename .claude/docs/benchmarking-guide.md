# Framework Benchmarking Guide

**Version:** v0.3+
**Purpose:** Measure and validate framework performance improvements
**Created:** 2025-12-06

---

## Overview

The Claude Code framework includes built-in benchmarking tools to help you:
- **Validate efficiency claims** - Confirm the 70%+ efficiency improvement
- **Profile your usage** - Identify bottlenecks and optimization opportunities
- **Track improvements** - Measure progress over time
- **Compare workflows** - Before/after v0.3 comparisons

---

## Quick Start

### 1. Run a Workflow

Execute any command workflow:
```bash
/project:implement "Add user authentication"
```

### 2. Export Session Data

```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

### 3. Review Results

Check `.claude/benchmark/results/{timestamp}/`:
- `EXECUTIVE-SUMMARY.md` - High-level metrics
- `FRAMEWORK-IMPROVEMENT-ANALYSIS.md` - Detailed analysis
- `QUICK-ANALYSIS.md` - Quick wins identified

---

## What Gets Benchmarked

### Token Efficiency Metrics

**1. Context Injection Impact (Phase 1)**

Measures redundant spec reads:
```
Baseline (pre-v0.3): 28+ spec reads
Target (v0.3): 3 spec reads (1 per file)
Expected improvement: 85% reduction
```

**2. File Discovery Impact (Phase 1)**

Measures redundant Bash file discovery:
```
Baseline (pre-v0.3): 60+ ls/find/tree commands
Target (v0.3): 3 commands (1 per workflow)
Expected improvement: 95% reduction
```

**3. Total Token Usage**

Measures overall token consumption:
```
Baseline (pre-v0.3): 40-60K tokens per implementation
Target (v0.3): 20-30K tokens per implementation
Expected improvement: 40-50% reduction
```

### Time Efficiency Metrics

**1. Quality Validation Time (Phase 2)**

Measures parallel vs sequential validation:
```
Baseline (pre-v0.3): 10-15 minutes (sequential or manual)
Target (v0.3): 5-7 minutes (parallel automated)
Expected improvement: 50% reduction
```

**2. Total Workflow Duration**

Measures end-to-end time:
```
Baseline (pre-v0.3): 45-60 minutes
Target (v0.3): 25-35 minutes
Expected improvement: 30-40% reduction
```

### Quality Coverage Metrics

**1. Automated Testing Coverage**

Percentage of implementations with automated tests:
```
Baseline (pre-v0.3): 0% (engineers test own code)
Target (v0.3): 100% (Tester agent on every implementation)
```

**2. Security Audit Coverage**

Percentage of implementations with security audits:
```
Baseline (pre-v0.3): 0% (no automated security)
Target (v0.3): 100% (Security Auditor on every implementation)
```

**3. Code Review Coverage**

Percentage of implementations with independent review:
```
Baseline (pre-v0.3): 0% (no automated review)
Target (v0.3): 100% (Code Reviewer on every implementation)
```

### Resume Capability Metrics

**1. Resume Success Rate (Phase 3)**

Percentage of interrupted sessions that can resume:
```
Baseline (pre-v0.3): 0% (no resume capability)
Target (v0.3): 100% (resume from any checkpoint)
```

**2. Rework Percentage**

Percentage of work redone after interruption:
```
Baseline (pre-v0.3): 100% (start from scratch)
Target (v0.3): 0% (continue from checkpoint)
```

---

## Benchmark Workflows

### Standard Benchmarks

The framework includes standard benchmark scenarios for consistent measurement.

#### Benchmark 1: Simple Feature Implementation

**Task:** Implement JWT authentication with bcrypt password hashing

**Baseline Metrics (Pre-v0.3):**
- Tokens: 45,000
- Time: 50 minutes
- Spec reads: 30
- File discovery: 65 Bash commands
- Quality coverage: 0%

**Target Metrics (v0.3):**
- Tokens: 22,500 (50% reduction)
- Time: 27 minutes (46% reduction)
- Spec reads: 3 (90% reduction)
- File discovery: 3 (95% reduction)
- Quality coverage: 100%

**How to Run:**
```bash
/project:implement "JWT authentication with bcrypt password hashing"
```

#### Benchmark 2: Bug Fix Workflow

**Task:** Fix login validation bug allowing empty passwords

**Baseline Metrics (Pre-v0.3):**
- Tokens: 15,000
- Time: 18 minutes
- Spec reads: 12
- File discovery: 25 Bash commands
- Quality coverage: 0%

**Target Metrics (v0.3):**
- Tokens: 8,000 (47% reduction)
- Time: 10 minutes (44% reduction)
- Spec reads: 3 (75% reduction)
- File discovery: 3 (88% reduction)
- Quality coverage: 100% (testing + review)

**How to Run:**
```bash
/project:fix "Login validation bug - empty passwords accepted"
```

#### Benchmark 3: Interrupted Workflow Recovery

**Task:** Implement feature, simulate interruption at 60%, resume

**Baseline Metrics (Pre-v0.3):**
- Resume capability: 0%
- Rework: 100% (restart from scratch)
- Time lost: 30+ minutes

**Target Metrics (v0.3):**
- Resume capability: 100%
- Rework: 0% (continue from checkpoint)
- Time to resume: <2 minutes

**How to Run:**
1. Start: `/project:implement "User profile management"`
2. Interrupt at 60% (simulate quota limit)
3. Resume: `/project:resume`
4. Measure time to resume vs time to restart

---

## Export Tools

### export-full-session.sh

**Location:** `.claude/benchmark/tools/export-full-session.sh`

**Purpose:** Exports complete session data including all sub-agents

**Usage:**
```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

**Output Structure:**
```
.claude/benchmark/results/{timestamp}/
├── EXECUTIVE-SUMMARY.md         # High-level metrics
├── FRAMEWORK-IMPROVEMENT-ANALYSIS.md  # Detailed analysis
├── QUICK-ANALYSIS.md            # Quick wins
├── README.md                    # Export info
├── session-index.md             # Session overview
├── statistics.txt               # Raw stats
├── readable/                    # Markdown conversations
│   ├── main-conversation.md
│   └── ...
└── sub-agents/                  # Sub-agent transcripts
    ├── agent-1.md
    └── ...
```

**What Gets Exported:**
- Main conversation (JSONL + Markdown)
- All sub-agent conversations
- Token usage by message
- Tool usage statistics
- Error patterns
- Performance metrics

### convert-jsonl-to-markdown.sh

**Location:** `.claude/benchmark/tools/convert-jsonl-to-markdown.sh`

**Purpose:** Converts JSONL session files to human-readable Markdown

**Usage:**
```bash
cd .claude/benchmark/tools
./convert-jsonl-to-markdown.sh input.jsonl output.md
```

**Features:**
- Preserves message structure
- Includes tool calls and results
- Highlights errors and warnings
- Formats code blocks
- Shows token counts

---

## Analysis Reports

### EXECUTIVE-SUMMARY.md

**What it contains:**
- Overall efficiency improvement percentage
- Token reduction metrics
- Time savings metrics
- Quality coverage summary
- Key findings (top 3-5)

**Example:**
```markdown
# Executive Summary

## Overall Improvement
- Token efficiency: 48% reduction
- Time efficiency: 42% reduction
- Quality coverage: 100% (from 0%)

## Key Findings
1. Context injection eliminated 26 redundant spec reads
2. Parallel validation saved 8 minutes per workflow
3. 100% of implementations now have automated testing
```

### FRAMEWORK-IMPROVEMENT-ANALYSIS.md

**What it contains:**
- Detailed token usage breakdown
- Command-by-command analysis
- Agent-by-agent performance
- Pattern compliance verification
- Optimization recommendations

**Example:**
```markdown
# Framework Improvement Analysis

## Token Usage Analysis

### Context Injection (Phase 1)
- requirements.md: 9 reads → 1 read (89% reduction)
- architecture.md: 11 reads → 1 read (91% reduction)
- tech-stack.md: 8 reads → 1 read (88% reduction)

### File Discovery (Phase 1)
- ls commands: 42 → 1 (98% reduction)
- find commands: 15 → 0 (100% reduction)
- tree commands: 8 → 2 (75% reduction)
```

### QUICK-ANALYSIS.md

**What it contains:**
- Top optimization opportunities
- Quick wins identified
- Anti-patterns detected
- Immediate action items

**Example:**
```markdown
# Quick Analysis

## Quick Wins Identified
1. 🎯 Context injection working correctly (28 → 3 spec reads)
2. ⚡ Parallel validation saved 7 minutes
3. ✅ 100% quality coverage achieved

## Optimization Opportunities
1. Engineer agent re-reading architecture.md (boundary issue?)
2. Tester agent running ls twice (use file tree from context)
```

---

## Creating Custom Benchmarks

### Step 1: Define Benchmark Template

Create `.claude/benchmark/templates/{benchmark-name}.md`:

```markdown
# Benchmark: {Name}

## Task Description
{Detailed description of what to implement/fix}

## Baseline Metrics (Pre-v0.3)
- Tokens: {expected}
- Time: {expected}
- Spec reads: {expected}
- File discovery: {expected}
- Quality coverage: {percentage}

## Target Metrics (v0.3)
- Tokens: {expected} ({improvement}%)
- Time: {expected} ({improvement}%)
- Spec reads: 3
- File discovery: 3
- Quality coverage: 100%

## Steps to Run
1. Run: /project:{command} "{task}"
2. Export: cd .claude/benchmark/tools && ./export-full-session.sh
3. Analyze: Review .claude/benchmark/results/{timestamp}/

## Success Criteria
- [ ] Token usage within target range
- [ ] Time within target range
- [ ] 100% quality coverage achieved
- [ ] No boundary violations detected
```

### Step 2: Run Benchmark

Execute the workflow:
```bash
/project:implement "{task from template}"
# or
/project:fix "{bug from template}"
```

### Step 3: Export Data

```bash
cd .claude/benchmark/tools
./export-full-session.sh
```

Wait for export to complete (may take 1-2 minutes for large sessions).

### Step 4: Analyze Results

Review generated reports:
```bash
cd .claude/benchmark/results/{timestamp}
cat EXECUTIVE-SUMMARY.md
```

Compare against template targets.

### Step 5: Document Findings

Update template with actual results:
```markdown
## Actual Results (Run {date})
- Tokens: {actual} ({actual improvement}%)
- Time: {actual} ({actual improvement}%)
- Spec reads: {actual}
- File discovery: {actual}
- Quality coverage: {actual}%

## Variance Analysis
- Tokens: {explanation of variance}
- Time: {explanation of variance}
```

---

## Continuous Benchmarking

### Monthly Benchmarks

Run standard benchmarks monthly to track performance over time:

```bash
# Month 1 (Baseline)
/project:implement "JWT authentication"
# Export and save: .claude/benchmark/results/2025-12-baseline/

# Month 2 (After v0.3)
/project:implement "JWT authentication"
# Export and save: .claude/benchmark/results/2025-12-v0.3/

# Month 3 (Refinements)
/project:implement "JWT authentication"
# Export and save: .claude/benchmark/results/2026-01-refined/
```

### Trend Analysis

Track metrics over time:
```
Metric          | Dec (baseline) | Dec (v0.3) | Jan (refined)
----------------|----------------|------------|---------------
Tokens          | 45,000         | 23,000     | 21,500
Time (min)      | 50             | 28         | 26
Spec reads      | 30             | 3          | 3
Quality cov.    | 0%             | 100%       | 100%
```

### Regression Detection

If metrics regress:

**1. Check Pattern Compliance**
- Is context injection being used? (Step 0 in commands)
- Is parallel validation running? (3 Task tools in single message)
- Is task tracking updating? (current-task.md checkpoints)

**2. Review Agent Boundaries**
- Are agents reading files they shouldn't?
- Are agents writing to wrong locations?
- Is distributed git working? (each agent commits own work)

**3. Verify Command Workflows**
- Are commands following the correct sequence?
- Are agents receiving context via XML documents?
- Are quality gates running?

---

## Interpreting Results

### Token Efficiency

**Good Performance:**
- ✅ 40-50% total token reduction
- ✅ 1-3 spec reads per file
- ✅ 1-3 file discovery commands per workflow

**Poor Performance:**
- ❌ <20% token reduction
- ❌ 10+ spec reads per file
- ❌ 20+ file discovery commands

**Action:** Review context injection implementation if poor.

### Time Efficiency

**Good Performance:**
- ✅ 30-50% time reduction
- ✅ 5-7 minutes for quality validation
- ✅ Parallel agent execution

**Poor Performance:**
- ❌ <15% time reduction
- ❌ 10+ minutes for quality validation
- ❌ Sequential agent execution

**Action:** Verify parallel validation if poor.

### Quality Coverage

**Good Performance:**
- ✅ 100% testing coverage
- ✅ 100% security audit coverage
- ✅ 100% code review coverage

**Poor Performance:**
- ❌ <100% coverage on any metric
- ❌ Quality agents not invoked
- ❌ Manual quality checks

**Action:** Check command workflows if poor.

---

## Troubleshooting

### Export Script Fails

**Error:** `export-full-session.sh: Permission denied`

**Solution:**
```bash
chmod +x .claude/benchmark/tools/export-full-session.sh
```

### No Session Data

**Error:** `Session data not found`

**Solution:**
- Export immediately after running workflow
- Check Claude Code data directory permissions
- Verify session ID is correct

### Results Don't Match Expected

**Issue:** Actual improvements less than expected

**Investigation:**
1. Check if all v0.3 patterns are active:
   ```bash
   # Context injection?
   grep "Step 0: Load Project Context" .claude/commands/implement.md

   # Parallel validation?
   grep "PARALLEL EXECUTION" .claude/commands/implement.md

   # Task tracking?
   cat .claude/plans/current-task.md
   ```

2. Review agent prompts for compliance
3. Check command execution logs
4. Look for error messages in export

---

## Best Practices

### 1. Baseline First

Always establish a baseline before v0.3:
- Run workflow without v0.3 features
- Export and save results
- Use as comparison point

### 2. Consistent Scenarios

Use the same task for before/after comparisons:
- "Implement JWT authentication" (not "auth" then "login")
- Same complexity level
- Same tech stack

### 3. Multiple Runs

Run benchmarks multiple times:
- Account for variability
- Average results
- Identify outliers

### 4. Document Context

Record environmental factors:
- Model used (Sonnet, Opus)
- Time of day (quota availability)
- Project complexity
- Tech stack

### 5. Share Results

Contribute benchmarks back to framework:
- Help validate improvements
- Identify edge cases
- Build community knowledge

---

## Example Benchmark Report

```markdown
# Benchmark Report: JWT Authentication

**Date:** 2025-12-06
**Task:** Implement JWT authentication with bcrypt
**Baseline:** Pre-v0.3 framework
**Test:** v0.3 framework

## Metrics Comparison

| Metric              | Baseline | v0.3    | Improvement |
|---------------------|----------|---------|-------------|
| Total Tokens        | 47,200   | 24,100  | 49%         |
| Total Time          | 52 min   | 29 min  | 44%         |
| Spec Reads          | 32       | 3       | 91%         |
| File Discovery      | 68       | 3       | 96%         |
| Quality Coverage    | 0%       | 100%    | +100pp      |

## Detailed Analysis

### Context Injection Impact
- requirements.md: 10 reads → 1 read
- architecture.md: 12 reads → 1 read
- tech-stack.md: 10 reads → 1 read
- **Total savings:** 29 redundant reads eliminated

### Parallel Validation Impact
- Sequential time: 12 minutes
- Parallel time: 6 minutes
- **Total savings:** 6 minutes (50% reduction)

### Quality Coverage Impact
- Tester agent: Designed 8 tests, 85% coverage
- Security agent: 0 CRITICAL, 1 HIGH finding
- Code Reviewer: PASS with 2 MINOR recommendations

## Conclusion

v0.3 framework delivered:
- ✅ 49% token reduction (target: 40-50%)
- ✅ 44% time reduction (target: 30-40%)
- ✅ 100% quality coverage (target: 100%)

**Recommendation:** Deploy v0.3 to production workflows
```

---

## References

- Export Tool Guide: `.claude/benchmark/SESSION-EXPORT-GUIDE.md`
- Export Tool Quick Reference: `.claude/benchmark/README-EXPORT-TOOLS.md`
- Benchmark Command: `.claude/commands/benchmark.md`
- v0.3 Roadmap: `.claude/docs/v0.3-realistic-roadmap.md`

---

**Document Version:** 1.0
**Status:** ACTIVE
**Owner:** Claude Code Framework Development Team
