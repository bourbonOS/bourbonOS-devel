#!/bin/bash

if [[ -f /etc/nix.img ]]; then
    mkdir /var/usrlocal/nix
    mv /etc/nix.img /var/usrlocal/nix/
else
    echo "nothing to do!!"
fi