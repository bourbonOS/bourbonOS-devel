#!/usr/bin/env bash

set -oue pipefail

mkdir /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

cat <<EOF > /etc/systemd/system/gdm.service.d/override.conf
[Unit]
After=mount-loopfs.service
BindsTo=mount-loopfs.service
EOF