#!/usr/bin/env sh

# Copy busybox
install -m 755 busybox/busybox "$ROOTFS_MNT/bin/busybox"
# Symlink important tools, can manually symlink or use busybox install later
ln -s "$ROOTFS_MNT/bin/busybox" "$ROOTFS/sbin/getty"
ln -s "$ROOTFS_MNT/bin/busybox" "$ROOTFS/sbin/mount"
ln -s "$ROOTFS_MNT/bin/busybox" "$ROOTFS/sbin/umount"
