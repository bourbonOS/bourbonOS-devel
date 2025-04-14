#!/bin/bash

HOEMFS_DIR="/var/usrlocal/homefs"
HOMEFS_IMG="$HOMEFS_DIR/homefs.img"
HOME_DIR="/var/home"
MOUNT_POINT="/tmp/homefs"
SALT_FILE="$HOMEFS_DIR/.homefs-salt"
KEY_PREFIX="homefs"

get_hwid() {
    local vendor=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null || echo "no-vendor")
    local sku=$(cat /sys/class/dmi/id/product_sku 2>/dev/null || echo "no-sku")
    echo "${vendor}${sku}"
}

get_key_material() {
    local salt="$1"
    local hwid=$(get_hwid)
    echo -n "${salt}${hwid}" | sha256sum | cut -d' ' -f1
}

if [[ "$1" == "--mount-all" ]]; then
    echo "Mounting homefs+nixfs..."
    local salt=$(cat "$SALT_FILE")
    local key_desc="${KEY_PREFIX}-mount-$salt"
    local key_material=$(get_key_material "$salt")
    local loopdev

    keyctl add user "$key_desc" "$key_material" @u

    loopdev=$(losetup -f)
    echo -n "$key_material" | losetup -e AES256 -p 0 "$loopdev" "$HOMEFS_IMG"
    mount "$loopdev" "$HOME_DIR"
    mount -t overlay overlay -o lowerdir=/nix,upperdir=/var/usrlocal/nixfs/upper,workdir=/var/usrlocal/nixfs/work /nix
    echo "homefs+nixfs mounted successfully."
else
    echo "Setting up encrypted homefs..."
    if [[ -d "$HOMEFS_DIR" ]]; then
        echo "$HOMEFS_DIR already exists. Exiting setup."
        exit 0
    fi

    mkdir -p "$HOMEFS_DIR"
    openssl rand -hex 12 > "$SALT_FILE"
    chmod 700 "$SALT_FILE"

    local max_size=$(df -h "$HOME_DIR" | awk 'NR==2 {print $2}')
    local salt=$(cat "$SALT_FILE")
    local key_desc="${KEY_PREFIX}-mountkey-$salt"
    local key_material=$(get_key_material "$salt")
    local loopdev

    keyctl add user "$key_desc" "$key_material" @u

    truncate -s "$max_size" "$HOMEFS_IMG"
    loopdev=$(losetup -f)
    echo -n "$key_material" | losetup -e AES256 -p 0 "$loopdev" "$HOMEFS_IMG"
    mkfs.ext4 -F "$loopdev"
    mount "$loopdev" "$MOUNT_POINT"
    mv "$HOME_DIR"/* "$MOUNT_POINT"/
    umount "$MOUNT_POINT"
    losetup -d "$loopdev"

    echo "Setting home directory permissions..."
    for USER_DIR in "$HOME_DIR"/*; do
        if [[ -d "$USER_DIR" ]]; then
            local username=$(basename "$USER_DIR")
            chown "$username:$username" "$USER_DIR"
            chmod 700 "$USER_DIR"
            restorecon -Rv "$USER_DIR"
        fi
    done

    echo "Setting up nixfs..."
    mkdir -p /var/usrlocal/nixfs/{,work,upper}

    echo "Mounting all..."
    systemctl restart mount-loopfs.service gdm.service nix-daemon.socket semanage-nix.service
fi