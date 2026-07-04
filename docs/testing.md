# ADE Testing Checklist

This checklist captures real failures found during the first VPS bootstrap runs. Apparently production is still the only environment honest enough to tell the truth.

## Target system

- Ubuntu Server 24.04
- Fresh VPS is preferred
- Login as a normal user with sudo rights

## Clean install flow

```bash
git clone https://github.com/tarnol-veer/vps-dev-env.git
cd vps-dev-env
bash ./bin/ade plan
bash ./bin/ade doctor
sudo bash ./bootstrap.sh
```

## Post-install checks

```bash
bash ./bin/ade doctor
bash ./scripts/healthcheck.sh
git config --global --list
tree ~/dev -L 2
ls -la ~/.config
```

Expected results:

- `doctor` passes.
- `healthcheck` passes.
- ADE uses the sudo caller as the target user by default.
- `~/dev` exists.
- `~/dev/repos`, `~/dev/tools`, `~/dev/cache`, and `~/dev/logs` exist.
- `~/dev/tools/hermes` exists.
- `~/dev/tools/opencode` exists.
- `~/.config`, `~/.config/ade`, and `~/.config/vos` are owned by the target user, not root.

## Idempotency check

Run bootstrap again:

```bash
sudo bash ./bootstrap.sh
bash ./scripts/healthcheck.sh
```

Expected result:

- The second run does not fail.
- Ownership remains correct.
- Existing directories are reused.

## Known regression checks

### mawk compatibility

```bash
bash ./bin/ade plan
```

Expected result:

- No `awk` warnings.
- Component graph order prints correctly.

### User resolution

```bash
bash ./bin/ade doctor
```

Expected result:

- Target user is the sudo caller/current user unless `AGENT_USER` is explicitly set.
- ADE does not create or use `vos` by default.

### fd/fdfind compatibility

Ubuntu installs `fd-find`, which provides `fdfind` instead of `fd`.

Expected result:

- Healthcheck accepts either `fd` or `fdfind`.

### ~/.config ownership

```bash
stat -c '%U:%G' ~/.config
stat -c '%U:%G' ~/.config/ade
stat -c '%U:%G' ~/.config/vos
```

Expected result:

```text
<user>:<user>
<user>:<user>
<user>:<user>
```

ADE may repair ownership of the top-level `~/.config` directory itself, but it must not recursively chown arbitrary existing application configuration files.

## Release gate for v0.1.0-alpha

Before tagging a release:

- clean install passes;
- second bootstrap run passes;
- `doctor` passes;
- `healthcheck` passes;
- `~/.config` ownership remains correct;
- `fd`/`fdfind` check passes;
- Git config is usable;
- `gh auth status` can be run after user authentication.
