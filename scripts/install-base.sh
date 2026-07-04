#!/usr/bin/env bash
set -euo pipefail

ADE_ROOT="${ADE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PACKAGES_FILE="${ADE_ROOT}/packages/apt.txt"
AGENT_USER="${AGENT_USER:-${SUDO_USER:-$(id -un)}}"
if [[ "${AGENT_USER}" == "root" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  AGENT_USER="${SUDO_USER}"
fi
AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
DEV_ROOT="${DEV_ROOT:-${AGENT_HOME}/dev}"
REPOS_DIR="${REPOS_DIR:-${DEV_ROOT}/repos}"
TOOLS_DIR="${TOOLS_DIR:-${DEV_ROOT}/tools}"
CACHE_DIR="${CACHE_DIR:-${DEV_ROOT}/cache}"
LOGS_DIR="${LOGS_DIR:-${DEV_ROOT}/logs}"
CONFIG_DIR="${AGENT_HOME}/.config"

if [[ "${EUID}" -ne 0 ]]; then
  echo "install-base.sh must be run as root" >&2
  exit 1
fi

if [[ -z "${AGENT_HOME}" ]]; then
  echo "Unable to resolve home directory for ${AGENT_USER}" >&2
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

if ! id "${AGENT_USER}" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "${AGENT_USER}"
  AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
  CONFIG_DIR="${AGENT_HOME}/.config"
fi

install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${DEV_ROOT}"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${REPOS_DIR}"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${TOOLS_DIR}"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${CACHE_DIR}"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${LOGS_DIR}"

# Create and repair only the top-level config directory and ADE-owned subdirectories.
# Do not recursively chown the whole config tree: other applications may own files there.
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${CONFIG_DIR}"
chown "${AGENT_USER}:${AGENT_USER}" "${CONFIG_DIR}"
chmod 755 "${CONFIG_DIR}"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${CONFIG_DIR}/ade"
install -d -o "${AGENT_USER}" -g "${AGENT_USER}" "${CONFIG_DIR}/vos"

systemctl enable ssh || true
systemctl start ssh || true

echo "ADE base installed for ${AGENT_USER} at ${DEV_ROOT}"
