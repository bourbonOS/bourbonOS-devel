#!/bin/bash

set -e pipefail

cshell() {
    if [[ ! -d "$HOME/.config/containerconf" ]]; then
        clear
        if ! getent group wheel > /dev/null; then
            echo "Hello there! Welcome to bourbonOS!"
            echo "We need to do some post-setup for you to access your shell."
            echo "You will be asked for your password in a few seconds. Be ready!"
            sleep 3
            pkexec /usr/libexec/ostools/remove-wheel
        fi
        mkdir -p $HOME/.config/containerconf
    fi
    printf "Starting your shell...\n\n"
    exec /usr/bin/ctsh
}


if [[ -d /var/home/$USER ]]; then
    if [[ "$TERM" == "xterm-256color" ]]; then
        cshell
    elif [[ "$TERM" == "linux" ]]; then
        printf "Would you like to enter host-shell mode?\n\n"
        read -p "[ y/n ]: " debug_ask
        if [[ "$debug_ask" == "y" ]]; then
            exec /usr/bin/ctsh --host
        else
            cshell
        fi
    fi
fi