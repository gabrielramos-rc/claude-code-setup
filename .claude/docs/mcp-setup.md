# MCP Server Setup Guide

This guide explains how to configure and authenticate MCP (Model Context Protocol) servers for the Claude Code Framework.

## Overview

MCP servers extend Claude Code's capabilities by connecting to external tools and services. This framework includes configurations for:

| Server | Purpose | Agent Benefit |
|--------|---------|---------------|
| **GitHub** | PR reviews, issues, code management | Code Reviewer, DevOps |
| **PostgreSQL** | Database queries, schema inspection | Engineer, Architect |
| **Sentry** | Error monitoring, debugging | Security Auditor, Tester |
| **Linear** | Issue tracking, project management | Product Manager |

## Configuration File

MCP servers are configured in `.mcp.json` at the project root:

```json
{
  "mcpServers": {
    "github": { ... },
    "postgres": { ... },
    "sentry": { ... },
    "linear": { ... }
  }
}
```

---

## GitHub Setup

### Authentication

1. Start Claude Code
2. Run `/mcp` to see available servers
3. Select "github" and click "Authenticate"
4. Follow the OAuth flow in your browser
5. Authorize Claude Code to access your GitHub account

### Usage Examples

```
> Review PR #123 for security issues
> Create an issue for the authentication bug
> List open PRs assigned to me
> Get the diff for PR #456
```

### Useful Commands

```bash
# Check authentication status
gh auth status

# Manual authentication (if needed)
gh auth login
```

---

## PostgreSQL Setup

### Prerequisites

1. Set your database connection string:
   ```bash
   export DATABASE_URL="postgresql://user:password@host:5432/database"
   ```

2. Or add to `.claude/settings.local.json`:
   ```json
   {
     "env": {
       "DATABASE_URL": "postgresql://user:password@host:5432/database"
     }
   }
   ```

### Security Warning

**Never commit database credentials!**
- Use environment variables
- Add `.claude/settings.local.json` to `.gitignore`
- Use read-only credentials when possible

### Usage Examples

```
> Show me the schema for the users table
> Find customers who haven't ordered in 90 days
> What indexes exist on the orders table?
> Run: SELECT COUNT(*) FROM users WHERE created_at > '2024-01-01'
```

### Useful Queries

```sql
-- List all tables
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check indexes
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';
```

---

## Sentry Setup

### Authentication

1. Start Claude Code
2. Run `/mcp` to see available servers
3. Select "sentry" and click "Authenticate"
4. Log in to your Sentry account
5. Authorize Claude Code

### Usage Examples

```
> What are the most common errors in the last 24 hours?
> Show me details for issue FRONTEND-123
> List unresolved errors in the auth module
> What's the error rate trend this week?
```

### Configuration Options

You can specify a default project:
```json
{
  "mcpServers": {
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.dev/mcp",
      "headers": {
        "X-Sentry-Project": "your-project-slug"
      }
    }
  }
}
```

---

## Linear Setup

### Authentication

1. Start Claude Code
2. Run `/mcp` to see available servers
3. Select "linear" and click "Authenticate"
4. Log in to your Linear workspace
5. Authorize Claude Code

### Usage Examples

```
> Show my assigned issues
> Create an issue for the login bug in the Auth team
> What issues are in the current sprint?
> Update issue AUTH-123 status to "In Progress"
```

### Configuration

Linear uses SSE transport. If you need API key authentication:
```json
{
  "mcpServers": {
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/sse",
      "headers": {
        "Authorization": "Bearer ${LINEAR_API_KEY}"
      }
    }
  }
}
```

---

## Managing MCP Servers

### List All Servers

```bash
claude mcp list
```

### Check Server Status

```bash
claude mcp get github
```

### Add a New Server

```bash
# HTTP server
claude mcp add --transport http myserver https://api.example.com/mcp

# Stdio server
claude mcp add --transport stdio myserver -- npx -y @some/package
```

### Remove a Server

```bash
claude mcp remove github
```

### Reset Authentication

```bash
claude mcp reset-project-choices
```

---

## Troubleshooting

### Server Not Connecting

1. Check the server is listed: `claude mcp list`
2. Verify authentication: Run `/mcp` in Claude Code
3. Check network connectivity
4. Review error messages in verbose mode (Ctrl+O)

### Authentication Expired

1. Run `/mcp` in Claude Code
2. Select the server
3. Click "Re-authenticate"

### Database Connection Failed

1. Verify `DATABASE_URL` is set correctly
2. Check network access to database
3. Ensure credentials are valid
4. Test connection manually:
   ```bash
   psql $DATABASE_URL -c "SELECT 1"
   ```

### Rate Limiting

MCP servers may have rate limits. If you hit limits:
- Wait before retrying
- Reduce query frequency
- Check server documentation for limits

---

## Security Best Practices

1. **Never commit credentials** - Use environment variables
2. **Use read-only access** - Where possible, use read-only database users
3. **Audit server access** - Review what each server can access
4. **Rotate credentials** - Regularly rotate API keys and passwords
5. **Review permissions** - Only grant necessary permissions

---

## Environment Variables

Set these in your shell or `.claude/settings.local.json`:

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `LINEAR_API_KEY` | Linear API key (optional) |
| `GITHUB_TOKEN` | GitHub personal access token (optional) |
| `SENTRY_AUTH_TOKEN` | Sentry auth token (optional) |

---

## Integration with Framework

### Agent-MCP Mapping

| Agent | Primary MCP | Use Case |
|-------|-------------|----------|
| Code Reviewer | GitHub | PR reviews, diffs |
| Engineer | PostgreSQL | Schema queries, data inspection |
| Security Auditor | Sentry | Error analysis, vulnerability context |
| Product Manager | Linear | Issue tracking, sprint planning |
| DevOps | GitHub | Deployment workflows, release management |

### Command-MCP Mapping

| Command | MCP Integration |
|---------|-----------------|
| `/project:pr-review` | GitHub for PR data |
| `/project:debug` | Sentry for error context |
| `/project:security` | Sentry for vulnerability analysis |

---

## Adding Custom MCP Servers

To add project-specific servers, edit `.mcp.json`:

```json
{
  "mcpServers": {
    "custom-api": {
      "type": "http",
      "url": "https://your-api.com/mcp",
      "headers": {
        "Authorization": "Bearer ${CUSTOM_API_KEY}"
      }
    }
  }
}
```

For team sharing, commit `.mcp.json` (without secrets).
For personal servers, use `claude mcp add --scope local`.

---

*Part of Claude Code Framework v0.3*
