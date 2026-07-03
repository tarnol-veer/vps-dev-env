#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-vos}"
TOOLS_DIR="${TOOLS_DIR:-/home/${AGENT_USER}/dev/tools}"

install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${TOOLS_DIR}/hermes"

cat > "${TOOLS_DIR}/hermes/README.md" <<'EOF'
# Hermes

Hermes is the required planner/orchestrator layer for ADE.

This installer currently prepares the expected directory and configuration hook.
Replace this placeholder with the official Hermes installation command once the upstream package source is fixed.
EOF

chown -R "${AGENT_USER}:${AGENT_USER}" "${TOOLS_DIR}/hermes"

echo "Hermes install hook prepared at ${TOOLS_DIR}/hermes"
