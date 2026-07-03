# Recovery

A healthy ADE machine should be reproducible from the repository and local secrets.

## Minimal recovery path

1. Provision a fresh Ubuntu Server.
2. Clone this repository.
3. Copy or recreate `configs/vps.env` locally.
4. Run `sudo bash ./bootstrap.sh`.
5. Authenticate GitHub with `gh auth login`.
6. Run `bash ./scripts/healthcheck.sh`.

Secrets are intentionally not stored in this repository. Yes, annoying. Also how security works.
