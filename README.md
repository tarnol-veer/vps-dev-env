# vps-dev-env

Reproducible VPS development environment for an agent-based engineering stack.

This repository is intended to be a public, reusable **Agent Development Environment** rather than a private pile of shell scraps. Its goal is to make a fresh Ubuntu VPS usable for cloud-model-based agent development with minimal manual setup.

## Goals

- bootstrap a new VPS with one command;
- keep the environment reproducible;
- avoid manual snowflake configuration;
- avoid local LLMs by default;
- use cloud model providers;
- use Hermes as a planner/orchestrator;
- use OpenCode as a code agent;
- use GitHub as the source of truth for code and project memory.

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

OpenCode is responsible only for code-oriented work.

## Minimum VPS

- Ubuntu Server 24.04
- 1 CPU
- 3 GB RAM
- 20 GB SSD

## Installed layers

### System

- openssh-server
- git, git-lfs
- curl, wget
- jq
- sqlite3
- tree
- ripgrep
- fd-find
- tmux
- htop, btop
- build-essential
- cmake

### Python

- uv
- Python 3.13 where available

### Node

- Node.js LTS
- npm
- pnpm

### GitHub

- GitHub CLI (`gh`)
- SSH setup helpers
- Git config helpers

### Agent layer

- Hermes
- OpenCode

Both are intentionally represented as install hooks until their exact upstream installation method is finalized.

## Directory layout on VPS

```text
~/dev/
  repos/
    project-memory/
    project-core/
    playground/
  tools/
  cache/
  logs/

~/.config/
  vos/
  agent-dev-env/
```

## Repository layout

```text
vps-dev-env/
  README.md
  bootstrap.sh
  install.sh
  Makefile
  .gitignore
  docs/
  configs/
  scripts/
  packages/
  systemd/
  templates/
```

## Usage

Clone and run locally on a fresh VPS:

```bash
git clone https://github.com/tarnol-veer/vps-dev-env.git
cd vps-dev-env
sudo bash ./bootstrap.sh
```

Or use the installer entrypoint after reviewing it:

```bash
bash ./install.sh
```

## Configuration

Copy the example environment file and fill it locally:

```bash
cp configs/vps.env.example configs/vps.env
```

`configs/vps.env` must never be committed.

## Principles

### No secrets

Only `.env.example` files belong in the repository. API keys, tokens, SSH private keys, and personal configuration stay local.

### Idempotency

Running the bootstrap repeatedly should not break the machine. Every script should be safe to rerun.

```bash
sudo bash ./bootstrap.sh
```

### Repository as source of truth

If the environment changes, the change should be reflected here. No "installed manually and forgotten" archaeology, humanity has suffered enough.

### Minimal dependencies

Do not add Docker, PostgreSQL, Redis, Neo4j, Qdrant, or local LLMs until they are actually needed.

## Roadmap

### v0.1

- Bootstrap VPS
- Python
- Node
- GitHub CLI
- Hermes hook
- OpenCode hook
- Directory layout

### v0.2

- MCP
- project-memory placeholder
- project-core placeholder
- automatic repository cloning

### v0.3

- Telegram gateway placeholder
- memory update workflows
- basic agent workflows

### v0.4

- Cherry Studio configuration notes
- OpenAI/OpenRouter setup notes
- multiple configuration profiles

### v1.0

A reproducible engineering environment for an agent-based VOS stack, deployable on a fresh Ubuntu Server with almost one command.
