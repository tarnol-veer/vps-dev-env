# Bootstrap

ADE is bootstrapped through `bootstrap.sh`.

`bootstrap.sh` is intentionally thin. It delegates execution to ADE Engine:

```bash
./engine/ade-engine apply ./ade.yaml
```

## User model

By default ADE installs into the user that invoked `sudo`.

For example:

```bash
sudo bash ./bootstrap.sh
```

run by user `memery` installs ADE paths under:

```text
/home/memery/dev
```

To force a dedicated user, set `AGENT_USER` in `configs/vps.env`.

## Basic flow

1. Load and require `ade.yaml`.
2. Resolve target user and paths.
3. Read the component graph from the manifest.
4. Execute each installer in dependency order.
5. Run healthcheck as the final install step.

## Command

```bash
sudo bash ./bootstrap.sh
```

## Inspect the plan

```bash
bash ./bin/ade plan
```

## Run doctor

```bash
bash ./bin/ade doctor
```

The bootstrap is designed to be rerunnable. If a component already exists, its installer should reuse or update it rather than breaking the machine for dramatic effect.
