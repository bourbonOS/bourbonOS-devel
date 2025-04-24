#!/usr/bin/env bash

set -oue pipefail

OPEN_SES="session     required type=open_session                   pam_exec.so /usr/libexec/homefs/manage_homedir	--mount"
CLOSE_SES="session     required type=close_session                  pam_exec.so /usr/libexec/homefs/manage_homedir	--umount"

echo "$OPEN_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$OPEN_SES" >> /usr/share/authselect/default/local/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/local/postlogin

authselect apply-changes