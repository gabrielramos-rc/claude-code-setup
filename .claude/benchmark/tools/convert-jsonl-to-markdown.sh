#!/bin/bash

# Convert JSONL Agent Transcripts to Human-Readable Markdown
# Usage: ./convert-jsonl-to-markdown.sh [session-export-directory]

set -e

# Configuration
EXPORT_DIR="${1:-.}"
OUTPUT_DIR="$EXPORT_DIR/readable"

echo "========================================="
echo "JSONL to Markdown Converter"
echo "========================================="
echo "Input: $EXPORT_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to convert a single JSONL file
convert_agent() {
    local jsonl_file="$1"
    local agent_id=$(basename "$jsonl_file" .jsonl)
    local md_file="$OUTPUT_DIR/$agent_id.md"

    echo "Converting $agent_id..."

    # Header
    cat > "$md_file" << EOF
# Agent Transcript: $agent_id

**Converted:** $(date '+%Y-%m-%d %H:%M:%S')

---

EOF

    # Process each line of JSONL
    local turn=1
    while IFS= read -r line; do
        # Skip empty lines to prevent jq parse errors
        [ -z "$line" ] && continue

        # Extract fields using jq
        local type=$(echo "$line" | jq -r '.type // "unknown"')
        local role=$(echo "$line" | jq -r '.role // ""')
        local content=$(echo "$line" | jq -r '.content // ""')

        case "$type" in
            "user"|"human")
                echo "## Turn $turn - User" >> "$md_file"
                echo "" >> "$md_file"
                echo "$content" >> "$md_file"
                echo "" >> "$md_file"
                echo "---" >> "$md_file"
                echo "" >> "$md_file"
                turn=$((turn + 1))
                ;;

            "assistant"|"ai")
                echo "## Turn $turn - Assistant" >> "$md_file"
                echo "" >> "$md_file"
                echo "$content" >> "$md_file"
                echo "" >> "$md_file"

                # Check for tool uses
                local tool_uses=$(echo "$line" | jq -r '.tool_uses // [] | length')
                if [ "$tool_uses" -gt 0 ]; then
                    echo "### Tool Uses:" >> "$md_file"
                    echo "" >> "$md_file"
                    echo "$line" | jq -r '.tool_uses[] | "- **\(.name)**: \(.input | @json)"' >> "$md_file"
                    echo "" >> "$md_file"
                fi

                echo "---" >> "$md_file"
                echo "" >> "$md_file"
                turn=$((turn + 1))
                ;;

            "tool_use")
                echo "### Tool Use: $(echo "$line" | jq -r '.name // "unknown"')" >> "$md_file"
                echo "" >> "$md_file"
                echo '```json' >> "$md_file"
                echo "$line" | jq -r '.input // {}' | jq '.' >> "$md_file"
                echo '```' >> "$md_file"
                echo "" >> "$md_file"
                ;;

            "tool_result")
                echo "### Tool Result" >> "$md_file"
                echo "" >> "$md_file"
                echo '```' >> "$md_file"
                echo "$content" | head -100 >> "$md_file"  # Limit output
                if [ $(echo "$content" | wc -l) -gt 100 ]; then
                    echo "..." >> "$md_file"
                    echo "[Output truncated - $(echo "$content" | wc -l) lines total]" >> "$md_file"
                fi
                echo '```' >> "$md_file"
                echo "" >> "$md_file"
                ;;

            *)
                # Unknown type, include as-is
                echo "### Unknown Type: $type" >> "$md_file"
                echo "" >> "$md_file"
                echo '```json' >> "$md_file"
                echo "$line" | jq '.' >> "$md_file"
                echo '```' >> "$md_file"
                echo "" >> "$md_file"
                ;;
        esac

    done < "$jsonl_file"

    echo "   ✅ $agent_id.md"
}

# Convert main session
if [ -f "$EXPORT_DIR/main-session.jsonl" ]; then
    echo "📝 Converting main session..."
    convert_agent "$EXPORT_DIR/main-session.jsonl"
fi

# Convert all sub-agents
echo ""
echo "🤖 Converting sub-agent transcripts..."

if [ -d "$EXPORT_DIR/sub-agents" ]; then
    find "$EXPORT_DIR/sub-agents" -name "agent-*.jsonl" -type f | sort | while read -r agent_file; do
        convert_agent "$agent_file"
    done
fi

# Create index
cat > "$OUTPUT_DIR/INDEX.md" << EOF
# Readable Transcripts Index

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

---

## Main Session

$([ -f "$OUTPUT_DIR/main-session.md" ] && echo "- [main-session.md](main-session.md)" || echo "*No main session found*")

---

## Sub-Agent Transcripts

EOF

find "$OUTPUT_DIR" -name "agent-*.md" -type f | sort | while read -r file; do
    agent_id=$(basename "$file" .md)
    lines=$(wc -l < "$file" | tr -d ' ')
    echo "- [$agent_id.md]($agent_id.md) - $lines lines" >> "$OUTPUT_DIR/INDEX.md"
done

echo ""
echo "========================================="
echo "✅ Conversion Complete!"
echo "========================================="
echo "Location: $OUTPUT_DIR"
echo "Index: $OUTPUT_DIR/INDEX.md"
echo ""
echo "Open with:"
echo "  open $OUTPUT_DIR/INDEX.md"
echo ""
