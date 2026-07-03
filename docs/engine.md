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
  planner.sh      # install plan display
  executor.sh     # apply implementation
  doctor.sh       # local checks
  logger.sh       # logging helpers
  utils.sh        # shared helpers
```

## Current implementation

The engine intentionally uses a narrow YAML reader based on `awk` for the current manifest shape. It only reads the `install_plan` list and a few simple scalar values.

This avoids adding a YAML parser dependency to the bootstrap path. Later, if ADE grows a richer manifest format, this can move to Python or a dedicated parser.

## Design rule

The manifest describes the desired ADE product. The engine executes it. Individual scripts remain responsible for idempotent installation of each component.
