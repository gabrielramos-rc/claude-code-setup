# Session Export Guide

Complete guide to exporting and analyzing full Claude Code sessions including all sub-agents.

---

## 🔍 What We Discovered

Your sub-agent transcripts are stored in:
```
~/.claude/projects/-Users-gabrielramos-rcconsultech-[project-name]/
```

**Your benchmark run created 17+ sub-agent transcripts!**

Each file is named: `agent-{agentId}.jsonl`

---

## 📦 Export Scripts Created

### 1. `export-full-session.sh`
Exports main session + all sub-agent transcripts

### 2. `convert-jsonl-to-markdown.sh`
Converts JSONL to human-readable Markdown

---

## 🚀 Quick Start

### Export Your Benchmark Session:

```bash
cd ~/rcconsultech/claude-code-setup

# Export the benchmark session
./export-full-session.sh task-api-benchmark-v0-2

# This creates:
# ./session-exports/YYYYMMDD-HHMMSS/
#   ├── main-session.jsonl
#   ├── sub-agents/
#   │   ├── agent-00a0149e.jsonl
#   │   ├── agent-10228ab9.jsonl
#   │   └── ... (all 17+ agents)
#   ├── session-index.md
#   └── statistics.txt
```

### Convert to Readable Format:

```bash
# Convert all JSONL to Markdown
./convert-jsonl-to-markdown.sh ./session-exports/[timestamp]

# This creates:
# ./session-exports/[timestamp]/readable/
#   ├── INDEX.md
#   ├── main-session.md
#   ├── agent-00a0149e.md
#   └── ... (all agents in readable format)
```

### View the Results:

```bash
# Open the index
open ./session-exports/[timestamp]/readable/INDEX.md

# Or view a specific agent
cat ./session-exports/[timestamp]/readable/agent-00a0149e.md
```

---

## 📊 Analysis Examples

### 1. Find Which Agent Did What

```bash
cd session-exports/[timestamp]/readable

# Search for specific actions
grep -l "architect" *.md          # Which agents mentioned architecture?
grep -l "PostgreSQL" *.md          # Which agents chose PostgreSQL?
grep -l "docker" *.md              # Which agents handled Docker?
```

### 2. Count Tool Usage

```bash
cd session-exports/[timestamp]/sub-agents

# Count Read operations per agent
for file in agent-*.jsonl; do
    echo "$(basename $file): $(grep -c '"name":"Read"' $file || echo 0) reads"
done | sort -t: -k2 -rn

# Count all tool uses
grep -h '"type":"tool_use"' *.jsonl | jq -r '.name' | sort | uniq -c | sort -rn
```

### 3. Extract All Error Messages

```bash
cd session-exports/[timestamp]/sub-agents

# Find all error mentions
grep -i "error" *.jsonl | jq -r '.content' > all-errors.txt
```

### 4. Track Retry Attempts

```bash
# Search for retry patterns
grep -i "retry\|attempt" readable/*.md

# Count retries per agent
grep -c "retry" readable/*.md | grep -v ":0$"
```

### 5. Identify Which Agents Hit Token Limits

```bash
# Look for token-related messages
grep -i "token\|limit\|quota" sub-agents/*.jsonl
```

---

## 🔧 Advanced Usage

### Export Different Projects

```bash
# List available projects
ls ~/.claude/projects/

# Export specific project
./export-full-session.sh claude-code-setup ./my-exports

# Export with custom output directory
./export-full-session.sh task-api-benchmark-v0-2 ./benchmark-analysis-$(date +%Y%m%d)
```

### Automated Analysis Pipeline

```bash
#!/bin/bash
# Full analysis pipeline

PROJECT="task-api-benchmark-v0-2"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPORT_DIR="./session-exports/$TIMESTAMP"

# 1. Export
./export-full-session.sh "$PROJECT" "$EXPORT_DIR"

# 2. Convert to readable
./convert-jsonl-to-markdown.sh "$EXPORT_DIR"

# 3. Generate analysis report
cat > "$EXPORT_DIR/analysis-report.md" << EOF
# Session Analysis Report

## Statistics
$(cat "$EXPORT_DIR/statistics.txt")

## Tool Usage
$(cd "$EXPORT_DIR/sub-agents" && grep -h '"type":"tool_use"' *.jsonl | jq -r '.name' | sort | uniq -c | sort -rn)

## Agents Involved
$(ls "$EXPORT_DIR/sub-agents" | wc -l) sub-agents

## Top File Operations
Read: $(grep -c '"name":"Read"' "$EXPORT_DIR/sub-agents"/*.jsonl | awk -F: '{sum+=$2} END {print sum}')
Write: $(grep -c '"name":"Write"' "$EXPORT_DIR/sub-agents"/*.jsonl | awk -F: '{sum+=$2} END {print sum}')
Edit: $(grep -c '"name":"Edit"' "$EXPORT_DIR/sub-agents"/*.jsonl | awk -F: '{sum+=$2} END {print sum}')
EOF

echo "Analysis complete: $EXPORT_DIR/analysis-report.md"
```

