#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="${ADE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ENV_FILE="${ADE_ROOT}/configs/vps.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

AGENT_USER="${AGENT_USER:-${SUDO_USER:-$(id -un)}}"
if [[ "${AGENT_USER}" == "root" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  AGENT_USER="${SUDO_USER}"
fi
AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
DEV_ROOT="${DEV_ROOT:-${AGENT_HOME}/dev}"
REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"
CONFIG_DIR="${AGENT_HOME}/.config"

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

check_any_cmd() {
  local label="$1"
  shift
  local cmd
  for cmd in "$@"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      echo "ok: ${label} (${cmd})"
      return 0
    fi
  done
  echo "missing: ${label}"
  failures=$((failures + 1))
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

check_owner() {
  local path="$1"
  local expected="$2"
  local owner
  if [[ ! -e "${path}" ]]; then
    echo "missing: ${path}"
    failures=$((failures + 1))
    return 0
  fi
  owner="$(stat -c '%U:%G' "${path}")"
  if [[ "${owner}" == "${expected}:${expected}" ]]; then
    echo "ok: owner ${path} -> ${owner}"
  else
    echo "bad owner: ${path} -> ${owner}, expected ${expected}:${expected}"
    failures=$((failures + 1))
  fi
}

echo "ADE healthcheck target user: ${AGENT_USER}"
echo "ADE healthcheck dev root: ${DEV_ROOT}"

check_cmd git
check_cmd gh
check_cmd python3
check_cmd uv
check_cmd node
check_cmd npm
check_cmd pnpm
check_cmd ssh
check_cmd rg
check_any_cmd fd fd fdfind

check_dir "${DEV_ROOT}"
check_dir "${REPOS_DIR}"
check_dir "${TOOLS_DIR}"
check_dir "${CACHE_DIR}"
check_dir "${LOGS_DIR}"
check_dir "${TOOLS_DIR}/hermes"
check_dir "${TOOLS_DIR}/opencode"
check_dir "${CONFIG_DIR}"
check_dir "${CONFIG_DIR}/ade"
check_dir "${CONFIG_DIR}/vos"
check_owner "${CONFIG_DIR}" "${AGENT_USER}"
check_owner "${CONFIG_DIR}/ade" "${AGENT_USER}"
check_owner "${CONFIG_DIR}/vos" "${AGENT_USER}"

if [[ "${failures}" -gt 0 ]]; then
  echo "ADE healthcheck failed with ${failures} issue(s)"
  exit 1
fi

echo "ADE healthcheck passed"
