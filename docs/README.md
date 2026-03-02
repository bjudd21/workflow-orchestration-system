# Documentation Index

## MCP Integration
See [mcp-integration.md](./mcp-integration.md) for:
- Configured MCP servers (GitHub, Docker, Filesystem)
- n8n API access patterns
- Troubleshooting MCP connections

## Quick n8n API Reference

**First**: Generate API key at http://localhost:5678 → Settings → API

```bash
# List workflows
curl -H "X-N8N-API-KEY: YOUR_KEY" http://localhost:5678/api/v1/workflows

# Execute workflow
curl -H "X-N8N-API-KEY: YOUR_KEY" -X POST \
  http://localhost:5678/api/v1/workflows/{id}/execute

# Check execution status
curl -H "X-N8N-API-KEY: YOUR_KEY" \
  http://localhost:5678/api/v1/executions/{id}
```

## Directory Structure

- `prompts/` - Agent system prompts by phase
- `skills/` - Knowledge documents for agents
- `workflows/` - Exported n8n workflow JSON files
- `contracts/` - Handoff validation schemas
- `workspace/` - Runtime artifacts (gitignored, managed by Filesystem MCP)
