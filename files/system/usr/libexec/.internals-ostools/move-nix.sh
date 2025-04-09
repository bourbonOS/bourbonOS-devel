#!/bin/bash

if [[ -d /etc/.nix-mount-temp ]]; then
    mv /etc/.nix-mount-temp/nix /var/usrlocal/
    rmdir /etc/.nixmount-temp
else
    echo "nothing to do!!"
fi