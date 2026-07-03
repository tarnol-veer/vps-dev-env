#!/usr/bin/env bash

planner_component_exists() {
  local needle="$1"
  local component
  while IFS= read -r component; do
    [[ "${component}" == "${needle}" ]] && return 0
  done < <(manifest_component_names)
  return 1
}

planner_resolve_component() {
  local component="$1"
  local dep installer

  if [[ "${ADE_VISITING[${component}]:-0}" == "1" ]]; then
    log_error "Cycle detected at component: ${component}"
    return 1
  fi

  if [[ "${ADE_VISITED[${component}]:-0}" == "1" ]]; then
    return 0
  fi

  if ! planner_component_exists "${component}"; then
    log_error "Unknown component referenced as dependency: ${component}"
    return 1
  fi

  ADE_VISITING["${component}"]=1

  while IFS= read -r dep; do
    [[ -z "${dep}" ]] && continue
    planner_resolve_component "${dep}"
  done < <(manifest_component_deps "${component}")

  ADE_VISITING["${component}"]=0
  ADE_VISITED["${component}"]=1

  installer="$(manifest_component_installer "${component}")"
  if [[ -z "${installer}" ]]; then
    log_error "Component has no installer: ${component}"
    return 1
  fi

  ADE_RESOLVED_COMPONENTS+=("${component}")
  ADE_RESOLVED_INSTALLERS+=("${installer}")
}

planner_build_component_plan() {
  ADE_RESOLVED_COMPONENTS=()
  ADE_RESOLVED_INSTALLERS=()
  declare -gA ADE_VISITED=()
  declare -gA ADE_VISITING=()

  local component
  while IFS= read -r component; do
    [[ -z "${component}" ]] && continue
    planner_resolve_component "${component}"
  done < <(manifest_component_names)
}

planner_print_plan() {
  log_info "manifest: $(manifest_path)"
  echo
  echo "ADE install plan"
  echo "================"
  echo
  echo "Reference stack:"
  echo "- Ubuntu LTS"
  echo "- Python via uv"
  echo "- Node.js LTS with pnpm"
  echo "- GitHub CLI"
  echo "- Hermes planner/orchestrator"
  echo "- OpenCode coding agent"
  echo

  if manifest_has_components; then
    planner_build_component_plan
    echo "Component graph order:"
    local i
    for i in "${!ADE_RESOLVED_COMPONENTS[@]}"; do
      printf -- '- %s -> %s\n' "${ADE_RESOLVED_COMPONENTS[$i]}" "${ADE_RESOLVED_INSTALLERS[$i]}"
    done
  else
    echo "Install steps:"
    manifest_install_plan | while IFS= read -r step; do
      [[ -z "${step}" ]] && continue
      echo "- ${step}"
    done
  fi
}

planner_installers() {
  if manifest_has_components; then
    planner_build_component_plan
    printf '%s\n' "${ADE_RESOLVED_INSTALLERS[@]}"
  else
    manifest_install_plan
  fi
}
