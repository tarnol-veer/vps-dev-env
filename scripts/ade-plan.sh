#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="${ADE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ADE_MANIFEST="${ADE_MANIFEST:-${ADE_ROOT}/ade.yaml}"

if [[ ! -f "${ADE_MANIFEST}" ]]; then
  echo "Missing ADE manifest: ${ADE_MANIFEST}" >&2
  exit 1
fi

cat <<EOF
ADE install plan
================

Manifest: ${ADE_MANIFEST}

Reference stack:
- Ubuntu LTS
- Python via uv
- Node.js LTS with pnpm
- GitHub CLI
- Hermes planner/orchestrator
- OpenCode coding agent

Install steps:
EOF

awk '
  /^install_plan:/ { in_plan = 1; next }
  in_plan && /^  - / { sub(/^  - /, ""); print "- " $0; next }
  in_plan && /^[^ ]/ { in_plan = 0 }
' "${ADE_MANIFEST}"
