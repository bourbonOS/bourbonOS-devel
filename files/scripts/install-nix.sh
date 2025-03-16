#!/usr/bin/env bash

set -oue pipefail
NIX_FACTORY_INSTALL_PATH="/usr/share/factory/var/nix"

mkdir -m 0755 /nix
chown root /nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

mkdir -p $NIX_FACTORY_INSTALL_PATH
mv /nix $NIX_FACTORY_INSTALL_PATH
rm -f /etc/systemd/system/nix-daemon.{service,socket}
cp $NIX_FACTORY_INSTALL_PATH/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/
systemctl enable nix-daemon.socket

semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?'
semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?'
semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?'
semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?'
semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?'
semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?'
semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
semanage fcontext -a -t etc_t '/var/nix/store/[^/]+/etc(/.*)?'
semanage fcontext -a -t lib_t '/var/nix/store/[^/]+/lib(/.*)?'
semanage fcontext -a -t systemd_unit_file_t '/var/nix/store/[^/]+/lib/systemd/system(/.*)?'
semanage fcontext -a -t man_t '/var/nix/store/[^/]+/man(/.*)?'
semanage fcontext -a -t bin_t '/var/nix/store/[^/]+/s?bin(/.*)?'
semanage fcontext -a -t usr_t '/var/nix/store/[^/]+/share(/.*)?'
semanage fcontext -a -t var_run_t '/var/nix/var/nix/daemon-socket(/.*)?'
semanage fcontext -a -t usr_t '/var/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
restorecon -RF /nix