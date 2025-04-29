#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

echo "session         required        pam_transit.so mount" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so unmount" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so mount" >> /usr/share/authselect/default/local/postlogin
echo "session         required        pam_transit.so unmount" >> /usr/share/authselect/default/local/postlogin

touch /etc/transit-id
chown root:root /etc/transit-id
chmod 700 /etc/transit-id

dnf -y install make gcc pam-devel

cd /Transit
make install
rm -rf /Transit
cd /

dnf -y remove make gcc pam-devel