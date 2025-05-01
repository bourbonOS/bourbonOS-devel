#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

# setup Transit

echo "session         required        pam_transit.so" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so" >> /usr/share/authselect/default/local/postlogin

touch /etc/transit-id
chown root:root /etc/transit-id
chmod 700 /etc/transit-id

mkdir -p /etc/skel/.ssh/

dnf -y install make gcc pam-devel

cd /Transit
make
make install
rm -rf /Transit
cd /

dnf -y remove make gcc pam-devel

# setup CLI

chmod 755 /etc/subsystem
podman build -t localhost/subsystem:latest /etc/subsystem