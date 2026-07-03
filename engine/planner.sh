#!/usr/bin/env bash

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
  echo "Install steps:"
  manifest_install_plan | while IFS= read -r step; do
    [[ -z "${step}" ]] && continue
    echo "- ${step}"
  done
}
