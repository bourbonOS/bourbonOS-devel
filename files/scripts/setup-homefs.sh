#!/usr/bin/env bash

set -oue pipefail

OPEN_SES="session         required        pam_exec.so type=open /usr/libexec/homefs/manage_homedir --mount"
CLOSE_SES="session         required        pam_exec.so type=close /usr/libexec/homefs/manage_homedir --unmount"

echo "$OPEN_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$OPEN_SES" >> /usr/share/authselect/default/local/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/local/postlogin