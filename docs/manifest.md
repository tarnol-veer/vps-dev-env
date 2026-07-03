# ADE Manifest

`ade.yaml` is the declarative source of truth for the reference ADE stack.

It describes what the environment is supposed to contain. Shell scripts remain component installers, not the place where architectural intent goes to die quietly.

## Current purpose

In v0.2, the manifest defines:

- Ubuntu 24.04 target
- Python managed by uv
- Node.js LTS and pnpm
- Git and GitHub CLI
- Hermes as the required planner/orchestrator
- OpenCode as the required coding agent
- optional project repositories
- healthcheck service template
- component graph consumed by ADE Engine

## Components

The `components` section is now the preferred execution model.

Each component may define:

```yaml
components:
  python:
    installer: scripts/install-python.sh
    depends_on:
      - base
    provides:
      - uv
      - python
```

ADE Engine reads the component graph, resolves dependencies, and executes installers in dependency order.

## Compatibility fallback

`install_plan` is still present as a simple fallback for older or simpler tooling.

```yaml
install_plan:
  - scripts/install-base.sh
  - scripts/install-python.sh
```

## Design rule

ADE is opinionated. Hermes and OpenCode are part of the reference product, not optional decorations.

Alternative agents can be explored later, but the supported baseline remains Hermes + OpenCode until there is a concrete reason to change it.
