#!/usr/bin/env bash

doctor_check_cmd() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    printf 'ok      %s\n' "${cmd}"
    return 0
  fi
  printf 'missing %s\n' "${cmd}"
  return 1
}

doctor_check_file() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    printf 'ok      %s\n' "${file}"
    return 0
  fi
  printf 'missing %s\n' "${file}"
  return 1
}

doctor_check_dir() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    printf 'ok      %s\n' "${dir}"
    return 0
  fi
  printf 'missing %s\n' "${dir}"
  return 1
}

doctor_run() {
  local failures=0
  log_info "doctor: $(manifest_path)"

  if [[ -f "${ADE_ROOT}/configs/vps.env" ]]; then
    # shellcheck disable=SC1090
    source "${ADE_ROOT}/configs/vps.env"
  fi
  ade_export_user_paths
  log_info "target user: ${AGENT_USER}"
  log_info "dev root: ${DEV_ROOT}"

  doctor_check_file "${ADE_ROOT}/ade.yaml" || failures=$((failures + 1))
  doctor_check_file "${ADE_ROOT}/bootstrap.sh" || failures=$((failures + 1))

  doctor_check_cmd bash || failures=$((failures + 1))
  doctor_check_cmd git || failures=$((failures + 1))
  doctor_check_cmd ssh || failures=$((failures + 1))
  doctor_check_cmd curl || failures=$((failures + 1))
  doctor_check_cmd awk || failures=$((failures + 1))

  doctor_check_dir "${AGENT_HOME}" || failures=$((failures + 1))

  if [[ "${failures}" -gt 0 ]]; then
    log_error "doctor found ${failures} issue(s)"
    exit 1
  fi

  log_info "doctor passed"
}
