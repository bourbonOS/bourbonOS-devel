#!/usr/bin/env bash

set -oue pipefail

echo "::group:: Install Nix"

mkdir /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

mv /nix /usr/
mkdir /nix

echo "::endgroup::"