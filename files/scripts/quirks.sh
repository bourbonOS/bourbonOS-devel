#!/usr/bin/env bash

set -oue pipefail

echo "$(date +%s)" > /etc/last_update_run
chmod +x -R /tmp/osrelease/*

if cat /etc/os-release | grep 'ID="fedora"' > /dev/null; then
    /tmp/misc/image-info-stable.sh
elif cat /etc/os-release | grep 'ID="centos"' > /dev/null; then
    /tmp/misc/image-info-lts.sh
    /tmp/misc/repo-setup-lts.sh
else
    echo "Unknown OS type. Abort."
    exit 1
fi