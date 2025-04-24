#!/usr/bin/env bash

set -oue pipefail

open_session_line="session     required type=open_session                   pam_exec.so /usr/libexec/homefs/manage_homedir	--mount"
close_session_line="session     required type=close_session                  pam_exec.so /usr/libexec/homefs/manage_homedir	--umount"
current_auth_profile=$(authselect current | awk '{print $3}' | head -n 1)

echo $open_session_line >> /usr/share/authselect/default/$current_auth_profile/system-auth
echo $close_session_line >> /usr/share/authselect/default/$current_auth_profile/system-auth

authselect select $current_auth_profile
authselect apply-changes
