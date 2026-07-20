#!/usr/bin/env bash
set -Eeuo pipefail

# Safe wrapper for the audited mozaroc/3x-ui-pro installer.
# It preserves Docker/Amnezia state, refuses port conflicts, creates backups,
# downloads the exact audited Git blob, and removes the broad localhost proxy
# plus destructive firewall/nginx cleanup before execution.

UPSTREAM_REPO="mozaroc/3x-ui-pro"
UPSTREAM_BLOB_SHA="d548b565ebdac837dd77839e0d667ec9c5b79433"
WORKDIR="${WORKDIR:-/root/3x-ui-safe}"
MODE="check"
DOMAIN=""
REALITY_DOMAIN=""
AUTO_DOMAIN="n"
PANEL_VERSION=""

log()  { printf '[3x-ui-safe] %s\n' "$*"; }
warn() { printf '[3x-ui-safe] WARNING: %s\n' "$*" >&2; }
die()  { printf '[3x-ui-safe] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage:
  sudo bash install-safe.sh --check
  sudo bash install-safe.sh --apply --domain panel.example.com \
      --reality-domain reality.example.com [--panel-version 3.5.0]
  sudo bash install-safe.sh --apply --auto-domain

The script intentionally refuses to continue when Docker or another service
already publishes TCP 80 or 443. Resolve the collision first; stealing ports
from Amnezia would be a remarkably efficient way to break both VPNs.
EOF
}

while (($#)); do
  case "$1" in
    --check) MODE="check"; shift ;;
    --apply) MODE="apply"; shift ;;
    --domain) DOMAIN="${2:-}"; shift 2 ;;
    --reality-domain) REALITY_DOMAIN="${2:-}"; shift 2 ;;
    --auto-domain) AUTO_DOMAIN="y"; shift ;;
    --panel-version) PANEL_VERSION="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ ${EUID} -eq 0 ]] || die "Run as root"
command -v curl >/dev/null || die "curl is required"
command -v jq >/dev/null || die "jq is required"
command -v base64 >/dev/null || die "base64 is required"
command -v ss >/dev/null || die "ss (iproute2) is required"

mkdir -p "$WORKDIR"
chmod 700 "$WORKDIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
STATE_DIR="$WORKDIR/state-$STAMP"
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

snapshot_state() {
  log "Saving host and Docker state to $STATE_DIR"
  ss -lntup > "$STATE_DIR/ss-lntup.txt" 2>&1 || true
  ip -br address > "$STATE_DIR/ip-address.txt" 2>&1 || true
  ip route show table all > "$STATE_DIR/routes.txt" 2>&1 || true
  nft list ruleset > "$STATE_DIR/nft-ruleset.txt" 2>&1 || true
  iptables-save > "$STATE_DIR/iptables.rules" 2>&1 || true
  ip6tables-save > "$STATE_DIR/ip6tables.rules" 2>&1 || true
  systemctl cat ssh sshd > "$STATE_DIR/ssh-units.txt" 2>&1 || true
  sshd -T > "$STATE_DIR/sshd-effective.txt" 2>&1 || true

  if command -v docker >/dev/null; then
    docker version > "$STATE_DIR/docker-version.txt" 2>&1 || true
    docker ps -a --no-trunc > "$STATE_DIR/docker-ps.txt" 2>&1 || true
    docker network ls > "$STATE_DIR/docker-networks.txt" 2>&1 || true
    docker ps -aq | xargs -r docker inspect > "$STATE_DIR/docker-inspect.json" 2>&1 || true
  fi
}

check_amnezia() {
  if ! command -v docker >/dev/null; then
    log "Docker not found; no Amnezia Docker deployment detected"
    return
  fi

  local matches
  matches="$(docker ps -a --format '{{.Names}} {{.Image}}' 2>/dev/null | grep -Ei 'amnezia|awg|wireguard|xray|cloak|openvpn' || true)"
  if [[ -n "$matches" ]]; then
    log "Detected VPN-related Docker containers:"
    printf '%s\n' "$matches"
  else
    warn "Docker exists, but container names/images do not clearly identify Amnezia"
  fi
}

check_required_ports() {
  local conflict=0
  for port in 80 443; do
    if ss -H -lnt "sport = :$port" | grep -q .; then
      warn "TCP $port is already in use:"
      ss -lntp "sport = :$port" >&2 || true
      conflict=1
    fi
  done

  if (( conflict )); then
    die "3x-ui-pro requires public TCP 80/443. Existing listeners must be moved or integrated deliberately; refusing to break Amnezia."
  fi
}

