#!/usr/bin/env bash

set -oue pipefail

ls /usr/etc/skel
exit 1

rm /etc/dnf/protected.d/sudo.conf
