#!/usr/bin/env bash

executor_load_env() {
  local env_file="${ADE_ROOT}/configs/vps.env"

  if [[ -f "${env_file}" ]]; then
    # shellcheck disable=SC1090
    source "${env_file}"
  else
    log_warn "configs/vps.env not found; using defaults"
  fi

  ade_export_user_paths
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
  log_info "target user: ${AGENT_USER}"
  log_info "dev root: ${DEV_ROOT}"

  local step
  while IFS= read -r step; do
    [[ -z "${step}" ]] && continue
    executor_run_step "${step}"
  done < <(planner_installers)

  log_info "apply complete"
}
