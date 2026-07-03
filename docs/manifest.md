# ADE Manifest

`ade.yaml` is the declarative source of truth for the reference ADE stack.

It describes what the environment is supposed to contain. Shell scripts remain the execution layer, not the place where architectural intent goes to die quietly.

## Current purpose

In v0.1, the manifest documents and stabilizes the reference stack:

- Ubuntu 24.04
- Python managed by uv
- Node.js LTS and pnpm
- Git and GitHub CLI
- Hermes as the required planner/orchestrator
- OpenCode as the required coding agent
- optional project repositories
- healthcheck service template

## Install plan

The `install_plan` section lists the scripts run by `bootstrap.sh`.

For now, `bootstrap.sh` follows the same plan explicitly. Later versions can parse the manifest directly and execute the listed steps dynamically.

## Design rule

ADE is opinionated. Hermes and OpenCode are part of the reference product, not optional decorations.

Alternative agents can be explored later, but the supported baseline remains Hermes + OpenCode until there is a concrete reason to change it.
