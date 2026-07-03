#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-vos}"
REPOS_DIR="${REPOS_DIR:-/home/${AGENT_USER}/dev/repos}"
MEMORY_REPO="${MEMORY_REPO:-}"
CORE_REPO="${CORE_REPO:-}"
PLAYGROUND_REPO="${PLAYGROUND_REPO:-}"

run_as_agent() {
  sudo -u "${AGENT_USER}" -H "$@"
}

clone_or_skip() {
  local repo="$1"
  local name="$2"

  if [[ -z "${repo}" ]]; then
    echo "Skipping ${name}: repository is not configured"
    return 0
  fi

  local target="${REPOS_DIR}/${name}"
  if [[ -d "${target}/.git" ]]; then
    echo "Updating ${name}"
    run_as_agent git -C "${target}" pull --ff-only || true
  else
    echo "Cloning ${name} from ${repo}"
    run_as_agent git clone "${repo}" "${target}" || true
  fi
}

install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${REPOS_DIR}"

clone_or_skip "${MEMORY_REPO}" "project-memory"
clone_or_skip "${CORE_REPO}" "project-core"
clone_or_skip "${PLAYGROUND_REPO}" "playground"
