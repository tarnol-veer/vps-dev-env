#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-vos}"
DEV_ROOT="${DEV_ROOT:-/home/${AGENT_USER}/dev}"
REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"

failures=0

check_cmd() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    echo "ok: ${cmd}"
  else
    echo "missing: ${cmd}"
    failures=$((failures + 1))
  fi
}

check_dir() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    echo "ok: ${dir}"
  else
    echo "missing: ${dir}"
    failures=$((failures + 1))
  fi
}

check_cmd git
check_cmd gh
check_cmd python3
check_cmd uv
check_cmd node
check_cmd npm
check_cmd pnpm
check_cmd ssh
check_cmd rg
check_cmd fd

check_dir "${DEV_ROOT}"
check_dir "${REPOS_DIR}"
check_dir "${TOOLS_DIR}"
check_dir "${CACHE_DIR}"
check_dir "${LOGS_DIR}"
check_dir "${TOOLS_DIR}/hermes"
check_dir "${TOOLS_DIR}/opencode"

if [[ "${failures}" -gt 0 ]]; then
  echo "ADE healthcheck failed with ${failures} issue(s)"
  exit 1
fi

echo "ADE healthcheck passed"
