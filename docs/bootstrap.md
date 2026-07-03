# Bootstrap

ADE is bootstrapped through `bootstrap.sh`.

`bootstrap.sh` is intentionally thin. It delegates execution to ADE Engine:

```bash
./engine/ade-engine apply ./ade.yaml
```

## Basic flow

1. Load and require `ade.yaml`.
2. Read `install_plan` from the manifest.
3. Load `configs/vps.env` if it exists.
4. Execute each installer in order.
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
