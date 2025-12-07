#!/bin/bash

# Export Full Claude Code Session (Main + Sub-Agents)
# Usage: ./export-full-session.sh [project-name] [output-directory]

set -e

# Configuration
PROJECT_NAME="${1:-task-api-benchmark-v0-2}"
OUTPUT_DIR="${2:-./session-exports/$(date +%Y%m%d-%H%M%S)}"
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

# Sanitize project name for directory lookup
SANITIZED_PROJECT=$(echo "$PROJECT_NAME" | sed 's|/|-|g')
PROJECT_DIR="$CLAUDE_PROJECTS_DIR/-Users-gabrielramos-rcconsultech-$SANITIZED_PROJECT"

echo "========================================="
echo "Claude Code Full Session Export"
echo "========================================="
echo "Project: $PROJECT_NAME"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/sub-agents"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Error: Project directory not found"
    echo "   Expected: $PROJECT_DIR"
    echo ""
    echo "Available projects:"
    ls -1 "$CLAUDE_PROJECTS_DIR" | grep "^-Users-gabrielramos"
    exit 1
fi

# Count sub-agent files
AGENT_COUNT=$(find "$PROJECT_DIR" -name "agent-*.jsonl" -type f | wc -l | tr -d ' ')

echo "📊 Found $AGENT_COUNT sub-agent transcripts"
echo ""

# Export main session (if exists)
if [ -f "$PROJECT_DIR/session.jsonl" ]; then
    echo "📝 Exporting main session..."
    cp "$PROJECT_DIR/session.jsonl" "$OUTPUT_DIR/main-session.jsonl"
    echo "   ✅ main-session.jsonl"
else
    echo "⚠️  No main session file found"
fi

# Export all sub-agent transcripts
echo ""
echo "🤖 Exporting sub-agent transcripts..."

COUNTER=1
find "$PROJECT_DIR" -name "agent-*.jsonl" -type f | sort | while read -r agent_file; do
    agent_id=$(basename "$agent_file" .jsonl)
    cp "$agent_file" "$OUTPUT_DIR/sub-agents/$agent_id.jsonl"
    printf "   [%2d/%2d] %s\n" $COUNTER $AGENT_COUNT "$agent_id"
    COUNTER=$((COUNTER + 1))
done

# Create index file
echo ""
echo "📋 Creating session index..."

cat > "$OUTPUT_DIR/session-index.md" << EOF
# Claude Code Session Export

**Project:** $PROJECT_NAME
**Export Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Total Sub-Agents:** $AGENT_COUNT

---

## Session Structure

\`\`\`
$OUTPUT_DIR/
├── main-session.jsonl          # Main conversation
├── sub-agents/                 # Sub-agent transcripts
│   ├── agent-00a0149e.jsonl
│   ├── agent-10228ab9.jsonl
│   └── ... ($AGENT_COUNT total)
└── session-index.md            # This file
\`\`\`

---

## Sub-Agent Transcripts

EOF

# List all sub-agents with file sizes
find "$OUTPUT_DIR/sub-agents" -name "agent-*.jsonl" -type f | sort | while read -r file; do
    agent_id=$(basename "$file" .jsonl)
    size=$(ls -lh "$file" | awk '{print $5}')
    lines=$(wc -l < "$file" | tr -d ' ')
    echo "- \`$agent_id\` - $size, $lines lines" >> "$OUTPUT_DIR/session-index.md"
done

cat >> "$OUTPUT_DIR/session-index.md" << EOF

---

## How to Analyze

### View a sub-agent transcript:
\`\`\`bash
cat sub-agents/agent-{id}.jsonl | jq '.'
\`\`\`

### Extract all user messages:
\`\`\`bash
cat sub-agents/agent-*.jsonl | jq -r 'select(.type=="user") | .content'
\`\`\`

### Extract all assistant responses:
\`\`\`bash
cat sub-agents/agent-*.jsonl | jq -r 'select(.type=="assistant") | .content'
\`\`\`

### Count tool uses per agent:
\`\`\`bash
for file in sub-agents/*.jsonl; do
    echo "\$(basename \$file): \$(grep -c '"type":"tool_use"' \$file || echo 0)"
done
\`\`\`

### Search for specific content:
\`\`\`bash
grep -r "search term" sub-agents/
\`\`\`

---

## Converting to Human-Readable Format

Run the conversion script:
\`\`\`bash
./convert-jsonl-to-markdown.sh "$OUTPUT_DIR"
\`\`\`

This will create readable Markdown files for each agent transcript.
EOF

echo "   ✅ session-index.md"

# Create summary statistics
echo ""
echo "📈 Generating statistics..."

TOTAL_SIZE=$(du -sh "$OUTPUT_DIR" | awk '{print $1}')
TOTAL_LINES=$(find "$OUTPUT_DIR/sub-agents" -name "*.jsonl" -exec wc -l {} + | tail -1 | awk '{print $1}')

cat > "$OUTPUT_DIR/statistics.txt" << EOF
Session Export Statistics
========================

Project: $PROJECT_NAME
Export Date: $(date '+%Y-%m-%d %H:%M:%S')

Files:
- Main session: $([ -f "$OUTPUT_DIR/main-session.jsonl" ] && echo "Yes" || echo "No")
- Sub-agents: $AGENT_COUNT transcripts

Data:
- Total size: $TOTAL_SIZE
- Total lines: $TOTAL_LINES JSONL records

Top 5 Largest Sub-Agents:
EOF

find "$OUTPUT_DIR/sub-agents" -name "*.jsonl" -exec ls -lh {} \; | \
    awk '{print $5 "\t" $9}' | \
    sort -rh | \
    head -5 | \
    sed 's|.*/||' >> "$OUTPUT_DIR/statistics.txt"

echo "   ✅ statistics.txt"

# Success message
echo ""
echo "========================================="
echo "✅ Export Complete!"
echo "========================================="
echo "Location: $OUTPUT_DIR"
echo "Files exported: $AGENT_COUNT sub-agents"
echo "Total size: $TOTAL_SIZE"
echo ""
echo "Next steps:"
echo "1. Review: cat $OUTPUT_DIR/session-index.md"
echo "2. Convert: ./convert-jsonl-to-markdown.sh $OUTPUT_DIR"
echo "3. Analyze: Explore sub-agents/ directory"
echo ""
