#!/usr/bin/env bash

set -oue pipefail

if rpm -q gdm > /dev/null; then
    LOGIN_MANAGER="gdm"
elif rpm -q sddm > /dev/null; then
    LOGIN_MANAGER="sddm"
else
    echo "No supported login manager detected. Abort."
    exit 1
fi

echo "session     required type=open_session                   pam_exec.so /usr/libexec/homefs/manage_homedir	--mount" >> /etc/pam.d/$LOGIN_MANAGER
echo "session     required type=close_session                  pam_exec.so /usr/libexec/homefs/manage_homedir	--umount" >> /etc/pam.d/$LOGIN_MANAGER