#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="${ADE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PACKAGES_FILE="${ADE_ROOT}/packages/apt.txt"

if [[ "${EUID}" -ne 0 ]]; then
  echo "install-base.sh must be run as root" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

if [[ -f "${PACKAGES_FILE}" ]]; then
  mapfile -t packages < <(grep -Ev '^\s*(#|$)' "${PACKAGES_FILE}")
  if [[ "${#packages[@]}" -gt 0 ]]; then
    apt-get install -y "${packages[@]}"
  fi
fi

if ! id "${AGENT_USER:-vos}" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "${AGENT_USER:-vos}"
fi

install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "${DEV_ROOT:-/home/${AGENT_USER:-vos}/dev}"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "${REPOS_DIR:-/home/${AGENT_USER:-vos}/dev/repos}"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "${TOOLS_DIR:-/home/${AGENT_USER:-vos}/dev/tools}"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "${CACHE_DIR:-/home/${AGENT_USER:-vos}/dev/cache}"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "${LOGS_DIR:-/home/${AGENT_USER:-vos}/dev/logs}"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "/home/${AGENT_USER:-vos}/.config/ade"
install -d -o "${AGENT_USER:-vos}" -g "${AGENT_USER:-vos}" "/home/${AGENT_USER:-vos}/.config/vos"

systemctl enable ssh || true
systemctl start ssh || true
