# Bootstrap

ADE is bootstrapped through `bootstrap.sh`.

## Basic flow

1. Load `configs/vps.env` if it exists.
2. Install base Ubuntu packages.
3. Install Python and uv.
4. Install Node.js LTS and pnpm.
5. Install GitHub CLI.
6. Configure Git.
7. Prepare SSH.
8. Install Hermes integration hook.
9. Install OpenCode integration hook.
10. Clone configured repositories.
11. Run healthcheck.

## Command

```bash
sudo bash ./bootstrap.sh
```

The script is designed to be rerunnable. If a component already exists, the installer should reuse or update it rather than breaking the machine for dramatic effect.
