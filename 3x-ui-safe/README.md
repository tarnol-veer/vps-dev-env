# 3x-ui safe installer beside Amnezia

This directory contains a guarded wrapper around the audited `mozaroc/3x-ui-pro` installer.

It is intended for a VPS where Amnezia already runs in Docker. The wrapper does **not** stop, remove, restart, or reconfigure Docker containers and refuses to proceed when public TCP 80 or 443 is already occupied.

## What is changed

- downloads the exact audited Git blob `d548b565ebdac837dd77839e0d667ec9c5b79433`, not a mutable `main` URL;
- records Docker, routes, listeners, nftables and iptables state before installation;
- detects Amnezia/VPN-related containers;
- refuses collisions on TCP 80 and 443;
- backs up existing `/etc/x-ui`, `/usr/local/x-ui`, `/etc/nginx` and `/etc/letsencrypt`;
- prevents the upstream script from disabling or rewriting UFW;
- preserves unrelated Nginx virtual hosts and stream configurations;
- removes the public `/<port>/<path>` proxy to arbitrary localhost ports;
- prevents the upstream script from calling Docker;
- validates the patched script with `bash -n` before execution.

## Important limitation

The upstream layout still requires public TCP 80 for Let's Encrypt validation and TCP 443 for SNI routing. If an Amnezia container already publishes either port, the wrapper stops. This is deliberate.

Do not "solve" that by blindly changing Docker port mappings. First determine which Amnezia protocol owns the port and whether clients depend on it. Humans have invented enough outages already.

## Usage

Download the wrapper from this repository, then run preflight only:

```bash
sudo bash install-safe.sh --check
```

The command creates a state snapshot under `/root/3x-ui-safe/` but performs no installation.

Install with two DNS names already pointing to the VPS:

```bash
sudo bash install-safe.sh --apply \
  --domain panel.example.com \
  --reality-domain reality.example.com
```

A specific official 3x-ui version can be requested:

```bash
sudo bash install-safe.sh --apply \
  --domain panel.example.com \
  --reality-domain reality.example.com \
  --panel-version 3.5.0
```

The upstream automatic `cdn-one.org` domain mode remains available, but using domains you control is preferable:

```bash
sudo bash install-safe.sh --apply --auto-domain
```

## Before applying

Review:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
ss -lntup
sudo nft list ruleset
```

Required free public ports:

- TCP 80
- TCP 443

Amnezia UDP ports may remain in use. Docker networks and firewall rules are snapshotted and preserved.

## Rollback material

Each run creates:

```text
/root/3x-ui-safe/state-YYYYMMDD-HHMMSS/
```

It contains:

- Docker container inspection data;
- listeners and routes;
- nftables/iptables exports;
- pre-install configuration archive;
- upstream and patched SHA256 files;
- installation log.

The wrapper does not attempt an automatic rollback because restoring host firewall and Docker state automatically is exactly the sort of cleverness that turns one fault into six.
