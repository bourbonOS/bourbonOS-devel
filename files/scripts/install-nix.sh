#!/usr/bin/env bash

set -oue pipefail

useradd -r -s /bin/false -M synergy-nix-rwx

mkdir /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

mv /nix /ostree/deploy/fedora/var/
mkdir /nix