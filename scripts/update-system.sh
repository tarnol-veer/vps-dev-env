#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "update-system.sh must be run as root" >&2
  exit 1
fi

apt-get update
apt-get upgrade -y
apt-get autoremove -y

if command -v uv >/dev/null 2>&1; then
  uv self update || true
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g npm pnpm || true
fi

if command -v gh >/dev/null 2>&1; then
  gh --version || true
fi

echo "System update complete"
