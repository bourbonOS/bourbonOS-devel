#!/usr/bin/env bash

set -oue pipefail

echo "session    required    pam_exec.so    type=open_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/system-auth
echo "session    required    pam_exec.so    type=close_session    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/system-auth

echo "$(date +%s)" > /etc/last_update_run
