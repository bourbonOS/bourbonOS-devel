#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

# Setup Transit

echo "session         required        pam_transit.so" >> /usr/share/authselect/default/sssd/postlogin
echo "session         required        pam_transit.so" >> /usr/share/authselect/default/local/postlogin

touch /etc/transit/transit-id
chown root:root /etc/transit/transit-id
chmod 700 /etc/transit/transit-id

# Compile stuff

dnf -y install make cargo rust gcc pam-devel

cd /Transit
make
make install
rm -rf /Transit
cd /ctsh
cargo build --release
install -Dm755 ./target/release/ctsh /usr/bin
rm -rf /ctsh
cd /

dnf -y remove make cargo rust gcc pam-devel

# Setup subsystem user

groupadd -r -g 173 bourbon-subsys
useradd -r -u 173 -g 173 -s /sbin/nologin -m -c "User for subsystem" bourbon-subsys
