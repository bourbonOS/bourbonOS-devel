#!/usr/bin/env bash

set -oue pipefail
set +x

ls /sysroot/ -lah

echo "session    required    pam_exec.so    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/common-session
echo "/var/ostools/nix  /nix  none  bind  0  0" >> /etc/fstab

mkdir /ostree/deploy/fedora/var/ostools/{,homefs}