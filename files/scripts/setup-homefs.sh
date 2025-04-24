#!/usr/bin/env bash

set -oue pipefail

OPEN_SES="session         required        pam_homefs.so mount"
CLOSE_SES="session         required        pam_homefs.so unmount"

echo "$OPEN_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/sssd/postlogin
echo "$OPEN_SES" >> /usr/share/authselect/default/local/postlogin
echo "$CLOSE_SES" >> /usr/share/authselect/default/local/postlogin

cd /tmp/homefs_module
make install
rm -rf /tmp/homefs_module
cd /