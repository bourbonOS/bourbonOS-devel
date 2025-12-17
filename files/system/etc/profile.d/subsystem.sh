#!/bin/bash

set -e pipefail

if [[ -d /var/home/$USER ]]; then
    if [[ "$TERM" == "linux" ]]; then
        printf "Would you like to enter host-shell mode?\n\n"
        read -p "[ y/n ]: " debug_ask
        if [[ "$debug_ask" == "n" ]]; then
            pkexec --user subsys exec /usr/libexec/ostools/enter-subsystem --subsys-user="$USER" --subsys-user-uid="$(id -u)" --subsys-user-gid="$(id -g)"
        else
            clear
            echo "WARNING"
            echo "You are now in a shell running on the host system."
            echo "Please be cautious."
            exec /bin/sh
        fi
    else
        pkexec --user subsys /usr/libexec/ostools/enter-subsystem --subsys-user="$USER" --subsys-user-uid="$(id -u)" --subsys-user-gid="$(id -g)"
    fi
fi