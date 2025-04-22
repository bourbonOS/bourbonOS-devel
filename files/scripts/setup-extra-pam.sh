#!/usr/bin/env bash

set -oue pipefail

if rpm -q gdm > /dev/null 2>&1; then
    echo "session    required    pam_exec.so    type=open_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/gdm-password
    echo "session    required    pam_exec.so    type=close_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/gdm-password
elif rpm -q sddm > /dev/null 2>&1; then
    echo "session    required    pam_exec.so    type=open_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/sddm
    echo "session    required    pam_exec.so    type=close_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/sddm
else
    echo "No extra PAM config needed!"
fi