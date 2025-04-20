#!/usr/bin/env bash

set -oue pipefail

echo "session    required    pam_exec.so    /usr/libexec/homefs/manage_homedir" >> /etc/pam.d/common-session