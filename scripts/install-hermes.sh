#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-${SUDO_USER:-$(id -un)}}"
if [[ "${AGENT_USER}" == "root" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  AGENT_USER="${SUDO_USER}"
fi
AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
TOOLS_DIR="${TOOLS_DIR:-${AGENT_HOME}/dev/tools}"

install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${TOOLS_DIR}/hermes"

cat > "${TOOLS_DIR}/hermes/README.md" <<'EOF'
# Hermes

Hermes is the required planner/orchestrator layer for ADE.

This installer currently prepares the expected directory and configuration hook.
Replace this placeholder with the official Hermes installation command once the upstream package source is fixed.
EOF

chown -R "${AGENT_USER}:${AGENT_USER}" "${TOOLS_DIR}/hermes"

echo "Hermes install hook prepared at ${TOOLS_DIR}/hermes"
