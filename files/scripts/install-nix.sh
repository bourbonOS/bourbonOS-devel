#!/usr/bin/env bash

set -oue pipefail

dnf -y install fuse3
truncate -s 1T /nix.img
mkfs.ext4 -F /nix.img
mkdir -p /nix-fs
ext4fuse /nix.img /nix-fs
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
fusermount -u /nix-fs
dnf -y remove fuse3

mv /nix.img /etc/