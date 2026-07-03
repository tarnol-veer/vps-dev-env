#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-vos}"
GIT_NAME="${GIT_NAME:-ADE User}"
GIT_EMAIL="${GIT_EMAIL:-ade@example.local}"

run_as_agent() {
  sudo -u "${AGENT_USER}" -H "$@"
}

if ! id "${AGENT_USER}" >/dev/null 2>&1; then
  echo "User ${AGENT_USER} does not exist" >&2
  exit 1
fi

run_as_agent git config --global user.name "${GIT_NAME}"
run_as_agent git config --global user.email "${GIT_EMAIL}"
run_as_agent git config --global init.defaultBranch main
run_as_agent git config --global pull.rebase false
run_as_agent git config --global core.editor nano

echo "Git configured for ${AGENT_USER}"
