#!/bin/bash

set -e pipefail

if [[ -d /var/home/$USER ]]; then
    if [[ "$TERM" == "linux" ]]; then
        printf "Would you like to enter host-shell mode?\n\n"
        read -p "[ y/n ]: " debug_ask
        if [[ "$debug_ask" == "n" ]]; then
            /usr/libexec/ostools/init-subsystem
        else
            clear
            echo "WARNING"
            echo "You are now in a shell running on the host system."
            echo "Please be cautious."
            exec /bin/sh
        fi
    else
        /usr/libexec/ostools/init-subsystem
    fi
fi