#!/usr/bin/env bash

set -oue pipefail

mkdir -m 0755 /nix
chown root /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes