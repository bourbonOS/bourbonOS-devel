#!/usr/bin/env bash

set -oue pipefail

echo "session    required    pam_exec.so    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/common-session
echo "overlay  /nix  overlay  workdir=/var/usrlocal/nixfs/work,upperdir=/var/usrlocal/nixfs/upper,lowerdir=/usr/nix  0  0" >> /etc/fstab