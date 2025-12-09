# Workflow Log

> Append-only log of protocol loading decisions for debugging and audit

---

## Usage

Agents append entries after selecting protocols. Never overwrite previous entries.

**Format:**
```markdown
### {ISO Timestamp} - {Agent Name}

**Task:** {brief task description}
**Protocols Loaded:**
- `{protocol}.md` - {reason for loading}

**Protocols Skipped:**
- `{protocol}.md` - {reason for skipping}
```

---

## Log Entries

<!-- Agents: Append new entries below this line -->

