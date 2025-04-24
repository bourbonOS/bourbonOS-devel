#!/usr/bin/env bash

set -oue pipefail

OPEN_SES="session         required        pam_homefs.so mount"
CLOSE_SES="session         required        pam_homefs.so unmount"

if rpm -q gdm > /dev/null; then
    for FILE in /etc/pam.d/gdm-*; do
        echo "$OPEN_SES" >> $FILE
        echo "$CLOSE_SES" >> $FILE
    done
elif rpm -q sddm > /dev/null
    set -x
    ls -lah /etc/pam.d
    set +x
    exit 1
fi

for FILE in login sshd remote; do
    echo $OPEN_SES >> /etc/pam.d/$FILE
    echo $CLOSE_SES >> /etc/pam.d/$FILE
done

dnf -y install make gcc pam-devel

cd /usr/homefs-module/
make install
rm -rf /usr/homefs-module/
cd /

dnf -y remove make gcc pam-devel