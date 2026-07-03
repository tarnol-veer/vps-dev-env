# Bootstrap

ADE is bootstrapped through `bootstrap.sh`.

The bootstrap process is now anchored by `ade.yaml`, which defines the reference stack and install plan.

## Basic flow

1. Load and require `ade.yaml`.
2. Load `configs/vps.env` if it exists.
3. Install base Ubuntu packages.
4. Install Python and uv.
5. Install Node.js LTS and pnpm.
6. Install GitHub CLI.
7. Configure Git.
8. Prepare SSH.
9. Install Hermes integration hook.
10. Install OpenCode integration hook.
11. Clone configured repositories.
12. Run healthcheck.

## Command

```bash
sudo bash ./bootstrap.sh
```

## Inspect the plan

```bash
bash ./scripts/ade-plan.sh
```

The script is designed to be rerunnable. If a component already exists, the installer should reuse or update it rather than breaking the machine for dramatic effect.
