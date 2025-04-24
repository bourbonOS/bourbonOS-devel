#!/usr/bin/env bash

set -oue pipefail
shopt -s extglob

OPEN_SES="session         required        pam_homefs.so mount"
CLOSE_SES="session         required        pam_homefs.so unmount"
PAMDIR="/etc/pam.d"

if rpm -q gdm > /dev/null; then
    for FILE in "$PAMDIR/gdm-@(!launch-environment)"; do
        echo "$OPEN_SES" >> $FILE
        echo "$CLOSE_SES" >> $FILE
    done
elif rpm -q sddm > /dev/null; then
    for FILE in $PAMDIR/sddm*; do
        echo "$OPEN_SES" >> $FILE
        echo "$CLOSE_SES" >> $FILE
    done   
fi

for FILE in login sshd remote; do
    echo $OPEN_SES >> $PAMDIR/$FILE
    echo $CLOSE_SES >> $PAMDIR/$FILE
done

dnf -y install make gcc pam-devel

cd /usr/homefs-module/
make install
rm -rf /usr/homefs-module/
cd /

dnf -y remove make gcc pam-devel