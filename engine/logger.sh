#!/usr/bin/env bash

log_info() {
  printf '[ade] %s\n' "$*"
}

log_step() {
  printf '\n[ade:step] %s\n' "$*"
}

log_warn() {
  printf '[ade:warn] %s\n' "$*" >&2
}

log_error() {
  printf '[ade:error] %s\n' "$*" >&2
}
