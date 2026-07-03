#!/usr/bin/env bash

executor_load_env() {
  local env_file="${ADE_ROOT}/configs/vps.env"

  if [[ -f "${env_file}" ]]; then
    # shellcheck disable=SC1090
    source "${env_file}"
  else
    log_warn "configs/vps.env not found; using defaults"
  fi

  export AGENT_USER="${AGENT_USER:-vos}"
  export DEV_ROOT="${DEV_ROOT:-/home/${AGENT_USER}/dev}"
  export REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
  export TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
  export CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
  export LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"
  export ADE_ROOT ADE_MANIFEST
}

executor_run_step() {
  local step="$1"
  local path="${ADE_ROOT}/${step}"
  require_file "${path}"
  log_step "${step}"
  bash "${path}"
}

executor_apply_plan() {
  require_root
  executor_load_env
  log_info "applying manifest: $(manifest_path)"

  local step
  while IFS= read -r step; do
    [[ -z "${step}" ]] && continue
    executor_run_step "${step}"
  done < <(manifest_install_plan)

  log_info "apply complete"
}
