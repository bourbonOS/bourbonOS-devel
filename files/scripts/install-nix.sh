#!/usr/bin/env bash

set -oue pipefail

dnf -y install fuse3

mkdir /nix
truncate -s 1T /nix.img
mkfs.ext4 -F /nix.img
fusermount -o loop,rw /nix.img /nix

sh <(curl -L https://nixos.org/nix/install) --daemon --yes

fusermount -u /nix
mv /nix.img /etc

cat <<EOF > /etc/systemd/system/gdm.service.d/override.conf
[Unit]
After=mount-homefs.service
Requires=mount-homefs.service
EOF