# Session Export Tools - Quick Reference

Complete toolset for exporting and analyzing Claude Code sessions including all sub-agents.

---

## 🎯 What You Get

✅ **Full session export** - Main conversation + all 18 sub-agents from your benchmark
✅ **Human-readable format** - Converts JSONL to Markdown
✅ **Analysis tools** - Scripts to investigate token usage, errors, patterns
✅ **Evidence collection** - Map findings to your CON-01 through CON-11 issues

---

## 📦 Files Created

### Scripts
- `export-full-session.sh` - Export all session data
- `convert-jsonl-to-markdown.sh` - Convert to readable format

### Documentation
- `SESSION-EXPORT-GUIDE.md` - Complete usage guide
- `ANALYSIS-SUMMARY.md` - Analysis templates and commands

---

## ⚡ Quick Start

### 1. Export Your Benchmark Session

```bash
cd ~/rcconsultech/claude-code-setup

./export-full-session.sh task-api-benchmark-v0-2
```

**Output:**
```
./session-exports/YYYYMMDD-HHMMSS/
├── sub-agents/          # 18 agent transcripts (5.9M total)
├── session-index.md     # Overview
└── statistics.txt       # Quick stats
```

### 2. Convert to Readable Format

```bash
./convert-jsonl-to-markdown.sh ./session-exports/[timestamp]
```

**Output:**
```
./session-exports/[timestamp]/readable/
├── agent-00a0149e.md
├── agent-0cbdf933.md
├── ... (18 total)
└── INDEX.md
```

### 3. Analyze Your Session

```bash
cd ./session-exports/[timestamp]

# Find which agent updated CLAUDE.md
grep -l "CLAUDE.md" readable/*.md

# Count tool usage
cat sub-agents/*.jsonl | jq -r 'select(.type=="tool_use") | .name' | sort | uniq -c | sort -rn

# Find errors
grep -i "error" readable/*.md > errors.txt

# Track retries
grep -i "retry" readable/*.md > retries.txt
```

---

## 🔍 What We Found

From your benchmark run:
- **18 sub-agents** executed
- **1,179 operations** total
- **5.9M** of session data
- Top 5 most active agents identified

---

## 📊 Use Cases

### For CON-10 (Token Optimization)
```bash
# Which agents used the most tokens?
cd session-exports/[timestamp]
wc -l sub-agents/*.jsonl | sort -rn | head -6
```

### For CON-01 (CLAUDE.md Updates)
```bash
# Which agent updated CLAUDE.md?
grep -n "CLAUDE.md" readable/*.md
```

### For CON-06 (Task Tracking)
```bash
# Did agents use plans/ directory?
grep -l "current-task\|plans/" readable/*.md
```

### For CON-11 (Code Rework)
```bash
# Find code deletion patterns
grep -i "delete.*\.ts\|remove.*\.js" readable/*.md
```

---

## 📍 Where Your Data Lives

Claude Code stores sub-agent transcripts in:
```
~/.claude/projects/-Users-gabrielramos-rcconsultech-[project-name]/
└── agent-{agentId}.jsonl
```

Each agent gets a unique ID like `agent-00a0149e`.

---

## 🚀 Next Steps

1. **Export** your benchmark session (if not done)
2. **Convert** to readable Markdown
3. **Analyze** using the templates in ANALYSIS-SUMMARY.md
4. **Document** findings in benchmark-learnings.md
5. **Update** v0.3-roadmap.md with evidence

---

## 📚 Full Documentation

- **SESSION-EXPORT-GUIDE.md** - Complete guide with all commands
- **benchmark-learnings.md** - Your CON-01 through CON-11 issues
- **v0.3-roadmap.md** - Framework improvement plan

---

## 💡 Pro Tips

1. **Export immediately** after benchmarks - data may be cleaned up
2. **Version your exports** - Compare v0.2 vs v0.3 runs
3. **Keep raw JSONL** - Don't delete after converting
4. **Automate analysis** - Create scripts for common investigations

---

## ❓ Common Questions

**Q: Can I export the main conversation too?**
A: The `/export` command (if available in your Claude Code version) exports main conversation. These scripts export sub-agents which are stored separately.

**Q: How do I know which agent did what?**
A: Read the first few lines of each transcript. The agent's task/role is usually in the initial prompt.

**Q: Can I resume a sub-agent?**
A: Yes! Use the agent ID: `Resume agent {agentId} and continue...`

**Q: What if I can't find my project?**
A: List available projects:
```bash
ls ~/.claude/projects/
```

---

**Created:** 2025-12-06
**For:** Claude Code Framework v0.2 Benchmark Analysis
**Status:** Ready to use ✅
