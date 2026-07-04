#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="${AGENT_USER:-${SUDO_USER:-$(id -un)}}"
if [[ "${AGENT_USER}" == "root" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  AGENT_USER="${SUDO_USER}"
fi
AGENT_HOME="$(getent passwd "${AGENT_USER}" | cut -d: -f6)"
SSH_DIR="${AGENT_HOME}/.ssh"

if ! id "${AGENT_USER}" >/dev/null 2>&1; then
  echo "User ${AGENT_USER} does not exist" >&2
  exit 1
fi

if [[ -z "${AGENT_HOME}" || ! -d "${AGENT_HOME}" ]]; then
  echo "Home directory for ${AGENT_USER} does not exist" >&2
  exit 1
fi

install -d -m 700 -o "${AGENT_USER}" -g "${AGENT_USER}" "${SSH_DIR}"

touch "${SSH_DIR}/authorized_keys"
chmod 600 "${SSH_DIR}/authorized_keys"
chown "${AGENT_USER}:${AGENT_USER}" "${SSH_DIR}/authorized_keys"

cat > "${SSH_DIR}/config" <<'EOF'
Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  IdentitiesOnly no
EOF

chmod 600 "${SSH_DIR}/config"
chown "${AGENT_USER}:${AGENT_USER}" "${SSH_DIR}/config"

echo "SSH directory prepared for ${AGENT_USER}"
