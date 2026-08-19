#!/usr/bin/env bash

########## Copyright C 2026 MIT Emad-ms ##########

# project: yuz-os builder module
# project git : https://github.com/emad1234-msoudi/Yuz-OS_edu

# module/build/config.sh
# script for build module to config live build

########### setup environment ##########

# source "../../bootstrap.sh" #-> tihs source just for development

set -Eeuo pipefail

########## setup config ##########

lb config \
  --distribution "$LB_DISTRIBUTION" \
  --architectures "$LB_ARCHITECTURE" \
  --linux-flavours "$LB_ARCHITECTURE" \
  --binary-images iso-hybrid \
  --debian-installer none \
  --archive-areas "$LB_ARCHIVE_AREAS" \
  --mirror-bootstrap "$LB_MIRROR" \
  --mirror-chroot "$LB_MIRROR" \
  --mirror-binary "$LB_MIRROR" \
  --mirror-chroot-security "$LB_MIRROR_SECURITY" \
  --mirror-binary-security "$LB_MIRROR_SECURITY" \
  --bootloaders "grub-efi grub-pc" \
  --chroot-squashfs-compression-type "$LB_CHROOT_COMPRESSION" \
  --compression "$LB_COMPRESSION" \
  --initramfs-compression "$LB_INITRAMFS_COMPRESSION" \
  --firmware-chroot "$LB_ENABLE_FIRMWARE" \
  --firmware-binary "$LB_ENABLE_FIRMWARE" \
  --image-name "$LB_IMAGE_NAME" \
  --iso-volume "$LB_VOLUME_NAME" \
  --iso-publisher "$PROJECT_PUBLISHER <$PROJECT_PUBLISHER_URL>" \
  --iso-application "$PROJECT_PRETTY_NAME" \
  --bootappend-live "boot=live components persistence quiet splash locales=en_US.UTF-8 keyboard-layouts=us" \
  --bootappend-install "quiet splash" \
  --cache "$LB_ENABLE_CACHE" \
  --cache-packages "$LB_ENABLE_CACHE" \
  --cache-indices "$LB_ENABLE_CACHE" \
  --apt-secure true \
  --color \
  --verbose \
  --checksums sha256 \
  --uefi-secure-boot auto \
  --memtest none \
  --zsync true 

########## end ##########