backup_paths() {
  local archive="$STATE_DIR/preinstall-backup.tar.gz"
  local paths=()
  [[ -e /etc/x-ui ]] && paths+=(/etc/x-ui)
  [[ -e /usr/local/x-ui ]] && paths+=(/usr/local/x-ui)
  [[ -e /etc/nginx ]] && paths+=(/etc/nginx)
  [[ -e /etc/letsencrypt ]] && paths+=(/etc/letsencrypt)
  if ((${#paths[@]})); then
    tar -czf "$archive" "${paths[@]}" 2>/dev/null || die "Backup failed"
    chmod 600 "$archive"
    log "Backup created: $archive"
  else
    log "No existing x-ui/nginx/letsencrypt paths to back up"
  fi
}

fetch_audited_upstream() {
  local dst="$WORKDIR/x-ui-latest.upstream.sh"
  log "Downloading immutable audited Git blob $UPSTREAM_BLOB_SHA"
  curl -fsSL "https://api.github.com/repos/${UPSTREAM_REPO}/git/blobs/${UPSTREAM_BLOB_SHA}" \
    | jq -er '.content' \
    | tr -d '\n' \
    | base64 -d > "$dst"
  [[ -s "$dst" ]] || die "Downloaded upstream script is empty"
  grep -q '^#!/bin/bash' "$dst" || die "Unexpected upstream content"
  chmod 600 "$dst"
  printf '%s  %s\n' "$(sha256sum "$dst" | awk '{print $1}')" "$dst" > "$STATE_DIR/upstream.sha256"
}

patch_upstream() {
  local src="$WORKDIR/x-ui-latest.upstream.sh"
  local dst="$WORKDIR/x-ui-latest.patched.sh"
  python3 - "$src" "$dst" <<'PY'
import pathlib
import re
import sys

src, dst = map(pathlib.Path, sys.argv[1:3])
s = src.read_text(encoding="utf-8")

# Never let the upstream installer disable or rewrite the host firewall.
lines = []
for line in s.splitlines(True):
    stripped = line.lstrip()
    if stripped.startswith("ufw ") or stripped.startswith("ufw\t"):
        indent = line[: len(line) - len(stripped)]
        lines.append(indent + ": # 3x-ui-safe: preserved host firewall; upstream was: " + stripped)
    else:
        lines.append(line)
s = "".join(lines)

# Preserve unrelated nginx virtual hosts and stream configs.
for destructive in (
    "    rm -rf /etc/nginx/sites-enabled/*\n",
    "    rm -rf /etc/nginx/sites-available/*\n",
    "    rm -rf /etc/nginx/stream-enabled/*\n",
):
    s = s.replace(destructive, "    : # 3x-ui-safe: preserve existing nginx configuration\n")

# Remove universal public URL -> arbitrary localhost port proxy.
start = "    #Xray generic proxy (WS / gRPC by port+path)\n"
end = "\n    location / { try_files \\$uri \\$uri/ =404; }"
if start not in s:
    raise SystemExit("generic proxy start marker not found; upstream changed")
head, rest = s.split(start, 1)
if end not in rest:
    raise SystemExit("generic proxy end marker not found; upstream changed")
_, tail = rest.split(end, 1)
s = head + "    # 3x-ui-safe: generic localhost-port proxy removed\n" + end.lstrip("\n") + tail

# Stop uninstall path from purging all nginx data on a shared host.
s = s.replace(
    "    rm -rf /var/www/html/ /var/www/diagnostics/ /var/www/subpage/ /etc/nginx/ /usr/share/nginx/\n",
    "    rm -rf /var/www/diagnostics/ /var/www/subpage/\n"
)

# Make accidental future Docker manipulation visible and fatal.
insert = '''\n# 3x-ui-safe runtime guard: this installer must not manipulate Docker/Amnezia.\ndocker() { echo "3x-ui-safe: upstream attempted to call docker: $*" >&2; exit 90; }\n'''
s = s.replace("#!/bin/bash\n", "#!/bin/bash\n" + insert, 1)

dst.write_text(s, encoding="utf-8")
PY
  chmod 700 "$dst"

  grep -q 'generic localhost-port proxy removed' "$dst" || die "Security patch was not applied"
  if grep -Eq '^[[:space:]]*ufw[[:space:]]' "$dst"; then
    die "Unpatched UFW command remains"
  fi
  if grep -q 'location ~ \^/(?<fwdport>' "$dst"; then
    die "Dangerous generic localhost proxy remains"
  fi
  bash -n "$dst" || die "Patched script failed bash syntax check"
  printf '%s  %s\n' "$(sha256sum "$dst" | awk '{print $1}')" "$dst" > "$STATE_DIR/patched.sha256"
  log "Patched installer ready: $dst"
}

run_installer() {
  local args=(-install y -auto_domain "$AUTO_DOMAIN")
  if [[ "$AUTO_DOMAIN" != "y" ]]; then
    [[ -n "$DOMAIN" ]] || die "--domain is required unless --auto-domain is used"
    [[ -n "$REALITY_DOMAIN" ]] || die "--reality-domain is required unless --auto-domain is used"
    [[ "$DOMAIN" != "$REALITY_DOMAIN" ]] || die "Panel and Reality domains must differ"
    args+=(-subdomain "$DOMAIN" -reality_domain "$REALITY_DOMAIN")
  fi
  [[ -z "$PANEL_VERSION" ]] || args+=(-version "$PANEL_VERSION")

  log "Starting patched installer"
  bash "$WORKDIR/x-ui-latest.patched.sh" "${args[@]}" 2>&1 | tee "$STATE_DIR/install.log"
}

snapshot_state
check_amnezia
check_required_ports

if [[ "$MODE" == "check" ]]; then
  log "Preflight passed. No changes were made."
  exit 0
fi

backup_paths
fetch_audited_upstream
patch_upstream
run_installer

log "Install finished. Docker containers were not stopped, removed, or reconfigured."
log "Review state and logs in: $STATE_DIR"