---

## 📋 What to Look For in Your Benchmark

Based on your considerations (CON-01 through CON-11), analyze:

### CON-01: CLAUDE.md Updates
```bash
grep -i "CLAUDE.md" readable/*.md
# Which agent updated it? When?
```

### CON-06: Task Tracking Usage
```bash
grep -i "current-task.md\|plans/" readable/*.md
# Did any agent use the plans directory?
```

### CON-07: Git Operations
```bash
grep -i "git commit\|git add" readable/*.md
# Which agents used git? What were the commit messages?
```

### CON-10: Token Consumption
```bash
# Count total operations per agent
for file in sub-agents/*.jsonl; do
    lines=$(wc -l < "$file")
    echo "$(basename $file): $lines operations"
done | sort -t: -k2 -rn
```

### CON-11: Code Rework
```bash
# Find deletion patterns
grep -i "delete\|remove\|clear" readable/*.md | grep -i "\.ts\|\.js"

# Find which agents created files
grep '"name":"Write"' sub-agents/*.jsonl | jq -r '.input.file_path' | sort | uniq
```

---

## 🎯 Quick Commands Reference

```bash
# Export
./export-full-session.sh [project-name] [output-dir]

# Convert
./convert-jsonl-to-markdown.sh [export-dir]

# Find agent by ID (when you have the agent ID)
cat ~/.claude/projects/-Users-gabrielramos-rcconsultech-*/agent-{id}.jsonl | jq '.'

# List all recent agent sessions
find ~/.claude/projects -name "agent-*.jsonl" -mtime -1

# Export all recent projects at once
for project in ~/.claude/projects/-Users-gabrielramos-rcconsultech-*/; do
    project_name=$(basename "$project" | sed 's/-Users-gabrielramos-rcconsultech-//')
    echo "Exporting: $project_name"
    ./export-full-session.sh "$project_name" "./all-exports/$project_name"
done
```

---

## 🐛 Troubleshooting

### "Project directory not found"
```bash
# List available projects
ls ~/.claude/projects/

# Use exact directory name from list
./export-full-session.sh [exact-name]
```

### "No such file or directory"
```bash
# Check if .claude directory exists
ls -la ~/.claude/projects/

# If not, Claude Code may store data elsewhere
# Check: ~/Library/Application Support/Claude/
```

### "Permission denied"
```bash
# Make scripts executable
chmod +x export-full-session.sh convert-jsonl-to-markdown.sh
```

### "jq: command not found"
```bash
# Install jq for JSON parsing
brew install jq
```

---

## 📚 Understanding JSONL Format

Each line in a `.jsonl` file is a complete JSON object:

```json
{"type":"user","content":"Implement authentication","timestamp":"2025-12-06T12:00:00Z"}
{"type":"assistant","content":"I'll implement JWT auth...","timestamp":"2025-12-06T12:00:15Z"}
{"type":"tool_use","name":"Write","input":{"file_path":"auth.ts","content":"..."}}
{"type":"tool_result","content":"File written successfully"}
```

**Fields:**
- `type`: Message type (user, assistant, tool_use, tool_result)
- `content`: Message content
- `timestamp`: When it occurred
- `name`: Tool name (for tool_use)
- `input`: Tool parameters (for tool_use)

---

## 🎓 Best Practices

1. **Export immediately after benchmark** - Don't wait, data may be cleaned up

2. **Version your exports** - Use timestamps or version numbers
   ```bash
   ./export-full-session.sh myproject ./exports/v0.2-run1
   ./export-full-session.sh myproject ./exports/v0.2-run2
   ```

3. **Keep raw JSONL** - Don't delete after converting to Markdown

4. **Document your findings** - Create analysis notes
   ```bash
   echo "CON-10: Agent XYZ used 500 Read operations" >> findings.txt
   ```

5. **Compare runs** - Export multiple benchmark runs and diff them
   ```bash
   diff exports/v0.2-run1/statistics.txt exports/v0.3-run1/statistics.txt
   ```

---

## 🔮 Next Steps

After exporting and analyzing:

1. **Update benchmark-learnings.md** with specific evidence
2. **Quantify issues** (e.g., "Agent A did 200 redundant reads")
3. **Identify patterns** across sub-agents
4. **Document in v0.3-roadmap.md** with data-driven priorities
5. **Create test scenarios** based on actual session behavior

---

## 📞 Need Help?

If you find interesting patterns or issues in your session data, document them:

```bash
# Create investigation notes
mkdir -p session-exports/investigations
echo "# CON-XX: [Issue Name]" > session-exports/investigations/CON-XX.md
echo "## Evidence from Agent ID: [agent-id]" >> session-exports/investigations/CON-XX.md
cat readable/agent-[id].md >> session-exports/investigations/CON-XX.md
```

---

**Created:** 2025-12-06
**For:** Claude Code Framework Benchmark Analysis
**Version:** 1.0
