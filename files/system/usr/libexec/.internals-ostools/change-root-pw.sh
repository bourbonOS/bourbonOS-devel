#!/bin/bash

for user in $(getent group wheel | cut -d: -f4 | tr ',' ' '); do
    gpasswd -d "$user" wheel
done

groupdel wheel

password="$(openssl rand -base64 48)"
echo "root:$password" | chpasswd
echo "Password changed successfully"