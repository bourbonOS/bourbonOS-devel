#!/usr/bin/env bash

set -oue pipefail

mkdir /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
