# ADE

**Agent Development Environment**

ADE is an opinionated, reproducible VPS development environment for AI-agent-based engineering.

It is intended to become a ready-to-use reference environment for agentic development on a fresh Ubuntu server.

## Goals

- bootstrap a new VPS with one command;
- keep the environment reproducible;
- avoid manual snowflake configuration;
- avoid local LLMs by default;
- use cloud model providers;
- use Hermes as the required planner/orchestrator;
- use OpenCode as the required coding agent;
- use GitHub as the source of truth for code and project memory.

## Reference stack

- Ubuntu Server 24.04
- Python + uv
- Node.js LTS + pnpm
- Git + GitHub CLI
- MCP-ready configuration layout
- Hermes
- OpenCode
- OpenAI / OpenRouter or compatible cloud model providers

## Manifest and engine

The reference environment is declared in:

```text
ade.yaml
```

ADE Engine resolves the component graph and executes the manifest:

```bash
bash ./bin/ade plan
sudo bash ./bin/ade apply
bash ./bin/ade doctor
```

`bootstrap.sh` is a thin wrapper around:

```bash
./engine/ade-engine apply ./ade.yaml
```

## Component model

ADE components declare installers and dependencies:

```yaml
components:
  hermes:
    installer: scripts/install-hermes.sh
    depends_on:
      - base
      - python
      - github
```

The engine resolves this graph before running installers.

## Architecture

```text
User
  |
  |-- Cherry Studio
  |-- VS Code
  |-- SSH
  |
  v
Ubuntu VPS
  |
  v
Hermes (planner / orchestrator)
  |
  v
OpenCode (coder)
  |
  v
Git / GitHub / MCP
  |
  |-- project-memory   # placeholder repository
  |-- project-core     # placeholder repository
```

Hermes is responsible for task understanding, planning, tool selection, invoking OpenCode, and checking results.

OpenCode is responsible for code-oriented implementation work.

## Minimum VPS

- Ubuntu Server 24.04
- 1 CPU
- 3 GB RAM
- 20 GB SSD

## Usage

Clone and run locally on a fresh VPS:

```bash
git clone https://github.com/tarnol-veer/vps-dev-env.git
cd vps-dev-env
sudo bash ./bootstrap.sh
```

Inspect the install plan:

```bash
bash ./bin/ade plan
```

Run doctor:

```bash
bash ./bin/ade doctor
```

Run healthcheck:

```bash
bash ./scripts/healthcheck.sh
```

## Configuration

Copy the example environment file and fill it locally:

```bash
cp configs/vps.env.example configs/vps.env
```

`configs/vps.env` must never be committed.

## Principles

### Opinionated stack

ADE ships a predefined stack instead of pretending to support every possible tool. The supported baseline is Hermes + OpenCode.

### No secrets

Only `.env.example` files belong in the repository. API keys, tokens, SSH private keys, and personal configuration stay local.

### Idempotency

Running the bootstrap repeatedly should not break the machine.

```bash
sudo bash ./bootstrap.sh
```

### Repository as source of truth

If the environment changes, the change should be reflected here.

### Minimal dependencies

Do not add Docker, PostgreSQL, Redis, Neo4j, Qdrant, or local LLMs until they are actually needed.

## Roadmap

See `docs/roadmap.md`.
