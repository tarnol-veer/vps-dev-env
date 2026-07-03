#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ADE_ROOT

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

log "starting ADE bootstrap"

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

run_step install-base.sh
run_step install-python.sh
run_step install-node.sh
run_step install-github.sh
run_step setup-git.sh
run_step setup-ssh.sh
run_step clone-repos.sh
run_step healthcheck.sh

log "bootstrap complete"
log "next steps:"
echo "  1. copy configs/vps.env.example to configs/vps.env and fill local values"
echo "  2. run: gh auth login"
echo "  3. add project repositories to configs/vps.env"
