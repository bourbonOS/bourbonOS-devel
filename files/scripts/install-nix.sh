#!/usr/bin/env bash

set -oue pipefail

# vars
MOUNT_POINT="/nix"
IMAGE_FILE="/nix-mount.imgfs"
MAX_SIZE_GB=100
INITIAL_SIZE_GB=1
BLOCK_SIZE=4096
MKFS_OPTIONS="-F"
TMP_NIX_DIR="/etc/.nix-mount-temp"

# functions
create_nix_dir() {
  echo "Creating directory: ${MOUNT_POINT}"
  mkdir -p "${MOUNT_POINT}"
  chmod 0755 "${MOUNT_POINT}"
  chown root "${MOUNT_POINT}"
  if [ $? -ne 0 ]; then
    echo "Error creating directory ${MOUNT_POINT}"
    exit 1
  fi
}

create_sparse_image() {
  echo "Creating sparse image file: ${IMAGE_FILE} (initial size ${INITIAL_SIZE_GB}G, max size ${MAX_SIZE_GB}G)"
  truncate -s "${INITIAL_SIZE_GB}G" "${IMAGE_FILE}"
  if [ $? -ne 0 ]; then
    echo "Error creating image file ${IMAGE_FILE}"
    exit 1
  fi
}

format_image() {
  echo "Formatting image file ${IMAGE_FILE} as ext4"
  mkfs.ext4 ${MKFS_OPTIONS} "${IMAGE_FILE}"
  if [ $? -ne 0 ]; then
    echo "Error formatting image file ${IMAGE_FILE}"
    exit 1
  fi
}

loop_mount_image() {
  echo "Loop mounting ${IMAGE_FILE} to ${MOUNT_POINT}"
  mount -o loop "${IMAGE_FILE}" "${MOUNT_POINT}"
  if [ $? -ne 0 ]; then
    echo "Error loop mounting ${IMAGE_FILE} to ${MOUNT_POINT}"
    exit 1
  fi
}

# cre nix dir
create_nix_dir
# cre ext4 img
create_sparse_image
format_image
# mount img
loop_mount_image

echo "file ${IMAGE_FILE} (max size ${MAX_SIZE_GB}G) is now mounted at ${MOUNT_POINT}."
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
unmount /nix
mkdir $TMP_NIX_DIR
mv /nix-mount.imgfs $TMP_NIX_DIR