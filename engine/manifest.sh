#!/usr/bin/env bash

ADE_MANIFEST="${ADE_MANIFEST:-}"

manifest_set_path() {
  ADE_MANIFEST="$1"
  export ADE_MANIFEST
  require_file "${ADE_MANIFEST}"
}

manifest_path() {
  printf '%s\n' "${ADE_MANIFEST}"
}

manifest_install_plan() {
  awk '
    /^install_plan:/ { in_plan = 1; next }
    in_plan && /^  - / { sub(/^  - /, ""); print; next }
    in_plan && /^[^ ]/ { in_plan = 0 }
  ' "${ADE_MANIFEST}"
}

manifest_value() {
  local key="$1"
  awk -v key="${key}" '
    $1 == key ":" { sub(/^[^:]+:[[:space:]]*/, ""); gsub(/\"/, ""); print; exit }
  ' "${ADE_MANIFEST}"
}
