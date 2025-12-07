# Claude Code Session Export

**Project:** task-api-benchmark-v0-2
**Export Date:** 2025-12-06 19:48:45
**Total Sub-Agents:** 18

---

## Session Structure

```
./session-exports/20251206-194845/
├── main-session.jsonl          # Main conversation
├── sub-agents/                 # Sub-agent transcripts
│   ├── agent-00a0149e.jsonl
│   ├── agent-10228ab9.jsonl
│   └── ... (18 total)
└── session-index.md            # This file
```

---

## Sub-Agent Transcripts

- `agent-00a0149e` - 1.4K, 1 lines
- `agent-0cbdf933` - 76K, 10 lines
- `agent-10228ab9` - 280K, 16 lines
- `agent-2cd490d2` - 310K, 42 lines
- `agent-32551ac2` - 142K, 27 lines
- `agent-4a328c96` - 534K, 238 lines
- `agent-4ed9b522` - 210K, 59 lines
- `agent-58e69205` - 453K, 123 lines
- `agent-5cd86443` - 100K, 13 lines
- `agent-61a9e7db` - 430K, 29 lines
- `agent-6633a783` - 785K, 196 lines
- `agent-73c2f256` - 219K, 13 lines
- `agent-8495e060` - 344K, 33 lines
- `agent-95ed9ff0` - 635K, 124 lines
- `agent-af41e798` - 344K, 33 lines
- `agent-c42525e1` - 1.8K, 1 lines
- `agent-ea8397c8` - 436K, 45 lines
- `agent-f1bdb977` - 658K, 176 lines

---

## How to Analyze

### View a sub-agent transcript:
```bash
cat sub-agents/agent-{id}.jsonl | jq '.'
```

### Extract all user messages:
```bash
cat sub-agents/agent-*.jsonl | jq -r 'select(.type=="user") | .content'
```

### Extract all assistant responses:
```bash
cat sub-agents/agent-*.jsonl | jq -r 'select(.type=="assistant") | .content'
```

### Count tool uses per agent:
```bash
for file in sub-agents/*.jsonl; do
    echo "$(basename $file): $(grep -c '"type":"tool_use"' $file || echo 0)"
done
```

### Search for specific content:
```bash
grep -r "search term" sub-agents/
```

---

## Converting to Human-Readable Format

Run the conversion script:
```bash
./convert-jsonl-to-markdown.sh "./session-exports/20251206-194845"
```

This will create readable Markdown files for each agent transcript.
