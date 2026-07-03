#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-vos}"
TOOLS_DIR="${TOOLS_DIR:-/home/${AGENT_USER}/dev/tools}"

install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${TOOLS_DIR}/opencode"

if command -v npm >/dev/null 2>&1; then
  npm install -g opencode-ai || true
fi

cat > "${TOOLS_DIR}/opencode/README.md" <<'EOF'
# OpenCode

OpenCode is the required coding agent layer for ADE.

The installer attempts a global npm install for opencode-ai and keeps this directory as the integration/configuration hook.
Adjust the package name here when the reference upstream package is finalized.
EOF

chown -R "${AGENT_USER}:${AGENT_USER}" "${TOOLS_DIR}/opencode"

echo "OpenCode install hook prepared at ${TOOLS_DIR}/opencode"
