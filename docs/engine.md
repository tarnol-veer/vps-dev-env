# ADE Engine

ADE Engine is the execution layer for `ade.yaml`.

It keeps `bootstrap.sh` thin and prevents it from becoming a thousand-line bash swamp, a fate many scripts meet after three confident afternoons.

## Commands

```bash
bash ./bin/ade plan
sudo bash ./bin/ade apply
bash ./bin/ade doctor
```

## Structure

```text
engine/
  ade-engine      # CLI entrypoint
  manifest.sh     # manifest reading helpers
  planner.sh      # dependency-aware planning
  executor.sh     # apply implementation
  doctor.sh       # local checks
  logger.sh       # logging helpers
  utils.sh        # shared helpers
```

## Component graph

The engine now prefers the `components` section in `ade.yaml`.

Each component has an installer and optional dependencies. The planner performs a small topological resolution pass and produces an execution order.

This is intentionally narrow. ADE is not trying to become a general-purpose YAML interpreter, because apparently we have suffered enough already.

## Fallback

If `components` is absent, the engine falls back to the legacy `install_plan` list.

## Design rule

The manifest describes the desired ADE product. The engine resolves and executes it. Individual scripts remain responsible for idempotent installation of each component.
