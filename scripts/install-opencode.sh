#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-${SUDO_USER:-$(id -un)}}"
if [[ "${AGENT_USER}" == "root" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  AGENT_USER="${SUDO_USER}"
fi
AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
TOOLS_DIR="${TOOLS_DIR:-${AGENT_HOME}/dev/tools}"

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
