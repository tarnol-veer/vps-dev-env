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

manifest_has_components() {
  grep -q '^components:' "${ADE_MANIFEST}"
}

manifest_component_names() {
  awk '
    /^components:/ { in_components = 1; next }
    in_components && /^  [A-Za-z0-9_][A-Za-z0-9_-]*:/ {
      name = $1
      sub(/:$/, "", name)
      print name
      next
    }
    in_components && /^[^ ]/ { in_components = 0 }
  ' "${ADE_MANIFEST}"
}

manifest_component_installer() {
  local component="$1"
  awk -v component="${component}" '
    /^components:/ { in_components = 1; next }
    in_components && /^  [A-Za-z0-9_][A-Za-z0-9_-]*:/ {
      current = $1
      sub(/:$/, "", current)
      in_target = (current == component)
      next
    }
    in_components && in_target && /^    installer:/ {
      sub(/^    installer:[[:space:]]*/, "")
      gsub(/\"/, "")
      print
      exit
    }
    in_components && /^[^ ]/ { in_components = 0 }
  ' "${ADE_MANIFEST}"
}

manifest_component_deps() {
  local component="$1"
  awk -v component="${component}" '
    /^components:/ { in_components = 1; next }
    in_components && /^  [A-Za-z0-9_][A-Za-z0-9_-]*:/ {
      current = $1
      sub(/:$/, "", current)
      in_target = (current == component)
      in_deps = 0
      next
    }
    in_components && in_target && /^    depends_on:/ { in_deps = 1; next }
    in_components && in_target && in_deps && /^      - / {
      sub(/^      - /, "")
      print
      next
    }
    in_components && in_target && in_deps && /^    [A-Za-z0-9_]/ { in_deps = 0 }
    in_components && /^[^ ]/ { in_components = 0 }
  ' "${ADE_MANIFEST}"
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
