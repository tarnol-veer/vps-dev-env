#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "install-node.sh must be run as root" >&2
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  node --version
else
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g pnpm
fi

node --version || true
npm --version || true
pnpm --version || true
