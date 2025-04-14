#!/bin/bash

LOOPFS_DIR="/var/usrlocal/loopfs"
HOMEFS_IMG="$LOOPFS_DIR/homefs.img"
NIX_IMG="/etc/nix.img"
LOOPFS_NIX_IMG="$LOOPFS_DIR/nixfs.img"
HOME_DIR="/var/home"
MOUNT_POINT="/tmp/homefs"
SALT_FILE="$LOOPFS_DIR/.homefs-salt"
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
    echo "Encrypted homefs mounted on $HOME_DIR"

    if [[ -f "$LOOPFS_NIX_IMG" ]]; then
        echo "Mounting nix image..."
        mount -o loop "$LOOPFS_NIX_IMG" /nix
        echo "Nix image mounted on /nix"
    fi
else
    echo "Setting up encrypted homefs..."
    if [[ -d "$LOOPFS_DIR" ]]; then
        echo "$LOOPFS_DIR already exists. Exiting setup."
        exit 0
    fi

    mkdir -p "$LOOPFS_DIR"
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
    if [[ -f "$NIX_IMG" ]]; then
        if [[ -f "$LOOPFS_NIX_IMG" ]]; then
            echo "Removing image-supplied $NIX_IMG"
            rm -f "$NIX_IMG"
        else
            echo "Moving $NIX_IMG to $LOOPFS_DIR"
            mkdir -p "$LOOPFS_DIR"
            mv "$NIX_IMG" "$LOOPFS_NIX_IMG"
        fi
    else
        echo "Nothing to do."
    fi

    echo "Mounting..."
    systemctl restart mount-loopfs.service
fi