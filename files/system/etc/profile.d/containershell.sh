#!/bin/bash

if [[ "$TERM" != "xterm-256color" && -d /var/home/$USER ]]; then
    if [ ! -d "$HOME/.config/containerconf" ]; then
        echo "Hello there! Welcome to bourbonOS!"
        echo "For you to access your shell, we need to set up the default container."
        echo "Don't worry! This wont take long."
        echo "The shell will open when we are done."
        mkdir -p $HOME/.config/containerconf
        exec distrobox-assemble create --file /etc/containerconf/configs.d/.cherry/cherry.ini
    else
        echo "Starting your shell...."
        exec distrobox-enter cherry-cli
    fi
fi