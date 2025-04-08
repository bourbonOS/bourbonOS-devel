#!/bin/bash

if [[ -d /var/home/$USER ]]; then
    if [[ "$TERM" == "xterm-256color" ]]; then
        if [[ ! -d "$HOME/.config/containerconf" ]]; then
            echo "Hello there! Welcome to bourbonOS!"
            if getent group wheel > /dev/null 2>&1; then
                echo "Please set your root password."
                echo "Be careful to not lose this password, otherwise"
                echo "you will lose root access entirely."
                run0 passwd root
                grep "^wheel:" /etc/group | cut -d':' -f4 | while IFS=',' read -r user; do
                    sudo gpasswd --delete "$user" wheel
                done
                sudo groupdel wheel
            fi
            echo "Now, for you to access your shell, we need to set up the default container."
            echo "Don't worry! This wont take long."
            echo "The shell will open when we are done."
            mkdir -p $HOME/.config/containerconf
            exec distrobox-assemble create --file /etc/containerconf/.cherry/cherry.ini
        else
            echo "Starting your shell...."
            exec distrobox-enter cherry-cli
        fi
    elif [[ "$TERM" == "linux" ]]; then
        echo "Would you like to enter debug mode? (host shell)"
        read -p "y/n: " debug_ask
        if [[ "$debug_ask" == "y" ]]; then
            exec sh
        else
            if [[ ! -d "$HOME/.config/containerconf" ]]; then
                echo "Hello there! Welcome to bourbonOS!"
                echo "For you to access your shell, we need to set up the default container."
                echo "Don't worry! This wont take long."
                echo "The shell will open when we are done."
                mkdir -p $HOME/.config/containerconf
                exec distrobox-assemble create --file /etc/containerconf/.cherry/cherry.ini
            else
                echo "Starting your shell...."
                exec distrobox-enter cherry-cli
            fi
        fi
    fi
fi