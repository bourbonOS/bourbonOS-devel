#!/usr/bin/env bash

set -oue pipefail

sh <(curl -L https://nixos.org/nix/install) --daemon --yes

mkdir /etc/.nix-mount-temp
mv /nix /etc/.nix-mount-temp
mkdir /nix /etc/systemd/system/gdm.service.d/

cat <<EOF > /etc/systemd/system/gdm.service.d/override.conf
[Unit]
After=homefs-setup.service
Requires=homefs-setup.service
EOF