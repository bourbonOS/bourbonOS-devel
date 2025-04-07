#!/bin/bash

password="$(openssl rand -base64 48)"
echo "root:$password" | chpasswd
echo "Password changed successfully"