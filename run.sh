#!/bin/bash

set -eux -o pipefail

MITAMAE_PATH="/usr/bin/mitamae"
MITAMAE_VERSION="1.6.2"
MITAMAE_CHECKSUM="c3e0a1d3e7dfaac5057cf63c94a0cb34ec5570edbcc164d1a0573130315d3076"
LOG_LEVEL="${LOG_LEVEL:-info}"
OVERRIDES="${OVERRIDES:-}"
NODE_ATTRIBUTES="--node-yaml vars.yml ${OVERRIDES}"

_cleanup() {
  rm -f /tmp/mitamae
}

install_mitamae() {
  trap _cleanup EXIT TERM

  if [ -x "${MITAMAE_PATH}" ] ; then
    if ${MITAMAE_PATH} version | grep -vq ${MITAMAE_VERSION} ; then
      _run_install
    fi
  else
    _run_install
  fi
}

_run_install() {
  wget -O /tmp/mitamae "https://github.com/itamae-kitchen/mitamae/releases/download/v${MITAMAE_VERSION}/mitamae-x86_64-linux" &&
  echo "${MITAMAE_CHECKSUM}  /tmp/mitamae" | sha256sum -c - &&
  sudo install -m 0755 /tmp/mitamae "${MITAMAE_PATH}"
}

install_mitamae

(
  cd mitamae/
  # shellcheck disable=SC2086
  sudo mitamae local -l "${LOG_LEVEL}" ${NODE_ATTRIBUTES} mitamae.rb
)
