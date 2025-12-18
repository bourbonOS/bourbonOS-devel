#!/usr/bin/env bash

set -oue pipefail

useradd --system --no-create-home --shell /usr/sbin/nologin subsys

curl -Lo /etc/containers/default.container https://github.com/bourbonOS/cherries/releases/download/container-v2/default.container