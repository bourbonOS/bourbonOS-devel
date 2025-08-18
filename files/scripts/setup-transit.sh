#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

dnf -y install make gcc pam-devel

cd /build/Transit
make
make install
rm -rf /build/Transit

dnf -y remove make gcc pam-devel

echo "session         required        pam_transit.so" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so" >> /usr/share/authselect/default/local/postlogin

touch /etc/transit/transit-id
chown root:root /etc/transit/transit-id
chmod 700 /etc/transit/transit-id