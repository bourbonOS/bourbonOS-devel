#!/usr/bin/env bash

set -oue pipefail

open_session_line="session    required    pam_exec.so    type=open_session    /usr/libexec/homefs/manage_homedir --mount"
close_session_line="session    required    pam_exec.so    type=close_session    /usr/libexec/homefs/manage_homedir --umount"
current_profile=$(authselect current)
custom_profile="homefs-auth"

[[ -z "$current_profile" ]] && { echo "Error: Could not determine the current authselect profile."; exit 1; }

if ! authselect show "$custom_profile" >/dev/null 2>&1; then
    authselect create-profile "$custom_profile" -b "$current_profile"
fi

authselect select "$custom_profile" -f
custom_profile_dir="/etc/authselect/$custom_profile/$current_profile"
session_config_file="$custom_profile_dir/session"
[[ ! -d "$custom_profile_dir" ]] && { echo "Error: Custom profile directory '$custom_profile_dir' not found."; exit 1; }
[[ ! $(grep -qF "$open_session_line" "$session_config_file") ]] && echo "$open_session_line" | sudo tee -a "$session_config_file" > /dev/null
[[ ! $(grep -qF "$close_session_line" "$session_config_file") ]] && echo "$close_session_line" | sudo tee -a "$session_config_file" > /dev/null

authselect apply

echo "$(date +%s)" > /etc/last_update_run