#!/bin/bash

if [[ -d /etc/.nix-mount-temp ]]; then
    mv /etc/.nix-mount-temp/nix /var/usrlocal
    rmdir /etc/.nix-mount-temp
else
    echo "nothing to do!!"
fi