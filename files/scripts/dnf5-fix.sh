#!/usr/bin/env bash

set -oue pipefail

dnf5 -y install 'dnf5-command(copr)'
dnf5 -y copr enable chronos/cherries
