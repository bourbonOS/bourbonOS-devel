#!/usr/bin/env bash

set -oue pipefail
NIX_FACTORY_INSTALL_PATH="/usr/share/factory/var"

mkdir -m 0755 /nix
chown root /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

mkdir -p $NIX_FACTORY_INSTALL_PATH
mv /nix $NIX_FACTORY_INSTALL_PATH
sed -i '/^\[Unit\]/a BindsTo=nix.mount\nAfter=nix.mount' /etc/systemd/system/nix-daemon.{service,socket}