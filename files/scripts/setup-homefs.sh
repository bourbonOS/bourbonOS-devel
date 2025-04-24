#!/usr/bin/env bash

set -oue pipefail

OPEN_SES="session         required        pam_homefs.so mount"
CLOSE_SES="session         required        pam_homefs.so unmount"

echo "$OPEN_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$OPEN_SES" >> /usr/share/authselect/default/local/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/local/postlogin

cd /usr/tmp-homefs-module/
make install
rm -rf /usr/tmp-homefs-module/
cd /