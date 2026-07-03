# Architecture

ADE means Agent Development Environment.

It is an opinionated, reproducible engineering environment for AI-agent-based development.

## Reference stack

- Ubuntu LTS
- Python + uv
- Node.js LTS + pnpm
- Git + GitHub CLI
- MCP-ready configuration layout
- Hermes as planner/orchestrator
- OpenCode as coding agent
- Cloud LLM providers

## Responsibility split

Hermes plans, selects tools, orchestrates work, and checks results.

OpenCode performs code-oriented changes.

GitHub stores code, issues, and project memory repositories.
