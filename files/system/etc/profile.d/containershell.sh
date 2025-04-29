#!/bin/bash

set -e pipefail

cshell() {
    if [[ ! -d "$HOME/.config/containerconf" ]]; then
        clear
        echo "Hello there! Welcome to bourbonOS!"
        echo "We need to do some post-setup for you to access your shell."
        echo "You will be asked for your password in a few seconds. Be ready!"
        sleep 3
        pkexec /usr/libexec/ostools/remove_wheel
        echo "Now, for you to access your shell, we need to set up the default container."
        echo "Don't worry! This wont take long."
        echo "The shell will open when we are done."
        sleep 1
        mkdir -p $HOME/.config/containerconf
        /usr/libexec/ostools/loadingbar --msg="We are setting up your shell... this might take a second." --cmd="distrobox-assemble create --file /etc/containerconf/.cherry/cherry.ini"
        exec distrobox-enter cherry-cli
    else
        clear
        printf "Starting your shell...\n\n"
        eval $(atuin init bash)
        exec distrobox-enter cherry-cli
    fi
}

if [[ -d /var/home/$USER ]]; then
    if [[ "$TERM" == "xterm-256color" ]]; then
        cshell
    elif [[ "$TERM" == "linux" ]]; then
        printf "Would you like to enter debug mode? (access to host shell)\n\n"
        read -p "y/n: " debug_ask
        if [[ "$debug_ask" == "y" ]]; then
            exec sh
        else
            cshell
        fi
    fi
fi