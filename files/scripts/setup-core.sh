#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

systemctl daemon-reload
systemctl enable subsystem.service

echo "session         required        pam_transit.so" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so" >> /usr/share/authselect/default/local/postlogin

touch /etc/transit/transit-id
chown root:root /etc/transit/transit-id
chmod 700 /etc/transit/transit-id

dnf -y install make gcc pam-devel

cd /Transit
make
make install
rm -rf /Transit
cd /

dnf -y remove make gcc pam-devel