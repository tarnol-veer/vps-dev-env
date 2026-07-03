# ADE Manifest

`ade.yaml` is the declarative source of truth for the reference ADE stack.

It describes what the environment is supposed to contain. Shell scripts remain component installers, not the place where architectural intent goes to die quietly.

## Current purpose

In v0.1, the manifest defines:

- Ubuntu 24.04 target
- Python managed by uv
- Node.js LTS and pnpm
- Git and GitHub CLI
- Hermes as the required planner/orchestrator
- OpenCode as the required coding agent
- optional project repositories
- healthcheck service template
- install plan consumed by ADE Engine

## Install plan

The `install_plan` section lists the scripts run by ADE Engine.

```yaml
install_plan:
  - scripts/install-base.sh
  - scripts/install-python.sh
  - scripts/install-node.sh
```

The engine currently supports this simple list shape. That is deliberate. The bootstrap path should stay boring and reliable, because excitement belongs in demos and outages.

## Design rule

ADE is opinionated. Hermes and OpenCode are part of the reference product, not optional decorations.

Alternative agents can be explored later, but the supported baseline remains Hermes + OpenCode until there is a concrete reason to change it.
