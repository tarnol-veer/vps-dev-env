#!/usr/bin/env bash

ade_resolve_user() {
  if [[ -n "${AGENT_USER:-}" ]]; then
    printf '%s\n' "${AGENT_USER}"
    return 0
  fi

  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    printf '%s\n' "${SUDO_USER}"
    return 0
  fi

  id -un
}

ade_user_home() {
  local user="$1"
  getent passwd "${user}" | cut -d: -f6
}

ade_export_user_paths() {
  export AGENT_USER="$(ade_resolve_user)"
  export AGENT_HOME="$(ade_user_home "${AGENT_USER}")"

  if [[ -z "${AGENT_HOME}" ]]; then
    echo "Unable to resolve home directory for ${AGENT_USER}" >&2
    return 1
  fi

  export DEV_ROOT="${DEV_ROOT:-${AGENT_HOME}/dev}"
  export REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
  export TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
  export CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
  export LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"
}
