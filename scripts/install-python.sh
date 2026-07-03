#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "install-python.sh must be run as root" >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh
fi

if command -v uv >/dev/null 2>&1; then
  uv python install 3.13 || uv python install 3.12 || true
fi

python3 --version || true
uv --version || true
