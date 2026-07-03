#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -eq 0 ]]; then
  bash "${ROOT}/bootstrap.sh"
else
  sudo bash "${ROOT}/bootstrap.sh"
fi
