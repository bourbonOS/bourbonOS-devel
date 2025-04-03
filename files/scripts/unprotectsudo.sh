#!/usr/bin/env bash

set -oue pipefail

rm /etc/dnf/protected.d/sudo.conf
set +x
ls /home
ls /var/home
set -x
