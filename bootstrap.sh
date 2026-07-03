#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADE_MANIFEST="${ADE_ROOT}/ade.yaml"
export ADE_ROOT ADE_MANIFEST

if [[ "${EUID}" -ne 0 ]]; then
  echo "bootstrap.sh must be run as root. Use: sudo bash ./bootstrap.sh" >&2
  exit 1
fi

log() {
  printf '\n[ade] %s\n' "$*"
}

run_step() {
  local script="$1"
  log "running ${script}"
  bash "${ADE_ROOT}/scripts/${script}"
}

require_file() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    echo "Required file is missing: ${file}" >&2
    exit 1
  fi
}

log "starting ADE bootstrap"
require_file "${ADE_MANIFEST}"
log "manifest: ${ADE_MANIFEST}"

if [[ -f "${ADE_ROOT}/configs/vps.env" ]]; then
  # shellcheck disable=SC1091
  source "${ADE_ROOT}/configs/vps.env"
else
  log "configs/vps.env not found; using defaults and configs/vps.env.example as reference"
fi

export AGENT_USER="${AGENT_USER:-vos}"
export DEV_ROOT="${DEV_ROOT:-/home/${AGENT_USER}/dev}"
export REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
export TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
export CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
export LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"

log "reference stack: Ubuntu + Python/uv + Node/pnpm + GitHub CLI + Hermes + OpenCode"

run_step install-base.sh
run_step install-python.sh
run_step install-node.sh
run_step install-github.sh
run_step setup-git.sh
run_step setup-ssh.sh
run_step install-hermes.sh
run_step install-opencode.sh
run_step clone-repos.sh
run_step healthcheck.sh

log "bootstrap complete"
log "next steps:"
echo "  1. copy configs/vps.env.example to configs/vps.env and fill local values"
echo "  2. run: gh auth login"
echo "  3. add project repositories to configs/vps.env"
echo "  4. run: bash ./scripts/healthcheck.sh"
