#!/usr/bin/env sh

# Copy busybox
sudo install -m 755 busybox/busybox "$ROOTFS_MNT/bin/busybox"
# Symlink important tools, can manually symlink or use busybox install later
# Getty must be a hardlink to be used as init
sudo ln "$ROOTFS_MNT/bin/busybox" "$ROOTFS_MNT/sbin/getty"
sudo ln -s ../bin/busybox "$ROOTFS_MNT/sbin/mount"
sudo ln -s ../bin/busybox "$ROOTFS_MNT/sbin/umount"
sudo cp -r ncurses/build/share/terminfo/ "$ROOTFS_MNT/share/"
sudo cp -r .emacs.d "$ROOTFS_MNT/"
sudo cp shutdown/shutdown "$ROOTFS_MNT/sbin/shutdown"
sudo ln -s shutdown "$ROOTFS_MNT/sbin/reboot"
if [ -e "./ffmpeg/bin/ffmpeg" ]; then
    sudo cp ffmpeg/bin/ffmpeg "$ROOTFS_MNT/bin/ffmpeg"
fi
