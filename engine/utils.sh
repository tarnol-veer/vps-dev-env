#!/usr/bin/env bash

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    log_error "This command must be run as root. Use sudo."
    exit 1
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    log_error "Required file is missing: ${file}"
    exit 1
  fi
}

repo_path() {
  local rel="$1"
  printf '%s/%s' "${ADE_ROOT}" "${rel}"
}

strip_yaml_list_marker() {
  sed 's/^  - //'
}
