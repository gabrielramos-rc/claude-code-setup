# Benchmark Baseline: v0.3

**Created:** 2025-12-07
**Version:** v0.3 (Token Optimization)

---

## Expected Performance

| Scenario | Time (typical) | Time (max) | Success Rate |
|----------|----------------|------------|--------------|
| implement-feature | 3-5 min | 10 min | >90% |
| fix-bug | 2-3 min | 5 min | >95% |
| test-coverage | 1-2 min | 4 min | >95% |

---

## v0.3 Improvements Over v0.2

| Metric | v0.2 | v0.3 | Improvement |
|--------|------|------|-------------|
| Redundant spec reads | ~28 per workflow | 1 per workflow | -96% |
| File discovery commands | ~60 per workflow | 1 per workflow | -98% |
| Parallel validation | No | Yes | 50% time saved |
| Tree injection | All agents | Only 2 agents | -60% tokens |

---

## Baseline Scenarios

### implement-feature

**Test:** `/project:implement add user authentication`

Expected flow:
1. Context loading (Step 0)
2. Engineer implementation (Step 1)
3. Parallel validation - Tester + Security + Reviewer (Step 2)
4. Documentation (Step 3)
5. Human gate (Step 4)

**Baseline metrics:**
- Time: 4 min
- Agent invocations: 5
- Retries: 0

---

### fix-bug

**Test:** `/project:fix TypeError in user service line 42`

Expected flow:
1. Context loading (Step 0)
2. Engineer diagnosis + fix (Step 1)
3. Parallel validation - Tester + Reviewer (Step 2)
4. Complete (Step 3)

**Baseline metrics:**
- Time: 2.5 min
- Agent invocations: 3
- Retries: 0

---

### test-coverage

**Test:** `/project:test unit auth`

Expected flow:
1. Context loading (Step 0)
2. Tester creates/runs tests (Step 1)
3. Code Reviewer reviews test quality (Step 2)

**Baseline metrics:**
- Time: 1.5 min
- Agent invocations: 2
- Retries: 0

---

## Regression Thresholds

| Metric | Warning | Failure |
|--------|---------|---------|
| Time | >25% increase | >50% increase |
| Success rate | <90% | <80% |
| Retries | >1 average | >2 average |

---

## How to Run Benchmarks

1. Copy `results/TEMPLATE.md` to `results/YYYY-MM-DD.md`
2. Run each scenario manually
3. Record metrics in the results file
4. Compare against this baseline
5. Note any regressions

---

## Notes

- Metrics are approximate (no automated collection yet)
- Time includes human review pauses
- Success = workflow completes without manual intervention
